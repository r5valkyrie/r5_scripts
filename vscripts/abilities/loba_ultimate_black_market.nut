#if SERVER || CLIENT || UI
global function LobaUltimateBlackMarket_LevelInit

global function GetBlackMarketNearbyLootRadius
global function GetBlackMarketUseLimit
#endif

#if SERVER
global function DoBlackMarketPrePickupLogic
global function DoBlackMarketPostPickupLogic
global function ForceKillBlackMarket
global function ClientCallback_OpenBlackMarket
global function ClientCallback_CloseBlackMarket
global function ClientCallback_TryPickupBlackMarket
global function GetBlackMarketInUseByPlayer
#endif

#if SERVER || CLIENT
global function OnWeaponRegenEnd_ability_black_market
global function OnWeaponAttemptOffhandSwitch_ability_black_market
global function OnWeaponActivate_ability_black_market
global function OnWeaponDeactivate_ability_black_market
global function OnWeaponPrimaryAttack_ability_black_market
global function GetBlackMarketUseCount
global function GetBlackMarketLastUseTime
#endif

#if CLIENT
global function ServerToClient_UpdateBlackMarketUseCount
global function GetBlackMarketUseItemRefs

#endif
#if SERVER || CLIENT
global const string BLACK_MARKET_SCRIPTNAME = "black_market"
global const string BLACK_MARKET_MOVER_SCRIPTNAME = "black_market_mover"
global const string BLACK_MARKET_HIGHLIGHT_PROXY_SCRIPTNAME = "black_market_highlight_proxy"
global const string BLACK_MARKET_CLOSE_CMD = "ClientCallback_CloseBlackMarket"
const string BLACK_MARKET_OPEN_CMD = "ClientCallback_OpenBlackMarket"
const string BLACK_MARKET_TRY_PICKUP_CMD = "ClientCallback_TryPickupBlackMarket"
const string BLACK_MARKET_ENTITY_CLASS = "prop_death_box"
const string BLACK_MARKET_LEGACY_ENTITY_CLASS = "prop_death_box"

const asset BLACK_MARKET_MODEL = $"mdl/props/loba_loot_stick/loba_loot_stick.rmdl"
const asset BLACK_MARKET_PROXY_MODEL = $"mdl/fx/loba_staff_holo_stand.rmdl"

const asset BLACK_MARKET_RADIUS_FX = $"P_loba_staff_ar_ring"
const string BLACK_MARKET_PLACEMENT_IMPACT_TABLE = "black_market_placement"
const asset BLACK_MARKET_START_FX = $"P_loba_staff_ar_init"
const string BLACK_MARKET_START_IMPACT_TABLE = "black_market_activation"
const asset BLACK_MARKET_DESTRUCTION_FX = $"P_loba_staff_exp"
const string BLACK_MARKET_START_FRIENDLY_SOUND = "Loba_Ultimate_BlackMarket_Pulse"
const string BLACK_MARKET_START_ENEMY_SOUND = "Loba_Ultimate_BlackMarket_Pulse"
const asset BLACK_MARKET_WARP_BEAM_FX = $"P_item_warp_travel"

const float BLACK_MARKET_PLACEMENT_RANGE_MAX = 94
const float BLACK_MARKET_PLACEMENT_RANGE_MIN = 64
const float BLACK_MARKET_PLACEMENT_ANGLE_LIMIT = 0.74
const vector BLACK_MARKET_PLACEMENT_OFFSET = <0, 0, 0>
const vector BLACK_MARKET_BOUND_MINS = <-16, -16, 0>
const vector BLACK_MARKET_BOUND_MAXS = <16, 16, 80>
const vector BLACK_MARKET_PLACEMENT_DOWN_TRACE_OFFSET = <0, 0, 94>
const float BLACK_MARKET_PLACEMENT_MAX_GROUND_DIST = 12.0

const vector BLACK_MARKET_PLACEMENT_COLOR = <1, 1, 1>
const float BLACK_MARKET_PLACEMENT_PLAYER_ALPHA = 1.0
const float BLACK_MARKET_PLACEMENT_SPECTATOR_ALPHA = 0.2

const bool BLACK_MARKET_DEBUG = false
const bool BLACK_MARKET_DEBUG_DRAW_PLACEMENT = false

const vector BLACK_MARKET_PLACEMENT_SIGHT_CHECK_OFFSET = < 0, 0, 4 >
#endif


#if SERVER || CLIENT
struct PlacementInfo
{
	vector origin
	vector angles
	entity parentTo
	bool   success = false
	string failReason = ""
}
#endif


#if SERVER || CLIENT
struct BlackMarketPlayerUseData
{
	array<LootData> lootFlavs
	array<int>      lootCounts
	float           lastUseTime
}
#endif


struct {
	#if SERVER || CLIENT
		table< EHI, table< EHI, BlackMarketPlayerUseData > > byBlackMarket_byPlayer_useData
	#endif
	#if SERVER
		table< entity, entity > playersToBlackMarketMap
	#endif
} file


#if SERVER || CLIENT || UI
void function LobaUltimateBlackMarket_LevelInit()
{
	#if SERVER || CLIENT
		PrecacheParticleSystem( BLACK_MARKET_RADIUS_FX )
		PrecacheImpactEffectTable( BLACK_MARKET_PLACEMENT_IMPACT_TABLE )
		PrecacheParticleSystem( BLACK_MARKET_START_FX )
		PrecacheImpactEffectTable( BLACK_MARKET_START_IMPACT_TABLE )
		PrecacheParticleSystem( BLACK_MARKET_DESTRUCTION_FX )
		PrecacheParticleSystem( BLACK_MARKET_WARP_BEAM_FX )
		PrecacheModel( BLACK_MARKET_MODEL )
		PrecacheModel( BLACK_MARKET_PROXY_MODEL )

		Remote_RegisterClientFunction( "ServerToClient_UpdateBlackMarketUseCount",
			"int", 0, INT_MAX, // EEH for blackMarket
			"int", 0, INT_MAX, // EEH for user
			"int", 0, 255, // int useCount
			"int", 0, 4096, // int lootRefIdx
			"int", 0, 4096, // int lootRefCount
			"int", 0, 255 // int maxUseCount
		)

	#endif

	#if SERVER
		AddClientCommandCallback( BLACK_MARKET_OPEN_CMD, ClientCallback_OpenBlackMarket )
		AddClientCommandCallback( BLACK_MARKET_CLOSE_CMD, ClientCallback_CloseBlackMarket )
		AddClientCommandCallback( BLACK_MARKET_TRY_PICKUP_CMD, ClientCallback_TryPickupBlackMarket )

		Loot_AddCallback_OnPlayerLootPickup( OnPlayerLootPickup )
		RegisterDynamicEntCleanupItem_Parented_Scriptname( BLACK_MARKET_SCRIPTNAME, ForceKillBlackMarket )
		RegisterDynamicEntCleanupItem_Area_Scriptname( BLACK_MARKET_SCRIPTNAME, ForceKillBlackMarket )
	#endif

	#if CLIENT
		AddCreateCallback( BLACK_MARKET_ENTITY_CLASS, OnPropScriptCreated )

		RegisterSignal( "BlackMarket_StopPlacementProxy" )

		RegisterMinimapPackage( BLACK_MARKET_ENTITY_CLASS, eMinimapObject_prop_script.BLACK_MARKET,
			MINIMAP_OBJ_AREA_RUI, void function( entity ent, var rui ) {
				SetupMapRui( ent, rui, false )
			},
			$"ui/in_world_minimap_objective_area.rpak", void function( entity ent, var rui ) {
				SetupMapRui( ent, rui, true )
			}
		)

		RegisterConCommandTriggeredCallback( "+scriptCommand5", OnCharacterButtonPressed )
	#endif
}
#endif


