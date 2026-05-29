//

#if SERVER
untyped

global function OnWeaponNpcPrimaryAttack_weapon_zipline
global function GrantPathfinderCooldownReduction
global function IsZiplinePlacedByPathfinder
#endif // #if SERVER

global function MpWeaponZipline_Init
global function OnWeaponPrimaryAttack_weapon_zipline
global function OnProjectileCollision_weapon_zipline
global function OnWeaponRaise_weapon_zipline
global function OnWeaponDeactivate_weapon_zipline

#if CLIENT
global function OnCreateClientOnlyModel_weapon_zipline
global function ClientCodeCallback_MaxPlayerZiplines
#endif

const ZIPLINE_STATION_MODEL_VERTICAL = $"mdl/IMC_base/scaffold_tech_horz_rail_c.rmdl"
const ZIPLINE_STATION_MODEL_HORIZONTAL = $"mdl/industrial/zipline_arm.rmdl"
const ZIPLINE_TEMP_ZIPLINE_GUN_STATION_MODEL = $"mdl/props/pathfinder_zipline/pathfinder_zipline.rmdl"
const ZIPLINE_TEMP_ZIPLINE_GUN_STATION_WALL_MODEL = $"mdl/props/pathfinder_zipline/pathfinder_zipline.rmdl"
const asset TEMP_ZIPLINE_RANGE_FX = $"P_ar_zipline_range"
const string ZIPLINE_EXTENSION_SOUND = "pathfinder_zipline_cable_extension"
const string ZIPLINE_USABLE_SOUND = "pathfinder_zipline_cable_tension"
const vector ZIPLINE_BEGIN_STATION_TOP_ROPE_OFFSET = <0.0, 0.0, 21.3> //measured in game, when we want to play the sound for the zipline expanding, the zipline model won't have finished playing its anim yet, so we have to manually account for how much it will "grow" during that anim when calculating the line to play the sound along.
const ZIPLINE_STATION_EXPLOSION = $"p_impact_exp_small_full"
const float ZIPLINE_REFUND_TIME = 3
const float ZIPLINE_AUTO_DETACH_DISTANCE = 100.0
const int ZIPLINE_MAX_IN_WORLD = 10
const string ZIPLINE_START_SCRIPTNAME = "zipline_start"

#if DEV
const bool DEBUG_ZIPLINE_AUDIO_LINE = false
#endif

struct
{
    table<int, entity> activeWeaponBolts
    array<entity>    pathfinderZiplines
    bool             weaponAlreadyActive
} file

void function MpWeaponZipline_Init()
{
    PrecacheScriptString( ZIPLINE_START_SCRIPTNAME )
    PrecacheModel( ZIPLINE_STATION_MODEL_VERTICAL )
    PrecacheModel( ZIPLINE_STATION_MODEL_HORIZONTAL )
    PrecacheModel( ZIPLINE_TEMP_ZIPLINE_GUN_STATION_MODEL )
    PrecacheModel( ZIPLINE_TEMP_ZIPLINE_GUN_STATION_WALL_MODEL )
    PrecacheParticleSystem( ZIPLINE_STATION_EXPLOSION )
    PrecacheParticleSystem( TEMP_ZIPLINE_RANGE_FX )


    PrecacheMaterial( $"cable/zipline" )
    PrecacheMaterial( $"cable/zipline_active" )

    #if CLIENT
    RegisterSignal( "ClearZiplineUI" )
    #endif

	                    
		#if SERVER
		AddCallback_OnPassiveChanged( ePassives.PAS_ULT_UPGRADE_TWO, ZiplineUpgrade_MultipleCharges_OnPassiveChanged )
		#endif
       
}

#if CLIENT
int function ClientCodeCallback_MaxPlayerZiplines()
{
	// ZIPLINE_MAX_IN_WORLD is the maximum number of ziplines a player can create. The limit of pathfinders in the game is actually probably closer to 32 (duo + no fill, since AFAIK, we don't put very many no fills into a single game)
	// So, it is theoretically possible to have more player created ziplines, but this number is more realistic. We would like to provide the maximum number to level placed ziplines so we're going with a good realistic number instead of the maximum possible.
	return 180
}
#endif

