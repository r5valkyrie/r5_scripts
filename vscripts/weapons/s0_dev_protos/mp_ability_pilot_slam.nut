global function OnWeaponPrimaryAttack_ability_pilot_slam
global function OnWeaponAttemptOffhandSwitch_ability_pilot_slam

#if SERVER
global function OnWeaponNpcPrimaryAttack_ability_pilot_slam
global function DEV_ToggleAutoFillSlamMeter

global function PilotSlam_PlayerPressedButton
#endif


global function SpWeaponPilotSlam_Init

const float MIN_GRAPPLE_SLAM_METER = 0.0
const float MAX_GRAPPLE_SLAM_METER = 100.0
const float GRAPPLE_SLAM_BASE_EARN_TICK = 1.0
const float GRAPPLE_SLAM_EARN_SPRINT = 2.0
const float GRAPPLE_SLAM_FLYING_EARN = 5.0
const float GRAPPLE_SLAM_EARN_WALLRUN = 15.0
//const float GRAPPLE_SLAM_EARN_SLIDE = 5.0
//const float GRAPPLE_SLAM_EARN_GRAPPLE = 5.0
const GRAPPLE_SLAM_INITIAL_SPEED = 1500.0

float currentPilotSlamMeter
bool pilotSlamReadyMessageDisplayed
WeaponPrimaryAttackParams& currentAttackParams
bool validAttackParams
bool dev_autoFillSlamMeter


void function SpWeaponPilotSlam_Init()
{
#if SERVER
	AddCallback_OnPlayerRespawned( PlayerDidRespawn )
#endif
}

#if SERVER
void function PlayerDidRespawn( entity player )
{
	AddButtonPressedPlayerInputCallback( player, IN_MELEE, PilotSlam_PlayerPressedButton )
	// thread PilotSlamMeterThink( player ) //Requires grapple. Cafe
}

// void function PlayerDidRespawn_Think( entity player )
// {
	// player.EndSignal( "OnDestroy" )

	// FlagWait( "EntitiesDidLoad" )

	// // HACK. PROTO. We need a real callback for this if we move forward with this ability.
	// while ( 1 )
	// {
		// entity offhand = GetOffhand( player, "mp_ability_pilot_slam" )
		// if ( IsValid( offhand ) && offhand.GetWeaponClassName() == "mp_ability_pilot_slam" )
			// break

		// wait 0.1
	// }

	// //AddPlayerHeldButtonEventCallback( player, IN_MELEE, PilotSlam_PlayerPressedButton, 0.2 )
	// AddButtonPressedPlayerInputCallback( player, IN_MELEE, PilotSlam_PlayerPressedButton )

	// player.SetPlayerSettingsWithMods( DEFAULT_PILOT_SETTINGS, [ "pas_ads_hover" ] )

	// thread PilotSlamMeterThink( player )
// }
#endif // SERVER


void function PilotSlam_PlayerPressedButton( entity player )
{
#if SERVER

	// if ( currentPilotSlamMeter < MAX_GRAPPLE_SLAM_METER )
		// return


	// -------------------------------------------------------------
	// Version 1: Fly to the crosshair and slam (no grapple needed)
	// if ( GetBugReproNum() == 0 )
	// {
		vector eyePos = player.EyePosition()
		vector pos = GetPlayerCrosshairOrigin( player )
		vector dir = player.GetViewForward()
		//DebugDrawLine( playerPos, playerPos + ( dir * 1100 ), 0, 255, 0, true, 10 )
		TraceResults result = TraceLine( eyePos, eyePos + ( dir * 1100 ), null, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )

		if ( IsValid( result.hitEnt ) && result.hitEnt.GetClassName() == "worldspawn" )
			thread DoPilotSlam( player, result.endPos )
	// }


	// -------------------------------------------------------------
	// Version 2: Fly to the grapple spot and slam
	// if ( GetBugReproNum() == 1 )
	// {
		// if ( !player.MayGrapple() )
			// return

		// if ( !validAttackParams )
			// return

		// vector pos = currentAttackParams.pos
		// vector dir = currentAttackParams.dir
		// //DebugDrawLine( pos, pos + ( dir * 1100 ), 0, 255, 0, true, 10 )
		// TraceResults result = TraceLine( pos, pos + ( dir * 1100 ), null, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )

		// if ( IsValid( result.hitEnt ) && result.hitEnt.GetClassName() == "worldspawn" )
			// thread DoPilotSlam( player, result.endPos )

		// validAttackParams = false
	// }

#endif // SERVER
}


