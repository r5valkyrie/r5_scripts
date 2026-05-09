global function MpWeaponMobileHMG_Init
global function OnWeaponActivate_weapon_mobile_hmg
global function OnWeaponDeactivate_weapon_mobile_hmg
global function OnWeaponPrimaryAttack_weapon_mobile_hmg
global function OnWeaponStartZoomIn_weapon_mobile_hmg
global function OnWeaponStartZoomOut_weapon_mobile_hmg
global function OnWeaponReload_weapon_mobile_hmg
global function OnAnimEvent_weapon_mobile_hmg
global function OnWeaponZoomFOVToggle_weapon_mobile_hmg
global function OnWeaponAttemptOffhandSwitch_weapon_mobile_hmg

#if SERVER
global function MobileHMG_RegisterNetworkFunctions
global function MobileHMG_SetPlayerLastSaidTurretChatterTime
global function MobileHMG_SetPlacementMode
global function MobileHMG_PlacementToggleEnabled
global function ClientCallback_ToggleMobileHMGPlacementMode
global function MobileHMG_DoRefund
global function ClientCallback_ForceCooldown
#endif

#if CLIENT
global function OnClientAnimEvent_weapon_mobile_hmg
#endif

global const string MOBILE_HMG_WEAPON_NAME = "mp_weapon_mobile_hmg"

// Audio
const string TURRET_BUTTON_PRESS_SOUND_1P = "weapon_sheilaturret_triggerpull"
const string TURRET_BUTTON_PRESS_SOUND_3P = "weapon_sheilaturret_triggerpull_3p"
const string TURRET_BARREL_SPIN_LOOP_1P = "weapon_sheilaturret_motorloop_1p"
const string TURRET_BARREL_SPIN_LOOP_3P = "Weapon_sheilaturret_mobile_motorLoop_3P"
const string TURRET_WINDUP_1P = "weapon_sheilaturret_windup_1p"
const string TURRET_WINDUP_3P = "weapon_sheilaturret_windup_3p"
const string TURRET_WINDDOWN_1P = "weapon_sheilaturret_mobile_winddown_1p"
const string TURRET_WINDDOWN_3P = "weapon_sheilaturret_winddown_3P"
const string TURRET_RELOAD_3P = "weapon_sheilaturret_reload_generic_comp_3p"
const string TURRET_RELOAD_RAMPART_3P = "weapon_sheilaturret_reload_rampart_comp_3p"

const string TURRET_RELOAD_RAMPART_UPGRADE_3P = "weapon_sheilaturret_reload_generic_comp_3p"

const string TURRET_RELOAD = "weapon_sheilaturret_reload_rampart_null"
const string TURRET_FIRED_LAST_SHOT_1P = "weapon_sheilaturret_lastshot_1p"
const string TURRET_FIRED_LAST_SHOT_3P = "weapon_sheilaturret_lastshot_3p"
const string TURRET_DISMOUNT_1P = "weapon_sheilaturret_mobile_dismount_1p"
const string TURRET_SIGHT_FLIP_UP_1P = "weapon_sheilaturret_sightflipup"
const string TURRET_SIGHT_FLIP_DOWN_1P = "weapon_sheilaturret_sightflipdown"

const string TURRET_DRAWFIRST_1P = "weapon_sheilaturret_drawfirst_1p"
const string TURRET_DRAW_1P = "weapon_sheilaturret_draw_1p"

// Dialogue
const float GLOBAL_TURRET_CHATTER_DEBOUNCE = 7.0
const float SUSTAINED_FIRE_QUIP_CHANCE = 0.15

// FX
const TURRET_LASER_1P				= $"P_wpn_rampart_laser_aim_FP"

//Signals
const string MOBILE_HMG_COOLDOWN_SIGNAL = "mobile_hmg_cooldown"
const string MOBILE_HMG_KILL_UI_SIGNAL = "mobile_hmg_kill_ui"
const string MOBILE_HMG_ACTIVATE_SIGNAL = "mobile_hmg_activate"

