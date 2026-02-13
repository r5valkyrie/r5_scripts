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
global function Sentinel_TryCharge
global function WeaponSentinel_TryApplyEnergized
global function Sentinel_UpdateChargeEndTime
global function Sentinel_NoShieldCellHint
#endif

const string SENTINEL_DEACTIVATE_SIGNAL = "SentinelDeactivate"
const string ENERGIZED_MOD = "energized"

global const string SENTINEL_USE_ENERGIZE_PLAYLIST_VAR = "sentinel_use_energize"
const string SENTINEL_SHOW_CROSSHAIR_ENERGIZE_PLAYLIST_VAR = "sentinel_show_crosshair_energize_status"

const asset SENTINEL_CHARGE_FX_1P = $"P_wpn_sentinel_charge_FP"
const asset SENTINEL_CHARGE_FX_3P = $"P_wpn_sentinel_charge_3P"

const bool DEBUG_FREE_ENERGIZE = false
const bool DEBUG_EFFECTS_TRIGGERS = false
const bool DEBUG_SCRIPT_CHARGE_FRAC = false
const bool DEBUG_FLAGS = false

const int ENERGIZE_FLAGS_OFF = 0
const int ENERGIZE_FLAGS_CHARGING = 1
const int ENERGIZE_FLAGS_CHARGED = 2

const string ENERGIZE_ACTIVITY = "ACT_VM_CHARGE_VER4"
const string ENERGIZE_DISPLAY_ABORT_SIGNAL = "EnergizeRuiDestroy"
const float ENERGIZE_STATUS_EFFECT_SLOW_INTENSITY = 0.15

const string RECHAMBER_RUI_ABORT_SIGNAL = "SentinelRechamberRuiAbort"
const string RECHAMBER_RUI_END_EVENT_ANIM = "rechamber"
const string RECHAMBER_RUI_END_EVENT = "hide_rechamber_dot"

enum ScriptChargeFracState
{
	OFF,
	INCREASE_TO_1,
	DECREASE_TO_0,
	MATCH_ENERGIZE,
	_count
}
const float SCRIPT_CHARGE_FRAC_INCREASE_TO_1_TIME = 3.5
const float SCRIPT_CHARGE_FRAC_INCREASE_TO_1_SPEED = 1.0 / SCRIPT_CHARGE_FRAC_INCREASE_TO_1_TIME
const float SCRIPT_CHARGE_FRAC_MATCH_ENERGIZE_SPEED_MAX = 0.35
const float SCRIPT_CHARGE_FRAC_MATCH_ENERGIZE_MIN = 0.5
const float SCRIPT_CHARGE_FRAC_DECREASE_TO_0_TIME = 0.5
const float SCRIPT_CHARGE_FRAC_DECREASE_TO_0_SPEED = SCRIPT_CHARGE_FRAC_MATCH_ENERGIZE_MIN / SCRIPT_CHARGE_FRAC_DECREASE_TO_0_TIME
const string SCRIPT_CHARGE_FRAC_THINK_ABORT_SIGNAL = "ScriptChargeFracThinkAbort"

enum EnergizeFXTime
{
	PRE_ENERGIZE,
	ENERGIZE,
	END_ENERGIZE
}
const int MAX_ENERGIZE_FX = 5
const string ENERGIZE_FX_ON_SCOPE_ZOOM_ABORT_SIGNAL = "ScopeZoomFXAbortSignal"

const vector ENERGIZED_UI_COLOR = <134, 255, 221> / 255.0
const vector ENERGIZED_UI_LEFT_BAR_COLOR = <0, 155, 146> / 255.0
const asset SNIPER_AMMO_ENERGIZED_ICON = $"rui/hud/gametype_icons/survival/sur_ammo_sniper_charged"

global const string ENERGIZE_STATUS_RUI_ABORT_SIGNAL = "SentinelEnergizRuiThinkAbortSignal"

struct ConsumableData
{
	string ref
	string consumableNamePlural
	string consumableNameSingular
	asset hudIcon
	int consumableType
}

const int BASE_CONSUMABLES_REQUIRED = 1

struct
{
	ConsumableData& consumableData
	float energizedDuration
	float energizedTimeConsumedPerShot
	float energizeActivityTime
} file

