global function MpWeaponTeslaTrap_Init
global function OnWeaponAttemptOffhandSwitch_weapon_tesla_trap
global function OnWeaponActivate_weapon_tesla_trap
global function OnWeaponDeactivate_weapon_tesla_trap
global function OnWeaponOwnerChanged_weapon_tesla_trap
global function OnWeaponPrimaryAttack_weapon_tesla_trap
global function CodeCallback_TeslaTrapCrossed

#if SERVER
global function AddTeslaTrapTriggeredCallback
global function TeslaTrap_MakeEntityRealTimeObstructor
global function TeslaTrap_AddEntityWirelineHitCallback
global function TeslaTrap_RemoveEntityWirelineHitCallback
global function TeslaTrap_CancelPlacement
global function WirelinePreviewEnabled
global function TeslaTrap_CreateWorldOwnedTrapsFromArrayOfPoints
#endif //SERVER

global function OnObjectPlacementCanPlace_weapon_tesla_trap

#if CLIENT
global function TeslaTrap_AreTrapsLinked
global function ClientCodeCallback_TeslaTrapLinked
global function ClientCodeCallback_TeslaTrapVisibilityChanged
global function RegisterTeslaTrapMinimapRui
global function TeslaTrap_OnPlayerTeamChanged
global function OnCreateClientOnlyModel_weapon_tesla_trap
#endif //CLIENT

const string TESLA_TRAP_WEAPON_NAME = "mp_weapon_tesla_trap"
global const string TESLA_TRAP_NAME = "tesla_trap"
const bool TESLA_TRAP_DAMAGE_DEBUG = false

//The max number of traps a player can have deployed at once.
const int TESLA_TRAP_MAX_TRAPS = 12

//TRAP FX VARS
const asset TESLA_TRAP_FX = $"P_wpn_arcTrap"
const asset TESLA_TRAP_IDLE_FX = $"P_arcTrap_light"
const asset TESLA_TRAP_START_FX = $"P_tesla_trap_start"
const asset TESLA_TRAP_ZAP_FX = $"P_tesla_trap_link_zap"
const asset TESLA_TRAP_LINK_FX = $"P_tesla_trap_link_CP"
const asset TESLA_TRAP_LINK_ENEMY_FX = $"P_tesla_trap_link_CP"
const asset TESLA_TRAP_DAMAGE_SPARK_FX = $"P_tesla_trap_dmg"
const asset TESLA_TRAP_DESTROY_FX = $"P_tesla_trap_exp"
const asset TESLA_TRAP_DESTROY_CLOSED_FX = $"P_tesla_trap_closed_exp"
const asset TESLA_TRAP_PLACE_FX = $"P_tesla_trap_place"
//const asset TESLA_TRAP_TAKE_DAMAGE_SMOKE_FX = $"sparks_dir_MD_CH_smoke"

#if CLIENT
const asset TESLA_TRAP_PLACE_RANGE_FX = $"P_tesla_trap_ar_place"
#endif //CLIENT

//TRAP SOUNDS
const string TESLA_TRAP_PLACEMENT_SOUND = "wattson_tactical_c"

const string TESLA_TRAP_ACTIVATE_SOUND = "wattson_tactical_d"
const string TESLA_TRAP_POLE_RISE_SOUND = "wattson_tactical_e"

const string TESLA_TRAP_LINK_ACTIVE_SOUND = "wattson_tactical_f"
const string TESLA_TRAP_LINK_SEGMENT_SOUND = "wattson_tactical_g" //HOOK UP!
const string TESLA_TRAP_LINK_POST_SOUND = "wattson_tactical_j" //HOOK UP!
const string TESLA_TRAP_LINK_LOOP_SOUND = "wattson_tactical_k"

const string TESLA_TRAP_LINK_OBSTRUCT_SOUND = "wattson_tactical_h"
const string TESLA_TRAP_LINK_RECONNECT_POST_SOUND = "wattson_tactical_i"
const string TESLA_TRAP_LINK_RECONNECT_POST_ENEMY_SOUND = "wattson_tactical_i_enemy"
const string TESLA_TRAP_LINK_RECONNECT_SEGMENT_SOUND = "wattson_tactical_g"

const string TESLA_TRAP_DISSOLVE_SOUND = "wattson_tactical_l"

const string TESLA_TRAP_LINK_DAMAGE_1P_SOUND = "wattson_tactical_m_1p"
const string TESLA_TRAP_LINK_DAMAGE_3P_SOUND = "wattson_tactical_m_3p"

const string TESLA_TRAP_POST_COLLAPSE_SOUND = "wattson_tactical_o"

const string TESLA_TRAP_DESTROY_SOUND = "wattson_tactical_p"
const string TESLA_TRAP_DAMAGE_SPARK_SOUND = "wattson_tactical_q"

//TRAP MODEL VARS
const asset TESLA_TRAP_MODEL = $"mdl/props/gibraltar_bubbleshield/gibraltar_bubbleshield.rmdl"
const asset TESLA_TRAP_PROXY_MODEL = $"mdl/props/wattson_electric_fence/wattson_electric_fence.rmdl"
const asset TESLA_TRAP_POLE_MODEL = $"mdl/props/pathfinder_zipline/pathfinder_zipline.rmdl"
const asset TESLA_TRAP_TRIGGER_RADIUS_MODEL = $"mdl/weapons_r5/weapon_tesla_trap/mp_weapon_tesla_trap_ar_trigger_radius.rmdl"

//TRAP SOUNDS
const string TESLA_TRAP_WARNING_SOUND = "weapon_vortex_gun_explosivewarningbeep"

//TRAP CANCEL VARS
const float TESLA_TRAP_CANCEL_DELAY = 0.1

//TRAP PLACEMENT VARS
const float TESLA_TRAP_PLACEMENT_RANGE_MAX_UPDATE = 300
const float TESLA_TRAP_PLACEMENT_RANGE_MIN = 0
const float TESLA_TRAP_PLACEMENT_SPACING_MIN = 64
const float TESLA_TRAP_PLACEMENT_SPACING_MIN_SQR = TESLA_TRAP_PLACEMENT_SPACING_MIN * TESLA_TRAP_PLACEMENT_SPACING_MIN
const vector TESLA_TRAP_BOUND_MINS = <-8, -8, 0>
const vector TESLA_TRAP_BOUND_MAXS = <8, 8, 16>
const vector TESLA_TRAP_PLACEMENT_TRACE_OFFSET_UPDATE = <0, 0, 256>
const float TESLA_TRAP_PLACEMENT_MAX_HEIGHT_DELTA = 8.0

//TRAP DEPLOY VARS
const float TESLA_TRAP_HEALTH = 25
const float TESLA_TRAP_ANGLE_LIMIT = 0.55
const float TESLA_TRAP_RADIUS = 256.0
const float TESLA_TRAP_DEPLOY_DELAY = 1.0

//TRAP MINE BEHAVIOR VARS
const float TESLA_TRAP_RISE_DURATION = 0.5
const float TESLA_TRAP_RISE_HEIGHT = 40.0
const float TESLA_TRAP_DROP_DURATION = 0.5
const float TESLA_TRAP_DURATION = 0.6
const float TESLA_TRAP_COOLDOWN = 6.0
const float TESLA_TRAP_REACTIVATE_DELAY = 0.4
const float TESLA_TRAP_CONE_HEIGHT_OFFSET = 24.0

//LINKED TRAP LINK VARS
const float TESLA_TRAP_LINK_HEIGHT = 24.0
const float TESLA_TRAP_LINK_DIST = 768.0//512.0
const float TESLA_TRAP_LINK_CANCEL_DIST = 1024.0
const float TESLA_TRAP_LINK_SNAP_DIST = 98.0
const float TESLA_TRAP_LINK_DIST_SQR = TESLA_TRAP_LINK_DIST * TESLA_TRAP_LINK_DIST
const int TESLA_TRAP_LINK_COUNT_MAX = 2
const int TESLA_TRAP_LINK_FX_COUNT = 4
const int TESLA_TRAP_LINK_FX_MIN = 3
const float TESLA_TRAP_LINK_MAX_DOT = 0.98
const float TESLA_TRAP_LINK_MIN_VIEW_RATING = 0.95
const float TESLA_TRAP_LINK_MAX_GROUND_DIST = 64.0
const float TESLA_TRAP_LINK_GROUND_CHECK_INTERVAL = 64.0
const int TESLA_TRAP_LINK_GROUND_CHECK_FAIL_COUNT = 2

//LINKED TRAP DAMAGE VARS
const int TESLA_TRAP_LINK_DAMAGE_AMOUNT_HEAVY_ARMOR = 250
const float TESLA_TRAP_LINK_DAMAGE_DIST_MIN = 16.0
const float TESLA_TRAP_LINK_DAMAGE_DIST_MIN_SQR = TESLA_TRAP_LINK_DAMAGE_DIST_MIN * TESLA_TRAP_LINK_DAMAGE_DIST_MIN
const float TESLA_TRAP_LINK_DAMAGE_DIST_MAX = 16.0
const float TESLA_TRAP_LINK_DAMAGE_DIST_MAX_SQR = TESLA_TRAP_LINK_DAMAGE_DIST_MAX * TESLA_TRAP_LINK_DAMAGE_DIST_MAX
const float TESLA_TRAP_LINK_DAMAGE_INTERVAL = 0.5
const float TESLA_TRAP_LINK_DAMAGE_INTERVAL_UPDATE = 1.0
const float TESLA_TRAP_LINK_DAMAGE_AMOUNT_UPDATE = 20
const float TESTLA_TRAP_EMP_DURATION_UPDATE = 3.0

//TRAP POLE POSE PARAMETERS
const float TESLA_TRAP_POSE_PARAMETER_HEIGHT_MAX = 5.0

//LINKED TRAP PING VARS
const float TESLA_TRAP_LINK_PING_INTERVAL = 3.0

//LINKED TRAP TRIGGER CONST VARS
const float TESLA_TRAP_LINK_TRIGGER_RADIUS = 96.0

//TRAP VO VARS
const float TESLA_TRAP_PING_VO_DBOUNCE = 6.0
const float TESLA_TRAP_LINK_VO_DBOUNCE = 3
const float TESLA_TRAP_PLACEMENT_END_VO_DBOUNCE = 15.0
const float TESLA_TRAP_CONSIDERED_FAR_DIST = 2953 //75m

//TRAP DEBUG DRAWING
const bool TESLA_TRAP_DEBUG_DRAW = false
const bool TESLA_TRAP_DEBUG_DRAW_LINKS = false
const bool TESLA_TRAP_DEBUG_DRAW_PRE_PLACEMENT = false
const bool TESLA_TRAP_DEBUG_DRAW_GROUND_CLAMP_PLACEMENT = false
const bool TESLA_TRAP_DEBUG_DRAW_GROUND_CLEARANCE = false
const bool TESLA_TRAP_DEBUG_DRAW_POST_INTERSECTION = false

const int TESLA_TRAP_TRACE_MASK = TRACE_MASK_SHOT & ~TRACE_MASK_WATER

enum eDeployLinkFlags
{
	DLF_NONE 			= 0,
	DLF_FAIL			= 1,
	DLF_CAN_LINK		= 2,
}

#if CLIENT
const float TESLA_TRAP_ICON_HEIGHT = 16.0
const bool TESLA_TRAP_DEBUG_DRAW_CLIENT_TRAP_LINKING = false
#endif //CLIENT

const asset TESLA_TRAP_ACTIVATED_ICON = $"rui/hud/tactical_icons/wattson_trap_enemy_collided"

struct TeslaTrapPlacementInfo
{
	entity 	connectionOwner
	vector 	origin
	vector 	angles
	entity 	parentTo
	entity 	snapTo
	entity 	forceLinkTo
	int 	beamCount = 0
	int 	deployLinkState = eDeployLinkFlags.DLF_NONE
	bool   	success = false
}

struct TeslaTrapPlayerPlacementData
{
	int    maxLinks        //The number of links the player specified when they placed the trap.
	vector viewOrigin    //The player's view origin when they placed the trap.
	vector viewForward    //The player's view forward when they placed the trap.
	vector playerOrigin //The player's world origin when they placed the trap.
	vector playerForward //The player's world forward when they placed the trap.

}

struct TeslaTrapSortingData
{
	entity trap
	float  sortingRating    //Sorting rating for last trap we tried to link with.
	float  distSqr            //Distance Squared for the last trap we tried to link with.
}

struct FramePlacementInfo
{
	float 	frameTime
	TeslaTrapPlacementInfo& placementInfo
}

#if SERVER
struct TeslaTrapLinkTriggerData
{
	int mainTrapID
	int otherTrapID
}

struct TeslaTrapLinkFXData
{
	int              numFXLinks
	//array<entity> 	linkFXs
	array<entity>    damageFXs
	entity           linkTrigger
	array<entity>    controlPoints
}

struct TeslaTrapData
{
	int                               id                                        //The unique ID for this trap.
	entity                            trap                                    //The trap entity
	array< int >                      linkedTrapIDs                                                //Array of traps linked to this trap.
	table< int, TeslaTrapLinkFXData > linkFXData                            //Table of id link FX data pairs for this trap.
	bool                              pickedUp = false                        //Flags whether this trap was picked up.
	int                               maxBeamCount                                //The maximum height this node is able to extend in terms of vertical connections.
}

struct TeslaTrapTimes
{
	float nextDamageTime 	= 0.0
	float nextPingTime		= 0.0
	float nextVOTime		= 0.0
}

#endif //SERVER

#if CLIENT
struct TrapMinimapData
{
	array<var> ruiArray
	array<entity> triggerArray
}
#endif //CLIENT

struct
{
	#if SERVER
		int                                        nextTrapId = 0
		array < void functionref( entity, var ) >  teslaTrapTriggerCallbacks = []
		table < int, TeslaTrapData >               trapData
		table < entity, int >                      activeTrapIds
		table < entity, TeslaTrapLinkTriggerData > linkTriggerData
		table < entity, float >                    weaponConfigured
		table < entity, bool >                     hasPlacedLinkedTrap
		int                                        realTimeObstructorArrayIndex
		int                                        scriptManagedTrapArrayID
		array < entity >						   scriptRegisteredObstructors
		table < entity, TeslaTrapTimes >		   trapTimes
		table < entity, array< void functionref ( entity ) > > entityWirelineHitCallback
		table < entity, bool >						playerPickupLocked
	#endif //SERVER

	table< entity, TeslaTrapSortingData > trapSortingData    //A shared table of sorting data
	table< entity, entity >               focalTrap
	FramePlacementInfo&					  framePlacementInfo

	entity 								  proxyEnt

	#if CLIENT
		array<entity>                       allTraps
		table< int, array< int > >          linkFXs_client
		table< int, entity >                linkAGs_client
		int                                 currentFXID = 0
		entity                              recalTrap
		table< entity, var >				trapRui
		table< entity, TrapMinimapData >    trapMinimapData
		float 								proxyBaseOffset = -1.0
	#endif //#if CLIENT

	//If a trap is placed on an ent that has a script name in this list, it will parent to the highest parent in the move hiarchy. This is so that multi-part movers like the loot tank allow wirelines to connect between all parts of the tank.
	array<string> parentToRoot = [
		"_hover_tank_interior"
	]

	//balance
	float balance_teslaTrapRange
	float balance_teslaTrapDamage
	bool balance_teslaTrapSelfRepair
} file



void function MpWeaponTeslaTrap_Init()
{
	PrecacheParticleSystem( TESLA_TRAP_FX )
	PrecacheParticleSystem( TESLA_TRAP_START_FX )
	PrecacheParticleSystem( TESLA_TRAP_IDLE_FX )
	PrecacheParticleSystem( TESLA_TRAP_ZAP_FX )
	PrecacheParticleSystem( TESLA_TRAP_LINK_FX )
	PrecacheParticleSystem( TESLA_TRAP_LINK_ENEMY_FX )
	PrecacheParticleSystem( TESLA_TRAP_DAMAGE_SPARK_FX )
	PrecacheParticleSystem( TESLA_TRAP_DESTROY_FX )
	PrecacheParticleSystem( TESLA_TRAP_DESTROY_CLOSED_FX )
	PrecacheParticleSystem( TESLA_TRAP_PLACE_FX )
	
	PrecacheScriptString( TESLA_TRAP_NAME )
	PrecacheScriptString( "tesla_trap_dead" )

	PrecacheModel( TESLA_TRAP_MODEL )
	PrecacheModel( TESLA_TRAP_PROXY_MODEL )
	PrecacheModel( TESLA_TRAP_POLE_MODEL )
	PrecacheModel( TESLA_TRAP_TRIGGER_RADIUS_MODEL )

	#if SERVER
		file.scriptManagedTrapArrayID = CreateScriptManagedEntArray()
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_tesla_trap, TeslaTrap_DamagedTarget )
		AddCallback_OnClientConnected( TeslaTrap_OnPlayerConnected )
		AddCallback_OnClientDisconnected( TeslaTrap_OnPlayerDisconnected )
		SurvivalLoot_AddCallback_OnPlayerBackpackOpened( TeslaTrap_CancelPlacement )
		RegisterSignal( "TeslaTrap_Activate" )
		RegisterSignal( "TeslaTrap_Deploy" )
		RegisterSignal( "TeslaTrap_Linked" )
		RegisterSignal( "TeslaTrap_Unlinked" )
		RegisterSignal( "TeslaTrap_PickedUp" )
		RegisterSignal( "TeslaTrap_LinkObstructed" )
		RegisterSignal( "TeslaTrap_DamageFXStop" )

		AddSpawnCallback( "prop_script", TeslaTrap_OnPropScriptSpawned )
		RegisterDynamicEntCleanupItem_Parented_Scriptname( TESLA_TRAP_NAME )
		RegisterDynamicEntCleanupItem_Area_Scriptname( TESLA_TRAP_NAME )

		file.realTimeObstructorArrayIndex = CreateScriptManagedEntArray()

		AddCallback_GameStateEnter( eGameState.WinnerDetermined, TeslaTrap_OnWinnerDetermined )
	#endif //SERVER

	#if CLIENT
		PrecacheParticleSystem( TESLA_TRAP_PLACE_RANGE_FX )
		AddCreateCallback( "prop_script", TeslaTrap_OnPropScriptCreated )
		AddDestroyCallback( "prop_script", TeslaTrap_OnPropScriptDestroyed )

		AddCreateCallback( "trigger_cylinder_heavy", TeslaTrap_OntriggerCreated )
		AddDestroyCallback( "trigger_cylinder_heavy", TeslaTrap_OntriggerDestroyed )

		RegisterSignal( "TeslaTrap_StopFocalTrapUpdate" )
		RegisterSignal( "TeslaTrap_StopFocalTrapCancelUpdate" )
		RegisterSignal( "TeslaTrap_StopPlacementProxy" )
		RegisterSignal( "TeslaTrap_StopHudIconUpdate" )

		RegisterNetVarEntityChangeCallback( "focalTrap", OnFocusTrapChanged )

		AddCallback_PlayerClassActuallyChanged( TeslaTrap_OnPlayerClassChanged )
		AddCallback_OnPlayerChangedTeam( TeslaTrap_OnPlayerTeamChanged )
		AddCallback_MinimapEntShouldCreateCheck_Scriptname( TESLA_TRAP_NAME, Minimap_DontCreateRuisForEnemies )
		AddCallback_ModifyDamageFlyoutForScriptName( TESLA_TRAP_NAME, OnModifyDamageFlyout )
		RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.ARC_TRAP, MINIMAP_ARC_TRAP_RUI, RegisterTeslaTrapMinimapRui, $"ui/in_world_minimap_tesla_trap.rpak", RegisterTeslaTrapMinimapRui )

                          
                                                
   
                                                       
                                                       
   
        
	#endif //CLIENT

	//balance
	file.balance_teslaTrapRange	= GetCurrentPlaylistVarFloat( "tesla_trap_range_override", TESLA_TRAP_PLACEMENT_RANGE_MAX_UPDATE )
	file.balance_teslaTrapSelfRepair = GetCurrentPlaylistVarBool( "tesla_trap_self_repair_override", false )
	file.balance_teslaTrapDamage = GetCurrentPlaylistVarFloat("tesla_trap_damage_override", TESLA_TRAP_LINK_DAMAGE_AMOUNT_UPDATE)
}

#if SERVER
void function TeslaTrap_MakeEntityRealTimeObstructor( entity ent )
{
	AddToScriptManagedEntArray( file.realTimeObstructorArrayIndex, ent )
}

void function TeslaTrap_OnPlayerConnected( entity player )
{
	file.hasPlacedLinkedTrap[ player ] <- false
}

void function TeslaTrap_OnPlayerDisconnected( entity player )
{
	//	delete file.hasPlacedLinkedTrap[ player ]

	if ( player in file.trapTimes )
		delete file.trapTimes[player]
}
#endif //SERVER

#if CLIENT
void function TeslaTrap_OnPlayerClassChanged( entity player )
{
	entity localViewPlayer = GetLocalViewPlayer()
	entity localClientPlayer = GetLocalClientPlayer()
	bool playerIsLocalViewPlayer = (player == localViewPlayer)

	if ( playerIsLocalViewPlayer )
	{
		player.Signal( "TeslaTrap_StopFocalTrapUpdate" )
		player.Signal( "TeslaTrap_StopHudIconUpdate" )
	}
}
#endif //CLIENT

void function OnWeaponActivate_weapon_tesla_trap( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )
	#if CLIENT
		ownerPlayer.Signal( "TeslaTrap_StopFocalTrapUpdate" )

		//Auto Cancel if the player gets too far away.
		thread TeslaTrap_MaxDistanceAutoCancelUpdate( ownerPlayer )
	#endif

	#if SERVER
		if ( ownerPlayer in file.hasPlacedLinkedTrap )
			file.hasPlacedLinkedTrap[ ownerPlayer ] = false

		TeslaTrap_SetPlacementMaxLinksToDefault( weapon )
		file.weaponConfigured[ weapon ] <- Time() + TESLA_TRAP_CANCEL_DELAY

		//TO DO: LOCK FOCAL TRAP ON SERVER.

		//printt( "ADDING CANCEL CALLBACKS" )
		AddButtonPressedPlayerInputCallback( ownerPlayer, IN_ZOOM, TeslaTrap_AttemptRemotePickup )
		AddButtonPressedPlayerInputCallback( ownerPlayer, IN_ZOOM_TOGGLE, TeslaTrap_AttemptRemotePickup )
		AddButtonReleasedPlayerInputCallback( ownerPlayer, IN_ZOOM, TeslaTrap_ReleasePickup )
		AddButtonReleasedPlayerInputCallback( ownerPlayer, IN_ZOOM_TOGGLE, TeslaTrap_ReleasePickup )

	#endif
}

void function OnWeaponDeactivate_weapon_tesla_trap( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )
	#if CLIENT
		thread TeslaTrap_TrackFocalTrapForPlayer( ownerPlayer )
		ownerPlayer.Signal( "TeslaTrap_StopFocalTrapCancelUpdate" )
	#endif //CLIENT

	#if SERVER
		//printt( "REMOVING CANCEL CALLBACKS" )
		//Set weapon back to extend mode.
		if ( ownerPlayer in file.hasPlacedLinkedTrap )
		{
			if ( file.hasPlacedLinkedTrap[ ownerPlayer ] && IsAlive( ownerPlayer ) )
			{
				if ( ownerPlayer.p.lastTacticalStowedVOTime + TESLA_TRAP_PLACEMENT_END_VO_DBOUNCE <= Time() )
				{
					ownerPlayer.p.lastTacticalStowedVOTime = Time()
					PlayBattleChatterLineToSpeakerAndTeam( ownerPlayer, "bc_wattson_tacticalDone" )
				}
			}

			file.hasPlacedLinkedTrap[ ownerPlayer ] = false
		}

		// release pending recal pickups since we are removing the release callback
		TeslaTrap_ReleasePickup( ownerPlayer )

		TeslaTrap_SetPlacementMaxLinksToDefault( weapon )
		TeslaTrap_RemoveDoubleLinkMode( weapon )
		TeslaTrap_ClearFocalTrapForPlayer( ownerPlayer )
		RemoveButtonPressedPlayerInputCallback( ownerPlayer, IN_ZOOM, TeslaTrap_AttemptRemotePickup )
		RemoveButtonPressedPlayerInputCallback( ownerPlayer, IN_ZOOM_TOGGLE, TeslaTrap_AttemptRemotePickup )
		RemoveButtonReleasedPlayerInputCallback( ownerPlayer, IN_ZOOM, TeslaTrap_ReleasePickup )
		RemoveButtonReleasedPlayerInputCallback( ownerPlayer, IN_ZOOM_TOGGLE, TeslaTrap_ReleasePickup )

	#endif //SERVER
}

