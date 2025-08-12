global function OnWeaponPrimaryAttack_ability_ground_slam
global function MpWeaponGroundSlam_Init

const SMALL_GROUND_SLAM_FX_TABLE = "exp_medium"
const MEDIUM_GROUND_SLAM_FX_TABLE = "exp_large"
const LARGE_GROUND_SLAM_FX_TABLE = "exp_xlarge"
const GROUND_SLAM_FX = $"wpn_grenade_frag_mag_trail"

const MAX_DESCENT_ANGLE = 25.0
const GROUND_SLAM_INITIAL_SPEED = 350.0

void function MpWeaponGroundSlam_Init()
{
	#if SERVER
		PrecacheImpactEffectTable( SMALL_GROUND_SLAM_FX_TABLE )
		PrecacheImpactEffectTable( MEDIUM_GROUND_SLAM_FX_TABLE )
		PrecacheImpactEffectTable( LARGE_GROUND_SLAM_FX_TABLE )
		PrecacheParticleSystem( GROUND_SLAM_FX )
		
		RegisterSignal( "SlamActivated" )
	#endif
}

var function OnWeaponPrimaryAttack_ability_ground_slam( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetWeaponOwner()

	if( !IsValid( ownerPlayer ) || !ownerPlayer.IsPlayer() || !IsAlive( ownerPlayer ) )
		return false
	
	// Assert( IsValid( ownerPlayer) && ownerPlayer.IsPlayer() )
	// if ( IsValid( ownerPlayer ) && ownerPlayer.IsPlayer() )
	// {
		// if ( ownerPlayer.GetCinematicEventFlags() & CE_FLAG_CLASSIC_MP_SPAWNING )
			// return false

		// if ( ownerPlayer.GetCinematicEventFlags() & CE_FLAG_INTRO )
			// return false
	// }

	#if SERVER
		//Cafe was here
		//I integrated the two slam protos into one single file.
		if( !GetCurrentPlaylistVarBool( "proto_ground_slam_type", false ) )
		{
			//Proto 1. Go to the point straight
			thread PROTO_PilotSlam( ownerPlayer )
		} else
		{
			// Proto 2. Can send you to the air
			thread PROTO_GroundSlam( ownerPlayer )
		}
	#endif

	return 1
}

vector function CalculateVectorBetweenTwoVectors( vector vec1, vector vec2, float angle )
{
	//TODO: Repurpose this into a general utility function RotateVectorToVector & preserve magnitude
	vector perpendicularVector = Normalize( CrossProduct( CrossProduct( vec1, vec2 ), vec1 ) )
	vector newVector = vec1 * deg_cos( angle ) + perpendicularVector * deg_sin( angle )

	//float dot = DotProduct( vec1, newVector )
	//local angleBetweenNewVectors = DotToAngle( dot )

	return newVector
}

#if SERVER
void function PROTO_GroundSlam( entity player )
{
	player.EndSignal( "OnDeath" )

	if ( player.IsOnGround() )
	{
		player.SetVelocity( ( player.GetUpVector() + player.GetForwardVector() ) * 2000 )
		wait 0.1
	}
	vector velocity = GetGroundSlamVelocity( player )
	player.SetVelocity( velocity )
	vector startingPos = player.GetOrigin()
	HolsterAndDisableWeapons( player )
	EmitSoundOnEntity( player, "Pilot_GroundPound_Windrush" )

	//thread PlayAnim( player, "pt_drone_ride_idle" )
	entity fx1 = PlayLoopFXOnEntity( GROUND_SLAM_FX, player, "vent_left" )
	entity fx2 = PlayLoopFXOnEntity( GROUND_SLAM_FX, player, "vent_right" )

	OnThreadEnd(
		function() : ( player, fx1, fx2 )
		{
			if ( IsValid( player ) )
			{
				DeployAndEnableWeapons( player )
				StopSoundOnEntity( player, "Pilot_GroundPound_Windrush" )
			}

			StopFX( fx1 )
			StopFX( fx2 )
		}
	)

	while ( !player.IsOnGround() ) //&& !RodeoState_GetIsPlayerRodeoing( player ) )
	{
		wait 0.1

		if ( !IsValid( player ) )
			return

		velocity = velocity * 1.8
		player.SetVelocity( velocity )
	}

	vector landingPos = player.GetOrigin()
	PROTO_GroundSlamExplosion( player, startingPos.z - landingPos.z, landingPos )
	player.SetVelocity( <0,0,0> )
	//player.Anim_Stop()
}

