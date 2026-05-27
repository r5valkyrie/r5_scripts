#if SERVER || CLIENT || UI
global function LobaTacticalTranslocation_LevelInit
#endif

#if SERVER || CLIENT
global function OnWeaponAttemptOffhandSwitch_ability_translocation
global function OnWeaponActivate_ability_translocation
global function OnWeaponDeactivate_ability_translocation
global function OnWeaponTossPrep_ability_translocation
global function OnWeaponToss_ability_translocation
global function OnWeaponTossReleaseAnimEvent_ability_translocation
global function OnWeaponRedirectProjectile_ability_translocation
#endif

#if CLIENT
global function ServerToClient_Translocation_ClientProjectilePlantedHandler
global function ServerToClient_Translocation_TeleportFailed
#endif

                    
#if SERVER
global function ClientToServer_Translocation_Cancel
#endif
      


#if SERVER || CLIENT
const asset TRANSLOCATION_WARP_SCREEN_FX = $"P_ability_warp_screen"
const asset TRANSLOCATION_WARP_BEAM_FX = $"P_ability_warp_travel"
const asset TRANSLOCATION_WARP_WORLD_FX = $"P_warp_imp_default"
const string TRANSLOCATION_WARP_IMPACT_TABLE = "ability_warp"
const asset TRANSLOCATION_DROP_TO_GROUND_MARKER_FX = $"P_wrp_trl_grnd"
const asset TRANSLOCATION_DROP_TO_GROUND_ACTIVATE_FX = $"P_warp_proj_drop"
const asset TRANSLOCATION_DROP_TO_GROUND_DESTINATION_FX = $"P_warp_proj_drop_grnd"

const bool TRANSLOCATION_DEBUG = false
const float TRANSLOCATION_DEBUG_TIMEOUT = 40
const int MAX_BACKUP_CANDIDATE_SPOTS = 2 // If our trigger position failed, how many backup points should we test?
const bool TRANSLOCATION_DO_VERIFICATION = true // if we should verify our spot again - really only turn false if you need to debug the first canputplayerinsafespot
const bool TRANSLOCATION_ADDITIONAL_DEBUG = false
                    
const float RUI_MAX_RANGE = 67.0                 //tied to projectile_launch_speed
const float RUI_MAX_RANGE_UPGRADED_AMOUNT = 10.0 //tied to projectile_launch_speed
     
                                
      

const bool FORCE_TELEPORT_FAIL = false
#endif


#if CLIENT
enum eLobaCrosshairStage
{
	// This needs to match LOBA_CROSSHAIR_STAGE_* in loba.rui
	HELD = 0
	TOSSED = 1
	REDIRECTED = 2
	PLANTED = 3
	TELEPORTED = 4
	FAILED = 5
}
#endif

                    
struct
{
	array<entity> canceledTeleports
}file
      


#if SERVER || CLIENT || UI
void function LobaTacticalTranslocation_LevelInit()
{
	#if SERVER || CLIENT
		PrecacheParticleSystem( TRANSLOCATION_WARP_BEAM_FX )
		PrecacheParticleSystem( TRANSLOCATION_WARP_WORLD_FX )
		PrecacheImpactEffectTable( TRANSLOCATION_WARP_IMPACT_TABLE )
		PrecacheParticleSystem( TRANSLOCATION_DROP_TO_GROUND_MARKER_FX )
		PrecacheParticleSystem( TRANSLOCATION_DROP_TO_GROUND_ACTIVATE_FX )
		PrecacheParticleSystem( TRANSLOCATION_DROP_TO_GROUND_DESTINATION_FX )

		RegisterNetworkedVariable( "Translocation_ActiveProjectile", SNDC_PLAYER_EXCLUSIVE, SNVT_ENTITY )

		Remote_RegisterClientFunction( "ServerToClient_Translocation_ClientProjectilePlantedHandler", "entity", "entity" )
		Remote_RegisterClientFunction( "ServerToClient_Translocation_TeleportFailed", "entity" )

		                    
			Remote_RegisterServerFunction( "ClientToServer_Translocation_Cancel" )
        

		RegisterSignal( "Translocation_Deactivate" )

		AddCallback_PlayerCanUseZipline( CanUseZipline )
	#endif

	#if SERVER
		RegisterSignal( "Translocation_StopWarpBeamFX" )
	#endif

	#if CLIENT
		RegisterSignal( "Translocation_StopVisualEffect" )
		RegisterSignal( "Translocation_RedirectProjectile" )
		PrecacheParticleSystem( TRANSLOCATION_WARP_SCREEN_FX )
		StatusEffect_RegisterEnabledCallback( eStatusEffect.translocation_visual_effect, StartVisualEffect )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.translocation_visual_effect, StopVisualEffect )

		                    
			RegisterConCommandTriggeredCallback( "+scriptCommand5", CancelTeleport )
        
	#endif
}
#endif


#if SERVER || CLIENT
bool function OnWeaponAttemptOffhandSwitch_ability_translocation( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()

	if ( !IsPlayerTranslocationPermitted( owner ) )
		return false

	return true
}
#endif


#if SERVER || CLIENT
void function OnWeaponActivate_ability_translocation( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	Assert( IsValid( owner ) )

	#if SERVER
		weapon.w.translocate_initialProjectile = null
		weapon.w.translocate_redirectedProjectile = null
		weapon.w.translocate_hasProjectilePlanted = false
		weapon.w.translocate_wasTeleportSuccessState = null
		weapon.w.translocate_projectileThrowPathTaken.clear()
	#elseif CLIENT
		if ( !(InPrediction() && IsFirstTimePredicted()) )
			return

		weapon.w.translocate_predictedInitialProjectile = null
		weapon.w.translocate_predictedRedirectedProjectile = null
		weapon.w.translocate_impactRumbleObj = null
	#endif

	thread TranslocationLifetimeThread( owner, weapon )
}
#endif


#if SERVER || CLIENT
void function OnWeaponDeactivate_ability_translocation( entity weapon )
{

	#if TRANSLOCATION_ADDITIONAL_DEBUG
		entity weaponOwner = weapon.GetOwner()
		string ownerName = IsValid( weaponOwner ) ? weaponOwner.GetPlayerName() : "NULL"
	#endif

	#if CLIENT
		if ( !InPrediction() )
		{
			#if TRANSLOCATION_ADDITIONAL_DEBUG
				printt( "TRANSLOCATION:(" + ownerName + ") Client not in prediction when deactivating weapon" )
			#endif
			return
		}
	#endif

	#if TRANSLOCATION_ADDITIONAL_DEBUG
		printt( "TRANSLOCATION:(" + ownerName + ") Weapon deactivated" )
	#endif

	                    
	if( !file.canceledTeleports.contains( weapon.GetOwner() ) )
       
		Signal( weapon, "Translocation_Deactivate" )
}
#endif


