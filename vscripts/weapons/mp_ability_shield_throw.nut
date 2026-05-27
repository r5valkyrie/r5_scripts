global function MpAbilityShieldThrow_Init
global function OnWeaponActivate_ability_shield_throw
global function OnWeaponAttemptOffhandSwitch_ability_shield_throw
global function OnWeaponToss_ability_shield_throw
global function OnWeaponTossPrep_ability_shield_throw
global function OnWeaponTossReleaseAnimEvent_ability_shield_throw

global function IsMobileShieldEnt
global function MobileShield_IsAllowedStickyEnt
global function CodeCallback_ScriptMoverTraversalStopped

#if SERVER
global function ClientCallback_AttemptChangeShieldDirection
#endif

#if CLIENT
global function ServerToClient_ShieldThrowToggleHint
global function ServerToClient_MobileShield_Complete
global function ServerToClient_UpdateShieldStopState
#endif

global const string SHIELD_THROW_SCRIPTNAME 		= "shield_throw"
global const string MOBILE_SHIELD_SCRIPTNAME 		= "mobile_shield"


//Shield Throw Variables
const asset SHIELD_MODEL 							= $"mdl/props/newcastle_tactical_prop/newcastle_tactical_v21_base_w.rmdl" //$"mdl/props/octane_jump_pad/octane_jump_pad.rmdl"
const float SHIELD_THROW_POWER 						= 1 //50 <- This is handled in the txt file now.
const float SHIELD_THROW_DURATION 					= 20.0
const float SHIELD_THROW_WARNING_DURATION 			= 3.0
const float SHIELD_THROW_HOVER_HEIGHT 				= 50.0

const float SHIELD_THROW_TEST_STEP 					= 64.0	// Test Distance for Movement. Mover will set next position this far ahead. (will affect overall speed)
const float SHEILD_THROW_DROP_HEIGHT_MAX			= 200.0 // Shield will consider any drop beyond this height too steep and trigger a STOP instead of floating.
const float SHIELD_HOVER_HEIGHT						= 40.0
const float SHIELD_GROUND_CHECK_DIST				= 3000.0


//Mobile Shield Variables
const MOBILE_SHIELD_MODEL 							= $"mdl/fx/newcastle_tac_hex_shield.rmdl"
const MOBILE_SHIELD_FX 								= $"P_NC_shield_hex_CP"
const MOBILE_SHIELD_TOP_MODEL 						= $"mdl/fx/newcastle_tac_hex_shield.rmdl"
const MOBILE_SHIELD_TOP_FX 							= $"P_NC_shield_hex_CP_top"
const MOBILE_SHIELD_DRONE_PROJECTOR_FX				= $"P_NC_shield_drone_projector"
const MOBILE_SHIELD_DRONE_ENGINE_FX					= $"P_NC_shield_drone_engine"
const MOBILE_SHIELD_DRONE_WARNING_FX				= $"P_nc_drone_warning"

const MOBILE_SHIELD_DRONE_HEALTH					= 150	//Drone cannot be shot
const MOBILE_SHIELD_WALL_HEALTH 					= 500	//350	//400
const float MOBILE_SHIELD_SPEED						= 160	//80
                    
const int MOBILE_SHIELD_WALL_HEALTH_UPGRADED		= 750
const float MOBILE_SHIELD_SPEED_UPGRADED			= 250
      

const vector MOBILE_SHIELD_FX_COLOR 				= < 40, 210, 255 >
const vector MOBILE_SHIELD_ENEMY_FX_COLOR 			= < 255, 100, 12 >
const vector MOBILE_SHIELD_AR_MARKER_COLOR			= < 64, 220, 255 >
const vector MOBILE_SHIELD_ENEMY_PROJECTOR_FX_COLOR	= < 255, 150, 12 >

const string MOBILE_SHIELD_PROPULSION_SFX_3P 		= "Newcastle_Tactical_ShieldActivation"
const string MOBILE_SHIELD_COMMAND_SFX_3P 			= "Newcastle_Tactical_Command"
const string MOBILE_SHIELD_STOP_SFX_3P 				= "Char_11_TacticalA_Recall_3p"
const string MOBILE_SHIELD_WARNING_SFX_3P			= "Newcastle_Tactical_ShieldPower_Shutdown"
const string MOBILE_SHIELD_DISSOLVE_SFX_3P			= "Newcastle_Drone_dissolve" // Test SFX > "Newcastle_Tactical_ShieldPower_Shutdown"
const string MOBILE_SHIELD_DESTROY_SFX_1P 			= "Newcastle_Tactical_ShieldBreak" // Test SFX > "wattson_tactical_m_1p"
const string MOBILE_SHIELD_DESTROY_SFX_3P 			= "Newcastle_Tactical_ShieldBreak_3p" // Test SFX > "wattson_tactical_m_3p"

const float MOBILE_SHIELD_UPDATE_CHATTER_BUFFER 			= 8
const string MOBILE_SHIELD_TACTICAL_ADJUST_POSITION_VO_1P 	= "diag_mp_newcastle_bc_tacticalAdjust_1p"
const string MOBILE_SHIELD_TACTICAL_ADJUST_POSITION_VO_3P 	= "diag_mp_newcastle_bc_tacticalAdjust_3p"

// Move To Position Variables //
const MOBILE_SHIELD_AR_MARKER 						= $"P_ar_ping_squad_CP"
const float MOBILE_SHIELD_TRACE_DIST 				= 2000.0
const float MOBILE_SHIELD_IGNORE_CLIFF_RESET_DELAY	= 3.0

const vector MOBILE_SHIELD_INVALID_PLACEMENT_MIN_AREA 	= <-15,-15,-50>
const vector MOBILE_SHIELD_INVALID_PLACEMENT_MAX_AREA 	= <15,15,50>
const float MOBILE_SHIELD_WP_DRAW_DIST_MIN 				= 100 			//Min Visible Distance for the Mobile Shield Waypoint

const vector MOBILE_SHIELD_DRONE_VEHICLE_ATTACH_OFFSET = <0,0,8>
const vector MOBILE_SHIELD_DRONE_VEHICLE_LEAVE_OFFSET = <0,0,20>

const vector DRONE_MINS = <-9, -9, -10>
const vector DRONE_MAXS = <9, 9, 10>

#if DEV
const bool DEBUG_CODE_SCRIPT_MOVER_TRAVERSAL = false
const bool DEBUG_WALL_CHECK = false
const bool DEBUG_THROW_CHECK = false
#endif //DEV


struct
{
	int mobileShieldHealth			= MOBILE_SHIELD_WALL_HEALTH
	float mobileShieldDuration		= SHIELD_THROW_DURATION
	float mobileShieldSpeed			= MOBILE_SHIELD_SPEED
	                    
	float mobileShieldSpeedUpgraded = MOBILE_SHIELD_SPEED_UPGRADED
       

	#if SERVER
	table<entity, bool > shieldActive = {}
	table<entity, vector> shieldTargetPos = {}
	table<entity, vector> initialGoalAngles = {}
	table<entity, array<vector> > projectileThrowPath = {}
	#endif

	table<entity, entity> mobileShield = {}
	table<entity, array<vector> > cornerPosList = {}
	table<entity, bool > shieldStopState = {}
	table<entity, bool > shieldIgnoreCliffs = {}
	table<entity, bool> canDoTacticalAdjustChatter = {}
	table<entity, entity> attachToVehicle = {}

	#if CLIENT
	bool cl_StopShield = false
	bool cl_shieldActive = false
	#endif

} file

void function MpAbilityShieldThrow_Init()
{
	PrecacheModel( SHIELD_MODEL )
	PrecacheModel( MOBILE_SHIELD_MODEL )
	PrecacheModel( MOBILE_SHIELD_TOP_MODEL )
	PrecacheParticleSystem( MOBILE_SHIELD_FX )
	PrecacheParticleSystem( MOBILE_SHIELD_TOP_FX )
	PrecacheParticleSystem( MOBILE_SHIELD_AR_MARKER )
	PrecacheParticleSystem( MOBILE_SHIELD_DRONE_PROJECTOR_FX )
	PrecacheParticleSystem( MOBILE_SHIELD_DRONE_ENGINE_FX )
	PrecacheParticleSystem( MOBILE_SHIELD_DRONE_WARNING_FX )
	
	PrecacheScriptString( SHIELD_THROW_SCRIPTNAME )
	PrecacheScriptString( MOBILE_SHIELD_SCRIPTNAME )

	RegisterSignal( "MobileShield_TriggerEnd" )
	RegisterSignal( "MobileShield_Complete" )
	RegisterSignal( "MobileShield_UpdateDestination" )
	RegisterSignal( "MobileShield_Deactivate" )
	RegisterSignal( "MobileShield_Shutdown" )
	RegisterSignal( "MobileShield_Projectile_Deployed" )

	Remote_RegisterServerFunction("ClientCallback_AttemptChangeShieldDirection", "vector", -100000.0, 100000.0, 32 )
	Remote_RegisterClientFunction( "ServerToClient_ShieldThrowToggleHint", "entity" )
	Remote_RegisterClientFunction( "ServerToClient_UpdateShieldStopState", "entity", "bool" )
	Remote_RegisterClientFunction( "ServerToClient_MobileShield_Complete", "entity" )

	#if CLIENT
		RegisterConCommandTriggeredCallback( "+offhand1", AttemptChangeDirection ) //Change Targets
		AddCreateCallback( PLAYER_WAYPOINT_CLASSNAME, OnWaypointCreated )
		AddCallback_ModifyDamageFlyoutForScriptName( MOBILE_SHIELD_SCRIPTNAME, MobileShield_OffsetDamageNumbersLower )
	#endif

	file.mobileShieldHealth			= GetCurrentPlaylistVarInt( "newcastle_mobile_shield_HP", MOBILE_SHIELD_WALL_HEALTH )
	file.mobileShieldDuration		= GetCurrentPlaylistVarFloat( "newcastle_mobile_shield_duration", SHIELD_THROW_DURATION )

	file.mobileShieldSpeed			= GetCurrentPlaylistVarFloat( "newcastle_mobile_shield_speed", MOBILE_SHIELD_SPEED )
	                    
	file.mobileShieldSpeedUpgraded	= GetCurrentPlaylistVarFloat( "newcastle_mobile_shield_speed_upgraded", MOBILE_SHIELD_SPEED_UPGRADED )
       
}



