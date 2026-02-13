untyped

global function MpWeaponSentinel_Init
global function OnWeaponPrimaryAttack_weapon_sentinel
global function OnWeaponActivate_weapon_sentinel
global function OnWeaponDeactivate_weapon_sentinel
global function OnWeaponCustomActivityStart_weapon_sentinel
global function OnWeaponCustomActivityEnd_weapon_sentinel
global function OnWeaponStartZoomIn_weapon_sentinel
global function OnWeaponStartZoomOut_weapon_sentinel

#if CLIENT
global function SentinelChargeHUD
global function Sentinel_UpdateChargeEndTime
global function Sentinel_NoShieldCellHint
global function Sentinel_PlayEnergizeEffect
global function Sentinel_StopEnergizeEffect
#endif

const string SENTINEL_DEACTIVATE_SIGNAL = "SentinelDeactivate"
const string ENERGIZED_MOD = "energized"

const asset SENTINEL_CHARGE_FX_1P = $"P_wpn_sentinel_charge_FP"
const asset SENTINEL_CHARGE_FX_3P = $"P_wpn_sentinel_charge_3P"

void function MpWeaponSentinel_Init()
{
	RegisterSignal( SENTINEL_DEACTIVATE_SIGNAL )

	if( !GetCurrentPlaylistVarBool( "sentinel_enable_charging", true ) )
		return

	#if SERVER
	PrecacheEnergizeFX( "mp_weapon_sentinel" )
	AddClientCommandCallback( "Sentinel_TryCharge", ClientCommand_TryCharge )
	PrecacheParticleSystem( SENTINEL_CHARGE_FX_1P )
	PrecacheParticleSystem( SENTINEL_CHARGE_FX_3P )
	#endif

	#if CLIENT
	RegisterConCommandTriggeredCallback( "+scriptCommand3", Sentinel_TryCharge )
	#endif

}

#if CLIENT
void function Sentinel_TryCharge( entity player )
{
	if( !IsValid(player) )
		return

	if ( player != GetLocalViewPlayer() )
		return

	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

	if ( !IsValid( weapon ) )
		return

	if ( weapon.GetWeaponClassName() != "mp_weapon_sentinel" )
		return

	player.ClientCommand( "Sentinel_TryCharge" )
}

void function SentinelChargeHUD( float chargeEndTime )
{
	thread function () : ( chargeEndTime )
	{
		entity weapon
		entity player = GetLocalViewPlayer()

		array<entity> weapons = player.GetMainWeapons()
		foreach ( sWeapon in weapons )
		{
			string weaponRef = sWeapon.GetWeaponClassName()
			if( weaponRef == "mp_weapon_sentinel" )
				weapon = sWeapon
		}

		if ( !IsValid( weapon ) )
			return

		weapon.EndSignal( "OnDestroy" )

		weapon.s.energizedEndTime <- chargeEndTime
		UISize screenSize = GetScreenSize()
		var screenAlignmentTopo = RuiTopology_CreatePlane( <(screenSize.width * 0.54), (screenSize.height * 0.51), 0>, <float(screenSize.width) * 0.5, 0, 0>, <0, float(screenSize.height) * 0.5, 0>, false )
		var rui = RuiCreate( $"ui/consumable_progress.rpak", screenAlignmentTopo, RUI_DRAW_HUD, 0 )

		float initialDuration = chargeEndTime - Time()
		float startTime = Time()

		RuiSetString( rui, "consumableName", "SENTINEL DISCHARGING" )
		RuiSetFloat( rui, "raiseTime", 0.0 )
		RuiSetFloat( rui, "chargeTime", initialDuration )
		RuiSetImage( rui, "hudIcon", $"rui/hud/loot/loot_stim_shield_small" )
		RuiSetInt( rui, "consumableType", 0 )
		RuiSetString( rui, "hintController", "" )
		RuiSetString( rui, "hintKeyboardMouse", "" )
		RuiSetGameTime( rui, "healStartTime", startTime )

		OnThreadEnd(
			function() : ( rui, screenAlignmentTopo, weapon )
			{
				RuiDestroyIfAlive( rui )
				RuiTopology_Destroy( screenAlignmentTopo )
				if ( IsValid( weapon ) && "energizedEndTime" in weapon.s )
					delete weapon.s.energizedEndTime
			}
		)

		float lastKnownEndTime = chargeEndTime

		while( IsValid( weapon ) && IsValid( player ) && weapon.HasMod( ENERGIZED_MOD ) )
		{
			if ( "energizedEndTime" in weapon.s )
			{
				float currentEndTime = expect float( weapon.s.energizedEndTime )
				float remainingTime = currentEndTime - Time()

				if ( remainingTime <= 0 )
					break

				if ( fabs( currentEndTime - lastKnownEndTime ) > 0.1 )
				{
					lastKnownEndTime = currentEndTime
					float elapsedTime = Time() - startTime
					float newChargeTime = elapsedTime + remainingTime
					RuiSetFloat( rui, "chargeTime", newChargeTime )
				}
			}
			else
			{
				break
			}

			WaitFrame()
		}
	}()
}