void function OnWeaponOwnerChanged_weapon_tesla_trap( entity weapon, WeaponOwnerChangedParams changeParams )
{
	if ( IsValid( changeParams.oldOwner ) && changeParams.oldOwner in file.focalTrap )
		delete file.focalTrap[ changeParams.oldOwner ]

	#if CLIENT
		if ( IsValid( changeParams.oldOwner ) && IsValid( changeParams.newOwner ) )
		{
			changeParams.oldOwner.Signal( "TeslaTrap_StopFocalTrapUpdate" )
			changeParams.oldOwner.Signal( "TeslaTrap_StopHudIconUpdate" )
		}

		if ( IsValid( changeParams.newOwner ) && changeParams.newOwner == GetLocalViewPlayer() )
		{
			thread TeslaTrap_TrackFocalTrapForPlayer( changeParams.newOwner )
			thread TeslaTrap_UpdateHudMarkers( changeParams.newOwner )
		}
	#endif //CLIENT
}

bool function OnWeaponAttemptOffhandSwitch_weapon_tesla_trap( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	asset model  = TESLA_TRAP_PROXY_MODEL
	entity proxy = TeslaTrap_CreateTrapPlacementProxy( model )

	TeslaTrap_UpdateFocalNodeForPlayer( player, proxy )

	if ( weapon == player.GetActiveWeapon( eActiveInventorySlot.mainHand ) )
		return true

	//Don't allow player to attempt to place new traps if they have no ammo and nothing to extend from.
	if ( !TeslaTrap_PlayerHasFocalTrap( player ) )
	{
		int ammoReq  = weapon.GetAmmoPerShot()
		int currAmmo = weapon.GetWeaponPrimaryClipCount()
		if ( currAmmo < ammoReq )
			return false
	}

#if SERVER
	if ( ( weapon in file.weaponConfigured ) )
	{
		if ( file.weaponConfigured[ weapon ] > Time() )
		{
			file.weaponConfigured[ weapon ] = Time() + TESLA_TRAP_CANCEL_DELAY
			return false
		}
		else
		{
			file.weaponConfigured[ weapon ] = Time() + TESLA_TRAP_CANCEL_DELAY
		}
	}
#endif //SERVER

	#if CLIENT
		player.Signal( "TeslaTrap_StopFocalTrapUpdate" )
	#endif //CLIENT

	return true
}

var function OnWeaponPrimaryAttack_weapon_tesla_trap( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	asset model = TESLA_TRAP_PROXY_MODEL

	entity proxy = TeslaTrap_CreateTrapPlacementProxy( model )
	TeslaTrapPlacementInfo placementInfo

	placementInfo = TeslaTrap_GetObjectPlacementInfo( ownerPlayer, weapon )
	TeslaTrap_PlacementInfoScriptChecks( ownerPlayer, placementInfo )

	if ( !placementInfo.success )
		return 0

	//Don't allow player to place traps without ammon unless they are snapping.
	int ammoReq  = weapon.GetAmmoPerShot()
	int currAmmo = weapon.GetWeaponPrimaryClipCount()
	if ( currAmmo < ammoReq && !IsValid( placementInfo.snapTo ) )
	{
		#if CLIENT
			printf( "mp_weapon_tesla_trap: No more ammo before placing trap. Switching out with 'invnext'." )
			ownerPlayer.ClientCommand( "invnext" )
		#endif //CLIENT

		return 0
	}

	#if SERVER
		//If the player is picking up a trap this frame don't fire.
		if ( ownerPlayer in  file.playerPickupLocked )
			return 0

		TeslaTrapPlayerPlacementData placementData
		placementData.maxLinks = TeslaTrap_GetPlacementMaxLinks( ownerPlayer )
		placementData.viewOrigin = ownerPlayer.EyePosition()
		placementData.viewForward = ownerPlayer.GetViewForward()
		placementData.playerOrigin = ownerPlayer.GetOrigin()
		placementData.playerForward = FlattenVec( ownerPlayer.GetViewForward() )

		if ( IsValid( placementInfo.snapTo ) && TeslaTrap_PlayerHasFocalTrap( ownerPlayer ) )
		{
			entity focalTrap        = TeslaTrap_GetFocalTrapForPlayer( ownerPlayer )
			int id                  = file.activeTrapIds[ focalTrap ]
			int otherID             = file.activeTrapIds[ placementInfo.snapTo ]
			TeslaTrapData trapData  = file.trapData[ id ]
			TeslaTrapData otherData = file.trapData[ otherID ]

			//Make sure the player linking the nodes owns the connection.
			if ( trapData.trap.GetTeam() == ownerPlayer.GetTeam() )
				TeslaTrap_AttemptTrapLink( trapData, otherData, placementInfo )
			else
				TeslaTrap_AttemptTrapLink( otherData, trapData, placementInfo )

			weapon.StartCustomActivity( "ACT_VM_SECONDARYATTACK", WCAF_NONE )
		}
		else
			thread TeslaTrap_Deploy( ownerPlayer, placementInfo )

		//Set Tesla Trap Back To Extend Mode.
		TeslaTrap_SetPlacementMaxLinksToExtend( weapon )
		TeslaTrap_RemoveDoubleLinkMode( weapon )
	#endif

	PlayerUsedOffhand( ownerPlayer, weapon, true, null, {pos = placementInfo.origin} )

	if ( IsValid( placementInfo.snapTo ) )
	{
		#if CLIENT
			if ( currAmmo < ammoReq )
			{
				printf( "mp_weapon_tesla_trap: No more ammo after placing trap. Switching out with 'invnext'." )
				ownerPlayer.ClientCommand( "invnext" )
			}
		#endif //CLIENT

		return 0
	}

	else
		return  weapon.GetAmmoPerShot()
}

/*
 ____  _        _    ____ _____ __  __ _____ _   _ _____   _____ _   _ _   _  ____ _____ ___ ___  _   _ ____
|  _ \| |      / \  / ___| ____|  \/  | ____| \ | |_   _| |  ___| | | | \ | |/ ___|_   _|_ _/ _ \| \ | / ___|
| |_) | |     / _ \| |   |  _| | |\/| |  _| |  \| | | |   | |_  | | | |  \| | |     | |  | | | | |  \| \___ \
|  __/| |___ / ___ \ |___| |___| |  | | |___| |\  | | |   |  _| | |_| | |\  | |___  | |  | | |_| | |\  |___) |
|_|   |_____/_/   \_\____|_____|_|  |_|_____|_| \_| |_|   |_|    \___/|_| \_|\____| |_| |___\___/|_| \_|____/

*/

TeslaTrapPlacementInfo function TeslaTrap_GetObjectPlacementInfo( entity player, entity weapon )
{
	TeslaTrapPlacementInfo placementInfo
	placementInfo.connectionOwner = player
	//placementInfo.success = weapon.ObjectPlacementHasValidSpot()
	//placementInfo.origin = weapon.GetObjectPlacementOrigin()
	//placementInfo.angles = weapon.GetObjectPlacementAngles()
	//placementInfo.parentTo = weapon.GetObjectPlacementParent()
	
	return placementInfo
}

void function TeslaTrap_PlacementInfoScriptChecks( entity player, TeslaTrapPlacementInfo placementInfo )
{
	//See if we can snap to any neighboring nodes.
	bool canSnap = TelsaTrap_AttemptSnapToNeighbor( player, placementInfo.origin, placementInfo )

	//If node cannot link to current focal point node and we are not snaping placement fails.
	if ( TeslaTrap_PlayerHasFocalTrap( player ) && !canSnap )
	{
		//Reset this as it might have been set in TelsaTrap_AttemptSnapToNeighbor
		placementInfo.deployLinkState = eDeployLinkFlags.DLF_NONE

		entity focalTrap = TeslaTrap_GetFocalTrapForPlayer( player )
		if ( !TeslaTrap_CanLink_ObjectPlacer( placementInfo.origin, AnglesToUp( placementInfo.angles ), focalTrap, placementInfo ) )
		{
			placementInfo.success = false
			placementInfo.deployLinkState = eDeployLinkFlags.DLF_FAIL
		}
	}
}

TeslaTrapPlacementInfo function TeslaTrap_ValidateObjectPlacerModel( entity player, entity proxy, entity weapon, bool ignorePlacedTraps = false )
{
	if ( IsValid( file.framePlacementInfo ) )
	{
		if ( file.framePlacementInfo.frameTime == Time() )
			return file.framePlacementInfo.placementInfo
	}

	TeslaTrapPlacementInfo placementInfo = TeslaTrap_GetPlacementInfoFromTraceResults_New( player, proxy, weapon )

	//If node cannot link to current focal point node, placement fails.
	if ( placementInfo.success && TeslaTrap_PlayerHasFocalTrap( player ) && !IsValid( placementInfo.snapTo ) )
	{
		entity focalTrap = TeslaTrap_GetFocalTrapForPlayer( player )
		if ( !TeslaTrap_CanDeploy( proxy, placementInfo.origin, AnglesToUp( placementInfo.angles ), focalTrap, placementInfo ) )
			placementInfo.success = false
	}

	//Create a backup of these results with a time stamp so that if we run this function again this frame we can return the existing results.
	FramePlacementInfo framePlacementInfo
	framePlacementInfo.frameTime = Time()
	framePlacementInfo.placementInfo = placementInfo
	file.framePlacementInfo = framePlacementInfo

	return placementInfo
}

TeslaTrapPlacementInfo function TeslaTrap_GetPlacementInfoFromTraceResults_New( entity player, entity proxy, entity weapon )
{
	vector placementPosition = <0,0,0>
	vector placementAngles = <0,0,0>
	entity placementParent = weapon.GetParent()
	bool success = false//weapon.ObjectPlacementHasValidSpot()

	if ( success && IsOriginInvalidForPlacingPermanentOnto( placementPosition, proxy ) )
		success = false

	TeslaTrapPlacementInfo placementInfo
	placementInfo.connectionOwner = player
	placementInfo.success = success
	placementInfo.origin = placementPosition
	placementInfo.angles = placementAngles
	placementInfo.parentTo = placementParent

	//See if we can snap to any neighboring nodes.
	bool canSnap = TelsaTrap_AttemptSnapToNeighbor( player, placementPosition, placementInfo )

	//If node cannot link to current focal point node and we are not snaping placement fails.
	if ( success && TeslaTrap_PlayerHasFocalTrap( player ) && !canSnap )
	{
		entity focalTrap = TeslaTrap_GetFocalTrapForPlayer( player )
		if ( !TeslaTrap_CanLink( proxy, placementInfo.origin, AnglesToUp( placementInfo.angles ), focalTrap, placementInfo ) )
		{
			placementInfo.success = false
			placementInfo.deployLinkState = eDeployLinkFlags.DLF_FAIL
		}
	}

	return placementInfo
}

TeslaTrapPlacementInfo function TeslaTrap_GetPlacementInfo( entity player, entity proxy, bool ignorePlacedTraps = false, int maxFallbacks = 3 )
{
	if ( IsValid( file.framePlacementInfo ) )
	{
		if ( file.framePlacementInfo.frameTime == Time() )
			return file.framePlacementInfo.placementInfo
	}

	vector eyePos  = player.EyePosition()
	vector viewVec = player.GetViewVector()
	vector angles  = < 0, VectorToAngles( viewVec ).y, 0 >
	float maxRange = file.balance_teslaTrapRange
	vector traceOffset = TESLA_TRAP_PLACEMENT_TRACE_OFFSET_UPDATE

	//Contstruct Ignore Ents Array
	array<entity> ignoreEnts = TeslaTrap_GetAllDead()
	ignoreEnts.extend( GetFriendlySquadArrayForPlayer_AliveConnected( player ) )
	ignoreEnts.append( player )
	ignoreEnts.append( proxy )

	if ( ignorePlacedTraps )
		ignoreEnts.extend( TeslaTrap_GetAll() )

	TraceResults viewTraceResults = TraceLine( eyePos, eyePos + player.GetViewVector() * (file.balance_teslaTrapRange * 2), ignoreEnts, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE, player )
	if ( viewTraceResults.fraction < 1.0 )
	{
		float slope = fabs( viewTraceResults.surfaceNormal.x ) + fabs( viewTraceResults.surfaceNormal.y )
		if ( slope < TESLA_TRAP_ANGLE_LIMIT )
			maxRange = min( Distance( eyePos, viewTraceResults.endPos ), file.balance_teslaTrapRange )
	}

	//Two Hull Traces, One Establishes Forward Bound, Second Establishes Ground Position From Forward Bound.
	vector idealPos          = player.GetOrigin() + (AnglesToForward( angles ) * file.balance_teslaTrapRange)
	TraceResults fwdResults  = TraceHull( eyePos + viewVec * min( TESLA_TRAP_PLACEMENT_RANGE_MIN, maxRange ), eyePos + viewVec * maxRange, TESLA_TRAP_BOUND_MINS, TESLA_TRAP_BOUND_MAXS, ignoreEnts, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE, <0, 0, 1>, player )
	TraceResults downResults = TraceHull( fwdResults.endPos, fwdResults.endPos - traceOffset, TESLA_TRAP_BOUND_MINS, TESLA_TRAP_BOUND_MAXS, ignoreEnts, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE, <0, 0, 1>, player )
	TraceResults upResults

	vector upStart	= ( fwdResults.endPos + viewVec * 20.0 ) + <0, 0, 32.0>
	vector upEnd	= upStart - <0, 0, 44.0>
	upResults = TraceHull( upStart, upEnd, TESLA_TRAP_BOUND_MINS, TESLA_TRAP_BOUND_MAXS, ignoreEnts, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE, <0, 0, 1>, player )

	vector roofTraceStart = eyePos //<eyePos.x, eyePos.y, upResults.endPos.z> //eyePos
	vector roofTraceEnd = ( upResults.endPos + <0, 0, 12.0> ) - ( <viewVec.x, viewVec.y, 0> * 4.0 )  //<eyePos.x, eyePos.y, upResults.endPos.z> + ( <viewVec.x, viewVec.y, 0> * 60.0 ) //upResults.endPos
	TraceResults roofTraceResults = TraceLine( roofTraceStart, roofTraceEnd, ignoreEnts, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE, player )
	if ( roofTraceResults.fraction < 1.0 )
	{
		upResults = downResults
	}

	if ( TESLA_TRAP_DEBUG_DRAW_PRE_PLACEMENT )
	{
		DebugDrawBox( fwdResults.endPos, TESLA_TRAP_BOUND_MINS, TESLA_TRAP_BOUND_MAXS, int( COLOR_GREEN.x ), int( COLOR_GREEN.y ), int( COLOR_GREEN.z ), 1, 0.1 ) //Forward Hull Cast Bounding Box
		DebugDrawBox( downResults.endPos, TESLA_TRAP_BOUND_MINS, TESLA_TRAP_BOUND_MAXS, int( COLOR_BLUE.x ), int( COLOR_BLUE.y ), int( COLOR_BLUE.z ), 1, 0.1 ) //Downward Hull Cast Bounding Box
		DebugDrawLine( eyePos + viewVec * min( TESLA_TRAP_PLACEMENT_RANGE_MIN, maxRange ), fwdResults.endPos, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 0.1 ) //Forward Hull Cast
		DebugDrawLine( fwdResults.endPos, eyePos + viewVec * maxRange, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 0.1 ) //Forward Hull Cast Blocked
		DebugDrawLine( fwdResults.endPos, downResults.endPos, int(COLOR_BLUE.x), int(COLOR_BLUE.y), int(COLOR_BLUE.z), true, 0.1 ) //Downward Hull Cast
		DebugDrawBox( upResults.endPos, TESLA_TRAP_BOUND_MINS, TESLA_TRAP_BOUND_MAXS, int( COLOR_CYAN.x ), int( COLOR_CYAN.y ), int( COLOR_CYAN.z ), 1, 0.1 ) //"Upward"" Hull Cast Bounding Box
		DebugDrawLine( upStart, upResults.endPos, int(COLOR_CYAN.x), int(COLOR_CYAN.y), int(COLOR_CYAN.z), true, 0.1 ) //"Upward" Hull Cast
		DebugDrawLine( roofTraceStart, roofTraceEnd, int(COLOR_MAGENTA.x), int(COLOR_MAGENTA.y), int(COLOR_MAGENTA.z), true, 0.1 ) //Roof Check
		DebugDrawLine( player.GetOrigin(), player.GetOrigin() + (AnglesToForward( angles ) * file.balance_teslaTrapRange), int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 0.1 ) //Max Placement Dist
		DebugDrawLine( eyePos + <0, 0, 8>, eyePos + <0, 0, 8> + (viewVec * file.balance_teslaTrapRange), int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 0.1 ) //Max Placement Dist

		DebugDrawLine( eyePos + <0, 0, 4>, viewTraceResults.endPos + <0, 0, 4>, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 0.1 ) //Max Placement Dist Adjusted
	}

	TeslaTrapPlacementInfo placementInfo = TeslaTrap_GetPlacementInfoFromTraceResults( player, proxy, downResults, upResults, viewTraceResults, ignoreEnts, idealPos )

	//Reattempt with fall back positions to give us better placement accuracy (This is Expensive!!!)
	int attempts       = 0
	vector fallbackPos = fwdResults.endPos
	while ( !placementInfo.success && attempts < maxFallbacks )
	{
		//printt( "TRYING TO USE FALLBACK POSITION" )
		//vector fallbackPos = fwdResults.endPos - ( viewVec * Length( TESLA_TRAP_BOUND_MINS ) )
		fallbackPos = fallbackPos - (viewVec * (Length( TESLA_TRAP_BOUND_MINS )))
		TraceResults downFallbackResults = TraceHull( fallbackPos, fallbackPos - traceOffset, TESLA_TRAP_BOUND_MINS, TESLA_TRAP_BOUND_MAXS, ignoreEnts, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )

		if ( TESLA_TRAP_DEBUG_DRAW_PRE_PLACEMENT )
		{
			DebugDrawBox( downFallbackResults.endPos, TESLA_TRAP_BOUND_MINS, TESLA_TRAP_BOUND_MAXS, int( COLOR_RED.x ), int( COLOR_RED.y ), int( COLOR_RED.z ), 1, 0.1 ) //Downward Fallback Hull Cast Bounding Box
		}

		placementInfo = TeslaTrap_GetPlacementInfoFromTraceResults( player, proxy, downFallbackResults, upResults, viewTraceResults, ignoreEnts, idealPos )
		attempts++
	}

	//If node cannot link to current focal point node, placement fails.
	if ( placementInfo.success && TeslaTrap_PlayerHasFocalTrap( player ) && !IsValid( placementInfo.snapTo ) )
	{
		entity focalTrap = TeslaTrap_GetFocalTrapForPlayer( player )
		if ( !TeslaTrap_CanDeploy( proxy, placementInfo.origin, AnglesToUp( placementInfo.angles ), focalTrap, placementInfo ) )
			placementInfo.success = false
	}

	//Create a backup of these results with a time stamp so that if we run this function again this frame we can return the existing results.
	FramePlacementInfo framePlacementInfo
	framePlacementInfo.frameTime = Time()
	framePlacementInfo.placementInfo = placementInfo
	file.framePlacementInfo = framePlacementInfo

	return placementInfo
}

TeslaTrapPlacementInfo function TeslaTrap_GetPlacementInfoFromTraceResults( entity player, entity proxy, TraceResults hullTraceResults, TraceResults ornull upTraceResults, TraceResults viewTraceResults, array<entity> ignoreEnts, vector idealPos )
{
	vector viewVec = player.GetViewVector()
	vector angles  = < 0, VectorToAngles( viewVec ).y, 0 >

	//PrintTraceResults( clearanceTraceResults )
	//PrintTraceResults( hullTraceResults )

	bool isScriptedPlaceable = false
	bool isUpTraced = false

	if ( upTraceResults != null )
	{
		TraceResults upTr = expect TraceResults( upTraceResults )
		if ( IsValid( upTr.hitEnt ) )
			isScriptedPlaceable = Placement_IsHitEntScriptedPlaceable( upTr.hitEnt, 1 )

		if ( !upTr.startSolid && upTr.fraction < 1.0 && (upTr.hitEnt.IsWorld() || isScriptedPlaceable) )
		{
			hullTraceResults = upTr
			isUpTraced = true
		}
	}
	//Handle placement of prop_scripts that support placeables.
	if ( !isUpTraced && IsValid( hullTraceResults.hitEnt ) )
		isScriptedPlaceable = Placement_IsHitEntScriptedPlaceable( hullTraceResults.hitEnt, 1 )

	bool success = isUpTraced || ( !hullTraceResults.startSolid && hullTraceResults.fraction < 1.0 && (hullTraceResults.hitEnt.IsWorld() || isScriptedPlaceable) )


	entity parentTo
	if ( IsValid( hullTraceResults.hitEnt ) && (hullTraceResults.hitEnt.GetNetworkedClassName() == "func_brush" || hullTraceResults.hitEnt.GetNetworkedClassName() == "script_mover" || hullTraceResults.hitEnt.GetNetworkedClassName() == "func_brush_lightweight") )
	{
		parentTo = hullTraceResults.hitEnt

		if ( file.parentToRoot.contains( parentTo.GetScriptName() ) )
		{
			entity parentAbove = parentTo.GetParent()
			//int count = 0
			while ( IsValid( parentAbove ) )
			{
				//printt( "PARENT ABOVE: " + parentAbove )
				parentTo = parentAbove
				parentAbove = parentTo.GetParent()
				//count++
			}

			//printt( "ITTERATION COUNT: " + count )
		}
	}

	if ( IsValid( hullTraceResults.hitEnt ) && IsEntInvalidForPlacingPermanentOnto( hullTraceResults.hitEnt ) )
		success = false

	//Limit the surface angle of the trap. It cannot be placed if the angle is too steep.
	vector surfaceAngles = angles
	vector proxyTestPos = <0, 0, 0>
	vector proxyTestAngles = <0, 0, 0>

	//Do a trace from the center of node to see if the center is to far from the surface.
	if ( success )
	{
		#if CLIENT
			proxy.SetOrigin( hullTraceResults.endPos )
			proxy.SetAngles( surfaceAngles )
		#endif

		proxyTestPos = hullTraceResults.endPos
		proxyTestAngles = surfaceAngles
	}

	//If we did not hit a valid surface.
	if ( success && hullTraceResults.hitEnt != null && (!hullTraceResults.hitEnt.IsWorld() && !isScriptedPlaceable) )
	{
		//printt( "PLACEMENT FAILED: PLAYER DID NOT HIT VALID ENT!!!" )
		surfaceAngles = angles
		success = false
	}

	//Just to stop players from putting placeable through thin walls
	//One Trace
	//vector canReachCheckEndPos = isUpTraced ? ( ( hullTraceResults.endPos + <0, 0, 12.0> ) - ( <viewVec.x, viewVec.y, 0> * 4.0 ) ) : hullTraceResults.endPos
	if ( !isUpTraced )
	{
		if ( success && !TeslaTrap_PlayerReachPos( player, player.EyePosition(), hullTraceResults.endPos, true, 90, ignoreEnts ) )
		{
			//	printt( "PLACEMENT FAILED: PLAYER CAN'T REACH POSITION!!!" )
			surfaceAngles = angles
			success = false
		}
	}

	//Get the most upright normal from a set of trace normals
	vector surfaceNormals = <0, 0, 0>
	if ( success && hullTraceResults.fraction < 1.0 )
	{
		vector up      	= hullTraceResults.surfaceNormal
		vector forward 	= CrossProduct( up, <1, 0, 0> )
		vector right 	= CrossProduct( forward, up )

		float length = Length( TESLA_TRAP_BOUND_MINS )

		//FIVE TRACES!!!
		array< vector > groundTestOffsets = [
			<0, 0, 0>,
							(-right * 6) + (forward * 6),
							(-right * 6) + (-forward * 6),
							(right * 6) + (forward * 6),
							(right * 6) + (-forward * 6),
		]

		//printt( "" )

		surfaceAngles = <0, 0, 0>
		vector testNormal = <0, 0, 1>
		vector bestNormal = <0, 0, -1>
		float bestDot     = -1.0
		foreach ( int i, vector testOffset in groundTestOffsets )
		{
			vector testPos           = proxyTestPos + testOffset
			TraceResults traceResult = TraceLine( testPos + (up * TESLA_TRAP_PLACEMENT_MAX_HEIGHT_DELTA), testPos + (up * -TESLA_TRAP_PLACEMENT_MAX_HEIGHT_DELTA), ignoreEnts, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE, player )

			if ( TESLA_TRAP_DEBUG_DRAW_GROUND_CLAMP_PLACEMENT )
			{
				DebugDrawLine( testPos, traceResult.endPos, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 0.05 )
			}

			float dot = DotProduct( testNormal, traceResult.surfaceNormal )
			//printt( dot )

			if ( dot >= bestDot )
			{
				bestDot = dot
				bestNormal = traceResult.surfaceNormal

				if ( bestDot >= 0.8 )
					break
			}
		}

		surfaceNormals = bestNormal
		surfaceAngles = AnglesOnSurface( bestNormal, AnglesToRight( angles ) )
	}

	//Limit the surface angle of the trap
	if ( hullTraceResults.fraction < 1.0 )
	{
		surfaceAngles = AnglesOnSurface( surfaceNormals, angles )
		vector newUpDir = AnglesToUp( surfaceAngles )
		vector oldUpDir = AnglesToUp( angles )

		if ( DotProduct( newUpDir, oldUpDir ) < TESLA_TRAP_ANGLE_LIMIT )
		{
			surfaceAngles = angles
			success = false
		}
	}

	//Check to see if the center of the trap is sitting on solid ground.
	if ( success )
	{
		#if CLIENT
			proxy.SetOrigin( hullTraceResults.endPos )
			proxy.SetAngles( surfaceAngles )
		#endif

		proxyTestPos = hullTraceResults.endPos
		proxyTestAngles = surfaceAngles

		//One Trace
		TraceResults traceResult = TraceLine( proxyTestPos + (hullTraceResults.surfaceNormal * 2), proxyTestPos + (hullTraceResults.surfaceNormal * -2), ignoreEnts, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE, player )
		if ( traceResult.fraction == 1.0 )
		{
			surfaceAngles = angles
			success = false
		}
	}

	//Check to see if there is enough vertical clearance above the trap for the pole to extend to its min height.
	if ( success )
	{
		vector startPos = hullTraceResults.endPos + (surfaceNormals * TESLA_TRAP_LINK_HEIGHT * 0.5)
		vector endPos = hullTraceResults.endPos + (surfaceNormals * (TESLA_TRAP_LINK_HEIGHT * TESLA_TRAP_LINK_FX_COUNT))
		TraceResults clearanceTraceResults = TraceLineHighDetail( startPos, endPos, ignoreEnts, TESLA_TRAP_TRACE_MASK, TRACE_COLLISION_GROUP_NONE, player )

		float height = (TESLA_TRAP_LINK_HEIGHT * TESLA_TRAP_LINK_FX_COUNT) * clearanceTraceResults.fraction
		int linkCount = int( height / TESLA_TRAP_LINK_HEIGHT )
		success = success && linkCount >= TESLA_TRAP_LINK_FX_MIN

//		DebugDrawLine( startPos, clearanceTraceResults.endPos, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 0.1 )
//		DebugDrawLine( clearanceTraceResults.endPos, endPos, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 0.1 )
	}

	if ( success )
	{
		if ( IsOriginInvalidForPlacingPermanentOnto( hullTraceResults.endPos, proxy ) )
			success = false
	}

	//printt( "SUCESS: " + success )

	TeslaTrapPlacementInfo placementInfo
	placementInfo.connectionOwner = player
	placementInfo.success = success
	placementInfo.origin = hullTraceResults.endPos
	placementInfo.angles = surfaceAngles
	placementInfo.parentTo = parentTo

	//See if we can snap to any neighboring nodes.
	bool canSnap = TelsaTrap_AttemptSnapToNeighbor( player, hullTraceResults.endPos, placementInfo )

	//If node cannot link to current focal point node and we are not snaping placement fails.
	if ( success && TeslaTrap_PlayerHasFocalTrap( player ) && !canSnap )
	{
		entity focalTrap = TeslaTrap_GetFocalTrapForPlayer( player )
		if ( !TeslaTrap_CanLink( proxy, placementInfo.origin, AnglesToUp( placementInfo.angles ), focalTrap, placementInfo ) )
		{
			placementInfo.success = false
			placementInfo.deployLinkState = eDeployLinkFlags.DLF_FAIL
		}
	}

	return placementInfo
}

