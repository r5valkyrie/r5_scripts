global function OnWeaponPrimaryAttack_holopilot
global function OnWeaponChargeLevelIncreased_holopilot
global function OnWeaponActivate_holopilot
global function PlayerCanUseDecoy
#if CLIENT
global function CreateARIndicator
                     
global function ServerToClient_ShowHolopilotDestroyedText
                           
#endif

const string FLASH_DECOY_IMPACT_TABLE = "exp_emp"

global const int DECOY_FADE_DISTANCE = 16000 //Really just an arbitrarily large number
const float DECOY_PING_MIN_DURATION = 1.5
const float DECOY_PING_MAX_DURATION = 8.0
const float ULTIMATE_DECOY_DURATION = 5.0

                     
const float BAMBOOZLE_DURATION = 3.5
      
                    
const int UPGRADE_MIRAGE_TACTICAL_DECOY_MAX = 2
      
global const vector HOLOPILOT_ANGLE_SEGMENT = <0, 60, 0>
global function Decoy_Init

const DECOY_AR_MARKER = $"P_ar_ping_squad_CP"
const float DECOY_TRACE_DIST = 5000.0

global function CodeCallback_PlayerDecoyStateChange
#if SERVER
global function CodeCallback_PlayerDecoyDie
global function CodeCallback_PlayerDecoyDissolve
global function CodeCallback_PlayerDecoyRemove
global function CodeCallback_DecoyFakeWeapon
global function CreateHoloPilotDecoys
global function SetupDecoy_Common
global function HoloPilot_OnDecoyDamaged
                     
global function HoloPilot_OnDecoyKilled
      
global function GetThreatPriorityForHolopilot
global function ClientCallback_ToggleDecoys
global function DecoyDestroyOnPlayerDeathOrClassChange
#endif // SERVER

global const SOUND_DECOY_CONTROL = "Mirage_PsycheOut_ModeSwitch"
global const SOUND_DECOY_RELEASE = "Mirage_PsycheOut_ModeSwitch"

global const string DECOY_SCRIPTNAME = "controllable_decoy"
global const string CONTROLLED_DECOY_SCRIPTNAME = "controlled_decoy"

const DECOY_FLAG_FX = $"P_flag_fx_foe"
const HOLO_EMITTER_CHARGE_FX_1P = $"P_mirage_holo_emitter_glow_FP"
const HOLO_EMITTER_CHARGE_FX_3P = $"P_mirage_emitter_flash"
const asset DECOY_TRIGGERED_ICON = $"rui/hud/tactical_icons/tactical_mirage_in_world"

enum eDecoyReceiveDamage
{
	NORMAL,
	FATAL,
	ZERO_DAMAGE,
}

struct
{
	#if SERVER
		array<entity> passiveDecoys
		array<entity> ultimateDecoys
		array<entity> tacticalDecoys
	#endif

	float decoyDuration

	float decoy_ping_min_duration = 3.0
	float decoy_ping_max_duration = 8.0
	float decoy_cloak_duration = 0.0
	float decoy_cloak_fadein = 0.0

	bool decoyFlashEnabled
} file

void function Decoy_Init()
{
	file.decoyFlashEnabled = GetCurrentPlaylistVarBool( "mirage_flashbang_decoys", false )

	Remote_RegisterServerFunction( "ClientCallback_ToggleDecoys" )

	#if SERVER
		RegisterSignal( "CleanupFXAndSoundsForDecoy" )
		RegisterSignal( "MirageSpotted" )
		RegisterSignal( "HighlightShooter" )
		RegisterSignal( "DecoyConvert" )

		PrecacheParticleSystem( HOLO_EMITTER_CHARGE_FX_1P )
		PrecacheParticleSystem( HOLO_EMITTER_CHARGE_FX_3P )

		if ( file.decoyFlashEnabled )
			PrecacheImpactEffectTable( FLASH_DECOY_IMPACT_TABLE )
	#else
		PrecacheParticleSystem( DECOY_AR_MARKER )

		AddCreateCallback( "player_decoy", OnDecoyCreate )

		RegisterConCommandTriggeredCallback( "+scriptCommand5", AttemptToggleDecoys )
	#endif

	file.decoy_ping_min_duration = GetCurrentPlaylistVarFloat( "mirage_sonar_min_duration", 0.0 )
	file.decoy_ping_max_duration = GetCurrentPlaylistVarFloat( "mirage_sonar_max_duration", 0.0 )

	file.decoy_cloak_duration = GetCurrentPlaylistVarFloat( "mirage_decoy_cloak_duration", 0.0 )
	file.decoy_cloak_fadein = GetCurrentPlaylistVarFloat( "mirage_decoy_cloak_fadein", 2.5 )

	file.decoyDuration = GetCurrentPlaylistVarFloat( "mirage_decoy_duration", 60.0 )

	PrecacheScriptString( DECOY_SCRIPTNAME )
	PrecacheScriptString( CONTROLLED_DECOY_SCRIPTNAME )
}

#if SERVER
void function CleanupExistingDecoy( entity decoy )
{
	if ( IsValid( decoy ) ) //This cleanup function is called from multiple places, so check that decoy is still valid before we try to clean it up again
	{
		decoy.Decoy_Dissolve()
		CleanupFXAndSoundsForDecoy( decoy )
	}
}

void function CleanupFXAndSoundsForDecoy( entity decoy )
{
	if ( !IsValid( decoy ) )
		return

	decoy.Signal( "CleanupFXAndSoundsForDecoy" )

	foreach ( fx in decoy.decoy.fxHandles )
	{
		if ( IsValid( fx ) )
		{
			fx.ClearParent()
			EffectStop( fx )
		}
	}

	decoy.decoy.fxHandles.clear() //probably not necessary since decoy is already being cleaned up, just for throughness.

	foreach ( loopingSound in decoy.decoy.loopingSounds )
	{
		StopSoundOnEntity( decoy, loopingSound )
	}

	decoy.decoy.loopingSounds.clear()
}

