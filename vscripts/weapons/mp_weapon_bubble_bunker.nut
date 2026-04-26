global function MpWeaponBubbleBunker_Init

global function OnWeaponTossReleaseAnimEvent_WeaponBubbleBunker
global function OnWeaponTossPrep_WeaponBubbleBunker






/*#if CLIENT
global function GetBubbleBunkerRui //commenting out incase we want to bring it back
#endif*/
global function GibraltarIsInDome
global function InDomeShield

global const string GIBRALTAR_DOME_SCRIPTNAME = "gibraltar_dome_shield"
global const string BUBBLE_BUNKER_MOVER_SCRIPTNAME = "Gibraltar_BubbleShield_mover"
global const string BUBBLE_BUNKER_WEAPON_NAME = "mp_weapon_bubble_bunker"

const float BUBBLE_BUNKER_DEPLOY_DELAY = 1.0
const float BUBBLE_BUNKER_DURATION_WARNING = 5.0

const bool BUBBLE_BUNKER_DAMAGE_ENEMIES = false

const float BUBBLE_BUNKER_ANGLE_LIMIT = 0.55






const asset BUBBLE_BUNKER_BEAM_FX = $"P_wpn_BBunker_beam"
const asset BUBBLE_BUNKER_BEAM_END_FX = $"P_wpn_BBunker_beam_end"
const asset BUBBLE_BUNKER_SHIELD_FX = $"P_wpn_BBunker_shield"
const asset BUBBLE_BUNKER_SHIELD_COLLISION_MODEL = $"mdl/fx/bb_shield.rmdl"
const asset BUBBLE_BUNKER_SHIELD_PROJECTILE = $"mdl/props/gibraltar_bubbleshield/gibraltar_bubbleshield.rmdl"







const asset BUBBLE_BUNKER_SHIELD_COLLISION_MODEL_SMALL = $"mdl/fx/bb_shield_small.rmdl"
const asset BUBBLESHIELD_FX_ASSET_SMALL = $"P_wpn_BBunker_shield_small"
const asset BUBBLE_BUNKER_SMALL_BEAM_FX = $"P_wpn_BBunker_beam_small"
const asset BUBBLE_BUNKER_SMALL_BEAM_END_FX = $"P_wpn_BBunker_beam_small_end"
const string BUBBLE_BUNKER_SOUND_ENDING_UPGRADE = "Gibraltar_BabyBubbleShield_LegendUpgrade_Ending"
const string BUBBLE_BUNKER_SOUND_FINISH_UPGRADE = "Gibraltar_BabyBubbleShield_LegendUpgrade_Deactivate"


const string BUBBLE_BUNKER_SOUND_ENDING = "Gibraltar_BubbleShield_Ending"
const string BUBBLE_BUNKER_SOUND_FINISH = "Gibraltar_BubbleShield_Deactivate"

const BUBBLE_BUNKER_THROW_POWER = 800.0
const BUBBLE_BUNKER_RADIUS = 240 //Controls the trigger size but not the dome size

/*struct
{
	#if CLIENT
	var bubbleBunkerRui //commenting out incase we want to bring it back
	#endif
} file*/


















void function MpWeaponBubbleBunker_Init()
{
	PrecacheParticleSystem( BUBBLE_BUNKER_BEAM_END_FX )
	PrecacheParticleSystem( BUBBLE_BUNKER_BEAM_FX )
	PrecacheParticleSystem( BUBBLE_BUNKER_SHIELD_FX )
	PrecacheModel( BUBBLE_BUNKER_SHIELD_COLLISION_MODEL )
	PrecacheModel( BUBBLE_BUNKER_SHIELD_PROJECTILE )

	PrecacheScriptString( GIBRALTAR_DOME_SCRIPTNAME )
	PrecacheScriptString( BUBBLE_BUNKER_MOVER_SCRIPTNAME )







		PrecacheParticleSystem( BUBBLESHIELD_FX_ASSET_SMALL )
		PrecacheParticleSystem( BUBBLE_BUNKER_SMALL_BEAM_FX )
		PrecacheParticleSystem( BUBBLE_BUNKER_SMALL_BEAM_END_FX )
		PrecacheModel( BUBBLE_BUNKER_SHIELD_COLLISION_MODEL_SMALL )


	#if SERVER
	//RegisterSignal( "ActivateArcTrap" )
	RegisterSignal( "DeployBubbleBunker" )
	RegisterSignal( "ProjectileShutdown")



	#else
	//StatusEffect_RegisterEnabledCallback( eStatusEffect.bubble_bunker, BubbleBunker_EnterDome ) //commenting out incase we want to bring it back
	//StatusEffect_RegisterDisabledCallback( eStatusEffect.bubble_bunker, BubbleBunker_ExitDome )
	#endif





}



























