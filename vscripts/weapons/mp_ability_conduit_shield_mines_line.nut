global function Mp_ability_shield_mines_line_init
global function OnProjectileCollision_ability_shield_mines_line

#if SERVER
global function DeployShieldMineLine
#if DEV
global function ShieldMineLifetime_Thread
#endif
#endif

global function GenerateMineLocations
global function GetMineRadius

// TUNING
const float SHIELD_MINE_ARMING_TIME = 3
const float SHIELD_MINE_LIFETIME = 45//5
const float SHIELD_MINE_DAMAGE_DEBOUNCE_TIME = 1.0
const float SHIELD_MINE_DAMAGE = 10
const float SHIELD_MINE_HEALTH = 200
const float SHIELD_MINE_LINE_COUNT = 7
const int SHIELD_MINE_MAX_NUM_PER_PLAYER = 14
global const string SHIELD_MINE_PROP_SCRIPTNAME = "conduit_shield_mine"
global const float SHIELD_MINE_RANGE = 200
const float SHIELD_MINE_MIN_SEPARATION = SHIELD_MINE_RANGE * 0.90
const float SHIELD_MINE_MIN_SEPARATION_SQR = SHIELD_MINE_MIN_SEPARATION * SHIELD_MINE_MIN_SEPARATION
global const float SHIELD_MINE_AIR_TRAVEL_TIME = 1.25
global const string SHIELD_MINES_THREAT_PROP_TARGETNAME = "shield_mines_threat"

const string SHIELD_MINES_LINE_CLASS_NAME = "mp_ability_conduit_shield_mines_line"

// SOUND
const string SHIELD_MINE_IMPACT_SOUND = "Conduit_Ult_Impact_Default_3p"
const string SHIELD_MINE_LOOP_SOUND = "Conduit_Ult_Active_3p"
const string SHIELD_MINE_ARMING_SOUND = "Conduit_Ult_Arming_3p"
const string SHIELD_MINE_DEPLOY_SOUND = "Conduit_Ult_Jammers_Deploy_3p"

const string SHIELD_MINE_PLAYER_DMG_SOUND = "Conduit_Ult_Player_Damage_3p"
const string SHIELD_MINE_PLAYER_DMG_1P_SOUND = "Conduit_Ult_Player_Damage_1p"

const string SHIELD_MINE_DAMAGE_SPARK_SOUND = "Conduit_Ult_Jammers_Damage_3p"
const string SHIELD_MINE_DESTROY_SOUND = "Conduit_Ult_Jammers_Destroy_3p"
const string SHIELD_MINE_DESTROY_SELF_SOUND = "Conduit_Ult_Jammers_SelfDestroy_3p"

// MODELS
const asset SHIELD_MINE_MODEL = $"mdl/props/conduit/conduit_shield_jammer.rmdl"
const float SHIELD_MINE_MODEL_Z_OFFSET = 9
const float SHIELD_MINE_MODEL_Z_OFFSET_ARMING = 15

// VFX
const asset SHIELD_MINE_PLAYER_DMG_1P_FX = $"P_con_ult_hitfx_1p"
const asset SHIELD_MINE_PLAYER_DMG_3P_FX = $"P_emp_body_human"
const asset SHIELD_MINE_PLAYER_DMG_ROPE_FX = $"P_con_ult_damageRope"


const asset SHIELD_MINES_AIR_DEPLOY_FX = $"P_con_ult_jmr_deploy"
const asset SHIELD_MINES_RADIUS_FX = $"P_con_ult_mine"
const asset SHIELD_MINES_RADIUS_ENEMY_FX = $"P_con_ult_mine_enemy"
const asset SHIELD_MINES_CONNECTION_FX = $"P_con_ult_linkRope"

const asset SHIELD_MINE_DAMAGE_SPARK_FX = $"P_tesla_trap_dmg"
const asset SHIELD_MINE_DESTROY_FX = $"P_con_ult_jmr_death"
const asset SHIELD_MINE_DESTROY_ENEMY_FX = $"P_con_ult_jmr_death_enm"
const asset SHIELD_MINE_FAIL_FX = $"P_con_ult_jmr_fail"
const string SHIELD_MINE_FX_ATTACH = "fx_center"

const asset SHIELD_MINE_CHARGE_FX = $"P_con_ult_mine_chargeUp"
const asset SHIELD_MINE_CHARGE_ENEMY_FX = $"P_con_ult_mine_chargeUp_enm"

const bool SHIELD_MINES_DEBUG = false

global const string SHIELD_MINE_BOMBARDMENT_WEAPON = "mp_ability_conduit_shield_mines_line"

struct
{
#if SERVER
	table < entity, float >       		lastDamageFxTime
	table < entity, array<entity> >		playersShieldMines
	#endif
} file

void function Mp_ability_shield_mines_line_init()
{
	PrecacheParticleSystem( SHIELD_MINE_PLAYER_DMG_1P_FX )
	PrecacheParticleSystem( SHIELD_MINE_PLAYER_DMG_3P_FX )
	PrecacheParticleSystem( SHIELD_MINE_CHARGE_FX )
	PrecacheParticleSystem( SHIELD_MINE_CHARGE_ENEMY_FX )

	PrecacheParticleSystem( SHIELD_MINES_AIR_DEPLOY_FX )
	PrecacheParticleSystem( SHIELD_MINES_RADIUS_FX )
	PrecacheParticleSystem( SHIELD_MINES_RADIUS_ENEMY_FX )
	PrecacheParticleSystem( SHIELD_MINE_PLAYER_DMG_ROPE_FX )
	PrecacheParticleSystem( SHIELD_MINES_CONNECTION_FX )

	PrecacheParticleSystem( SHIELD_MINE_DAMAGE_SPARK_FX )
	PrecacheParticleSystem( SHIELD_MINE_DESTROY_FX )
	PrecacheParticleSystem( SHIELD_MINE_DESTROY_ENEMY_FX )
	PrecacheParticleSystem( SHIELD_MINE_FAIL_FX )
	


	PrecacheModel( SHIELD_MINE_MODEL )

	PrecacheWeapon( SHIELD_MINE_BOMBARDMENT_WEAPON )

	                      
	INVALID_GRAVITY_CANNON_PLACEABLES.append( SHIELD_MINES_LINE_CLASS_NAME )
       

	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_ability_conduit_shield_mines, ShieldMine_OnDamageDealt )
		RegisterSignal( "OnMineShutdown" )
	#endif

	#if CLIENT
		RegisterSignal( "PatternTargetingUI_Signal" )
		AddTargetNameCreateCallback( SHIELD_MINES_THREAT_PROP_TARGETNAME, AddThreatIndicator )
	#endif

}




