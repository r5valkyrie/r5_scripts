global function MpSpaceElevatorAbility_Init
global function OnWeaponReadyToFire_weapon_space_elevator_tac
global function OnWeaponDeactivate_weapon_space_elevator_tac
global function OnWeaponTossRelease_weapon_space_elevator_tac
global function SpaceElevatorTac_ProjectileLanded

const asset ELEVATOR_GRENADE_FX_GLOW_FP = $"P_repulsor_ptpov"
const asset ELEVATOR_GRENADE_FX_GLOW_3P = $"P_repulsor_pt3p"

const int CHANCE_TO_BATTLE_CHATTER_ELEVATOR = 50

void function MpSpaceElevatorAbility_Init()
{
	PrecacheParticleSystem( ELEVATOR_GRENADE_FX_GLOW_FP )
	PrecacheParticleSystem( ELEVATOR_GRENADE_FX_GLOW_3P )
}

void function OnWeaponReadyToFire_weapon_space_elevator_tac( entity weapon )
{
	weapon.PlayWeaponEffect( ELEVATOR_GRENADE_FX_GLOW_FP, ELEVATOR_GRENADE_FX_GLOW_3P, "muzzle_flash" )
}

void function OnWeaponDeactivate_weapon_space_elevator_tac( entity weapon )
{
	weapon.StopWeaponEffect( ELEVATOR_GRENADE_FX_GLOW_FP, ELEVATOR_GRENADE_FX_GLOW_3P )
	Grenade_OnWeaponDeactivate( weapon )
}

var function OnWeaponTossRelease_weapon_space_elevator_tac( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.StopWeaponEffect( ELEVATOR_GRENADE_FX_GLOW_FP, ELEVATOR_GRENADE_FX_GLOW_3P )
	entity ownerPlayer = weapon.GetWeaponOwner()
	int ammoReq        = weapon.GetAmmoPerShot()
	Assert( ownerPlayer.IsPlayer() )

	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )

	WeaponFireGrenadeParams fireGrenadeParams
	fireGrenadeParams.pos = attackParams.pos
	
	fireGrenadeParams.vel = attackParams.dir * 1
	fireGrenadeParams.angVel = <0, 0, 600> 
	fireGrenadeParams.fuseTime = 100.0 
	fireGrenadeParams.scriptTouchDamageType = damageTypes.projectileImpact
	fireGrenadeParams.scriptExplosionDamageType = damageTypes.explosive
	fireGrenadeParams.clientPredicted = true
	fireGrenadeParams.lagCompensated = true
	fireGrenadeParams.useScriptOnDamage = true
	
	entity projectile = weapon.FireWeaponGrenade( fireGrenadeParams )
	
	if ( IsValid( projectile ) )
	{
		entity player = weapon.GetWeaponOwner()
		PlayerUsedOffhand( player, weapon, true, projectile )

		#if SERVER
			string projectileSound = GetGrenadeProjectileSound( weapon )
			if ( projectileSound != "" )
				EmitSoundOnEntity( projectile, projectileSound )

			weapon.w.lastProjectileFired = projectile
		#endif
	}

	#if SERVER
		PlayBattleChatterLineToSpeakerAndTeam( weapon.GetOwner(), "bc_super" )
	#endif

	return ammoReq
}

void function SpaceElevatorTac_ProjectileLanded( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	if ( normal.z < 0.7 )
	{
		#if SERVER
			vector velocity = projectile.GetVelocity()
			vector bounceVel = velocity - 2 * DotProduct(velocity, normal) * normal
			projectile.SetVelocity( (bounceVel * .5) + (normal * 50) )
		#endif
		
		return 
	}

	bool didStick = PlantSuperStickyGrenade( projectile, pos, normal, hitEnt, hitbox )
	if ( !didStick )
		return

	#if SERVER
		if ( projectile.IsMarkedForDeletion() )
			return
			
		entity projOwner = projectile.GetOwner()
		entity parentTo = projectile.GetParent()
		
		vector surfaceAngles = projectile.proj.savedAngles
		TraceResults traceResult = TraceLine( pos, pos - normal * 32, [ projectile ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
		if ( traceResult.fraction < 1.0 )
		{
			vector forward = AnglesToForward( projectile.proj.savedAngles )
			surfaceAngles = AnglesOnSurface( traceResult.surfaceNormal, forward )
		}
		
		if ( IsValid( projectile ) )
			projectile.Destroy()
			
		vector adjustedPos = pos - <0, 0, 8.0>
			
		thread SpaceElevator_PropDeploy( projOwner, adjustedPos, ZERO_VECTOR, parentTo )
	#endif
}