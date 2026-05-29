global function OnWeaponActivate_ability_shadow_form
global function OnWeaponTossReleaseAnimEvent_ability_shadow_form
global function OnWeaponAttemptOffhandSwitch_ability_shadow_form
global function OnWeaponOwnerChanged_ability_shadow_form
global function MpAbilityShadowForm_Init
global function IsInForgedShadows
global function IsForgedShadowsShield
global function ShadowShield_IsAllowedStickyEnt

#if SERVER
global function ShadowForm_ApplyShadowSkin
global function IsForgedShadowShieldActive
#endif
#if CLIENT
global function ServerToClient_UpdateDamageRUI
global function ServerToClient_DoShadowShieldDamageIndicator

global function MpAbilityShadowForm_GetEnableHealFlash
global function MpAbilityShadowForm_IsRecharging
global function MpAbilityShadowForm_PopulateRui
#endif

const string ABILITY_USED_MOD = "ability_used_mod"

global const string FORGED_SHADOWS_SHIELD_NAME = "forged_shadows_shield"

// SFX
const string SHADOW_FORM_ACTIVATE_SOUND_1P = "DeathProtection_Reborn_Activate_1P"
const string SHADOW_FORM_LOOP_SOUND_1P = "DeathProtection_Reborn_Loop_1P"
const string SHADOW_FORM_DEACTIVATE_SOUND_1P = "DeathProtection_Reborn_End_1P"
const string SHADOW_FORM_WINDUP_SOUND_1P = "DeathProtection_Reborn_Windup_1P"
const string SHADOW_FORM_EXPIRATION_WARNING_1P = "DeathProtection_Reborn_WarningToEnd_1p"
const string SHADOW_FORM_COUNTDOWN_SOUND = "TDM_UI_InGame_Countdown"
const string SHADOW_FORM_SHIELD_BREAK_SOUND_1P = "DeathProtection_Reborn_Shield_Broken_1P"
const string SHADOW_FORM_SHIELD_BREAKER_SOUND_1P = "DeathProtection_Reborn_Shield_Broken_1P_Enemy"
const string SHADOW_FORM_SHIELD_RECHARGE_SOUND_1P = "DeathProtection_Reborn_Shield_Recharge_1P"
const string SHADOW_FORM_SHIELD_CHARGED_SOUND_1P = "DeathProtection_Reborn_Shield_Charged_1P"
const string SHADOW_FORM_SHIELD_HIT_SOUND_1P = "DeathProtection_Reborn_Shield_Damage_1P"

const string SHADOW_FORM_ACTIVATE_SOUND_3P = "DeathProtection_Reborn_Activate_3P"
const string SHADOW_FORM_LOOP_SOUND_3P = "DeathProtection_Reborn_Loop_3P"
const string SHADOW_FORM_DEACTIVATE_SOUND_3P = "DeathProtection_Reborn_End_3P"
const string SHADOW_FORM_WINDUP_SOUND_3P = "DeathProtection_Reborn_Windup_3P"
const string SHADOW_FORM_EXPIRATION_WARNING_3P = "DeathProtection_Reborn_WarningToEnd_3p"
const string SHADOW_FORM_SHIELD_BREAK_SOUND_3P = "DeathProtection_Reborn_Shield_Broken_3P"
const string SHADOW_FORM_SHIELD_RECHARGE_SOUND_3P = "DeathProtection_Reborn_Shield_Recharge_3P"
const string SHADOW_FORM_SHIELD_CHARGED_SOUND_3P = "DeathProtection_Reborn_Shield_Charged_3P"
const string SHADOW_FORM_SHIELD_HIT_SOUND_3P = "DeathProtection_Reborn_Shield_Damage_3P"

// VFX
// 1P
const asset SHADOW_FORM_SHIELD_HIT_FX_1P = $"P_armor_FP_Hit_rev"
const asset SHADOW_FORM_SHIELD_HIT_FX2_1P = $"P_health_hex_rev_fast"
const asset SHADOW_FORM_SHIELD_ACTIVE_FX_1P = $"p_rev_reborn_FP_ult_screen_shield"

// 3P
const asset SHADOW_FORM_ACTIVATION_FX_3P = $"p_rev_reborn_3P_ult_activation_arms"
const asset SHADOW_FORM_SHIELD_ACTIVATION_FX_3P = $"P_rev_reborn_shield_start"
const asset SHADOW_FORM_SHIELD_FX_3P = $"P_rev_reborn_shield"
const asset SHADOW_FORM_SHIELD_RECHARGE_FX_3P = $"P_rev_reborn_3P_ult_activation"
const asset SHADOW_FORM_SHIELD_BREAK_FX_3P = $"P_rev_reborn_shield_end"
const asset SHADOW_FORM_BODY_FX_3P = $"P_rev_reborn_shield_powerup"
const asset SHADOW_FORM_EYE_FX_3P = $"P_rev_reborn_shield_eye"
const asset SHADOW_FORM_TRAIL_FX_3P = $"P_rev_reborn_3P_ult_body_trail"
const asset SHADOW_FORM_SHIELD_HIT_FX_3P = $"P_rev_reborn_shield_dmg"

// Assets
const asset SHADOW_FORM_SHIELD_COLLISION_MODEL = $"mdl/fx/forged_shadows_shield_physX.rmdl"


#if CLIENT
const asset SHADOW_FORM_SHADOW_SCREEN_FX = $"p_rev_reborn_FP_ult_screen_base"
#endif

// ----- Tuning -----
// General
global const float SHADOW_FORM_DURATION = 25.0
const float SHADOW_FORM_TIME_ADD = 5.0
const float SHADOW_FORM_ASSIST_TIME = 3.0
const float SHADOW_FORM_SHIELD_HEALTH = 75
const float SHADOW_FORM_SHIELD_REGEN_RATE = 1.0
const float SHADOW_FORM_SHIELD_REGEN_DELAY = 1.0
const float SHADOW_FORM_EXPIRATION_WARNING_TIME = 3.0
const vector SHADOW_FORM_SHIELD_ORIGIN_OFFSET= < 0, 0, -5 >
const int SHADOW_FORM_ENABLE_SHIELD_RESET = 1
const int SHADOW_FORM_ENABLE_TAC_RESET = 0
const int SHADOW_FORM_ENABLE_TAC_COOLDOWN_REDUC = 0
const int SHADOW_FORM_ENABLE_CARRYOVER_DMG = 1

const int SHADOW_FORM_CHEST_FOCUS = 1

global const string SHADOW_FORM_HEALTH_NETVAR = "revenant_shadow_health"

struct
{
	#if SERVER
		table< entity, int > shadowFormEffectID
		table< entity, entity > healthIndicatorEffectID
		table< entity, entity > forgedShadowShield
		table< entity, entity > forgedShadowShieldFX
		table< entity, entity >	lastDamageInflictor
 	#endif
	#if CLIENT
		int colorCorrection
		int shadowShieldFx

		bool isRecharging 	  = false
		bool enableHealFlash  = false
		float lastKillTime    = -1

		bool enableDmgFlash   = false

		float mitigatedDamageRemaining = 0.0
	#endif //CLIENT

	// Live Tuning
	float duration
	float extensionTime
	float assistTime
	float shieldHealth
	float shieldRegenRate
	float shieldRegenDelay
	bool enableShieldReset
	bool enableTacReset
	bool enableTacCooldownReduc
	bool enableCarryoverDmg
} file