#if SERVER
void function DeployShieldMineLine( entity player, entity projectile )
{
	int airdeployFXID     = GetParticleSystemIndex( SHIELD_MINES_AIR_DEPLOY_FX )
	StartParticleEffectInWorld( airdeployFXID, projectile.GetOrigin(), ZERO_VECTOR )
	EmitSoundAtPosition( player.GetTeam(), projectile.GetOrigin(), SHIELD_MINE_DEPLOY_SOUND, projectile )


	if ( !IsValid(player) )
		return

	entity shieldMineLineWeapon = VerifyBombardmentWeapon( player, SHIELD_MINE_BOMBARDMENT_WEAPON )
	if ( !IsValid( shieldMineLineWeapon ) )
		return

	FiringRange_AddToRemoveOnCharacterChange( shieldMineLineWeapon, player )

	//DebugDrawSphere( projectile.GetOrigin(), 10, COLOR_LIGHT_RED, false, 3.0 )

	vector airBurstLocation = projectile.proj.trackingPosition
	vector flattennedVel = FlattenNormalizeVec( projectile.GetVelocity() )
	vector fireDirection = FlattenNormalizeVec( airBurstLocation - projectile.proj.savedOrigin )
	vector velAngles = VectorToAngles( flattennedVel )
	vector directionRight = AnglesToRight( velAngles )

	velAngles = VectorToAngles( fireDirection )
	directionRight = AnglesToRight( velAngles )


	array<vector> mineLocations = GenerateMineLocations( shieldMineLineWeapon, airBurstLocation, directionRight, false,projectile.proj.projectileID, false )
	foreach( mineLoc in mineLocations )
	{
		vector launchVel = CalcProjectileTrajectory( projectile.GetOrigin(), mineLoc, SHIELD_MINE_AIR_TRAVEL_TIME, false )
		const vector JAMMER_ANGVEL = <0,500,0>
		entity grenade = Grenade_Launch( shieldMineLineWeapon, projectile.GetOrigin(), launchVel, false, true, JAMMER_ANGVEL )

		FiringRange_AddToRemoveOnCharacterChange( grenade, player )
	}
}


#endif

float function GetMineRadius( entity owner )
{
	float result = SHIELD_MINE_RANGE

	                    
	if( PlayerHasPassive( owner, ePassives.PAS_ULT_UPGRADE_TWO ) ) // upgrade_conduit_ult_mine_range
	{
		result *= 1.1
	}
       

	return result
}

array<vector> function GenerateMineLocations( entity weapon, vector airBurstLocation, vector directionRight, bool DEBUG_DRAW, int projectileID = -1, bool simulateCollisions = true )//entity projectile )
{
	array<vector> mineLocations
	array<float> radiusMultiple = [-3.0, -2, -1, 3, 2, 1, 0 ]
	Assert( radiusMultiple.len() == SHIELD_MINE_LINE_COUNT, "Array should match number of shield mines" )
	const float RADIUS_SCALAR = 1.9

	//vector airBurstLocation = projectile.GetOrigin()
	//vector projectileRight = AnglesToRight( projectile.proj.savedAngles )

	int startIndex = 0
	int endIndex = 6

	                    
		entity owner = weapon.GetOwner()
		if( PlayerHasPassive( owner, ePassives.PAS_ULT_UPGRADE_ONE ) )
		{
			radiusMultiple = [-4.0, -3.0, -2, -1, 4.0, 3, 2, 1, 0 ]
			endIndex = 8
		}
       

	if ( projectileID != -1 )
	{
		if ( projectileID == 0 )
			endIndex = 3
		else
			startIndex = 4
	}

	for ( int i=startIndex; i<=endIndex; ++i )
	{
		//Clamp Velocity Angles to the surface normal.
		float offsetDistance = radiusMultiple[i]*RADIUS_SCALAR*SHIELD_MINE_RANGE
		vector idealMinePos  = airBurstLocation + offsetDistance*directionRight - UP_VECTOR*SHIELD_MINE_AIRBURST_HEIGHT
		vector launchVel     = CalcProjectileTrajectory( airBurstLocation, idealMinePos, SHIELD_MINE_AIR_TRAVEL_TIME, false )

		vector minePos = idealMinePos
		if ( simulateCollisions )
		{
			minePos = ZERO_VECTOR//weapon.SimulateGrenadeImpactPos( airBurstLocation, launchVel , -1, 3 )
		}

		#if DEV
		const float DRAW_TIME = 0.1
		if ( DEBUG_DRAW )
		{
			DebugDrawSphere( airBurstLocation, 6, COLOR_GREEN, false, DRAW_TIME )
			DebugDrawSphere( idealMinePos, 6, COLOR_YELLOW, false, DRAW_TIME )
			DebugDrawSphere( minePos, 5, COLOR_GREEN, false, DRAW_TIME )
			DebugDrawText( minePos, (" Mine: " + radiusMultiple[i]), false, DRAW_TIME)
			DebugDrawArrow( airBurstLocation, minePos, 3, COLOR_LIGHT_GREEN, false, DRAW_TIME )

			vector lineEnd = airBurstLocation+ Normalize(launchVel)*30
			DebugDrawText( lineEnd, ("Proj: " + projectileID + " Mine: " + radiusMultiple[i]), false, DRAW_TIME)
			DebugDrawArrow(airBurstLocation, lineEnd, 5, COLOR_LIGHT_RED, false, DRAW_TIME)


			//Check distances between
			//if( mineLocations.len() > 0 && projectileID == -1 )
			//{
			//	vector prevMinePos = mineLocations.top()
			//
			//	vector dirToNew    = Normalize( minePos - prevMinePos )
			//	float distance     = Distance( prevMinePos, minePos )
			//	DebugDrawText( prevMinePos + (dirToNew*distance/2), ("D: " + distance ), false, DRAW_TIME)
			//	DebugDrawLine(prevMinePos, minePos, COLOR_YELLOW, false, DRAW_TIME)
			//}
		}
		#endif
		mineLocations.append( minePos )
	}

	return mineLocations
}



