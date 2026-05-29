global function MpAbilityPortableAutoLoader_Init
global function IsBallisticUltActive
global function DoesPlayerHaveAutoLoaderBuff
global function OnWeaponAttemptOffhandSwitch_portableAutoLoader
global function OnWeaponTossReleaseAnimEvent_ability_portable_auto_loader
global function OnWeaponActivate_ability_portable_auto_loader

const float AUTO_LOADER_DURATION = 30.0
const float AUTOLOADER_RANGE = 256.0
const vector AUTOLOADER_START_EFFECT_COLOR = <134, 182, 255>
const float AUTOLOADER_START_EFFECT_SIZE = 768.0

const float AUTOLOADER_SPEEDBOOST_SEVERITY = 0.075

const float MAX_DISTANCE = 3620 * 3620
const float ADDITIONAL_TIME = 5.0

int COCKPIT_AUTO_LOADER_SCREEN_FX
const asset AUTO_LOADER_1P_SCREEN_FX = $"P_clbr_ulti_screen"

const asset AUTO_LOADER_FLASH_FX = $"P_clbr_ulti_backpack_init"
const asset AUTO_LOADER_AURA_FX = $"P_clbr_ulti_buff_body"
const asset AUTO_LOADER_BEAM_FX = $"P_clbr_ulti_backpack_connect"
const asset AUTO_LOADER_BEAM_FX_INIT = $"P_clbr_ulti_backpack_cnct_init"

const asset AUTO_LOADER_BACKPACK_ARM_IDLE_L = $"P_clbr_ulti_backpack_arm_idle_l"
const asset AUTO_LOADER_BACKPACK_ARM_IDLE_R = $"P_clbr_ulti_backpack_arm_idle_r"
const asset AUTO_LOADER_BACKPACK_JET_IDLE = $"P_clbr_ulti_backpack_jet_idle"

const string BALLISTIC_ULT_ACTIVATED_1P = "Ballistic_Ult_Activate_1P"
const string BALLISTIC_ULT_ACTIVATED_3P_FRIENDLY = "Ballistic_Ult_Activate_3P_Friendly"
const string BALLISTIC_ULT_ACTIVATED_3P_ENEMY = "Ballistic_Ult_Activate_3P_Enemy"
const string BALLISTIC_ULT_DEACTIVATED_1P = "Ballistic_Ult_Deactivate_1P"
const string BALLISTIC_ULT_DEACTIVATED_3P_FRIENDLY = "Ballistic_Ult_Deactivate_3P_Friendly"
const string BALLISTIC_ULT_DEACTIVATED_3P_ENEMY = "Ballistic_Ult_Deactivate_3P_Enemy"
const string BALLISTIC_ULT_TEAMMATE_DEACTIVATED_3P_FRIENDLY = "Ballistic_Ult_Deactivate_Teammate_3P"
const string BALLISTIC_ULT_TEAMMATE_DEACTIVATED_3P_ENEMY = "Ballistic_Ult_Deactivate_Teammate_3P"
const string BALLISTIC_ULT_ENDING_SOON_1P = "Ballistic_Ult_5SecRemaining_1P"
const string BALLISTIC_ULT_TIME_ADDED = "Ballistic_Ult_TimeAdded_1P"
const string BALLISTIC_FRIEDNLY_NOTIFY_1P = "Ballistic_Ult_Activate_Teammate_1P"
const string BALLISTIC_FRIEDNLY_NOTIFY_3P = "Ballistic_Ult_Activate_Teammate_3P"
const string BALLISTIC_FRIENDLY_BUFF_DEACTIVATE = "Ballistic_Ult_Deactivate_Teammate_1P"

const string BALLISTIC_ULT_ACTIVE_NETVAR = "ballisticUltIsActive"

struct
{
	float autoLoaderDuration
	float additionalTime
} file

