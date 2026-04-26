// Travis - The charge based on Thermite taken from mp_weapon_sentinel.  David left behind this warning which would apply here too.  Can revisit later if the gun progresses / if they change how sentinel works:
// dbocek: had to do a lot of hacks due to time and lack of features -- this is a somewhat complicated web. Be careful changing things! Feel free to reach out, I'm happy to talk and answer questions
global function MpWeaponDragon_LMG_Init

global function OnWeaponActivate_weapon_dragon_lmg
global function OnWeaponDeactivate_weapon_dragon_lmg
global function OnWeaponPrimaryAttack_weapon_dragon_lmg
global function OnWeaponEnergizedStart_weapon_dragon_lmg
global function OnWeaponStartEnergizing_weapon_dragon_lmg
global function OnWeaponEnergizedEnd_weapon_dragon_lmg







global const string DRAGON_LMG_ENERGIZED_MOD = "energized"

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
			//weapon.ForceEnergizeState( ENERGIZE_ENERGIZED )
			//weapon.ForceEnergizedEndTime( Time() + energizedDuration )
			weapon.AddMod( DRAGON_LMG_ENERGIZED_MOD )
		}
	#endif

	#if SERVER
		if ( !weapon.w.modsToRemoveOnDrop.contains( DRAGON_LMG_ENERGIZED_MOD ) )
			weapon.w.modsToRemoveOnDrop.append( DRAGON_LMG_ENERGIZED_MOD )

		if ( !IsValid( player ) )
			Warning( "Dragon LMG activated without valid player weapon owner, energize may not be removed correctly" )

		thread UpdateRuiFractionThread( weapon )
	#endif

	#if CLIENT
		if ( IsValid( player ) )
		{
			int slot = GetSlotForWeapon( player, weapon )
			if ( slot >= 0 )
				weapon.w.activeOptic = SURVIVAL_GetWeaponAttachmentForPoint( player, slot, "sight" )
			else
				weapon.w.activeOptic = ""

			thread UpdateWeaponEnergizeRui( player, weapon, ENERGIZED_CROSSHAIR_RUI, ENERGIZE_UI_CONSUMABLE_ICON, AMMO_ENERGIZED_ICON )
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
		//float ruiFrac = ( weapon.GetEnergizeState() == ENERGIZE_ENERGIZED  ) ? weapon.GetEnergizeFrac() : 0.0
		//weapon.SetScriptFloat0( ruiFrac )
		WaitFrame()
	}
}
#endif

/**********************************************************************************************************************
Client Functions
**********************************************************************************************************************/
#if CLIENT

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