void function OnProjectileCollision_ability_shield_mines_line( entity projectile, vector pos, vector normal, entity hitEnt, int hitBox, bool isCritical, bool isPassthrough )
{
	entity player = projectile.GetOwner()
	if ( hitEnt == player )
		return

	DeployableCollisionParams cp
	cp.pos        = pos
	cp.normal     = normal
	cp.hitEnt     = hitEnt
	cp.hitBox     = hitBox
	cp.isCritical = isCritical
	                     
		cp.deployableFlags = eDeployableFlags.VEHICLES_NO_STICK
                            

#if SERVER
	projectile.proj.savedAngles = VectorToAngles( projectile.GetVelocity() )
	Deployable_CountBouncesAndRefund(projectile, cp)
	#endif
	bool result = PlantStickyEntityThatBouncesOffWalls( projectile, cp, DOT_45DEGREE )

	if ( !result )
	{
#if SERVER
		if ( hitEnt.GetScriptName() == SHIELD_MINE_PROP_SCRIPTNAME )
		{
			if ( IsFriendlyTeam( hitEnt.GetTeam(), projectile.GetTeam() ) )
			{
				vector currentVel     = projectile.GetVelocity()
				vector currentVelFlat = FlattenNormalizeVec( currentVel )
				vector bounceDir      = Normalize( currentVelFlat + (UP_VECTOR * 0.5) )
				vector bounceVel      = bounceDir * 300
				projectile.SetVelocity( bounceVel )
				//DebugDrawArrow( projectile.GetOrigin(), projectile.GetOrigin() + bounceVel, 10, COLOR_BLUE, false, 2.0 )
			}
			else
			{
				ShieldMine_PlayTrapDestroyFX( hitEnt, true )
				hitEnt.Destroy()
				return
			}
			
		}
#endif
		return
	}


	#if SERVER
	//Impact fx table
	EmitSoundAtPosition( TEAM_ANY, projectile.GetOrigin(), SHIELD_MINE_IMPACT_SOUND, projectile )

	if ( hitEnt.GetScriptName() == SHIELD_MINE_PROP_SCRIPTNAME )
	{
		hitEnt.TakeDamage( SHIELD_MINE_HEALTH, null, null, { damageSourceId = eDamageSourceId.mp_ability_conduit_shield_mines } )
		return
	}


		//Check if this is too close to other previously landed shield mines
		if ( PositionTooCloseToOtherMines( player, projectile.GetOrigin() ) )
		{
			thread ShieldMine_PlayTrapDestroyFXAtPos( projectile.GetOrigin(), projectile, true )
		}
		else
		{
			entity parentTo = null
			//if ( hitEnt.IsMoverOrChildOfMover() )
			//	parentTo = hitEnt

			DestroyEnemyMinesInRange( projectile.GetTeam(), projectile.GetOrigin() )
			thread ShieldMineLifetime_Thread( player, projectile.GetOrigin(), GetMineRadius( player ), parentTo )
		}
		//DebugDrawSphere( projectile.GetOrigin(), range, COLOR_DARK_BLUE, false, ignitionTime )
	#endif
	projectile.Destroy()
}


#if SERVER