#if SERVER
                    
void function ZiplineUpgrade_MultipleCharges_OnPassiveChanged( entity player, int passive, bool didHave, bool nowHas )
{
	if( !PlayerHasPassive( player, ePassives.PAS_PATHFINDER ) )
		return

	if( didHave )
	{
		entity offhandWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
		if( !IsValid( offhandWeapon ) )
			return

		if( offhandWeapon.HasMod( "upgrade_ult_one" ) )
			offhandWeapon.RemoveMod( "upgrade_ult_one" )
	}

	if ( nowHas )
	{
		entity offhandWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
		if( !IsValid( offhandWeapon ) )
			return

		offhandWeapon.AddMod( "upgrade_ult_one" )
	}



	Remote_CallFunction_NonReplay( player, "ServerCallback_UpdateOffhandRuis" )
}
      

var function OnWeaponNpcPrimaryAttack_weapon_zipline( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return 0
}

float function PathfinderCooldownReduction_ChargeResetPercentage()
{
	return GetCurrentPlaylistVarFloat( "pathfinder_passive_ultimate_charge_percent_reduction", 1.0 )
}

bool function GrantPathfinderCooldownReduction( entity player )
{
	entity offhandWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
	if( !IsValid( offhandWeapon ) )
		return false

	bool reducedCooldown = true
	                    
	if( UpgradeCore_IsEnabled() )
	{
		if ( offhandWeapon.HasMod( "cooldown_reduction_1" ) )
		{
			offhandWeapon.RemoveMod( "cooldown_reduction_1" )
			offhandWeapon.AddMod( "cooldown_reduction_2" )
		}
		else if ( offhandWeapon.HasMod( "cooldown_reduction_2" ) )
		{
			offhandWeapon.RemoveMod( "cooldown_reduction_2" )
			offhandWeapon.AddMod( "cooldown_reduction_3" )
		}
		else if ( offhandWeapon.HasMod( "cooldown_reduction_3" ) )
		{
			offhandWeapon.RemoveMod( "cooldown_reduction_3" )
			offhandWeapon.AddMod( "cooldown_reduction_4" )
		}
		else if ( offhandWeapon.HasMod( "cooldown_reduction_4" ) )
		{
			offhandWeapon.RemoveMod( "cooldown_reduction_4" )
			offhandWeapon.AddMod( "cooldown_reduction_5" )
		}
		else if ( offhandWeapon.HasMod( "cooldown_reduction_5" ) )
		{
			offhandWeapon.RemoveMod( "cooldown_reduction_5" )
			offhandWeapon.AddMod( "cooldown_reduction_6" )
		}
		else if ( offhandWeapon.HasMod( "cooldown_reduction_6" ) )
		{
			offhandWeapon.RemoveMod( "cooldown_reduction_6" )
			offhandWeapon.AddMod( "cooldown_reduction_7" )
		}
		else if ( offhandWeapon.HasMod( "cooldown_reduction_7" ) )
		{
			offhandWeapon.RemoveMod( "cooldown_reduction_7" )
			offhandWeapon.AddMod( "cooldown_reduction_8" )
		}
		else if ( offhandWeapon.HasMod( "cooldown_reduction_8" ) )
		{
			reducedCooldown = false
		}
		else
		{
			offhandWeapon.AddMod( "cooldown_reduction_1" )
		}
	}
	else
       
	{
		if ( offhandWeapon.HasMod( "beacon_1" ) )
		{
			offhandWeapon.RemoveMod( "beacon_1" )
			offhandWeapon.AddMod( "beacon_2" )
		}
		else if ( offhandWeapon.HasMod( "beacon_2" ) )
		{
			offhandWeapon.RemoveMod( "beacon_2" )
			offhandWeapon.AddMod( "beacon_3" )
		}
		else if ( offhandWeapon.HasMod( "beacon_3" ) )
		{
			offhandWeapon.RemoveMod( "beacon_3" )
			offhandWeapon.AddMod( "beacon_4" )
		}
		else if ( offhandWeapon.HasMod( "beacon_4" ) )
		{
			offhandWeapon.RemoveMod( "beacon_4" )
			offhandWeapon.AddMod( "beacon_5" )
		}
		else if ( offhandWeapon.HasMod( "beacon_5" ) )
		{
			offhandWeapon.RemoveMod( "beacon_5" )
			offhandWeapon.AddMod( "beacon_6" )
		}
		else if ( offhandWeapon.HasMod( "beacon_6" ) )
		{
			reducedCooldown = false
		}
		else
		{
			offhandWeapon.AddMod( "beacon_1" )
		}
	}

	int currentCount = offhandWeapon.GetWeaponPrimaryClipCount()
	int maxCharge = offhandWeapon.GetWeaponPrimaryClipCountMax()
	int chargeGrant = int( maxCharge * PathfinderCooldownReduction_ChargeResetPercentage() )
	                    
	if( UpgradeCore_IsEnabled() )
	{
		chargeGrant /= 2
	}
       
	int newCount =  currentCount + chargeGrant
	if( newCount > maxCharge )
		newCount = maxCharge

	offhandWeapon.SetWeaponPrimaryClipCount( newCount )

	if( reducedCooldown )
		Remote_CallFunction_NonReplay( player, "ServerToClient_NotifyPathfinderCooldownReduction" )

	return true
}
#endif // #if SERVER