bool function TeslaTrap_PlayerReachPos( entity player, vector startPos, vector targetPos, bool doTrace, float degrees, array<entity> ignoreEnts )
{
	float minDot = deg_cos( degrees )
	float dot    = DotProduct( Normalize( targetPos - startPos ), player.GetViewVector() )
	if ( dot < minDot )
		return false

	if ( doTrace )
	{
		TraceResults trace = TraceLine( startPos, targetPos, ignoreEnts, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE, player )
		if ( trace.fraction < 0.99 )
			return false
	}

	return true
}

bool function TeslaTrap_OriginTooCloseToNeighbor( vector origin )
{
	array<entity> traps = TeslaTrap_GetAll()
	foreach ( entity trap in traps )
	{
		float distSqr = DistanceSqr( origin, trap.GetOrigin() )
		if ( distSqr <= TESLA_TRAP_PLACEMENT_SPACING_MIN_SQR )
			return true
	}

	return false
}

bool function TelsaTrap_AttemptSnapToNeighbor( entity player, vector origin, TeslaTrapPlacementInfo placementInfo )
{
	if ( !TeslaTrap_PlayerHasFocalTrap( player ) )
		return false

	entity focalTrap = TeslaTrap_GetFocalTrapForPlayer( player )
	entity focalTrapParent = focalTrap.GetParent()
	
	if ( IsValid( focalTrapParent ) )
	{
		while ( IsValid( focalTrapParent.GetParent() ) )
			focalTrapParent = focalTrapParent.GetParent()
	}

	entity closestTrap
	float closestDist = TESLA_TRAP_PLACEMENT_SPACING_MIN_SQR

	array<entity> traps = TeslaTrap_GetAllLinkable( player )
	foreach ( entity trap in traps )
	{
		if ( trap == focalTrap )
			continue

		float distSqr = DistanceSqr( origin, trap.GetOrigin() )
		if ( distSqr > closestDist )
			continue

		entity trapParent = trap.GetParent()
		
		// Compare Parents
		if ( IsValid( focalTrapParent ) )
		{
			if ( !IsValid( trapParent ) )
				continue
			
			while ( IsValid( trapParent.GetParent() ) )
				trapParent = trapParent.GetParent()
			
			if ( trapParent != focalTrapParent )
				continue
		}
		else if ( IsValid( trapParent ) )
		{
			continue
		}

		if ( TeslaTrap_AreTrapsLinked( focalTrap, trap ) )
			continue

		if ( !TeslaTrap_CanDeploy( focalTrap, focalTrap.GetOrigin(), focalTrap.GetUpVector(), trap, placementInfo ) )
		{
			continue
		}

		//Do not allow us to link two existing enemy traps.
		int team = player.GetTeam()
		if ( focalTrap.GetTeam() != team && trap.GetTeam() != team )
			continue

		if ( TESLA_TRAP_DEBUG_DRAW_LINKS )
		{
			DebugDrawSphere( focalTrap.GetOrigin(), 15, int(COLOR_PINK.x), int(COLOR_PINK.y), int(COLOR_PINK.z), false, 0.1 )
			DebugDrawText( trap.GetOrigin()+<0,0,8>, VM_NAME()+": link trap ", false, 0.1 )
			DebugDrawSphere( trap.GetOrigin(), 15, int(COLOR_PURPLE.x), int(COLOR_PURPLE.y), int(COLOR_PURPLE.z), false, 0.1 )
		}
		if ( distSqr <= closestDist )
		{
			closestTrap = trap
			closestDist = distSqr
		}
	}

	if ( IsValid( closestTrap ) )
	{
		placementInfo.origin = closestTrap.GetOrigin()
		placementInfo.angles = closestTrap.GetAngles()
		placementInfo.parentTo = closestTrap.GetParent()
		placementInfo.snapTo = closestTrap
		placementInfo.success = true

		return true
	}

	return false
}

entity function TeslaTrap_CreateTrapPlacementProxy( asset modelName )
{
	if ( !IsValid( file.proxyEnt ) )
	{
		#if SERVER
			entity proxy = CreatePropDynamic( modelName, <0, 0, 0>, <0, 0, 0> )
		#else
			entity proxy = CreateClientSidePropDynamic( <0, 0, 0>, <0, 0, 0>, modelName )
		#endif
		proxy.kv.renderamt = 255
		proxy.kv.rendermode = 3
		proxy.kv.rendercolor = "255 255 255 255"
		proxy.Hide()

		file.proxyEnt = proxy
	}
	else
	{
		file.proxyEnt.SetOrigin( <0, 0, 0> )
		file.proxyEnt.SetAngles( <0, 0, 0> )
	}

	return file.proxyEnt
}

#if SERVER
void function TeslaTrap_AddEntityWirelineHitCallback( entity ent, void functionref( entity ) callback )
{
	if ( ent in file.entityWirelineHitCallback )
		file.entityWirelineHitCallback[ ent ].append( callback )
	else
		file.entityWirelineHitCallback[ ent ] <- [ callback ]
}

void function TeslaTrap_RemoveEntityWirelineHitCallback( entity ent, void functionref( entity ) callback )
{
	Assert( ent in file.entityWirelineHitCallback, "Entity has no wireline hit callbacks." )
	Assert( file.entityWirelineHitCallback[ ent ].contains( callback ) )

	file.entityWirelineHitCallback[ ent ].fastremovebyvalue( callback )

	if ( file.entityWirelineHitCallback[ ent ].len() == 0 )
		delete file.entityWirelineHitCallback[ ent ]
}

bool function TeslaTrap_EntityHasWirelineHitCallbacks( entity ent )
{
	if ( ent in file.entityWirelineHitCallback )
		return true

	return false
}

void function TeslaTrap_RunEntityWirelineHitCallbacks( entity ent )
{
	foreach ( callback in file.entityWirelineHitCallback[ ent ] )
	{
		callback( ent )
	}
}

bool function WirelinePreviewEnabled()
{
	return (GetCurrentPlaylistVarInt( "wireline_preview", 0 ) > 0)
}

void function TeslaTrap_CreateWorldOwnedTrapsFromArrayOfPoints( array<Point> points, bool isClosedLoop = false )
{
	array<int> createdTrapIDs
	foreach ( int i, Point point in points )
	{
		TeslaTrapPlacementInfo placementInfo
		placementInfo.success = true
		placementInfo.origin = point.origin
		placementInfo.angles = point.angles

		placementInfo.forceLinkTo = i > 0 ? file.trapData[ createdTrapIDs[ i - 1 ] ].trap : null

		int nextTrapID = TeslaTrap_GetNextTrapID()

		createdTrapIDs.append( nextTrapID )
		thread TeslaTrap_Deploy( null, placementInfo )

		//Close the circuit if we are flagged to do so.
		if ( isClosedLoop && i == points.len() - 1 )
		{
			TeslaTrapData trapData  = file.trapData[ nextTrapID ]
			TeslaTrapData otherData = file.trapData[ createdTrapIDs[ 0 ] ]
			TeslaTrap_AttemptTrapLink( trapData, otherData, placementInfo )
		}
	}
}

int function TeslaTrap_GetNextTrapID()
{
	return file.nextTrapId
}

void function TeslaTrap_CancelPlacement( entity player )
{
	if ( player.IsUsingOffhandWeapon( eActiveInventorySlot.mainHand ) )
	{
		entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

		if ( !IsValid( activeWeapon ) )
			return

		if ( activeWeapon.GetWeaponClassName() != TESLA_TRAP_WEAPON_NAME )
			return
		//printt( "PLAYER IS USING OFFHAND WEAPON." )

		if ( file.weaponConfigured[ activeWeapon ] > Time() )
			return

		//Swap back to the player's main weapon when we cancel tesla trap placement
		file.weaponConfigured[ activeWeapon ] = Time() + TESLA_TRAP_CANCEL_DELAY
		SwapToLastEquippedPrimary( player )
	}
}

//HACK NOTE: SCRIPTFLAG0 IS MEANT TO SET WEAPON FLAGS SUCH AS AMPED STATE.
//SINCE THIS WEAPON DOES NOT USE ANY SCRIPT FLAGS WE ARE USING THIS VARIABLE AS AN INT TO NETWORK THE NUMBER OF NODES WE WANT THE TRAP WE ARE PLACING TO LINK TO SO THAT WE CAN VISUALIZE IT ON THE CLIENT.
void function TeslaTrap_IncrementPlacementMaxLinks( entity weapon )
{
	//printt( "LAST MODE: " + weapon.GetScriptFlags0() )
	int mode = weapon.GetScriptFlags0()

	if ( mode - 1 < 0 )
	{
		mode = 1//TESLA_TRAP_LINK_COUNT_MAX
	}
	else
	{
		mode--
	}

	weapon.SetScriptFlags0( mode )
	//printt( "CURRENT MODE: " + weapon.GetScriptFlags0() )
}

void function TeslaTrap_SetPlacementMaxLinksToDefault( entity weapon )
{
	weapon.SetScriptFlags0( 0 )
}

void function TeslaTrap_SetPlacementMaxLinksToExtend( entity weapon )
{
	weapon.SetScriptFlags0( 1 )
}

void function TeslaTrap_RemoveDoubleLinkMode( entity weapon )
{
	if ( DoesModExist( weapon, "double_link_mod" ) )
	{
		if ( weapon.HasMod( "double_link_mod" ) )
			weapon.RemoveMod( "double_link_mod" )
	}
}
#endif //SERVER

int function TeslaTrap_GetPlacementMaxLinks( entity player )
{
	if ( !IsValid( player ) )
		return -1

	entity weapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )

	if ( !IsValid( weapon ) )
		return -1

	string className = weapon.GetWeaponClassName()
	if ( className != TESLA_TRAP_WEAPON_NAME )
		return -1

	if ( weapon.GetScriptFlags0() > 0 )
	{
		array<string> mods = weapon.GetMods()
		foreach ( mod in mods )
		{
			if ( mod == "double_link_mod" )
				return TESLA_TRAP_LINK_COUNT_MAX
		}
	}

	return weapon.GetScriptFlags0()
}

bool function OnObjectPlacementCanPlace_weapon_tesla_trap( entity weapon, vector origin, vector angles, entity parentTo )
{
	entity player = weapon.GetOwner()
	
	TeslaTrapPlacementInfo placementInfo
	placementInfo.connectionOwner = player
	placementInfo.success = true // This value is what is being determined with this callback, so assume true unless we find a reason for it not to be
	placementInfo.origin = origin
	placementInfo.angles = angles
	placementInfo.parentTo = parentTo
	
	TeslaTrap_PlacementInfoScriptChecks( player, placementInfo )

	return placementInfo.success
}

#if CLIENT
void function OnCreateClientOnlyModel_weapon_tesla_trap( entity weapon, entity model, bool validHighlight )
{
	entity player = weapon.GetOwner()

	thread TeslaTrap_SnapClientOnlyModel( player, weapon, model )
}

void function TeslaTrap_SnapClientOnlyModel( entity player, entity weapon, entity model )
{
	EndSignal( weapon, "OnDestroy" )
	EndSignal( model, "OnDestroy" )
	EndSignal( player, "OnDeath", "TeslaTrap_StopPlacementProxy" )

	var placementRui        = CreateCockpitPostFXRui( $"ui/tesla_trap_placement.rpak", RuiCalculateDistanceSortKey( player.EyePosition(), model.GetOrigin() ) )
	int placementAttachment = model.LookupAttachment( "BASE_POINT" )

	RuiSetInt( placementRui, "trapLimit", TESLA_TRAP_MAX_TRAPS )
	RuiTrackFloat3( placementRui, "mainTrapPos", model, RUI_TRACK_POINT_FOLLOW, placementAttachment )
	RuiKeepSortKeyUpdated( placementRui, true, "mainTrapPos" )

	//Create rui to show connection to focal trap.
	var linkRui    = CreateCockpitRui( $"ui/tesla_trap_link.rpak", 0 )
	RuiSetBool( linkRui, "showAll", false )
	RuiTrackFloat3( linkRui, "mainTrapPos", model, RUI_TRACK_POINT_FOLLOW, placementAttachment )
	RuiSetFloat( linkRui, "maxDist", TESLA_TRAP_LINK_DIST )
	RuiKeepSortKeyUpdated( linkRui, true, "otherTrapPos" )

	int fxHandle = -1
	table<entity, int> proxyRangeTable
	proxyRangeTable[ model ] <- fxHandle

	OnThreadEnd(
		function() : ( model, proxyRangeTable, placementRui, linkRui )
		{
			RuiDestroy( placementRui )
			RuiDestroy( linkRui )

			int fxHandle = proxyRangeTable[ model ]
			if ( EffectDoesExist( fxHandle ) )
				EffectStop( fxHandle, true, false )

			// clear the recal trap
			file.recalTrap = null
		}
	)

	entity lastFocalTrap
	while ( IsValid( weapon ) )
	{
		//TeslaTrapPlacementInfo placementInfo = TeslaTrap_ValidateObjectPlacerModel( player, model, weapon )
		
		TeslaTrapPlacementInfo placementInfo = TeslaTrap_GetObjectPlacementInfo( player, weapon )
		TeslaTrap_PlacementInfoScriptChecks( player, placementInfo )

		model.SetOrigin( placementInfo.origin )
		model.SetAngles( placementInfo.angles )

		if ( IsValid( placementInfo.snapTo ) )
			model.Hide()
		else
			model.Show()

		//Do not show a sucessful placement if the player is not snapping and does not have enough ammo to fire.
		int ammoReq   = weapon.GetAmmoPerShot()
		int currAmmo  = weapon.GetWeaponPrimaryClipCount()
		if ( currAmmo < ammoReq && !IsValid( placementInfo.snapTo ) )
			placementInfo.success = false

		array<entity> linkTraps
		bool canRecall = false
		file.recalTrap = null

		bool hasFocalTrap = TeslaTrap_PlayerHasFocalTrap( player )
		if ( hasFocalTrap )
		{
			entity focalTrap = TeslaTrap_GetFocalTrapForPlayer( player )
			linkTraps = TeslaTrap_AttemptTrapLinkOnClient( model, focalTrap, placementInfo )

			RuiSetFloat3( linkRui, "otherTrapPos", focalTrap.GetOrigin() + <0, 0, 6> )

			float distSqr = DistanceSqr( placementInfo.origin, focalTrap.GetOrigin() )
			if ( distSqr <= (file.balance_teslaTrapRange * file.balance_teslaTrapRange) )
			{
				canRecall = true
				file.recalTrap = focalTrap
			}
		}

		if ( placementInfo.success )
			DeployableModelHighlight( model )
		else
			DeployableModelInvalidHighlight( model )

		//Check to see which traps we can actually connect to with our current connection settings.
		TeslaTrapPlayerPlacementData placementData
		placementData.maxLinks = TeslaTrap_GetPlacementMaxLinks( player )
		placementData.viewOrigin = player.EyePosition()
		placementData.viewForward = player.GetViewForward()
		placementData.playerOrigin = player.GetOrigin()
		placementData.playerForward = FlattenVec( player.GetViewForward() )

		bool tacticalChargeActive = StatusEffect_HasSeverity( player, eStatusEffect.trophy_tactical_charge )
		RuiSetBool( placementRui, "boostActive", tacticalChargeActive )

		RuiSetBool( placementRui, "success", placementInfo.success )
		RuiSetBool( placementRui, "canRecall", canRecall )
		RuiSetInt( placementRui, "maxLinkCount", placementData.maxLinks )
		RuiSetInt( placementRui, "linkCount", linkTraps.len() )
		RuiSetInt( placementRui, "linkCountAvailable", linkTraps.len() )
		RuiSetInt( placementRui, "trapCount", TeslaTrap_GetOwnedLivingTrapCountOnClient( player ) )
		RuiSetBool( placementRui, "snapTo", IsValid( placementInfo.snapTo ) )

		RuiTrackFloat( placementRui, "chargeFrac", weapon, RUI_TRACK_WEAPON_CLIP_AMMO_FRACTION )

		RuiSetBool( linkRui, "showAll", false )
		RuiSetBool( linkRui, "success", placementInfo.success )

		if ( hasFocalTrap )
		{
			entity focalTrap = TeslaTrap_GetFocalTrapForPlayer( player )

			//Update Rui Visibility
			RuiSetBool( linkRui, "showAll", true )
			RuiSetBool( linkRui, "success", placementInfo.success )
			RuiSetFloat3( linkRui, "otherTrapPos", focalTrap.GetOrigin() + <0, 0, 6> )

			//Show distance dial for the farthest trap we are connected to.
			RuiSetBool( linkRui, "showDial", true )

			if ( TESLA_TRAP_DEBUG_DRAW_CLIENT_TRAP_LINKING )
				DebugDrawLine( model.GetOrigin(), focalTrap.GetOrigin(), int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 0.1 )

			if ( lastFocalTrap != focalTrap )
			{
				//Show the link radius for the other trap in primary focus.
				fxHandle = proxyRangeTable[ model ]
				if ( EffectDoesExist( fxHandle ) )
				{
					EffectStop( fxHandle, true, false )
					proxyRangeTable[ model ] = -1
				}

				fxHandle = StartParticleEffectOnEntity( focalTrap, GetParticleSystemIndex( TESLA_TRAP_PLACE_RANGE_FX ), FX_PATTACH_POINT_FOLLOW, focalTrap.LookupAttachment( "REF" ) )
				proxyRangeTable[ model ] = fxHandle
			}

			lastFocalTrap = focalTrap
		}
		else
		{
			//Show the link radius for the other trap in primary focus.
			if ( EffectDoesExist( fxHandle ) )
			{
				EffectStop( fxHandle, true, false )
				proxyRangeTable[ model ] = -1
			}
		}

		WaitFrame()
	}
}

void function TeslaTrap_OnBeginPlacement( entity weapon, entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	asset model = TESLA_TRAP_PROXY_MODEL

	thread TeslaTrap_PlacementProxy( weapon, player, model )
}

void function TeslaTrap_OnEndPlacement( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	player.Signal( "TeslaTrap_StopPlacementProxy" )
}

