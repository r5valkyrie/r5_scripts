#if SERVER
global function MaggieCommon_ValidateEntityInDangerZone
global function MaggieCommon_ImpactTableFX_Think
#endif

global function MpMaggieCommon_Init
global function MaggieCommon_KnockbackTargetFromAttacker
global function MaggieCommon_KnockbackTargetFromEntity
global function MaggieCommon_CleanUpFX
global function MaggieCommon_GetTrapToDestroyNames

struct
{
	//TO DO: TURN THESE INTO FUNCTIONS THAT TRAPS CALL TO REGISTER THEMSELVES FOR CONCUSSIVE BREACH DAMAGE/DESTRUCTION!!!
	array<string> destroyTrapNames = [
		"caustic_trap",
		"tesla_trap_proxy",
		"crypto_camera",
		"crypto_camera_ultimate",
		"debris_trap",
		"cover_wall",
		"mounted_turret_placeable",
	]
}
file

///////////////////////////////////
/// CLIENT AND SERVER FUNCTIONS ///
///////////////////////////////////

void function MpMaggieCommon_Init()
{
	RegisterSignal( "MaggieCommon_StopImpactTableFX" )
}

void function MaggieCommon_CleanUpFX( entity fx, float time )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	EndSignal( fx, "OnDestroy" )
	entity fxParent = fx.GetParent()
	if ( IsValid( fxParent ) )
		EndSignal( fxParent, "OnDeath", "OnDestroy" )

	OnThreadEnd(
		function() : ( fx )
		{
			if ( IsValid( fx ) )
				fx.Destroy()
		}
	)

	wait time
}

void function MaggieCommon_KnockbackTargetFromAttacker( entity attacker, entity target, float magnitude = 350 )
{
	if ( IsValid( target ) )
	{
		vector lookDirection		= attacker.GetViewForward()
		vector pushBackVelocity		= magnitude * lookDirection

		if ( target.IsPlayer() || target.IsNPC() || target.IsPlayerDecoy() )
		{
			vector targetDirection = target.GetWorldSpaceCenter() - attacker.GetWorldSpaceCenter()
			if ( DotProduct( lookDirection, targetDirection ) < 0 )
				pushBackVelocity = -pushBackVelocity

			if ( target.IsPlayer() )
			{
				if ( LengthSqr( pushBackVelocity ) > 0.0 )
					target.KnockBack( pushBackVelocity, 0.25 )
			}
#if SERVER
			else
			{
				float pushbackScale = target.IsOnGround() ? 1.0 : 0.1
				PushEnt( target, pushBackVelocity * pushbackScale )
			}
#endif
		}
	}
}

void function MaggieCommon_KnockbackTargetFromEntity( entity ent, entity target, float magnitude = 300.0, vector sourceOffset = <0.0, 0.0, 0.0> )
{
	if ( !IsValid( target ) )
		return

	if ( target.IsPlayer() || target.IsNPC() || target.IsPlayerDecoy() )
	{
		vector dir					= Normalize ( ( target.GetOrigin() + <0.0, 0.0, 40.0> ) - ( ent.GetOrigin() + sourceOffset ) )
		vector pushBackVelocity		= magnitude * dir
		pushBackVelocity 			= < pushBackVelocity.x, pushBackVelocity.y, 300.0 >

		if ( target.IsPlayer() )
		{
			if ( LengthSqr( pushBackVelocity ) > 0.0 )
				target.KnockBack( pushBackVelocity, 0.25 )
		}
	#if SERVER
		else
		{
			float pushbackScale = target.IsOnGround() ? 1.0 : 0.1
			PushEnt( target, pushBackVelocity * pushbackScale )
		}
	#endif
	}
}

array<string> function MaggieCommon_GetTrapToDestroyNames()
{
	return file.destroyTrapNames
}

/////////////////////////
///  SERVER FUNCTIONS ///
/////////////////////////

#if SERVER
bool function MaggieCommon_ValidateEntityInDangerZone( entity trigger, entity ent, bool allowSelf )
{
	entity owner = trigger.GetOwner()

	if ( !IsValid( ent )  ) //|| !ent.IsPlayer()
		return false

	if ( !IsValid( owner ) )
		return false

	if ( !ent.DoesShareRealms( trigger ) )
		return false

	if ( ent.IsPlayer() || ent.IsNPC() || ent.IsPlayerDecoy() )
	{
		if ( ent == owner && allowSelf ) // self
			return true
		else if ( ent.GetTeam() == owner.GetTeam() ) // ally
			return false
		else // enemy
			return true
	}

	if ( IsCodeDoor( ent ) )
		return true

	if ( file.destroyTrapNames.contains( ent.GetScriptName() ) )
		return true

	return false
}

void function MaggieCommon_ImpactTableFX_Think( entity ent, string fxTable, float refireTime, float duration, float offset = 0, vector offsetDir = <0, 0, 0>, asset defaultFX = $"", vector defaultOffsetAngle = <0, 0, 0> )
{
	Assert( refireTime >= 0.1, "Refire time too short! Must be >= 0.1 " )

	EndSignal( ent, "MaggieCommon_StopImpactTableFX" )

	entity owner = ent.GetOwner()
	entity parentEnt = ent.GetParent()

	float endTime = Time() + duration

	while ( IsValid( ent ) && ( Time() < endTime ) )
	{
		vector pos = ent.GetOrigin() + ( offset * offsetDir )

		if ( IsValid( parentEnt ) && !parentEnt.IsWorld() && ( defaultFX != $"" ) )
			StartParticleEffectInWorld( GetParticleSystemIndex( defaultFX ), pos, defaultOffsetAngle )
		else
			PlayImpactFXTable( pos, owner, fxTable )

		wait refireTime
	}
}
#endif // #if SERVER