void function OnHoloPilotDestroyed( entity decoy, int state )
{
	entity bossPlayer = decoy.GetBossPlayer()
	if ( IsValid( bossPlayer ) )
	{
		if ( bossPlayer.IsPlayer() && PlayerHasPassive( bossPlayer, ePassives.PAS_MIRAGE ) )
		{
			EmitSoundAtPositionOnlyToPlayer( TEAM_ANY, decoy.GetOrigin(), bossPlayer, "Mirage_PsycheOut_Decoy_End_1P" )
			EmitSoundAtPositionExceptToPlayer( TEAM_ANY, decoy.GetOrigin(), bossPlayer, "Mirage_PsycheOut_Decoy_End_3P" )

			                          
			if( state == 0 )
			{
				entity tacticalWeapon =  bossPlayer.GetOffhandWeapon( OFFHAND_TACTICAL )
				if( IsValid( tacticalWeapon ) )
				{
					int curTacAmmo = tacticalWeapon.GetWeaponPrimaryClipCount()
					int maxTacAmmo = tacticalWeapon.GetWeaponPrimaryClipCountMax()
					
					if( curTacAmmo < maxTacAmmo )
					{
						tacticalWeapon.SetWeaponPrimaryClipCountNoRegenReset( maxTacAmmo )
					}
				}
			}
         
		}
	}

	CleanupFXAndSoundsForDecoy( decoy )
}

void function CodeCallback_PlayerDecoyDie( entity decoy, int currentState )
//All Die does is play the death animation. Eventually calls CodeCallback_PlayerDecoyDissolve too
{
	//PrintFunc()
	OnHoloPilotDestroyed( decoy, currentState )
}

void function CodeCallback_PlayerDecoyDissolve( entity decoy, int currentState )
{
	//PrintFunc()
	OnHoloPilotDestroyed( decoy, currentState )
}

void function CodeCallback_PlayerDecoyRemove( entity decoy, int currentState )
{
	//PrintFunc()
}

void function CodeCallback_DecoyFakeWeapon( entity decoy, entity player, entity weapon, entity fakeWeapon )
{
	return
}
#endif // SERVER

void function CodeCallback_PlayerDecoyStateChange( entity decoy, int previousState, int currentState )
{
	//PrintFunc()
}


var function OnWeaponPrimaryAttack_holopilot( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	Assert( weaponOwner.IsPlayer() )

	if ( !PlayerCanUseDecoy( weaponOwner ) )
		return 0

	int chargeLevel = weapon.IsChargeWeapon() ? weapon.GetWeaponChargeLevel() : 1
	if ( weapon.GetWeaponChargeLevelMax() > 1 )
		chargeLevel *= 2 // We want to send  out 6, but the charge visual is tied to the level being 3
	//chargeLevel = int( min( chargeLevel, weapon.GetWeaponPrimaryClipCount() / weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire ) ) )
	#if SERVER
		vector offsetOrigin = OFFSET_ORIGIN_DEFAULTPARAM
		                     
			if ( HoverVehicle_IsPlayerInAnyVehicle( weaponOwner ) )
			{
				const vector VEHICLE_HEIGHT = <0.0, 0.0, 32.0>
				const float VEHICLE_FORWARD = 64.0
				offsetOrigin = (VEHICLE_HEIGHT + weaponOwner.GetViewVector() * VEHICLE_FORWARD)
			}
                             
		array<entity> holos = CreateHoloPilotDecoys( weaponOwner, chargeLevel, "", offsetOrigin )
		                    
			bool hasUpgradeExtraDecoy = weaponOwner.HasPassive( ePassives.PAS_TAC_UPGRADE_ONE )
			bool hasUpgradeRefreshDecoy = weaponOwner.HasPassive( ePassives.PAS_TAC_UPGRADE_TWO )
			//Destroy Oldest clone if we try to use more than the Tac Limit
			if( hasUpgradeExtraDecoy || hasUpgradeRefreshDecoy )
			{
				if( weapon.w.holoEntities.len() >= GetMaxAllowedTacticalDecoys( weaponOwner ) )
				{
					if( IsValid( weapon.w.holoEntities[0] ) )
						weapon.w.holoEntities[0].Destroy()
				}
			}
        

		ArrayRemoveInvalid( weapon.w.holoEntities )

		                    
		if( !hasUpgradeExtraDecoy )
        
			{
				foreach ( h in weapon.w.holoEntities )
					h.Destroy()
				weapon.w.holoEntities.clear()
			}

		foreach ( h in holos )
		{
			h.SetScriptName( DECOY_SCRIPTNAME )
			                      
			if (!weapon.HasMod(COPYCAT_MOD))
         
			h.SetTeamMemberIndex( 99 )

		}
		                    
		if( hasUpgradeExtraDecoy )
		{
			foreach ( h in holos )
			{
				weapon.w.holoEntities.append( h )
			}
		}
		else
        
		weapon.w.holoEntities = holos

		thread TryAutoConvertToMimic( weaponOwner )
		if ( chargeLevel <= 1 )
		{
			//thread PlayBattleChatterLineDelayedToSpeakerAndTeam( weaponOwner, weapon.GetWeaponSettingString( eWeaponVar.battle_chatter_event ), 0.2 )
		}
	#else
		if ( chargeLevel == 1 )
			CreateARIndicator( weaponOwner )
	#endif

	PlayerUsedOffhand( weaponOwner, weapon )

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire ) //* chargeLevel
}

                    
int function GetMaxAllowedTacticalDecoys( entity player )
{
	if( player.HasPassive( ePassives.PAS_TAC_UPGRADE_ONE ) ) // upgrade_mirage_tactical_upgrade
		return GetCurrentPlaylistVarInt( "upgrade_mirage_tactical_decoy_max", UPGRADE_MIRAGE_TACTICAL_DECOY_MAX )

	return 1
}
      

#if SERVER
void function TryAutoConvertToMimic( entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "DecoyConvert" )

	float startTime = Time()
	float endTime   = Time() + 0.3

	while ( player.IsInputCommandHeld( IN_OFFHAND1 ) )
	{
		if ( Time() >= endTime )
		{
			thread TryAutoConvertToMimic_Pt2( player )
			return
		}

		WaitFrame()
	}
}

void function TryAutoConvertToMimic_Pt2( entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "DecoyConvert" )

	entity weapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )

	if ( IsValid( weapon ) )
	{
		foreach ( decoy in weapon.w.holoEntities )
		{
			if ( IsValid( decoy ) )
			{
				Highlight_SetOwnedHighlight( decoy, "sp_objective_outline" )
			}
		}
	}

	while ( player.IsInputCommandHeld( IN_OFFHAND1 ) )
	{
		WaitFrame()
	}

	thread Decoy_ConvertToMimic( player )
}

void function ClientCallback_ToggleDecoys( entity player )
{
	player.Signal( "DecoyConvert" )

	if ( AreAbilitiesSilenced( player ) )
		return

	Decoy_ConvertToMimic( player )
}

