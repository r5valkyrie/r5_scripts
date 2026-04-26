global function PassiveHeartbeatSensor_Init
global function OnWeaponPrimaryAttack_ability_heartbeat_sensor
global function OnWeaponAttemptOffhandSwitch_ability_heartbeat_sensor
global function OnWeaponActivate_ability_heartbeat_sensor
global function OnWeaponDeactivate_ability_heartbeat_sensor
global function ActivateHeartbeatSensor
global function DeactivateHeartbeatSensor
global function GetHeartbeatSensorRange




#if CLIENT
global function InitializeHeartbeatSensorUI
global function GeneratePlayersInViewInfo
#endif //CLIENT

#if SERVER
global function ClientCallback_ToggleHeartbeatSensor
global function ClientCallback_UpdateHeartbeatsHeardStat
global function WeaponModDisableHeartbeatSensorADSMelee
global function WeaponModEnableHeartbeatSensorADSMelee
#endif //SERVER

global const string HEARTBEAT_SENSOR_WEAPON_NAME = "mp_ability_heartbeat_sensor"

global const float HEARTBEAT_SENSOR_NATURAL_RANGE = 50

global const float HEARTBEAT_SENSOR_NATURAL_RANGE_UPGRADE = 75

global const float HEARTBEAT_SENSOR_INITIAL_ACTIVATION_DELAY_DEFAULT = 0.4
global const float HEARTBEAT_SENSOR_PING_INTERVAL_MIN = 0.4
global const float HEARTBEAT_SENSOR_PING_INTERVAL_MAX = 1.65 //Trying this at a bit under the old value for now, if we want //1.5275 is the timing such that when locked, you'll always have some version of the pip. (so that it doesn't feel like you have "dead" time on the sensor between pips when looking at a target.)
const float HEARTBEAT_SENSOR_STARTUP_TARGET_DELAY_MIN = HEARTBEAT_SENSOR_PING_INTERVAL_MIN * 0.25 //when we go into ADS, how long we wait before a heartbeat can start showing up on the UI.
const float HEARTBEAT_SENSOR_STARTUP_TARGET_DELAY_MAX = HEARTBEAT_SENSOR_PING_INTERVAL_MAX * 0.25 //0.6

const bool HEARTBEAT_SENSOR_UNARMED_ONLY = false
const bool HEARTBEAT_SENSOR_WEAPONS_ONLY = false

const float TICK_RATE = 0.01
const float HEARTBEAT_SOUND_BAR_WAIT_TIME = 0.28 //time between pulses to represent the 2 beats of the heart sound
const float HEARTBEAT_SENSOR_MIN_ZOOM_FOV = 55
const float HEARTBEAT_SENSOR_MAX_ZOOM_FOV = 8.01071 //10x sniper scope
const float HEARTBEAT_SENSOR_MIN_WATCH_RANGE = 5500
const float HEARTBEAT_SENSOR_MAX_WATCH_RANGE = 20000
const float HEARTBEAT_SENSOR_RANGE_VISUAL_COMBAT_THRESHOLD = 2.0
const float HEARTBEAT_SENSOR_RANGE_VISUAL_DEBOUNCE_THRESHOLD = 3.5
const float HEARTBEAT_SENSOR_TEAMMATES_COMMS_DISPLAYTIME = 6.0
const float HEARTBEAT_SENSOR_REPORT_DELAY = HEARTBEAT_SENSOR_PING_INTERVAL_MAX
const float HEARTBEAT_SENSOR_COMMS_COOLDOWN_CLEAR_AFTER_ENEMIES = 15.0
const float HEARTBEAT_SENSOR_COMMS_COOLDOWN = 35.0
const float HEARTBEAT_SENSOR_STATE_COOLDOWN = HEARTBEAT_SENSOR_PING_INTERVAL_MAX
const float HEARTBEAT_SENSOR_GLOBAL_COOLDOWN = 3.5
const float HEARTBEAT_SENSOR_REPORT_LISTEN_DELAY = 2.0
const int HEARTBEAT_SENSOR_OFFHAND_INDEX = OFFHAND_EQUIPMENT
const int MAX_HEARTBEAT_SENSOR_TARGETS = 10 //max 10 in the UI

const asset HEARTBEAT_SENSOR_RADIUS_FX = $"P_decoy_grenade_radius_ping"

const string HEARTBEAT_SENSOR_HEARTBEAT_SOUND_3P = "Seer_Passive_Heartbeat_3p"
const string HEARTBEAT_SENSOR_ACTIVE_SOUND_3P = "Seer_Passive_HeartbeatSensor_3p"
const string HEARTBEAT_SENSOR_ACTIVE_SOUND_1P = "Seer_Passive_HeartbeatSensor_1p"

const asset FX_HEARTBEAT_SENSOR_EYEGLOW_FRIEND = $"p_heart_sensor_eye_foe" // $"p_heart_sensor_eye_friend"
const asset FX_HEARTBEAT_SENSOR_EYEGLOW_FOE = $"p_heart_sensor_eye_foe"
const asset FX_HEARTBEAT_SENSOR_SONAR_PULSE = $"P_heart_sensor_pulse_1p"
const asset FX_HEARTBEAT_SENSOR_SONAR_PULSE_NO_INTRO = $"P_heart_sensor_on_1p"

#if DEVELOPER
const bool HEARTBEAT_SENSOR_DEBUG = false
const bool HEARTBEAT_SENSOR_DEBUG_VERBOSE = false
const bool HEARTBEAT_SENSOR_WEAPON_MODS_DEBUG = false
const bool HEARTBEAT_SENSOR_STAT_TRACKING_DEBUG = false
const bool DEBUG_HEARTBEAT_SENSOR_DELAY = false

const bool HEARTBEAT_SENSOR_COMMS_DEBUG = false
#endif //DEV

struct BarData
{
	float angle
	float lastGameTimeBeat
	bool isLocked
	bool inTacRange
}

struct
{
	#if CLIENT
		table<entity, int> heartbeatSensorEyeVFX //keep track of eye VFX for Seer
		array<entity> heartbeatSensorVictims
		table<entity, BarData> waveformRadialValueTable
		table<entity, PlayersInViewInfo> victimPlayerViewportInfo
		entity bestVictimForAudio
		bool hasTargetLocked
		int heartbeatsHeardWhileActive
		float lastHeartbeatSensorActivationTime
		float         lastCommsTimeEnemies
		float         lastCommsTimeClear
		float         lastCommsTimeClearInCombat
		float         lastCommsTimeEither
		vector        lastCommsLocation
		float         commsResetRange
		float	      commsEnemyRemovalRange
		array<entity> lastHeardEnemies
		float		  lastHeardHeartbeatTime
	#endif //CLIENT
	#if SERVER
		table<entity, float> lastHeartbeatSensorActivationTime
	#endif //SERVER
	var heartbeatSensorRui
	float heartbeatSensorRange
	float heartbeatSensorRangeSqr
} file