#if SERVER || CLIENT
void function TranslocationLifetimeThread( entity owner, entity weapon )
{
	EndSignal( owner, "OnDeath" )
	EndSignal( weapon, "OnDestroy" )
	EndSignal( weapon, "Translocation_Deactivate" )

	string ownerName = IsValid( owner ) ? owner.GetPlayerName() : "NULL"

	var rui
	#if CLIENT
		rui = CreateFullscreenRui( $"ui/crosshair_loba_translocation.rpak", 500 )
		RuiTrackFloat( rui, "weaponGrenadeDistToImpact", weapon, RUI_TRACK_GRENADE_DIST_FROM_IMPACT )
		RuiSetFloat( rui, "estimatedMaxDist", GetLobaTacticalEstimatedMaxDistance( owner ) )

		                    
			if( owner.HasPassive( ePassives.PAS_TAC_UPGRADE_TWO ) ) // loba_upgrade_teleport_cancel
			{
				RuiSetString( rui, "locString", "%&attack% Drop %scriptCommand5% Cancel" )
			}
        
	#endif

	bool[1] haveLockedForToss = [false]

	OnThreadEnd( void function() : ( owner, weapon, rui, haveLockedForToss, ownerName ) {
		#if TRANSLOCATION_ADDITIONAL_DEBUG
			printt( "TRANSLOCATION:(" + ownerName + ") Translocation lifetime thread end" )
		#endif

		if ( IsValid( owner ) )
		{
			if ( haveLockedForToss[0] )
			{
				#if SERVER
					if ( weapon.w.translocate_wallClimbBlockStatusEffectID != null )
					{
						StatusEffect_Stop( owner, expect int( weapon.w.translocate_wallClimbBlockStatusEffectID ) )
						weapon.w.translocate_wallClimbBlockStatusEffectID = null

						Assert( weapon.w.translocate_doubleJumpBlockStatusEffectID != null )
						StatusEffect_Stop( owner, expect int( weapon.w.translocate_doubleJumpBlockStatusEffectID ) )
						weapon.w.translocate_doubleJumpBlockStatusEffectID = null

						Assert( weapon.w.translocate_wallHangBlockStatusEffectID != null )
						StatusEffect_Stop( owner, expect int( weapon.w.translocate_wallHangBlockStatusEffectID ) )
						weapon.w.translocate_wallHangBlockStatusEffectID = null

						if ( !GetLobaTacticalAllowMantle() )
							EnableMantle( owner )
					}
					owner.EnableWeaponTypes( WPT_ULTIMATE | WPT_CONSUMABLE )
					UnlockWeaponsAndMelee( owner, "translocation" )
				#endif
			}
		}

		#if CLIENT
			RuiDestroyIfAlive( rui )
		#endif
	} )

	int offhandSlot = 0

	while ( true )
	{
		entity currentActiveOffhandWeapon = owner.GetActiveWeapon( offhandSlot )
		if ( currentActiveOffhandWeapon != weapon )
		{
			#if TRANSLOCATION_ADDITIONAL_DEBUG
				string offhandWeaponName = IsValid( currentActiveOffhandWeapon ) ? currentActiveOffhandWeapon.GetWeaponClassName() : "NULL"
				printt( "TRANSLOCATION:(" + ownerName + ") Current active weapon in the offhand slot " + offhandWeaponName + " does not match this weapon " + weapon.GetWeaponClassName() )
			#endif
			break
		}

		#if CLIENT
			int crosshairStage = eLobaCrosshairStage.HELD
		#endif

		entity currentProjectile = GetCurrentTranslocationProjectile( owner, weapon )
		if ( IsValid( currentProjectile ) )
		{
			#if CLIENT
				if ( currentProjectile.IsGrenadeStatusFlagSet( GSF_PLANTED ) )
					crosshairStage = eLobaCrosshairStage.PLANTED
				//else if ( currentProjectile.IsGrenadeStatusFlagSet( GSF_REDIRECTED ) )
				//	crosshairStage = eLobaCrosshairStage.REDIRECTED
				else
					crosshairStage = eLobaCrosshairStage.TOSSED
			#endif

			if ( !haveLockedForToss[0] )
			{
				#if SERVER // (dw): These disables aren't predicted, which may lead to small mispredictions

					Assert( weapon.w.translocate_wallClimbBlockStatusEffectID == null )
					weapon.w.translocate_wallClimbBlockStatusEffectID = StatusEffect_AddEndless( owner, eStatusEffect.disable_wall_run, 1.0 )

					Assert( weapon.w.translocate_doubleJumpBlockStatusEffectID == null )
					weapon.w.translocate_doubleJumpBlockStatusEffectID = StatusEffect_AddEndless( owner, eStatusEffect.disable_double_jump, 1.0 )

					Assert( weapon.w.translocate_wallHangBlockStatusEffectID == null )
					weapon.w.translocate_wallHangBlockStatusEffectID = StatusEffect_AddEndless( owner, eStatusEffect.disable_automantle_hang, 1.0 )

					if ( !GetLobaTacticalAllowMantle() )
						DisableMantle( owner )
					owner.DisableWeaponTypes( WPT_ULTIMATE | WPT_CONSUMABLE )

					LockWeaponsAndMelee( owner, "translocation" )

				#endif

				haveLockedForToss[0] = true
			}
		}
		else
		{
			#if CLIENT
				if ( weapon.GetWeaponActivity() == ACT_VM_PICKUP )
					crosshairStage = eLobaCrosshairStage.TELEPORTED
				else if ( weapon.GetWeaponActivity() == ACT_VM_MISSCENTER )
					crosshairStage = eLobaCrosshairStage.FAILED
			#endif
		}

		#if CLIENT
			RuiSetInt( rui, "stage", crosshairStage )
			//RuiSetFloat( rui, "weaponGrenadeDistToImpact", weapon.GetDistanceFromGrenadeImpact2D() )
		#endif

		WaitFrame()
	}
}
#endif


                    
#if SERVER
void function ClientToServer_Translocation_Cancel( entity player )
{
	if( !IsValid( player ) && !player.IsPlayer() )
		return
	if( !PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_TWO ) ) // loba_upgrade_teleport_cancel
		return
	entity offhandWeapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )
	if( !IsValid( offhandWeapon ) )
		return
	if( !IsValid( GetCurrentTranslocationProjectile( player, offhandWeapon ) ) )
		return
	if( file.canceledTeleports.contains( player ) )
		return

	file.canceledTeleports.append( player )
	offhandWeapon.StartCustomActivity( "ACT_VM_MISSCENTER", WCAF_PLAYRAISEONCOMPLETE )
}
#endif
      


#if SERVER || CLIENT
bool function CanUseZipline( entity player, entity zipline, vector ziplineClosestPoint )
{
	entity mainHandWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( IsValid( mainHandWeapon ) && mainHandWeapon.GetWeaponClassName() == "mp_ability_translocation" )
		return GetLobaTacticalAllowZiplineWhileDeployed()

	return true
}
#endif


