global function MpWeaponMountedTurretPlaceable_Init

global function OnWeaponOwnerChanged_weapon_mounted_turret_placeable
global function OnWeaponAttemptOffhandSwitch_weapon_mounted_turret_placeable
global function OnWeaponPrimaryAttack_weapon_mounted_turret_placeable
global function OnWeaponActivate_weapon_mounted_turret_placeable
global function OnWeaponDeactivate_weapon_mounted_turret_placeable

global function MountedTurretPlaceable_SetEligibleForRefund

#if CLIENT
global function OnCreateClientOnlyModel_weapon_mounted_turret_placeable
global function ServerCallback_PlayTurretDestroyFX
#endif

#if SERVER
global function MountedTurretPlaceable_IsUsingMountedTurret
global function MountedTurretPlaceable_Disable
global function MountedTurretPlaceable_GetLastAmmoCount
global function MountedTurretPlaceable_SetLastAmmoCount
global function MountedTurretPlaceable_ForceDestroy
global function MountedTurretPlaceable_ClearDriver_ForTurretUseDone
global function MountedTurretPlaceable_ClearDriver_ForTurretDestroyed
global function MountedTurretPlaceable_ClearDriver_ForTurretDisabled
global function MountedTurretPlaceable_ClearDriver_ForDeployThreadIsFinished
global function MountedTurretPlaceable_ClearDriver_ForOtherReason
global function ClientCallback_TryPickupMountedTurret
global function MountedTurretPlaceable_GetAllTurretsInPlay

global function MountedTurretPlaceable_Deploy
#endif //SERVER

//$"mdl/barriers/sandbags_large_01.rmdl"
//$"mdl/barriers/sandbags_curved_01.rmdl"

global enum eTurretClearUserReason
{
	TURRET_USE_FINISHED,
	TURRET_DESTROYED,
	TURRET_DISABLED,
	DEPLOYTHREADFINISHED,
	OTHERREASON,

	_count
}

const asset CAMERA_RIG = $"mdl/props/editor_ref_camera/editor_ref_camera.rmdl"

const asset MOUNTED_TURRET_PLACEABLE_MODEL = $"mdl/props/rampart_turret/rampart_turret.rmdl"
const asset MOUNTED_TURRET_PLACEABLE_SHIELD_COL_MODEL = $"mdl/fx/sentry_turret_shield.rmdl"
const asset MOUNTED_TURRET_PLACEABLE_SHIELD_FX = $"P_anti_titan_shield_3P"
global const asset COLLISION_CYLINDER_MODEL = $"mdl/props/rampart_cover_wall_replacement/rampart_cover_wall_invisible_collision_40x15_phys.rmdl"
const asset MOUNTED_TURRET_VEHICLE_COLLISION_MODEL = $"mdl/props/rampart_turret_vehicle_clip/rampart_turret_vehicle_clip_static.rmdl"

global const string MOUNTED_TURRET_PLACEABLE_WEAPON_NAME = "mp_weapon_mounted_turret_placeable"
global const string MOUNTED_TURRET_PLACEABLE_SCRIPT_NAME = "mounted_turret_placeable"
const string MOUNTED_TURRET_PLACEABLE_ENT_NAME = "rampart_turret"

const int MOUNTED_TURRET_PLACEABLE_MAX_TURRETS = 3

const float MOUNTED_TURRET_PLACEABLE_NO_SPAWN_RADIUS = 256.0
const float MOUNTED_TURRET_PLACEABLE_ICON_HEIGHT = 48.0
const int MOUNTED_TURRET_PLACEABLE_MAX_HEALTH = 350

const float TURRET_AMMO_REFUND_ON_PICKUP_FRAC = 0.5

const float EMP_DISABLE_DURATION = 15

//TURRET PLACEMENT VARS
const float MOUNTED_TURRET_PLACEABLE_PLACEMENT_RANGE_MAX = 92
const float MOUNTED_TURRET_PLACEABLE_PLACEMENT_RANGE_MIN = 32
const vector MOUNTED_TURRET_PLACEABLE_BOUND_MINS = <-8,-8,-8>
const vector MOUNTED_TURRET_PLACEABLE_BOMB_BOUND_MAXS = <8,8,8>
const vector MOUNTED_TURRET_PLACEABLE_PLACEMENT_TRACE_OFFSET = <0,0,128>
const float MOUNTED_TURRET_PLACEABLE_ANGLE_LIMIT = 0.55
const float MOUNTED_TURRET_PLACEABLE_PLACEMENT_MAX_HEIGHT_DELTA = 32.0


const bool MOUNTED_TURRET_PLACEABLE_DEBUG_DRAW_PLACEMENT = false


// FX
const FX_EMP_TURRET					= $"P_emp_body_human"
const TURRET_BASE_DESTROYED_FX		= $"P_rampart_turret_base_dest"
const TURRET_GUN_DESTROYED_FX		= $"P_rampart_turret_dest"
const TURRET_DESTROYED_GUN_ATTACH	= "__illumPosition"
const TURRET_DAMAGE_FX_3P			= $"P_rampart_turret_dmg"
const TURRET_PLACEABLE_RANGE_FX 	= $"P_Rampart_Turret_Range_AR"

// AUDIO
const TURRET_DAMAGED_3P 			= "Turret_Ignite_Burn"
const MOUNT_TURRET_1P 				= "weapon_sheilaturret_mount_1p"
const MOUNT_TURRET_3P				= "weapon_sheilaturret_mount_3p"
const DISMOUNT_TURRET_3P 			= "weapon_sheilaturret_dismount_3p"


// DIALOGUE
const float TURRET_DESTROYED_CALLOUT_MIN_DIST = 1024

struct MountedTurretPlaceablePlacementInfo
{
	vector origin
	vector angles
	entity parentTo
	bool success = false
}

struct MountedTurretPlaceablePlayerPlacementData
{
	vector viewOrigin	//The player's view origin when they placed the trap.
	vector viewForward	//The player's view forward when they placed the trap.
	vector playerOrigin //The player's world origin when they placed the trap.
	vector playerForward //The player's world forward when they placed the trap.
}

struct
{
	#if SERVER
		table< entity, bool > isTurretEnabled
		table< entity, int > turretToLastAmmoCount
		array < entity > placedTurrets
	#endif

	#if CLIENT
		bool isShowingPlacementFX
	#endif
	table< entity, bool > turretEligibleForRefund
	int maxNumTurretsDeployed
} file

void function MpWeaponMountedTurretPlaceable_Init()
{
	MountedTurretPlaceable_Precache()

	file.maxNumTurretsDeployed = GetCurrentPlaylistVarInt( "rampart_max_turrets_deployed", MOUNTED_TURRET_PLACEABLE_MAX_TURRETS )

	Remote_RegisterServerFunction( "ClientCallback_TryPickupMountedTurret", "typed_entity", "turret" )

	RegisterSignal( "EnterMountedTurret" )

	#if SERVER
		RegisterDynamicEntCleanupItem_Parented_Scriptname( MOUNTED_TURRET_PLACEABLE_SCRIPT_NAME, MountedTurretPlaceable_ForceDestroy )
		RegisterDynamicEntCleanupItem_Area_Scriptname( MOUNTED_TURRET_PLACEABLE_SCRIPT_NAME, MountedTurretPlaceable_ForceDestroy )
		AddCallback_OnClientDisconnected( MountedTurretPlaceable_OnPlayerDisconnected )
		AddCallback_OnPlayerPositionReset( OnPlayerPositionReset )
		Survival_AddCallback_OnPlayerKillDamage( OnPlayerKillDamage )
		Bleedout_AddCallback_CleanupUtilitySlot( MountedTurretPlaceable_CleanupUtilitySlot )
	#endif // SERVER

	#if CLIENT
		// health FX
		ModelFX_BeginData( "turretDamage", MOUNTED_TURRET_PLACEABLE_MODEL, "all", true )
		ModelFX_AddTagHealthFX( 0.50, "__illumPosition", TURRET_DAMAGE_FX_3P, false )
		ModelFX_EndData()

		RegisterConCommandTriggeredCallback( "+scriptCommand5", OnCharacterButtonPressed )
		AddCallback_UseEntGainFocus( MountedTurretPlaceable_OnGainFocus )
		AddCallback_UseEntLoseFocus( MountedTurretPlaceable_OnLoseFocus )

		//RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.RAMPART_TURRET, MINIMAP_OBJECT_RUI, MinimapPackage_RampartGun, FULLMAP_OBJECT_RUI, MinimapPackage_RampartGun )
	#endif // CLIENT
}