/**********************************************************************************************************************
Init Functions
**********************************************************************************************************************/
void function PassiveHeartbeatSensor_Init()
{
	RegisterSignal( "DestroyHeartbeatSensor" ) //For when the player is no longer Seer
	RegisterSignal( "EndHeartbeatSensorUI" ) //Stops the UI
	RegisterSignal( "DeactivateHeartbeatSensor" )

	file.heartbeatSensorRange = HEARTBEAT_SENSOR_NATURAL_RANGE / INCHES_TO_METERS
	file.heartbeatSensorRangeSqr = pow( file.heartbeatSensorRange, 2 )

	#if SERVER
	//Survival_AddCallback_OnPlayerSetupComplete( OnPlayerSetupComplete_Seer )
	#endif

	#if CLIENT
	RegisterSignal( "EndHeartbeatSensorVictimManager" ) //Stop the functionality that does the heartbeats and finds vicitms

	RegisterSignal( "StopWatchingHeartbeatSensorVictim" ) //Shut down heartbeat sensor threads for player (they're now out of view or out of range)
	//AddCallback_ClientOnPlayerConnectionStateChanged( OnClientConnectionChanged )
	AddCallback_OnViewPlayerChanged( HeartbeatSensor_OnLocalViewPlayerChanged )
	RegisterConCommandTriggeredCallback( "+scriptCommand5", HeartbeatSensorTogglePressed )

	file.lastCommsTimeEnemies = -100.0
	file.lastCommsTimeClear = -100.0
	file.lastCommsTimeClearInCombat = -100.0
	file.lastCommsTimeEither = -100.0

	file.lastCommsLocation = ZERO_VECTOR
	float baseSonicBlastRange = HEARTBEAT_SENSOR_NATURAL_RANGE / INCHES_TO_METERS + SONIC_BLAST_RANGE_EXTENSION
	file.commsResetRange = baseSonicBlastRange * 0.75 //how far Seer has to move from his last comms position to reset it.
	file.commsEnemyRemovalRange = baseSonicBlastRange * 1.35 //how far an enemy has to move from Seer's position to no longer be considered a target that was recently heard.
	#endif //CLIENT

	PrecacheParticleSystem( FX_HEARTBEAT_SENSOR_EYEGLOW_FRIEND )
	PrecacheParticleSystem( FX_HEARTBEAT_SENSOR_EYEGLOW_FOE )
	PrecacheParticleSystem( FX_HEARTBEAT_SENSOR_SONAR_PULSE )
	PrecacheParticleSystem( FX_HEARTBEAT_SENSOR_SONAR_PULSE_NO_INTRO )

	#if SERVER
	AddClientCommandCallback( "HeartbeatSensor_Toggle", ClientCallback_ToggleHeartbeatSensor )
	AddClientCommandCallback( "HeartbeatSensor_UpdateStat", ClientCallback_UpdateHeartbeatsHeardStat )
	#endif

	AddCallback_OnPassiveChanged( ePassives.PAS_PARIAH, HeartbeatSensor_OnPassiveChanged )
	AddCallback_OnPlayerZoomIn( PlayerZoomInCallback )
	AddCallback_OnPlayerZoomOut( PlayerZoomOutCallback )
}

/**********************************************************************************************************************
Callback Functions
**********************************************************************************************************************/
void function HeartbeatSensor_OnPassiveChanged( entity player, int passive, bool didHave, bool nowHas )
{
	#if CLIENT
		entity localViewPlayer = GetLocalViewPlayer()
	#endif //CLIENT
	if ( didHave )
	{
		#if SERVER
		if ( IsValid( player ) )
		{
			//clean up
			entity weapon = player.GetOffhandWeapon( HEARTBEAT_SENSOR_OFFHAND_INDEX )
			player.TakeOffhandWeapon( HEARTBEAT_SENSOR_OFFHAND_INDEX )
			player.Signal( "DestroyHeartbeatSensor" )

			if ( player in file.lastHeartbeatSensorActivationTime )
			{
				delete file.lastHeartbeatSensorActivationTime[player]
			}
		}
		#elseif CLIENT
			if ( player == localViewPlayer )
			{
				localViewPlayer.Signal( "DestroyHeartbeatSensor" )
			}
			if ( player in file.heartbeatSensorEyeVFX )
			{
				if ( EffectDoesExist( file.heartbeatSensorEyeVFX[player] ) )
				{
					EffectStop( file.heartbeatSensorEyeVFX[player], false, true )
					delete file.heartbeatSensorEyeVFX[player]
				}
			}
		#endif //CLIENT
	}
	if ( nowHas )
	{
		#if SERVER
		player.GiveOffhandWeapon( HEARTBEAT_SENSOR_WEAPON_NAME, HEARTBEAT_SENSOR_OFFHAND_INDEX, [] )

		file.lastHeartbeatSensorActivationTime[player] <- 0.0





		#elseif CLIENT
			if ( player == localViewPlayer )
			{
				file.heartbeatSensorVictims.clear()
			}

			if ( player in file.heartbeatSensorEyeVFX )
			{
				if ( EffectDoesExist( file.heartbeatSensorEyeVFX[player] ) )
				{
					EffectStop( file.heartbeatSensorEyeVFX[player], false, true )
					delete file.heartbeatSensorEyeVFX[player]
				}

				delete file.heartbeatSensorEyeVFX[player]
			}
		#endif //CLIENT


	}
}

#if SERVER
void function OnPlayerSetupComplete_Seer( entity player )
{
	if( !IsValid( player ) )
		return
	if ( !PlayerHasPassive( player, ePassives.PAS_PARIAH ) )
		return

	if( GetCurrentPlaylistVarBool( "seer_heartbeat_sensor_weapons_only", HEARTBEAT_SENSOR_WEAPONS_ONLY ))
	{
		WeaponModDisableHeartbeatSensorADSMelee( player )
	}
}
#endif

void function PlayerZoomInCallback( entity player )
{
	if ( !PlayerHasPassive( player, ePassives.PAS_PARIAH ) )
		return

	#if CLIENT
	if ( !IsAlive( player ) )
		return

	if ( player == GetLocalViewPlayer() )
	{
		InitializeHeartbeatSensorUI( player )

		//Sheila calls DisableOffhandWeapons on the player, so our heartbeat sensor will not activate on zoom in despite offhand_activates_on_zoom being set.
		//Putting a special case here to handle this.
		entity turret = null
		if ( IsValid( turret ) )
		{
			ActivateHeartbeatSensor( player, false )
			thread TurretHeartbeatSensor_Thread( player )
		}
	}
	#elseif SERVER
	AddMoveSpeedWeaponModForMelee( player )
	#endif
}

#if CLIENT
void function HeartbeatSensor_OnLocalViewPlayerChanged( entity player )
{
	if ( !PlayerHasPassive( player, ePassives.PAS_PARIAH ) )
	{
		if ( file.heartbeatSensorRui != null )
		{
			player.Signal( "DestroyHeartbeatSensor" )
		}
	}
	else
	{
		//the zoomin/activate callbacks don't get called on spectator target change.  So we need to manually activate the heartbeat sensor in this case where a player has switched spectator targets to one already in ADS.
		if ( PlayerIsInADS( player, false ) )
		{
			if ( file.heartbeatSensorRui == null )
			{
				entity heartbeatSensor = player.GetOffhandWeapon( HEARTBEAT_SENSOR_OFFHAND_INDEX )
				if ( IsValid( heartbeatSensor ) )
				{
					//we can't rely on entirely on an ADS check here, since the player can be in ADS but sensor disabled.
					if ( PlayerIsInADS( player ) )
					{
						ActivateHeartbeatSensor( player, false )
					}
				}
			}
		}
	}
}

void function TurretHeartbeatSensor_Thread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "DestroyHeartbeatSensor" )
	player.EndSignal( "EndHeartbeatSensorVictimManager" )
	player.EndSignal( "EndHeartbeatSensorUI" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	OnThreadEnd(
			function() : ( player )
			{
				if ( IsValid( player ) )
				{
					DeactivateHeartbeatSensor( player, false )

					//zoom out callback usually handles this, but that callback doesn't happen if the player jumps off of the turret
					player.Signal( "EndHeartbeatSensorUI" )
				}
			}
		)

	WaitSignal( player, "DeactivateMountedTurret" )
}
#endif

void function PlayerZoomOutCallback( entity player )
{
	#if CLIENT
	if ( player == GetLocalViewPlayer() )
	{
		player.Signal("EndHeartbeatSensorUI")
	}
	#elseif SERVER
	RemoveMoveSpeedWeaponModForMelee( player )
	#endif
}

void function OnWeaponActivate_ability_heartbeat_sensor( entity weapon )
{
	entity player = weapon.GetWeaponOwner()

	if ( !IsAlive( player ) )
		return

	if ( !PlayerHasPassive( player, ePassives.PAS_PARIAH ) )
		return


	bool isUnarmed = true
	string activeWeaponName = player.GetActiveWeapon( eActiveInventorySlot.mainHand ).GetWeaponClassName()
	if( activeWeaponName != "mp_weapon_melee_survival"  )
	{
		//check for heirloom
		if( activeWeaponName != "mp_weapon_seer_heirloom_primary"  )
			isUnarmed = false
	}

	// For Playtesting - Default to Unarmed-Only //
	if( !isUnarmed && GetCurrentPlaylistVarBool( "seer_heartbeat_sensor_unarmed_only", HEARTBEAT_SENSOR_UNARMED_ONLY ) )
		return

	thread DelayedActivateHeartbeatSensor_Thread( player, false )

}