//Mods
global const string MOBILE_HMG_ACTIVE_MOD = "mobile_hmg_active"
global const string MOBILE_HMG_FAST_SWITCH_MOD = "mobile_hmg_fast_switch"

//Tuning
const float MAX_REFUND_PERCENTAGE = 0.75

struct
{
	#if SERVER
		table< entity, float > playerLastSaidTurretChatterTime
		table< entity, bool > placementMode
		table< entity, bool > placementToggleEnabled
	#endif
	#if CLIENT
		int laserFXHandle = -1
	#endif
} file

void function MpWeaponMobileHMG_Init()
{
	RegisterAdditionalMainWeapon( MOBILE_HMG_WEAPON_NAME  )

	PrecacheParticleSystem( TURRET_LASER_1P )
	PrecacheParticleSystem( $"wpn_muzzleflash_rampart_turret_FP" )
	PrecacheParticleSystem( $"wpn_muzzleflash_rampart_turret" )
	PrecacheParticleSystem( $"wpn_muzzleflash_turret_center_FP" )
	PrecacheWeapon( MOUNTED_TURRET_PLACEABLE_WEAPON_NAME )
	RegisterSignal( MOBILE_HMG_COOLDOWN_SIGNAL )
	RegisterSignal( MOBILE_HMG_KILL_UI_SIGNAL )
	RegisterSignal( MOBILE_HMG_ACTIVATE_SIGNAL )

#if CLIENT
	RegisterConCommandTriggeredCallback( "+scriptCommand5", PlacementModeTogglePressed )
	RegisterConCommandTriggeredCallback( "+scriptCommand3", ForceCooldownPressed )
#endif
}

void function OnWeaponActivate_weapon_mobile_hmg( entity weapon )
{
	OnWeaponActivate_weapon_basic_bolt( weapon )
	entity weaponOwner = weapon.GetOwner()
	bool serverOrPredicted = IsServer() || ( InPrediction() && IsFirstTimePredicted() )
	if( serverOrPredicted && !weapon.HasMod( MOBILE_HMG_FAST_SWITCH_MOD ) )
	{
		weapon.w.startChargeTime = Time()
	}
#if SERVER
	MobileHMG_SetPlacementMode( weapon, false )
	MobileHMG_PlacementToggleEnabled( weapon, true )
#endif // SERVER
#if CLIENT
	if ( weaponOwner != GetLocalViewPlayer() )
		return

	weapon.Signal( MOBILE_HMG_KILL_UI_SIGNAL )
	weapon.Signal( MOBILE_HMG_ACTIVATE_SIGNAL )
	thread PlacementModeHintRuiThread( weaponOwner, weapon )
	thread MobileHMG_WeaponActiveThreadClient( weapon )
#endif


	if ( serverOrPredicted )
	{
		#if SERVER
			if( !weapon.HasMod( MOBILE_HMG_ACTIVE_MOD ) )
			{
				weapon.AddMod( MOBILE_HMG_ACTIVE_MOD )
				thread MobileHMG_WeaponActiveThreadServer( weapon )
			}
		#endif
	}








	#if SERVER



	#endif
}

void function OnWeaponDeactivate_weapon_mobile_hmg( entity weapon )
{
	weapon.StopWeaponSound( TURRET_BARREL_SPIN_LOOP_1P )
	weapon.StopWeaponSound( TURRET_BARREL_SPIN_LOOP_3P )
	weapon.StopWeaponSound( TURRET_BUTTON_PRESS_SOUND_1P )
	weapon.StopWeaponSound( TURRET_BUTTON_PRESS_SOUND_3P )
	StopSoundOnEntity( weapon, TURRET_WINDUP_1P )
	StopSoundOnEntity( weapon, TURRET_WINDUP_3P )
	StopSoundOnEntity( weapon, TURRET_WINDDOWN_1P )
	StopSoundOnEntity( weapon, TURRET_RELOAD_3P )
	StopSoundOnEntity( weapon, TURRET_RELOAD_RAMPART_3P )

		StopSoundOnEntity( weapon, TURRET_RELOAD_RAMPART_UPGRADE_3P )


	entity weaponOwner = weapon.GetOwner()

	if ( !IsValid( weaponOwner ) )
		return

	StopSoundOnEntity( weaponOwner, TURRET_DRAWFIRST_1P )
	StopSoundOnEntity( weaponOwner, TURRET_DRAW_1P )

#if CLIENT
	SetTurretVMLaserEnabled( weapon, false )

	if ( weaponOwner == GetLocalViewPlayer() )
	{
		EmitSoundOnEntity( weaponOwner, TURRET_DISMOUNT_1P )
	}
#endif // CLIENT

	bool serverOrPredicted = IsServer() || ( InPrediction() && IsFirstTimePredicted() )
	if ( serverOrPredicted )
	{
	#if SERVER
		weapon.RemoveMod( MOBILE_HMG_FAST_SWITCH_MOD )
	#endif
	}
}