void function Decoy_ConvertToMimic( entity player )
{
	entity weapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )

	if ( IsValid( weapon ) )
	{
		if ( weapon.w.voDebounceTime < Time() )
		{
			weapon.w.holoEntities = ConvertHolosToMimics( weapon.GetOwner(), weapon.w.holoEntities )
			weapon.w.voDebounceTime = Time() + 0.3
		}
	}
}

#endif

#if CLIENT
void function CreateARIndicator( entity player )
{
	vector decoyPos
	bool validPos = false
	if ( player.HasThirdPersonAttackFocus() )
	{
		decoyPos = player.GetThirdPersonAttackFocus()
		validPos = true
	}
	else
	{
		vector eyePos      = player.EyePosition()
		vector viewVector  = player.GetViewVector()
		TraceResults trace = TraceLine( eyePos, eyePos + (viewVector * DECOY_TRACE_DIST), player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
		if ( trace.fraction < 1.0 )
		{
			decoyPos = trace.endPos
			validPos = true
		}
	}

	if ( validPos )
	{
		TraceResults trace = TraceLine( decoyPos, decoyPos + <0, 0, -2000>, player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
		int arID           = GetParticleSystemIndex( DECOY_AR_MARKER )
		int fxHandle       = StartParticleEffectInWorldWithHandle( arID, trace.endPos, trace.surfaceNormal )
		EffectSetControlPointVector( fxHandle, 1, FRIENDLY_COLOR_FX )
		thread DestroyAfterTime( fxHandle, 1.0 )
	}
}

void function DestroyAfterTime( int fxHandle, float time )
{
	OnThreadEnd(
		function() : ( fxHandle )
		{
			if ( !EffectDoesExist( fxHandle ) )
				return

			EffectStop( fxHandle, true, true )
		}
	)
	wait(time)
}
#endif

#if SERVER
const vector OFFSET_ORIGIN_DEFAULTPARAM = <-1, -1, -1>
array<entity> function CreateHoloPilotDecoys( entity player, int numberOfDecoysToMake = 1, string animToPlay = "", vector offsetOrigin = OFFSET_ORIGIN_DEFAULTPARAM, vector angleOverride = <-1, -1, -1> )
{
	Assert( numberOfDecoysToMake > 0 )
	Assert( player )

	array<entity> holos

	TestHolopilotLimit( numberOfDecoysToMake )

	float displacementDistance = 30.0

	bool setOriginAndAngles = ((numberOfDecoysToMake > 1) || (angleOverride != <-1, -1, -1>))

	asset modelName      = $""
	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	ItemFlavor skin      = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_CharacterSkin( character ) )

	vector eyePos     = player.EyePosition()
	vector viewVector = player.GetViewVector()
	for ( int i = 0; i < numberOfDecoysToMake; ++i )
	{
		entity decoy
		if ( setOriginAndAngles )
		{
			//printt( "ult I think" )
			vector angleToAdd      = angleOverride != <-1, -1, -1> ? angleOverride : CalculateAngleSegmentForDecoy( i, HOLOPILOT_ANGLE_SEGMENT )
			vector normalizedAngle = player.GetAngles() + angleToAdd
			normalizedAngle.y = AngleNormalize( normalizedAngle.y ) //Only care about changing the yaw
			vector forwardVector = AnglesToForward( normalizedAngle )
			TraceResults trace   = TraceLine( eyePos, eyePos + (forwardVector * 100), player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
			decoy = CreateDecoy( trace.endPos, $"", modelName, player, skin, ULTIMATE_DECOY_DURATION, true )
			decoy.SetAngles( normalizedAngle )
			decoy.e.canBurn = true
			forwardVector *= displacementDistance
			vector baseOrigin = ((offsetOrigin != OFFSET_ORIGIN_DEFAULTPARAM) ? (offsetOrigin + <0, 0, 25>) : player.GetOrigin())
			decoy.SetOrigin( baseOrigin + forwardVector ) //Using player origin instead of decoy origin as defensive fix, see bug 223066
			PutEntityInSafeSpot( decoy, player, null, baseOrigin, decoy.GetOrigin() )
			player.p.decoy = decoy
			AddUltimateDecoy( decoy )
		}
		else if ( animToPlay != "" )
		{
			//printt( "is this ultimate?" )
			Assert( player.LookupSequence( animToPlay ) != -1, " bug design about getting a demo for this and debugging" )
			if ( player.LookupSequence( animToPlay ) != -1 )
			{
				decoy = player.CreateAnimatedPlayerDecoy( animToPlay )
				thread CleanUpPassiveDecoyIfExecuted( decoy, player )
				player.p.decoy = decoy
				AddPassiveDecoy( decoy )
			}
			else
			{
				continue
			}
		}
		else
		{
			// ACTUAL TACTICAL SCRIPT PATH
			//ValidDecoyDisguise vdd = SetNextDisguiseCharacter( player )
			//modelName = CharacterSkin_GetBodyModel( vdd.skin )
			//skin = vdd.skin
			asset characterSetFile = $""//CharacterClass_GetSetFile( vdd.character )

			vector decoyPos
			if ( player.HasThirdPersonAttackFocus() )
			{
				decoyPos = player.GetThirdPersonAttackFocus()
			}
			else
			{
				TraceResults trace = TraceLine( eyePos, eyePos + (viewVector * DECOY_TRACE_DIST), player, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
				decoyPos = trace.endPos
			}
			decoy = CreateDecoy( decoyPos, characterSetFile, modelName, player, skin, file.decoyDuration, true )
			if ( IsValid( decoy ) && (offsetOrigin != OFFSET_ORIGIN_DEFAULTPARAM) )
			{
				vector newOrigin = (player.GetOrigin() + offsetOrigin)
				PutEntityInSafeSpot( decoy, player, null, newOrigin, newOrigin )
			}
			player.p.decoy = decoy
			AddTacticalDecoy( decoy )
		}

		if ( !IsValid( decoy ) )
			continue

		bool ultimateDecoy = numberOfDecoysToMake > 1
		SetupDecoy_Common( player, decoy, ultimateDecoy )
		if ( animToPlay != "" )
		{
			decoy.SetMaxHealth( 2000 )
			decoy.SetHealth( 2000 )
			decoy.SetCanBeMeleed( false )
			//decoy.SetPlayerOneHits( false )
		}

		decoy.SetScriptName( DECOY_SCRIPTNAME )
		decoy.e.spawnTime = Time()
		holos.append( decoy )
	}

	return holos
}

void function CleanUpPassiveDecoyIfExecuted( entity decoy, entity player )
{
	player.EndSignal( "OnSyncedMeleeVictim" )
	decoy.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( decoy, player )
		{
			if ( IsValid( player ) && player.IsCloaked( true ) )
				DisableCloak( player )
			CleanupExistingDecoy( decoy ) //Is valid check in function
		}
	)

	wait ULTIMATE_DECOY_DURATION
}

/*
ValidDecoyDisguise function SetNextDisguiseCharacter( entity player )
{
	ValidDecoyDisguise vdd
	vdd.character = expect ItemFlavor(GetRandomGoodItemFlavorForLoadoutSlot( EHI_null, Loadout_CharacterClass() ))
	vdd.skin = expect ItemFlavor(GetRandomGoodItemFlavorForLoadoutSlot( ToEHI( player ), Loadout_CharacterSkin( vdd.character ) ))
	return vdd
}
*/

int function GetThreatPriorityForHolopilot( entity player )
{
	const int EXTRA_PRIORITY = 0

	int setting = (IsValid( player ) ? player.GetPlayerSettingInt( "aiEnemy_priority" ) : 10)
	return (setting + EXTRA_PRIORITY)
}

void function DecoyDestroyOnPlayerDeathOrClassChange( entity player, entity decoy, float duration )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "PlayerChangedClass" )
	decoy.EndSignal( "OnDestroy" )
	OnThreadEnd(
		function() : ( player, decoy )
		{
			if ( IsValid( decoy ) )
			{
				CleanupExistingDecoy( decoy )
			}
		}
	)
	Wait( duration )
}

