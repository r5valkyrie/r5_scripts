
global function MpWeaponCoverWall_Init

global function OnWeaponAttemptOffhandSwitch_weapon_cover_wall
global function OnWeaponPrimaryAttack_weapon_cover_wall
global function OnWeaponActivate_weapon_cover_wall
global function OnWeaponDeactivate_weapon_cover_wall

//$"mdl/barriers/sandbags_large_01.rmdl"
//$"mdl/barriers/sandbags_curved_01.rmdl"

const asset COVER_WALL_MODEL = $"mdl/barriers/sandbags_large_01.rmdl"

const int COVER_WALL_MAX_WALLS = 12

const float COVER_WALL_NO_SPAWN_RADIUS = 256.0
const float COVER_WALL_ICON_HEIGHT = 48.0
const int COVER_WALL_MAX_HEALTH = 500

//WALL PLACEMENT VARS
const float COVER_WALL_PLACEMENT_RANGE_MAX = 128
const float COVER_WALL_PLACEMENT_RANGE_MIN = 32
const vector COVER_WALL_BOUND_MINS = <-12,-12,-12>
const vector COVER_WALL_BOUND_MAXS = <12,12,12>
const vector COVER_WALL_PLACEMENT_TRACE_OFFSET = <0,0,128>
const float COVER_WALL_ANGLE_LIMIT = 0.90
const float COVER_WALL_PLACEMENT_MAX_HEIGHT_DELTA = 32.0

//WALL SUSTAINED USE VARS
const float COVER_WALL_MAX_USE_DIST2_MOD = 64 * 64
const float COVER_WALL_PICKUP_TIME = 1.0
const bool COVER_WALL_USE_QUICK = true
const bool COVER_WALL_USE_ALT = true

//WALL REPAIR VARS
const float COVER_WALL_REPAIR_INTERVAL = 1.0
const int	COVER_WALL_REPAIR_AMOUNT = 20

const bool COVER_WALL_DEBUG_DRAW_PLACEMENT = false

struct CoverWallPlacementInfo
{
	vector origin
	vector angles
	entity parentTo
	bool success = false
}

struct CoverWallPlayerPlacementData
{
	vector viewOrigin	//The player's view origin when they placed the trap.
	vector viewForward	//The player's view forward when they placed the trap.
	vector playerOrigin //The player's world origin when they placed the trap.
	vector playerForward //The player's world forward when they placed the trap.
}

struct
{
	#if SERVER
	table< entity, int > triggerTargets
	#endif
} file

void function MpWeaponCoverWall_Init()
{
	CoverWall_Precache()
}

void function CoverWall_Precache()
{
	RegisterSignal( "CoverWall_Detonated" )
	RegisterSignal( "CoverWall_PickedUp" )
	RegisterSignal( "CoverWall_Disarmed" )
	RegisterSignal( "CoverWall_Active" )
	RegisterSignal( "CoverWall_OnContinousUseStopped" )

	PrecacheModel( COVER_WALL_MODEL )

	#if CLIENT
		RegisterSignal( "CoverWall_StopPlacementProxy" )
		StatusEffect_RegisterEnabledCallback( eStatusEffect.placing_cover_wall, CoverWall_OnBeginPlacement )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.placing_cover_wall, CoverWall_OnEndPlacement )

		AddCreateCallback( "prop_script", CoverWall_OnPropScriptCreated )
	#endif
}

void function OnWeaponActivate_weapon_cover_wall( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	weapon.w.startChargeTime = Time()

	Assert( ownerPlayer.IsPlayer() )
	#if CLIENT
		if ( !InPrediction() ) //Stopgap fix for Bug 146443
			return
	#endif

	int statusEffect = eStatusEffect.placing_cover_wall

	StatusEffect_AddEndless( ownerPlayer, statusEffect, 1.0 )

	#if SERVER
		AddButtonPressedPlayerInputCallback( ownerPlayer, IN_OFFHAND1, CoverWall_CancelPlacement )
	#endif
}


void function OnWeaponDeactivate_weapon_cover_wall( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )
	#if CLIENT
		if ( !InPrediction() ) //Stopgap fix for Bug 146443
			return
	#endif
	StatusEffect_StopAllOfType( ownerPlayer, eStatusEffect.placing_cover_wall )

	#if SERVER
		RemoveButtonPressedPlayerInputCallback( ownerPlayer, IN_OFFHAND1, CoverWall_CancelPlacement )
	#endif
}


