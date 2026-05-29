                          
global function MpWeaponTitanSword_Super_Init
global function TitanSword_Super_OnWeaponActivate
global function TitanSword_Super_OnWeaponDeactivate
global function TitanSword_Super_ClearMods

global function TitanSword_Super_BlockAction

#if CLIENT
global function ServerToClient_TitanSword_StartSuperFx
global function ServerToClient_TitanSword_StopSuperFx
global function ServerToClient_TitanSword_SuperReady
global function ServerToClient_TitanSword_AddChargeFx
#endif

#if SERVER
global function TitanSword_Super_AddCharge
global function ClientCallback_TitanSword_SelectFirePressed
#endif

#if DEVELOPER
#if SERVER
global function DEV_TitanSword_GiveSuper
global function DEV_TitanSword_BotTestSuper
#endif
#endif

global function TitanSword_Super_IsActive


//Names
const string TITAN_SWORD_SUPER_MOD = "super"

//Playlist Vars
const string PVAR_TITAN_SWORD_MAX_SUPER = "titan_sword_super_max"
const string PVAR_TITAN_SWORD_SUPER_WHIFF_RESET = "titan_sword_super_whiff_reset"
const string PVAR_TITAN_SWORD_SUPER_TICK = "titan_sword_super_tick"
const string PVAR_TITAN_SWORD_SUPER_PER_TICK = "titan_sword_super_per_tick"
const string PVAR_TITAN_SWORD_SUPER_DECAY = "titan_sword_super_decay"

//Signals
const string SIG_TITAN_SWORD_DESTROY_SUPER_RUI = "TitanSword_DestroySuperRui"
const string SIG_TITAN_SWORD_BEEP_THREAD = "TitanSword_BeepThread"
const string SIG_TITAN_SWORD_SUPER_STOP = "TitanSword_Super_Stop"

const string NETVAR_TITAN_SWORD_SUPER = "TitanSwordSuper"

//Vars
const array<int> TITAN_SWORD_SLOTS_TO_LOCK = [
	WEAPON_INVENTORY_SLOT_PRIMARY_0,
	WEAPON_INVENTORY_SLOT_PRIMARY_1,
	WEAPON_INVENTORY_SLOT_PRIMARY_2,
	WEAPON_INVENTORY_SLOT_PRIMARY_3,
	WEAPON_INVENTORY_SLOT_PRIMARY_4,
]

const float TITAN_SWORD_SUPER_ACTIVATION_DURATION = 2.33

//VFX
const asset VFX_TITAN_SWORD_SUPER_ACTIVATE = $"P_pilot_powerup_flash"
const asset VFX_TITAN_SWORD_SUPER_1P = $"P_pilot_powerup_FP"
const asset VFX_TITAN_SWORD_SUPER_3P = $"P_pilot_powerup_chest"
const asset VFX_TITAN_SWORD_SUPER_WEAPON_START_GLOWING_1P = $"P_pilot_sword_charging_FP" //Plays when the button is pressed
const asset VFX_TITAN_SWORD_SUPER_WEAPON_START_GLOWING_3P = $"P_pilot_sword_charging_3P" //Not sure if this was needed, or just the 1P  <- just the 1P 
const asset VFX_TITAN_SWORD_SUPER_WEAPON_ACTIVATE_1P = $"P_pilot_sword_charged_FP" //Plays when super is activated
const asset VFX_TITAN_SWORD_SUPER_WEAPON_ACTIVATE_3P = $"P_pilot_sword_charged_3P"
const asset VFX_TITAN_SWORD_SUPER_WEAPON_CONTINUOUS_1P = $"P_pilot_sword_swipe_super_FP" //Plays until super ends
const asset VFX_TITAN_SWORD_SUPER_WEAPON_CONTINUOUS_3P = $"P_pilot_sword_swipe_super_3P"

//SFX
const string SFX_TITAN_SWORD_SUPER_READY = "titansword_special_super_ready_1p"
const string SFX_TITAN_SWORD_SUPER_START_1P = "titansword_special_super_start_1p"
const string SFX_TITAN_SWORD_SUPER_START_3P = "titansword_special_super_start_3p"
const string SFX_TITAN_SWORD_SUPER_ACTIVATE_1P = "titansword_special_super_activate_1p"
const string SFX_TITAN_SWORD_SUPER_ACTIVATE_3P = "titansword_special_super_activate_3p"

//RUI
const asset RUI_TITAN_SWORD_SUPER_HUD = $"ui/weapon_hud_charged_gh.rpak"

struct
{
	#if CLIENT
		int superFxHandle
	#endif
	var superRui
}file

