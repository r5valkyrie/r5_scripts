global function SniperUlt_Init
global function OnWeaponActivate_ability_sniper_ult
global function OnWeaponDeactivate_ability_sniper_ult
global function OnWeaponPrimaryAttack_ability_sniper_ult
global function OnWeaponAttemptOffhandSwitch_ability_sniper_ult
global function OnProjectileCollision_sniper_ult
global function OnWeaponStartZoomIn_ability_sniper_ult
global function OnWeaponStartZoomOut_ability_sniper_ult
global function OnWeaponZoomFOVToggle_ability_sniper_ult

global function SniperUlt_GetMarkedDuration

#if SERVER
global function SniperUlt_OnDamagedByPlayer_DiamondScan
global function SniperUlt_Whizby_Mark_Thread
#endif

#if CLIENT
global function OnClientAnimEvent_ability_sniper_ult
#endif // #if CLIENT


global const string SNIPERULT_WEAPON_NAME = "mp_ability_sniper_ult"
const string SNIPER_ULT_TOGGLE_ZOOMIN_1P = "weapon_vantageUlt_zoomin_1p"
const string SNIPER_ULT_TOGGLE_ZOOMOUT_1P = "weapon_vantageUlt_zoomout_1p"


////////////////////////////
// HEALING DENIED
global  const float SNIPERULT_HEALINGDENIED_DURATION = 15
//const float SNIPERULT_HEALINGDENIED_MINHEALTH = 10
//const float SNIPERULT_HEALINGDENIED_ZONE_DURATION = 15
//
//
//const float SNIPERULT_HEALINGDENIED_ZONE_RADIUS = 235
//const float SNIPERULT_HEALINGDENIED_ZONE_OPACITY = 0.4
//const float SNIPERULT_HEALINGDENIED_ZONE_DOWN_TRACE_HEIGHT = 5 * METERS_TO_INCHES
//////////////////////////////////////////


const float SNIPERULT_WHIZ_BY_SCAN_DURATION = 1
const float SNIPERULT_PLAYER_MARKED_DURATION = 10
const float SNIPERULT_VANTAGE_DMG_SCALE = 2
const float SNIPERULT_TEAM_DMG_SCALE = 1.15

//const float SNIPERULT_BROADCAST_SCAN_INTERVAL = 1.5
//const float SNIPERULT_BROADCAST_SCAN_FOV = 180
//const float SNIPERULT_BROADCAST_SCAN_RADIUS = 10 * METERS_TO_INCHES

//FX
const asset FX_SNIPER_ULT_MARK = $"P_van_sniper_mark"
const asset FX_SNIPER_ULT_MARK_WHIZ_BY = $"P_van_sniper_mark_wizby"
const asset FX_SNUPER_ULT_MUZZLE_FLASH_1P = $"P_van_sniper_muzzleflash_FP"
const asset FX_SNUPER_ULT_MUZZLE_FLASH_3P = $"P_van_sniper_muzzleflash_3P"

//Sound
const string SNIPERULT_MARKED_SOUND = "Vantage_Ult_TargetLock_1p"
const string SNIPERULT_MARKED_END_SOUND = "Vantage_Ult_TargetUnlock_1p"
const string SNIPERULT_MARKED_SOUND_TEAM = "Vantage_Ult_TargetLock_Squad_1p"
const string SNIPERULT_MARKED_END_SOUND_TEAM = "Vantage_Ult_TargetUnlock_Squad_1p"
const string SNIPERULT_MARKED_SOUND_VICTIM = "Vantage_Ult_TargetLock_Victim_1p"
const string SNIPERULT_MARKED_END_SOUND_VICTIM = "Vantage_Ult_TargetUnlock_Victim_1p"
const string SNIPERULT_ZOOM_IN = "weapon_vantageUlt_ads_in"
const string SNIPERULT_ZOOM_OUT = "weapon_vantageUlt_ads_out"

