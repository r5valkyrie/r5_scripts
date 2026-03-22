untyped

// Travis - The charge based on Thermite taken from mp_weapon_sentinel.  David left behind this warning which would apply here too.  Can revisit later if the gun progresses / if they change how sentinel works:
// dbocek: had to do a lot of hacks due to time and lack of features -- this is a somewhat complicated web. Be careful changing things! Feel free to reach out, I'm happy to talk and answer questions
global function MpWeaponDragon_LMG_Init

global function OnWeaponActivate_weapon_dragon_lmg
global function OnWeaponDeactivate_weapon_dragon_lmg
global function OnWeaponPrimaryAttack_weapon_dragon_lmg
global function OnWeaponEnergizedStart_weapon_dragon_lmg
global function OnWeaponStartEnergizing_weapon_dragon_lmg
global function OnWeaponEnergizedEnd_weapon_dragon_lmg

#if CLIENT
global function DragonLMG_ChargeHUD
global function DragonLMG_UpdateChargeEndTime
global function DragonLMG_NoThermiteHint
#endif





global const string DRAGON_LMG_ENERGIZED_MOD = "energized"

// Energize state constants
global enum eEnergizeState
{
	ENERGIZE_NONE = 0,
	ENERGIZE_ENERGIZING = 1,
	ENERGIZE_ENERGIZED = 2
}

const string DRAGON_CLASS_NAME = "mp_weapon_dragon_lmg"

const string CHARGING_SOUND_3P = "weapon_rampage_thermite_charge_3p"
const string CHARGE_END_SOUND_FP = "weapon_rampage_lmg_charge_end_1p"
const string CHARGE_END_SOUND_SHOOTING_FP = "weapon_rampage_lmg_charge_end_shooting_1p"
const string CHARGE_END_SOUND_3P = "weapon_rampage_lmg_charge_end_3p"
const string EQUIPPED_WHILE_CHARGED = "weapon_rampage_thermite_charge_04_equip"

const asset EFFECT_ENHANCED_MODE_FP = $"P_drg_ignited_amb_FP"
const asset EFFECT_ENHANCED_MODE_3P = $"P_drg_ignited_amb_3P"
const asset EFFECT_CHAMBER_OPENING_FP = $"P_rampage_chamber_opening"
const asset EFFECT_ENHANCED_MODE_SHOOTING_FP = $"P_Exhaust_drg_ignited_FP"
const asset EFFECT_ENHANCED_MODE_SHOOTING_3P = $"P_Exhaust_drg_ignited_3P"

const asset ENERGIZED_CROSSHAIR_RUI = $"ui/crosshair_energize_status_sentinel.rpak"

//changed charged icon while weapon is in crate. revert if removed from crate.
const asset AMMO_ENERGIZED_ICON = $"rui/hud/gametype_icons/survival/sur_ammo_crate_heavy_charged"
const asset ENERGIZE_UI_CONSUMABLE_ICON = $"rui/ordnance_icons/grenade_incendiary"

const string ENERGIZED_STATE_END = "energized_state_end"

/**********************************************************************************************************************
Init Functions
**********************************************************************************************************************/
void function MpWeaponDragon_LMG_Init()
{
	PrecacheWeapon( DRAGON_CLASS_NAME )
	PrecacheParticleSystem( EFFECT_ENHANCED_MODE_FP )
	PrecacheParticleSystem( EFFECT_ENHANCED_MODE_3P )
	PrecacheParticleSystem( EFFECT_ENHANCED_MODE_SHOOTING_FP )
	PrecacheParticleSystem( EFFECT_ENHANCED_MODE_SHOOTING_3P )
	PrecacheParticleSystem( EFFECT_CHAMBER_OPENING_FP )

	RegisterSignal( ENERGIZE_STATUS_RUI_ABORT_SIGNAL )
	RegisterSignal( ENERGIZED_STATE_END )

	#if SERVER
		AddClientCommandCallback( "DragonLMG_TryCharge", ClientCommand_TryCharge )
	#endif

	#if CLIENT
		RegisterConCommandTriggeredCallback( "+scriptCommand3", DragonLMG_TryCharge )
	#endif
}