#if SERVER
void function OnPlayerPositionReset( entity player )
{
	if ( player.IsPlayer() && IsValid( player.p.mountedTurretEnt ) )
		MountedTurretPlaceable_ClearDriver_ForOtherReason( player.p.mountedTurretEnt )

	entity turretProxy = player.p.mountedTurretEnt

	if ( IsValid( turretProxy ) )
		turretProxy.Signal( "MountedTurretPlaceable_PlayerLeave" )
}
#endif

void function MountedTurretPlaceable_Precache()
{
	RegisterSignal( "MountedTurretPlaceable_PickedUp" )
	RegisterSignal( "MountedTurretPlaceable_Active" )
	RegisterSignal( "MountedTurretPlaceable_PlayerLeave" )

	PrecacheModel( MOUNTED_TURRET_PLACEABLE_MODEL )
	PrecacheModel( MOUNTED_TURRET_PLACEABLE_SHIELD_COL_MODEL )
	PrecacheModel( CAMERA_RIG )
	PrecacheModel( COLLISION_CYLINDER_MODEL )
	PrecacheModel( MOUNTED_TURRET_VEHICLE_COLLISION_MODEL )

	PrecacheParticleSystem( MOUNTED_TURRET_PLACEABLE_SHIELD_FX )
	PrecacheParticleSystem( TURRET_DAMAGE_FX_3P )
	PrecacheParticleSystem( TURRET_BASE_DESTROYED_FX )
	PrecacheParticleSystem( TURRET_GUN_DESTROYED_FX )
	PrecacheParticleSystem( TURRET_PLACEABLE_RANGE_FX )

	#if SERVER
		BleedoutState_AddCallback_OnPlayerBleedoutStateChanged( MountedTurretPlaceable_OnPlayerBleedoutStateChanged )
	#endif

	#if CLIENT
		RegisterSignal( "MountedTurretPlaceable_StopPlacementProxy" )

		AddCreateCallback( "turret", MountedTurretPlaceable_OnTurretCreated )
		AddDestroyCallback( "turret", MountedTurretPlaceable_OnTurretDestroyed )
	#endif
}

void function OnWeaponOwnerChanged_weapon_mounted_turret_placeable( entity weapon, WeaponOwnerChangedParams changeParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	if ( !IsValid( weaponOwner ) )
		return

	if ( !weaponOwner.IsPlayer() )
		return
}

#if CLIENT
void function OnCreateClientOnlyModel_weapon_mounted_turret_placeable( entity weapon, entity model, bool validHighlight )
{
	if ( validHighlight )
	{
		DeployableModelHighlight( model )
		if (!file.isShowingPlacementFX)
			thread ShowPlacementFX( weapon, model )
	}
	else
	{
		DeployableModelInvalidHighlight( model )
	}
}

void function ShowPlacementFX( entity weapon, entity model )
{
	if ( !IsValid(weapon.GetOwner()) )
		return

	weapon.GetOwner().EndSignal( "MountedTurretPlaceable_StopPlacementProxy" )

	file.isShowingPlacementFX = true

	//int proxyRadiusFx = StartParticleEffectOnEntity( model, GetParticleSystemIndex( TURRET_PLACEABLE_RANGE_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	//EffectSetControlPointVector( proxyRadiusFx, 1, <50, 0, 0> )

	OnThreadEnd(
		function() : (  )
		{
			file.isShowingPlacementFX = false

			//if ( EffectDoesExist( proxyRadiusFx ) )
			//	EffectStop( proxyRadiusFx, true, true )
		}
	)

	WaitForever()
}

void function ServerCallback_PlayTurretDestroyFX( vector baseOrigin, vector baseAngles, vector gunOrigin, vector gunAngles )
{
	int baseFxID = GetParticleSystemIndex( TURRET_BASE_DESTROYED_FX )
	int gunFxID = GetParticleSystemIndex( TURRET_GUN_DESTROYED_FX )

	StartParticleEffectInWorld( baseFxID, baseOrigin, baseAngles )
	StartParticleEffectInWorld( gunFxID, gunOrigin, gunAngles )
}
#endif // CLIENT

void function OnWeaponActivate_weapon_mounted_turret_placeable( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	weapon.w.startChargeTime = Time()

	Assert( ownerPlayer.IsPlayer() )
	#if CLIENT
		if ( ownerPlayer != GetLocalViewPlayer() )
			return

		AddPlayerHint( 120, 0, $"", "#WPN_MOUNTED_TURRET_PLAYER_DEPLOY_HINT" )

		if ( !InPrediction() ) //Stopgap fix for Bug 146443
			return
	#endif

	#if SERVER
		AddButtonPressedPlayerInputCallback( ownerPlayer, IN_OFFHAND1, MountedTurretPlaceable_CancelPlacement )
		weapon.RemoveMod( MOBILE_HMG_FAST_SWITCH_MOD )
		weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
	#endif
}


void function OnWeaponDeactivate_weapon_mounted_turret_placeable( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )
	#if CLIENT
		if ( ownerPlayer != GetLocalViewPlayer() )
			return

		HidePlayerHint( "#WPN_MOUNTED_TURRET_PLAYER_DEPLOY_HINT" )

		if ( !InPrediction() ) //Stopgap fix for Bug 146443
			return
	#endif

	#if SERVER
		RemoveButtonPressedPlayerInputCallback( ownerPlayer, IN_OFFHAND1, MountedTurretPlaceable_CancelPlacement )
	#endif
}

var function OnWeaponPrimaryAttack_weapon_mounted_turret_placeable( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if SERVER
		// Calculate placement info inline since GetObjectPlacement methods don't exist
		vector eyePos = ownerPlayer.EyePosition()
		vector viewVec = ownerPlayer.GetViewVector()
		vector angles = < 0, VectorToAngles( viewVec ).y, 0 >
		viewVec = AnglesToForward( angles )

		float maxRange = MOUNTED_TURRET_PLACEABLE_PLACEMENT_RANGE_MAX
		TraceResults viewTraceResults = TraceLine( eyePos, eyePos + viewVec * maxRange, [ownerPlayer], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )

		vector origin
		if ( viewTraceResults.fraction < 1.0 )
			origin = viewTraceResults.endPos
		else
			origin = eyePos + viewVec * maxRange

		// No parent entity support in this version
		entity parentTo = null

		thread MountedTurretPlaceable_Deploy( weapon, ownerPlayer, origin, angles, parentTo )
	#endif

	PlayerUsedOffhand( ownerPlayer, weapon )
	return weapon.GetAmmoPerShot()
}

bool function OnWeaponAttemptOffhandSwitch_weapon_mounted_turret_placeable( entity weapon )
{
	return true
}

#if SERVER
void function MountedTurretPlaceable_CancelPlacement( entity player )
{

	if ( player.IsUsingOffhandWeapon( eActiveInventorySlot.mainHand ) )
	{
		entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

		if ( !IsValid( activeWeapon ) )
			return

		if ( activeWeapon.GetWeaponClassName() != "mp_weapon_mounted_turret_placeable" )
			return

		if ( activeWeapon.w.startChargeTime + 0.1 > Time() )
			return
	}
	else
	{
		return
	}


	SwapToLastEquippedPrimary( player )
}