void function MpWeaponSentinel_Init()
{
	RegisterSignal( SENTINEL_DEACTIVATE_SIGNAL )
	RegisterSignal( ENERGIZE_DISPLAY_ABORT_SIGNAL )
	RegisterSignal( RECHAMBER_RUI_ABORT_SIGNAL )
	RegisterSignal( ENERGIZE_STATUS_RUI_ABORT_SIGNAL )
	RegisterSignal( SCRIPT_CHARGE_FRAC_THINK_ABORT_SIGNAL )
	RegisterSignal( ENERGIZE_FX_ON_SCOPE_ZOOM_ABORT_SIGNAL )

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
	RegisterConCommandTriggeredCallback( "+weaponcycle", AttemptCancelEnergize )
	RegisterConCommandTriggeredCallback( "+speed", AttemptCancelEnergize )
	#endif

	ConsumableData consumableData
	consumableData.ref = "health_pickup_combo_small"
	consumableData.consumableNamePlural = "#SURVIVAL_PICKUP_HEALTH_COMBO_SMALL_PLURAL"
	consumableData.consumableNameSingular = "#SURVIVAL_PICKUP_HEALTH_COMBO_SMALL"
	consumableData.hudIcon = $"rui/hud/loot/loot_stim_shield_small"
	consumableData.consumableType = 1
	file.consumableData = consumableData
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

	int consumablesRequired = player.HasPassive( ePassives.PAS_BONUS_SMALL_HEAL ) ? maxint( 0, BASE_CONSUMABLES_REQUIRED - 1 ) : BASE_CONSUMABLES_REQUIRED
	int shieldCellCount = SURVIVAL_CountItemsInInventory( player, "health_pickup_combo_small" )
	printt( "Sentinel_TryCharge: shieldCellCount=" + shieldCellCount + " required=" + consumablesRequired )

	if ( shieldCellCount < consumablesRequired )
	{
		Sentinel_NoShieldCellHint()
		return
	}

	player.ClientCommand( "Sentinel_TryCharge" )
}

void function WeaponSentinel_TryApplyEnergized( entity player, entity weapon )
{
	if ( !IsValid( player ) || !IsValid( weapon ) )
		return

	int activity = weapon.GetWeaponActivity()
	if ( weapon.IsInCustomActivity() && (activity == ACT_VM_CHARGE_VER4 || activity == ACT_VM_ONEHANDED_CHARGE) )
		return

	if ( player.IsSwitching( 0 ) )
		return

	int consumablesRequired = player.HasPassive( ePassives.PAS_BONUS_SMALL_HEAL ) ? maxint( 0, BASE_CONSUMABLES_REQUIRED - 1 ) : BASE_CONSUMABLES_REQUIRED
	string consumableString = consumablesRequired > 1 ? file.consumableData.consumableNamePlural : file.consumableData.consumableNameSingular
	int consumableCount = SURVIVAL_CountItemsInInventory( player, file.consumableData.ref )
	if ( !DEBUG_FREE_ENERGIZE && consumableCount <= (consumablesRequired - 1) )
	{
		AnnouncementMessageRight( player, Localize( "#WPN_SENTINEL_ENERGIZE_CONSUMABLE_REQUIRED", consumablesRequired, Localize( consumableString ) ) )
		return
	}

	int eHandle = weapon.GetEncodedEHandle()
	player.ClientCommand( "BeginEnergize " + eHandle )
}

void function DisplayRechamberRui( entity weapon )
{
	if ( !IsValid( weapon ) )
		return
	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDeath" )
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( RECHAMBER_RUI_ABORT_SIGNAL )

	var rui = CreateCockpitPostFXRui( $"ui/crosshair_single_dot_sentinel.rpak" )
	RuiSetBool( rui, "isActive", false )

	OnThreadEnd(
		function() : ( rui, weapon, player )
		{
			RuiDestroy( rui )

			if ( IsValid( weapon ) && weapon.w.sentinelEnergizeHintRui != null )
				RuiSetBool( weapon.w.sentinelEnergizeHintRui, "isRechambering", false)
		}
	)

	float fireRate = weapon.GetWeaponSettingFloat( eWeaponVar.fire_rate )
	if ( fireRate <= 0 )
		return
	wait 1.0 / fireRate

	if ( !IsValid( weapon ) )
		return

	float duration = weapon.GetSequenceDuration( RECHAMBER_RUI_END_EVENT_ANIM )
	float frac = weapon.GetScriptedAnimEventCycleFrac( RECHAMBER_RUI_END_EVENT_ANIM, RECHAMBER_RUI_END_EVENT )
	float endTime = Time() + duration * frac

	RuiSetBool( rui, "isActive", true )
	RuiSetFloat( rui, "birthTime", Time() )
	RuiSetFloat( rui, "deathTime", endTime )

	if ( weapon.w.sentinelEnergizeHintRui != null )
		RuiSetBool( weapon.w.sentinelEnergizeHintRui, "isRechambering", true)

	while ( Time() < endTime )
	{
		WaitFrame()
	}

	RuiSetBool( rui, "isActive", false )

	if ( IsValid( weapon ) && weapon.w.sentinelEnergizeHintRui != null )
		RuiSetBool( weapon.w.sentinelEnergizeHintRui, "isRechambering", false)
}