void function DelayedActivateHeartbeatSensor_Thread( entity player, bool fromTac )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "DeactivateHeartbeatSensor" )

	float delayTime = Time() + HEARTBEAT_SENSOR_INITIAL_ACTIVATION_DELAY_DEFAULT

	entity viewWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( IsValid( viewWeapon ) && !DoesWeaponTriggerMeleeAttack( viewWeapon ) )
	{
		float raiseTime = viewWeapon.GetWeaponSettingFloat( eWeaponVar.raise_time )
		if ( raiseTime > 0.0 )
		{
			#if DEVELOPER
				if ( DEBUG_HEARTBEAT_SENSOR_DELAY )
					printt( FUNC_NAME() + "Setting delay to: " + ( raiseTime * 0.5 ) )
			#endif
			delayTime = Time() + ( raiseTime * 0.5 )
		}
	}
	#if DEVELOPER
	else
	{
		if ( DEBUG_HEARTBEAT_SENSOR_DELAY )
			printt( FUNC_NAME() + "Setting delay to: " + HEARTBEAT_SENSOR_INITIAL_ACTIVATION_DELAY_DEFAULT )
	}
	#endif

	while( Time() < delayTime )
	{
		if( !IsValid(player) )
			return
		if ( !PlayerIsInADS( player, false ) )
			return
		WaitFrame()
	}

	ActivateHeartbeatSensor( player, fromTac )
}


void function OnWeaponDeactivate_ability_heartbeat_sensor( entity weapon )
{
	entity player = weapon.GetWeaponOwner()

	if ( !IsAlive( player ) )
		return

	if ( !PlayerHasPassive( player, ePassives.PAS_PARIAH ) )
		return

	DeactivateHeartbeatSensor( player, false )
}

bool function OnWeaponAttemptOffhandSwitch_ability_heartbeat_sensor( entity weapon )
{
	entity player = weapon.GetOwner()

	if( !IsValid( player ) )
		return false







	return PlayerHasPassive( player, ePassives.PAS_PARIAH )
}


var function OnWeaponPrimaryAttack_ability_heartbeat_sensor( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return 0
}

//This function is being called multiple times and in an order that doesn't make sense.
//SERVER:
//CALL 1: OldOwner: Invalid, NewOwner: Me
//CALL 2: OldOwner: Me, NewOwner: Invalid
//CALL 3: OldOwner: Invalid, NewOwner: Me
//CLIENT:
//CALL 1: OldOwner: Invalid, NewOwner: Me
//CALL 2: OldOwner: Invalid, NewOwner: Me
//CALL 3: OldOwner: Me, NewOwner: Invalid
//CALL 4: OldOwner: Me, NewOwner: Invalid
//This makes reliably knowing when I do or don't have this weapon for the purposes of setup/cleanup impossible.  Going back to using the passive changed callback.
//void function OnWeaponOwnerChanged_ability_heartbeat_sensor( entity weapon, WeaponOwnerChangedParams changeParams )

#if CLIENT
void function HeartbeatSensorTogglePressed( entity player )
{
	if ( player != GetLocalViewPlayer() || player != GetLocalClientPlayer() )
		return

	entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( !IsValid( activeWeapon ) )
		return

	if ( StatusEffect_HasSeverity( player, eStatusEffect.silenced ) )
		return

	if ( activeWeapon.IsWeaponAdsButtonPressed() || activeWeapon.IsWeaponInAds() )
	{
		player.ClientCommand( "HeartbeatSensor_Toggle" )
	}
}
#endif // #if CLIENT

#if SERVER
bool function ClientCallback_ToggleHeartbeatSensor( entity player, array<string> args )
{
	if ( !IsAlive( player ) )
		return false

	if ( !PlayerHasPassive( player, ePassives.PAS_PARIAH ) )
		return false

	entity weapon = player.GetOffhandWeapon( HEARTBEAT_SENSOR_OFFHAND_INDEX )

	if ( !IsValid( weapon ) )
		return false

	if ( weapon.GetWeaponClassName() != HEARTBEAT_SENSOR_WEAPON_NAME )
		return false

	array<string> mods = weapon.GetMods()

	if ( mods.contains( "disabled" ) )
		mods.fastremovebyvalue( "disabled" )
	else
		mods.append( "disabled" )

	weapon.SetMods( mods )
	return true
}

void function AddMoveSpeedWeaponModForMelee( entity player )
{
	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

	string modName = "seer_heartbeat_sensor_active"

	if ( IsValid( weapon ) && ( DoesWeaponTriggerMeleeAttack( weapon ) ) )
	{
		array mods = player.GetExtraWeaponMods()

		if ( !mods.contains( modName ) )
		{
			#if DEVELOPER
			if ( HEARTBEAT_SENSOR_WEAPON_MODS_DEBUG )
			{
				printt( FUNC_NAME() + " Adding " + modName + " weapon mod." )
			}
			#endif
			mods.append( modName )
			player.SetExtraWeaponMods( mods )
		}
	}
}

void function RemoveMoveSpeedWeaponModForMelee( entity player )
{
	entity weapon = player.GetOffhandWeapon( OFFHAND_MELEE )

	if ( IsValid( weapon ) && ( DoesWeaponTriggerMeleeAttack( weapon ) ) )
	{
		array mods = player.GetExtraWeaponMods()
		string modToRemove
		if ( mods.contains( "seer_heartbeat_sensor_active" ) )
		{
			modToRemove = "seer_heartbeat_sensor_active"
		}

		if( modToRemove != "" )
		{
			#if DEVELOPER
			if ( HEARTBEAT_SENSOR_WEAPON_MODS_DEBUG )
			{
				printt( FUNC_NAME() + " Removing " + modToRemove + " weapon mod." )
			}
			#endif
			mods.fastremovebyvalue( modToRemove )
			player.SetExtraWeaponMods( mods )
		}
	}
}

void function WeaponModDisableHeartbeatSensorADSMelee( entity player )
{
	if ( !IsAlive( player ) )
		return

	//Note that removing these mods from the melee weapons themselves didn't work, I'm guessing because they are granted as part of the extraWeaponMods given by the passive in Bakery.
	//Need to give/take them away in the same way.
	array mods = player.GetExtraWeaponMods()

	if ( mods.contains( "pariah_ads_melee" ) )
		mods.fastremovebyvalue( "pariah_ads_melee" )

	player.SetExtraWeaponMods( mods )
}

void function WeaponModEnableHeartbeatSensorADSMelee( entity player )
{
	if ( !IsAlive( player ) )
		return

	array mods = player.GetExtraWeaponMods()

	if ( !mods.contains( "pariah_ads_melee" ) )
		mods.append( "pariah_ads_melee" )

	player.SetExtraWeaponMods( mods )
}

bool function ClientCallback_UpdateHeartbeatsHeardStat( entity player, array<string> args )
{
	if ( args.len() < 1 )
		return false

	int count = args[0].tointeger()

	if ( player in file.lastHeartbeatSensorActivationTime )
	{
		float activationTime = Time() - file.lastHeartbeatSensorActivationTime[player]

		int maxPossibleVal = int( activationTime / HEARTBEAT_SENSOR_PING_INTERVAL_MIN )
		int cappedVal = minint( count, maxPossibleVal )

		#if DEVELOPER
		if ( HEARTBEAT_SENSOR_STAT_TRACKING_DEBUG )
		{
			printt("Client reported hearing " + count + " heartbeats, server says max possible would have been " + maxPossibleVal + ", incrementing stat by " + cappedVal + ". Sensor was active for: " + activationTime )
		}
		#endif //DEV

		if ( cappedVal > 0 )
		{
			//StatsHook_SeerEnemyHeartbeatsHeard( player, cappedVal )
		}
	}
	return true
}
#endif //SERVER

void function OnClientConnectionChanged( entity player )
{
	#if CLIENT
		if ( player != GetLocalClientPlayer() )
			return

		if ( !IsConnected() )
			return

		if ( !PlayerHasPassive( player, ePassives.PAS_PARIAH ) )
			return

		if ( player == GetLocalViewPlayer() )
		{
			//the zoomin callback doesn't get called on reconnect, but for the heartbeat sensor it sets up the UI, so we need to manually initialize the heartbeat sensor UI in this case where a player has reconnected already in ADS.
			if ( PlayerIsInADS( player, false ) )
			{
				if ( file.heartbeatSensorRui == null )
				{
					SetupHeartbeatSensorUI( player )
				}
			}
		}
	#endif
}