/////////////////////////////////////
//////////WEAPON CALLBACKS///////////
/////////////////////////////////////


void function OnWeaponActivate_ability_shield_throw( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if SERVER

	#endif

	#if CLIENT
		if ( !InPrediction() )
			return
	#endif
}


bool function OnWeaponAttemptOffhandSwitch_ability_shield_throw( entity weapon )
{
	#if SERVER
		if ( IsValid( weapon ) && weapon.HasMod( "ability_in_effect_regen_paused" ) )
		{
			return false
		}
	#endif

	#if CLIENT
	if ( !InPrediction() )
		return false
	#endif
	return true
}

void function OnWeaponTossPrep_ability_shield_throw( entity weapon, WeaponTossPrepParams prepParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()
}


var function OnWeaponToss_ability_shield_throw( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	#if SERVER
		PlayBattleChatterLineToSpeakerAndTeam( weaponOwner, "bc_tactical" )
		file.shieldStopState[weaponOwner] <- false
		file.shieldActive[weaponOwner] <- true
	#endif //SERVER

	#if CLIENT
		file.cl_shieldActive = true
	#endif
	return true
}



var function OnWeaponTossReleaseAnimEvent_ability_shield_throw( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	int ammoReq = weapon.GetAmmoPerShot()
	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )

	entity weaponOwner = weapon.GetWeaponOwner()
	vector desiredPos = ShieldThrow_GetThrowDestination( weaponOwner, weapon, true )

	#if SERVER
		ShieldThrow_ActivatePrompts( weaponOwner )
		if ( !( weaponOwner in file.shieldTargetPos ) )
		{
			file.shieldTargetPos[weaponOwner] <- desiredPos
			thread ShieldThrow_TrackTimeSinceChangeDirection_Thread( weaponOwner )
		}
	#endif //SERVER

	entity deployable = ThrowShield( weapon, attackParams, SHIELD_THROW_POWER, OnDeployableShieldPlanted )
	if ( deployable )
	{
		entity player = weapon.GetWeaponOwner()
		PlayerUsedOffhand( player, weapon )

		#if SERVER
			thread TrackProjetilePath( player, deployable )
			string projectileSound = GetGrenadeProjectileSound( weapon )
			if ( projectileSound != "" )
				EmitSoundOnEntity( deployable, projectileSound )

			deployable.proj.savedAngles = VectorToAngles( FlattenVec( player.GetViewVector() ) )
			weapon.w.lastProjectileFired = deployable
		#endif
	}

	return ammoReq
}

#if SERVER
void function TrackProjetilePath( entity player, entity projectile )
{
	Assert ( IsNewThread(), "Must be threaded off" )
	projectile.EndSignal( "OnDeath" )
	projectile.EndSignal( "OnDestroy" )
	projectile.EndSignal( "MobileShield_Projectile_Deployed" )

	OnThreadEnd(
		function() : ( projectile )
		{
			delete file.projectileThrowPath[projectile]
		}
	)

	array<vector> pathPositions

	if ( IsValid( player ) )
	{
		pathPositions.append( player.EyePosition() )
		#if DEV
		if ( DEBUG_WALL_CHECK )
		{
			DebugDrawSphere( player.EyePosition(), 8.0, COLOR_BLUE, true, 3.0 )
		}
		#endif
	}

	file.projectileThrowPath[projectile] <- pathPositions

	while ( true )
	{
		#if DEV
		if ( DEBUG_WALL_CHECK )
		{
			DebugDrawSphere( projectile.GetOrigin(), 8.0, COLOR_BLUE, true, 3.0 )
		}
		#endif
		
		file.projectileThrowPath[projectile].insert( 0, projectile.GetOrigin() )
		WaitFrame()		
	}
}
#endif

//////////////////////////////////////
////////////THROW SHIELD//////////////
//////////////////////////////////////

entity function ThrowShield( entity weapon, WeaponPrimaryAttackParams attackParams, float throwPower, void functionref(entity) deployFunc, vector ornull angularVelocity = null )
{
	#if CLIENT
		if ( !weapon.ShouldPredictProjectiles() )
			return null
	#endif

	entity player = weapon.GetWeaponOwner()

	vector attackPos
	if ( IsValid( player ) )
		attackPos = GetShieldThrowStartPos( player, attackParams.pos )
	else
		attackPos = attackParams.pos



	//attackPos can end up on the other side of geo if thrown right up against a wall (bad value from GetShieldThrowStartPos ? ).
	TraceResults tr = TraceHull( player.EyePosition(), attackPos, DRONE_MINS, DRONE_MAXS, [player], TRACE_MASK_PLAYERSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )

	#if DEV
	if ( DEBUG_THROW_CHECK )
	{
		DebugDrawMark( attackPos, 5, COLOR_RED, true, 5.0 )
		DebugDrawArrow( player.EyePosition(), attackPos, 8, COLOR_RED, true, 5.0 )
		printt("ThrowShield: looking fraction: " + tr.fraction )
	}
	#endif //DEV

	if ( tr.fraction < 1.0 )
	{
		#if DEV
		if ( DEBUG_THROW_CHECK )
			DebugDrawMark( attackPos, 5, COLOR_GREEN, true, 5.0 )
		#endif //DEV

		attackPos = tr.endPos
	}

	vector angles   = VectorToAngles( attackParams.dir )
	vector velocity = GetShieldThrowVelocity( player, angles, throwPower )
	if ( angularVelocity == null )
		angularVelocity = <600, RandomFloatRange( -300, 300 ), 0>
	expect vector( angularVelocity )

	float fuseTime = 0.0    // infinite

	bool isPredicted = PROJECTILE_PREDICTED
	if ( player.IsNPC() )
		isPredicted = PROJECTILE_NOT_PREDICTED

	WeaponFireGrenadeParams fireGrenadeParams
	fireGrenadeParams.pos = attackPos
	fireGrenadeParams.vel = velocity
	fireGrenadeParams.angVel = <0,0,0>
	fireGrenadeParams.fuseTime = fuseTime
	fireGrenadeParams.scriptTouchDamageType = damageTypes.projectileImpact
	fireGrenadeParams.scriptExplosionDamageType = damageTypes.explosive
	fireGrenadeParams.clientPredicted = isPredicted
	fireGrenadeParams.lagCompensated = true
	fireGrenadeParams.useScriptOnDamage = true
	entity deployable = weapon.FireWeaponGrenade( fireGrenadeParams )

	if ( deployable )
	{
		#if SERVER
		//Want to store the desired starting angles so that we can set them in the deploy func when the shield deploys.
		if ( GetShieldThrowIsScriptMoverTraversal() )
			file.initialGoalAngles[deployable] <- VectorToAngles( FlattenVec( attackParams.dir ) )
		#endif //SERVER

		deployable.SetAngles( <0, angles.y - 180, 0> )
		#if SERVER
			if ( IsValid( player ) )
				FiringRange_AddToRemoveOnCharacterChange( deployable, player )
			deployFunc( deployable )
			weapon.AddMod( "ability_in_effect_regen_paused" )
		#endif
	}

	return deployable
}


vector function GetShieldThrowStartPos( entity player, vector baseStartPos )
{
	// shouldn't I be able to get the position of the viewmodel version so that they match perfectly. - Roger
	vector attackPos = player.OffsetPositionFromView( baseStartPos, <20, 0, 2.5> )    // forward, right, up
	return attackPos
}


vector function GetShieldThrowVelocity( entity player, vector baseAngles, float throwPower )
{
	vector forward = AnglesToForward( baseAngles )

	if ( baseAngles.x < 80 )
		throwPower = GraphCapped( baseAngles.x, 0, 80, throwPower, throwPower )

	vector velocity = forward * throwPower

	return velocity
}

void function OnDeployableShieldPlanted( entity projectile )
{
	#if SERVER
		//don't start the shield until the projectile has got close enough to the ground.
		thread DeployShieldOnGround_Thread( projectile )
	#endif
}

#if SERVER
void function DeployShieldOnGround_Thread( entity projectile )
{
	Assert ( IsNewThread(), "Must be threaded off" )
	projectile.EndSignal( "OnDeath" )
	projectile.EndSignal( "OnDestroy" )

	entity weaponOwner = projectile.GetOwner()
	OnThreadEnd(
		function() : ( projectile, weaponOwner )
		{
			if ( projectile in file.initialGoalAngles )
			{
				delete file.initialGoalAngles[projectile]
			}

			if( IsValid( weaponOwner ) )
			{
				if( !( weaponOwner in file.mobileShield ) )
				{
					//Reset Shield Thrower Variables
					if( weaponOwner in file.shieldActive )
						delete file.shieldActive[weaponOwner]

					//Allow Cooldown to Start
					entity weapon = weaponOwner.GetOffhandWeapon( OFFHAND_TACTICAL )
					if ( IsValid( weapon ) && weapon.HasMod( "ability_in_effect_regen_paused" ) )
						weapon.RemoveMod( "ability_in_effect_regen_paused" )

					//End Client-side activities (HUD prompt)
					Remote_CallFunction_NonReplay( weaponOwner, "ServerToClient_MobileShield_Complete", weaponOwner )
				}
			}
		}
	)

	bool isHanging = false
	bool isCrouchedOnGround = false
	float startTime = Time()
	float bailoutTime = Time()
	const float bailTime = 0.2
	const float timeOut = 10.0
	//projectile.Anim_Play( "newcastle_drone_toss" )

	while ( true )
	{
		if ( !IsValid( projectile ) )
			return

		float hoverDetectionOffset = 1.25
		if( IsValid( weaponOwner ) )
		{
			isCrouchedOnGround = weaponOwner.IsOnGround() && weaponOwner.IsCrouched()
			if( isCrouchedOnGround )
				hoverDetectionOffset = 0.85
		}

		TraceResults groundTrace = TraceLine( projectile.GetOrigin(), projectile.GetOrigin() - <0, 0, SHIELD_HOVER_HEIGHT * hoverDetectionOffset>, MobileShieldIgnoreArray(), TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )

		                     
			vector traceStart = projectile.GetOrigin()
			vector traceEnd = (traceStart + projectile.GetVelocity() * 10)
			TraceResults tr = TraceLine( traceStart, traceEnd, projectile, TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE, projectile )
			if ( EntIsHoverVehicle( tr.hitEnt ) )
			{
				file.attachToVehicle[weaponOwner] <- tr.hitEnt
				break
			}
                             

		if ( groundTrace.fraction < 1.0 )
			break

		if ( Time() - startTime > timeOut )
			break

		//If we aren't moving, we want to bail out sooner//
		float speed = Length( projectile.GetVelocity() )
		if( speed < 50.0 )
		{

			//We're hanging - set flag and start the bailTime check
			if( !isHanging )
			{
				bailoutTime = Time() + bailTime
				isHanging = true
			}

			if( Time() > bailoutTime && bailoutTime != startTime )
			{
				break
			}
		}
		else
			isHanging = false

		WaitFrame()
	}

	projectile.SetPhysics( MOVETYPE_NONE )

	if ( projectile in file.initialGoalAngles )
	{
		projectile.SetAngles( file.initialGoalAngles[projectile] )

		#if DEV
		if ( DEBUG_CODE_SCRIPT_MOVER_TRAVERSAL )
			 DebugDrawArrow( projectile.GetOrigin(), projectile.GetOrigin() + AnglesToForward( projectile.GetAngles() ) * 16, 8, COLOR_GREEN, true, 5.0 )
		#endif //DEV
	}

	thread DeployMobileShield( projectile )
}
#endif



