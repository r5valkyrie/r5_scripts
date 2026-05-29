             
global function OnWeaponActivate_ability_transport_portal
global function OnWeaponDeactivate_ability_transport_portal
global function OnWeaponTossPrep_ability_transport_portal
global function OnWeaponTossReleaseAnimEvent_ability_transport_portal
global function MpAbilityTransportPortal_Init

global function TransportPortal_IsPlayerCurrentlyChanneling
global function TransportPortal_GetReceiverPlayerIsLookingAt

#if SERVER
global function CreateChasePortal_Thread
global function GetAlterRootEntData
global function ClientToServer_TransportPortal_RecallUlt
global function TransportPortal_EndUseOfDatapad
#endif
#if CLIENT
global function ServerToClient_TransportPortal_UltDurationChanged
global function IsPlayersBeingWarnedAboutNexus
global function TransportPortal_SetChannelUseTime
#endif

const float TRANSPORT_PORTAL_ROTATE_SPEED_SLOW = 360.0 * 0.1
const float TRANSPORT_PORTAL_ROTATE_SPEED_FAST = 360.0 * 1.75
const float TRANSPORT_PORTAL_ROTATE_SPEED_ENDING = 360.0 * 0.75
const int TRANSPORT_PORTAL_TRIGGER_RADIUS = 20

const vector CHASE_PORTAL_OFFSET = <0,0,50>

global const float TRANSPORT_PORTAL_TRANSLOCATOR_PORTAL_OFFSET = 90.0

const vector ALTER_PURPLE_COLOR = <147,112,219>

//Signals
#if SERVER
global const string TRANSPORT_PORTAL_EXTRA_WAIT_TIME_SIGNAL = "alter_ult_fx_extra_time"
const string TRANSPORT_PORTAL_LEAVE_WAYPOINT_TRIGGER_SIGNAL = "alter_ult_leave_wp_trigger"
#endif
#if CLIENT
const string TRANSPORT_PORTAL_HINT_THREAD = "alter_ult_hint_thread"
const string TRANSPORT_PORTAL_SPECTATOR_CHANGED = "alter_ult_spectator_changed"
const string TRANSPORT_PORTAL_PREVIEW_END = "alter_ult_preview_end"
const string TRANSPORT_PORTAL_LONG_HOLD_END = "alter_ult_long_hold_end"
#endif

//Script names
global const string TRANSPORT_PORTAL_ROOT_SCRIPTNAME = "alter_ult_root"
global const string TRANSPORT_PORTAL_RECEIVER_SCRIPTNAME = "alter_ult_receiver"
const string TRANSPORT_PORTAL_TRANSLOCATOR_SCRIPTNAME = "alter_ult_translocator"
global const string TRANSPORT_PORTAL_TRANSLOCATOR_TRACE_BLOCKER_SCRIPTNAME = "alter_ult_translocator_trace_blocker"
const string TRANSPORT_PORTAL_WARNING_TRIGGER_SCRIPTNAME = "alter_ult_warning_trigger"
global const string TRANSPORT_PORTAL_ALLY_PORTAL_SCRIPTNAME = "alter_ult_ally_portal"
global const string TRANSPORT_PORTAL_ALLY_PORTAL_TRACE_BLOCKER_SCRIPTNAME = "alter_ult_ally_trace_blocker"
global const string TRANSPORT_PORTAL_WEAPON_NAME = "mp_ability_transport_portal"

//RPCs
const string TRANSPORT_PORTAL_SERVER_TO_CLIENT_ULT_DURATION_CHANGED = "ServerToClient_TransportPortal_UltDurationChanged"

const string TRANSPORT_PORTAL_CLIENT_TO_SERVER_RECALL_ULT = "ClientToServer_TransportPortal_RecallUlt"

//Netvars
const string TRANSPORT_PORTAL_EXPIRE_TIME_NETVAR = "TransportPortal_ExpireTime"

//Anims

//Models
const asset PORTAL_RECIEVER_MODEL = $"mdl/props/alter_teleporter/alter_teleporter.rmdl"
const asset PORTAL_TRANSLOCATOR_MODEL = $"mdl/props/alter_teleporter/alter_teleporter_portal.rmdl"

//FX
const asset TRANSPORT_PORTAL_AR_EDGE_FX = $"P_alter_ulti_ar_edge"
const asset TRANSPORT_PORTAL_ENTER_EXIT_FX = $"P_alter_ulti_portal_announce"
const asset TRANSPORT_PORTAL_ONEWAY_START = $"P_alter_ulti_portal_in"
const asset TRANSPORT_PORTAL_WARNING_FRIENDLY = $"P_alter_ulti_portal_warning_friendly"
const asset TRANSPORT_PORTAL_WARNING_ENEMY = $"P_alter_ulti_portal_warning_enemy"
const asset TRANSPORT_PORTAL_RECIEVER_IDLE = $"P_alter_ulti_prop_idle"
const asset TRANSPORT_PORTAL_RECIEVER_ACTIVE = $"P_alter_ulti_prop_activate"
const asset TRANSPORT_PORTAL_TRANSLOCATOR_IDLE = $"P_alter_ulti_prop_idle_top"
const asset TRANSPORT_PORTAL_TRANSLOCATOR_ACTIVE = $"P_alter_ulti_prop_activate_top"
const asset TRANSPORT_PORTAL_CHASE_INACTIVE = $"P_alter_ulti_portal_inactive"
const asset TRANSPORT_PORTAL_CHASE_ACTIVE = $"P_alter_ulti_portal_init"
const asset TRANSPORT_PORTAL_DESTROYED = $"P_alter_ulti_portal_prop_exp"

//Sounds
const string TRANSPORT_PORTAL_PLACED_SOUND = "Alter_Ult_Base_Activate_3p"
const string TRANSPORT_PORTAL_END_SOUND = "Alter_Ult_Base_Bottom_Dissolve_3p"
const string TRANSPORT_PORTAL_CLOSE_SOUND = "Alter_Ult_Base_Expire_3p"
const string TRANSPORT_PORTAL_CHASE_PORTAL_WARMUP_SOUND = "Alter_Ult_ChasePortal_Channeling_3p"
const string TRANSPORT_PORTAL_CHASE_PORTAL_ACTIVE_SOUND = "Alter_Ult_ChasePortal_Active_3p"
const string TRANSPORT_PORTAL_CHASE_PORTAL_ENDING_SOUND = "Alter_Ult_ChasePortal_Ending_3p"
const string TRANSPORT_PORTAL_AMBIENT_IDLE_HUM_SOUND = "Alter_Ult_Base_Idle_Inactive_3p"
const string TRANSPORT_PORTAL_AMBIENT_ACTIVE_HUM_SOUND = "Alter_Ult_Base_Idle_Active_3p"
const string TRANSPORT_PORTAL_DESTROYED_SOUND = "Alter_Ult_Base_Destroyed_3p"
const string TRANSPORT_PORTAL_ARRIVAL_WARNING_SOUND_FRIENDLY_3P = "Alter_Ult_Base_Alert_ArrivalWarning_Friendly_3p"
const string TRANSPORT_PORTAL_ARRIVAL_WARNING_SOUND_ENEMY_3P = "Alter_Ult_Base_Alert_ArrivalWarning_Enemy_3p"

//UI stuff
global const asset TRANSPORT_PORTAL_IN_WORLD_HUD_OBJECT = $"ui/in_world_alter_recall_icon.rpak"
const asset TRANSPORT_PORTAL_RECEIVER_IMAGE = $"rui/hud/ultimate_icons/ultimate_alter"
const asset TRANSPORT_PORTAL_PORTAL_ICON = $"rui/hud/ping/icon_ping_phase_tunnel"

const bool TRANSPORT_PORTAL_DATAPAD_DEBUG = true
#if DEVELOPER
global const bool TRANSPORT_PORTAL_NAVMESH_PATH_DEBUG = false
#endif

#if SERVER
struct UltData
{
	int             regroupPortalCount = 0
	entity          translocator
	entity          receiver
	array< entity > teammatesWhoHaveUsedReceiver
	array< entity > currentUsers
	array< entity > allyPortals
	array< entity > playersInTransit
}
#endif

struct AllyPortalData
{
#if SERVER
	PhaseTunnelPortalData& tunnelData

	entity fx
#endif
}

global enum eTransportPortalDestructionReason
{
	NONE,
	ENEMY,
	WORLDSPAWN,
	TIMEOUT,
	CANCELLED,

	_COUNT
}

struct{
	#if SERVER
		float portalSpeed = 1800.0
		float portalMinTravelTime = 0.8
		float portalMaxTravelTime = 10.0

		bool createDelayedAutoFollowPortal = true
		float chasePortalWarmupTime = 6.0
		float chasePortalOpenDuration = 10.0

		float chasePortalTimeoutWarningDuration = 5.0
		bool chasePortalRequiresFacing = true
		float chasePortalRentryDebounce = 2.0

		float receiverExpireVOWarningTime = 15.0

		bool createWaypointWhenInArea = true

		int ammoAddedOnRecal = 0//30
		int ammoAddedOnRecalWithCooldownUpgrade = 0//20

		float destroyedByMoverRefundWindow = 5

		bool createIncomingWarning = true
		float incomingWarningHeight = 10.0

		float tossTimeout = 10

		int receiverHealth = 140
	#endif

	float receiverLifespan = 120
	float receiverLifespanUpgradeAmount = 30
	bool receiverLastsForeverWithUpgrade = true

	float incomingWarningRadius = 15.0

	float maxUseDistance = 200

	float portalWarmupTime = 1.0

	float useTime = 0.3
}tuning

struct
{
	table<entity, AllyPortalData > allyPortalToDataMap
	#if SERVER
	table<entity, entity> alterToRootEntMap
	table<entity, UltData> rootEntToDataMap
	array<string> disallowedTriggerTypes
	entity pathfindingEnt
	#endif

	table< int, array<entity> > teamToReceiversMap

	#if CLIENT
	float useStartTime = -1
	array< entity > allReceivers
	array< entity > warningTriggers
	entity ultPendingRuiDurationUpdate = null

	float channelStartTime = -1
	float channelTime = 0
	float channelTimeElapsed = 0
	#endif
}file