/**********************************************************************************************************************
Gameplay Functions
**********************************************************************************************************************/
#if CLIENT
void function SetupHeartbeatSensorUI( entity player )
{
	InitializeHeartbeatSensorUI( player )
	entity heartbeatSensor = player.GetOffhandWeapon( HEARTBEAT_SENSOR_OFFHAND_INDEX )

	//we can't rely on an ADS check here, since the heartbeat sensor can be in ADS but could be disabled.
	if ( PlayerIsInADS( player ) )
	{
		RuiSetBool( file.heartbeatSensorRui, "heartbeatSensorEnabled", true )
	}
	else
	{
		RuiSetBool( file.heartbeatSensorRui, "heartbeatSensorEnabled", false )
	}
}

void function InitializeHeartbeatSensorUI( entity player )
{
	if( file.heartbeatSensorRui == null )
	{
		file.heartbeatSensorRui = CreateCockpitRui( $"ui/heartbeat_sensor_waveform_radial.rpak" )
		RuiSetGameTime( file.heartbeatSensorRui, "startTime", Time() )
		entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
		thread CL_HeartSeekerRUIThread( player, activeWeapon )
	}


}
#endif //CLIENT

void function ActivateHeartbeatSensor( entity player, bool fromTac )
{
	#if SERVER
		if ( player in file.lastHeartbeatSensorActivationTime )
		{
			#if DEVELOPER
			if ( HEARTBEAT_SENSOR_STAT_TRACKING_DEBUG )
			{
				printt( "Setting last activation time on Server to " + Time() )
			}
			#endif //DEV

			file.lastHeartbeatSensorActivationTime[player] = Time()
		}
	#endif //SERVER
	#if CLIENT
		entity localViewPlayer = GetLocalViewPlayer()

		if ( player == localViewPlayer )
		{
			SetupHeartbeatSensorUI( player )

			RuiSetBool( file.heartbeatSensorRui, "heartbeatSensorEnabled", true )

			if ( fromTac )
			{
				//Tac doesn't ADS, so sys.player.adsFrac which is used for alpha in the .rui will return 0.  We have this flag to force the alpha to 1.0
				RuiSetBool( file.heartbeatSensorRui, "heartbeatSensorADSOverride", true )
			}

			thread ShowHeartbeatSensorRange_Thread( player )

			thread ManageVictims_Thread( player )
			thread ManageHeartbeatSensorComms_Thread( player )

			file.heartbeatsHeardWhileActive = 0
		}
		else
		{
			EmitSoundOnEntity( player, HEARTBEAT_SENSOR_ACTIVE_SOUND_3P )
			bool isFriendly = IsFriendlyTeam( localViewPlayer.GetTeam(), player.GetTeam() )
			int particleIndex = isFriendly ? GetParticleSystemIndex( FX_HEARTBEAT_SENSOR_EYEGLOW_FRIEND ) : GetParticleSystemIndex( FX_HEARTBEAT_SENSOR_EYEGLOW_FOE )

			if ( player in file.heartbeatSensorEyeVFX )
			{
				if ( EffectDoesExist( file.heartbeatSensorEyeVFX[player] ) )
				{
					EffectStop( file.heartbeatSensorEyeVFX[player], false, true )
					file.heartbeatSensorEyeVFX[player] = -1
				}
			}
			else
			{
				file.heartbeatSensorEyeVFX[player] <- -1
			}

			int leftEyeFX = StartParticleEffectOnEntity( player, particleIndex, FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "EYE_L" ) )

			file.heartbeatSensorEyeVFX[player] = leftEyeFX

			// -- KCRAFT testing chest FX --
			//int chestFX = StartParticleEffectOnEntity( player, particleIndex, FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "CHESTFOCUS" ) )
			//file.heartbeatSensorEyeVFX[player] = chestFX
		}
	#endif //CLIENT
}