entity function CreateDecoy( vector endPosition, asset settingsName, asset modelName, entity player, ItemFlavor skin, float duration, bool moveForwardDefault )
{
	entity decoy = player.CreateTargetedPlayerDecoy( endPosition, settingsName, modelName, 0, 0 )
	CharacterSkin_Apply( decoy, skin )
	int decoyHealth = GetCurrentPlaylistVarInt( "mirage_decoy_health", 45 )
	decoy.SetMaxHealth( decoyHealth )
	decoy.SetHealth( decoyHealth )
	decoy.EnableAttackableByAI( GetThreatPriorityForHolopilot( player ), 0, AI_AP_FLAG_NONE )
	decoy.SetCanBeMeleed( true )
	decoy.SetTimeout( duration )
	//decoy.SetPlayerOneHits( true )
	decoy.SetOwner( player )
	decoy.SetAimAssistAllowed( true )

	thread TrapDestroyOnRoundEnd( player, decoy )
	thread DecoyDestroyOnPlayerDeathOrClassChange( player, decoy, duration )

	decoy.Highlight_Enable()
	AddEMPDamageDevice( decoy )

	StatsHook_HoloPiliot_OnDecoyCreated( player )
	AddEntityCallback_OnDamaged( decoy, void function( entity decoy, var damageInfo ) : ( player ) {
		if ( IsValid( player ) )
			HoloPilot_OnDecoyPreDamaged( decoy, player, damageInfo )
	} )
	AddEntityCallback_OnPostDamaged( decoy, void function( entity decoy, var damageInfo ) : ( player ) {
		if ( IsValid( player ) )
			HoloPilot_OnDecoyDamaged( decoy, player, damageInfo )
	} )
	                     
	AddEntityCallback_OnKilled( decoy, void function( entity decoy, var damageInfo ) : ( player ) {
		if (IsValid( player ) )
			HoloPilot_OnDecoyKilled( decoy, player, damageInfo )
	})
       
	return decoy
}

entity function CreateDecoyFromMimic(asset settingsName, asset modelName, entity player, ItemFlavor skin, float duration, bool moveForwardDefault, vector inheritedDecoyVelocity )
{
	entity decoy = player.CreatePlayerDecoy( settingsName, modelName, 0, 0, 0.75, true )
	CharacterSkin_Apply( decoy, skin )
	int decoyHealth = GetCurrentPlaylistVarInt( "mirage_decoy_health", 45 )
	decoy.SetMaxHealth( decoyHealth )
	decoy.SetHealth( decoyHealth )
	decoy.EnableAttackableByAI( GetThreatPriorityForHolopilot( player ), 0, AI_AP_FLAG_NONE )
	decoy.SetCanBeMeleed( true )
	decoy.SetTimeout( duration )
	//decoy.SetPlayerOneHits( true )
	decoy.SetOwner( player )
	decoy.SetAimAssistAllowed( true )

	decoy.Highlight_Enable()
	AddSonarDetectionForPropScript( decoy )
	AddEMPDamageDevice( decoy )

	StatsHook_HoloPiliot_OnDecoyCreated( player )
	AddEntityCallback_OnDamaged( decoy, void function( entity decoy, var damageInfo ) : ( player ) {
		if ( IsValid( player ) )
			HoloPilot_OnDecoyPreDamaged( decoy, player, damageInfo )
	} )
	AddEntityCallback_OnPostDamaged( decoy, void function( entity decoy, var damageInfo ) : ( player ) {
		if ( IsValid( player ) )
			HoloPilot_OnDecoyDamaged( decoy, player, damageInfo )
	} )
	                     
	AddEntityCallback_OnKilled( decoy, void function( entity decoy, var damageInfo ) : ( player ) {
		if (IsValid( player ) )
			HoloPilot_OnDecoyKilled( decoy, player, damageInfo )
	})
       
	return decoy
}

int function DetermineDecoyDamageOutcome( entity owner, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( attacker ) )
		return eDecoyReceiveDamage.NORMAL

	if ( !IsEnemyTeam( owner.GetTeam(), attacker.GetTeam() ) )
		return eDecoyReceiveDamage.NORMAL

	if ( attacker.IsNPC() )
		return eDecoyReceiveDamage.NORMAL

	bool hasUpgradedDecoyBonus = file.decoy_ping_max_duration > 0 || file.decoy_cloak_duration > 0
	if ( hasUpgradedDecoyBonus )
	{
		if ( !IsBitFlagSet( DamageInfo_GetCustomDamageType( damageInfo ), DF_BULLET ) || DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.mp_weapon_tesla_trap )
		{
			// Only bullets damage upgraded decoys
			return eDecoyReceiveDamage.ZERO_DAMAGE
		}
	}

	if ( attacker.IsPlayer() )
		return eDecoyReceiveDamage.NORMAL

	return eDecoyReceiveDamage.NORMAL
}

void function HoloPilot_OnDecoyPreDamaged( entity decoy, entity owner, var damageInfo )
{
	int damageOutcome = DetermineDecoyDamageOutcome( owner, damageInfo )

	if ( damageOutcome == eDecoyReceiveDamage.FATAL )
	{
		DamageInfo_SetDamage( damageInfo, decoy.GetHealth() )
	}
	else if ( damageOutcome == eDecoyReceiveDamage.ZERO_DAMAGE )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
	}
}