void function MpAbilityShadowForm_Init()
{
	// 1P FX
	PrecacheParticleSystem( SHADOW_FORM_SHIELD_HIT_FX_1P )
	PrecacheParticleSystem( SHADOW_FORM_SHIELD_HIT_FX2_1P )

	// 3P FX
	PrecacheParticleSystem( SHADOW_FORM_ACTIVATION_FX_3P )
	PrecacheParticleSystem( SHADOW_FORM_SHIELD_ACTIVATION_FX_3P )
	PrecacheParticleSystem( SHADOW_FORM_SHIELD_FX_3P )
	PrecacheParticleSystem( SHADOW_FORM_SHIELD_RECHARGE_FX_3P )
	PrecacheParticleSystem( SHADOW_FORM_SHIELD_BREAK_FX_3P )
	PrecacheParticleSystem( SHADOW_FORM_BODY_FX_3P )
	PrecacheParticleSystem( SHADOW_FORM_EYE_FX_3P )
	PrecacheParticleSystem( SHADOW_FORM_TRAIL_FX_3P )
	PrecacheParticleSystem( SHADOW_FORM_SHIELD_HIT_FX_3P )

	// Models
	PrecacheModel( SHADOW_FORM_SHIELD_COLLISION_MODEL )

	// Live Tuning
	file.duration = GetCurrentPlaylistVarFloat( "revenant_shadow_form_duration", SHADOW_FORM_DURATION )
	file.extensionTime = GetCurrentPlaylistVarFloat( "revenant_shadow_form_extension_time", SHADOW_FORM_TIME_ADD )
	file.assistTime = GetCurrentPlaylistVarFloat( "revenant_shadow_form_extension_time", SHADOW_FORM_ASSIST_TIME )
	file.shieldHealth = GetCurrentPlaylistVarFloat( "revenant_shadow_form_shield_health", SHADOW_FORM_SHIELD_HEALTH )
	file.shieldRegenRate = GetCurrentPlaylistVarFloat( "revenant_shadow_form_shield_regen_rate", SHADOW_FORM_SHIELD_REGEN_RATE )
	file.shieldRegenDelay = GetCurrentPlaylistVarFloat( "revenant_shadow_form_shield_regen_delay", SHADOW_FORM_SHIELD_REGEN_DELAY )
	file.enableShieldReset = ( GetCurrentPlaylistVarInt( "revenant_shadow_form_enable_shield_reset", SHADOW_FORM_ENABLE_SHIELD_RESET ) > 0 )
	file.enableTacReset = ( GetCurrentPlaylistVarInt( "revenant_shadow_form_enable_tactical_reset", SHADOW_FORM_ENABLE_TAC_RESET ) > 0 )
	file.enableTacCooldownReduc = ( GetCurrentPlaylistVarInt( "revenant_shadow_form_enable_tactical_cd_reduc", SHADOW_FORM_ENABLE_TAC_COOLDOWN_REDUC ) > 0 )
	file.enableCarryoverDmg = ( GetCurrentPlaylistVarInt( "revenant_shadow_form_enable_carryover_dmg", SHADOW_FORM_ENABLE_CARRYOVER_DMG ) > 0 )

	RegisterNetworkedVariable( SHADOW_FORM_HEALTH_NETVAR, SNDC_PLAYER_GLOBAL, SNVT_FLOAT_RANGE, 0.0, 0.0, file.shieldHealth )
	Remote_RegisterClientFunction( "ServerToClient_UpdateDamageRUI", "bool", "bool", "float", 0.0, 32000.0, 32  )
	Remote_RegisterClientFunction( "ServerToClient_DoShadowShieldDamageIndicator", "entity", "entity", "int", INT_MIN, INT_MAX )

	#if SERVER
		Bleedout_AddCallback_OnPlayerStartBleedout( ShadowForm_OnBleedoutStarted_Server )
		AddCallback_OnPlayerKilled( Executioner_HealOnKill )
		AddCallback_OnPlayerAssist( Executioner_HealOnAssist )
		AddDamageCallback( "player", OnPlayerTookDamage )
	#endif

	#if CLIENT
		PrecacheParticleSystem( SHADOW_FORM_SHADOW_SCREEN_FX )
		PrecacheParticleSystem( SHADOW_FORM_SHIELD_ACTIVE_FX_1P )
		RegisterSignal( "ShadowForm_EndShadowScreenFx" )
		RegisterSignal( "EndDamageFlash" )
		RegisterSignal( "EndHealFlash" )
		AddCallback_OnBleedoutStarted( ShadowForm_OnBleedoutStarted_Client )
		file.colorCorrection = ColorCorrection_Register( "materials/correction/ability_silence.raw_hdr" )
		StatusEffect_RegisterEnabledCallback( eStatusEffect.shadow_form, ShadowForm_StartClient )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.shadow_form, ShadowForm_StopClient )
	#endif

	RegisterSignal( "ExitShadowForm" )
	RegisterSignal( "EndShieldRegenDelay" )
	RegisterSignal( "EndExpirationThread" )
}

#if SERVER
void function ShadowForm_OnBleedoutStarted_Server( entity victim, entity attacker, var damageInfo )
{
	if( !victim.IsPlayer() || !attacker.IsPlayer() )
		return

	// Heal on knock
	if ( PlayerHasPassive( attacker, ePassives.PAS_REVENANT_REWORK ) )
		ExecutionerHealOnKillOrAssist( attacker, victim )

	// Heal on Knock Assist
	victim.p.playerToTimeThatAssistCreditLastsTable = GetLatestAssistingPlayersFromSameTeam( victim, attacker )
	foreach( entity assistCreditPlayer, float assistTime in victim.p.playerToTimeThatAssistCreditLastsTable )
	{
		if ( !IsValid( assistCreditPlayer ) )
			continue

		float maxAssistGap = GetCurrentPlaylistVarFloat( "max_assist_time_gap", MAX_ASSIST_TIME_GAP )
		float reducedAssistTime = maxAssistGap - file.assistTime
		float curAssistTime = assistTime - reducedAssistTime
		if( Time() > curAssistTime )
			continue

		if ( PlayerHasPassive( assistCreditPlayer, ePassives.PAS_REVENANT_REWORK ) )
			ExecutionerHealOnKillOrAssist( assistCreditPlayer, victim )
	}

	if( !PlayerHasPassive( victim, ePassives.PAS_REVENANT_REWORK ) )
		return

	if ( IsInForgedShadows( victim ) )
	{
		victim.Signal( "ExitShadowForm" )
	}
}
#elseif CLIENT
void function ShadowForm_OnBleedoutStarted_Client( entity player, float endTime )
{
	if ( player == GetLocalViewPlayer() )
	{
		if ( IsInForgedShadows( player ) )
		{
			player.Signal( "ExitShadowForm" )
		}
	}
}
#endif

bool function OnWeaponAttemptOffhandSwitch_ability_shadow_form( entity weapon )
{
	entity weaponOwner = weapon.GetOwner()

	if ( !IsValid( weaponOwner ) )
		return false

	if( IsInForgedShadows( weaponOwner ) )
		return false

	return true
}