#if CLIENT
void function ManageHeartbeatSensorComms_Thread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "DestroyHeartbeatSensor" )
	player.EndSignal( "EndHeartbeatSensorVictimManager" )
	player.EndSignal( "EndHeartbeatSensorUI" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	float lastTimeHadEnemies = 0.0
	float lastTimeHadClear = 0.0

	if ( IsSpectating() )
		return

	wait HEARTBEAT_SENSOR_REPORT_DELAY

	while ( true  )
	{
		if ( !PlayerDeliveryShouldBeUrgent( player, player.GetOrigin() ) )
		{
			#if DEVELOPER
			if ( HEARTBEAT_SENSOR_COMMS_DEBUG )
				printt(FUNC_NAME() + " Out of Combat")
			#endif //DEV

			//if we've never made a report, then we don't want to distance check against ZERO_VECTOR since that will almost always pass
			vector lastReportLocation = file.lastCommsLocation != ZERO_VECTOR ? file.lastCommsLocation : player.EyePosition()

			float deltaTimeEither = Time() - file.lastCommsTimeEither
			bool onGlobalCooldown = ( deltaTimeEither <= HEARTBEAT_SENSOR_GLOBAL_COOLDOWN )

			float deltaHeardHeartbeat = Time() - file.lastHeardHeartbeatTime

			if ( file.heartbeatSensorVictims.len() > 0 && deltaHeardHeartbeat <= HEARTBEAT_SENSOR_REPORT_LISTEN_DELAY )
			{
				#if DEVELOPER
				if ( HEARTBEAT_SENSOR_COMMS_DEBUG )
					printt(FUNC_NAME() + " Has enemeis")
				#endif //DEV

				lastTimeHadEnemies = Time()

				foreach ( entity enemy in file.heartbeatSensorVictims )
				{
					if ( !file.lastHeardEnemies.contains( enemy ) )
					{
						file.lastHeardEnemies.append( enemy )
					}
				}

				if ( !onGlobalCooldown )
				{
					#if DEVELOPER
					if ( HEARTBEAT_SENSOR_COMMS_DEBUG )
						printt(FUNC_NAME() + " Off Cooldown")
					#endif //DEV

					float distanceFromLastReport = Length( player.EyePosition() - lastReportLocation )
					float deltaTimeEnemies = Time() - file.lastCommsTimeEnemies
					float deltaTimeSinceHadClear = Time() - lastTimeHadClear

					if ( ( deltaTimeEnemies > HEARTBEAT_SENSOR_COMMS_COOLDOWN || distanceFromLastReport > file.commsResetRange ) && ( deltaTimeSinceHadClear > HEARTBEAT_SENSOR_STATE_COOLDOWN ) )
					{
						#if DEVELOPER
						if ( HEARTBEAT_SENSOR_COMMS_DEBUG )
							printt(FUNC_NAME() + " Adding enemy prompt" )
						#endif //DEV

						AddOnscreenPromptFunction( "quickchat", TryHeartbeatSensorEnemiesNearCommsTeammates, HEARTBEAT_SENSOR_TEAMMATES_COMMS_DISPLAYTIME, "#SEER_HEARTBEAT_SENSOR_COMMS_ENEMIES", 100 )
						file.lastCommsTimeEnemies = Time()
						file.lastCommsTimeEither  = Time()
					}
				}
			}
			else
			{
				#if DEVELOPER
				if ( HEARTBEAT_SENSOR_COMMS_DEBUG )
					printt(FUNC_NAME() + " No enemeis")
				#endif //DEV

				lastTimeHadClear = Time()

				if ( !onGlobalCooldown )
				{
					#if DEVELOPER
					if ( HEARTBEAT_SENSOR_COMMS_DEBUG )
						printt(FUNC_NAME() + " Off Cooldown")
					#endif //DEV

					float distanceFromLastReport = Length( player.EyePosition() - lastReportLocation )
					float deltaTimeClear = Time() - file.lastCommsTimeClear
					float deltaTimeEnemies = Time() - file.lastCommsTimeEnemies
					float deltaTimeSinceHadEnemies = Time() - lastTimeHadEnemies

					#if DEVELOPER
					if ( HEARTBEAT_SENSOR_COMMS_DEBUG )
						printt(FUNC_NAME() + "distanceFromLastReport: " + distanceFromLastReport + " deltaTimeClear: " + deltaTimeClear + " deltaTimeEnemies: " + deltaTimeEnemies + " deltaTimeSinceHadEnemies: " + deltaTimeSinceHadEnemies)
					#endif //DEV

					//There's an additional check for the all clear comms to not follow too closely after a enemies comms.  Can easily have the situation where you may have indicated enemies nearby, and then move your aim such that you have no enemies on heartbeat anymore.  Immediatly communicating no heartbeats after feels weird becuse chances are those enemies are still around.
					if ( ( ( deltaTimeClear > HEARTBEAT_SENSOR_COMMS_COOLDOWN && deltaTimeEnemies > HEARTBEAT_SENSOR_COMMS_COOLDOWN_CLEAR_AFTER_ENEMIES ) || distanceFromLastReport > file.commsResetRange ) && ( deltaTimeSinceHadEnemies > HEARTBEAT_SENSOR_STATE_COOLDOWN ) )
					{
						#if DEVELOPER
						if ( HEARTBEAT_SENSOR_COMMS_DEBUG )
							printt( FUNC_NAME() + " Adding clear prompt" )
						#endif //DEV

						AddOnscreenPromptFunction( "quickchat", TryHeartbeatSensorEnemiesClearCommsTeammates, HEARTBEAT_SENSOR_TEAMMATES_COMMS_DISPLAYTIME, "#SEER_HEARTBEAT_SENSOR_COMMS_CLEAR", 100 )
						file.lastCommsTimeClear  = Time()
						file.lastCommsTimeEither = Time()
					}
				}
			}
		}
		else //even if we're in combat by that check (under 30s since we took or did damage), let's see if our nearby enemies are all dead or too far away to care, in that case probably want to be able to give an all clear comms.
		{
			#if DEVELOPER
			if ( HEARTBEAT_SENSOR_COMMS_DEBUG )
				printt( FUNC_NAME() + " In Combat")
			#endif //DEV
			bool foundAliveEnemy = false

			for ( int i = 0; i < file.lastHeardEnemies.len(); i++ )
			{
				if ( !IsValid( file.lastHeardEnemies[i] ) || !IsAlive( file.lastHeardEnemies[i] ) )
				{
					#if DEVELOPER
					if ( HEARTBEAT_SENSOR_COMMS_DEBUG )
						printt( FUNC_NAME() + " found dead or invalid enemy in list from last comms, removing" )
					#endif //DEV
					file.lastHeardEnemies.fastremove( i )
					i--
					continue
				}
				else if ( Length( player.EyePosition() - file.lastHeardEnemies[i].EyePosition() ) > file.commsEnemyRemovalRange )
				{
					#if DEVELOPER
						if ( HEARTBEAT_SENSOR_COMMS_DEBUG )
							printt( FUNC_NAME() + " enemy is far enoughaway from Seer that we no longer want to track them, removing." )
					#endif //DEV
					file.lastHeardEnemies.fastremove( i )
					i--
					continue
				}
				else if ( IsAlive( file.lastHeardEnemies[i] ) )
				{
					#if DEVELOPER
					if ( HEARTBEAT_SENSOR_COMMS_DEBUG )
						printt( FUNC_NAME() + " found alive enemy from last group seen" )
					#endif //DEV

					foundAliveEnemy = true
					lastTimeHadEnemies = Time()
					break
				}
			}

			//we didn't find anyone alive from our last ping, and we have no one on the sensor
			if ( !foundAliveEnemy && ( file.heartbeatSensorVictims.len() == 0 ) )
			{
				#if DEVELOPER
				if ( HEARTBEAT_SENSOR_COMMS_DEBUG )
					printt( FUNC_NAME() + " !foundAliveEnemy && ( file.heartbeatSensorVictims.len() == 0 )")
				#endif //DEV

				float deltaTimeClear = Time() - file.lastCommsTimeClearInCombat
				float deltaTimeEither = Time() - file.lastCommsTimeEither
				float deltaTimeHadEnemies = Time() - lastTimeHadEnemies

				#if DEVELOPER
				if ( HEARTBEAT_SENSOR_COMMS_DEBUG )
					printt(FUNC_NAME() + "deltaTimeEither: " + deltaTimeEither + " deltaTimeClear: " + deltaTimeClear + " deltaTimeHadEnemies: " + deltaTimeHadEnemies)
				#endif //DEV

				//Allow Seer to do the all clear comms if we drop
				if ( ( ( deltaTimeClear > HEARTBEAT_SENSOR_COMMS_COOLDOWN ) ) && ( deltaTimeEither > HEARTBEAT_SENSOR_GLOBAL_COOLDOWN ) && ( deltaTimeHadEnemies > HEARTBEAT_SENSOR_GLOBAL_COOLDOWN ) )
				{
					AddOnscreenPromptFunction( "quickchat", TryHeartbeatSensorEnemiesClearCommsTeammates, HEARTBEAT_SENSOR_TEAMMATES_COMMS_DISPLAYTIME, "#SEER_HEARTBEAT_SENSOR_COMMS_CLEAR", 100 )
					file.lastCommsTimeClear  = Time()
					file.lastCommsTimeClearInCombat = Time()
					file.lastCommsTimeEither = Time()
				}
			}
			#if DEVELOPER
			else if ( HEARTBEAT_SENSOR_COMMS_DEBUG )
			{
				printt(FUNC_NAME() + " found alive enemy from last ping")
			}
			#endif //DEV
		}

		wait 0.1
	}
}

void function TryHeartbeatSensorEnemiesNearCommsTeammates( entity player )
{
	Quickchat( eCommsAction.HEARTBEAT_SENSOR_DETECT_ENEMY, null )

	file.lastCommsLocation = player.EyePosition()
}

void function TryHeartbeatSensorEnemiesClearCommsTeammates( entity player )
{
	Quickchat( eCommsAction.HEARTBEAT_SENSOR_NO_ENEMY, null )
	file.lastCommsLocation = player.EyePosition()
	//We just told allies there are no heartbeats, so we probably want to be able to quickly correct that and let them know if we do sunddenly hear some again.  Reset the last timer so that it will be available to prompt if heartbeats are heard.
	file.lastCommsTimeEnemies = 0.0
}