void function ShieldMinePropArming_Thread( entity shieldMineProp, float time )
{
	if ( !IsValid( shieldMineProp ) )
		return

	thread ShieldMineAnim_AnimateZ( shieldMineProp, time, SHIELD_MINE_MODEL_Z_OFFSET_ARMING )
	thread ShieldMineAnim_DoPreActivateAnims( shieldMineProp )

	EmitSoundOnEntity( shieldMineProp, SHIELD_MINE_ARMING_SOUND )

	int fxCenterAttachPt = shieldMineProp.LookupAttachment( SHIELD_MINE_FX_ATTACH )
	array<entity> fxArray
	//{
	//	entity glowFX = StartParticleEffectOnEntityWithPos_ReturnEntity ( shieldMineProp, GetParticleSystemIndex( $"P_plasma_proj_LG_DLight" ), FX_PATTACH_POINT_FOLLOW_NOROTATE, fxCenterAttachPt, ZERO_VECTOR, <-90, 0, 0> )
	//	glowFX.SetOwner( shieldMineProp )
	//	SetTeam( glowFX, shieldMineProp.GetTeam() )
	//	//ringFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_OWNER
	//	//EffectSetControlPointVector( ringFX, 1, <radius, 0.5, 0.5> )
	//	//EffectSetControlPointVector( ringFX, 2, <75, 140, 200> )
	//	fxArray.append( glowFX )
	//}

	float SMALL_SPHERE_SIZE = 18
	{
		int debugSphereFXID = GetParticleSystemIndex( SHIELD_MINE_CHARGE_FX )
		//entity debugSphere  = StartParticleEffectInWorld_ReturnEntity( debugSphereFXID, shieldMineProp.GetOrigin(), shieldMineProp.GetAngles() )
		entity debugSphere  = StartParticleEffectOnEntity_ReturnEntity ( shieldMineProp, debugSphereFXID, FX_PATTACH_POINT_FOLLOW, fxCenterAttachPt )
		debugSphere.SetOwner( shieldMineProp )
		SetTeam( debugSphere, shieldMineProp.GetTeam() )
		debugSphere.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_OWNER
		EffectSetControlPointVector( debugSphere, 1, <SMALL_SPHERE_SIZE, 0, 0.15> )
		vector friendlyColor = <75, 140, 255>
		EffectSetControlPointVector( debugSphere, 2, friendlyColor )

		fxArray.append( debugSphere )
	}

	{
		int debugSphereFXID = GetParticleSystemIndex( SHIELD_MINE_CHARGE_ENEMY_FX )
		//entity debugSphere  = StartParticleEffectInWorld_ReturnEntity( debugSphereFXID, shieldMineProp.GetOrigin(), shieldMineProp.GetAngles() )
		entity debugSphere  = StartParticleEffectOnEntity_ReturnEntity ( shieldMineProp, debugSphereFXID, FX_PATTACH_POINT_FOLLOW, fxCenterAttachPt )

		debugSphere.SetOwner( shieldMineProp )
		SetTeam( debugSphere, shieldMineProp.GetTeam() )
		debugSphere.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
		EffectSetControlPointVector( debugSphere, 1, <SMALL_SPHERE_SIZE, 0, 0.15> )
		vector enemyColor = <255, 50, 0>
		EffectSetControlPointVector( debugSphere, 2, enemyColor )

		fxArray.append( debugSphere )
	}


	OnThreadEnd(
		function() : ( fxArray, shieldMineProp)
		{
			foreach ( fx in fxArray )
			{
				if ( IsValid( fx ) )
				{
					EffectSetControlPointVector( fx, 1, <0, 0, 0> )
					EffectStop( fx )
					fx.Destroy()
				}
			}
			if ( IsValid(shieldMineProp) )
				StopSoundOnEntity( shieldMineProp, SHIELD_MINE_ARMING_SOUND )
		}
	)

	wait time
}

void function ShieldMineAnim_AnimateZ( entity shieldMineProp, float armingTime, float zAmount )
{
	EndSignal( shieldMineProp, "OnDestroy" )
	EndSignal( shieldMineProp, "OnDeath" )

	float endHeight = shieldMineProp.GetLocalOrigin().z + zAmount
	float frames = armingTime*10
	float zInc = zAmount / frames

	OnThreadEnd(
		function() : ( shieldMineProp, endHeight )
		{
			vector newPos = shieldMineProp.GetLocalOrigin()
			newPos.z = endHeight
			if ( IsValid( shieldMineProp ) )
				shieldMineProp.SetLocalOrigin( newPos )
		}
	)

	float endTime = Time() + armingTime
	while ( Time() < endTime )
	{
		vector currentPos = shieldMineProp.GetLocalOrigin()
		float zLeft = fabs( currentPos.z - endHeight )
		if ( zLeft >= zInc )
		{
			currentPos.z += zInc
			shieldMineProp.SetLocalOrigin( currentPos )
		}


		WaitFrame()
	}
}


void function ShieldMineAnim_DoPreActivateAnims( entity shieldMineProp )
{
	waitthread PlayAnimOnly( shieldMineProp, "prop_conduit_ultimate_jammer_deploy" )
	if ( IsValid( shieldMineProp ) )
		shieldMineProp.Anim_PlayOnly( "prop_conduit_ultimate_jammer_pre_activate_idle" )
}

void function ShieldMineAnim_DoActivateAnims( entity shieldMineProp )
{
	waitthread PlayAnimOnly( shieldMineProp, "prop_conduit_ultimate_jammer_activate" )
	if ( IsValid( shieldMineProp ) )
		shieldMineProp.Anim_PlayOnly( "prop_conduit_ultimate_jammer_idle" )
}