void function EnergizeRuiThink( entity player, entity weapon )
{
	AssertIsNewThread()
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( ENERGIZE_STATUS_RUI_ABORT_SIGNAL )

	if ( !IsValid( player ) || !IsLocalViewPlayer( player ) )
		return
	player.EndSignal( "OnDeath" )

	var rui = ClWeaponStatus_GetWeaponHudRui( player )
	var crosshairRui = CreateCockpitPostFXRui( $"ui/crosshair_energize_status_sentinel.rpak" )
	weapon.w.sentinelEnergizeHintRui = crosshairRui

	OnThreadEnd(
		function() : ( player, weapon, rui, crosshairRui )
		{
			RuiSetBool( rui, "showChargeBar", false )
			RuiDestroy( crosshairRui )
			if ( IsValid( weapon ) )
				weapon.w.sentinelEnergizeHintRui = null
		}
	)

	vector energizedColor = SrgbToLinear( ENERGIZED_UI_COLOR )
	vector energizedLeftBarColor = SrgbToLinear( ENERGIZED_UI_LEFT_BAR_COLOR )

	vector shieldBatteryLeftBarColor = SrgbToLinear( GetKeyColor( COLORID_HUD_LOOT_TIER0, 2 ) / 255.0 ) * 0.8
	const float COLOR_ADD = 0.2
	vector shieldBatteryColor = <min( shieldBatteryLeftBarColor.x + COLOR_ADD, 1), min( shieldBatteryLeftBarColor.y + COLOR_ADD, 1), min( shieldBatteryLeftBarColor.z + COLOR_ADD, 1)>

	RuiSetImage( rui, "chargeIcon", $"rui/hud/loot/loot_stim_shield_small" )
	RuiSetImage( rui, "chargedAmmoIconOverride", SNIPER_AMMO_ENERGIZED_ICON )
	RuiSetFloat3( rui, "chargedAmmoOverrideColor", energizedColor )

	RuiSetBool( crosshairRui, "isActive", false )
	RuiSetFloat3( crosshairRui, "energizeColor", energizedColor )

	int consumablesRequired
	string consumableName

	float energizingStartTime = -1.0
	float curEnergizingTime = -1.0

	float offset = 0.05
	float width = 100
	float lastTime = Time()

	int flags = -1

	int state = -1
	int lastState = -1
	while ( true )
	{
		{
			lastState = state
			flags = weapon.GetScriptFlags0()
			if ( DEBUG_FLAGS )
				printt( "CLIENT: "+flags )

			consumablesRequired = player.HasPassive( ePassives.PAS_BONUS_SMALL_HEAL ) ? maxint( 0, BASE_CONSUMABLES_REQUIRED - 1 ) : BASE_CONSUMABLES_REQUIRED

			if ( flags == ENERGIZE_FLAGS_CHARGING )
			{
				RuiSetBool( rui, "showChargeBar", true )

				state = 0
				if ( state != lastState )
				{
					RuiSetBool( rui, "showChargeBarBorder", true )
					RuiSetBool( rui, "showChargeBarBorderColor", true )
					RuiSetFloat3( rui, "chargeBarBorderOverlayColor", shieldBatteryLeftBarColor )
					RuiSetString( rui, "chargeBarTextLeft", Localize( "#WPN_SENTINEL_ENERGIZING_LABEL" ) )
					RuiSetString( rui, "chargeBarTextLeftLong", "" )

					RuiSetBool( rui, "showChargeProgressBar", true )
					RuiSetFloat3( rui, "chargeBarColorRight", shieldBatteryColor )
					RuiSetFloat3( rui, "chargeBarColorLeft", shieldBatteryLeftBarColor )
					energizingStartTime = Time()

					RuiSetBool( rui, "showChargeIcon", true )

					RuiSetBool( rui, "showChargedAmmoIconOverride", false )
					RuiSetBool( rui, "showChargedAmmoOverride", false )
				}

				curEnergizingTime = Time() - energizingStartTime
				RuiSetFloat( rui, "chargeBarTimeRemaining", file.energizeActivityTime - curEnergizingTime )
				RuiSetFloat( rui, "chargeBarFrac", min( curEnergizingTime / file.energizeActivityTime, 1.0 ) )
			}
			else if ( flags == ENERGIZE_FLAGS_CHARGED && weapon.HasMod( ENERGIZED_MOD ) )
			{
				RuiSetBool( rui, "showChargeBar", true )
				RuiSetFloat( rui, "chargeBarTimeRemaining", -1.0 )

				state = 1
				if ( state != lastState )
				{
					RuiSetBool( rui, "showChargeBarBorder", true )
					RuiSetBool( rui, "showChargeBarBorderColor", true )
					RuiSetFloat3( rui, "chargeBarBorderOverlayColor", energizedLeftBarColor )
					RuiSetString( rui, "chargeBarTextLeft", Localize( "#WPN_SENTINEL_ENERGIZE_LABEL" ) )
					RuiSetString( rui, "chargeBarTextLeftLong", "" )

					RuiSetBool( rui, "showChargeProgressBar", true )
					RuiSetFloat3( rui, "chargeBarColorRight", energizedColor )
					RuiSetFloat3( rui, "chargeBarColorLeft", energizedLeftBarColor )

					RuiSetBool( rui, "showChargeIcon", false )

					RuiSetBool( rui, "showChargedAmmoIconOverride", true )
					RuiSetBool( rui, "showChargedAmmoOverride", true )
				}

				RuiSetFloat( rui, "chargeBarFrac", max( weapon.GetScriptTime0() - Time(), 0 ) / file.energizedDuration )
			}
			else if ( DEBUG_FREE_ENERGIZE || SURVIVAL_CountItemsInInventory( player, file.consumableData.ref ) > (consumablesRequired -1) )
			{
				RuiSetBool( rui, "showChargeBar", true )
				RuiSetFloat( rui, "chargeBarTimeRemaining", -1.0 )

				state = 2
				if ( state != lastState )
				{
					RuiSetBool( rui, "showChargeBarBorder", false )
					RuiSetBool( rui, "showChargeBarBorderColor", false )
					RuiSetString( rui, "chargeBarTextLeft", "" )
					RuiSetString( rui, "chargeBarTextLeftLong", Localize( "#WPN_SENTINEL_ENERGIZE_HINT" ) )

					RuiSetBool( rui, "showChargeProgressBar", false )

					RuiSetBool( rui, "showChargeIcon", true )

					RuiSetBool( rui, "showChargedAmmoIconOverride", false )
					RuiSetBool( rui, "showChargedAmmoOverride", false )
				}
			}
			else
			{
				RuiSetBool( rui, "showChargeBar", true )
				RuiSetFloat( rui, "chargeBarTimeRemaining", -1.0 )

				consumableName = consumablesRequired > 1 ? file.consumableData.consumableNamePlural : file.consumableData.consumableNameSingular
				RuiSetString( rui, "chargeBarTextLeftLong", Localize( "#WPN_SENTINEL_ENERGIZE_CONSUMABLE_REQUIRED", consumablesRequired, Localize( consumableName ) ) )

				state = 3
				if ( state != lastState )
				{
					RuiSetBool( rui, "showChargeBarBorder", false )
					RuiSetBool( rui, "showChargeBarBorderColor", false )
					RuiSetString( rui, "chargeBarTextLeft", "" )

					RuiSetBool( rui, "showChargeProgressBar", false )

					RuiSetBool( rui, "showChargeIcon", true )

					RuiSetBool( rui, "showChargedAmmoIconOverride", false )
					RuiSetBool( rui, "showChargedAmmoOverride", false )
				}
			}
		}


		if ( GetCurrentPlaylistVarBool( SENTINEL_SHOW_CROSSHAIR_ENERGIZE_PLAYLIST_VAR, true ) ){
			if ( weapon.HasMod( ENERGIZED_MOD ) )
			{
				RuiSetBool( crosshairRui, "isActive", true )
				RuiSetFloat( crosshairRui, "energizeFrac", max( weapon.GetScriptTime0() - Time(), 0.0 ) / file.energizedDuration )
				RuiSetFloat( crosshairRui, "adsFrac", player.GetZoomFrac() )

				switch ( weapon.w.activeOptic )
				{
					case "":
						offset = 0.085
						break
					case "optic_cq_hcog_classic":
						offset = 0.035
						break
					case "optic_cq_holosight":
						offset = 0.055
						break
					case "optic_cq_hcog_bruiser":
						offset = 0.055
						break
					case "optic_cq_holosight_variable":
						offset = 0.055
						break
					case "optic_ranged_hcog":
						offset = 0.085
						break
					case "optic_ranged_aog_variable":
						offset = 0.085
						break
					case "optic_sniper":
						offset = 0.135
						break
					case "optic_sniper_variable":
						float offset4x = 0.135
						float offset8x = 0.175
						offset = GraphCapped( weapon.GetWeaponZoomFOV(), 19.8583, 10.0042, offset4x, offset8x )
						break
					case "optic_sniper_threat":
						float offset4x = 0.135
						float offset10x = 0.2
						offset = GraphCapped( weapon.GetWeaponZoomFOV(), 19.8583, 8.01071, offset4x, offset10x )
						break
					default:
						Warning( "Sentinel energize crosshair rui: unhandled optic " + weapon.w.activeOptic + ". Falling back on default offset." )
						offset = 0.05
				}

				RuiSetFloat( crosshairRui, "offset", offset )
			}
			else
			{
				RuiSetBool( crosshairRui, "isActive", false )
			}
		}

		lastTime = Time()
		WaitFrame()
	}
}