float function BubbleBunker_BaseScaler()
{
	return GetCurrentPlaylistVarFloat( "passive_upgrade_gibraltar_bunker_throw_base_scaler", 1.0 )
}

float function BubbleBunker_UpgradedScaler()
{
	return GetCurrentPlaylistVarFloat( "passive_upgrade_gibraltar_bunker_throw_upgraded_scaler", 1.1 )
}


float function BubbleBunker_GetThrowPower( entity player )
{
	float result = BUBBLE_BUNKER_THROW_POWER


	if( UpgradeCore_IsEnabled() )
	{
		result *= BubbleBunker_BaseScaler()
		if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_THREE ) ) // upgrade_gibralter_tac_throw_range
		{
			result *= BubbleBunker_UpgradedScaler()
		}
	}


	return result
}

var function OnWeaponTossReleaseAnimEvent_WeaponBubbleBunker( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	int ammoReq = weapon.GetAmmoPerShot()
	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )

	entity deployable = ThrowDeployable( weapon, attackParams, BubbleBunker_GetThrowPower( weapon.GetOwner() ), OnBubbleBunkerPlanted, null, null )
	if ( deployable )
	{
		entity player = weapon.GetWeaponOwner()
		PlayerUsedOffhand( player, weapon, true, deployable )

		#if SERVER
			deployable.proj.refundAmount = ammoReq
			deployable.e.isDoorBlocker = true

			string projectileSound = GetGrenadeProjectileSound( weapon )
			if ( projectileSound != "" )
				EmitSoundOnEntity( deployable, projectileSound )

			weapon.w.lastProjectileFired = deployable

			PlayBattleChatterLineToSpeakerAndTeam( player, "bc_tactical" )
		#endif

	}

	return ammoReq
}

void function OnWeaponTossPrep_WeaponBubbleBunker( entity weapon, WeaponTossPrepParams prepParams )
{
	weapon.EmitWeaponSound_1p3p( GetGrenadeDeploySound_1p( weapon ), GetGrenadeDeploySound_3p( weapon ) )
}

