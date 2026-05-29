global function Mp_ability_shield_mines_init
global function OnProjectileCollision_ability_shield_mines
global function OnWeaponPrimaryAttack_ability_shield_mines
global function OnWeaponActivate_ability_shield_mines
global function OnWeaponDeactivate_ability_shield_mines
global function OnWeaponOwnerChanged_ability_shield_mines

global function OnWeaponAttemptOffhandSwitch_ability_shield_mines

#if DEVELOPER
global function DEV_ShieldMineLaunchDebug


const bool SHIELD_MINES_POSE_PARAM_DEBUG = false

#endif

enum eDebugStage
{
	INITIAL_TARGET_AIR_POS,
	SIMULATED_ARC_END_POS,
	DRAW_GENERATED_MINE_LOCS,
	OFF
}
int SHIELD_MINES_AIRBURST_DEBUG = eDebugStage.OFF


global const string SHIELD_MINES_WEAPON_NAME = "mp_ability_conduit_shield_mines"

//Sounds
const string SHIELD_MINE_IMPACT_SOUND = "Conduit_Ult_Impact_Default_3p"

const asset FX_SHIELD_MINE_PREVIEW = $"P_ar_ping_squad_CP"
const asset FX_SHIELD_MINE_PREVIEW_CHEAP = $"P_ar_ping_squad_cheap_CP"
const asset FX_SHIELD_MINE_RING_PREVIEW = $"P_ar_target_fuse_instant"
const asset FX_SHIELD_MINE_PROJ = $"P_con_ult_proj"

//Multiple locations
const float SHIELD_MINE_MAX_ATTACK_RANGE = 2000.0 // max range from current position that line can be
const float SHIELD_MINE_MIN_ATTACK_RANGE = 120.0 // for safety: minimum range

global const float SHIELD_MINE_AIRBURST_HEIGHT = 4 * METERS_TO_INCHES

const float SHIELD_MINES_AIM_PITCH_ANGLE_MIN = -25.0
const float SHIELD_MINES_AIM_PITCH_ANGLE_MAX = 50.0
const float SHIELD_MINES_AIM_PITCH_PARAM_MIN = 0.0
const float SHIELD_MINES_AIM_PITCH_PARAM_MAX = 80.0
const float SHIELD_MINES_AIM_PITCH_DIFF_SNAP_VALUE = 1.0
const float SHIELD_MINES_AIM_PITCH_DIFF_CHECK_MIN = -90.0
const float SHIELD_MINES_AIM_PITCH_DIFF_CHECK_MAX = 90.0
const float SHIELD_MINES_AIM_PITCH_INCREMENT_MIN = -7
const float SHIELD_MINES_AIM_PITCH_INCREMENT_MAX = 7


struct
{
	#if SERVER
		table< entity, bool > hasLockedWeaponsAndMelee
	#endif
	table< entity, vector > cachedImpactPos
} file

void function Mp_ability_shield_mines_init()
{
	PrecacheParticleSystem( FX_SHIELD_MINE_PREVIEW )
	PrecacheParticleSystem( FX_SHIELD_MINE_PREVIEW_CHEAP )
	PrecacheParticleSystem( FX_SHIELD_MINE_RING_PREVIEW )
	PrecacheParticleSystem( FX_SHIELD_MINE_PROJ )

	#if CLIENT
		RegisterSignal( "ShieldMines_ArcPreviewStop" )
	#endif
}


void function OnWeaponActivate_ability_shield_mines( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( !IsValid(weaponOwner) )
		return

	#if SERVER
	VerifyBombardmentWeapon( weaponOwner, SHIELD_MINE_BOMBARDMENT_WEAPON )
	#endif

	#if CLIENT
			if ( weaponOwner != GetLocalViewPlayer() )
				return

			thread WeaponArcPreviewThread_Client( weaponOwner, weapon )
		#endif //CLIENT
}


void function OnWeaponDeactivate_ability_shield_mines( entity weapon )
{
	#if CLIENT
	entity owner = weapon.GetOwner()
	if ( IsValid(owner) )
		owner.Signal( "ShieldMines_ArcPreviewStop" )
	#endif

	#if SERVER
		entity player = weapon.GetOwner()
		if ( player in file.hasLockedWeaponsAndMelee && file.hasLockedWeaponsAndMelee[player]  )
		{
			if ( IsValid( player ) )
			{
				UnlockWeaponsAndMelee( player, "conduit_ult" )
				player.EnableWeaponTypes( WPT_CONSUMABLE )
			}
			file.hasLockedWeaponsAndMelee[player] <- false
		}
	#endif


}

