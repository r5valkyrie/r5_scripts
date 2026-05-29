global function Armor_ShieldRegen_IsUsingShieldRegen

global function Armor_ShieldRegen_Init
global function Armor_ShieldRegen_RegisterNetworking

#if SERVER
global function Armor_ShieldRegen_RechargePlayerShields_Thread
#endif

#if CLIENT
global function Armor_ShieldRegen_ServerCallback_RegenTriggerEvent
global function Armor_ShieldRegen_ServerCallback_RegenCancelEvent
#endif

#if DEVELOPER
const bool SHIELD_REGEN_DEBUG = false
#endif // DEV

const float DEFAULT_SHIELD_REGEN_DELAY_TIME = 8.0 // how long after damage before shields being to recharge
const float DEFAULT_SHIELD_REGEN_BREAK_DELAY_TIME = 16.0 // how long after damage before shields being to recharge when broken
const float SHIELD_REGEN_PREEMPTIVE_TIME = 0.25

#if SERVER
const float DEFAULT_SHIELD_REGEN_RATE_PER_SECOND = 12.0 // how many points of shields regen per second
#endif

// ===   AUDIO   ===
#if SERVER
// regen start 1p
const string RECHARGING_START_SOUND = "CampFire_Healing_Start_1P" //"shield_battery_charge"
// regen loop 1p
const string RECHARGING_SHIELDS_SOUND = "CampFire_Healing_Loop_1P" //"shield_battery_charge"
// regen complete 1p
const string RECHARGING_COMPLETE_SOUND = "CampFire_Healing_End_1P" //"Shield_Battery_Holster_LTM_TEST_1P"

// regen start 3p
const string RECHARGING_START_SOUND_3P = "CampFire_Healing_Start_3P" //"Shield_Battery_Charge_LTM_TEST_3P"
// regen loop 3p
const string RECHARGING_SHIELDS_SOUND_3P = "CampFire_Healing_Loop_3P" //"Shield_Battery_Charge_LTM_TEST_3P"
// regen complete 3p
const string RECHARGING_COMPLETE_SOUND_3P = "CampFire_Healing_End_3P" //"Shield_Battery_Holster_LTM_TEST_3P"
#endif
// === END AUDIO ===

// ===   VFX   ===
#if SERVER
// regen start / loop p3
const asset FX_RECHARGING_SHIELDS_3P = $"P_armor_3P_loop_CP" // taken from Wattson's Trophy
// regen complete p3
// todo (dswieczko): currently existing logic triggers the EVO armor upgrade vfx we may want something else
#endif
// === END VFX ===

struct
{
	var armorShieldRegenRui
	float shieldRegenDelayTime
	float shieldRegenBreakDelayTime
	#if SERVER
		float shieldRegenRatePerSec
	#endif
} file

void function Armor_ShieldRegen_Init()
{
	#if DEVELOPER
		if ( SHIELD_REGEN_DEBUG )
		{
			printf("Armor_ShieldRegen_Init()")
		}
	#endif

	if ( !Armor_ShieldRegen_IsUsingShieldRegen() )
	{
		#if DEVELOPER
			if ( SHIELD_REGEN_DEBUG )
			{
				printf("Armor_ShieldRegen_Init: Shield Regen disabled. See playlist vars!")
			}
		#endif
		return
	}

	#if SERVER
		AddCallback_OnClientConnected( Armor_ShieldRegen_OnClientConnected )
		AddCallback_OnClientConnectionRestored( Armor_ShieldRegen_OnPlayerReconnected )
		AddCallback_OnClientConnectionLost( Armor_ShieldRegen_OnClientDisconnected )
		Bleedout_AddCallback_OnPlayerStopBleedout( Armor_ShieldRegen_OnPlayerRevived )
		Loot_AddCallback_OnPlayerLootPickup( Armor_ShieldRegen_OnPlayerLootPickup )
		file.shieldRegenRatePerSec = GetCurrentPlaylistVarFloat( "shield_regen_rate_per_sec", DEFAULT_SHIELD_REGEN_RATE_PER_SECOND )
	#endif

	RegisterSignal( "Armor_ShieldRegen_OnDamaged" )
	RegisterSignal( "Armor_ShieldRegen_OnDisconnect" )
	file.shieldRegenDelayTime = GetCurrentPlaylistVarFloat( "shield_regen_delay_time", DEFAULT_SHIELD_REGEN_DELAY_TIME )
	file.shieldRegenBreakDelayTime = GetCurrentPlaylistVarFloat( "shield_regen_break_delay_time", DEFAULT_SHIELD_REGEN_BREAK_DELAY_TIME )
	#if CLIENT
		AddCallback_OnPlayerDisconnected( Armor_ShieldRegen_OnPlayerDisconnected )
		AddCallback_LocalClientPlayerSpawned( Armor_ShieldRegen_OnPlayerSpawned )
		AddCallback_GameStateEnter( eGameState.Postmatch, Armor_ShieldRegen_OnGameState_Ending )
	#endif
}