void function AttemptCancelEnergize( entity player )
{
	if ( !IsValid( player ) )
		return

	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( !IsValid( weapon ) )
		return

	if ( weapon.GetWeaponClassName() != "mp_weapon_sentinel" )
		return

	int activity = weapon.GetWeaponActivity()
	if ( activity != ACT_VM_CHARGE_VER4 && activity != ACT_VM_ONEHANDED_CHARGE )
		return

	int eHandle = weapon.GetEncodedEHandle()
	player.ClientCommand( "CancelEnergize " + eHandle )
}

void function Sentinel_UpdateChargeEndTime( float newEndTime )
{
	// Handled by EnergizeRuiThink via ScriptTime0
}

void function Sentinel_NoShieldCellHint()
{
	entity player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	player.ClientCommand( "ClientCommand_Quickchat " + eCommsAction.INVENTORY_NEED_SHIELDS )

	int consumablesRequired = player.HasPassive( ePassives.PAS_BONUS_SMALL_HEAL ) ? maxint( 0, BASE_CONSUMABLES_REQUIRED - 1 ) : BASE_CONSUMABLES_REQUIRED
	string consumableString = consumablesRequired > 1 ? file.consumableData.consumableNamePlural : file.consumableData.consumableNameSingular
	AnnouncementMessageRight( player, Localize( "#WPN_SENTINEL_ENERGIZE_CONSUMABLE_REQUIRED", consumablesRequired, Localize( consumableString ) ) )
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

	int consumablesRequired = player.HasPassive( ePassives.PAS_BONUS_SMALL_HEAL ) ? maxint( 0, BASE_CONSUMABLES_REQUIRED - 1 ) : BASE_CONSUMABLES_REQUIRED
	int shieldCellCount = SURVIVAL_CountItemsInInventory( player, "health_pickup_combo_small" )
	if ( shieldCellCount < consumablesRequired )
	{
		Remote_CallFunction_NonReplay( player, "Sentinel_NoShieldCellHint" )
		return false
	}

	SURVIVAL_RemoveFromPlayerInventory( player, "health_pickup_combo_small", consumablesRequired )

	weapon.StartCustomActivity( ENERGIZE_ACTIVITY, 0 )
	return true
}