void function HoloPilot_OnDecoyDamaged( entity decoy, entity owner, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( attacker ) || !attacker.IsPlayer() || !IsEnemyTeam( owner.GetTeam(), attacker.GetTeam() ) )
		return

	if ( decoy.e.attachedEnts.contains( attacker ) )
		return

	if ( DamageInfo_GetDamage( damageInfo ) <= 0 )
	{
		if ( DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.mp_weapon_arc_bolt ) // TODO: Script bleed, maybe this should be a damage flag?
		{
			entity inflictor = DamageInfo_GetInflictor( damageInfo )
			if ( IsValid( inflictor ) && ArcBolt_IsBoltPlanted( inflictor ) )
				return
		}
		else
		{
			return
		}
	}

	StatsHook_HoloPiliot_OnDecoyDamaged( decoy, owner, attacker, damageInfo )

	decoy.e.attachedEnts.append( attacker )

	vector damagePos = DamageInfo_GetDamagePosition( damageInfo )

	                     
		if ( GetCurrentPlaylistVarBool( "mirage_rework_enabled", true ) )
		{
			int damageType = DamageInfo_GetDamageType( damageInfo )
			if ( damageType == DMG_BULLET || damageType == DMG_MELEE_ATTACK )
				PingForDecoyTriggered( decoy, owner, attacker, damagePos )
		}
		else
                            
		{
			PingForDecoyTriggered( decoy, owner, attacker, damagePos )
		}

	                    
		if( IsValid( owner ) && owner.HasPassive( ePassives.PAS_TAC_UPGRADE_TWO ) )
		{
			entity tacticalWeapon = owner.GetOffhandWeapon( OFFHAND_TACTICAL )
			if ( IsValid( tacticalWeapon ) )
			{
				int maxTacAmmo 		= tacticalWeapon.GetWeaponPrimaryClipCountMax()
				tacticalWeapon.SetWeaponPrimaryClipCountNoRegenReset( maxTacAmmo )
			}
		}
       
}

                     
void function HoloPilot_OnDecoyKilled( entity decoy, entity owner, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( attacker ) || !IsEnemyTeam( owner.GetTeam(), attacker.GetTeam() ) )
		return

	int damageType = DamageInfo_GetDamageType( damageInfo )
	if ( damageType != DMG_BULLET && damageType != DMG_MELEE_ATTACK )
	{
		Remote_CallFunction_Replay( owner, "ServerToClient_ShowHolopilotDestroyedText" )
	}
}
                           

entity function PingForDecoyTriggered( entity decoy, entity playerOwner, entity targetEnt, vector damagePos )
{
	if ( playerOwner.IsPlayer() )
		EmitSoundOnEntityOnlyToPlayer( playerOwner, playerOwner, "ui_mapping_item_1p" )

	vector wpPosition = targetEnt.GetOrigin()
	entity wp
	                     
		if ( GetCurrentPlaylistVarBool( "mirage_rework_enabled", true ) )
		{
			wp = CreateWaypoint_TrackEnt( targetEnt, "", DECOY_TRIGGERED_ICON, <0, 0, 50> )
			wp.SetParent( targetEnt )

			LockOnWarningStart( targetEnt )
			StatusEffect_AddTimed( targetEnt, eStatusEffect.mirage_detected, 1.0, BAMBOOZLE_DURATION, 0.0 )
		}
		else
                            
		{
			wp = CreateWaypoint_BasicPos( wpPosition + <0, 0, 96>, "", DECOY_TRIGGERED_ICON )
		}
	wp.SetOwner( playerOwner )

	// Transmit to single team. If using Alliances also show to friendly alliance players
	AllianceProximity_SetOnlyTransmitWaypointToFriendlyTeams( wp, playerOwner.GetTeam() )

	targetEnt.Signal( "MirageSpotted" )

	if ( playerOwner.IsPlayer() && targetEnt.IsPlayer() )
		AddAssistingPlayerToVictim( playerOwner, targetEnt )

	EmitSoundOnEntityToEnemies( decoy, "diag_mp_mirage_bc_bamboozled_3p", playerOwner.GetTeam() )

	thread DelayedDestroyTracking( wp, targetEnt )

                      
	//Unique Mirage line when Mirage shoots a decoy that is not of himself
	if ( !IsPlayerCharacter ( playerOwner,"character_mirage" ) && IsPlayerCharacter ( targetEnt,"character_mirage" ) )
	{
		//thread PlayBattleChatterLineDelayedToSpeakerAndTeam( targetEnt, "diag_mp_playerM1_bc_copycatBamboozleKilled_1p", 0.0 )
		EmitSoundOnEntityOnlyToPlayer( targetEnt, targetEnt, "diag_mp_mirage_bc_copycatBamboozleKilled_1p"  )
	}
	//Play a character specific Bamboozle line if you are not Mirage and your clone gets shot
	else if ( !IsPlayerCharacter ( playerOwner,"character_mirage" ) )
	{
		thread PlayBattleChatterLineDelayedToSpeakerAndTeam( playerOwner, "bc_copycatBamboozle", 0.0 )
	}
	//Just be normal
	else
      
		thread PlayBattleChatterLineDelayedToSpeakerAndTeam( playerOwner, "bc_tacticalTaunt", 0.0 )


	Highlight_ClearOwnedHighlight( decoy )

	if ( GetDecoySonarMaxDuration( playerOwner ) > 0 && GetDecoySonarMinDuration( playerOwner ) > 0 )
		thread HighlightShooter( decoy, playerOwner, targetEnt )

	bool shouldFlash = file.decoyFlashEnabled

	if ( shouldFlash )
	{
		thread FlashBang_Flash( targetEnt, 0.9, 1.0, 0.4 )
		PlayImpactFXTable( damagePos, playerOwner, FLASH_DECOY_IMPACT_TABLE )
	}

	if ( file.decoy_cloak_duration > 0 )
		thread CloakMirage( playerOwner )

	return wp
}

#if SERVER
float function GetDecoySonarMinDuration( entity player )
{
	return file.decoy_ping_min_duration
}

float function GetDecoySonarMaxDuration( entity player )
{
	return file.decoy_ping_max_duration
}

void function CloakMirage( entity player )
{
	player.EndSignal( "OnDeath" )
	EnableCloak( player, file.decoy_cloak_duration, file.decoy_cloak_fadein )
}