void function OnWeaponOwnerChanged_ability_shield_mines( entity weapon, WeaponOwnerChangedParams changeParams )
{
#if SERVER
	if ( IsValid( changeParams.oldOwner ) )
	{
		//printt("Losing shield mines")
		entity shieldMineBombardmentWeapon = changeParams.oldOwner.GetOffhandWeapon( OFFHAND_RIGHT )
		if ( IsValid( shieldMineBombardmentWeapon ) && shieldMineBombardmentWeapon.GetWeaponClassName() == SHIELD_MINE_BOMBARDMENT_WEAPON )
			changeParams.oldOwner.TakeOffhandWeapon( OFFHAND_RIGHT )
	}

	//if ( IsValid( changeParams.newOwner ) )
	//{
	//}

	#endif
}

bool function OnWeaponAttemptOffhandSwitch_ability_shield_mines( entity weapon )
{
	bool hasFullAmmo = weapon.GetWeaponPrimaryClipCount() >= weapon.GetWeaponPrimaryClipCountMax()

#if CLIENT
	if( !hasFullAmmo )
	{
		entity player = weapon.GetOwner()
		if ( IsValid( player ) )
			EmitSoundOnEntity( player, "Survival_UI_Ability_NotReady" )
	}
#endif

	return hasFullAmmo
}


var function OnWeaponPrimaryAttack_ability_shield_mines( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner            = weapon.GetWeaponOwner()
	if ( !IsValid( weaponOwner ) )
		return

	#if CLIENT
	if ( !weapon.ShouldPredictProjectiles() )
		return

	weaponOwner.Signal( "ShieldMines_ArcPreviewStop" )
	#endif

	bool projectilePredicted      = PROJECTILE_PREDICTED
	bool projectileLagCompensated = PROJECTILE_LAG_COMPENSATED
	#if SERVER
		if ( weapon.IsForceReleaseFromServer() )
		{
			projectilePredicted      = false
			projectileLagCompensated = false
		}
		//printt("Conduit OnWeaponToss")
	#endif

	//Airburst position based on normal projectile arc
	vector impactPos
	if ( attackParams.burstIndex == 0 )
	{
		impactPos = GetFinalImpactPos( weapon, weaponOwner )//weapon.SimulateGrenadeImpactPos( ZERO_VECTOR, ZERO_VECTOR, -1, -1 )
		file.cachedImpactPos[weaponOwner] <- impactPos
	}
	else if ( attackParams.burstIndex == 1 )
	{
		if ( weaponOwner in file.cachedImpactPos )
			impactPos = file.cachedImpactPos[weaponOwner]
		else
		{
			//ReportNonFatalErrorMsg( "Conduit Ult - somehow firing the second projectile without a cached impact position from the first one." )
			impactPos = GetFinalImpactPos( weapon, weaponOwner )
		}
	}

	TraceResults trUp = TraceLine( impactPos, impactPos + <0,0,SHIELD_MINE_AIRBURST_HEIGHT>, [ weaponOwner ], TRACE_MASK_GRENADE, TRACE_COLLISION_GROUP_PROJECTILE )
	vector finalTargetPos = trUp.endPos
	vector savedDeployPos = finalTargetPos

	//Push projectiles left or right based on burstIndex
	vector fireDirection = FlattenNormalizeVec( attackParams.dir )
	vector fireAngles = VectorToAngles( fireDirection )
	vector fireRightDir = AnglesToRight( fireAngles )
	vector offset = -fireRightDir*30
	if ( attackParams.burstIndex == 0 )
		offset *= -1

	finalTargetPos += offset
	//DebugDrawSphere( finalTargetPos, 5, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), false, 5.0 )
	//DebugDrawText( finalTargetPos, ("p:"+attackParams.burstIndex), false, 5.0)


	#if SERVER
		if ( attackParams.burstIndex == 0 )
		{
			//This ensures that we cant interrupt the firing process once we start
			LockWeaponsAndMelee( weaponOwner, "conduit_ult" )
			weaponOwner.DisableWeaponTypes( WPT_CONSUMABLE )
			file.hasLockedWeaponsAndMelee[weaponOwner] <- true
		}
		else if ( attackParams.burstIndex == 1 )
		{
			UnlockWeaponsAndMelee( weaponOwner, "conduit_ult" )
			weaponOwner.EnableWeaponTypes( WPT_CONSUMABLE )
			file.hasLockedWeaponsAndMelee[weaponOwner] <- false
			PlayBattleChatterLineToSpeakerAndTeam( weaponOwner, "bc_super" )
		}

	#endif

	//DebugDrawSphere( finalTargetPos, 20, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), false, 5.0 )
	float launchSpeed = weapon.GetWeaponSettingFloat( eWeaponVar.projectile_launch_speed )
	ArcSolution as = SolveBallisticArc( weapon.GetAttackPosition(), launchSpeed*1.05, finalTargetPos, GetConVarFloat( "sv_gravity" ) )
	//DebugDrawSphere( attackParams.pos, 10, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), false, 5.0 )
	//DebugDrawBox(attackParams.pos, <-5, -5, -2>, <5, 5, 5>, COLOR_LIGHT_RED, 1, 5.0 )

	entity grenade = Grenade_Launch( weapon, attackParams.pos, as.fire_velocity/launchSpeed, projectilePredicted, projectileLagCompensated, ZERO_VECTOR )

	if ( !IsValid( grenade ) )
		return -1

	#if SERVER
		grenade.proj.projectileID = attackParams.burstIndex
		grenade.proj.savedOrigin = weapon.GetAttackPosition()
		grenade.proj.trackingPosition = savedDeployPos
		FiringRange_AddToRemoveOnCharacterChange( grenade, weaponOwner )
	#endif
	thread BombFlightThread( grenade, weapon, weaponOwner, finalTargetPos)//crosshairData.airburstTarget )

	#if CLIENT
		entity owner = weapon.GetOwner()
		if ( IsValid(owner) )
			weaponOwner.Signal( "ShieldMines_ArcPreviewStop" )
	#endif


	int ammoUsed = weapon.GetAmmoPerShot()
	return ammoUsed
}