#if SERVER
void function OnZiplineGrenadeDestroyed( entity weapon, entity projectile )
{
	Assert( IsValid( weapon ) )
	Assert( IsValid( projectile ) )

	OnThreadEnd(
		function() : ( weapon )
		{
			if ( !IsValid( weapon ) )
			{
				return
			}

			if ( weapon.w.ziplineGrenadeCollided )
			{
				// The zipline grenade deployed, so no need to refund (it might still fail deployment, in which case
				// OnZiplineDestroyed() will handle giving the refund).
				return
			}

			// The grenade was destroyed without getting a chance to deploy. Refund the ultimate back to the player.
			weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
		}
	)

	EndSignal( weapon, "OnDestroy" )
	EndSignal( projectile, "OnDestroy" )

	WaitForever()
}
#endif

var function OnWeaponPrimaryAttack_weapon_zipline( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if ( !weapon.ZiplineGrenadeHasValidSpot() )
	{
		weapon.DoDryfire()
		return 0
	}

	#if SERVER
		if ( IsValid( weapon.w.lastProjectileFired ) )
		{
			// There is a zipline grenade already in flight. Don't fire another one.
			weapon.DoDryfire()
			return 0
		}
	#endif

	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	entity weaponOwner = weapon.GetWeaponOwner()
	int weaponOwnerTeam = weaponOwner.GetTeam()

	bool shouldCreateProjectile = false
	if ( IsServer() || weapon.ShouldPredictProjectiles() )
		shouldCreateProjectile = true

	if ( shouldCreateProjectile )
	{
		WeaponFireGrenadeParams fireGrenadeParams
		fireGrenadeParams.pos = attackParams.pos
		fireGrenadeParams.vel = attackParams.dir
		fireGrenadeParams.angVel = <0, 0, 0>
		fireGrenadeParams.fuseTime = 0.0
		fireGrenadeParams.scriptTouchDamageType = 0
		fireGrenadeParams.scriptExplosionDamageType = 0
		fireGrenadeParams.clientPredicted = true
		fireGrenadeParams.lagCompensated = true
		fireGrenadeParams.useScriptOnDamage = true
		fireGrenadeParams.isZiplineGrenade = true
		fireGrenadeParams.ziplineGrenadeRopeMaterial = "cable/zipline_active"

		entity projectile = weapon.FireWeaponGrenade( fireGrenadeParams )
		if ( !IsValid( projectile ) )
			return 0

		#if SERVER
			EmitSoundOnEntity( projectile, ZIPLINE_EXTENSION_SOUND )
			weapon.w.lastProjectileFired = projectile
			weapon.w.ziplineGrenadeCollided = false
			SetTeam( projectile, weaponOwner.GetTeam() )
			projectile.s.weapon <- weapon
			thread WeaponMakesZipline( weapon, projectile, weaponOwnerTeam )
			thread OnZiplineGrenadeDestroyed( weapon, projectile )

			PlayerUsedOffhand( weaponOwner, weapon, true, projectile )
			PlayBattleChatterLineToSpeakerAndTeam( weaponOwner, "bc_super" )
		#else
			PlayerUsedOffhand( weaponOwner, weapon )
		#endif // SERVER
		#if CLIENT
		weapon.Signal( "ClearZiplineUI" )
		#endif
	}

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
}