#if SERVER || CLIENT
void function OnWeaponTossPrep_ability_translocation( entity weapon, WeaponTossPrepParams prepParams )
{
	entity owner = weapon.GetWeaponOwner()

	#if CLIENT
		if ( !(InPrediction() && IsFirstTimePredicted()) )
			return
	#endif

	weapon.EmitWeaponSound_1p3p( GetGrenadeDeploySound_1p( weapon ), GetGrenadeDeploySound_3p( weapon ) )

	#if CLIENT
		Rumble_Play( "loba_tactical_pull", {} )
	#endif
}
#endif


#if SERVER || CLIENT
var function OnWeaponToss_ability_translocation( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()

	return weapon.GetAmmoPerShot()
}
#endif


#if SERVER || CLIENT
var function OnWeaponTossReleaseAnimEvent_ability_translocation( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()

	#if SERVER
		//
	#elseif CLIENT
		if ( !(InPrediction() && IsFirstTimePredicted()) )
			return
	#endif

	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )

	#if SERVER
		if ( !IsEventFinale() )
			PlayBattleChatterLineToSpeakerAndTeam( owner, "bc_tactical" )
	#endif

	entity projectile = ThrowDeployable( weapon, attackParams, 1, OnProjectilePlanted, null, null )
	if ( IsValid( projectile ) )
	{
		PlayerUsedOffhand( owner, weapon, true, projectile )

		#if SERVER
			weapon.w.translocate_initialProjectile = projectile
			owner.SetPlayerNetEnt( "Translocation_ActiveProjectile", projectile )

			weapon.w.translocate_projectileThrowPathTaken.append( attackParams.pos )

			projectile.SetIgnorePredictedTriggerTypes( TT_JUMP_PAD | TT_TESLA_TRAP | TT_GRAVITY_LIFT | TT_BLACKHOLE )

			projectile.SetTouchTriggers( true )
			//projectile.SetProjectileTouchesOwnerTriggers( true )
			projectile.proj.projectileForceBounceWithinDist = GetCurrentPlaylistVarFloat( "loba_tactical_force_more_bounces_dist", 59.0 )

			string projectileSound = GetGrenadeProjectileSound( weapon )
			if ( projectileSound != "" )
				EmitSoundOnEntity( projectile, projectileSound )

			TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_TRANSLOCATION_TOSS, owner, owner.GetOrigin(), owner.GetTeam(), owner )
		#elseif CLIENT
			weapon.w.translocate_predictedInitialProjectile = projectile
			//Rumble_Play( "loba_tactical_toss", {} )
		#endif

		#if TRANSLOCATION_ADDITIONAL_DEBUG
			vector ownerPos = owner.GetOrigin(), ownerAng = owner.EyeAngles()
			printf( "TRANSLOCATION:(" + owner.GetPlayerName() + ") Toss from setpos %f %f %f; setang %f %f %f", ownerPos.x, ownerPos.y, ownerPos.z, ownerAng.x, ownerAng.y, ownerAng.z )
		#endif

		thread TranslocationTossedThread( owner, weapon )
	}

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot ) //weapon.GetAmmoPerShot()
}
#endif


#if SERVER || CLIENT
bool function OnWeaponRedirectProjectile_ability_translocation( entity weapon, WeaponRedirectParams params )
{
	entity owner = weapon.GetWeaponOwner()

	if ( !GetLobaTacticalAllowDropToGround() )
		return false

	float dropToGroundMinimumTime = GetCurrentPlaylistVarFloat( "loba_tactical_drop_minimum_time", 0.24 )
	if ( Time() < params.projectile.GetProjectileCreationTimeServer() + dropToGroundMinimumTime )
		return false

	if ( params.projectile.HasWeaponMod( "redirect_mod" ) )
		return false

	#if SERVER
		if ( weapon.w.translocate_hasProjectilePlanted )
			return false
	#endif

	#if TRANSLOCATION_ADDITIONAL_DEBUG
		vector ownerPos = owner.GetOrigin(), ownerAng = owner.EyeAngles()
		printf( "TRANSLOCATION:(" + owner.GetPlayerName() + ") Redirect at setpos %f %f %f", params.projectilePos.x, params.projectilePos.y, params.projectilePos.z )
	#endif

	weapon.StartCustomActivity( "ACT_VM_HITCENTER", WCAF_NONE )

	WeaponPrimaryAttackParams attackParams
	attackParams.pos = params.projectilePos
	attackParams.dir = <0.0, 0.0, -1.0>
	attackParams.firstTimePredicted = false
	attackParams.burstIndex = 0
	attackParams.barrelIndex = 0

	                    
	if( !PlayerHasPassive( owner, ePassives.PAS_TAC_UPGRADE_THREE ) ) // loba_upgrade_teleport_trail_stealth
       
	weapon.AddMod( "redirect_mod" )
	entity projectile = ThrowDeployable( weapon, attackParams, 1, OnProjectilePlanted, null, null )
	                    
	if( !PlayerHasPassive( owner, ePassives.PAS_TAC_UPGRADE_THREE ) ) // loba_upgrade_teleport_trail_stealth
       
	weapon.RemoveMod( "redirect_mod" )

	if ( !IsValid( projectile ) )
		return false

	//projectile.AddGrenadeStatusFlag( GSF_REDIRECTED )

	string projectileSound = GetGrenadeProjectileSound( weapon )
	if ( projectileSound != "" )
		EmitSoundOnEntity( projectile, projectileSound )

	#if SERVER
		weapon.w.translocate_redirectedProjectile = projectile
		weapon.w.translocate_projectileThrowPathTaken.append( params.projectilePos )
		owner.SetPlayerNetEnt( "Translocation_ActiveProjectile", projectile )

		projectile.SetIgnorePredictedTriggerTypes( TT_JUMP_PAD | TT_TESLA_TRAP )

		projectile.SetTouchTriggers( true )
		//projectile.SetProjectileTouchesOwnerTriggers( true )
		projectile.proj.projectileForceBounceWithinDist = GetCurrentPlaylistVarFloat( "loba_tactical_force_more_bounces_dist", 59.0 )

		thread DropToGroundFXThread( owner, projectile, params.projectile, params.projectilePos )
		EmitSoundOnEntityExceptToPlayer( projectile, owner, "Loba_TeleportRing_ForceDown_3P" )
	#elseif CLIENT
		weapon.w.translocate_predictedRedirectedProjectile = projectile

		if ( !InPrediction() || IsFirstTimePredicted() )
		{
			thread DropToGroundFXThread( owner, projectile, params.projectile, params.projectilePos )
			EmitSoundOnEntity( projectile, "Loba_TeleportRing_ForceDown_3P" )
		}
	#endif

	return true
}
#endif


