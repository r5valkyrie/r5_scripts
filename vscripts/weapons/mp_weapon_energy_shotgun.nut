global function OnWeaponActivate_weapon_energy_shotgun
global function OnWeaponDeactivate_weapon_energy_shotgun
global function OnWeaponPrimaryAttack_weapon_energy_shotgun
global function OnWeaponChargeLevelIncreased_weapon_energy_shotgun
global function OnWeaponChargeEnd_weapon_energy_shotgun

#if SERVER
global function OnWeaponNpcPrimaryAttack_weapon_energy_shotgun
#endif

struct
{
	EnergyChargeWeaponData chargeWeaponData
} file

void function OnWeaponActivate_weapon_energy_shotgun( entity weapon )
{
		if ( weapon.HasMod( KINETIC_LOADER_HOPUP ) )
		{
#if SERVER
			if ( weapon.HasMod ( "choke" ) && !weapon.HasMod( "hopup_kinetic_choke" ))
				weapon.AddMod( "hopup_kinetic_choke" )
#endif
			OnWeaponActivate_Kinetic_Loader( weapon )
		}
#if SERVER
		else
		{
			if ( weapon.HasMod( "hopup_kinetic_choke" ) )
				weapon.RemoveMod( "hopup_kinetic_choke" )

			if( weapon.HasMod( "kinetic_choke" ) || !weapon.HasMod( "choke" ))
			{
				weapon.RemoveMod( "kinetic_choke" )
				//weapon.AddMod( "choke" )
			}
		}

		entity player = weapon.GetWeaponOwner()

		if ( IsValid( player ) && player.IsPlayer() )
			Remote_CallFunction_Replay( player, "ServerCallback_UpdateHudWeaponData", weapon )
#endif
}

void function OnWeaponDeactivate_weapon_energy_shotgun( entity weapon )
{
	//OnWeaponDeactivate_ReactiveKillEffects( weapon )
}

var function OnWeaponPrimaryAttack_weapon_energy_shotgun( entity weapon, WeaponPrimaryAttackParams attackParams)
{
	bool playerFired = true
	return Fire_EnergyShotgun( weapon, attackParams, playerFired )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_weapon_energy_shotgun( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	bool playerFired = false
	return Fire_EnergyShotgun( weapon, attackParams, playerFired )
}
#endif

int function Fire_EnergyShotgun( entity weapon, WeaponPrimaryAttackParams attackParams, bool playerFired )
{
	float patternScale = 1.0
	if ( weapon.HasMod( "npc_shotgunner" ) )
		patternScale = weapon.GetWeaponSettingFloat( eWeaponVar.blast_pattern_npc_scale )

	return Fire_EnergyChargeWeapon( weapon, attackParams, file.chargeWeaponData, playerFired, patternScale )
}

bool function OnWeaponChargeLevelIncreased_weapon_energy_shotgun( entity weapon )
{
	return EnergyChargeWeapon_OnWeaponChargeLevelIncreased( weapon, file.chargeWeaponData )
}

void function OnWeaponChargeEnd_weapon_energy_shotgun( entity weapon )
{
	EnergyChargeWeapon_OnWeaponChargeEnd( weapon, file.chargeWeaponData )
}