#if SERVER
void function OnZiplineDestroyed( entity owner, entity startModel, entity endModel, entity ziplineStart, entity ziplineEnd )
{
	Assert( IsValid( startModel ) || IsValid( endModel ) || IsValid( ziplineStart ) || IsValid( ziplineEnd ) )

	// Need to put this into a table so it gets passed to OnThreadEnd as a reference
	table refundZipline = { value = true }

                                 
                                                                                                                               
                                                                              
                              
                                       

	OnThreadEnd(
		function () : ( owner, startModel, endModel, ziplineStart, ziplineEnd, refundZipline )
		{
			RemoveLimitedLegendObject( owner, ziplineStart )

			if ( IsValid( owner ) )
			{
				if ( refundZipline.value )
				{
					entity ziplineWeapon = owner.GetOffhandWeapon( OFFHAND_ULTIMATE )
					if ( IsValid(ziplineWeapon) )
					{
						int clipSize = ziplineWeapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
						ziplineWeapon.SetWeaponPrimaryClipCount( clipSize )
					}
				}
			}

			if ( IsValid( startModel ) )
			{
				EmitSoundAtPosition( TEAM_UNASSIGNED, startModel.GetOrigin(), "coop_sentrygun_explode", startModel )
				PlayFX( ZIPLINE_STATION_EXPLOSION, startModel.GetOrigin() )
				CreatePhysExplosion( startModel.GetOrigin(), 50, PHYS_EXPLOSION_LARGE, 11 )
				entity shake = CreateShake( startModel.GetOrigin(), 5, 150, 1, 200 )
				shake.kv.spawnflags = 4 // SF_SHAKE_INAIR
				startModel.Destroy()
			}

			if ( IsValid( endModel ) )
			{
				EmitSoundAtPosition( TEAM_UNASSIGNED, endModel.GetOrigin(), "coop_sentrygun_explode", endModel )
				PlayFX( ZIPLINE_STATION_EXPLOSION, endModel.GetOrigin() )
				CreatePhysExplosion( endModel.GetOrigin(), 50, PHYS_EXPLOSION_LARGE, 11 )
				entity shake = CreateShake( endModel.GetOrigin(), 5, 150, 1, 200 )
				shake.kv.spawnflags = 4 // SF_SHAKE_INAIR
				endModel.Destroy()
			}

			if ( IsValid( ziplineStart ) )
			{
				ziplineStart.Destroy()
			}

			if ( IsValid( ziplineEnd ) )
			{
				ziplineEnd.Destroy()
			}
		}
	)

	if ( IsValid( startModel ) )
	{
		EndSignal( startModel, "OnDestroy" )
	}

	if ( IsValid( endModel ) )
	{
		EndSignal( endModel, "OnDestroy" )
	}

	if ( IsValid( ziplineStart ) )
	{
		EndSignal( ziplineStart, "OnDestroy" )
	}

	if ( IsValid( ziplineEnd ) )
	{
		EndSignal( ziplineEnd, "OnDestroy" )
	}

	wait ZIPLINE_REFUND_TIME

	refundZipline.value = false

	WaitForever()
}