bool function OnWeaponAttemptOffhandSwitch_weapon_mobile_hmg( entity weapon )
{
	return true
}

void function OnWeaponStartZoomIn_weapon_mobile_hmg( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	if ( !IsValid( weaponOwner ) )
		return

	float zoomFrac = weaponOwner.GetZoomFrac()
	float zoomTimeIn = weapon.GetWeaponSettingFloat( eWeaponVar.zoom_time_in )

	#if SERVER
		EmitSoundOnEntityExceptToPlayerWithSeek( weapon, weaponOwner, TURRET_WINDUP_3P, zoomFrac * zoomTimeIn )
	#endif
	#if CLIENT
		if ( weaponOwner == GetLocalViewPlayer() )
		{
			EmitSoundOnEntityWithSeek( weapon, TURRET_WINDUP_1P, zoomFrac * zoomTimeIn )

			if ( !InPrediction() || IsFirstTimePredicted() )
			{
				//SetTurretVMLaserEnabled( weapon, true )
			}
		}
	#endif
}

void function OnWeaponStartZoomOut_weapon_mobile_hmg( entity weapon )
{
	weapon.StopWeaponSound( TURRET_BARREL_SPIN_LOOP_1P )
	weapon.StopWeaponSound( TURRET_BARREL_SPIN_LOOP_3P )
	weapon.StopWeaponSound( TURRET_BUTTON_PRESS_SOUND_1P )
	weapon.StopWeaponSound( TURRET_BUTTON_PRESS_SOUND_3P )
	StopSoundOnEntity( weapon, TURRET_WINDUP_1P )
	StopSoundOnEntity( weapon, TURRET_WINDUP_3P )

	entity weaponOwner = weapon.GetWeaponOwner()
	if ( !IsValid( weaponOwner ) )
		return

	float zoomFrac = weaponOwner.GetZoomFrac()
	float zoomOutTime = weapon.GetWeaponSettingFloat( eWeaponVar.zoom_time_out )

	#if SERVER
		EmitSoundOnEntityExceptToPlayerWithSeek( weapon, weaponOwner, TURRET_WINDDOWN_3P, (1 - zoomFrac) * zoomOutTime )
	#endif

	#if CLIENT
		SetTurretVMLaserEnabled( weapon, false )
		if ( weaponOwner == GetLocalViewPlayer() )
			EmitSoundOnEntityWithSeek( weapon, TURRET_WINDDOWN_1P, (1 - zoomFrac) * zoomOutTime )
	#endif
	bool serverOrPredicted = IsServer() || ( InPrediction() && IsFirstTimePredicted() )
}