void function Armor_ShieldRegen_RegisterNetworking()
{
	if ( !Armor_ShieldRegen_IsUsingShieldRegen() )
		return

	Remote_RegisterClientFunction( "Armor_ShieldRegen_ServerCallback_RegenTriggerEvent", "bool" )
	Remote_RegisterClientFunction( "Armor_ShieldRegen_ServerCallback_RegenCancelEvent" )
}

#if SERVER
void function Armor_ShieldRegen_OnClientConnected( entity player )
{
	#if DEVELOPER
		if ( SHIELD_REGEN_DEBUG )
			printf("Armor_ShieldRegen_OnClientConnected()")
	#endif

	if ( !IsValid( player ) )
		return

	if ( !player.e.entPostDamageCallbacks.contains( Armor_ShieldRegen_OnPlayerDamaged ) )
		AddEntityCallback_OnPostDamaged( player, Armor_ShieldRegen_OnPlayerDamaged )
}

void function Armor_ShieldRegen_OnClientDisconnected( entity player )
{
	#if DEVELOPER
		if ( SHIELD_REGEN_DEBUG )
			printf("Armor_ShieldRegen_OnClientDisconnected()")
	#endif

	player.Signal( "Armor_ShieldRegen_OnDisconnect" )

	if ( player.e.entDamageCallbacks.contains( Armor_ShieldRegen_OnPlayerDamaged ) )
		RemoveEntityCallback_OnPostDamaged( player, Armor_ShieldRegen_OnPlayerDamaged )
}

void function Armor_ShieldRegen_OnPlayerDamaged( entity player, var damageInfo )
{
	#if DEVELOPER
		if ( SHIELD_REGEN_DEBUG )
			printf("Armor_ShieldRegen_OnPlayerDamaged()")
	#endif

	// don't start regen when (A) damaged by direct health damage and full shields or, (B) no shields equip or, (C) a player is downed or dead
	if ( ( player.GetShieldHealth() == player.GetShieldHealthMax() && IsBitFlagSet( DamageInfo_GetCustomDamageType( damageInfo ), DF_BYPASS_SHIELD ) ) )
	{
		#if DEVELOPER
			if ( SHIELD_REGEN_DEBUG )
				printf( "Armor_ShieldRegen_OnPlayerDamaged: Health damage. Sheilds full, returning." )
		#endif
		return
	}

	if ( player.GetShieldHealthMax() == 0 )
	{
		#if DEVELOPER
			if ( SHIELD_REGEN_DEBUG )
				printf( "Armor_ShieldRegen_OnPlayerDamaged: Player has no shields, returning." )
		#endif
		return
	}

	if ( !IsAlive( player ) || Bleedout_IsBleedingOut( player ) )
	{
		#if DEVELOPER
			if ( SHIELD_REGEN_DEBUG )
				printf( "Armor_ShieldRegen_OnPlayerDamaged: Player has no shields, returning." )
		#endif
		return
	}

	thread Armor_ShieldRegen_RechargePlayerShields_Thread( player, false )
}

void function Armor_ShieldRegen_OnPlayerRevived( entity player )
{
	#if DEVELOPER
		if ( SHIELD_REGEN_DEBUG )
			printf("Armor_ShieldRegen_OnPlayerRevived()")
	#endif

	thread Armor_ShieldRegen_RechargePlayerShields_Thread( player, true )
}