void function TeslaTrap_PlacementProxy( entity weapon, entity player, asset model )
{
	EndSignal( weapon, "OnDestroy" )
	EndSignal( player, "OnDeath", "TeslaTrap_StopPlacementProxy" )

	entity proxy = TeslaTrap_CreateTrapPlacementProxy( model )
	proxy.EnableRenderAlways()
	proxy.Show()
	DeployableModelHighlight( proxy )

	var placementRui        = CreateCockpitPostFXRui( $"ui/tesla_trap_placement.rpak", RuiCalculateDistanceSortKey( player.EyePosition(), proxy.GetOrigin() ) )
	int placementAttachment = proxy.LookupAttachment( "BASE_POINT" )

	RuiSetInt( placementRui, "trapLimit", TESLA_TRAP_MAX_TRAPS )
	RuiTrackFloat3( placementRui, "mainTrapPos", proxy, RUI_TRACK_POINT_FOLLOW, placementAttachment )
	RuiKeepSortKeyUpdated( placementRui, true, "mainTrapPos" )

	//Create rui to show connection to focal trap.
	int attachment = proxy.LookupAttachment( "BASE_POINT" )
	var linkRui    = CreateCockpitRui( $"ui/tesla_trap_link.rpak", 0 )
	RuiSetBool( linkRui, "showAll", false )
	RuiTrackFloat3( linkRui, "mainTrapPos", proxy, RUI_TRACK_POINT_FOLLOW, attachment )
	RuiSetFloat( linkRui, "maxDist", TESLA_TRAP_LINK_DIST )
	RuiKeepSortKeyUpdated( linkRui, true, "otherTrapPos" )

	int fxHandle = -1
	table<entity, int> proxyRangeTable
	proxyRangeTable[ proxy ] <- fxHandle

	OnThreadEnd(
		function() : ( proxy, proxyRangeTable, placementRui, linkRui )
		{
			RuiDestroy( placementRui )
			RuiDestroy( linkRui )

			int fxHandle = proxyRangeTable[ proxy ]
			if ( EffectDoesExist( fxHandle ) )
				EffectStop( fxHandle, true, false )

			if ( IsValid( proxy ) )
				proxy.Hide()

			// clear the recal trap
			file.recalTrap = null
		}
	)

	entity lastFocalTrap
	while ( IsValid( weapon ) )
	{
		proxy.ClearParent()
		TeslaTrapPlacementInfo placementInfo = TeslaTrap_GetPlacementInfo( player, proxy )

		proxy.SetOrigin( placementInfo.origin )
		proxy.SetAngles( placementInfo.angles )

		if ( IsValid( placementInfo.parentTo ) )
			proxy.SetParent( placementInfo.parentTo )

		//Do not show a sucessful placement if the player is not snapping and does not have enough ammo to fire.
		int ammoReq   = weapon.GetAmmoPerShot()
		int currAmmo  = weapon.GetWeaponPrimaryClipCount()
		if ( currAmmo < ammoReq && !IsValid( placementInfo.snapTo ) )
			placementInfo.success = false

		array<entity> linkTraps
		bool canRecall = false
		file.recalTrap = null

		bool hasFocalTrap = TeslaTrap_PlayerHasFocalTrap( player )
		if ( hasFocalTrap )
		{
			entity focalTrap = TeslaTrap_GetFocalTrapForPlayer( player )
			linkTraps = TeslaTrap_AttemptTrapLinkOnClient( proxy, focalTrap, placementInfo )

			RuiSetFloat3( linkRui, "otherTrapPos", focalTrap.GetOrigin() + <0, 0, 6> )

			float distSqr = DistanceSqr( placementInfo.origin, focalTrap.GetOrigin() )
			if ( distSqr <= (file.balance_teslaTrapRange * file.balance_teslaTrapRange) )
			{
				canRecall = true
				file.recalTrap = focalTrap
			}
		}

		if ( !placementInfo.success )
			DeployableModelInvalidHighlight( proxy )
		else if ( placementInfo.success )
			DeployableModelHighlight( proxy )

		//Check to see which traps we can actually connect to with our current connection settings.
		TeslaTrapPlayerPlacementData placementData
		placementData.maxLinks = TeslaTrap_GetPlacementMaxLinks( player )
		placementData.viewOrigin = player.EyePosition()
		placementData.viewForward = player.GetViewForward()
		placementData.playerOrigin = player.GetOrigin()
		placementData.playerForward = FlattenVec( player.GetViewForward() )

		bool tacticalChargeActive = StatusEffect_HasSeverity( player, eStatusEffect.trophy_tactical_charge )
		RuiSetBool( placementRui, "boostActive", tacticalChargeActive )

		RuiSetBool( placementRui, "success", placementInfo.success )
		RuiSetBool( placementRui, "canRecall", canRecall )
		RuiSetInt( placementRui, "maxLinkCount", placementData.maxLinks )
		RuiSetInt( placementRui, "linkCount", linkTraps.len() )
		RuiSetInt( placementRui, "linkCountAvailable", linkTraps.len() )
		RuiSetInt( placementRui, "trapCount", TeslaTrap_GetOwnedLivingTrapCountOnClient( player ) )
		RuiSetBool( placementRui, "snapTo", IsValid( placementInfo.snapTo ) )

		RuiTrackFloat( placementRui, "chargeFrac", weapon, RUI_TRACK_WEAPON_CLIP_AMMO_FRACTION )

		RuiSetBool( linkRui, "showAll", false )
		RuiSetBool( linkRui, "success", placementInfo.success )

		if ( hasFocalTrap )
		{
			entity focalTrap = TeslaTrap_GetFocalTrapForPlayer( player )

			//Update Rui Visibility
			RuiSetBool( linkRui, "showAll", true )
			RuiSetBool( linkRui, "success", placementInfo.success )
			RuiSetFloat3( linkRui, "otherTrapPos", focalTrap.GetOrigin() + <0, 0, 6> )

			//Show distance dial for the farthest trap we are connected to.
			RuiSetBool( linkRui, "showDial", true )

			if ( TESLA_TRAP_DEBUG_DRAW_CLIENT_TRAP_LINKING )
			{
				DebugDrawLine( proxy.GetOrigin(), focalTrap.GetOrigin(), int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 0.1 )
			}

			if ( lastFocalTrap != focalTrap )
			{
				//Show the link radius for the other trap in primary focus.
				fxHandle = proxyRangeTable[ proxy ]
				if ( EffectDoesExist( fxHandle ) )
				{
					EffectStop( fxHandle, true, false )
					proxyRangeTable[ proxy ] = -1
				}

				fxHandle = StartParticleEffectOnEntity( focalTrap, GetParticleSystemIndex( TESLA_TRAP_PLACE_RANGE_FX ), FX_PATTACH_POINT_FOLLOW, focalTrap.LookupAttachment( "REF" ) )
				proxyRangeTable[ proxy ] = fxHandle
			}

			lastFocalTrap = focalTrap
		}
		else
		{
			//Show the link radius for the other trap in primary focus.
			if ( EffectDoesExist( fxHandle ) )
			{
				EffectStop( fxHandle, true, false )
				proxyRangeTable[ proxy ] = -1
			}
		}

		WaitFrame()
	}
}
#endif //CLIENT

/*
 ____    _    ____  _____   _____ ____      _    ____    _____ _   _ _   _  ____ _____ ___ ___  _   _ ____
| __ )  / \  / ___|| ____| |_   _|  _ \    / \  |  _ \  |  ___| | | | \ | |/ ___|_   _|_ _/ _ \| \ | / ___|
|  _ \ / _ \ \___ \|  _|     | | | |_) |  / _ \ | |_) | | |_  | | | |  \| | |     | |  | | | | |  \| \___ \
| |_) / ___ \ ___) | |___    | | |  _ <  / ___ \|  __/  |  _| | |_| | |\  | |___  | |  | | |_| | |\  |___) |
|____/_/   \_\____/|_____|   |_| |_| \_\/_/   \_\_|     |_|    \___/|_| \_|\____| |_| |___\___/|_| \_|____/

*/

#if SERVER
void function TeslaTrap_Deploy( entity owner, TeslaTrapPlacementInfo placementInfo )
{
	vector origin = placementInfo.origin
	vector angles = placementInfo.angles

	bool ownedTrap = IsValid( owner )

	int team = ownedTrap ? owner.GetTeam() : TEAM_UNASSIGNED

	//Create Trap.
	entity trap = CreatePropScript( TESLA_TRAP_PROXY_MODEL, origin, angles, SOLID_VPHYSICS, -1, false )
	trap.kv.collisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	SetTeam( trap, team )
	trap.DisableHibernation()
	trap.SetMaxHealth( TESLA_TRAP_HEALTH )
	trap.SetHealth( TESLA_TRAP_HEALTH )
	trap.SetTakeDamageType( DAMAGE_YES )
	trap.SetDamageNotifications( false )
	trap.SetDeathNotifications( false )
	trap.SetScriptName( TESLA_TRAP_NAME )
	trap.SetIgnorePredictedTriggerTypes( TT_JUMP_PAD | TT_GRAVITY_LIFT | TT_BLACKHOLE  )
	SetTargetName( trap, TESLA_TRAP_NAME )
	trap.SetBlocksRadiusDamage( false )
	DispatchSpawn( trap ) //Call this explicitly so that the script name is set before the spawn callback.

	//Set the origin and angles after the dispatch spawn to avoid the rounding that's done in code on spawn
	trap.SetOrigin( origin )
	trap.SetAngles( angles )

	if ( ownedTrap )
	{
		trap.SetOwner( owner )
		trap.SetBossPlayer( owner )
		trap.RemoveFromAllRealms()
		trap.AddToOtherEntitysRealms( owner )
	}

	// no reason not to use the trap as the minimap object.
	// This also means it'll be easy to figure out how to draw the lines on the minimap
	trap.Minimap_SetCustomState( eMinimapObject_prop_script.ARC_TRAP )
	trap.Minimap_AlwaysShow( trap.GetTeam(), null )

	// If we are in a mode where we allow communication between players near each other that are on the same team (but not the same squad); show the icon to nearby teammates
	AllianceProximity_SetMinimapAlwaysShow_ForAlliance( trap.GetTeam(), trap, null )

	trap.Minimap_SetObjectScale( 0.02 )

	//	trap.EnableNetworkedEntityLinks() //Enable networked entity links so the client knows which traps we are linked to.

	if ( IsValid( placementInfo.parentTo ) )
		trap.SetParent( placementInfo.parentTo )

	trap.SetCanBeMeleed( false )
	SetVisibleEntitiesInConeQueriableEnabled( trap, false )

	if ( ownedTrap )
		thread TrapDestroyOnRoundEnd( owner, trap )

	EndSignal( trap, "OnDestroy", "TeslaTrap_PickedUp" )

	//Start logic to handle tesla trap pickup.
	thread TeslaTrap_WaitForPickup( trap )

	if ( ownedTrap )
		EmitSoundOnEntity( trap, TESLA_TRAP_PLACEMENT_SOUND )

	trap.SetBoundingBox( TESLA_TRAP_BOUND_MINS, TESLA_TRAP_BOUND_MAXS )
	trap.SetTouchTriggers( true )
	trap.e.canBurn = true
	trap.e.canBeDamagedFromGas = true
	trap.EnableAttackableByAI( AI_PRIORITY_NO_THREAT, 0, AI_PRIORITY_NO_THREAT ) // Players are priority 10, so make this a lower priority target

	PlayerObjects_CommonInit( owner, trap, true, "sp_friendly_hero", false, true, false )

                         
                                                                     

       

                 
                              
       

	trap.SetCanBeMeleed( true )
	SetVisibleEntitiesInConeQueriableEnabled( trap, false )

	if ( ownedTrap )
		EndThreadOn_PlayerChangedClass( owner )

	AddEntityCallback_OnDamaged( trap, TeslaTrap_OnTrapDamaged )
	AddEntityCallback_OnPostDamaged( trap, TeslaTrap_OnTrapPostDamaged )

	//Put traps in default anim state.
	trap.Anim_PlayOnly( "prop_fence_idle" )
	trap.Anim_DisableUpdatePosition()
	int proxyHeightIndex = trap.LookupPoseParameterIndex( "Height" )
	trap.SetPoseParameter( proxyHeightIndex, 0 )

	array<entity> ignoreEnts = ownedTrap ? [owner, trap] : [trap]
	ignoreEnts.extend( GetPlayerArray_Alive() )

	//commented-out stuff here is a fix for R5DEV-287347. Apparently at some point in the past it was possible for fences to be of variable height? - JMH 9.15.21
	vector startPos = trap.GetOrigin() + (trap.GetUpVector() * TESLA_TRAP_LINK_HEIGHT * 0.5)	// this matches the same trace in TeslaTrap_GetPlacementInfoFromTraceResults
	vector endPos = trap.GetOrigin() + (trap.GetUpVector() * (TESLA_TRAP_LINK_HEIGHT * TESLA_TRAP_LINK_FX_COUNT))
	//TraceResults clearanceTraceResults = TraceLineHighDetail( startPos, endPos, ignoreEnts, TESLA_TRAP_TRACE_MASK, TRACE_COLLISION_GROUP_NONE, trap )
	float height                       = (TESLA_TRAP_LINK_HEIGHT * TESLA_TRAP_LINK_FX_COUNT) //* clearanceTraceResults.fraction

	int id = file.nextTrapId

	//Create and store trap data
	TeslaTrapData data
	data.id = id
	data.trap = trap
	data.linkedTrapIDs = []
	data.maxBeamCount = int ( height / TESLA_TRAP_LINK_HEIGHT )

	file.trapData[ file.nextTrapId ] <- data
	file.activeTrapIds[ trap ] <- file.nextTrapId
	file.nextTrapId++

	//Attempt to link trap to focal trap.
	if ( ownedTrap && TeslaTrap_PlayerHasFocalTrap( owner ) )
	{
		entity otherTrap = TeslaTrap_GetFocalTrapForPlayer( owner )
		if ( IsValid( otherTrap ) )
		{
			int otherID             = file.activeTrapIds[ otherTrap ]
			TeslaTrapData otherData = file.trapData[ otherID ]
			TeslaTrap_AttemptTrapLink( data, otherData, placementInfo )
		}
	}
	else if ( IsValid( placementInfo.forceLinkTo ) )
	{
		entity otherTrap        = placementInfo.forceLinkTo
		int otherID             = file.activeTrapIds[ otherTrap ]
		TeslaTrapData otherData = file.trapData[ otherID ]
		TeslaTrap_AttemptTrapLink( data, otherData, placementInfo )
	}

	//Set this trap as the new focal trap on the server, it must be set as the focal trap on the client seperately.
	if ( ownedTrap )
		TeslaTrap_SetFocalTrapForPlayer( owner, data.trap )

	if ( ownedTrap )
		AddNewLimitedLegendObject(owner, trap, TESLA_TRAP_MAX_TRAPS )

	//Check to see if the trap's post intersects anything in real-time.
	thread TeslaTrap_CheckForPostIntersection( data )

	OnThreadEnd(
		function() : ( owner, trap, id )
		{
			RemoveLimitedLegendObject( owner, trap ) //must do this before we change the script name below as that is how we delete these objects

			if ( IsValid( trap ) )
			{
				trap.NotSolid()
				bool pickedUp = false
				if ( IsValid( owner ) && IsAlive( owner ) )
				{
					//if this was the owner's focal trap, try to rewind to a previous node.
					if ( trap in file.activeTrapIds )
					{
						int id                 = file.activeTrapIds[ trap ]
						TeslaTrapData trapData = file.trapData[ id ]

						if ( trapData.pickedUp )
						{
							pickedUp = true
							if ( trapData.linkedTrapIDs.len() == 1 )
							{
								int otherID = trapData.linkedTrapIDs[ 0 ]
								if ( otherID in file.trapData )
								{
									TeslaTrapData otherData = file.trapData[ otherID ]
									if ( IsValid( otherData.trap ) )
										TeslaTrap_SetFocalTrapForPlayer( owner, otherData.trap )
								}
							}
						}
					}
				}

				trap.SetScriptName( "tesla_trap_dead" ) //Change name so that client cannot find entity
				trap.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 1 )

				int mainHeightIndex = trap.LookupPoseParameterIndex( "Height" )
				trap.Anim_PlayOnly( "prop_fence_idle" )
				trap.Anim_DisableUpdatePosition()
				trap.SetPoseParameterOverTime( mainHeightIndex, 0, 1.0 )

				//Remove sonar detection from trap.
				RemoveSonarDetectionForPropScript( trap )
			}

			TeslaTrap_UnlinkAllFromTraps( owner, id )
			delete file.trapData[ id ]
			delete file.activeTrapIds[ trap ]
		}
	)

	WaitFrame()

	TeslaTrap_PlayTrapPlaceFX( trap )

	//Wait Before Turning the Trap On.
	wait TESLA_TRAP_DEPLOY_DELAY

	//Despawn oldest trap if player goes over trap limit.
	if ( ownedTrap )
	{
		trap.e.trapSetTeamFunc = TeslaTrap_SetTeam
	}

	while ( true )
	{
		//Wait for trap to become unlinked
		trap.WaitSignal( "TeslaTrap_Unlinked" )
	}
}

entity function TeslaTrap_CreateTrapTrigger( TeslaTrapData trapData )
{
	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetCylinderRadius( TESLA_TRAP_RADIUS )
	trigger.SetAboveHeight( 100 )
	trigger.SetBelowHeight( 20 )
	trigger.SetOrigin( trapData.trap.GetOrigin() )
	trigger.kv.triggerFilterNpc = "all"
	trigger.kv.triggerFilterPlayer = "all"
	trigger.kv.triggerFilterNonCharacter = "0"
	DispatchSpawn( trigger )

	trigger.SetEnterCallback( TriggerSignal )
	trigger.SetOrigin( trapData.trap.GetOrigin() )

	return trigger
}

void function AddTeslaTrapTriggeredCallback( void functionref( entity, var ) callback )
{
	file.teslaTrapTriggerCallbacks.append( callback )
}

void function TeslaTrap_FlashUpdate( entity trapProxy )
{
	EndSignal( trapProxy, "OnDestroy", "TeslaTrap_Activate", "TeslaTrap_Linked", "TeslaTrap_PickedUp" )

	//Start blinking light effect.
	int idleFxId       = GetParticleSystemIndex( TESLA_TRAP_IDLE_FX )
	int startAttachID  = trapProxy.LookupAttachment( "BASE_POINT" )
	entity idleLightFX = StartParticleEffectOnEntity_ReturnEntity( trapProxy, idleFxId, FX_PATTACH_POINT_FOLLOW, startAttachID )

	OnThreadEnd(
		function() : ( idleLightFX )
		{
			if ( IsValid( idleLightFX ) )
				EffectStop( idleLightFX )
		}
	)

	WaitForever()
}

void function TriggerSignal( entity trigger, entity other )
{
	trigger.Signal( "OnTrigger" )
}

entity function AutoPingForTrapDetection( entity playerOwner, entity targetEnt, entity trap, vector position )
{
	if ( playerOwner.IsPlayer() )
		EmitSoundOnEntityOnlyToPlayer( playerOwner, playerOwner, TESLA_TRAP_DAMAGE_SPARK_SOUND )

	entity wp = CreateWaypoint_BasicPos( position, "#EMPTY_STRING", TESLA_TRAP_ACTIVATED_ICON )
	wp.SetOwner( trap )

	// Transmit to single team. If using Alliances also show to friendly alliance players
	AllianceProximity_SetOnlyTransmitWaypointToFriendlyTeams( wp, playerOwner.GetTeam() )

	thread DelayedDestroyWP( wp )
	return wp
}

void function DelayedDestroyWP( entity wp )
{
	wp.EndSignal( "OnDestroy" )

	wait 4.0

	wp.Destroy()
}

void function TeslaTrap_DamagedTarget( entity victim, var damageInfo )
{
	if ( victim.IsNPC() && Electricity_ShouldStunNPCAndAddImmunity( victim ) )
	{
		DamageInfo_ScaleDamage( damageInfo, 0 )
		return
	}

	foreach ( callback in file.teslaTrapTriggerCallbacks )
	{
		callback( victim, damageInfo )
	}

	//Don't Show Damage Indicator.
	//DamageInfo_AddCustomDamageType( damageInfo, DF_NO_INDICATOR )

	//if the attacker is a valid friendly set damage do zero.
	//Note: We need the FF so we can trigger the emp effect.
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( IsValid( attacker ) )
	{
		if ( IsFriendlyTeam( attacker.GetTeam(), victim.GetTeam() ) && attacker != victim )
			DamageInfo_ScaleDamage( damageInfo, 0 )
	}

	                             
		bool shouldTestForShadowDamageScale = false

		                              
			if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) )
				shouldTestForShadowDamageScale = true
        

		                            
			if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) )
				shouldTestForShadowDamageScale = true
        

		if ( shouldTestForShadowDamageScale && !IsFriendlyTeam( attacker.GetTeam(), victim.GetTeam() ) && IsPlayerShadowZombie( victim ) )
			DamageInfo_ScaleDamage( damageInfo, GetCurrentPlaylistVarFloat( "shadow_damage_taken_scale_from_fences", 0.5 ) )
                                    

	Electricity_DamagedPlayerOrNPC( victim, damageInfo, TESTLA_TRAP_EMP_DURATION_UPDATE )
}

void function TeslaTrap_OnTrapDamaged( entity trapProxy, var damageInfo )
{
	//printt( "TRAP DAMAGED" )

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( attacker ) )
		return

	int trapTeam     = trapProxy.GetTeam()
	int attackerTeam = attacker.GetTeam()

	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	bool ignoreFriendlyFire = damageSourceID != eDamageSourceId.mp_ability_crypto_drone_emp_trap || !TESLA_TRAP_DAMAGE_DEBUG
	if ( IsFriendlyTeam( attackerTeam, trapTeam ) && ignoreFriendlyFire )
	{
		DamageInfo_ScaleDamage( damageInfo, 0.0 )
		return
	}

	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if ( !IsValid( inflictor ) )
		return

	//Check team of inflictor, this is to cover cases like caustic barrels.
	int inflictorTeam = inflictor.GetTeam()

	if ( IsFriendlyTeam( inflictorTeam, trapTeam ) && ignoreFriendlyFire )
	{
		DamageInfo_ScaleDamage( damageInfo, 0.0 )
		return
	}

	                             
		bool shouldTestForShadowDamageScale = false

		                              
			if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ROYALE ) )
				shouldTestForShadowDamageScale = true
        

		                            
			if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) )
				shouldTestForShadowDamageScale = true
        

		//zombies do more damage per-swipe to fences
		if ( shouldTestForShadowDamageScale && !IsFriendlyTeam( inflictorTeam, trapTeam ) && IsPlayerShadowZombie( inflictor ) && DamageInfo_GetDamageSourceIdentifier( damageInfo ) != eDamageSourceId.crushed )
			DamageInfo_ScaleDamage( damageInfo, GetCurrentPlaylistVarFloat( "shadow_damage_scale_vs_fences", 2.0 ) )
                                    

	if ( damageSourceID == eDamageSourceId.mp_weapon_tesla_trap )
	{
		DamageInfo_ScaleDamage( damageInfo, 0 )
		return
	}
}

void function TeslaTrap_OnTrapPostDamaged( entity trapProxy, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( attacker ) )
		return

	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if ( !IsValid( inflictor ) )
		return

	if ( !IsValid( trapProxy ) )
		return

	float damage = DamageInfo_GetDamage( damageInfo )
	if ( damage <= 0 )
		return

	DamageInfo_ScaleDamage( damageInfo, 0 )

	int maxHealth = trapProxy.GetMaxHealth()
	int health    = trapProxy.GetHealth()

	float newHealth = max( health - damage, 0.0 )

	if ( newHealth <= 0 )
	{
		DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )

		TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_TESLA_TRAP, trapProxy, trapProxy.GetOrigin(), attacker.GetTeam(), attacker )

		TeslaTrap_PlayTrapDestroyFX( trapProxy )
		EmitSoundAtPosition( TEAM_UNASSIGNED, trapProxy.GetOrigin(), TESLA_TRAP_DESTROY_SOUND, trapProxy )
	}
	else
	{
		float healthFrac = newHealth / maxHealth

		if ( healthFrac <= 0.99 )
			TeslaTrap_PlayTrapDamagedFX( trapProxy )
		
		DamageInfo_AddCustomDamageType( damageInfo, DF_SOUR )

	}

	if ( attacker.IsPlayer() )
	{
		attacker.NotifyDidDamage( trapProxy, DamageInfo_GetHitBox( damageInfo ), DamageInfo_GetDamagePosition( damageInfo ),
									DamageInfo_GetCustomDamageType( damageInfo ), damage, DamageInfo_GetDamageFlags( damageInfo ),
									DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
	}

	trapProxy.SetHealth( newHealth )
}

void function TeslaTrap_PlayTrapPlaceFX( entity trapProxy )
{
	int placeFXID       = GetParticleSystemIndex( TESLA_TRAP_PLACE_FX )
	int placeFXAttachID = trapProxy.LookupAttachment( "REF" )
	entity placeFX      = StartParticleEffectOnEntity_ReturnEntity( trapProxy, placeFXID, FX_PATTACH_POINT_FOLLOW, placeFXAttachID )
}

void function TeslaTrap_PlayTrapDestroyFX( entity trapProxy )
{
	if ( trapProxy.GetModelName() != TESLA_TRAP_PROXY_MODEL )
		return

	int poseIndex        = trapProxy.LookupPoseParameterIndex( "height" )
	float heightPose     = trapProxy.GetPoseParameter( poseIndex )
	int damageFXID       = heightPose > 0 ? GetParticleSystemIndex( TESLA_TRAP_DESTROY_FX ) : GetParticleSystemIndex( TESLA_TRAP_DESTROY_CLOSED_FX )
	int damageFXAttachID = trapProxy.LookupAttachment( "REF" )
	entity fx            = StartParticleEffectInWorld_ReturnEntity( damageFXID, trapProxy.GetAttachmentOrigin( damageFXAttachID ), trapProxy.GetUpVector() )
	fx.RemoveFromAllRealms()
	fx.AddToOtherEntitysRealms( trapProxy )
}

void function TeslaTrap_PlayTrapDamagedFX( entity trapProxy )
{
	int damageFXID       = GetParticleSystemIndex( TESLA_TRAP_DAMAGE_SPARK_FX )
	int damageFXAttachID = trapProxy.LookupAttachment( "BASE_POINT" )

	if ( trapProxy.IsMarkedForDeletion() )
		return

	entity fx = StartParticleEffectOnEntityWithPos_ReturnEntity( trapProxy, damageFXID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, trapProxy.GetUpVector() * 4, VectorToAngles( trapProxy.GetUpVector() ) )
	fx.RemoveFromAllRealms()
	fx.AddToOtherEntitysRealms( trapProxy )

	EmitSoundOnEntity( trapProxy, TESLA_TRAP_DAMAGE_SPARK_SOUND )
}