void function BombFlightThread( entity projectile, entity weapon, entity player, vector target )
{
	EndSignal( projectile, "OnDestroy" )
	EndSignal( player, "OnDestroy" )

	vector launchDirection = player.GetViewForward()

	#if SERVER
		OnThreadEnd( void function() : ( projectile ) {
			if( IsValid( projectile ) )
				projectile.Destroy()
		} )
	#endif

	vector projectileOriginStart = projectile.GetOrigin()
	float startDistance = Distance2D( projectileOriginStart, target )

	while ( true )
	{
		vector projectileOrigin = projectile.GetOrigin()
		vector projectileOriginXY = FlattenVec( projectileOrigin )
		vector projectileDir = Normalize( projectile.GetVelocity() )
		projectile.SetAngles( VectorToAngles( projectileDir ) )
		#if SERVER
			float current2DDistance = Distance2D( projectileOrigin, projectileOriginStart )
			float threshold = startDistance - 50
			if( current2DDistance < threshold )
			{
				WaitFrame()
				continue
			}
			else
			{
				const vector SHIELD_MINE_BOUND_MINS = <-10, -10, -2>
				const vector SHIELD_MINE_BOUND_MAXS = <10, 10, 10>

				TraceResults adjTrace = TraceHull( projectileOrigin, target, SHIELD_MINE_BOUND_MINS, SHIELD_MINE_BOUND_MAXS, [], TRACE_MASK_SHOT_BRUSHONLY )
				projectile.SetOrigin( adjTrace.endPos )

				//DebugDrawSphere( projectileOrigin, 5, int(COLOR_YELLOW.x), int(COLOR_YELLOW.y), int(COLOR_YELLOW.z), false, 3.0 )
				//DebugDrawLine( projectileOrigin, target, int(COLOR_LIGHT_GREEN.x), int(COLOR_LIGHT_GREEN.y), int(COLOR_LIGHT_GREEN.z), false, 3.0 )
				//DebugDrawSphere( target, 8, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), false, 3.0 )
				//DebugDrawSphere( adjTrace.endPos, 7, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), false, 3.0 )
			}


			thread DeployShieldMineLine( player,projectile )
			return
		#endif
		WaitFrame()
	}
	unreachable
}