#if SERVER || CLIENT
void function OnWeaponRegenEnd_ability_black_market( entity weapon )
{
	OnWeaponRegenEndGeneric( weapon )
}
#endif


#if SERVER || CLIENT
bool function OnWeaponAttemptOffhandSwitch_ability_black_market( entity weapon )
{
	return true
}
#endif


#if SERVER || CLIENT
void function OnWeaponActivate_ability_black_market( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	#if CLIENT
		if ( !InPrediction() || !IsFirstTimePredicted() )
			return

		OnBeginPlacement( weapon, owner )
	#endif
}
#endif


#if SERVER || CLIENT
void function OnWeaponDeactivate_ability_black_market( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	#if CLIENT
		OnEndPlacement( owner )
		if ( !InPrediction() || !IsFirstTimePredicted() )
			return
	#endif
}
#endif


#if SERVER || CLIENT
var function OnWeaponPrimaryAttack_ability_black_market( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()

	PlacementInfo placementInfo = GetPlacementInfo( owner )

	if ( !placementInfo.success )
		return 0

	#if SERVER
		thread BlackMarketDeployThread( owner, placementInfo )
	#endif

	PlayerUsedOffhand( owner, weapon, true, null, {pos = placementInfo.origin} )

#if CLIENT
	if ( InPrediction() )
	{
		OnEndPlacement( owner )
	}
#endif

	return weapon.GetAmmoPerShot()
}
#endif


#if SERVER || CLIENT
PlacementInfo function GetPlacementInfo( entity player )
{
	PlacementInfo info
	info.success = true

	vector eyePos            = player.EyePosition()
	vector viewVec           = player.GetViewVector()
	vector angles            = < 0, VectorToAngles( viewVec ).y, 0 >
	vector up                = <0, 0, 1>
	float hullWidth          = BLACK_MARKET_BOUND_MAXS.x - BLACK_MARKET_BOUND_MINS.x
	float hullHeight         = BLACK_MARKET_BOUND_MAXS.z - BLACK_MARKET_BOUND_MINS.z
	array<entity> ignoreEnts = []

	float range = BLACK_MARKET_PLACEMENT_RANGE_MAX

	TraceResults viewTraceResults = TraceLine(
		eyePos,
		eyePos + player.GetViewVector() * (BLACK_MARKET_PLACEMENT_RANGE_MAX + 0.5 * hullWidth),
		ignoreEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_NONE, player )

	TraceResults fwdResults = TraceHull(
		viewTraceResults.endPos - 0.5 * (BLACK_MARKET_PLACEMENT_RANGE_MAX - BLACK_MARKET_PLACEMENT_RANGE_MIN) * viewVec,
		viewTraceResults.endPos - 0.5 * hullWidth * viewVec,
		BLACK_MARKET_BOUND_MINS, BLACK_MARKET_BOUND_MAXS,
		ignoreEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_NONE, up, player )

	TraceResults downResults = TraceHull(
		fwdResults.endPos - 1.0 * viewVec,
		fwdResults.endPos - 1.0 * viewVec - BLACK_MARKET_PLACEMENT_DOWN_TRACE_OFFSET,
		BLACK_MARKET_BOUND_MINS, BLACK_MARKET_BOUND_MAXS,
		ignoreEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_NONE, up, player )

	info.origin = downResults.endPos
	info.angles = AnglesCompose( angles, <0, 180, 0> )

	#if BLACK_MARKET_DEBUG_DRAW_PLACEMENT
		//DebugDrawBox( fwdResults.endPos, BLACK_MARKET_BOUND_MINS, BLACK_MARKET_BOUND_MAXS, <0, 255, 0>, 1, 1.0 )
		//DebugDrawBox( info.origin, BLACK_MARKET_BOUND_MINS, BLACK_MARKET_BOUND_MAXS, <0, 0, 255>, 1, 1.0 )
		//DebugDrawLine( eyePos + viewVec * min( BLACK_MARKET_PLACEMENT_RANGE_MIN, range ), fwdResults.endPos, <0, 255, 0>, true, 1.0 )
		//DebugDrawLine( fwdResults.endPos, eyePos + viewVec * range, <255, 0, 0>, true, 1.0 )
		//DebugDrawLine( fwdResults.endPos, info.origin, <0, 0, 255>, true, 1.0 )
		//DebugDrawLine( player.GetOrigin(), player.GetOrigin() + (AnglesToForward( angles ) * BLACK_MARKET_PLACEMENT_RANGE_MAX), <0, 255, 0>, true, 1.0 )
		//DebugDrawLine( eyePos + <0, 0, 8>, eyePos + <0, 0, 8> + (viewVec * BLACK_MARKET_PLACEMENT_RANGE_MAX), <0, 255, 0>, true, 1.0 )
	#endif

	if ( info.success && downResults.fraction > 0.99 )
	{
		info.success = false
		info.failReason = ""
	}

	if ( info.success && downResults.startSolid )
	{
		info.success = false
		info.failReason = "#PLAYER_DEPLOY_FAIL_HINT_START_SOLID"
	}

	info.parentTo = null
	if ( info.success )
	{
		if ( IsValid( downResults.hitEnt ) && CanScriptPlaceableBePlacedOn( downResults.hitEnt ) )
		{
			if ( IsEntInvalidForPlacingPermanentOnto( downResults.hitEnt ) )
			{
				info.success = false
			}
			else if ( ShouldScriptedPlaceableParentTo( downResults.hitEnt ) )
			{
				info.parentTo = downResults.hitEnt
			}
		}
		else
		{
			info.success = false
			info.failReason = "#PLAYER_DEPLOY_FAIL_HINT_INVALID_PARENT"
		}
	}

	if ( info.success )
	{
		if ( IsOriginInvalidForPlacingPermanentOnto( downResults.endPos ) )
		{
			info.success = false
		}
	}

	if ( info.success )
	{
		TraceResults upResults = TraceHull( info.origin, info.origin, BLACK_MARKET_BOUND_MINS, BLACK_MARKET_BOUND_MAXS, ignoreEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_NONE, up, player )
		if ( upResults.startSolid )
		{
			info.success = false
			info.failReason = "#PLAYER_DEPLOY_FAIL_HINT_OBSTRUCTED"
		}
	}

	if ( info.success && !PlayerCanSeePos( player, info.origin + BLACK_MARKET_PLACEMENT_SIGHT_CHECK_OFFSET, true, 90 ) )
	{
		info.success = false
		info.failReason = "#PLAYER_DEPLOY_FAIL_HINT_CANNOT_SEE"
	}

	if ( info.success && DotProduct( downResults.surfaceNormal, up ) < BLACK_MARKET_PLACEMENT_ANGLE_LIMIT )
	{
		info.success = false
		info.failReason = "#PLAYER_DEPLOY_FAIL_HINT_TOO_STEEP"
	}

	if ( GetCurrentPlaylistVarBool("loba_ultimate_respects_oob", true) )
	{
		array<string> triggersToCheck =
		[
			"trigger_out_of_bounds",
			"trigger_no_object_placement",
			"trigger_networked_out_of_bounds",
			"trigger_networked_no_op",
			"trigger_networked_block_all_op"
		]

		array<vector> triggerTestPoints = [
			info.origin,
			info.origin + < BLACK_MARKET_BOUND_MINS.x, BLACK_MARKET_BOUND_MINS.y, BLACK_MARKET_BOUND_MINS.z >,
			info.origin + < BLACK_MARKET_BOUND_MINS.x, BLACK_MARKET_BOUND_MAXS.y, BLACK_MARKET_BOUND_MINS.z >,
			info.origin + < BLACK_MARKET_BOUND_MAXS.x, BLACK_MARKET_BOUND_MINS.y, BLACK_MARKET_BOUND_MINS.z >,
			info.origin + < BLACK_MARKET_BOUND_MAXS.x, BLACK_MARKET_BOUND_MAXS.y, BLACK_MARKET_BOUND_MINS.z >,
			info.origin + < BLACK_MARKET_BOUND_MINS.x, BLACK_MARKET_BOUND_MINS.y, BLACK_MARKET_BOUND_MAXS.z >,
			info.origin + < BLACK_MARKET_BOUND_MINS.x, BLACK_MARKET_BOUND_MAXS.y, BLACK_MARKET_BOUND_MAXS.z >,
			info.origin + < BLACK_MARKET_BOUND_MAXS.x, BLACK_MARKET_BOUND_MINS.y, BLACK_MARKET_BOUND_MAXS.z >,
			info.origin + < BLACK_MARKET_BOUND_MAXS.x, BLACK_MARKET_BOUND_MAXS.y, BLACK_MARKET_BOUND_MAXS.z >
		]

		#if SERVER
			foreach ( string triggerClass in triggersToCheck )
			{
				foreach ( entity trigger in GetEntArrayByClass_Expensive( triggerClass ) )
				{
					if ( !IsValid( trigger ) )
						continue

					if ( !trigger.DoesShareRealms( player ) )
						continue

					bool overlapsBlockedTrigger = false
					foreach ( vector testPoint in triggerTestPoints )
					{
						if ( trigger.ContainsPoint( testPoint ) )
						{
							overlapsBlockedTrigger = true
							break
						}
					}

					if ( !overlapsBlockedTrigger )
						continue

					info.success = false
					info.failReason = "#PLAYER_DEPLOY_FAIL_HINT_OBSTRUCTED"
					break
				}

				if ( !info.success )
					break
			}
		#endif
	}

	if ( info.success )
	{
		if ( IsOriginInvalidForPlacingPermanentOnto( info.origin ) )
		{
			info.success = false
			info.failReason = "#PLAYER_DEPLOY_FAIL_HINT_OBSTRUCTED"
		}
	}

	if ( info.success )
	{
		vector onSurfaceAngles = AnglesOnSurface( downResults.surfaceNormal, AnglesToForward( angles ) )
		vector osaForward      = AnglesToForward( onSurfaceAngles )
		vector osaUp           = AnglesToUp( onSurfaceAngles )
		vector osaRight        = AnglesToRight( onSurfaceAngles )

		float length = Length( BLACK_MARKET_BOUND_MINS )

		array< vector > groundTestOffsets = [
			Normalize( osaRight + osaForward ) * length,
			Normalize( -osaRight + osaForward ) * length,
			Normalize( osaRight + -osaForward ) * length,
			Normalize( -osaRight + -osaForward ) * length
		]

		#if BLACK_MARKET_DEBUG_DRAW_PLACEMENT
			//DebugDrawLine( info.origin, info.origin + (osaRight * 64), <0, 255, 0>, true, 1.0 )
			//DebugDrawLine( info.origin, info.origin + (osaForward * 64), <0, 0, 255>, true, 1.0 )
		#endif

		foreach ( vector testOffset in groundTestOffsets )
		{
			vector testPos           = info.origin + testOffset
			TraceResults traceResult = TraceLine(
				testPos + (osaUp * BLACK_MARKET_PLACEMENT_MAX_GROUND_DIST),
				testPos + (osaUp * -BLACK_MARKET_PLACEMENT_MAX_GROUND_DIST),
				ignoreEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_NONE )

			#if BLACK_MARKET_DEBUG_DRAW_PLACEMENT
				//DebugDrawLine( testPos + (osaUp * BLACK_MARKET_PLACEMENT_MAX_GROUND_DIST), traceResult.endPos, <255, 0, 0>, true, 1.0 )
			#endif

			if ( traceResult.fraction == 1.0 )
			{
				info.success = false
				info.failReason = "#PLAYER_DEPLOY_FAIL_HINT_TOO_UNEVEN"
				break
			}
		}
	}

	info.origin += BLACK_MARKET_PLACEMENT_OFFSET

	return info
}
#endif