void function HighlightShooter( entity decoy, entity player, entity target )
{
	target.Signal( "HighlightShooter" )
	target.EndSignal( "HighlightShooter" )
	target.EndSignal( "OnDeath" )

	int team = player.GetTeam()

	float aliveTime    = Time() - decoy.e.spawnTime
	float waitDuration = GraphCapped( aliveTime, 1.0, 2.0, GetDecoySonarMinDuration( player ), GetDecoySonarMaxDuration( player ) )

	int statusEffectHandle = StatusEffect_AddEndless( target, eStatusEffect.mirage_detected, 1.0 )
	SonarStart( target, target.GetOrigin(), team, player )

	OnThreadEnd(
		function() : ( team, target, player, statusEffectHandle )
		{
			StatusEffect_Stop( target, statusEffectHandle )

			if ( IsValid( target ) )
			{
				SonarEnd( target, team, player )
			}
		}
	)

	wait waitDuration
}
#endif

void function DelayedDestroyTracking( entity wp, entity targetEnt )
{
	wp.EndSignal( "OnDestroy" )
	targetEnt.EndSignal( "MirageSpotted" )

	OnThreadEnd(
		function() : ( wp, targetEnt )
		{
			if ( IsValid( wp ) )
				wp.Destroy()
			                     
			if ( IsValid( targetEnt ) )
			{
				LockOnWarningEnd( targetEnt )
			}
         
		}
	)

	                     
		if ( GetCurrentPlaylistVarBool( "mirage_rework_enabled", true ) )
		{
			wait BAMBOOZLE_DURATION
		}
		else
                            
		{
			wait 2.5
		}
}

void function SetupDecoy_Common( entity player, entity decoy, bool ultimateDecoy = false )
//functioned out mainly so holopilot execution can call this as well
{
	decoy.SetDeathNotifications( true )
	decoy.SetPassThroughThickness( 0 )
	decoy.SetNameVisibleToOwner( true )
	decoy.SetNameVisibleToFriendly( true )
	decoy.SetNameVisibleToEnemy( true )
	decoy.SetDecoyRandomPulseRateMax( 0.5 ) //pulse amount per second
	decoy.SetFadeDistance( DECOY_FADE_DISTANCE )
	decoy.SetBossPlayer( player )
	decoy.SetForceVisibleInPhaseShift( true )
	//decoy.SetFlickerOnHit( true )
	decoy.SetOwner( player )
	AddNeurolinkDetectionForPropScript( decoy )
	AddSonarDetectionForPropScript( decoy )
	AddEMPDestroyDevice( decoy )

	float distanceLimit = GetCurrentPlaylistVarFloat( "mirage_decoy_distance_limit", 0.0 )

	if ( distanceLimit > 0 )
	{
		thread Decoy_DestroyIfTooFar( player, decoy, distanceLimit )
	}

	int friendlyTeam = decoy.GetTeam()
	if ( ultimateDecoy )
	{
		EmitSoundOnEntityToTeam( decoy, "Mirage_Vanish_Decoy_Sustain", friendlyTeam ) //loopingSound
		EmitSoundOnEntityToEnemies( decoy, "Mirage_Vanish_Decoy_Sustain_Enemy", friendlyTeam ) ///loopingSound
		decoy.decoy.loopingSounds = [ "Mirage_Vanish_Decoy_Sustain", "Mirage_Vanish_Decoy_Sustain_Enemy" ]
	}
	else
	{
		EmitSoundOnEntityToTeam( decoy, "Mirage_PsycheOut_Decoy_Sustain", friendlyTeam ) //loopingSound
		EmitSoundOnEntityToEnemies( decoy, "Mirage_PsycheOut_Decoy_Sustain_Enemy", friendlyTeam ) ///loopingSound
		decoy.decoy.loopingSounds = [ "Mirage_PsycheOut_Decoy_Sustain", "Mirage_PsycheOut_Decoy_Sustain_Enemy" ]
	}

	Highlight_SetFriendlyHighlight( decoy, HIGHLIGHT_FRIENDLY_PLAYER_DECOY )
	Highlight_SetOwnedHighlight( decoy, HIGHLIGHT_FRIENDLY_PLAYER_DECOY )
	decoy.e.hasDefaultEnemyHighlight = player.e.hasDefaultEnemyHighlight
	SetDefaultMPEnemyHighlight( decoy )
	StartManagingHealingFXRequestsForNonPlayerEntity( player, decoy, Decoy_HealingFXValidation )

	int attachID = decoy.LookupAttachment( "CHESTFOCUS" )

	var childEnt = player.FirstMoveChild()
	while ( childEnt != null )
	{
		expect entity( childEnt )

		bool isBattery      = false
		bool createHologram = false
		switch ( childEnt.GetClassName() )
		{
			case "item_titan_battery":
			{
				isBattery = true
				createHologram = true
				break
			}

			case "item_flag":
			{
				createHologram = true
				break
			}
		}

		asset modelName = childEnt.GetModelName()
		if ( createHologram && modelName != $"" && childEnt.GetParentAttachment() != "" )
		{
			entity decoyChildEnt = CreatePropDynamic( modelName, <0, 0, 0>, <0, 0, 0>, 0 )
			decoyChildEnt.Highlight_SetInheritHighlight( true )
			decoyChildEnt.SetParent( decoy, childEnt.GetParentAttachment() )

			if ( isBattery )
				thread Decoy_BatteryFX( decoy, decoyChildEnt )
			else
				thread Decoy_FlagFX( decoy, decoyChildEnt )
		}

		childEnt = childEnt.NextMovePeer()
	}

	entity holoPilotTrailFX = StartParticleEffectOnEntity_ReturnEntity( decoy, HOLO_PILOT_TRAIL_FX, FX_PATTACH_POINT_FOLLOW, attachID )
	SetTeam( holoPilotTrailFX, friendlyTeam )
	holoPilotTrailFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY

	decoy.decoy.fxHandles.append( holoPilotTrailFX )
	decoy.SetFriendlyFire( false )
	decoy.SetKillOnCollision( false )

	if ( player.IsShadowForm() )
		SetShadowAbilitiesSkin( decoy )
	//
	FiringRange_AddToRemoveOnCharacterChange( decoy, player )
}

bool function Decoy_HealingFXValidation( entity player, entity decoy, int healingRequestType )
{
	switch ( healingRequestType )
	{
		//case eHealingRequestType.Trophy:
		//	return Trophy_IsDecoyInRangeOfTrophy( decoy )

		case eHealingRequestType.ShieldRegen:
			return true

	                               
		case eHealingRequestType.Valentines:
			if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_VALENTINES_S15 ) )
			{

			}
			return false
       
	}
	unreachable
}

