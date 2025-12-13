#if SERVER
global function OnWeaponNpcPrimaryAttack_Weapon_Spider_Jungle

var function OnWeaponNpcPrimaryAttack_Weapon_Spider_Jungle( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	float speedScale = 1.0
	float patternScale = 1.0
	weapon.FireWeapon_Default( attackParams.pos, attackParams.dir, speedScale, patternScale, false )

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}
#endif // #if SERVER