void function MpAbilityPortableAutoLoader_Init()
{
	PrecacheParticleSystem( AUTO_LOADER_1P_SCREEN_FX )
	COCKPIT_AUTO_LOADER_SCREEN_FX = PrecacheParticleSystem( AUTO_LOADER_1P_SCREEN_FX )
	PrecacheParticleSystem( AUTO_LOADER_FLASH_FX )
	PrecacheParticleSystem( AUTO_LOADER_AURA_FX )
	PrecacheParticleSystem( AUTO_LOADER_BEAM_FX )
	PrecacheParticleSystem( AUTO_LOADER_BACKPACK_ARM_IDLE_L )
	PrecacheParticleSystem( AUTO_LOADER_BACKPACK_ARM_IDLE_R )
	PrecacheParticleSystem( AUTO_LOADER_BACKPACK_JET_IDLE )
	PrecacheParticleSystem( AUTO_LOADER_BEAM_FX_INIT )

	RegisterSignal( "AutoLoaderEnded" )
	RegisterSignal( "EndUltBackpackVFX" )

	RegisterNetworkedVariable( BALLISTIC_ULT_ACTIVE_NETVAR, SNDC_PLAYER_GLOBAL, SNVT_BOOL )

	file.autoLoaderDuration = GetCurrentPlaylistVarFloat( "ballistic_ult_auto_loader_duration", AUTO_LOADER_DURATION )
	file.additionalTime = GetCurrentPlaylistVarFloat( "ballistic_ult_additional_time", ADDITIONAL_TIME )

	#if SERVER
		AddCallback_OnPlayerKilled( OnKilledWithAutoLoaderBuff )
		Bleedout_AddCallback_OnPlayerStartBleedout( OnKnockedWithAutoLoaderBuff )
	#endif

	#if CLIENT
		RegisterConCommandTriggeredCallback( "+offhand4", AttemptSwapToSlingWhileUltIsActive )
		StatusEffect_RegisterEnabledCallback( eStatusEffect.has_auto_loader, AutoLoaderScreenVFXEnabled )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.has_auto_loader, AutoLoaderScreenVFXDisabled )
		RegisterNetVarBoolChangeCallback( BALLISTIC_ULT_ACTIVE_NETVAR, OnBallisticUltStatusChange )
	#endif
}

void function OnWeaponActivate_ability_portable_auto_loader( entity weapon )
{
	#if SERVER
		entity player = weapon.GetWeaponOwner()
		PlayBattleChatterLineToSpeakerAndTeam( player, "bc_super" )
	#endif
}

bool function IsBallisticUltActive( entity player )
{
	return player.GetPlayerNetBool( BALLISTIC_ULT_ACTIVE_NETVAR )
}

bool function DoesPlayerHaveAutoLoaderBuff( entity player )
{
	return StatusEffect_HasSeverity( player, eStatusEffect.has_auto_loader )
}

                    
float function GetUpgradedTempestRangeMultiplier()
{
	return GetCurrentPlaylistVarFloat( "tempest_range_upgraded_multiplier", 50.0 )
}
      

float function GetAutoLoaderVFXRange( entity player )
{
	float result = AUTOLOADER_RANGE
	                    
		if( PlayerHasPassive( player, ePassives.PAS_ULT_UPGRADE_ONE ) ) // upgrade_ballistic_ult_range
		{
			result *= GetUpgradedTempestRangeMultiplier()
		}
       
	return result
}

float function GetAutoLoaderRange( entity player )
{
	float result = MAX_DISTANCE
	                    
		if( PlayerHasPassive( player, ePassives.PAS_ULT_UPGRADE_ONE ) ) // upgrade_ballistic_ult_range
		{
			result *= GetUpgradedTempestRangeMultiplier()
		}
       
	return result
}

bool function OnWeaponAttemptOffhandSwitch_portableAutoLoader( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	if( IsBallisticUltActive( player ) )
		return false

	return true
}

var function OnWeaponTossReleaseAnimEvent_ability_portable_auto_loader( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if SERVER
		int backpackChargeParam = ownerPlayer.LookupPoseParameterIndex( "characterScriptParam" )
		ownerPlayer.SetPoseParameter( backpackChargeParam, 1.0 )

		thread AutoLoader_Deploy( ownerPlayer, weapon )
		TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_BALLISTIC_PORTABLE_AUTO_LOADER, ownerPlayer, ownerPlayer.GetOrigin(), ownerPlayer.GetTeam(), ownerPlayer )
	#endif

	PlayerUsedOffhand( ownerPlayer, weapon )

	int ammoReq = weapon.GetAmmoPerShot()
	return ammoReq
}