#if CLIENT
void function OnBeginPlacement( entity weapon, entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	thread PlacementProxyThread( weapon, player )
}
#endif


#if CLIENT
void function OnEndPlacement( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	player.Signal( "BlackMarket_StopPlacementProxy" )
}
#endif


#if CLIENT
void function PlacementProxyThread( entity weapon, entity player )
{
	weapon.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "BlackMarket_StopPlacementProxy" )

	entity proxy = CreateClientSidePropDynamic( <0, 0, 0>, <0, 0, 0>, BLACK_MARKET_PROXY_MODEL )
	proxy.EnableRenderAlways()
	proxy.kv.rendermode = 3
	proxy.kv.renderamt = 1
	DeployableModelHighlight( proxy )

	float lootGrabDist = GetBlackMarketNearbyLootRadius( player )

	proxy.e.clientEntMinimapClassName = BLACK_MARKET_ENTITY_CLASS
	proxy.e.clientEntMinimapCustomState = eMinimapObject_prop_script.BLACK_MARKET
	proxy.e.clientEntMinimapFlags = 1
	proxy.e.clientEntMinimapScale = lootGrabDist / 16384.0
	proxy.e.clientEntMinimapZOrder = MINIMAP_Z_OBJECT
	if ( proxy.GetNetworkedClassName() != null )
		thread AddMinimapObject( proxy )

	int proxyRadiusFx = StartParticleEffectOnEntity( proxy, GetParticleSystemIndex( BLACK_MARKET_RADIUS_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	EffectSetControlPointVector( proxyRadiusFx, 1, <lootGrabDist, 0, 0> )

	string[1] displayedHint = [""]

	OnThreadEnd( void function() : ( proxy, proxyRadiusFx, displayedHint ) {
		if ( EffectDoesExist( proxyRadiusFx ) )
			EffectStop( proxyRadiusFx, false, true )

		if ( IsValid( proxy ) )
			proxy.Destroy()

		if ( displayedHint[0] != "" )
			HidePlayerHint( displayedHint[0] )
	} )

	PlacementInfo placementInfo
	while ( true )
	{
		placementInfo = GetPlacementInfo( player )

		proxy.SetOrigin( placementInfo.origin )
		proxy.SetAngles( placementInfo.angles )
		if ( IsValid( placementInfo.parentTo ) )
			proxy.SetParent( placementInfo.parentTo, "", true )
		proxy.SetOrigin( placementInfo.origin )
		proxy.SetAngles( placementInfo.angles )

		string hint
		if ( placementInfo.success )
		{
			hint = "#LOBA_ULT_BLACK_MARKET_DEPLOY_HINT"
			DeployableModelHighlight( proxy )
		}
		else
		{
			hint = placementInfo.failReason
			DeployableModelInvalidHighlight( proxy )
		}

		if ( hint != displayedHint[0] )
		{
			if ( displayedHint[0] != "" )
				HidePlayerHint( displayedHint[0] )
			if ( hint != "" )
				AddPlayerHint( 60.0, 0, $"", hint )
			displayedHint[0] = hint
		}

		WaitFrame()
	}
}
#endif


#if SERVER
void function BlackMarketDeployThread( entity owner, PlacementInfo placementInfo )
{
	vector origin = placementInfo.origin
	vector angles = placementInfo.angles

	float lootGrabDist = GetBlackMarketNearbyLootRadius( owner )

	int maxConcurrentBlackMarketCount = GetCurrentPlaylistVarInt( "loba_ultimate_max_concurrent", 1 )
	while ( owner.e.activeUltimateTraps.len() > (maxConcurrentBlackMarketCount - 1) )
	{
		entity entToDelete = owner.e.activeUltimateTraps.pop()
		if( IsValid( entToDelete ) )
		{
			if ( IsBlackMarketDevice( entToDelete ) )
			{
				if ( !GradeFlagsHas( entToDelete, eGradeFlags.IS_BUSY ) )
				{
					GradeFlagsSet( entToDelete, eGradeFlags.IS_BUSY )

					thread (void function() : ( entToDelete ) {
						OnThreadEnd( void function() : ( entToDelete ) {
							if ( IsValid( entToDelete ) )
								entToDelete.Destroy()
						} )
						if ( IsValid( entToDelete.e.highlightProxy ) )
							entToDelete.e.highlightProxy.Destroy()
						waitthread PlayAnim( entToDelete, "mp_prop_lootcane_destroy" )
					})()
				}
				else if ( !entToDelete.IsDissolving() )
				{
					entToDelete.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 500 )
				}
			}
			else
			{
				entToDelete.Destroy()
			}
		}
	}

	entity blackMarket
	{
		blackMarket = CreateEntity( BLACK_MARKET_ENTITY_CLASS )
		blackMarket.SetScriptName( BLACK_MARKET_SCRIPTNAME )
		SetTargetName( blackMarket, BLACK_MARKET_SCRIPTNAME )

		blackMarket.SetValueForModelKey( BLACK_MARKET_MODEL )
		blackMarket.kv.fadedist = 320000
		blackMarket.kv.solid = SOLID_CYLINDER
		{
			int contents = int( blackMarket.kv.contents )
			contents = (contents | CONTENTS_NOCLIMB)
			contents = (contents & ~CONTENTS_TITANCLIP)
			blackMarket.kv.contents = contents
		}

		blackMarket.DisableHibernation()

		blackMarket.SetOrigin( origin )
		blackMarket.SetAngles( angles )

		//if ( blackMarket.SetLootGrabDist != null )
		//	blackMarket.SetLootGrabDist( lootGrabDist )

		#if BLACK_MARKET_DEBUG
			//DebugDrawCircle( origin, <0, 0, 0>, lootGrabDist, <255, 0, 0>, true, 20.0 )
		#endif

		blackMarket.SetOwner( owner )
		SetTeam( blackMarket, owner.GetTeam() )

		blackMarket.SetAbsOrigin( origin )
		blackMarket.SetAbsAngles( angles )

		blackMarket.SetCanBeMeleed( true )
		SetVisibleEntitiesInConeQueriableEnabled( blackMarket, true )

		thread TrapDestroyOnRoundEnd( owner, blackMarket )

		AddSonarDetectionForPropScript( blackMarket )

		blackMarket.Minimap_SetCustomState( eMinimapObject_prop_script.BLACK_MARKET )
		foreach ( entity player in GetPlayerArray() )
			blackMarket.Minimap_Hide( player.GetTeam(), null )
		blackMarket.Minimap_AlwaysShow( owner.GetTeam(), null )

		// AllianceProximity_SetMinimapAlwaysShow_ForAlliance( owner.GetTeam(), blackMarket, null )  // TODO: Port if needed

		blackMarket.Minimap_SetObjectScale( lootGrabDist / 16384.0 )
		blackMarket.Minimap_SetAlignUpright( true )
		blackMarket.Minimap_SetZOrder( MINIMAP_Z_OBJECT )

		DispatchSpawn( blackMarket )

		blackMarket.kv.impacteffectcolorid = COLORID_FX_LOOT_TIER1
		blackMarket.SetTouchTriggers( true )
		blackMarket.SetIgnorePredictedTriggerTypes( TT_JUMP_PAD  )
		blackMarket.SetPhysics( MOVETYPE_FLY )

		if ( IsValid( placementInfo.parentTo ) )
		{
			entity mover = CreateScriptMover_NEW( BLACK_MARKET_MOVER_SCRIPTNAME, origin, angles )
			mover.SetParent( placementInfo.parentTo )
			blackMarket.SetParent( mover )
		}

		int health = GetCurrentPlaylistVarInt( "loba_ultimate_health", 150 )
		blackMarket.SetMaxHealth( health )
		blackMarket.SetHealth( health )

		AddToUltimateRealm( owner, blackMarket )

		blackMarket.SetTakeDamageType( DAMAGE_YES )
		blackMarket.SetBlocksRadiusDamage( false )
		blackMarket.e.noFriendlyFireProtection = true
		AddEntityCallback_OnPostDamaged( blackMarket, OnBlackMarketPostDamaged )
		AddEntityCallback_OnKilled( blackMarket, OnBlackMarketKilled )

		blackMarket.e.canBurn = true
		blackMarket.e.canBeDamagedFromGas = false
		AddEMPDestroyDeviceNoDissolve( blackMarket )

		AddWreckingBallEMPDamageDevice( blackMarket )

		thread (void function() : (blackMarket) {
			blackMarket.EndSignal( "OnDestroy" )

			blackMarket.WaitSignal( "EMP_Destroy" )
			blackMarket.TakeDamage( 99999, null, null, {} )
		})()

		SetCallback_CanUseEntityCallback_Retail( blackMarket, CanUseBlackMarket )
		AddCallback_OnUseEntity_ClientServer( blackMarket, OnBlackMarketUsed )
		SetCallback_ShouldUseBlockReloadCallback( blackMarket, SimpleShouldNotBlockReloadCallback )
	}

	entity blackMarketHighlightProxy
	{
		blackMarketHighlightProxy = CreatePropDynamic( BLACK_MARKET_PROXY_MODEL, blackMarket.GetOrigin(), blackMarket.GetAngles(), 0, 320000, false )
		blackMarket.e.highlightProxy = blackMarketHighlightProxy

		blackMarketHighlightProxy.kv.rendermode = 3
		blackMarketHighlightProxy.kv.renderamt = 1

		CopyRealmsFromTo( blackMarket, blackMarketHighlightProxy )
		blackMarketHighlightProxy.SetParent( blackMarket )
		blackMarketHighlightProxy.DisableHibernation()

		SetTeam( blackMarketHighlightProxy, blackMarket.GetTeam() )
		blackMarketHighlightProxy.SetOwner( blackMarket.GetOwner() )
		blackMarketHighlightProxy.Highlight_Enable()
		Highlight_SetOwnedHighlight( blackMarketHighlightProxy, "sp_friendly_hero_force_on" )
		Highlight_SetFriendlyHighlight( blackMarketHighlightProxy, "sp_friendly_hero_force_on" )

		DispatchSpawn( blackMarketHighlightProxy )
		blackMarketHighlightProxy.SetAbsOrigin( blackMarket.GetOrigin() )
		blackMarketHighlightProxy.SetAbsAngles( blackMarket.GetAngles() )
	}

	owner.e.activeUltimateTraps.insert( 0, blackMarket )

	EndSignal( blackMarket, "OnDestroy" )

	OnThreadEnd( void function() : ( blackMarket, owner, blackMarketHighlightProxy ) {
		if ( IsValid( owner ) )
			owner.e.activeUltimateTraps.fastremovebyvalue( blackMarket )
		if ( IsValid( blackMarket ) )
			blackMarket.Destroy()
		if ( IsValid( blackMarketHighlightProxy ) )
			blackMarketHighlightProxy.Destroy()
	} )

	GradeFlagsSet( blackMarket, eGradeFlags.IS_BUSY )

	blackMarketHighlightProxy.Hide()
	blackMarket.Hide()
	blackMarket.NotSolid()
	wait 0.4
	blackMarket.Show()
	blackMarket.Solid()

	if ( GetCurrentPlaylistVarBool( LOOT_BIN_DELAY_LOOT_SPAWNING_PLAYLIST_VAR, true ) )
	{
		TriggerLootSpawnForLootBinsInRadius( blackMarket.GetOrigin(), lootGrabDist, eLootTier.NONE, 10 )
	}

	WaitFrame()

	EmitSoundOnEntity( blackMarket, "Loba_Ultimate_Staff_Impact_Generic" )

	blackMarket.SetUsable()
	blackMarket.SetUsableByGroup( "pilot" )
	blackMarket.AddUsableValue( USABLE_CUSTOM_HINTS )
	blackMarket.SetUsablePriority( USABLE_PRIORITY_LOW )

	PlayBattleChatterLineToSpeakerAndTeam( owner, "bc_super" )

	//if ( IsValid( owner ) )
	//	CreateWaypoint_Ping_Location( owner, ePingType.ABILITY_BLACK_MARKET, blackMarket, blackMarket.GetOrigin(), -1, false )

	PlayImpactFXTable( blackMarket.GetOrigin(), blackMarket, BLACK_MARKET_PLACEMENT_IMPACT_TABLE )

	blackMarket.Anim_DisableUpdatePosition()
	waitthread PlayAnim( blackMarket, "mp_prop_lootcane_deploy" )
	blackMarketHighlightProxy.Show()

	thread PlayAnim( blackMarket, "mp_prop_lootcane_deploy_idle" )

	GradeFlagsClear( blackMarket, eGradeFlags.IS_BUSY )

	StartParticleEffectOnEntity( blackMarket, GetParticleSystemIndex( BLACK_MARKET_START_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	PlayImpactFXTable( blackMarket.GetOrigin(), blackMarket, BLACK_MARKET_START_IMPACT_TABLE )
	EmitSoundOnEntityToTeam( blackMarket, BLACK_MARKET_START_FRIENDLY_SOUND, blackMarket.GetTeam() )
	EmitSoundOnEntityToEnemies( blackMarket, BLACK_MARKET_START_ENEMY_SOUND, blackMarket.GetTeam() )

	while( true )
	{
		TriggerLootSpawnForLootBinsInRadius( blackMarket.GetOrigin(), lootGrabDist, eLootTier.NONE )
		wait 0.5
	}
}
#endif


#if SERVER
void function OnBlackMarketPostDamaged( entity device, var damageInfo )
{
	float damage = DamageInfo_GetDamage( damageInfo )

	if ( damage <= 0 )
		return

	if ( IsBitFlagSet( DamageInfo_GetCustomDamageType( damageInfo ), DF_MELEE ) )
		DamageInfo_SetDamage( damageInfo, device.GetMaxHealth() * (1.0 / GetCurrentPlaylistVarFloat( "loba_ult_melee_hits_to_kill", 2.85714285714 )) )

	if ( device.GetHealth() < DamageInfo_GetDamage( damageInfo ) )
		EmitSoundAtPosition( device.GetTeam(), device.GetOrigin(), "Loba_Ultimate_Staff_Destroy", device )

	float newHealth = max( device.GetHealth() - damage, 0.0 )
	if ( newHealth <= 0 )
		DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
	else
		DamageInfo_AddCustomDamageType( damageInfo, DF_SOUR )

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( IsValid( attacker ) && attacker.IsPlayer() )
	{
		float damageToDisplay = DamageInfo_GetDamage( damageInfo )
		attacker.NotifyDidDamage(
			device, DamageInfo_GetHitBox( damageInfo ),
			DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ),
			damageToDisplay,
			DamageInfo_GetDamageFlags( damageInfo ), DamageInfo_GetHitGroup( damageInfo ),
			DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo )
		)
	}
}
#endif