void function OnBubbleBunkerPlanted( entity projectile, DeployableCollisionParams collisionParams )
{
	#if SERVER
		Assert( IsValid( projectile ) )

		entity owner = projectile.GetOwner()
		if ( !IsValid( owner ) )
		{
			projectile.Destroy()
			return
		}

		vector origin = projectile.GetOrigin()

		vector endOrigin = origin - <0,0,32>
		vector up = AnglesToUp( projectile.GetAngles() )
		vector start = projectile.GetOrigin() + (up*16)
		vector surfaceAngles = projectile.proj.savedAngles
		vector oldUpDir = AnglesToUp( surfaceAngles )

		TraceResults traceResult = TraceLine( start, endOrigin, [ projectile ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS_AND_PHYSICS )
		if ( traceResult.fraction < 1.0 )
		{
			vector forward = AnglesToForward( projectile.proj.savedAngles )
			surfaceAngles = AnglesOnSurface( traceResult.surfaceNormal, forward )

			vector newUpDir = AnglesToUp( surfaceAngles )
			if ( DotProduct( newUpDir, oldUpDir ) < BUBBLE_BUNKER_ANGLE_LIMIT )
				surfaceAngles = projectile.proj.savedAngles
		}

		entity oldParent = projectile.GetParent()
		projectile.ClearParent()

		origin = projectile.GetOrigin()
		asset model = BUBBLE_BUNKER_SHIELD_PROJECTILE// projectile.GetModelName()
		float duration = projectile.GetProjectileWeaponSettingFloat( eWeaponVar.fire_duration )

		int solidType = SOLID_NONE





		entity newProjectile = CreatePropDynamic( model, origin, surfaceAngles, solidType )
		newProjectile.RemoveFromAllRealms()
		newProjectile.AddToOtherEntitysRealms( projectile )
		newProjectile.SetBlocksLOS( false )
		newProjectile.SetScriptName( GIBRALTAR_DOME_SCRIPTNAME )





		projectile.Destroy()

		newProjectile.SetOwner( owner )

		thread TrapDestroyOnRoundEnd( owner, newProjectile )

		if ( IsValid( traceResult.hitEnt ) && EntityShouldStick( projectile, traceResult.hitEnt ) )
			newProjectile.SetParent( traceResult.hitEnt )
		else if ( IsValid( oldParent ) )
			newProjectile.SetParent( oldParent )

		thread DeployBubbleBunker( newProjectile, duration )


		//if ( EntIsHoverVehicle( oldParent ) )
		//	HoverVehicle_ReplaceAbilityAttachmentEntity( newProjectile, projectile, oldParent )


	#endif
}

#if SERVER



























































void function DeployBubbleBunker( entity projectile, float duration )
{
	projectile.EndSignal( "OnDestroy" )

	entity owner = projectile.GetOwner()

	if ( !IsValid( owner ) )
	{
		projectile.Destroy()
		return
	}
	int team = owner.GetTeam()

	entity wp = CreateWaypoint_Ping_Location( owner, ePingType.ABILITY_DOMESHIELD, projectile, projectile.GetOrigin(), -1, false )
	if ( IsValid( wp ) )
	{
		wp.SetAbsOrigin( projectile.GetOrigin() + <0, 0, 35> )
		wp.SetParent( projectile )
	}

	SetTeam( projectile, team )

	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_BUBBLE_BUNKER, owner, projectile.GetOrigin(), owner.GetTeam(), owner )

	projectile.Anim_PlayOnly( "prop_bubbleshield_deploy" )
	WaittillAnimDone( projectile )

	thread BubbleShieldIdleAnims( projectile )

	int startAttachID = projectile.LookupAttachment( "fx_beam" )
	vector beamFXOrigin = projectile.GetAttachmentOrigin( startAttachID )

	owner.Signal( "DeployBubbleBunker" )

	owner.EndSignal( "OnDestroy" )

	FiringRange_AddToPermanentDeployableQuota( projectile, owner )

	OnThreadEnd(
		function() : ( projectile, wp )
		{
			if ( IsValid( projectile ) )
			{
				thread ProjectileShutdown( projectile )
			}

			if ( IsValid( wp ) )
			{
				wp.Destroy()
			}
		}
	)

	FriendlyEnemyFXStruct effects

	if( PlayerHasPassive( owner, ePassives.PAS_TAC_UPGRADE_TWO ) ) // upgrade_gibraltar_smaller_bubble
		effects = CreateFriendlyEnemyFX( projectile, BUBBLE_BUNKER_SMALL_BEAM_FX, beamFXOrigin, <-90,0,0>, team )
	else

		effects = CreateFriendlyEnemyFX( projectile, BUBBLE_BUNKER_BEAM_FX, beamFXOrigin, <-90,0,0>, team)

	waitthread CreateBubbleShieldAroundProjectile( projectile, team, duration, effects )
}



void function BubbleShieldIdleAnims( entity projectile )
{
	projectile.EndSignal( "OnDestroy" )

	projectile.Anim_PlayOnly( "prop_bubbleshield_deploy_trans" )
	WaittillAnimDone( projectile )
	projectile.Anim_PlayOnly( "prop_bubbleshield_deploy_idle" )
}











































































































