///////////////////////////////////
// planted zone
//const asset DEBUG_SPHERE_FX = $"debug_sphere_diff_edge"
//const asset ELECTRIC_SPHERE_FX = $"P_emp_charge_radius_MDL"
//const float ELECTRIC_MODEL_SCALE_MULTIPLIER = 0.00042553191
//const float ELECTRIC_MODEL_LIFETME = 2.25
//const float ELECTRIC_MODEL_TIME_INTERVAL = 1.5
//const asset SNIPERULT_ZONE_PLANTED_MODEL = $"mdl/props/gibraltar_bubbleshield/gibraltar_bubbleshield.rmdl"
////////////////////////////////
struct
{
	#if CLIENT
		float timeLastUltHint = 0
	#endif

} file

const bool SNIPERULT_DEBUG_DRAW = false

void function SniperUlt_Init()
{
	///////////////////////////////////
	PrecacheParticleSystem( FX_SNIPER_ULT_MARK )
	PrecacheParticleSystem( FX_SNIPER_ULT_MARK_WHIZ_BY )
	PrecacheParticleSystem( FX_SNUPER_ULT_MUZZLE_FLASH_1P )
	PrecacheParticleSystem( FX_SNUPER_ULT_MUZZLE_FLASH_3P )


	#if SERVER
		AddDamageByCallback( "player", SniperUlt_OnDamagedByPlayer_DiamondScan )
                       
                                                             
        
		//Bleedout_AddCallback_OnPlayerStartGiveFirstAid( SniperUlt_OnPlayerStartGiveFirstAid )
	#endif


	//HEALING DENIAL
	#if CLIENT
		RegisterSignal( "SniperUlt_StopHealingDeniedFXSignal" )

		//Status Effects
		StatusEffect_RegisterEnabledCallback( eStatusEffect.healing_denied, SniperUlt_HealingDenied_Start1PFX )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.healing_denied, SniperUlt_HealingDenied_Stop1PFX )
	#endif

	#if CLIENT
		//Setting this temporarily wherever Vantage is enabled to get the proper laser FX
		SetConVarBool( "rope_visibility_fx_enable", true )

		RegisterSignal( "SniperUlt_Mark_StopSignal" )
                       
                                            
        

		//Status Effects
		StatusEffect_RegisterEnabledCallback( eStatusEffect.sonar_round_embedded, SniperUlt_Mark_Client_Start )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.sonar_round_embedded, SniperUlt_Mark_Client_Stop )
	#endif
}


void function OnWeaponActivate_ability_sniper_ult( entity weapon )
{
	bool serverOrPredicted = IsServer() || ( InPrediction() && IsFirstTimePredicted() )
	if ( serverOrPredicted )
	{

	}

	entity weaponOwner = weapon.GetOwner()
	#if SERVER
	if ( IsValid( weaponOwner ) )
	{
		SniperUlt_UpdateBackGunVisibility( weaponOwner, false )
	}
	#endif
	
                      
           
                              
  
                                                  
  
       
       

                                 
                                                                              
   
                                                 
   
       
}

void function OnWeaponDeactivate_ability_sniper_ult( entity weapon )
{
                      
           
                       
                                           
       
       
	#if SERVER
		thread DelayedWeaponHide_Thread( weapon )
	#endif
}

#if SERVER
//Raise/Lower events aren't working correctly, I suspect because this is an "ult weapon".  Need more time to investigate, but this is good enough for now (IE we want to show the weapon on the back close to when Vantage reaches back to "stow" the ult.)
void function DelayedWeaponHide_Thread( entity weapon )
{
	Assert ( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( weapon ) )
		return

	weapon.EndSignal( "OnDestroy" )

	entity weaponOwner = weapon.GetOwner()

	if ( IsValid( weaponOwner ) )
	{
		weaponOwner.EndSignal( "OnDeath" )
		weaponOwner.EndSignal( "OnDestroy" )

		float lowerTime = weapon.GetWeaponSettingFloat( eWeaponVar.holster_time )
		wait lowerTime

		if ( IsValid( weaponOwner ) )
		{
			SniperUlt_UpdateBackGunVisibility( weaponOwner, true )
		}
	}
}
#endif