void function ShieldMine_OnDamageDealt( entity target, var damageInfo )
{
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if ( IsValid(inflictor) && inflictor.GetScriptName() != SHIELD_MINE_PROP_SCRIPTNAME )
	{
		//printt( "CONDUIT ERROR: Inflictor is " + inflictor + " sn: " + inflictor.GetScriptName() )
		return
	}

	if ( target.GetScriptName() == SHIELD_MINE_PROP_SCRIPTNAME )
	{
		if ( IsFriendlyTeam( target.GetTeam(), inflictor.GetTeam() ) )
		{
			DamageInfo_SetDamage( damageInfo, 0 )
		}
		else
		{
			//DebugDrawLine( inflictor.GetOrigin(), target.GetOrigin(), COLOR_RED, false, 0.1 )
			DamageInfo_SetDamage( damageInfo, SHIELD_MINE_HEALTH )
		}
		return
	}

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( IsValid( attacker ) && attacker != target && IsFriendlyTeam( target.GetTeam(), attacker.GetTeam() ) )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	if ( target.IsNPC() )
	{
		if ( (target.IsNonCombatAI() && target.GetClassName() != "npc_dummie") || Electricity_ShouldStunNPCAndAddImmunity( target, SHIELD_MINE_DAMAGE_DEBOUNCE_TIME ) )
		{
			DamageInfo_SetDamage( damageInfo, 0 )
			return
		}

		EMP_DamagedPlayerOrNPC( target, damageInfo )
	}
	else if ( !target.IsPlayer() )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	if ( !target.IsPlayer() )
		return

	float timeSinceLastShieldMine = Time() - target.p.lastShieldMineDamageTime
	if ( timeSinceLastShieldMine < SHIELD_MINE_DAMAGE_DEBOUNCE_TIME )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	//Let's actually do the damage and status effects then.
	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_CONDUIT_ULTIMATE_DAMAGE, target, target.GetOrigin(), target.GetTeam(), target )

	const float EXPLOSION_EFFECTS_DURATION = SHIELD_MINE_DAMAGE_DEBOUNCE_TIME
	//StatusEffect_AddTimed( target, eStatusEffect.minimap_jammed, 1.0, EXPLOSION_EFFECTS_DURATION, 0.0 )
	StatusEffect_AddTimed( target, eStatusEffect.move_slow, 0.25, EXPLOSION_EFFECTS_DURATION, 1.0 )

	EmitSoundOnEntityOnlyToPlayer( target, target, SHIELD_MINE_PLAYER_DMG_1P_SOUND )
	EmitSoundOnEntityExceptToPlayer(  target, target, SHIELD_MINE_PLAYER_DMG_SOUND ) //Everyone hearing it on the target
	
	target.p.lastShieldMineDamageTime = Time()

	if( target.IsPlayer() && !target.IsOnGround() )
	{
		vector vel = target.GetVelocity()
		target.SetVelocity( < vel.x / 2.0, vel.y / 2.0, vel.z > )
	}
	else if( target.IsPlayer() && target.IsSliding() )
	{
		vector vel = target.GetVelocity()
		target.SetVelocity( < vel.x / 2.0, vel.y / 2.0, vel.z > )
	}

	thread ShieldMine_VictimFXThread( inflictor, target, EXPLOSION_EFFECTS_DURATION )
	                             
		if( target.IsPlayer() )
			ShadowZombie_TryDamagingTrapAfterTakingDamage( target, attacker, inflictor )
       

}

void function ShieldMine_VictimFXThread( entity shieldMine, entity target, float time )
{
	if ( !target.IsPlayer() )
		return

	target.EndSignal( "OnDestroy" )
	target.EndSignal( "OnDeath" )

	array <entity> fxArray

	int effectIndex    = GetParticleSystemIndex( SHIELD_MINE_PLAYER_DMG_3P_FX )
	entity empEffect3p = StartParticleEffectOnEntity_ReturnEntity( target, effectIndex, FX_PATTACH_POINT_FOLLOW, target.LookupAttachment( "CHESTFOCUS" ) )
	empEffect3p.SetOwner( target )
	empEffect3p.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)
	fxArray.append( empEffect3p )

	int ropeFXIndex     = GetParticleSystemIndex( SHIELD_MINE_PLAYER_DMG_ROPE_FX )
	entity damageRopeFX = StartParticleEffectOnEntity_ReturnEntity( target, ropeFXIndex, FX_PATTACH_POINT_FOLLOW, target.LookupAttachment( "CHESTFOCUS" ) )
	EffectSetControlPointEntity( damageRopeFX, 1, shieldMine )
	damageRopeFX.SetOwner( shieldMine )
	damageRopeFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	fxArray.append( damageRopeFX )

	OnThreadEnd(
		function() : ( target,  fxArray )
		{
			foreach ( fx in fxArray )
			{
				if ( IsValid( fx ) )
				{
					EffectSetControlPointVector( fx, 1, <0, 0, 0> )
					EffectStop( fx )
					fx.Destroy()
				}
			}
		}
	)

	wait time
}

bool function PositionTooCloseToOtherMines( entity player, vector pos )
{
	if ( player in file.playersShieldMines )
	{
		foreach ( shieldMine in file.playersShieldMines[player] )
		{
			if ( IsValid( shieldMine ) )
			{
				float distSqr = DistanceSqr( shieldMine.GetOrigin(), pos )

				#if DEV
				//{
				//	vector prevMinePos = shieldMine.GetOrigin()
				//	vector dirToNew    = Normalize( pos - prevMinePos )
				//	float distance     = Distance( prevMinePos, pos )
				//
				//
				//	if ( distance < SHIELD_MINE_RANGE*2 )
				//	{
				//		vector color = COLOR_YELLOW
				//		if ( distSqr <= SHIELD_MINE_MIN_SEPARATION_SQR )
				//			color = COLOR_RED
				//
				//		DebugDrawText( prevMinePos + (dirToNew * distance / 2), ("D: " + distance), false, 5.0 )
				//		DebugDrawLine( prevMinePos, pos, color, false, 5.0 )
				//	}
				//}
				#endif

				if ( distSqr <= SHIELD_MINE_MIN_SEPARATION_SQR )
				{
					return true
				}
			}
		}
	}

	return false
}

int function DestroyEnemyMinesInRange( int playerTeam, vector pos )
{
	int numDestroyed = 0
	array<entity> allShieldMines = GetEntArrayByScriptName( SHIELD_MINE_PROP_SCRIPTNAME )
	foreach( shieldMine in allShieldMines )
	{
		if ( !IsValid( shieldMine ) )
			continue

		if ( IsFriendlyTeam( playerTeam, shieldMine.GetTeam() ) )
			continue

		float distSqr = DistanceSqr( shieldMine.GetOrigin(), pos )
		if ( distSqr <= (SHIELD_MINE_RANGE * SHIELD_MINE_RANGE) )
		{
			//DebugDrawSphere( pos,10, COLOR_GREEN, false, 2.0 )
			//DebugDrawLine( pos, shieldMine.GetOrigin(), COLOR_RED, false, 2.0 )
			//DebugDrawSphere( shieldMine.GetOrigin(),5, COLOR_RED, false, 2.0 )
			ShieldMine_PlayTrapDestroyFX( shieldMine, true)
			shieldMine.Destroy()
			numDestroyed++
		}
	}

	return numDestroyed
}