void function Flowstate_SentinelCharging( entity player, entity weapon )
{
	weapon.EndSignal( "OnDestroy" )

	if ( !("s" in weapon) )
		weapon.s <- {}
	weapon.s.chargingInterrupted <- false

	float chargeEndTime = Time() + weapon.GetCustomActivityDuration()

	thread function() : ( weapon, player )
	{
		weapon.EndSignal( "OnDestroy" )
		weapon.WaitSignal( SENTINEL_DEACTIVATE_SIGNAL )

		if ( IsValid( weapon ) )
		{
			if ( !("s" in weapon) )
				weapon.s <- {}
			weapon.s.chargingInterrupted <- true

			if ( IsValid( player ) && weapon.IsInCustomActivity() )
			{
				weapon.StopCustomActivity()
				SURVIVAL_AddToPlayerInventory( player, "health_pickup_combo_small" )
			}
		}
	}()

	OnThreadEnd( function() : ( player, weapon )
	{
		if ( !IsValid( player ) || !IsValid( weapon ) )
			return

		if ( "s" in weapon && "chargingInterrupted" in weapon.s && weapon.s.chargingInterrupted )
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
			weapon.SetScriptFlags0( ENERGIZE_FLAGS_OFF )
			AddEnergize( weapon )
			thread SentinelOnModAddedWatcher( player, weapon )
		}

		if ( "s" in weapon && "chargingInterrupted" in weapon.s )
			delete weapon.s.chargingInterrupted
	})

	while( Time() < chargeEndTime && IsValid( weapon ) && weapon == player.GetActiveWeapon( eActiveInventorySlot.mainHand ) && weapon.IsInCustomActivity() )
	{
		WaitFrame()
	}
}