#if SERVER
void function AutoLoader_Deploy( entity player, entity weapon )
{
	if ( !IsValid( player ) )
		return

	EndSignal( player, "OnDeath", "OnDestroy", "AutoLoaderEnded", "BleedOut_OnStartDying" )

	int team = player.GetTeam()

	EmitSoundOnEntityOnlyToPlayer( player, player, BALLISTIC_ULT_ACTIVATED_1P )
	EmitSoundOnEntityToTeamExceptPlayer( player, BALLISTIC_ULT_ACTIVATED_3P_FRIENDLY, team, player )
	EmitSoundOnEntityToEnemies( player, BALLISTIC_ULT_ACTIVATED_3P_ENEMY, team )

	player.SetPlayerNetBool( BALLISTIC_ULT_ACTIVE_NETVAR, true )

	thread ConvertSlingWeaponToGold( player )

	if( !DoesPlayerHaveAutoLoaderBuff( player ) )
	{
		thread AutoLoader_CreatePlayerEffects( player )
		thread AutoLoader_ApplyTeammateBuff_Think( player, player, file.autoLoaderDuration )
	}

	OnThreadEnd(
		function() : ( player, team )
		{
			thread TurnoffBackpackFX( player )

			EmitSoundOnEntityOnlyToPlayer( player, player, BALLISTIC_ULT_DEACTIVATED_1P )
			EmitSoundOnEntityToTeamExceptPlayer( player, BALLISTIC_ULT_DEACTIVATED_3P_FRIENDLY, team, player )
			EmitSoundOnEntityToEnemies( player, BALLISTIC_ULT_DEACTIVATED_3P_ENEMY, team )

			player.SetPlayerNetBool( BALLISTIC_ULT_ACTIVE_NETVAR, false )

			if ( !IsPlayerWeaponSlingEmpty( player ) )
			{
				entity slingWeapon = GetPlayerSlingWeapon( player )
				bool shouldSetSlingActive = slingWeapon == player.GetActiveWeapon( eActiveInventorySlot.mainHand )
				int ammoLeftInClip = slingWeapon.GetWeaponPrimaryClipCount()
				float energizedDuration = 0.0//slingWeapon.GetEnergizedEndTime()
				bool hasBeenEnergized = slingWeapon.HasMod( "energized" )

				string slingRef = slingWeapon.GetWeaponClassName()
				Assert( slingRef != "", "Empty sling ref when player ending auto loader with a sling weapon in sling" )

				bool hasAltAmmoMod = false
				if ( slingWeapon.HasMod( "alt_ammo" ))
				{
					hasAltAmmoMod = true
				}

				slingWeapon.ForceChargeEndNoAttack()

				player.TakeWeaponByEntNow( slingWeapon )

				GivePlayerSlingWeaponByRef( player, GetStoredPreSlingWeaponRefForPlayer( player ), shouldSetSlingActive, ammoLeftInClip, hasAltAmmoMod )
				
				if ( hasBeenEnergized )
				{
					entity newSlingWeapon = GetPlayerSlingWeapon( player )
					//Force energized on first pickup
					newSlingWeapon.AddMod ( "energized" )
					//newSlingWeapon.ForceEnergizeState( ENERGIZE_ENERGIZED )
					//newSlingWeapon.ForceEnergizedEndTime( energizedDuration )
				}
			}

			player.Signal( "AutoLoaderEnded" )
		}
	)

	float timeRemainingOnUlt = StatusEffect_GetTimeRemaining( player, eStatusEffect.has_auto_loader )

	while ( timeRemainingOnUlt > 0 )
	{
		array < entity > teammates = GetPlayerArrayOfTeam( player.GetTeam() )

		foreach ( teammate in teammates )
		{
			if ( !IsValid( teammate ) )
				continue

			if( teammate == player )
				continue

			if ( Bleedout_IsBleedingOut( teammate ) )
				continue

			if ( IsTeamRabid( team ) )
				continue

			float distanceSqr = DistanceSqr( player.GetOrigin(), teammate.GetOrigin() )
			if ( distanceSqr < ( GetAutoLoaderRange( player ) ) && !DoesPlayerHaveAutoLoaderBuff( teammate ) )
			{
				thread WarpBeamFXThread( player, teammate )
				thread AutoLoader_ApplyTeammateBuff_Think( player, teammate, timeRemainingOnUlt )
			}
		}

		WaitFrame()

		timeRemainingOnUlt = StatusEffect_GetTimeRemaining( player, eStatusEffect.has_auto_loader )
	}

	entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	while( IsValid( activeWeapon ) )
	{
		bool IsConsumable = IsBitFlagSet( activeWeapon.GetWeaponTypeFlags(), WPT_CONSUMABLE )
		if( !IsConsumable )
			break

		WaitFrame()

		activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	}

	if ( IsValid( activeWeapon ) )
	{
		entity slingWeapon = GetPlayerSlingWeapon( player )
		if( !IsValid( slingWeapon ) || slingWeapon != activeWeapon )
			return

		while ( IsValid( slingWeapon ) )
		{
			//if( slingWeapon.IsWeaponActivelyFiring() )
			{
				//WaitFrame()
				//continue
			}

			if( slingWeapon.IsReloading() )
			{
				WaitFrame()
				continue
			}

			//else if ( weapon.GetEnergizeState() == ENERGIZE_ENERGIZING )
			{
				//WaitFrame()
			//	continue
			}
			if( IsWeaponSemiAuto( slingWeapon ) )
			{
				//if( slingWeapon.NeedsRechambering() )
				{
					//WaitFrame()
					//continue
				}
			}

			break
		}
	}
}