bool function TitanSword_Super_BlockAction( entity player, string action )
{
	//Global disable
	if ( !GetCurrentPlaylistVarBool( "titan_sword_super_allow_context_blocking", true ) )
		return false

	//Individual item disable
	if ( !GetCurrentPlaylistVarBool( "titan_sword_super_context_" + action, true ) )
		return false

	entity weapon = TitanSword_GetMainWeapon( player )

	if ( !IsValid( weapon ) )
		return false

	int activity = weapon.GetWeaponActivity()

	//Only block action if we're playing the reload anim
	if ( activity == ACT_VM_RELOADEMPTY )
		return true

	return false
}

bool function TitanSword_Super_HotfixConsumables()
{
	return GetCurrentPlaylistVarBool( "titan_sword_super_consumables", true )
}

bool function TitanSword_Super_HotfixContextActions()
{
	//I have this set to false because this is an emergency scorched earth solution to anims
	//Turn on if other things are failing
	return GetCurrentPlaylistVarBool( "titan_sword_super_context_actions", false )
}

bool function TitanSword_Super_HotfixAnimPostStart()
{
	return GetCurrentPlaylistVarBool( "titan_sword_super_anim_post_start", true )
}

void function MpWeaponTitanSword_Super_Init()
{
	PrecacheParticleSystem( VFX_TITAN_SWORD_SUPER_ACTIVATE )
	PrecacheParticleSystem( VFX_TITAN_SWORD_SUPER_1P )
	PrecacheParticleSystem( VFX_TITAN_SWORD_SUPER_3P )
	PrecacheParticleSystem( VFX_TITAN_SWORD_SUPER_WEAPON_START_GLOWING_1P )
	PrecacheParticleSystem( VFX_TITAN_SWORD_SUPER_WEAPON_START_GLOWING_3P )
	PrecacheParticleSystem( VFX_TITAN_SWORD_SUPER_WEAPON_ACTIVATE_1P )
	PrecacheParticleSystem( VFX_TITAN_SWORD_SUPER_WEAPON_ACTIVATE_3P )
	PrecacheParticleSystem( VFX_TITAN_SWORD_SUPER_WEAPON_CONTINUOUS_1P )
	PrecacheParticleSystem( VFX_TITAN_SWORD_SUPER_WEAPON_CONTINUOUS_3P )

	RegisterNetworkedVariable( NETVAR_TITAN_SWORD_SUPER, SNDC_PLAYER_EXCLUSIVE, SNVT_TIME, -2.0 )
	//Revisit
	//Remote_RegisterServerFunction( "ClientCallback_TitanSword_SelectFirePressed" )
	Remote_RegisterClientFunction( "ServerToClient_TitanSword_SuperReady", "entity" )
	Remote_RegisterClientFunction( "ServerToClient_TitanSword_StartSuperFx" )
	Remote_RegisterClientFunction( "ServerToClient_TitanSword_StopSuperFx" )
	Remote_RegisterClientFunction( "ServerToClient_TitanSword_AddChargeFx" )

	#if CLIENT
		RegisterSignal( SIG_TITAN_SWORD_DESTROY_SUPER_RUI )

		RegisterConCommandTriggeredCallback( "+scriptCommand3", OnSelectFirePressed )

		AddCallback_OnPrimaryWeaponStatusUpdate( OnPrimaryWeaponStatusUpdate_TitanSwordSuper )

		//We may not need cuz it's activated via player
		//StatusEffect_RegisterEnabledCallback( eStatusEffect.titan_sword_super, TitanSword_StartSuperVFX )
		//StatusEffect_RegisterDisabledCallback( eStatusEffect.titan_sword_super, TitanSword_StopSuperVFX )
	#endif

	#if SERVER
		RegisterSignal( SIG_TITAN_SWORD_BEEP_THREAD )
		RegisterSignal( SIG_TITAN_SWORD_SUPER_STOP )
		AddCallback_OnPlayerInventoryChanged( TitanSword_Super_OnPlayerInventoryChanged )
	#endif
}

void function TitanSword_Super_StartGlowingVFX( entity weapon )
{
	weapon.PlayWeaponEffect( VFX_TITAN_SWORD_SUPER_WEAPON_START_GLOWING_1P, VFX_TITAN_SWORD_SUPER_WEAPON_START_GLOWING_3P, "blade_mid" )
}

void function TitanSword_Super_StopGlowingVFX( entity weapon )
{
	weapon.StopWeaponEffect( VFX_TITAN_SWORD_SUPER_WEAPON_START_GLOWING_1P, VFX_TITAN_SWORD_SUPER_WEAPON_START_GLOWING_3P )
}

void function TitanSword_Super_StartActivationVFX( entity weapon )
{
	weapon.PlayWeaponEffect( VFX_TITAN_SWORD_SUPER_WEAPON_ACTIVATE_1P, VFX_TITAN_SWORD_SUPER_WEAPON_ACTIVATE_3P, "blade_mid" )
}

void function TitanSword_Super_StopActivationVFX( entity weapon )
{
	weapon.StopWeaponEffect( VFX_TITAN_SWORD_SUPER_WEAPON_ACTIVATE_1P, VFX_TITAN_SWORD_SUPER_WEAPON_ACTIVATE_3P )
}