/*
 _     ___ _   _ _  _______ ____    _____ ____      _    ____    _____ _   _ _   _  ____ _____ ___ ___  _   _ ____
| |   |_ _| \ | | |/ / ____|  _ \  |_   _|  _ \    / \  |  _ \  |  ___| | | | \ | |/ ___|_   _|_ _/ _ \| \ | / ___|
| |    | ||  \| | ' /|  _| | | | |   | | | |_) |  / _ \ | |_) | | |_  | | | |  \| | |     | |  | | | | |  \| \___ \
| |___ | || |\  | . \| |___| |_| |   | | |  _ <  / ___ \|  __/  |  _| | |_| | |\  | |___  | |  | | |_| | |\  |___) |
|_____|___|_| \_|_|\_\_____|____/    |_| |_| \_\/_/   \_\_|     |_|    \___/|_| \_|\____| |_| |___\___/|_| \_|____/

*/
void function TeslaTrap_LinkTraps( int mainTrapID, int linkTrapID )
{
	Assert( mainTrapID != linkTrapID, "Tesla Trap is trying to link to itself." )

	TeslaTrapData mainData  = file.trapData[ mainTrapID ]
	TeslaTrapData otherData = file.trapData[ linkTrapID ]

	if ( IsValid( mainData.trap.GetOwner() ) && IsAlive( mainData.trap.GetOwner() ) )
	{
		if ( mainData.trap.GetOwner() in file.hasPlacedLinkedTrap )
		{
			file.hasPlacedLinkedTrap[ mainData.trap.GetOwner() ] = true
			if ( mainData.trap.GetOwner().p.lastTacticalVOTime + TESLA_TRAP_LINK_VO_DBOUNCE <= Time() )
			{
				mainData.trap.GetOwner().p.lastTacticalVOTime = Time()
				PlayBattleChatterLineToSpeakerAndTeam( mainData.trap.GetOwner(), "bc_tactical" )
			}
		}
	}

	//Link Main to Other
	TeslaTrap_CreateTrapLinkData( mainData, otherData )
	mainData.linkedTrapIDs.append( linkTrapID )
	mainData.trap.LinkToEnt( otherData.trap )
	if ( TESLA_TRAP_DEBUG_DRAW )
	{
		DebugDrawLine( mainData.trap.GetOrigin(), otherData.trap.GetOrigin(), int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 30.0 )
	}

	//Link Other to Main
	otherData.linkedTrapIDs.append( mainTrapID )
	otherData.trap.LinkToEnt( mainData.trap )

	mainData.trap.Signal( "TeslaTrap_Linked" )
	otherData.trap.Signal( "TeslaTrap_Linked" )
}

void function TeslaTrap_UnlinkTraps( int mainTrapID, int unlinkTrapID )
{
	Assert( mainTrapID != unlinkTrapID, "Tesla Trap is trying to unlink from itself." )

	TeslaTrapData mainData  = file.trapData[ mainTrapID ]
	TeslaTrapData otherData = file.trapData[ unlinkTrapID ]

	//Unlink Main trap from Other trap.
	TeslaTrap_DestroyTrapLinkBeamFX( mainData, otherData )
	int otherIndex = mainData.linkedTrapIDs.find( unlinkTrapID )
	mainData.linkedTrapIDs.fastremove( otherIndex )
	mainData.trap.UnlinkFromEnt( otherData.trap )

	//Unlink Other trap from Main trap.
	int mainIndex = otherData.linkedTrapIDs.find( mainTrapID )
	otherData.linkedTrapIDs.fastremove( mainIndex )
	otherData.trap.UnlinkFromEnt( mainData.trap )

	//If this was the main trap's last link to another trap, signal that the main trap is now unlinked.
	if ( mainData.linkedTrapIDs.len() == 0 )
	{
		mainData.trap.Anim_PlayOnly( "prop_fence_idle" )
		mainData.trap.Anim_DisableUpdatePosition()
		int trapHeightIndex = mainData.trap.LookupPoseParameterIndex( "Height" )
		mainData.trap.SetPoseParameterOverTime( trapHeightIndex, 0, 1.0 )
		mainData.trap.Signal( "TeslaTrap_Unlinked" )
		EmitSoundAtPosition( TEAM_UNASSIGNED, mainData.trap.GetOrigin(), TESLA_TRAP_POST_COLLAPSE_SOUND, mainData.trap )
	}

	//If this was the other trap's last link to another trap, signal that the other trap is now unlinked.
	if ( otherData.linkedTrapIDs.len() == 0 )
	{
		otherData.trap.Anim_PlayOnly( "prop_fence_idle" )
		otherData.trap.Anim_DisableUpdatePosition()
		int trapHeightIndex = otherData.trap.LookupPoseParameterIndex( "Height" )
		otherData.trap.SetPoseParameterOverTime( trapHeightIndex, 0, 1.0 )
		otherData.trap.Signal( "TeslaTrap_Unlinked" )
		EmitSoundAtPosition( TEAM_UNASSIGNED, otherData.trap.GetOrigin(), TESLA_TRAP_POST_COLLAPSE_SOUND, otherData.trap )
	}
}

bool function TeslaTrap_AttemptTrapLink( TeslaTrapData trapData, TeslaTrapData otherData, TeslaTrapPlacementInfo placementInfo )
{
	//Link to the other trap if it meets all link criteria.

	if ( TeslaTrap_CanLink( trapData.trap, trapData.trap.GetOrigin(), trapData.trap.GetUpVector(), otherData.trap, placementInfo ) )
	{
		//Play snapping FX and sounds.
		if ( placementInfo.snapTo )
		{
			TeslaTrap_PlayTrapPlaceFX( otherData.trap )
			EmitSoundOnEntityOnlyToPlayer( placementInfo.connectionOwner, placementInfo.connectionOwner, TESLA_TRAP_PLACEMENT_SOUND )
		}

		int linkID = otherData.id
		TeslaTrap_LinkTraps( trapData.id, linkID )

		//If player has placed a dead end node, start a new chain of nodes.
		if ( IsValid( placementInfo.connectionOwner ) )
		{
			switch ( otherData.linkFXData.len() )
			{
				case 1:
					TeslaTrap_SetFocalTrapForPlayer( placementInfo.connectionOwner, otherData.trap )
					break

				case TESLA_TRAP_LINK_COUNT_MAX:
					TeslaTrap_ClearFocalTrapForPlayer( placementInfo.connectionOwner )
					break
			}
		}

		return true
	}

	return false
}

void function TeslaTrap_UnlinkAllFromTraps( entity owner, int trapID )
{
	//int trapID          = file.activeTrapIds[ trap ]
	TeslaTrapData trapData = file.trapData[ trapID ]

	array<int> unlinkIDs = clone trapData.linkedTrapIDs

	if ( file.balance_teslaTrapSelfRepair && IsValid( owner ) && ( unlinkIDs.len() > 1 ) )
	{
		entity trap1 	= file.trapData[ unlinkIDs[0] ].trap
		entity trap2 	= file.trapData[ unlinkIDs[1] ].trap
		vector trap1Pos = trap1.GetOrigin()
		vector trap2Pos = trap2.GetOrigin()
		float distSqr 	= DistanceSqr(  trap1Pos, trap2Pos )
		int beamCount 	= TeslaTrap_GetLinkLOSBeamCount( trap1Pos, trap1.GetUpVector(), trap2Pos, trap2.GetUpVector(), trap1, trap2 )

		if 	( 	( distSqr <= TESLA_TRAP_LINK_DIST_SQR) &&
				( beamCount >= TESLA_TRAP_LINK_FX_MIN ) &&
				!TeslaTrap_AreTrapsLinked( trap1, trap2 ) &&
				( trap1 != trap2 )
			)
			TeslaTrap_LinkTraps( unlinkIDs[ 0 ], unlinkIDs[ 1 ] )
	}

	foreach ( int unlinkID in unlinkIDs )
	{
		TeslaTrap_UnlinkTraps( trapID, unlinkID )
	}
}

bool function TeslaTrap_IsFlushWithGround( TeslaTrapData mainTrapData, TeslaTrapData otherTrapData )
{
	array<entity> ignoreEnts = GetPlayerArray_Alive()

	vector mainOrigin  = mainTrapData.trap.GetOrigin() + (mainTrapData.trap.GetUpVector() * TESLA_TRAP_LINK_HEIGHT)
	vector otherOrigin = otherTrapData.trap.GetOrigin() + (otherTrapData.trap.GetUpVector() * TESLA_TRAP_LINK_HEIGHT)

	int groundCheckDensity   = maxint ( int ( Distance( mainOrigin, otherOrigin ) / TESLA_TRAP_LINK_GROUND_CHECK_INTERVAL ), 1 )
	vector mainToOtherOffset = (otherOrigin - mainOrigin) / (groundCheckDensity + 1)

	float failCount = 0
	for ( int i = 1; i < (groundCheckDensity + 1); i++ )
	{
		vector startOffset   = mainOrigin + (mainToOtherOffset * i)
		vector endOffset     = startOffset - (< 0, 0, 1 > * TESLA_TRAP_LINK_MAX_GROUND_DIST)
		//TraceResults results = TraceLineHighDetail( startOffset, endOffset, ignoreEnts, TRACE_MASK_BLOCKLOS, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
		TraceResults results = TraceLine( startOffset, endOffset, ignoreEnts, TESLA_TRAP_TRACE_MASK, TRACE_COLLISION_GROUP_NONE )

		if ( TESLA_TRAP_DEBUG_DRAW_GROUND_CLEARANCE )
		{
			DebugDrawLine( results.endPos, endOffset, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 1.0 )
			DebugDrawLine( startOffset, results.endPos, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 1.0 )
		}

		//PrintTraceResults( results )

		if ( results.fraction == 1.0 )
			failCount += 1
		else
			failCount = 0

		int failMax = minint( TESLA_TRAP_LINK_GROUND_CHECK_FAIL_COUNT, groundCheckDensity )
		if ( failCount == failMax )
			return false
	}

	return true
}

void function TeslaTrap_CreateTrapLinkData( TeslaTrapData mainTrapData, TeslaTrapData otherTrapData )
{
	//Get the number of beam fx to use in this link.
	int beamCount      = TeslaTrap_GetLinkLOSBeamCount( mainTrapData.trap.GetOrigin(), mainTrapData.trap.GetUpVector(), otherTrapData.trap.GetOrigin(), otherTrapData.trap.GetUpVector(), mainTrapData.trap, otherTrapData.trap )
	int trapBeamCount  = minint ( mainTrapData.maxBeamCount, otherTrapData.maxBeamCount )
	int finalBeamCount = minint ( beamCount, trapBeamCount )

	//array<entity> linkFXs
	array<entity> damageFXs
	array<entity> controlPoints
	for ( int i = 1; i <= finalBeamCount; i++ )
	{
		float heightOffset  = TESLA_TRAP_LINK_HEIGHT * i
		vector otherUp      = otherTrapData.trap.GetUpVector()
		entity controlPoint = CreateEntity( "info_placement_helper" )
		SetTargetName( controlPoint, UniqueString( "tesla_beam_cpEnd" ) )
		int attachID  = otherTrapData.trap.LookupAttachment( "BASE_POINT" )
		vector origin = otherTrapData.trap.GetAttachmentOrigin( attachID )
		controlPoint.SetOrigin( origin + (otherUp * heightOffset) )
		controlPoint.SetParent( otherTrapData.trap, "", true, 0.0 )
		DispatchSpawn( controlPoint )

		entity damageFX = TeslaTrap_CreateServerDamageBeamWithControlPoint( mainTrapData.trap, TESLA_TRAP_ZAP_FX, controlPoint, heightOffset )

		if ( IsValid( mainTrapData.trap ) )
		{
			damageFX.RemoveFromAllRealms()
			damageFX.AddToOtherEntitysRealms( mainTrapData.trap )
		}

		controlPoints.append( controlPoint )
		damageFXs.append( damageFX )
	}

	mainTrapData.trap.Anim_PlayOnly( "prop_fence_idle" )
	mainTrapData.trap.Anim_DisableUpdatePosition()
	otherTrapData.trap.Anim_PlayOnly( "prop_fence_idle" )
	otherTrapData.trap.Anim_DisableUpdatePosition()

	int mainHeightIndex  = mainTrapData.trap.LookupPoseParameterIndex( "Height" )
	int otherHeightIndex = otherTrapData.trap.LookupPoseParameterIndex( "Height" )

	if ( mainTrapData.trap.GetPoseParameter( otherHeightIndex ) < finalBeamCount / TESLA_TRAP_POSE_PARAMETER_HEIGHT_MAX )
	{
		mainTrapData.trap.SetPoseParameterOverTime( mainHeightIndex, finalBeamCount / TESLA_TRAP_POSE_PARAMETER_HEIGHT_MAX, 1.0 )
		EmitSoundOnEntity( mainTrapData.trap, TESLA_TRAP_POLE_RISE_SOUND )
		thread TeslaTrap_PlayPollRiseFXDefered( mainTrapData.trap )
	}

	if ( otherTrapData.trap.GetPoseParameter( otherHeightIndex ) < finalBeamCount / TESLA_TRAP_POSE_PARAMETER_HEIGHT_MAX )
	{
		otherTrapData.trap.SetPoseParameterOverTime( otherHeightIndex, finalBeamCount / TESLA_TRAP_POSE_PARAMETER_HEIGHT_MAX, 1.0 )
		EmitSoundOnEntity( otherTrapData.trap, TESLA_TRAP_POLE_RISE_SOUND )
		thread TeslaTrap_PlayPollRiseFXDefered( otherTrapData.trap )
	}

	TeslaTrap_CreateLinkTriggerCylinder( mainTrapData, otherTrapData, finalBeamCount, damageFXs, controlPoints )
}

void function TeslaTrap_PlayPollRiseFXDefered( entity trapProxy )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	trapProxy.EndSignal( "OnDestroy" )

	WaitFrame()

	int startAttachID = trapProxy.LookupAttachment( "BASE_POINT" )
	int startFxId     = GetParticleSystemIndex( TESLA_TRAP_START_FX )
	StartParticleEffectOnEntity( trapProxy, startFxId, FX_PATTACH_POINT_FOLLOW, startAttachID )
//	EmitSoundOnEntity( trapProxy, TESLA_TRAP_ACTIVATE_SOUND )
}

entity function TeslaTrap_CreateServerDamageBeamWithControlPoint( entity trapProxy, asset effect, entity controlPoint, float heightOffset )
{
	vector trapUp     = trapProxy.GetUpVector()
	int attachID  = trapProxy.LookupAttachment( "BASE_POINT" )
	entity beamSystem = StartParticleEffectOnEntityWithPos_ReturnEntity( trapProxy, GetParticleSystemIndex( effect ), FX_PATTACH_POINT_FOLLOW_NOROTATE, attachID, <0, 0, heightOffset>, <0, 0, 0> )

	beamSystem.kv.VisibilityFlags = ENTITY_VISIBLE_TO_NOBODY    // don't start visible
	beamSystem.kv.cpoint1 = controlPoint.GetTargetName()
	beamSystem.SetValueForEffectNameKey( effect )

	return beamSystem
}

vector function TeslaTrap_GetFenceMidpoint( TeslaTrapData mainTrapData, TeslaTrapData otherTrapData )
{
	TeslaTrapLinkFXData linkFXData = mainTrapData.linkFXData[ otherTrapData.id ]
	int beamCount                  = linkFXData.numFXLinks
	float halfCount                = float ( beamCount / 2 ) + 1

	vector mainOffset  = (mainTrapData.trap.GetUpVector() * (halfCount * TESLA_TRAP_LINK_HEIGHT))
	vector otherOffest = (otherTrapData.trap.GetUpVector() * (halfCount * TESLA_TRAP_LINK_HEIGHT))
	vector midpoint    = ((mainTrapData.trap.GetOrigin() + mainOffset) + (otherTrapData.trap.GetOrigin() + otherOffest)) / 2

	return midpoint
}

void function TeslaTrap_HideTrapLinkBeamFX( TeslaTrapData mainTrapData, TeslaTrapData otherTrapData, bool wasObstructed )
{
	//Sleep the Trap FX
	TeslaTrapLinkFXData linkFXData = mainTrapData.linkFXData[ otherTrapData.id ]

	vector origin = TeslaTrap_GetFenceMidpoint( mainTrapData, otherTrapData )

	if ( wasObstructed )
		return

	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, TESLA_TRAP_LINK_OBSTRUCT_SOUND, mainTrapData.trap  )
}

void function TeslaTrap_ShowTrapLinkBeamFX( TeslaTrapData mainTrapData, TeslaTrapData otherTrapData )
{
	//Wake the Trap FX
	//TeslaTrapLinkFXData linkFXData = mainTrapData.linkFXData[ otherTrapData.id ]

	//printt( "showing the tesla beams now " )

	//vector origin = TeslaTrap_GetFenceMidpoint( mainTrapData, otherTrapData )
	//EmitSoundAtPosition( TEAM_UNASSIGNED, origin, TESLA_TRAP_LINK_RECONNECT_SEGMENT_SOUND )
	//EmitSoundAtPosition( TEAM_UNASSIGNED, origin, TESLA_TRAP_LINK_LOOP_SOUND )

	//EmitSoundOnEntity ( mainTrapData.trap, TESLA_TRAP_LINK_RECONNECT_POST_SOUND )
	//EmitSoundOnEntity ( otherTrapData.trap, TESLA_TRAP_LINK_RECONNECT_POST_SOUND )

	//Wake all FX stored in this data
	//foreach ( entity fx in linkFXData.linkFXs )
	{
		//if ( IsValid( fx ) )
		//	EffectWake( fx )
	}
}

void function TeslaTrap_DestroyTrapLinkBeamFX( TeslaTrapData mainTrapData, TeslaTrapData otherTrapData )
{
	vector origin = TeslaTrap_GetFenceMidpoint( mainTrapData, otherTrapData )
	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, TESLA_TRAP_LINK_OBSTRUCT_SOUND, mainTrapData.trap )
	//StopSoundAtPosition( origin, TESLA_TRAP_LINK_LOOP_SOUND )

	//Destroy the Trap FX
	TeslaTrapLinkFXData linkFXData = mainTrapData.linkFXData[ otherTrapData.id ]

	//Destroy all FX stored in this data
	//foreach ( entity fx in linkFXData.linkFXs )
	{
		//if ( IsValid( fx ) )
		//	fx.Destroy()
	}

	foreach ( entity fx in linkFXData.damageFXs )
	{
		if ( IsValid( fx ) )
			fx.Destroy()
	}

	if ( IsValid( linkFXData.linkTrigger ) )
	{
		delete file.linkTriggerData[ linkFXData.linkTrigger ]
		linkFXData.linkTrigger.Destroy()
	}

	//Destroy all control points stored in this data.
	foreach ( entity controlPoint in linkFXData.controlPoints )
	{
		if ( IsValid( controlPoint ) )
			controlPoint.Destroy()
	}

	delete mainTrapData.linkFXData[ otherTrapData.id ]
	delete otherTrapData.linkFXData[ mainTrapData.id ]
}

void function TeslaTrap_SetTeam( entity trap, int newTeam )
{
	if ( IsValid( trap ) )
	{
		SetTeam( trap, newTeam )

		int id = file.activeTrapIds[ trap ]
		TeslaTrapData trapData = file.trapData[ id ]

		array<int> linkedIDs = clone trapData.linkedTrapIDs
		foreach ( int linkedID in linkedIDs )
		{
			TeslaTrapData mainData  = file.trapData[ id ]
			TeslaTrapLinkFXData linkFXData = mainData.linkFXData[ linkedID ]
			SetTeam( linkFXData.linkTrigger, newTeam )
		}
	}
}

void function TeslaTrap_PlayTrapLinkBeamDamageFX( TeslaTrapData mainTrapData, TeslaTrapData otherTrapData )
{
	TeslaTrapLinkFXData linkFXData = mainTrapData.linkFXData[ otherTrapData.id ]
	array<entity> damageFXs
	foreach ( int i, entity damageFX in linkFXData.damageFXs )
	{
		damageFX.Destroy()
		float heightOffset  = TESLA_TRAP_LINK_HEIGHT * (i + 1)
		entity controlPoint = linkFXData.controlPoints[ i ]
		entity newDamageFX  = TeslaTrap_CreateServerDamageBeamWithControlPoint( mainTrapData.trap, TESLA_TRAP_ZAP_FX, controlPoint, heightOffset )
		//newDamageFX.Fire( "Start" )

		damageFXs.append( newDamageFX )
	}

	linkFXData.damageFXs = damageFXs
}

entity function TeslaTrap_CreateLinkTriggerCylinder( TeslaTrapData mainTrapData, TeslaTrapData otherTrapData, int fxCount, array<entity> damageFXs, array<entity> controlPoints )
{
	//Create a trigger cylinder that is oriented such that its height runs the length of the electric link between the two traps.
	vector mainOrigin  = mainTrapData.trap.GetOrigin() + (mainTrapData.trap.GetUpVector() * ((TESLA_TRAP_LINK_HEIGHT * TESLA_TRAP_LINK_FX_COUNT) * 0.5))
	vector otherOrigin = otherTrapData.trap.GetOrigin() + (otherTrapData.trap.GetUpVector() * ((TESLA_TRAP_LINK_HEIGHT * TESLA_TRAP_LINK_FX_COUNT) * 0.5))

	vector offset     = (otherOrigin - mainOrigin)
	vector halfOffset = offset / 2

	//Use the positions of the two traps to determine the dimensions of the trigger cylinder.
	vector offsetDir  = Normalize( offset )
	vector trigOrigin = mainOrigin + halfOffset
	float trigLength  = Length( offset ) / 2
	trigLength += 32

	if ( TESLA_TRAP_DEBUG_DRAW )
	{
		DebugDrawLine( mainOrigin, mainOrigin - (offsetDir * TESLA_TRAP_LINK_TRIGGER_RADIUS), int(COLOR_BLUE.x), int(COLOR_BLUE.y), int(COLOR_BLUE.z), true, 20.0 )
	}

	int attachID      = mainTrapData.trap.LookupAttachment( "BASE_POINT" )
	vector basePos    = mainTrapData.trap.GetAttachmentOrigin( attachID )
	vector toBasePos  = basePos - mainTrapData.trap.GetOrigin()
	float proxyOffset = DotProduct( mainTrapData.trap.GetUpVector(), toBasePos )

	entity trigger = CreateEntity( "trigger_cylinder_heavy" )
	SetTeam( trigger, mainTrapData.trap.GetTeam() )
	trigger.SetOrigin( trigOrigin )
	trigger.SetForwardVectorWithUp( CrossProduct( offsetDir, < 0, 0, 1 > ), offsetDir )
	trigger.SetCylinderRadius( TESLA_TRAP_LINK_TRIGGER_RADIUS )
	trigger.SetAboveHeight( trigLength )
	trigger.SetBelowHeight( trigLength )
	trigger.SetTriggerType( TT_TESLA_TRAP )
	trigger.SetTeslaLink( mainTrapData.trap, otherTrapData.trap, mainTrapData.trap.GetUpVector(), proxyOffset + TESLA_TRAP_LINK_HEIGHT )
	trigger.SetVertOverride( proxyOffset + (fxCount * TESLA_TRAP_LINK_HEIGHT) )
	trigger.kv.triggerFilterNpc = "all"
	trigger.kv.triggerFilterPlayer = "all"
	trigger.kv.triggerFilterNonCharacter = 0

	if ( IsValid( mainTrapData.trap ) )
	{
		trigger.RemoveFromAllRealms()
		trigger.AddToOtherEntitysRealms( mainTrapData.trap )
	}

	DispatchSpawn( trigger )

	//Store the IDs of the traps associated with this trigger so we can retrieve them later.
	TeslaTrapLinkTriggerData triggerData
	triggerData.mainTrapID = mainTrapData.id
	triggerData.otherTrapID = otherTrapData.id
	file.linkTriggerData[ trigger ] <- triggerData

	//Create and store the link FX data.
	TeslaTrapLinkFXData linkFXData
	linkFXData.numFXLinks = fxCount
	linkFXData.damageFXs = damageFXs
	linkFXData.linkTrigger = trigger
	//linkFXData.isObstructed		= true //We start the fx out as obstructed so that we don't play the disconnect audio cue for the first connection.
	linkFXData.controlPoints = controlPoints

	mainTrapData.linkFXData[ otherTrapData.id ] <- linkFXData
	otherTrapData.linkFXData[ mainTrapData.id ]    <- linkFXData

	//Set the enter callback and set the origin and angles of the trigger so it touches entities that are already in the trigger bounds.
	trigger.SetOrigin( trigOrigin )
	trigger.SetForwardVectorWithUp( CrossProduct( offsetDir, < 0, 0, 1 > ), offsetDir )

	trigger.SetParent( mainTrapData.trap )

	entity owner = mainTrapData.trap.GetOwner()
	if ( IsValid( owner ) && !(owner in file.trapTimes) )
	{
		TeslaTrapTimes initTimes
		initTimes.nextDamageTime = 0.0
		initTimes.nextPingTime = 0.0
		initTimes.nextVOTime = 0.0

		file.trapTimes[owner] <- initTimes
	}

	if ( TESLA_TRAP_DEBUG_DRAW )
	{
		 DebugDrawCylinder( trigOrigin, AnglesCompose( trigger.GetAngles(), < 90, 0, 0 > ), trigger.GetRadius(), trigger.GetAboveHeight(), int( COLOR_RED.x ), int( COLOR_RED.y ), int( COLOR_RED.z ), true, 60.0 )
		 DebugDrawCylinder( trigOrigin, AnglesCompose( trigger.GetAngles(), < 90, 0, 0 > ), trigger.GetRadius(), -trigger.GetBelowHeight(), int( COLOR_RED.x ), int( COLOR_RED.y ), int( COLOR_RED.z ), true, 60.0 )
	}

	//Even though the traps are linked, don't activate them right away.
	trigger.SetObstructedEndTime( Time() + TESLA_TRAP_DEPLOY_DELAY )

	thread TeslaTrap_CheckForRealTimeGeoObstructions( mainTrapData, otherTrapData, trigger )

	return trigger
}