void function OnWeaponStartZoomIn_ability_sniper_ult( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	if ( !IsValid( weaponOwner ) )
		return

	bool serverOrPredicted = IsServer() || ( InPrediction() && IsFirstTimePredicted() )
	if ( serverOrPredicted )
	{
		#if CLIENT
		if ( weaponOwner == GetLocalViewPlayer() )
		{
			StopSoundOnEntity( weapon, SNIPERULT_ZOOM_OUT )
		}
		#endif

	}
}

void function OnWeaponStartZoomOut_ability_sniper_ult( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( !IsValid( weaponOwner ) )
		return

	bool serverOrPredicted = IsServer() || ( InPrediction() && IsFirstTimePredicted() )
	if ( serverOrPredicted )
	{
		#if CLIENT
		if ( weaponOwner == GetLocalViewPlayer() )
		{
			StopSoundOnEntity( weapon, SNIPERULT_ZOOM_IN )
			StopSoundOnEntity( weaponOwner, SNIPER_RECON_UI_START_SOUND )
		}
		#endif

	}
}

void function OnWeaponZoomFOVToggle_ability_sniper_ult( entity weapon, float targetFOV )
{
	#if CLIENT
		if ( weapon.GetOwner() != GetLocalViewPlayer() )
			return

		if ( targetFOV == weapon.GetWeaponSettingFloat( eWeaponVar.zoom_fov ) ) // base zoom
		{
			EmitSoundOnEntity( weapon, SNIPER_ULT_TOGGLE_ZOOMOUT_1P )
			StopSoundOnEntity( weapon, SNIPER_ULT_TOGGLE_ZOOMIN_1P )
		}
		else // zoom in
		{
			EmitSoundOnEntity( weapon, SNIPER_ULT_TOGGLE_ZOOMIN_1P )
			StopSoundOnEntity( weapon, SNIPER_ULT_TOGGLE_ZOOMOUT_1P )
		}
	#endif
}


bool function OnWeaponChargeLevelIncreased_sniper_ult( entity weapon )
{
	if ( weapon.GetWeaponChargeLevel() == weapon.GetWeaponChargeLevelMax() )
	{
		entity player = weapon.GetWeaponOwner()
		if ( !IsValid( player ) )
			return true

		#if CLIENT
			string chargeCompleteSound = GetWeaponInfoFileKeyField_GlobalString( SNIPERULT_WEAPON_NAME, "charge_complete_sound_1p" )
			weapon.EmitWeaponSound_1p3p( chargeCompleteSound, "" )

			if ( IsValid( player ) && IsLocalClientPlayer( player ) )
			{
				Rumble_Play( "rumble_bow_max_charge", {} )
			}
		#endif

	}
	return true
}


var function OnWeaponPrimaryAttack_ability_sniper_ult( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	int ammoUsed = weapon.GetAmmoPerShot()

	if ( weapon.GetWeaponPrimaryClipCount() == weapon.GetWeaponPrimaryClipCountMax() )
	{
		PlayerUsedOffhand( weapon.GetOwner(), weapon )
	}

	bool shouldCreateProjectile = false
	if ( IsServer() || weapon.ShouldPredictProjectiles() )
		shouldCreateProjectile = true

	if ( shouldCreateProjectile )
	{
		entity projectile = FireBallisticRoundWithDrop( weapon, attackParams.pos, attackParams.dir, true, false, 0, false )
		projectile.proj.savedOrigin = attackParams.pos
		projectile.proj.savedDir    = attackParams.dir

		weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.1 )

		weapon.PlayWeaponEffect( FX_SNUPER_ULT_MUZZLE_FLASH_1P, FX_SNUPER_ULT_MUZZLE_FLASH_3P, "muzzle_flash" )
	}
	#if SERVER
	entity player  = weapon.GetOwner()
	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_VANTAGE_ULTIMATE_FIRED, player, player.GetOrigin(), player.GetTeam(), player )
	#endif

	return ammoUsed
}