/**********************************************************************************************************************
Weapon Functions
**********************************************************************************************************************/
void function OnWeaponActivate_weapon_dragon_lmg( entity weapon )
{
	entity player = weapon.GetWeaponOwner()

	#if SERVER
		bool startEnergized = bool(GetWeaponInfoFileKeyField_GlobalInt_WithDefault( DRAGON_CLASS_NAME, "start_energized", 0 ))
		if ( startEnergized && !weapon.HasMod( DRAGON_LMG_ENERGIZED_MOD ) )
		{
			//Force energized on first pickup
			float energizedDuration = GetWeaponInfoFileKeyField_GlobalFloat( DRAGON_CLASS_NAME, "energized_duration" )
			weapon.AddMod( DRAGON_LMG_ENERGIZED_MOD )
		}
	#endif

	#if SERVER
		if ( !weapon.w.modsToRemoveOnDrop.contains( DRAGON_LMG_ENERGIZED_MOD ) )
			weapon.w.modsToRemoveOnDrop.append( DRAGON_LMG_ENERGIZED_MOD )

		if ( !IsValid( player ) )
			Warning( "Dragon LMG activated without valid player weapon owner, energize may not be removed correctly" )

		// Disabled: GetEnergizeState/GetEnergizeFrac/SetScriptFloat0 not available on weapon entities
		// thread UpdateRuiFractionThread( weapon )
	#endif

	#if CLIENT
		if ( IsValid( player ) )
		{
			int slot = GetSlotForWeapon( player, weapon )
			if ( slot >= 0 )
				weapon.w.activeOptic = SURVIVAL_GetWeaponAttachmentForPoint( player, slot, "sight" )
			else
				weapon.w.activeOptic = ""

			//thread UpdateWeaponEnergizeRui( player, weapon, ENERGIZED_CROSSHAIR_RUI, ENERGIZE_UI_CONSUMABLE_ICON, AMMO_ENERGIZED_ICON )
		}

		if ( weapon.HasMod( DRAGON_LMG_ENERGIZED_MOD ) )
		{
			weapon.EmitWeaponSound_1p3p( EQUIPPED_WHILE_CHARGED, $"" )

		}
		else
		{
			weapon.kv.rendercolor = "0 0 0"
		}
	#endif

#if SERVER
	if ( weapon.HasMod( DRAGON_LMG_ENERGIZED_MOD ) )
	{
		entity vm = weapon.GetWeaponViewmodel()
		int bodygroupIdx = weapon.FindBodygroup( "thermite" )
		if ( IsValid( vm ) && bodygroupIdx >= 0 )
		{
			vm.SetBodygroupModelByIndex( bodygroupIdx, 1 )
		}
	}



#endif




}

void function OnWeaponDeactivate_weapon_dragon_lmg( entity weapon )
{
	#if SERVER
		weapon.Signal( ENERGIZED_STATE_END  )
	#endif

	weapon.StopWeaponEffect( EFFECT_ENHANCED_MODE_FP, EFFECT_ENHANCED_MODE_3P )
	weapon.StopWeaponSound( EQUIPPED_WHILE_CHARGED )

	#if SERVER



	#endif




}

var function OnWeaponPrimaryAttack_weapon_dragon_lmg( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.FireWeapon_Default( attackParams.pos, attackParams.dir, 1.0, 1.0, false )

	#if SERVER
	if ( weapon.HasMod( DRAGON_LMG_ENERGIZED_MOD ) && "energizedEndTime" in weapon.s )
	{
		// Reduce 0.5 seconds from energizer timer per shot
		weapon.s.energizedEndTime = expect float( weapon.s.energizedEndTime ) - 0.5
		entity owner = weapon.GetWeaponOwner()
		if ( IsValid( owner ) && owner.IsPlayer() )
			Remote_CallFunction_NonReplay( owner, "DragonLMG_UpdateChargeEndTime", expect float( weapon.s.energizedEndTime ) )
	}
	#endif

	int ammoPerShot = weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
	return ammoPerShot
}

void function OnWeaponStartEnergizing_weapon_dragon_lmg( entity weapon, entity player )
{
	if ( !IsValid( weapon ) )
		return

	weapon.PlayWeaponEffectNoCull ( EFFECT_CHAMBER_OPENING_FP, $"", "muzzle_flash" )
	weapon.EmitWeaponSound_1p3p( $"", CHARGING_SOUND_3P )
}

void function OnWeaponEnergizedStart_weapon_dragon_lmg( entity weapon, entity player, bool costConsumable )
{
	OnWeaponEnergizedStart( weapon, player, costConsumable )
#if CLIENT
	SetEnableEmission( weapon, true )
#endif

	#if SERVER
	//if( weapon.HasMod( DRAGON_LMG_ENERGIZED_MOD ) )
		//PIN_OnPlayerWeaponAttachmentChanged( player, weapon, DRAGON_LMG_ENERGIZED_MOD, "" )

	string weaponRef = weapon.GetWeaponClassName()
	string consumableRef = GetWeaponInfoFileKeyField_GlobalString ( weaponRef, "energized_consumable" )
	RefreshOrdnanceSlot( player, consumableRef )
	#endif
}