void function SentinelOnModAddedWatcher( entity player, entity weapon )
{
	weapon.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	float duration = GetWeaponInfoFileKeyField_GlobalFloat( weapon.GetWeaponClassName(), "energized_duration" )
	float chargeEndTime = Time() + duration
	if ( !("s" in weapon) )
		weapon.s <- {}
	weapon.s.energizedEndTime <- chargeEndTime
	weapon.Signal( SENTINEL_DEACTIVATE_SIGNAL )

	OnThreadEnd( function() : ( player, weapon )
	{
		RemoveEnergize( weapon )
		if ( "s" in weapon && "energizedEndTime" in weapon.s )
			delete weapon.s.energizedEndTime
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
			if ( "s" in weapon && "energizedEndTime" in weapon.s )
				delete weapon.s.energizedEndTime
			break
		}

		if ( "s" in weapon && "energizedEndTime" in weapon.s )
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

void function AddEnergize( entity weapon )
{
	weapon.SetWeaponChargeFraction( 1.0 )
	weapon.SetScriptInt0( ScriptChargeFracState.MATCH_ENERGIZE )
	weapon.SetScriptTime0( Time() + file.energizedDuration )
	weapon.SetScriptFlags0( ENERGIZE_FLAGS_CHARGED )
	weapon.AddMod( ENERGIZED_MOD )
}

void function RemoveEnergize( entity weapon )
{
	if ( weapon.GetScriptInt0() == ScriptChargeFracState.MATCH_ENERGIZE || weapon.GetScriptInt0() == ScriptChargeFracState.INCREASE_TO_1 )
		weapon.SetScriptInt0( ScriptChargeFracState.DECREASE_TO_0 )
	else
		weapon.SetScriptInt0( ScriptChargeFracState.OFF )
	weapon.SetScriptTime0( -1.0 )
	weapon.SetScriptFlags0( ENERGIZE_FLAGS_OFF )
	if ( IsValid( weapon ) && weapon.HasMod( ENERGIZED_MOD ) )
		weapon.RemoveMod( ENERGIZED_MOD )
}

void function ScriptChargeFracThink( entity weapon, entity player )
{
	weapon.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	weapon.EndSignal( SCRIPT_CHARGE_FRAC_THINK_ABORT_SIGNAL )

	int lastState = 0
	float newFrac = 0.0
	float lastTime = Time()
	float dt = 0.0
	WaitFrame()

	while ( true )
	{
		dt = Time() - lastTime
		lastTime = Time()

		bool serverOrPredicted = IsServer() || (IsClient() && InPrediction() && IsFirstTimePredicted())

		switch ( weapon.GetScriptInt0() )
		{
			case ScriptChargeFracState.OFF:
				if ( serverOrPredicted )
					weapon.SetWeaponChargeFraction( 0.0 )
				break

			case ScriptChargeFracState.INCREASE_TO_1:
				if ( serverOrPredicted )
				{
					newFrac = min( weapon.GetWeaponChargeFraction() + SCRIPT_CHARGE_FRAC_INCREASE_TO_1_SPEED * dt, 1.0 )
					weapon.SetWeaponChargeFraction( newFrac )
				}
				break

			case ScriptChargeFracState.DECREASE_TO_0:
				if ( serverOrPredicted )
				{
					newFrac = max( weapon.GetWeaponChargeFraction() - SCRIPT_CHARGE_FRAC_DECREASE_TO_0_SPEED * dt, 0.0 )
					weapon.SetWeaponChargeFraction( newFrac )
					if ( newFrac <= 0.0 )
						weapon.SetScriptInt0( ScriptChargeFracState.OFF )
				}
				break

			case ScriptChargeFracState.MATCH_ENERGIZE:
				if ( serverOrPredicted )
				{
					float energizeFrac = max( weapon.GetScriptTime0() - Time(), 0 ) / file.energizedDuration
					float targetFrac = GraphCapped( energizeFrac, 0.0, 1.0, SCRIPT_CHARGE_FRAC_MATCH_ENERGIZE_MIN, 1.0 )
					float curFrac = weapon.GetWeaponChargeFraction()
					newFrac = targetFrac < curFrac ? max( curFrac - SCRIPT_CHARGE_FRAC_MATCH_ENERGIZE_SPEED_MAX * dt, targetFrac ) : targetFrac
					weapon.SetWeaponChargeFraction( newFrac )
				}
				break
		}

		lastState = weapon.GetScriptInt0()
		WaitFrame()
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

	weapon.SetScriptFlags0( ENERGIZE_FLAGS_CHARGING )

	#if SERVER
	thread Flowstate_SentinelCharging( player, weapon )
	#endif
}

void function OnWeaponCustomActivityEnd_weapon_sentinel( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return

	if ( IsClient() && (!InPrediction() || !IsFirstTimePredicted()) )
		return

	if ( weapon.GetScriptInt0() == ScriptChargeFracState.INCREASE_TO_1 )
		weapon.SetScriptInt0( ScriptChargeFracState.DECREASE_TO_0 )

	weapon.SetScriptFlags0( ENERGIZE_FLAGS_OFF )
}

void function OnWeaponStartZoomIn_weapon_sentinel( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	weapon.Signal( SENTINEL_DEACTIVATE_SIGNAL )
	weapon.Signal( ENERGIZE_FX_ON_SCOPE_ZOOM_ABORT_SIGNAL )

	entity player = weapon.GetWeaponOwner()
	if ( IsValid( player ) && HasFullscreenScope( weapon ) )
		thread StopEnergizeFXOnScopeZoomIn( weapon, player )
}

void function OnWeaponStartZoomOut_weapon_sentinel( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	weapon.Signal( SENTINEL_DEACTIVATE_SIGNAL )
	weapon.Signal( ENERGIZE_FX_ON_SCOPE_ZOOM_ABORT_SIGNAL )

	entity player = weapon.GetWeaponOwner()
	if ( IsValid( player ) && HasFullscreenScope( weapon ) && weapon.GetScriptInt0() == ScriptChargeFracState.MATCH_ENERGIZE )
		thread StartEnergizeFXOnScopeZoomOut( weapon, player )
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
		weapon.s.energizedEndTime = expect float( weapon.s.energizedEndTime ) - file.energizedTimeConsumedPerShot
		weapon.SetScriptTime0( expect float( weapon.s.energizedEndTime ) )
	}
	#endif
	int ammoPerShot = weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
	#if CLIENT
	if ( InPrediction() && IsFirstTimePredicted() )
	{
		if ( weapon.GetWeaponPrimaryClipCount() > ammoPerShot && !HasFullscreenScope( weapon ) )
		{
			weapon.Signal( RECHAMBER_RUI_ABORT_SIGNAL )
			thread DisplayRechamberRui( weapon )
		}
	}
	#endif
	return ammoPerShot
}

void function OnWeaponDeactivate_weapon_sentinel( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	weapon.Signal( SENTINEL_DEACTIVATE_SIGNAL )

	#if CLIENT
	weapon.Signal( ENERGIZE_STATUS_RUI_ABORT_SIGNAL )
	#endif

	weapon.Signal( SCRIPT_CHARGE_FRAC_THINK_ABORT_SIGNAL )
	weapon.SetWeaponChargeFraction( 0.0 )
}

void function OnWeaponActivate_weapon_sentinel( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return

	file.energizedDuration = GetWeaponInfoFileKeyField_GlobalFloat( "mp_weapon_sentinel", "energized_duration" )
	file.energizedTimeConsumedPerShot = GetWeaponInfoFileKeyField_GlobalFloat( "mp_weapon_sentinel", "energized_time_consumed_per_shot" )
	file.energizeActivityTime = GetWeaponInfoFileKeyField_GlobalFloat( "mp_weapon_sentinel", "energize_activity_time" )

	#if CLIENT
	if ( IsValid( player ) )
	{
		int slot = GetSlotForWeapon( player, weapon )
		if ( slot >= 0 )
			weapon.w.activeOptic = SURVIVAL_GetWeaponAttachmentForPoint( player, slot, "sight" )
		else
			weapon.w.activeOptic = ""
		thread EnergizeRuiThink( player, weapon )
	}
	#endif

	#if SERVER
	if ( IsValid( player ) && player.IsPlayer() )
		thread ScriptChargeFracThink( weapon, player )
	#endif
}

#if SERVER
void function PrecacheEnergizeFX( string weaponClassName )
{
	string baseStr = "energize_effect"
	string preBaseStr = "pre_energize_effect"
	string endBaseStr = "end_energize_effect"

	string str1p = baseStr + "_1p"
	string preStr1p = preBaseStr + "_1p"
	string endStr1p = endBaseStr + "_1p"
	string str3p = baseStr + "_3p"
	string preStr3p = preBaseStr + "_3p"
	string endStr3p = endBaseStr + "_3p"

	for ( int i = 0; i < MAX_ENERGIZE_FX; i++ )
	{
		string suffix = string( i )
		asset fx1p = GetWeaponInfoFileKeyFieldAsset_Global( weaponClassName, baseStr + suffix + "_1p" )
		asset preFx1p = GetWeaponInfoFileKeyFieldAsset_Global( weaponClassName, preBaseStr + suffix + "_1p" )
		asset endFx1p = GetWeaponInfoFileKeyFieldAsset_Global( weaponClassName, endBaseStr + suffix + "_1p" )
		asset fx3p = GetWeaponInfoFileKeyFieldAsset_Global( weaponClassName, baseStr + suffix + "_3p" )
		asset preFx3p = GetWeaponInfoFileKeyFieldAsset_Global( weaponClassName, preBaseStr + suffix + "_3p" )
		asset endFx3p = GetWeaponInfoFileKeyFieldAsset_Global( weaponClassName, endBaseStr + suffix + "_3p" )

		if ( fx1p != "" )
			PrecacheEffect( fx1p )
		if ( preFx1p != "" )
			PrecacheEffect( preFx1p )
		if ( endFx1p != "" )
			PrecacheEffect( endFx1p )
		if ( fx3p != "" )
			PrecacheEffect( fx3p )
		if ( preFx3p != "" )
			PrecacheEffect( preFx3p )
		if ( endFx3p != "" )
			PrecacheEffect( endFx3p )
	}
}
#endif

void function PlayEnergizeFX( entity weapon, int energizeTime, bool play3p = true, bool playInFullscreenScope = false )
{
	if ( !IsValid( weapon ) )
	{
		Warning( "Sentinel PlayEnergizeFX called with invalid weapon" )
		return
	}

	if ( ShouldShowADSScopeView( weapon ) && !playInFullscreenScope )
		return

	entity vm = weapon.GetWeaponViewmodel()

	string baseStr = ""
	switch ( energizeTime )
	{
		case EnergizeFXTime.PRE_ENERGIZE:
			baseStr = "pre_"
			break
		case EnergizeFXTime.ENERGIZE:
			break
		case EnergizeFXTime.END_ENERGIZE:
			baseStr = "end_"
			break
	}
	baseStr += "energize_effect"

	for ( int i = 0; i < MAX_ENERGIZE_FX; i++ )
	{
		string str = baseStr + string( i )
		asset fx1p = weapon.GetWeaponInfoFileKeyFieldAsset( str + "_1p" )
		asset fx3p = weapon.GetWeaponInfoFileKeyFieldAsset( str + "_3p" )
		if ( fx1p == "" && fx3p == "" )
			continue
		if ( fx1p == "" && !play3p )
			continue

		if ( fx3p == "" && !IsValid( vm ) )
			continue

		var attachRaw = weapon.GetWeaponInfoFileKeyField( str + "_attachment" )
		var attachScopedRaw = weapon.GetWeaponInfoFileKeyField( str + "_attachment_scoped" )
		if ( attachRaw == null && attachScopedRaw == null )
			continue

		string attachUnscoped = ""
		if ( attachRaw != null )
			attachUnscoped = expect string( attachRaw )

		string attachScoped = ""
		if ( attachScopedRaw != null )
			attachScoped = expect string( attachScopedRaw )

		entity player = weapon.GetWeaponOwner()

		#if CLIENT
			bool useScopedAttach = attachScoped != "" && IsValid( player ) && IsLocalViewPlayer( player ) && ShouldShowADSScopeView( weapon )
		#else
			bool useScopedAttach = attachScoped != "" && IsValid( player )
		#endif

		if ( !useScopedAttach && attachUnscoped == "" )
			continue

		string attach = useScopedAttach ? attachScoped : attachUnscoped

		if ( play3p )
			weapon.PlayWeaponEffectNoCull( fx1p, fx3p, attach, true )
		else
			weapon.PlayWeaponEffectNoCull( fx1p, $"", attach, true )
	}
}

void function StopEnergizeFX( entity weapon, int energizeTime, bool stop3p = true )
{
	if ( !IsValid( weapon ) )
		return

	entity vm = weapon.GetWeaponViewmodel()

	string baseStr = ""
	switch ( energizeTime )
	{
		case EnergizeFXTime.PRE_ENERGIZE:
			baseStr = "pre_"
			break
		case EnergizeFXTime.ENERGIZE:
			break
		case EnergizeFXTime.END_ENERGIZE:
			baseStr = "end_"
			break
	}
	baseStr += "energize_effect"

	for ( int i = 0; i < MAX_ENERGIZE_FX; i++ )
	{
		string str = baseStr + string( i )
		asset fx1p = weapon.GetWeaponInfoFileKeyFieldAsset( str + "_1p" )
		asset fx3p = weapon.GetWeaponInfoFileKeyFieldAsset( str + "_3p" )
		if ( fx1p == "" && fx3p == "" )
			continue
		if ( fx1p == "" && !stop3p )
			continue

		if ( fx3p == "" && !IsValid( vm ) )
			continue

		if ( stop3p )
			weapon.StopWeaponEffect( fx1p, fx3p )
		else
			weapon.StopWeaponEffect( fx1p, $"" )
	}
}

void function StartEnergizeFXOnScopeZoomOut( entity weapon, entity player )
{
	weapon.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	weapon.EndSignal( ENERGIZE_FX_ON_SCOPE_ZOOM_ABORT_SIGNAL )

	float safetyAbortTime = Time() + 5.0
	while ( Time() < safetyAbortTime )
	{
		if ( player.GetZoomFrac() < weapon.GetWeaponSettingFloat( eWeaponVar.ads_fov_zoomfrac_end ) )
		{
			PlayEnergizeFX( weapon, EnergizeFXTime.ENERGIZE, false )
			return
		}

		WaitFrame()
	}
}

void function StopEnergizeFXOnScopeZoomIn( entity weapon, entity player )
{
	weapon.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	weapon.EndSignal( ENERGIZE_FX_ON_SCOPE_ZOOM_ABORT_SIGNAL )

	float safetyAbortTime = Time() + 5.0
	while ( Time() < safetyAbortTime )
	{
		if ( player.GetZoomFrac() > (weapon.GetWeaponSettingFloat( eWeaponVar.ads_fov_zoomfrac_end ) - 0.1) )
		{
			StopEnergizeFX( weapon, EnergizeFXTime.PRE_ENERGIZE, false )
			StopEnergizeFX( weapon, EnergizeFXTime.ENERGIZE, false )
			StopEnergizeFX( weapon, EnergizeFXTime.END_ENERGIZE, false )
			return
		}

		WaitFrame()
	}
}