var function OnWeaponPrimaryAttack_weapon_mobile_hmg( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetOwner()

	if ( !IsValid( weaponOwner ) )
		return 0


	if ( weapon.IsWeaponInAds() && weaponOwner.GetZoomFrac() >= 1.0 )
	{
		// Dialogue
		#if SERVER
			if ( weapon.GetWeaponPrimaryClipCount() == ( weapon.GetWeaponPrimaryClipCountMax() / 2 ) )
				TryPlayTurretChatterLine( weaponOwner, "bc_rampart_clipHalfFull" )

			if ( weapon.GetShotCount() >= 20 && weapon.GetShotCount() % 20 == 0 && RandomFloat( 1.0 ) < SUSTAINED_FIRE_QUIP_CHANCE )
				TryPlayTurretChatterLine( weaponOwner, "bc_rampart_sustainedFire" )
		#endif // SERVER

		// Audio
		if ( weapon.GetWeaponPrimaryClipCount() == 1 )
		{
			#if SERVER
				EmitSoundOnEntityExceptToPlayer( weapon, weaponOwner, TURRET_FIRED_LAST_SHOT_3P )
				thread MobileHMG_SwitchOnEmpty( weaponOwner, weapon )
			#elseif CLIENT
				if ( weaponOwner == GetLocalViewPlayer() )
					EmitSoundOnEntity( weapon, TURRET_FIRED_LAST_SHOT_1P )
				weapon.Signal( MOBILE_HMG_KILL_UI_SIGNAL )
			#endif
		}

		//	Rampart unique tracker
		#if SERVER
			//StatsHook_RampartUltimate_OnBulletFired( weaponOwner )
		#endif

		if( weapon.GetWeaponPrimaryClipCount() == weapon.GetWeaponPrimaryClipCountMax() )
		{
			PlayerUsedOffhand( weaponOwner, weapon )
		}

		return OnWeaponPrimaryAttack_weapon_basic_bolt( weapon, attackParams )
	}
	else
	{
		return 0
	}
}

void function OnWeaponReload_weapon_mobile_hmg( entity weapon, int milestoneIndex )
{
	#if SERVER

		int reloadTimeLateVar = -1
		switch ( milestoneIndex )
		{
			case 1:
				reloadTimeLateVar = eWeaponVar.reload_time_late1
				break
			case 2:
				reloadTimeLateVar = eWeaponVar.reload_time_late2
				break
			case 3:
				reloadTimeLateVar = eWeaponVar.reload_time_late3
				break
			case 4:
				reloadTimeLateVar = eWeaponVar.reload_time_late4
				break
			case 5:
				reloadTimeLateVar = eWeaponVar.reload_time_late5
				break
		}

		float seekTime
		seekTime = ( reloadTimeLateVar > -1 ) ? weapon.GetWeaponSettingFloat( eWeaponVar.reload_time ) - weapon.GetWeaponSettingFloat( reloadTimeLateVar ) : 0.0

		if ( weapon.HasMod( "rampart_gunner" ) )
		{

			entity weaponOwner = weapon.GetWeaponOwner()
			if ( !IsValid( weaponOwner ) )
				return

			if ( PlayerHasPassive( weaponOwner, ePassives.PAS_PAS_UPGRADE_TWO ) ) // upgrade_rampart_fast_reloads
				EmitSoundOnEntityExceptToPlayerWithSeek( weapon, weapon.GetOwner(), TURRET_RELOAD_RAMPART_UPGRADE_3P, seekTime )
			else

				EmitSoundOnEntityExceptToPlayerWithSeek( weapon, weapon.GetOwner(), TURRET_RELOAD_RAMPART_3P, seekTime )
		}
		else
			EmitSoundOnEntityExceptToPlayerWithSeek( weapon, weapon.GetOwner(), TURRET_RELOAD_3P, seekTime )
	#endif
}

void function OnAnimEvent_weapon_mobile_hmg( entity weapon, string eventName )
{
#if CLIENT
	if ( InPrediction() && !IsFirstTimePredicted() )
		return
#endif

	switch ( eventName )
	{
		case "rampart_turret_mobile_button_press":
			weapon.EmitWeaponSound_1p3p( TURRET_BUTTON_PRESS_SOUND_1P, TURRET_BUTTON_PRESS_SOUND_3P )
			break
		case "rampart_turret_mobile_spin_up":
			weapon.EmitWeaponSound_1p3p( TURRET_BARREL_SPIN_LOOP_1P, TURRET_BARREL_SPIN_LOOP_3P )
			break
		default:
			return
	}
}