void function OnWeaponActivate_ability_shadow_form( entity weapon )
{
	entity player = weapon.GetOwner()
	if( !IsValid( player ) )
		return

	#if SERVER
		if ( IsValid( weapon.GetOwner() ) )
		{
			PlayBattleChatterLineToSpeakerAndTeam( weapon.GetOwner(), "bc_super" )
		}

		EmitSoundOnEntityOnlyToPlayer(player, player, SHADOW_FORM_WINDUP_SOUND_1P  )
		EmitSoundOnEntityExceptToPlayer( player, player, SHADOW_FORM_WINDUP_SOUND_3P )
	#endif
}

var function OnWeaponTossReleaseAnimEvent_ability_shadow_form( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetOwner()
	Assert( ownerPlayer.IsPlayer() )

	thread ShadowForm_Start( ownerPlayer, weapon )

	PlayerUsedOffhand( ownerPlayer, weapon )

	return weapon.GetAmmoPerShot()
}

void function OnWeaponOwnerChanged_ability_shadow_form( entity weapon, WeaponOwnerChangedParams changeParams )
{
	entity oldOwner = changeParams.oldOwner
	if( IsValid( oldOwner ) )
		oldOwner.Signal( "ExitShadowForm" )
}

bool function IsInForgedShadows( entity player )
{
	if ( !IsValid( player ) )
		return false

	if ( StatusEffect_HasSeverity( player, eStatusEffect.shadow_form ) )
		return true

	return false
}

bool function IsForgedShadowsShield( entity ent )
{
	if( !IsValid( ent ) )
		return false

	return ent.GetTargetName() == FORGED_SHADOWS_SHIELD_NAME
}

#if SERVER
bool function IsForgedShadowShieldActive( entity player )
{
	if( !IsValid( player ) )
		return false

	if( IsInForgedShadows( player ) )
	{
		if( player in file.forgedShadowShield )
		{
			if( IsValid( file.forgedShadowShield[player] ) )
				return true
		}
	}

	return false
}
#endif

bool function ShadowShield_IsAllowedStickyEnt( entity shadowShield, entity stickyEnt, string stickyEntWeaponClassName )
{
	if( !IsValid( shadowShield ) || !IsValid( stickyEnt ) )
		return false
	if( IsFriendlyTeam( stickyEnt.GetTeam(), shadowShield.GetTeam() ) )
		return false

	bool allowStick = false

	if ( stickyEntWeaponClassName == "mp_weapon_cluster_bomb_launcher" )
		allowStick = true

	if ( stickyEntWeaponClassName == "mp_weapon_arc_bolt" )
		allowStick = true

	if ( stickyEntWeaponClassName == GRENADE_EMP_WEAPON_NAME )
		allowStick = true

	if( allowStick )
		thread ShadowShield_TrackStickyEnt_Thread( shadowShield, stickyEnt )

	return allowStick
}

//Track Sticky Ents to dislodge them if the Mobile Shield moves them through a wall/door.
void function ShadowShield_TrackStickyEnt_Thread( entity shadowShield, entity stickyEnt )
{
	EndSignal( shadowShield, "OnDestroy" )
	EndSignal( stickyEnt, "OnDestroy" )

	bool hadLoS = true

	array<entity> ignoreArray	= ShadowShieldIgnoreArray()
	TraceResults initialTrace = TraceLine( shadowShield.GetOrigin(), stickyEnt.GetOrigin(), ignoreArray, TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )

	if(initialTrace.fraction < 1)
		hadLoS = false

	WaitFrame() //need this frame to allow the projectile to actually "stick"

	while ( true )
	{
		if( !IsValid( shadowShield ) )
			return
		if( !IsValid( stickyEnt ) )
			return

		ignoreArray	= ShadowShieldIgnoreArray()
		TraceResults results = TraceLine( shadowShield.GetOrigin(), stickyEnt.GetOrigin(), ignoreArray, TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )
		if(	results.fraction < 1 )
		{
			#if SERVER
				stickyEnt.ClearParent()
				if( hadLoS )
					stickyEnt.SetAbsOrigin( results.endPos )
			#endif
			return
		}

		WaitFrame()
	}
}

array<entity> function ShadowShieldIgnoreArray()
{
	array<entity> ignoreArray = GetPlayerArray_Alive()

	array<entity> shadowShields = GetEntArrayByScriptName( FORGED_SHADOWS_SHIELD_NAME ) // Forged Shadows Shield
	foreach ( shadowShield in shadowShields )
	{
		if( !IsValid( shadowShield ) )
			continue
		ignoreArray.append( shadowShield )
	}

	array<entity> mobileShields = GetEntArrayByScriptName( MOBILE_SHIELD_SCRIPTNAME ) //mobile Shield Energy Walls
	foreach ( shieldWall in mobileShields )
	{
		if( !IsValid(shieldWall) )
			continue
		ignoreArray.append( shieldWall )
	}

	array<entity> thrownShields = GetEntArrayByScriptName( SHIELD_THROW_SCRIPTNAME ) // Mobile Shield Drones
	foreach ( shield in thrownShields )
	{
		if( !IsValid(shield) )
			continue
		ignoreArray.append( shield )
	}

	array<entity> bubbleShields = GetEntArrayByScriptName( BUBBLE_SHIELD_SCRIPTNAME ) //Gibby Domes
	foreach ( bubble in bubbleShields )
	{
		if( !IsValid(bubble) )
			continue
		ignoreArray.append( bubble )
	}

	array<entity> holoEnts = GetPlayerDecoyArray() //Mirage Decoys
	ignoreArray.extend( holoEnts )

	return ignoreArray
}