void function Sentinel_UpdateChargeEndTime( float newEndTime )
{
	entity player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	array<entity> weapons = player.GetMainWeapons()
	foreach ( weapon in weapons )
	{
		if ( weapon.GetWeaponClassName() == "mp_weapon_sentinel" )
		{
			if ( "energizedEndTime" in weapon.s )
				weapon.s.energizedEndTime = newEndTime
			break
		}
	}
}

void function Sentinel_NoShieldCellHint()
{
	entity player = GetLocalViewPlayer()
	if ( IsValid( player ) )
		player.ClientCommand( "ClientCommand_Quickchat " + eCommsAction.INVENTORY_NEED_SHIELDS )

	AddPlayerHint( 2.0, 0.25, $"rui/hud/loot/loot_stim_shield_small", "Need Shield Cell to charge Sentinel" )
}

void function Sentinel_PlayEnergizeEffect()
{
	entity player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	array<entity> weapons = player.GetMainWeapons()
	entity weapon
	foreach ( sWeapon in weapons )
	{
		string weaponRef = sWeapon.GetWeaponClassName()
		if( weaponRef == "mp_weapon_sentinel" )
			weapon = sWeapon
	}

	if ( !IsValid( weapon ) )
		return

	if ( !weapon.HasMod( ENERGIZED_MOD ) )
		return

	if ( "effectThreadRunning" in weapon.s && weapon.s.effectThreadRunning )
		return

	thread Sentinel_MaintainEnergizeEffect( weapon )
}

void function Sentinel_MaintainEnergizeEffect( entity weapon )
{
	weapon.EndSignal( "OnDestroy" )
	weapon.s.effectThreadRunning <- true

	OnThreadEnd( function() : ( weapon )
	{
		if ( IsValid( weapon ) && "effectThreadRunning" in weapon.s )
			delete weapon.s.effectThreadRunning
	})

	weapon.PlayWeaponEffect( SENTINEL_CHARGE_FX_1P, SENTINEL_CHARGE_FX_3P, "muzzle_flash" )

	while( IsValid( weapon ) && weapon.HasMod( ENERGIZED_MOD ) )
	{
		WaitFrame()
	}

	weapon.StopWeaponEffect( SENTINEL_CHARGE_FX_1P, SENTINEL_CHARGE_FX_3P )
}

void function Sentinel_StopEnergizeEffect()
{
	entity player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	array<entity> weapons = player.GetMainWeapons()
	entity weapon
	foreach ( sWeapon in weapons )
	{
		string weaponRef = sWeapon.GetWeaponClassName()
		if( weaponRef == "mp_weapon_sentinel" )
			weapon = sWeapon
	}

	if ( !IsValid( weapon ) )
		return

	weapon.StopWeaponEffect( SENTINEL_CHARGE_FX_1P, SENTINEL_CHARGE_FX_3P )
	if ( "effectPlaying" in weapon.s )
		delete weapon.s.effectPlaying
}
#endif