#if SERVER
void function OnBlackMarketKilled( entity device, var damageInfo )
{
	StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( BLACK_MARKET_DESTRUCTION_FX ), device.GetOrigin(), device.GetAngles() )
}
#endif


#if SERVER
int function DoBlackMarketPrePickupLogic( entity player, entity blackMarket, entity lootEnt, int pickupFlags )
{
	entity blackMarketOwner = blackMarket.GetOwner()
	int blackMarketFailure = -1
	if ( GradeFlagsHas( blackMarket, eGradeFlags.IS_BUSY ) )
	{
		PIN_PlayerAbility( player, "mp_ability_black_market", ABILITY_TYPE.ULTIMATE, null, {loot_success = false, reason = "is_busy"} )
		return blackMarketFailure
	}

	if ( Distance( blackMarket.GetOrigin(), lootEnt.GetOrigin() ) > GetBlackMarketNearbyLootRadius( blackMarketOwner ) )
	{
		PIN_PlayerAbility( player, "mp_ability_black_market", ABILITY_TYPE.ULTIMATE, null, {loot_success = false, reason = "too_far"} )
		return blackMarketFailure
	}

	if ( !IsBitFlagSet( pickupFlags, PICKUP_FLAG_DONT_COUNT_TOWARD_BLACK_MARKET_QUOTA )
		&& GetBlackMarketUseCount( blackMarket, player ) >= GetBlackMarketUseLimit( blackMarket, player ) )
	{
		PIN_PlayerAbility( player, "mp_ability_black_market", ABILITY_TYPE.ULTIMATE, null, {loot_success = false, reason = "at_quota"} )
		return blackMarketFailure
	}

	return pickupFlags
}
#endif