void function ShadowForm_Start( entity player, entity weapon )
{
	Assert ( IsNewThread(), "Must be threaded off" )
	if ( !IsAlive( player ) )
		return

	EndSignal( player, "OnDeath", "OnDestroy", "BleedOut_OnStartDying" ,"ExitShadowForm" )

	#if SERVER
		player.SetPlayerNetFloat( SHADOW_FORM_HEALTH_NETVAR, file.shieldHealth )

		weapon.AddMod( "ability_in_effect_regen_paused" )

		// Reduce Tac cooldown time during ult
		if( file.enableTacCooldownReduc )
		{
			entity tacticalAbility = player.GetOffhandWeapon( OFFHAND_TACTICAL )
			if ( tacticalAbility.GetWeaponClassName() == "mp_ability_revenant_shadow_pounce_free" )
			{
				array<string> currentTacMods = tacticalAbility.GetMods()
				if ( !currentTacMods.contains( "shadow_form_active" ) )
				{
					tacticalAbility.AddMod( "shadow_form_active" )
				}
			}
		}

		// VFX 3P
		array<entity> fxArray
		int chestAttachID = player.LookupAttachment( "CHESTFOCUS" )
		int eyeLAttachID = player.LookupAttachment( "EYE_L" )
		int eyeRAttachID = player.LookupAttachment( "EYE_R" )
		int forearmLAttachID = player.LookupAttachment( "L_hand" )
		int forearmRAttachID = player.LookupAttachment( "R_hand" )

		if( chestAttachID > 0 )
		{
			// Shadow Trail effect
			entity shadowTrailFX = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( SHADOW_FORM_TRAIL_FX_3P ), FX_PATTACH_POINT_FOLLOW, chestAttachID )
			shadowTrailFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
			shadowTrailFX.SetOwner( player )
			fxArray.append( shadowTrailFX )

			// Shadow body effects
			entity FX_BODY
			FX_BODY                    = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( SHADOW_FORM_BODY_FX_3P ), FX_PATTACH_POINT_FOLLOW, chestAttachID )
			FX_BODY.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
			FX_BODY.SetOwner( player )
			fxArray.append( FX_BODY )
		}

		if( eyeLAttachID > 0 )
		{
			entity FX_EYE_L
			FX_EYE_L                    = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( SHADOW_FORM_EYE_FX_3P ), FX_PATTACH_POINT_FOLLOW, eyeLAttachID )
			FX_EYE_L.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
			FX_EYE_L.SetOwner( player )
			fxArray.append( FX_EYE_L )
		}

		if( eyeRAttachID > 0 )
		{
			entity FX_EYE_R
			FX_EYE_R                    = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( SHADOW_FORM_EYE_FX_3P ), FX_PATTACH_POINT_FOLLOW, eyeRAttachID )
			FX_EYE_R.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
			FX_EYE_R.SetOwner( player )
			fxArray.append( FX_EYE_R )
		}

		if( forearmLAttachID > 0 && forearmRAttachID > 0 )
		{
			array< entity > FX_FOREARM_3P
			FX_FOREARM_3P.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( SHADOW_FORM_ACTIVATION_FX_3P ), FX_PATTACH_POINT_FOLLOW, forearmLAttachID ) )
			FX_FOREARM_3P.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( SHADOW_FORM_ACTIVATION_FX_3P ), FX_PATTACH_POINT_FOLLOW, forearmRAttachID ) )
			foreach ( fx in FX_FOREARM_3P )
			{
				fx.SetOwner( player )
				fx.kv.VisibilityFlags = ENTITY_VISIBLE_EXCLUDE_PARENT_PLAYER | ENTITY_VISIBLE_TO_EVERYONE
			}
			fxArray.extend( FX_FOREARM_3P )
		}

		thread ShadowForm_CreateShieldAroundPlayer( player )

		ShadowForm_ApplyShadowSkin( player )
		file.shadowFormEffectID[player] <- StatusEffect_AddTimed( player, eStatusEffect.shadow_form, 1.0, file.duration, 0.0 )
		//player.EnterShadowFormFortified()

		// Bloodhound Tracking
		TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_REVENANT_FORGED_SHADOWS, player, player.GetOrigin(), player.GetTeam(), player )

		// SFX
		EmitSoundOnEntityExceptToPlayer( player, player, SHADOW_FORM_ACTIVATE_SOUND_3P )
		EmitSoundOnEntityExceptToPlayer( player, player, SHADOW_FORM_LOOP_SOUND_3P )

		thread ShadowForm_Expiration_Thread( player )

	OnThreadEnd(
		function() : ( player, weapon, fxArray)
		{
			#if SERVER
				player.Signal( "ExitShadowForm" )

				if ( IsValid( player ) )
				{
					// Remove Shadow Skin
					ShadowSquadCancelCharacterSkin( player )
					player.LeaveShadowForm()

					// Take Fortified Passive if applied
					if( PlayerHasPassive( player, ePassives.PAS_FORTIFIED ) )
						TakePassive( player, ePassives.PAS_FORTIFIED )

					// Remove Tac cooldown buff
					if( file.enableTacCooldownReduc )
					{
						entity tacticalAbility = player.GetOffhandWeapon( OFFHAND_TACTICAL )
						if ( IsValid( tacticalAbility ) )
						{
							array<string> currentTacMods = tacticalAbility.GetMods()
							if ( currentTacMods.contains( "shadow_form_active" ) )
							{
								tacticalAbility.RemoveMod( "shadow_form_active" )
							}
						}
					}

					StopSoundOnEntity( player, SHADOW_FORM_EXPIRATION_WARNING_1P )
					StopSoundOnEntity( player, SHADOW_FORM_EXPIRATION_WARNING_3P )
					StopSoundOnEntity( player, SHADOW_FORM_LOOP_SOUND_3P )
					EmitSoundOnEntityExceptToPlayer( player, player, SHADOW_FORM_DEACTIVATE_SOUND_3P )

					if( player in file.shadowFormEffectID )
					{
						StatusEffect_Stop( player, file.shadowFormEffectID[player] )
						delete file.shadowFormEffectID[player]
					}

					if( player in file.healthIndicatorEffectID )
					{
						EffectStop( file.healthIndicatorEffectID[player] )
						delete file.healthIndicatorEffectID[player]
					}
				}

				if ( IsValid( weapon ) )
				{
					if ( weapon.HasMod( "ability_in_effect_regen_paused" ) )
						weapon.RemoveMod( "ability_in_effect_regen_paused" )
				}

				foreach (fx in fxArray)
				{
					if( IsValid(fx) )
					{
						EffectStop( fx )
						fx.Destroy()
					}
				}
			#endif
		}
	)
	#endif

	while( StatusEffect_HasSeverity( player, eStatusEffect.shadow_form ) )
	{
		#if SERVER
			// Give Fortified while in Ult
			if( !PlayerHasPassive( player, ePassives.PAS_FORTIFIED ) )
				GivePassive( player, ePassives.PAS_FORTIFIED )
		#endif

		WaitFrame()
	}
}

#if SERVER
void function ShadowForm_Expiration_Thread( entity player )
{
	Assert ( IsNewThread(), "Must be threaded off" )
	if ( !IsAlive( player ) )
		return

	player.Signal( "EndExpirationThread" )
	EndSignal( player, "OnDeath", "OnDestroy", "BleedOut_OnStartDying" ,"ExitShadowForm", "EndExpirationThread" )

	OnThreadEnd(
		function() : ( player )
		{
			if( IsAlive( player ) )
			{
				StopSoundOnEntity( player, SHADOW_FORM_EXPIRATION_WARNING_1P )
				StopSoundOnEntity( player, SHADOW_FORM_EXPIRATION_WARNING_3P )
			}
		}
	)

	while ( StatusEffect_GetTimeRemaining( player, eStatusEffect.shadow_form ) > SHADOW_FORM_EXPIRATION_WARNING_TIME )
		WaitFrame()

	EmitSoundOnEntityOnlyToPlayer( player, player, SHADOW_FORM_EXPIRATION_WARNING_1P )
	EmitSoundOnEntityExceptToPlayer( player, player, SHADOW_FORM_EXPIRATION_WARNING_3P )

	wait SHADOW_FORM_EXPIRATION_WARNING_TIME
}

