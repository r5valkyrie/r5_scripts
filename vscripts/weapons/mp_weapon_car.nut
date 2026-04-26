global function MpWeaponCar_Init
global function OnWeaponActivate_Car
global function OnWeaponDeactivate_Car
global function OnWeaponPrimaryAttack_weapon_Car
global function OnWeaponReadyToFire_Car
global function OnWeaponReloadFailed_Car

global const string CMDNAME_CAR_AMMO_SWAP = "ClientCallback_CarHandleAmmoSwap"

#if SERVER
global function OnWeaponModChange_Car
global function ClientCallback_CarHandleAmmoSwap
global function OnAnimEvent_weapon_car_ammo_swap_complete
#endif

#if CLIENT
global function Weapon_CAR_TryApplyAmmoSwap
#endif

const string CAR_ALT_AMMO_MOD = "alt_ammo"
const string CAR_AMMO_SWAP_MOD_FOR_RELOAD = "ammo_type_swap"
const string CAR_AMMO_SWAP_FAIL_SFX = "weapon_car_CantSwapAmmo"

const vector CAR_AMMO_EMISSIVE_LIGHT_COLOR = <0.953125, 0.6015625, 0.2890625> // 244, 154, 74
const vector CAR_AMMO_EMISSIVE_HEAVY_COLOR = <0.41796875, 0.8046875, 0.65625> // 107, 206, 168

const VFX_COCKPIT_HEALTH = $"VFX_NAME_"


void function MpWeaponCar_Init()
{
#if SERVER
	AddWeaponModChangedCallback( "mp_weapon_car", OnWeaponModChange_Car )
#endif
	Remote_RegisterServerFunction( CMDNAME_CAR_AMMO_SWAP )
}


void function OnWeaponActivate_Car( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return
#if SERVER
	if ( weapon.HasMod(CAR_AMMO_SWAP_MOD_FOR_RELOAD) )
	{
		if (weapon.GetWeaponPrimaryClipCount() > 0)
		{
			weapon.RemoveMod( CAR_AMMO_SWAP_MOD_FOR_RELOAD )
		}
		else
		{
			player.ForceWeaponReload()
		}
	}
#endif

	#if CLIENT
		thread UpdatePoseParameter( weapon )
	#endif

#if CLIENT
	if ( InPrediction() )
#endif
	{
		// Light Ammo
		if ( weapon.HasMod( CAR_ALT_AMMO_MOD ) )
		{
			//weapon.SetScriptVector( CAR_AMMO_EMISSIVE_LIGHT_COLOR )
		}
		else // Heavy Ammo
		{
			//weapon.SetScriptVector( CAR_AMMO_EMISSIVE_HEAVY_COLOR )
		}
	}
}

void function OnWeaponDeactivate_Car( entity weapon )
{
}


void function OnWeaponReadyToFire_Car( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

#if SERVER
	//if ( weapon.HasMod( CAR_AMMO_SWAP_MOD_FOR_RELOAD ) )
	//	weapon.RemoveMod( CAR_AMMO_SWAP_MOD_FOR_RELOAD )
#endif
}

var function OnWeaponPrimaryAttack_weapon_Car( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if ( !IsValid( weapon ) )
		return 0

	if ( !weapon.IsWeaponX() )
		return 0

	int clipCount = weapon.GetWeaponPrimaryClipCount()

	if ( clipCount > 0 )
	{
		weapon.FireWeapon_Default( attackParams.pos, attackParams.dir, 1.0, 1.0, false )
		return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
	}
	else if ( clipCount <= 0 )
	{
		entity player = weapon.GetWeaponOwner()

		if ( !IsValid(player) )
			return 0
#if SERVER
		HandleOutOfAmmoSwap( player, weapon )
#endif
#if CLIENT
		HandleCarDryFire( player, weapon, clipCount )
#endif
		return 0
	}

}