#if SERVER || CLIENT
void function TranslocationTossedThread( entity owner, entity weapon )
{
	EndSignal( owner, "OnDeath" )
	EndSignal( weapon, "OnDestroy" )
	EndSignal( weapon, "Translocation_Deactivate" )

	array<int> fxIds
	table[1] rumbleHandle = [{}]

	string ownerName = IsValid( owner ) ? owner.GetPlayerName() : "NULL"

	#if TRANSLOCATION_ADDITIONAL_DEBUG
		entity ownerParent = owner.GetParent()
		if( IsValid( ownerParent ) )
		{
			printt( "TRANSLOCATION:(" + ownerName + ") parented to " + ownerParent + " when starting the toss thread" )
		}
	#endif

	OnThreadEnd( void function() : ( owner, weapon, fxIds, rumbleHandle, ownerName ) {
		#if SERVER
			#if TRANSLOCATION_ADDITIONAL_DEBUG
				printt( "TRANSLOCATION:(" + ownerName + ") Tossed thread ending" )
			#endif

			if ( IsValid( weapon ) )
			{
				entity currentProjectile = GetCurrentTranslocationProjectile( owner, weapon )

				if ( !IsValid( currentProjectile ) )
				{
					#if TRANSLOCATION_ADDITIONAL_DEBUG
						printt("TRANSLOCATION:(" + ownerName + ") Projectile was not valid when ending the tossed thread" )
					#endif
					weapon.w.translocate_wasTeleportSuccessState = false
				}

				// If our teleport was unnsuccessful..
				if ( weapon.w.translocate_wasTeleportSuccessState != true )
				{
					#if TRANSLOCATION_ADDITIONAL_DEBUG
						printt( "TRANSLOCATION:(" + ownerName + ") Teleport was unsuccessful. Refunding weapon ammo" )
					#endif

					// Refund the tactical charge.
					int ammoPerShot = weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
					int maxAmmo     = weapon.GetWeaponPrimaryClipCountMax()
					int curAmmo     = weapon.GetWeaponPrimaryClipCount()
					int newAmmo     = minint( curAmmo + ammoPerShot, maxAmmo )
					weapon.SetWeaponPrimaryClipCount( newAmmo )
					weapon.OverrideNextAttackTime( Time() )

					// Play miss animation.
					                    
					if( !file.canceledTeleports.contains( owner ) )
           
					{
						if ( IsValid( owner ) )
						{
							#if TRANSLOCATION_ADDITIONAL_DEBUG
								entity mainhandWeapon = owner.GetActiveWeapon( eActiveInventorySlot.mainHand )
								string mainhandWeaponName = IsValid( mainhandWeapon ) ? mainhandWeapon.GetWeaponClassName() : "NULL"
								printt( "TRANSLOCATION:("+ owner.GetPlayerName() + ") Playing failure animation. Active weapon: " + mainhandWeaponName + " and current weapon activty: " + weapon.GetWeaponActivity() )
							#endif

							Signal( owner, "Translocation_StopWarpBeamFX" )
							StatusEffect_StopAllOfType( owner, eStatusEffect.translocation_visual_effect )
							//EmitSoundOnEntityOnlyToPlayer( owner, owner, "shield_battery_failure" )
							weapon.StartCustomActivity( "ACT_VM_MISSCENTER", WCAF_PLAYRAISEONCOMPLETE )

							Remote_CallFunction_Replay( owner, "ServerToClient_Translocation_TeleportFailed", weapon )
						}
					}
				}
			}

			// Destroy projectile if it still exists.

			if ( IsValid( weapon.w.translocate_initialProjectile ) )
				weapon.w.translocate_initialProjectile.Destroy()
			if ( IsValid( weapon.w.translocate_redirectedProjectile ) )
				weapon.w.translocate_redirectedProjectile.Destroy()
		#elseif CLIENT
			//if ( IsValid( weapon ) && weapon.GetWeaponOwner() == owner )
			//	weapon.SetWeaponPrimaryClipCount( 0 )

			CleanupFXArray( fxIds, true, false )

			rumbleHandle[0].loop = false

			#if TRANSLOCATION_ADDITIONAL_DEBUG
				printt( "TRANSLOCATION: Client tossed thread ended" )
			#endif
		#endif
	} )

	#if CLIENT
		rumbleHandle[0] = expect table(Rumble_Play( "loba_tactical_toss_loop", { loop = true, } ))
		//rumbleHandle[0].scale <- 40.0

		int dropTargetFXId = -1
		if ( GetLobaTacticalAllowDropToGround() )
		{
			dropTargetFXId = StartParticleEffectInWorldWithHandle( GetParticleSystemIndex( TRANSLOCATION_DROP_TO_GROUND_MARKER_FX ),
				weapon.GetAttackPosition(), <-90, VectorToAngles( weapon.GetAttackDirection() ).y, 0> )
			if ( dropTargetFXId != -1 )
				fxIds.append( dropTargetFXId )
		}
	#endif

	bool didDrop        = false
	bool dropInProgress = false

	float tossTime     = Time()
	float timeoutDelay = weapon.GetWeaponSettingFloat( eWeaponVar.grenade_fuse_time )
	#if SERVER
		vector prevVel = <0, 0, 0>
	#endif

	//const float SAMPLE_TIME = 0.2
	//float nextSampleTime = Time() + SAMPLE_TIME
	while( true )
	{
		entity currentProjectile = GetCurrentTranslocationProjectile( owner, weapon )
		if ( !IsValid( currentProjectile ) )
		{
			#if TRANSLOCATION_ADDITIONAL_DEBUG
				printt( "TRANSLOCATION:(" + ownerName + ") Projectile was invalid in translocation tossed thread" )
			#endif
			break
		}

		#if SERVER
			if ( prevVel == <0, 0, 0> )
			{
				prevVel = currentProjectile.GetVelocity()
				prevVel = Normalize( prevVel )
			}
			// Track position along the path
			{
				vector curPos = currentProjectile.GetOrigin()
				weapon.w.translocate_projectileThrowPathTaken.append( curPos )
			}

			if ( weapon.w.translocate_wasTeleportSuccessState != null )
			{
				#if TRANSLOCATION_ADDITIONAL_DEBUG
					string successState = weapon.w.translocate_wasTeleportSuccessState ? "true" : "false"
					printf("TRANSLOCATION:(%s) Tossed thread ending because teleport was attempted and success state was %s", ownerName, successState )
				#endif
				break // The teleport has been attempted (whether it succeeded or failed)
			}

			// Cancel teleport if it takes too long
			float extendedWait = (weapon.w.translocate_hasProjectilePlanted ? 2.0 : 0.0)
			if ( Time() > tossTime + timeoutDelay + extendedWait )
				break

		#elseif CLIENT
			if ( dropTargetFXId != 1 )
				EffectSetControlPointVector( dropTargetFXId, 0, OriginToGround( currentProjectile.GetOrigin(), TRACE_MASK_NPCWORLDSTATIC, currentProjectile ) + <0, 0, 5> )
		#endif

		// Cancel teleport if player is in a bad state
		if ( !IsPlayerTranslocationPermitted( owner ) )
			break

		//weapon.SetWeaponPrimaryClipCount( 0 )

		WaitFrame()
	}

	#if SERVER
		if ( weapon.w.translocate_wasTeleportSuccessState == null )
		{
			#if TRANSLOCATION_ADDITIONAL_DEBUG
				printt( "TRANSLOCATION:(" + ownerName + ") Teleport success state was never set to true or false" )
			#endif
			weapon.w.translocate_wasTeleportSuccessState = false
		}
	#endif
}
#endif