void function TurnoffBackpackFX( entity player )
{
	WaitEndFrame()
	if( !IsValid( player ) )
		return

	int backpackChargeParam = player.LookupPoseParameterIndex( "characterScriptParam" )
	player.SetPoseParameter( backpackChargeParam, 0.0 )
}

void function ConvertSlingWeaponToGold( entity player )
{
	EndSignal( player, "OnDeath", "OnDestroy", "AutoLoaderEnded", "BleedOut_OnStartDying" )

	while( true )
	{
		entity slingWeapon = GetPlayerSlingWeapon( player )
		if ( IsValid( slingWeapon ) )
		{
			bool hasAltAmmoMod = false
			if ( slingWeapon.HasMod( "alt_ammo" ) )
			{
				hasAltAmmoMod = true
			}

			player.TakeWeaponByEntNow( slingWeapon )

			GivePlayerSlingWeaponByRef( player, GetStoredPreSlingWeaponRefForPlayer( player ), true, -1, hasAltAmmoMod, false )

			entity newSlingWeapon = GetPlayerSlingWeapon( player )

			if( !IsValid( newSlingWeapon ) )
				return

			bool hasEnergized = bool( GetWeaponInfoFileKeyField_GlobalInt_WithDefault( newSlingWeapon.GetWeaponClassName(), "has_energized", 0 ) )
			if ( hasEnergized )
			{
				//Force energized on first pickup
				float energizedDuration = GetWeaponInfoFileKeyField_GlobalFloat( newSlingWeapon.GetWeaponClassName(), "energized_duration" )
				newSlingWeapon.AddMod( "energized" )
				//newSlingWeapon.ForceEnergizeState( ENERGIZE_ENERGIZED )
				//newSlingWeapon.ForceEnergizedEndTime( Time() + energizedDuration )
			}

                                   
                                                                                
     
                                                           
     
         

			return
		}
		WaitFrame()
	}
}