vector function GetGroundSlamVelocity( entity player )
{
	//vector velocity = player.GetVelocity()
	vector viewVector = player.GetViewVector()

	// If the player is looking up, slam down directly below them.
	if ( viewVector.z >= 0 )
		return <0,0,-GROUND_SLAM_INITIAL_SPEED>

	//Otherwise, clamp to the MAX_DESCENT_ANGLE and skew downward velocity
	vector downVector = player.GetUpVector() * -1
	float dot = DotProduct( downVector, viewVector )
	float angle = DotToAngle( dot )
	if ( angle > MAX_DESCENT_ANGLE )
	{
		return CalculateVectorBetweenTwoVectors( downVector, viewVector, MAX_DESCENT_ANGLE ) * GROUND_SLAM_INITIAL_SPEED
	}
	else
	{
		return viewVector * GROUND_SLAM_INITIAL_SPEED
	}

	unreachable
}

void function PROTO_GroundSlamExplosion( entity player, float heightDifference, vector landingPos )
{
	string fxTable
	float damage
	float damageHeavyArmor
	float outerRadius

	if ( heightDifference < 100 )
	{
		damage = 100.0
		damageHeavyArmor = 500.0
		outerRadius = 100.0
		fxTable = SMALL_GROUND_SLAM_FX_TABLE
	}
	else if ( heightDifference < 400 )
	{
		damage = 300.0
		damageHeavyArmor = 1500.0
		outerRadius = 200.0
		fxTable = MEDIUM_GROUND_SLAM_FX_TABLE
	}
	else
	{
		damage = 400.0
		damageHeavyArmor = 2000.0
		outerRadius = 300.0
		fxTable = LARGE_GROUND_SLAM_FX_TABLE
	}

	Explosion(
		landingPos,										//center,
		player,											//attacker,
		player,											//inflictor,
		damage,											//damage,
		damageHeavyArmor,								//damageHeavyArmor,
		50.0,											//innerRadius,
		outerRadius,									//outerRadius,
		SF_ENVEXPLOSION_NO_DAMAGEOWNER,					//flags,
		landingPos,										//projectileLaunchOrigin,
		1000.0,											//explosionForce,
		damageTypes.explosive,							//scriptDamageFlags,
		eDamageSourceId.mp_ability_ground_slam,			//scriptDamageSourceIdentifier,
		fxTable )										//impactEffectTableName
}



//PROTO
const GRAPPLE_SLAM_INITIAL_SPEED = 1500.0

void function PROTO_PilotSlam( entity player )
{
	vector eyePos = player.EyePosition()
	vector pos = GetPlayerCrosshairOrigin( player )
	vector dir = player.GetViewForward()
	//DebugDrawLine( playerPos, playerPos + ( dir * 1100 ), 0, 255, 0, true, 10 )
	TraceResults result = TraceLine( eyePos, eyePos + ( dir * 1100 ), null, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )

	if ( IsValid( result.hitEnt ) && result.hitEnt.GetClassName() == "worldspawn" )
		thread DoPilotSlam( player, result.endPos )
}

void function DoPilotSlam( entity player, vector targetPos )
{
	player.Signal( "SlamActivated" )
	player.EndSignal( "SlamActivated" )

	printt( "targetPos:", targetPos )

	EmitSoundOnEntity( player, "titan_1p_warpfall_start" )
	StimPlayer( player, 1.0 )

	//bool pilotIsMoving = Length( player.GetVelocity() ) >= 100

	vector velocity = ( targetPos - player.GetOrigin() )
	velocity = Normalize( velocity ) * GRAPPLE_SLAM_INITIAL_SPEED
	player.SetVelocity( velocity )

	while ( Distance( player.GetOrigin(), targetPos ) > 100 )
	{
		WaitFrame()

		if ( !IsValid( player ) )
			return

		player.SetVelocity( velocity )
	}

	player.SetVelocity( <0,0,0> )

	thread PilotSlamExplosion( player, player.GetOrigin() )
}


void function PilotSlamExplosion( entity player, vector landingPos )
{
	EmitSoundOnEntity( player, "SuperSpectre.GroundSlam.Impact" )

	PlayImpactFXTable( landingPos, player, "superSpectre_groundSlam_impact" )

	RadiusDamage_DamageDefSimple( damagedef_pilot_slam, landingPos, player, player, 0 )
}

#endif