void function CreateBubbleShieldAroundProjectile( entity projectile, int team, float duration,  FriendlyEnemyFXStruct oldEffects )
{
	projectile.EndSignal( "OnDestroy" )
	projectile.EndSignal( "EMP_Destroy" )




	entity owner = projectile.GetOwner()

	if ( !IsValid( owner ) )
		return

	EndThreadOn_PlayerCleanupPermanents( owner )
	entity bubbleShield = null






























		if( PlayerHasPassive( owner, ePassives.PAS_TAC_UPGRADE_TWO ) ) // upgrade_gibraltar_smaller_bubble
		{
			// todo a real fx person should prob remake this effect
			bubbleShield = CreateBubbleShieldWithSettings( owner.GetTeam(), projectile.GetOrigin(), <0, 0, 0>, owner, duration, BUBBLE_BUNKER_DAMAGE_ENEMIES, BUBBLESHIELD_FX_ASSET_SMALL, BUBBLE_BUNKER_SHIELD_COLLISION_MODEL_SMALL )
		}
		else

		{
			bubbleShield = CreateBubbleShieldWithSettings( owner.GetTeam(), projectile.GetOrigin(), <0, 0, 0>, owner, duration, BUBBLE_BUNKER_DAMAGE_ENEMIES, BUBBLE_BUNKER_SHIELD_FX, BUBBLE_BUNKER_SHIELD_COLLISION_MODEL )
		}




	bubbleShield.RemoveFromAllRealms()
	bubbleShield.AddToOtherEntitysRealms( projectile )

	bubbleShield.SetParent( projectile, "", true )
	bubbleShield.SetCollisionDetailHigh()

	thread CreateDomeTrigger( projectile )

	AddEMPDestroyDevice( projectile )

	AddWreckingBallEMPDestroyDevice( projectile )
	AddWreckingBallEMPDestroyDevice( bubbleShield )
	bubbleShield.EndSignal( "EMP_Destroy" )

	//Make bubble shield obstruct wattson wirelines in real time.
	TeslaTrap_MakeEntityRealTimeObstructor( bubbleShield )


	AddEntityCallback_OnPostDamaged( bubbleShield, void function( entity bubbleShield, var damageInfo ) : ( owner ) {
		if ( IsValid( owner ) )
			StatsHook_BubbleShield_OnDamageAbsorbed( owner, damageInfo )
	})


	OnThreadEnd(
		function() : ( oldEffects, bubbleShield )
		{

			if ( IsValid( oldEffects.friendlyColoredFX ) )
				EffectStop( oldEffects.friendlyColoredFX )
			if ( IsValid( oldEffects.enemyColoredFX ) )
				EffectStop( oldEffects.enemyColoredFX )
			if ( IsValid( bubbleShield ) )
				DestroyBubbleShield( bubbleShield )
		}
	)











	//Wait until we are getting close to ending the shield
	wait duration - BUBBLE_BUNKER_DURATION_WARNING

	if ( IsValid( oldEffects.friendlyColoredFX ) )
		EffectStop( oldEffects.friendlyColoredFX )
	if ( IsValid( oldEffects.enemyColoredFX ) )
		EffectStop( oldEffects.enemyColoredFX )

	int startAttachID = projectile.LookupAttachment( "fx_beam" )
	vector beamFXOrigin = projectile.GetAttachmentOrigin( startAttachID )

	FriendlyEnemyFXStruct effects

	if( PlayerHasPassive( owner, ePassives.PAS_TAC_UPGRADE_TWO ) ) // upgrade_gibraltar_smaller_bubble
		effects = CreateFriendlyEnemyFX( projectile, BUBBLE_BUNKER_SMALL_BEAM_END_FX, beamFXOrigin, <-90,0,0>, team )
	else

		effects = CreateFriendlyEnemyFX( projectile, BUBBLE_BUNKER_BEAM_END_FX, beamFXOrigin, <-90,0,0>, team)

	OnThreadEnd(
		function() : ( effects, projectile )
		{
			if ( IsValid( effects.friendlyColoredFX ) )
				EffectStop( effects.friendlyColoredFX )
			if ( IsValid( effects.enemyColoredFX ) )
				EffectStop( effects.enemyColoredFX )

			if ( IsValid( projectile ) )
			{
				StopSoundOnEntity( projectile, BUBBLE_BUNKER_SOUND_ENDING )

					StopSoundOnEntity( projectile, BUBBLE_BUNKER_SOUND_ENDING_UPGRADE )

			}
		}
	)


	if ( PlayerHasPassive( owner, ePassives.PAS_TAC_UPGRADE_TWO ) ) // upgrade_gibraltar_smaller_bubble
		EmitSoundOnEntity( projectile, BUBBLE_BUNKER_SOUND_ENDING_UPGRADE )
	else

		EmitSoundOnEntity( projectile, BUBBLE_BUNKER_SOUND_ENDING )

	//wait rest of shield life duration
	wait BUBBLE_BUNKER_DURATION_WARNING

}

void function ProjectileShutdown( entity projectile )
{
	entity mover = CreateScriptMover( BUBBLE_BUNKER_MOVER_SCRIPTNAME, projectile.GetOrigin(), projectile.GetAngles() )

	entity oldParent = projectile.GetParent()

	if ( IsValid( oldParent ) )
		mover.SetParent( oldParent )

	projectile.SetParent( mover )

	projectile.EndSignal( "OnDestroy" )
	projectile.Signal( "ProjectileShutdown")

	OnThreadEnd(
		function() : ( mover )
		{
			if ( IsValid( mover ) )
				mover.Destroy()
		}
	)


	entity owner = projectile.GetOwner()

	if ( !IsValid( owner ) )
		return

	if ( PlayerHasPassive( owner, ePassives.PAS_TAC_UPGRADE_TWO ) ) // upgrade_gibraltar_smaller_bubble
		EmitSoundOnEntity( projectile, BUBBLE_BUNKER_SOUND_FINISH_UPGRADE )
	else

		EmitSoundOnEntity( projectile, BUBBLE_BUNKER_SOUND_FINISH )

	waitthread PlayAnim( projectile, "prop_bubbleshield_shutdown", mover )
	projectile.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 500 )
	WaitSignal( projectile, "OnDestroy" )
}

