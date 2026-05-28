global function MpWeaponShotgun_Init
global function OnWeaponActivate_weapon_shotgun
global function OnWeaponDeactivate_weapon_shotgun
global function OnWeaponPrimaryAttack_weapon_shotgun
#if SERVER
global function OnWeaponNpcPrimaryAttack_weapon_shotgun
#endif // #if SERVER
global function OnProjectileCollision_weapon_shotgun

void function MpWeaponShotgun_Init()
{
#if SERVER
	Loot_AddCallback_OnWeaponAttachmentChanged( OnPlayerWeaponModCommand )
#endif
	AddCallback_OnPlayerAddWeaponMod( OnPlayerChangeWeaponMod )
	AddCallback_OnPlayerRemoveWeaponMod( OnPlayerChangeWeaponMod )
}

void function OnWeaponActivate_weapon_shotgun( entity weapon )
{
	OnWeaponActivate_weapon_basic_bolt( weapon )

	UpdateDoubleTapShotgunBoltPairing( weapon )

	                    
		GoldenHorseGreen_OnWeaponActivate( weapon )
       
}

void function OnWeaponDeactivate_weapon_shotgun( entity weapon )
{
	UpdateDoubleTapShotgunBoltPairing( weapon )

	                    
		GoldenHorseGreen_OnWeaponDeactivate( weapon )
       
}

void function UpdateDoubleTapShotgunBoltPairing( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	bool isPredictedOrServer = InPrediction() && IsFirstTimePredicted()
#if SERVER
	isPredictedOrServer = true
#endif //SERVER
	if ( !isPredictedOrServer )
		return

	const string BOLT_MOD_BASE = "shotgun_bolt_"
	const string DOUBLE_TAP_SUFFIX = "_double_tap"
	array<string> levels = ["l1", "l2", "l3"]
	                         
		levels.append( "l4" )
       

	//shotgun bolt needs to change burst fire delay instead of fire_rate, so we add an extra shotgun_bolt_l#_double_tap mod that has the burst delay change and the inverse fire rate multiplier for that level bolt
	//    for now, this is the best way to make bolts not affect fire rate while in double tap, since you can't otherwise overwrite other mod values with a mod. --dbocek
	if ( weapon.HasMod( "altfire_double_tap" ) )
	{

		foreach ( string level in levels )
		{
			string boltModBase = BOLT_MOD_BASE + level
			string boltModDT = boltModBase + DOUBLE_TAP_SUFFIX

			weapon.RemoveMod( boltModDT )

			if ( weapon.HasMod( boltModBase ) )
				weapon.AddMod( boltModDT )
		}
	}
	else
	{
		foreach ( string level in levels )
		{
			string boltModDT = BOLT_MOD_BASE + level + DOUBLE_TAP_SUFFIX

			weapon.RemoveMod( boltModDT )
		}
	}
}

var function OnWeaponPrimaryAttack_weapon_shotgun( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	bool playerFired = true
	Fire_EVA_Shotgun( weapon, attackParams, playerFired )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_weapon_shotgun( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	bool playerFired = false
	Fire_EVA_Shotgun( weapon, attackParams, playerFired )
}


void function OnPlayerWeaponModCommand( entity player, entity weapon, string modToAdd, string modToRemove )
{
	if ( IsValid( player ) )
		UpdateDoubleTapShotgunBoltPairing( weapon )
}
#endif // #if SERVER

void function OnPlayerChangeWeaponMod( entity player, entity weapon, string mod )
{
	if ( IsValid( player ) && mod == "altfire_double_tap" )
		UpdateDoubleTapShotgunBoltPairing( weapon )
}

int function Fire_EVA_Shotgun( entity weapon, WeaponPrimaryAttackParams attackParams, bool playerFired = true )
{
	entity owner = weapon.GetWeaponOwner()

	float patternScale = 1.0
	if ( !playerFired )
		patternScale = weapon.GetWeaponSettingFloat( eWeaponVar.blast_pattern_npc_scale )

	float speedScale = 1.0
	bool ignoreSpread = true
	weapon.FireWeapon_Default( attackParams.pos, attackParams.dir, speedScale, patternScale, ignoreSpread )

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}


void function OnProjectileCollision_weapon_shotgun( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
                          
            
                                                               
                 
                               
}
