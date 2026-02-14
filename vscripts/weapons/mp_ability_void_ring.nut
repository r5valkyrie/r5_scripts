global function VOID_RING_Init

global function OnWeaponActivate_void_ring
global function OnWeaponDeactivate_void_ring
global function OnWeaponReadyToFire_void_ring

global function OnWeaponTossPrep_void_ring
global function OnWeaponTossReleaseAnimEvent_void_ring
global function OnWeaponAttemptOffhandSwitch_void_ring

#if CLIENT
global function ServerToClient_VoidRingHintDetection
global function ServerToClient_VoidRingHintCancelDetection
global function ServerToClient_VoidRingHPToClient
global function ServerToClient_VoidRingStateToClient
#endif

////////////////////////////
//Variable Definitions
///////////////////////////
global const string VOID_RING_PROP_SCRIPTNAME = "void_ring"
global const string VOID_RING_WEAPON_REF = "mp_ability_void_ring"
const string VOID_RING_MOVER_SCRIPTNAME = "void_ring_mover"
global const float DEATHFIELD_DAMAGE_CHECK_STEP_TIME = 1.5

const bool DEBUG_ACTIVE_RING_TEST = false 			//Use to allow Debug Variables AND sets VR Active when inside
const int DEBUG_RING_STAGE = 3
const int DEBUG_NUM_STAGES = 6						//Current Deathfield now has 6 Stages (instead of 9)
const float DEBUG_RING_DMG_SCALAR = 1 				//Multiplies the amount Damage Dealt to Void Ring per tick (Used for Debug tests for Ring Stage DMG)

const float VOID_RING_DEPLOY_DELAY = 1.0
const float VOID_RING_DURATION = 45.0
const float VOID_RING_DURATION_WARNING = 5.0
const float VOID_RING_ANGLE_LIMIT = 0.55
const float VOID_RING_PLANT_START_TRACE_OFFSET = 32 //Used when finding surface to plant Void Ring
const float VOID_RING_PLANT_END_TRACE_DISTANCE = 64 //Used when finding surface to plant Void Ring
const float VOID_RING_WAYPOINT_LOCAL_OFFSET = 30
const float VOID_RING_WAYPOINT_POI_OFFSET_Z = 10
const float VOID_RING_WAYPOINT_WP_OFFSET_Z = 5
const float VOID_RING_BEAM_ATTACHMENT_LOCAL_OFFSET = 26
const vector VOID_RING_INVALID_PLACEMENT_MIN_AREA = <-15,-15,-50>
const vector VOID_RING_INVALID_PLACEMENT_MAX_AREA = <15,15,50>

const float VOID_RING_THROW_BACKSPIN = -600
const int VOID_RING_RADIUS = 300 							//Initial Dome Size (260)
const int VOID_RING_VISUAL_RADIUS_OFFSET = 20 				//Size Offset to match the Visual Dome actual size and account for character collision
const int VOID_RING_AR_RADIUS_OFFSET = 15 					//AR Ring when given Void Ring Radius appears larger than the actual dome by ~15 units. //todo: Replace later if FX lines up more accurately when replaced.
const int VOID_RING_MIN_RADIUS = 120 						//Smallest Size the Dome is allowed to go during decay (65)
const int VOID_RING_BELOW_RANGE = 2500 						//Range of additional coverage below the Trigger Origin (for stairs and slopes) (25)
const int VOID_RING_NORMAL_WARNING_PULSE_COUNT 		= 2 	//Number of Warning Pulses used before destruction when HP < 0
const int VOID_RING_FINAL_CIRCLE_WARNING_PULSE_COUNT= 0		//Number of Warning Pulses used before destruction when HP < 0 in the final circle
const float VOID_RING_EXPAND_TIME = 0.4 					//Time it takes for Void Ring to Expand to max Radius
const float VOID_RING_WP_HP_DRAW_DIST_MIN = 350 			//Min Visible Distance for the Void Ring HP Waypoint
const float VOID_RING_WP_HP_DRAW_DIST_MAX = 2500 			//Max Visible Distance for the Void Ring HP Waypoint

const float VOID_RING_HEALTH = 100.0
const float VOID_RING_MAX_HEALTH = 100.0

const bool VOID_RING_FAST_HEAL = false

//Models & VFX
const asset VOID_RING_PROJECTILE = $"mdl/props/void_ring/void_ring.rmdl"

const asset VOID_RING_BEAM_FX = $"P_wpn_voidring_beam"
const asset VOID_RING_BEAM_PULSE_FX = $"P_wpn_voidring_dmg_pulse_beam"
const asset VOID_RING_BEAM_WARNING_FX = $"P_wpn_voidring_dmg_warning_beam"
//const asset VOID_RING_BEAM_END_FX = $"P_wpn_voidring_beam_end"
const asset VOID_RING_DESTROY_FX = $"P_wpn_voidring_exp"
const asset VOID_RING_SHIELD_FX = $"P_wpn_voidring_shield"
const asset VOID_RING_HEATWAVE_FX = $"P_wpn_heatwave_shield"
const asset VOID_RING_DMG_PULSE_FX = $"P_wpn_voidring_dmg_pulse"
const asset VOID_RING_HEATWAVE_DMG_PULSE_FX = $"P_wpn_heatwave_dmg_pulse"
const asset VOID_RING_SHIELD_WARNING_FX = $"P_wpn_heatwave_dmg_warning"
const asset VOID_RING_FLARE_SHIELD_FX = $"P_wpn_voidring_fury_shield"
const asset VOID_RING_FLARE_DMG_PULSE_FX = $"P_wpn_voidring_fury_dmg_pulse"
const asset VOID_RING_FLARE_SHIELD_WARNING_FX = $"P_wpn_voidring_fury_dmg_warning"
const asset VOID_RING_POV_WPN_FX = $"P_wpn_voidring_pov"
const asset VOID_RING_3P_WPN_FX = $"P_wpn_voidring_3p"

const vector VOID_RING_COLOR_FX =  < 204, 188, 255>
const vector VOID_RING_WARNING_COLOR_FX =  < 255, 188, 188>

const asset VOID_RING_PREVIEW_RING_FX = $"P_wpn_voidring_preview"
float VR_AR_EFFECT_SIZE = 1.0 //768.0 // coresponds with the size of the sphere model used for the AR effect

//SFX Variables
const string VOID_RING_SOUND_ENDING = "VoidRing_Ending"
const string VOID_RING_SOUND_ENDING_IN_CIRCLE = "VoidRing_Ending_InCircle"
const string VOID_RING_SOUND_SUSTAIN = "VoidRing_Sustain"
const string VOID_RING_SOUND_SUSTAIN_COLUMN = "VoidRing_Sustain_Column"
const string VOID_RING_SOUND_DAMAGE = "VoidRing_Damage"
const string VOID_RING_SOUND_DAMAGE_COLUMN = "VoidRing_Damage_Column"
const string VOID_RING_SOUND_DESTROY = "VoidRing_Destroy"
const string VOID_RING_SOUND_TIMEOUT = "VoidRing_Deactivate"
const string VOID_RING_SOUND_INSIDE = "VoidRing_Inside_1P"
const string VOID_RING_DEACTIVATE_1P_SOUND = "VoidRing_Holster_1P"
const string VOID_RING_DEACTIVATE_3P_SOUND = "VoidRing_Holster_3P"
const string SOUND_DEATHFIELD_START = "Survival_Circle_Enter_3p"
const string SOUND_DEATHFIELD_STOP = "Survival_Circle_Exit_3p"

// Void Ring Damage Ticks - Percentage of Damage Applied to the Void Ring for each tick of the Deathfield
const float VOID_RING_DMG_TICK_R0 = 0.05 // MATCH START (No Ring in play)
const float VOID_RING_DMG_TICK_R1 = 0.05
const float VOID_RING_DMG_TICK_R2 = 0.06
const float VOID_RING_DMG_TICK_R3 = 0.08 // Mid-game - first round where the Void Ring Explodes before 30s
const float VOID_RING_DMG_TICK_R4 = 0.15 // Can REVIVE a teammate && use a PHEONIX KIT
const float VOID_RING_DMG_TICK_R5 = 0.25 // Can REVIVE (+syringe if pre-set) or PHEONIX KIT
const float VOID_RING_DMG_TICK_R6 = 1.00 // Final Ring (Closing)
const float VOID_RING_DMG_TICK_R7 = 1.00 // UNUSED - (previous SURVIVAL RING used to have 8 rounds)
const float VOID_RING_DMG_TICK_R8 = 1.00 // UNUSED

array<float> ringStageVRDamageTable = [

	/* 0 */ VOID_RING_DMG_TICK_R0, // Start (Round 1)
	/* 1 */ VOID_RING_DMG_TICK_R1,
	/* 2 */ VOID_RING_DMG_TICK_R2,
	/* 3 */ VOID_RING_DMG_TICK_R3,
	/* 4 */ VOID_RING_DMG_TICK_R4,
	/* 5 */ VOID_RING_DMG_TICK_R5,
	/* 6 */ VOID_RING_DMG_TICK_R6, // Final Ring (Closing)
	/* 7 */ VOID_RING_DMG_TICK_R7,
	/* 8 */ VOID_RING_DMG_TICK_R8,
]

struct
{
	#if SERVER
	table<entity, int> 				voidringStatusCount = {}
	table<entity, array<entity> > 	playerInVoidRing
	table<entity, bool> 			voidRingInActiveState = {}
	table<entity, bool> 			voidRingInRingFissure = {}
	table<entity, float> 			voidRingHP = {}
	table<entity, float> 			voidRingEndTime = {}
	table<entity, int>				voidRingRadius = {}
	#endif

	#if CLIENT
		var 	voidRingHUDRui
		var 	voidRingHUDStatusRui
		float 	cl_voidHP = 100.0
		bool 	cl_voidActive = false
	#endif
} file