//Continuous VFX loops for the duration of the sword
void function TitanSword_Super_StartContinuousVFX( entity weapon )
{
	//We may need to do NoCull on this one
	weapon.PlayWeaponEffect( VFX_TITAN_SWORD_SUPER_WEAPON_CONTINUOUS_1P, VFX_TITAN_SWORD_SUPER_WEAPON_CONTINUOUS_3P, "blade_mid", true )
}

void function TitanSword_Super_StopContinuousVFX( entity weapon )
{
	weapon.StopWeaponEffect( VFX_TITAN_SWORD_SUPER_WEAPON_CONTINUOUS_1P, VFX_TITAN_SWORD_SUPER_WEAPON_CONTINUOUS_3P )
}

void function TitanSword_Super_OnWeaponActivate( entity player, entity weapon )
{
	#if CLIENT
		thread TitanSword_SuperRui_Thread( weapon, player )
	#endif

	#if CLIENT
		if ( !InPrediction() )
			return
	#endif

	if ( TitanSword_Super_IsActive( player ) )
	{
		TitanSword_Super_StartContinuousVFX( weapon )
		if ( !weapon.HasMod( TITAN_SWORD_SUPER_MOD ) )
		{
			weapon.AddMod( TITAN_SWORD_SUPER_MOD )
		}
	}
	else
	{
		//Playlist just in case anything goes wrong... R5DEV-554107, R5DEV-554757
		if ( GetCurrentPlaylistVarBool( "titan_sword_super_activate_hotfix", true ) )
		{
			if ( weapon.HasMod( TITAN_SWORD_SUPER_MOD ) )
			{
				weapon.RemoveMod( TITAN_SWORD_SUPER_MOD )
			}
		}
		else
		{
			if ( !weapon.HasMod( TITAN_SWORD_SUPER_MOD ) )
			{
				weapon.RemoveMod( TITAN_SWORD_SUPER_MOD )
			}
		}
	}

	#if SERVER
		if ( GetCurrentPlaylistVarBool( "titan_sword_super_thread_hotfix", true ) )
		{
			thread SuperFix_Thread( player, weapon )
		}

		TitanSword_RemoveModOnDrop( weapon, TITAN_SWORD_SUPER_MOD )
	#endif
}

#if SERVER
//This is a dumb check for the super R5DEV-554107, R5DEV-554757
void function SuperFix_Thread( entity player, entity weapon )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( SIG_TITAN_SWORD_SUPER_STOP )
	player.EndSignal( "BleedOut_OnStartDying" )
	weapon.EndSignal( "OnDestroy" )

	float time = Time() + 0.5

	//The issue here is a race condition between the status effect and the weapon equipping
	//If we pick up a new sword to replace our sword and we still have super, it won't remove
	//super before it is applied to the new sword (but the super lifetime thread has already been destroyed)
	while( Time() < time && IsValid( weapon ) && IsValid( player ) )
	{
		if ( !TitanSword_Super_IsActive( player ) )
		{
			if ( weapon.HasMod( TITAN_SWORD_SUPER_MOD ) )
			{
				weapon.RemoveMod( TITAN_SWORD_SUPER_MOD )
				break
			}
		}
		WaitFrame()
	}
}
#endif

void function TitanSword_Super_OnWeaponDeactivate( entity player, entity weapon )
{
	TitanSword_Super_StopGlowingVFX( weapon )
	TitanSword_Super_StopActivationVFX( weapon )
	TitanSword_Super_StopContinuousVFX( weapon )
}

void function TitanSword_Super_ClearMods( entity weapon )
{
}

float function TitanSword_Super_GetCharge( entity player )
{
	return player.GetPlayerNetTime( NETVAR_TITAN_SWORD_SUPER )
}

bool function TitanSword_Super_HasCharge( entity player )
{
	return Time() >= TitanSword_Super_GetCharge( player )
}

bool function TitanSword_Super_ChargingStopped( entity player )
{
	return player.GetPlayerNetTime( NETVAR_TITAN_SWORD_SUPER ) <= -1.0
}

bool function TitanSword_Super_IsFirstPickup( entity player )
{
	return player.GetPlayerNetTime( NETVAR_TITAN_SWORD_SUPER ) <= -2.0
}

#if SERVER
void function TitanSword_Super_OnPlayerInventoryChanged( entity player )
{
	bool exists = false
	foreach ( entity weapon in player.GetMainWeapons() )
	{
		if ( TitanSword_WeaponIsTitanSword( weapon ) )
		{
			exists = true
			break
		}
	}

	if ( exists )
	{
		//If it's the first time we've equipped a titan sword, start the timer
		if ( TitanSword_Super_IsFirstPickup( player ) )
			TitanSword_Super_ResetCharge( player )
	}
	else
	{
		//Is this too harsh? They drop the swords and lose their super?
		TitanSword_Super_DropCharge( player )
	}
}