void function PilotSlamMeterThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	currentPilotSlamMeter = MIN_GRAPPLE_SLAM_METER

	while ( 1 )
	{
		if ( player.HasGrapple() )
		{
			// Flying through the air
			if ( !player.IsOnGround() && !player.IsWallRunning() )
			{
				currentPilotSlamMeter += GRAPPLE_SLAM_FLYING_EARN
			}
			else if ( player.IsWallRunning() )
			{
				currentPilotSlamMeter += GRAPPLE_SLAM_EARN_WALLRUN
			}
			else if ( player.IsSprinting() )
			{
				currentPilotSlamMeter += GRAPPLE_SLAM_EARN_SPRINT
			}
			else
			{
				currentPilotSlamMeter += GRAPPLE_SLAM_BASE_EARN_TICK
			}

			if ( currentPilotSlamMeter > MAX_GRAPPLE_SLAM_METER )
				currentPilotSlamMeter = MAX_GRAPPLE_SLAM_METER

			if ( dev_autoFillSlamMeter )
				currentPilotSlamMeter = MAX_GRAPPLE_SLAM_METER

			#if SERVER

			// Remote_CallFunction_Replay( player, "ScriptCallback_SetPilotSlamMeterValue", currentPilotSlamMeter )

			if ( currentPilotSlamMeter >= MAX_GRAPPLE_SLAM_METER && !pilotSlamReadyMessageDisplayed )
			{
				EmitSoundOnEntity( player, "titan_shield_ready" )
				EmitSoundOnEntity( player, "hud_40mm_trackerbeep_locked" )

				pilotSlamReadyMessageDisplayed = true

				thread DrawSlamHint( player )
			}
			#endif // SERVER
		}

		wait 1
	}
}


#if SERVER

void function DEV_ToggleAutoFillSlamMeter()
{
	dev_autoFillSlamMeter = !dev_autoFillSlamMeter
}


void function DrawSlamHint( entity player )
{
	player.EndSignal( "SlamActivated" )
	player.EndSignal( "OnDestroy" )

	while ( 1 )
	{
		vector eyePos = player.EyePosition()
		vector pos = GetPlayerCrosshairOrigin( player )

		if ( Distance( pos, eyePos ) <= 1100 )
		{
			vector dir = player.GetViewForward()
			TraceResults result = TraceLine( eyePos, eyePos + ( dir * 1100 ), null, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )

			if ( IsValid( result.hitEnt ) )
			{
			//	DebugDrawCircle( result.endPos, <0,0,0>, 25.0, 0, 255, 0, true, 0.02 )
			//	DebugDrawCircle( result.endPos, <0,0,0>, 15.0, 0, 255, 0, true, 0.02 )
			//	DebugDrawCircle( result.endPos, <0,0,0>, 5.0, 0, 255, 0, true, 0.02 )

				for ( int i = 0; i <= 25; i++ )
					DebugDrawCircle( result.endPos, <0,0,0>, float(i), 0, 255, 0, true, 0.02 )
			}
		}

		WaitFrame()
	}
}




void function DoPilotSlam( entity player, vector targetPos )
{
	player.Signal( "SlamActivated" )
	player.EndSignal( "SlamActivated" )

	printt( "targetPos:", targetPos )

	//targetPos = GetPlayerCrosshairOrigin( player )

	currentPilotSlamMeter = MIN_GRAPPLE_SLAM_METER
	pilotSlamReadyMessageDisplayed = false

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

#endif // SERVER



var function OnWeaponPrimaryAttack_ability_pilot_slam( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()

#if SERVER
	currentAttackParams = attackParams
	validAttackParams = true

	if ( owner.MayGrapple() )
	{
		#if BATTLECHATTER_ENABLED
			TryPlayWeaponBattleChatterLine( owner, weapon ) //Note that this is fired whenever you fire the grapple, not when you've successfully grappled something. No callback for that unfortunately...
		#endif // BATTLECHATTER_ENABLED
	}
#endif // SERVER

	PlayerUsedOffhand( owner, weapon )

	owner.Grapple( attackParams.dir )

	return 1
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_ability_pilot_slam( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()

	owner.GrappleNPC( attackParams.dir )

	return 1
}
#endif // SERVER

bool function OnWeaponAttemptOffhandSwitch_ability_pilot_slam( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	bool allowSwitch = (ownerPlayer.GetSuitGrapplePower() >= 100.0)

	if ( !allowSwitch )
	{
		Assert( ownerPlayer == weapon.GetWeaponOwner() )
		ownerPlayer.Grapple( <0,0,1> )
	}

	return allowSwitch
}