void function MountedTurret_CreateVehicleCollision( entity turret, vector origin, vector angles )
{
	entity vehicleCollisionEnt = CreateEntity( "prop_dynamic" )
	vehicleCollisionEnt.SetValueForModelKey( MOUNTED_TURRET_VEHICLE_COLLISION_MODEL )
	vehicleCollisionEnt.kv.solid = SOLID_VPHYSICS
	vehicleCollisionEnt.kv.contents = CONTENTS_TITANCLIP
	vehicleCollisionEnt.SetOrigin( origin )
	vehicleCollisionEnt.SetAngles( angles )
	vehicleCollisionEnt.e.ignorePingTrace = true
	vehicleCollisionEnt.SetBlocksRadiusDamage( false )
	vehicleCollisionEnt.SetBlocksLOS( false )
	DispatchSpawn( vehicleCollisionEnt )
	vehicleCollisionEnt.Hide()
	vehicleCollisionEnt.SetParent( turret )
}

void function MountedTurretPlaceable_Deploy( entity weapon, entity owner, vector origin, vector angles, entity parentTo )
{
	if ( !IsValid( owner ) )
		return

	entity mountedTurr = CreateScriptMoverModel( MOUNTED_TURRET_PLACEABLE_MODEL, origin, angles )

	if ( IsValid( parentTo ) )
		mountedTurr.SetParent( parentTo )

	//owner.EndSignal( "OnDestroy" )
	//owner.EndSignal( "SquadEliminated" )

	int team           = owner.GetTeam()
	//turretProxy.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)	// everyone but owner
	//canisterProxy.kv.collisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	mountedTurr.DisableHibernation()
	mountedTurr.SetMaxHealth( MOUNTED_TURRET_PLACEABLE_MAX_HEALTH )
	mountedTurr.SetHealth( MOUNTED_TURRET_PLACEABLE_MAX_HEALTH )
	mountedTurr.SetDamageNotifications( false )
	mountedTurr.SetDeathNotifications( false )
	//mountedTurr.SetArmorType( ARMOR_TYPE_HEAVY )
	mountedTurr.SetScriptName( MOUNTED_TURRET_PLACEABLE_SCRIPT_NAME )
	mountedTurr.SetBlocksRadiusDamage( false )
	mountedTurr.SetTitle( "#WPN_MOUNTED_TURRET_PLACEABLE" )
	SetTargetName( mountedTurr, MOUNTED_TURRET_PLACEABLE_SCRIPT_NAME )
	mountedTurr.EndSignal( "OnDestroy" )
	mountedTurr.SetOwner( owner )
	mountedTurr.e.canBurn = true
	mountedTurr.e.noOwnerFriendlyFire = false
	mountedTurr.e.noFriendlyFireProtection = true
	mountedTurr.e.canBeDamagedFromGas = false
	mountedTurr.e.preventStickyEnts = true
	mountedTurr.RemoveFromAllRealms()
	mountedTurr.AddToOtherEntitysRealms( owner )
	SetTeam( mountedTurr, team )
	mountedTurr.EnableAttackableByAI( AI_PRIORITY_NO_THREAT, 0, AI_AP_FLAG_NONE )

	/*entity minimapObj = CreatePropScript( $"mdl/dev/empty_model.rmdl", mountedTurr.GetOrigin() )
	minimapObj.Minimap_SetCustomState( eMinimapObject_prop_script.RAMPART_TURRET )
	minimapObj.Minimap_SetObjectScale( 1 )
	minimapObj.Minimap_SetAlignUpright( true )
	minimapObj.Minimap_SetClampToEdge( false )

	foreach( int enemyTeam in GetAllValidPlayerTeams() )
	{
		if ( enemyTeam == team )
			continue

		minimapObj.Minimap_Hide( enemyTeam, null )
	}

	minimapObj.Minimap_AlwaysShow( team, null )

	// If we are in a mode where we allow communication between players near each other that are on the same team (but not the same squad); show the icon to nearby teammates
	//AllianceProximity_SetMinimapAlwaysShow_ForAlliance( team, minimapObj, owner )

	minimapObj.SetParent( mountedTurr )
	minimapObj.Minimap_SetZOrder( MINIMAP_Z_OBJECT - 1 )*/

	mountedTurr.Solid()
	mountedTurr.AllowMantle()
	mountedTurr.SetForceVisibleInPhaseShift( true )

	file.isTurretEnabled[ mountedTurr ] <- true

	file.placedTurrets.append(mountedTurr)

	entity primaryUltWeapon = owner.GetOffhandWeapon( OFFHAND_ULTIMATE )
	if( IsValid( primaryUltWeapon ) )
	{
		file.turretEligibleForRefund[ mountedTurr ] <- false
		file.turretToLastAmmoCount[ mountedTurr ] <- primaryUltWeapon.GetWeaponPrimaryClipCountMax()
		primaryUltWeapon.SetWeaponPrimaryClipCount( 0 )
		MobileHMG_PlacementToggleEnabled( primaryUltWeapon, false )
	}

	//EmitSoundOnEntityOnlyToPlayer( mountedTurr, owner, "weapon_sentryfragdrone_pinpull_1p" )
	//EmitSoundOnEntityExceptToPlayer( mountedTurr, owner, "weapon_sentryfragdrone_pinpull_3p" )

	string noSpawnIdx = CreateNoSpawnArea( TEAM_INVALID, team, origin, -1.0, MOUNTED_TURRET_PLACEABLE_NO_SPAWN_RADIUS )
	mountedTurr.SetCanBeMeleed( true )
	SetVisibleEntitiesInConeQueriableEnabled( mountedTurr, false )
	thread TrapDestroyOnRoundEnd( owner, mountedTurr )

	PlayerObjects_CommonInit( owner, mountedTurr, true, "sp_friendly_hero", false, false, false, MountedTurretPlaceable_Disable )

	entity cylinder = CreatePropScript( COLLISION_CYLINDER_MODEL, origin, angles, SOLID_CAPSULE )
	InitCollisionCylinder( cylinder, owner, mountedTurr )

	MountedTurret_CreateVehicleCollision( mountedTurr, origin, angles )

	PIN_Interact( owner, "rampart_turret_deployed", origin )

	OnThreadEnd(
	function() : ( owner, mountedTurr, noSpawnIdx )
		{
			if ( IsValid( owner ) && mountedTurr != null )
				TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_TURRET, mountedTurr, mountedTurr.GetOrigin(), owner.GetTeam(), owner )

			DeleteNoSpawnArea( noSpawnIdx )

			if ( mountedTurr != null )
			{
				MountedTurretPlaceable_ClearDriver_ForDeployThreadIsFinished( mountedTurr )
				StopSoundOnEntity( mountedTurr, TURRET_DAMAGED_3P )
			}

			if ( IsValid( owner ) )
			{
				for ( int i=owner.e.mountedTurrets.len()-1; i>=0 ; i-- )
				{
					if ( owner.e.mountedTurrets[i] == mountedTurr )
					{
						owner.e.mountedTurrets.remove( i )
					}
				}
			}

			if(file.placedTurrets.contains(mountedTurr))
			{
				file.placedTurrets.fastremovebyvalue(mountedTurr)
			}

			if ( IsValid( mountedTurr ) )
			{
				mountedTurr.Destroy()
			}

		}
	)

	mountedTurr.EndSignal( "OnDestroy" )
	mountedTurr.EndSignal( "MountedTurretPlaceable_PickedUp" )

	thread MountedTurretPlaceable_WaitForUse( mountedTurr )

	mountedTurr.SetTakeDamageType( DAMAGE_YES )
	AddEntityCallback_OnDamaged( mountedTurr, MountedTurretPlaceable_OnDamaged )
	AddEntityCallback_OnPostDamaged( mountedTurr, MountedTurretPlaceable_OnPostDamaged )

	thread Turret_CheckForGeoIntersection( mountedTurr )





	owner.e.mountedTurrets.insert( 0, mountedTurr )

	while ( owner.e.mountedTurrets.len() > file.maxNumTurretsDeployed )
	{
		entity entToDelete = owner.e.mountedTurrets.pop()
		if ( IsValid( entToDelete ) )
		{
			entToDelete.TakeDamage( MOUNTED_TURRET_PLACEABLE_MAX_HEALTH + 10, owner, owner, { scriptType = DF_NO_HITBEEP } )
			entToDelete.Destroy()
		}
	}

	PlayBattleChatterLineToSpeakerAndTeam( owner, "bc_super" )
	MountedTurretWeapon_SetPlayerLastSaidTurretChatterTime( owner, Time() )

	WaitForever()
}