void function VOID_RING_Init()
{
	SURVIVAL_Loot_RegisterConditionalCheck( VOID_RING_WEAPON_REF, VoidRing_ConditionalCheck )
	
	PrecacheModel( VOID_RING_PROJECTILE )
	//PrecacheParticleSystem( VOID_RING_BEAM_END_FX )
	PrecacheParticleSystem( VOID_RING_BEAM_FX )
	PrecacheParticleSystem( VOID_RING_BEAM_PULSE_FX )
	PrecacheParticleSystem( VOID_RING_BEAM_WARNING_FX )
	PrecacheParticleSystem( VOID_RING_SHIELD_FX )
	PrecacheParticleSystem( VOID_RING_DESTROY_FX )
	PrecacheParticleSystem( VOID_RING_PREVIEW_RING_FX )
	PrecacheParticleSystem( VOID_RING_DMG_PULSE_FX )
	PrecacheParticleSystem( VOID_RING_SHIELD_WARNING_FX )
	PrecacheParticleSystem( VOID_RING_FLARE_SHIELD_FX )
	PrecacheParticleSystem( VOID_RING_FLARE_DMG_PULSE_FX )
	PrecacheParticleSystem( VOID_RING_FLARE_SHIELD_WARNING_FX )
	PrecacheParticleSystem( VOID_RING_POV_WPN_FX )
	PrecacheParticleSystem( VOID_RING_3P_WPN_FX )

	PrecacheParticleSystem( VOID_RING_HEATWAVE_FX )
	PrecacheParticleSystem( VOID_RING_HEATWAVE_DMG_PULSE_FX )

	Remote_RegisterClientFunction( "ServerToClient_VoidRingHintDetection", "entity" )
	Remote_RegisterClientFunction( "ServerToClient_VoidRingHintCancelDetection", "entity" )
	Remote_RegisterClientFunction( "ServerToClient_VoidRingHPToClient", "entity", "float", 0.0, 500.0, 16 ) //float needs to be followed by min/max/bit
	Remote_RegisterClientFunction( "ServerToClient_VoidRingStateToClient", "entity", "bool" )

	ringStageVRDamageTable[0] = GetCurrentPlaylistVarFloat( "heatshield_dmgTickPercent_ring0", VOID_RING_DMG_TICK_R0 )
	ringStageVRDamageTable[1] = GetCurrentPlaylistVarFloat( "heatshield_dmgTickPercent_ring1", VOID_RING_DMG_TICK_R1 )
	ringStageVRDamageTable[2] = GetCurrentPlaylistVarFloat( "heatshield_dmgTickPercent_ring2", VOID_RING_DMG_TICK_R2 )
	ringStageVRDamageTable[3] = GetCurrentPlaylistVarFloat( "heatshield_dmgTickPercent_ring3", VOID_RING_DMG_TICK_R3 )
	ringStageVRDamageTable[4] = GetCurrentPlaylistVarFloat( "heatshield_dmgTickPercent_ring4", VOID_RING_DMG_TICK_R4 )
	ringStageVRDamageTable[5] = GetCurrentPlaylistVarFloat( "heatshield_dmgTickPercent_ring5", VOID_RING_DMG_TICK_R5 )
	ringStageVRDamageTable[6] = GetCurrentPlaylistVarFloat( "heatshield_dmgTickPercent_ring6", VOID_RING_DMG_TICK_R6 )
	ringStageVRDamageTable[7] = GetCurrentPlaylistVarFloat( "heatshield_dmgTickPercent_ring7", VOID_RING_DMG_TICK_R7 )
	ringStageVRDamageTable[8] = GetCurrentPlaylistVarFloat( "heatshield_dmgTickPercent_ring8", VOID_RING_DMG_TICK_R8 )

	#if SERVER
		RegisterSignal( "DeployVoidRing" )
		RegisterSignal( "ProjectileShutdown")
		RegisterSignal( "VoidRingShutdown")
		RegisterSignal( "VoidRing_WeaponEnd" )

		AddCallback_OnPlayerInventoryChanged(VoidRing_HintCheck)
	#endif

	#if CLIENT
		StatusEffect_RegisterEnabledCallback( eStatusEffect.in_void_ring, VoidRing_EnterDome )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.in_void_ring, VoidRing_ExitDome )
		RegisterSignal( "VoidRingEquipped" )
		RegisterSignal( "VoidRing_EndPreview" )
		RegisterSignal( "VoidRing_DestroyHUD" )
		//AddCreateCallback( PLAYER_WAYPOINT_CLASSNAME, OnWaypointCreated )

	#endif
}

bool function VoidRing_ConditionalCheck( string ref, entity player )
{
	// Void ring is always available unless restricted by specific playlist logic
	// Returns true to allow void ring to be equipped and used
	return true
}

void function OnWeaponActivate_void_ring( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if CLIENT
		if ( !InPrediction() ) //Stopgap fix for Bug 146443
			return

		if ( ownerPlayer == GetLocalViewPlayer() )
		{
			RunUIScript( "CloseSurvivalInventoryMenu" )
		}
	#endif

}

bool function OnWeaponAttemptOffhandSwitch_void_ring( entity weapon )
{
	return true
}

int function VoidRing_GetVoidRingRadius()
{
	return GetCurrentPlaylistVarInt(  "void_ring_radius_overide", VOID_RING_RADIUS )
}


void function OnWeaponReadyToFire_void_ring (entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if SERVER
	//LootData lootData = EquipmentSlot_GetEquippedLootDataForSlot( ownerPlayer, "MAIN_WEAPON0" )
	//if( lootData.ref != VOID_RING_WEAPON_REF )
	//	SwapToLastEquippedPrimary( ownerPlayer )
	#endif

}

void function OnWeaponTossPrep_void_ring( entity weapon, WeaponTossPrepParams prepParams )
{
	weapon.EmitWeaponSound_1p3p( GetGrenadeDeploySound_1p( weapon ), GetGrenadeDeploySound_3p( weapon ) )

	#if SERVER
		entity weaponOwner = weapon.GetWeaponOwner()
		thread ShowVoidRingWeaponFX( weapon )
	#endif

	#if CLIENT //todo: We want to move this to ReadyToFire or OnActivation - but it doesn't consistently work there, or causes other problems.
		if( weapon.GetWeaponOwner() == GetLocalViewPlayer() )
			thread ShowVoidRingRadius( weapon )
	#endif
}

var function OnWeaponTossReleaseAnimEvent_void_ring( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	int ammoReq = weapon.GetAmmoPerShot()
	entity player = weapon.GetWeaponOwner()

	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )

	entity deployable = ThrowDeployable_Retail( weapon, attackParams, 1.0, OnVoidRingPlanted, null,  <0,VOID_RING_THROW_BACKSPIN,0> )
	if ( deployable )
	{
		PlayerUsedOffhand( player, weapon, true, deployable )

		#if SERVER
			deployable.e.isDoorBlocker = true

			string projectileSound = GetGrenadeProjectileSound( weapon )
			if ( projectileSound != "" )
				EmitSoundOnEntity( deployable, projectileSound )

			weapon.w.lastProjectileFired = deployable

		#endif

		#if SERVER
			TryPlayWeaponBattleChatterLine( player, weapon )
			Signal( weapon, "VoidRing_WeaponEnd" )
		#endif

		#if CLIENT
			Signal( weapon, "VoidRing_EndPreview" )
		#endif
	}
	else
	{
		return 0
	}

	return ammoReq
}

void function OnWeaponDeactivate_void_ring( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if SERVER
		//EmitSoundOnEntityExceptToPlayer( ownerPlayer, ownerPlayer, VOID_RING_DEACTIVATE_3P_SOUND )
		Signal( weapon, "VoidRing_WeaponEnd" )
	#endif

	#if CLIENT
		if ( ownerPlayer != GetLocalViewPlayer() )
			return

		//EmitSoundOnEntity( ownerPlayer, VOID_RING_DEACTIVATE_1P_SOUND )
		Signal( weapon, "VoidRing_EndPreview" )
	#endif
}

///////////////////////////////////////
///// VOID RING OBJECT ON GROUND //////
//////////////////////////////////////

void function OnVoidRingPlanted( entity projectile, DeployableCollisionParams collisionParams )
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

		vector endOrigin = origin - <0,0,VOID_RING_PLANT_END_TRACE_DISTANCE>
		vector up = AnglesToUp( projectile.GetAngles() )
		vector start = projectile.GetOrigin() + (up*VOID_RING_PLANT_START_TRACE_OFFSET)
		vector surfaceAngles = projectile.proj.savedAngles
		vector oldUpDir = AnglesToUp( surfaceAngles )

		TraceResults traceResult = TraceLine( start, endOrigin, [ projectile ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS_AND_PHYSICS )
		if ( traceResult.fraction < 1.0 )
		{
			vector forward = AnglesToForward( projectile.proj.savedAngles )
			surfaceAngles = AnglesOnSurface( traceResult.surfaceNormal, forward )

			vector newUpDir = AnglesToUp( surfaceAngles )
			if ( DotProduct( newUpDir, oldUpDir ) < VOID_RING_ANGLE_LIMIT )
				surfaceAngles = projectile.proj.savedAngles
		}

		entity oldParent = projectile.GetParent()
		projectile.ClearParent()

		origin = projectile.GetOrigin()
		asset model = VOID_RING_PROJECTILE

		float heatShieldDuration = GetCurrentPlaylistVarFloat( "heatshield_duration", VOID_RING_DURATION)

		entity newProjectile = CreatePropDynamic( model, origin, surfaceAngles )
		newProjectile.RemoveFromAllRealms()
		newProjectile.AddToOtherEntitysRealms( projectile )

		newProjectile.SetOwner( owner )


		thread TrapDestroyOnRoundEnd( owner, newProjectile )


		//////////Void Ring on Vehicles//////////////
		//Removing temporarily due to a number of issues: R5DEV-227560  | R5DEV-227475 that were deemed too risky to attempt to resolve for 8.1
		//todo: Post 8.1, we need to turn this back on and resolve the above issues along with any other refactors needed to the script

		//Replace this with below once we reactivate Heat Shields on Vehicles
		if ( IsValid( traceResult.hitEnt ) && EntityShouldStick( projectile, traceResult.hitEnt ) )
			newProjectile.SetParent( traceResult.hitEnt )
		else if ( IsValid( oldParent ) )
			newProjectile.SetParent( oldParent )

		//bool isVehicle = false
		//%if HAS_HOVER_VEHICLE
		//	 isVehicle = EntIsHoverVehicle( oldParent )
		//%endif
		//if ( !isVehicle && IsValid( traceResult.hitEnt ) && EntityShouldStick( projectile, traceResult.hitEnt ) ) // Testing against isVehicle in the unlikely but possible case there's a sticky ent our trace hit first
		//{
		//	newProjectile.SetParent( traceResult.hitEnt )
		//}
		//else if ( IsValid( oldParent ) )
		//{
		//	newProjectile.SetParent( oldParent )
		//
		//	%if HAS_HOVER_VEHICLE
		//		if ( isVehicle )
		//		{
		//			newProjectile.SetAbsAngles( <0, 0, 0> )
		//			HoverVehicle_ReplaceAbilityAttachmentEntity( newProjectile, projectile, oldParent )
		//		}
		//	%endif // HAS_HOVER_VEHICLE
		//}

		projectile.Destroy()
		thread DeployVoidRing( newProjectile, heatShieldDuration )

	#endif
}