bool function OnWeaponAttemptOffhandSwitch_ability_sniper_ult( entity weapon )
{
	return true
}


void function OnProjectileCollision_sniper_ult( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical, bool isPassthrough )
{
		// If we hit a person then find geo and plant the dome there.
		if ( !IsValid( hitEnt ) )
			return

		entity projectileOwner = projectile.GetOwner()
		if ( !IsValid( projectileOwner ) )
			return



		//DebugDrawSphere( midPoint, 10, <100,100,0>,false, 5.0 )
		//DebugDrawSphere( midPoint, dist/2, COLOR_GREEN,false, 5.0 , 32 )

		//DebugDrawLine( projectile.proj.savedOrigin, pos, COLOR_GREEN,false, 5.0 )

	#if SERVER
		//printt( "hit ent class " + hitEnt.GetClassName() )
		vector fireLine = pos - projectile.proj.savedOrigin
		vector fireLineNorm = Normalize( fireLine )
		float dist          = Length( fireLine )

		vector midPoint = projectile.proj.savedOrigin + (fireLineNorm * dist / 2)

		array<entity> enemies = GetPlayerArrayEx( "any", TEAM_ANY, projectile.GetTeam(), midPoint, dist / 2 )

		foreach ( target in enemies )
		{
			if ( target == hitEnt )
				continue

			//if ( target.GetTeam() == projectile.GetTeam() )
			//	continue
			//
			//if ( StatusEffect_HasSeverity( target, eStatusEffect.sonar_round_embedded ) )
			//{
			//	//printt("was already hit")
			//	continue
			//}

			float distFromFireLine = GetDistanceFromLineSegment( projectile.proj.savedOrigin, pos, target.GetCenter() )
			//DebugDrawText( target.EyePosition(),"d: "+ distFromFireLine, false, 5.0 )
			if ( distFromFireLine > 120 )
				continue



			thread SniperUlt_Whizby_Mark_Thread( target, projectileOwner, SNIPERULT_WHIZ_BY_SCAN_DURATION )

		}

	#endif
}

float function SniperUlt_GetMarkedDuration()
{
	float duration = GetCurrentPlaylistVarFloat( "sniperult_marked_duration", SNIPERULT_PLAYER_MARKED_DURATION )
	return duration
}



#if SERVER
                    
void function SniperUlt_TryApplyTacRefresh( entity attacker )
{
		if( PlayerHasPassive( attacker, ePassives.PAS_ULT_UPGRADE_ONE ) ) //upgrade_vantage_ult_tac_refresh
		{
			// refresh Tactical
			entity tacWeapon = attacker.GetOffhandWeapon( OFFHAND_TACTICAL )
			if( !IsValid( tacWeapon ) )
				return
			int ammo = tacWeapon.GetWeaponPrimaryClipCount()
			int ammoReq = tacWeapon.GetAmmoPerShot()
			int ammoMax = tacWeapon.GetWeaponPrimaryClipCountMax()
			tacWeapon.SetWeaponPrimaryClipCount( minint( ammo + ammoReq, ammoMax ) )
		}
}
      