var function OnWeaponPrimaryAttack_weapon_cover_wall( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	asset model = COVER_WALL_MODEL

	entity proxy                                      = CoverWall_CreateProxyModel( model )
	CoverWallPlacementInfo placementInfo = CoverWall_GetPlacementInfo( ownerPlayer, proxy )
	proxy.Destroy()

	if ( !placementInfo.success )
	{
		#if CLIENT
		EmitSoundOnEntity( ownerPlayer, "Wpn_ArcTrap_Beep" )
		#endif
		return 0
	}
	#if SERVER
		CoverWallPlayerPlacementData placementData
		placementData.viewOrigin = ownerPlayer.EyePosition()
		placementData.viewForward 	= ownerPlayer.GetViewForward()
		placementData.playerOrigin 	= ownerPlayer.GetOrigin()
		placementData.playerForward	= FlattenVector( ownerPlayer.GetViewForward() )
		thread CoverWall_Deploy( ownerPlayer, placementInfo )
	#endif

	PlayerUsedOffhand( ownerPlayer, weapon )
	return weapon.GetAmmoPerShot()
}

bool function OnWeaponAttemptOffhandSwitch_weapon_cover_wall( entity weapon )
{
	int ammoReq = weapon.GetAmmoPerShot()
	int currAmmo = weapon.GetWeaponPrimaryClipCount()
	if ( currAmmo < ammoReq )
		return false

	entity player = weapon.GetWeaponOwner()
	if ( player.IsPhaseShifted() )
		return false

	return true
}