#if SERVER
bool function IsLandingPositionValid( vector position, entity player, array<int> realms, entity projectile )
{
	return true
}


#endif

#if SERVER || CLIENT
void function OnProjectilePlanted( entity projectile, DeployableCollisionParams collisionParams )
{
	entity owner = projectile.GetOwner()
	if ( !IsValid( owner ) )
		return

	entity weapon = projectile.GetWeaponSource()
	if ( !IsValid( weapon ) )
		return

                    
	if( file.canceledTeleports.contains( owner ) )
	{
	#if SERVER
		projectile.Destroy()
	#endif
		thread CleanupCanceledTeleport( owner )
		return
	}
      

	#if SERVER
		#if TRANSLOCATION_ADDITIONAL_DEBUG
			printt( "TRANSLOCATION:(" + owner.GetPlayerName() + ") Projectile planted" )
		#endif

		weapon.w.translocate_hasProjectilePlanted = true
		thread TranslocatePlayerThread( owner, weapon, projectile, collisionParams, projectile.GetOrigin() )

		Remote_CallFunction_Replay( owner, "ServerToClient_Translocation_ClientProjectilePlantedHandler", weapon, projectile )
	#elseif CLIENT
		#if TRANSLOCATION_ADDITIONAL_DEBUG
			printt( "TRANSLOCATION: Client projectile had predicted plant" )
		#endif
		ClientProjectilePlantHandler( weapon, projectile ) // predicted plant
	#endif
}
#endif

                    
#if SERVER || CLIENT
void function CleanupCanceledTeleport( entity player )
{
	wait( .1 )
	if( file.canceledTeleports.contains( player ) )
		file.canceledTeleports.fastremovebyvalue( player )
}
#endif
      

#if CLIENT
void function ServerToClient_Translocation_ClientProjectilePlantedHandler( entity weapon, entity projectile )
{
	if ( !IsValid( weapon ) || !IsValid( projectile ) )
		return

	ClientProjectilePlantHandler( weapon, projectile )
}
#endif


#if CLIENT
void function ClientProjectilePlantHandler( entity weapon, entity projectile )
{
	// This may be called twice -- once predicted and once from server -- so make sure things don't occur twice

	if ( weapon.w.translocate_impactRumbleObj == null )
		weapon.w.translocate_impactRumbleObj = expect table(Rumble_Play( "loba_tactical_impact_and_teleport", {} ))

	#if TRANSLOCATION_ADDITIONAL_DEBUG
		printt( "TRANSLOCATION: Client Projectile planted" )
	#endif
}
#endif


#if CLIENT
void function ServerToClient_Translocation_TeleportFailed( entity weapon )
{
	#if TRANSLOCATION_ADDITIONAL_DEBUG
		printt( "TRANSLOCATION: Client teleport failed" )
	#endif

	if ( !IsValid( weapon ) )
		return

	if ( weapon.w.translocate_impactRumbleObj == null )
		return

	table impactRumbleObj = expect table(weapon.w.translocate_impactRumbleObj)
	impactRumbleObj.scale = 0.0
	weapon.w.translocate_impactRumbleObj = null
}
#endif