void function Decoy_DestroyIfTooFar( entity player, entity decoy, float distanceLimit )
{
	player.EndSignal( "OnDeath" )
	decoy.EndSignal( "OnDestroy" )

	float distanceLimitSqr = distanceLimit * distanceLimit

	OnThreadEnd(
		function() : ( decoy )
		{
			if ( IsValid( decoy ) )
			{
				CleanupExistingDecoy( decoy )
			}
		}
	)

	while ( true )
	{
		float distanceSqr = Distance2DSqr( player.GetOrigin(), decoy.GetOrigin() )

		if ( distanceSqr > distanceLimitSqr )
			break

		wait 0.5
	}
}

vector function CalculateAngleSegmentForDecoy( int loopIteration, vector angleSegment )
{
	if ( loopIteration == 0 )
		return <0, 0, 0>

	if ( loopIteration % 2 == 0 )
		return (loopIteration / 2) * angleSegment * -1
	else
		return ((loopIteration / 2) + 1) * angleSegment

	unreachable
}

void function Decoy_BatteryFX( entity decoy, entity decoyChildEnt )
{
	decoy.EndSignal( "OnDeath" )
	decoy.EndSignal( "CleanupFXAndSoundsForDecoy" )

	OnThreadEnd(
		function() : ( decoyChildEnt )
		{
			if ( IsValid( decoyChildEnt ) )
				decoyChildEnt.Destroy()
		}
	)

	WaitForever()
}

void function Decoy_FlagFX( entity decoy, entity decoyChildEnt )
{
	decoy.EndSignal( "OnDeath" )
	decoy.EndSignal( "CleanupFXAndSoundsForDecoy" )

	SetTeam( decoyChildEnt, decoy.GetTeam() )
	entity flagTrailFX = StartParticleEffectOnEntity_ReturnEntity( decoyChildEnt, GetParticleSystemIndex( DECOY_FLAG_FX ), FX_PATTACH_POINT_FOLLOW, decoyChildEnt.LookupAttachment( "fx_end" ) )
	flagTrailFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY

	OnThreadEnd(
		function() : ( flagTrailFX, decoyChildEnt )
		{
			if ( IsValid( flagTrailFX ) )
				flagTrailFX.Destroy()

			if ( IsValid( decoyChildEnt ) )
				decoyChildEnt.Destroy()
		}
	)

	WaitForever()
}

#endif // SERVER

bool function PlayerCanUseDecoy( entity ownerPlayer )
//For holopilot and HoloPilot Nova. No better place to put this for now
{
	if ( !ownerPlayer.IsZiplining() )
	{
		if ( ownerPlayer.ContextAction_IsActive() ) //Stops every single context action from letting decoy happen, including rodeo, melee, embarking etc
			return false
	}

	return true
}

#if SERVER
array<entity> function ConvertHolosToMimics( entity owner, array<entity> holoEntities )
{
	array<entity> newHolos

	ArrayRemoveInvalid( holoEntities )

	foreach ( ent in holoEntities )
	{
		float duration  = file.decoyDuration - (Time() - ent.e.spawnTime)
		float yawOffset = ent.GetAngles().y - owner.GetAngles().y

		if ( IsAlive( ent ) && duration > 0 )
		{
			if ( ent.GetScriptName() == DECOY_SCRIPTNAME )
			{
				entity decoy = owner.CreateMimicPlayerDecoy( yawOffset )
				decoy.SetOrigin( ent.GetOrigin() )
				decoy.SetAngles( ent.GetAngles() )
				decoy.SetOwner( owner )
				decoy.SetMaxHealth( ent.GetMaxHealth() )
				decoy.SetHealth( ent.GetHealth() )
				decoy.EnableAttackableByAI( GetThreatPriorityForHolopilot( owner ), 0, AI_AP_FLAG_NONE )
				decoy.SetCanBeMeleed( true )
				decoy.SetTimeout( duration )
				decoy.SetAimAssistAllowed( true )
				//decoy.SetPlayerOneHits( true )
				decoy.e.spawnTime = ent.e.spawnTime
				decoy.SetScriptName( CONTROLLED_DECOY_SCRIPTNAME )
				decoy.SetTeamMemberIndex( 99 )
				thread TrapDestroyOnRoundEnd( owner, decoy )
				thread DecoyDestroyOnPlayerDeathOrClassChange( owner, decoy, duration )
				AddTacticalDecoy( decoy )
				SetupDecoy_Common( owner, decoy, true )
				AddEntityCallback_OnDamaged( decoy, void function( entity decoy, var damageInfo ) : ( owner ) {
					if ( IsValid( owner ) )
						HoloPilot_OnDecoyPreDamaged( decoy, owner, damageInfo )
				} )
				AddEntityCallback_OnPostDamaged( decoy, void function( entity decoy, var damageInfo ) : ( owner ) {
					if ( IsValid( owner ) )
						HoloPilot_OnDecoyDamaged( decoy, owner, damageInfo )
				} )
				                     
				AddEntityCallback_OnKilled( decoy, void function( entity decoy, var damageInfo ) : ( owner ) {
					if (IsValid( owner ) )
						HoloPilot_OnDecoyKilled( decoy, owner, damageInfo )
				})
          
				Highlight_SetOwnedHighlight( decoy, "sp_objective_entity" )
				ent.Destroy()
				newHolos.append( decoy )
			}
			else
			{
				asset modelName        = $""
				asset characterSetFile = $""
				ItemFlavor character   = LoadoutSlot_GetItemFlavor( ToEHI( owner ), Loadout_Character() )
				ItemFlavor skin        = LoadoutSlot_GetItemFlavor( ToEHI( owner ), Loadout_CharacterSkin( character ) )

				entity decoy = CreateDecoyFromMimic( characterSetFile, modelName, owner, skin, duration, false, ent.GetVelocity() )
				decoy.SetOrigin( ent.GetOrigin() )
				decoy.SetAngles( ent.GetAngles() )
				//decoy.SetPlayerOneHits( true )
				decoy.e.spawnTime = ent.e.spawnTime
				decoy.SetScriptName( DECOY_SCRIPTNAME )
				decoy.SetTeamMemberIndex( 99 )
				thread TrapDestroyOnRoundEnd( owner, decoy )
				thread DecoyDestroyOnPlayerDeathOrClassChange( owner, decoy, duration )

				AddTacticalDecoy( decoy )
				SetupDecoy_Common( owner, decoy, true )
				AddTacticalDecoy( decoy )
				ent.Destroy()
				newHolos.append( decoy )
			}
		}
	}

	if ( newHolos.len() > 0 )
	{
		if ( newHolos[0].GetScriptName == DECOY_SCRIPTNAME )
			EmitSoundOnEntityOnlyToPlayer( owner, owner, SOUND_DECOY_RELEASE )
		else
			EmitSoundOnEntityOnlyToPlayer( owner, owner, SOUND_DECOY_CONTROL )
	}

	return newHolos
}
#endif