array <entity> function MountedTurretPlaceable_GetAllTurretsInPlay()
{
	ArrayRemoveInvalid(file.placedTurrets)
	return file.placedTurrets
}

void function Turret_CheckForGeoIntersection( entity turretProxy )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	turretProxy.EndSignal( "OnDestroy" )

	float startTime = Time()

	float turretDepth = 16 // from middle origin to forward edge
	float turretWidth = 16 // from middle origin to side edge
	float turretHeight = 58 // from bottom origin to top
	float heightOffGround = 25

	while ( true )
	{
		array<entity> ignoreEnts = GetPlayerArray_Alive()
		ignoreEnts.append( turretProxy )

		vector up = turretProxy.GetUpVector()

		vector startPos = turretProxy.GetOrigin() + up * heightOffGround
		vector endPos   = startPos + up // traces one unit upwards

		TraceResults results = TraceHull( startPos, endPos, <-turretWidth, -turretDepth, 0>, <turretWidth, turretDepth, turretHeight - heightOffGround>, ignoreEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
		//DebugDrawBox( results.endPos, <-turretWidth,-turretDepth,0>, <turretWidth,turretDepth,turretHeight - heightOffGround>, COLOR_GREEN, 1, 1.0 ) //Forward Hull Cast Bounding Box
		//PrintTraceResults( results )
		if ( results.startSolid )
		{
			entity hitEnt = results.hitEnt
			if ( IsValid( hitEnt ) )
			{
				string hitEntClassname = hitEnt.GetClassName()

				if ( hitEntClassname == "worldspawn" || hitEntClassname == "phys_bone_follower" || hitEntClassname == "func_brush" || hitEntClassname == "script_mover" || hitEntClassname == "func_brush_lightweight" || hitEntClassname == "prop_dynamic" )
				{
					entity driver = turretProxy.GetOwner()

					if ( IsValid( driver ) && driver.IsPlayer() && IsAlive( driver ) )
						MountedTurretPlaceable_ClearDriver_ForTurretDestroyed( turretProxy )

					DestroyTurretFX( turretProxy, null )
					turretProxy.Destroy()
				}
			}
		}

		wait 0.25
	}
}

void function InitCollisionCylinder( entity cylinder, entity owner, entity turret )
{
	cylinder.kv.collisionGroup = TRACE_COLLISION_GROUP_PROJECTILE
	cylinder.DisableHibernation()
	cylinder.RemoveFromAllRealms()
	cylinder.AddToOtherEntitysRealms( owner )
	cylinder.SetTakeDamageType( DAMAGE_NO )
	cylinder.Solid()
	cylinder.SetParent( turret )
	cylinder.SetBlocksLOS( false )
}

void function MountedTurretPlaceable_WaitForUse( entity turretProxy )
{
	Assert( IsNewThread(), "Must be threaded off." )
	turretProxy.EndSignal( "OnDestroy" )
	turretProxy.EndSignal( "MountedTurretPlaceable_PickedUp" )
	turretProxy.EndSignal( "MountedTurretPlaceable_Active" )

	OnThreadEnd(
		function() : ( turretProxy )
		{
			if ( IsValid( turretProxy ) )
			{
				turretProxy.UnsetUsable()
			}
		}
	)

	SetCallback_CanUseEntityCallback_Retail( turretProxy, MountedTurretPlaceable_CanUse )

	while( true )
	{

		turretProxy.SetUsable()
		turretProxy.SetUsablePriority( USABLE_PRIORITY_HIGH )
		turretProxy.SetUsableByGroup( "pilot" )
		turretProxy.AddUsableValue( USABLE_CUSTOM_HINTS )

		entity player = expect entity( turretProxy.WaitSignal( "OnPlayerUse" ).player )

		if ( !IsValid( player ) )
			continue

		//Titans cannot interact with turret.
		if ( player.IsTitan() )
			continue

		if ( !IsTurretEnabled( turretProxy ) )
			continue

		if ( player.ContextAction_IsActive() )
			continue

		if ( player.IsPhaseShiftedOrPending() )
			continue

		// Check if player has a valid weapon cuz GetTurretWeaponX doesn't exist in s3
		entity owner = turretProxy.GetOwner()
		if ( !IsValid( owner ) || !owner.IsPlayer() )
			continue

		entity playerWeapon = owner.GetActiveWeapon( eActiveInventorySlot.mainHand )
		if ( !IsValid( playerWeapon ) )
			continue

		waitthread MountedTurretPlaceable_UseGun( player, turretProxy )
		wait 1.0 //Afford player enough time to get off gun before making turret useable again.
	}
}

void function MountedTurretPlaceable_UseGun( entity player, entity turretProxy )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( turretProxy, "MountedTurretPlaceable_PlayerLeave" )
	EndSignal( turretProxy, "OnDestroy" )

	//Cubemap_CleanupUtilitySlot( player )

	turretProxy.UnsetUsable()

	entity driver = turretProxy.GetOwner()

	Assert ( !IsValid( driver ) )

	if ( ! IsValid( player ) || !IsAlive( player ) )
		return

	player.Signal( "EnterMountedTurret" )

	player.p.mountedTurretEnt = turretProxy

	EmitSoundOnEntityExceptToPlayer( player, player, MOUNT_TURRET_3P )
	EmitSoundOnEntityOnlyToPlayer( player, player, MOUNT_TURRET_1P )

	AddButtonPressedPlayerInputCallback( player, IN_USE_LONG, MountedTurretPlaceable_PlayerLeaveTurret )
	AddButtonPressedPlayerInputCallback( player, IN_WEAPON_CYCLE, MountedTurretPlaceable_PlayerLeaveTurret )
	AddButtonPressedPlayerInputCallback( player, IN_DUCK, MountedTurretPlaceable_PlayerLeaveTurret )
	AddButtonPressedPlayerInputCallback( player, IN_DUCKTOGGLE, MountedTurretPlaceable_PlayerLeaveTurret )
	AddButtonPressedPlayerInputCallback( player, IN_JUMP, MountedTurretPlaceable_PlayerLeaveTurret )

	player.ContextAction_SetBusy()

	OnThreadEnd(
		function() : ( player, turretProxy )
		{
			if ( IsValid( turretProxy ) )
			{
				if ( IsValid( player ) )
				{
				if ( IsValid( player.p.mountedTurretEnt ) && player.p.mountedTurretEnt == turretProxy )
						EmitSoundOnEntityExceptToPlayer( turretProxy, player, DISMOUNT_TURRET_3P )
				}

				MountedTurretPlaceable_ClearDriver_ForTurretUseDone( turretProxy )
			}

			if ( IsValid( player ) )
			{
				RemoveButtonPressedPlayerInputCallback( player, IN_USE_LONG, MountedTurretPlaceable_PlayerLeaveTurret )
				RemoveButtonPressedPlayerInputCallback( player, IN_WEAPON_CYCLE, MountedTurretPlaceable_PlayerLeaveTurret )
				RemoveButtonPressedPlayerInputCallback( player, IN_DUCK, MountedTurretPlaceable_PlayerLeaveTurret )
				RemoveButtonPressedPlayerInputCallback( player, IN_DUCKTOGGLE, MountedTurretPlaceable_PlayerLeaveTurret )
				RemoveButtonPressedPlayerInputCallback( player, IN_JUMP, MountedTurretPlaceable_PlayerLeaveTurret )
				player.p.mountedTurretEnt = null

				if( player.IsInputCommandHeld( IN_USE_LONG ) )
					AddButtonReleasedPlayerInputCallback( player, IN_USE_LONG, MountedTurretPlaceable_ClearBusy )
				else
					player.ContextAction_ClearBusy()

				StopSoundOnEntity( player, MOUNT_TURRET_3P )
				StopSoundOnEntity( player, MOUNT_TURRET_1P )
			}
		}
	)

	WaitForever()
}