#if SERVER
void function DeployVoidRing( entity projectile, float duration )
{
	projectile.EndSignal( "OnDestroy" )

	entity owner = projectile.GetOwner()

	if ( !IsValid( owner ) )
	{
		projectile.Destroy()
		return
	}
	int team = owner.GetTeam()

	//TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_LOOT_ABILITY_VOID_RING, owner, projectile.GetOrigin(), owner.GetTeam(), owner )

	entity mover = CreateScriptMover_NEW( VOID_RING_MOVER_SCRIPTNAME + "__deployMover", projectile.GetOrigin(), projectile.GetAngles() )
	entity oldParent = projectile.GetParent()

	if ( IsValid( oldParent ) )
		mover.SetParent( oldParent )

	projectile.SetParent( mover )
	projectile.SetScriptName( VOID_RING_PROP_SCRIPTNAME )
	waitthread PlayAnim( projectile, "prop_void_ring_deploy", mover ) //ANIMATION REPLACEMENT NEEDED
	thread VoidRingIdleAnims( projectile, mover )

	owner.Signal( "DeployVoidRing" )

	owner.EndSignal( "OnDestroy" )
	mover.EndSignal( "OnDestroy" )

	//FiringRange_AddToPermanentDeployableQuota( mover, owner )

	//Add a PING region around Void Ring
	vector pingOrigin = projectile.GetOrigin() + <0,0,25>
	entity traceBlocker = CreateTraceBlockerVolume( pingOrigin, 64.0, false, CONTENTS_BLOCK_PING, team, VOID_RING_PROP_SCRIPTNAME )
	traceBlocker.SetParent( projectile )
	//DebugDrawSphere( pingOrigin, 64, COLOR_BLUE, true, 10 )

	AddEMPDestroyDeviceNoDissolve( projectile )
	AddEntToInvalidEntsForPlacingPermanentsOnto( projectile )
	AddEntityDestroyedCallback( projectile,
		void function( entity ent ) : ( projectile )
		{
			RemoveEntFromInvalidEntsForPlacingPermanentsOnto( ent )
		}
	)
	AddRefEntAreaToInvalidOriginsForPlacingPermanentsOnto( projectile, VOID_RING_INVALID_PLACEMENT_MIN_AREA, VOID_RING_INVALID_PLACEMENT_MAX_AREA )
	AddEntityDestroyedCallback( projectile,
		void function( entity ent ) : ( projectile )
		{
			RemoveRefEntAreaFromInvalidOriginsForPlacingPermanentsOnto( ent )
		}
	)

	OnThreadEnd(
		function() : ( mover, projectile, oldParent, traceBlocker )
		{
			if ( IsValid( projectile ) )
			{
				if ( IsValid( oldParent ) )
					projectile.SetParent( oldParent )
				else
					projectile.ClearParent()

				thread ProjectileShutdown( projectile )
			}

			if ( IsValid(traceBlocker) )
			{
				traceBlocker.Destroy()
			}

			if ( IsValid( mover ) )
			{
				mover.Destroy()
			}
		}
	)

	//Create an Active Thread to handle Lifetime and Dynamic Properties of the Void Ring
	waitthread VoidRingActiveThread(projectile, team, duration )
}

void function VoidRingIdleAnims( entity projectile, entity mover )
{
	projectile.EndSignal( "OnDestroy" )
	mover.EndSignal( "OnDestroy" )

	waitthread PlayAnim( projectile, "prop_void_ring_deploy_trans", mover )
	vector origin = projectile.GetOrigin()
	bool vrActive = false
	bool wasActive = false

	thread PlayAnim( projectile, "prop_void_ring_deploy_idle", mover )

	while ( IsValid( projectile ) )
	{
		if( projectile in file.voidRingInActiveState )
			vrActive = file.voidRingInActiveState[projectile]

		if( projectile in file.voidRingHP )
		{
			float vrHP = file.voidRingHP[projectile]
			if( vrHP > 0 )
			{
				if( wasActive != vrActive  )
				{
					wasActive = vrActive

					if( vrActive )
					{
						thread PlayAnim( projectile, "prop_void_ring_deploy_idle_alt", mover )
					}
					else
						thread PlayAnim( projectile, "prop_void_ring_deploy_idle", mover )
				}
			}
			else
			{
				//todo: Henry replace this anim with the Warning State Version
				thread PlayAnim( projectile, "prop_void_ring_deploy_idle_warning", mover )
				break
			}
		}

		WaitFrame()
	}
}

void function ProjectileShutdown( entity projectile )
{
	entity mover = CreateScriptMover_NEW( VOID_RING_MOVER_SCRIPTNAME + "__proj_shutdownMover", projectile.GetOrigin(), projectile.GetAngles() )

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

	EmitSoundOnEntity( projectile, VOID_RING_SOUND_TIMEOUT )
	waitthread PlayAnim( projectile, "prop_void_ring_shutdown", mover )
	projectile.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 1000 )
	WaitSignal( projectile, "OnDestroy" )
}
///// END OF VOID RING OBJECT ON GROUND //////


///////////////////////////////////////
///// DEATHFIELD & STATE TRACKING /////
///////////////////////////////////////
void function VoidRing_TrackState_Thread( entity projectile )
{
	EndSignal( projectile, "OnDestroy" )
	EndSignal( projectile, "OnDeath" )

	while ( IsValid( projectile ) && projectile in file.voidRingInActiveState )
	{
		vector origin 			= projectile.GetOrigin()
		vector center 			= SURVIVAL_GetDeathFieldCenter( )
		vector flatCenter 		= <center.x, center.y, origin.z>
		vector dirToRingEdge 	= Normalize(origin - flatCenter)
		vector vrEdgePos 		= origin + ( dirToRingEdge * file.voidRingRadius[projectile] )

		DeathFieldData deathFieldData = SURVIVAL_GetDeathFieldData( )

		bool isInRing 		= SURVIVAL_PosInsideDeathField( origin )
		bool isInFissure	= VoidRing_IsInRingFissure( projectile, origin )
		bool isAlwaysActive = false

		isAlwaysActive	= VoidRing_IsInHeatwave( projectile, origin )


		bool isEdgeInRing 	= SURVIVAL_PosInsideDeathField( vrEdgePos )

		if ( projectile in file.voidRingInRingFissure )
		{
			file.voidRingInRingFissure[projectile] <- isInFissure
		}
		//DebugDrawSphere( vrEdgePos, 20, <0, 0, 150>, true, 0.1 )
		// DebugDrawArrow( flatCenter, origin, 8, COLOR_GREEN, true, 0.1 )
		//DebugDrawArrow( origin, vrEdgePos, 8, COLOR_CYAN, true, 0.1 )

		bool voidRingActiveState =   !isInRing || isInFissure || isAlwaysActive || file.playerInVoidRing[projectile].len() > 0  || !isEdgeInRing

		file.voidRingInActiveState[projectile] <- voidRingActiveState

		WaitFrame()
	}
}

bool function VoidRing_IsInRingFissure( entity projectile, vector origin )
{

































	return false
}

bool function VoidRing_IsInHeatwave( entity projectile, vector origin )
{
	//if( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_HEATWAVE ) )
		return false

	//return Heatwave_IsHeatwaveActive()

}


///////////////////////////////////
///// MASTER VOID RING THREAD /////
///////////////////////////////////