void function WarpBeamFXThread( entity player, entity teammate )
{
	int r_backpiston_fx_AttachmentID = player.LookupAttachment( "r_backpiston_fx" )
	int chestFocus = teammate.LookupAttachment( "CHESTFOCUS" )

	if( r_backpiston_fx_AttachmentID == 0 )
		return

	vector attachPosRight = player.GetAttachmentOrigin( r_backpiston_fx_AttachmentID )
	vector endPos = teammate.GetAttachmentOrigin( chestFocus )

	int l_backpiston_fx_AttachmentID = player.LookupAttachment( "l_backpiston_fx" )

	if( l_backpiston_fx_AttachmentID == 0 )
		return
	
	vector attachPosLeft = player.GetAttachmentOrigin( l_backpiston_fx_AttachmentID )

	entity r_ConnectInit
	entity l_ConnectInit

	int armIdle_r_FxId  = GetParticleSystemIndex( AUTO_LOADER_BEAM_FX_INIT )
	r_ConnectInit = StartParticleEffectOnEntityWithPos_ReturnEntity( player, armIdle_r_FxId, FX_PATTACH_ABSORIGIN_FOLLOW, r_backpiston_fx_AttachmentID, <0,0,0>, <-90,0,-90> )
	r_ConnectInit.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE | ENTITY_VISIBLE_EXCLUDE_PARENT_PLAYER
	r_ConnectInit.SetOwner( player )

	int armIdle_l_FxId  = GetParticleSystemIndex( AUTO_LOADER_BEAM_FX_INIT )
	l_ConnectInit = StartParticleEffectOnEntityWithPos_ReturnEntity( player, armIdle_l_FxId, FX_PATTACH_ABSORIGIN_FOLLOW, l_backpiston_fx_AttachmentID, <0,0,0>, <-90,0,-90> )
	l_ConnectInit.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE | ENTITY_VISIBLE_EXCLUDE_PARENT_PLAYER
	l_ConnectInit.SetOwner( player )

	entity controlPoint = CreateEntity( "info_placement_helper" )
	SetTargetName( controlPoint, UniqueString( "translocation_endPos" ) )
	controlPoint.SetOrigin( endPos )
	CopyRealmsFromTo( player, controlPoint )
	DispatchSpawn( controlPoint )

	entity beamFX = CreateEntity( "info_particle_system" )
	beamFX.SetValueForEffectNameKey( AUTO_LOADER_BEAM_FX )
	beamFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	beamFX.kv.cpoint1         = controlPoint.GetTargetName()
	beamFX.kv.start_active    = 1
	beamFX.SetOrigin( attachPosRight )
	CopyRealmsFromTo( player, beamFX )
	DispatchSpawn( beamFX )

	entity controlPoint2 = CreateEntity( "info_placement_helper" )
	SetTargetName( controlPoint2, UniqueString( "translocation_endPos" ) )
	controlPoint2.SetOrigin( endPos )
	CopyRealmsFromTo( player, controlPoint2 )
	DispatchSpawn( controlPoint2 )

	entity beamFXLeft = CreateEntity( "info_particle_system" )
	beamFXLeft.SetValueForEffectNameKey( AUTO_LOADER_BEAM_FX )
	beamFXLeft.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	beamFXLeft.kv.cpoint1         = controlPoint2.GetTargetName()
	beamFXLeft.kv.start_active    = 1
	beamFXLeft.SetOrigin( attachPosLeft )
	CopyRealmsFromTo( player, beamFXLeft )
	DispatchSpawn( beamFXLeft )

	OnThreadEnd( function () : ( beamFX, controlPoint, beamFXLeft, controlPoint2, l_ConnectInit, r_ConnectInit ) {
		if ( IsValid( beamFX ) )
			beamFX.Destroy()

		if ( IsValid( controlPoint ) )
			controlPoint.Destroy()

		if ( IsValid( beamFXLeft ) )
			beamFXLeft.Destroy()

		if ( IsValid( controlPoint2 ) )
			controlPoint2.Destroy()

		if ( IsValid( l_ConnectInit ) )
			l_ConnectInit.Destroy()

		if ( IsValid( r_ConnectInit ) )
			r_ConnectInit.Destroy()
	} )

	wait 2.0

	return
}