void function ShowHeartbeatSensorRange_Thread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "DestroyHeartbeatSensor" )
	player.EndSignal( "EndHeartbeatSensorVictimManager" )
	player.EndSignal( "EndHeartbeatSensorUI" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	entity weapon     = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

	if ( IsValid( weapon ) )
	{
		EmitSoundOnEntity( player, HEARTBEAT_SENSOR_ACTIVE_SOUND_1P )

		float activationTime = Time()

		bool showRangeDebounce = file.lastHeartbeatSensorActivationTime > ( activationTime - HEARTBEAT_SENSOR_RANGE_VISUAL_DEBOUNCE_THRESHOLD )
		//the player recently activated their sensor so lets not play the pop at the start of the range VFX
		int fxId              = showRangeDebounce ? GetParticleSystemIndex( FX_HEARTBEAT_SENSOR_SONAR_PULSE_NO_INTRO ) : GetParticleSystemIndex( FX_HEARTBEAT_SENSOR_SONAR_PULSE )

		int pulseVFX      = StartParticleEffectOnEntity( player, fxId, FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
		float adjustedRange = GetHeartbeatSensorRange( player )
		EffectSetControlPointVector( pulseVFX, 1, <adjustedRange, 0, 0> )

		file.lastHeartbeatSensorActivationTime = activationTime

		Minimap_SetVisiblityCone(true, adjustedRange, $"rui/hud/minimap/minimap_seer_tac_cone", GetKeyColor( COLORID_ENEMY ))

		OnThreadEnd(
			function() : ( player, pulseVFX )
			{
				if ( EffectDoesExist( pulseVFX ) )
				{
					EffectStop( pulseVFX, false, true )
				}

				if ( IsValid( player ) )
				{
					StopSoundOnEntity( player, HEARTBEAT_SENSOR_ACTIVE_SOUND_1P )
				}

				Minimap_SetVisiblityCone( false, GetHeartbeatSensorRange( player ), $"rui/hud/minimap/minimap_seer_tac_cone", GetKeyColor( COLORID_ENEMY ) )
			}
		)

		WaitForever()
	}
}
#endif //CLIENT

void function DeactivateHeartbeatSensor( entity player, bool fromTac )
{
	player.Signal("DeactivateHeartbeatSensor")

	#if CLIENT
		if ( player == GetLocalViewPlayer() )
		{
			//The zoomout callback (which destroys the UI) happens before deactivate, so we need to check to make sure that the UI is still valid
			//But a player can still toggle the heartbeat sensor while in ADS in which case the RUI is still valid.
			if ( file.heartbeatSensorRui != null )
			{
				RuiSetBool( file.heartbeatSensorRui, "heartbeatSensorEnabled", false )

				if ( fromTac )
				{
					RuiSetBool( file.heartbeatSensorRui, "heartbeatSensorADSOverride", false )
				}
			}

			//Zoom out callback not called while spectating joining Valk ult which usually triggers this signal.
			if ( IsSpectating() )
			{
				player.Signal("EndHeartbeatSensorUI")
			}

			player.Signal( "EndHeartbeatSensorVictimManager" )

			if ( file.heartbeatsHeardWhileActive > 0 && !IsSpectating() )
			{
				player.ClientCommand( "HeartbeatSensor_UpdateStat " + file.heartbeatsHeardWhileActive )
			}
		}
		else
		{
			StopSoundOnEntity( player, HEARTBEAT_SENSOR_ACTIVE_SOUND_3P )
			if ( player in file.heartbeatSensorEyeVFX )
			{
				if ( EffectDoesExist( file.heartbeatSensorEyeVFX[player] ) )
				{
					EffectStop( file.heartbeatSensorEyeVFX[player], false, true )
					delete file.heartbeatSensorEyeVFX[player]
				}
			}
		}
	#endif //CLIENT
}

#if CLIENT
void function ManageVictims_Thread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "EndHeartbeatSensorVictimManager" )
	player.EndSignal( "DestroyHeartbeatSensor" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( player )
		{
			file.heartbeatSensorVictims.clear()
		}
	)

	while ( true )
	{
		#if DEVELOPER
			if ( HEARTBEAT_SENSOR_DEBUG_VERBOSE )
			{
				//DebugDrawSphere( player.EyePosition(), GetHeartbeatSensorRange( player ), <255, 0, 0>, true, 0.1 )
				//DebugDrawCylinder( player.EyePosition(), < -90, 0, 0 >, GetHeartbeatSensorRange( player ), 750, <255, 0, 0>, true, 0.1 )
			}
		#endif //DEV
		float viewportFOV = GetCurrentPlayerFOV( player )


		//The idea here is to scale how far we actually look for enemies based on zoom fov (scope).  Previously we just had a big value to cover all cases (IE if they have a 10x zoom) but that can lead to weirdness where you can hit some LOS hits on someone really far away from you with a 1x scope.
		float watchRange = GraphCapped( viewportFOV, HEARTBEAT_SENSOR_MIN_ZOOM_FOV, HEARTBEAT_SENSOR_MAX_ZOOM_FOV, HEARTBEAT_SENSOR_MIN_WATCH_RANGE, HEARTBEAT_SENSOR_MAX_WATCH_RANGE )

		#if DEVELOPER
			if ( HEARTBEAT_SENSOR_DEBUG )
			{
				printt("viewportFOV: " + viewportFOV + " watchRange: " + watchRange)
				//DebugDrawArrow( player.EyePosition(), player.EyePosition() + ( player.GetViewVector() * watchRange ), 10, <255, 0, 0>, true, 0.1)
			}
		#endif //DEV

		// Get nearby enemy players and NPCs
		array<entity> nearbyPlayers = GetPlayerArrayEx( "any", TEAM_ANY, player.GetTeam(), player.GetOrigin(), watchRange )
		array<entity> nearbyNPCs = GetNPCArrayEx( "any", TEAM_ANY, player.GetTeam(), player.GetOrigin(), watchRange )
		array<entity> allTargets = nearbyPlayers
		allTargets.extend( nearbyNPCs )

		array<PlayersInViewInfo> victimsInfo
		array<entity> victimsReturned

		float minDot = deg_cos( viewportFOV )

		// Process all nearby targets and filter by view direction
		foreach ( entity target in allTargets )
		{
			if ( !IsValid( target ) )
				continue

			if ( IsFriendlyTeam( target.GetTeam(), player.GetTeam() ) )
				continue

			PlayersInViewInfo ornull data = GeneratePlayersInViewInfo( player, target, minDot, watchRange )

			if ( data != null )
			{
				victimsInfo.append( expect PlayersInViewInfo( data ) )
			}
		}

		// Handle decoys separately
		array<entity> decoys = GetEntArrayByScriptName( DECOY_SCRIPTNAME )
		decoys.extend( GetEntArrayByScriptName( CONTROLLED_DECOY_SCRIPTNAME ) )

		foreach ( entity decoy in decoys )
		{
			if ( !IsValid( decoy ) )
				continue

			if ( IsFriendlyTeam( decoy.GetTeam(), player.GetTeam() ) )
				continue

			PlayersInViewInfo ornull data = GeneratePlayersInViewInfo( player, decoy, minDot, watchRange )

			if ( data != null )
			{
				victimsInfo.append( expect PlayersInViewInfo( data ) )
			}
		}

		float bestDot = -1.0
		entity bestVictimForAudio = null

		foreach ( PlayersInViewInfo victimInfo in victimsInfo )
		{
			victimsReturned.append( victimInfo.player )

			if ( victimInfo.player in file.victimPlayerViewportInfo )
			{
				file.victimPlayerViewportInfo[victimInfo.player] = victimInfo
			}
			else
			{
				file.victimPlayerViewportInfo[victimInfo.player] <- victimInfo
			}

			if ( !file.heartbeatSensorVictims.contains( victimInfo.player ) )
			{
				HeartseekerAddWatchTarget( victimInfo, watchRange )
			}

			if ( victimInfo.dot > bestDot && victimInfo.distanceSqr <= GetHeartbeatSensor_Range_Sqr( player ) )
			{
				bestDot = victimInfo.dot
				bestVictimForAudio = victimInfo.player
			}

			#if DEVELOPER
			if ( HEARTBEAT_SENSOR_DEBUG )
			{
				//DebugDrawMark( victimInfo.player.GetWorldSpaceCenter(), 15, <255, 0, 0>, true, 0.1 )
			}
			#endif //DEV
		}

		#if DEVELOPER
			if ( HEARTBEAT_SENSOR_DEBUG )
			{
				if ( IsValid( bestVictimForAudio ) )
				{
					//DebugDrawMark( bestVictimForAudio.EyePosition(), 25, <0, 255, 0>, true, 0.1 )
				}
			}
		#endif //DEV
		file.bestVictimForAudio = bestVictimForAudio

		foreach ( entity victim in file.heartbeatSensorVictims )
		{
			if ( !victimsReturned.contains( victim ) )
			{
				victim.Signal( "StopWatchingHeartbeatSensorVictim" )
				file.heartbeatSensorVictims.fastremovebyvalue( victim )
			}
		}

		wait 0.1
	}
}

PlayersInViewInfo ornull function GeneratePlayersInViewInfo( entity player, entity target, float minDot, float watchRange )
{
	if ( !IsValid( target ) )
		return null

	float dot = DotProduct( Normalize( target.GetWorldSpaceCenter() - player.EyePosition() ), player.GetViewVector() )
	float watchRangeSqr = pow( watchRange, 2 )
	float distanceSqr = DistanceSqr( player.EyePosition(), target.GetWorldSpaceCenter() )

	if ( dot < minDot )
		return null

	if ( distanceSqr > watchRangeSqr )
		return null

	PlayersInViewInfo data
	data.player = target
	data.dot = dot
	data.distanceSqr = DistanceSqr( player.EyePosition(), target.GetWorldSpaceCenter() )

	TraceResults trace = TraceLine( player.EyePosition(), target.GetWorldSpaceCenter(), null, TRACE_MASK_BLOCKLOS, TRACE_COLLISION_GROUP_NONE )
	data.hasLOS = ( trace.fraction >= 0.99 )

	return data
}