void function SniperUlt_OnDamagedByPlayer_DiamondScan( entity hitEnt, var damageInfo )
{

	int dmgSrcID    = DamageInfo_GetDamageSourceIdentifier( damageInfo )


	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( IsTrainingDummie( hitEnt ) )
	{
		if( dmgSrcID == eDamageSourceId.mp_ability_sniper_ult  )
		{
			SniperUlt_Mark_Dummie( hitEnt, damageInfo )
                    
			SniperUlt_TryApplyTacRefresh( attacker )
      
		}
		else if ( StatusEffect_HasSeverity( hitEnt, eStatusEffect.sonar_round_embedded ) )
		{
			float damageScale = GetCurrentPlaylistVarFloat( "sniperult_team_dmgScale", SNIPERULT_TEAM_DMG_SCALE )
			DamageInfo_ScaleDamage( damageInfo, SNIPERULT_TEAM_DMG_SCALE )
		}

		return
	}

	if ( !hitEnt.IsPlayer() )
		return
	//Sonar rounds
	if ( StatusEffect_HasSeverity( hitEnt, eStatusEffect.sonar_round_embedded ) )
	{
		if ( IsValid( hitEnt.p.sonarRoundsAttacker ) )
		{
			if ( attacker.GetTeam() == hitEnt.p.sonarRoundsAttacker.GetTeam() )
			{
				if ( dmgSrcID == eDamageSourceId.mp_ability_sniper_ult )
				{
					float damageScale = GetCurrentPlaylistVarFloat( "vantage_sniperult_dmgScale", SNIPERULT_VANTAGE_DMG_SCALE )
					DamageInfo_ScaleDamage( damageInfo, damageScale )
					StatsHook_VantageUltimateMarkedHits( attacker )
				}
				else
				{
					//Team % damage increase
					float damageScale = GetCurrentPlaylistVarFloat( "vantage_sniperult_team_dmgScale", SNIPERULT_TEAM_DMG_SCALE )
					DamageInfo_ScaleDamage( damageInfo, damageScale )
				}
			}
		}
	}

	if ( !IsValid(attacker) || !attacker.IsPlayer() || !attacker.HasPassive( ePassives.PAS_VANTAGE ) )
		return

	//Hawk Ult section
	if ( dmgSrcID != eDamageSourceId.mp_ability_sniper_ult )
		return

	                    
	SniperUlt_TryApplyTacRefresh( attacker )
       

	//EmitSoundOnEntityOnlyToPlayer( hitEnt, hitEnt, "Arcstar_visualimpair" )

	//thread EMP_FX( FX_EMP_BODY_HUMAN, hitEnt, "CHESTFOCUS", SNIPERULT_EMP_FX_DURATION )

	if ( !StatusEffect_HasSeverity( hitEnt, eStatusEffect.sonar_round_embedded ) )
	{
		int damageAmount = int( DamageInfo_GetDamage( damageInfo ) )
		int startingHealth = hitEnt.GetHealth() + hitEnt.GetShieldHealth()
		float leftoverHealth = max( 0, ( startingHealth - damageAmount ) )

		//printt( "VANTAGE ULT enemy health:" + hitEnt.GetHealth() + "maxHealth:" + hitEnt.GetMaxHealth() )
		//printt( "VANTAGE ULT enemy shield:" + hitEnt.GetShieldHealth() + "maxShields:" + hitEnt.GetShieldHealthMax() )
		//printt( "VANTAGE ULT	---damageamount:" + damageAmount )

		if ( leftoverHealth > 0 )
			PlayBattleChatterLineToSpeakerAndTeam( attacker, "bc_super" )
	}

	float duration = SniperUlt_GetMarkedDuration()
	SniperUlt_PlayerMarked( hitEnt, attacker, duration )

	//For visual flavour
	StatusEffect_AddTimed( hitEnt, eStatusEffect.emp, 0.2, 0.5, 1.0 )
}