void function VoidRingActiveThread( entity projectile, int team, float duration )
{
	EndSignal( projectile, "OnDestroy" )
	EndSignal( projectile, "OnDeath" )

	if ( !IsValid( projectile ) )
		return

	//Variables//
	vector origin = projectile.GetOrigin()
	int vRadius 		 = VoidRing_GetVoidRingRadius()  //Void Ring Area


	float MaxVoidHP      = VOID_RING_MAX_HEALTH
	float voidHP         = VOID_RING_HEALTH
	float DebugDMGScalar = DEBUG_RING_DMG_SCALAR
	int aboveHeight 	 = VoidRing_GetVoidRingRadius()
	int belowHeight 	 = VOID_RING_BELOW_RANGE
	int warnCount 		 = 0 //used to count warning pulses used before destroyed

	file.voidRingEndTime[projectile] <- Time() + ( duration - VOID_RING_DURATION_WARNING ) //preset the endTime
	file.voidRingRadius[projectile] <- vRadius

	int startAttachID 		= projectile.LookupAttachment( "beam_fx" )
	vector beamFXOrigin 	= projectile.GetAttachmentOrigin( startAttachID ) + ( Normalize( projectile.GetUpVector() )  ) //todo:DM Remove temp Offset with final Anim/VFX update
	int effectId 			= GetParticleSystemIndex( VOID_RING_SHIELD_FX )

	//if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_HEATWAVE ) )
		//effectId 			= GetParticleSystemIndex( VOID_RING_HEATWAVE_FX )

	int effectBeamId 		= GetParticleSystemIndex( VOID_RING_BEAM_FX )
	int effectBeamPulseId 	= GetParticleSystemIndex( VOID_RING_BEAM_PULSE_FX )
	int effectBeamWarnId	= GetParticleSystemIndex( VOID_RING_BEAM_WARNING_FX )
	//int effectEndBeamId 	= GetParticleSystemIndex( VOID_RING_BEAM_END_FX )
	int effectDmgId 		= GetParticleSystemIndex( VOID_RING_DMG_PULSE_FX )

	//if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_HEATWAVE ) )
		//effectDmgId 		= GetParticleSystemIndex( VOID_RING_HEATWAVE_DMG_PULSE_FX )

	int effectWarnId 		= GetParticleSystemIndex( VOID_RING_SHIELD_WARNING_FX )

	int effectFId 			= GetParticleSystemIndex( VOID_RING_FLARE_SHIELD_FX )
	int effectFDmgId 		= GetParticleSystemIndex( VOID_RING_FLARE_DMG_PULSE_FX )
	int effectFWarnId 		= GetParticleSystemIndex( VOID_RING_FLARE_SHIELD_WARNING_FX )

	//Add Void Ring (projectile) as the entity holder of the array of players inside and in deathfield.
	file.playerInVoidRing[projectile] <- []

	//Default Void Ring State
	file.voidRingInActiveState[projectile] <- false
	file.voidRingInRingFissure[projectile] <- false
	thread VoidRing_TrackState_Thread( projectile )

	//Create Trigger Volume
	entity trigger = CreateVoidRing_TriggerArea( projectile, vRadius - VOID_RING_VISUAL_RADIUS_OFFSET, aboveHeight, belowHeight )

	//Create Void Ring VFX//
	entity shieldFX
	entity flareShieldFX
	entity shieldFX_Pulse

	//Create Warning Dome //
	entity shieldFX_Warning
	entity flareShieldFX_Warning

	//Create Beam FX
	entity beamFX = CreateVoidRing_BeamFX( projectile, effectBeamId, beamFXOrigin, vRadius, VOID_RING_COLOR_FX )
	entity beamFX_Pulse
	entity beamFX_Warning

	//Start Void Ring Sustain Sound
	EmitSoundOnEntity( projectile, VOID_RING_SOUND_SUSTAIN )

	//Create WP & RUI for Monitoring Void Ring HP
	/*entity wpUI = CreatePlayerWaypoint( eWaypoint.CUSTOM_TYPE )
	wpUI.SetOrigin( projectile.GetOrigin() + ( projectile.GetUpVector() * VOID_RING_WAYPOINT_LOCAL_OFFSET ) + <0, 0, VOID_RING_WAYPOINT_WP_OFFSET_Z> )
	wpUI.SetAngles( projectile.GetAngles() )
	wpUI.SetWaypointFloat( 0, voidHP )
	wpUI.SetWaypointFloat( 1, MaxVoidHP )
	wpUI.SetWaypointInt( 0, voidHP.tointeger() )
	wpUI.SetWaypointInt( 1, MaxVoidHP.tointeger() )
	wpUI.wp.waypointCreatedTime = Time()
	wpUI.SetOwner( projectile.GetOwner() )
	wpUI.SetParent( projectile )
	CopyRealmsFromTo( projectile, wpUI )
	SetTeam( wpUI, team )*/

	//Ambient Generic Sound - Active Ambience
	entity soundEnt = VoidRing_CreateAmbientSoundEntity( projectile, VOID_RING_SOUND_SUSTAIN_COLUMN )
	entity soundDMGEnt

	OnThreadEnd(
		function() : ( projectile, beamFX, trigger, /*wpUI,*/ shieldFX, shieldFX_Warning, shieldFX_Pulse, beamFX_Pulse, beamFX_Warning, flareShieldFX, flareShieldFX_Warning, soundEnt, soundDMGEnt )
		{
			if ( IsValid( shieldFX ) )
				EffectStop( shieldFX )
			if ( IsValid( beamFX ) )
				EffectStop( beamFX )
			if ( IsValid( trigger ) )
				trigger.Destroy()
			if( IsValid(projectile) )
			{
				delete file.playerInVoidRing[projectile]
				delete file.voidRingInActiveState[projectile]
				delete file.voidRingInRingFissure[projectile]
			}
			/*if( IsValid(wpUI) )
			{
				wpUI.Destroy()
			}*/

			if( IsValid(soundEnt) )
				soundEnt.Destroy()
			if( IsValid(soundDMGEnt) )
				soundDMGEnt.Destroy()

			if ( IsValid( shieldFX_Warning ) )
				EffectStop( shieldFX_Warning )
			if ( IsValid( shieldFX_Pulse ) )
				EffectStop( shieldFX_Pulse )
			if ( IsValid( beamFX_Pulse ) )
				EffectStop( beamFX_Pulse )
			if ( IsValid( flareShieldFX ) )
				EffectStop( flareShieldFX )
			if ( IsValid( flareShieldFX_Warning ) )
				EffectStop( flareShieldFX_Warning )

			VoidRing_CleanUp_ObjectStatusEffects()

			StopSoundOnEntity( projectile, VOID_RING_SOUND_SUSTAIN )
		}
	)

	////////////////////////
	// Void Ring - EXPAND //
	///////////////////////

	if ( projectile in file.voidRingInRingFissure )
	{
		if ( file.voidRingInRingFissure[projectile] )
		{
			flareShieldFX = CreateVoidRing_ShieldFX( projectile, effectFId, vRadius, VOID_RING_COLOR_FX )
			thread VoidRing_ScaleSphereThread( flareShieldFX, VOID_RING_EXPAND_TIME, 0, vRadius.tofloat() )
		}
		else
		{
			shieldFX = CreateVoidRing_ShieldFX( projectile, effectId, vRadius, VOID_RING_COLOR_FX )
			thread VoidRing_ScaleSphereThread( shieldFX, VOID_RING_EXPAND_TIME, 0, vRadius.tofloat() )
		}
	}

	wait VOID_RING_EXPAND_TIME

	thread VoidRing_UpdateVisibleFXDome_Thread( projectile, shieldFX, flareShieldFX, vRadius.tofloat(), effectId, effectFId )

	////////////////////////
	// Void Ring - ACTIVE //
	///////////////////////
	wait DEATHFIELD_DAMAGE_CHECK_STEP_TIME
	file.voidRingEndTime[projectile] <- Time() + ( duration - VOID_RING_DURATION_WARNING ) //Set the EndTime
	float savedTime = 0.0 //Used to store the time remaining on a Void Ring inside the main game circle.


	while( IsValid( projectile ) && ( Time() < file.voidRingEndTime[projectile] || warnCount > 0 ) )
	{
		DeathFieldData deathFieldData = SURVIVAL_GetDeathFieldData()

		bool isInRing 		= SURVIVAL_PosInsideDeathField(  origin )
		bool isInFissure	= VoidRing_IsInRingFissure( projectile, origin )
		int curStage 		= SURVIVAL_GetCurrentDeathFieldStage()
		int numStages 		= Survival_GetNumDeathfieldStages()

		if( curStage < 0 )
			curStage = 0

		if( curStage >= ringStageVRDamageTable.len() )
			curStage 	= ringStageVRDamageTable.len()

		DeathFieldStageData deathFieldStageData = GetDeathFieldStage( curStage )
		float shrinkDuration = deathFieldStageData.shrinkDuration

		//Final Circle - Treat the final closing circle as the final round
		if ( SURVIVAL_IsFinalDeathFieldStage( ))
		{
			float now                 = Time()
			float nextCircleStartTime = GetGlobalNetTime( "nextCircleStartTime" )

			if ( (nextCircleStartTime - now) <= 0.0 )
			{
				curStage 		= SURVIVAL_GetCurrentDeathFieldStage() + 1
			}
		}

		if( DEBUG_ACTIVE_RING_TEST )
		{
			curStage 		= DEBUG_RING_STAGE
			numStages		= DEBUG_NUM_STAGES
		}

		float perHP 		= voidHP / MaxVoidHP //Current Health Ratio
		float ringDMG 		= MaxVoidHP * ringStageVRDamageTable[curStage] //Amount of Damage Dealt to Void Ring per Tick.

		if( DEBUG_ACTIVE_RING_TEST )
			ringDMG 		= MaxVoidHP * ringStageVRDamageTable[curStage] * DebugDMGScalar //Allows Debug Scalar. Used to test Ring Stage Values w/o an Active Ring


		if( IsValid( soundDMGEnt ) )
			soundDMGEnt.Destroy()

		//////////////////////////////////
		///VOID RING TAKES RING DAMAGE //
		////////////////////////////////
		if( file.voidRingInActiveState[projectile] && ( voidHP > 0 ) ) //TAKE RING DAMAGE
		{
			voidHP = voidHP - ringDMG
			perHP  = voidHP / MaxVoidHP
			EmitSoundOnEntity( projectile, VOID_RING_SOUND_DAMAGE )

			if( isInRing ) //Void Ring is NOT in the Deathfield and hasn't been set
			{
				//save the Time Remaining on the Void Ring
				if( savedTime == 0 )
				{
					savedTime = file.voidRingEndTime[projectile] - Time() //Amount of Time remaining on the Void Ring.
					if ( savedTime < VOID_RING_DURATION_WARNING )
					{
						savedTime = VOID_RING_DURATION_WARNING
					}
				}
			}
			else //Void Ring is IN the Deathfield
			{
				//Reset Timer - Void Ring no longer Times Out once inside the Deathfield

				//if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_HEATWAVE ) )
					//voidHP = 0

				file.voidRingEndTime[projectile] <- Time() + ( duration - VOID_RING_DURATION_WARNING )
				savedTime = 0.0
			}

			if( voidHP < 0 ) //Force to 0
			{
				voidHP = 0
				perHP  = 0
			}

			int fxId = effectDmgId
			if ( projectile in file.voidRingInRingFissure )
			{
				if ( file.voidRingInRingFissure[projectile] )
					fxId = effectFDmgId
			}

			soundDMGEnt = VoidRing_CreateAmbientSoundEntity( projectile, VOID_RING_SOUND_DAMAGE_COLUMN )
			beamFXOrigin = projectile.GetAttachmentOrigin( startAttachID ) + ( Normalize( projectile.GetUpVector() )  )
			shieldFX_Pulse = CreateVoidRing_ShieldFX( projectile, fxId, vRadius, VOID_RING_COLOR_FX )
			beamFX_Pulse = CreateVoidRing_BeamFX( projectile, effectBeamPulseId, beamFXOrigin, vRadius, VOID_RING_COLOR_FX )
			EffectSetControlPointVector( beamFX_Pulse, 2, <vRadius, 0, 0> ) //BEAM HEIGHT

			//thread VoidRing_AdjustWPUIDamage_Thread( wpUI, voidHP, 0.25 )
			VoidRing_CheckForHealDrones( projectile, vRadius )
			VoidRing_CheckForNEWTs( projectile, vRadius )
			VoidRing_CheckForPhaseTunnels( projectile, vRadius )
			VoidRing_CheckForNPCs( projectile, vRadius )
			VoidRing_CheckForFlyers( projectile, vRadius )

			EffectSetControlPointVector( beamFX, 2, <beamFXOrigin.x, beamFXOrigin.y, beamFXOrigin.z+vRadius> ) //RING BEAM

		}
		else // VOID RING = INACTIVE
		{
			if( voidHP > 0 )
			{
				if( IsValid(shieldFX) )
				{
					EffectSetControlPointVector( shieldFX, 3, <0, 0, 0> ) //DAMAGE SHELL CONTROL - Return to Standby if not set for destruction
				}
				if ( savedTime > 0 )
				{
					file.voidRingEndTime[projectile] <- Time() + savedTime
					savedTime = 0.0 //Left
				}
			}
		}

		//Update the HP while we wait for a Deathfield Tick Step
		thread VoidRing_UpdateVoidRingHP_Thread( projectile, voidHP, DEATHFIELD_DAMAGE_CHECK_STEP_TIME )

		/////////////////////////////////////////////
		// Void Ring - WARNING PHASE & DESTRUCTION //
		/////////////////////////////////////////////

		//KILL VOID RING after WARNING PULSE(s)
		if( voidHP <= 0 )
		 {
			 int warningCount
			 if( !SURVIVAL_IsFinalDeathFieldStage() )
				 warningCount 	= GetCurrentPlaylistVarInt( "heatshield_warning_pulse_count", VOID_RING_NORMAL_WARNING_PULSE_COUNT )
			 else
				 warningCount 	= GetCurrentPlaylistVarInt( "heatshield_warning_pulse_count_final", VOID_RING_FINAL_CIRCLE_WARNING_PULSE_COUNT )

			 if( warnCount < warningCount )
			 {
				 if ( projectile in file.voidRingInRingFissure )
				 {
					 if ( file.voidRingInRingFissure[projectile] )
					 {
						 flareShieldFX_Warning = VoidRing_UpdateFXDome( flareShieldFX_Warning, shieldFX_Warning, projectile, effectFWarnId, vRadius.tofloat() )
					 }
					 else
					 {
						 shieldFX_Warning = VoidRing_UpdateFXDome( shieldFX_Warning, flareShieldFX_Warning, projectile, effectWarnId, vRadius.tofloat() )
					 }
				 }

				 beamFX_Warning = CreateVoidRing_BeamFX( projectile, effectBeamWarnId, beamFXOrigin, vRadius, VOID_RING_COLOR_FX )
				 EffectSetControlPointVector( beamFX_Warning, 2, <vRadius, 0, 0> ) //BEAM HEIGHT

				 if( warnCount == 0)
				 {
					 EmitSoundOnEntity( projectile, VOID_RING_SOUND_ENDING_IN_CIRCLE )
				 }
				 warnCount++
			 }
			 else
			 {
				 projectile.Signal("VoidRingShutdown")
				 thread VoidRing_PlayDestroyedFX( projectile.GetOrigin() )
				 delete file.playerInVoidRing[projectile]
				 delete file.voidRingHP[projectile]
				 delete file.voidRingEndTime[projectile]
				 delete file.voidRingInActiveState[projectile]
				 delete file.voidRingInRingFissure[projectile]
				 projectile.Destroy()
			 }
		 }

		file.voidRingRadius[projectile] <- vRadius
		wait DEATHFIELD_DAMAGE_CHECK_STEP_TIME
	}

	/////////////////////////////////////////////
	// Void Ring - TIMEOUT SEQUENCE //
	/////////////////////////////////////////////

	if ( IsValid( beamFX ) )
		EffectStop( beamFX )

	//Create Ending Timeout Beam   //todo: We'll need to replace this. It's using the same effect as placeholder.
	entity endBeamFX = CreateVoidRing_BeamFX( projectile, effectBeamId, beamFXOrigin, vRadius, VOID_RING_WARNING_COLOR_FX )

	OnThreadEnd(
		function() : ( endBeamFX, projectile )
		{
			if ( IsValid( endBeamFX ) )
				EffectStop( endBeamFX )
			if ( IsValid( projectile ) )
				StopSoundOnEntity( projectile, VOID_RING_SOUND_ENDING )
		}
	)

	EmitSoundOnEntity( projectile, VOID_RING_SOUND_ENDING )

	float endTime = Time() + VOID_RING_DURATION_WARNING

	while( IsValid( projectile ) && ( Time() < endTime ) )
	{
		if(IsValid( shieldFX) )
		{
			if( file.voidRingInActiveState[projectile] )
			{
				EffectSetControlPointVector( shieldFX, 3, <1, 0, 0> ) //DAMAGE SHELL CONTROL
			}
			else
			{
				EffectSetControlPointVector( shieldFX, 3, <0, 0, 0> ) //DAMAGE SHELL CONTROL
			}
		}
		WaitFrame()
	}
	projectile.Signal("VoidRingShutdown")

}