void function MountedTurretPlaceable_ClearBusy( entity player )
{
	if( IsValid( player ) && player.ContextAction_IsBusy() )
		player.ContextAction_ClearBusy()
	RemoveButtonReleasedPlayerInputCallback( player, IN_USE_LONG, MountedTurretPlaceable_ClearBusy )
}

void function MountedTurretPlaceable_Disable( entity turretProxy )
{
	if ( IsValid( turretProxy ) )
		thread DisableTurretForDuration( turretProxy )
}

void function DisableTurretForDuration( entity turretProxy )
{
	EndSignal( turretProxy, "OnDestroy" )

	thread EMP_FX( FX_EMP_TURRET, turretProxy, "muzzle_flash", EMP_DISABLE_DURATION )

	file.isTurretEnabled[ turretProxy ] <- false

	entity wp = CreatePlayerWaypoint( eWaypoint.DEVICE_DISABLED )
	wp.SetOrigin( turretProxy.GetOrigin() )
	wp.SetAngles( turretProxy.GetAngles() )
	wp.SetParent( turretProxy )
	wp.SetScriptName( DISABLE_WAYPOINT_SCRIPTNAME )
	wp.wp.waypointCreatedTime = Time()

	EndSignal( wp, "OnDestroy" )

	turretProxy.LinkToEnt( wp )

	OnThreadEnd(
		function() : ( turretProxy, wp )
		{
			if ( IsValid( wp ) )
			{
				wp.Destroy()
			}
			if ( IsValid( turretProxy ) )
			{
				file.isTurretEnabled[ turretProxy ] <- true
			}
		}
	)

	MountedTurretPlaceable_ClearDriver_ForTurretDisabled( turretProxy )

	if ( IsValid( turretProxy.GetOwner() ) )
		wp.SetOwner( turretProxy.GetOwner() )

	wait EMP_DISABLE_DURATION
}


void function MountedTurretPlaceable_PlayerLeaveTurret( entity player )
{
	entity turretProxy = player.p.mountedTurretEnt

	Assert( IsValid( turretProxy ), "Player is not currently using a mounted turret" )

	if ( IsValid( turretProxy ) )
	turretProxy.Signal( "MountedTurretPlaceable_PlayerLeave" )
}

void function MountedTurretPlaceable_ClearDriver_( entity turret, int turretClearUserReason )
{
	if ( !IsValid( turret ) )
		return
	if ( turret.GetScriptName() != MOUNTED_TURRET_PLACEABLE_SCRIPT_NAME )
		return

	entity driver = turret.GetOwner()

	turret.SetOwner( null )
}

void function MountedTurretPlaceable_ClearDriver_ForTurretUseDone( entity turret )
{
	MountedTurretPlaceable_ClearDriver_( turret, eTurretClearUserReason.TURRET_USE_FINISHED )
}
void function MountedTurretPlaceable_ClearDriver_ForTurretDestroyed( entity turret )
{
	MountedTurretPlaceable_ClearDriver_( turret, eTurretClearUserReason.TURRET_DESTROYED )
}
void function MountedTurretPlaceable_ClearDriver_ForTurretDisabled( entity turret )
{
	MountedTurretPlaceable_ClearDriver_( turret, eTurretClearUserReason.TURRET_DISABLED )
}
void function MountedTurretPlaceable_ClearDriver_ForDeployThreadIsFinished( entity turret )
{
	MountedTurretPlaceable_ClearDriver_( turret, eTurretClearUserReason.DEPLOYTHREADFINISHED )
}
void function MountedTurretPlaceable_ClearDriver_ForOtherReason( entity turret )
{
	MountedTurretPlaceable_ClearDriver_( turret, eTurretClearUserReason.OTHERREASON )
}

int function MountedTurretPlaceable_GetLastAmmoCount( entity turret )
{
	Assert ( turret in file.turretToLastAmmoCount, "Turret not in file table" )

	if ( turret in file.turretToLastAmmoCount )
		return file.turretToLastAmmoCount[ turret ]

	return 0
}

void function MountedTurretPlaceable_SetLastAmmoCount( entity turret, int ammoCount )
{
	file.turretToLastAmmoCount[ turret ] <- ammoCount
}

bool function MountedTurretPlaceable_IsUsingMountedTurret( entity player )
{
	return IsValid( player.p.mountedTurretEnt )
}

void function MountedTurretPlaceable_OnPlayerDisconnected( entity player )
{
	if ( IsValid_ThisFrame( player ) && player.IsPlayer() && IsValid( player.p.mountedTurretEnt ) )
	{
		MountedTurretPlaceable_ClearDriver_ForOtherReason( player.p.mountedTurretEnt )
	}
}

void function MountedTurretPlaceable_OnPlayerBleedoutStateChanged( entity player, int newState )
{
	if ( newState == BS_ENTERING_BLEEDOUT && MountedTurretPlaceable_IsUsingMountedTurret( player ) )
	{
		//Vehicle_KickPlayer_ForBleedout( player )
		MountedTurretPlaceable_PlayerLeaveTurret( player )
	}
}

void function OnPlayerKillDamage( entity player, var di, int actualTotalDamage )
{
	//if ( MountedTurretPlaceable_IsUsingMountedTurret( player ) )
		//Vehicle_KickPlayer_ForKilled( player )
}

void function MountedTurretPlaceable_CleanupUtilitySlot( entity player )
{
	entity turret = player.p.mountedTurretEnt
	if ( IsValid( turret ) )
	{
		MountedTurretPlaceable_ClearDriver_ForOtherReason( turret )
	}
}

void function MountedTurretPlaceable_ForceDestroy( entity turretProxy )
{
	turretProxy.TakeDamage( MOUNTED_TURRET_PLACEABLE_MAX_HEALTH + 10, turretProxy, turretProxy, null )
}

void function MountedTurretPlaceable_OnDamaged( entity turretProxy, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( turretProxy ) )
		return

	if ( !IsValid( attacker ) )
		return

	if ( IsWorldSpawn( attacker ) )
		return

	int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )

	//Two melees will destroy the turret
	if ( IsBitFlagSet( damageFlags, DF_EXPLOSION ) || IsBitFlagSet( damageFlags, DF_MELEE ) )
	{
		if ( IsBitFlagSet( damageFlags, DF_EXPLOSION ) )
		{
			int damageSourceIdentifier = DamageInfo_GetDamageSourceIdentifier( damageInfo )

			switch ( damageSourceIdentifier )
			{


				case eDamageSourceId.melee_shadowroyale_hands:
				case eDamageSourceId.melee_shadowsquad_hands:
				case eDamageSourceId.mp_weapon_shadow_squad_hands_primary:
					DamageInfo_SetDamage( damageInfo, MOUNTED_TURRET_PLACEABLE_MAX_HEALTH / 2 )
					DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
					break

				default:
					DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
			}
		}

		if ( IsBitFlagSet( damageFlags, DF_MELEE ) )
		{
			DamageInfo_SetDamage( damageInfo, MOUNTED_TURRET_PLACEABLE_MAX_HEALTH / 2 )
			DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
		}
	}
}