void function HeartseekerAddWatchTarget( PlayersInViewInfo victimInfo, float watchRange )
{
	float watchRangeSqr = pow( watchRange, 2 )
	entity player = GetLocalViewPlayer()
	thread DoVictimHeartbeat_Thread( player, victimInfo.player, watchRangeSqr )
	//thread UpdateVictimUIPosition_Thread( player, victimInfo.player, watchRangeSqr )
}

void function DoVictimHeartbeat_Thread( entity player, entity victim, float watchRangeSqr )
{
	Assert( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "DestroyHeartbeatSensor" )
	player.EndSignal( "EndHeartbeatSensorVictimManager" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	victim.EndSignal( "OnDestroy" )
	victim.EndSignal( "OnDeath" )
	victim.EndSignal( "StopWatchingHeartbeatSensorVictim" )

	file.heartbeatSensorVictims.append( victim )

	OnThreadEnd(
		function() : ( victim )
		{
			if ( file.heartbeatSensorVictims.contains( victim ) )
			{
				file.heartbeatSensorVictims.removebyvalue( victim )
			}
			if ( victim in file.waveformRadialValueTable )
			{
				delete file.waveformRadialValueTable[victim]
			}
		}
	)

	//If we suddenly have a bunch of targets start being watched they won't all have the same interval for their heartbeats
	float randomWait = RandomFloatRange( HEARTBEAT_SENSOR_STARTUP_TARGET_DELAY_MIN, HEARTBEAT_SENSOR_STARTUP_TARGET_DELAY_MAX )
	wait randomWait

	while ( true )
	{
		int victimHealth = Bleedout_IsBleedingOut( victim ) ? 25 : victim.GetHealth()
		float healthPercent = float( victimHealth ) / float(victim.GetMaxHealth())

		if ( victim.IsPlayerDecoy() )
		{
			entity decoyOwner = victim.GetOwner()
			if ( IsValid( decoyOwner ) )
			{
				victimHealth = decoyOwner.GetHealth()
				int decoyOwnerMaxHealth = decoyOwner.GetMaxHealth()

				if ( victimHealth > 0 && decoyOwnerMaxHealth > 0 )
					healthPercent = float( victimHealth ) / float( decoyOwnerMaxHealth )
				else //R5DEV-379843 - Guard against a decoy owner returning 0 for health or max health, just treat the decoy as full health then for this edge case.
					healthPercent = 1.0

			}
		}


		float scaledWait = Graph( healthPercent, 0.0, 1.0, HEARTBEAT_SENSOR_PING_INTERVAL_MIN, HEARTBEAT_SENSOR_PING_INTERVAL_MAX )
		float beatSoundTime = 0.0

		bool playAudio = IsValid( file.bestVictimForAudio ) ? victim == file.bestVictimForAudio : false

		if ( file.heartbeatSensorRui != null )
		{
			PlayersInViewInfo data = file.victimPlayerViewportInfo[victim]

			bool inTacRange = IsVicitmInTacRange( data )

			if ( inTacRange )
			{
				if ( playAudio )
				{
					file.heartbeatsHeardWhileActive++
					if ( GetConVarBool( "player_setting_enable_heartbeat_sounds" ) )
					{
						EmitSoundOnEntity( victim, HEARTBEAT_SENSOR_HEARTBEAT_SOUND_3P )
						file.lastHeardHeartbeatTime = Time()
					}
				}

				UpdateDataForHeartseekerRadarWaveformRadial( player, victim, true, false )

				wait HEARTBEAT_SOUND_BAR_WAIT_TIME

				UpdateDataForHeartseekerRadarWaveformRadial( player, victim, true, false)
				beatSoundTime = HEARTBEAT_SOUND_BAR_WAIT_TIME
			}
			else if ( data.hasLOS )
			{
				UpdateDataForHeartseekerRadarWaveformRadial( player, victim, false, false )

				wait HEARTBEAT_SOUND_BAR_WAIT_TIME

				UpdateDataForHeartseekerRadarWaveformRadial( player, victim, false, false )
				beatSoundTime = HEARTBEAT_SOUND_BAR_WAIT_TIME
			}
			else if ( victim in file.waveformRadialValueTable )
			{
				delete file.waveformRadialValueTable[victim]
			}
		}

		wait scaledWait - beatSoundTime
	}
}

/*void function UpdateVictimUIPosition_Thread( entity player, entity victim, float watchRangeSqr )
{
	Assert( IsNewThread(), "Must be threaded off." )
	player.EndSignal( "DestroyHeartbeatSensor" )
	player.EndSignal( "EndHeartbeatSensorVictimManager" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	victim.EndSignal( "OnDestroy" )
	victim.EndSignal( "OnDeath" )
	victim.EndSignal( "StopWatchingHeartbeatSensorVictim" )

	while ( true )
	{
		if ( file.heartbeatSensorRui != null )
		{
			PlayersInViewInfo data = file.victimPlayerViewportInfo[victim]
			bool inTacRange = IsVicitmInTacRange( data )

			if ( inTacRange || data.hasLOS )
			{
				UpdateDataForHeartseekerRadarWaveformRadial( player, victim, inTacRange, true )
			}
		}

		wait TICK_RATE
	}
}*/

bool function IsVicitmInTacRange( PlayersInViewInfo data )
{
	if ( data.distanceSqr <= GetHeartbeatSensor_Range_Sqr( GetLocalViewPlayer() ) )
		return true

	return false
}

void function UpdateDataForHeartseekerRadarWaveformRadial( entity player, entity victim, bool inTacRange, bool distPercentOverride=false )
{
	bool isLocked = false

	//determine if the tactical would hit this target
	if ( inTacRange )
	{
		vector startPos 		  = player.GetAttachmentOrigin( player.LookupAttachment( "CHESTFOCUS" ) ) + ( player.GetViewVector() * SONIC_BLAST_IN_FRONT_START_DISTANCE )
		vector blastVector        = startPos + (player.GetViewVector() * GetSonicBlastRange( player ) )
		vector blastVecNormalized = Normalize( blastVector - player.GetWorldSpaceCenter() )
		isLocked = ShouldBlastHitVictim( startPos, blastVector, blastVecNormalized, victim, player.GetTeam() )
	}
	else
	{
		//For the out of tac range UI, when really far away the blast hit calc gets to be really small (IE the target has to be almost exactly under the crosshair).
		//So instead going to try lighting up the centre of the reticle if the target is inside of it (hopefully help with locating them at long ranges?)
		UISize screenSize = GetScreenSize()
		entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
		float offset = GetHeartbeatSensorUISizeForWeapon( player, activeWeapon, screenSize )
		ScreenSpaceData data = GetScreenSpaceData( player, victim.GetWorldSpaceCenter() )

		//pythagorean theorem ftw
		float distOnScreen = sqrt( pow( data.deltaCenterX, 2 ) + pow( data.deltaCenterY, 2 ) )

		//our offset needs to scale for res
		int screenWidth          = screenSize.width
		//RUI Res is defined as 1920x1080.  Offset is a pixel value, but the centre circle of the heartbeat Sensor UI is scaled to 0.6 of the overall RUI element inside the RUIEditor.  0.6 left us too small here, but 0.75 seems to be just right.
		float scale = offset/1920.0 * 0.75
		float scaledOffsetVal = screenWidth * scale

		if ( distOnScreen <= scaledOffsetVal )
		{
			isLocked = true
		}
	}

	BarData data
	bool isInTable = victim in file.waveformRadialValueTable

	if ( isInTable )
	{
		data =  file.waveformRadialValueTable[victim]
	}

	if( !distPercentOverride || !isInTable )
	{
		data.lastGameTimeBeat = Time()
	}
	data.inTacRange = inTacRange
	data.isLocked = isLocked
	file.waveformRadialValueTable[victim] <- data

	return
}
#endif //CLIENT

/**********************************************************************************************************************
UI Functions
**********************************************************************************************************************/
#if CLIENT
void function CL_HeartSeekerRUIThread( entity player, entity weapon )
{
	Assert( IsNewThread(), "Must be threaded off." )

	if ( !IsValid( player ) || !IsValid( weapon ) )
		return

	player.EndSignal( "OnDestroy" )
	player.EndSignal( "DestroyHeartbeatSensor" )
	player.EndSignal( "EndHeartbeatSensorUI" )
	weapon.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( player )
		{
			if(	file.heartbeatSensorRui != null )
			{
				RuiSetGameTime( file.heartbeatSensorRui, "endTime", Time() )
				file.heartbeatSensorRui = null
			}
		}
	)

	UISize screenSize = GetScreenSize()
	float offset = GetHeartbeatSensorUISizeForWeapon( player, weapon, screenSize )

	#if DEVELOPER
	if ( HEARTBEAT_SENSOR_DEBUG )
	{
		printt( "Weapon name: " + weapon.GetWeaponClassName() + "optic: " + weapon.w.activeOptic + " FOV - " + weapon.GetWeaponZoomFOV() + " Offset: " + offset )
	}
	#endif //DEV

	float fireRate = weapon.GetWeaponSettingFloat( eWeaponVar.fire_rate )
	float weaponFireDelay = 1.0

	if ( fireRate > 0 )
	{
		weaponFireDelay = 1.0 / fireRate
	}

	//0.3 + rate of fire delay with the first 1/2 of that being turned off completely (in RUI) feels pretty good.
	weaponFireDelay += 0.3

	RuiSetFloat( file.heartbeatSensorRui, "weaponFireDelay", weaponFireDelay )
	RuiSetFloat( file.heartbeatSensorRui, "offset", offset )
	RuiSetFloat( file.heartbeatSensorRui, "heartbeatSensorNaturalRange", GetHeartbeatSensorRange( player ) )
	RuiSetFloat2( file.heartbeatSensorRui, "screenSize", <screenSize.width, screenSize.height, 0> )

	RuiTrackGameTime( file.heartbeatSensorRui, "lastFireTime", weapon, RUI_TRACK_WEAPON_LAST_PRIMARY_ATTACK_TIME )
	RuiTrackFloat( file.heartbeatSensorRui, "bleedoutEndTime", player, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndexSafe( "bleedoutEndTime" ) )
	RuiTrackFloat( file.heartbeatSensorRui, "reviveEndTime", player, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndexSafe( "reviveEndTime" ) )

	bool lastTargetsInRange = false

	while ( true )
	{
		bool isSilenced = ( StatusEffect_HasSeverity( player, eStatusEffect.silenced ) )
		RuiSetBool( file.heartbeatSensorRui, "isSilenced", isSilenced )

		bool targetsInRange = false
		int i = 0
		float fastestDeltaBeatTime = FLT_MAX

		foreach ( entity victim, BarData data in file.waveformRadialValueTable )
		{
			if ( file.heartbeatSensorRui != null )
			{
				RuiSetFloat3( file.heartbeatSensorRui, "target" + (i + 1), victim.GetWorldSpaceCenter() )
				RuiSetFloat( file.heartbeatSensorRui, "target" + (i + 1) + "GameTimeBeat",  data.lastGameTimeBeat )
				RuiSetBool( file.heartbeatSensorRui, "target" + (i + 1) + "Locked",  data.isLocked )
			}

			targetsInRange = targetsInRange || data.inTacRange

			if ( data.inTacRange )
			{
				float deltaBeatTime = ( Time() - data.lastGameTimeBeat ) //+ HEARTBEAT_SOUND_BAR_WAIT_TIME

				if ( deltaBeatTime < fastestDeltaBeatTime )
					fastestDeltaBeatTime = deltaBeatTime
			}

			i++
			if( i == MAX_HEARTBEAT_SENSOR_TARGETS )
				break
		}

		//clearing out old data on targets that no longer exist
		for(int j = i; j < MAX_HEARTBEAT_SENSOR_TARGETS; j++)
		{
			if ( file.heartbeatSensorRui != null )
			{
				RuiSetFloat( file.heartbeatSensorRui, "target" + (j + 1) + "GameTimeBeat", -1 )
				RuiSetBool( file.heartbeatSensorRui, "target" + (j + 1) + "Locked", false )
			}
		}

		if ( targetsInRange )
		{
			//from heartbeat_sensor_waveform_radial they use 1.52 to set alpha - float diff = (sys.gameTime - lastGameTime) / 1.52 ------- centerBeatIntensity = ClampRadial(centerBeatIntensity - diff, 0.0, MAX_INTENSITY)
			vector lerpedColor = GraphCappedVector( fastestDeltaBeatTime, 0.0, 1.52 - HEARTBEAT_SOUND_BAR_WAIT_TIME, GetKeyColor( COLORID_ENEMY ), GetKeyColor( COLORID_ENEMY ) )
			Minimap_SetVisiblityConeColor( lerpedColor )
		}
		else
		{
			if ( lastTargetsInRange != targetsInRange )
			{
				Minimap_SetVisiblityConeColor( GetKeyColor( COLORID_ENEMY ) )
			}
		}

		lastTargetsInRange = targetsInRange

		WaitFrame()
	}
}