void function VoidRing_ScaleSphereThread( entity sphereFX, float totalTime, float startRadius, float endRadius )
{
	EndSignal(sphereFX, "OnDeath")
	EndSignal(sphereFX, "OnDestroy")

	float timeElapsed   = 0.0
	float startTime     = Time()
	float lastFrameTime = startTime

	OnThreadEnd(
		function() : ( sphereFX, endRadius )
		{
			if ( IsValid( sphereFX ) )
			{
				EffectSetControlPointVector( sphereFX, 2, <endRadius, 0, 0> )
			}
		}
	)

	while ( timeElapsed < totalTime )
	{
		float newRadius = GraphCapped( timeElapsed, 0, totalTime, startRadius, endRadius )
		if ( IsValid( sphereFX ) )
		{
			EffectSetControlPointVector( sphereFX, 2, <newRadius, 0, 0> ) //RING RADIUS
		}

		WaitFrame()
		timeElapsed = Time() - lastFrameTime
	}

}

void function VoidRing_UpdateVisibleFXDome_Thread( entity projectile, entity shieldFX, entity flareShieldFX, float vRadius, int effectId, int effectFId )
{
	projectile.EndSignal( "OnDestroy" )
	projectile.EndSignal( "VoidRingShutdown" )

	OnThreadEnd(
		function() : ( shieldFX, flareShieldFX )
		{
			if ( IsValid( shieldFX ) )
			{
				shieldFX.ClearParent()
				EffectStop( shieldFX )
			}
			if ( IsValid( flareShieldFX ) )
			{
				flareShieldFX.ClearParent()
				EffectStop( flareShieldFX )
			}
		}
	)

	bool isInFissure = false
	bool wasInFissure = false
	bool wasInDeathfield = false
	while ( IsValid( projectile ) && projectile in file.voidRingInActiveState )
	{
		if( file.voidRingInActiveState[projectile] )
		{
			isInFissure = file.voidRingInRingFissure[projectile]

			if( isInFissure != wasInFissure ) //has changed
			{
				if( isInFissure )
				{
					flareShieldFX = VoidRing_UpdateFXDome( flareShieldFX, shieldFX, projectile, effectFId, vRadius )
					wasInFissure = true
					wasInDeathfield = false
				}
				else
				{
					shieldFX = VoidRing_UpdateFXDome( shieldFX, flareShieldFX, projectile, effectId, vRadius )
					if( IsValid( shieldFX ) )
					{
						EffectSetControlPointVector( shieldFX, 3, <1, 0, 0> ) //DAMAGE SHELL CONTROL
					}
					wasInFissure = false
					wasInDeathfield = true
				}

			}
			else
			{
				if( !isInFissure && !wasInDeathfield )
				{
					if( IsValid( shieldFX ) )
					{
						EffectSetControlPointVector( shieldFX, 3, <1, 0, 0> ) //DAMAGE SHELL CONTROL
						wasInFissure = false
						wasInDeathfield = true
					}
				}
			}

			//#if DEV
			//if( isInFissure )
			//{
			//	DebugDrawSphere( projectile.GetOrigin(), vRadius-20, <150, 0, 0>, true, 0.1 )
			//}
			//else
			//	DebugDrawSphere( projectile.GetOrigin(), vRadius-30, <150, 150, 0>, true, 0.1 )
			//#endif

		}
		else //if NOT active
		{
			shieldFX = VoidRing_UpdateFXDome( shieldFX, flareShieldFX, projectile, effectId, vRadius )
			wasInFissure = false
			wasInDeathfield = false
		}

		WaitFrame()

	}


}

entity function VoidRing_UpdateFXDome( entity activeShield, entity hiddenShield, entity projectile, int fxId, float vRadius )
{
	if( IsValid( hiddenShield ) )
		EffectSetControlPointVector( hiddenShield, 2, <0, 0, 0> )

	entity temp = activeShield
	if( !IsValid( activeShield ) )
	{
		temp = CreateVoidRing_ShieldFX( projectile, fxId, VoidRing_GetVoidRingRadius() , VOID_RING_COLOR_FX )
	}

	EffectSetControlPointVector( temp, 2, <vRadius, 0, 0> )

	return temp // Have to return to increase ref count on new entity if we did create one
}


entity function VoidRing_CreateAmbientSoundEntity( entity projectile, string soundName )
{

	entity soundEnt = CreateEntity( "ambient_generic" )
	soundEnt.SetOrigin( projectile.GetOrigin() )
	soundEnt.RemoveFromAllRealms()
	soundEnt.AddToOtherEntitysRealms( projectile )
	soundEnt.SetParent( projectile )
	soundEnt.SetSoundName( soundName )
	soundEnt.SetSegmentEndpoints( projectile.GetOrigin(), projectile.GetOrigin() + <0,0,-VOID_RING_BELOW_RANGE> )
	soundEnt.SetEnabled( true )

	return soundEnt
}


void function VoidRing_AdjustWPUIDamage_Thread (entity wpUI, float voidHP, float totalTime)
{
	//Setting WP variables for the In World UI
	wait totalTime //Timed with VFX Pulse
	if( IsValid( wpUI ) )
	{
		wpUI.SetWaypointFloat( 0, voidHP )
		wpUI.SetWaypointInt( 0, voidHP.tointeger() )
	}
}