void function Armor_ShieldRegen_RechargePlayerShields_Thread( entity player, bool skipDelay )
{
	#if DEVELOPER
		if ( SHIELD_REGEN_DEBUG )
			printf("Armor_ShieldRegen_RechargePlayerShields()")
	#endif

	player.Signal( "Armor_ShieldRegen_OnDamaged" )

	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "BleedOut_OnStartDying" )
	player.EndSignal( "Armor_ShieldRegen_OnDamaged" )
	player.EndSignal( "Armor_ShieldRegen_OnDisconnect" )

	Remote_CallFunction_NonReplay( player, "Armor_ShieldRegen_ServerCallback_RegenTriggerEvent", skipDelay )

	OnThreadEnd( function() : ( player ) {
		#if DEVELOPER
			if ( SHIELD_REGEN_DEBUG )
				printf("Armor_ShieldRegen_RechargePlayerShields: Thread End")
		#endif

		Remote_CallFunction_NonReplay( player, "Armor_ShieldRegen_ServerCallback_RegenCancelEvent" )
	} )

	WaitFrame() // need this for the player's shield value to actually update

	if ( !skipDelay )
	{
		float regenDelay = file.shieldRegenDelayTime

		if ( player.GetShieldHealth() == 0 )
		{
			regenDelay = file.shieldRegenBreakDelayTime
		}

		float lastframe = Time()
		while ( Time() < ( lastframe + regenDelay ) )
		{
			if ( player.GetShieldHealth() == player.GetShieldHealthMax() )
				break

			WaitFrame()
		}
	}

	                       
		while ( StatusEffect_HasSeverity( player, eStatusEffect.healing_denied ) )
		{
			#if DEVELOPER
				if ( SHIELD_REGEN_DEBUG )
					printf( "healing_denied" + StatusEffect_GetSeverity( player, eStatusEffect.healing_denied ) + ", waiting...")
			#endif
			WaitFrame()
		}
       

	if ( player.GetShieldHealth() != player.GetShieldHealthMax() )
	{
		RecoveryHealingFXRequest healingRequest = Player3pHealFXAddRequest( player, eHealingRequestType.ShieldRegen )
		healingRequest.requestShieldFX = true

		OnThreadEnd( function() : ( healingRequest, player ) {
			#if DEVELOPER
				if ( SHIELD_REGEN_DEBUG )
					printf("Armor_ShieldRegen_RechargePlayerShields: Thread End")
			#endif

			Remote_CallFunction_NonReplay( player, "Armor_ShieldRegen_ServerCallback_RegenCancelEvent" )

			Player3pHealFXRemoveRequest( player, healingRequest )

			StopSoundOnEntity( player, RECHARGING_SHIELDS_SOUND )
			StopSoundOnEntity( player, RECHARGING_SHIELDS_SOUND_3P )
		} )

		EmitSoundOnEntityExceptToPlayer( player, player, RECHARGING_START_SOUND_3P )
		EmitSoundOnEntityOnlyToPlayer( player, player, RECHARGING_START_SOUND )

		EmitSoundOnEntityExceptToPlayer( player, player, RECHARGING_SHIELDS_SOUND_3P )
		EmitSoundOnEntityOnlyToPlayer( player, player, RECHARGING_SHIELDS_SOUND )

		float lastframe = Time()
		while ( player.GetShieldHealth() != player.GetShieldHealthMax() )
		{
			float elapsedTime = Time() - lastframe
			lastframe = Time()
			float newShieldHealth = min( player.GetShieldHealthMax(), player.GetShieldHealth() + ( elapsedTime * file.shieldRegenRatePerSec ) )
			float repairAmount    = newShieldHealth - player.GetShieldHealth()

			if ( repairAmount > 0 )
			{
				player.SetShieldHealth( newShieldHealth )
			}

			WaitFrame()
		}

		EmitSoundOnEntityExceptToPlayer( player, player, RECHARGING_COMPLETE_SOUND_3P )
		EmitSoundOnEntityOnlyToPlayer( player, player, RECHARGING_COMPLETE_SOUND )
	}
}

void function Armor_ShieldRegen_OnPlayerLootPickup( entity player, entity pickup, string ref, int unitsPickedUp, bool willDestroy, entity deathBox, int pickupFlags )
{
	#if DEVELOPER
		if ( SHIELD_REGEN_DEBUG )
			printf("Armor_ShieldRegen_OnPlayerLootPickup() item string ref = " + ref)
	#endif

	LootData data = SURVIVAL_Loot_GetLootDataByRef( ref )

	if ( !IsValid( data ) )
		return

	if ( data.lootType == eLootType.ARMOR )
	{
		if ( player.GetShieldHealth() != player.GetShieldHealthMax() )
			thread Armor_ShieldRegen_RechargePlayerShields_Thread( player, false )
	}
}

void function Armor_ShieldRegen_OnPlayerReconnected( entity player )
{
	#if DEVELOPER
		if ( SHIELD_REGEN_DEBUG )
			printf( "DeathTrigger_OnPlayerReconnected()" )
	#endif

	if ( !player.e.entPostDamageCallbacks.contains( Armor_ShieldRegen_OnPlayerDamaged ) )
		AddEntityCallback_OnPostDamaged( player, Armor_ShieldRegen_OnPlayerDamaged )

	thread Armor_ShieldRegen_OnPlayerReconnected_Thread( player )
}

void function Armor_ShieldRegen_OnPlayerReconnected_Thread( entity player )
{
	wait 2.0 // give a chance for the server and client to sync up, fixes a mismatch in timing when restarting the regen delay after a reconnect

	if ( !IsAlive( player ) )
		return

	if ( player.GetShieldHealth() == player.GetShieldHealthMax() )
		return

	thread Armor_ShieldRegen_RechargePlayerShields_Thread( player, false )
}
#endif