#if SERVER
bool function ClientCommand_TryCharge( entity player, array<string> args )
{
	if ( !IsValid( player ) )
		return false

	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

	if ( !IsValid( weapon ) )
		return false

	if ( weapon.GetWeaponClassName() != "mp_weapon_sentinel" )
		return false

	if( weapon.IsInCustomActivity() )
		return false

	if( weapon.HasMod( ENERGIZED_MOD ) )
		return false

	int shieldCellCount = SURVIVAL_CountItemsInInventory( player, "health_pickup_combo_small" )
	if ( shieldCellCount <= 0 )
	{
		Remote_CallFunction_NonReplay( player, "Sentinel_NoShieldCellHint" )
		return false
	}

	SURVIVAL_RemoveFromPlayerInventory( player, "health_pickup_combo_small", 1 )

	weapon.StartCustomActivity("ACT_VM_CHARGE_VER4", 0)
	return true
}

void function Flowstate_SentinelCharging( entity player, entity weapon )
{
	EndSignal( weapon, "OnDestroy" )

	float chargeEndTime = Time() + weapon.GetCustomActivityDuration()
	weapon.s.chargingInterrupted <- false

	thread function() : ( weapon, player )
	{
		EndSignal( weapon, "OnDestroy" )
		weapon.WaitSignal( SENTINEL_DEACTIVATE_SIGNAL )

		if ( IsValid( weapon ) )
		{
			weapon.s.chargingInterrupted <- true

			if ( IsValid( player ) && weapon.IsInCustomActivity() )
			{
				weapon.StopCustomActivity()
				SURVIVAL_AddToPlayerInventory( player, "health_pickup_combo_small" )
			}
		}
	}()

	table signalData = {}
	thread function() : ( weapon, signalData )
	{
		EndSignal( weapon, "OnDestroy" )
		weapon.WaitSignal( SENTINEL_DEACTIVATE_SIGNAL )
		signalData.wasInterrupted <- true
	}()

	OnThreadEnd( function() : ( player, weapon, signalData )
	{
		if ( !IsValid( player ) || !IsValid( weapon ) )
			return

		if ( "chargingInterrupted" in weapon.s && weapon.s.chargingInterrupted )
		{
			if ( "chargingInterrupted" in weapon.s )
				delete weapon.s.chargingInterrupted
			return
		}

		if( weapon != player.GetActiveWeapon( eActiveInventorySlot.mainHand ) )
		{
			SURVIVAL_AddToPlayerInventory( player, "health_pickup_combo_small" )
			return
		}

		if ( weapon.IsInCustomActivity() )
		{
			weapon.StopCustomActivity()
		}

		if( !weapon.IsInCustomActivity() && weapon == player.GetActiveWeapon( eActiveInventorySlot.mainHand ) )
		{
		    player.HolsterWeapon()
			player.DeployWeapon()
			weapon.AddMod( ENERGIZED_MOD )

			thread SentinelOnModAddedWatcher( player, weapon )
		}

		if ( "chargingInterrupted" in weapon.s )
			delete weapon.s.chargingInterrupted
	})

	while( Time() < chargeEndTime && IsValid( weapon ) && weapon == player.GetActiveWeapon( eActiveInventorySlot.mainHand ) && weapon.IsInCustomActivity() )
	{
		WaitFrame()
	}
}

void function SentinelOnModAddedWatcher( entity player, entity weapon )
{
	EndSignal( weapon, "OnDestroy" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "OnDeath" )

	float duration = GetWeaponInfoFileKeyField_GlobalFloat( weapon.GetWeaponClassName(), "energized_duration" )
	float chargeEndTime = Time() + duration
	weapon.s.energizedEndTime <- chargeEndTime
	weapon.Signal( SENTINEL_DEACTIVATE_SIGNAL )

	Remote_CallFunction_NonReplay( player, "SentinelChargeHUD", chargeEndTime )
	Remote_CallFunction_NonReplay( player, "Sentinel_PlayEnergizeEffect" )

	OnThreadEnd( function() : ( player, weapon )
	{
		if( IsValid( weapon ) && weapon.HasMod( ENERGIZED_MOD ) )
		{
			weapon.RemoveMod( ENERGIZED_MOD )
		}
		if ( "energizedEndTime" in weapon.s )
			delete weapon.s.energizedEndTime
		if ( IsValid( player ) )
		{
			Remote_CallFunction_NonReplay( player, "Sentinel_StopEnergizeEffect" )
		}
	})

	while( IsValid( weapon ) && weapon.HasMod( ENERGIZED_MOD ) )
	{
		entity weaponOwner = weapon.GetWeaponOwner()
		bool weaponStillOwned = false

		if ( IsValid( weaponOwner ) && weaponOwner == player )
		{
			array<entity> weapons = player.GetMainWeapons()
			foreach ( w in weapons )
			{
				if ( w == weapon )
				{
					weaponStillOwned = true
					break
				}
			}
		}

		if ( !weaponStillOwned )
		{
			weapon.RemoveMod( ENERGIZED_MOD )
			if ( "energizedEndTime" in weapon.s )
				delete weapon.s.energizedEndTime
			break
		}

		if ( "energizedEndTime" in weapon.s )
		{
			float currentEndTime = expect float( weapon.s.energizedEndTime )
			if ( Time() >= currentEndTime )
				break
		}
		else
		{
			break
		}
		wait 0.1
	}
}
#endif