#if SERVER
void function CoverWall_CancelPlacement( entity player )
{

	if ( player.IsUsingOffhandWeapon( eActiveInventorySlot.mainHand ) )
	{
		entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

		if ( !IsValid( activeWeapon ) )
			return

		if ( activeWeapon.GetWeaponClassName() != "mp_weapon_cover_wall" )
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

void function CoverWall_Deploy( entity owner, CoverWallPlacementInfo placementInfo )
{
	if ( !IsValid( owner ) )
		return

	vector origin = placementInfo.origin
	vector angles = placementInfo.angles

	//owner.EndSignal( "OnDestroy" )
	//owner.EndSignal( "SquadEliminated" )

	int team         = owner.GetTeam()
	entity wallProxy = CreatePropScript( COVER_WALL_MODEL, origin, angles, SOLID_VPHYSICS )
	//canisterProxy.kv.collisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	wallProxy.DisableHibernation()
	wallProxy.SetMaxHealth( COVER_WALL_MAX_HEALTH )
	wallProxy.SetHealth( COVER_WALL_MAX_HEALTH )
	wallProxy.SetDamageNotifications( false )
	wallProxy.SetDeathNotifications( false )
	wallProxy.SetArmorType( ARMOR_TYPE_HEAVY )
	wallProxy.SetScriptName( "cover_wall" )
	//wallProxy.SetBlocksRadiusDamage( true )
	wallProxy.SetTitle( "#WPN_TITAN_SLOW_TRAP" )
	SetTargetName( wallProxy, "#WPN_TITAN_SLOW_TRAP" )
	wallProxy.EndSignal( "OnDestroy" )
	wallProxy.SetBossPlayer( owner )
	wallProxy.e.isGasSource = true
	wallProxy.e.noOwnerFriendlyFire = false
	wallProxy.RemoveFromAllRealms()
	wallProxy.AddToOtherEntitysRealms( owner )
	//SetTeam( wallProxy, team )
	wallProxy.Minimap_SetCustomState( eMinimapObject_prop_script.DIRTY_BOMB )
	wallProxy.Minimap_AlwaysShow( team, null )
	wallProxy.Minimap_SetZOrder( MINIMAP_Z_OBJECT-1 )
	wallProxy.Solid()
	wallProxy.AllowMantle()
	wallProxy.SetScriptPropFlags( PROP_IS_VALID_FOR_TURRET_PLACEMENT )

	EmitSoundOnEntityOnlyToPlayer( wallProxy, owner, "weapon_sentryfragdrone_pinpull_1p" )
	EmitSoundOnEntityExceptToPlayer( wallProxy, owner, "weapon_sentryfragdrone_pinpull_3p" )


	string noSpawnIdx = CreateNoSpawnArea( TEAM_INVALID, team, origin, -1.0, COVER_WALL_NO_SPAWN_RADIUS )
	SetObjectCanBeMeleed( wallProxy, true )
	SetVisibleEntitiesInConeQueriableEnabled( wallProxy, false )
	// thread TrapDestroyOnRoundEnd( owner, wallProxy )

	if ( IsValid( placementInfo.parentTo ) )
	{
		wallProxy.SetParent( placementInfo.parentTo )
	}

	//make npc's fire at their own traps to cut off lanes
	if ( owner.IsNPC() )
	{
		owner.SetSecondaryEnemy( wallProxy )
		wallProxy.EnableAttackableByAI( AI_PRIORITY_NO_THREAT, 0, AI_AP_FLAG_NONE )		// don't let other AI target this
	}

	//Register Canister so that it is detected by sonar.
	wallProxy.Highlight_Enable()
	AddSonarDetectionForPropScript( wallProxy )

	EmitSoundOnEntity( wallProxy, "incendiary_trap_land" )

	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetOwner( wallProxy )
	trigger.SetRadius( 128 )
	trigger.SetAboveHeight( 32 )
	trigger.SetBelowHeight( 0 )
	trigger.SetOrigin( origin )
	trigger.SetAngles( angles )
	trigger.kv.triggerFilterNonCharacter = "0"
	DispatchSpawn( trigger )

	trigger.SetEnterCallback( CoverWall_OnTriggerEnter )

	trigger.SetOrigin( origin )
	trigger.SetAngles( angles )

	OnThreadEnd(
	function() : ( owner, wallProxy, trigger, noSpawnIdx )
		{
			DeleteNoSpawnArea( noSpawnIdx )

			if ( IsValid( trigger ) )
				trigger.Destroy()

			if ( IsValid( owner ) )
			{
				for ( int i=owner.e.coverWalls.len()-1; i>=0 ; i-- )
				{
					if ( owner.e.coverWalls[i] == wallProxy )
					{
						owner.e.coverWalls.remove( i )
					}
				}
			}

			if ( IsValid( wallProxy ) )
			{
				wallProxy.Destroy()
			}
		}
	)

	wallProxy.EndSignal( "OnDestroy" )
	wallProxy.EndSignal( "CoverWall_Detonated" )
	wallProxy.EndSignal( "CoverWall_PickedUp" )
	wallProxy.EndSignal( "CoverWall_Disarmed" )

	thread CoverWall_WaitForPickup( wallProxy )

	wallProxy.SetTakeDamageType( DAMAGE_YES )
	AddEntityCallback_OnDamaged( wallProxy, CoverWall_OnDamaged )

	owner.e.coverWalls.insert( 0, wallProxy )

	while ( owner.e.coverWalls.len() > COVER_WALL_MAX_WALLS )
	{
		entity entToDelete = owner.e.coverWalls.pop()
		if ( IsValid( entToDelete ) )
		{
			entToDelete.Destroy()
		}
	}

	WaitForever()
}

void function CoverWall_OnTriggerEnter( entity trigger, entity player )
{
	if ( !player.IsPlayer() )
		return

	thread CoverWall_Repair( trigger, player )
}

void function CoverWall_Repair( entity trigger, entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	trigger.EndSignal( "OnDestroy" )

	entity wallProxy = trigger.GetOwner()

	if ( !IsValid( wallProxy ) )
		return

	wallProxy.EndSignal( "OnDestroy" )

	if ( !player.IsPlayer() )
		return

	//Only continue if player has repair passive.
	// if ( !player.HasPassive( ePassives.PAS_REPAIR ) )
		// return

	while ( trigger.IsTouching( player ) )
	{
		wait COVER_WALL_REPAIR_INTERVAL

		int newHealth = minint( COVER_WALL_MAX_HEALTH, wallProxy.GetHealth() + COVER_WALL_REPAIR_AMOUNT )
		wallProxy.SetHealth( newHealth )
	}
}

void function CoverWall_WaitForPickup( entity wallProxy )
{
	Assert( IsNewThread(), "Must be threaded off." )
	wallProxy.EndSignal( "OnDestroy" )
	wallProxy.EndSignal( "CoverWall_PickedUp" )
	wallProxy.EndSignal( "CoverWall_Disarmed" )
	wallProxy.EndSignal( "CoverWall_Active" )

	wallProxy.SetUsable()
	//canister.SetUsableByGroup( "owner pilot" )
	wallProxy.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER ) //Update hint text every server frame so that we can keep unique client texts up to date.
 	wallProxy.SetUsePrompts( "#WPN_COVER_WALL_DYNAMIC", "#WPN_COVER_WALL_DYNAMIC" )
	SetCallback_CanUseEntityCallback( wallProxy, CoverWall_CanUse )

	OnThreadEnd(
	function() : ( wallProxy )
		{
			if ( IsValid( wallProxy ) )
			{
				wallProxy.UnsetUsable()
			}
		}
	)

 	while( true )
 	{
 		entity player = expect entity( wallProxy.WaitSignal( "OnPlayerUseLong" ).player )

 		//Titans cannot interact with cover wall.
 		if ( player.IsTitan() )
 			continue

		//Don't allow the player to pick up walls if they are using a mounted turret.
		// if ( MountedTurretPlaceable_IsUsingMountedTurret( player ) )
			// continue

		entity owner = wallProxy.GetBossPlayer()

 		if ( player == owner )
 		{
 			waitthread CoverWall_PlayerAttemptPickup( player, wallProxy )
 		}
 	}
}

void function CoverWall_PlayerAttemptPickup( entity player, entity wallProxy )
{
	player.EndSignal( "OnDeath" )
	wallProxy.EndSignal( "OnDestroy" )
	player.EndSignal( "CoverWall_OnContinousUseStopped" )
	player.EndSignal( "OnSyncedMelee" )
	player.EndSignal( "StartPhaseShift" )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{
				DeployAndEnableWeapons( player )
			}
		}
	)

	HolsterAndDisableWeapons( player )

	waitthread CoverWall_TrackContinuousUse( player, wallProxy, COVER_WALL_PICKUP_TIME, true )

	if ( CoverWall_PickUp( player ) )
	{
		wallProxy.Signal( "CoverWall_PickedUp" )
		printt("wall cover picked up.." )
	}
}