void function OnPlayerTookDamage( entity player, var damageInfo )
{
	if ( player.IsPlayer() && IsInForgedShadows( player ) )
	{
		int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )
		int damageType = DamageInfo_GetDamageType( damageInfo )
		float damage = DamageInfo_GetDamage( damageInfo )
		entity attacker = DamageInfo_GetAttacker( damageInfo )
		entity inflictor = DamageInfo_GetInflictor( damageInfo )

		if( player in file.forgedShadowShield )
		{
			// Redirect damage to the shield
			if ( damageType == DMG_BULLET || damageType == DMG_MELEE_ATTACK )
			{
				DamageInfo_ScaleDamage( damageInfo, 0.0 ) // Take no player damage
				if( IsValid( file.forgedShadowShield[player] ) )
					file.forgedShadowShield[player].TakeDamage( damage, attacker, inflictor, { damageSourceId = damageSourceId } )
			}
			
			// Explosions are applied to shield, not Rev
			if( damageType == DMG_BLAST )
			{
				switch( damageSourceId )
				{
					case eDamageSourceId.damagedef_grenade_gas:
					case eDamageSourceId.damagedef_gas_exposure:
					               
					case eDamageSourceId.mp_ability_conduit_shield_mines:
           
						return // Take player damage, ignore the shield
					default:
						DamageInfo_ScaleDamage( damageInfo, 0.0 ) // Take no player damage
				}
			}

			// Exception list
			switch( damageSourceId )
			{
				case eDamageSourceId.mp_ability_crypto_drone_emp:
				case eDamageSourceId.damagedef_defensive_bombardment:
				case eDamageSourceId.damagedef_creeping_bombardment_detcord_explosion:
					DamageInfo_ScaleDamage( damageInfo, 0.0 ) // Take no player damage
			}
		}
		else if( player in file.lastDamageInflictor )
		{
			if( IsValid( file.lastDamageInflictor[player] ) )
			{
				// If the shield was damaged by the same inflictor first and the shield broke, we dont want to have the same inflictor deal damage to Revenant after that
				if ( file.lastDamageInflictor[player] == inflictor )
					DamageInfo_ScaleDamage( damageInfo, 0.0 )
			}

			delete file.lastDamageInflictor[player]
		}
		else
			thread ShadowForm_ShieldRegenDelay( player )
	}
}

void function Server_Broadcast_DamageIndicator( entity player, entity attacker, int damageSourceId )
{
	Remote_CallFunction_Replay( player, "ServerToClient_DoShadowShieldDamageIndicator", player, attacker, damageSourceId )
}

void function ShadowForm_ShieldRegenDelay( entity player )
{
	Assert ( IsNewThread(), "Must be threaded off" )
	if ( !IsAlive( player ) )
		return
	if( !IsInForgedShadows( player ) )
		return

	player.Signal( "EndShieldRegenDelay" )
	EndSignal( player, "OnDeath", "OnDestroy", "BleedOut_OnStartDying" ,"ExitShadowForm", "EndShieldRegenDelay" )

	wait file.shieldRegenDelay

	EmitSoundOnEntityOnlyToPlayer( player, player, SHADOW_FORM_SHIELD_RECHARGE_SOUND_1P )
	EmitSoundOnEntityExceptToPlayer( player, player, SHADOW_FORM_SHIELD_RECHARGE_SOUND_3P )

	OnThreadEnd(
		function() : ( player )
		{
			if( IsValid( player ) )
			{
				StopSoundOnEntity( player, SHADOW_FORM_SHIELD_RECHARGE_SOUND_1P )
				StopSoundOnEntity( player, SHADOW_FORM_SHIELD_RECHARGE_SOUND_3P )
			}
		}
	)

	float rechargeAmount = player.GetPlayerNetFloat( SHADOW_FORM_HEALTH_NETVAR )
	while( rechargeAmount != file.shieldHealth )
	{
		rechargeAmount = Clamp( rechargeAmount + file.shieldRegenRate, 0.0, file.shieldHealth )
		player.SetPlayerNetFloat( SHADOW_FORM_HEALTH_NETVAR, Clamp( rechargeAmount, 0, file.shieldHealth ) )
		Remote_CallFunction_Replay( player, "ServerToClient_UpdateDamageRUI", true, false, rechargeAmount )

		WaitFrame()
	}

	thread ShadowForm_CreateShieldAroundPlayer( player )
}