#if SERVER
void function TranslocatePlayerThread( entity owner, entity weapon, entity projectile, DeployableCollisionParams collisionParams, vector projectilePos )
{
	string ownerName = IsValid( owner ) ? owner.GetPlayerName() : "NULL"

	if ( !IsValid( projectile ) )
	{
		#if TRANSLOCATION_ADDITIONAL_DEBUG
			printt( "TRANSLOCATION:(" + owner.GetPlayerName() + ") Projectile was invalid when starting the translocate player thread" )
		#endif
		return
	}

	EndSignal( owner, "OnDeath" )
	EndSignal( weapon, "OnDestroy" )
	EndSignal( weapon, "Translocation_Deactivate" )
	EndSignal( projectile, "OnDestroy" )

	#if TRANSLOCATION_DEBUG
		int numPathPts = weapon.w.translocate_projectileThrowPathTaken.len()
		DebugDrawSphere( projectilePos, 5.0, COLOR_BLACK, false,TRANSLOCATION_DEBUG_TIMEOUT )
		for ( int i = 1; i < numPathPts; ++i )
		{
			vector pathPos = weapon.w.translocate_projectileThrowPathTaken[i]
			DebugDrawLine( weapon.w.translocate_projectileThrowPathTaken[i-1], pathPos, COLOR_RED, false,TRANSLOCATION_DEBUG_TIMEOUT )
			DebugDrawSphere( pathPos, 4.0, COLOR_RED, false,TRANSLOCATION_DEBUG_TIMEOUT )
			DebugDrawText( pathPos, string( Distance( pathPos, projectilePos ) ), false, TRANSLOCATION_DEBUG_TIMEOUT )
		}
		if ( numPathPts > 0 )
			DebugDrawLine( weapon.w.translocate_projectileThrowPathTaken[numPathPts-1], projectilePos, COLOR_RED, false,TRANSLOCATION_DEBUG_TIMEOUT )
	#endif

	array<vector> candidateSpots = []
	candidateSpots.append( projectilePos )
	FillBackupCandidateSpots( weapon.w.translocate_projectileThrowPathTaken,candidateSpots, MAX_BACKUP_CANDIDATE_SPOTS )

	// Check for a valid place to teleport to.
	vector ornull ownerMaybePos = TryTranslocateSpots( owner, weapon, projectile, candidateSpots, projectilePos )
	if ( ownerMaybePos == null )
	{
		// If none found, just immediately fail.
		printt( "TRANSLOCATION:(" + ownerName + ") Couldn't find a valid spot to teleport to" )
		weapon.w.translocate_wasTeleportSuccessState = false
		return
	}
	expect vector( ownerMaybePos )

	// Play a satisfying confirmation sound on plant (except when we early fail)
	EmitSoundOnEntityExceptToPlayer( projectile, owner, "Loba_Tactical_Impact_3P" )
	EmitSoundOnEntityOnlyToPlayer( projectile, owner, "Loba_Tactical_Impact_1P" )

	// Start the teleport sound early, for build up
	EmitSoundOnEntityOnlyToPlayer( owner, owner, "Loba_Tactical_Warp_1P" )

	OnThreadEnd( void function() : ( owner, weapon, ownerName ) {
		#if TRANSLOCATION_ADDITIONAL_DEBUG
			string successState = IsValid( weapon.w.translocate_wasTeleportSuccessState ) ? ( weapon.w.translocate_wasTeleportSuccessState ? "true" : "false" ) : "null"
			printf( "TRANSLOCATION:(%s) Translocate player thread ended and success state was %s", ownerName, successState )
		#endif

		if ( IsValid( owner ) && IsValid( weapon ) )
		{
			if ( weapon.w.translocate_wasTeleportSuccessState != true )
				StopSoundOnEntity( owner, "Loba_Tactical_Warp_1P" ) // cancel teleport sound if teleport fails
		}
	} )

	weapon.StartCustomActivity( "ACT_VM_PICKUP", WCAF_PLAYRAISEONCOMPLETE )

	float customActDuration = weapon.IsInCustomActivity() ? weapon.GetCustomActivityDuration() : 1.2 // defensive fix for R5DEV-149708
	thread RestoreWallclimbAndDoubleJumpAfterAnim( owner, weapon, customActDuration )

	// Wait a short time before teleporting the player.
	float plantTime = Time()
	float delay     = GetCurrentPlaylistVarFloat( "loba_tactical_pre_teleport_delay", 0.4 )
	float fxPreTime = 0.2
	#if TRANSLOCATION_ADDITIONAL_DEBUG
		printt( "TRANSLOCATION:(" + ownerName + ") Player reached first delay while loop with wait" )
	#endif
	while ( Time() < plantTime + delay - fxPreTime )
	{
		if ( !IsPlayerTranslocationPermitted( owner ) )
		{
			#if TRANSLOCATION_ADDITIONAL_DEBUG
				printt( "TRANSLOCATION:(" + ownerName + ") Player entered a bad state during the initial teleport delay and was not permitted to teleport" )
			#endif
			return // If the player enters a bad state, abort the teleport.
		}

		WaitFrame()
	}

	#if TRANSLOCATION_ADDITIONAL_DEBUG
		printt( "TRANSLOCATION:(" + ownerName + ") Player finished first delay while loop" )
	#endif

	// Play some screen FX just before teleport
	StatusEffect_AddTimed( owner, eStatusEffect.translocation_visual_effect, 1.0, GetCurrentPlaylistVarFloat( "loba_tactical_screen_fx_duration", 1.0 ), 0.0 )

	// Wait the rest of the time
	while ( Time() < plantTime + delay )
	{
		if ( !IsPlayerTranslocationPermitted( owner ) )
		{
			#if TRANSLOCATION_ADDITIONAL_DEBUG
				printt( "TRANSLOCATION:(" + ownerName + ") Player entered a bad state during the second teleport delay and was not permitted to teleport" )
			#endif
			return // If the player enters a bad state, abort the teleport.
		}

		WaitFrame()
	}

	// Store original position
	vector ownerOrigPos = owner.GetOrigin()
	vector ownerOrigAng = owner.GetAngles()
	vector ownerOrigVel = owner.GetVelocity()

	// Time has passed so we need to adjust the starting position
	// We've aleady played the success sound, so if we can't find a valid destination spot this time the player will be very disappointed... oh well.
	// also need to resort incase projectile is on a mover

	vector ornull ownerFinalPos = ownerMaybePos
	if ( TRANSLOCATION_DO_VERIFICATION )
	{
		// Save on high collision detection which the first query did the first time.  safeSpot should be high collision free.
		ownerFinalPos = CanPutPlayerInSafeSpot( owner, null, null, false, false, ownerMaybePos, ownerMaybePos )
		if ( ownerFinalPos == null )
		{
			weapon.w.translocate_wasTeleportSuccessState = false
			#if TRANSLOCATION_ADDITIONAL_DEBUG
				printt( "TRANSLOCATION:(" + ownerName + ") Final teleport position was not valid (CanPutPlayerInSafeSpot failed)" )
			#endif
			return
		}
	}
	else
	{
		ownerFinalPos = ownerMaybePos
	}

	expect vector( ownerFinalPos )


       

	if ( owner.ContextAction_IsZipline() )
		owner.Zipline_Stop()

	thread SetPlayerTeleportingFlagThread( owner )

	//PlayerMelee_ClearPlayerAsLungeTarget( owner, true )
	//owner.Server_InvalidateMeleeLungeLagCompensationRecords() // EXTREMELY DANGEROUS - Talk to Code before using!!!

	owner.SetAbsAngles( VectorToAngles( ownerFinalPos - ownerOrigPos ) )
	owner.SetVelocity( <0, 0, 0> )

	bool success = false
	#if !FORCE_TELEPORT_FAIL
		success = TeleportPlayerNoInterp( owner, ownerFinalPos )
	#endif
	if ( !success )
	{
		owner.SetAbsAngles( ownerOrigAng )
		owner.SetVelocity( ownerOrigVel )
		weapon.w.translocate_wasTeleportSuccessState = false
		#if TRANSLOCATION_ADDITIONAL_DEBUG
			printt( "TRANSLOCATION:(" + ownerName + ") Teleport player function was not successful" )
		#endif
		return
	}
	#if TRANSLOCATION_ADDITIONAL_DEBUG
		printt( "TRANSLOCATION:(" + ownerName + ") Teleport player function was successful" )
	#endif
	weapon.w.translocate_wasTeleportSuccessState = true
	// (dw): Cannot call SetAbsAngles here otherwise it triggers any pending trigger enter callbacks IMMEDIATELY! (see R5DEV-136092)
	//owner.SetAbsAngles( VectorToAngles( owner.GetOrigin() - ownerOrigPos ) )
	//owner.SetVelocity( <0, 0, 0> )

	// Play cool sounds at start and destination
	EmitSoundAtPositionExceptToPlayer( owner.GetTeam(), ownerOrigPos, owner, "Loba_Tactical_WarpOut_3P" )
	EmitSoundAtPositionExceptToPlayer( owner.GetTeam(), ownerFinalPos, owner, "Loba_Tactical_WarpIn_3P" )
	//EmitWhizbySoundExceptToPlayer( owner.GetTeam(), owner, ownerOrigPos, ownerFinalPos, "Loba_Tactical_WarpBy_3P" )

	// Touch Triggers that the player may have passed
	owner.SetTouchTriggers( true )
	//projectile.TriggerAndTouchOwnerTouchedTriggers()

	// Play cool FX at start and destination
	vector ang = VectorToAngles( Normalize( ownerFinalPos - ownerOrigPos ) )
	StartParticleEffectInWorld( GetParticleSystemIndex( TRANSLOCATION_WARP_WORLD_FX ), ownerOrigPos, <0, ang.y, 0> )
	StartParticleEffectInWorld( GetParticleSystemIndex( TRANSLOCATION_WARP_WORLD_FX ), ownerFinalPos, <0, ang.y, 0> )
	PlayImpactFXTable( ownerOrigPos, owner, TRANSLOCATION_WARP_IMPACT_TABLE )
	PlayImpactFXTable( ownerFinalPos, owner, TRANSLOCATION_WARP_IMPACT_TABLE )

	// Play a beam effect
	thread WarpBeamFXThread( owner, ownerOrigPos + <0, 0, 32>, ownerFinalPos + <0, 0, 8> )

	// Interactions with other abilities
	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_TRANSLOCATION_TELEPORT, owner, owner.GetOrigin(), owner.GetTeam(), owner )
	Signal( owner, SIGNAL_TELEPORTED )

	// Stats
	StatsHook_Translocation_OnTeleport( owner, ownerOrigPos, ownerFinalPos )
}