void function MpAbilityTransportPortal_Init()
{
	SetupTuning()

	PrecacheScriptString( TRANSPORT_PORTAL_ROOT_SCRIPTNAME )
	PrecacheScriptString( TRANSPORT_PORTAL_RECEIVER_SCRIPTNAME )
	PrecacheScriptString( TRANSPORT_PORTAL_TRANSLOCATOR_SCRIPTNAME )
	PrecacheScriptString( TRANSPORT_PORTAL_TRANSLOCATOR_TRACE_BLOCKER_SCRIPTNAME )
	PrecacheScriptString( TRANSPORT_PORTAL_WARNING_TRIGGER_SCRIPTNAME )
	PrecacheScriptString( TRANSPORT_PORTAL_ALLY_PORTAL_SCRIPTNAME )
	PrecacheScriptString( TRANSPORT_PORTAL_ALLY_PORTAL_TRACE_BLOCKER_SCRIPTNAME )

	PrecacheModel( PORTAL_RECIEVER_MODEL )
	PrecacheModel( PORTAL_TRANSLOCATOR_MODEL )

	PrecacheParticleSystem( TRANSPORT_PORTAL_AR_EDGE_FX )
	PrecacheParticleSystem( TRANSPORT_PORTAL_ENTER_EXIT_FX )
	PrecacheParticleSystem( TRANSPORT_PORTAL_ONEWAY_START )
	PrecacheParticleSystem( TRANSPORT_PORTAL_WARNING_FRIENDLY )
	PrecacheParticleSystem( TRANSPORT_PORTAL_WARNING_ENEMY )
	PrecacheParticleSystem( TRANSPORT_PORTAL_RECIEVER_IDLE )
	PrecacheParticleSystem( TRANSPORT_PORTAL_RECIEVER_ACTIVE )
	PrecacheParticleSystem( TRANSPORT_PORTAL_TRANSLOCATOR_IDLE )
	PrecacheParticleSystem( TRANSPORT_PORTAL_TRANSLOCATOR_ACTIVE )
	PrecacheParticleSystem( TRANSPORT_PORTAL_CHASE_INACTIVE )
	PrecacheParticleSystem( TRANSPORT_PORTAL_CHASE_ACTIVE )
	PrecacheParticleSystem( TRANSPORT_PORTAL_DESTROYED )

	#if SERVER
	RegisterSignal( TRANSPORT_PORTAL_EXTRA_WAIT_TIME_SIGNAL )
	RegisterSignal( TRANSPORT_PORTAL_LEAVE_WAYPOINT_TRIGGER_SIGNAL )
	#endif
	#if CLIENT
	RegisterSignal( TRANSPORT_PORTAL_HINT_THREAD )
	RegisterSignal( TRANSPORT_PORTAL_SPECTATOR_CHANGED )
	RegisterSignal( TRANSPORT_PORTAL_PREVIEW_END )
	RegisterSignal( TRANSPORT_PORTAL_LONG_HOLD_END )
	#endif

	Remote_RegisterServerFunction( TRANSPORT_PORTAL_CLIENT_TO_SERVER_RECALL_ULT )
	Remote_RegisterClientFunction( TRANSPORT_PORTAL_SERVER_TO_CLIENT_ULT_DURATION_CHANGED, "entity" )

	AddGetExtendedRangeUseEntityCallback( GetExtendedRangeUseEntityCallbackForPlayer )

	RegisterNetworkedVariable( TRANSPORT_PORTAL_EXPIRE_TIME_NETVAR, SNDC_PLAYER_EXCLUSIVE, SNVT_TIME, 0.0 )

	#if SERVER
	RegisterDynamicEntCleanupItem_Parented_Scriptname( TRANSPORT_PORTAL_RECEIVER_SCRIPTNAME )
	RegisterDynamicEntCleanupItem_Area_Scriptname( TRANSPORT_PORTAL_RECEIVER_SCRIPTNAME )
	file.disallowedTriggerTypes = [
		"trigger_slip",
		"trigger_out_of_bounds",
		"trigger_networked_out_of_bounds"
	]

	if ( GetCurrentPlaylistVarBool( "alter_ult_disallowObjectPlacement", true ) )
	{
		file.disallowedTriggerTypes.extend( [
				"trigger_no_object_placement",
				"trigger_networked_no_op"
			] )
	}

	AddCallback_EntitiesDidLoad( TransportPortal_OnEntitiesDidLoad )
	#endif

	#if CLIENT
	AddCreateCallback( "prop_script", OnPropScriptCreated )
	AddCreateCallback( "trigger_cylinder_networked", OnPropScriptCreated )

	RegisterConCommandTriggeredCallback( "+scriptCommand5", TransportPortal_OnCharacterButtonPressed )

	AddCallback_OnBleedoutStarted( OnBleedoutStarted )
	AddCallback_OnYouRespawned( OnYouRespawned )
	AddOnSpectatorTargetChangedCallback( OnSpectatorTargetChanged )

	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.TRANSPORT_PORTAL_TRANSLOCATOR,
		MINIMAP_OBJECT_RUI, SetupMapRuiTranslocator, FULLMAP_OBJECT_RUI, SetupMapRuiTranslocator )

	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.TRANSPORT_PORTAL_RECEIVER,
		MINIMAP_OBJ_AREA_RUI, void function( entity ent, var rui ) {
			SetupMapRuiReceiver( ent, rui, false )
		},
		FULLMAP_OBJECTIVE_AREA_RUI, void function( entity ent, var rui ) {
			SetupMapRuiReceiver( ent, rui, true )
		}
	)

	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.TRANSPORT_PORTAL_RECEIVER_PREVIEW,
		MINIMAP_OBJ_AREA_RUI, void function( entity ent, var rui ) {
			SetupMapRuiReceiverPreview( ent, rui, false )
		},
		FULLMAP_OBJECTIVE_AREA_RUI, void function( entity ent, var rui ) {
			SetupMapRuiReceiverPreview( ent, rui, true )
		}
	)

	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.TRANSPORT_PORTAL_CHASE_PORTAL,
		MINIMAP_OBJECT_RUI, SetupMapRuiChasePortal, FULLMAP_OBJECT_RUI, SetupMapRuiChasePortal )

	#endif
}

void function SetupTuning()
{
	#if SERVER
		tuning.portalSpeed = 						GetCurrentPlaylistVarFloat	( "alter_ult_portalSpeed", tuning.portalSpeed )
		tuning.portalMinTravelTime = 				GetCurrentPlaylistVarFloat	( "alter_ult_minTravelTime", tuning.portalMinTravelTime )
		tuning.portalMaxTravelTime = 				GetCurrentPlaylistVarFloat	( "alter_ult_maxTravelTime", tuning.portalMaxTravelTime )
		tuning.chasePortalOpenDuration = 			GetCurrentPlaylistVarFloat	( "alter_ult_portalDuration", tuning.chasePortalOpenDuration )
		tuning.createDelayedAutoFollowPortal =		GetCurrentPlaylistVarBool	( "alter_ult_createDelayedAutoFollowPortal", tuning.createDelayedAutoFollowPortal )
		tuning.chasePortalWarmupTime = 				GetCurrentPlaylistVarFloat	( "alter_ult_allyPortalWarmupTime", tuning.chasePortalWarmupTime )
		tuning.chasePortalTimeoutWarningDuration = 	GetCurrentPlaylistVarFloat	( "alter_ult_portalTimeoutWarningDuration", tuning.chasePortalTimeoutWarningDuration )
		tuning.chasePortalRequiresFacing = 			GetCurrentPlaylistVarBool	( "alter_ult_chasePortalRequiresFacing", tuning.chasePortalRequiresFacing )
		tuning.chasePortalRentryDebounce = 			GetCurrentPlaylistVarFloat	( "alter_ult_chasePortalRentryDebounce", tuning.chasePortalRentryDebounce )

		tuning.receiverExpireVOWarningTime =		GetCurrentPlaylistVarFloat	( "alter_ult_receiverExpireVOWarningTime", tuning.receiverExpireVOWarningTime )
		tuning.ammoAddedOnRecal =					GetCurrentPlaylistVarInt	( "alter_ult_ammoAddedOnRecal", tuning.ammoAddedOnRecal )
		tuning.ammoAddedOnRecalWithCooldownUpgrade =		GetCurrentPlaylistVarInt	( "alter_ult_ammoAddedOnRecalWithUpgrade", tuning.ammoAddedOnRecalWithCooldownUpgrade )
		tuning.destroyedByMoverRefundWindow =		GetCurrentPlaylistVarFloat	( "alter_ult_destroyedByMoverRefundWindow", tuning.destroyedByMoverRefundWindow )
		tuning.createIncomingWarning = 				GetCurrentPlaylistVarBool	( "alter_ult_createIncomingWarning", tuning.createIncomingWarning )
		tuning.incomingWarningHeight =				GetCurrentPlaylistVarFloat	( "alter_ult_incomingWarningHeight", tuning.incomingWarningHeight ) * METERS_TO_INCHES
		tuning.tossTimeout =						GetCurrentPlaylistVarFloat	( "alter_ult_tossTimeout", tuning.tossTimeout )
		tuning.receiverHealth = 					GetCurrentPlaylistVarInt	( "alter_ult_receiverHealth", tuning.receiverHealth )
	#endif
	tuning.receiverLifespan = 					GetCurrentPlaylistVarFloat	( "alter_ult_receiverLifespan", tuning.receiverLifespan )
	tuning.receiverLifespanUpgradeAmount = 		GetCurrentPlaylistVarFloat	( "alter_ult_receiverLifespanUpgradeAmount", tuning.receiverLifespanUpgradeAmount )
	tuning.receiverLastsForeverWithUpgrade = 	GetCurrentPlaylistVarBool	( "alter_ult_receiverLastsForeverWithUpgrade", tuning.receiverLastsForeverWithUpgrade )

	tuning.incomingWarningRadius =				GetCurrentPlaylistVarFloat	( "alter_ult_incomingWarningRadius", tuning.incomingWarningRadius ) * METERS_TO_INCHES

	tuning.maxUseDistance = 					GetCurrentPlaylistVarFloat	( "alter_ult_maxUseDist", tuning.maxUseDistance ) * METERS_TO_INCHES

	tuning.portalWarmupTime = 					GetCurrentPlaylistVarFloat	( "alter_ult_portalWarmupTime", tuning.portalWarmupTime )

	tuning.useTime = 							GetCurrentPlaylistVarFloat	( "alter_ult_useTime", tuning.useTime )
}

#if SERVER
UltData function GetAlterRootEntData( entity rootEnt )
{
	if ( rootEnt in file.rootEntToDataMap )
		return file.rootEntToDataMap[rootEnt]
	else
		Warning( "RootEnt " + rootEnt + " not in datamap" )

	UltData noData
	return noData
}
#endif


#if SERVER
void function TransportPortal_OnEntitiesDidLoad()
{
	file.pathfindingEnt = CreateEntity( "info_target" )
	DispatchSpawn( file.pathfindingEnt )
	//RegisterNavMesh_EntityMemoryWithSettings( file.pathfindingEnt, HULL_HUMAN, 12 * METERS_TO_INCHES, 3 * METERS_TO_INCHES, MAX_WORLD_COORD, 1 * METERS_TO_INCHES, true, true, true, true )

	thread UnregisterNavmeshEnt_Thread()
}
void function UnregisterNavmeshEnt_Thread( )
{
	EndSignal( file.pathfindingEnt, "OnDestroy" )

	OnThreadEnd(
		function() : (  )
		{
			DeregisterNavMesh_EntityMemory( file.pathfindingEnt )
		}
	)

	WaitForever()
}
#endif

entity function GetTransportPortalWeaponFromOwner( entity owner )
{
	entity ultWeapon = owner.GetOffhandWeapon( OFFHAND_ULTIMATE )
	if ( IsValid( ultWeapon ) && ultWeapon.GetWeaponBaseClassName() == TRANSPORT_PORTAL_WEAPON_NAME )
	{
		return ultWeapon
	}
	return null
}

void function OnWeaponActivate_ability_transport_portal( entity weapon )
{
}


void function OnWeaponDeactivate_ability_transport_portal( entity weapon )
{
#if CLIENT
	weapon.Signal( TRANSPORT_PORTAL_PREVIEW_END )
#endif
}

void function OnWeaponTossPrep_ability_transport_portal( entity weapon, WeaponTossPrepParams prepParams )
{
#if CLIENT
	thread PreviewMinimapLocation_Thread( weapon )
#endif
}

#if CLIENT
void function PreviewMinimapLocation_Thread( entity weapon )
{
	EndSignal( weapon, TRANSPORT_PORTAL_PREVIEW_END, "OnDestroy" )

	wait 0.2

	entity proxy = CreateClientSidePropDynamic( <0, 0, 0>, <0, 90, 0>, $"mdl/dev/empty_model.rmdl" )
	EndSignal( proxy, "OnDestroy" )

	proxy.e.clientEntMinimapClassName = "prop_script"
	proxy.e.clientEntMinimapCustomState = eMinimapObject_prop_script.TRANSPORT_PORTAL_RECEIVER_PREVIEW
	proxy.e.clientEntMinimapFlags = MINIMAP_FLAG_VISIBILITY_SHOW
	proxy.e.clientEntMinimapScale = tuning.maxUseDistance / 16384.0
	proxy.e.clientEntMinimapZOrder = MINIMAP_Z_OBJECT
	thread MinimapObjectThread( proxy )

	int fxId = GetParticleSystemIndex( TRANSPORT_PORTAL_AR_EDGE_FX )
	int pulseVFX  = StartParticleEffectOnEntity( proxy, fxId, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	EffectSetControlPointVector( pulseVFX, 1, <tuning.maxUseDistance, 0, 0> )

	var overlayRui = CreateCockpitPostFXRui( $"ui/ult_deployment.rpak", HUD_Z_BASE )
	RuiSetVisible( overlayRui, true )

	OnThreadEnd(
		function() : ( proxy, overlayRui )
		{
			if ( IsValid( proxy ) )
				proxy.Destroy()

			RuiDestroyIfAlive( overlayRui )
		}
	)

	while( true )
	{
		vector dropPosition = weapon.GetMostRecentGrenadeImpactPos()
		proxy.SetOrigin( dropPosition )
		WaitFrame()
	}
}
#endif

var function OnWeaponTossReleaseAnimEvent_ability_transport_portal( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetWeaponOwner()

	#if CLIENT
		weapon.Signal( TRANSPORT_PORTAL_PREVIEW_END )
	#endif

	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )

	entity deployable = ThrowDeployable( weapon, attackParams, 1.0, OnTransportPortalPlanted, null, <0, 0, 200> )
	if ( deployable )
	{
		PlayerUsedOffhand( player, weapon, true, deployable )

		#if SERVER
			deployable.e.isDoorBlocker = true
			deployable.proj.refundAmount = weapon.GetAmmoPerShot()

			string projectileSound = GetGrenadeProjectileSound( weapon )
			if ( projectileSound != "" )
				EmitSoundOnEntity( deployable, projectileSound )

			weapon.w.lastProjectileFired = deployable

			TryPlayWeaponBattleChatterLine( player, weapon )
		#endif //SERVER
	}

	return weapon.GetAmmoPerShot()
}

#if CLIENT
void function OnPropScriptCreated( entity ent )
{
	entity player = GetLocalViewPlayer()
	if ( ent.GetScriptName() == TRANSPORT_PORTAL_RECEIVER_SCRIPTNAME )
	{
		file.allReceivers.append( ent )
		if ( ent.GetTeam() == player.GetTeam() )
		{
			thread ManageReceiverLifetime_Thread( ent )
			SetCallback_CanUseEntityCallback( ent, Receiver_CanUseCallback )
			SetCallback_ShouldUseBlockReloadCallback( ent, SimpleShouldNotBlockReloadCallback )
			AddEntityCallback_GetUseEntOverrideText( ent, Receiver_TextOverride )

			AddCallback_OnUseEntity_ClientServer( ent, OnUse_Receiver )

			entity rootEnt = ent.GetOwner()

		}
	}
	else if ( ent.GetScriptName() == TRANSPORT_PORTAL_ALLY_PORTAL_SCRIPTNAME )
	{
		thread ChasePortalLifetime_Client_Thread( ent )
	}
	else if ( ent.GetScriptName() == TRANSPORT_PORTAL_WARNING_TRIGGER_SCRIPTNAME )
	{
		file.warningTriggers.append( ent )
		thread CleanupWarningTriggerOnDestroy_Thread( ent )
	}
}
#endif