void function MountedTurretPlaceable_OnPostDamaged( entity turretProxy, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( turretProxy ) )
		return

	if ( !IsValid( attacker ) )
		return

	if ( IsWorldSpawn( attacker ) )
		return

	int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )

	float damage = DamageInfo_GetDamage( damageInfo )
	if ( damage <= 0 )
		return

	if ( damage >= turretProxy.GetHealth() )
	{
		MountedTurretPlaceable_ClearDriver_ForTurretDestroyed( turretProxy )
		DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
	}
	else
	{
		DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
	}

	if ( attacker.IsPlayer() && ( !IsBitFlagSet( damageFlags, DF_MELEE ) && !IsBitFlagSet( damageFlags, DF_NO_HITBEEP ) ) )
	{
		attacker.NotifyDidDamage( turretProxy, 0, DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ),
			damage, DamageInfo_GetDamageFlags( damageInfo ) | DF_NO_HITBEEP,
			DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
	}

	if ( turretProxy.GetHealth() - DamageInfo_GetDamage( damageInfo ) <= turretProxy.GetMaxHealth() / 2.0 )
	{
		if ( turretProxy.GetHealth() > turretProxy.GetMaxHealth()/2 )
		{
			EmitSoundOnEntity( turretProxy, TURRET_DAMAGED_3P )

if ( IsValid( turretProxy.GetOwner() ) )
		{
			entity turretWeapon = turretProxy.GetOwner().GetActiveWeapon( eActiveInventorySlot.mainHand )

				if ( IsValid( turretWeapon ) && turretWeapon.GetWeaponClassName() == MOUNTED_TURRET_WEAPON_NAME )
					MountedTurretWeapon_Play1pDamageFX( turretWeapon )
			}
		}
	}

	if ( turretProxy.GetHealth() - DamageInfo_GetDamage( damageInfo ) <= 0 )
	{
		DestroyTurretFX( turretProxy, attacker )

		if ( IsValid( turretProxy.GetOwner() ) )
			PIN_Interact( turretProxy.GetOwner(), "rampart_turret_destroyed", turretProxy.GetOrigin() )
	}
}

void function DestroyTurretFX( entity turretProxy, entity attacker )
{
	vector baseOrigin = turretProxy.GetOrigin()
		vector baseAngles = turretProxy.GetAngles()

		int gunAttachIdx = turretProxy.LookupAttachment( TURRET_DESTROYED_GUN_ATTACH )
		vector gunOrigin = turretProxy.GetAttachmentOrigin( gunAttachIdx )
		vector gunAngles = turretProxy.GetAttachmentAngles( gunAttachIdx )

		foreach ( entity player in GetPlayerArray() )
		{
			if ( !IsValid( player ) )
				continue

			Remote_CallFunction_Replay( player, "ServerCallback_PlayTurretDestroyFX", baseOrigin, baseAngles, gunOrigin, gunAngles )
		}

		EmitSoundAtPosition( TEAM_UNASSIGNED, turretProxy.GetOrigin(), "Turret_Explode", turretProxy )

		entity owner = turretProxy.GetOwner()
		if ( IsValid( owner )
			&& attacker != owner
			&& Distance( owner.GetOrigin(), turretProxy.GetOrigin() ) < TURRET_DESTROYED_CALLOUT_MIN_DIST
			&& GetPlayerVoice( owner ) == "rampart" )
		{
			PlayBattleChatterLineToSpeakerAndTeamWithDebounceTime( owner, "bc_rampart_turretDestroyed", 5.0, 5.0 )
		}
}

void function ClientCallback_TryPickupMountedTurret( entity player, entity device )
{
	if ( !SURVIVAL_PlayerAllowedToPickup( player ) )
		return

	if ( !IsValid( device ) || device.GetScriptName() != MOUNTED_TURRET_PLACEABLE_SCRIPT_NAME )
		return

	if ( device != player.GetUseEntity() )
		return

	if ( GradeFlagsHas( device, eGradeFlags.IS_BUSY ) )
		return

	entity owner = device.GetOwner()

	if ( player != owner )
		return

	entity ultWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )

	if ( !IsValid( ultWeapon ) || ultWeapon.GetWeaponClassName() != MOBILE_HMG_WEAPON_NAME )
		return

	GradeFlagsSet( device, eGradeFlags.IS_BUSY )
	device.NotSolid()

	if ( IsValid( device.GetOwner() ) )
		PIN_Interact( device.GetOwner(), "rampart_turret_picked_up", device.GetOrigin() )

	thread (void function() : ( player, device ) {
		OnThreadEnd( void function() : ( player, device ) {
			if ( IsValid( device ) )
			{
				device.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 1000 )
			}
		} )

		if ( IsValid( device.e.highlightProxy ) )
			device.e.highlightProxy.Destroy()

		if ( IsValid( player ) && CanReclaimTurret( device ) )
		{
			entity weapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )

			string className = weapon.GetWeaponClassName()
			if ( className == MOUNTED_TURRET_PLACEABLE_WEAPON_NAME )
			{
				int maxAmmo     = weapon.GetWeaponPrimaryClipCountMax()
				int curAmmo     = weapon.GetWeaponPrimaryClipCount()
				int newAmmo     = minint( curAmmo + int( maxAmmo * TURRET_AMMO_REFUND_ON_PICKUP_FRAC ), maxAmmo )

				weapon.SetWeaponPrimaryClipCount( newAmmo )
			}
		}

		if ( IsValid( player) && GetPlayerVoice( player ) == "rampart" )
			PlayBattleChatterLineToSpeakerAndTeamWithDebounceTime( player, "bc_rampart_turretPackedUp", 5.0, 5.0 )

		waitthread PlayAnimOnly( device, "prop_rampart_turret_collapse" )
	})()
}

#endif // SERVER

