global function OnWeaponPrimaryAttack_ItemSpawner

var function OnWeaponPrimaryAttack_ItemSpawner( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	Assert( weaponOwner.IsPlayer() )

#if SERVER
	//LootDrop( org, "health_pickup_health_small" )

	string refOrGroup = SURVIVAL_GetWeightedItemFromGroup( "loot_roller_contents_epic" )
	string ref = GetRefOrRefFromGroup( refOrGroup )
	if ( ref == "blank" )
		return 0

	int countPerDrop = SURVIVAL_Loot_GetLootDataByRef( ref ).countPerDrop

	vector attackOrigin = attackParams.pos - <0,0,16>
	vector attackVec = attackParams.dir
	entity lootEnt = SURVIVAL_ThrowLootFromPoint( attackOrigin, (attackVec * 5.0), ref, countPerDrop, null, null )
#endif // SERVER

#if CLIENT
	ScreenFlash( 4.0, 4.0, 4.0, 0.1, 0.2 )
#endif // CLIENT

	weapon.EmitWeaponSound_1p3p( "Dummie_Tactical_Trigger_1p", "Dummie_Tactical_Trigger_3p" )
	PlayerUsedOffhand( weaponOwner, weapon )
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
}