void function FillBackupCandidateSpots( array<vector> pathPts, array<vector> candidateSpots, int maxBackupSpots )
{
	// Due to the low frequency of updates for the projectile's path position, it can bounce around
	// a lot so getting interpolated positions might put us in unexpected positions.
	// It is always best to pick a location on the path if possible.
	//
	// Pick candidates that are close to where we threw and distanced from one another
	// We prefer a location actually on the path of the throw, but
	const float MIN_DIST_AWAY = 50  // If it's too close we might still get stuck
	const float MIN_DIST_AWAY_SQR = MIN_DIST_AWAY * MIN_DIST_AWAY
	const float MAX_DIST_AWAY_SQR = 4*MIN_DIST_AWAY_SQR
	const float MIN_DIST_AWAY_FROM_INITIAL_THROW_SQR = 40 * 40
	int numPathPts = pathPts.len()
	vector initialThrowPos = numPathPts > 0 ? pathPts[0] : <0, 0, 0>
	int backupCount = 0

	Assert( candidateSpots.len() >= 1 )
	for ( int i = numPathPts - 1; i >= 0 && backupCount < maxBackupSpots; )
	{
		vector pathPos = pathPts[i]
		vector prevPos = candidateSpots[candidateSpots.len()-1]

		float distAwaySqr = DistanceSqr(prevPos, pathPos );
		if ( distAwaySqr >= MIN_DIST_AWAY_SQR )
		{
			if ( distAwaySqr <= MAX_DIST_AWAY_SQR && DistanceSqr( pathPos, initialThrowPos ) >= MIN_DIST_AWAY_FROM_INITIAL_THROW_SQR )
			{
				candidateSpots.append( pathPos )
				backupCount++
				i--
			}
			else
			{
				vector interpDir = Normalize( pathPos - prevPos )
				vector newPos = prevPos + interpDir*MIN_DIST_AWAY
				if ( interpDir.Dot( newPos - pathPos ) < 0.0 )
				{
					if ( DistanceSqr( newPos, initialThrowPos ) < MIN_DIST_AWAY_FROM_INITIAL_THROW_SQR ) // Discard backups if we're getting too close to the player - don't waste their tac (we don't discard original pos because we assume deliberate intent)
						break

					candidateSpots.append( prevPos + interpDir*MIN_DIST_AWAY )
					backupCount++
				}
				else
					break // Don't go behind
			}
		}
		else
		{
			i--
		}
	}
}

void function RestoreWallclimbAndDoubleJumpAfterAnim( entity owner, entity weapon, float duration )
{
	if ( duration > 0.0 )
		wait duration

	if ( IsValid( weapon ) && IsValid( owner ) && weapon.w.translocate_wallClimbBlockStatusEffectID != null )
	{
		StatusEffect_Stop( owner, expect int( weapon.w.translocate_wallClimbBlockStatusEffectID ) )
		weapon.w.translocate_wallClimbBlockStatusEffectID = null

		Assert( weapon.w.translocate_doubleJumpBlockStatusEffectID != null )
		StatusEffect_Stop( owner, expect int( weapon.w.translocate_doubleJumpBlockStatusEffectID ) )
		weapon.w.translocate_doubleJumpBlockStatusEffectID = null

		Assert( weapon.w.translocate_wallHangBlockStatusEffectID != null )
		StatusEffect_Stop( owner, expect int( weapon.w.translocate_wallHangBlockStatusEffectID ) )
		weapon.w.translocate_wallHangBlockStatusEffectID = null

		if ( !GetLobaTacticalAllowMantle() )
			EnableMantle( owner )
	}
}

void function SetPlayerTeleportingFlagThread( entity owner )
{
	OnThreadEnd( void function() : ( owner ) {
		if ( IsValid( owner ) )
		{
			//owner.EndTeleport()
		}
	} )

	//owner.StartTeleport()
	WaitFrame()
}
#endif

#if SERVER
vector ornull function TryTranslocateSpots( entity owner, entity weapon, entity projectile, array<vector> candidateSpots, vector projectilePos )
{
	#if TRANSLOCATION_DEBUG
		for ( int i = 0; i < candidateSpots.len(); i++ )
		{
			DebugDrawSphere( candidateSpots[i], 5.5, <204, 153, 255>, false, TRANSLOCATION_DEBUG_TIMEOUT )
		}
	#endif

	vector ownerOrigPos = owner.GetOrigin()
	vector prevPos
	int maxTries = candidateSpots.len()
	for ( int spotIdx = 0; spotIdx < maxTries; spotIdx++ )
	{
		vector spot = candidateSpots[spotIdx]

#if TRANSLOCATION_DEBUG
		DebugDrawArrow(  spot + 40*<0.0, 0.0, 1.0>, spot, 5.0, COLOR_RED, true, TRANSLOCATION_DEBUG_TIMEOUT )
#endif

		if ( PassesAdditionalSafePosTests( spot, owner, projectile ) )
		{
			vector ornull safeSpot = CanPutPlayerInSafeSpot( owner, null, null, true, false, spot, spot )
			if ( safeSpot != null )
			{
				// Test final position
				expect vector( safeSpot )
				if ( PassesAdditionalSafePosTests( safeSpot, owner, projectile ) )
				{
					return safeSpot
				}
			}
		}
	}
	return null
}
#endif

#if SERVER
bool function PassesAdditionalSafePosTests( vector pos, entity owner, entity projectile )
{
	if ( !IsLandingPositionValid( pos, owner, projectile.GetRealms(), projectile ) )
	 {
		 string ownerName = IsValid( owner ) ? owner.GetPlayerName() : "NULL"
		 printt(  "TRANSLOCATION:(" + ownerName + ") Landing into invalid triggers @ " + pos )
		 return false
	 }
	return true
}
#endif