void function OnWeaponReloadFailed_Car( entity weapon )
{
#if SERVER
	entity player = weapon.GetWeaponOwner()

	if ( !IsValid( player ) )
		return

	HandleOutOfAmmoSwap( player, weapon )
#endif
}

#if CLIENT
void function Weapon_CAR_TryApplyAmmoSwap( entity player, entity weapon )
{
	if ( !IsValid( player ) || !IsValid( weapon ) )
		return

	if ( weapon.HasMod( CAR_AMMO_SWAP_MOD_FOR_RELOAD ) || weapon.IsReloading() )
		return

	Remote_ServerCallFunction( CMDNAME_CAR_AMMO_SWAP )
}
#endif

#if SERVER
void function ClientCallback_CarHandleAmmoSwap( entity player )
{
	if ( !IsValid( player ) )
		return

	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand  )

	if ( !IsValid( weapon ) )
		return

	if ( weapon.GetWeaponClassName() != "mp_weapon_car" )
		return

	int activity = weapon.GetWeaponActivity()

	if (activity == ACT_VM_RELOADEMPTY)
		return

	if (activity == ACT_VM_RELOAD)
		return

	if ( !weapon.HasMod( CAR_AMMO_SWAP_MOD_FOR_RELOAD ) && !weapon.IsReloading() )
	{
		if ( weapon.IsInCustomActivity())
			weapon.StopCustomActivity()

		HandleAmmoSwap( player, weapon )
	}
}
#endif

#if SERVER
void function HandleAmmoSwap( entity player, entity weapon )
{
	if ( !IsValid( weapon ) || !IsValid( player) )
		return

	int currentHighcalStockPile 		= player.AmmoPool_GetCount( eAmmoPoolType.highcal )
	int currentLightStockPile   		= player.AmmoPool_GetCount( eAmmoPoolType.bullet )
	bool inLightAmmoMode				= weapon.HasMod( CAR_ALT_AMMO_MOD )

	if ( inLightAmmoMode && currentHighcalStockPile > 0 )
	{
		//toggle mod swap and reload into high cal ammo
		weapon.RemoveMod(CAR_ALT_AMMO_MOD)
		OnWeaponModChange_Car(weapon, CAR_ALT_AMMO_MOD, false)
		Remote_CallFunction_Replay( player, "ServerCallback_UpdateHudWeaponData", weapon )
	}
	else if ( !inLightAmmoMode && currentLightStockPile > 0 )
	{
		//toggle mod swap and reload into light ammo
		weapon.AddMod( CAR_ALT_AMMO_MOD )
		OnWeaponModChange_Car( weapon, CAR_ALT_AMMO_MOD, true )
		Remote_CallFunction_Replay( player, "ServerCallback_UpdateHudWeaponData", weapon )
	}
	else
	{
		EmitSoundOnEntityOnlyToPlayer( player, player, CAR_AMMO_SWAP_FAIL_SFX )
	}
}
#endif