void function OnWeaponEnergizedEnd_weapon_dragon_lmg( entity weapon, entity player )
{
	#if SERVER
	//PIN_OnPlayerWeaponAttachmentChanged( player, weapon, "", DRAGON_LMG_ENERGIZED_MOD )
	#endif

#if CLIENT
	Stop_Thermite_Effects( weapon )
	SetEnableEmission( weapon, false )
#endif
}

















#if SERVER
// Update the remaining energy rui on the weapon
// Disabled: GetEnergizeState/GetEnergizeFrac/SetScriptFloat0 not available on weapon entities
/*
void function UpdateRuiFractionThread( entity weapon )
{
	AssertIsNewThread()
	weapon.EndSignal( ENERGIZED_STATE_END  )

	OnThreadEnd(
		function() : ( weapon )
		{
			weapon.SetScriptFloat0( 0 )
		}
	)

	while( true )
	{
		var ruiFrac = ( weapon.GetEnergizeState() == eEnergizeState.ENERGIZE_ENERGIZED ) ? weapon.GetEnergizeFrac() : 0.0
		weapon.SetScriptFloat0( ruiFrac )
		WaitFrame()
	}
}
*/
#endif

/**********************************************************************************************************************
Charge Command Functions
**********************************************************************************************************************/
#if CLIENT
void function DragonLMG_TryCharge( entity player )
{
	if( !IsValid(player) )
		return

	if ( player != GetLocalViewPlayer() )
		return

	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

	if ( !IsValid( weapon ) )
		return

	if ( weapon.GetWeaponClassName() != DRAGON_CLASS_NAME )
		return

	player.ClientCommand( "DragonLMG_TryCharge" )
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

	if ( weapon.GetWeaponClassName() != DRAGON_CLASS_NAME )
		return false

	if( weapon.IsInCustomActivity() )
		return false

	if( weapon.HasMod( DRAGON_LMG_ENERGIZED_MOD ) )
		return false

	// Check if player has thermite grenade in inventory
	int thermiteCount = SURVIVAL_CountItemsInInventory( player, "mp_weapon_thermite_grenade" )
	if ( thermiteCount <= 0 )
	{
		Remote_CallFunction_NonReplay( player, "DragonLMG_NoThermiteHint" )
		return false
	}

	// Consume one thermite grenade
	SURVIVAL_RemoveFromPlayerInventory( player, "mp_weapon_thermite_grenade", 1 )

	weapon.StartCustomActivity("ACT_VM_CHARGE_VER4", 0)
	thread DragonLMG_Charging( player, weapon )
	return true
}

void function DragonLMG_Charging( entity player, entity weapon )
{
	EndSignal( weapon, "OnDestroy" )
	EndSignal( weapon, ENERGIZED_STATE_END )

	float chargeEndTime = Time() + weapon.GetCustomActivityDuration()

	OnThreadEnd( function() : ( player, weapon )
	{
		if( IsValid( weapon ) && weapon != player.GetActiveWeapon( eActiveInventorySlot.mainHand ) )
			return

		if ( IsValid( weapon ) && weapon.IsInCustomActivity() )
		{
			weapon.StopCustomActivity()
		}

		if( IsValid( weapon ) && !weapon.IsInCustomActivity() && IsValid( player ) && weapon == player.GetActiveWeapon( eActiveInventorySlot.mainHand ) )
		{
			player.HolsterWeapon()
			player.DeployWeapon()
			weapon.AddMod( DRAGON_LMG_ENERGIZED_MOD )

			thread DragonLMG_OnModAddedWatcher( player, weapon )
		}
	})

	while( Time() < chargeEndTime && IsValid( weapon ) && weapon == player.GetActiveWeapon( eActiveInventorySlot.mainHand ) )
	{
		WaitFrame()
	}
}