void function AutoLoader_CreatePlayerEffects( entity player )
{
	EndSignal( player, "OnDeath", "OnDestroy", "AutoLoaderEnded", "BleedOut_OnStartDying" )

	entity pulseFx
	entity r_ArmIdleFx
	entity l_ArmIdleFx
	entity r_BackpackIdleFX
	entity l_BackpackIdleFX

	int r_backpiston_fx_AttachmentID = player.LookupAttachment( "r_backpiston_fx" )
	int pulseFxId = GetParticleSystemIndex( AUTO_LOADER_FLASH_FX )
	pulseFx = StartParticleEffectOnEntityWithPos_ReturnEntity( player, pulseFxId, FX_PATTACH_ABSORIGIN_FOLLOW, r_backpiston_fx_AttachmentID, <5,0,0>, <0,0,0> )
	pulseFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	EffectSetControlPointVector( pulseFx, 1, <10.0, GetAutoLoaderVFXRange( player ) / AUTOLOADER_START_EFFECT_SIZE, 0> )
	EffectSetControlPointVector( pulseFx, 2, AUTOLOADER_START_EFFECT_COLOR )
	pulseFx.SetOwner( player )

	int armIdle_r_FxId  = GetParticleSystemIndex( AUTO_LOADER_BACKPACK_ARM_IDLE_R )
	r_ArmIdleFx = StartParticleEffectOnEntityWithPos_ReturnEntity( player, armIdle_r_FxId, FX_PATTACH_ABSORIGIN_FOLLOW, r_backpiston_fx_AttachmentID, <0,0,0>, <-90,0,-90> )
	r_ArmIdleFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE | ENTITY_VISIBLE_EXCLUDE_PARENT_PLAYER
	r_ArmIdleFx.SetOwner( player )

	int l_backpiston_fx_AttachmentID = player.LookupAttachment( "l_backpiston_fx" )
	int armIdle_l_FxId  = GetParticleSystemIndex( AUTO_LOADER_BACKPACK_ARM_IDLE_L )
	l_ArmIdleFx = StartParticleEffectOnEntityWithPos_ReturnEntity( player, armIdle_l_FxId, FX_PATTACH_ABSORIGIN_FOLLOW, l_backpiston_fx_AttachmentID, <0,0,0>, <-90,0,-90> )
	l_ArmIdleFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE | ENTITY_VISIBLE_EXCLUDE_PARENT_PLAYER
	l_ArmIdleFx.SetOwner( player )

	int backpack_r_fx_AttachmentID = player.LookupAttachment( "c_backpack_r_fx" )
	int backpackIdleFxId  = GetParticleSystemIndex( AUTO_LOADER_BACKPACK_JET_IDLE )
	r_BackpackIdleFX = StartParticleEffectOnEntityWithPos_ReturnEntity( player, backpackIdleFxId, FX_PATTACH_ABSORIGIN_FOLLOW, backpack_r_fx_AttachmentID, <0,0,0>, <0,0,0> )
	r_BackpackIdleFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE | ENTITY_VISIBLE_EXCLUDE_PARENT_PLAYER
	r_BackpackIdleFX.SetOwner( player )

	int backpack_l_fx_AttachmentID = player.LookupAttachment( "c_backpack_l_fx" )
	l_BackpackIdleFX = StartParticleEffectOnEntityWithPos_ReturnEntity( player, backpackIdleFxId, FX_PATTACH_ABSORIGIN_FOLLOW, backpack_l_fx_AttachmentID, <0,0,0>, <0,0,0> )
	l_BackpackIdleFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE | ENTITY_VISIBLE_EXCLUDE_PARENT_PLAYER
	l_BackpackIdleFX.SetOwner( player )

	OnThreadEnd(
		function() : ( pulseFx, r_ArmIdleFx, l_ArmIdleFx, r_BackpackIdleFX, l_BackpackIdleFX  )
		{
			if( IsValid( pulseFx ) )
				pulseFx.Destroy()

			if( IsValid( r_ArmIdleFx ) )
				r_ArmIdleFx.Destroy()

			if( IsValid( l_ArmIdleFx ) )
				l_ArmIdleFx.Destroy()

			if( IsValid( r_BackpackIdleFX ) )
				r_BackpackIdleFX.Destroy()

			if( IsValid( l_BackpackIdleFX ) )
				l_BackpackIdleFX.Destroy()
		}
	)

	WaitForever()
}