float function GetHeartbeatSensorUISizeForWeapon( entity player, entity weapon, UISize screenSize )
{
	float size = 84

	if ( !IsValid( weapon ) )
		return size

	int slot = GetSlotForWeapon( player, weapon )

	if ( slot >= 0 )
		weapon.w.activeOptic = SURVIVAL_GetWeaponAttachmentForPoint( player, slot, "sight" )
	else
		weapon.w.activeOptic = ""

	#if DEVELOPER
		if ( HEARTBEAT_SENSOR_DEBUG )
		{
			printt(FUNC_NAME() + ": looking up offset value for optic: " + weapon.w.activeOptic )
		}
	#endif //DEV

	int screenWidth          = screenSize.width
	int screenHeight         = screenSize.height

	float defaultAR = 16.0/9.0
	float currentAR = float(screenWidth)/float(screenHeight)

	//fix for ultrawide, if ultrawide we'll want to scale down a bit more to keep the width relatively the same across ARs
	float scaledAR = defaultAR/currentAR

	#if DEVELOPER
		if ( HEARTBEAT_SENSOR_DEBUG )
		{
			printt( FUNC_NAME() + " - ScaledAR: " + scaledAR )
		}
	#endif

	//TODO - Move this to a CSV datatable?
	switch ( weapon.w.activeOptic )
	{
		case "":	//ironsights
			size = 84
			break
		case "optic_cq_threat":
		case "optic_cq_hcog_classic":
		case "optic_cq_holosight":
		case "optic_cq_hcog_bruiser":
		case "optic_cq_holosight_variable":
		case "optic_ranged_hcog":
		case "optic_ranged_aog_variable":
		case "optic_sniper":
		case "optic_sniper_threat":
			size = 84
			break
		case "optic_sniper_variable":
			size = 110
			break
		default:
			Warning( "Heartbeat Sensor HUD rui: unhandled optic " + weapon.w.activeOptic + ". Falling back on default offset." )
			size = 84
	}

	size *= scaledAR

	switch ( weapon.GetWeaponClassName() )
	{
		case "mp_weapon_semipistol":
		case "mp_weapon_wingman":
		case "mp_weapon_shotgun_pistol":
			if ( weapon.w.activeOptic == "" )
			{
				size *= 0.9
			}
			else
			{
				size *= 0.75
			}
			break
		default:
			break
	}

	return size
}
#endif //CLIENT

float function GetHeartbeatSensorRange( entity player )
{
	float result = GetCurrentPlaylistVarFloat( "seer_passive_range", HEARTBEAT_SENSOR_NATURAL_RANGE ) / INCHES_TO_METERS

	if( !IsValid( player ) )
		return result

	if( !player.IsPlayer() )
		return result


		if( PlayerHasPassive( player, ePassives.PAS_PAS_UPGRADE_ONE ) ) // upgrade_seer_sensor_range_extension
		{
			result = GetCurrentPlaylistVarFloat( "seer_passive_extended_range_upgraded", HEARTBEAT_SENSOR_NATURAL_RANGE_UPGRADE ) / INCHES_TO_METERS
		}


	return result
}

float function GetHeartbeatSensor_Range_Sqr( entity player )
{
	float result = file.heartbeatSensorRangeSqr

	if( !IsValid( player ) )
		return result

	if( !player.IsPlayer() )
		return result


		if( PlayerHasPassive( player, ePassives.PAS_PAS_UPGRADE_ONE ) ) // upgrade_seer_sensor_range_extension
		{
			result = pow( GetHeartbeatSensorRange( player ), 2 )
		}


	return result
}