void function OnProjectileCollision_ability_shield_mines( entity projectile, vector pos, vector normal, entity hitEnt, int hitBox, bool isCritical, bool isPassthrough )
{
	entity player = projectile.GetOwner()
	if ( hitEnt == player )
		return

	//if ( projectile.GrenadeHasIgnited() )
	//	return

	DeployableCollisionParams cp
	cp.pos        = pos
	cp.normal     = normal
	cp.hitEnt     = hitEnt
	cp.hitBox     = hitBox
	cp.isCritical = isCritical
	                     
		cp.deployableFlags = eDeployableFlags.VEHICLES_NO_STICK
                            

#if SERVER
	projectile.proj.savedAngles = VectorToAngles( projectile.GetVelocity() )
	#endif
	//bool result = PlantStickyEntityOnWorldThatBouncesOffWalls( projectile, cp, 0.7, <0, 0, 0>, true )

	//DebugDrawSphere( pos, 5, int(COLOR_PINK.x), int(COLOR_PINK.y), int(COLOR_PINK.z), false, 5.0 )
	//DebugDrawArrow(pos, pos+(normal*32), 5, COLOR_PURPLE, false, 5.0)

#if SERVER
	entity weapon = projectile.GetWeaponSource()
	if ( IsValid(weapon) )
	{
		thread DeployShieldMineLine( player, projectile )
		projectile.Destroy()
	}

	projectile.NotSolid()
#endif



//	EmitSoundOnEntity( projectile, SHIELD_MINE_IMPACT_SOUND )
	#if SERVER

		projectile.Destroy()
	#endif
}