void function AutoLoader_ApplyTeammateBuff_Think( entity ballisticPlayer, entity teammate, float buffTime )
{
	if ( !IsValid( ballisticPlayer ) )
		return

	if ( !IsValid( teammate ) || !teammate.IsPlayer() )
		return

	if( ballisticPlayer != teammate )
		EndSignal( ballisticPlayer, "OnDeath", "OnDestroy" )
	EndSignal( teammate, "OnDeath", "OnDestroy", "AutoLoaderEnded", "BleedOut_OnStartDying" )

	StatusEffect_AddTimed( teammate, eStatusEffect.has_auto_loader, 1.0, buffTime, 0.5 )

	if ( teammate != ballisticPlayer )
	{
		EmitSoundOnEntityOnlyToPlayer( teammate, teammate, BALLISTIC_FRIEDNLY_NOTIFY_1P )
		EmitSoundOnEntityToTeamExceptPlayer( teammate, BALLISTIC_FRIEDNLY_NOTIFY_3P, teammate.GetTeam(), teammate )
	}


	bool fiveSecondWarningSet = false

	int AttachmentID = teammate.LookupAttachment( "CHESTFOCUS" )
	int fxid         = GetParticleSystemIndex( AUTO_LOADER_AURA_FX )

	entity fxHandle = StartParticleEffectOnEntity_ReturnEntity( teammate, fxid, FX_PATTACH_POINT_FOLLOW, AttachmentID )
	fxHandle.SetOwner( teammate )
	fxHandle.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE

	if( !teammate.p.infiniteGameModeAmmo )
		SetInfiniteAmmoForPlayer( teammate, true, ["crate"], true, true )

	PassByReferenceInt speedBoostHandle
	speedBoostHandle.value = SE_INVALID_HANDLE

	OnThreadEnd(
		function() : ( teammate, fxHandle, ballisticPlayer, speedBoostHandle )
		{
			SetInfiniteAmmoForPlayer( teammate, false, ["crate"], true, true )

			if ( IsValid( fxHandle ) )
				EffectStop( fxHandle )

			StatusEffect_StopAllOfType( teammate, eStatusEffect.has_auto_loader )
			StatusEffect_Stop( teammate, speedBoostHandle.value )
			StopSoundOnEntity( teammate, BALLISTIC_ULT_ENDING_SOON_1P )
			StopSoundOnEntity( teammate, BALLISTIC_FRIEDNLY_NOTIFY_1P )

			if ( teammate != ballisticPlayer )
			{
				EmitSoundOnEntityToTeamExceptPlayer( teammate, BALLISTIC_ULT_TEAMMATE_DEACTIVATED_3P_FRIENDLY, teammate.GetTeam(), teammate )
				EmitSoundOnEntityToEnemies( teammate, BALLISTIC_ULT_TEAMMATE_DEACTIVATED_3P_ENEMY, teammate.GetTeam() )
				EmitSoundOnEntityOnlyToPlayer( teammate, teammate, BALLISTIC_FRIENDLY_BUFF_DEACTIVATE )

				if( IsValid( teammate ) )
					teammate.Signal( "AutoLoaderEnded" )
			}

			array<entity> primaryWeapons = SURVIVAL_GetPrimaryWeaponsIncludingSling( teammate )
			foreach ( weapon in primaryWeapons )
			{
				if ( weapon.HasMod( "auto_loader" ) )
				{
					weapon.RemoveMod( "auto_loader" )
				}
			}
		}
	)

	while ( DoesPlayerHaveAutoLoaderBuff( teammate ) )
	{
		entity weapon = teammate.GetActiveWeapon( eActiveInventorySlot.mainHand )
		if ( IsValid( weapon ) )
		{
			bool isMountedTurret = weapon.GetWeaponClassName() == MOUNTED_TURRET_WEAPON_NAME

			int weaponFlags = weapon.GetWeaponTypeFlags()
			if ( !weapon.IsWeaponOffhand() && weaponFlags == WPT_PRIMARY && !isMountedTurret )
			{
				if ( !weapon.HasMod( "auto_loader" ) )
				{
					weapon.AddMod( "auto_loader" )

					if ( !weapon.w.modsToRemoveOnDrop.contains( "auto_loader" ) )
						weapon.w.modsToRemoveOnDrop.append( "auto_loader" )
				}
			}

			if( speedBoostHandle.value == SE_INVALID_HANDLE && weapon.HasMod( "auto_loader" ) )
			{
				speedBoostHandle.value = StatusEffect_AddEndless( teammate, eStatusEffect.speed_boost, AUTOLOADER_SPEEDBOOST_SEVERITY )
			}
			else if( speedBoostHandle.value != SE_INVALID_HANDLE && !weapon.HasMod( "auto_loader" ) )
			{
				StatusEffect_Stop( teammate, speedBoostHandle.value )
				speedBoostHandle.value = SE_INVALID_HANDLE
			}
		}
		else
		{
			if( speedBoostHandle.value != SE_INVALID_HANDLE )
			{
				StatusEffect_Stop( teammate, speedBoostHandle.value )
				speedBoostHandle.value = SE_INVALID_HANDLE
			}
		}

		float timeRemainingOnUlt = StatusEffect_GetTimeRemaining( teammate, eStatusEffect.has_auto_loader )

		if ( timeRemainingOnUlt < 5.0 && !fiveSecondWarningSet )
		{
			EmitSoundOnEntityOnlyToPlayer( teammate, teammate, BALLISTIC_ULT_ENDING_SOON_1P )
			fiveSecondWarningSet = true
		}
		else if ( timeRemainingOnUlt > 5.0 && fiveSecondWarningSet )
		{
			fiveSecondWarningSet = false
			StopSoundOnEntity( teammate, BALLISTIC_ULT_ENDING_SOON_1P )
		}

		if( teammate.IsCloaked( true ) || teammate.IsPhaseShifted() )
			fxHandle.kv.VisibilityFlags = ENTITY_VISIBLE_TO_NOBODY
		else
			fxHandle.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE

		WaitFrame()
	}
}

void function OnKilledWithAutoLoaderBuff( entity victim, entity attacker, var damageInfo )
{
	if ( !IsValid( attacker ) )
		return

	if( !DoesPlayerHaveAutoLoaderBuff( attacker ) )
		return

	if ( !Bleedout_IsBleedingOut( victim ) )
	{
		ApplyTimeIncreaseToUlt( victim, attacker, damageInfo )
	}
}