void function OnWeaponZoomFOVToggle_weapon_mobile_hmg( entity weapon, float targetFOV )
{
	#if CLIENT
	if ( weapon.GetOwner() != GetLocalViewPlayer() )
		return

	if ( targetFOV == weapon.GetWeaponSettingFloat( eWeaponVar.zoom_fov ) ) // base zoom
	{
		EmitSoundOnEntity( weapon, TURRET_SIGHT_FLIP_DOWN_1P )
		StopSoundOnEntity( weapon, TURRET_SIGHT_FLIP_UP_1P )
	}
	else // zoom in
	{
		EmitSoundOnEntity( weapon, TURRET_SIGHT_FLIP_UP_1P )
		StopSoundOnEntity( weapon, TURRET_SIGHT_FLIP_DOWN_1P )
	}
	#endif
}

#if SERVER
void function MobileHMG_RegisterNetworkFunctions()
{
	Remote_RegisterServerFunction( "ClientCallback_ToggleMobileHMGPlacementMode" )
	Remote_RegisterServerFunction( "ClientCallback_ForceCooldown" )
}

void function MobileHMG_WeaponActiveThreadServer( entity weapon )
{
	EndSignal( weapon, MOBILE_HMG_COOLDOWN_SIGNAL )

	EndSignal( weapon, "OnDestroy" )
	entity weaponOwner = weapon.GetWeaponOwner()

	if ( !IsValid( weaponOwner ) )
		return
	EndSignal( weaponOwner, "OnDestroy" )

	entity placementWeapon = weaponOwner.GetOffhandWeapon( OFFHAND_ORDNANCE )
	if ( !IsValid( placementWeapon ) )
		return
	EndSignal( placementWeapon, "OnDestroy" )

	OnThreadEnd(
		function() : ( weapon )
		{
			if( IsValid( weapon ) )
			{
				weapon.RemoveMod( MOBILE_HMG_ACTIVE_MOD )
			}
		}
	)

	while( true )
	{
		entity activeWeapon = weaponOwner.GetActiveWeapon( eActiveInventorySlot.mainHand )
		if ( IsValid( activeWeapon ) )
		{
			if( activeWeapon != weapon && activeWeapon != placementWeapon && !activeWeapon.IsWeaponMelee() && weapon.GetWeaponPrimaryClipCount() == 0 )
				return
		}
		WaitFrame()
	}
}

void function ClientCallback_ForceCooldown( entity player )
{
	entity ultWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
	if ( !IsValid( ultWeapon ) )
		return

	entity placementWeapon = player.GetOffhandWeapon( OFFHAND_ORDNANCE )
	if ( !IsValid( placementWeapon ) )
		return

	entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )


	if( ( activeWeapon == ultWeapon && ultWeapon.GetWeaponClassName() == MOBILE_HMG_WEAPON_NAME ) ||
			activeWeapon == placementWeapon && placementWeapon.GetWeaponClassName() == MOUNTED_TURRET_PLACEABLE_WEAPON_NAME )
	{
		MobileHMG_PlacementToggleEnabled( ultWeapon, false )
		MobileHMG_DoRefund( ultWeapon )
		SwapToLastEquippedPrimary( player )
		ultWeapon.Signal( MOBILE_HMG_COOLDOWN_SIGNAL )
	}
}

void function MobileHMG_SwitchOnEmpty( entity player, entity weapon )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( weapon, "OnDestroy" )

	WaitFrame() // Wait for ammo to be set to 0

	entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( !IsValid( activeWeapon ) )
		return

	if( weapon == activeWeapon && weapon.GetWeaponPrimaryClipCount() == 0 )
		ClientCallback_ToggleMobileHMGPlacementMode( player )
}

void function MobileHMG_SetPlayerLastSaidTurretChatterTime( entity player, float time )
{
	file.playerLastSaidTurretChatterTime[player] <- time
}

void function MobileHMG_SetPlacementMode( entity weapon, bool placementMode )
{
	if( IsValid( weapon ) )
		file.placementMode[ weapon ] <- placementMode
}

void function MobileHMG_PlacementToggleEnabled( entity weapon, bool enabled )
{
	if( IsValid( weapon ) )
		file.placementToggleEnabled[ weapon ] <- enabled
}