void function ShieldMineLifetime_Thread( entity player, vector pos, float radius, entity parentTo = null )
{
	if ( !IsValid(player) )
		return

	entity shieldMineProp = CreatePropScript( SHIELD_MINE_MODEL, pos + <0,0,SHIELD_MINE_MODEL_Z_OFFSET>, <0, 0, 0>, SOLID_CYLINDER, 99999 )

	shieldMineProp.DisableHibernation()
	shieldMineProp.SetMaxHealth( SHIELD_MINE_HEALTH )
	shieldMineProp.SetHealth( SHIELD_MINE_HEALTH  )
	shieldMineProp.SetTakeDamageType( DAMAGE_YES )
	shieldMineProp.SetDamageNotifications( true )
	shieldMineProp.SetDeathNotifications( true )
	shieldMineProp.SetArmorType( ARMOR_TYPE_HEAVY )
	shieldMineProp.SetBlocksRadiusDamage( false )
	shieldMineProp.SetCanBeMeleed( true )

	shieldMineProp.RemoveFromAllRealms()
	shieldMineProp.AddToOtherEntitysRealms( player )

	FiringRange_AddToRemoveOnCharacterChange( shieldMineProp, player )

	//smokeCenterProp.SetParent(  )
	shieldMineProp.SetBossPlayer( player )
	shieldMineProp.SetOwner( player )
	SetTeam( shieldMineProp, player.GetTeam() )
	shieldMineProp.SetScriptName( SHIELD_MINE_PROP_SCRIPTNAME )
	SetTargetName( shieldMineProp, SHIELD_MINES_THREAT_PROP_TARGETNAME )
	//SetTargetName( smokeCenterProp, THREAT_PROP_TARGETNAME )
	shieldMineProp.SetPhysics( MOVETYPE_FLY ) // doesn't actually make it move, but allows pushers to interact with it
	shieldMineProp.SetAIObstacle( true )	// AI will try to navigate around this
	shieldMineProp.kv.contents = int( shieldMineProp.kv.contents ) & ~CONTENTS_TITANCLIP // So hover vehicles don't collide with them
	shieldMineProp.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	shieldMineProp.SetIgnorePredictedTriggerTypes( TT_JUMP_PAD | TT_GRAVITY_LIFT | TT_BLACKHOLE ) // So it ignores jump pads placed underneath later
	//shieldMineProp.SetNeverCrush( true )
	//shieldMineProp.SetScriptPropFlags( SPF_OBJECT_PLACEMENT_SPECIAL_IGNORE )
	shieldMineProp.e.preventStickyEnts = true

	shieldMineProp.e.noOwnerFriendlyFire      = true
	shieldMineProp.e.canBeDamagedFromGas      = false
	shieldMineProp.e.canBurn                  = true
	shieldMineProp.SetTouchTriggers( true )

	if ( IsValid( parentTo ) )
	{
		shieldMineProp.SetParent( parentTo )
	}

	AddWreckingBallEMPDamageDevice( shieldMineProp )

                 
                                           
       

	AddEntityCallback_OnPostDamaged( shieldMineProp, ShieldMine_OnPostDamaged )

	PlayerObjects_CommonInit( player, shieldMineProp, true, "sp_friendly_hero", false, false, true, null, eEmpDestroyType.EMP_DESTROY_DAMAGE )

	AddNewLimitedLegendObject( player, shieldMineProp, SHIELD_MINE_MAX_NUM_PER_PLAYER )

	EndSignal( shieldMineProp, "OnDestroy" )
	EndSignal( shieldMineProp, "OnDeath" )
	EndSignal( shieldMineProp, "EMP_Destroy" )
	EndSignal( player, "SquadEliminated" )

	if ( !( player in file.playersShieldMines ) )
	{
		array<entity> shieldMines
		file.playersShieldMines[player] <- shieldMines
	}
	array<entity> shieldMinesLandedBefore = clone file.playersShieldMines[player]
	file.playersShieldMines[player].append(shieldMineProp)

	array<entity> fxArray

	OnThreadEnd(
		function() : ( fxArray, shieldMineProp, player )
		{
			RemoveLimitedLegendObject( player, shieldMineProp )

			foreach ( fx in fxArray )
			{
				if ( IsValid( fx ) )
				{
					EffectSetControlPointVector( fx, 1, <0, 0, 0> )
					EffectStop( fx )
					fx.Destroy()
				}
			}

			if ( IsValid( shieldMineProp ) )
			{
				StopSoundOnEntity( shieldMineProp, SHIELD_MINE_LOOP_SOUND )
				thread ShieldMine_PowerDown( shieldMineProp )
			}

			file.playersShieldMines[player].removebyvalue(shieldMineProp)
		}
	)

	waitthread ShieldMinePropArming_Thread( shieldMineProp, SHIELD_MINE_ARMING_TIME )

	thread ShieldMineAnim_DoActivateAnims( shieldMineProp )

	int fxCenterAttachPt = shieldMineProp.LookupAttachment( SHIELD_MINE_FX_ATTACH )

	// Connection FX between mines
	const float SHIELD_MINE_CONNECTION_RANGE_SQR = (2.25*SHIELD_MINE_RANGE) * (2.25*SHIELD_MINE_RANGE)
	foreach ( shieldMine in shieldMinesLandedBefore )
	{
		if ( !IsValid( shieldMine ) )
			continue

		if ( shieldMine == shieldMineProp )
			continue

		float distanceSqr = DistanceSqr(shieldMine.GetOrigin(), shieldMineProp.GetOrigin() )
		if( distanceSqr <= SHIELD_MINE_CONNECTION_RANGE_SQR )
		{
			thread ShieldMine_CreateConnectingRope( shieldMineProp, shieldMine )
		}
	}


	float fxRadius = radius * 1.1

	{
		int radiusFXIndex       = GetParticleSystemIndex( SHIELD_MINES_RADIUS_FX )
		entity radiusFriendlyFX = StartParticleEffectOnEntity_ReturnEntity ( shieldMineProp, radiusFXIndex, FX_PATTACH_POINT_FOLLOW, fxCenterAttachPt  )
		radiusFriendlyFX.SetOwner( shieldMineProp )
		SetTeam( radiusFriendlyFX, shieldMineProp.GetTeam() )
		radiusFriendlyFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_OWNER

		EffectSetControlPointVector( radiusFriendlyFX, 1, <fxRadius, 0, 0> )

		fxArray.append( radiusFriendlyFX )
	}

	{
		int radiusFXIndex    = GetParticleSystemIndex( SHIELD_MINES_RADIUS_ENEMY_FX )
		entity radiusEnemyFX = StartParticleEffectOnEntity_ReturnEntity ( shieldMineProp, radiusFXIndex, FX_PATTACH_POINT_FOLLOW, fxCenterAttachPt  )
		radiusEnemyFX.SetOwner( shieldMineProp )
		SetTeam( radiusEnemyFX, shieldMineProp.GetTeam() )
		radiusEnemyFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY

		EffectSetControlPointVector( radiusEnemyFX, 1, <fxRadius, 0, 0> )

		fxArray.append( radiusEnemyFX )
	}

	if ( !IsValid( shieldMineProp ) )
		return

	EmitSoundOnEntity( shieldMineProp, SHIELD_MINE_LOOP_SOUND )



	float endTime = Time() + SHIELD_MINE_LIFETIME
	while( Time() <= endTime )
	{
		vector damagePos = shieldMineProp.GetAttachmentOrigin( fxCenterAttachPt )
		//
		if ( SHIELD_MINES_DEBUG )
		{
			DebugDrawSphere( damagePos, 3, COLOR_RED, true, 0.1)
			DebugDrawSphere( damagePos, radius, COLOR_YELLOW, false, 0.1 )
		}


		RadiusDamage(
			damagePos,
			shieldMineProp.GetOwner(), //attacker
			shieldMineProp, //inflictor
			SHIELD_MINE_DAMAGE,
			SHIELD_MINE_DAMAGE,
			radius, // inner radius
			radius, // outer radius
			SF_ENVEXPLOSION_NO_DAMAGEOWNER | SF_ENVEXPLOSION_MASK_BRUSHONLY,
			0, // distanceFromAttacker
			0, // explosionForce
			DF_NO_SELF_DAMAGE,
			eDamageSourceId.mp_ability_conduit_shield_mines )

		WaitFrame()

	}
}