void function OnKnockedWithAutoLoaderBuff( entity victim, entity attacker, var damageInfo )
{
	if ( !IsValid( attacker ) )
		return

	if( !DoesPlayerHaveAutoLoaderBuff( attacker ) )
		return

	ApplyTimeIncreaseToUlt( victim, attacker, damageInfo )
}

void function ApplyTimeIncreaseToUlt( entity victim, entity attacker, var damageInfo )
{
	int team = attacker.GetTeam()
	array<entity> teammates = GetPlayerArrayOfTeam_Alive( team )

	foreach ( teammate in teammates )
	{
		if ( DoesPlayerHaveAutoLoaderBuff( teammate ) )
		{
			float timeRemaining = StatusEffect_GetTimeRemaining( teammate, eStatusEffect.has_auto_loader )
			float buffTime      = timeRemaining + file.additionalTime

			StatusEffect_StopAllOfType( teammate, eStatusEffect.has_auto_loader )
			StatusEffect_AddTimed( teammate, eStatusEffect.has_auto_loader, 1.0, buffTime, 0.5 )
			EmitSoundOnEntityOnlyToPlayer( teammate, teammate, BALLISTIC_ULT_TIME_ADDED )

		                           
			Remote_CallFunction_Replay( teammate, "ServerCallback_ShowUltTimeIncreasedHint", teammate, file.additionalTime )
        
		}
	}
}
#endif //SERVER

#if CLIENT
void function OnPrimaryWeaponStatusUpdate_FastReloadIcon( entity player, var weaponRui, bool turnOn )
{
	if( turnOn )
	{
		RuiSetBool( weaponRui, "showPassiveBonusIconAmmo", true )
		RuiSetImage( weaponRui, "passiveBonusIconAmmo", $"rui/hud/character_abilities/icon_caliber_fast_reload_dongle_2x_size" )
		RuiSetBool( weaponRui, "showUltimateBonusWeaponInfo", true )
		RuiSetString( weaponRui, "ultimateBonusWeaponInfoText", Localize( "#MOD_FAST_RELOAD_NAME" ) )
	}
	else
	{
		RuiSetBool( weaponRui, "showPassiveBonusIconAmmo", false )
		RuiSetImage( weaponRui, "passiveBonusIconAmmo", $"" )
		RuiSetBool( weaponRui, "showUltimateBonusWeaponInfo", false )
		RuiSetString( weaponRui, "ultimateBonusWeaponInfoText", "" )
	}
}

void function AttemptSwapToSlingWhileUltIsActive( entity player )
{
	if ( player != GetLocalViewPlayer() || IsPlayerWeaponSlingEmpty( player ) || IsPlayerHoldingSlingWeapon( player ) || !IsBallisticUltActive( player ) )
		return

	AttemptWeaponSlingSwap( player )
}

void function AutoLoaderScreenVFXEnabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged )
		return

	entity viewPlayer = GetLocalViewPlayer()
	if ( ent != viewPlayer )
		return

	thread AutoLoader_1PFX_Thread( viewPlayer )
}

void function AutoLoaderScreenVFXDisabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	ent.Signal( "AutoLoaderEnded" )
}

void function AutoLoader_1PFX_Thread( entity player )
{
	player.EndSignal( "OnDeath", "OnDestroy", "BleedOut_OnStartDying", "AutoLoaderEnded" )

	int fxHandle
	fxHandle = StartParticleEffectOnEntityWithPos( player, COCKPIT_AUTO_LOADER_SCREEN_FX, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, player.EyePosition(), <0, 0, 0> )
	EffectSetIsWithCockpit( fxHandle, true )
	EffectSetControlPointVector( fxHandle, 1, <255, 255, 255> )
	EffectSetControlPointVector( fxHandle, 3, <0.8,0.8,0.8> )

	OnThreadEnd(
		function() : ( fxHandle )
		{
			if ( EffectDoesExist( fxHandle ) )
				EffectStop( fxHandle, false, true )
		}
	)

	for ( ;; )
	{
		if ( !EffectDoesExist( fxHandle ) )
			break

		EffectSetControlPointVector( fxHandle, 1, <1.0, 999, 0> )

		WaitFrame()
	}
}

void function OnBallisticUltStatusChange( entity player, bool ultIsActive )
{
	if( !ultIsActive )
	{
		entity slingWeapon = GetPlayerSlingWeapon( player )
		if( IsValid( slingWeapon ) )
		{
			slingWeapon.ForceChargeEndNoAttack()
		}
	}
}
#endif //CLIENT