#if SERVER
void function HandleOutOfAmmoSwap( entity player, entity weapon )
{
	if ( !IsValid( weapon ) || !IsValid( player) )
		return

	if ( !weapon.IsWeaponX() )
		return

	int currentHighcalStockPile 		= player.AmmoPool_GetCount( eAmmoPoolType.highcal )
	int currentLightStockPile   		= player.AmmoPool_GetCount( eAmmoPoolType.bullet )

	string ammoType             		= AmmoType_GetRefFromIndex( weapon.GetWeaponAmmoPoolType() )
	int ammoPoolType            		= eAmmoPoolType[ ammoType ]
	int playerAmmoPoolCount     		= player.AmmoPool_GetCount( ammoPoolType )

	string secondaryAmmoType 			= GetWeaponInfoFileKeyField_GlobalString(weapon.GetWeaponClassName(), "secondary_ammo_pool_type")
	int secondaryAmmoPoolType 			= eAmmoPoolType[ secondaryAmmoType ]
	int playerSecondaryAmmoPoolCount 	= player.AmmoPool_GetCount(secondaryAmmoPoolType)

	int clipCount               		= weapon.GetWeaponPrimaryClipCount()
	int maxPoolCount            		= player.AmmoPool_GetCapacity()

	bool inLightAmmoMode				= weapon.HasMod(CAR_ALT_AMMO_MOD)


                        
	if ( GameMode_IsActive( eGameModes.CONTROL ) && GetCurrentPlaylistVarBool( "control_infinite_ammo", false ) )
	{
		player.ForceWeaponReload()
		return
	}
                              

	if ( GetInfiniteAmmo( weapon ) )
	{
		player.ForceWeaponReload()
		return
	}

	if ( clipCount <= 0 && currentHighcalStockPile <= 0 && currentLightStockPile <= 0 )
	{
		return
	}

	if ( clipCount <= 0 )
	{
		if ( inLightAmmoMode && currentLightStockPile > 0 )
		{
			 player.ForceWeaponReload()
		}
		else if ( !inLightAmmoMode && currentHighcalStockPile > 0 )
		{
			 player.ForceWeaponReload()
		}
		else if ( inLightAmmoMode && currentLightStockPile <= 0 && currentHighcalStockPile > 0 )
		{
			//toggle mod swap and reload into high cal ammo
			weapon.RemoveMod( CAR_ALT_AMMO_MOD )
			OnWeaponModChange_Car( weapon, CAR_ALT_AMMO_MOD, false )
			Remote_CallFunction_Replay( player, "ServerCallback_UpdateHudWeaponData", weapon )
		}
		else if (!inLightAmmoMode && currentHighcalStockPile <= 0 && currentLightStockPile > 0)
		{
			//toggle mod swap and reload into light ammo
			weapon.AddMod( CAR_ALT_AMMO_MOD )
			OnWeaponModChange_Car( weapon, CAR_ALT_AMMO_MOD, true )
			Remote_CallFunction_Replay( player, "ServerCallback_UpdateHudWeaponData", weapon )
		}
	}
}
#endif

#if SERVER
void function OnWeaponModChange_Car( entity weapon, string mod, bool modAdded )
{
	if ( mod == CAR_ALT_AMMO_MOD )
	{
		if ( !IsValid( weapon ) )
			return

		if ( !weapon.IsWeaponX() )
			return

		entity player = weapon.GetWeaponOwner()
		if ( !IsValid(player) )
			return

		int clipCount               = weapon.GetWeaponPrimaryClipCount()
		int maxPoolCount            = player.AmmoPool_GetCapacity()
		int currentHighcalStockPile = player.AmmoPool_GetCount( eAmmoPoolType.highcal )
		int currentLightStockPile   = player.AmmoPool_GetCount( eAmmoPoolType.bullet )
		string ammoType             = AmmoType_GetRefFromIndex( weapon.GetWeaponAmmoPoolType() )
		int ammoPoolType            = eAmmoPoolType[ ammoType ]
		int oldAmmoPoolType			= 0

		if ( ammoPoolType == eAmmoPoolType.bullet )
			oldAmmoPoolType = eAmmoPoolType.highcal
		else if ( ammoPoolType == eAmmoPoolType.highcal )
			oldAmmoPoolType = eAmmoPoolType.bullet

		int playerOldAmmoPoolCount = player.AmmoPool_GetCount( oldAmmoPoolType )


		//add ammo from mag to inventory
		int amountAdded = SURVIVAL_AddToPlayerInventory( player, AmmoType_GetRefFromIndex( oldAmmoPoolType ), clipCount, false )
		int poolCountToGive = playerOldAmmoPoolCount + amountAdded
		if ( poolCountToGive > maxPoolCount )
			poolCountToGive = maxPoolCount

		if( !GetInfiniteAmmo( weapon ) )
			player.AmmoPool_SetCount( oldAmmoPoolType, poolCountToGive )

		if ( weapon.UsesClipsForAmmo() )
		{
			weapon.SetWeaponPrimaryClipCount( 0 )
		}

		//if inventory is full drop remaining ammo on the ground
		int ammoToDrop = clipCount - amountAdded
		if ( ammoToDrop > 0 )
		{
			entity ammoDrop = SpawnGenericLoot( AmmoType_GetRefFromIndex( oldAmmoPoolType ), GetThrowOrigin( player ), < -1, -1, -1 >, ammoToDrop )
			SetItemSpawnSource( ammoDrop, eSpawnSource.PLAYER_DROP, player )

			vector vel = AnglesToForward( player.EyeAngles() ) * 100
			FakePhysicsThrow( player, ammoDrop, vel, true )
		}

		if ( modAdded )
		{
			//Turn on highcal and reload into the ammo if any available
			if ( currentLightStockPile > 0 )
			{
				weapon.AddMod( CAR_AMMO_SWAP_MOD_FOR_RELOAD )
				player.ForceWeaponReload()
			}
		}
		else
		{
			//Remove high cal and go back to bullets and reload into the ammo if any available
			if ( currentHighcalStockPile > 0 )
			{
				weapon.AddMod( CAR_AMMO_SWAP_MOD_FOR_RELOAD )
				player.ForceWeaponReload()
			}
		}
	}
}
#endif

