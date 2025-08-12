global function OnWeaponAttemptOffhandSwitch_ability_dodge_roll
global function OnWeaponPrimaryAttack_ability_dodge_roll
global function DodgeRoll_GetDirectionFromInput
#if SERVER
global function OnWeaponNPCPrimaryAttack_ability_dodge_roll
#endif

const float DODGE_ROLL_SPEED_GROUND = 832.5
const float DODGE_ROLL_SPEED_AIR = 832.5 //500
const float DODGE_ROLL_SPEED_POST_DASH = 90
const float DODGE_ROLL_TIME = 0.4
const float DODGE_ROLL_CLOAK_TIME = 0.75
const float DODGE_ROLL_CLOAK_FADE_IN_TIME = 0.25

bool function OnWeaponAttemptOffhandSwitch_ability_dodge_roll( entity weapon )
{
	int ammoReq  = weapon.GetAmmoPerShot()
	int currAmmo = weapon.GetWeaponPrimaryClipCount()
	if ( currAmmo < ammoReq )
		return false

	entity player = weapon.GetWeaponOwner()

	if ( !IsValid( player ) )
		return false

	//Can't roll in air
	//if ( !player.IsOnGround() )
	//	return false

	return true
}

var function OnWeaponPrimaryAttack_ability_dodge_roll( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	//PlayWeaponSound( "fire" )
	entity player = weapon.GetWeaponOwner()

	float rollTime = DODGE_ROLL_TIME

	if ( IsAlive( player ) )
	{
		if ( player.IsPlayer() && !player.IsOnGround() )
		{
			PlayerUsedOffhand( player, weapon )

			#if SERVER
				EmitSoundOnEntityExceptToPlayer( player, player, "Stryder.Dash" )
				thread DodgeRoll_Attempt( weapon, player )

				float fade = 0.125
				StatusEffect_AddTimed( player, eStatusEffect.move_slow, 0.6, rollTime + fade, fade )
				StatusEffect_AddTimed( player, eStatusEffect.turn_slow, 1.0, rollTime + fade, fade )

				thread DodgeRoll_PostRollCleanUp( player, rollTime + fade, !player.IsOnGround() )
			#elseif CLIENT
				float xAxis = InputGetAxis( ANALOG_LEFT_X )
				float yAxis = InputGetAxis( ANALOG_LEFT_Y ) * -1
				vector angles = player.EyeAngles()
				vector directionForward = DodgeRoll_GetDirectionFromInput( angles, xAxis, yAxis )
				if ( IsFirstTimePredicted() )
				{
					EmitSoundOnEntity( player, "Stryder.Dash" )
				}
			#endif
		}
	}
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

#if SERVER
var function OnWeaponNPCPrimaryAttack_ability_dodge_roll( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return 0 //OnWeaponPrimaryAttack_ability_phase_dash( weapon, attackParams )
}

void function DodgeRoll_Attempt( entity weapon, entity player )
{
	player.ForceCrouch()
	float movestunEffect = 1.0 - StatusEffect_GetSeverity( player, eStatusEffect.dodge_speed_slow )
	float dashSpeed = player.IsOnGround() ? DODGE_ROLL_SPEED_GROUND : DODGE_ROLL_SPEED_AIR
	float moveSpeed = dashSpeed * movestunEffect
	DodgeRoll_SetPlayerVelocityFromInput( player, moveSpeed, <0,0,200> )

	//if ( !IsCloaked( player ) )
	//	EnableCloak( player, DODGE_ROLL_CLOAK_TIME, DODGE_ROLL_CLOAK_FADE_IN_TIME )
}

void function DodgeRoll_SetPlayerVelocityFromInput( entity player, float scale, vector baseVel = <0,0,0> )
{
	vector angles = player.EyeAngles()
	float xAxis = player.GetInputAxisRight()
	float yAxis = player.GetInputAxisForward()
	vector directionForward = DodgeRoll_GetDirectionFromInput( angles, xAxis, yAxis )

	player.SetVelocity( directionForward * scale + baseVel )
}

void function DodgeRoll_PostRollCleanUp( entity player, float duration, bool startedInAir )
{
	Assert( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	player.HolsterWeapon()

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{
				player.DeployWeapon()
				player.UnforceCrouch()
				player.UnforceStand()
			}
		}
	)

	bool wasStanding = player.IsStanding()

	//TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITIES_PHASE_DASH_START, player, player.GetOrigin(), player.GetTeam(), player.GetRealmsBitMask() )
	wait duration
	//TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITIES_PHASE_DASH_STOP, player, player.GetOrigin(), player.GetTeam(), player.GetRealmsBitMask() )

	if ( !startedInAir )
	{
		vector velNorm = Normalize( player.GetVelocity() )
		player.SetVelocity( velNorm * DODGE_ROLL_SPEED_POST_DASH )
	}

	player.SetCanBeAimAssistTrackedWhilePhased( false )

	if ( wasStanding )
		player.ForceStand()

	WaitFrame()

}
#endif

vector function DodgeRoll_GetDirectionFromInput( vector playerAngles, float xAxis, float yAxis )
{
	playerAngles.x = 0
	playerAngles.z = 0
	vector forward = AnglesToForward( playerAngles )
	vector right = AnglesToRight( playerAngles )

	vector directionVec = <0,0,0>
	directionVec += right * xAxis
	directionVec += forward * yAxis

	vector directionAngles = directionVec == <0,0,0> ? playerAngles : VectorToAngles( directionVec )
	vector directionForward = AnglesToForward( directionAngles )

	return directionForward
}