void function ShadowForm_CreateShieldAroundPlayer( entity player )
{
	EndSignal( player, "OnDeath", "OnDestroy", "BleedOut_OnStartDying", "ExitShadowForm" )

	if( player in file.forgedShadowShield )
	{
		if( IsValid( file.forgedShadowShield[player] ) )
			file.forgedShadowShield[player].Destroy()
		delete file.forgedShadowShield[player]
	}

	if( player in file.forgedShadowShieldFX )
	{
		if( IsValid( file.forgedShadowShieldFX[player] ) )
			EffectStop( file.forgedShadowShieldFX[player] )
		delete file.forgedShadowShieldFX[player]
	}

	entity shadowShield = CreatePropScript( SHADOW_FORM_SHIELD_COLLISION_MODEL, player.GetAttachmentOrigin( player.LookupAttachment( "CHESTFOCUS" ) ), player.GetAngles(), SOLID_VPHYSICS )
	SetTeam( shadowShield, player.GetTeam() )
	shadowShield.SetParent( player, "CHESTFOCUS", false )
	shadowShield.SetOwner( player )
	shadowShield.SetTakeDamageType( DAMAGE_YES )
	shadowShield.SetDamageNotifications( true )
	shadowShield.SetBlocksRadiusDamage( false )
	shadowShield.SetMaxHealth( file.shieldHealth )
	shadowShield.SetHealth( file.shieldHealth )
	shadowShield.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	shadowShield.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	shadowShield.kv.rendercolor = <175, 50, 25>
	shadowShield.EnableAttackableByAI( 5, 0, AI_AP_FLAG_NONE )
	//shadowShield.DisallowObjectPlacement()
	shadowShield.e.preventStickyEnts = true
	//shadowShield.SetCanBeMeleedByOwner( false )
	shadowShield.SetCanBeMeleed( true )
	//shadowShield.SetIgnoreMoveParentRotation()
	shadowShield.SetLocalOrigin( SHADOW_FORM_SHIELD_ORIGIN_OFFSET )

	CopyRealmsFromTo( player, shadowShield )
	SetTargetName( shadowShield, FORGED_SHADOWS_SHIELD_NAME )
	shadowShield.SetScriptName( FORGED_SHADOWS_SHIELD_NAME )

	AddEntityCallback_OnPostDamaged( shadowShield, Shield_OnPostDamaged )

	AddEMPDamageDevice( shadowShield )
	AddWreckingBallEMPDamageDevice( shadowShield )
                 
                                         
       

	file.forgedShadowShield[player] <- shadowShield
	//player.SetShadowShieldIsActive( true )

	// Forged Shadows Shield FX
	entity shadowShieldFX = StartParticleEffectOnEntity_ReturnEntity( shadowShield, GetParticleSystemIndex( SHADOW_FORM_SHIELD_FX_3P ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	shadowShieldFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
	shadowShieldFX.SetOwner( player )
	shadowShieldFX.SetParent( shadowShield )
	CopyRealmsFromTo( player, shadowShieldFX )
	EffectSetControlPointVector( shadowShieldFX, 5, <1,0,0> )

	file.forgedShadowShieldFX[player] <- shadowShieldFX

	// Shadow Form Activation Burst
	entity activationBurstFX = StartParticleEffectOnEntity_ReturnEntity( shadowShield, GetParticleSystemIndex( SHADOW_FORM_SHIELD_ACTIVATION_FX_3P ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	activationBurstFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
	activationBurstFX.SetOwner( player )
	CopyRealmsFromTo( player, activationBurstFX )

	EmitSoundOnEntityOnlyToPlayer( player, player, SHADOW_FORM_SHIELD_CHARGED_SOUND_1P )
	EmitSoundOnEntityExceptToPlayer( player, player, SHADOW_FORM_SHIELD_CHARGED_SOUND_3P )

	OnThreadEnd(
		function() : ( player, activationBurstFX )
		{
			if( IsValid( player ) )
			{
				if ( player in file.forgedShadowShield )
				{
					if( IsValid( file.forgedShadowShield[player] ) )
					{
						Shield_CleanUp( file.forgedShadowShield[player] )
						file.forgedShadowShield[player].Destroy()
					}
					delete file.forgedShadowShield[player]
				}

				if( player in file.forgedShadowShieldFX )
				{
					if( IsValid( file.forgedShadowShieldFX[player] ) )
						EffectStop( file.forgedShadowShieldFX[player] )
					delete file.forgedShadowShieldFX[player]
				}

				//player.SetShadowShieldIsActive( false )
			}

			if( IsValid( activationBurstFX ) )
			{
				EffectStop( activationBurstFX )
				activationBurstFX.Destroy()
			}
		}
	)

	while( true )
	{
		bool playerIsCloakedOrShifted = player.IsPhaseShifted() || player.IsCloaked( true )

		if( player in file.forgedShadowShield && IsValid( file.forgedShadowShield[player] ) )
		{
			file.forgedShadowShield[player].SetAbsAngles( VectorToAngles( player.GetForwardVector() * -1.0 ) )
			
			if( playerIsCloakedOrShifted )
			{
				file.forgedShadowShield[player].SetCollisionAllowed( false )
			}
			else
			{
				file.forgedShadowShield[player].SetCollisionAllowed( true )
			}
		}

		if( player in file.forgedShadowShieldFX && IsValid( file.forgedShadowShieldFX[player] ) )
		{
			if( playerIsCloakedOrShifted )
			{
				file.forgedShadowShieldFX[player].SetVisibilityFlags( ENTITY_VISIBLE_TO_NOBODY )
			}
			//else if( player.IsPlayerCameraInThirdPerson() )
			//{
				//file.forgedShadowShieldFX[player].SetVisibilityFlags( ENTITY_VISIBLE_TO_EVERYONE )
			//}
			else
			{
				file.forgedShadowShieldFX[player].SetVisibilityFlags( ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY )
			}
		}

		WaitFrame()
	}
}

void function Shield_OnPostDamaged( entity shadowShield, var damageInfo )
{
	if( !IsValid( shadowShield ) )
		return

	entity owner = shadowShield.GetOwner()
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	entity damageInflictor = DamageInfo_GetInflictor( damageInfo )
	int damageSourceIdentifier = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	float damage = DamageInfo_GetDamage( damageInfo )

	if ( damage <= 0 )
		return

	thread Shield_DamageFX_Thread( owner, shadowShield )

	Server_Broadcast_DamageIndicator( owner, attacker, damageSourceIdentifier )

	// Damage Feedback and Modification
	if ( attacker.IsPlayer() )
	{
		DamageInfo_AddCustomDamageType( damageInfo, DF_SOUR )
		DamageInfo_AddCustomDamageType( damageInfo, DAMAGEFLAG_VICTIM_HAS_VORTEX )

		// Apply highlights or damage scaling from Attacker abilities
		if( PlayerHasPassive( attacker,ePassives.PAS_WARLORDS_IRE )  )
			Remote_CallFunction_Replay( attacker, "ServerCallback_WarlordsIre_HighlightTargetRemote", attacker, owner, DamageInfo_GetDamageType( damageInfo ) )
		if( PlayerHasPassive( attacker,ePassives.PAS_VANTAGE ) )
			SniperUlt_OnDamagedByPlayer_DiamondScan( owner, damageInfo )

		//Ensure damaging shield counts as an assist
		if( attacker != owner )
			AddAssistingPlayerToVictim( attacker, owner )

		damage = DamageInfo_GetDamage( damageInfo ) // Update damage incase scaling affected it
		float shieldDamage = min( damage, shadowShield.GetHealth() )

		attacker.NotifyDidDamage( shadowShield, 0, DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ),
			int( shieldDamage ), DamageInfo_GetDamageFlags( damageInfo ) | DF_NO_HITBEEP, DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )

		entity weapon = DamageInfo_GetWeapon( damageInfo )
		Survival_PlayerDealtDamage( attacker, owner, weapon, 0, 0, int( shieldDamage ), damageSourceIdentifier )
		StoreDamageHistoryAndUpdate( owner, GetCurrentPlaylistVarFloat( "max_damage_history_time", MAX_DAMAGE_HISTORY_TIME  ), shieldDamage, owner.GetCenter(), DamageInfo_GetDamageFlags( damageInfo ) | DF_NO_HITBEEP, damageSourceIdentifier, attacker )
	}

	// Carry over damage from shield to player
	if( file.enableCarryoverDmg && damage > shadowShield.GetHealth() )
	{
		// Dont carry over damage from Wrecking Ball or EMP
		switch( damageSourceIdentifier )
		{
			case eDamageSourceId.damagedef_wrecking_ball:
			case eDamageSourceId.mp_ability_crypto_drone_emp:
			case eDamageSourceId.mp_ability_crypto_drone_emp_trap:
				break
			default:
				float carryoverDmg = damage - shadowShield.GetHealth()
				//owner.TakeDamage( carryoverDmg, attacker, damageInflictor, { damageSourceId = damageSourceIdentifier, scriptType = DF_OVERFLOW } )
				break
		}
	}

	if( IsAlive( owner ) )
	{
		Remote_CallFunction_Replay( owner, "ServerToClient_UpdateDamageRUI", false, false, Clamp( shadowShield.GetHealth() - DamageInfo_GetDamage( damageInfo ), 0.0, file.shieldHealth) )

		bool shadowShieldDestroyed = ( shadowShield.GetHealth() - DamageInfo_GetDamage( damageInfo ) ) <= 0

		if( shadowShieldDestroyed )
		{
			if( owner in file.forgedShadowShield )
				delete file.forgedShadowShield[owner]

			if( owner in file.lastDamageInflictor )
				file.lastDamageInflictor[owner] = damageInflictor
			else
				file.lastDamageInflictor[owner] <- damageInflictor

			//owner.SetShadowShieldIsActive( false )

			Shield_CleanUp( shadowShield )

			thread Shield_BreakFX_Thread( owner, attacker, shadowShield )

			owner.SetPlayerNetFloat( SHADOW_FORM_HEALTH_NETVAR, 0 )
			thread ShadowForm_ShieldRegenDelay( owner )
		}
	}

	LiveAPI_SendCombatInstanceEvent( eLiveAPI_EventTypes.revenantForgedShadowDamaged, attacker, owner, 0, int( floor( damage ) ) )
}

void function Shield_DamageFX_Thread( entity player, entity shadowShield )
{
	Assert ( IsNewThread(), "Must be threaded off" )
	if ( !IsValid( player ) || !IsAlive( player ) || !IsValid( shadowShield ) )
		return

	EndSignal( player, "OnDeath", "OnDestroy", "ExitShadowForm" )

	array< entity > hitEffects
	OnThreadEnd(
		function() : ( hitEffects )
		{
			foreach( hitEffect in hitEffects)
			{
				if( IsValid( hitEffect ) )
				{
					EffectStop( hitEffect )
					hitEffect.Destroy()
				}
			}
		}
	)

	EmitSoundOnEntityOnlyToPlayer( player, player, SHADOW_FORM_SHIELD_HIT_SOUND_1P )
	EmitSoundOnEntityExceptToPlayer( player, player, SHADOW_FORM_SHIELD_HIT_SOUND_3P )

	// Hit Effects 3P
	array< entity > hitEffects3P
	hitEffects3P.append( StartParticleEffectOnEntity_ReturnEntity( shadowShield, GetParticleSystemIndex( SHADOW_FORM_SHIELD_HIT_FX_3P ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID ) )
	foreach( hitEffect3P in hitEffects3P )
	{
		hitEffect3P.SetOwner( player )
		hitEffect3P.SetParent( shadowShield )
		hitEffect3P.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE | ENTITY_VISIBLE_EXCLUDE_PARENT_PLAYER
		CopyRealmsFromTo( player, hitEffect3P )
	}
	hitEffects.extend( hitEffects3P )

	if( player in file.forgedShadowShieldFX )
	{
		if( IsValid( file.forgedShadowShieldFX[player] ) )
		{
			float shieldFrac = GetHealthFrac( shadowShield )
			EffectSetControlPointVector( file.forgedShadowShieldFX[player], 5, <shieldFrac, 0, 0> )
		}
	}

	wait 0.2
}

void function Shield_BreakFX_Thread( entity player, entity attacker, entity shadowShield )
{
	Assert ( IsNewThread(), "Must be threaded off" )
	if ( !IsAlive( player ) )
		return

	EndSignal( player, "OnDeath", "OnDestroy", "ExitShadowForm" )

	entity shieldBreakFX = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( SHADOW_FORM_SHIELD_BREAK_FX_3P ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "CHESTFOCUS" ) )
	shieldBreakFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
	shieldBreakFX.SetOwner( player )
	CopyRealmsFromTo( player, shieldBreakFX )

	EmitSoundOnEntityOnlyToPlayer( player, player, SHADOW_FORM_SHIELD_BREAK_SOUND_1P )
	if ( attacker.IsPlayer() )
	{
		EmitSoundOnEntityOnlyToPlayer( player, attacker, SHADOW_FORM_SHIELD_BREAKER_SOUND_1P )
		EmitSoundOnEntityExceptToPlayers( player, [player, attacker], SHADOW_FORM_SHIELD_BREAK_SOUND_3P )
	}
	else
	{
		EmitSoundOnEntityExceptToPlayer( player, player, SHADOW_FORM_SHIELD_BREAK_SOUND_3P )
	}

	OnThreadEnd(
		function() : ( shieldBreakFX )
		{
			if( IsValid( shieldBreakFX ) )
			{
				EffectStop( shieldBreakFX )
				shieldBreakFX.Destroy()
			}
		}
	)

	wait 1.0
}

void function Shield_CleanUp( entity shadowShield )
{
	if( IsValid( shadowShield ) )
	{
		array<entity> shieldChildren = shadowShield.GetChildren()

		foreach( child in shieldChildren )
		{
			if( !IsValid(child) )
				continue

			if( child.GetClassName() == "info_particle_system" ) //Don't unparent VFX
				continue

			child.ClearParent() //Allows Grenades / Sticky Abilities to DROP when the shield goes down.
		}
	}

}

// Heal on knock/kill
void function Executioner_HealOnKill( entity victim, entity player, var damageInfo )
{
	if( !Bleedout_IsBleedingOut( victim ) )
		ExecutionerHealOnKillOrAssist( player, victim )
}

void function Executioner_HealOnAssist( entity player, entity victim )
{
	if( !Bleedout_IsBleedingOut( victim ) )
	{
		foreach( entity assistCreditPlayer, float assistTime in victim.p.playerToTimeThatAssistCreditLastsTable )
		{
			if ( !IsValid( assistCreditPlayer ) )
				continue

			float maxAssistGap = GetCurrentPlaylistVarFloat( "max_assist_time_gap", MAX_ASSIST_TIME_GAP )
			float reducedAssistTime = maxAssistGap - file.assistTime
			float curAssistTime = assistTime - reducedAssistTime
			if( Time() > curAssistTime )
				continue

			if ( PlayerHasPassive( assistCreditPlayer, ePassives.PAS_REVENANT_REWORK ) )
				ExecutionerHealOnKillOrAssist( assistCreditPlayer, victim )
		}
	}
}

void function ExecutionerHealOnKillOrAssist( entity player, entity victim )
{
	if ( !IsValidPlayer( victim ) || !IsValidPlayer( player ) )
		return
	if( !PlayerHasPassive( player, ePassives.PAS_REVENANT_REWORK ) )
		return
	if( !StatusEffect_HasSeverity( player, eStatusEffect.shadow_form ) )
		return
	if ( IsFriendlyTeam( player.GetTeam(), victim.GetTeam() ) )
		return

	// Reset ability timer
	ShadowForm_ExtendTimer( player )

	Statshook_RevenantUltimateKnocksKills( player )
}

void function ShadowForm_ExtendTimer( entity player )
{
	if( ( player in file.shadowFormEffectID ) && ( IsInForgedShadows( player ) ) )
	{
		float timeRemaining = StatusEffect_GetTimeRemaining( player, eStatusEffect.shadow_form )
		StatusEffect_SetDuration( player, file.shadowFormEffectID[player], Clamp( ( timeRemaining + file.extensionTime ), 0, file.duration ) )
		thread ShadowForm_Expiration_Thread( player )

		if( file.enableShieldReset )
		{
			// Reset shield
			player.Signal( "EndShieldRegenDelay" )
			thread ShadowForm_CreateShieldAroundPlayer( player )
			player.SetPlayerNetFloat( SHADOW_FORM_HEALTH_NETVAR, file.shieldHealth )
			Remote_CallFunction_Replay( player, "ServerToClient_UpdateDamageRUI", true, true, file.shieldHealth )
		}

		                           
			Remote_CallFunction_Replay( player, "ServerCallback_ShowUltTimeIncreasedHint", player, file.extensionTime )
        
	}

	if( file.enableTacReset )
	{
		// Reset Tac cooldown on kill
		entity tacticalAbility = player.GetOffhandWeapon( OFFHAND_TACTICAL )
		int tacClipCount       = tacticalAbility.GetWeaponPrimaryClipCount()
		int maxAmmo            = tacticalAbility.GetWeaponPrimaryClipCountMax()

		if ( tacticalAbility.GetWeaponClassName() == "mp_ability_revenant_shadow_pounce_free" )
		{
			if ( tacClipCount != maxAmmo )
				tacticalAbility.SetWeaponPrimaryClipCount( maxAmmo )
		}
	}
}

void function ShadowForm_ApplyShadowSkin( entity player )
{
	//////////////////////////////////////
	// Apply the shadow skin material if we have it
	//////////////////////////////////////

	int skinIdx = player.GetSkinIndexByName( "ShadowSquad_reborn_3p" )
	if ( skinIdx > 0 )
	{
		player.SetSkin( skinIdx )
		player.SetCamo( 0 )
	}
	else //otherwise just tint the player full black till we get the skin
	{
		player.kv.rendercolor = <0, 0, 0>
	}
}
#endif

#if CLIENT
void function ShadowForm_StartClient( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	thread ShadowForm_FXThink( ent )
}

void function ShadowForm_StopClient( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	Rumble_Play( "rumble_burn_card_activate", {} )

	ent.Signal( "ShadowForm_EndShadowScreenFx" )
}

void function ShadowForm_FXThink( entity player )
{
	if( !IsValid( player ) )
		return
	entity cockpit = player.GetCockpit()
	if( !IsValid( cockpit ) )
		return

	EndSignal( player, "OnDeath", "OnDestroy", "BleedOut_OnStartDying", "ShadowForm_EndShadowScreenFx" )

	int fxHandle = StartParticleEffectOnEntity( cockpit, GetParticleSystemIndex( SHADOW_FORM_SHADOW_SCREEN_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	EffectSetIsWithCockpit( fxHandle, true )
	vector controlPoint = <1, 1, 1>
	EffectSetControlPointVector( fxHandle, 1, controlPoint )

	thread ColorCorrection_LerpWeight( file.colorCorrection, 0, 1, 0.25 )

	thread ShadowShield_ToggleFX_Think( player )

	EmitSoundOnEntity( player, SHADOW_FORM_ACTIVATE_SOUND_1P ) // 1p activation sound
	EmitSoundOnEntity( player, SHADOW_FORM_LOOP_SOUND_1P )  // 1p looping sound

	file.mitigatedDamageRemaining = file.shieldHealth

	OnThreadEnd(
		function() : ( player, fxHandle )
		{
			if( IsValid( player ) )
			{
				StopSoundOnEntity( player, SHADOW_FORM_LOOP_SOUND_1P ) // 1p end loop sound
				EmitSoundOnEntity( player, SHADOW_FORM_DEACTIVATE_SOUND_1P ) // 1p end sound
			}

			if ( EffectDoesExist( fxHandle ) )
				EffectStop( fxHandle, true, true )

			thread ColorCorrection_LerpWeight( file.colorCorrection, 1, 0, 1 )
		}
	)

	WaitForever()
}

void function ShadowShield_ToggleFX_Think( entity player )
{
	if( !IsValid( player ) )
		return
	entity cockpit = player.GetCockpit()
	if( !IsValid( cockpit ) )
		return
	entity viewPlayer = GetLocalViewPlayer()
	if ( player != GetLocalViewPlayer() )
		return

	EndSignal( player, "OnDeath", "OnDestroy", "BleedOut_OnStartDying", "ShadowForm_EndShadowScreenFx" )

	file.shadowShieldFx = StartParticleEffectOnEntity( viewPlayer, GetParticleSystemIndex( SHADOW_FORM_SHIELD_ACTIVE_FX_1P ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	EffectSetIsWithCockpit( file.shadowShieldFx, true )
	Rumble_Play( "rumble_stim_activate", {} )

	OnThreadEnd(
		function() : ()
		{
			if ( EffectDoesExist( file.shadowShieldFx ) )
				EffectStop( file.shadowShieldFx, true, true )
		}
	)

	bool effectiveActive = true
	while( true )
	{
		float shieldHealth = player.GetPlayerNetFloat( SHADOW_FORM_HEALTH_NETVAR )
		if( effectiveActive && ( shieldHealth <= 0.0 ) )
		{
			if( EffectDoesExist( file.shadowShieldFx ) )
				EffectStop( file.shadowShieldFx, true, true )
			effectiveActive = false
		}
		if( !effectiveActive && ( shieldHealth == file.shieldHealth ) )
		{
			file.shadowShieldFx = StartParticleEffectOnEntity( viewPlayer, GetParticleSystemIndex( SHADOW_FORM_SHIELD_ACTIVE_FX_1P ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
			EffectSetIsWithCockpit( file.shadowShieldFx, true )
			effectiveActive = true
			Rumble_Play( "rumble_stim_activate", {} )
		}

		WaitFrame()
	}
}

#if CLIENT
void function MpAbilityShadowForm_PopulateRui( entity player,  var rui )
{
	if( rui != null )
	{
		RuiTrackFloat( rui, "timeRemaining", player, RUI_TRACK_STATUS_EFFECT_TIME_REMAINING, eStatusEffect.shadow_form )
		RuiSetFloat( rui, "mitigatedDamageRemaining", file.mitigatedDamageRemaining )
		RuiSetFloat( rui, "maxMitigatedDamage", file.shieldHealth )
		RuiSetBool( rui, "enableDmgFlash", file.enableDmgFlash )
		RuiSetBool( rui, "enableHealFlash", file.enableHealFlash )
		RuiSetBool( rui, "isRecharging", file.isRecharging )
		RuiSetGameTime( rui, "lastKillTime", file.lastKillTime )
	}
}
#endif

#if CLIENT
bool function MpAbilityShadowForm_GetEnableHealFlash()
{
	return file.enableHealFlash
}
#endif

#if CLIENT
bool function MpAbilityShadowForm_IsRecharging()
{
	return file.isRecharging
}
#endif

void function ServerToClient_DoShadowShieldDamageIndicator( entity player, entity attacker, int damageSourceId )
{
	if ( IsValid( player ) && IsValid( attacker ) )
	{
		if ( player == GetLocalViewPlayer() )
		{
			vector damageOrigin = attacker.GetWorldSpaceCenter()
			DamageIndicators( damageOrigin, attacker, damageSourceId )
		}
	}
}

void function ServerToClient_UpdateDamageRUI( bool isHeal, bool isKill , float shadowFormHealth )
{
	entity player = GetLocalViewPlayer()

	if( IsInForgedShadows( player ) )
	{
		file.mitigatedDamageRemaining = shadowFormHealth

		if( isHeal )
		{
			if( !isKill )
				thread HealFlash( player )
			else
				file.lastKillTime = Time()
		}
		else
			thread DamageTakenFlash( player )
	}
}

void function DamageTakenFlash( entity player )
{
	if( !IsValid( player ) )
		return
	entity viewPlayer = GetLocalViewPlayer()
	if( player != viewPlayer )
		return

	player.Signal( "EndDamageFlash" )
	EndSignal( player, "EndDamageFlash" )

	int shieldDamageFx = StartParticleEffectOnEntity( viewPlayer, GetParticleSystemIndex( SHADOW_FORM_SHIELD_HIT_FX_1P ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	EffectSetIsWithCockpit( shieldDamageFx, true )
	int shieldDamageHexFx = StartParticleEffectOnEntity( viewPlayer, GetParticleSystemIndex( SHADOW_FORM_SHIELD_HIT_FX2_1P ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	EffectSetIsWithCockpit( shieldDamageHexFx, true )

	Rumble_Play( "rumble_pilot_hurt", {} )

	OnThreadEnd(
		function() : ( player, shieldDamageFx, shieldDamageHexFx )
		{
			if( IsAlive( player ) )
				file.enableDmgFlash = true

			if( EffectDoesExist( shieldDamageFx ) )
				EffectStop( shieldDamageFx, true, true )

			if( EffectDoesExist( shieldDamageHexFx ) )
				EffectStop( shieldDamageHexFx, true, true )
		}
	)

	file.enableDmgFlash = false

	wait 0.2

	return
}

void function HealFlash( entity player )
{
	player.Signal( "EndHealFlash" )
	EndSignal( player, "EndHealFlash" )

	OnThreadEnd(
		function() : ( player )
		{
			file.isRecharging    = false
			file.enableHealFlash = false
		}
	)

	file.isRecharging    = true
	file.enableHealFlash = true

	wait 0.4

	return
}

void function ColorCorrection_LerpWeight( int colorCorrection, float startWeight, float endWeight, float lerpTime = 0 )
{
	float startTime = Time()
	float endTime = startTime + lerpTime
	ColorCorrection_SetExclusive( colorCorrection, true )

	while ( Time() <= endTime )
	{
		WaitFrame()
		float weight = GraphCapped( Time(), startTime, endTime, startWeight, endWeight )
		ColorCorrection_SetWeight( colorCorrection, weight )
	}

	ColorCorrection_SetWeight( colorCorrection, endWeight )
}
#endif