#if SERVER
void function DoBlackMarketPostPickupLogic( entity player, entity blackMarket, entity lootEnt, LootData lootFlav, int unitsPickedUp, int pickupFlags )
{
	int useCount = GetBlackMarketUseCount( blackMarket, player )

	if ( !IsBitFlagSet( pickupFlags, PICKUP_FLAG_DONT_COUNT_TOWARD_BLACK_MARKET_QUOTA ) )
		useCount += 1

	Assert( useCount > 0 || IsBitFlagSet( pickupFlags, PICKUP_FLAG_DONT_COUNT_TOWARD_BLACK_MARKET_QUOTA ) )
	if ( useCount > 0 )
	{
		int maxUseCount = GetBlackMarketUseLimit( blackMarket, player )
		if ( !IsBitFlagSet( pickupFlags, PICKUP_FLAG_DONT_COUNT_TOWARD_BLACK_MARKET_QUOTA ) )
		{
			// This bumps GetBlackMarketUseCount
			AddToBlackMarketPlayerUseData(
				blackMarket, player,
				useCount, lootFlav.index, unitsPickedUp, maxUseCount )
		}

		foreach ( entity teammate in GetPlayerArrayOfTeam_Connected( player.GetTeam() ) )
		{
			Remote_CallFunction_NonReplay( teammate, "ServerToClient_UpdateBlackMarketUseCount",
				blackMarket.GetEncodedEHandle(), player.GetEncodedEHandle(),
				GetBlackMarketUseCount( blackMarket, player ), lootFlav.index, unitsPickedUp, maxUseCount )
		}
	}

	entity blackMarketOwner = blackMarket.GetOwner()
	if ( IsValid( blackMarketOwner ) )
	{
		// StatsHook_BlackMarket_OnUsed( blackMarket, blackMarketOwner, player )  // TODO: Port if needed
	}

	entity lootEntParent = lootEnt.GetParent()
	if ( IsValid( lootEntParent ) )
	{
		if ( lootEntParent.GetScriptName() == LOOT_BIN_SCRIPTNAME )
		{
			bool shouldOpenRegularCompartment = true
			bool shouldOpenSecretCompartment  = lootEnt.e.isSecretLoot
			// thread LootBin_ForceOpen_Thread( lootEntParent, shouldOpenRegularCompartment, shouldOpenSecretCompartment )  // TODO: Port if needed
		}
		else if ( lootEntParent.GetScriptName() == CARE_PACKAGE_SCRIPTNAME )
		{
			if ( lootEntParent.DoesShareRealms( player ) )
			{
				// thread RemoteOpenAirdrop( lootEntParent, null )  // TODO: Port if needed
			}
		}
	}

	if ( lootFlav.lootType == eLootType.MAINWEAPON && GetWeaponInfoFileKeyField_GlobalBool( lootFlav.baseWeapon, "uses_ammo_pool" ) )
	{
		if ( GetCurrentPlaylistVarBool( "loba_ultimate_refill_weapon_clip", true ) )
		{
			entity newMainWeapon = player.p.justCreatedSurvivalMainWeapon
			if ( IsValid( newMainWeapon ) && newMainWeapon.GetWeaponClassName() == lootFlav.baseWeapon && newMainWeapon.UsesClipsForAmmo() )
				newMainWeapon.SetWeaponPrimaryClipCount( newMainWeapon.GetWeaponPrimaryClipCountMax() )
		}
	}

	if ( lootFlav.lootType != eLootType.AMMO )
	{
		foreach ( int restrictedLootType in eRestrictedLootTypes )
			SURVIVAL_Loot_MaybeStartRestrictedDefense_Thread( restrictedLootType, lootEnt, blackMarket, player )
	}
}
#endif