void function TeslaTrap_CheckForRealTimeGeoObstructions( TeslaTrapData mainTrapData, TeslaTrapData otherTrapData, entity trigger )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	mainTrapData.trap.EndSignal( "OnDestroy" )
	otherTrapData.trap.EndSignal( "OnDestroy" )
	trigger.EndSignal( "OnDestroy" )

	float waittime = TESLA_TRAP_REACTIVATE_DELAY
	waittime = waittime - 0.1

	while ( true )
	{
		array<entity> ignoreEnts = GetPlayerArray_Alive()
		int count                = mainTrapData.linkFXData[ otherTrapData.id ].numFXLinks

		vector mins = TESLA_TRAP_BOUND_MINS
		vector maxs = TESLA_TRAP_BOUND_MAXS

		maxs.z = count * TESLA_TRAP_LINK_HEIGHT

		//DebugDrawBox( mainTrapData.trap.GetOrigin() + (mainTrapData.trap.GetUpVector() * TESLA_TRAP_LINK_HEIGHT * 0.5), mins, maxs, COLOR_GREEN, 1, 1.0 ) //Forward Hull Cast Bounding Box
		TraceResults hullResults = TraceHull( mainTrapData.trap.GetOrigin() + (mainTrapData.trap.GetUpVector() * TESLA_TRAP_LINK_HEIGHT * 0.5), otherTrapData.trap.GetOrigin() + (otherTrapData.trap.GetUpVector() * TESLA_TRAP_LINK_HEIGHT * 0.5), mins, maxs, ignoreEnts, TRACE_MASK_SOLID | CONTENTS_PLAYERCLIP, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
		if ( hullResults.fraction < 1.0 )
		{
			//printt( "HITTING SOMETHING WITH HULL TRACE " + hullResults.hitEnt )
			if ( IsValid( hullResults.hitEnt ) && ( hullResults.hitEnt.GetNetworkedClassName() == "func_brush" || hullResults.hitEnt.GetNetworkedClassName() == "script_mover" || hullResults.hitEnt.GetNetworkedClassName() == "func_brush_lightweight" ) || hullResults.hitEnt.GetScriptName() == "survival_door_plain" )
			{
				entity parentTo = hullResults.hitEnt
				if ( file.parentToRoot.contains( parentTo.GetScriptName() ) )
				{
					float delay = TESLA_TRAP_REACTIVATE_DELAY
					thread TeslaTrap_SetLinkedTrapsObstructedForDuration( mainTrapData, otherTrapData, delay )
					wait ( delay - 0.2 )
					continue
				}
				else if ( ( hullResults.hitEnt.GetScriptName() == "gondola_func_brush" ) && ( IsGondolaAtStation( hullResults.hitEnt ) ) )
				{
					float gondolaObstructionTime = 8.0
					thread TeslaTrap_SetLinkedTrapsObstructedForDuration( mainTrapData, otherTrapData, gondolaObstructionTime )
					wait ( gondolaObstructionTime )
					continue
				}
				else if ( hullResults.hitEnt.GetScriptName() == "survival_door_plain" )
				{
					float doorObstructionTime = 0.5
					thread TeslaTrap_SetLinkedTrapsObstructedForDuration( mainTrapData, otherTrapData, doorObstructionTime )
					wait ( doorObstructionTime )
					continue
				}
			}
		}

		for ( int i = 1; i <= count; i++ )
		{
			vector startOffset
			vector endOffset
			if ( IsEven( i ) )
			{
				startOffset   = mainTrapData.trap.GetOrigin() + (mainTrapData.trap.GetUpVector() * (TESLA_TRAP_LINK_HEIGHT * i))
				endOffset     = otherTrapData.trap.GetOrigin() + (otherTrapData.trap.GetUpVector() * (TESLA_TRAP_LINK_HEIGHT * i))
			}
			else
			{
				startOffset = otherTrapData.trap.GetOrigin() + (otherTrapData.trap.GetUpVector() * (TESLA_TRAP_LINK_HEIGHT * i))
				endOffset = mainTrapData.trap.GetOrigin() + (mainTrapData.trap.GetUpVector() * (TESLA_TRAP_LINK_HEIGHT * i))
			}

			TraceResults results = TraceLineHighDetail( startOffset, endOffset, ignoreEnts, TESLA_TRAP_TRACE_MASK, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

			if ( TESLA_TRAP_DEBUG_DRAW )
			{
				DebugDrawLine( results.endPos, endOffset, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 20.0 )
				DebugDrawLine( startOffset, results.endPos, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 20.0 )
			}

			//PrintTraceResults( results )

			if ( results.fraction < 1.0 )
			{
				entity hitEnt                  = results.hitEnt
				TeslaTrapLinkFXData linkFXData = mainTrapData.linkFXData[ otherTrapData.id ]
				bool wasObstructed = linkFXData.linkTrigger.GetObstructedEndTime() > Time()
				if ( IsValid( hitEnt ) )
				{
					//Run any special wireline hit callbacks for this entity
					if ( TeslaTrap_EntityHasWirelineHitCallbacks( hitEnt ) && !wasObstructed)
						TeslaTrap_RunEntityWirelineHitCallbacks( hitEnt )

					float disruptionTime = 0.0

					if ( hitEnt.IsWorld() )
						disruptionTime = 1.1
					else if ( hitEnt.GetClassName() == "func_brush" )
						disruptionTime = 1.1
					else if ( (hitEnt.GetClassName() == "prop_door") && (trigger.GetObstructedEndTime() < Time()) )
						hitEnt.TakeDamage( hitEnt.GetMaxHealth(), mainTrapData.trap.GetOwner(), mainTrapData.trap, { origin = hitEnt.GetOrigin(), scriptType = DF_EXPLOSION } )
					else if ( ( hitEnt.GetTargetName() == PASSIVE_REINFORCE_REBUILT_DOOR_SCRIPT_NAME && IsReinforced( hitEnt ) ) && ( trigger.GetObstructedEndTime() < Time() ) )
						hitEnt.TakeDamage( hitEnt.GetMaxHealth() / 8.0, mainTrapData.trap.GetOwner(), mainTrapData.trap, { origin = hitEnt.GetOrigin(), scriptType = DF_EXPLOSION } )

					else if ( hitEnt.GetClassName() == "phys_bone_follower" )
						disruptionTime = 1.1
					else if ( TeslaTrap_EntIsRealTimeObstruction( hitEnt ) )
						disruptionTime = 1.1

					if ( disruptionTime > 0.0001 )
						thread TeslaTrap_SetLinkedTrapsObstructedForDuration( mainTrapData, otherTrapData, disruptionTime )
				}
			}
		}

		wait waittime
	}
}

void function TeslaTrap_CheckForPostIntersection( TeslaTrapData trapData )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	trapData.trap.EndSignal( "OnDestroy" )

	while ( true )
	{
		array<entity> ignoreEnts = GetPlayerArray_Alive()
		ignoreEnts.append( trapData.trap )
		ignoreEnts.append( trapData.trap )
		int count = trapData.maxBeamCount

		int poseIndex    = trapData.trap.LookupPoseParameterIndex( "height" )
		float heightPose = trapData.trap.GetPoseParameter( poseIndex )

		if ( heightPose > 0 )
		{

			int attachID      = trapData.trap.LookupAttachment( "BASE_POINT" )
			vector basePos    = trapData.trap.GetAttachmentOrigin( attachID )

			vector startPos      = basePos //start from top of trap not very bottom incase it clips
			vector endPos        = trapData.trap.GetOrigin() + (trapData.trap.GetUpVector() * (count * TESLA_TRAP_LINK_HEIGHT))
			TraceResults results = TraceLineHighDetail( startPos, endPos, ignoreEnts, TESLA_TRAP_TRACE_MASK, TRACE_COLLISION_GROUP_NONE, trapData.trap )

			if ( TESLA_TRAP_DEBUG_DRAW_POST_INTERSECTION )
			{
				DebugDrawLine( results.endPos, endPos, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 20.0 )
				DebugDrawLine( startPos, results.endPos, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 20.0 )
			}

			if ( results.fraction < 1.0 )
			{
				entity hitEnt = results.hitEnt
				if ( IsValid( hitEnt ) )
				{
					string hitEntClassname = hitEnt.GetClassName()

					if ( hitEntClassname == "phys_bone_follower" || hitEntClassname == "func_brush" || hitEntClassname == "script_mover" || hitEntClassname == "func_brush_lightweight" )
					{
						TeslaTrap_PlayTrapDestroyFX( trapData.trap )
						trapData.trap.Destroy()
					}
				}
			}
		}

		wait 0.25
	}
}

bool function TeslaTrap_EntIsRealTimeObstruction( entity ent )
{
	array<entity> realTimeObstructors = GetScriptManagedEntArray( file.realTimeObstructorArrayIndex )

	if ( realTimeObstructors.contains( ent ) )
		return true

	return false
}

void function TeslaTrap_SetLinkedTrapsObstructedState( TeslaTrapData mainTrapData, TeslaTrapData otherTrapData, bool isObstructed, bool wasObstructed )
{
	//Get old obstruction state.
	TeslaTrapLinkFXData linkFXData = mainTrapData.linkFXData[ otherTrapData.id ]

	//printt( "WAS OBSTRUCTED: " + wasObstructed )
	//printt( "IS OBSTRUCTED: " + isObstructed )

	if ( isObstructed )
		TeslaTrap_HideTrapLinkBeamFX( mainTrapData, otherTrapData, wasObstructed )
	else if ( !isObstructed )
		TeslaTrap_ShowTrapLinkBeamFX( mainTrapData, otherTrapData )

	//linkFXData.isObstructed = isObstructed
}

void function TeslaTrap_SetLinkedTrapsObstructedForDuration( TeslaTrapData mainTrapData, TeslaTrapData otherTrapData, float duration )
{
	Assert( IsNewThread(), "Must be threaded off." )
	TeslaTrapLinkFXData linkFXData = mainTrapData.linkFXData[ otherTrapData.id ]
	linkFXData.linkTrigger.Signal( "TeslaTrap_LinkObstructed" )
	linkFXData.linkTrigger.EndSignal( "TeslaTrap_LinkObstructed" )
	linkFXData.linkTrigger.EndSignal( "OnDestroy" )
	mainTrapData.trap.EndSignal( "OnDestroy" )
	otherTrapData.trap.EndSignal( "OnDestroy" )

	bool wasObstructed = linkFXData.linkTrigger.GetObstructedEndTime() > Time()
	linkFXData.linkTrigger.SetObstructedEndTime( Time() + duration )

	TeslaTrap_SetLinkedTrapsObstructedState( mainTrapData, otherTrapData, true, wasObstructed )
	wait duration
	TeslaTrap_SetLinkedTrapsObstructedState( mainTrapData, otherTrapData, false, true )
}

#endif //SERVER

//This function returns the best focal trap the given trap can link with.
entity function TeslaTrap_CalculateFocalTrap( entity player, entity trap )
{
	TeslaTrapPlayerPlacementData placementData
	placementData.maxLinks = TESLA_TRAP_LINK_COUNT_MAX
	placementData.viewOrigin = player.EyePosition()
	placementData.viewForward = player.GetViewForward()
	placementData.playerOrigin = player.GetOrigin()
	placementData.playerForward = FlattenVec( player.GetViewForward() )

	//Early out with an empty array if we can't link to other traps.
	if ( placementData.maxLinks == 0 )
	{
		entity focalTrap
		return focalTrap
	}

	//Get an array of traps we can link with.
	array<entity> filteredTraps

	int distanceExcluded = 0
	int viewExcluded = 0
	int linkExcluded = 0

	foreach ( entity otherTrap in TeslaTrap_GetAllLinkable( player ) )
	{
		float distSqr = DistanceSqr( player.GetOrigin(), otherTrap.GetOrigin() )
		if ( distSqr > ( ( TESLA_TRAP_LINK_DIST + TESLA_TRAP_LINK_SNAP_DIST ) * ( TESLA_TRAP_LINK_DIST + TESLA_TRAP_LINK_SNAP_DIST ) ) )
		{
			distanceExcluded++
			continue
		}

		float viewRating = TeslaTrap_GetTrapViewRating( placementData, otherTrap )
		//If the trap is not in our view cone and not within snapping range.
		if ( viewRating < TESLA_TRAP_LINK_MIN_VIEW_RATING && distSqr > (TESLA_TRAP_LINK_SNAP_DIST * TESLA_TRAP_LINK_SNAP_DIST ) )
		{
			viewExcluded++
			continue
		}

		//Update the data's sort distance
		TeslaTrapSortingData sortingData = file.trapSortingData[ otherTrap ]
		sortingData.sortingRating = viewRating
		sortingData.distSqr = Distance2DSqr( placementData.playerOrigin, otherTrap.GetOrigin() )

		filteredTraps.append( otherTrap )
	}

	//Early out if we have no traps to link to.
	if ( filteredTraps.len() == 0 )
	{
		if ( TESLA_TRAP_DEBUG_DRAW_PRE_PLACEMENT )
		{
			DebugDrawScreenText( 0.5, 0.4, "TeslaTraps: No focal trap" )
		}
		entity focalTrap
		return focalTrap
	}

	//Sort the filtered traps by view rating.
	filteredTraps.sort( TeslaTrap_LinkTrapSort )

	TeslaTrapPlacementInfo placementInfo = TeslaTrap_GetPlacementInfo( player, trap, true, 0 ) //Don't use fallback positions to save overhead.

	entity focalTrap
	foreach ( entity otherTrap in filteredTraps )
	{
		if ( TeslaTrap_CanLink( trap, placementInfo.origin, AnglesToUp( placementInfo.angles ), otherTrap, placementInfo ) )
		{
			focalTrap = otherTrap
			break
		}
		else
		{
			linkExcluded++
		}
	}

	if ( TESLA_TRAP_DEBUG_DRAW_PRE_PLACEMENT )
	{
		if ( IsValid( focalTrap ) )
			DebugDrawSphere( focalTrap.GetOrigin(), 15, int(COLOR_PINK.x), int(COLOR_PINK.y), int(COLOR_PINK.z), false, 0.1 )
	}

	//printt( "DISTANCE CULLED: " + distanceExcluded )
	//printt( "VIEW CULLED: " + viewExcluded )
	//printt( "LINK CULLED: " + linkExcluded )
	//printt( "TOTAL LINKABLE: " + filteredTraps.len() )

	return focalTrap
}

#if CLIENT
void function TeslaTrap_TrackFocalTrapForPlayer( entity player )
{
	Assert ( IsNewThread(), "Must be threaded off." )

	if ( !IsValid( player ) )
		return

	if ( player != GetLocalViewPlayer() )
		return

	player.Signal( "TeslaTrap_StopFocalTrapUpdate" )
	EndSignal( player, "OnDeath", "OnDestroy", "TeslaTrap_StopFocalTrapUpdate" )

	asset model  = TESLA_TRAP_PROXY_MODEL
	entity proxy = TeslaTrap_CreateTrapPlacementProxy( model )

	while ( true )
	{
		TeslaTrap_UpdateFocalNodeForPlayer( player, proxy )
		WaitFrame()
	}
}
#endif //CLIENT

void function TeslaTrap_UpdateFocalNodeForPlayer( entity player, entity proxy )
{
	//Attempt to link trap to any valid neighbors.
	entity focalTrap = TeslaTrap_CalculateFocalTrap( player, proxy )

	if ( IsValid( focalTrap ) )
	{
		if ( TeslaTrap_GetAll().contains( focalTrap ) )
		{
			TeslaTrap_SetFocalTrapForPlayer( player, focalTrap )
		}
	}
	else
	{
		TeslaTrap_ClearFocalTrapForPlayer( player )
	}
}
/*
 _   _ _____ ___ _     ___ _______   __  _____ _   _ _   _  ____ _____ ___ ___  _   _ ____
| | | |_   _|_ _| |   |_ _|_   _\ \ / / |  ___| | | | \ | |/ ___|_   _|_ _/ _ \| \ | / ___|
| | | | | |  | || |    | |  | |  \ V /  | |_  | | | |  \| | |     | |  | | | | |  \| \___ \
| |_| | | |  | || |___ | |  | |   | |   |  _| | |_| | |\  | |___  | |  | | |_| | |\  |___) |
 \___/  |_| |___|_____|___| |_|   |_|   |_|    \___/|_| \_|\____| |_| |___\___/|_| \_|____/

*/

#if CLIENT
void function TeslaTrap_OnPlayerTeamChanged( entity player, int oldTeam, int newTeam )
{
	foreach( array<int>fxIDs in file.linkFXs_client )
	{
		foreach( int fxID in fxIDs )
		{
			EffectWake( fxID )
		}
	}
}
#endif // #if CLIENT

void function TeslaTrap_SetFocalTrapForPlayer( entity player, entity focalTrap )
{
	if ( player in file.focalTrap )
		file.focalTrap[ player ] = focalTrap
	else
		file.focalTrap[ player ] <- focalTrap

	#if SERVER
		player.SetPlayerNetEnt( "focalTrap", focalTrap )
	#endif //SERVER
}

void function TeslaTrap_ClearFocalTrapForPlayer( entity player )
{
	if ( player in file.focalTrap )
		delete file.focalTrap[ player ]

	#if SERVER
		player.SetPlayerNetEnt( "focalTrap", null )
	#endif //SERVER
}

bool function TeslaTrap_PlayerHasFocalTrap( entity player )
{
	if ( player in file.focalTrap )
	{
		entity focalTrap = file.focalTrap[ player ]
		if ( IsValid( focalTrap ) )
		{
			//Ensure the trap is not flagged for death.
			if ( focalTrap.GetScriptName() == "tesla_trap" )
				return true
		}
	}

	return false
}

entity function TeslaTrap_GetFocalTrapForPlayer( entity player )
{
	entity focalTrap = null
	if ( player in file.focalTrap )
	{
		focalTrap = file.focalTrap[ player ]
	}

	return focalTrap
}

#if CLIENT
void function OnFocusTrapChanged( entity player, entity newEnt )
{
	entity localViewPlayer = GetLocalViewPlayer()
	if ( !IsValid( localViewPlayer ) )
		return

	if ( !IsValid( newEnt ) )
	{
		TeslaTrap_ClearFocalTrapForPlayer( localViewPlayer )
		return
	}

	TeslaTrap_SetFocalTrapForPlayer( localViewPlayer, newEnt )
}
#endif //CLIENT


#if SERVER
bool function TeslaTrap_ShouldPingTarget( entity playerOwner, entity playerTarget )
{
	//If the trap owner is dead, don't ping.
	if ( !IsAlive( playerOwner ) )
		return false

	//If the player who triggered the trap is on the same team as the owner, don't ping.
	if ( IsFriendlyTeam( playerOwner.GetTeam(), playerTarget.GetTeam() ) )
		return false

	return true
}

vector function TeslaTrap_GetPointOnRectangularPlane( TeslaTrapData mainTrapData, TeslaTrapData otherTrapData, vector testPoint )
{
	TeslaTrapLinkFXData linkFXData = mainTrapData.linkFXData[ otherTrapData.id ]
	int fxCount                    = linkFXData.numFXLinks

	//Get point on Tri A
	vector triAPointA  = mainTrapData.trap.GetOrigin() + (mainTrapData.trap.GetUpVector() * TESLA_TRAP_LINK_HEIGHT)
	vector triAPointB  = mainTrapData.trap.GetOrigin() + (mainTrapData.trap.GetUpVector() * (TESLA_TRAP_LINK_HEIGHT * fxCount))
	vector triAPointC  = otherTrapData.trap.GetOrigin() + (otherTrapData.trap.GetUpVector() * TESLA_TRAP_LINK_HEIGHT)
	vector pointOnTriA = GetClosestPointOnPlane( triAPointA, triAPointB, triAPointC, testPoint, true )

	//Get point on Tri B
	vector triBPointA  = otherTrapData.trap.GetOrigin() + (otherTrapData.trap.GetUpVector() * TESLA_TRAP_LINK_HEIGHT)
	vector triBPointB  = otherTrapData.trap.GetOrigin() + (otherTrapData.trap.GetUpVector() * (TESLA_TRAP_LINK_HEIGHT * fxCount))
	vector triBPointC  = mainTrapData.trap.GetOrigin() + (mainTrapData.trap.GetUpVector() * (TESLA_TRAP_LINK_HEIGHT * fxCount))
	vector pointOnTriB = GetClosestPointOnPlane( triBPointA, triBPointB, triBPointC, testPoint, true )

	if ( TESLA_TRAP_DEBUG_DRAW )
	{
		DebugDrawLine( triAPointA, triAPointB, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 20.0 )
		DebugDrawLine( triAPointB, triAPointC, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 20.0 )
		DebugDrawLine( triAPointC, triAPointA, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 20.0 )

		DebugDrawLine( triBPointA, triBPointB, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 20.0 )
		DebugDrawLine( triBPointB, triBPointC, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 20.0 )
		DebugDrawLine( triBPointC, triBPointA, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 20.0 )
	}

	//Return the closer of the two points
	float distSqrA = DistanceSqr( testPoint, pointOnTriA )
	float distSqrB = DistanceSqr( testPoint, pointOnTriB )
	return distSqrA <= distSqrB ? pointOnTriA : pointOnTriB
}

bool function TeslaTrap_IsLinked( TeslaTrapData trapData )
{
	return bool ( trapData.linkedTrapIDs.len() )
}

void function TeslaTrap_WaitForPickup( entity trap )
{
	Assert( IsNewThread(), "Must be threaded off." )

	EndSignal( trap, "OnDestroy", "TeslaTrap_PickedUp" )

	trap.SetUsable()
	trap.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER | USABLE_BY_PILOTS ) //Update hint text every server frame so that we can keep unique client texts up to date.
	trap.SetUsablePriority( USABLE_PRIORITY_LOW )
	trap.SetUsePrompts( "#WPN_TESLA_TRAP_PICKUP", "#WPN_TESLA_TRAP_PICKUP_PC" )
	SetCallback_CanUseEntityCallback( trap, TeslaTrap_CanUse )

	OnThreadEnd(
		function() : ( trap )
		{
			if ( IsValid( trap ) )
			{
				trap.UnsetUsable()
			}
		}
	)

	while( true )
	{
		entity player = expect entity( trap.WaitSignal( "OnPlayerUse" ).player )

		if ( !(trap in file.activeTrapIds) )
			continue

		//Titans cannot interact with tesla trap.
		if ( !IsValid( player ) || player.IsTitan() )
			continue

		entity owner = trap.GetOwner()

		if ( player == owner )
		{
			TeslaTrap_TryPickup( owner, trap )
		}
	}
}

void function TeslaTrap_TryPickup( entity owner, entity trap )
{
	if ( TeslaTrap_PickUp( owner ) )
	{
		int id                 = file.activeTrapIds[ trap ]
		TeslaTrapData trapData = file.trapData[ id ]
		trapData.pickedUp = true
		EmitSoundAtPosition( TEAM_UNASSIGNED, trap.GetOrigin(), TESLA_TRAP_DISSOLVE_SOUND, trap )
		trap.Signal( "TeslaTrap_PickedUp" )
	}
}