bool function MountedTurretPlaceable_CanUse( entity player, entity ent, int useFlags )
{
	if ( IsValid( ent.GetOwner() ) )
	{
		return ent.GetOwner() == player
	}

	if ( ! SURVIVAL_PlayerAllowedToPickup( player ) )
		return false

	if ( !IsTurretEnabled( ent ) )
		return false

	if ( GradeFlagsHas( ent, eGradeFlags.IS_BUSY ) )
		return false


	entity parentEnt = ent.GetParent()
	int maxAngleToAxisAllowedDegrees = 100

	vector playerEyePos = player.EyePosition()
	int attachmentIndex = ent.LookupAttachment( "turret_player_use" )

	Assert( attachmentIndex != 0 )
	vector attachmentAngles   = ent.GetAttachmentAngles( attachmentIndex )
	vector attachmentAnglesToForward  = AnglesToForward( attachmentAngles )
	vector attachmentPos = ent.GetAttachmentOrigin( attachmentIndex ) + <0,0,48> + attachmentAnglesToForward*40

	vector attachmentToPlayerEyes = Normalize( playerEyePos - attachmentPos )

	bool playerEyesInPermittedZone = DotProduct( attachmentToPlayerEyes, attachmentAnglesToForward * -1 ) > deg_cos( maxAngleToAxisAllowedDegrees )
	bool playerLookingTowardsTurretEnough = DotProduct( player.GetViewForward(), -1 * attachmentToPlayerEyes ) > deg_cos( maxAngleToAxisAllowedDegrees / 2 )

	// 36 is half the height of large rigs, so this should be midway (or just below) for all of our characters
	TraceResults pathTraceResults = TraceLine( playerEyePos - <0,0,36>, attachmentPos, [player, ent], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
	bool pathToTurretUnobstructed = pathTraceResults.fraction < 1.0 ? false : true

	return playerEyesInPermittedZone && playerLookingTowardsTurretEnough && pathToTurretUnobstructed

}

void function MountedTurretPlaceable_SetEligibleForRefund( entity turretProxy, bool eligible )
{
	file.turretEligibleForRefund[ turretProxy ] <- eligible
}

//TODO OT:  Remove this function
bool function CanReclaimTurret( entity turret )
{
	return false
}

#if CLIENT
	void function MountedTurretPlaceable_OnTurretCreated( entity ent )
	{
		switch ( ent.GetScriptName() )
		{
			case MOUNTED_TURRET_PLACEABLE_SCRIPT_NAME:
				SetCallback_CanUseEntityCallback_Retail( ent, MountedTurretPlaceable_CanUse )
				AddEntityCallback_GetUseEntOverrideText( ent, MountedTurretPlaceable_UseTextOverride )
				file.turretEligibleForRefund[ ent ] <- true
				//thread MountedTurretPlaceable_CreateHUDMarker( ent )
			break
		}
	}

	void function MountedTurretPlaceable_OnTurretDestroyed( entity ent )
	{
		if ( !IsValid( ent ) )
			return

		switch ( ent.GetScriptName() )
		{
			case MOUNTED_TURRET_PLACEABLE_SCRIPT_NAME:
				CustomUsePrompt_ClearForEntity( ent )
				break
		}
	}

	void function MountedTurretPlaceable_OnGainFocus( entity ent )
	{
		if ( !IsValid( ent ) )
			return

		if ( ent.GetScriptName() == MOUNTED_TURRET_PLACEABLE_SCRIPT_NAME )
		{
			CustomUsePrompt_Show( ent )
		}
	}

	void function MountedTurretPlaceable_OnLoseFocus( entity ent )
	{
		//CustomUsePrompt_ClearForAny()
	}

	string function MountedTurretPlaceable_UseTextOverride( entity ent )
	{
		entity player = GetLocalViewPlayer()

		if ( !IsTurretEnabled( ent ) )
		{
			CustomUsePrompt_SetText( Localize("#WPN_MOUNTED_TURRET_PLACEABLE_DISABLED") )
			CustomUsePrompt_SetHintImage( $"" )
			CustomUsePrompt_ShowSourcePos( false )
		}
		else if ( !MountedTurretPlaceable_CanUse( player, ent, 0 ) || player.IsTitan() || GradeFlagsHas( ent, eGradeFlags.IS_BUSY ) )
		{
			CustomUsePrompt_SetText( Localize("#WPN_MOUNTED_TURRET_PLACEABLE_NO_INTERACTION") )
			CustomUsePrompt_SetHintImage( $"" )
			CustomUsePrompt_ShowSourcePos( false )
		}
		else if ( ent.GetOwner() == player )
		{
			CustomUsePrompt_SetSourcePos( ent.GetOrigin() + < 0, 0, 35 > )

			if ( CanReclaimTurret( ent ) )
			{
				CustomUsePrompt_SetText( Localize("#WPN_MOUNTED_TURRET_PLACEABLE_OWNER_RECLAIM") )
				CustomUsePrompt_SetAdditionalText( Localize( "#WPN_MOUNTED_TURRET_PLACEABLE_DYNAMIC" ) )
				CustomUsePrompt_SetHintImage( $"rui/hud/character_abilities/rampart_cover_pickup" )
				CustomUsePrompt_SetLineColor( <0.0, 1.0, 1.0> )
			}
			else
			{
				CustomUsePrompt_SetText( Localize("#WPN_MOUNTED_TURRET_PLACEABLE_OWNER_DESTROY") )
				CustomUsePrompt_SetAdditionalText( Localize( "#WPN_MOUNTED_TURRET_PLACEABLE_DYNAMIC" ) )
				//CustomUsePrompt_SetHintImage( $"rui/hud/character_abilities/rampart_cover_destroy" )
				CustomUsePrompt_SetHintImage( $"" )
				CustomUsePrompt_SetLineColor( <1.0, 0.5, 0.0> )
			}


			if ( PlayerIsInADS( player ) )
				CustomUsePrompt_ShowSourcePos( false )
			else
				CustomUsePrompt_ShowSourcePos( true )
		}
		else
		{
			CustomUsePrompt_SetSourcePos( ent.GetOrigin() + < 0, 0, 35 > )
			CustomUsePrompt_ShowSourcePos( true )
			CustomUsePrompt_SetText( Localize( "#WPN_MOUNTED_TURRET_PLACEABLE_DYNAMIC" ) )
		}

		return ""
	}

	void function OnCharacterButtonPressed( entity player )
	{
		entity useEnt = player.GetUsePromptEntity()
		if ( !IsValid( useEnt ) || useEnt.GetScriptName() != MOUNTED_TURRET_PLACEABLE_SCRIPT_NAME )
			return

		if ( useEnt.GetOwner() != player )
			return

		Remote_ServerCallFunction( "ClientCallback_TryPickupMountedTurret", useEnt )
	}

	void function MountedTurretPlaceable_CreateHUDMarker( entity turret )
	{
		entity localClientPlayer = GetLocalClientPlayer()

		turret.EndSignal( "OnDestroy" )

		if ( !MountedTurretPlaceable_ShouldShowIcon( localClientPlayer, turret ) )
			return

		vector pos = turret.GetOrigin() + <0,0,MOUNTED_TURRET_PLACEABLE_ICON_HEIGHT>
		var rui = CreateCockpitRui( $"ui/cover_wall_marker_icons.rpak", RuiCalculateDistanceSortKey( localClientPlayer.EyePosition(), pos ) )
		RuiTrackFloat( rui, "healthFrac", turret, RUI_TRACK_HEALTH )
		RuiTrackFloat3( rui, "pos", turret, RUI_TRACK_OVERHEAD_FOLLOW )
		RuiKeepSortKeyUpdated( rui, true, "pos" )

		OnThreadEnd(
		function() : ( rui )
		{
			RuiDestroy( rui )
		}
		)

		WaitForever()
	}

	bool function MountedTurretPlaceable_ShouldShowIcon( entity localPlayer, entity wall )
	{
		if ( !GamePlayingOrSuddenDeath() )
			return false

		//if ( IsWatchingReplay() )
		//	return false
		entity owner = wall.GetOwner()
		if ( !IsValid( owner ) )
			return false

		if ( localPlayer.GetTeam() != owner.GetTeam() )
			return false

		return true
	}
#endif //CLIENT

bool function IsTurretEnabled( entity turret )
{
	#if SERVER
		if ( turret in file.isTurretEnabled )
			return file.isTurretEnabled[ turret ]
		else
			Assert( false, "turret not in enabled list in mp_weapon_mounted_turret_placeable!" )
			return false
	#endif

	#if CLIENT
		foreach ( entity linkedEnt in turret.GetLinkEntArray() )
		{
			if ( IsPlayerWaypoint( linkedEnt ) && linkedEnt.GetWaypointType() == eWaypoint.DEVICE_DISABLED )
				return false
		}

		return true
	#endif
}

#if 0		// old prototype
entity function MountedTurretPlaceable_CreateProxyModel( asset modelName )
{
	#if SERVER
		entity proxy = CreatePropDynamic( modelName, <0,0,0>, <0,0,0> )
	#else
		entity proxy = CreateClientSidePropDynamic( <0,0,0>, <0,0,0>, modelName )
	#endif
	proxy.kv.renderamt = 255
	proxy.kv.rendermode = 3
	proxy.kv.rendercolor = "255 255 255 255"
	proxy.Hide()

	return proxy
}

MountedTurretPlaceablePlacementInfo function MountedTurretPlaceable_GetPlacementInfo( entity player, entity turretModel )
{
	vector eyePos = player.EyePosition()
	vector viewVec = player.GetViewVector()
	vector angles = < 0, VectorToAngles( viewVec ).y, 0 >
	viewVec = AnglesToForward( angles )

	float maxRange = MOUNTED_TURRET_PLACEABLE_PLACEMENT_RANGE_MAX

	TraceResults viewTraceResults = TraceLine( eyePos, eyePos + player.GetViewVector() * (MOUNTED_TURRET_PLACEABLE_PLACEMENT_RANGE_MAX * 2), [player, turretModel], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
	if ( viewTraceResults.fraction < 1.0 )
	{
		//printt( viewTraceResults.hitEnt.GetScriptName() )
		float slope = fabs( viewTraceResults.surfaceNormal.x ) + fabs( viewTraceResults.surfaceNormal.y )
		if ( slope < 0.707 )
			maxRange = min( Distance2D( eyePos, viewTraceResults.endPos ), MOUNTED_TURRET_PLACEABLE_PLACEMENT_RANGE_MAX )
	}

	vector idealPos = player.GetOrigin() + (viewVec * MOUNTED_TURRET_PLACEABLE_PLACEMENT_RANGE_MAX)

	MountedTurretPlaceablePlacementInfo placementInfo

	vector fwdStart = eyePos + viewVec * min( MOUNTED_TURRET_PLACEABLE_PLACEMENT_RANGE_MIN, maxRange )
	TraceResults fwdResults = TraceHull( fwdStart, eyePos + viewVec * maxRange, MOUNTED_TURRET_PLACEABLE_BOUND_MINS, <30,30,1>, [player, turretModel], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )

	if ( MOUNTED_TURRET_PLACEABLE_DEBUG_DRAW_PLACEMENT )
	{
		DebugDrawLine( fwdStart, fwdResults.endPos, COLOR_RED, true, 0.05 )
		DebugDrawLine( fwdStart, fwdResults.endPos, COLOR_RED, true, 0.05 )
		DebugDrawSphere( fwdResults.endPos, 16, COLOR_RED, true, 0.05 )
		DebugDrawLine( fwdResults.endPos, fwdResults.endPos - MOUNTED_TURRET_PLACEABLE_PLACEMENT_TRACE_OFFSET, COLOR_RED, true, 0.05 )
	}


	TraceResults downResults = TraceHull( fwdResults.endPos, fwdResults.endPos - MOUNTED_TURRET_PLACEABLE_PLACEMENT_TRACE_OFFSET, MOUNTED_TURRET_PLACEABLE_BOUND_MINS, MOUNTED_TURRET_PLACEABLE_BOMB_BOUND_MAXS, [player, turretModel], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )

	bool isScriptedPlaceable = false
	if ( IsValid( downResults.hitEnt ) )
	{
		var hitEntClassname = downResults.hitEnt.GetNetworkedClassName()

		if ( hitEntClassname == "func_brush" || hitEntClassname == "script_mover" )
		{
			isScriptedPlaceable = true
		}
	}

	bool success = !downResults.startSolid && downResults.fraction < 1.0 && ( downResults.hitEnt.IsWorld() || downResults.hitEnt.GetNetworkedClassName() == "func_brush" || isScriptedPlaceable )

	entity parentTo
	if ( IsValid( downResults.hitEnt ) && ( downResults.hitEnt.GetNetworkedClassName() == "func_brush" || downResults.hitEnt.GetNetworkedClassName() == "script_mover" ) )
	{
		parentTo = downResults.hitEnt
	}

	if ( downResults.startSolid && downResults.fraction < 1.0 && ( downResults.hitEnt.IsWorld() || isScriptedPlaceable ) )
	{
		TraceResults upResults = TraceHull( downResults.endPos, downResults.endPos, MOUNTED_TURRET_PLACEABLE_BOUND_MINS, MOUNTED_TURRET_PLACEABLE_BOMB_BOUND_MAXS, [player, turretModel], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
		if ( !upResults.startSolid )
			success = true
	}

	//angles = AnglesCompose( angles, <0,90,0> ) //rotating walls sideways
	vector surfaceAngles = viewVec
	if ( downResults.fraction < 1.0 )
	{
		surfaceAngles 	= AnglesOnSurface( downResults.surfaceNormal, viewVec )
		vector newUpDir = AnglesToUp( surfaceAngles )
		vector oldUpDir = AnglesToUp( angles )

		if ( DotProduct( newUpDir, oldUpDir ) < MOUNTED_TURRET_PLACEABLE_ANGLE_LIMIT )
		{
			surfaceAngles = viewVec
			success = false
		}
	}

	if ( success )
	{
		turretModel.SetOrigin( downResults.endPos )
		turretModel.SetAngles( surfaceAngles )
	}

	if ( !player.IsOnGround() )
		success = false

	//EVEN GROUND CHECK AND SURFACE ANGLE CHECK
	if ( success && downResults.fraction < 1.0 )
	{
		vector right = turretModel.GetRightVector()
		vector forward = turretModel.GetForwardVector()
		vector up = turretModel.GetUpVector()

		float length = Length( MOUNTED_TURRET_PLACEABLE_BOUND_MINS )

		array< vector > groundTestOffsets = [
			( <0,0,0> ),
			( right * 20 ) + ( forward * 12 ),
			( -right * 20 ) + ( forward * 12 ),
			( -forward * 28 )
		]

		foreach ( vector testOffset in groundTestOffsets )
		{
			vector testPos = turretModel.GetOrigin() + testOffset
			TraceResults traceResult = TraceLine( testPos + ( up * MOUNTED_TURRET_PLACEABLE_PLACEMENT_MAX_HEIGHT_DELTA ), testPos + ( up * -MOUNTED_TURRET_PLACEABLE_PLACEMENT_MAX_HEIGHT_DELTA ), [player, turretModel], TRACE_MASK_SOLID | TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_NONE )

			if ( MOUNTED_TURRET_PLACEABLE_DEBUG_DRAW_PLACEMENT )
			{
				DebugDrawLine( testPos, traceResult.endPos, COLOR_RED, true, 0.05 )
			}

			if ( traceResult.fraction == 1.0 )
			{
				success = false
				break
			}
		}
	}

	//PrintTraceResults( viewTraceResults )

	//printt( isScriptedPlaceable )

	//if ( success && viewTraceResults.hitEnt != null && ( !viewTraceResults.hitEnt.IsWorld() && !isScriptedTurretPlaceable ) )
	//	success = false
	if ( success && downResults.hitEnt != null && ( !downResults.hitEnt.IsWorld() && !isScriptedPlaceable ) )
		success = false

	//BOOL SHOULD BE TRUE - This is causing issues with the sight blocker effect of smoke, so it's temporarily disabled. This results in the bug mentioned below.
	if ( success && !PlayerCanSeePos( player, downResults.endPos, true, 90 ) ) //Just to stop players from putting turrets through thin walls
		success = false

	vector org = success ? downResults.endPos - <0,0,MOUNTED_TURRET_PLACEABLE_BOMB_BOUND_MAXS.x> : idealPos // for some reason this trace isn't perfectly flush with the ground
	vector ang = success ? surfaceAngles : angles
	placementInfo.success = success
	placementInfo.origin = org
	placementInfo.angles = ang//angles
	placementInfo.parentTo = parentTo

	return placementInfo
}
#endif // #if 0

#if CLIENT
void function MinimapPackage_RampartGun( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", $"rui/hud/ultimate_icons/ultimate_rampart" )
	RuiSetImage( rui, "clampedDefaultIcon", $"rui/hud/ultimate_icons/ultimate_rampart" )
	RuiSetBool( rui, "useTeamColor", false )
	RuiSetFloat( rui, "iconBlend", 0.0 )
}
#endif