#if SERVER
void function AddAmmoToInventory( entity player, int ammoType, int amountToAdd )
{
	if ( !IsValid(player ) || amountToAdd <= 0 )
			return

	if ( ammoType == eAmmoPoolType.bullet )
		GiveLoot( player, BULLET_AMMO, amountToAdd )
	else if ( ammoType == eAmmoPoolType.highcal )
		GiveLoot( player, HIGHCAL_AMMO, amountToAdd )
}
#endif

#if SERVER
void function OnAnimEvent_weapon_car_ammo_swap_complete( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	if ( weapon.HasMod( CAR_AMMO_SWAP_MOD_FOR_RELOAD ) )
		weapon.RemoveMod( CAR_AMMO_SWAP_MOD_FOR_RELOAD )
}
#endif

#if CLIENT
void function HandleCarDryFire( entity player, entity weapon, int clipCount )
{
	if ( !IsValid( player ) )
	{
		Warning( "CAR HandleCarDryFire reached with invalid player" )
		return
	}
	int currentHighcalStockPile 		= player.AmmoPool_GetCount( eAmmoPoolType.highcal )
	int currentLightStockPile   		= player.AmmoPool_GetCount( eAmmoPoolType.bullet )
	if ( clipCount <= 0 && currentHighcalStockPile <= 0 && currentLightStockPile <= 0 && player.IsInputCommandPressed(IN_ATTACK) )
	{
		weapon.DoDryfire()
	}
}
#endif

#if CLIENT
void function UpdatePoseParameter( entity weapon )
{
	AssertIsNewThread()

	if ( !IsValid( weapon ) )
		return

	weapon.EndSignal( "OnDestroy" )

	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) || !IsLocalViewPlayer( player ) )
		return

	player.EndSignal( "OnDeath" )

	bool inLightAmmoModeLastFrame = weapon.HasMod( CAR_ALT_AMMO_MOD )
	float swapAmmoTime = 0.0
	float swapAnimDuration = 0.25
	weapon.SetScriptPoseParam0( 0.0 )

	while( true )
	{
		bool inLightAmmoMode	= weapon.HasMod( CAR_ALT_AMMO_MOD )

		if( inLightAmmoMode != inLightAmmoModeLastFrame )
		{
			swapAmmoTime = Time()
			inLightAmmoModeLastFrame = inLightAmmoMode
		}

		if( Time() - swapAmmoTime <= swapAnimDuration )
		{
			float swapAnimFrac = Clamp( Time() - swapAmmoTime, 0.0, swapAnimDuration ) / swapAnimDuration
			float poseParam = inLightAmmoMode ? swapAnimFrac : 1.0 - swapAnimFrac
			weapon.SetScriptPoseParam0( poseParam )
		}

		WaitFrame()
	}
}
#endif