void function TitanSword_Super_TryInitCharge( entity player )
{
	TitanSword_Super_ResetCharge( player )
}

void function TitanSword_Super_FillCharge( entity player )
{
	player.SetPlayerNetTime( NETVAR_TITAN_SWORD_SUPER, Time() )
}

void function TitanSword_Super_ResetCharge( entity player )
{
	player.SetPlayerNetTime( NETVAR_TITAN_SWORD_SUPER, Time() + GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "super_cooldown_sec" ) )
	thread TitanSword_Super_UpdateCharge_Thread( player )
}

void function TitanSword_Super_StopCharge( entity player )
{
	player.SetPlayerNetTime( NETVAR_TITAN_SWORD_SUPER, -1.0 )
}

void function TitanSword_Super_DropCharge( entity player )
{
	player.SetPlayerNetTime( NETVAR_TITAN_SWORD_SUPER, -2.0 )
	TitanSword_Super_UpdateWeaponChargeFx( player, 0.3 )
}

void function TitanSword_Super_AddCharge( entity player, int amount )
{
	if ( TitanSword_Super_IsActive( player ) )
		return

	if ( TitanSword_Super_ChargingStopped( player ) )
		return

	if ( TitanSword_Super_HasCharge( player ) )
		return

	float conversion = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "super_cooldown_sec" ) / GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "super_max" )
	float timeCost   = amount * conversion
	float prevTime   = TitanSword_Super_GetCharge( player )

	float newTime = prevTime - timeCost

	player.SetPlayerNetTime( NETVAR_TITAN_SWORD_SUPER, newTime )

	if ( TitanSword_Super_HasCharge( player ) )
	{
		EmitSoundOnEntityOnlyToPlayer( player, player, SFX_TITAN_SWORD_SUPER_READY )
		Remote_CallFunction_Replay( player, "ServerToClient_TitanSword_SuperReady", player )
	}
	Remote_CallFunction_Replay( player, "ServerToClient_TitanSword_AddChargeFx" )

	TitanSword_Super_UpdateWeaponChargeFx( player, 0.3 )
}

void function TitanSword_Super_UpdateCharge_Thread( entity player )
{
	//Only have one of these threads running
	player.Signal( SIG_TITAN_SWORD_BEEP_THREAD )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( SIG_TITAN_SWORD_BEEP_THREAD )

	float prevFrac    = TitanSword_Super_GetChargeScale( player )
	float currentFrac = prevFrac

	float updateSec = GetCurrentPlaylistVarFloat( "titan_sword_super_update_sec", 5.0 )

	float nextUpdate = Time() + updateSec

	while ( IsValid( player ) && !TitanSword_Super_HasCharge( player ) && !TitanSword_Super_ChargingStopped( player ) )
	{
		if ( Time() >= nextUpdate )
		{
			TitanSword_Super_UpdateWeaponChargeFx( player, 0.3 )
			nextUpdate = Time() + updateSec
		}

		WaitFrame()
	}

	if ( IsValid( player ) && !TitanSword_Super_ChargingStopped( player ) )
	{
		EmitSoundOnEntityOnlyToPlayer( player, player, SFX_TITAN_SWORD_SUPER_READY )
		Remote_CallFunction_Replay( player, "ServerToClient_TitanSword_SuperReady", player )
		TitanSword_Super_UpdateWeaponChargeFx( player, 0.35 )
	}
}

void function TitanSword_Super_UpdateWeaponChargeFx( entity player, float scale )
{
	entity weapon = TitanSword_GetMainWeapon( player )
	if ( IsValid( weapon ) )
	{
		weapon.SetWeaponChargeFractionForced( TitanSword_Super_GetChargeScale( player ) * scale )
	}
}
#endif

float function TitanSword_Super_GetChargeScale( entity player )
{
	if ( TitanSword_Super_IsActive( player ) )
	{
		float active = StatusEffect_GetTimeRemaining( player, eStatusEffect.titan_sword_super )
		float diff   = active / GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "super_active_sec" )
		return clamp( diff, 0.0, 1.0 )
	}

	if ( TitanSword_Super_ChargingStopped( player ) )
		return 0.0

	if ( TitanSword_Super_HasCharge( player ) )
		return 1.0

	float charge = TitanSword_Super_GetCharge( player ) - Time()
	//	float diff = charge / GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "fuel_cooldown_sec" )
	float diff   = charge / GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "super_cooldown_sec" )

	return clamp( 1.0 - diff, 0.0, 1.0 )
}

bool function TitanSword_Super_IsActive( entity player )
{
	return StatusEffect_HasSeverity( player, eStatusEffect.titan_sword_super )
}