void function CreateGunZipline( entity weapon, vector startPos, vector endPos, vector startBasePos, vector endBasePos, entity startModel, entity endModel )
{
	vector delta     = startPos - endPos
	vector direction = Normalize( delta )
	float steepness  = fabs( direction.z )
	bool isSteep     = steepness > 0.7 ? true : false

	entity zipline_start = CreateEntity( "zipline" )
	file.pathfinderZiplines.append( zipline_start )
	if ( IsZiplinePlacedByPathfinder( zipline_start ) )
	    zipline_start.kv.Material = "cable/zipline_active"

	zipline_start.RemoveFromAllRealms()
	zipline_start.AddToOtherEntitysRealms( weapon )
	zipline_start.kv.ZiplineAutoDetachDistance = ZIPLINE_AUTO_DETACH_DISTANCE
	zipline_start.kv._zipline_rest_point_0 = startPos.x + " " + startPos.y + " " + startPos.z
	zipline_start.kv._zipline_rest_point_1 = endPos.x + " " + endPos.y + " " + endPos.z
	zipline_start.kv.ZiplineBreakable = 1
	zipline_start.kv.ZiplineBreakableBasePosition = startBasePos.x + " " + startBasePos.y + " " + startBasePos.z
	zipline_start.kv.ZiplineVertical = isSteep
	zipline_start.kv.ZiplinePreserveVelocity = isSteep

	zipline_start.SetParent( startModel, "ATTACH_TOP_ROPE", false, 0.0 )

	entity owner = weapon.GetWeaponOwner()
	if ( IsValid( owner ) )
		zipline_start.SetOwner( owner )


	                    
		ZiplineShield_TryStart( owner, zipline_start, startPos, endPos )
       

	entity zipline_end = CreateEntity( "zipline_end" )
	zipline_end.RemoveFromAllRealms()
	zipline_end.AddToOtherEntitysRealms( weapon )
	zipline_end.kv.ZiplineAutoDetachDistance = ZIPLINE_AUTO_DETACH_DISTANCE
	zipline_end.kv.ZiplineBreakableBasePosition = endBasePos.x + " " + endBasePos.y + " " + endBasePos.z
	zipline_end.SetParent( endModel, "ATTACH_TOP_ROPE", false, 0.0 )

	zipline_start.LinkToEnt( zipline_end )
	zipline_start.Zipline_WakeUp()

	DispatchSpawn( zipline_start )
	DispatchSpawn( zipline_end )
	zipline_start.SetScriptName( ZIPLINE_START_SCRIPTNAME )

	if ( IsValid( owner.Zipline_GetBeginStation() ) && (owner.Zipline_GetBeginStation() == startModel) )
	{
		owner.Zipline_SetBeginStation( null, ATTACHMENTID_INVALID )
	}

	thread OnZiplineDestroyed( owner, startModel, endModel, zipline_start, zipline_end )

	AddNewLimitedLegendObject(owner, zipline_start, ZIPLINE_MAX_IN_WORLD )
}

bool function IsZiplinePlacedByPathfinder( entity zipline )
{
	return file.pathfinderZiplines.contains( zipline )
}

#endif

bool function CanTetherEntities( entity startEnt, entity endEnt )
{
	TraceResults traceResult = TraceLine( startEnt.GetOrigin(), endEnt.GetOrigin(), [], TRACE_MASK_NPCWORLDSTATIC, TRACE_COLLISION_GROUP_NONE )
	if ( traceResult.fraction < 1 )
		return false

	return true
}