void function SniperUlt_Mark_Dummie( entity hitEnt, var damageInfo )
{
	if ( !IsTrainingDummie(hitEnt) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	bool hasStatusEffectAlready = StatusEffect_HasSeverity( hitEnt, eStatusEffect.sonar_round_embedded )

	if ( hasStatusEffectAlready )
	{
		int dmgSrcID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
		if ( dmgSrcID == eDamageSourceId.mp_ability_sniper_ult )
		{
			float damageScale = GetCurrentPlaylistVarFloat( "sniperult_vantage_dmgScale", SNIPERULT_VANTAGE_DMG_SCALE )
			DamageInfo_ScaleDamage( damageInfo, damageScale )
		}
		else
		{
			//Team % damage increase
			float damageScale = GetCurrentPlaylistVarFloat( "sniperult_team_dmgScale", SNIPERULT_TEAM_DMG_SCALE )
			DamageInfo_ScaleDamage( damageInfo, damageScale )
		}
	}

	float duration = SniperUlt_GetMarkedDuration()

	StatusEffect_AddTimed( hitEnt, eStatusEffect.sonar_round_embedded, 1.0, duration, 0.0 )

	if ( !hasStatusEffectAlready && IsValid(attacker) )
	{
		thread SniperUlt_DummieMarkedThread( hitEnt, attacker, duration )
	}

}

void function SniperUlt_DummieMarkedThread( entity target, entity vantage, float duration)
{
	target.EndSignal( "OnDestroy" )

	entity markFX          = StartParticleEffectOnEntity_ReturnEntity( target, GetParticleSystemIndex( FX_SNIPER_ULT_MARK ), FX_PATTACH_POINT_FOLLOW_NOROTATE, target.LookupAttachment( "CHESTFOCUS" ) )
	SetTeam( markFX, vantage.GetTeam() )
	markFX.SetVisibilityFlags( ENTITY_VISIBLE_TO_FRIENDLY )

	FiringRange_AddToRemoveOnCharacterChange( markFX, vantage )

	EmitSoundOnEntityOnlyToPlayer( target, vantage,SNIPERULT_MARKED_SOUND )
	EmitSoundOnEntityToTeamExceptPlayer( target, SNIPERULT_MARKED_SOUND_TEAM, vantage.GetTeam(), vantage )


	OnThreadEnd(
		function() : ( vantage, target, markFX )
		{
			if ( IsValid( target ) )
			{
				if ( IsValid( markFX ) )
				{
					EffectStop( markFX )
				}

				if ( IsValid( vantage ) )
				{
					EmitSoundOnEntityOnlyToPlayer( vantage, vantage, SNIPERULT_MARKED_END_SOUND )
					EmitSoundOnEntityToTeamExceptPlayer( target, SNIPERULT_MARKED_END_SOUND_TEAM, vantage.GetTeam(), vantage )
				}
			}
		}
	)
	//float endTime = Time() + duration
	while ( StatusEffect_HasSeverity( target, eStatusEffect.sonar_round_embedded ) )
	{
		WaitFrame()
	}
}

void function SniperUlt_Whizby_Mark_Thread( entity target, entity vantage, float duration )
{
	vantage.EndSignal( "OnDestroy" )
	target.EndSignal( "OnDestroy" )

	float endTime = Time() + duration

	entity whizbyMarkFx = StartParticleEffectOnEntity_ReturnEntity( target, GetParticleSystemIndex( FX_SNIPER_ULT_MARK_WHIZ_BY ), FX_PATTACH_POINT_FOLLOW_NOROTATE, target.LookupAttachment( "CHESTFOCUS" ) )
	SetTeam( whizbyMarkFx, vantage.GetTeam() )
	whizbyMarkFx.SetVisibilityFlags( ENTITY_VISIBLE_TO_FRIENDLY )

	OnThreadEnd(
		function() : ( target, whizbyMarkFx )
		{
			if ( IsValid( whizbyMarkFx ) )
			{
				EffectStop( whizbyMarkFx )
			}
		}
	)

	while ( IsAlive( target ) && Time() <= endTime )
	{
		WaitFrame()
	}
}


void function SniperUlt_SonarTrackPlayerThread( entity target, entity vantage, float duration )
{
	vantage.EndSignal( "OnDestroy" )
	target.EndSignal( "OnDestroy" )

	int cachedSonarTeam = vantage.GetTeam()
	//printt("Sniper sonar start")
	SonarStart( target, target.GetOrigin(), cachedSonarTeam, vantage )


	OnThreadEnd(
		function() : ( vantage, target, cachedSonarTeam )
		{
			if ( IsValid( target ) )
			{
				SonarEnd( target, cachedSonarTeam, vantage )
			}
		}
	)

	float endTime = Time() + duration
	while ( IsAlive( target ) && Time() <= endTime )
	{
		WaitFrame()
	}
}

void function SniperUlt_PlayerMarked( entity target, entity vantage, float duration )
{
	if ( StatusEffect_HasSeverity( target, eStatusEffect.sonar_round_embedded ) )
	{
		//printt( "NEW SONAR ROUNDS" )
		StatusEffect_AddTimed( target, eStatusEffect.sonar_round_embedded, 1.0, duration, 0.0 )
	}
	else
	{
		thread SniperUlt_PlayerMarkedThread( target, vantage, duration )
	}
}

void function SniperUlt_PlayerMarkedThread( entity target, entity vantage, float duration )
{
	//vantage.EndSignal( "OnDestroy" )
	target.EndSignal( "OnDestroy" )
	target.EndSignal( "OnDeath" )

	target.p.sonarRoundsAttacker     = vantage

	int statusEffectHandle = StatusEffect_AddTimed( target, eStatusEffect.sonar_round_embedded, 1.0, duration, 0.0 )
	entity markFX          = StartParticleEffectOnEntity_ReturnEntity( target, GetParticleSystemIndex( FX_SNIPER_ULT_MARK ), FX_PATTACH_POINT_FOLLOW_NOROTATE, target.LookupAttachment( "CHESTFOCUS" ) )
	SetTeam( markFX, vantage.GetTeam() )
	markFX.SetVisibilityFlags( ENTITY_VISIBLE_TO_FRIENDLY )

	FiringRange_AddToRemoveOnCharacterChange( markFX, vantage )

	EmitSoundOnEntityOnlyToPlayer( target, vantage,SNIPERULT_MARKED_SOUND )
	EmitSoundOnEntityToTeamExceptPlayer( target, SNIPERULT_MARKED_SOUND_TEAM, vantage.GetTeam(), vantage )


	//printt( "BEGIN SONAR ROUNDS" )

	OnThreadEnd(
		function() : ( vantage, target, markFX, statusEffectHandle )
		{
			if ( IsValid( target ) )
			{
				//printt( "END SONAR ROUNDS" )
				target.p.sonarRoundsAttacker      = null

				if ( IsValid( markFX ) )
				{
					EffectStop( markFX )
				}

				if ( IsValid( vantage ) )
				{
					EmitSoundOnEntityOnlyToPlayer( vantage, vantage,SNIPERULT_MARKED_END_SOUND )
					EmitSoundOnEntityToTeamExceptPlayer( target, SNIPERULT_MARKED_END_SOUND_TEAM, vantage.GetTeam(), vantage )

				}

				StatusEffect_Stop( target, statusEffectHandle )
			}
		}
	)
	//float endTime = Time() + duration
	while ( StatusEffect_HasSeverity( target, eStatusEffect.sonar_round_embedded ) )
	{
		if ( Bleedout_IsBleedingOut( target ) )
			return

		WaitFrame()
	}
}


//HEALING DENIED
void function SniperUlt_PlayerDenyHealsThread( entity player, entity vantage, float duration, var damageInfo )
{
	player.EndSignal( "OnDestroy" )

	int statusEffectHandle = StatusEffect_AddEndless( player, eStatusEffect.healing_denied, 1.0 )
	OnThreadEnd(
		function() : ( player, statusEffectHandle )
		{
			if ( IsValid( player ) )
			{
				StatusEffect_Stop( player, statusEffectHandle )
			}
		}
	)

	wait duration
}

void function SniperUlt_UpdateBackGunVisibility( entity player, bool visible )
{
	int bodyGroupIdx = player.FindBodygroup( "ultimate" )

	if ( bodyGroupIdx != -1 )
	{
		if ( visible )
			player.SetBodygroupModelByIndex( bodyGroupIdx, 0 )
		else
			player.SetBodygroupModelByIndex( bodyGroupIdx, 1 )
	}
}

                     
                                                     
 
                                                          
        

                                                         
                                                                                  
                               
        

                                                   
        

                                                                                                             

 
      

#endif



#if CLIENT

void function OnClientAnimEvent_ability_sniper_ult( entity weapon, string name )
{
	GlobalClientEventHandler( weapon, name )

	if ( name == "muzzle_flash" )
	{
		if ( IsOwnerViewPlayerFullyADSed( weapon ) )
			return

		//		weapon.PlayWeaponEffect( $"wpn_mflash_snp_hmn_smoke_side_FP", $"wpn_mflash_snp_hmn_smoke_side", "muzzle_flash_L" )
		//		weapon.PlayWeaponEffect( $"wpn_mflash_snp_hmn_smoke_side_FP", $"wpn_mflash_snp_hmn_smoke_side", "muzzle_flash_R" )
	}
}
#endif




//HEALING DENIED
#if CLIENT
void function SniperUlt_HealingDenied_Start1PFX( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	entity viewPlayer = GetLocalViewPlayer()

	int fxHandle
	//fxHandle = StartParticleEffectOnEntityWithPos( viewPlayer, SNIPER_ULT_1P_SCREEN_FX_ID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, viewPlayer.EyePosition(), <0, 0, 0> )
	//EffectSetIsWithCockpit( fxHandle, true )
	//
	//EffectSetControlPointVector( fxHandle, 1, <1,999,0> )
	//
	//EmitSoundOnEntity( viewPlayer, "diag_mp_wraith_voices_sniper_1p" )
	//
	//EmitSoundOnEntity( viewPlayer, SNIPER_ULT_SOUND_PLAYER_LOCKING_ON_START_1P )

	EmitSoundOnEntity( viewPlayer, "wattson_tactical_g" )

	thread SniperUlt_HealingDenied_1PFXThread( viewPlayer, fxHandle )
}

void function  SniperUlt_HealingDenied_1PFXThread( entity player, int fxHandle )
{
	player.EndSignal( "SniperUlt_StopHealingDeniedFXSignal" )
	player.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( fxHandle, player  )
		{
			if ( !EffectDoesExist( fxHandle ) )
				return

			EffectStop( fxHandle, false, true )
		}
	)
}