void function CoverWall_TrackContinuousUse( entity player, entity useTarget, float useTime, bool doRequireUseButtonHeld )
{
	player.EndSignal( "OnDeath" )
	useTarget.EndSignal( "OnDeath" )
	useTarget.EndSignal( "OnDestroy" )
	player.EndSignal( "StartPhaseShift" )
	useTarget.EndSignal( "StartPhaseShift" )

	table result = {}
	result.success <- false

	float maxDist2 = DistanceSqr( player.GetOrigin(), useTarget.GetOrigin() ) + COVER_WALL_MAX_USE_DIST2_MOD

	OnThreadEnd
	(
		function() : ( player, result )
		{
			if ( !result.success )
			{
				player.Signal( "CoverWall_OnContinousUseStopped" )
			}
		}
	)

	float startTime = Time()
	while ( Time() < startTime + useTime && (!doRequireUseButtonHeld || CoverWall_IsReviveButtonDown( player )) && DistanceSqr( player.GetOrigin(), useTarget.GetOrigin() ) <= maxDist2 )
		WaitFrame()

	if ( (!doRequireUseButtonHeld || CoverWall_IsReviveButtonDown( player )) && DistanceSqr( player.GetOrigin(), useTarget.GetOrigin() ) <= maxDist2 )
		result.success = true
}

bool function CoverWall_IsReviveButtonDown( entity player )
{
	bool inUse      = player.IsInputCommandHeld( IN_USE )
	bool inUseAlt   = COVER_WALL_USE_ALT && player.IsInputCommandHeld( IN_USE_ALT )
	bool inUseQuick = COVER_WALL_USE_QUICK && player.IsInputCommandHeld( IN_USE_LONG )

	return inUse || inUseAlt || inUseQuick
}

bool function CoverWall_PickUp( entity player )
{
	entity weapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )

	string className = weapon.GetWeaponClassName()
	if ( className != "mp_weapon_cover_wall" )
		return false

	if ( Bleedout_IsBleedingOut( player ) )
		return false

	int ammoPerShot = weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
	int maxAmmo = weapon.GetWeaponPrimaryClipCountMax()
	int curAmmo = weapon.GetWeaponPrimaryClipCount(  )
	int newAmmo = minint( curAmmo + ammoPerShot, maxAmmo )

	weapon.SetWeaponPrimaryClipCount( newAmmo )

	return true
}