void function ShieldMine_PowerDown( entity shieldMineProp )
{
	shieldMineProp.Signal("OnMineShutdown")
	thread ShieldMineAnim_AnimateZ( shieldMineProp, 0.5, -SHIELD_MINE_MODEL_Z_OFFSET_ARMING )
	waitthread PlayAnimOnly( shieldMineProp, "prop_conduit_ultimate_jammer_end" )

	if ( IsValid( shieldMineProp ) )
		shieldMineProp.Dissolve( ENTITY_DISSOLVE_CORE, ZERO_VECTOR, 500 )

	while( IsValid( shieldMineProp ) && shieldMineProp.IsDissolving() )
	{
		WaitFrame()
	}

	if ( IsValid( shieldMineProp ) )
		shieldMineProp.Destroy()
}

void function ShieldMine_CreateConnectingRope( entity shieldMine1, entity shieldMine2 )
{
	EndSignal( shieldMine1, "OnMineShutdown" )
	EndSignal( shieldMine1, "OnDestroy" )
	EndSignal( shieldMine1, "OnDeath" )

	EndSignal( shieldMine2, "OnMineShutdown" )
	EndSignal( shieldMine2, "OnDestroy" )
	EndSignal( shieldMine2, "OnDeath" )


	array<entity> fxArray

	int fxCenterAttachPt = shieldMine1.LookupAttachment( SHIELD_MINE_FX_ATTACH )
	int connectingRopeID = GetParticleSystemIndex( SHIELD_MINES_CONNECTION_FX )

	entity connectingFriendlyFX = StartParticleEffectOnEntity_ReturnEntity( shieldMine1, connectingRopeID, FX_PATTACH_POINT_FOLLOW, fxCenterAttachPt )
	EffectSetControlPointEntity( connectingFriendlyFX, 1, shieldMine2 )
	EffectSetControlPointVector( connectingFriendlyFX, 2, <77, 217, 255> )
	SetTeam( connectingFriendlyFX, shieldMine1.GetTeam() )
	connectingFriendlyFX.SetOwner( shieldMine1 )
	connectingFriendlyFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_OWNER

	fxArray.append( connectingFriendlyFX )

	entity connectingEnemyFX = StartParticleEffectOnEntity_ReturnEntity( shieldMine1, connectingRopeID, FX_PATTACH_POINT_FOLLOW, fxCenterAttachPt )
	EffectSetControlPointEntity( connectingEnemyFX, 1, shieldMine2 )
	EffectSetControlPointVector( connectingEnemyFX, 2, <255,188,137> )
	SetTeam( connectingEnemyFX, shieldMine1.GetTeam() )
	connectingEnemyFX.SetOwner( shieldMine1 )
	connectingEnemyFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY

	fxArray.append( connectingEnemyFX )

	OnThreadEnd(
		function() : ( fxArray )
		{
			foreach ( fx in fxArray )
			{
				if ( IsValid( fx ) )
				{
					EffectSetControlPointVector( fx, 1, <0, 0, 0> )
					EffectStop( fx )
					fx.Destroy()
				}
			}
		}
	)

	WaitForever()
}