void function OnProjectileCollision_weapon_zipline( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	#if SERVER
		bool ziplineStationSuccessfullyDeployed = false
		entity weapon

		entity owner = projectile.GetOwner()
		if ( IsValid( owner ) )
		{
			if ( owner.IsPlayer() )
			{
				if ( "weapon" in projectile.s )
				{
					weapon = expect entity( projectile.s.weapon )
					if ( IsValid( weapon ) )
					{
						entity ziplineStartModel = weapon.w.ziplineStartModel
						if ( IsValid( ziplineStartModel ) )
						{
							ziplineStartModel.RemoveFromAllRealms()
							ziplineStartModel.AddToOtherEntitysRealms( owner )
							if ( IsValid( weapon.w.ziplineStartPos ) )
							{
								ZiplineStationSpots ornull spotsOrNull = Zipline_FindZiplineStationSpotsForProjectile( projectile, hitEnt, normal, ziplineStartModel.GetOrigin(), ziplineStartModel.GetAngles() )
								if ( spotsOrNull )
								{
									ZiplineStationSpots spots = expect ZiplineStationSpots( spotsOrNull )
									vector startPos           = expect vector( weapon.w.ziplineStartPos )

									// Create anchor model and zipline
									entity ziplineEndModel = CreatePropDynamic( spots.endStationModel, spots.endStationOrigin, spots.endStationAngles )
									ziplineEndModel.RemoveFromAllRealms()
									ziplineEndModel.AddToOtherEntitysRealms( owner )
									ziplineEndModel.SetParent( spots.endStationMoveParent, "", true, 0.0 )
									ziplineEndModel.RemoveOnMovement() // This will make the station destroy itself if it is moved (i.e., its parent moved)
									CreateGunZipline( weapon, spots.beginZiplineOrigin, spots.endZiplineOrigin, spots.beginStationOrigin, spots.endStationOrigin, ziplineStartModel, ziplineEndModel )
									if ( spots.endStationAnimation.len() > 0 )
										ziplineEndModel.Anim_PlayOnly( spots.endStationAnimation )
									weapon.w.ziplineStartPos = null

									ziplineStationSuccessfullyDeployed = true

									StopSoundOnEntity( ziplineStartModel, ZIPLINE_EXTENSION_SOUND )
									//EmitSoundFromLine( spots.beginZiplineOrigin, spots.endZiplineOrigin, ZIPLINE_USABLE_SOUND, weapon )
									#if DEV
									if ( DEBUG_ZIPLINE_AUDIO_LINE )
										DebugDrawLine( spots.beginZiplineOrigin, spots.endZiplineOrigin, COLOR_MAGENTA, true, 10.0 )
									#endif
								}
							}
						}
					}
				}
			}
		}

		if ( !ziplineStationSuccessfullyDeployed )
		{
			if ( IsValid( weapon ) )
			{
				weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
			}

			foreach( groupEnt in projectile.proj.projectileGroup )
			{
				if ( IsValid( groupEnt ) )
				{
					groupEnt.Destroy()
				}
			}
		}

		if ( IsValid( weapon ) )
		{
			weapon.w.ziplineGrenadeCollided = true
		}
		projectile.Destroy()
	#endif
}


#if CLIENT
void function OnCreateClientOnlyModel_weapon_zipline( entity weapon, entity model, bool validHighlight )
{
	if ( validHighlight )
	{
		DeployableModelHighlight( model )
	}
	else
	{
		DeployableModelInvalidHighlight( model )
	}
	if ( !file.weaponAlreadyActive )
    	thread WeaponActiveVFXThread_Client( weapon )
}