#if CLIENT
void function Armor_ShieldRegen_OnPlayerSpawned( entity player )
{
	#if DEVELOPER
		if ( SHIELD_REGEN_DEBUG )
			printf( "Armor_ShieldRegen_OnPlayerSpawned()" )
	#endif

	if ( player == GetLocalClientPlayer() )
		ShieldRegen_CreateShieldRegenUI()
}

void function Armor_ShieldRegen_OnPlayerDisconnected( entity player )
{
	#if DEVELOPER
		if ( SHIELD_REGEN_DEBUG )
			printf("Armor_ShieldRegen_OnPlayerDisconnected()")
	#endif

	if ( !IsValid( player ) )
		return

	player.Signal( "Armor_ShieldRegen_OnDisconnect" )
}

void function ShieldRegen_CreateShieldRegenUI()
{
	#if DEVELOPER
		if ( SHIELD_REGEN_DEBUG )
			printf("ShieldRegen_CreateShieldRegenUI()")
	#endif

	if ( file.armorShieldRegenRui != null )
		return

	file.armorShieldRegenRui = CreateCockpitPostFXRui( $"ui/armor_shieldregen.rpak" , MINIMAP_Z_BASE )
	RuiSetFloat( file.armorShieldRegenRui, "maxRegenDelay", file.shieldRegenBreakDelayTime )
}

void function Armor_ShieldRegen_OnGameState_Ending()
{
	#if DEVELOPER
		if ( SHIELD_REGEN_DEBUG )
			printf("Armor_ShieldRegen_OnGameState_Ending()")
	#endif

	if ( file.armorShieldRegenRui == null )
		return

	RuiDestroyIfAlive( file.armorShieldRegenRui )
	file.armorShieldRegenRui = null
}

void function Armor_ShieldRegen_ServerCallback_RegenTriggerEvent( bool skipDelay )
{
	#if DEVELOPER
		if ( SHIELD_REGEN_DEBUG )
			printf("Armor_ShieldRegen_ServerCallback_RegenTriggerEvent()")
	#endif

	thread ShieldRegen_RegenTriggerNotice_Thread( skipDelay )
}

void function Armor_ShieldRegen_ServerCallback_RegenCancelEvent()
{
	#if DEVELOPER
		if ( SHIELD_REGEN_DEBUG )
			printf("Armor_ShieldRegen_ServerCallback_RegenCancelEvent()")
	#endif

	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) )
		return

	player.Signal( "Armor_ShieldRegen_OnDamaged" )
}


void function ShieldRegen_RegenTriggerNotice_Thread( bool skipDelay )
{
	#if DEVELOPER
		if ( SHIELD_REGEN_DEBUG )
			printf("ShieldRegen_RegenTriggerNotice_Thread()")
	#endif

	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) || !IsValid(file.armorShieldRegenRui))
		return

	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Armor_ShieldRegen_OnDamaged" )
	player.EndSignal( "Armor_ShieldRegen_OnDisconnect" )

	OnThreadEnd( function() : ( ) {
		#if DEVELOPER
			if ( SHIELD_REGEN_DEBUG )
				printf("ShieldRegen_RegenTriggerNotice: Thread End")
		#endif

		RuiSetBool( file.armorShieldRegenRui, "isDamaged", false )
		RuiSetFloat( file.armorShieldRegenRui, "regenDelay", 0.0 )
	} )

	float regenDelay = 0.0
	if ( !skipDelay )
	{
		regenDelay = file.shieldRegenDelayTime

		if ( player.GetShieldHealth() == 0 )
			regenDelay = file.shieldRegenBreakDelayTime
	}

	// set rui
	int armorTier = EquipmentSlot_GetEquipmentTier( player, "armor" )
	vector color = GetFXRarityColorForTier( armorTier )

	RuiSetBool( file.armorShieldRegenRui, "isDamaged", true )
	RuiSetGameTime( file.armorShieldRegenRui, "lastDamageTime", Time() )
	RuiSetFloat( file.armorShieldRegenRui, "regenDelay", regenDelay )

	RuiSetFloat3( file.armorShieldRegenRui, "armorColor", SrgbToLinear(<color.x, color.y, color.z>/255.0) )

	if ( !skipDelay )
		wait( regenDelay - SHIELD_REGEN_PREEMPTIVE_TIME ) // make the sound and hud callout a bit pre-emptive

	while ( player.GetShieldHealth() != player.GetShieldHealthMax() )
	{
		WaitFrame()
	}

	RuiSetBool( file.armorShieldRegenRui, "isDamaged", false )
}
#endif

// Determine if armor auto shield regen is enabled
bool function Armor_ShieldRegen_IsUsingShieldRegen()
{
	return GetCurrentPlaylistVarBool( "use_shield_regen", false )
}
 