#if SERVER
void function ClientToServer_TransportPortal_RecallUlt( entity player )
{
	if ( !(player in file.alterToRootEntMap) )
		return

	entity rootEnt = file.alterToRootEntMap[player]

	if ( !IsValid( rootEnt ) )
		return

	if ( !(rootEnt in file.rootEntToDataMap) )
		return

	entity receiver = file.rootEntToDataMap[rootEnt].receiver
	if ( !IsValid( receiver ) )
		return

	bool anyoneUsedUlt = (file.rootEntToDataMap[rootEnt].teammatesWhoHaveUsedReceiver.len() != 0)

	PlayBattleChatterLineToSpeakerAndTeam( player, "bc_portalGeneratorPack" )

	PIN_PlayerItemDestruction( player, ITEM_DESTRUCTION_TYPES.TRANSPORTATION_PORTAL, { reason = eTransportPortalDestructionReason.CANCELLED } )

	DissolveReceiver( receiver, rootEnt )

	if ( !anyoneUsedUlt )
	{
		entity ultWeapon = GetTransportPortalWeaponFromOwner( player )

		if ( IsValid( ultWeapon ) )
		{
			int ammoToAdd = tuning.ammoAddedOnRecal
			if ( ultWeapon.HasMod( "upgrade_core_ult_cooldown_reduction" ) )
			{
				ammoToAdd = tuning.ammoAddedOnRecalWithCooldownUpgrade
			}

			if ( ammoToAdd > 0 )
			{
				int oldAmmo = ultWeapon.GetWeaponPrimaryClipCount()
				int ammoMax = ultWeapon.GetWeaponPrimaryClipCountMax()
				int newAmmo = minint( oldAmmo + ammoToAdd, ammoMax )

				ultWeapon.SetWeaponPrimaryClipCountNoRegenReset( newAmmo )
			}
		}
	}
}
#endif

#if CLIENT
void function TransportPortal_OnCharacterButtonPressed( entity player )
{
	Remote_ServerCallFunction( TRANSPORT_PORTAL_CLIENT_TO_SERVER_RECALL_ULT )
}
#endif

#if SERVER
void function TimeoutPlacementThread( entity projectile, entity owner )
{
	EndSignal( projectile, "OnDestroy" )
	EndSignal( owner, "OnDeath", "OnDestroy" )

	wait tuning.tossTimeout

	entity weapon = projectile.GetWeaponSource()
	if ( IsValid( weapon ) )
	{
		int ammo = weapon.GetWeaponPrimaryClipCount()
		weapon.SetWeaponPrimaryClipCount( minint( ammo + projectile.proj.refundAmount, weapon.GetWeaponPrimaryClipCountMax() ) )
		weapon.SetNextAttackAllowedTime( Time() )
	}

	EmitSoundOnEntityOnlyToPlayer( owner, owner, "survival_ui_ability_notready" )

	projectile.Destroy()
}
#endif

#if SERVER
bool function IsPlacementPositionValid( vector position, entity player, entity projectile )
{
	// Make sure we can't fall to our deaths
	TraceResults tr = TraceLine( position, position+<0, 0, -1000>, [projectile],TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
	if ( tr.fraction == 1.0 )
	{
		return false
	}
	return true
}
#endif

void function OnTransportPortalPlanted( entity projectile, DeployableCollisionParams collisionParams )
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

		if ( !IsPlacementPositionValid( origin, owner, projectile ) )
		{
			entity weapon = projectile.GetWeaponSource()
			if ( IsValid( weapon ) )
			{
				int ammo = weapon.GetWeaponPrimaryClipCount()
				weapon.SetWeaponPrimaryClipCount( minint( ammo + projectile.proj.refundAmount, weapon.GetWeaponPrimaryClipCountMax() ) )
				weapon.SetNextAttackAllowedTime( Time() )
			}

			EmitSoundOnEntityOnlyToPlayer( owner, owner, "survival_ui_ability_notready" )

			projectile.Destroy()
			return
		}

		vector endOrigin = origin - <0,0,32>
		vector surfaceAngles = projectile.proj.savedAngles

		TraceResults traceResult = TraceLine( origin, endOrigin, [ projectile ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS_AND_PHYSICS )

		entity oldParent = projectile.GetParent()
		projectile.ClearParent()

		TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_ALTER_ULTIMATE_PLACED, owner, origin, owner.GetTeam(), owner )

		projectile.Destroy()

		entity parentEnt = null
		if ( IsValid( traceResult.hitEnt ) && EntityShouldStick( projectile, traceResult.hitEnt ) && !traceResult.hitEnt.IsWorld() )
		{
			parentEnt = traceResult.hitEnt
		}
		else if ( IsValid( oldParent ) )
		{
			parentEnt = oldParent
		}

		TransportPortal_Deploy( owner, origin, surfaceAngles, parentEnt )
	#endif //SERVER
}

#if INTELLIJ_OUTLINE_SECTION_MARKER
void function _____________CreateTransportPortal___________________________(){}
#endif
#if SERVER
void function TransportPortal_Deploy( entity owner, vector origin, vector angles, entity parentTo )
{
	int team = owner.GetTeam()

	entity rootEnt = CreateEntity( "prop_material_harvester" )
	rootEnt.SetValueForModelKey( $"mdl/dev/empty_model.rmdl" )
	rootEnt.SetOrigin( origin )
	rootEnt.SetAngles( angles )
	rootEnt.SetOwner( owner )
	if ( IsValid( parentTo ) )
	{
		rootEnt.SetParent( parentTo )
	}
	SetTeam( rootEnt, team )
	rootEnt.SetScriptName( TRANSPORT_PORTAL_ROOT_SCRIPTNAME )
	DispatchSpawn( rootEnt )

	AddToUltimateRealm( owner, rootEnt )
	thread TrapDestroyOnRoundEnd( owner, rootEnt )

	if ( owner in file.alterToRootEntMap )
	{
		entity oldRootEnt = file.alterToRootEntMap[owner]

		if ( oldRootEnt in file.rootEntToDataMap )
		{
			entity oldReceiver = file.rootEntToDataMap[oldRootEnt].receiver
			if ( IsValid( oldReceiver ) )
			{
				DissolveReceiver( oldReceiver, oldRootEnt )
			}
		}
	}

	file.alterToRootEntMap[owner] <- rootEnt

	UltData data
	file.rootEntToDataMap[rootEnt] <- data

	entity receiver = CreatePropScript( PORTAL_RECIEVER_MODEL, origin, angles, SOLID_VPHYSICS )
	receiver.SetScriptName( TRANSPORT_PORTAL_RECEIVER_SCRIPTNAME )
	data.receiver = receiver

	receiver.SetDamageNotifications( false )
	receiver.SetDeathNotifications( false )
	receiver.SetTakeDamageType( DAMAGE_YES )

	receiver.e.noOwnerFriendlyFire      = true
	receiver.e.noFriendlyFireProtection = false
	receiver.e.canBeDamagedFromGas      = false
	receiver.e.canBurn                  = true
	receiver.e.blocksThermite           = false
	receiver.e.preventStickyEnts        = true

	receiver.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS

	receiver.SetMaxHealth( tuning.receiverHealth )
	receiver.SetHealth( tuning.receiverHealth )

	SetTeam( receiver, team )
	receiver.SetOwner( rootEnt )
	receiver.SetBossPlayer( owner )
	receiver.SetParent( rootEnt )
	receiver.SetTouchTriggers( true ) //Make it destroyable by triggers e.g. Leviathan stomp
	receiver.SetIgnorePredictedTriggerTypes( TT_JUMP_PAD | TT_GRAVITY_LIFT | TT_BLACKHOLE  )
	//receiver.SetPhysics( MOVETYPE_FLY ) // doesn't actually make it move, but allows pushers to interact with it
	//receiver.DisallowObjectPlacement() //Don't allow Rampart turrets or anything else to be placed on this.
	receiver.e.preventStickyEnts = true
	//receiver.SetNeverCrush( true ) //We don't want to have this ever crush another entity.
	//receiver.SetDoOnBeingCrushedEntityCallback( true )

	SetCallback_CanUseEntityCallback( receiver, Receiver_CanUseCallback )

	receiver.SetUsable()
	receiver.SetUsableByGroup( "pilot" )
	receiver.AddUsableValue( USABLE_BY_TEAMMATES | USABLE_CUSTOM_HINTS | USABLE_FROM_EXTENDED_RANGE )
	receiver.SetUsablePriority( USABLE_PRIORITY_LOW )
	receiver.SetUsableDistanceOverride( tuning.maxUseDistance )
	AddCallback_OnUseEntity_ClientServer( receiver, OnUse_Receiver )

	AddEntityCallback_OnPostDamaged( receiver, Receiver_OnPostDamaged )

	AddToUltimateRealm( owner, receiver )
	owner.LinkToEnt( receiver )
	AddSonarDetectionForPropScript( receiver )
	Highlight_SetOwnedHighlight( receiver, "sp_friendly_hero" )
	Highlight_SetFriendlyHighlight( receiver, "sp_friendly_hero" )

	thread ManageReceiverLifetime_Thread( receiver )

	receiver.Minimap_SetCustomState( eMinimapObject_prop_script.TRANSPORT_PORTAL_RECEIVER )
	foreach ( entity player in GetPlayerArray() )
	{
		receiver.Minimap_Hide( player.GetTeam(), null )
	}
	receiver.Minimap_AlwaysShow( owner.GetTeam(), null )
	// If we are in a mode where we allow communication between players near each other that are on the same team (but not the same squad); show the icon to nearby teammates
	//AllianceProximity_SetMinimapAlwaysShow_ForAlliance( team, receiver, receiver.GetOwner() )

	AddEMPDamageDevice( receiver )
	AddWreckingBallEMPDamageDevice( receiver )

	thread PropCheckDamageFromDeathfield( receiver, 1 )

	entity translocatorMover = CreateScriptMover( TRANSPORT_PORTAL_TRANSLOCATOR_SCRIPTNAME, origin, <0,0,0> )
	translocatorMover.SetParent( rootEnt )

	entity translocator = CreatePropScript( PORTAL_TRANSLOCATOR_MODEL, origin, <0,0,90> )
	translocator.SetScriptName( TRANSPORT_PORTAL_TRANSLOCATOR_SCRIPTNAME )
	translocator.SetParent( translocatorMover )
	translocator.Highlight_Enable()
	translocator.SetOwner( owner )
	SetTeam( translocator, team )
	data.translocator = translocator

	AddToUltimateRealm( owner, translocator )
	AddSonarDetectionForPropScript( translocator )
	Highlight_SetOwnedHighlight( translocator, "sp_friendly_hero" )
	Highlight_SetFriendlyHighlight( translocator, "sp_friendly_hero" )

	vector moveOffset = ( receiver.GetUpVector() * TRANSPORT_PORTAL_TRANSLOCATOR_PORTAL_OFFSET )
	vector moveDest = translocatorMover.GetOrigin() + moveOffset
	translocatorMover.NonPhysicsMoveTo( moveDest, tuning.portalWarmupTime, tuning.portalWarmupTime * 0.15, 0.1 )

	entity traceBlocker = CreateTraceBlockerVolume( moveDest, 30, false, CONTENTS_BLOCK_PING | CONTENTS_NOGRAPPLE, translocator.GetTeam(), TRANSPORT_PORTAL_TRANSLOCATOR_TRACE_BLOCKER_SCRIPTNAME, translocator )
	traceBlocker.SetParent( rootEnt )
	//DebugDrawSphere( moveDest, 30, int(COLOR_BLUE.x), int(COLOR_BLUE.y), int(COLOR_BLUE.z), false, 10 )

	entity minimapEnt = CreatePropScript( $"mdl/dev/empty_model.rmdl", origin, <0,0,0>, SOLID_NONE )
	//SetTargetName( vars.minimapEnt, "SpectreDrop" )
	minimapEnt.Minimap_SetCustomState( eMinimapObject_prop_script.TRANSPORT_PORTAL_TRANSLOCATOR )
	minimapEnt.Minimap_SetAlignUpright( true )
	minimapEnt.Minimap_SetClampToEdge( false )
	minimapEnt.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
	minimapEnt.DisableHibernation()
	minimapEnt.SetOwner( owner )
	SetTeam( minimapEnt, team )
	minimapEnt.SetParent( rootEnt )

	foreach ( entity player in GetPlayerArray() )
	{
		minimapEnt.Minimap_Hide( team, null )
	}
	minimapEnt.Minimap_AlwaysShow( team, null )

	EmitSoundOnEntity( receiver, TRANSPORT_PORTAL_PLACED_SOUND )
	thread ManageRootEntLifetime_Thread( translocator, receiver, rootEnt )

	thread MaintainPortalFX_Thread( translocator, rootEnt )

	translocatorMover.NonPhysicsRotate( translocatorMover.GetUpVector(), TRANSPORT_PORTAL_ROTATE_SPEED_SLOW )
}
#endif