bool function TeslaTrap_PickUp( entity player )
{
	entity weapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )

	string className = weapon.GetWeaponClassName()
	if ( className != TESLA_TRAP_WEAPON_NAME )
		return false

	Weapon_AddSingleCharge( weapon )
	weapon.StartCustomActivity( "ACT_VM_PICKUP", WCAF_ISINTERRUPTIBLE )
	//printt( "TESLA TRAP PICKED UP." )

	return true
}

void function TeslaTrap_ReleasePickup( entity player )
{
	if ( player in file.playerPickupLocked )
		delete file.playerPickupLocked[ player ]
}

void function TeslaTrap_AttemptRemotePickup( entity player )
{
	if ( !TeslaTrap_PlayerHasFocalTrap( player ) )
		return

	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( !IsValid( weapon ) )
		return

	string className = weapon.GetWeaponClassName()

	//printt( className )

	if ( className != TESLA_TRAP_WEAPON_NAME )
		return

	entity focalTrap = TeslaTrap_GetFocalTrapForPlayer( player )

	if ( !IsValid( focalTrap ) )
		return

	if ( !(focalTrap in file.activeTrapIds) )
		return

	entity owner = focalTrap.GetOwner()

	if ( player == owner )
	{

		if ( player in file.playerPickupLocked )
			return

		asset model                          = TESLA_TRAP_PROXY_MODEL
		entity proxy                         = TeslaTrap_CreateTrapPlacementProxy( model )
		TeslaTrapPlacementInfo placementInfo = TeslaTrap_GetPlacementInfo( player, proxy )

		float distSqr = DistanceSqr( placementInfo.origin, focalTrap.GetOrigin() )
		if ( distSqr > (file.balance_teslaTrapRange * file.balance_teslaTrapRange) )
			return

		if ( TeslaTrap_PickUp( player ) )
		{
			int id                 = file.activeTrapIds[ focalTrap ]
			TeslaTrapData trapData = file.trapData[ id ]
			trapData.pickedUp = true
			focalTrap.Signal( "TeslaTrap_PickedUp" )

			file.playerPickupLocked[ player ] <- true
		}
	}
}

void function TeslaTrap_OnPropScriptSpawned( entity ent )
{
	switch ( ent.GetScriptName() )
	{
		case "tesla_trap":
			TeslaTrapSortingData sortingData
			file.trapSortingData[ ent ] <- sortingData

			AddEntityCallback_OnKilled( ent, TeslaTrap_OnKilled )

			AddToScriptManagedEntArray( file.scriptManagedTrapArrayID, ent )
			break
	}
}

void function TeslaTrap_OnKilled( entity ent, var damageInfo )
{
	delete file.trapSortingData[ ent ]
}

void function TeslaTrap_OnWinnerDetermined()
{
	foreach(entity trap, int i in clone file.activeTrapIds)
	{
		if(!IsValid(trap))
			continue
		Signal( trap, "TeslaTrap_PickedUp" )
	}
}
#endif //SERVER

int function TeslaTrap_LinkTrapSort( entity trapA, entity trapB )
{
	TeslaTrapSortingData trapASort = file.trapSortingData[ trapA ]
	TeslaTrapSortingData trapBSort = file.trapSortingData[ trapB ]

	if ( trapASort.sortingRating < trapBSort.sortingRating )
		return 1
	else if ( trapASort.sortingRating > trapBSort.sortingRating )
		return -1
	return 0
}

int function TeslaTrap_LinkMultiTrapSort( entity trapA, entity trapB )
{
	TeslaTrapSortingData trapASort = file.trapSortingData[ trapA ]
	TeslaTrapSortingData trapBSort = file.trapSortingData[ trapB ]

	if ( trapASort.distSqr < trapBSort.distSqr )
		return 1
	else if ( trapASort.distSqr > trapBSort.distSqr )
		return -1
	return 0
}

float function TeslaTrap_GetTrapViewRating( TeslaTrapPlayerPlacementData mainPlacementData, entity otherTrap )
{
	vector otherOrigin   = otherTrap.GetOrigin()
	vector viewToOther   = Normalize( otherOrigin - mainPlacementData.viewOrigin )
	vector playerToOther = Normalize( otherOrigin - mainPlacementData.playerOrigin )

	//DebugDrawLine( mainPlacementData.viewOrigin, mainPlacementData.viewOrigin + ( viewToOther * 128 ), int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 0.1 )
	//DebugDrawLine( mainPlacementData.viewOrigin, mainPlacementData.viewOrigin + ( mainPlacementData.viewForward * 128 ), int(COLOR_WHITE.x), int(COLOR_WHITE.y), int(COLOR_WHITE.z), true, 0.1 )
	//DebugDrawLine( mainPlacementData.playerOrigin, mainPlacementData.playerOrigin + ( playerToOther * 128 ), int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 0.1 )
	//DebugDrawLine( mainPlacementData.playerOrigin, mainPlacementData.playerOrigin + ( mainPlacementData.playerForward * 128 ), int(COLOR_WHITE.x), int(COLOR_WHITE.y), int(COLOR_WHITE.z), true, 0.1 )

	//Get a rating based on how close the trap is to the direction the player is looking.
	float viewDot    = DotProduct( viewToOther, mainPlacementData.viewForward )
	float viewRating = GraphCapped( viewDot, -1.0, 1.0, 0.0, 1.0 )

	return viewDot

	//Get a rating based on how close the trap is to the direction the player's body is facing.
	float feetDot    = DotProduct2D( playerToOther, mainPlacementData.playerForward )
	float feetRating = GraphCapped( feetDot, -1.0, 1.0, 0.0, 1.0 )

	//Bias towards feet direction as player looks downward.
	float weightDot  = DotProduct( <0, 0, -1>, mainPlacementData.viewForward )
	float feetWeight = GraphCapped( weightDot, 0.5, 0.85, 0.0, 1.0 )
	float viewWeight = 1.0 - feetWeight

	/*
	printt( "" )
	printt( "FEET WEIGHT: " + feetWeight )
	printt( "VIEW WEIGHT: " + viewWeight )
	*/

	feetRating *= feetWeight
	viewRating *= viewWeight

	/*
	printt( "FEET RATING: " + feetRating )
	printt( "VIEW RATING: " + viewRating )
	*/

	return (viewRating + feetRating)
}

bool function TeslaTrap_CanUse( entity player, entity ent, int useFlags )
{
	if ( Bleedout_IsBleedingOut( player ) )
		return false

	if ( player.IsPhaseShifted() )
		return false

	return true
}

array<entity> function TeslaTrap_GetAll()
{
	#if SERVER
		array<entity> allTraps = GetScriptManagedEntArray( file.scriptManagedTrapArrayID )
		return allTraps
	#elseif CLIENT
		array<entity> allTraps = file.allTraps
		return allTraps
	#endif
}

array<entity> function TeslaTrap_GetAllLinkable( entity player )
{
	#if SERVER
		array<entity> allTraps = GetScriptManagedEntArray( file.scriptManagedTrapArrayID )
		array<entity> linkableTraps
		foreach ( entity trap in allTraps )
		{
			if ( !trap.DoesShareRealms( player ) )
				continue

			if ( trap.GetLinkEntArray().len() < TESLA_TRAP_LINK_COUNT_MAX )
				linkableTraps.append( trap )
		}
		return linkableTraps
	#elseif CLIENT
		array<entity> allTraps = file.allTraps
		array<entity> linkableTraps
		foreach ( entity trap in allTraps )
		{
			if ( !trap.DoesShareRealms( player ) )
				continue

			if ( trap.GetLinkEntArray().len() < TESLA_TRAP_LINK_COUNT_MAX )
				linkableTraps.append( trap )
		}
		return linkableTraps
	#endif
}

array<entity> function TeslaTrap_GetAllDead()
{
	#if SERVER
		array<entity> allTraps = GetScriptManagedEntArray( file.scriptManagedTrapArrayID )
		array<entity> deadTraps
		foreach ( entity trap in allTraps )
		{
			if ( trap.GetScriptName() == "tesla_trap_dead" )
				deadTraps.append( trap )
		}
		return deadTraps
	#elseif CLIENT
		array<entity> allTraps = file.allTraps
		array<entity> deadTraps
		foreach ( entity trap in allTraps )
		{
			if ( trap.GetScriptName() == "tesla_trap_dead" )
				deadTraps.append( trap )
		}
		return deadTraps
	#endif
}

#if CLIENT
void function TeslaTrap_MaxDistanceAutoCancelUpdate( entity player )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	player.Signal( "TeslaTrap_StopFocalTrapCancelUpdate" )
	EndSignal( player, "OnDeath", "OnDestroy", "TeslaTrap_StopFocalTrapCancelUpdate" )

	asset model  = TESLA_TRAP_PROXY_MODEL
	entity proxy = TeslaTrap_CreateTrapPlacementProxy( model )

	while ( true )
	{
		if ( TeslaTrap_PlayerHasFocalTrap( player ) )
		{
			entity focalTrap                     = TeslaTrap_GetFocalTrapForPlayer( player )
			float playerDistSqr                    = DistanceSqr( focalTrap.GetOrigin(), player.GetOrigin() )
			if ( playerDistSqr >= (TESLA_TRAP_LINK_CANCEL_DIST * TESLA_TRAP_LINK_CANCEL_DIST) )
			{
				TeslaTrapPlacementInfo placementInfo = TeslaTrap_GetPlacementInfo( player, proxy, false, 0 )//Don't allow fallbacks on this check to reduce client overhead.
				float trapDistSqr                    = DistanceSqr( focalTrap.GetOrigin(), placementInfo.origin )
				if ( trapDistSqr >= (TESLA_TRAP_LINK_CANCEL_DIST * TESLA_TRAP_LINK_CANCEL_DIST) )
					player.ClientCommand( "invnext" )
			}
		}

		WaitFrame()
	}
}

void function TeslaTrap_OntriggerCreated( entity trigger )
{
	if ( trigger.GetTriggerType() != TT_TESLA_TRAP )
		return

	//printt( "TT: TeslaTrap_OntriggerCreated" )
	//printt( trigger.GetTeslaTrapStart(), trigger.GetTeslaTrapEnd() )

	entity startTrap = trigger.GetTeslaTrapStart()
	entity endTrap = trigger.GetTeslaTrapEnd()

	CreateTrapMinimapData( startTrap )
	CreateTrapMinimapData( endTrap )

	// add triggers from trap data
	file.trapMinimapData[ startTrap ].triggerArray.append( trigger )
	Assert( file.trapMinimapData[ startTrap ].triggerArray.len() <= 2 )

	file.trapMinimapData[ endTrap ].triggerArray.append( trigger )
	Assert( file.trapMinimapData[ endTrap ].triggerArray.len() <= 2 )

	thread RefreshTrapTriggerMinimapConnection( startTrap )
	thread RefreshTrapTriggerMinimapConnection( endTrap )
}

void function TeslaTrap_OntriggerDestroyed( entity trigger )
{
	if ( trigger.GetTriggerType() != TT_TESLA_TRAP )
		return

	//printt( "TT: TeslaTrap_OntriggerDestroyed" )
	//printt( trigger.GetTeslaTrapStart(), trigger.GetTeslaTrapEnd() )

	entity startTrap = trigger.GetTeslaTrapStart()
	entity endTrap = trigger.GetTeslaTrapEnd()

	// remove triggers from trap data
	if ( startTrap in file.trapMinimapData )
		file.trapMinimapData[ startTrap ].triggerArray.fastremovebyvalue( trigger )
	if ( endTrap in file.trapMinimapData )
		file.trapMinimapData[ endTrap ].triggerArray.fastremovebyvalue( trigger )

	thread RefreshTrapTriggerMinimapConnection( startTrap )
	thread RefreshTrapTriggerMinimapConnection( endTrap )
}

                        
                                                 
 
                       
        

                                     
                          
        

                                                                       
  
                                                               
                             
  
 

                                                 
 
                              
 
      

void function TeslaTrap_OnPropScriptCreated( entity ent )
{
	switch ( ent.GetScriptName() )
	{
		case "tesla_trap":

			TeslaTrapSortingData sortingData
			file.trapSortingData[ ent ] <- sortingData

			CreateTrapMinimapData( ent )

			SetAllowForKillreplayProjectileCam( ent )
			SetCustomKillreplayChaseCamFromWeaponClass( ent, TESLA_TRAP_WEAPON_NAME )

			file.allTraps.append( ent )
			thread TeslaTrap_CreateHUDMarker( ent )
			AddEntityCallback_GetUseEntOverrideText( ent, TeslaTrap_UseTextOverride )
			SetCallback_CanUseEntityCallback( ent, TeslaTrap_CanUse )
			break
	}
}

void function TeslaTrap_OnPropScriptDestroyed( entity ent )
{
	DestroyTrapMinimapData( ent )

	if ( file.allTraps.contains( ent ) )
		file.allTraps.fastremovebyvalue( ent )
	if ( ent in file.trapSortingData )
		delete file.trapSortingData[ ent ]
}

void function CreateTrapMinimapData( entity trap )
{
	if(!IsValid(trap))
		return

	//printt( "CreateTrapMinimapData", trap )
	if ( trap in file.trapMinimapData )
		return

	//printt( "Added to trapMinimapData table", trap )
	TrapMinimapData data
	file.trapMinimapData[ trap ] <- data
}

void function DestroyTrapMinimapData( entity trap )
{
	if ( !(trap in file.trapMinimapData) )
		return

	delete file.trapMinimapData[ trap ]
}

array<entity> function TeslaTrap_AttemptTrapLinkOnClient( entity trap, entity otherTrap, TeslaTrapPlacementInfo placementInfo )
{
	array<entity> linkTraps
	if ( TeslaTrap_CanLink( trap, trap.GetOrigin(), trap.GetUpVector(), otherTrap, placementInfo ) )
		linkTraps.append( otherTrap )

	return linkTraps
}

void function TeslaTrap_CreateHUDMarker( entity trap )
{
	entity localClientPlayer = GetLocalClientPlayer()

	trap.EndSignal( "OnDestroy" )
	localClientPlayer.EndSignal( "OnDestroy" )

	if ( !TeslaTrap_ShouldShowIcon( localClientPlayer, trap ) )
		return

	int attachment = trap.LookupAttachment( "REF" )
	vector pos     = trap.GetOrigin() + (trap.GetUpVector() * TESLA_TRAP_ICON_HEIGHT)
	var rui        = CreateCockpitRui( $"ui/tesla_trap_marker_icons.rpak", 0 )
	RuiTrackFloat3( rui, "pos", trap, RUI_TRACK_POINT_FOLLOW, attachment )
	RuiSetBool( rui, "linkMode", false )
	RuiTrackInt( rui, "teamRelation", trap, RUI_TRACK_TEAM_RELATION_VIEWPLAYER )
	RuiKeepSortKeyUpdated( rui, true, "pos" )

	asset icon = $"rui/menu/boosts/boost_icon_tesla_trap"
	RuiSetImage( rui, "iconImage", icon )

	file.trapRui[ trap ] <- rui

	OnThreadEnd(
		function() : ( rui, trap )
		{
			if ( IsValid( trap ) )
				delete file.trapRui[ trap ]

			RuiDestroy( rui )
		}
	)

	WaitForever()
}

void function TeslaTrap_UpdateHudMarkers( entity localClientPlayer )
{
	//printt( "TT: TeslaTrap_UpdateHudMarkers", localClientPlayer, GetLocalClientPlayer() )

	localClientPlayer.Signal( "TeslaTrap_StopHudIconUpdate" )
	localClientPlayer.EndSignal( "OnDestroy" )
	localClientPlayer.EndSignal( "TeslaTrap_StopHudIconUpdate" )

	asset icon = $"rui/menu/boosts/boost_icon_tesla_trap"

	OnThreadEnd(
		function() : ()
		{
			foreach ( entity trap, var rui in file.trapRui )
			{
				if ( IsValid( trap ) )
				{
					RuiSetBool( rui, "shouldDraw", false )
					RuiSetBool( rui, "extendMode", false )
				}
			}
		}
	)

	while ( true )
	{
		entity localViewPlayer = GetLocalViewPlayer()
		array<entity> traps = TeslaTrap_GetAll()
		entity focalTrap = TeslaTrap_GetFocalTrapForPlayer( localViewPlayer )
		entity weapon = localViewPlayer.GetOffhandWeapon( OFFHAND_TACTICAL )

		foreach ( entity trap, var rui in file.trapRui )
		{
			if ( !IsValid( trap ) )
				continue

			//if ( trap.GetScriptName() == "tesla_trap_dead" )
			//	continue

			if ( trap.GetTeam() != localViewPlayer.GetTeam() )
				continue

			//TO DO: MAKE THIS CHANGE WHEN THE FOCAL TRAP NETWORK VAR IS CHANGED RATHER THAN POLLING EVERY FRAME.
			if ( !IsValid( weapon ) || weapon.GetWeaponClassName() != TESLA_TRAP_WEAPON_NAME || trap.GetLinkEntArray().len() >= TESLA_TRAP_LINK_COUNT_MAX )
			{
				//icon = $"rui/menu/boosts/boost_icon_tesla_trap_link"
				RuiSetImage( rui, "iconImage", icon )
				RuiSetBool( rui, "shouldDraw", false )
				RuiSetBool( rui, "extendMode", false )
			}
			else if ( focalTrap == trap )
			{
				if ( Bleedout_IsBleedingOut( localViewPlayer ) )
				{
					//icon = $"rui/menu/boosts/boost_icon_tesla_trap_link"
					RuiSetImage( rui, "iconImage", icon )
					RuiSetBool( rui, "shouldDraw", false )
					RuiSetBool( rui, "extendMode", false )
				}
				else if ( weapon.GetWeaponClassName() == TESLA_TRAP_WEAPON_NAME )
				{
					//icon = $"rui/menu/boosts/boost_icon_tesla_trap_link"
					RuiSetImage( rui, "iconImage", icon )
					RuiSetBool( rui, "shouldDraw", true )
					RuiSetBool( rui, "extendMode", true )
				}
				else
				{
					//icon = $"rui/menu/boosts/boost_icon_tesla_trap_link"
					RuiSetImage( rui, "iconImage", icon )
					RuiSetBool( rui, "shouldDraw", true )
					RuiSetBool( rui, "extendMode", false )
				}
			}
			else
			{
				if ( Bleedout_IsBleedingOut( localViewPlayer ) )
				{
					//icon = $"rui/menu/boosts/boost_icon_tesla_trap"
					RuiSetImage( rui, "iconImage", icon )
					RuiSetBool( rui, "shouldDraw", false )
					RuiSetBool( rui, "linkMode", false )
					RuiSetBool( rui, "extendMode", false )
				}
				else
				{
					//icon = $"rui/menu/boosts/boost_icon_tesla_trap"
					RuiSetImage( rui, "iconImage", icon )
					RuiSetBool( rui, "shouldDraw", true )
					RuiSetBool( rui, "linkMode", false )
					RuiSetBool( rui, "extendMode", false )
				}
			}

			// is this trap the reacl trap
			RuiSetBool( rui, "recalPossible", trap == file.recalTrap )
		}

		WaitFrame()
	}
}

bool function TeslaTrap_ShouldShowIcon( entity localPlayer, entity trapProxy )
{
	if ( !GamePlayingOrSuddenDeath() )
		return false

	//if ( IsWatchingReplay() )
	//	return false

	if ( IsEnemyTeam( localPlayer.GetTeam(), trapProxy.GetTeam() ) )
		return false

	return true
}

string function TeslaTrap_UseTextOverride( entity ent )
{
	entity player = GetLocalViewPlayer()

	if ( player.IsTitan() )
		return "#WPN_DIRTY_BOMB_NO_INTERACTION"

	if ( player == ent.GetOwner() )
	{
		return ""
	}

	return "#WPN_DIRTY_BOMB_NO_INTERACTION"
}

int function TeslaTrap_GetOwnedLivingTrapCountOnClient( entity player )
{
	int count
	array<entity> traps = TeslaTrap_GetAll()
	foreach ( entity trap in traps )
	{
		if ( trap.GetScriptName() == "tesla_trap_dead" )
			continue

		if ( trap.GetOwner() == player )
			count++
	}

	return count
}

void function TeslaTrap_CreateClientEffects( entity trigger, entity start, entity end, int actualBeamCount )
{
	int triggerFXID = trigger.GetTeslaLinkFXIdx()

	int fxIDTeam = GetParticleSystemIndex( TESLA_TRAP_LINK_FX )
	int fxIDEnemy = GetParticleSystemIndex( TESLA_TRAP_LINK_ENEMY_FX )
	vector colorFriendly = GetKeyColor( COLORID_FRIENDLY )
	vector colorEnemy = GetKeyColor( COLORID_ENEMY )

	vector startUp = start.GetUpVector()
	vector endUp   = end.GetUpVector()

	for ( int i = 1; i <= actualBeamCount; i++ )
	{
		float heightOffset = TESLA_TRAP_LINK_HEIGHT * i

		//DebugDrawLine( startOrigin, startOrigin + (startUp * TESLA_TRAP_LINK_HEIGHT), int(COLOR_BLUE.x), int(COLOR_BLUE.y), int(COLOR_BLUE.z), true, 20.0 )

		int fxIdxTeam = StartParticleEffectOnEntityWithPos( start, fxIDTeam, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, (startUp * (heightOffset + file.proxyBaseOffset)), <0, 0, 0> )
		EffectSetPlayFriendlyOnly( fxIdxTeam )
		EffectSetDontKillForReplay( fxIdxTeam )
		EffectAddTrackingForControlPoint( fxIdxTeam, 1, end, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, (endUp * (heightOffset + file.proxyBaseOffset)) )
		EffectSetControlPointVector( fxIdxTeam, 2, colorFriendly )

		int fxIdxEnemy = StartParticleEffectOnEntityWithPos( start, fxIDEnemy, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, (startUp * (heightOffset + file.proxyBaseOffset)), <0, 0, 0> )
		EffectSetPlayEnemyOnly( fxIdxEnemy )
		EffectSetDontKillForReplay( fxIdxEnemy )
		EffectAddTrackingForControlPoint( fxIdxEnemy, 1, end, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, (endUp * (heightOffset + file.proxyBaseOffset)) )
		EffectSetControlPointVector( fxIdxEnemy, 2, colorEnemy )

		file.linkFXs_client[triggerFXID].append( fxIdxTeam )
		file.linkFXs_client[triggerFXID].append( fxIdxEnemy )
	}
}

void function ClientCodeCallback_TeslaTrapLinked( entity trigger, entity start, entity end )
{
	if ( !IsValid( trigger ) ) //This can happen now that this is a deferred callback
		return
	thread TeslaTrap_CreateClientTeslaTrapEffects( trigger, start, end )
}

void function TeslaTrap_CreateClientTeslaTrapEffects( entity trigger, entity start, entity end )
{
	EndSignal( trigger, "OnDestroy" )
	EndSignal( start, "OnDestroy" )
	EndSignal( end, "OnDestroy" )

	int finalBeamCount = int( trigger.GetTeslaTrapHeight() / TESLA_TRAP_LINK_HEIGHT )
	//printt( "FINALBEAMCOUNT: " + finalBeamCount )

	if ( finalBeamCount == 0 )
		return

	WaitFrame()

	if ( file.proxyBaseOffset == -1.0 )
	{
		entity localViewPlayer 	= GetLocalViewPlayer()
		asset model           	= TESLA_TRAP_PROXY_MODEL
		entity proxy       		= TeslaTrap_CreateTrapPlacementProxy( model )

		int attachID      = proxy.LookupAttachment( "BASE_POINT" )
		vector basePos    = proxy.GetAttachmentOrigin( attachID )
		float proxyOffset = basePos.z - proxy.GetOrigin().z
		file.proxyBaseOffset = proxyOffset
	}

	//printt( "proxyOffset " + proxyOffset )
	//printt( "height of the trap " + trigger.GetTeslaTrapHeight() )

	int actualBeamCount = int( ceil( trigger.GetTeslaTrapHeight() - file.proxyBaseOffset ) / TESLA_TRAP_LINK_HEIGHT )
	//printt( "actual beam count is " + actualBeamCount )

	int currentFXID = file.currentFXID++
	trigger.SetTeslaLinkFXIdx( currentFXID )

	if ( !(currentFXID in file.linkFXs_client) )
		file.linkFXs_client[currentFXID] <- []

	int halfCount   = finalBeamCount / 2
	entity clientAG = CreateClientSideAmbientGeneric( start.GetOrigin(), TESLA_TRAP_LINK_LOOP_SOUND, 0 )
	SetTeam( clientAG, trigger.GetTeam() )
	clientAG.SetSegmentEndpoints( start.GetOrigin() + (start.GetUpVector() * (halfCount * TESLA_TRAP_LINK_HEIGHT)), end.GetOrigin() + (end.GetUpVector() * (halfCount * TESLA_TRAP_LINK_HEIGHT)) )
	clientAG.SetEnabled( true )
	clientAG.RemoveFromAllRealms()
	clientAG.AddToOtherEntitysRealms( trigger )
	file.linkAGs_client[ currentFXID ] <- clientAG

	bool startObstructed = (trigger.GetObstructedEndTime() > Time())

	if ( startObstructed )
	{
		trigger.SetObstructedEndTime( trigger.GetObstructedEndTime() )
		clientAG.SetEnabled( false )
	}
	else
	{
		TeslaTrap_CreateClientEffects( trigger, start, end, actualBeamCount )
	}

	WaitFrame()
}