#if CLIENT
void function WeaponArcPreviewThread_Client( entity owner, entity weapon )
{
	
	owner.EndSignal( "ShieldMines_ArcPreviewStop" )
	owner.EndSignal( "OnDestroy" )
	weapon.EndSignal( "OnDestroy" )

	while ( !IsValid( owner.GetOffhandWeapon( OFFHAND_ORDNANCE ) ) )
		WaitFrame()

	const vector DEFAULT_COLOR = < 50, 200, 255>
	const float MORTAR_RING_RADIUS_FX_DIVISOR = 20.0

	vector initialImpactPos = weapon.GetMostRecentGrenadeImpactPos()

	int ringFX = StartParticleEffectInWorldWithHandle( GetParticleSystemIndex( FX_SHIELD_MINE_RING_PREVIEW ), ZERO_VECTOR, ZERO_VECTOR )
	EffectSetControlPointVector( ringFX, 0, initialImpactPos )
	EffectSetControlPointVector( ringFX, 1, DEFAULT_COLOR )
	EffectSetControlPointVector( ringFX, 2, <GetMineRadius( owner ) / MORTAR_RING_RADIUS_FX_DIVISOR, 0, 0> )


	int airBurstMarkerFX //= StartParticleEffectInWorldWithHandle( GetParticleSystemIndex( MORTAR_RING_MARKER_FX ), ZERO_VECTOR, < 0, 0, 1> )
	//EffectSetControlPointVector( airBurstMarkerFX, 1, DEFAULT_COLOR )

	int centerMarkerFX = StartParticleEffectInWorldWithHandle( GetParticleSystemIndex( FX_SHIELD_MINE_PREVIEW ), ZERO_VECTOR, ZERO_VECTOR )
	EffectSetControlPointVector( centerMarkerFX, 0, initialImpactPos )
	EffectSetControlPointVector( centerMarkerFX, 1, FRIENDLY_COLOR_FX )

	array<int> sideMarkerHandles
	int maxMarkers = 6
	                    
	if( PlayerHasPassive( owner, ePassives.PAS_ULT_UPGRADE_ONE ) )
		maxMarkers = 8
       
	for (int i=0; i<maxMarkers; ++i )
	{
		int sideMarkerFX = StartParticleEffectInWorldWithHandle( GetParticleSystemIndex( FX_SHIELD_MINE_PREVIEW_CHEAP ), ZERO_VECTOR, ZERO_VECTOR )
		sideMarkerHandles.append( sideMarkerFX )
		EffectSetControlPointVector( sideMarkerFX, 0, initialImpactPos )
		EffectSetControlPointVector( sideMarkerFX, 1, FRIENDLY_COLOR_FX )

	}

	array<int> sideRingHandles
	//for (int i=0; i<6; ++i )
	//{
	//	int sideRingHandle = StartParticleEffectInWorldWithHandle( GetParticleSystemIndex( MORTAR_RING_RADIUS_INSTANT_FX ), ZERO_VECTOR, ZERO_VECTOR )
	//	//EffectSetControlPointVector( sideRingHandle, 0, crosshairData.groundTarget )
	//	EffectSetControlPointVector( sideRingHandle, 1, DEFAULT_COLOR )
	//	EffectSetControlPointVector( sideRingHandle, 2, <SHIELD_MINE_RANGE / MORTAR_RING_RADIUS_FX_DIVISOR, 0, 0> )
	//	sideRingHandles.append( sideRingHandle )
	//
	//}

	var overlayRui = CreateCockpitPostFXRui( $"ui/ult_deployment.rpak", HUD_Z_BASE )
	RuiSetVisible( overlayRui, true )

	OnThreadEnd(
		function() : ( owner, ringFX, airBurstMarkerFX, centerMarkerFX, weapon, sideMarkerHandles, sideRingHandles, overlayRui )
		{
			if( EffectDoesExist( ringFX ) )
				EffectStop( ringFX, true, false )

			if( EffectDoesExist( airBurstMarkerFX ) )
				EffectStop( airBurstMarkerFX, true, false )

			if( EffectDoesExist( centerMarkerFX ) )
				EffectStop( centerMarkerFX, true, false )

			if( IsValid( weapon ) )
				weapon.ClearIndicatorEffectOverrides()

			foreach( sideMarker in sideMarkerHandles )
			{
				if( EffectDoesExist( sideMarker ) )
					EffectStop( sideMarker, true, false )
			}
			foreach( sideRing in sideRingHandles )
			{
				if( EffectDoesExist( sideRing ) )
					EffectStop( sideRing, true, false )
			}

			RuiDestroyIfAlive( overlayRui )

			//EmitSoundOnEntity( owner, MORTAR_RING_UI_CLOSE_SOUND )
		}
	)

	while( true )
	{

		vector impactPos = GetFinalImpactPos( weapon, owner, SHIELD_MINES_AIRBURST_DEBUG == eDebugStage.INITIAL_TARGET_AIR_POS )
		TraceResults trUp = TraceLine( impactPos, impactPos + <0,0,SHIELD_MINE_AIRBURST_HEIGHT>, [ owner ], TRACE_MASK_SHOT_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )

		vector finalTargetPos = impactPos
		const float DOWN_OFFSET = 10
		if ( trUp.endPos.z - impactPos.z > DOWN_OFFSET*2 )
			finalTargetPos = trUp.endPos - <0,0,DOWN_OFFSET>
		
		float distanceToTarget = Distance( weapon.GetAttackPosition(), impactPos )

		#if DEVELOPER
		if ( SHIELD_MINES_AIRBURST_DEBUG == eDebugStage.INITIAL_TARGET_AIR_POS )
		{
			DebugDrawSphere( impactPos, 5, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), false, 0.1 )
			DebugDrawLine( impactPos, finalTargetPos, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), false, 0.1 )
			DebugDrawSphere( finalTargetPos, 10, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), false, 0.1 )
		}
		#endif


		vector arcEndPos                  = finalTargetPos//crosshairData.airburstTarget
		vector arcEndNormal = ZERO_VECTOR


		vector flattenedAttackDir = FlattenNormalizeVec(weapon.GetAttackDirection())
		vector fwdAngles = VectorToAngles( flattenedAttackDir )//crosshairData.directionToTarget )
		//if ( weapon.GetMostRecentGrenadeIndicatorData().hitNormal != UP_VECTOR )
		//	fwdAngles = VectorToAngles( -weapon.GetMostRecentGrenadeIndicatorData().hitNormal )
		//DebugDrawLine( origin, origin + ( projectileForward * 128.0 ), int(COLOR_CYAN.x), int(COLOR_CYAN.y), int(COLOR_CYAN.z), true, 2 )
		vector directionRight = AnglesToRight( fwdAngles )
		array<float> radiusMultiple = [1.0,-1,2,-2,3,-3]
		array<vector> sideMarkerPositions


		/////////////////////////
		//  Set variables for the visual arc and get the simulated point of impact
		/////////////////////////

		vector centerMinePos = impactPos//crosshairData.groundTarget

		float launchSpeed  = weapon.GetWeaponSettingFloat( eWeaponVar.projectile_launch_speed )
		//float launchSpeed = GraphCapped( distanceToTarget, 0, GetShieldMineMaxRange( owner ), SHIELD_MINE_LAUNCH_SPEED_MIN, SHIELD_MINE_LAUNCH_SPEED_MAX  )
		ArcSolution as = SolveBallisticArc( weapon.GetAttackPosition(), launchSpeed*1.05, finalTargetPos, GetConVarFloat( "sv_gravity" ) )
		//if ( !as.valid )
		//{
		//	as = SolveBallisticArc( weapon.GetAttackPosition(), launchSpeed*1.05, finalTargetPos, GetConVarFloat( "sv_gravity" ) )
		//}
		if ( !as.valid )
		{
			//printt( "Conduit Ult - No arc solution")
			WaitFrame()
			continue
		}


		weapon.SetIndicatorEffectVelocityOverride( as.fire_velocity )
		weapon.SetIndicatorEffectDurationOverride( as.duration )
		arcEndPos = ZERO_VECTOR
		//arcEndNormal = weapon.GetMostRecentGrenadeIndicatorData().hitNormal
		//vector offSurfaceOffset = ZERO_VECTOR
		//if ( arcEndNormal != UP_VECTOR )
		//	offSurfaceOffset = arcEndNormal*30
		//
		//{
		//	vector traceStart = arcEndPos + offSurfaceOffset
		//	vector traceEnd = traceStart - UP_VECTOR*SHIELD_MINE_AIRBURST_HEIGHT*5
		//
		//	TraceResults traceDown = TraceLine( traceStart, traceEnd, [], TRACE_MASK_SHOT_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
		//	centerMinePos = traceDown.endPos
		//}

		#if DEVELOPER
		if ( SHIELD_MINES_AIRBURST_DEBUG == eDebugStage.SIMULATED_ARC_END_POS )
		{
			DebugDrawSphere( arcEndPos, 8, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), false, 0.1 )
			//DebugDrawArrow( arcEndPos, arcEndPos + arcEndNormal*60,6, COLOR_GREEN,false, 0.1)
		}
		#endif

		entity shieldMineLineWeapon = owner.GetOffhandWeapon( OFFHAND_ORDNANCE )
		if ( !IsValid(shieldMineLineWeapon ) )
		{
			WaitFrame()
			continue
		}

		//////////////////////////////////////////////////////////////////////////
		// Pose param for animation
		vector aimDirection = VectorRotateAxis( owner.GetViewForward(),owner.GetViewRight(), 15)
		float dot = DotProduct( aimDirection , Normalize( as.fire_velocity ) )
		float angle = DotToAngle( dot )

		vector fireVelAngles = VectorToAngles( Normalize( as.fire_velocity ) )
		vector fireUp = AnglesToUp( fireVelAngles )
		float dotUp = DotProduct( fireUp, aimDirection )

		angle *= dotUp > 0.0 ? -1.0 : 1.0

		float desiredAimPitch = GraphCapped( angle, SHIELD_MINES_AIM_PITCH_ANGLE_MIN, SHIELD_MINES_AIM_PITCH_ANGLE_MAX, SHIELD_MINES_AIM_PITCH_PARAM_MIN, SHIELD_MINES_AIM_PITCH_PARAM_MAX  )

		vector start = owner.CameraPosition() + (owner.GetViewForward() * 10) + (owner.GetViewRight() * -5)

		#if DEVELOPER
		if ( SHIELD_MINES_POSE_PARAM_DEBUG )
		{
			//DebugDrawArrow( start, start + (aimDirection * 20), 2, COLOR_GREEN, false, 0.1 )

			//DebugDrawArrow( start, start + (Normalize( as.fire_velocity ) * 20), 2, COLOR_YELLOW, false, 0.1 )
			DebugDrawLine( start, start + (fireUp * 20), int(COLOR_YELLOW.x), int(COLOR_YELLOW.y), int(COLOR_YELLOW.z), false, 0.1 )

			DebugDrawLine( start, start + (FlattenNormalizeVec( owner.GetViewForward() ) * 20), int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), false, 0.1 )
			DebugDrawLine( start, start + (UP_VECTOR * 20), int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), false, 0.1 )

			printt( "dot " + dot + " angle " + angle + " desiredAimPitch " + desiredAimPitch )
		}
		#endif
		DoPoseParamLerp( weapon, desiredAimPitch, false )
		//////////////////////////////////////////////////////////////////////////

		array<vector> mineLocations = GenerateMineLocations( shieldMineLineWeapon, arcEndPos, directionRight, SHIELD_MINES_AIRBURST_DEBUG == eDebugStage.DRAW_GENERATED_MINE_LOCS )

		#if DEVELOPER
		//if ( SHIELD_MINES_AIRBURST_DEBUG == eDebugStage.DRAW_GENERATED_MINE_LOCS )
		//{
		//	foreach( mineLoc in mineLocations )
		//	{
		//		//DebugDrawSphere( mineLoc, 15, int(COLOR_ORANGE.x), int(COLOR_ORANGE.y), int(COLOR_ORANGE.z), false, 0.1 )
		//	}
		//}
		#endif


		sideMarkerPositions = mineLocations
		/////////////////////////
		// Set the pose parameter for the aim blendspace
		/////////////////////////

		//const float MORTAR_RING_AIM_PITCH_ANGLE_MIN = 25.0
		//const float MORTAR_RING_AIM_PITCH_ANGLE_MAX = 180.0
		//const float MORTAR_RING_AIM_PITCH_PARAM_MIN = 0.0
		//const float MORTAR_RING_AIM_PITCH_PARAM_MAX = 150.0
		//float angle = DotToAngle( crosshairData.directionToTarget.Dot( Normalize( as.fire_velocity ) ) )
		//float desiredAimPitch = GraphCapped( angle, MORTAR_RING_AIM_PITCH_ANGLE_MIN, MORTAR_RING_AIM_PITCH_ANGLE_MAX, MORTAR_RING_AIM_PITCH_PARAM_MIN, MORTAR_RING_AIM_PITCH_PARAM_MAX  )
		//
		//DoPoseParamLerp( weapon, desiredAimPitch, firstLoop )



		//if( newClearance )
		//{
		//	if( firstLoop || newClearance != lastClearance || newInRange != lastInRange )
		//		Remote_ServerCallFunction( CMDNAME_CLEARANCE_ENABLED )
		//
		//	if( EffectDoesExist( ringFX ) )
		//		EffectSetControlPointVector( ringFX, 1, DEFAULT_COLOR )
		//	if( EffectDoesExist( airBurstMarkerFX ) )
		//		EffectSetControlPointVector( airBurstMarkerFX, 1, DEFAULT_COLOR )
		//}
		//else
		//{
		//	if( firstLoop || newClearance != lastClearance || newInRange != lastInRange )
		//		Remote_ServerCallFunction( CMDNAME_CLEARANCE_DISABLED )
		//
		//	if( EffectDoesExist( ringFX ) )
		//		EffectSetControlPointVector( ringFX, 1, CLEARANCE_COLOR )
		//	if( EffectDoesExist( airBurstMarkerFX ) )
		//		EffectSetControlPointVector( airBurstMarkerFX, 1, CLEARANCE_COLOR )
		//}

		//if( firstUILoop || ( visibleUI && newInRange != lastInRange ) )
		//	EmitSoundOnEntity( owner, MORTAR_RING_UI_IN_RANGE_SOUND )

		//else
		//{
		//	if( firstLoop || newInRange != lastInRange )
		//		Remote_ServerCallFunction( CMDNAME_ARC_DISABLED )
		//
		//	if( EffectDoesExist( ringFX ) )
		//		EffectSetControlPointVector( ringFX, 1, OUT_OF_RANGE_COLOR )
		//	if( EffectDoesExist( airBurstMarkerFX ) )
		//		EffectSetControlPointVector( airBurstMarkerFX, 1, OUT_OF_RANGE_COLOR )
		//
		//	//if( firstUILoop || ( visibleUI && newInRange != lastInRange ) )
		//	//	EmitSoundOnEntity( owner, MORTAR_RING_UI_OUT_OF_RANGE_SOUND )
		//}


		//if ( SHIELD_MINES_AIRBURST_DEBUG )
		//{
		//	//DebugDrawSphere( centerMinePos, 20, int(COLOR_LIGHT_PINK.x), int(COLOR_LIGHT_PINK.y), int(COLOR_LIGHT_PINK.z), false, 0.1 )
		//}

		if( EffectDoesExist( ringFX ) )
			EffectSetControlPointVector( ringFX, 0, centerMinePos )
		if( EffectDoesExist( airBurstMarkerFX ) )
			EffectSetControlPointVector( airBurstMarkerFX, 0, centerMinePos - <0,0,450> )
		if( EffectDoesExist( centerMarkerFX ) )
			EffectSetControlPointVector( centerMarkerFX, 0, centerMinePos )


		for( int i=0; i<sideMarkerHandles.len(); i++ )
		{
			int markerHandle = sideMarkerHandles[i]
			if( EffectDoesExist( markerHandle ) )
			{
				EffectWake( markerHandle )
				EffectSetControlPointVector( markerHandle, 0, sideMarkerPositions[i] )
			}
			//int ringHandle = sideRingHandles[i]
			//if( EffectDoesExist( ringHandle ) )
			//{
			//	EffectWake( ringHandle )
			//	EffectSetControlPointVector( ringHandle, 0, sideMarkerPositions[i] )
			//}
		}

		WaitFrame()
	}

}