void function CoverWall_OnDamaged( entity wallProxy, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( wallProxy ) )
		return

	if ( !IsValid( attacker ) )
		return

	if ( IsWorldSpawn( attacker ) )
		return

	int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )

	//Two explosions will destroy the wall
	if ( damageFlags & DF_EXPLOSION )
		DamageInfo_SetDamage( damageInfo, wallProxy.GetMaxHealth() * 0.6 )

	//Four Melee attacks will destroy the wall.
	if ( damageFlags & DF_MELEE )
		DamageInfo_SetDamage( damageInfo, wallProxy.GetMaxHealth() / 4 )
}
#endif // SERVER

bool function CoverWall_CanUse( entity player, entity ent )
{
	return SURVIVAL_PlayerAllowedToPickup( player )
}

#if CLIENT
	void function CoverWall_OnPropScriptCreated( entity ent )
	{
		switch ( ent.GetScriptName() )
		{
			case "cover_wall":
				SetCallback_CanUseEntityCallback( ent, CoverWall_CanUse )
				AddEntityCallback_GetUseEntOverrideText( ent, CoverWall_UseTextOverride )
				thread CoverWall_CreateHUDMarker( ent )
			break
		}
	}

	string function CoverWall_UseTextOverride( entity ent )
	{
		entity player = GetLocalViewPlayer()

		if ( player.IsTitan() )
			return "#WPN_COVER_WALL_NO_INTERACTION"

		if ( player == ent.GetBossPlayer() )
		{
			return ""
		}

		return "#WPN_COVER_WALL_NO_INTERACTION"
	}

	void function CoverWall_CreateHUDMarker( entity wall )
	{
		entity localClientPlayer = GetLocalClientPlayer()

		wall.EndSignal( "OnDestroy" )

		if ( !CoverWall_ShouldShowIcon( localClientPlayer, wall ) )
			return

		vector pos = wall.GetOrigin() + <0,0,COVER_WALL_ICON_HEIGHT>
		var rui = CreateCockpitRui( $"ui/cover_wall_marker_icons.rpak", RuiCalculateDistanceSortKey( localClientPlayer.EyePosition(), pos ) )
		RuiTrackFloat( rui, "healthFrac", wall, RUI_TRACK_HEALTH )
		RuiTrackFloat3( rui, "pos", wall, RUI_TRACK_OVERHEAD_FOLLOW )
		RuiKeepSortKeyUpdated( rui, true, "pos" )

		OnThreadEnd(
		function() : ( rui )
		{
			RuiDestroy( rui )
		}
		)

		WaitForever()
	}

bool function CoverWall_ShouldShowIcon( entity localPlayer, entity wall )
{
	if ( !GamePlayingOrSuddenDeath() )
		return false

	//if ( IsWatchingReplay() )
	//	return false
	entity owner = wall.GetBossPlayer()
	if ( !IsValid( owner ) )
		return false

	if ( localPlayer.GetTeam() != owner.GetTeam() )
		return false

	return true
}

void function CoverWall_OnBeginPlacement( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return

	thread CoverWall_Placement( player )
}

void function CoverWall_OnEndPlacement( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return

	player.Signal( "CoverWall_StopPlacementProxy" )
}

void function CoverWall_Placement( entity player )
{
	player.EndSignal( "CoverWall_StopPlacementProxy" )

	entity wall = CoverWall_CreateProxyModel( COVER_WALL_MODEL )
	wall.EnableRenderAlways()
	wall.Show()
	DeployableModelHighlight( wall )

	var placementRui = CreateCockpitRui( $"ui/generic_trap_placement.rpak", RuiCalculateDistanceSortKey( player.EyePosition(), wall.GetOrigin() ) )
	int placementAttachment = wall.LookupAttachment( "fx_top" )
	RuiSetBool( placementRui, "staticPosition", true )
	RuiSetInt( placementRui, "trapLimit", COVER_WALL_MAX_WALLS )
	RuiTrackFloat3( placementRui, "mainTrapPos", wall, RUI_TRACK_POINT_FOLLOW, placementAttachment )
	RuiKeepSortKeyUpdated( placementRui, true, "mainTrapPos" )
	RuiSetImage( placementRui, "trapIcon", $"rui/pilot_loadout/ordnance/electric_smoke" )

	OnThreadEnd(
		function() : ( wall, placementRui )
		{
			if ( IsValid( wall ) )
				wall.Destroy()

			RuiDestroy( placementRui )
		}
	)

	while ( true )
	{
		CoverWallPlacementInfo placementInfo = CoverWall_GetPlacementInfo( player, wall )

		if ( !placementInfo.success )
		{
			DeployableModelInvalidHighlight( wall )
		}
		else if ( placementInfo.success )
		{
			DeployableModelHighlight( wall )
		}

		RuiSetBool( placementRui, "success", placementInfo.success )
		RuiSetInt( placementRui, "trapCount", CoverWall_GetOwnedTrapCountOnClient( player ) )

		wall.SetOrigin( placementInfo.origin )
		wall.SetAngles( placementInfo.angles )

		WaitFrame()
	}
}