void function RegisterTeslaTrapMinimapRui( entity trapEnt, var rui )
{
	// trap got deleted in the same frame as it got created.
	if ( trapEnt.GetScriptName() != "tesla_trap" )
		return

	Assert( trapEnt in file.trapMinimapData )
	file.trapMinimapData[ trapEnt ].ruiArray.append( rui )
}

void function RefreshTrapTriggerMinimapConnection( entity trap )
{
	AssertIsNewThread()

	//printt( "TT: RefreshTrapTriggerMinimapConnection", trap )
	if ( !IsValid( trap ) )
		return

	EndSignal( trap, "OnDestroy" )

	WaitFrame()

	// fix for R5DEV-119031.
	// Not sure how file.trapMinimapData didn't have the trap in it, and the EndSignal not having ended the tread, but it seems to have happened some how.
	if ( !( trap in file.trapMinimapData ) )
		return

	int linkCount = file.trapMinimapData[ trap ].triggerArray.len()

	for ( int index = 0; index < 2; index++ )
	{
		entity _trigger
		if ( file.trapMinimapData[ trap ].triggerArray.len() > index )
			_trigger = file.trapMinimapData[ trap ].triggerArray[ index ]

		// only enable minimap links if the trap is the startTrap and there is a trigger associated with this trap
		bool enabled = ( IsValid( _trigger ) && _trigger.GetTeslaTrapEnd() != trap )

		//printt( "TT: link", (index+1), "is", enabled )
		foreach( rui in file.trapMinimapData[ trap ].ruiArray )
		{
			// link1EndPos
			// link1Enabled
			if ( enabled )
				RuiTrackFloat3( rui, "link" + (index+1) + "EndPos", _trigger.GetTeslaTrapEnd(), RUI_TRACK_ABSORIGIN_FOLLOW )
			RuiSetBool( rui, "link" + (index+1) + "Enabled", enabled )
		}
	}

	//printt( "TT: trap link count", trap, linkCount )
	foreach( rui in file.trapMinimapData[ trap ].ruiArray )
	{
		RuiSetInt( rui, "linkCount", linkCount )
	}
}

void function UpdateTrapTriggerMinimapConnection( entity trigger, bool isVisible )
{
	//printt( "TT: UpdateTrapTriggerMinimapConnection", trigger, isVisible, trigger.GetTeslaTrapStart(), trigger.GetTeslaTrapEnd() )

	entity startTrap = trigger.GetTeslaTrapStart()

	if ( !( startTrap in file.trapMinimapData ) )
	{
		// start trap didn't exist in the table so it's either not been created yet or just removed. In either case we can just return here and nothing bad should come of it.
		return
	}

	foreach ( index, _trigger in file.trapMinimapData[ startTrap ].triggerArray )
	{
		if ( trigger != _trigger )
			continue

		foreach( rui in file.trapMinimapData[ startTrap ].ruiArray )
		{
			// link1Enabled
			RuiSetBool( rui, "link" + (index+1) + "Enabled", isVisible )
		}
	}
}

void function ClientCodeCallback_TeslaTrapVisibilityChanged( entity trigger, entity start, entity end, bool isVisible, int fxIdx )
{
	int triggerFXID = fxIdx
	if ( triggerFXID < 0 )
		return

	if ( !IsValid( start ) || !IsValid( end ) ) //trap must have been destroyed
	{
		if ( triggerFXID in file.linkFXs_client )
		{
			foreach( int fxID in file.linkFXs_client[triggerFXID] )
				EffectStop( fxID, false, true )

			delete file.linkFXs_client[triggerFXID]
		}

		if ( triggerFXID in file.linkAGs_client )
		{
			//Clean up ambient generic sound
			entity ambientGeneric = file.linkAGs_client[ triggerFXID ]

			if ( IsValid( ambientGeneric ) )
				ambientGeneric.Destroy()
			delete file.linkAGs_client[ triggerFXID ]
		}
		return
	}

	if ( !IsValid( trigger ) )
		return

	Assert( trigger )
	UpdateTrapTriggerMinimapConnection( trigger, isVisible )

	if ( isVisible )
	{
		//printt( "make effects visible" )
		int actualBeamCount = int( ceil( trigger.GetTeslaTrapHeight() - file.proxyBaseOffset ) / TESLA_TRAP_LINK_HEIGHT )
		TeslaTrap_CreateClientEffects( trigger, start, end, actualBeamCount )

		if ( triggerFXID in file.linkAGs_client )
		{
			entity ambientGeneric = file.linkAGs_client[ triggerFXID ]
			if ( IsValid( ambientGeneric ) )
				ambientGeneric.SetEnabled( true )
		}

		vector origin = trigger.GetOrigin()
		EmitSoundAtPosition( TEAM_UNASSIGNED, origin, TESLA_TRAP_LINK_RECONNECT_SEGMENT_SOUND )

		entity localViewPlayer = GetLocalViewPlayer()

		if ( localViewPlayer.GetTeam() == start.GetTeam() )
			EmitSoundOnEntity( start, TESLA_TRAP_LINK_RECONNECT_POST_SOUND )
		else
			EmitSoundOnEntity( start, TESLA_TRAP_LINK_RECONNECT_POST_ENEMY_SOUND )

		if ( localViewPlayer.GetTeam() == end.GetTeam() )
			EmitSoundOnEntity( end, TESLA_TRAP_LINK_RECONNECT_POST_SOUND )
		else
			EmitSoundOnEntity( end, TESLA_TRAP_LINK_RECONNECT_POST_ENEMY_SOUND )
	}
	else
	{
		// this doesn't seem to ever happen. when IsVisible in false, start and end thend to be not valid, so the function returns earlier above.
		foreach( int fxID in file.linkFXs_client[triggerFXID] )
			EffectStop( fxID, false, true )

		file.linkFXs_client[triggerFXID] <- []

		if ( triggerFXID in file.linkAGs_client )
		{
			entity ambientGeneric = file.linkAGs_client[ triggerFXID ]
			if ( IsValid( ambientGeneric ) )
				ambientGeneric.SetEnabled( false )
		}
	}
}

vector function OnModifyDamageFlyout( entity ent, vector pos )
{
	return ( pos - < 0, 0, ent.GetBoundingMaxs().z * 0.8 > )
}
#endif // #if CLIENT

bool function TrippedEntIsFriendly( entity crossingEnt, entity trapStart )
{
	int trapTeam = trapStart.GetTeam()
	if ( IsFriendlyTeam( crossingEnt.GetTeam(), trapTeam ) )
		return true

	if ( crossingEnt == trapStart.GetOwner() )
		return true

	                     
	if ( EntIsHoverVehicle( crossingEnt ) && !HoverVehicle_IsHostileToTeam( crossingEnt, trapTeam ) )
		return true
                            

	return false
}

bool function TrippedEntIsFriendlyObstructionType( entity crossingEnt )
{
	if ( crossingEnt.IsPlayer() )
		return true
	if ( crossingEnt.IsPlayerDecoy() )
		return true
	return false
}

void function CodeCallback_TeslaTrapCrossed( entity trigger, entity start, entity end, entity crossingEnt )
{
	#if SERVER
		entity owner = start.GetOwner()
		if ( TrippedEntIsFriendly( crossingEnt, start ) )
		{
			if ( trigger.GetObstructedEndTime() < Time() )
			{
				if ( crossingEnt.IsPlayer() )
					EmitSoundAtPositionExceptToPlayer( TEAM_UNASSIGNED, trigger.GetOrigin(), crossingEnt, TESLA_TRAP_LINK_OBSTRUCT_SOUND )
				else if ( crossingEnt.IsPlayerDecoy() )
					EmitSoundAtPosition( TEAM_UNASSIGNED, trigger.GetOrigin(), TESLA_TRAP_LINK_OBSTRUCT_SOUND, trigger )
			}

			if ( TrippedEntIsFriendlyObstructionType( crossingEnt ) )
			{
				float delay = TESLA_TRAP_REACTIVATE_DELAY
				trigger.SetObstructedEndTime( Time() + delay )
			}
			return
		}

		if ( trigger.GetObstructedEndTime() > Time() )
			return

		if ( !(crossingEnt in file.trapTimes) )
		{
			TeslaTrapTimes initTimes
			initTimes.nextDamageTime = 0.0
			initTimes.nextPingTime = 0.0
			initTimes.nextVOTime = 0.0

			file.trapTimes[crossingEnt] <- initTimes
		}

		if ( IsValid( owner ) && file.trapTimes[owner].nextVOTime < Time() && ( crossingEnt.IsPlayer() || crossingEnt.IsPlayerDecoy() ) )
		{
			file.trapTimes[owner].nextVOTime = Time() + TESLA_TRAP_PING_VO_DBOUNCE

			if ( Distance( owner.GetOrigin(), crossingEnt.GetOrigin() ) > TESLA_TRAP_CONSIDERED_FAR_DIST )
				PlayBattleChatterLineToSpeakerAndTeam( owner, "bc_wattson_enemyTrippedFenceFar" )
			else
				PlayBattleChatterLineToSpeakerAndTeam( owner, "bc_wattson_enemyTrippedFenceNear" )
		}

		if ( file.trapTimes[crossingEnt].nextDamageTime > Time() )
			return

		float damageInterval = TESLA_TRAP_LINK_DAMAGE_INTERVAL_UPDATE

		file.trapTimes[crossingEnt].nextDamageTime = Time() + damageInterval

		//printt("damaging the player")

		//Deliver team agnostic damage so we can trigger emp effect. We set friendly damage to zero in the callback so there is no friendly fire.
		entity damageOwner = IsValid( owner ) ? owner : svGlobal.worldspawn

		StatsHook_TeslaTrap_OnEntityCrossed( owner, crossingEnt )

		vector crossingEntPos = crossingEnt.GetWorldSpaceCenter()
		crossingEnt.TakeDamage( file.balance_teslaTrapDamage, damageOwner, start, { origin = crossingEntPos, damageType = DF_ELECTRICAL, scriptType = DF_STUN_AI, damageSourceId = eDamageSourceId.mp_weapon_tesla_trap } )
		if ( crossingEnt.IsPlayer() )
		{
			EmitSoundAtPositionOnlyToPlayer( TEAM_UNASSIGNED, crossingEntPos, crossingEnt, TESLA_TRAP_LINK_DAMAGE_1P_SOUND )
			EmitSoundAtPositionExceptToPlayer( TEAM_UNASSIGNED, crossingEntPos, crossingEnt, TESLA_TRAP_LINK_DAMAGE_3P_SOUND )

			                             
				ShadowZombie_TryDamagingTrapAfterTakingDamage( crossingEnt, owner, start )
         
		}
		else
		{
			EmitSoundAtPosition( TEAM_UNASSIGNED, crossingEntPos, TESLA_TRAP_LINK_DAMAGE_3P_SOUND, crossingEnt )
		}

                     

      
		if ( file.trapTimes[crossingEnt].nextPingTime > Time() )
			return

		file.trapTimes[crossingEnt].nextPingTime = Time() + TESLA_TRAP_LINK_PING_INTERVAL

		entity mainOwner = start.GetOwner()
		entity otherOwner = end.GetOwner()
		entity mainTrapOwner  = IsValid( mainOwner ) ? mainOwner : svGlobal.worldspawn
		entity otherTrapOwner = IsValid( otherOwner ) ? otherOwner : svGlobal.worldspawn

		//If the player who owns the trap has the Perimeter Surveilance Passive, ping the trap's location to the entire team.
		if ( TeslaTrap_ShouldPingTarget( mainTrapOwner, crossingEnt ) )
		{
			//Create a ping for the threat detection system
			ThreatDetection_CreateThreatZoneForPing( start, mainTrapOwner, crossingEntPos, mainTrapOwner.GetTeam() )
			AutoPingForTrapDetection( mainTrapOwner, crossingEnt, start, crossingEntPos )
			int team = mainTrapOwner.GetTeam()
			Minimap_RingPulseForTeam( team, crossingEntPos, TESLA_TRAP_RADIUS / 10, 2.0, 8, TEAM_COLOR_FRIENDLY / 255.0 )

			// If we are in a mode where we allow communication between players near each other that are on the same team (but not the same squad); show the icon to nearby teammates
			if ( AllianceProximity_ShouldTryToTransmitPingOrIconToAlliance( false ) && !MiniMapIsDisabled() )
			{
				foreach ( player in AllianceProximity_GetLivingAllianceMembersInProximity( team, crossingEntPos ) )
				{
					Minimap_RingPulseForPlayer( player, crossingEntPos, TESLA_TRAP_RADIUS / 10, 2.0, 8, TEAM_COLOR_FRIENDLY / 255.0 )
				}
			}

		}

		//If the other trap is owned by a diffrent player than the main trap, give them a ping as well.
		if ( mainTrapOwner != otherTrapOwner )
		{
			if ( TeslaTrap_ShouldPingTarget( otherTrapOwner, crossingEnt ) )
			{
				//Create a ping for the threat detection system
				ThreatDetection_CreateThreatZoneForPing( start, otherTrapOwner, crossingEntPos, otherTrapOwner.GetTeam() )
				AutoPingForTrapDetection( otherTrapOwner, crossingEnt, end, crossingEntPos )
				int team = mainTrapOwner.GetTeam()
				Minimap_RingPulseForTeam( team, crossingEntPos, TESLA_TRAP_RADIUS / 10, 2.0, 8, TEAM_COLOR_FRIENDLY / 255.0 )

				// If we are in a mode where we allow communication between players near each other that are on the same team (but not the same squad); show the icon to nearby teammates
				if ( AllianceProximity_ShouldTryToTransmitPingOrIconToAlliance( false ) && !MiniMapIsDisabled() )
				{
					foreach ( player in AllianceProximity_GetLivingAllianceMembersInProximity( team, crossingEntPos ) )
					{
						Minimap_RingPulseForPlayer( player, crossingEntPos, TESLA_TRAP_RADIUS / 10, 2.0, 8, TEAM_COLOR_FRIENDLY / 255.0 )
					}
				}
			}
		}

		//TeslaTrap_PlayTrapLinkBeamDamageFX( mainTrapData, otherTrapData )
	#endif

	#if CLIENT
		if ( trigger.IsTeslaTrapObstructed() )
			return

		if ( !TrippedEntIsFriendly( crossingEnt, start ) )
		{
			                     
				if ( EntIsHoverVehicle( crossingEnt ) )
					crossingEnt.HoverVehicle_StunBegin()
         

			return
		}

		if ( !TrippedEntIsFriendlyObstructionType( crossingEnt ) )
			return

		//printt("obstructing target")

		trigger.SetObstructedEndTime( Time() + 1.0 )

		UpdateTrapTriggerMinimapConnection( trigger, false )

		EmitSoundAtPosition( TEAM_UNASSIGNED, trigger.GetOrigin(), TESLA_TRAP_LINK_OBSTRUCT_SOUND )

		int triggerFXID = trigger.GetTeslaLinkFXIdx()
		if ( triggerFXID in file.linkFXs_client )
		{
			foreach( int fxID in file.linkFXs_client[triggerFXID] )
				EffectStop( fxID, false, true )
		}

		file.linkFXs_client[triggerFXID] <- []

		if ( triggerFXID in file.linkAGs_client )
		{
			entity ambientGeneric = file.linkAGs_client[ triggerFXID ]
			ambientGeneric.SetEnabled( false )
		}
	#endif // #if CLIENT
}

bool function TeslaTrap_AreTrapsLinked( entity mainTrap, entity otherTrap )
{
	array<entity> mainLinks  = mainTrap.GetLinkEntArray()
	array<entity> otherLinks = otherTrap.GetLinkEntArray()

	if ( mainLinks.contains( otherTrap ) && otherLinks.contains( mainTrap ) )
		return true

	return false
}

bool function TeslaTrap_CanLink_ObjectPlacer( vector trapPos, vector trapUp, entity otherTrap, TeslaTrapPlacementInfo placementInfo )
{
	//We should not link to ourself.
	//if ( trap == otherTrap )
	//	return false

	//Don't link to dead traps.
	if ( otherTrap.GetScriptName() == "tesla_trap_dead" )
		return false

	//We cannot link to a trap that has reached it's link limit.
	if ( otherTrap.GetLinkEntArray().len() >= TESLA_TRAP_LINK_COUNT_MAX )
		return false

	//We cannot link from a trap that has reached it's link limit.
	//if ( trap.GetLinkEntArray().len() >= TESLA_TRAP_LINK_COUNT_MAX )
	//	return false

	if ( placementInfo.deployLinkState != eDeployLinkFlags.DLF_NONE )
		return placementInfo.deployLinkState == eDeployLinkFlags.DLF_CAN_LINK

	//If trap is parented to another entity only allow it to link to traps that share the same parent.
	entity otherParent = otherTrap.GetParent()
	entity parentOfParent = placementInfo.parentTo

                        
	if ( GameMode_IsActive( eGameModes.CONTROL ) )
	{
		if ( IsValid( otherParent ) && otherParent.GetScriptName() == CONTROL_FUNC_BRUSH_GEO_NAME )
			otherParent = null

		if ( IsValid( parentOfParent ) && parentOfParent.GetScriptName() == CONTROL_FUNC_BRUSH_GEO_NAME )
			parentOfParent = null
	}
      
	
	if ( IsValid( parentOfParent ) )
	{
		if ( !IsValid( otherParent ) )
			return false
		
		while ( IsValid( otherParent.GetParent() ) )
			otherParent = otherParent.GetParent()
		
		while ( IsValid( parentOfParent.GetParent() ) )
			parentOfParent = parentOfParent.GetParent()

		if ( otherParent != parentOfParent )
			return false
	}
	else if ( IsValid( otherParent ) )
	{
		return false
	}

	vector otherOrigin = otherTrap.GetOrigin()
	float distSqr = DistanceSqr( trapPos, otherOrigin )

	//Do not link with traps that are too far away.
	if ( distSqr > TESLA_TRAP_LINK_DIST_SQR )
		return false

	//Check to see if there are any obstructions blocking our link.
	int beamCount = TeslaTrap_GetLinkLOSBeamCount( trapPos, trapUp, otherOrigin, otherTrap.GetUpVector(), null, otherTrap )
	if ( beamCount < TESLA_TRAP_LINK_FX_MIN )
		return false

	//Check to see if the angle is too steep
	if ( TeslaTrap_IsLinkAngleTooSteep( trapPos, otherTrap ) )
		return false

	placementInfo.beamCount = beamCount
	placementInfo.deployLinkState = eDeployLinkFlags.DLF_CAN_LINK

	return true
}

//This function tests whether the given trap can link to the other given trap on client.
bool function TeslaTrap_CanLink( entity trap, vector trapPos, vector trapUp, entity otherTrap, TeslaTrapPlacementInfo placementInfo )
{
	//We should not link to ourself.
	if ( trap == otherTrap )
		return false

	//Don't link to dead traps.
	if ( otherTrap.GetScriptName() == "tesla_trap_dead" )
		return false

	//We cannot link to a trap that has reached it's link limit.
	if ( otherTrap.GetLinkEntArray().len() >= TESLA_TRAP_LINK_COUNT_MAX )
		return false

	//We cannot link from a trap that has reached it's link limit.
	if ( trap.GetLinkEntArray().len() >= TESLA_TRAP_LINK_COUNT_MAX )
		return false

	if ( placementInfo.deployLinkState == eDeployLinkFlags.DLF_FAIL )
		return false

	//If trap is parented to another entity only allow it to link to traps that share the same parent.
	entity otherParent = otherTrap.GetParent()
	if ( IsValid( placementInfo.parentTo ) )
	{
		if ( IsValid( otherParent ) && otherParent != placementInfo.parentTo )
			return false
		else if ( !IsValid( otherParent ) )
			return false
	}
	else if ( IsValid( otherParent ) )
		return false

	vector otherOrigin = otherTrap.GetOrigin()
	float distSqr = DistanceSqr( trapPos, otherOrigin )

	//Do not link with traps that are too far away.
	if ( distSqr > TESLA_TRAP_LINK_DIST_SQR )
		return false

	//Check to see if there are any obstructions blocking our link.
	int beamCount = TeslaTrap_GetLinkLOSBeamCount( trapPos, trapUp, otherOrigin, otherTrap.GetUpVector(), trap, otherTrap )
	if ( beamCount < TESLA_TRAP_LINK_FX_MIN )
		return false

	placementInfo.beamCount = beamCount
	placementInfo.deployLinkState = eDeployLinkFlags.DLF_CAN_LINK

	return true
}

//Checks to see if a trap can both link and be deployed in a location.
bool function TeslaTrap_CanDeploy( entity trap, vector testPos, vector testUp, entity otherTrap, TeslaTrapPlacementInfo placementInfo )
{
	//Check to see if we can link and check to see if this angle is doubling back at a sharp angle
	if ( !TeslaTrap_CanLink( trap, testPos, testUp, otherTrap, placementInfo ) )
	{
		placementInfo.deployLinkState = eDeployLinkFlags.DLF_FAIL
		return false
	}

	if ( TeslaTrap_IsLinkAngleTooSteep( testPos, otherTrap ) )
	{
		//fail on click but not for any focal node stuff
		return false
	}

	return true
}

int function TeslaTrap_GetLinkLOSBeamCount( vector mainOrigin, vector mainUp, vector otherOrigin, vector otherUp, entity mainTrap, entity otherTrap )
{
	if ( IsValid( file.framePlacementInfo ) )
	{
		if ( file.framePlacementInfo.frameTime == Time() && file.framePlacementInfo.placementInfo.deployLinkState != eDeployLinkFlags.DLF_NONE )
			return file.framePlacementInfo.placementInfo.beamCount
	}

	array<entity> ignoreEnts = GetPlayerArray_Alive()
	ignoreEnts.extend( GetAllPropDoors() )
	ignoreEnts.extend( GetAllDeathBoxes() )
	if( IsValid( mainTrap ) )
		ignoreEnts.append( mainTrap )
	if( IsValid( otherTrap ) )
		ignoreEnts.append( otherTrap )

	for ( int i = 1; i <= TESLA_TRAP_LINK_FX_COUNT; i++ )
	{
		vector startOffset   = mainOrigin + (mainUp * (TESLA_TRAP_LINK_HEIGHT * i))
		vector endOffset     = otherOrigin + (otherUp * (TESLA_TRAP_LINK_HEIGHT * i))
		TraceResults results = TraceLineHighDetail( startOffset, endOffset, ignoreEnts, TESLA_TRAP_TRACE_MASK, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

		if ( TESLA_TRAP_DEBUG_DRAW_LINKS )
		{
			DebugDrawLine( results.endPos, endOffset, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 0.1 )
			DebugDrawLine( startOffset, results.endPos, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 0.1 )
		}

		//PrintTraceResults( results )

		if ( results.fraction < 1.0 )
			return i - 1
	}

	return TESLA_TRAP_LINK_FX_COUNT
}

bool function TeslaTrap_IsLinkAngleTooSteep( vector proxyTestPos, entity otherTrap )
{
	vector otherToProxy = Normalize( proxyTestPos - otherTrap.GetOrigin() )
	array<entity> links = otherTrap.GetLinkEntArray()

	//DebugDrawLine( otherTrap.GetOrigin(), otherTrap.GetOrigin() + otherToProxy, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 1.0 )

	foreach ( entity trap in links )
	{
		vector otherToTrap = Normalize( trap.GetOrigin() - otherTrap.GetOrigin() )

		//DebugDrawLine( otherTrap.GetOrigin(), otherTrap.GetOrigin() + otherToTrap, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 1.0 )

		float dot = DotProduct2D( otherToProxy, otherToTrap )
		//printt( "CLIENT DOT: " + dot )

		if ( dot > TESLA_TRAP_LINK_MAX_DOT )
		{
			//	printt( "LINK FAILED: TOO STEEP!" )
			return true
		}
	}

	return false
}
 