#if SERVER
void function ClientCallback_TitanSword_SelectFirePressed( entity player )
{
	if ( TryActivateSuper( player ) )
		thread TitanSword_ActivateSuper_Thread( player )
}

void function TitanSword_ActivateSuper_Thread( entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( SIG_TITAN_SWORD_SUPER_STOP )
	player.EndSignal( "BleedOut_OnStartDying" )

	entity weapon = TitanSword_GetMainWeapon( player )

	if ( !IsValid( weapon ) )
		return

	weapon.EndSignal( "OnDestroy" )

	if ( !weapon.HasMod( TITAN_SWORD_SUPER_MOD ) )
		weapon.AddMod( TITAN_SWORD_SUPER_MOD )

	TitanSword_FillFuel( player )

	float activeTime  = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "super_active_sec" )
	float startupTime = TITAN_SWORD_SUPER_ACTIVATION_DURATION//weapon.GetWeaponSettingFloat( eWeaponVar.reloadempty_time )

	StatusEffect_AddTimed( player, eStatusEffect.titan_sword_super, 1.0, startupTime + activeTime, 0.0 )
	TitanSword_Super_StopCharge( player )

	if ( !TitanSword_Super_HotfixAnimPostStart() )
	{
		//Preserving original location behind playlist var
		weapon.StartCustomActivityDetailed( "ACT_VM_RELOADEMPTY", WCAF_DISABLEWEAPON, startupTime, player.IsCrouched() ? "ACT_MP_RELOAD_CROUCH" : "ACT_MP_RELOAD_STAND" )
	}

	Embark_Disallow( player )
	DisableMantle( player )
	LockWeaponsAndMelee( player, "sword_super" )
	if ( TitanSword_Super_HotfixConsumables() )
	{
		//Stop weapons from being used
		HolsterAndDisableWeapons( player )
		//Except our main weapon so we see the anim
		player.DeployWeapon()
	}

	if ( TitanSword_Super_HotfixContextActions() )
	{
		player.ContextAction_SetBusy()
	}

	if ( TitanSword_Super_HotfixAnimPostStart() )
	{
		//We want the anim to play after we lock everything (order of operations)
		weapon.StartCustomActivityDetailed( "ACT_VM_RELOADEMPTY", WCAF_DISABLEWEAPON, startupTime, player.IsCrouched() ? "ACT_MP_RELOAD_CROUCH" : "ACT_MP_RELOAD_STAND" )
	}

	StatusEffect_AddTimed( player, eStatusEffect.disable_wall_run, 1.0, startupTime, 0.0 )
	StatusEffect_AddTimed( player, eStatusEffect.disable_double_jump, 1.0, startupTime, 0.0 )

	EmitSoundOnEntityOnlyToPlayer( player, player, SFX_TITAN_SWORD_SUPER_START_1P )
	EmitSoundOnEntityExceptToPlayer( player, player, SFX_TITAN_SWORD_SUPER_START_3P )

	entity activateFx = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( VFX_TITAN_SWORD_SUPER_ACTIVATE ), FX_PATTACH_ABSORIGIN_FOLLOW, player.LookupAttachment( "CHESTFOCUS" ) )
	entity bodyFx     = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( VFX_TITAN_SWORD_SUPER_3P ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "CHESTFOCUS" ) )

	TitanSword_Super_StartActivationVFX( weapon )
	TitanSword_Super_StartContinuousVFX( weapon )

	bodyFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
	//bodyFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE // TEST FOR VFX - ship should be ^^ above entry


	bodyFx.SetOwner( player )

	PassByReferenceBool finishedAnim
	finishedAnim.value = false

	TitanSword_Super_StartGlowingVFX( weapon )

	OnThreadEnd(
		function() : ( player, weapon, activateFx, bodyFx, finishedAnim )
		{
			if ( IsValid( player ) )
			{
				StatusEffect_StopAllOfType( player, eStatusEffect.titan_sword_super )
				Remote_CallFunction_Replay( player, "ServerToClient_TitanSword_StopSuperFx" )
				TitanSword_Super_ResetCharge( player )

				StopSoundOnEntity( player, SFX_TITAN_SWORD_SUPER_START_1P )
				StopSoundOnEntity( player, SFX_TITAN_SWORD_SUPER_START_3P )
				StopSoundOnEntity( player, SFX_TITAN_SWORD_SUPER_ACTIVATE_1P )
				StopSoundOnEntity( player, SFX_TITAN_SWORD_SUPER_ACTIVATE_3P )
				//player.UnsetSoundCodeControllerValue()
				//Go back to charging super

				#if SERVER
					if ( !finishedAnim.value )
					{
						Embark_Allow( player )
						EnableMantle( player )
						UnlockWeaponsAndMelee( player, "sword_super" )
						if ( TitanSword_Super_HotfixConsumables() )
						{
							DeployAndEnableWeapons( player )
						}

						if ( TitanSword_Super_HotfixContextActions() )
						{
							player.ContextAction_ClearBusy()
						}
					}
					else
					{
						foreach ( int slot in TITAN_SWORD_SLOTS_TO_LOCK )
						{
							//player.UnlockWeaponInventorySlot( slot )
						}
					}
				#endif
			}

			if ( IsValid( weapon ) )
			{
				if ( weapon.HasMod( TITAN_SWORD_SUPER_MOD ) )
					weapon.RemoveMod( TITAN_SWORD_SUPER_MOD )
				TitanSword_Super_StopGlowingVFX( weapon )
				TitanSword_Super_StopActivationVFX( weapon )
				TitanSword_Super_StopContinuousVFX( weapon )
				weapon.SetWeaponChargeFractionForced( 0.0 )
			}

			if ( IsValid( activateFx ) )
				EffectStop( activateFx )

			if ( IsValid( bodyFx ) )
				EffectStop( bodyFx )
		}
	)

	wait startupTime

	//Some Extra placeholder stuff - ideally the sound just matches the anim
	EmitSoundOnEntityOnlyToPlayer( player, player, SFX_TITAN_SWORD_SUPER_ACTIVATE_1P )
	EmitSoundOnEntityExceptToPlayer( player, player, SFX_TITAN_SWORD_SUPER_ACTIVATE_3P )
	//entity shake = CreateAirShake( player.GetOrigin(), 12, 400, 0.75, 200 )
	//CopyRealmsFromTo( player, shake )

	#if SERVER
		Embark_Allow( player )
		EnableMantle( player )
		UnlockWeaponsAndMelee( player, "sword_super" )
		if ( TitanSword_Super_HotfixConsumables() )
		{
			DeployAndEnableWeapons( player )
		}

		if ( TitanSword_Super_HotfixContextActions() )
		{
			player.ContextAction_ClearBusy()
		}
	#endif //SERVER
	finishedAnim.value = true //we can write this in a way where we kick off a different thread so we dont have to pass by ref

	//Now we lock individual stuff
	int activeWeaponSlot = SURVIVAL_GetActiveWeaponSlot( player )
	foreach ( int slot in TITAN_SWORD_SLOTS_TO_LOCK )
	{
		if ( activeWeaponSlot == slot )
			continue

		//player.LockWeaponInventorySlot( slot )
	}

	//entity burstFx = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( VFX_TITAN_SWORD_SUPER_ACTIVATE ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )

	//if ( weapon.IsInCustomActivity() && weapon.GetCurrentCustomActivity() == ACT_VM_SPRINT )
	//	weapon.StopCustomActivity()

	Remote_CallFunction_Replay( player, "ServerToClient_TitanSword_StartSuperFx" )

	TitanSword_Super_StopGlowingVFX( weapon )
	TitanSword_Super_StartActivationVFX( weapon )
	TitanSword_Super_StartContinuousVFX( weapon )

	//TODO: Ask Jello if there's a way to get this FOV effect without the rest of the stim stuff
	//StatusEffect_AddTimed( player, eStatusEffect.stim_visual_effect, 1.0, 30, 30 )

	float waitTime = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "super_active_sec" )

	weapon.SetWeaponChargeFractionForced( TitanSword_Super_GetChargeScale( player ) )
	//player.SetSoundCodeControllerValue( 1.0 )
	/*while( Time() < waitTime )
	{
		printt( "CHARGE FRAC: " + TitanSword_Super_GetChargeScale( player ) )
		weapon.SetWeaponChargeFractionForced( TitanSword_Super_GetChargeScale( player ) )
		WaitFrame()
	}*/
	wait waitTime
}
#endif