void function VoidRing_UpdateVoidRingHP_Thread (entity projectile, float voidHP, float duration)
{
	projectile.EndSignal( "OnDestroy" )
	float endTime = Time() + duration
	while( IsValid(projectile) && Time() < endTime )
	{
		//Setting HP for the Void Ring to the file
		if ( !( projectile in file.voidRingHP ) )
		{
			file.voidRingHP[projectile] <- voidHP
		}
		else
		{
			if( file.voidRingHP[projectile] > voidHP )
			{
				file.voidRingHP[projectile] <- voidHP
			}
		}
		WaitFrame()
	}
}

void function VoidRing_CheckForHealDrones( entity voidRing, int vRadius )
{
	foreach ( drone in GetAllHealDrones() )
	{
		if ( !IsValid( drone ) )
			continue

		if ( StatusEffect_HasSeverity( drone, eStatusEffect.ring_immunity ) )
			StatusEffect_StopAllOfType( drone, eStatusEffect.ring_immunity )

		vector droneOrigin = drone.GetOrigin()
		bool inRange = VoidRing_IsPositionInRange( droneOrigin, droneOrigin, voidRing )
		if ( inRange )
		{
			if ( !StatusEffect_HasSeverity( drone, eStatusEffect.ring_immunity ) )
				StatusEffect_AddEndless( drone, eStatusEffect.ring_immunity, 1.0 )
			//drone.e.deathfieldDamageTicks = 0
		}
	}
}

void function VoidRing_CheckForNEWTs( entity voidRing, int vRadius )
{
	foreach ( entity newt in GetEntArrayByScriptName( BLACKHOLE_PROP_SCRIPTNAME ) )
	{
		if ( !IsValid( newt ) )
			continue

		if ( StatusEffect_HasSeverity( newt, eStatusEffect.ring_immunity ) )
			StatusEffect_StopAllOfType( newt, eStatusEffect.ring_immunity )

		vector newtOrigin = newt.GetOrigin()
		bool inRange = VoidRing_IsPositionInRange( newtOrigin, newtOrigin, voidRing )
		if ( inRange )
		{
			if ( !StatusEffect_HasSeverity( newt, eStatusEffect.ring_immunity ) )
				StatusEffect_AddEndless( newt, eStatusEffect.ring_immunity, 1.0 )
		}
	}
}

void function VoidRing_CheckForPhaseTunnels( entity voidRing, int vRadius )
{
	foreach ( tunnelEnt in PhaseTunnel_GetAllTunnelEnts() )
	{
		if ( !IsValid( tunnelEnt ) )
			continue

		if ( !PhaseTunnel_IsTunnelValid( tunnelEnt ) )
			continue

		vector start = PhaseTunnel_GetTunnelStart( tunnelEnt )
		vector end = PhaseTunnel_GetTunnelEnd( tunnelEnt )

		if ( !IsValid( start ) || !IsValid( end ) )
			continue

		if ( StatusEffect_HasSeverity( tunnelEnt, eStatusEffect.ring_immunity ) )
			StatusEffect_StopAllOfType( tunnelEnt, eStatusEffect.ring_immunity )

		bool inRange = VoidRing_IsPositionInRange( start, start, voidRing ) || VoidRing_IsPositionInRange( end, end, voidRing )

		if ( inRange )
		{
			if ( !StatusEffect_HasSeverity( tunnelEnt, eStatusEffect.ring_immunity ) )
				StatusEffect_AddEndless( tunnelEnt, eStatusEffect.ring_immunity, 1.0 )
		}
	}
}

void function VoidRing_CheckForNPCs( entity voidRing, int vRadius )
{
	foreach ( npc in GetNPCArray() )
	{
		if ( !IsValid( npc ) )
			continue

		if ( npc.ai.hasDeathFieldImmunity == true )
			npc.ai.hasDeathFieldImmunity = false

		vector npcOrigin = npc.GetOrigin()
		bool inRange = VoidRing_IsPositionInRange( npcOrigin, npcOrigin, voidRing )
		if ( inRange )
		{
			if ( npc.ai.hasDeathFieldImmunity == false )
				npc.ai.hasDeathFieldImmunity = true
		}
	}
}

void function VoidRing_CheckForFlyers( entity voidRing, int vRadius )
{
	foreach ( flyer in Flyers_GetAllFlyers() )
	{
		if ( !IsValid( flyer ) )
			continue

		if ( StatusEffect_HasSeverity( flyer, eStatusEffect.ring_immunity ) )
			StatusEffect_StopAllOfType( flyer, eStatusEffect.ring_immunity )

		vector flyerOrigin = flyer.GetOrigin()
		bool inRange = VoidRing_IsPositionInRange( flyerOrigin, flyerOrigin, voidRing )
		if ( inRange )
		{
			if ( !StatusEffect_HasSeverity( flyer, eStatusEffect.ring_immunity ) )
				StatusEffect_AddEndless( flyer, eStatusEffect.ring_immunity, 1.0 )
		}
	}
}

void function VoidRing_CleanUp_ObjectStatusEffects()
{

	foreach ( drone in GetAllHealDrones() )
	{
		if ( !IsValid( drone ) )
			continue

		if ( StatusEffect_HasSeverity( drone, eStatusEffect.ring_immunity ) )
			StatusEffect_StopAllOfType( drone, eStatusEffect.ring_immunity )
	}

	foreach ( entity newt in GetEntArrayByScriptName( BLACKHOLE_PROP_SCRIPTNAME ) )
	{
		if ( !IsValid( newt ) )
			continue

		if ( StatusEffect_HasSeverity( newt, eStatusEffect.ring_immunity ) )
			StatusEffect_StopAllOfType( newt, eStatusEffect.ring_immunity )

	}

	foreach ( tunnelEnt in PhaseTunnel_GetAllTunnelEnts() )
	{
		if ( !IsValid( tunnelEnt ) )
			continue

		if ( StatusEffect_HasSeverity( tunnelEnt, eStatusEffect.ring_immunity ) )
			StatusEffect_StopAllOfType( tunnelEnt, eStatusEffect.ring_immunity )
	}

	foreach ( npc in GetNPCArray() )
	{
		if ( !IsValid( npc ) )
			continue

		if ( npc.ai.hasDeathFieldImmunity == true )
			npc.ai.hasDeathFieldImmunity = false
	}

	foreach ( flyer in Flyers_GetAllFlyers() )
	{
		if ( !IsValid( flyer ) )
			continue

		if ( StatusEffect_HasSeverity( flyer, eStatusEffect.ring_immunity ) )
			StatusEffect_StopAllOfType( flyer, eStatusEffect.ring_immunity )
	}

}
void function VoidRing_PlayDestroyedFX( vector emitPos )
{
	int damageFXID       = GetParticleSystemIndex( VOID_RING_DESTROY_FX )
	entity idleFX = StartParticleEffectInWorld_ReturnEntity ( damageFXID, emitPos, <0,0,0> )
	EmitSoundOnEntity( idleFX, VOID_RING_SOUND_DESTROY )

	OnThreadEnd(
		function() : ( idleFX )
		{
			if ( IsValid( idleFX ) )
				EffectStop( idleFX )
		}
	)
	wait 3 //Arbitrary number to let temp SFX finish. todo:DM Update when using proper SFX
}



////////////////////////////////////////
///// VOID RING VFX SHIELD & BEAM //////
////////////////////////////////////////

entity function CreateVoidRing_ShieldFX( entity projectile, int effectId, int vRadius, vector color )
{
	entity shieldFX = StartParticleEffectInWorld_ReturnEntity( effectId, projectile.GetOrigin(), <0,0,0> )
	shieldFX.RemoveFromAllRealms()
	shieldFX.AddToOtherEntitysRealms( projectile )
	shieldFX.SetParent( projectile)

	EffectSetControlPointVector( shieldFX, 1, color*0.45 )
	EffectSetControlPointVector( shieldFX, 2, <vRadius, 0, 0> ) //DEFAULT RING SIZE

	//Set Initial VFX State
	if( file.voidRingInActiveState[projectile] )
	{
		EffectSetControlPointVector( shieldFX, 3, <1, 0, 0> )
	}
	else
	{
		EffectSetControlPointVector( shieldFX, 3, <0, 0, 0> )
	}

	return shieldFX
}

entity function CreateVoidRing_BeamFX( entity projectile, int particleSystemIndex, vector beamFXOrigin, int vRadius, vector color )
{
	entity beamFX   = StartParticleEffectInWorld_ReturnEntity( particleSystemIndex, beamFXOrigin, <-90,0,0> )
	beamFX.SetParent( projectile )
	beamFX.RemoveFromAllRealms()
	beamFX.AddToOtherEntitysRealms( projectile )
	EffectSetControlPointVector( beamFX, 1, VOID_RING_COLOR_FX ) //Changed from FRIENDLY_COLOR_FX
	EffectSetControlPointVector( beamFX, 2, <beamFXOrigin.x, beamFXOrigin.y, beamFXOrigin.z+vRadius> ) //RING RADIUS
	EffectSetControlPointVector( beamFX, 3, <vRadius, 0, 0> ) //BEAM HEIGHT


	return beamFX
}
///// END OF VFX SHIELD & BEAM ////


///////////////////////////
///// TRIGGER VOLUME //////
///////////////////////////

entity function CreateVoidRing_TriggerArea( entity projectile, int vRadius, int aboveHeight, int belowHeight )
{
	entity trigger = CreateTriggerCylinderNoCylinderRadius( projectile.GetOrigin(), vRadius, aboveHeight, belowHeight )
	trigger.RemoveFromAllRealms()
	trigger.AddToOtherEntitysRealms( projectile )
	trigger.SetParent( projectile )
	trigger.SetEnterCallback( DomeTriggerEnter )
	trigger.SetLeaveCallback( DomeTriggerExit )
	trigger.SearchForNewTouchingEntity()

	return trigger
}
void function DomeTriggerEnter( entity trigger, entity ent )
{
	if ( ent.IsPlayer() )
	{

		if ( !( ent in file.voidringStatusCount ) )
		{
			file.voidringStatusCount[ent] <- 1
			AddEntityCallback_OnDamaged( ent, InVoidRing_OnDamaged )
		}
		else
		{
			file.voidringStatusCount[ent]++
		}

		thread DomeTriggerTouchingThread( trigger, ent )
	}

}

