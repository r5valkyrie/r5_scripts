global function OnWeaponOwnerChanged_weapon_shotgun_kick
global function OnWeaponPrimaryAttack_weapon_shotgun_kick
global function WeaponShotgunKick_FireWeaponPlayerAndNPC

#if SERVER
global function OnWeaponNpcPrimaryAttack_weapon_shotgun_kick
#endif // #if SERVER

#if CLIENT
global function ServerCallback_ShotgunKickNoAmmoMessage
#endif //CLIENT

const MASTIFF_MAX_BOLTS = 8 // this is the code limit for bolts per frame... do not increase.

const float WEAPON_SHOTGUN_KICK_AMMO_MESSAGE_DURATION = 3.0

struct {
	float[2][MASTIFF_MAX_BOLTS] boltOffsets = [
		[0.0, 0.3], //
		[0.0, 0.6], //
		[0.0, 1.2], //
		[0.0, 2.4], //
		[0.0, -0.6], //
		[0.0, -1.2], //
		[0.0, -2.4], //
		[0.0, -0.3], //
	]
	/*
	float[2][MASTIFF_MAX_BOLTS] boltOffsets = [
		[0.0, 0.15], //
		[0.0, 0.3], //
		[0.0, 0.6], //
		[0.0, 1.2], //
		[0.0, -0.3], //
		[0.0, -0.6], //
		[0.0, -1.2], //
		[0.0, -0.15], //
	]
	*/

	/*array boltOffsets = [
		[0.0, 0.0], // center
		[1.0, 0.0], // top
		[0.0, 1.0], // right
		[0.0, -1.0], // left
		[0.5, 0.5],
		[0.5, -0.5],
		[-0.5, 0.5],
		[-0.5, -0.5]
	]*/
} file

void function OnWeaponOwnerChanged_weapon_shotgun_kick( entity weapon, WeaponOwnerChangedParams changeParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	if ( !IsValid( weaponOwner ) )
		return

	if ( !weaponOwner.IsPlayer() )
		return

	//Make this player require shotgun ammo for their shotgun boot.
	SetPlayerRequireLootType( weaponOwner, "shotgun" )
}

var function OnWeaponPrimaryAttack_weapon_shotgun_kick( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return WeaponShotgunKick_FireWeaponPlayerAndNPC( attackParams, true, weapon )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_weapon_shotgun_kick( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return WeaponShotgunKick_FireWeaponPlayerAndNPC( attackParams, false, weapon )
}
#endif // #if SERVER

int function WeaponShotgunKick_FireWeaponPlayerAndNPC( WeaponPrimaryAttackParams attackParams, bool playerFired, entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	bool shouldCreateProjectile = false
	if ( IsServer() || weapon.ShouldPredictProjectiles() )
		shouldCreateProjectile = true
	#if CLIENT
		if ( !playerFired )
			shouldCreateProjectile = false
	#endif

	int ammoPool = owner.AmmoPool_GetCount( eAmmoPoolType.shotgun )

	//Do not fire if we do not have any shotgun shells
	if ( ammoPool == 0 )
	{
		//Tell client to display the no ammo message.
		#if SERVER
			Remote_CallFunction_ByRef( owner, "ServerCallback_ShotgunKickNoAmmoMessage" )
		#endif //SERVER

		return 0
	}


	#if SERVER
	owner.AmmoPool_SetCount( eAmmoPoolType.shotgun, ammoPool - 1 )
	#endif //SERVER

	vector attackAngles = VectorToAngles( attackParams.dir )
	vector baseUpVec = AnglesToUp( attackAngles )
	vector baseRightVec = AnglesToRight( attackAngles )

	float zoomFrac
	if ( playerFired )
		zoomFrac = owner.GetZoomFrac()
	else
		zoomFrac = 0.5

	float spreadFrac = Graph( zoomFrac, 0, 1, 0.05, 0.025 ) * 1.0

	array<entity> projectiles

	if ( shouldCreateProjectile )
	{
		weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

		for ( int index = 0; index < MASTIFF_MAX_BOLTS; index++ )
		{
			vector upVec = baseUpVec * file.boltOffsets[index][0] * spreadFrac
			vector rightVec = baseRightVec * file.boltOffsets[index][1] * spreadFrac

			vector attackDir = attackParams.dir + upVec + rightVec
			int damageFlags = weapon.GetWeaponDamageFlags()
			WeaponFireBoltParams fireBoltParams
			fireBoltParams.pos = attackParams.pos
			fireBoltParams.dir = attackDir
			fireBoltParams.speed = 4500
			fireBoltParams.scriptTouchDamageType = damageFlags
			fireBoltParams.scriptExplosionDamageType = damageFlags
			fireBoltParams.clientPredicted = playerFired
			fireBoltParams.additionalRandomSeed = index
			entity bolt = weapon.FireWeaponBolt( fireBoltParams )
			if ( bolt != null )
			{
				bolt.kv.gravity = 0.09

				if ( !(playerFired && zoomFrac > 0.8) )
					bolt.SetProjectileLifetime( RandomFloatRange( 0.65, 0.85 ) )
				else
					bolt.SetProjectileLifetime( RandomFloatRange( 0.65, 0.85 ) * 1.25 )

				projectiles.append( bolt )

				#if SERVER
					EmitSoundOnEntity( bolt, "weapon_mastiff_projectile_crackle" )
				#endif
			}
		}
	}

	return 1
}

#if CLIENT
void function ServerCallback_ShotgunKickNoAmmoMessage()
{
	var rui = CreateFullscreenRui( $"ui/weapon_shotgun_kick_ammo_hint.rpak" )
	RuiSetString( rui, "displayText", "#WPN_SHOTGUN_KICK_AMMO_HINT" )
	RuiSetString( rui, "displayTextSub", "#WPN_SHOTGUN_KICK_AMMO_HINT_SUB" )
	RuiSetGameTime( rui, "startTime", Time() )
	RuiSetGameTime( rui, "endTime", Time() + WEAPON_SHOTGUN_KICK_AMMO_MESSAGE_DURATION )
}
#endif //CLIENT
