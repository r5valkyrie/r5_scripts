global function OnWeaponActivate_Vinson
global function OnWeaponDeactivate_Vinson
global function OnWeaponPrimaryAttack_Vinson
#if CLIENT
global function FS_ForceDestroyCustomAdsOverlay
global function FS_ForceDestroyCustomAdsOverlay_Callback
#endif

void function OnWeaponActivate_Vinson( entity weapon )
{
	OnWeaponActivate_weapon_basic_bolt( weapon )
}

void function OnWeaponDeactivate_Vinson( entity weapon )
{

}

var function OnWeaponPrimaryAttack_Vinson( entity weapon, WeaponPrimaryAttackParams attackParams )
{

	if ( weapon.HasMod( "altfire_highcal" ) )
		thread PlayDelayedShellEject( weapon, RandomFloatRange( 0.03, 0.04 ) )

	weapon.FireWeapon_Default( attackParams.pos, attackParams.dir, 1.0, 1.0, false )

	// fire in both dimensions behavior. no need for this to happen on client cuz the player sees none of this lmao
	if (SERVER && Flowstate_Is4DMode() && weapon.GetWeaponInfoFileKeyField("4d_fire_in_both_dimensions"))
	{
		entity owner = weapon.GetWeaponOwner()
		vector prevOrigin = owner.GetOrigin()
		vector offset = <0,0,0>
		if (prevOrigin.x > 0)
		{
			offset -= <30000,0,0>
		}
		else
		{
			offset += <30000,0,0>
		}

		owner.SetOrigin(prevOrigin + offset) // prevents los check from attack position

		weapon.FireWeapon_Default( attackParams.pos + offset, attackParams.dir, 1.0, 1.0, false )

		owner.SetOrigin(prevOrigin)
	}

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

#if CLIENT
void function FS_ForceDestroyCustomAdsOverlay()
{
	#if DEVELOPER
		printt( "You died! Removing custom overlay and restoring HUD visibility." )
	#endif

	var BRAds = HudElement( "FS_HaloMod_BattleRifleAdsOverlay")
	Hud_SetVisible( BRAds, false )

	//Show the HUD.
	var gamestateRui = ClGameState_GetRui()
	RuiSetBool( gamestateRui, "weaponInspect", false )
	PlayerHudSetWeaponInspect( false )
	WeaponStatusSetWeaponInspect( false )

	entity player = GetLocalClientPlayer()
	entity weapon = SURVIVAL_GetLastActiveWeapon( player )

	if( IsValid( weapon ) && weapon.w.isInAdsCustom )
	{
		weapon.ShowWeapon()
		weapon.w.isInAdsCustom = false
	}
}

void function FS_ForceDestroyCustomAdsOverlay_Callback( entity attacker, float healthFrac, int damageSourceId, float recentHealthDamage )
{
	if( Gamemode() == eGamemodes.fs_dm )
		return

	#if DEVELOPER
		printt( "You died! Removing custom overlay and restoring HUD visibility. - From callback." )
	#endif

	var BRAds = HudElement( "FS_HaloMod_BattleRifleAdsOverlay")
	Hud_SetVisible( BRAds, false )

	//Show the HUD.
	var gamestateRui = ClGameState_GetRui()
	RuiSetBool( gamestateRui, "weaponInspect", false )
	PlayerHudSetWeaponInspect( false )
	WeaponStatusSetWeaponInspect( false )

	entity player = GetLocalClientPlayer()
	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

	if( IsValid( weapon ) && weapon.w.isInAdsCustom )
	{
		weapon.ShowWeapon()
		weapon.w.isInAdsCustom = false
	}
}
#endif