#if SERVER
void function MaintainPortalFX_Thread( entity translocator, entity rootEnt )
{
	EndSignal( translocator, "OnDestroy" )

	entity translocatorMover = translocator.GetParent()
	Assert( IsValid( translocatorMover ) )
	vector rotationAxis = translocatorMover.GetUpVector()

	bool portalWasActive      = false
	bool portalShouldBeActive = false
	PassByReferenceEntity translocatorFX
	UltData data              = file.rootEntToDataMap[rootEnt]

	EmitSoundOnEntity( translocator, TRANSPORT_PORTAL_AMBIENT_IDLE_HUM_SOUND )

	translocatorFX.value = StartParticleEffectOnEntityWithPos_ReturnEntity( translocator, GetParticleSystemIndex( TRANSPORT_PORTAL_TRANSLOCATOR_IDLE ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0> )

	OnThreadEnd(
		function() : ( translocatorFX )
		{
			if ( IsValid( translocatorFX.value ) )
			{
				EffectStop( translocatorFX.value )
			}
		}
	)

	while( true )
	{
		WaitFrame()

		if ( !(rootEnt in file.rootEntToDataMap) )
			break

		if ( data.regroupPortalCount == 0 )
		{
			portalShouldBeActive = false
		}
		else
		{
			portalShouldBeActive = true
		}

		if ( portalShouldBeActive && !portalWasActive )
		{
			StopSoundOnEntity( translocator, TRANSPORT_PORTAL_AMBIENT_IDLE_HUM_SOUND )
			EmitSoundOnEntity( translocator, TRANSPORT_PORTAL_AMBIENT_ACTIVE_HUM_SOUND )

			EffectStop( translocatorFX.value )
			translocatorFX.value = StartParticleEffectOnEntityWithPos_ReturnEntity( translocator, GetParticleSystemIndex( TRANSPORT_PORTAL_TRANSLOCATOR_ACTIVE ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0> )

			translocatorMover.NonPhysicsRotate( rotationAxis, TRANSPORT_PORTAL_ROTATE_SPEED_FAST )
		}
		else if ( !portalShouldBeActive && portalWasActive )
		{
			translocatorMover.NonPhysicsRotate( rotationAxis, TRANSPORT_PORTAL_ROTATE_SPEED_SLOW )
			StopSoundOnEntity( translocator, TRANSPORT_PORTAL_AMBIENT_ACTIVE_HUM_SOUND )
			EmitSoundOnEntity( translocator, TRANSPORT_PORTAL_AMBIENT_IDLE_HUM_SOUND )

			EffectStop( translocatorFX.value )
			translocatorFX.value = StartParticleEffectOnEntityWithPos_ReturnEntity( translocator, GetParticleSystemIndex( TRANSPORT_PORTAL_TRANSLOCATOR_IDLE ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0> )
		}

		portalWasActive = portalShouldBeActive
	}

}
#endif

#if SERVER
void function ManageRootEntLifetime_Thread( entity translocator, entity receiver, entity rootEnt )
{
	EndSignal( rootEnt, "OnDestroy" )

	OnThreadEnd(
		function() : ( translocator, receiver, rootEnt )
		{
			if ( rootEnt in file.rootEntToDataMap )
			{
				delete file.rootEntToDataMap[rootEnt]
			}
			else
			{
				Assert( false, "Root ent has already been deleted from table!" )
			}

			if ( IsValid( translocator ) )
			{
				//UnparentAndReparentIfNeeded( translocator, rootEnt )
				EmitSoundAtPosition( TEAM_UNASSIGNED, translocator.GetCenter(), TRANSPORT_PORTAL_CLOSE_SOUND, translocator)
				translocator.Dissolve( ENTITY_DISSOLVE_NONE, ZERO_VECTOR, 500 )
				StopSoundOnEntity( translocator, TRANSPORT_PORTAL_AMBIENT_ACTIVE_HUM_SOUND )
			}

			if ( IsValid( receiver ) && !receiver.IsDissolving() )
			{
				DissolveReceiver( receiver, rootEnt )
			}

			if ( IsValid( rootEnt ) )
			{
				rootEnt.Destroy()
			}
		}
	)

	while( true )
	{
		WaitFrame()

		if ( IsValid( receiver ) && !receiver.IsDissolving() )
			continue

		if ( file.rootEntToDataMap[rootEnt].currentUsers.len() > 0 )
			continue

		if ( file.rootEntToDataMap[rootEnt].playersInTransit.len() > 0 )
			continue

		if ( file.rootEntToDataMap[rootEnt].regroupPortalCount == 0 )
			break
	}
}
#endif

#if INTELLIJ_OUTLINE_SECTION_MARKER
void function _____________ReceiverLifetime___________________________(){}
#endif
void function ManageReceiverLifetime_Thread( entity receiver )
{
	Assert ( IsNewThread(), "Must be started as new thread" )

	int team = receiver.GetTeam()

	if ( !(team in file.teamToReceiversMap) )
	{
		file.teamToReceiversMap[team] <- []
	}
	file.teamToReceiversMap[team].append( receiver )

	#if SERVER
		entity owner = receiver.GetBossPlayer()
		EndThreadOn_PlayerChangedClass( owner )
		owner.EndSignal( "SquadEliminated" )

		thread ManageReceiverAnimations_Thread( receiver )
		thread MonitorForReceiverParentMoving_Thread( receiver )
	#endif

	receiver.EndSignal( "OnDestroy", "OnBeginDissolve" )

	OnThreadEnd(
		function() : ( receiver, team )
		{
			#if SERVER
				if ( IsValid( receiver ) || IsInvalidButMemberVarsStillValid( receiver ) )
				{
					EmitSoundAtPosition( TEAM_UNASSIGNED, receiver.GetCenter(), TRANSPORT_PORTAL_END_SOUND, receiver )

					entity rootEnt = receiver.GetOwner()
					if ( IsValid( rootEnt ) && IsValid( receiver ) )
					{
						DissolveReceiver( receiver, rootEnt )
					}
				}
			#endif

			file.teamToReceiversMap[team].fastremovebyvalue( receiver )
			if ( file.teamToReceiversMap[team].len() == 0 )
			{
				delete file.teamToReceiversMap[team]
			}
		}
	)

	#if SERVER
		float endTime = Time() + tuning.receiverLifespan
		bool durationIsUpgraded = false
		if ( PlayerHasPassive( owner, ePassives.PAS_ALTER_UPGRADE_ULT_DURATION ) )
		{
			durationIsUpgraded = true
			if ( tuning.receiverLastsForeverWithUpgrade )
			{
				endTime = 0
			}
			else
			{
				endTime += tuning.receiverLifespanUpgradeAmount
			}
		}

		foreach ( entity teammate in GetPlayerArrayOfTeam( team ) )
		{
			if ( IsValid( teammate ) )
			{
				teammate.SetPlayerNetTime( TRANSPORT_PORTAL_EXPIRE_TIME_NETVAR, endTime )
			}
		}

		bool playedWarning = false
		while ( Time() < endTime )
		{
			if ( !durationIsUpgraded && PlayerHasPassive( owner, ePassives.PAS_ALTER_UPGRADE_ULT_DURATION ) )
			{
				durationIsUpgraded = true
				if ( tuning.receiverLastsForeverWithUpgrade )
				{
					playedWarning = true
					endTime = 0
				}
				else
				{
					playedWarning = false
					endTime += tuning.receiverLifespanUpgradeAmount
				}

				foreach ( entity teammate in GetPlayerArrayOfTeam( team ) )
				{
					if ( IsValid( teammate ) )
					{
						teammate.SetPlayerNetTime( TRANSPORT_PORTAL_EXPIRE_TIME_NETVAR, endTime )
						Remote_CallFunction_Replay( teammate, TRANSPORT_PORTAL_SERVER_TO_CLIENT_ULT_DURATION_CHANGED, receiver )
					}
				}
			}

			if ( !playedWarning && Time() > (endTime - tuning.receiverExpireVOWarningTime) )
			{
				playedWarning = true
				PlayBattleChatterLineToSpeakerAndTeam( owner, "bc_portalGeneratorExpire" )
			}

			WaitFrame()
		}

		if ( durationIsUpgraded && tuning.receiverLastsForeverWithUpgrade )
		{
			WaitForever()
		}

		if( IsValid( owner ) )
		{
			PIN_PlayerItemDestruction( owner, ITEM_DESTRUCTION_TYPES.TRANSPORTATION_PORTAL, { reason = eTransportPortalDestructionReason.TIMEOUT } )
		}


	#else
		WaitForever()
	#endif
}

#if SERVER
void function MonitorForReceiverParentMoving_Thread( entity receiver )
{
	EndSignal( receiver, "OnDestroy", "OnBeginDissolve" )

	vector initialPos = receiver.GetOrigin()
	const float maxDistSqr = 10.0 * 10.0

	float startTime = Time()

	while( true )
	{
		WaitFrame()

		if ( DistanceSqr(receiver.GetOrigin(), initialPos) > maxDistSqr )
		{
			#if DEVELOPER
			printf("Destroying Receiver due to entity moving")
			#endif
			break
		}
	}

	if ( (Time() - startTime) < tuning.destroyedByMoverRefundWindow )
	{
		entity player = receiver.GetBossPlayer()
		if ( IsValid( player ) )
		{
			entity weapon = GetTransportPortalWeaponFromOwner( player )
			if ( IsValid( weapon ) )
			{
				weapon.SetWeaponPrimaryClipCountNoRegenReset( weapon.GetWeaponPrimaryClipCountMax() )
			}
		}

	}

	entity rootEnt = receiver.GetOwner()
	if ( IsValid( rootEnt ) )
	{
		DissolveReceiver( receiver, rootEnt )
	}
	else
	{
		receiver.Destroy()
	}
}
#endif

#if SERVER
void function ManageReceiverAnimations_Thread( entity receiver )
{
	receiver.EndSignal( "OnDestroy", "OnBeginDissolve" )

	receiver.Anim_PlayOnly( "prop_alter_teleporter_deploy" )
	receiver.Anim_DisableUpdatePosition()
	WaittillAnimDone( receiver )

	entity rootEnt = receiver.GetOwner()
	UltData data
	if ( IsValid( rootEnt ) && ( rootEnt in file.rootEntToDataMap ) )
	{
		data = file.rootEntToDataMap[rootEnt]
	}
	else
	{
		Assert( false, "Root Ent is invalid while receiver is still kicking??" )
		return
	}

	receiver.Anim_PlayOnly( "prop_alter_teleporter_idle" )

	PassByReferenceEntity receiverFX
	receiverFX.value = StartParticleEffectOnEntityWithPos_ReturnEntity( receiver, GetParticleSystemIndex( TRANSPORT_PORTAL_RECIEVER_IDLE ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0> )

	OnThreadEnd(
		function() : ( receiverFX )
		{
			if ( IsValid( receiverFX.value ) )
			{
				EffectStop( receiverFX.value )
			}
		}
	)

	bool portalWasActive      = false
	bool portalShouldBeActive = false
	while ( true )
	{
		if ( data.regroupPortalCount == 0 )
		{
			portalShouldBeActive = false
		}
		else
		{
			portalShouldBeActive = true
		}

		if ( portalShouldBeActive && !portalWasActive )
		{
			EffectStop( receiverFX.value )
			receiverFX.value = StartParticleEffectOnEntityWithPos_ReturnEntity( receiver, GetParticleSystemIndex( TRANSPORT_PORTAL_RECIEVER_ACTIVE ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0> )

			receiver.Anim_PlayOnly( "prop_alter_teleporter_activate" )
		}
		else if ( !portalShouldBeActive && portalWasActive )
		{
			EffectStop( receiverFX.value )
			receiverFX.value = StartParticleEffectOnEntityWithPos_ReturnEntity( receiver, GetParticleSystemIndex( TRANSPORT_PORTAL_RECIEVER_IDLE ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0> )
			receiver.Anim_PlayOnly( "prop_alter_teleporter_idle" )
		}

		portalWasActive = portalShouldBeActive
		WaitFrame()
	}
}
#endif

#if SERVER
void function Receiver_OnPostDamaged( entity receiver, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( receiver ) )
		return

	if ( !IsValid( attacker ) )
		return

	bool isAttackerWorldSpawn
	if ( IsWorldSpawn( attacker ) )
		isAttackerWorldSpawn = true

	int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )

	if ( receiver.GetHealth() <= DamageInfo_GetDamage( damageInfo ) )
	{
		entity player = receiver.GetBossPlayer()
		if ( IsValid( player ) )
		{
			if ( attacker.IsPlayer() )
			{
				PlayBattleChatterLineToSpeakerAndTeam( player, "bc_portalGeneratorDestroyed" )
			}
			else
			{
				PlayBattleChatterLineToSpeakerAndTeam( player, "bc_portalGeneratorDestroyedEnv" )
			}

			// PIN Tracking
			int destructionReason = eTransportPortalDestructionReason.NONE
			if( isAttackerWorldSpawn )
				destructionReason = eTransportPortalDestructionReason.WORLDSPAWN
			else if( attacker.IsPlayer() )
				destructionReason = eTransportPortalDestructionReason.ENEMY
			PIN_PlayerItemDestruction( player, ITEM_DESTRUCTION_TYPES.TRANSPORTATION_PORTAL, { reason = destructionReason } )
		}

		StartParticleEffectInWorld( GetParticleSystemIndex( TRANSPORT_PORTAL_DESTROYED ), receiver.GetOrigin(), <0,0,0> )
		EmitSoundAtPosition( TEAM_UNASSIGNED, receiver.GetOrigin(), TRANSPORT_PORTAL_DESTROYED_SOUND, receiver)

		array<entity> children = receiver.GetChildren()
		foreach ( child in children )
		{
			if( !IsValid(child) )
				continue

			entity deathBox = FindTargetNameInChildren( child, DEATH_BOX_TARGETNAME )
			if ( IsValid ( deathBox ) )
			{
				child.ClearParent()
				FakePhysicsThrow( null, child, <0,0,50>, true )
			}
		}

		DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
	}
	else
	{
		DamageInfo_AddCustomDamageType( damageInfo, DF_SOUR )
	}

	if ( isAttackerWorldSpawn )
		return

	if ( attacker.IsPlayer() && !IsBitFlagSet( damageFlags, DF_MELEE ) )
	{
		attacker.NotifyDidDamage( receiver, 0, DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ),
			DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ) | DF_NO_HITBEEP,
			DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
	}
}
#endif

#if SERVER
void function DissolveReceiver( entity receiver, entity rootEnt )
{
	//UnparentAndReparentIfNeeded( receiver, rootEnt )
	receiver.Dissolve( ENTITY_DISSOLVE_NONE, ZERO_VECTOR, 500 )
	receiver.NotSolid()
}
#endif

#if INTELLIJ_OUTLINE_SECTION_MARKER
void function _____________ReceiverUse___________________________(){}
#endif

bool function TransportPortal_IsPlayerCurrentlyChanneling( entity player )
{
	entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( IsValid( activeWeapon ) && activeWeapon.GetWeaponClassName() == TRANSPORT_PORTAL_DATAPAD_WEAPON_NAME )
		return true

	return false
}

void function GetExtendedRangeUseEntityCallbackForPlayer( entity player, array<entity> outEnts )
{
	int team = player.GetTeam()
	if ( team in file.teamToReceiversMap )
	{
		outEnts.extend( file.teamToReceiversMap[team] )
	}
}

bool function Receiver_CanUseCallback( entity player, entity receiver, int useFlags )
{
	#if TRANSPORT_PORTAL_DATAPAD_DEBUG && SERVER
		printf( "Alter - " + player + ": Ult Receiver_CanUseCallback for " + player  )
	#endif
	if ( !IsValid ( player ) || !IsValid( receiver ) )
		return false

	if ( !Receiver_CanUseStandardChecks( player, receiver ) )
		return false

	if ( player.p.isInExtendedUse )
		return false

	entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( IsValid( activeWeapon ) && activeWeapon.GetWeaponClassName() == TRANSPORT_PORTAL_DATAPAD_WEAPON_NAME )
		return false

	#if TRANSPORT_PORTAL_DATAPAD_DEBUG && SERVER
		printf( "Alter - " + player + ": Ult can use success!" )
	#endif
	#if SERVER
	Assert( !file.rootEntToDataMap[receiver.GetOwner()].currentUsers.contains( player ) )
	#endif

	return true
}

bool function Receiver_CanUseStandardChecks( entity player, entity receiver )
{
	if ( !IsValid ( player ) || !IsValid( receiver ) )
		return false

	if ( receiver.GetTeam() != player.GetTeam() )
		return false

	if ( StatusEffect_HasSeverity( player, eStatusEffect.placing_phase_tunnel ) )
		return false

	if ( player.Player_IsSkywardLaunching() )
		return false

	if ( player.Player_IsSkywardFollowing() )
		return false

	if ( player.Player_IsSkydiving() )
		return false

	if ( player.ContextAction_IsActive() )
		return false

	if ( player.ContextAction_IsBusy() )
		return false
	if ( receiver.IsDissolving() )
		return false

	entity rootEnt = receiver.GetOwner()
	if ( !IsValid( rootEnt ) )
		return false

	if ( IsBitFlagSet( player.GetWeaponDisableFlags(), WEAPON_DISABLE_FLAGS_MAIN) )
		return false

	entity weapon = player.GetOffhandWeapon( OFFHAND_EQUIPMENT )
	if ( IsValid( weapon ) )
	{
		if ( weapon.GetWeaponClassName() == TRANSPORT_PORTAL_DATAPAD_WEAPON_NAME )
		{
			return false
		}
	}

	return true
}

void function OnUse_Receiver( entity receiver, entity player, int useInputFlags )
{
	if ( !IsBitFlagSet( useInputFlags, USE_INPUT_LONG ) )
		return

	if ( IsBitFlagSet( useInputFlags, USE_INPUT_ALT ) )
		return

	#if CLIENT
		CustomUsePrompt_SetLastUsedTime( Time() )
	#endif
	thread ReceiverActivate_LongPress_Thread( receiver, player )
}

void function ReceiverActivate_LongPress_Thread( entity receiver, entity player )
{
	ExtendedUseSettings settings
	settings.duration = tuning.useTime

	#if CLIENT
		settings.loopSound = "survival_titan_linking_loop"
		settings.displayRuiType = eExtendedUseRuiType.NONE
		settings.displayRui = $"ui/extended_use_hint.rpak"
		settings.displayRuiFunc = void function( entity ent, entity player, var rui, ExtendedUseSettings settings )
		{
			RuiSetString( rui, "holdButtonHint", settings.holdHint )
			RuiSetString( rui, "hintText", settings.hint )
			RuiSetGameTime( rui, "startTime", Time() )
			RuiSetGameTime( rui, "endTime", Time() + settings.duration )
		}
		settings.icon = $""
		settings.hint = Localize( "#TRANSPORT_PORTAL_CHASE_PORTAL_CONFIRM_PROMPT" )
		file.useStartTime = Time()
	#elseif SERVER // end CLIENT
		settings.exclusiveUse = false
		settings.setUsableOnSuccess = true
		settings.successFunc = OnReceiverUse_Success
	#endif // SERVER

	#if CLIENT
		thread SetUseStartTime_Thread( player )
	#endif

	waitthread ExtendedUse( receiver, player, settings )

	#if CLIENT
		player.Signal( TRANSPORT_PORTAL_LONG_HOLD_END )
	#endif
}

#if CLIENT
void function SetUseStartTime_Thread( entity player )
{
	EndSignal( player, TRANSPORT_PORTAL_LONG_HOLD_END )

	OnThreadEnd(
		function() : ()
		{
			file.useStartTime = -1
		}
	)

	//we need to wait for the end of the frame as the long hold succcess is run in prediction, which is in the future
	//but the update of the rui is in a thread which is the current time, so these times were getting mismatched
	WaitEndFrame()
	file.useStartTime = Time()

	WaitForever()
}
#endif

#if SERVER
void function OnReceiverUse_Success( entity receiver, entity player, ExtendedUseSettings settings )
{
	if( !IsValid( player ) )
		return

	if ( !Receiver_CanUseStandardChecks( player, receiver ) )
		return

	BeginUseOfDatapad( player, receiver )
}
#endif

#if CLIENT
string function Receiver_TextOverride( entity ent )
{
	return "#TRANSPORT_PORTAL_ALLY_RECALL_USE_PROMPT_LOOKING"
}
#endif

#if SERVER
void function BeginUseOfDatapad( entity player, entity receiver )
{
	bool isKnocked = Bleedout_IsBleedingOut( player )
	array<string> mods = []
	if ( isKnocked )
		mods.append( "player_knocked" )

	player.DisableWeaponTypes( WPT_ULTIMATE | WPT_TACTICAL )

	entity datapadWeapon = GivePlayerOffhandEquipment( player, TRANSPORT_PORTAL_DATAPAD_WEAPON_NAME, true, mods )

	entity rootEnt = receiver.GetOwner()
	datapadWeapon.w.transportPortalRootEnt = rootEnt

	player.SetSelectedOffhand( eActiveInventorySlot.mainHand, datapadWeapon )

	#if TRANSPORT_PORTAL_DATAPAD_DEBUG
		printf( "Alter - " + player + ": BeginUseOfDatapad" )
	#endif

	file.rootEntToDataMap[rootEnt].currentUsers.append( player )
	thread TakeDataPadIfInterrupted_Thread( player )
	thread TakeDataPadIfNeverActivates_Thread( player )
}

void function TransportPortal_EndUseOfDatapad( entity player )
{
	entity weapon = player.GetOffhandWeapon( OFFHAND_EQUIPMENT )
	if ( IsValid( weapon ) )
	{
		if ( weapon.GetWeaponClassName() == TRANSPORT_PORTAL_DATAPAD_WEAPON_NAME )
		{
			#if TRANSPORT_PORTAL_DATAPAD_DEBUG
				printf( "Alter - " + player + ": Taking datapad - " + GetStack() )
			#endif

			if ( weapon.w.transportPortalRootEnt in file.rootEntToDataMap )
			{
				file.rootEntToDataMap[weapon.w.transportPortalRootEnt].currentUsers.fastremovebyvalue( player )
			}

			TakePlayerOffhandEquipment( player, TRANSPORT_PORTAL_DATAPAD_WEAPON_NAME, true )

			player.EnableWeaponTypes( WPT_ULTIMATE | WPT_TACTICAL )
		}
	}
}

void function TakeDataPadIfNeverActivates_Thread( entity player )
{
	player.EndSignal( "OnDeath", "OnDestroy" )

	//two frames is probably enough, but if we trigger it too soon, the ult channeling gets cancelled
	//and it no longer crashes if it get cancelled, so we're better off with this being a bit too long.
	wait 1

	entity currentWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

	if ( !IsValid( currentWeapon ) || currentWeapon.GetWeaponClassName() != TRANSPORT_PORTAL_DATAPAD_WEAPON_NAME )
	{
		#if TRANSPORT_PORTAL_DATAPAD_DEBUG
			printf( "Alter: datapad never activated!" )
		#endif
		TransportPortal_EndUseOfDatapad( player )
	}
}
#endif // SERVER

#if INTELLIJ_OUTLINE_SECTION_MARKER
void function _____________Receiver_UI___________________________(){}
#endif

#if CLIENT
bool function InRangeOfReceiver( entity player, entity receiver )
{
	if ( Distance( receiver.GetOrigin(), player.GetOrigin() ) > tuning.maxUseDistance )
		return false

	return true
}
#endif

#if CLIENT
void function TransportPortalCreatedHint_Thread( entity receiver, entity player, float hintDuration )
{
	Assert ( IsNewThread(), "Must be started as new thread" )

	Assert ( IsValid( receiver ) && IsValid( player ), "calling TransportPortalCreatedHint_Thread with invalid ents!" )

	receiver.Signal( TRANSPORT_PORTAL_HINT_THREAD )
	player.EndSignal( "OnDeath", "OnDestroy" )
	receiver.EndSignal( "OnDestroy", "OnBeginDissolve", TRANSPORT_PORTAL_HINT_THREAD )

	float removeHintTime   = Time() + hintDuration

	AddPlayerHint( hintDuration, 0, TRANSPORT_PORTAL_RECEIVER_IMAGE, Localize( "#TRANSPORT_PORTAL_ALLY_RECALL_HINT" ) )

	OnThreadEnd(
		function() : ()
		{
			HidePlayerHint( Localize( "#TRANSPORT_PORTAL_ALLY_RECALL_HINT" ) )
		}
	)

	while ( Time() < removeHintTime )
	{
		if ( player.GetUseEntity() == receiver )
			return

		WaitFrame()
	}
}
#endif

#if CLIENT
void function OnBleedoutStarted( entity victim, float endTime )
{
	if ( victim != GetLocalViewPlayer() )
		return

	int team = victim.GetTeam()
	if ( !( team in file.teamToReceiversMap ) )
		return

	Assert( file.teamToReceiversMap[team].len() > 0, "No receivers in the map!" )

	foreach ( entity receiver in file.teamToReceiversMap[team] )
	{
		if ( !IsValid( receiver ) )
			continue

		entity rootEnt = receiver.GetOwner()
		if ( !IsValid( rootEnt ) )
			continue
		thread DelayUltHintThreadOnKnock( victim, receiver )
		break
	}
}

void function DelayUltHintThreadOnKnock( entity victim, entity receiver )
{
	EndSignal( victim, "OnDeath", "OnDestroy" )
	EndSignal( receiver, "OnDestroy", "OnBeginDissolve" )

	wait 1.5

	thread TransportPortalCreatedHint_Thread( receiver, victim, 5 )
}
#endif


#if CLIENT
void function OnYouRespawned()
{
	ArrayRemoveInvalid( file.allReceivers )

	int team = GetLocalViewPlayer().GetTeam()
	foreach( entity receiver in file.allReceivers )
	{
		if ( receiver.GetTeam() == team )
		{
			thread ManageLookAtRui_Thread( receiver, GetLocalViewPlayer() )
		}
	}
}
#endif

#if CLIENT
void function OnSpectatorTargetChanged( entity player, entity prevTarget, entity newTarget )
{
	if ( IsValid(prevTarget) )
	{
		prevTarget.Signal( TRANSPORT_PORTAL_SPECTATOR_CHANGED )
	}

	if ( !IsValid(newTarget) )
		return

	ArrayRemoveInvalid( file.allReceivers )

	int team = newTarget.GetTeam()
	foreach( entity receiver in file.allReceivers )
	{
		if ( receiver.GetTeam() == team )
		{
			thread ManageLookAtRui_Thread( receiver, GetLocalViewPlayer() )
		}
	}
}
#endif

#if CLIENT
void function ManageLookAtRui_Thread( entity receiver, entity player )
{
	Assert ( IsNewThread(), "Must be started as new thread" )

	if ( !IsValid( player ) || !IsValid( receiver ) )
		return

	player.EndSignal( "OnDeath", "OnDestroy", TRANSPORT_PORTAL_SPECTATOR_CHANGED )
	receiver.EndSignal( "OnDestroy", "OnBeginDissolve" )

	entity rootEnt = receiver.GetOwner()

	if ( !IsValid( rootEnt )  )
		return

	rootEnt.EndSignal( "OnDestroy" )

	file.ultPendingRuiDurationUpdate = null

	vector pos             = receiver.GetOrigin()

	var iconRui            = CreateCockpitPostFXRui( TRANSPORT_PORTAL_IN_WORLD_HUD_OBJECT, RuiCalculateDistanceSortKey( player.EyePosition(), pos ) )
	var regroupInfoRui	   = CreateCockpitPostFXRui( $"ui/alter_ult_hint_display.rpak", RuiCalculateDistanceSortKey( player.EyePosition(), pos ) )

	RuiTrackFloat3( iconRui, "pos", receiver, RUI_TRACK_ABSORIGIN_FOLLOW  )
	RuiTrackFloat3( iconRui, "playerAngles", player, RUI_TRACK_CAMANGLES_FOLLOW )
	RuiKeepSortKeyUpdated( iconRui, true, "pos" )

	OnThreadEnd(
		function() : ( iconRui, regroupInfoRui )
		{
			if ( iconRui != null )
			{
				RuiDestroyIfAlive( iconRui )
			}

			if ( regroupInfoRui != null )
			{
				RuiDestroyIfAlive( regroupInfoRui )
			}
		}
	)

	RuiTrackFloat3( regroupInfoRui, "pos", receiver, RUI_TRACK_ABSORIGIN_FOLLOW  )

	float endTime = player.GetPlayerNetTime( TRANSPORT_PORTAL_EXPIRE_TIME_NETVAR )
	if ( endTime == 0 )
	{
		RuiSetBool( regroupInfoRui, "isEndless", true  )
		RuiSetBool( iconRui, "isEndless", true )
	}
	else
	{
		RuiSetGameTime( regroupInfoRui, "endTime", endTime  )
		RuiSetGameTime( iconRui, "endTime", endTime )
	}

	while ( true )
	{
		bool inRange = InRangeOfReceiver( player, rootEnt)
		RuiSetBool( iconRui, "isInRange", inRange )
		RuiSetBool( regroupInfoRui, "isInRange", inRange )

		bool hasPlayerUsedRecal = false
		RuiSetBool( regroupInfoRui, "playerHasUsedRecall", hasPlayerUsedRecal )

		if ( file.ultPendingRuiDurationUpdate == receiver )
		{
			file.ultPendingRuiDurationUpdate = null
			endTime = player.GetPlayerNetTime( TRANSPORT_PORTAL_EXPIRE_TIME_NETVAR )
			if ( endTime == 0 )
			{
				RuiSetBool( regroupInfoRui, "isEndless", true  )
				RuiSetBool( iconRui, "isEndless", true )
			}
			else
			{
				RuiSetGameTime( regroupInfoRui, "endTime", endTime  )
				RuiSetGameTime( iconRui, "endTime", endTime )
			}
		}

		bool ownedByPlayer = rootEnt.GetOwner() == player
		bool isChanneling = TransportPortal_IsPlayerCurrentlyChanneling( player )
		bool showText = false

		if (  hasPlayerUsedRecal )
		{
			showText = ownedByPlayer
		}
		else if ( isChanneling || player.p.isInExtendedUse )
		{
			if ( player.p.lastExtededUseEnt == receiver )
				showText = true
		}
		else if ( player.GetUseEntity() == receiver )
		{
			showText = true
		}
		else if ( !inRange && player.GetUseEntity() == null )
		{
			showText = true
		}

		RuiSetBool( regroupInfoRui, "isVisible", showText )

		RuiSetBool( iconRui, "isVisible",  inRange )

		RuiSetBool( regroupInfoRui, "isChanneling", isChanneling )
		RuiSetBool( iconRui, "isChanneling", isChanneling )

		//variables for regroup info state
		int team                   = player.GetTeam()
		int squadUses			   = 0 //Counter for if it's been used by the squad or not


		array<entity> playerSquad = GetPlayerArrayOfTeam( team )
		ArrayRemoveInvalid( playerSquad )

		RuiSetInt( regroupInfoRui, "squadSize", playerSquad.len() )
		RuiSetInt( iconRui, "squadSize", playerSquad.len() )

		for ( int index = 0 ; index < playerSquad.len() ; index++ )
		{
			if( index > 3 )
				break

			RuiSetBool( iconRui, "isOwner", ownedByPlayer )
			RuiSetBool( regroupInfoRui, "isOwner", ownedByPlayer )

			if ( index < playerSquad.len() && index > 0)
			{
				entity squadMate = playerSquad[index]
				ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( squadMate ), Loadout_Character() )
				RuiSetImage( iconRui, "teammatePortrait" + index, CharacterClass_GetGalleryPortrait(character) )

			}
		}

		RuiSetInt( iconRui, "squadUses", squadUses )

		float fillAmount = 0
		if ( file.useStartTime > 0 )
		{
			fillAmount = clamp((Time() - file.useStartTime) / tuning.useTime, 0, 1)
		}

		if ( isChanneling && file.channelStartTime == -1 )
			file.channelStartTime = Time()

		if ( !isChanneling )
			file.channelStartTime = -1

		if ( file.channelStartTime > 0 && file.channelTime > 0 )
		{
			fillAmount = clamp((Time() - (file.channelStartTime - file.channelTimeElapsed)) / file.channelTime, 0, 1)
		}


		RuiSetFloat( iconRui, "arcFill", fillAmount )
		RuiSetFloat( regroupInfoRui, "arcFill", fillAmount )

		WaitFrame()
	}
}
#endif

#if CLIENT
void function ServerToClient_TransportPortal_UltDurationChanged( entity ult )
{
	file.ultPendingRuiDurationUpdate = ult
}
#endif

entity function TransportPortal_GetReceiverPlayerIsLookingAt( entity player )
{
	if ( !IsValid( player ) )
		return null

	int team = player.GetTeam()
	if ( !( team in file.teamToReceiversMap ) )
		return null

	vector eyeDir = player.GetViewVector()
	vector eyePos = player.EyePosition()
	const float MAX_DOT = cos( 3.0 * DEG_TO_RAD )

	entity bestReceiver = null
	float closestDist = FLOAT_INFINITY
	foreach( entity receiver in file.teamToReceiversMap[team] )
	{
		if ( !IsValid( receiver ) )
			continue

		vector playerToReceiver = (receiver.GetOrigin() - eyePos)
		float distToReceiver = Length( playerToReceiver )
		vector dirFromPlayerToReceiver = playerToReceiver / distToReceiver

		if ( DotProduct( eyeDir, dirFromPlayerToReceiver ) > MAX_DOT )
		{
			if ( distToReceiver < closestDist )
			{
				bestReceiver = receiver
			}
		}
	}

	return bestReceiver
}

#if INTELLIJ_OUTLINE_SECTION_MARKER
void function _____________ChasePortal___________________________(){}
#endif

#if SERVER
void function CreateChasePortal_Thread( entity rootEnt, entity player )
{
	Assert ( IsNewThread(), "Must be started as new thread" )

	rootEnt.EndSignal( "OnDestroy" )

	vector portalPos = player.GetOrigin()

	vector allyPortalToRootEntDir = Normalize( FlattenVec( rootEnt.GetOrigin() - player.GetOrigin() ) )
	vector portalAngles = VectorToAngles( allyPortalToRootEntDir )

	entity allyPortalRootEnt = CreatePropScript( $"mdl/dev/empty_model.rmdl", portalPos, portalAngles )
	allyPortalRootEnt.SetScriptName( TRANSPORT_PORTAL_ALLY_PORTAL_SCRIPTNAME )
	allyPortalRootEnt.SetOwner( rootEnt )
	allyPortalRootEnt.SetBossPlayer( player )
	allyPortalRootEnt.RemoveFromAllRealms()
	allyPortalRootEnt.AddToOtherEntitysRealms( player )
	SetTeam( allyPortalRootEnt, player.GetTeam() )
	//we intentionally don't parent this as it'd change the pathing

	AllyPortalData data
	file.allyPortalToDataMap[allyPortalRootEnt] <- data
	file.rootEntToDataMap[rootEnt].regroupPortalCount++
	file.rootEntToDataMap[rootEnt].allyPortals.append( allyPortalRootEnt )

	EmitSoundOnEntity( allyPortalRootEnt, TRANSPORT_PORTAL_CHASE_PORTAL_WARMUP_SOUND )

	entity portalFX = StartParticleEffectOnEntityWithPos_ReturnEntity( allyPortalRootEnt, GetParticleSystemIndex( TRANSPORT_PORTAL_CHASE_INACTIVE ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, CHASE_PORTAL_OFFSET, <0,0,0> )
	data.fx = portalFX

	vector rotatedAngles = RotateAnglesAboutAxis( allyPortalRootEnt.GetAngles(), allyPortalRootEnt.GetUpVector(), 90.0 )
	const vector traceBlockerMins = <-50, -3, -50>
	const vector traceBlockerMaxs = <50, 3, 50>
	entity traceBlocker = CreateTraceBlockerVolume_CustomBox( portalPos + CHASE_PORTAL_OFFSET, rotatedAngles, traceBlockerMins, traceBlockerMaxs, CONTENTS_BLOCK_PING | CONTENTS_NOGRAPPLE, allyPortalRootEnt.GetTeam(), TRANSPORT_PORTAL_ALLY_PORTAL_TRACE_BLOCKER_SCRIPTNAME, allyPortalRootEnt.GetOwner() )
	traceBlocker.SetParent( allyPortalRootEnt )
	//DrawAngledBox( portalPos + CHASE_PORTAL_OFFSET, rotatedAngles, traceBlockerMaxs, traceBlockerMaxs, COLOR_RED, false, 10 )

	allyPortalRootEnt.Minimap_SetCustomState( eMinimapObject_prop_script.TRANSPORT_PORTAL_CHASE_PORTAL )
	allyPortalRootEnt.Minimap_SetAlignUpright( true )
	allyPortalRootEnt.Minimap_SetClampToEdge( false )
	allyPortalRootEnt.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
	allyPortalRootEnt.DisableHibernation()

	foreach ( entity otherPlayer in GetPlayerArray() )
	{
		allyPortalRootEnt.Minimap_Hide( otherPlayer.GetTeam(), null )
	}
	allyPortalRootEnt.Minimap_AlwaysShow( player.GetTeam(), null )

	GeneratePathFromPlayerToRootEnt( rootEnt, player, null, allyPortalRootEnt )

	//printf("ALTER - Teleporting from " + allyPortalRootEnt)
	#if DEVELOPER
	if (!TRANSPORT_PORTAL_NAVMESH_PATH_DEBUG)
	#endif
	{
		ChasePortalDoTeleport( allyPortalRootEnt, player )
	}

	TransportPortal_EndUseOfDatapad( player )
	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_ALTER_ULTIMATE_USED, player, portalPos, player.GetTeam(), player )

	// PIN Tracking
	PIN_Interact( player, "alter_transport_team", rootEnt.GetOrigin() )

	//Stat Tracking
	entity owner = rootEnt.GetOwner()
	if( IsValid( owner ) )
		StatsHook_AlterAlliesRegrouped( owner )

	if ( tuning.createWaypointWhenInArea )
	{
		CreateWaypointTrigger( allyPortalRootEnt )
	}

	allyPortalRootEnt.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( allyPortalRootEnt, rootEnt, player, portalFX )
		{
			if ( IsValid( portalFX ) )
				EffectStop( portalFX )

			StopSoundOnEntity( allyPortalRootEnt, TRANSPORT_PORTAL_CHASE_PORTAL_ACTIVE_SOUND )

			allyPortalRootEnt.Destroy()

			if ( rootEnt in file.rootEntToDataMap )
			{
				file.rootEntToDataMap[rootEnt].regroupPortalCount--
				file.rootEntToDataMap[rootEnt].allyPortals.fastremovebyvalue( allyPortalRootEnt )
			}

			delete file.allyPortalToDataMap[allyPortalRootEnt]
		}
	)

	if ( rootEnt in file.rootEntToDataMap )
	{
		array<entity> receiverUsers = file.rootEntToDataMap[rootEnt].teammatesWhoHaveUsedReceiver
		#if DEVELOPER
		if (!TRANSPORT_PORTAL_NAVMESH_PATH_DEBUG)
		#endif
		{
			Assert( !receiverUsers.contains( player ), "Player has already created a portal!" )
		}

		receiverUsers.append( player )

		entity receiver = file.rootEntToDataMap[rootEnt].receiver

		//receiver can be invalid if it was destroyed during channeling
		if ( IsValid( receiver ) )
		{
			bool everyoneUsedUlt = true
			foreach ( teammate in GetPlayerArrayOfTeam( rootEnt.GetTeam() ) )
			{
				if ( !receiverUsers.contains( teammate ) )
				{
					everyoneUsedUlt = false
					break
				}
			}

			if ( everyoneUsedUlt )
			{
				DissolveReceiver( receiver, rootEnt )
			}
		}
	}
	else
	{
		Assert( false, "rootEnt isn't in the map!" )
	}

	WaitFrame()

	if ( tuning.createDelayedAutoFollowPortal )
	{
		wait tuning.chasePortalWarmupTime

		StopSoundOnEntity( allyPortalRootEnt, TRANSPORT_PORTAL_CHASE_PORTAL_WARMUP_SOUND )

		CreateChasePortalTrigger( allyPortalRootEnt )
	}

	EmitSoundOnEntity( allyPortalRootEnt, TRANSPORT_PORTAL_CHASE_PORTAL_ACTIVE_SOUND )

	wait tuning.chasePortalOpenDuration - tuning.chasePortalTimeoutWarningDuration

	EmitSoundOnEntity( allyPortalRootEnt, TRANSPORT_PORTAL_CHASE_PORTAL_ENDING_SOUND )

	wait tuning.chasePortalTimeoutWarningDuration
}
#endif

#if CLIENT
void function ChasePortalLifetime_Client_Thread( entity allyPortalRootEnt )
{
	AllyPortalData data
	file.allyPortalToDataMap[allyPortalRootEnt] <- data

	EndSignal( allyPortalRootEnt, "OnDestroy" )

	OnThreadEnd(
		function() : ( allyPortalRootEnt )
		{
			delete file.allyPortalToDataMap[allyPortalRootEnt]
		}
	)

	WaitForever()
}
#endif

#if SERVER
void function CreateChasePortalTrigger( entity allyPortalRootEnt )
{
	if ( !(allyPortalRootEnt in file.allyPortalToDataMap) )
		return

	if ( IsValid( file.allyPortalToDataMap[allyPortalRootEnt].fx ) )
		EffectStop( file.allyPortalToDataMap[allyPortalRootEnt].fx )

	vector fxOffset = <0,0,50>
	entity ringFX = StartParticleEffectOnEntityWithPos_ReturnEntity( allyPortalRootEnt, GetParticleSystemIndex( TRANSPORT_PORTAL_CHASE_ACTIVE ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, fxOffset, <0,0,0> )
	file.allyPortalToDataMap[allyPortalRootEnt].fx = ringFX

	const vector offset = <0,0,42>

	entity teamMatePortalTrigger = CreateTriggerCylinder( allyPortalRootEnt.GetOrigin() + offset, TRANSPORT_PORTAL_TRIGGER_RADIUS, 32, 32 )
	teamMatePortalTrigger.RemoveFromAllRealms()
	teamMatePortalTrigger.AddToOtherEntitysRealms( allyPortalRootEnt )
	teamMatePortalTrigger.kv.triggerFilterNpc          = "none"
	teamMatePortalTrigger.kv.triggerFilterPlayer       = "all"
	teamMatePortalTrigger.kv.triggerFilterNonCharacter = 0
	teamMatePortalTrigger.SetPhaseShiftCanTouch( false )

	teamMatePortalTrigger.SetEnterCallback( PortalTriggerEnter )
	//teamMatePortalTrigger.SearchForNewTouchingEntity()
	teamMatePortalTrigger.SetOwner( allyPortalRootEnt )
	teamMatePortalTrigger.SetParent( allyPortalRootEnt )
}
#endif // SERVER

#if SERVER
void function PortalTriggerEnter( entity trigger, entity player )
{
	if ( !IsValid( player ) )
		return

	if ( !IsValid( trigger ) )
		return

	if ( !player.DoesShareRealms( trigger ) )
		return

	if ( !player.IsPlayer() )
		return

	if ( tuning.chasePortalRequiresFacing )
	{
		vector playerVel = player.GetVelocity()
		vector playerFwd = player.GetViewForward()
		float lookDot = DotProduct( Normalize(playerVel), Normalize(playerFwd) )
		//printt( "LookDot " + lookDot )
		if ( lookDot < -DOT_80DEGREE )
			return
	}

	if ( (player.p.lastTransportPortalArrivalTime + tuning.chasePortalRentryDebounce) > Time() )
		return

	//do this check last since it's not const (can change the player's state)
	if ( !PhaseTunnel_ShouldPhaseEnt( player ) )
		return

	entity allyPortalRootEnt = trigger.GetOwner()
	if ( IsValid( allyPortalRootEnt ) )
	{
		if ( IsEnemyTeam( allyPortalRootEnt.GetTeam(), player.GetTeam() ) && allyPortalRootEnt != player )
		{
			PlayBattleChatterLineToSpeakerAndTeamWithDebounceTime( player, "bc_chasePortalUsing", 15, 15 )
		}
		else
		{
			PlayBattleChatterLineToSpeakerAndTeamWithDebounceTime( player, "bc_portalUsing", 15, 15 )
		}

		//printf("ALTER - Touching trigger from " + triggerOwner)
		ChasePortalDoTeleport( allyPortalRootEnt, player )

		// PIN Tracking
		PIN_Interact( player, "alter_transport_chase", allyPortalRootEnt.GetOrigin() )
	}
}
#endif // SERVER

#if SERVER
void function ChasePortalDoTeleport( entity allyPortalRootEnt, entity player )
{
	Assert( player.IsPlayer() )

	if( !IsAlive( player ) )
		return

	if ( player.IsPhaseShifted() )
		return

	if ( player.ContextAction_IsActive() )
		return

	if ( player.ContextAction_IsBusy() )
		return

	if ( player.Player_IsSkywardLaunching() )
		return

	if ( player.Player_IsSkywardFollowing() )
		return

	if ( player.Player_IsSkydiving() )
		return

	if ( player.e.isInPhaseTunnel )
		return

	if ( !(allyPortalRootEnt in file.allyPortalToDataMap) )
	{
		Assert( false, "No path data for alter ult portal?" )
		return
	}

	entity rootEnt = allyPortalRootEnt.GetOwner()
	if ( !IsValid( rootEnt ) )
		return

	#if DEVELOPER
	//if (!TRANSPORT_PORTAL_NAVMESH_PATH_DEBUG)
	#endif
	{
		//rootEnt.SetUseStateByIndex( player.GetPlayerIndex(), true )
	}

	PhaseTunnelPortalData portalData = file.allyPortalToDataMap[allyPortalRootEnt].tunnelData

	StartParticleEffectOnEntityWithPos_ReturnEntity( allyPortalRootEnt, GetParticleSystemIndex( TRANSPORT_PORTAL_ONEWAY_START ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, CHASE_PORTAL_OFFSET, <0,0,0> )

	StartParticleEffectInWorldForRealms( GetParticleSystemIndex( TRANSPORT_PORTAL_ENTER_EXIT_FX ), allyPortalRootEnt.GetOrigin(), <0,0,0>, allyPortalRootEnt )

	thread DoPhaseTravel_Thread( player, allyPortalRootEnt, portalData )
}

void function DoPhaseTravel_Thread( entity player, entity allyPortalRootEnt, PhaseTunnelPortalData portalData )
{
	Assert ( IsNewThread(), "Must be started as new thread" )

	player.EndSignal( "OnDeath", "OnDestroy" )

	PhaseTunnelData tunnelData
	tunnelData.startPortal = portalData
	tunnelData.shiftStyle  = PHASETYPE_TRANSPORT
	tunnelData.tunnelEnt = CreatePropScript( $"mdl/dev/empty_model.rmdl", portalData.startOrigin )
	//tunnelData.additionalPhaseTime = 1.5

	PhaseTunnelTravelState travelState
	travelState.shiftStyle               = PHASETYPE_TRANSPORT
	travelState.holsterRemoveDelay       = 0.4//1.5
	travelState.endSeekCheckOverrideFunc = TransportPortal_PathNodeCheck
	travelState.ignoreStuckCrouchCheck   = true

	entity rootEnt = allyPortalRootEnt.GetOwner()
	Assert( IsValid( rootEnt ), "Trying to travel but root end was invalid" )
	Assert ( rootEnt in file.rootEntToDataMap, "Trying to travel but root end wasn't in the table" )
	Assert( !file.rootEntToDataMap[rootEnt].playersInTransit.contains( player ), "Player already being teleported" )

	file.rootEntToDataMap[rootEnt].playersInTransit.append( player )

	vector rootEntStartPos = rootEnt.GetOrigin()

	                   
	VoidVision_GrantVoidVision( player )
       

	OnThreadEnd(
		function() : ( tunnelData, rootEnt, player )
		{
			if ( IsValid( tunnelData.tunnelEnt ) )
				tunnelData.tunnelEnt.Destroy()

			if ( rootEnt in file.rootEntToDataMap )
			{
				file.rootEntToDataMap[rootEnt].playersInTransit.fastremovebyvalue( player )
			}

			if ( IsValid( player ) )
			{
				player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, player.GetLastCycleSlot() )

				                   
					VoidVision_TakeVoidVision( player )
          
			}
		}
	)

	float travelTime = portalData.pathData.frameSteps.len() * 0.1 + 0.1
	float startTime  = Time()

	thread ManageWarningFX_Thread( travelTime, rootEnt, player )
	player.Signal( TRANSPORT_PORTAL_EXTRA_WAIT_TIME_SIGNAL, { extraTime = travelTime } )

	//todo-iholstead: remove me once R5DEV-578675 is closed
	printf("DoPhaseTravel_Thread called on "+ player )

	waitthread PhaseTunnel_PhaseEntity( player, tunnelData.tunnelEnt, tunnelData, portalData, travelState )

	SwapToLastEquippedPrimary( player )
	#if DEVELOPER
	printf("ALTER ult - Predicted: " + travelTime + ", Actual: " + (Time() - startTime))
	#endif

	player.p.lastTransportPortalArrivalTime = Time()

	vector endPos = portalData.endOrigin
	//under rare circumstances, the root ent can be destroyed
	if ( IsValid( rootEnt ) && DistanceSqr( rootEntStartPos, rootEnt.GetOrigin() ) > 1.0 )
	{
		const vector offset = <0,0,9>
		endPos = rootEnt.GetOrigin() + offset
	}

	PutPlayerInSafeSpot( player, null, null, endPos, endPos )

	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_ALTER_ULTIMATE_USED, player, endPos, player.GetTeam(), player )

	                  
		FR_Nessie_OnVoidNexusUsed( player, portalData.endOrigin )
       
}
#endif

#if INTELLIJ_OUTLINE_SECTION_MARKER
void function _____________PathGeneration___________________________(){}
#endif

#if SERVER
int function TransportPortal_PathNodeCheck( entity player, array<PhaseTunnelPathNodeData> pathNodes, int index, int nextIndex )
{
	//These phases will go through geo so just always accept.
	return 0
}

void function GeneratePathFromPlayerToRootEnt( entity rootEnt, entity player, entity teamMatePortalVFX, entity allyPortalRootEnt )
{

}

PhaseTunnelPortalData function ConvertPathToTunnelPortalData( entity rootEnt, entity portalFX, array<vector> path )
{
	PhaseTunnelPortalData results

	results.startOrigin = path[0]
	results.startAngles = VectorToAngles( rootEnt.GetForwardVector() )
	results.portalFX = portalFX
	results.endOrigin = path[path.len()-1]
	results.endAngles = VectorToAngles( results.endOrigin - path[path.len()-2] )
	results.crouchPortal = false

	PhaseTunnelPathData pathData
	float totalDistance

	//Tunnel portal expected from dest to start, our path was generated from start to dest.  So we have to essentailly reverse it here.
	for ( int i = path.len() - 1; i >= 0; i-- )
	{
		vector pos = path[i]
		PhaseTunnelPathNodeData pathNodeData
		pathNodeData.origin = pos
		pathNodeData.wasCrouched = false

		int nextPos = i-1

		if (  nextPos > 0 )
			pathNodeData.angles = path[nextPos] - pos
		else
			pathNodeData.angles = results.endAngles

		if ( i == 0 )
			pathNodeData.validExit = true

		pathData.pathNodes.append( pathNodeData )

		if ( i > 0 )
			totalDistance += Distance( pos, path[i-1] )
	}

	pathData.pathDistance = totalDistance
	pathData.pathTime = totalDistance / tuning.portalSpeed
	pathData.phaseTime = pathData.pathTime

	results.pathData = pathData

	return results
}


//Based on CreateSmoothPath from _hovertank.gnut, but this version will optimize the path to be the least number of segments.
//tnordin - changing the path optimization to be on a flag, I am using segments on the path to do things like slow down and speed up based on how many segments are left.
//This kind of falls apart if the segments aren't all the same length.
array<vector> function CreateOptimizedSmoothPath( array<vector> points, bool optimizePath=false, float segmentLength=64.0, float pathingTension=0.05 )
{
	//const float SMOOTH_PATHING_SEGMENT_LENGTH = 64.0 // higher number more optimized but path may look less smooth
	//const float SMOOTH_PATHING_TENSION = 0.05 // 1 is high, 0 normal, -1 is low

	//Assert( points.len() >= 2 )

	// Optimization - if there's only 2 points don't smooth them because we will fly a straight line
	if ( points.len() <= 2 )
		return points

	// Add duplicate start/end points to ensure the hermite interpolate starts/ends at the exact start and end point
	points.insert( 0, points[0] )
	points.append( points[points.len() - 1] )

	array<vector> smoothedPoints

	for ( int i = 0; i < points.len() - 3; i++ )
	{
		float d              = Distance( points[i + 1], points[i + 2] )
		int pointsPerSegment = int( ceil( d / segmentLength ) )
		//printt( "generated", pointsPerSegment, "smoothed segments for line" )
		for ( int k = 0 ; k < pointsPerSegment ; k++ )
		{
			float mu  = (1.0 / pointsPerSegment) * k
			vector pt = GetSmoothedPoint( points[i], points[i + 1], points[i + 2], points[i + 3], mu, pathingTension )
			smoothedPoints.append( pt )
		}
	}

	smoothedPoints.append( points[points.len() - 1] )

	return smoothedPoints
}
#endif

#if INTELLIJ_OUTLINE_SECTION_MARKER
void function _____________IncomingPlayerWarning___________________________(){}
#endif

#if SERVER

void function ManageWarningFX_Thread( float travelTime, entity rootEnt, entity player )
{
	entity translocator = file.rootEntToDataMap[rootEnt].translocator

	printf( "ALTER travel time " + travelTime )
	EndSignal( translocator, "OnDestroy" )
	EndSignal( rootEnt, "OnDestroy" )
	EndSignal( player, "OnDeath", "OnDestroy" )

	float endTime = Time() + travelTime

	entity trigger
	if ( tuning.createIncomingWarning )
	{
		if ( travelTime > 5)
			wait ( travelTime - 5 )

		trigger = CreateTriggerCylinderNetworked( rootEnt.GetOrigin(), tuning.incomingWarningRadius, tuning.incomingWarningHeight, tuning.incomingWarningHeight, <0,0,0> )
		trigger.SetScriptName( TRANSPORT_PORTAL_WARNING_TRIGGER_SCRIPTNAME )
		trigger.RemoveFromAllRealms()
		trigger.AddToOtherEntitysRealms( rootEnt )
		trigger.kv.triggerFilterNpc          = "none"
		trigger.kv.triggerFilterPlayer       = "all"
		trigger.kv.triggerFilterNonCharacter = 0
		trigger.SetPhaseShiftCanTouch( true )

		trigger.SetOwner( player )
		trigger.SetParent( rootEnt )
		SetTeam( trigger, player.GetTeam() )

	}

	OnThreadEnd(
		function() : ( trigger )
		{
			if ( IsValid( trigger ) )
			{
				trigger.Destroy()
			}
		}
	)

	if ( (endTime - Time()) > 1)
		wait ( (endTime - Time() - 1) )

	int rootEntTeam = rootEnt.GetTeam()


	int particleSystemSourcePortalID
	if ( IsFriendlyTeam( player.GetTeam(), rootEntTeam ) || rootEnt.GetOwner() == player )
	{
		particleSystemSourcePortalID = GetParticleSystemIndex( TRANSPORT_PORTAL_WARNING_FRIENDLY )
	}
	else
	{
		particleSystemSourcePortalID = GetParticleSystemIndex( TRANSPORT_PORTAL_WARNING_ENEMY )
	}
	entity portalFX = StartParticleEffectOnEntityWithPos_ReturnEntity( translocator, particleSystemSourcePortalID, FX_PATTACH_ABSORIGIN_FOLLOW_NOROTATE, translocator.LookupAttachment( "REF" ), <0,0,0>, <0,0,0> )

	OnThreadEnd(
		function() : ( portalFX )
		{
			if ( IsValid( portalFX ) )
			{
				EffectStop( portalFX )
				portalFX.Destroy()
			}
		}
	)

	wait 1

	if ( IsValid( trigger ) )
	{
		trigger.Destroy()
	}

	wait 1
}
#endif
#if CLIENT
bool function IsPlayersBeingWarnedAboutNexus( entity player )
{
	array<entity> closeUlts = GetEntitiesFromArrayNearPos( file.warningTriggers, player.GetOrigin(), tuning.incomingWarningRadius )
	foreach ( entity trigger in closeUlts )
	{
		if ( IsEnemyTeam( player.GetTeam(), trigger.GetTeam() ) && trigger.GetOwner() != player )
		{
			return true
		}
	}
	return false
}

void function TransportPortal_SetChannelUseTime(float channelTime, float channelTimeElapsed)
{
	file.channelTime = channelTime
	file.channelTimeElapsed = channelTimeElapsed
}

void function CleanupWarningTriggerOnDestroy_Thread( entity trigger )
{
	EndSignal( trigger, "OnDestroy" )

	OnThreadEnd(
		function() : ( trigger )
		{
			file.warningTriggers.fastremovebyvalue( trigger )
		}
	)

	WaitForever()
}
#endif

#if INTELLIJ_OUTLINE_SECTION_MARKER
void function _____________ChasePortalWaypoints___________________________(){}
#endif
#if SERVER
void function CreateWaypointTrigger( entity allyPortalRootEnt )
{
	const int triggerRadius = int(5 * METERS_TO_INCHES)
	entity areaWaypointTrigger = CreateTriggerCylinder( allyPortalRootEnt.GetOrigin() + CHASE_PORTAL_OFFSET, triggerRadius, 128, 128 )
	areaWaypointTrigger.RemoveFromAllRealms()
	areaWaypointTrigger.AddToOtherEntitysRealms( allyPortalRootEnt )
	areaWaypointTrigger.kv.triggerFilterNpc          = "none"
	areaWaypointTrigger.kv.triggerFilterPlayer       = "all"
	areaWaypointTrigger.kv.triggerFilterNonCharacter = 0

	areaWaypointTrigger.SetEnterCallback( WaypointTriggerEnter )
	areaWaypointTrigger.SetLeaveCallback( WaypointTriggerLeave )
	areaWaypointTrigger.SetOwner( allyPortalRootEnt )
	areaWaypointTrigger.SetParent( allyPortalRootEnt )
	SetTeam( areaWaypointTrigger, allyPortalRootEnt.GetTeam() )

	areaWaypointTrigger.SearchForNewTouchingEntity()
}

void function WaypointTriggerEnter( entity trigger, entity player )
{
	if ( !IsValid( player ) || !IsAlive( player ) || !player.IsPlayer() )
		return

	if ( player.e.isInPhaseTunnel )
		return

	if ( player.GetTeam() == trigger.GetTeam() )
		return

	thread WaypointLifetime_Thread( trigger, player )
}

void function WaypointTriggerLeave( entity trigger, entity player )
{
	if ( !IsValid( player ) )
		return

	player.Signal( TRANSPORT_PORTAL_LEAVE_WAYPOINT_TRIGGER_SIGNAL )
}

void function WaypointLifetime_Thread( entity trigger, entity player )
{
	Assert ( IsNewThread(), "Must be started as new thread" )
	entity allyPortalRootEnt = trigger.GetOwner()
	entity rootEnt = allyPortalRootEnt.GetOwner()

	if ( !IsValid( rootEnt ) )
		return

	entity wp = CreateWaypoint_ObjectiveEnt( rootEnt, "#TRANSPORT_PORTAL_CHASE_PORTAL_DESTINATION", <0,0,0>, TRANSPORT_PORTAL_RECEIVER_IMAGE )
	wp.SetOnlyTransmitToOnePlayer( player )

	EndSignal( player, "OnDeath", "OnDestroy", TRANSPORT_PORTAL_LEAVE_WAYPOINT_TRIGGER_SIGNAL )
	EndSignal( allyPortalRootEnt, "OnDestroy" )
	EndSignal( rootEnt, "OnDestroy" )

	OnThreadEnd(
		function() : ( wp )
		{
			wp.Destroy()
		}
	)

	WaitForever()
}
#endif

#if INTELLIJ_OUTLINE_SECTION_MARKER
void function _____________MiniMap___________________________(){}
#endif

#if CLIENT
const vector RING_COLOR = ALTER_PURPLE_COLOR/255
const float  RING_PLAYER_ALPHA = 1.0
const float  RING_SPECTATOR_ALPHA = 0.2

void function SetupMapRuiReceiverPreview( entity receiverProxy, var rui, bool isFullMap )
{
	RuiSetAsset( rui, "areaImage", $"rui/hud/character_abilities/transport_portal_map_circle" )
	RuiSetFloat( rui, "areaImageAlpha",
		GetLocalClientPlayer().GetTeam() == TEAM_SPECTATOR ? RING_SPECTATOR_ALPHA : RING_PLAYER_ALPHA )
	RuiSetImage( rui, "clampedImage", $"" )

	string areaColorArgName = "objColor"
	if ( !isFullMap )
	{
		RuiSetBool( rui, "useOverrideColor", true )
		areaColorArgName = "overrideColor"
	}
	RuiSetColorAlpha( rui, areaColorArgName, RING_COLOR, 1 )

	RuiSetImage( rui, "centerImage", TRANSPORT_PORTAL_RECEIVER_IMAGE )
	RuiSetFloat( rui, "objectRadius", tuning.maxUseDistance / 16384.0 )

	if ( IsValid( receiverProxy ) )
	{
		thread RecieverPreview_Thread( receiverProxy, rui, areaColorArgName )
	}
}

void function SetupMapRuiReceiver( entity receiver, var rui, bool isFullMap )
{
	RuiSetAsset( rui, "areaImage", $"rui/hud/character_abilities/transport_portal_map_circle" )
	RuiSetFloat( rui, "areaImageAlpha",
		GetLocalClientPlayer().GetTeam() == TEAM_SPECTATOR ? RING_SPECTATOR_ALPHA : RING_PLAYER_ALPHA )
	RuiSetImage( rui, "clampedImage", $"" )

	string areaColorArgName = "objColor"
	if ( !isFullMap )
	{
		RuiSetBool( rui, "useOverrideColor", true )
		areaColorArgName = "overrideColor"
	}
	RuiSetColorAlpha( rui, areaColorArgName, RING_COLOR, 1 )

	RuiSetImage( rui, "centerImage", $"" )
	RuiSetFloat( rui, "objectRadius", tuning.maxUseDistance / 16384.0 )

	if ( IsValid( receiver ) )
	{
		thread InRangeForMinimapRui_Thread( receiver, rui, areaColorArgName )
	}
}
void function SetupMapRuiTranslocator( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", TRANSPORT_PORTAL_RECEIVER_IMAGE )
	RuiSetImage( rui, "clampedDefaultIcon", TRANSPORT_PORTAL_RECEIVER_IMAGE )
	RuiSetBool( rui, "useTeamColor", false )
	RuiSetFloat( rui, "iconBlend", 0.0 )
}

void function SetupMapRuiChasePortal( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", TRANSPORT_PORTAL_PORTAL_ICON )
	RuiSetImage( rui, "clampedDefaultIcon", TRANSPORT_PORTAL_PORTAL_ICON )
	RuiSetBool( rui, "useTeamColor", false )
	RuiSetFloat( rui, "iconBlend", 0.0 )
}

void function InRangeForMinimapRui_Thread( entity receiver, var rui, string argName )
{
	EndSignal( receiver, "OnDestroy", "OnBeginDissolve" )

	while ( true )
	{
		entity player = GetLocalViewPlayer()
		bool playerInRing = false
		entity rootEnt = receiver.GetOwner()
		if ( IsValid( player ) && IsValid( rootEnt ) )
		{

		}
		//float v = 0.8 + 0.6 * sin( 1.15 * 2 * PI * Time() )
		vector colour = playerInRing ? <1,1,1> : <0.1, 0.1, 0.1>
		float alpha = playerInRing ? 1.0 : 0.1
		RuiSetColorAlpha( rui, argName, colour, alpha )
		WaitFrame()
	}
}

void function RecieverPreview_Thread( entity receiverProxy, var rui, string argName )
{
	EndSignal( receiverProxy, "OnDestroy" )

	while ( true )
	{
		vector receieverPos = receiverProxy.GetOrigin()
		bool posInNextRing = Cl_SURVIVAL_PosInSafeZone( receieverPos )
		bool posOutsideRing = !Cl_SURVIVAL_PosInsideDeathField( receieverPos )
		float blinkRate = posOutsideRing ? 2.5 : !posInNextRing ? 1.3 : 0.5
		float v = 0.8 + 0.6 * sin( blinkRate * 2 * PI * Time() )
		RuiSetColorAlpha( rui, argName, <v, v, v>, v )
		WaitFrame()
	}
}
#endif

      