void function MobileHMG_DoRefund( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	if( !IsValid( player ) )
		return

	int clipCount = weapon.GetWeaponPrimaryClipCount()
	int clipCountMax = weapon.GetWeaponPrimaryClipCountMax()
	int refundMax = int( float( clipCountMax ) * GetMaxRefundPercentage() )
	if( clipCount <  clipCountMax )
	{
		int newClipCount = ClampInt( clipCount, 0, refundMax )
		weapon.SetWeaponPrimaryClipCount( newClipCount )
	}
}

void function TryPlayTurretChatterLine( entity player, string line )
{
	if ( !PlayerIsEligibleToPlayTurretChatter( player ) )
		return

	PlayBattleChatterLineToSpeakerAndTeam( player, line )
	MobileHMG_SetPlayerLastSaidTurretChatterTime( player, Time() )

}

bool function PlayerIsEligibleToPlayTurretChatter( entity player )
{
	if ( !IsValid( player ) )
		return false

	if ( ! ( GetPlayerVoice( player ) == "rampart" ) )
		return false

	return !( player in file.playerLastSaidTurretChatterTime ) || ( Time() - file.playerLastSaidTurretChatterTime[player] > GLOBAL_TURRET_CHATTER_DEBOUNCE )
}

void function ClientCallback_ToggleMobileHMGPlacementMode( entity player )
{
	if ( !IsAlive( player ) )
		return

	if ( player.IsMantling() || player.IsWallRunning() || player.IsWallHanging()  )
		return

	entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( !IsValid( activeWeapon ) )
		return

	entity ultWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
	if ( !IsValid( ultWeapon ) )
		return

	if( !( ultWeapon in file.placementToggleEnabled ) || !file.placementToggleEnabled[ ultWeapon ] )
		return

	entity placementWeapon = VerifyBombardmentWeapon( player, MOUNTED_TURRET_PLACEABLE_WEAPON_NAME )
	if ( !IsValid( placementWeapon ) )
		return

	if( activeWeapon == ultWeapon && ultWeapon.GetWeaponClassName() == MOBILE_HMG_WEAPON_NAME )
	{
		MobileHMG_SetPlacementMode( activeWeapon, true )
		placementWeapon.AddMod( MOBILE_HMG_FAST_SWITCH_MOD )
		player.SetActiveWeaponByName( eActiveInventorySlot.mainHand, MOUNTED_TURRET_PLACEABLE_WEAPON_NAME )
	}
	else if( activeWeapon == placementWeapon && placementWeapon.GetWeaponClassName() == MOUNTED_TURRET_PLACEABLE_WEAPON_NAME && ultWeapon.GetWeaponPrimaryClipCount() > 0 )
	{
		if ( !IsValid( ultWeapon ) )
			return

		ultWeapon.AddMod( MOBILE_HMG_FAST_SWITCH_MOD )
		player.SetActiveWeaponByName( eActiveInventorySlot.mainHand, MOBILE_HMG_WEAPON_NAME )
	}
}
#endif

#if CLIENT
void function MobileHMG_WeaponActiveThreadClient( entity weapon )
{
	EndSignal( weapon, MOBILE_HMG_ACTIVATE_SIGNAL )
	EndSignal( weapon, "OnDestroy" )
	entity weaponOwner = weapon.GetWeaponOwner()

	if ( !IsValid( weaponOwner ) )
		return
	EndSignal( weaponOwner, "OnDestroy" )
	EndSignal( weaponOwner, "OnDeath" )

	OnThreadEnd(
		function() : ( weaponOwner )
		{
			if( IsValid( weaponOwner ) )
			{
				InitWeaponStatusRuis( weaponOwner )
			}
		}
	)

	while( !weapon.HasMod( MOBILE_HMG_ACTIVE_MOD ) )
		WaitFrame()

	while( weapon.HasMod( MOBILE_HMG_ACTIVE_MOD ) )
	{
		InitWeaponStatusRuis( weaponOwner )
		WaitFrame()
	}
}