bool function OnWeaponChargeLevelIncreased_holopilot( entity weapon )
{
	#if CLIENT
		if ( InPrediction() && !IsFirstTimePredicted() )
			return true
	#endif

	int level    = weapon.GetWeaponChargeLevel()
	int maxLevel = weapon.GetWeaponChargeLevelMax()

	if ( level == maxLevel )
	{
		if ( weapon.HasMod( "disguise" ) )
		{
			//	weapon.EmitWeaponSound_1p3p( "weapon_peacekeeper_leveltick_final", "weapon_peacekeeper_leveltick_final_3p" )
			//	weapon.PlayWeaponEffect( HOLO_EMITTER_CHARGE_FX_1P, HOLO_EMITTER_CHARGE_FX_3P, "FX_EMITTER_L_03" )
		}
		else
		{
			//	weapon.EmitWeaponSound_1p3p( "weapon_peacekeeper_leveltick_final", "weapon_peacekeeper_leveltick_final_3p" )
			weapon.PlayWeaponEffect( HOLO_EMITTER_CHARGE_FX_1P, HOLO_EMITTER_CHARGE_FX_3P, "FX_EMITTER_L_01" )
		}
	}
	else
	{
		switch ( level )
		{
			case 1:
				//	weapon.PlayWeaponEffect( HOLO_EMITTER_CHARGE_FX_1P, HOLO_EMITTER_CHARGE_FX_3P, "FX_EMITTER_L_01" )
				//	weapon.EmitWeaponSound_1p3p( "weapon_peacekeeper_leveltick_1", "weapon_peacekeeper_leveltick_1_3p" )
				//	break

			case 2:
				//	weapon.PlayWeaponEffect( HOLO_EMITTER_CHARGE_FX_1P, HOLO_EMITTER_CHARGE_FX_3P, "FX_EMITTER_L_02" )
				//	weapon.EmitWeaponSound_1p3p( "weapon_peacekeeper_leveltick_2", "weapon_peacekeeper_leveltick_2_3p" )
				//	break
			}
	}

	return true
}

#if SERVER
void function AddPassiveDecoy( entity decoy )
{
	if ( GetCurrentPlaylistVarInt( "use_holopilot_limit", 1 ) == 0 )
		return

	file.passiveDecoys.append( decoy )
}

void function AddUltimateDecoy( entity decoy )
{
	if ( GetCurrentPlaylistVarInt( "use_holopilot_limit", 1 ) == 0 )
		return

	file.ultimateDecoys.append( decoy )
}

void function AddTacticalDecoy( entity decoy )
{
	if ( GetCurrentPlaylistVarInt( "use_holopilot_limit", 1 ) == 0 )
		return

	file.tacticalDecoys.append( decoy )
}

void function TestHolopilotLimit( int numberOfDecoysToMake )
{
	if ( GetCurrentPlaylistVarInt( "use_holopilot_limit", 1 ) == 0 )
		return

	ArrayRemoveInvalid( file.passiveDecoys )
	ArrayRemoveInvalid( file.ultimateDecoys )
	ArrayRemoveInvalid( file.tacticalDecoys )

	int sum                   = file.passiveDecoys.len() + file.ultimateDecoys.len() + file.tacticalDecoys.len()
	array<entity> playerArray = GetPlayerArray_Alive()
	int maxCount              = playerArray.len() + sum + numberOfDecoysToMake
	int arbitrayLimit         = GetCurrentPlaylistVarInt( "max_players", 60 ) + 36
	if ( maxCount > arbitrayLimit )
	{
		int decoysToDestroy = maxCount - arbitrayLimit
		while( decoysToDestroy > 0 )
		{
			if ( file.passiveDecoys.len() > 0 )
			{
				file.passiveDecoys[0].Destroy()
				file.passiveDecoys.remove( 0 )
				decoysToDestroy--
			}
			else if ( file.ultimateDecoys.len() > 0 )
			{
				file.ultimateDecoys[0].Destroy()
				file.ultimateDecoys.remove( 0 )
				decoysToDestroy--
			}
			else if ( file.tacticalDecoys.len() > 0 )
			{
				file.tacticalDecoys[0].Destroy()
				file.tacticalDecoys.remove( 0 )
				decoysToDestroy--
			}
		}
	}
}
#endif

#if CLIENT
void function OnDecoyCreate( entity decoy )
{
	// decoy.SetEnableFootstepFX( false )
}
void function AttemptToggleDecoys( entity player )
{
	if ( !TryCharacterButtonCommonReadyChecks( player ) )
		return

	// Controller shares this binding with quick chat prompts
	if ( IsControllerModeActive() )
	{
		if ( TryOnscreenPromptFunction( player, "quickchat" ) )
			return
	}

	Remote_ServerCallFunction( "ClientCallback_ToggleDecoys" )
}

                     
void function ServerToClient_ShowHolopilotDestroyedText()
{
	entity player = GetLocalViewPlayer()

	if (IsValid(player))
	{
		AnnouncementMessageRight( player, "#WPN_HOLOPILOT_DESTROYED" )
	}
}
                           
#endif

void function OnWeaponActivate_holopilot( entity weapon )
{
	                      
		if (weapon.HasMod(COPYCAT_MOD))
			return
       

	weapon.PlayWeaponEffect( HOLO_EMITTER_CHARGE_FX_1P, HOLO_EMITTER_CHARGE_FX_3P, "FX_EMITTER_L_01" )
	weapon.PlayWeaponEffect( HOLO_EMITTER_CHARGE_FX_1P, HOLO_EMITTER_CHARGE_FX_3P, "FX_EMITTER_L_02" )
	weapon.PlayWeaponEffect( HOLO_EMITTER_CHARGE_FX_1P, HOLO_EMITTER_CHARGE_FX_3P, "FX_EMITTER_L_03" )
	weapon.PlayWeaponEffect( HOLO_EMITTER_CHARGE_FX_1P, HOLO_EMITTER_CHARGE_FX_3P, "FX_EMITTER_L_04" )
	weapon.PlayWeaponEffect( HOLO_EMITTER_CHARGE_FX_1P, HOLO_EMITTER_CHARGE_FX_3P, "FX_EMITTER_L_05" )
} 