void function CreateDomeTrigger( entity projectile )
{
	projectile.EndSignal( "OnDestroy")
	projectile.EndSignal( "ProjectileShutdown")

	int aboveHeight = BUBBLE_BUNKER_RADIUS
	int belowHeight = 0

	entity trigger = CreateTriggerCylinder( projectile.GetOrigin(), BUBBLE_BUNKER_RADIUS, aboveHeight, belowHeight )
	trigger.RemoveFromAllRealms()
	trigger.AddToOtherEntitysRealms( projectile )
	trigger.SetOwner( projectile.GetOwner() )

	trigger.SetEnterCallback( DomeTriggerEnter )
	trigger.SearchForNewTouchingEntity()
	trigger.SetParent( projectile )

	EndSignal( trigger, "OnDestroy" )

	OnThreadEnd(
		function () : ( trigger )
		{
			if ( IsValid( trigger ) )
				trigger.Destroy()
		}
	)

	WaitForever()
}

void function DomeTriggerEnter( entity trigger, entity ent )
{
	if ( ent.IsPlayer() )
		thread DomeTriggerTouchingThread( trigger, ent )
}

void function DomeTriggerTouchingThread( entity trigger, entity ent )
{
	EndSignal( ent, "OnDestroy" )
	EndSignal( ent, "OnDeath" )
	EndSignal( trigger, "OnDestroy" )

	OnThreadEnd(
		function() : ( ent )
		{
			if ( IsValid( ent ) )
			{
				if ( ent.p.bubbleBunkerStatusEffectId != -1 )
				{
					StatusEffect_Stop( ent, ent.p.bubbleBunkerStatusEffectId )
					ent.p.bubbleBunkerStatusEffectId = -1
				}
			}
		}
	)

	while( trigger.IsTouching( ent ) )
	{
		bool inRange = Distance( trigger.GetOrigin(), ent.GetOrigin() ) <= BUBBLE_BUNKER_RADIUS
		if ( inRange )
		{
			if ( ent.p.bubbleBunkerStatusEffectId == -1 )
				ent.p.bubbleBunkerStatusEffectId = StatusEffect_AddEndless( ent, eStatusEffect.bubble_bunker, 1.0 )
		}
		else
		{
			StatusEffect_Stop( ent, ent.p.bubbleBunkerStatusEffectId )
			ent.p.bubbleBunkerStatusEffectId = -1
		}

		WaitFrame()
	}

	if ( ent.p.bubbleBunkerStatusEffectId != -1 )
	{
		StatusEffect_Stop( ent, ent.p.bubbleBunkerStatusEffectId )
		ent.p.bubbleBunkerStatusEffectId = -1
	}
}

#endif //server

//commenting out incase we want to bring it back
/*#if CLIENT
void function BubbleBunker_EnterDome( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return

	file.bubbleBunkerRui = CreateCockpitRui( $"ui/bubble_bunker.rpak", HUD_Z_BASE )
	RuiTrackFloat( file.bubbleBunkerRui, "bleedoutEndTime", player, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "bleedoutEndTime" ) )
	RuiTrackFloat( file.bubbleBunkerRui, "reviveEndTime", player, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "reviveEndTime" ) )
}

void function BubbleBunker_ExitDome( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return

	RuiDestroyIfAlive( file.bubbleBunkerRui )
	file.bubbleBunkerRui = null
}

var function GetBubbleBunkerRui()
{
	return file.bubbleBunkerRui
}
#endif //client*/


bool function GibraltarIsInDome( entity player )
{
	if ( !PlayerHasPassive( player, ePassives.PAS_ADS_SHIELD ) )
		return false

	return InDomeShield( player )
}

bool function InDomeShield( entity player )
{
	return StatusEffect_HasSeverity( player, eStatusEffect.bubble_bunker )
}