void function DoPoseParamLerp( entity weapon, float target, bool immediate )
{
	if( !immediate )
	{
		float currentAimPitch = weapon.GetScriptPoseParam0()

		float diff = target - currentAimPitch
		float aimPitchIncrement = GraphCapped( diff, SHIELD_MINES_AIM_PITCH_DIFF_CHECK_MIN, SHIELD_MINES_AIM_PITCH_DIFF_CHECK_MAX, SHIELD_MINES_AIM_PITCH_INCREMENT_MIN, SHIELD_MINES_AIM_PITCH_INCREMENT_MAX )
		float aimPitch = 0
		if( fabs( diff ) < SHIELD_MINES_AIM_PITCH_DIFF_SNAP_VALUE )
			aimPitch = target
		else
			aimPitch = currentAimPitch + aimPitchIncrement

		weapon.SetScriptPoseParam0( aimPitch )
	}
	else
	{
		weapon.SetScriptPoseParam0( target )
	}
}
#endif


vector function GetFinalImpactPos( entity weapon, entity player, bool DEBUG_DRAW = false )
{
	vector impactPos = ZERO_VECTOR//weapon.SimulateGrenadeImpactPos( ZERO_VECTOR, ZERO_VECTOR, -1, -1 )
	vector flattenedAttackDir = FlattenNormalizeVec( weapon.GetAttackDirection() )

	TraceResults trImpact = TraceLine( impactPos, impactPos + flattenedAttackDir*1 * METERS_TO_INCHES, [player],TRACE_MASK_SHOT_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
	if ( DEBUG_DRAW )
	{
		DebugDrawLine( impactPos, trImpact.endPos, (trImpact.fraction < 1.0 ? COLOR_RED.x : COLOR_GREEN.x), (trImpact.fraction < 1.0 ? COLOR_RED.y : COLOR_GREEN.y), (trImpact.fraction < 1.0 ? COLOR_RED.z : COLOR_GREEN.z), false, 0.1 )
		if ( trImpact.fraction < 1.0 )
		{
			//DebugDrawArrow( trImpact.endPos, trImpact.endPos +(trImpact.surfaceNormal*10), 5, COLOR_LIGHT_RED, false, 0.1)
			float upDot = DotProduct( trImpact.surfaceNormal, UP_VECTOR )
			float upDotAbs  = fabs( upDot )
			bool normalIsFlat = upDotAbs < DOT_45DEGREE
			//DebugDrawText( trImpact.endPos, normalIsFlat ? "Wall" : "Ground", false, 0.1 )
		}
	}
	if ( trImpact.fraction < 1.0 )
	{
		float upDot        = DotProduct( trImpact.surfaceNormal, UP_VECTOR )
		float upDotAbs     = fabs( upDot )
		bool surfaceIsWall = upDotAbs < DOT_45DEGREE
		if ( surfaceIsWall )
		{
			const float LEDGE_CHECK_UP = SHIELD_MINE_AIRBURST_HEIGHT// + (2 * METERS_TO_INCHES)
			const float LEDGE_CHECK_BACK = 1 * METERS_TO_INCHES
			float debugDrawTime      = DEBUG_DRAW ? 0.1 : 0.0
			WallToTopResults results = TraceFromWallToTop( impactPos, -flattenedAttackDir, [ player ], LEDGE_CHECK_BACK, LEDGE_CHECK_UP, TRACE_MASK_SHOT_BRUSHONLY, TRACE_COLLISION_GROUP_NONE, debugDrawTime )
			if ( results.found )
			{
				impactPos = results.pos
			}
		}
	}

	return impactPos
}

                    
float function GetShieldMineUpgradedRangeScaler()
{
	return GetCurrentPlaylistVarFloat( "upgrade_shield_min_range_scaler", 1.15 )
}
      

float function GetShieldMineMaxRange( entity player )
{
	float result = SHIELD_MINE_MAX_ATTACK_RANGE

	                    
	if( PlayerHasPassive( player, ePassives.PAS_ULT_UPGRADE_ONE ) )
	{
		result *= GetShieldMineUpgradedRangeScaler()
	}
       

	return result
}

#if DEVELOPER
void function DEV_ShieldMineLaunchDebug( int stage = -1 )
{
	int desiredStage = (SHIELD_MINES_AIRBURST_DEBUG + 1)
	if ( stage >= 0 )
		desiredStage = stage


	SHIELD_MINES_AIRBURST_DEBUG = desiredStage % (eDebugStage.OFF + 1 )
	printt( "Conduit ShieldMine Debug state " + SHIELD_MINES_AIRBURST_DEBUG )
}
#endif