void function OnWeaponCustomActivityStart_weapon_sentinel( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return

	#if SERVER
	thread Flowstate_SentinelCharging( player, weapon )
	#endif
}

void function OnWeaponCustomActivityEnd_weapon_sentinel( entity weapon )
{
	if ( !IsValid( weapon ) )
		return
}

void function OnWeaponStartZoomIn_weapon_sentinel( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	weapon.Signal( SENTINEL_DEACTIVATE_SIGNAL )
}

void function OnWeaponStartZoomOut_weapon_sentinel( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	weapon.Signal( SENTINEL_DEACTIVATE_SIGNAL )
}

var function OnWeaponPrimaryAttack_weapon_sentinel( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return 0

	weapon.FireWeapon_Default( attackParams.pos, attackParams.dir, 1.0, 1.0, false )

	#if SERVER
	if ( weapon.HasMod( ENERGIZED_MOD ) && "energizedEndTime" in weapon.s )
	{
		weapon.s.energizedEndTime = expect float( weapon.s.energizedEndTime ) - 14
		if ( IsValid( player ) && player.IsPlayer() )
			Remote_CallFunction_NonReplay( player, "Sentinel_UpdateChargeEndTime", expect float( weapon.s.energizedEndTime ) )
	}
	#endif

	int ammoPerShot = weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
	return ammoPerShot
}

void function OnWeaponDeactivate_weapon_sentinel( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	weapon.Signal( SENTINEL_DEACTIVATE_SIGNAL )
}

void function OnWeaponActivate_weapon_sentinel( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	#if CLIENT
	// frick you red
	if ( weapon.HasMod( ENERGIZED_MOD ) )
	{
		weapon.StopWeaponEffect( SENTINEL_CHARGE_FX_1P, SENTINEL_CHARGE_FX_3P )
		weapon.PlayWeaponEffect( SENTINEL_CHARGE_FX_1P, SENTINEL_CHARGE_FX_3P, "muzzle_flash" )
	}
	#endif
}

#if SERVER
void function PrecacheEnergizeFX( string weaponClassName )
{
	string baseStr = "energize_effect"
	string preBaseStr = "pre_energize_effect"

	string str1p = baseStr + "_1p"
	string preStr1p = preBaseStr + "_1p"
	string str3p = baseStr + "_3p"
	string preStr3p = preBaseStr + "_3p"

	asset fx1p = GetWeaponInfoFileKeyFieldAsset_Global( weaponClassName, str1p )
	asset preFx1p = GetWeaponInfoFileKeyFieldAsset_Global( weaponClassName, preStr1p )
	asset fx3p = GetWeaponInfoFileKeyFieldAsset_Global( weaponClassName, str3p )
	asset preFx3p = GetWeaponInfoFileKeyFieldAsset_Global( weaponClassName, preStr3p )

	if ( fx1p != "" )
		PrecacheEffect( fx1p )
	if ( preFx1p != "" )
		PrecacheEffect( preFx1p )
	if ( fx3p != "" )
		PrecacheEffect( fx3p )
	if ( preFx3p != "" )
		PrecacheEffect( preFx3p )
}
#endif