#if CLIENT
void function OnSelectFirePressed( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	if ( !TryActivateSuper( player ) )
		return

	Remote_ServerCallFunction( "ClientCallback_TitanSword_SelectFirePressed" )

	const int randomHints = 1
	int hintSelection = RandomIntRange( 0, randomHints )

	entity activeWeapon = TitanSword_GetMainWeapon( player )
	if ( IsValid( activeWeapon ) )
		TitanSword_Super_StartGlowingVFX( activeWeapon )

	string hintBase = "#WPN_TITAN_SWORD_SUPER_ACTIVATED_BASE"
	string hintStr  = "#WPN_TITAN_SWORD_SUPER_ACTIVATED_" + hintSelection
	//TitanSword_DisplayHint( player, Localize( hintBase ) + Localize( hintStr ) )
	AnnouncementMessageRight( player, Localize( hintBase ) + Localize( hintStr ), "", <1, 1, 0>, $"", 5.0 )
}

void function ServerToClient_TitanSword_StartSuperFx()
{
	entity player = GetLocalViewPlayer()

	entity cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	Assert( !EffectDoesExist( file.superFxHandle ), "tried to start a second screen fx" )

	int fxID = GetParticleSystemIndex( VFX_TITAN_SWORD_SUPER_1P )
	file.superFxHandle = StartParticleEffectOnEntity( cockpit, fxID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	EffectSetIsWithCockpit( file.superFxHandle, true )
	entity weapon = TitanSword_GetMainWeapon ( player )
	if ( IsValid( weapon ) )
	{
		TitanSword_Super_StopGlowingVFX( weapon )
		TitanSword_Super_StartActivationVFX( weapon )
		TitanSword_Super_StartContinuousVFX( weapon )
	}
	//player.SetFOVScale( 2, 0.25 ) //This doesn't do anything?
}


void function ServerToClient_TitanSword_StopSuperFx()
{
	if ( !EffectDoesExist( file.superFxHandle ) )
		return

	EffectStop( file.superFxHandle, false, true )

	entity player = GetLocalViewPlayer()

	entity weapon = TitanSword_GetMainWeapon ( player )
	if ( IsValid( weapon ) )
	{
		TitanSword_Super_StopGlowingVFX( weapon )
		TitanSword_Super_StopActivationVFX( weapon )
		TitanSword_Super_StopContinuousVFX( weapon )
	}
	//player.SetFOVScale( 1.0, 0.25 )
}

void function ServerToClient_TitanSword_SuperReady( entity player )
{
	printt( "SUPER READY: " + player + " :: " + GetLocalViewPlayer() )
	if ( player != GetLocalViewPlayer() )
		return

	AddOnscreenPromptFunction( "quickchat", CreateQuickchatFunction( eCommsAction.QUICKCHAT_TITAN_SWORD_READY_FULL, player ), 8.0, Localize( "#WPN_TITAN_SWORD_SUPER_READY_COMMS" ) )
	//Quickchat( eCommsAction.QUICKCHAT_TITAN_SWORD_READY_FULL, null )
}
void function ServerToClient_TitanSword_AddChargeFx()
{
	if ( file.superRui != null )
		RuiSetGameTime( file.superRui, "flashStartTime", Time() )
}
#endif

bool function TryActivateSuper( entity player )
{
	if ( TitanSword_Super_IsActive( player ) )
		return false

	if ( !TitanSword_Super_HasCharge( player ) )
		return false

	if ( player.IsMantling() || player.IsWallRunning() || player.IsWallHanging() )
		return false

	//This is a common use check for first or third person animations among other things (ziplines, etc)
	if ( TitanSword_PostCopySanityCheck( "super_try_anim" ) )
	{
		if ( IsPlayerBusyOrAnimating( player ) )
			return false

		//Allow players to activate on a zip
		if ( !PlayerInValidState( player, TitanSword_PostCopySanityCheck( "super_zip_activate" ) ) )
			return false
	}

	entity activeWeapon = TitanSword_GetMainWeapon( player )
	if ( !IsValid( activeWeapon ) )
		return false

	if ( !activeWeapon.IsReadyToFire() )
		return false

	if ( activeWeapon.HasMod( TITAN_SWORD_SUPER_MOD ) )
		return false

	return true
}

#if CLIENT

void function OnPrimaryWeaponStatusUpdate_TitanSwordSuper( entity selectedWeapon, var weaponRui )
{
	if ( !IsValid( selectedWeapon ) )
		return

	// send signal here to make sure it happens right after we switch to another weapon
	entity activeWeapon         = GetLocalViewPlayer().GetActiveWeapon( eActiveInventorySlot.mainHand )
	bool switchToMeleeOrGrenade = IsBitFlagSet( selectedWeapon.GetWeaponTypeFlags(), (WPT_VIEWHANDS | WPT_GRENADE) )
	if ( IsValid( activeWeapon ) && activeWeapon != selectedWeapon )
	{
		if ( !(TitanSword_WeaponIsTitanSword( activeWeapon ) && switchToMeleeOrGrenade) )
			activeWeapon.Signal( SIG_TITAN_SWORD_DESTROY_SUPER_RUI )
	}

	if ( TitanSword_WeaponIsTitanSword( selectedWeapon ) )
	{
		entity player = selectedWeapon.GetWeaponOwner()
		thread TitanSword_SuperRui_Thread( selectedWeapon, player )
	}
}

void function TitanSword_SuperRui_Thread( entity weapon, entity player )
{
	AssertIsNewThread()

	if ( !IsValid( player ) )
		return

	if ( !IsLocalViewPlayer( player ) )
		return

	//If it's not my main weapon i don't care
	if ( weapon != player.GetActiveWeapon( eActiveInventorySlot.mainHand ) )
		return

	weapon.Signal( SIG_TITAN_SWORD_DESTROY_SUPER_RUI )
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( SIG_TITAN_SWORD_DESTROY_SUPER_RUI )
	weapon.EndSignal( SIG_TITAN_SWORD_DEACTIVATE )

	player.Signal( WEAPON_CHARGED_RUI_ABORT_SIGNAL )
	player.EndSignal( WEAPON_CHARGED_RUI_ABORT_SIGNAL )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	string weaponName = weapon.GetWeaponClassName()
	var rui           = ClWeaponStatus_GetWeaponHudRui( player )

	if ( rui == null )
		return

	RuiDestroyNestedIfAlive( rui, "chargedHandle" )

	var nestedRui = RuiCreateNested( rui, "chargedHandle", RUI_TITAN_SWORD_SUPER_HUD )
	if ( nestedRui == null )
		return

	file.superRui = nestedRui
	OnThreadEnd(
		function() : ( player, weapon, rui, nestedRui )
		{
			RuiSetBool( rui, "showChargeBar", false )
			RuiSetBool( rui, "showChargeBarBorderColor", false )
			RuiDestroyNestedIfAlive( rui, "chargedHandle" )
			file.superRui = null
		}
	)

	vector frameColorBase    = SrgbToLinear( GetAmmoColorByType( "supply_drop" ) ) //SrgbToLinear( <45, 117, 233> / 255.0 ) //SrgbToLinear( <6, 139, 70> / 255.0 )
	vector frameColorCharged = SrgbToLinear( <247, 226, 70> / 255.0 )

	RuiSetFloat3( nestedRui, "frameColor", frameColorBase )
	RuiSetString( nestedRui, "chargeBarText", "" )
	RuiSetBool( nestedRui, "showChargeBar", true )
	RuiSetBool( rui, "showChargeBar", true )
	RuiSetBool( rui, "hasNoAmmo", true )
	RuiSetFloat3( rui, "chargeBarBorderOverlayColor", frameColorCharged )

	while( IsValid ( weapon ) && IsValid( player ) && file.superRui != null )
	{
		float superFrac       = TitanSword_Super_GetChargeScale( player )
		string chargeBarText  = ""
		bool showChargedState = true
		bool superIsActive    = TitanSword_Super_IsActive( player )

		if ( !superIsActive )
		{
			if ( superFrac >= 1.0 )
			{
				chargeBarText    = Localize( "#WPN_TITAN_SWORD_SUPER_READY" )
				showChargedState = true
			}
			else
			{
				chargeBarText = Localize( "#WPN_TITAN_SWORD_SUPER_CHARGING" )
				int chargePercent = int( floor( superFrac * 100 ) )
				chargeBarText += (" " + chargePercent + "%")
				showChargedState = false
			}
		}

		//RuiSetFloat( nestedRui, "chargeBarTimeRemaining", float(weapon.GetScriptInt0()) )
		RuiSetString( nestedRui, "chargeBarText", chargeBarText )
		RuiSetFloat( nestedRui, "chargeBarFrac", superFrac )
		RuiSetFloat3( nestedRui, "chargeBGcolor", GetSuperColor( superFrac ) )
		RuiSetFloat3( nestedRui, "frameColor", showChargedState ? frameColorCharged : frameColorBase )
		RuiSetBool( nestedRui, "superActive", superIsActive )
		RuiSetBool( rui, "showChargeBarBorderColor", showChargedState )

		WaitFrame()
	}
}


vector function GetSuperColor( float frac )
{
	if ( frac < 1.0 )
		return <255, 234, 0>

	return <255, 0, 255>
}
#endif


#if DEVELOPER
#if SERVER
void function DEV_TitanSword_GiveSuper( entity player, int amount = -1 )
{
	if ( amount == -1 )
		TitanSword_Super_FillCharge( player )
	else
		TitanSword_Super_AddCharge( player, amount )
}

void function DEV_TitanSword_BotTestSuper( entity player, float duration = -1 )
{
	thread DEV_TitanSword_BotTestSuper_Thread( player, duration )
}

void function DEV_TitanSword_BotTestSuper_Thread( entity player, float duration = -1 )
{
	ServerCommand( "bot" )

	array< entity > allPlayers = GetPlayerArray_Alive()

	entity bot = allPlayers[allPlayers.len() - 1]

	vector origin = GetPlayerCrosshairOrigin( player )
	origin += <0, 0, -32>

	bot.SetOrigin( origin )

	bot.EndSignal( "OnDeath" )
	bot.EndSignal( "OnDestroy" )

	foreach ( entity weapon in bot.GetMainWeapons() )
	{
		if ( IsValid( weapon ) )
		{
			bot.DropWeapon( weapon )
		}
	}

	bot.GiveWeapon( TITAN_SWORD_WEAPON_REF, WEAPON_INVENTORY_SLOT_PRIMARY_0 )

	float waitTime = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "super_active_sec" )

	if ( duration != -1 )
		waitTime = duration

	wait 1

	while( IsValid( bot ) )
	{
		thread TitanSword_ActivateSuper_Thread( bot )

		wait waitTime + 5

		if ( duration != -1 )
			bot.Signal( SIG_TITAN_SWORD_SUPER_STOP )
	}
}
#endif
#endif

                               
 