#if SERVER || CLIENT
bool function IsPlayerTranslocationPermitted( entity player )
{
	//if ( IsValid( player.GetParent() ) && !player.IsPlayerInAnyVehicle() )
	//	return false

	if ( IsPlayingFirstPersonAnimation( player ) )
		return false

	if ( IsPlayingFirstAndThirdPersonAnimation( player ) )
		return false

	if ( player.IsPhaseShifted() )
		return false

	if ( Bleedout_IsBleedingOut( player ) )
		return false

	bool allowDeployWhileZiplining = GetLobaTacticalAllowDeployWhileZiplining()
	bool allowZiplineWhileDeployed = GetLobaTacticalAllowZiplineWhileDeployed()
	bool isZiplining               = player.ContextAction_IsZipline()

	if ( IsBitFlagSet( player.GetWeaponDisableFlags(), WEAPON_DISABLE_FLAGS_MAIN ) )
	{
		if ( allowZiplineWhileDeployed && isZiplining )
		{
			// Hopping on a zipline temporarily disables the player's offhand weapons.
			// (dw): Feels weird to not check weapon disabling at all in this branch... but it's a problem with ziplines really.
		}
		else
		{
			return false
		}
	}

	if ( player.ContextAction_IsActive() )
	{
		if ( (allowDeployWhileZiplining || allowZiplineWhileDeployed) && isZiplining )
		{
			// (dw): Instead of blindly ignoring all context actions while the player is zipling, we should check "is
			// the player doing a context action other than ziplining?" but it's not easy, so oh well...
		}
		else
		{
			return false
		}
	}

	if ( player.ContextAction_IsMeleeExecution() || player.ContextAction_IsMeleeExecutionTarget() )
		return false

	return true
}
#endif


#if SERVER
void function WarpBeamFXThread( entity player, vector startPos, vector endPos )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "Translocation_StopWarpBeamFX" )

	entity controlPoint = CreateEntity( "info_placement_helper" )
	SetTargetName( controlPoint, UniqueString( "translocation_endPos" ) )
	controlPoint.SetOrigin( endPos )
	DispatchSpawn( controlPoint )

	entity beamFX = CreateEntity( "info_particle_system" )
	beamFX.RemoveFromAllRealms()
	beamFX.AddToOtherEntitysRealms( player )
	beamFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	beamFX.SetValueForEffectNameKey( TRANSLOCATION_WARP_BEAM_FX )
	beamFX.kv.cpoint1 = controlPoint.GetTargetName()
	beamFX.kv.start_active = 1
	beamFX.SetOrigin( startPos )
	DispatchSpawn( beamFX )

	OnThreadEnd( function () : ( beamFX, controlPoint ) {
		if ( IsValid( beamFX ) )
			beamFX.Destroy()

		if ( IsValid( controlPoint ) )
			controlPoint.Destroy()
	} )

	wait 2.0
}
#endif


#if SERVER || CLIENT
void function DropToGroundFXThread( entity player, entity existingProjectile, entity predictedRedirectedProjectile, vector currentProjectilePos )
{

}
#endif


#if CLIENT
void function StartVisualEffect( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() || (GetLocalViewPlayer() == GetLocalClientPlayer() && !actuallyChanged) )
		return

	thread (void function() : ( player, statusEffect ) {
		EndSignal( player, "OnDeath" )
		EndSignal( player, "Translocation_StopVisualEffect" )

		int fxHandle = StartParticleEffectOnEntityWithPos( player,
			GetParticleSystemIndex( TRANSLOCATION_WARP_SCREEN_FX ),
			FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, player.EyePosition(), <0, 0, 0> )

		EffectSetIsWithCockpit( fxHandle, true )

		OnThreadEnd( function() : ( fxHandle ) {
			CleanupFXHandle( fxHandle, false, true )
		} )

		while( true )
		{
			if ( !EffectDoesExist( fxHandle ) )
				break

			float severity = StatusEffect_GetSeverity( player, statusEffect )
			//DebugDrawScreenText( 0.47, 0.68, "severity: " + severity )
			EffectSetControlPointVector( fxHandle, 1, <severity, 999, 0> )

			WaitFrame()
		}
	})()
}
#endif


#if SERVER || CLIENT
entity function GetCurrentTranslocationProjectile( entity owner, entity weapon )
{
	#if SERVER
		if ( IsValid( weapon.w.translocate_redirectedProjectile ) )
		{
			Assert( !IsValid( weapon.w.translocate_initialProjectile ) )
			return weapon.w.translocate_redirectedProjectile
		}
		else if ( IsValid( weapon.w.translocate_initialProjectile ) )
		{
			Assert( !IsValid( weapon.w.translocate_redirectedProjectile ) )
			return weapon.w.translocate_initialProjectile
		}
	#elseif CLIENT
		if ( IsValid( weapon.w.translocate_predictedRedirectedProjectile ) )
		{
			return weapon.w.translocate_predictedRedirectedProjectile
		}
		else if ( IsValid( weapon.w.translocate_predictedInitialProjectile ) )
		{
			return weapon.w.translocate_predictedInitialProjectile
		}
		else
		{
			entity serverProjectile = owner.GetPlayerNetEnt( "Translocation_ActiveProjectile" )
			if ( IsValid( serverProjectile ) )
				return serverProjectile
		}
	#endif

	return null
}
#endif


#if CLIENT
                    
void function CancelTeleport( entity player )
{
	entity offhandWeapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )
	if( !IsValid( offhandWeapon ) )
		return
	if( !IsValid( GetCurrentTranslocationProjectile( player, offhandWeapon ) ) )
		return

	if( !file.canceledTeleports.contains( player ) )
		file.canceledTeleports.append( player )

	if( !PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_TWO ) ) // loba_upgrade_teleport_cancel
		return

	Remote_ServerCallFunction( "ClientToServer_Translocation_Cancel" )
}
      

void function StopVisualEffect( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() || (GetLocalViewPlayer() == GetLocalClientPlayer() && !actuallyChanged) )
		return

	player.Signal( "Translocation_StopVisualEffect" )
}
#endif


#if SERVER || CLIENT
float function GetLobaTacticalEstimatedMaxDistance( entity owner )
{
	float result = RUI_MAX_RANGE
	                    
	if ( UpgradeCore_IsEnabled() && PlayerHasPassive( owner, ePassives.PAS_TAC_UPGRADE_ONE ) )
	{
		result += RUI_MAX_RANGE_UPGRADED_AMOUNT
		return GetCurrentPlaylistVarFloat( "loba_tactical_upgraded_estimated_max_distance", result )
	}
       
	return GetCurrentPlaylistVarFloat( "loba_tactical_estimated_max_distance", result )
}
#endif


#if SERVER || CLIENT
bool function GetLobaTacticalAllowDropToGround()
{
	return GetCurrentPlaylistVarBool( "loba_tactical_allow_drop_to_ground", true )
}
#endif


#if SERVER || CLIENT
bool function GetLobaTacticalAllowMantle()
{
	return GetCurrentPlaylistVarBool( "loba_tactical_allow_mantle", true )
}
#endif


#if SERVER || CLIENT
bool function GetLobaTacticalAllowZiplineWhileDeployed()
{
	return GetCurrentPlaylistVarBool( "loba_tactical_allow_zipline_while_deployed", false )
}
#endif


#if SERVER || CLIENT
bool function GetLobaTacticalAllowDeployWhileZiplining()
{
	return GetCurrentPlaylistVarBool( "loba_tactical_allow_deploy_while_ziplining", true )
}
#endif 