void function DragonLMG_OnModAddedWatcher( entity player, entity weapon )
{
	EndSignal( weapon, "OnDestroy" )

	float duration = 60.0 // Default duration if not specified in weapon file
	var durationVal = GetWeaponInfoFileKeyField_Global( weapon.GetWeaponClassName(), "energized_duration" )
	if ( durationVal != null )
		duration = expect float( durationVal )

	float chargeEndTime = Time() + duration
	weapon.s.energizedEndTime <- chargeEndTime // Store in weapon struct
	weapon.Signal( ENERGIZED_STATE_END )

	Remote_CallFunction_NonReplay( player, "DragonLMG_ChargeHUD", chargeEndTime )

	OnThreadEnd( function() : ( weapon )
	{
		if( IsValid( weapon ) )
		{
			weapon.RemoveMod( DRAGON_LMG_ENERGIZED_MOD )
			if ( "energizedEndTime" in weapon.s )
				delete weapon.s.energizedEndTime
		}
	})

	while( IsValid( weapon ) && weapon.HasMod( DRAGON_LMG_ENERGIZED_MOD ) )
	{
		// Check if energy ran out from shooting
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

/**********************************************************************************************************************
Client Functions
**********************************************************************************************************************/
#if CLIENT

void function DragonLMG_ChargeHUD( float chargeEndTime )
{
	thread function () : ( chargeEndTime )
	{
		entity weapon
		entity player = GetLocalViewPlayer()

		array<entity> weapons = player.GetMainWeapons()
		foreach ( sWeapon in weapons )
		{
			string weaponRef = sWeapon.GetWeaponClassName()
			if( weaponRef == DRAGON_CLASS_NAME )
				weapon = sWeapon
		}

		if ( !IsValid( weapon ) )
			return

		weapon.EndSignal( "OnDestroy" )

		// Store end time in weapon client struct
		weapon.s.energizedEndTime <- chargeEndTime

		// Create topology positioned above the weapon icon in bottom right
		UISize screenSize = GetScreenSize()
		var screenAlignmentTopo = RuiTopology_CreatePlane( <(screenSize.width * 0.54), (screenSize.height * 0.51), 0>, <float(screenSize.width) * 0.5, 0, 0>, <0, float(screenSize.height) * 0.5, 0>, false )
		var rui = RuiCreate( $"ui/consumable_progress.rpak", screenAlignmentTopo, RUI_DRAW_HUD, 0 )

		float initialDuration = chargeEndTime - Time()
		float startTime = Time()

		RuiSetString( rui, "consumableName", "RAMPAGE ENERGIZED" )
		RuiSetFloat( rui, "raiseTime", 0.0 )
		RuiSetFloat( rui, "chargeTime", initialDuration )
		RuiSetImage( rui, "hudIcon", $"rui/ordnance_icons/grenade_incendiary" )
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

		while( IsValid( weapon ) && IsValid( player ) && weapon.HasMod( DRAGON_LMG_ENERGIZED_MOD ) )
		{
			if ( "energizedEndTime" in weapon.s )
			{
				float currentEndTime = expect float( weapon.s.energizedEndTime )
				float remainingTime = currentEndTime - Time()

				if ( remainingTime <= 0 )
					break

				// Update chargeTime when end time changes from shooting
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

void function DragonLMG_UpdateChargeEndTime( float newEndTime )
{
	entity player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	array<entity> weapons = player.GetMainWeapons()
	foreach ( weapon in weapons )
	{
		if ( weapon.GetWeaponClassName() == DRAGON_CLASS_NAME )
		{
			if ( "energizedEndTime" in weapon.s )
				weapon.s.energizedEndTime = newEndTime
			break
		}
	}
}

void function DragonLMG_NoThermiteHint()
{
	entity player = GetLocalViewPlayer()
	if ( IsValid( player ) )
		player.ClientCommand( "ClientCommand_Quickchat " + eCommsAction.INVENTORY_NEED_THERMITE )

	AddPlayerHint( 2.0, 0.25, $"rui/ordnance_icons/grenade_incendiary", "Need Thermite Grenade to charge Rampage" )
}

void function Stop_Thermite_Effects ( entity weapon )
{
	//printt("stopped thermite FX")
	entity player = weapon.GetWeaponOwner()

	if (!IsValid( player ) )
		return

	if (!IsLocalViewPlayer( player ) )
		return

	if ( weapon.IsReadyToFire() )
		weapon.EmitWeaponSound_1p3p( CHARGE_END_SOUND_FP, $"" )
	else
		weapon.EmitWeaponSound_1p3p( CHARGE_END_SOUND_SHOOTING_FP, $"" )

	weapon.StopWeaponSound( "weapon_rampage_lmg_firstshot_1p_alt" )
	weapon.StopWeaponSound( "weapon_rampage_lmg_loop_1p_alt" )
	weapon.StopWeaponEffect( EFFECT_ENHANCED_MODE_FP, EFFECT_ENHANCED_MODE_3P )
}

void function SetEnableEmission( entity weapon, bool enable )
{
	if( enable )
		weapon.kv.rendercolor = "255 255 255"
	else
		weapon.kv.rendercolor = "0 0 0"
}

#endif //CLIENT