void function ShieldMine_OnPostDamaged( entity shieldMine, var damageInfo )
{
	entity attacker  = DamageInfo_GetAttacker( damageInfo )
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	entity weapon    = DamageInfo_GetWeapon ( damageInfo )

	if ( !IsValid( shieldMine ) )
		return

	if ( !IsValid( attacker ) )
		return

	if ( !IsValid( inflictor ) )
		return

	int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )
	float damage    = DamageInfo_GetDamage( damageInfo )
	if ( damage <= 0 )
		return

	damage = DamageInfo_GetDamage( damageInfo )
	bool isDestroyed = (shieldMine.GetHealth() - damage) <= 0

	if ( attacker.IsPlayer() && inflictor.GetScriptName() != SHIELD_MINE_PROP_SCRIPTNAME )
	{
		if ( isDestroyed )
			DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
		else
			DamageInfo_AddCustomDamageType( damageInfo, DF_SOUR )

		attacker.NotifyDidDamage( shieldMine, 0, DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ),
			DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ) | DF_NO_HITBEEP,
			DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
	}

	int maxHealth = shieldMine.GetMaxHealth()
	int health    = shieldMine.GetHealth()
	//
	float newHealth  = max( health - damage, 0.0 )
	float healthFrac = newHealth / maxHealth
	//
	float currTime = Time()
	if ( !(shieldMine in file.lastDamageFxTime) )
		file.lastDamageFxTime[shieldMine] <- currTime

	float damageTimeDelta = currTime - file.lastDamageFxTime[shieldMine]
	if ( !isDestroyed && (healthFrac <= 0.99) && (damageTimeDelta >= 0.5) )
	{
		ShieldMine_PlayTrapDamagedFX( shieldMine )

		file.lastDamageFxTime[shieldMine] = currTime
	}


	if ( isDestroyed )
	{
		ShieldMine_PlayTrapDestroyFX( shieldMine )
	}
}

void function ShieldMine_PlayTrapDestroyFX( entity shieldMine, bool selfDestroy = false )
{
	int damageFXAttachID = shieldMine.LookupAttachment( SHIELD_MINE_FX_ATTACH )
	vector fxPos = shieldMine.GetAttachmentOrigin( damageFXAttachID )

	thread ShieldMine_PlayTrapDestroyFXAtPos( fxPos, shieldMine, selfDestroy )
}

void function ShieldMine_PlayTrapDestroyFXAtPos( vector fxPos, entity realmsEntity, bool selfDestroy = false )
{
	if ( selfDestroy )
	{
		int destroyFXID = GetParticleSystemIndex( SHIELD_MINE_FAIL_FX )
		entity fx            = StartParticleEffectInWorld_ReturnEntity( destroyFXID, fxPos, ZERO_VECTOR )
		fx.RemoveFromAllRealms()
		fx.AddToOtherEntitysRealms( realmsEntity )
	}
	else
	{
		int destroyFXID = GetParticleSystemIndex( SHIELD_MINE_DESTROY_FX )
		entity fx            = StartParticleEffectInWorld_ReturnEntity( destroyFXID, fxPos, ZERO_VECTOR )
		fx.RemoveFromAllRealms()
		fx.AddToOtherEntitysRealms( realmsEntity )
		SetTeam( fx, realmsEntity.GetTeam() )
		fx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY

		int enemyDestroyFXID = GetParticleSystemIndex( SHIELD_MINE_DESTROY_ENEMY_FX )
		entity enemyFx            = StartParticleEffectInWorld_ReturnEntity( enemyDestroyFXID, fxPos, ZERO_VECTOR )
		enemyFx.RemoveFromAllRealms()
		enemyFx.AddToOtherEntitysRealms( realmsEntity )
		SetTeam( enemyFx, realmsEntity.GetTeam() )
		enemyFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
	}


	if ( selfDestroy )
		EmitSoundAtPosition( TEAM_UNASSIGNED, fxPos, SHIELD_MINE_DESTROY_SELF_SOUND, realmsEntity )
	else
		EmitSoundAtPosition( TEAM_UNASSIGNED, fxPos, SHIELD_MINE_DESTROY_SOUND, realmsEntity )
}


void function ShieldMine_PlayTrapDamagedFX( entity shieldMine )
{
	int damageFXID       = GetParticleSystemIndex( SHIELD_MINE_DAMAGE_SPARK_FX )

	if ( shieldMine.IsMarkedForDeletion() )
		return

	entity fx = StartParticleEffectOnEntityWithPos_ReturnEntity( shieldMine, damageFXID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, shieldMine.GetUpVector() * 4, VectorToAngles( shieldMine.GetUpVector() ) )
	fx.RemoveFromAllRealms()
	fx.AddToOtherEntitysRealms( shieldMine )

	EmitSoundOnEntity( shieldMine, SHIELD_MINE_DAMAGE_SPARK_SOUND )
}
#endif



#if CLIENT
void function AddThreatIndicator( entity grenade )
{
	SetAllowForKillreplayProjectileCam( grenade )
	SetCustomKillreplayChaseCamFromWeaponClass( grenade, SHIELD_MINE_BOMBARDMENT_WEAPON )

	// is there a non dev way to get the radius of the damageDef
	entity player         = GetLocalViewPlayer()
	entity grenadeOwner = grenade.GetOwner()
	ShowGrenadeArrow( player, grenade, GetMineRadius( grenadeOwner )*1.4, 0.0, false, eThreatIndicatorVisibility.INDICATOR_SHOW_TO_ENEMIES, <0, 0, SHIELD_MINE_MODEL_Z_OFFSET> )
}
#endif //


 