#if SERVER
void function OnPlayerLootPickup( entity player, entity lootEnt, string ref, int unitsPickedUp, bool willDestroy, entity blackMarket, int pickupFlags )
{
	LootData lootFlav = SURVIVAL_Loot_GetLootDataByRef( ref )
	entity resolvedBlackMarket = blackMarket

	if ( !IsBlackMarketDevice( resolvedBlackMarket ) )
		resolvedBlackMarket = GetBlackMarketInUseByPlayer( player )

	if ( !IsBlackMarketDevice( resolvedBlackMarket ) )
		return

	if ( !IsValid( lootEnt ) )
		return

	if ( resolvedBlackMarket.GetScriptName() != BLACK_MARKET_SCRIPTNAME )
		return

	Assert( unitsPickedUp > 0, "In OnPlayerLootPickup with unitsPickedUp: " + unitsPickedUp + ". player: " + player + " lootRef: " + ref )

	DoBlackMarketPostPickupLogic( player, resolvedBlackMarket, lootEnt, lootFlav, unitsPickedUp, pickupFlags )

	entity blackMarketOwner = resolvedBlackMarket.GetOwner()
	if ( IsValid( blackMarketOwner )
	&& IsFriendlyTeam( player.GetTeam(), resolvedBlackMarket.GetTeam() )
	&& Distance( player.GetOrigin(), blackMarketOwner.GetOrigin() ) < 620
	&& PlayerCanSee( blackMarketOwner, resolvedBlackMarket, true, 80 )
	&& lootFlav.tier >= eLootTier.RARE
	)
	{
		string bcLine

		if ( player == blackMarketOwner )
			bcLine = "bc_lootingEnemySquad"
		else if ( PlayerDeliveryShouldBeUrgent( blackMarketOwner, player.GetOrigin() ) )
			bcLine = "bc_loba_black_market_friendly_took_loot_urgent"
		else
			bcLine = "bc_loba_black_market_friendly_took_loot_calm"

		thread PlayBattleChatterLineDelayedToSpeakerAndTeamWithDebounceTime_Thread( blackMarketOwner, bcLine, 1.0, 55.0, 100.0, player )
	}

	EmitSoundOnEntity( resolvedBlackMarket, "Loba_Ultimate_BlackMarket_WarpOut" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, lootEnt.GetOrigin(), "Loba_Ultimate_BlackMarket_WarpIn", resolvedBlackMarket )
	thread WarpBeamFXThread( resolvedBlackMarket, resolvedBlackMarket.GetOrigin() + (resolvedBlackMarket.GetUpVector() * 48.0), lootEnt.GetOrigin() )

	//LiveAPI_SendOnePlayerItemEvent( eLiveAPI_EventTypes.blackMarketAction, player, ref )
}
#endif


#if SERVER || CLIENT
void function AddToBlackMarketPlayerUseData( EHI blackMarketEHI, EHI userEHI, int useCount, int lootRefIdx, int lootRefCount, int maxUseCount )
{
	Assert( SURVIVAL_Loot_IsLootIndexValid( lootRefIdx ) )
	LootData lootFlav = SURVIVAL_Loot_GetLootDataByIndex( lootRefIdx )

	if ( !(blackMarketEHI in file.byBlackMarket_byPlayer_useData) )
		file.byBlackMarket_byPlayer_useData[ blackMarketEHI ] <- {}

	BlackMarketPlayerUseData bmpud
	if ( userEHI in file.byBlackMarket_byPlayer_useData[ blackMarketEHI ] )
		bmpud = file.byBlackMarket_byPlayer_useData[ blackMarketEHI ][ userEHI ]
	else
		file.byBlackMarket_byPlayer_useData[ blackMarketEHI ][ userEHI ] <- bmpud

	if ( bmpud.lootFlavs.len() < useCount )
	{
		bmpud.lootFlavs.resize( useCount )
		bmpud.lootCounts.resize( useCount )
	}
	bmpud.lootFlavs[ useCount - 1 ] = lootFlav
	bmpud.lootCounts[ useCount - 1 ] += lootRefCount

	bmpud.lastUseTime = Time()

#if CLIENT
	if ( IsValid( GetLocalViewPlayer() ) && userEHI == GetLocalViewPlayer().GetEncodedEHandle() && useCount >= maxUseCount )
		EmitSoundOnEntity( GetLocalViewPlayer(), "Loba_Ultimate_BlackMarket_MaxedOut" )
#endif

#if CLIENT
	if ( IsValid( GetEntityFromEncodedEHandle( blackMarketEHI ) ) && IsValid( GetEntityFromEncodedEHandle( userEHI ) ) )
#endif
	{
		array<EHI> invalidBlackMarkets = []
		foreach ( EHI bm, table<EHI, BlackMarketPlayerUseData> perPlayerData in file.byBlackMarket_byPlayer_useData )
		{
			if ( !IsValid( FromEHI( bm ) ) )
				invalidBlackMarkets.append( bm )
		}
		foreach ( EHI bm in invalidBlackMarkets )
			delete file.byBlackMarket_byPlayer_useData[bm]
	}
}
#endif