void function SniperUlt_HealingDenied_Stop1PFX( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	entity viewPlayer = GetLocalViewPlayer()


	EmitSoundOnEntity( viewPlayer, "wattson_tactical_g_enemy" )

	//EmitSoundOnEntity( viewPlayer, SNIPER_ULT_SOUND_PLAYER_LOCKING_ON_END_1P )

	ent.Signal( "SniperUlt_StopHealingDeniedFXSignal" )
}



void function SniperUlt_Mark_Client_Start( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	entity viewPlayer = GetLocalViewPlayer()

	int fxHandle
	//fxHandle = StartParticleEffectOnEntityWithPos( viewPlayer, SNIPER_ULT_1P_SCREEN_FX_ID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, viewPlayer.EyePosition(), <0, 0, 0> )
	//EffectSetIsWithCockpit( fxHandle, true )
	//EffectSetControlPointVector( fxHandle, 1, <1,999,0> )

	EmitSoundOnEntity( viewPlayer, SNIPERULT_MARKED_SOUND_VICTIM )


	//printt("SonarRound Start")

	thread SniperUlt_Mark_Client_Thread( viewPlayer, fxHandle )
}

void function SniperUlt_Mark_Client_Thread( entity player, int fxHandle )
{
	player.EndSignal( "SniperUlt_Mark_StopSignal" )
	player.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( fxHandle, player )
		{
			if ( !EffectDoesExist( fxHandle ) )
				return

			EffectStop( fxHandle, false, true )

			//if ( IsValid( player ) )
			//{
			//	StopSoundOnEntity( player, SNIPER_ULT_SOUND_PLAYER_LOCKING_ON_START_1P )
			//}
		}
	)

	while ( true )
	{
		WaitFrame()
	}
}

void function SniperUlt_Mark_Client_Stop( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	entity viewPlayer = GetLocalViewPlayer()

	EmitSoundOnEntity( viewPlayer, SNIPERULT_MARKED_END_SOUND_VICTIM )

	//printt("SonarRound Stop")
	ent.Signal( "SniperUlt_Mark_StopSignal" )
}

                     
                                                                
 
                        
        

                                      
        

                          
        

                                          
                                             

             
                  
   
                                              
   
  

              
  
                                                                               
   
                                     
                                                             
                                                  
    
                                 
                                                                                                  
    
   

          
  
 
      
#endif 