void function OnClientAnimEvent_weapon_mobile_hmg( entity weapon, string eventName )
{
	GlobalClientEventHandler( weapon, eventName )

	OnAnimEvent_weapon_mobile_hmg( weapon, eventName )

	if ( eventName == "muzzle_flash" )
		weapon.PlayWeaponEffect( $"wpn_muzzleflash_turret_center_FP", $"", "muzzle_flash" )

	if( eventName == "rampart_turret_mobile_laser_on" )
		SetTurretVMLaserEnabled( weapon, true )
}

void function SetTurretVMLaserEnabled( entity weapon, bool enabled )
{
	entity vm = weapon.GetWeaponViewmodel()

	int fxid = GetParticleSystemIndex( TURRET_LASER_1P )

	if ( enabled )
	{
		if ( file.laserFXHandle > -1 )
			SetTurretVMLaserEnabled( weapon, false )

		file.laserFXHandle = StartParticleEffectOnEntityWithPos( vm, fxid, FX_PATTACH_POINT_FOLLOW, vm.LookupAttachment( "LASER" ), <0,0,0>, <0,0,0> )
	}
	else
	{
		if ( file.laserFXHandle > -1 )
		{
			EffectStop( file.laserFXHandle, true, true )
			file.laserFXHandle = -1
		}
	}

}

void function PlacementModeHintRuiThread( entity player, entity weapon )
{
	EndSignal( weapon, "OnDestroy" )
	EndSignal( weapon, MOBILE_HMG_KILL_UI_SIGNAL )
	EndSignal( player, "OnDestroy" )

	var hintRui = CreateCockpitRui( $"ui/mobile_hmg_hint.rpak" )
	RuiTrackBool( hintRui, "weaponIsDisabled", weapon, RUI_TRACK_WEAPON_IS_DISABLED )

	OnThreadEnd(
		function() : ( hintRui )
		{
			RuiDestroyIfAlive( hintRui )
		}
	)

	while( true )
	{
		entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
		if ( !IsValid( activeWeapon ) )
			return

		entity placementWeapon = player.GetOffhandWeapon( OFFHAND_RIGHT )

		if( activeWeapon == weapon )
			RuiSetString( hintRui, "hintText", "#WPN_MOBILE_HMG_SWITCH_TO_PLACEMENT" )
		else if( activeWeapon == placementWeapon )
			RuiSetString( hintRui, "hintText", "#WPN_MOBILE_HMG_SWITCH_TO_FIRE" )
		else
			return

		WaitFrame()
	}
}

void function PlacementModeTogglePressed( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( !IsValid( activeWeapon ) )
		return

	entity ultWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
	entity placementWeapon = player.GetOffhandWeapon( OFFHAND_RIGHT )
	if( activeWeapon == ultWeapon && ultWeapon.GetWeaponClassName() == MOBILE_HMG_WEAPON_NAME )
		Remote_ServerCallFunction( "ClientCallback_ToggleMobileHMGPlacementMode" )
	else if( activeWeapon == placementWeapon && placementWeapon.GetWeaponClassName() == MOUNTED_TURRET_PLACEABLE_WEAPON_NAME )
		Remote_ServerCallFunction( "ClientCallback_ToggleMobileHMGPlacementMode" )
}

void function ForceCooldownPressed( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( !IsValid( activeWeapon ) )
		return

	entity ultWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
	entity placementWeapon = player.GetOffhandWeapon( OFFHAND_RIGHT )
	if( activeWeapon == ultWeapon && ultWeapon.GetWeaponClassName() == MOBILE_HMG_WEAPON_NAME )
		Remote_ServerCallFunction( "ClientCallback_ForceCooldown" )
	else if( activeWeapon == placementWeapon && placementWeapon.GetWeaponClassName() == MOUNTED_TURRET_PLACEABLE_WEAPON_NAME )
		Remote_ServerCallFunction( "ClientCallback_ForceCooldown" )
}
#endif // CLIENT

float function GetMaxRefundPercentage()
{
	return GetCurrentPlaylistVarFloat( "mobile_hmg_max_refund_percentage", MAX_REFUND_PERCENTAGE )
}