#if SERVER
void function OnClientConnectionRestored( entity player )
{
	thread (void function() : ( player ) {
		EndSignal( player, "OnDestroy" )

		foreach ( entity teammate in GetPlayerArrayOfTeam_Connected( player.GetTeam() ) )
		{
			if ( !IsValid( teammate ) )
				continue

			foreach ( entity blackMarket, table<entity, BlackMarketPlayerUseData> perPlayerData in file.byBlackMarket_byPlayer_useData )
			{
				if ( !IsValid( blackMarket ) )
					continue

				if ( teammate in perPlayerData )
				{
					BlackMarketPlayerUseData data = perPlayerData[teammate]
					foreach ( int pickupIdx, LootData lootFlav in data.lootFlavs )
					{
						if ( !IsValid( teammate ) || !IsValid( blackMarket ) )
							continue

						int maxUseCount = GetBlackMarketUseLimit( blackMarket, player )
						Remote_CallFunction_NonReplay( player, "ServerToClient_UpdateBlackMarketUseCount",
							blackMarket.GetEncodedEHandle(), teammate.GetEncodedEHandle(),
							pickupIdx + 1, lootFlav.index, data.lootCounts[pickupIdx], maxUseCount )

						WaitFrame()
					}
				}
			}
		}
	})();
}
#endif


#if SERVER || CLIENT
float function GetBlackMarketLastUseTime( entity blackMarket, entity user )
{
	EHI blackMarketEHI = ToEHI( blackMarket )
	EHI userEHI        = ToEHI( user )

	if ( blackMarketEHI in file.byBlackMarket_byPlayer_useData )
	{
		if ( userEHI in file.byBlackMarket_byPlayer_useData[blackMarketEHI] )
			return file.byBlackMarket_byPlayer_useData[blackMarketEHI][userEHI].lastUseTime
	}

	return -9999.0
}
#endif


#if SERVER || CLIENT
int function GetBlackMarketUseCount( entity blackMarket, entity user )
{
	EHI blackMarketEHI = ToEHI( blackMarket )
	EHI userEHI        = ToEHI( user )

	if ( blackMarketEHI in file.byBlackMarket_byPlayer_useData )
	{
		if ( userEHI in file.byBlackMarket_byPlayer_useData[blackMarketEHI] )
			return file.byBlackMarket_byPlayer_useData[blackMarketEHI][userEHI].lootFlavs.len()
	}

	return 0
}
#endif