//////////////////////////////////////
////////////MOBILE SHIELD/////////////
//////////////////////////////////////

#if SERVER
void function DeployMobileShield( entity projectile )
{
	if ( !IsValid( projectile ) )
		return

	vector originalLaunchPosition = projectile.GetOrigin()
	vector originalVelocity       = projectile.GetVelocity()
	entity owner                  = projectile.GetOwner()

	// can't EndSignal on the projectile because that will end the thread prematurely.
	if ( !IsValid( projectile ) )
		return

	vector origin   = projectile.GetOrigin()
	vector angles   = projectile.proj.savedAngles

	if ( angles == ZERO_VECTOR )
	{
		//if thrown right at the ground, this can fire before we've actually set the angles on the projectile inside of OnWeaponTossReleaseAnimEvent_ability_shield_throw, so look them up here instead from the player.
		if ( IsValid( owner ) )
		{
			angles = VectorToAngles( FlattenVec( owner.GetViewVector() ) )
		}
	}

	vector velocity = FlattenVec( projectile.GetVelocity() ) //don't inherit any Z
	owner    = projectile.GetOwner()
	entity _parent  = projectile.GetParent()
	string parentAttachment = projectile.GetParentAttachment()

	TraceResults traceResult = TraceHull( originalLaunchPosition, origin, DRONE_MINS, DRONE_MAXS, projectile, TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE ) //DRONE_MINS, DRONE_MAXS
	origin = traceResult.endPos


	//projectiles fire with a different trace mask that our shield will use to traverse (player movement for the shield traversal, projectile for the thrown shield.)
	//So we want to just do a quick check and see if we hit a wall right in front of us, if so, pick an origin outside of that wall area.
	//There was an example on composite where the projectile could end up in this little divot/nook that a player couldn't get into but a projectile could.  Then when we tried to move it got stuck.
	if ( EnableFindBetterShieldStartingPos() )
	{
		bool foundBetterOrigin = false
		TraceResults wallCheck = TraceHull( origin - ( projectile.GetForwardVector() * 12.0 ), origin + ( projectile.GetForwardVector() * 12.0 ), DRONE_MINS, DRONE_MAXS, projectile, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT ) //DRONE_MINS, DRONE_MAXS

		#if DEV
			if ( DEBUG_WALL_CHECK )
			{
				if ( wallCheck.startSolid )
					DebugDrawArrow( origin - (projectile.GetForwardVector() * 24.0), origin + (projectile.GetForwardVector() * 24.0), 15,COLOR_YELLOW, true, 10.0 )
				else if ( wallCheck.fraction < 0.99 )
					DebugDrawArrow( origin - (projectile.GetForwardVector() * 24.0), origin + (projectile.GetForwardVector() * 24.0), 15,COLOR_RED, true, 10.0 )
				else
					DebugDrawArrow( origin - (projectile.GetForwardVector() * 24.0), origin + (projectile.GetForwardVector() * 24.0), 15,COLOR_GREEN, true, 10.0 )
			}
		#endif

		if ( wallCheck.fraction < 0.99 && !wallCheck.startSolid )
		{
			#if DEV
			if ( DEBUG_WALL_CHECK )
			{
				DebugDrawMark( wallCheck.endPos, 5, COLOR_BLUE, true, 10.0 )
				printt("EnableFindBetterShieldStartingPos - forward check found better starting pos.")
			}
			#endif
			origin = wallCheck.endPos
			foundBetterOrigin = true
		}


		if ( !foundBetterOrigin && ( projectile in file.projectileThrowPath ) )
		{
			vector traceStart
			vector traceEnd = projectile.GetOrigin()

			for ( int i = 0; i < file.projectileThrowPath[projectile].len(); i++ )
			{
				traceStart = file.projectileThrowPath[projectile][i]

				wallCheck = TraceHull( traceStart, traceEnd, DRONE_MINS, DRONE_MAXS, projectile, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT ) //DRONE_MINS, DRONE_MAXS

				#if DEV
					if ( DEBUG_WALL_CHECK )
					{
						if ( wallCheck.startSolid )
							DebugDrawArrow( traceStart, traceEnd, 15,COLOR_YELLOW, true, 10.0 )
						else if ( wallCheck.fraction < 0.99 )
							DebugDrawArrow( traceStart, traceEnd, 15,COLOR_RED, true, 10.0 )
						else
							DebugDrawArrow( traceStart, traceEnd, 15,COLOR_GREEN, true, 10.0 )
					}
				#endif

				//we started solid, lets keep moving back looking for a clear path
				if ( wallCheck.startSolid )
					continue

				//its clear, nothing we need to do
				if ( wallCheck.fraction >= 0.99 )
					break

				//trace has some endPos, can use that to place the shield.
				if ( wallCheck.fraction < 0.99 )
				{
					#if DEV
						if ( DEBUG_WALL_CHECK )
						{
							DrawStar( wallCheck.endPos, 8, 10.0, true )
						}
					#endif
					origin = wallCheck.endPos

					break
				}
			}
		}
	}

	if ( !IsValid( owner ) )
	{
		if ( IsValid( projectile ) )
			projectile.Destroy()
		return
	}

	owner.EndSignal( "OnDestroy" )

	if ( IsValid( projectile ) )
	{
		// Destroy the projectile in the next snapshot so the projectile will be in the final position
		// when it is removed from clients. This is used to prevent a pop between the projectile position and the
		// final script mover drone position.
		projectile.kv.solid = 0
		projectile.Hide()
		projectile.SetProjectileLifetime( .04 )
		projectile.Signal( "MobileShield_Projectile_Deployed" )
	}

	//Create the Mobile Shield Object
	entity mobileShield = CreateEntity( "script_mover" )
	mobileShield.kv.solid = SOLID_NONE
	mobileShield.kv.collisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS //NONE allows players to run into the shield and bounce it around. EF_PLAYER_MOVE_IGNORE_ATTACHMENT
	mobileShield.kv.fadedist = -1
	mobileShield.SetVelocity( velocity )
	mobileShield.kv.SpawnAsPhysicsMover = 0
	mobileShield.SetValueForModelKey( SHIELD_MODEL )
	mobileShield.SetOrigin( origin )
	mobileShield.SetAngles( angles )
	DispatchSpawn( mobileShield )

	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( owner ), Loadout_Character() )
	ItemFlavor skin      = LoadoutSlot_GetItemFlavor( ToEHI( owner ), Loadout_CharacterSkin( character ) )
	string characterSkinName = CharacterSkin_GetSkinName( skin )
	int characterCamo = CharacterSkin_GetCamoIndex( skin )
	AbilityCosmetics_Apply( mobileShield, characterSkinName, characterCamo )

	EndSignal( mobileShield, "OnDestroy" )
	EndSignal( mobileShield, "MobileShield_Deactivate" )

	if ( IsValid( _parent ) )
		mobileShield.SetParent( _parent, parentAttachment )


	mobileShield.DisableHibernation()
	mobileShield.SetMaxHealth( MOBILE_SHIELD_DRONE_HEALTH )
	mobileShield.SetHealth( MOBILE_SHIELD_DRONE_HEALTH )
	mobileShield.SetTakeDamageType( DAMAGE_NO ) //otherwise grenades will push it around
	mobileShield.SetDamageNotifications( true )
	mobileShield.SetDeathNotifications( true )
	mobileShield.SetArmorType( ARMOR_TYPE_HEAVY )
	mobileShield.SetScriptName( SHIELD_THROW_SCRIPTNAME )
	mobileShield.SetBlocksRadiusDamage( false )
	mobileShield.SetTitle( "" )
	mobileShield.SetOwner( owner )
	mobileShield.SetIgnorePredictedTriggerTypes( TT_JUMP_PAD )
	SetTeam( mobileShield, owner.GetTeam() )
	SetTargetName( mobileShield, SHIELD_THROW_SCRIPTNAME )
	mobileShield.SetCanBeMeleed( false )
	SetVisibleEntitiesInConeQueriableEnabled( mobileShield, false )
	mobileShield.RemoveFromAllRealms()
	mobileShield.AddToOtherEntitysRealms( owner )
	mobileShield.NotSolid()
	thread TrapDestroyOnRoundEnd( owner, mobileShield )

	//Register Shield so that it is detected by sonar.
	//mobileShield.Highlight_Enable()
	mobileShield.e.noOwnerFriendlyFire = true
	mobileShield.e.noFriendlyFireProtection = false
	mobileShield.e.canBeDamagedFromGas = false
	mobileShield.e.canBurn = false

	mobileShield.SetTouchTriggers( true )

	Highlight_SetOwnedHighlight( mobileShield, "sp_friendly_hero" )
	Highlight_SetFriendlyHighlight( mobileShield, "sp_friendly_hero" )
	AddSonarDetectionForPropScript( mobileShield )

	MarkEntForCleanupOnRoundEnd( mobileShield )

	file.mobileShield[owner] <- mobileShield

	                     
		if ( owner in file.attachToVehicle )
		{
			entity hoverVehicle = file.attachToVehicle[owner]
			if( IsValid( hoverVehicle ) && EntIsHoverVehicle( hoverVehicle ) )
			{
				HoverVehicle_AttachEntToNearestAbilityAttachment( mobileShield, hoverVehicle, true, false, MOBILE_SHIELD_DRONE_VEHICLE_ATTACH_OFFSET )
				file.shieldStopState[owner] <- true
				Remote_CallFunction_Replay( owner, "ServerToClient_UpdateShieldStopState", owner, file.shieldStopState[owner] )
			}
		}
                            

	bool shouldAnimsSetOrigin = true
	//The animation PLAY type seems to govern how the mobileShield behaves when attached to a vehicle
	//IF we Anim_Play()        - The animation sets the origin, and the mobile shield gets locked at its attachpoint, offsets do not apply
	//IF we Anim_PlayOnly()    - The mobile shield doesn't take on the angles when parenting properly, and ends up attaching at odd positions/angles

	                     
		if ( owner in file.attachToVehicle )
			shouldAnimsSetOrigin = false
                            

	thread MobileShield_Anim_Thread( mobileShield, shouldAnimsSetOrigin )
	thread MobileShield_TrackLifetimeForAudio_Thread( mobileShield, file.mobileShieldDuration - SHIELD_THROW_WARNING_DURATION )
	thread MobileShield_CreateAmbientDroneFX_Thread( mobileShield )

	//Add a PING region around Void Ring
	float pingRadius = 20.0
	vector pingOrigin = mobileShield.GetOrigin() + <0,0,-15>
	entity traceBlocker = CreateTraceBlockerVolume( pingOrigin, pingRadius, false, CONTENTS_BLOCK_PING, owner.GetTeam(), VOID_RING_PROP_SCRIPTNAME )
	traceBlocker.RemoveFromAllRealms()
	traceBlocker.AddToOtherEntitysRealms( mobileShield )
	traceBlocker.SetParent( mobileShield )

	/////////////DRONE MOVEMENT/////////////
	thread MobileShield_Hover_Thread( mobileShield, velocity )

	///////////SHIELD SEGMENTS///////////////
	entity topShield = CreateMobileShieldWall( mobileShield, owner, velocity, MOBILE_SHIELD_TOP_MODEL, MOBILE_SHIELD_TOP_FX )
	entity bottomShield = CreateMobileShieldWall( mobileShield, owner, velocity, MOBILE_SHIELD_MODEL, MOBILE_SHIELD_FX )
	bottomShield.SetLocalAngles( AnglesCompose( bottomShield.GetLocalAngles(), <180,180,0> ) )
	///////////////////////////////////////

	const float MOBILE_SHIELD_WAYPOINT_OFFSET_Z = 10

	//Create WP & RUI for Monitoring Void Ring HP
	entity wpUI = CreatePlayerWaypoint( eWaypoint.NEWCASTLE_MOBILE_SHIELD_LOCATOR )
	wpUI.SetOrigin( mobileShield.GetOrigin() + <0, 0, MOBILE_SHIELD_WAYPOINT_OFFSET_Z> )
	wpUI.SetAngles( mobileShield.GetAngles() )
	wpUI.SetWaypointFloat( 0, file.mobileShieldDuration )
	wpUI.SetWaypointFloat( 1, file.mobileShieldDuration )
	wpUI.SetWaypointInt( 0, file.mobileShieldDuration.tointeger() )
	wpUI.SetWaypointInt( 1, file.mobileShieldDuration.tointeger() )
	wpUI.wp.waypointCreatedTime = Time()
	wpUI.SetOwner( mobileShield.GetOwner() )
	CopyRealmsFromTo( mobileShield, wpUI )
	wpUI.SetParent( mobileShield )
	SetTeam( wpUI, owner.GetTeam() )

	//Create Bloodhound Tracking Breadcrumb START
	TraceResults groundTraceStart = TraceLine( mobileShield.GetOrigin(), mobileShield.GetOrigin() + <0, 0, -5000>, [ mobileShield ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_NEWCASTLE_MOBILE_SHIELD_START, mobileShield, groundTraceStart.endPos, mobileShield.GetTeam(), mobileShield )

	OnThreadEnd(
		function() : ( mobileShield, topShield, bottomShield, wpUI, owner )
		{
			if ( IsValid( owner ) )
				ShieldThrow_OwnerCleanUp( owner )

			if ( IsValid( mobileShield ) )
			{
				//Create Bloodhound Tracking Breadcrumb END
				TraceResults groundTraceEnd = TraceLine( mobileShield.GetOrigin(), mobileShield.GetOrigin() + <0, 0, -5000>, [ mobileShield ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
				TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_NEWCASTLE_MOBILE_SHIELD_END, mobileShield, groundTraceEnd.endPos, mobileShield.GetTeam(), mobileShield )

				ShieldThrow_CleanUp( mobileShield )
			}
			if( IsValid(topShield) )
			{
				ShieldWall_CleanUp( topShield )
				topShield.Destroy()
			}
			if( IsValid(bottomShield) )
			{
				ShieldWall_CleanUp( bottomShield )
				bottomShield.Destroy()
			}
			if( IsValid( wpUI ) )
			{
				wpUI.Destroy()
			}
			if( owner in file.mobileShield )
			{
				delete file.mobileShield[owner]
			}
		}
	)
	wait file.mobileShieldDuration - SHIELD_THROW_WARNING_DURATION

	//WARNING TIMEOUT INDICATION//
	if( !IsValid(mobileShield) )
		return

	EmitSoundOnEntity( mobileShield, MOBILE_SHIELD_WARNING_SFX_3P )

	entity warningFX = StartParticleEffectOnEntity( mobileShield, GetParticleSystemIndex( MOBILE_SHIELD_DRONE_WARNING_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )

	OnThreadEnd(
		function() : ( warningFX )
		{
			if ( IsValid( warningFX ) )
				EffectStop( warningFX )
		}
	)

	wait SHIELD_THROW_WARNING_DURATION
}
#endif //SERVER

#if SERVER
void function MobileShield_Anim_Thread( entity mobileShield, bool shouldAnimsSetOrigin )
{
	Assert ( IsNewThread(), "Must be threaded off" )
	EndSignal( mobileShield, "OnDestroy" )

	//newcastle_drone_toss      //looping idle when thrown
	//newcastle_drone_deploy  	//anim that transforms drone when at the ideal spot in environment
	//newcastle_drone_idle   	//looping idle of winged drone hovering
	//newcastle_drone_end		//anim that collapses drone as it fades off

	if( shouldAnimsSetOrigin )
		mobileShield.Anim_Play( "newcastle_drone_deploy" )
	else
		mobileShield.Anim_PlayOnly( "newcastle_drone_deploy" )

	OnThreadEnd(
		function() : ( mobileShield )
		{
			if ( IsValid( mobileShield ) )
			{
			}
		}
	)

	float deployDelay = 1.0

	wait deployDelay

	if(!IsValid(mobileShield))
		return

	if( shouldAnimsSetOrigin )
		mobileShield.Anim_Play( "newcastle_drone_idle" )
	else
		mobileShield.Anim_PlayOnly( "newcastle_drone_idle" )

	wait file.mobileShieldDuration - deployDelay

}
#endif //SERVER

#if SERVER
void function MobileShield_TrackLifetimeForAudio_Thread( entity mobileShield, float duration )
{
	Assert ( IsNewThread(), "Must be threaded off" )
	EndSignal( mobileShield, "OnDestroy" )
	EndSignal( mobileShield, "MobileShield_Shutdown" )

	float endTime = Time() + duration
	while( true )
	{
		if ( !IsValid( mobileShield ) )
			return

		float curTime = min( endTime - Time(), 0 )
		mobileShield.SetSoundCodeControllerValue( curTime / duration )
		WaitFrame()
	}
}
#endif //SERVER

#if SERVER
void function MobileShield_CreateAmbientDroneFX_Thread( entity mobileShield )
{
    Assert ( IsNewThread(), "Must be threaded off" )
    EndSignal( mobileShield, "OnDestroy" )
    EndSignal( mobileShield, "MobileShield_Shutdown" )


    entity owner = mobileShield.GetOwner()
	int team = mobileShield.GetTeam()
	array<entity> fxArray
    int fxID = mobileShield.LookupAttachment( "fx_center" )

    int fxProjectorId = GetParticleSystemIndex( MOBILE_SHIELD_DRONE_PROJECTOR_FX )
    int fxEngineId = GetParticleSystemIndex( MOBILE_SHIELD_DRONE_ENGINE_FX )

    entity engineFX = StartParticleEffectOnEntity_ReturnEntity( mobileShield, fxEngineId , FX_PATTACH_POINT_FOLLOW, fxID )
	fxArray.append(engineFX)

	//Ally Projector Beams StartParticleEffectOnEntityWithPos_ReturnEntity
	//entity projectorFriendlyFX = StartParticleEffectOnEntity_ReturnEntity( mobileShield, fxProjectorId, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID ) // FX_PATTACH_POINT_FOLLOW, fxID)
	entity projectorFriendlyFX = StartParticleEffectOnEntityWithPos_ReturnEntity( mobileShield, fxProjectorId, FX_PATTACH_ABSORIGIN_FOLLOW, fxID, <0,0,0>, <-90,0,0> )
	projectorFriendlyFX.SetOwner( owner )
	SetTeam( projectorFriendlyFX, team )
	projectorFriendlyFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_OWNER
	projectorFriendlyFX.DisableHibernation()
	if( IsValid(projectorFriendlyFX) )
	{
		projectorFriendlyFX.RemoveFromAllRealms()
		projectorFriendlyFX.AddToOtherEntitysRealms( mobileShield )
	}

	EffectSetControlPointVector( projectorFriendlyFX, 1, MOBILE_SHIELD_FX_COLOR )
	fxArray.append(projectorFriendlyFX)

	//Enemy Projector Beams
	//entity projectorEnemyFX = StartParticleEffectOnEntity_ReturnEntity( mobileShield, fxProjectorId , FX_PATTACH_POINT_FOLLOW, fxID )
	entity projectorEnemyFX = StartParticleEffectOnEntityWithPos_ReturnEntity( mobileShield, fxProjectorId, FX_PATTACH_ABSORIGIN_FOLLOW, fxID, <0,0,0>, <-90,0,0> )
	projectorEnemyFX.SetOwner( owner )
	SetTeam( projectorEnemyFX, team )
	projectorEnemyFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
	projectorEnemyFX.DisableHibernation()
	projectorEnemyFX.RemoveFromAllRealms()
	projectorEnemyFX.AddToOtherEntitysRealms( mobileShield )

	EffectSetControlPointVector( projectorEnemyFX, 1, MOBILE_SHIELD_ENEMY_PROJECTOR_FX_COLOR ) //MOBILE_SHIELD_ENEMY_FX_COLOR
	fxArray.append(projectorEnemyFX)


	OnThreadEnd(
		function() : ( fxArray )
		{
			foreach( fx in fxArray)
			{
				if ( IsValid( fx ) )
					EffectStop( fx )
			}
		}
	)

	WaitForever()
}
#endif //SERVER

#if SERVER
void function MobileShield_Hover_Thread( entity mobileShield, vector velocity )
{
	EndSignal( mobileShield, "OnDestroy" )
	EndSignal( mobileShield, "MobileShield_Shutdown" )

	entity owner = mobileShield.GetOwner()
	bool isStrafing						= false
	bool isYawOverrideSet   			= false
	vector lastPlayerFwd				= Normalize( owner.GetForwardVector() )
	vector finalDest                 	= ZERO_VECTOR
	float yawAccelerationScale       	= 180.0 //full turn takes 1 second

	EmitSoundOnEntity( mobileShield, MOBILE_SHIELD_PROPULSION_SFX_3P )

	bool wasVehicleAttached = false
	bool isVehicleAttached = false

	if ( owner in file.attachToVehicle )
	{
		isVehicleAttached 	= true
		wasVehicleAttached 	= true
	}

	if( !isVehicleAttached )
		MobileShield_EnableNonPhysicsTraversal( mobileShield, yawAccelerationScale, velocity )

	bool arrivedAtDest = false
	vector lastDestSet = ZERO_VECTOR

	while( true )
	{
		if( !IsValid( mobileShield ) )
			return

		if( !(owner in file.attachToVehicle) )
			isVehicleAttached = false

		if ( !isVehicleAttached && wasVehicleAttached )
		{
			velocity = mobileShield.GetVelocity()
			MobileShield_EnableNonPhysicsTraversal( mobileShield, yawAccelerationScale, velocity )
			wasVehicleAttached = false
		}

		//printt("Velocty: " + Length( mobileShield.GetVelocity() ) )
		if( !isVehicleAttached )
		{
			if( owner in file.shieldTargetPos )
			{
				finalDest = file.shieldTargetPos[owner]

				vector dirToFinalDest 			= FlattenVec( Normalize( file.shieldTargetPos[owner] - mobileShield.GetOrigin() ) )
				vector dirPlayerToFinalDest 	= FlattenVec( Normalize( file.shieldTargetPos[owner] - owner.GetOrigin() ) )
				vector dirToPlayer 				= FlattenVec( Normalize( owner.GetOrigin() - mobileShield.GetOrigin() ) )

				float dotPlayer 				= DotProduct( dirToPlayer, mobileShield.GetForwardVector() )
				float dotPlayerDir 				= DotProduct( dirToFinalDest, dirPlayerToFinalDest )
				float dotDest					= DotProduct( dirToFinalDest, mobileShield.GetForwardVector() )

				if( dotPlayer < 0.2 ) //--Player is on the BACK side of the SHIELD --//
				{
					if( dotPlayerDir > 0.85  ) //SHIELD and PLAYER dir to target is CLOSE! We want to turn the Shield
					{
						float dotViewDir = DotProduct( Normalize( AnglesToForward( owner.EyeAngles() ) ), mobileShield.GetForwardVector() )
						if( dotViewDir > 0.9 )
						{
							isStrafing = true
							lastPlayerFwd = Normalize( AnglesToForward( owner.EyeAngles() ) )
							isYawOverrideSet = false
						}
						else if ( dotViewDir < -0.4 ) //looking backwards from the shield's direction - we want to maintain strafe
						{
							isStrafing = true
							lastPlayerFwd = Normalize( mobileShield.GetForwardVector() )
						}
						else
							isStrafing = false
					}
					else
					{
						isStrafing = true
						lastPlayerFwd = Normalize( mobileShield.GetForwardVector() )
					}
				}
				else
					isStrafing = false	//--PLAYER is on the FRONT side of the SHIELD--//

				if( !isStrafing && IsValid(mobileShield))
				{
					//todo: NEEDS FIX FROM TRAVIS
					//yawAccelerationScale = GraphCapped( dotDest, -1, 1, maxYawAccelScale, minYawAccelScale )
					//mobileShield.SetYawAccelerationScale( yawAccelerationScale )

				}

				delete file.shieldTargetPos[owner]
			}

			if ( IsValid(owner) )
			{
				if ( lastDestSet != finalDest )
				{
					TraceResults groundTraceResult = TraceHull( finalDest, finalDest - <0, 0, 2000>, DRONE_MINS, DRONE_MAXS, mobileShield, TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
					entity groundEnt               = groundTraceResult.hitEnt && GetConVarBool( "script_mover_traversal_mover_support" ) ? groundTraceResult.hitEnt.GetRootMoveParent() : null

					if ( !GetConVarBool( "script_mover_traversal_mover_support" ) )
						mobileShield.SetGroundEntity( groundEnt )

					//mobileShield.SetMoveToPositionGroundNonPhysics( finalDest, groundEnt )
					lastDestSet = finalDest
				}

				if ( isStrafing )
				{
					if ( !isYawOverrideSet )
					{
						#if DEV
							if ( DEBUG_CODE_SCRIPT_MOVER_TRAVERSAL )
								printt(FUNC_NAME() + " SETTING STRAFING YAW")
						#endif //DEV

						//mobileShield.SetDesiredYawDir( Normalize( FlattenVec( lastPlayerFwd ) ) )
						isYawOverrideSet = true
					}
				}
				else
				{
					if ( isYawOverrideSet )
					{
						#if DEV
							if ( DEBUG_CODE_SCRIPT_MOVER_TRAVERSAL )
								printt(FUNC_NAME() + " SETTING NORMAL YAW")
						#endif //DEV

						mobileShield.ClearDesiredYaw()
						isYawOverrideSet = false
					}
				}
			}
		}


		#if DEV
		if ( DEBUG_CODE_SCRIPT_MOVER_TRAVERSAL )
		{
			DebugDrawLine( mobileShield.GetOrigin(), mobileShield.GetMoveToPositionWorld(), COLOR_YELLOW, true, 0.1 )
			DrawStar( mobileShield.GetMoveToPositionWorld(), 2, 0.5, true )
		}
		#endif //DEV

		WaitFrame()
	}
}

#endif //SERVER

#if SERVER
float function MobileShield_GetMoveSpeed( entity owner )
{
	                    
	if( IsValid( owner ) && owner.HasPassive( ePassives.PAS_TAC_UPGRADE_ONE ) ) // upgrade_newcastle_faster_shield
		return file.mobileShieldSpeedUpgraded
       
	return file.mobileShieldSpeed
}

void function MobileShield_EnableNonPhysicsTraversal( entity mobileShield, float yawAccelerationScale, vector velocity )
{
	float moveSpeed = MobileShield_GetMoveSpeed( mobileShield.GetOwner() )

	float checkDist                  = 5.0 		//Range at which we break out of the Update (too close to destination) (Original - 60)
	float lookaheadDistance          = 75.0
	float sideVelocity               = moveSpeed
	float maxWidthCorrectionVelocity = 50.0
	float maxSpeed                   = moveSpeed
	float traversalTraceOffset       = 18.0
	float maxInitialSpeed            = 300.0 //How fast can it go on spawn - 300 is max player sprint speed, good starting value?
	float initialVelocityDecayTime   = 2.5 //How long we lerp from maxInitialVelocity to maxSpeed
	float deaccelDest 				 = 150
	float deaccelSpeed 		 	 	 = 25

	const bool collideWithPlayers = false
	const bool collideWithNPCs = false
	//Rotation Params
	const float maxYawAccelScale = 180
	const float minYawAccelScale = 60
	//Slide Params
	const float maxSlideDistance = 400.0
	const int slideEdgeDetectAttempts = 8
	const float slideTargetGoalDistance = 30.0
	const float slideMaxDot = 0.999
	const float slideTestDepth = 100.0
	//Step Over Params
	const float maxStepOverHeight = 40.0
	const float stepOverCheckRange = 100
	const float stepOverTargetGoalDistance = 15.0
	const float traversalForceDecayunsigned = 90.0
	//Gravity
	const float gravityScale = 0.125 //this controls how fast the shield will fall to the ground, but also step up over obstacles.

	//mobileShield.EnableNonPhysicsTraversal( checkDist, lookaheadDistance, sideVelocity, maxWidthCorrectionVelocity, traversalTraceOffset, traversalForceDecayunsigned,TRACE_MASK_NPCSOLID, TRACE_COLLISION_GROUP_NPC_MOVEMENT, collideWithPlayers, collideWithNPCs )
	//mobileShield.SetMinimalHeightGround( SHIELD_HOVER_HEIGHT, SHIELD_GROUND_CHECK_DIST, TRACE_MASK_NPCSOLID, TRACE_COLLISION_GROUP_NPC_MOVEMENT )
	mobileShield.SetMaxSpeed( maxSpeed )
	//mobileShield.SetInitialSpeed( min( Length( velocity ), maxInitialSpeed ), initialVelocityDecayTime )
	//mobileShield.EnableDeaccelerationApproachingDest( deaccelDest, deaccelSpeed )

	//mobileShield.SetYawAccelerationScale( yawAccelerationScale )
	//mobileShield.EnableLedgeChecking( MOBILE_SHIELD_IGNORE_CLIFF_RESET_DELAY, SHIELD_THROW_TEST_STEP, SHEILD_THROW_DROP_HEIGHT_MAX )
	//mobileShield.EnableSliding( maxSlideDistance, slideEdgeDetectAttempts, slideTargetGoalDistance, slideMaxDot, slideTestDepth )//( float maxSlideDistance, int edgeDetectAttempts, float slideTargetGoalDistance, float maxDot, float slideTestDepth )
	//mobileShield.EnableStepOver( maxStepOverHeight, stepOverCheckRange, stepOverTargetGoalDistance )
	//mobileShield.EnableGravityAboveMinHeight( gravityScale )

}
#endif //SERVER

void function CodeCallback_ScriptMoverTraversalStopped( entity ent, bool isBlocked )
{
	if ( ent.GetScriptName() != SHIELD_THROW_SCRIPTNAME )
		return

	#if SERVER
		entity owner = ent.GetOwner()
		if ( IsValid( owner ) )
		{
			file.shieldStopState[owner] <- true
			//stop the shield
			Remote_CallFunction_Replay( owner, "ServerToClient_UpdateShieldStopState", owner, file.shieldStopState[owner] )
		}

		if ( isBlocked )
			EmitSoundOnEntity( ent, MOBILE_SHIELD_STOP_SFX_3P )
	#endif //SERVER
}


#if SERVER
int function GetMobileShieldHealth( entity player )
{
	                    
	if( player.HasPassive( ePassives.PAS_TAC_UPGRADE_TWO ) ) // upgrade_newcastle_shield_extra_health
		return GetCurrentPlaylistVarInt( "newcastle_tac_wall_health_upgrade", MOBILE_SHIELD_WALL_HEALTH_UPGRADED )
       
	return file.mobileShieldHealth
}


entity function CreateMobileShieldWall( entity mobileShield, entity owner, vector velocity, asset shieldModel, asset shieldFX )
{

	entity shieldEnt = CreatePropScript( shieldModel, mobileShield.GetOrigin(), AnglesCompose( mobileShield.GetAngles(),  < 0, 180, 0 > ), SOLID_VPHYSICS )
	shieldEnt.SetScriptName( MOBILE_SHIELD_SCRIPTNAME )
	//So that newcastle mobile sheilds don't collide with each other
	shieldEnt.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS

	int team = owner.GetTeam()

	shieldEnt.Hide()
	shieldEnt.DisableHibernation()
	shieldEnt.RemoveFromAllRealms()
	shieldEnt.AddToOtherEntitysRealms( mobileShield )
	shieldEnt.SetMaxHealth( GetMobileShieldHealth( owner ) )
	shieldEnt.SetHealth( GetMobileShieldHealth( owner ) )
	shieldEnt.SetOwner( owner )
	SetTeam( shieldEnt, team )
	shieldEnt.SetDamageNotifications( false )
	shieldEnt.SetDeathNotifications( false )
	shieldEnt.SetBlocksLOS( false ) // allows NPCs to see through shield
	shieldEnt.SetTakeDamageType( DAMAGE_YES )
	shieldEnt.kv.contents = ( CONTENTS_WINDOW | CONTENTS_BLOCK_PING | CONTENTS_NOGRAPPLE )
	//shieldEnt.SetScriptPropFlags( SPF_OBJECT_PLACEMENT_SPECIAL_IGNORE )

	shieldEnt.SetParent( mobileShield, "", true )

	entity shieldWallFriendlyFX = StartParticleEffectOnEntityWithPos_ReturnEntity( shieldEnt, GetParticleSystemIndex( shieldFX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,180,0> )
	shieldWallFriendlyFX.SetOwner( owner )
	SetTeam( shieldWallFriendlyFX, team )
	shieldWallFriendlyFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_OWNER
	shieldWallFriendlyFX.DisableHibernation()
	shieldEnt.e.fxControlPoints.append( shieldWallFriendlyFX )

	if ( IsValid( shieldWallFriendlyFX ) )
	{
		shieldWallFriendlyFX.RemoveFromAllRealms()
		shieldWallFriendlyFX.AddToOtherEntitysRealms( mobileShield )
	}

	entity shieldWallEnemyFX = StartParticleEffectOnEntityWithPos_ReturnEntity( shieldEnt, GetParticleSystemIndex( shieldFX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,180,0> )
	shieldWallEnemyFX.SetOwner( owner )
	SetTeam( shieldWallEnemyFX, team )
	shieldWallEnemyFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
	shieldWallEnemyFX.DisableHibernation()
	shieldEnt.e.fxControlPoints.append( shieldWallEnemyFX )

	if ( IsValid( shieldWallEnemyFX ) )
	{
		shieldWallEnemyFX.RemoveFromAllRealms()
		shieldWallEnemyFX.AddToOtherEntitysRealms( mobileShield )
	}

	shieldEnt.e.noOwnerFriendlyFire = true
	shieldEnt.e.noFriendlyFireProtection = false
	shieldEnt.e.canBeDamagedFromGas = false
	shieldEnt.e.canBurn = true
	shieldEnt.SetTouchTriggers( true )
	shieldEnt.e.preventStickyEnts = true
	AddSonarDetectionForPropScript( shieldEnt )
	MarkEntForCleanupOnRoundEnd( shieldEnt )

	EffectSetControlPointVector( shieldWallFriendlyFX, 1, MOBILE_SHIELD_FX_COLOR ) //TEAM_COLOR_FRIENDLY )
	EffectSetControlPointVector( shieldWallEnemyFX, 1, MOBILE_SHIELD_ENEMY_FX_COLOR )

	AddEMPDamageDevice( shieldEnt )

	AddWreckingBallEMPDamageDevice( shieldEnt )

                 
                                      
       

	AddEntityCallback_OnDamaged( shieldEnt, MobileShieldWall_OnDamaged )
	AddEntityCallback_OnPostDamaged( shieldEnt, MobileShieldWall_OnPostDamaged )

	return shieldEnt
}
#endif


#if SERVER
void function ShieldWall_CleanUp( entity shieldEnt )
{
	if( IsValid( shieldEnt ) )
	{
		array<entity> shieldChildren = shieldEnt.GetChildren()

		foreach( child in shieldChildren )
		{
			if( !IsValid(child) )
				continue

			if( child.GetClassName() == "info_particle_system" ) //Don't unparent VFX
				continue

			child.ClearParent() //Allows Grenades / Sticky Abilities to DROP when the shield goes down.
		}
	}

}
#endif

#if SERVER
void function MobileShieldWall_OnDamaged( entity shieldEnt, var damageInfo )
{
	// Damage Math

	int damageSourceIdentifier = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	float damageScale = 1.0
	float damage = DamageInfo_GetDamage( damageInfo )

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	int shieldTeam = shieldEnt.GetTeam()
	int attackTeam = attacker.GetTeam()

	//Restrict friendly Damage//
	if ( IsFriendlyTeam( shieldTeam, attackTeam ) )
		return

	if ( damage <= 0 )
		return

	//if ( IsBitFlagSet( DamageInfo_GetCustomDamageType( damageInfo ), DF_ELECTRICAL ) )
	//{
	//	if ( damageSourceIdentifier == eDamageSourceId.mp_weapon_grenade_emp )
	//		damageScale *= 1.5
	//}

	if ( damageSourceIdentifier == eDamageSourceId.mp_ability_crypto_drone_emp_trap )
		damageScale *= shieldEnt.GetMaxHealth() / damage

	if ( damageScale > 1.0 )
		DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )

	DamageInfo_SetDamage( damageInfo, damage * damageScale )
}

void function MobileShieldWall_OnPostDamaged( entity shieldEnt, var damageInfo )
{
	if( !IsValid( shieldEnt ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	entity weapon = DamageInfo_GetWeapon( damageInfo )
	entity owner = shieldEnt.GetOwner()

	if( IsValid( owner ) )
	{
		StatsHook_NewcastleMobileShieldDamageBlocked( owner, DamageInfo_GetDamage( damageInfo ).tointeger() ) //Track damage prevented for player stats
	}

	if ( !IsValid( attacker ) )
		return

	bool shieldWallDestroyed = ( shieldEnt.GetHealth() - DamageInfo_GetDamage( damageInfo ) ) <= 0

	if ( attacker.IsPlayer() )
	{
		DamageInfo_AddCustomDamageType( damageInfo, DF_NO_HITBEEP )
		DamageInfo_AddCustomDamageType( damageInfo, DAMAGEFLAG_VICTIM_HAS_VORTEX )

		if ( shieldWallDestroyed )
			DamageInfo_AddCustomDamageType( damageInfo, DF_KILLSHOT )

		attacker.NotifyDidDamage( shieldEnt, 0, DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ),
			DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ) | DF_NO_HITBEEP | DAMAGEFLAG_VICTIM_HAS_VORTEX,
			DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )

	}

	float shieldFrac = GetHealthFrac( shieldEnt )
	vector fColor = (shieldFrac * MOBILE_SHIELD_FX_COLOR) + ( (1 - shieldFrac) * <128,128,128> )
	vector eColor = (shieldFrac * MOBILE_SHIELD_ENEMY_FX_COLOR) + ( (1 - shieldFrac) * <128,128,128> )
	EffectSetControlPointVector( shieldEnt.e.fxControlPoints[0], 1, fColor )
	EffectSetControlPointVector( shieldEnt.e.fxControlPoints[1], 1, eColor )

	if( shieldWallDestroyed )
	{
		entity mobileShield = shieldEnt.GetParent()
		entity validShield = null


		foreach ( ent in mobileShield.GetChildren() )
		{
			if ( !IsValid( ent ) )
				continue

			if ( ent.GetScriptName() == MOBILE_SHIELD_SCRIPTNAME && ent != shieldEnt ) //Is there another...sky...walker?
			{
				validShield = ent
				break
			}
		}

		ShieldWall_CleanUp( shieldEnt )

		vector hitPos = DamageInfo_GetDamagePosition( damageInfo )
		if( attacker.IsPlayer() )
			EmitSoundAtPositionOnlyToPlayer( TEAM_UNASSIGNED, hitPos, attacker, MOBILE_SHIELD_DESTROY_SFX_1P )
		EmitSoundAtPosition( TEAM_UNASSIGNED, hitPos, MOBILE_SHIELD_DESTROY_SFX_3P, mobileShield )

		if( validShield == null )
			Signal( mobileShield, "MobileShield_Deactivate" )
	}
}
#endif

bool function IsMobileShieldEnt( entity ent )
{
	return ent.GetScriptName() == MOBILE_SHIELD_SCRIPTNAME
}

#if CLIENT
vector function MobileShield_OffsetDamageNumbersLower( entity shieldEnt, vector damageFlyoutPosition )
{
	vector flyoutPosition = ZERO_VECTOR

	const float MOBILE_SHIELD_DAMAGE_POS_VERT_OFFSET = 25.0
	const float MOBILE_SHIELD_DAMAGE_POS_FWD_OFFSET = 64.0
	vector origin = shieldEnt.GetOrigin() - shieldEnt.GetForwardVector() * MOBILE_SHIELD_DAMAGE_POS_FWD_OFFSET

	if( DotProduct(shieldEnt.GetUpVector(), <0,0,1> ) > 0 )
	{
		flyoutPosition = origin + <0,0,MOBILE_SHIELD_DAMAGE_POS_VERT_OFFSET> //Top Shield
	}
	else
	{
		flyoutPosition = origin - <0,0,MOBILE_SHIELD_DAMAGE_POS_VERT_OFFSET> //Bot Shield
	}

	return flyoutPosition
}
#endif


#if SERVER
void function ShieldThrow_OwnerCleanUp( entity player )
{
	if( IsValid(player) )
	{
		//Reset Shield Thrower Variables
		if( player in file.shieldActive )
			delete file.shieldActive[player]

		if( player in file.attachToVehicle)
			delete file.attachToVehicle[player]
		entity weapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )
		if ( IsValid( weapon ) && weapon.HasMod( "ability_in_effect_regen_paused" ) )
			weapon.RemoveMod( "ability_in_effect_regen_paused" )

		Remote_CallFunction_NonReplay( player, "ServerToClient_MobileShield_Complete", player )
	}
}
void function ShieldThrow_CleanUp( entity mobileShield )
{
	if( IsValid(mobileShield) )
	{
		mobileShield.Signal( "MobileShield_Shutdown" )
		StopSoundOnEntity( mobileShield, MOBILE_SHIELD_WARNING_SFX_3P )
		StopSoundOnEntity( mobileShield, MOBILE_SHIELD_PROPULSION_SFX_3P )
		EmitSoundOnEntity( mobileShield, MOBILE_SHIELD_DISSOLVE_SFX_3P )
		RemoveSonarDetectionForPropScript( mobileShield )
		mobileShield.Anim_Play( "newcastle_drone_end" )
		                     
			if ( !EntIsHoverVehicle( mobileShield.GetParent() ) )
                             
		mobileShield.ClearParent()
		mobileShield.Dissolve( ENTITY_DISSOLVE_CORE, ZERO_VECTOR, 500 )
	}

}
#endif


array<entity> function MobileShieldIgnoreArray()
{
	array<entity> ignoreArray = GetPlayerArray_Alive()

	array<entity> mobileShields = GetEntArrayByScriptName( MOBILE_SHIELD_SCRIPTNAME ) //mobile Shield Energy Walls
	foreach ( shieldWall in mobileShields )
	{
		if( !IsValid(shieldWall) )
			continue
		ignoreArray.append( shieldWall )
	}

	array<entity> thrownShields = GetEntArrayByScriptName( SHIELD_THROW_SCRIPTNAME ) // Mobile Shield Drones
	foreach ( shield in thrownShields )
	{
		if( !IsValid(shield) )
			continue
		ignoreArray.append( shield )
	}

	array<entity> bubbleShields = GetEntArrayByScriptName( BUBBLE_SHIELD_SCRIPTNAME ) //Gibby Domes
	foreach ( bubble in bubbleShields )
	{
		if( !IsValid(bubble) )
			continue
		ignoreArray.append( bubble )
	}

	array<entity> holoEnts = GetPlayerDecoyArray() //Mirage Decoys
	ignoreArray.extend( holoEnts )

	return ignoreArray
}


////////////////////////////////////////
///////MOBILE SHIELD HINT TOGGLE////////
////////////////////////////////////////
#if CLIENT
void function AttemptChangeDirection( entity player ) //AttemptChangeTargets
{
	if ( player != GetLocalViewPlayer() )
		return

	if ( AreAbilitiesSilenced( player ) )
		return

	if ( Bleedout_IsBleedingOut( player ) )
		return

	if ( player.IsPhaseShifted() )
		return

	if( player.HasPassive( ePassives.PAS_AXIOM ) )
	{
		vector desiredPos = <0,0,0>
		entity weapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )
		if ( !IsValid( weapon ) )
			return

		if( file.cl_shieldActive == true )
		{
			desiredPos = ShieldThrow_GetThrowDestination( player, weapon )
			Remote_ServerCallFunction( "ClientCallback_AttemptChangeShieldDirection", desiredPos )
		}
		else
		{
			if( weapon.GetWeaponPrimaryClipCount() < weapon.GetWeaponPrimaryClipCountMax() )
			{
				if ( IsValid( player ) )
					EmitSoundOnEntity( player, "Survival_UI_Ability_NotReady" )
			}
		}

	}
}
#endif

#if SERVER
void function ClientCallback_AttemptChangeShieldDirection( entity player, vector desiredPos )
{
	if ( AreAbilitiesSilenced( player ) )
		return

	if( player in file.shieldActive )
	{
		if(file.shieldActive[player] == false)
			return

		if( file.shieldStopState[player] == true )
		{
			file.shieldStopState[player] <- false

			if( !( player in file.shieldIgnoreCliffs ) )
				file.shieldIgnoreCliffs[player] <- true
		}

		if ( !( player in file.shieldTargetPos ) )
		{
			file.shieldTargetPos[player] <- desiredPos


		}
		else if ( GetShieldThrowIsScriptMoverTraversal() )
		{
			file.shieldTargetPos[player] = desiredPos
		}

		if( player in file.attachToVehicle )
		{
			if( !( player in file.mobileShield ) ) //We shouldn't hit this anymore after splitting CleanUp for Owner/MobileShield - Extra Guard for R5DEV-353084
				return

			entity mobileShield = file.mobileShield[player]
			if( IsValid( mobileShield ) )
			{
				entity shieldParent = mobileShield.GetParent()
				if( EntIsHoverVehicle( shieldParent ) )
				{
					mobileShield.ClearParent()
					mobileShield.SetOrigin( mobileShield.GetOrigin() + MOBILE_SHIELD_DRONE_VEHICLE_LEAVE_OFFSET ) //Drone gets a little exit offset to jump out of the vehicle
					delete file.attachToVehicle[player]
				}
			}
		}

		EmitSoundOnEntity( player, MOBILE_SHIELD_COMMAND_SFX_3P )

		if( player in file.canDoTacticalAdjustChatter )
		{
			if( file.canDoTacticalAdjustChatter[player] )
			{
				EmitSoundOnEntityOnlyToPlayer( player, player, MOBILE_SHIELD_TACTICAL_ADJUST_POSITION_VO_1P )
				EmitSoundOnEntityToTeamExceptPlayer( player, MOBILE_SHIELD_TACTICAL_ADJUST_POSITION_VO_3P, player.GetTeam(), player )
				thread ShieldThrow_TrackTimeSinceChangeDirection_Thread( player )
			}
		}

		Remote_CallFunction_Replay( player, "ServerToClient_UpdateShieldStopState", player, file.shieldStopState[player] )
	}
}
#endif

#if SERVER
void function ShieldThrow_TrackTimeSinceChangeDirection_Thread( entity player )
{
	EndSignal( player, "MobileShield_UpdateDestination" )
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )

	entity mobileShield
	if( player in file.mobileShield )
	{
		mobileShield = file.mobileShield[player]
		EndSignal( mobileShield, "MobileShield_Shutdown" )
		EndSignal( mobileShield, "MobileShield_Deactivate" )
	}

	file.canDoTacticalAdjustChatter[player] <- false
	OnThreadEnd(
		function() : ( player )
		{
			if( IsValid( player ) )
				file.canDoTacticalAdjustChatter[player] <- false
		}
	)

	float updateBuffer = Time() + MOBILE_SHIELD_UPDATE_CHATTER_BUFFER
	while( Time() < updateBuffer )
	{
		WaitFrame()
	}
	file.canDoTacticalAdjustChatter[player] <- true

	WaitForever()
}
#endif

#if SERVER
void function ShieldThrow_ActivatePrompts( entity player )
{
	Remote_CallFunction_Replay( player, "ServerToClient_ShieldThrowToggleHint", player )
}
#endif

#if CLIENT
void function ServerToClient_UpdateShieldStopState( entity player, bool shieldStop )
{
	if ( player != GetLocalViewPlayer() )
		return

	file.cl_StopShield = shieldStop
}
#endif

#if CLIENT
void function ServerToClient_ShieldThrowToggleHint( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	thread ShieldThrow_ShieldCommandPromptsRUI_Thread( player )
}
#endif

#if CLIENT
void function ServerToClient_MobileShield_Complete( entity player )
{
	Signal( player, "MobileShield_Complete" )

	file.cl_shieldActive = false

}

void function ShieldThrow_ShieldCommandPromptsRUI_Thread( entity player )
{
	EndSignal( player, "MobileShield_Complete" )
	EndSignal( player, "OnDeath" )

	if ( !IsValid( GetLocalClientPlayer() ) )
		return

	array<var> ruis
	var rui = CreateCockpitRui( $"ui/mobile_shield_command_prompt.rpak", HUD_Z_BASE )

	const string SHIELD_THROW_TEXT_REDIRECT = "#NEWCASTLE_MOBILE_SHIELD_REDIRECT"


	ruis.append( rui )

	OnThreadEnd(
		function() : ( ruis )
		{
			foreach ( rui in ruis )
				RuiDestroyIfAlive( rui )
		}
	)

	RuiSetString( rui, "promptText_Redirect", SHIELD_THROW_TEXT_REDIRECT )

	while ( IsValid( rui ) )
	{
		WaitFrame()
	}
}
#endif


vector function ShieldThrow_GetThrowDestination( entity ent, entity weapon, bool fromInitialToss=false )
{
	vector eyeHitPos
	array<entity> ignoreArray = MobileShieldIgnoreArray()

	vector eyePos = ent.EyePosition()
	vector eyeDir = ent.GetViewVector()
	eyeDir          = Normalize( eyeDir )

	float rangeNormal = MOBILE_SHIELD_TRACE_DIST
	float rangeSqr    = rangeNormal * rangeNormal

	// Effective range based on a cylindrical range change instead of spherical
	float pitchClamped   = clamp( ent.EyeAngles().x, -70.0, 70.0 )
	float rangeEffective = rangeNormal / deg_cos( pitchClamped )

	// Initial trace from eye - looking to hit something within effective range of the ability
	TraceResults initialTrace

	//initial toss will be a projectile, so we want a projectile trace
	if ( fromInitialToss )
	{
		initialTrace = TraceLineHighDetail( eyePos, eyePos + (eyeDir * rangeEffective), ignoreArray, TRACE_MASK_SHOT_HULL, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
	}
	else //other times will be when trying to move the tac through the world, so we want to trace based on player movement.
	{
		initialTrace = TraceLine( eyePos, eyePos + (eyeDir * rangeEffective), ignoreArray, TRACE_MASK_PLAYERSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )  //TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER )
	}
	eyeHitPos = initialTrace.endPos

	TraceResults trace = TraceLineHighDetail( eyeHitPos, eyeHitPos + <0, 0, -200000>, ent, TRACE_MASK_PLAYERSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT ) //TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER )
	Signal( ent, "MobileShield_UpdateDestination" )
	#if CLIENT
		thread ShieldThrow_CreateDestinationMarker( ent, trace.endPos, trace.surfaceNormal, trace.hitEnt )
	#endif

	return trace.endPos + <0, 0, SHIELD_HOVER_HEIGHT>

}

#if CLIENT
void function ShieldThrow_CreateDestinationMarker( entity player, vector endPos, vector normal, entity hitEnt )
{
	if( player != GetLocalClientPlayer() )
		return

	EndSignal( player, "MobileShield_Complete" )
	EndSignal( player, "OnDeath" )
	EndSignal( player, "MobileShield_UpdateDestination" )

	entity mover = null
	int fxHandle = -1
	int arID           = GetParticleSystemIndex( MOBILE_SHIELD_AR_MARKER )

	//if our destination is on a mover, then we need to make a dummy ent to parent to it so that the VFX is attached to it nicely and not just floating in the world.
	entity groundMoverEnt               = hitEnt ? hitEnt.GetRootMoveParentScriptMover() : null
	if ( IsValid ( groundMoverEnt ) && GetConVarBool( "script_mover_traversal_mover_support" ) )
	{
		mover  = CreateClientsideScriptMover( $"mdl/dev/empty_model.rmdl", endPos, normal )
		mover.SetParent( groundMoverEnt, "", true )
		fxHandle = StartParticleEffectOnEntity( mover, arID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	}
	else
	{
		fxHandle = StartParticleEffectInWorldWithHandle( arID, endPos, normal )
	}

	if ( EffectDoesExist( fxHandle) )
	{
		EffectSetControlPointVector( fxHandle, 1, MOBILE_SHIELD_AR_MARKER_COLOR )
	}

	OnThreadEnd(
		function() : ( fxHandle, mover )
		{
			if ( !EffectDoesExist( fxHandle ) )
				return

			EffectStop( fxHandle, true, true )

			if ( IsValid( mover ) )
			{
				mover.Destroy()
			}
		}
	)

	wait 1 //guarentee input confirmation even if not moving.

	while( !file.cl_StopShield )
	{
		WaitFrame()
	}
}
#endif

#if CLIENT
void function OnWaypointCreated( entity wp )
{
	int wpType = wp.GetWaypointType()

	if ( wpType == eWaypoint.NEWCASTLE_MOBILE_SHIELD_LOCATOR )
	{
		thread MobileShield_WaypointUI_Thread( wp )
		AddRefEntAreaToInvalidOriginsForPlacingPermanentsOnto( wp, MOBILE_SHIELD_INVALID_PLACEMENT_MIN_AREA, MOBILE_SHIELD_INVALID_PLACEMENT_MAX_AREA )
		AddEntityDestroyedCallback( wp,
			void function( entity ent ) : ( wp )
			{
				RemoveRefEntAreaFromInvalidOriginsForPlacingPermanentsOnto( ent )
			}
		)
	}

}


void function MobileShield_WaypointUI_Thread( entity wp )
{
	wp.SetDoDestroyCallback( true )
	wp.EndSignal( "OnDestroy" )

	array<var> ruis

	bool isOwned = IsFriendlyTeam( wp.GetTeam(), GetLocalViewPlayer().GetTeam() )
	entity player = GetLocalViewPlayer()

	var ownedRui
	if ( isOwned )
	{
		ownedRui = CreateCockpitRui( $"ui/mobile_shield_waypoint.rpak", 1 )
		RuiTrackFloat3( ownedRui, "playerAngles", player, RUI_TRACK_EYEANGLES_FOLLOW )
		RuiTrackFloat3( ownedRui, "worldPos", wp, RUI_TRACK_ABSORIGIN_FOLLOW )
		RuiTrackFloat( ownedRui, "curHP", wp, RUI_TRACK_WAYPOINT_FLOAT, 0 )
		RuiTrackFloat( ownedRui, "maxHP", wp, RUI_TRACK_WAYPOINT_FLOAT, 1 )
		ruis.append( ownedRui )
	}

	OnThreadEnd(
		function() : ( ruis )
		{
			foreach ( rui in ruis )
				RuiDestroy( rui )
		}
	)

	if ( isOwned )
	{
		while ( IsValid( wp ) )
		{
			bool displayRui = false

			if ( IsValid( player ) )
			{
				vector adjWPOrigin			= wp.GetOrigin() + <0,0,-10>
				vector eyeDir				= player.GetViewVector()
				vector dirToWP				= Normalize( adjWPOrigin - player.EyePosition() )
				float dotShield				= DotProduct( eyeDir, dirToWP )
				array<entity> ignoreArray	= MobileShieldIgnoreArray()

				TraceResults results = TraceLine( player.EyePosition(), adjWPOrigin, ignoreArray, TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )
				bool hasLoS		= results.fraction > 0.95
				bool isInFrame 	= dotShield > 0.9

				if ( !isInFrame || !hasLoS )
				{
					float dist = Distance( player.EyePosition(), wp.GetOrigin() )
					bool isInRange = ( dist > MOBILE_SHIELD_WP_DRAW_DIST_MIN )
					if ( isInRange )
						displayRui = true
				}

			}

			RuiSetBool( ownedRui, "isVisible", ( displayRui ) )

			WaitFrame()

			player = GetLocalViewPlayer()
		}
	}
	else
	{
		WaitForever()
	}
}
#endif //client


//Use code based script_mover traversal instead of doing it in script with non phyiscs mover.
bool function GetShieldThrowIsScriptMoverTraversal()
{
	return GetCurrentPlaylistVarBool( "newcastle_tac_code_traversal", true )
}

//This fix is coming in late, adding ability to turn it off if problems crop up
bool function EnableFindBetterShieldStartingPos()
{
	return GetCurrentPlaylistVarBool( "newcastle_tac_find_better_starting_pos", true )
}

//StickyEnt Exceptions for Mobile Shield
bool function MobileShield_IsAllowedStickyEnt( entity mobileShield, entity stickyEnt, string stickyEntWeaponClassName )
{
	bool allowStick = false

	if ( stickyEntWeaponClassName == "mp_weapon_cluster_bomb_launcher" )
		allowStick = true

	if ( stickyEntWeaponClassName == "mp_weapon_arc_bolt" )
		allowStick = true

	if ( stickyEntWeaponClassName == GRENADE_EMP_WEAPON_NAME )
		allowStick = true

	if( allowStick )
		thread MobileShield_TrackStickyEnt_Thread( mobileShield, stickyEnt )

	return allowStick
}

//Track Sticky Ents to dislodge them if the Mobile Shield moves them through a wall/door.
void function MobileShield_TrackStickyEnt_Thread( entity mobileShield, entity stickyEnt )
{
	EndSignal( mobileShield, "OnDestroy" )
	EndSignal( stickyEnt, "OnDestroy" )

	bool hadLoS = true

	array<entity> ignoreArray	= MobileShieldIgnoreArray()
	TraceResults initialTrace = TraceLine( mobileShield.GetOrigin(), stickyEnt.GetOrigin(), ignoreArray, TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )

	if(initialTrace.fraction < 1)
		hadLoS = false

	WaitFrame() //need this frame to allow the projectile to actually "stick"

	while ( true )
	{
		if( !IsValid( mobileShield ) )
			return
		if( !IsValid( stickyEnt ) )
			return

		ignoreArray	= MobileShieldIgnoreArray()
		TraceResults results = TraceLine( mobileShield.GetOrigin(), stickyEnt.GetOrigin(), ignoreArray, TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )
		if(	results.fraction < 1 )
		{
			#if SERVER
			stickyEnt.ClearParent()
			if( hadLoS )
				stickyEnt.SetAbsOrigin( results.endPos )
			#endif
			return
		}

		WaitFrame()
	}

}
 