void function DomeTriggerExit( entity trigger, entity ent )
{
	if ( ent.IsPlayer() )
	{
	}
}

void function DomeTriggerTouchingThread( entity trigger, entity ent )
{
	EndSignal( ent, "OnDestroy" )
	EndSignal( ent, "OnDeath" )
	EndSignal( trigger, "OnDestroy" )

	int lastStatusEffectID_VR = -1
	int lastStatus_InVoidRing = -1
	entity projectile = trigger.GetParent()

	OnThreadEnd(
		function() : ( ent, trigger, projectile )
		{
			if ( IsValid( ent ) )
			{

				if( file.voidringStatusCount[ent] > 0 )
					file.voidringStatusCount[ent]--

				if ( file.voidringStatusCount[ent] <= 0 )
				{

					RemoveEntityCallback_OnDamaged( ent, InVoidRing_OnDamaged )
					delete file.voidringStatusCount[ent]

					if ( StatusEffect_HasSeverity( ent, eStatusEffect.ring_immunity ) )
					{
						StatusEffect_StopAllOfType( ent, eStatusEffect.ring_immunity )
					}

					if ( StatusEffect_HasSeverity( ent, eStatusEffect.in_void_ring ) )
						StatusEffect_StopAllOfType( ent, eStatusEffect.in_void_ring )

					if( PlayerHasPassive( ent, ePassives.PAS_FAST_HEAL ) )
					{
						TakePassive( ent, ePassives.PAS_FAST_HEAL )
					}

					//ent.DeathfieldFXDisabledOff()
				}


				if( IsValid( projectile ) )
				{
					if ( projectile in file.voidRingInActiveState )
					{
						if ( file.voidRingInActiveState[projectile] ) //Give Players in an ACTIVE Void Ring FAST HEAL (also get Fast-Revive inside: sh_bleedout.gnut)
						{
							EmitSoundOnEntity( ent, SOUND_DEATHFIELD_START )
						}
					}
				}

				RemovePlayerFromVoidRingCount( trigger, ent )
			}
		}
	)

	//Add Status Effect - Turns off/on of Deathfield Effect & HUD Icon (handled externally) when inside the zone
	while( trigger.IsTouching( ent ) )
	{
		bool isInDrone = IsPlayerInCryptoDroneCameraView( ent )
		vector checkPos =  isInDrone ? ent.GetAttachmentOrigin( ent.LookupAttachment( "HEADFOCUS" ) ) : ent.EyePosition() //Using this so that if you poke your head outside the upper area of the dome it doesn't "look" safe and the deathfield effects return.
		bool inRange = VoidRing_IsPositionInRange( checkPos, ent.GetOrigin(), trigger )

		if ( inRange )
		{
			if ( lastStatus_InVoidRing != -1 )
				StatusEffect_Stop( ent, lastStatus_InVoidRing )

			lastStatus_InVoidRing = StatusEffect_AddEndless( ent, eStatusEffect.in_void_ring, 1.0 )

			if( isInDrone )
			{
				bool isDroneInRange = VoidRing_IsPositionInRange( ent.EyePosition(), ent.GetOrigin(), trigger )
				if( !isDroneInRange )
				{
					RemoveActiveVoidRingEffects(ent, trigger, lastStatusEffectID_VR)
					//ent.DeathfieldFXDisabledOff()

					WaitFrame()
					continue
				}
			}

			if ( projectile in file.voidRingInActiveState )
			{
				if (file.voidRingInActiveState[projectile]) //Give Players in an ACTIVE Void Ring FAST HEAL (also get Fast-Revive inside: sh_bleedout.gnut)
				{
					if ( !StatusEffect_HasSeverity( ent, eStatusEffect.ring_immunity ) )
					{
						EmitSoundOnEntity( ent, SOUND_DEATHFIELD_STOP )
						//ent.DeathfieldFXDisabledOn()
					}        //This turns OFF the "bloom" when you cross the deathfield ( unlike the 1P effect, this bloom is not created in script )

					//Re-Add the Status Effect each frame (as Bangalore Smoke & Gravity Reduction Field)
					if ( lastStatusEffectID_VR != -1 )
						StatusEffect_Stop( ent, lastStatusEffectID_VR )

					lastStatusEffectID_VR = StatusEffect_AddEndless( ent, eStatusEffect.ring_immunity, 1.0 )

					//todo: Need to replace the PAS_FAST_HEAL with out OWN solution. No one's using it currently...but if it does come back, we'd want it seperate and unique
					bool allowFastHeal = GetCurrentPlaylistVarBool( "heatshield_fastHeal", VOID_RING_FAST_HEAL )

					if ( !PlayerHasPassive( ent, ePassives.PAS_FAST_HEAL ) && allowFastHeal )
					{
						GivePassive( ent, ePassives.PAS_FAST_HEAL )
					}

				}
				else
					RemoveActiveVoidRingEffects( ent, trigger, lastStatusEffectID_VR )

				Remote_CallFunction_Replay( ent, "ServerToClient_VoidRingStateToClient", ent, file.voidRingInActiveState[projectile] )
			}

			if ( projectile in file.voidRingHP )
			{
				Remote_CallFunction_Replay( ent, "ServerToClient_VoidRingHPToClient", ent, file.voidRingHP[projectile] )
			}

			//Debug Test allows test of the ACTIVE state on Entering the Trigger
			if( DEBUG_ACTIVE_RING_TEST )
				VoidRing_TrackPlayerInside( trigger, ent, projectile )

		}
		else
		{
			RemoveActiveVoidRingEffects(ent, trigger, lastStatusEffectID_VR)
			StatusEffect_Stop( ent, lastStatus_InVoidRing )
		}

		WaitFrame()
	}
}
bool function VoidRing_IsPositionInRange( vector checkPos, vector entOrigin, entity voidRing )
{
	//CheckPos is used for PLAYERS so that if you poke your head outside the upper area of the dome it doesn't "look" safe and the deathfield effects return.
	//For objects with a single desired check position, checkPos and entOrigin should be the same

	bool inAboveRange = Distance( voidRing.GetOrigin(), checkPos ) <= VoidRing_GetVoidRingRadius()  - VOID_RING_VISUAL_RADIUS_OFFSET  && voidRing.GetOrigin().z <= entOrigin.z
	bool inBelowRange = Distance2D( voidRing.GetOrigin(), checkPos ) <= VoidRing_GetVoidRingRadius() - VOID_RING_VISUAL_RADIUS_OFFSET  && voidRing.GetOrigin().z > entOrigin.z

	bool inRange = inAboveRange || inBelowRange

	return inRange
}

void function RemoveActiveVoidRingEffects( entity ent, entity trigger, int lastStatusEffectID_VR )
{
	if ( lastStatusEffectID_VR != 0 )
	{
		StatusEffect_Stop( ent, lastStatusEffectID_VR )

		if( PlayerHasPassive( ent, ePassives.PAS_FAST_HEAL ) )
		{
			TakePassive( ent, ePassives.PAS_FAST_HEAL )
		}

		RemovePlayerFromVoidRingCount( trigger, ent )
	}
}

void function VoidRing_TrackPlayerInside( entity trigger, entity ent, entity projectile )
{
	//Originally, this was used to tally Players in the Void Ring who were ALSO in the Deathfield to determine Activation of the Void Ring
	//We've currently simplified to allow the Void Ring to become ACTIVE if ANY PART of it is touching the Deathfield
	//Now I use this simply for debugging in box with actual Deathfield. - May be useful for Telemetry

	//DeathFieldData deathFieldData = SURVIVAL_GetDeathFieldData()
	//bool isInRing                 = SURVIVAL_PosInsideDeathField( ent.GetOrigin() )
	//bool isInFissure              = VoidRing_IsInRingFissure( projectile, ent.GetOrigin() )

	if ( DEBUG_ACTIVE_RING_TEST ) //if ( !isInRing || isInFissure || DEBUG_ACTIVE_RING_TEST )
	{
		if ( IsValid( ent ) && IsValid( projectile ) )
		{
			if ( !(file.playerInVoidRing[projectile].contains( ent )) )
			{
				file.playerInVoidRing[projectile].append( ent )
			}
		}
	}
	else
	{
		RemovePlayerFromVoidRingCount( trigger, ent )
	}
}

void function RemovePlayerFromVoidRingCount( entity trigger, entity ent )
{
	if ( IsValid( ent ) && IsValid( trigger ) )
	{
		Assert( ent.IsPlayer() )
		entity projectile = trigger.GetParent()
		if ( file.playerInVoidRing[projectile].contains( ent ) )
		{
			file.playerInVoidRing[projectile].fastremovebyvalue( ent )
		}
	}
}

void function InVoidRing_OnDamaged( entity ent , var damageInfo )
{
	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	bool isDeathfieldDamageSource = false

	if ( damageSourceID == eDamageSourceId.deathField )
		isDeathfieldDamageSource = true








		// Replicate Deathfield damage behaviour for Heatwaves
		if ( damageSourceID == eDamageSourceId.heatwave )
			isDeathfieldDamageSource = true


	if ( isDeathfieldDamageSource && StatusEffect_HasSeverity( ent, eStatusEffect.in_void_ring ) )
	{

			//if( SimplifiedRingLethality_Enabled() && StatusEffect_HasSeverity( ent, eStatusEffect.ring_lethality_increase ) )
			{
				//SimplifiedRingLethality_InstaDeath( ent )
			}
			//else

		{
			//StatsHook_VoidRing_RingDamagePrevented( ent, DamageInfo_GetDamage( damageInfo ).tointeger() ) //Track damage prevented for player stats
			DamageInfo_SetDamage( damageInfo, 0 )
		}
	}
}


//Runs when AddCallback_OnPlayerInventoryChanged() is called to initiate checks to announce VoidRing Usage Hints on the Client
void function VoidRing_HintCheck( entity player )
{
	string equipRef = EquipmentSlot_GetLootRefForSlot( player, "gadget" )
	if( equipRef == VOID_RING_WEAPON_REF )
	{
		Remote_CallFunction_Replay( player, "ServerToClient_VoidRingHintDetection", player )
	}
	else
	{
		Remote_CallFunction_Replay( player, "ServerToClient_VoidRingHintCancelDetection", player )
	}
}