#if SERVER
void function WarpBeamFXThread( entity blackMarket, vector startPos, vector endPos )
{
	entity controlPoint = CreateEntity( "info_placement_helper" )
	SetTargetName( controlPoint, UniqueString( "translocation_endPos" ) )
	controlPoint.SetOrigin( endPos )
	CopyRealmsFromTo( blackMarket, controlPoint )
	DispatchSpawn( controlPoint )

	entity beamFX = CreateEntity( "info_particle_system" )
	beamFX.SetValueForEffectNameKey( BLACK_MARKET_WARP_BEAM_FX )
	beamFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	beamFX.kv.cpoint1 = controlPoint.GetTargetName()
	beamFX.kv.start_active = 1
	beamFX.SetOrigin( startPos )
	CopyRealmsFromTo( blackMarket, beamFX )
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


#if SERVER
bool function ClientCallback_OpenBlackMarket( entity player, array<string> args )
{
	if ( args.len() < 1 )
		return true

	entity grabber = GetEntByIndex( args[0].tointeger() )

	if ( !IsBlackMarketDevice( grabber ) || !IsValid( player ) || !player.IsPlayer() )
		return true

	//if ( grabber.IncrementPlayersGrabbingLoot != null )
		//grabber.IncrementPlayersGrabbingLoot()
	file.playersToBlackMarketMap[ player ] <- grabber

	return true
}
#endif


#if SERVER
bool function ClientCallback_CloseBlackMarket( entity player, array<string> args )
{
	if ( args.len() < 1 )
		return true

	entity grabber = GetEntByIndex( args[0].tointeger() )

	if ( !IsBlackMarketDevice( grabber ) || !IsValid( player ) || !player.IsPlayer() )
		return true

	//if ( grabber.DecrementPlayersGrabbingLoot != null )
		//grabber.DecrementPlayersGrabbingLoot()

	if ( player in file.playersToBlackMarketMap )
		delete file.playersToBlackMarketMap[ player ]

	return true
}
#endif


#if SERVER
entity function GetBlackMarketInUseByPlayer( entity player )
{
	entity grabber = null

	if ( !IsValid( player ) )
		return grabber

	if ( player in file.playersToBlackMarketMap )
		grabber = file.playersToBlackMarketMap[ player ]

	return grabber
}
#endif


#if SERVER || CLIENT
bool function IsBlackMarketDevice( entity ent )
{
	if ( !IsValid( ent ) )
		return false

	if ( ent.GetScriptName() == BLACK_MARKET_SCRIPTNAME )
		return true

	return ent.GetNetworkedClassName() == BLACK_MARKET_LEGACY_ENTITY_CLASS
}
#endif


#if SERVER || CLIENT
bool function CanUseBlackMarket( entity player, entity ent, int useFlags )
{
	return SURVIVAL_PlayerAllowedToPickup( player )
}
#endif

#if CLIENT
void function ServerToClient_UpdateBlackMarketUseCount( EncodedEHandle blackMarketEEH, EncodedEHandle userEEH, int useCount, int lootRefIdx, int lootRefCount, int maxUseCount )
{
	LootData lootFlav = SURVIVAL_Loot_GetLootDataByIndex( lootRefIdx )
	if (lootFlav.lootType != eLootType.AMMO)
		AddToBlackMarketPlayerUseData( blackMarketEEH, userEEH, useCount, lootRefIdx, lootRefCount, maxUseCount )
}
#endif


#if SERVER || CLIENT
void function OnBlackMarketUsed( entity blackMarket, entity player, int useInputFlags )
{
	if ( !IsBitFlagSet( useInputFlags, USE_INPUT_LONG ) )
		return

	if ( IsBitFlagSet( useInputFlags, USE_INPUT_ALT ) )
		return

	#if CLIENT
		if ( Survival_IsGroundlistOpen() )
			return
	#endif

	if ( GradeFlagsHas( blackMarket, eGradeFlags.IS_BUSY ) )
		return

	thread (void function() : ( blackMarket, player ) {
		ExtendedUseSettings settings
		settings.duration = GetCurrentPlaylistVarFloat( "loba_ultimate_open_duration", 0.3 )
		settings.disableWeaponTypes = WPT_TACTICAL | WPT_ULTIMATE | WPT_CONSUMABLE
		settings.loopSound = "UI_Survival_PickupTicker"
		settings.successSound = ""
		#if SERVER
		#elseif CLIENT
			settings.displayRui = $"ui/extended_use_hint.rpak"
			settings.displayRuiFunc = void function( entity blackMarket, entity player, var rui, ExtendedUseSettings settings )
			{
				RuiSetString( rui, "holdButtonHint", settings.holdHint )
				RuiSetString( rui, "hintText", settings.hint )
				RuiSetGameTime( rui, "startTime", Time() )
				RuiSetGameTime( rui, "endTime", Time() + settings.duration )
			}
			settings.icon = $""
			settings.hint = "#PROMPT_OPEN"
			settings.successFunc = void function( entity blackMarket, entity player, ExtendedUseSettings settings )
			{
				OpenSurvivalGroundListRetail( player, blackMarket, eGroundListBehavior.NEARBY, eGroundListType.GRABBER )
				player.ClientCommand( BLACK_MARKET_OPEN_CMD + " " + blackMarket.GetEntIndex() )
			}
		#endif

		#if CLIENT
			EndSignal( clGlobal.levelEnt, "ClearSwapOnUseThread" )
		#endif
		EndSignal( blackMarket, "OnDestroy" )
		waitthread ExtendedUse( blackMarket, player, settings )
	})()
}
#endif


#if CLIENT
void function OnCharacterButtonPressed( entity player )
{
	entity useEnt = player.GetUsePromptEntity()
	if ( !IsBlackMarketDevice( useEnt ) )
		return

	if ( useEnt.GetOwner() != player )
		return

	player.ClientCommand( BLACK_MARKET_TRY_PICKUP_CMD + " " + useEnt.GetEntIndex() )
}
#endif


#if SERVER
bool function ClientCallback_TryPickupBlackMarket( entity player, array<string> args )
{
	if ( args.len() < 1 )
		return false

	entity device = GetEntByIndex( args[0].tointeger() )

	if ( !SURVIVAL_PlayerAllowedToPickup( player ) )
		return false

	if ( !IsBlackMarketDevice( device ) )
		return false

	if ( device != player.GetUseEntity() )
		return false

	if ( GradeFlagsHas( device, eGradeFlags.IS_BUSY ) )
		return false

	GradeFlagsSet( device, eGradeFlags.IS_BUSY )

	thread (void function() : ( device ) {
		OnThreadEnd( void function() : ( device ) {
			if ( IsValid( device ) )
				device.Destroy()
		} )
		if ( IsValid( device.e.highlightProxy ) )
			device.e.highlightProxy.Destroy()
		waitthread PlayAnim( device, "mp_prop_lootcane_destroy" )
	})()

	return true
}
#endif


#if CLIENT
void function OnPropScriptCreated( entity ent )
{
	if ( ent.GetScriptName() == BLACK_MARKET_SCRIPTNAME )
	{
		AddEntityCallback_GetUseEntOverrideText( ent, GetBlackMarketUsePromptText )
		SetCallback_CanUseEntityCallback_Retail( ent, CanUseBlackMarket )
		AddCallback_OnUseEntity_ClientServer( ent, OnBlackMarketUsed )
		SetCallback_ShouldUseBlockReloadCallback( ent, SimpleShouldNotBlockReloadCallback )
	}
	if ( ent.GetScriptName() == BLACK_MARKET_HIGHLIGHT_PROXY_SCRIPTNAME )
	{
		ManageHighlightEntity( ent )
	}
}
#endif


#if CLIENT
string function GetBlackMarketUsePromptText( entity device )
{
	if ( GradeFlagsHas( device, eGradeFlags.IS_BUSY ) )
	{
		if ( !device.e.blackMarket_haveSeenReady )
			return ""
		else
			return ""
	}

	device.e.blackMarket_haveSeenReady = true

	if ( device.GetOwner() == GetLocalClientPlayer() )
		return "#LOBA_ULT_BLACK_MARKET_USE_HINT_OWNER"

	return "#LOBA_ULT_BLACK_MARKET_USE_HINT"
}
#endif


#if CLIENT
void function SetupMapRui( entity ent, var rui, bool isFullMap )
{
	RuiSetAsset( rui, "areaImage", $"rui/hud/character_abilities/loba_ult_map_circle" )
	RuiSetFloat( rui, "areaImageAlpha",
		GetLocalClientPlayer().GetTeam() == TEAM_SPECTATOR ? BLACK_MARKET_PLACEMENT_SPECTATOR_ALPHA : BLACK_MARKET_PLACEMENT_PLAYER_ALPHA )
	RuiSetImage( rui, "clampedImage", $"" )

	string areaColorArgName = "objColor"
	if ( !isFullMap )
	{
		RuiSetBool( rui, "useOverrideColor", true )
		areaColorArgName = "overrideColor"
	}
	RuiSetColorAlpha( rui, areaColorArgName, BLACK_MARKET_PLACEMENT_COLOR, 1 )

	if ( ent.IsClientOnly() )
	{
		RuiSetImage( rui, "centerImage", $"" )
		RuiSetFloat( rui, "objectRadius", ent.e.clientEntMinimapScale )
		thread PROTO_PulseMinimapRui( ent, rui, areaColorArgName )
	}
	else
	{
		RuiSetImage( rui, "centerImage", $"rui/hud/gametype_icons/survival/loba_ult_map_icon" )
		RuiTrackFloat( rui, "objectRadius", ent, RUI_TRACK_MINIMAP_SCALE )
	}
}
#endif


#if CLIENT
void function PROTO_PulseMinimapRui( entity ent, var rui, string argName )
{
	EndSignal( ent, "OnDestroy" )

	while ( true )
	{
		float v = 0.8 + 0.6 * sin( 1.15 * 2 * PI * Time() )
		RuiSetColorAlpha( rui, argName, <v, v, v>, v )
		WaitFrame()
	}
}
#endif


float function UpgradedBlackMarketRangeMultiplier()
{
	return GetCurrentPlaylistVarFloat( "loba_ultimate_upgraded_range_multiplier", 1.25 )
}


#if SERVER || CLIENT || UI
float function GetBlackMarketNearbyLootRadius( entity owner = null )
{
	float result = GetCurrentPlaylistVarFloat( "loba_ultimate_nearby_loot_radius", 4500.0 )

	#if SERVER || CLIENT
	if( PlayerHasPassive( owner, ePassives.PAS_ULT_UPGRADE_TWO ) )
	{
		result *= UpgradedBlackMarketRangeMultiplier()
	}
	#endif

	return result
}
#endif


#if SERVER || CLIENT || UI
int function GetBlackMarketUseLimit( entity blackMarket = null, entity player = null )
{
	if ( IsInfiniteAmmoEnabled() )
		return 99
	int result = GetCurrentPlaylistVarInt( "loba_ultimate_use_limit", 2 )

	#if SERVER || CLIENT
		if( !IsValid( blackMarket ) || !IsValid( player ) )
			return result
		if( player.HasPassive( ePassives.PAS_ULT_UPGRADE_ONE ) && player.HasPassive( ePassives.PAS_LOBA_EYE_FOR_QUALITY ) )
		{
			result += 1
		}
	#endif

	return result
}
#endif


#if SERVER
void function ForceKillBlackMarket( entity device )
{
	thread ForceKillBlackMarket_Thread( device )
}

void function ForceKillBlackMarket_Thread( entity device )
{
	if ( IsValid( device ) )
		GradeFlagsSet( device, eGradeFlags.IS_BUSY )

	WaitFrame()

	if ( IsValid( device ) )
		device.TakeDamage( 9999, null, null, {} )
}
#endif

#if CLIENT
array<LootRef> function GetBlackMarketUseItemRefs( entity blackMarket, entity user )
{
	EHI blackMarketEHI = ToEHI( blackMarket )
	EHI userEHI        = ToEHI( user )

	array<LootRef> lootRefs = []
	if ( blackMarketEHI in file.byBlackMarket_byPlayer_useData )
	{
		if ( userEHI in file.byBlackMarket_byPlayer_useData[blackMarketEHI] )
		{
			BlackMarketPlayerUseData data = file.byBlackMarket_byPlayer_useData[blackMarketEHI][userEHI]
			foreach ( int idx, LootData lootFlav in data.lootFlavs )
			{
				LootRef ref
				ref.lootData = lootFlav
				ref.count = data.lootCounts[idx]
				lootRefs.append( ref )
			}
		}
	}
	return lootRefs
}
#endif