void function WeaponActiveVFXThread_Client( entity weapon )
{
	file.weaponAlreadyActive = true
	entity owner = weapon.GetOwner()
	owner.EndSignal( "OnDestroy" )
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( "ClearZiplineUI" )

	var overlayRui = CreateCockpitPostFXRui( $"ui/zipline_placement.rpak", HUD_Z_BASE )
	RuiSetVisible( overlayRui, false )
	RuiSetBool( overlayRui, "useWeaponCycleToCancel", GetKeyCodeForBinding( "weaponCycle", IsControllerModeActive().tointeger() ) != -1 )

	int fxId = GetParticleSystemIndex( TEMP_ZIPLINE_RANGE_FX )
	int pulseVFX  = StartParticleEffectOnEntity( owner, fxId, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	float ziplineRange =  GetWeaponInfoFileKeyField_WithMods_GlobalFloat( weapon.GetWeaponClassName(), weapon.GetMods(), "zipline_distance_max" )
	EffectSetControlPointVector( pulseVFX, 1, <ziplineRange, 0, 0> )

	OnThreadEnd(
		function() : ( weapon, overlayRui, pulseVFX )
		{
			if( IsValid( weapon ) )
				RuiDestroyIfAlive( overlayRui )
			if ( EffectDoesExist( pulseVFX ) )
				EffectStop( pulseVFX, false, true )
			file.weaponAlreadyActive = false
		}
	)

	while( true )
	{
		RuiSetVisible( overlayRui, true )
		WaitFrame()
	}
}
#endif

#if SERVER
void function WeaponMakesZipline( entity weapon, entity grenade, int weaponOwnerTeam )
{
	// Only if the player is on the ground and the grenade is valid

	//Temp fix for a script error. The weapon will be overhauled and this variable will no longer be necessary.
	//Assert( weapon.w.ziplineStartPos == null )
	if ( weapon.w.ziplineStartPos != null )
		weapon.w.ziplineStartPos = null
	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( grenade ) )
		return
	if ( !player.IsOnGround() && !player.IsWallRunning() && !player.IsWallHanging() )
		return

	entity groundEntity = player.GetGroundEntity()
	if ( !IsValid( groundEntity ) )
		return

	if ( groundEntity.IsMarkedForDeletion() )
		return

	if ( groundEntity.GetClassName() == "entity_blocker" )
		return

	if ( !IsAllowedToAttachZiplines( groundEntity ) )
		return

	// Create the base of the zip line at the player position
	vector beginStationOrigin = weapon.GetBeginStationOriginForZiplineGrenade( player )
	vector beginStationAngles = weapon.GetBeginStationAnglesForZiplineGrenade( player )
	entity beginStation = CreateZipLineStation( weapon, player, beginStationOrigin, beginStationAngles, grenade )
	if ( !IsValid( groundEntity ) || groundEntity.IsMarkedForDeletion() )
	{
		beginStation.Destroy()
		return
	}

	beginStation.RemoveFromAllRealms()
	beginStation.AddToOtherEntitysRealms( grenade )
	beginStation.SetParent( groundEntity, "", true, 0.0 )
	beginStation.RemoveOnMovement() // This will make the station destroy itself if it is moved (i.e., its parent moved)
	beginStation.Anim_PlayOnly( "prop_pathfinder_zipline_release" )

	int beginStationRopeIndex = beginStation.LookupAttachment( "ATTACH_TOP_ROPE" )
	vector startPos           = beginStation.GetAttachmentOrigin( beginStationRopeIndex )

	weapon.w.ziplineStartPos = startPos
	weapon.w.ziplineStartModel = beginStation
	player.Zipline_SetBeginStation( beginStation, beginStationRopeIndex ) // Tells code to attach the other end of the temporary rope on the grenade to this station

	EmitSoundOnEntityToTeam( beginStation, ZIPLINE_EXTENSION_SOUND, weaponOwnerTeam )
}

entity function CreateZipLineStation( entity weapon, entity player, vector origin, vector angles, entity projectile )
{
	asset modelAsset = ZIPLINE_TEMP_ZIPLINE_GUN_STATION_MODEL
	if ( player.IsWallRunning() || player.IsWallHanging() )
	{
		// If we are on a wall we make an anchor on the wall
		modelAsset = ZIPLINE_TEMP_ZIPLINE_GUN_STATION_WALL_MODEL
	}

	// If we are on the ground we make a pole station
	entity model = CreatePropDynamic( modelAsset, origin, angles, 0 )
	projectile.proj.projectileGroup.append( model )

	MarkEntForCleanupOnRoundEnd( model )
	FiringRange_AddToPermanentDeployableQuota( model, player )

	return model
}

#endif // SERVER

void function OnWeaponRaise_weapon_zipline( entity weapon )
{
	weapon.EmitWeaponSound_1p3p( "pathfinder_zipline_predeploy", "pathfinder_zipline_predeploy" )
}

void function OnWeaponDeactivate_weapon_zipline( entity weapon )
{
	#if CLIENT
	weapon.Signal( "ClearZiplineUI" )
	#endif
}