#endif //server

#if SERVER
void function ShowVoidRingWeaponFX( entity weapon )
{
	entity weaponOwner = weapon.GetOwner()
	EndSignal( weapon, "OnDestroy" )
	EndSignal( weapon, "VoidRing_WeaponEnd" )
	EndSignal( weaponOwner, "OnDeath" )
	EndSignal( weaponOwner, "OnDestroy" )

	int team = weaponOwner.GetTeam()
	int startAttachID 		= weapon.LookupAttachment( "fx_beam" )

	entity fx = StartParticleEffectOnEntity_ReturnEntity( weapon, GetParticleSystemIndex( VOID_RING_3P_WPN_FX ), FX_PATTACH_POINT_FOLLOW, startAttachID )
	SetTeam( fx, team )
	fx.kv.VisibilityFlags = ( ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY ) //not owner
	fx.SetOwner( weaponOwner )
	if ( weaponOwner.IsThirdPersonShoulderModeOn() )
		fx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY | ENTITY_VISIBLE_TO_OWNER

	OnThreadEnd(
		function() : ( fx )
		{
			if (IsValid( fx ))
			{
				EffectStop( fx )
			}
		}
	)
	while( fx )
		WaitFrame()
}
#endif
#if CLIENT
void function ShowVoidRingRadius( entity weapon )
{
	EndSignal( weapon, "VoidRing_EndPreview" )
	EndSignal( weapon, "OnDestroy" )

	WaitFrame()

	int fxHandle = -1
	int fxPovHandle = -1
	int voidRingRadius = VoidRing_GetVoidRingRadius()

	if ( IsValid( weapon ) )
	{
		fxHandle = StartParticleEffectInWorldWithHandle( GetParticleSystemIndex( VOID_RING_PREVIEW_RING_FX ), weapon.GetOrigin(), ZERO_VECTOR )
		EffectSetControlPointVector( fxHandle, 1, < voidRingRadius  - VOID_RING_AR_RADIUS_OFFSET, 0, 0> )
		EffectSetControlPointVector( fxHandle, 2, < voidRingRadius , 0, 0> ) //RING RADIUS For Exclusion

		//Adding the Void Ring "glow" here for now - may move later if there are specific needs.
		fxPovHandle = weapon.PlayWeaponEffectReturnViewEffectHandle( VOID_RING_POV_WPN_FX, $"", "fx_beam" )
	}

	OnThreadEnd(
		function() : ( fxHandle, fxPovHandle )
		{
			if ( fxHandle != -1 )
				EffectStop( fxHandle, true, false )
			if ( fxPovHandle != -1 )
				EffectStop( fxPovHandle, true, false )
		}
	)

	while( IsValid( fxHandle ) )
	{
		vector dropPosition = weapon.GetOrigin()
		//DebugDrawSphere( dropPosition, VOID_RING_RADIUS, <0, 0, 120>, true, 0.1 )
		EffectSetControlPointVector( fxHandle, 0, dropPosition )
		WaitFrame()
	}
}
#endif

#if CLIENT
void function ServerToClient_VoidRingHintDetection( entity player)
{
	if ( player != GetLocalViewPlayer() )
		return

	thread CL_VoidRingHintThread( GetLocalViewPlayer() )
}

void function ServerToClient_VoidRingHintCancelDetection( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	player.Signal( "VoidRingEquipped" )
}

//Hint Thread - Triggers Usage Hint for the Void Ring when a Player is inside the Deathfield and has a Void Ring in their Survival Slot
void function CL_VoidRingHintThread( entity player )
{
	EndSignal( player, "VoidRingEquipped" )

	while( IsValid( player ) )
	{
		//LootData lootData = EquipmentSlot_GetEquippedLootDataForSlot( player, "MAIN_WEAPON" )
		//if( lootData.ref != VOID_RING_WEAPON_REF )
		//	break

		vector eyePos      = player.EyePosition()
		float frontierDist = DeathField_PointDistanceFromFrontier( player.EyePosition() )
		entity heldGadget = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_2 )
		entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
		int hasDownedState = BleedoutState_GetPlayerBleedoutState( player )
		bool isInsideFissure = false




		if( frontierDist < 0 || isInsideFissure )
		{
			if ( IsValid( heldGadget ) )
			{
				if ((heldGadget != activeWeapon) && hasDownedState <= 0 )
				{
					if( IsControllerModeActive() )
					{
						int useSurvivalSlotButton = GetConVarInt("gamepad_toggle_survivalSlot_to_weaponInspect")

						if ( useSurvivalSlotButton == 0 ) //0 = Survival Slot / 1 = Weapon Inspect
							AnnouncementMessageRight( player, "#HINT_USE_VOID_RING_CONSOLE" , "Void Ring Warning", <1, 1, 1> )
					}
					else
						AnnouncementMessageRight( player, "#HINT_USE_VOID_RING_PC" , "Void Ring Warning", <1, 1, 1> )
				}
			}
		}
		wait 1.5
	}

}

void function ServerToClient_VoidRingHPToClient( entity player, float voidHP )
{
	if ( player != GetLocalViewPlayer() )
		return
	file.cl_voidHP = voidHP
}
void function ServerToClient_VoidRingStateToClient( entity player, bool voidRingIsActive )
{
	if ( player != GetLocalViewPlayer() )
		return
	file.cl_voidActive = voidRingIsActive
}

void function CL_TrackVoidHP_Thread( entity player )
{
	return
	player.EndSignal( "VoidRing_DestroyHUD" )
	if ( player != GetLocalViewPlayer() )
		return

	array<var> ruis
	var rui = CreateCockpitRui( $"ui/void_ring_protection_status.rpak", HUD_Z_BASE )

	// since HP is set with network callbacks, we can't be sure when it'll get set to the proper value
	// so use an error value hide hud until something new comes in
	file.cl_voidHP = -1

	ruis.append( rui )

	OnThreadEnd(
		function() : ( ruis )
		{
			foreach ( rui in ruis )
				RuiDestroyIfAlive( rui )
		}
	)

	while ( IsValid( rui ) )
	{
		RuiSetFloat( rui, "curHP", file.cl_voidHP )
		WaitFrame()
	}
}

//Adds the Void Ring Icon to the Player HUD when the Player has the Ring Immunity Status Effect (is inside the Void Ring)
void function VoidRing_EnterDome( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return
	EmitSoundOnEntity( player, VOID_RING_SOUND_INSIDE )

	thread CL_TrackVoidHP_Thread( player )

}

void function VoidRing_ExitDome( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return

	StopSoundOnEntity( player, VOID_RING_SOUND_INSIDE )

	//Destroy the Void Ring HUD on leave
	if( file.voidRingHUDRui != null )
	{
		RuiDestroyIfAlive( file.voidRingHUDRui )
		file.voidRingHUDRui = null
	}

	Signal( player, "VoidRing_DestroyHUD" )

}

void function OnWaypointCreated( entity wp )
{
	int wpType = wp.GetWaypointType()

	if ( wpType == eWaypoint.CUSTOM_TYPE )
	{
		thread VoidRing_WaypointUI_Thread( wp )
		AddRefEntAreaToInvalidOriginsForPlacingPermanentsOnto( wp, VOID_RING_INVALID_PLACEMENT_MIN_AREA, VOID_RING_INVALID_PLACEMENT_MAX_AREA )
		AddEntityDestroyedCallback( wp,
			void function( entity ent ) : ( wp )
			{
				RemoveRefEntAreaFromInvalidOriginsForPlacingPermanentsOnto( ent )
			}
		)
	}

}


void function VoidRing_WaypointUI_Thread( entity wp )
{
	return
	wp.SetDoDestroyCallback( true )
	wp.EndSignal( "OnDestroy" )

	float width  = 220
	float height = 220
	vector right = <0, 1, 0> * height * 0.5
	vector fwd   = <1, 0, 0> * width * 0.5 * -1.0
	vector org   = <0, 0, 0>

	var topo = RuiTopology_CreatePlane( org - right * 0.5 - fwd * 0.5, fwd, right, true )
	RuiTopology_SetParent( topo, wp )

	var rui

	bool isOwned = IsFriendlyTeam( wp.GetTeam(), GetLocalViewPlayer().GetTeam() )
	entity player = GetLocalViewPlayer()

	var ownedRui
	if ( isOwned )
	{
		rui = CreateCockpitRui( $"ui/void_ring_hp_meter_cockpit.rpak", 1 )
		RuiTrackFloat3( rui, "playerAngles", player, RUI_TRACK_EYEANGLES_FOLLOW )
		RuiTrackFloat3( rui, "worldPos", wp, RUI_TRACK_ABSORIGIN_FOLLOW )
		RuiTrackFloat( rui, "curHP", wp, RUI_TRACK_WAYPOINT_FLOAT, 0 )
		RuiTrackFloat( rui, "maxHP", wp, RUI_TRACK_WAYPOINT_FLOAT, 1 )
	}
	else
	{
		rui = RuiCreate( $"ui/void_ring_hp_meter_cockpit.rpak", topo, RUI_DRAW_WORLD, 1 )
	}

	OnThreadEnd(
		function() : ( topo, rui )
		{
			RuiDestroyIfAlive( rui )
			RuiTopology_Destroy( topo )
		}
	)

	if ( isOwned )
	{
		while ( IsValid( wp ) )
		{
			bool displayRui = false

			if ( IsValid( player ) )
			{
				float dist = Distance( player.EyePosition(), wp.GetOrigin() )
				bool isInRange = ( dist > VOID_RING_WP_HP_DRAW_DIST_MIN ) && ( dist < VOID_RING_WP_HP_DRAW_DIST_MAX )
				if( isInRange )
				{
					TraceResults results = TraceLine( player.EyePosition(), wp.GetOrigin(), [player], TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )
					displayRui = results.fraction > 0.95
				}
			}

			RuiSetBool( rui, "isVisible", displayRui )

			WaitFrame()

			player = GetLocalViewPlayer()
		}
	}
	else
	{
		WaitForever()
	}
}

#endif //client
 