int function CoverWall_GetOwnedTrapCountOnClient( entity player )
{
	int count
	array<entity> walls = GetEntArrayByScriptName( "cover_wall" )
	foreach ( entity wall in walls )
	{
		if ( wall.GetBossPlayer() == player )
			count++
	}

	return count
}

#endif //CLIENT

entity function CoverWall_CreateProxyModel( asset modelName )
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

CoverWallPlacementInfo function CoverWall_GetPlacementInfo( entity player, entity wallModel )
{
	vector eyePos = player.EyePosition()
	vector viewVec = player.GetViewVector()
	vector angles = < 0, VectorToAngles( viewVec ).y, 0 >
	//viewVec = AnglesToForward( angles )

	float maxRange = COVER_WALL_PLACEMENT_RANGE_MAX

	TraceResults viewTraceResults = TraceLine( eyePos, eyePos + player.GetViewVector() * (COVER_WALL_PLACEMENT_RANGE_MAX * 2), [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
	if ( viewTraceResults.fraction < 1.0 )
	{
		float slope = fabs( viewTraceResults.surfaceNormal.x ) + fabs( viewTraceResults.surfaceNormal.y )
		if ( slope < 0.707 )
			maxRange = min( Distance2D( eyePos, viewTraceResults.endPos ), COVER_WALL_PLACEMENT_RANGE_MAX )
	}

	vector idealPos =  player.GetOrigin() + ( AnglesToForward( angles ) * COVER_WALL_PLACEMENT_RANGE_MAX )

	vector fwdStart = eyePos + viewVec * min( COVER_WALL_PLACEMENT_RANGE_MIN, maxRange )
	//TraceResults fwdResults = TraceHull( fwdStart, eyePos + viewVec * maxRange, COVER_WALL_BOUND_MINS, <30,30,1>, [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
	TraceResults fwdResults = TraceHull( fwdStart, eyePos + viewVec * maxRange, COVER_WALL_BOUND_MINS, COVER_WALL_BOUND_MAXS, [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
	TraceResults downResults = TraceHull( fwdResults.endPos, fwdResults.endPos - COVER_WALL_PLACEMENT_TRACE_OFFSET, COVER_WALL_BOUND_MINS, COVER_WALL_BOUND_MAXS, [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

	if ( COVER_WALL_DEBUG_DRAW_PLACEMENT )
	{
		DebugDrawLine( fwdStart, fwdResults.endPos, 255,0,0, true, 0.05 )
		DebugDrawLine( fwdStart, fwdResults.endPos, 255,0,0, true, 0.05 )
		DebugDrawSphere( fwdResults.endPos, 16, 255,0,0, true, 0.05 )
		DebugDrawLine( fwdResults.endPos, fwdResults.endPos - COVER_WALL_PLACEMENT_TRACE_OFFSET, 255,0,0, true, 0.05 )
		DebugDrawBox( downResults.endPos, COVER_WALL_BOUND_MINS, COVER_WALL_BOUND_MAXS, 0, 255, 0, 1, 1.0 ) //Downward Fallback Hull Cast Bounding Box
	}

	CoverWallPlacementInfo placementInfo = CoverWall_GetPlacementInfoFromTraceResults( player, wallModel, downResults, viewTraceResults, idealPos )

	int attempts = 0
	vector fallbackPos = fwdResults.endPos

	while ( !placementInfo.success && attempts < 3 )
	{
		//printt( "TRYING TO USE FALLBACK POSITION" )
		//vector fallbackPos = fwdResults.endPos - ( viewVec * Length( COVER_WALL_BOUND_MINS ) )
		fallbackPos = fallbackPos - ( viewVec * ( Length( COVER_WALL_BOUND_MINS ) / 4 ) )
		//fallbackPos = fallbackPos - ( viewVec * -12 )
		TraceResults downFallbackResults = TraceHull( fallbackPos, fallbackPos - COVER_WALL_PLACEMENT_TRACE_OFFSET, COVER_WALL_BOUND_MINS, COVER_WALL_BOUND_MAXS, [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

		if ( COVER_WALL_DEBUG_DRAW_PLACEMENT )
		{
			DebugDrawBox( downFallbackResults.endPos, COVER_WALL_BOUND_MINS, COVER_WALL_BOUND_MAXS, 255, 0, 0, 1, 1.0 ) //Downward Fallback Hull Cast Bounding Box
		}

		placementInfo = CoverWall_GetPlacementInfoFromTraceResults( player, wallModel, downFallbackResults, viewTraceResults, idealPos )
		attempts++
	}

	return placementInfo

}

CoverWallPlacementInfo function CoverWall_GetPlacementInfoFromTraceResults( entity player, entity wallModel, TraceResults hullTraceResults, TraceResults viewTraceResults, vector idealPos )
{

	vector viewVec = player.GetViewVector()
	vector angles  = < 0, VectorToAngles( viewVec ).y, 0 >

	bool isScriptedTurretPlaceable = false
	if ( IsValid( hullTraceResults.hitEnt ) )
	{
		var hitEntClassname = hullTraceResults.hitEnt.GetNetworkedClassName()

		if ( hitEntClassname == "prop_script" )
		{
			if ( hullTraceResults.hitEnt.GetScriptPropFlags() == PROP_IS_VALID_FOR_TURRET_PLACEMENT )
				isScriptedTurretPlaceable = true
		}
	}

	bool success = !hullTraceResults.startSolid && hullTraceResults.fraction < 1.0 && ( hullTraceResults.hitEnt.IsWorld() || hullTraceResults.hitEnt.GetNetworkedClassName() == "func_brush" || isScriptedTurretPlaceable )

	entity parentTo
	if ( IsValid( hullTraceResults.hitEnt ) && hullTraceResults.hitEnt.GetNetworkedClassName() == "func_brush" )
	{
		parentTo = hullTraceResults.hitEnt
	}

	if ( hullTraceResults.startSolid && hullTraceResults.fraction < 1.0 && ( hullTraceResults.hitEnt.IsWorld() || isScriptedTurretPlaceable ) )
	{
		TraceResults upResults = TraceHull( hullTraceResults.endPos, hullTraceResults.endPos, COVER_WALL_BOUND_MINS, COVER_WALL_BOUND_MAXS, [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
		if ( !upResults.startSolid )
			success = true
	}

	//angles = AnglesCompose( angles, <0,90,0> ) //rotating walls sideways
	vector surfaceAngles = AnglesToRight( angles )
	if ( hullTraceResults.fraction < 1.0 )
	{
		surfaceAngles 	= AnglesOnSurface( hullTraceResults.surfaceNormal, AnglesToRight( angles ) )
		vector newUpDir = AnglesToUp( surfaceAngles )
		vector oldUpDir = AnglesToUp( angles )

		if ( DotProduct( newUpDir, oldUpDir ) < COVER_WALL_ANGLE_LIMIT )
		{
			//printt( "PLACEMENT FAILED: ANGLE TOO STEEP!!!" )
			surfaceAngles = AnglesToRight( angles )
			success = false
		}
	}

	if ( success )
	{
		wallModel.SetOrigin( hullTraceResults.endPos )
		wallModel.SetAngles( surfaceAngles )
	}

	if ( !player.IsOnGround() )
	{
		//printt( "PLACEMENT FAILED: PLAYER IN AIR!!!" )
		success = false
	}

	//EVEN GROUND CHECK AND SURFACE ANGLE CHECK
	if ( success && hullTraceResults.fraction < 1.0 )
	{
		vector right = wallModel.GetRightVector()
		vector forward = wallModel.GetForwardVector()
		vector up = wallModel.GetUpVector()

		float length = Length( COVER_WALL_BOUND_MINS )

		array< vector > groundTestOffsetsForward = [
			( -right * 8 ),
			( -right * 8 ) + ( forward * 40 ),
			( -right * 8 ) + ( -forward * 40 ),
		]

		array<vector> groundTestOffsetsBack = [
			( right * 8 ),
			( right * 8 ) + ( forward * 40 ),
			( right * 8 ) +  ( -forward * 40 ),
		]

		//printt( "" )

		surfaceAngles = <0,0,0>
		vector surfaceNormals = <0,0,0>
		foreach ( vector testOffset in groundTestOffsetsForward )
		{
			vector testPos = wallModel.GetOrigin() + testOffset
			TraceResults traceResult = TraceLine( testPos + ( up * COVER_WALL_PLACEMENT_MAX_HEIGHT_DELTA ), testPos + ( up * -COVER_WALL_PLACEMENT_MAX_HEIGHT_DELTA ), [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

			if ( COVER_WALL_DEBUG_DRAW_PLACEMENT )
			{
				DebugDrawLine( testPos, traceResult.endPos, 255,0,0, true, 0.05 )
			}

			if ( traceResult.fraction == 1.0 )
			{
				//printt( "PLACEMENT FAILED: TOO FAR FROM GROUND!!!" )
				success = false
				break
			}
		}

		foreach ( vector testOffset in groundTestOffsetsBack )
		{
			vector testPos = wallModel.GetOrigin() + testOffset
			TraceResults traceResult = TraceLine( testPos + ( up * COVER_WALL_PLACEMENT_MAX_HEIGHT_DELTA ), testPos + ( up * -COVER_WALL_PLACEMENT_MAX_HEIGHT_DELTA ), [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

			if ( COVER_WALL_DEBUG_DRAW_PLACEMENT )
			{
				DebugDrawLine( testPos, traceResult.endPos, 255,0,0, true, 0.05 )
			}

			if ( traceResult.fraction == 1.0 )
			{
				//printt( "PLACEMENT FAILED: TOO FAR FROM GROUND!!!" )
				success = false
				break
			}

			//printt( AnglesOnSurface( traceResult.surfaceNormal, AnglesToRight( angles ) ) )

			surfaceNormals += traceResult.surfaceNormal
		}

		surfaceNormals.x /= groundTestOffsetsForward.len()
		surfaceNormals.y /= groundTestOffsetsForward.len()
		surfaceNormals.z /= groundTestOffsetsForward.len()
		surfaceAngles += AnglesOnSurface( surfaceNormals, AnglesToRight( angles ) )
	}

	if ( success )
	{
		vector right = wallModel.GetRightVector()
		vector forward = wallModel.GetForwardVector()
		vector up = wallModel.GetUpVector()

		float length = Length( COVER_WALL_BOUND_MINS )

		array< vector > wallTestOffsets = [
			( right * 8 ) + ( forward * 40 ),
			( -right * 8 ) + ( forward * 40 ),
			( right * 8 ) +  ( -forward * 40 ),
			( -right * 8 ) + ( -forward * 40 )
		]

		foreach ( vector testOffset in wallTestOffsets )
		{
			vector testPos = wallModel.GetWorldSpaceCenter()
			//TraceResults traceResult = TraceLine( testPos + ( up * 64 ), testPos + ( up * -64 ), [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
			TraceResults traceResult = TraceLine( testPos, testPos + testOffset, [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

			if ( COVER_WALL_DEBUG_DRAW_PLACEMENT )
			{
				DebugDrawLine( testPos, traceResult.endPos, 0,255,0, true, 0.05 )
			}

			if ( traceResult.fraction < 1.0 )
			{
				//printt( "PLACEMENT FAILED: INTERSECTS WALL!!!" )
				success = false
				break
			}
		}
	}

	//if ( success && viewTraceResults.hitEnt != null && ( !viewTraceResults.hitEnt.IsWorld() && !isScriptedTurretPlaceable ) )
	//	success = false
	if ( success && hullTraceResults.hitEnt != null && ( !hullTraceResults.hitEnt.IsWorld() && !isScriptedTurretPlaceable ) )
	{
		//printt( "PLACEMENT FAILED: PLAYER DID NOT HIT VALID ENT!!!" )
		success = false
	}

	//BOOL SHOULD BE TRUE - This is causing issues with the sight blocker effect of smoke, so it's temporarily disabled. This results in the bug mentioned below.
	if ( success && !PlayerCanSeePos( player, hullTraceResults.endPos, true, 90 ) ) //Just to stop players from putting turrets through thin walls
	{
		//printt( "PLACEMENT FAILED: PLAYER CAN'T REACH POSITION!!!" )
		success = false
	}

	vector org = success ? hullTraceResults.endPos - <0,0,COVER_WALL_BOUND_MAXS.x> : idealPos // for some reason this trace isn't perfectly flush with the ground
	vector ang = success ? surfaceAngles : AnglesCompose( angles, <0,-90,0> )
	CoverWallPlacementInfo placementInfo
	placementInfo.success = success
	placementInfo.origin = org
	placementInfo.angles = ang//angles
	placementInfo.parentTo = parentTo

	return placementInfo
}