global function LootVault_Enabled
global function Sh_Loot_Vault_Panel_Init
global function SetVaultPanelMinimapObj
global function GetVaultPanelMinimapObj
global function SetVaultPanelOpenMinimapObj
global function VaultPanel_GetBestMinimapObjs
global function VaultPanel_GetAllMinimapObjs

global function IsVaultDoor
global function IsVaultPanel
global function GetVaultPanelFromDoor
global function GetVaultDoorForHitEnt
global function GetVaultPanelForLoot
global function IsVaultPanelLocked
global function GetUniqueVaultData
global function GetUniqueVaultDataByLootItem

global function VaultPanel_GetTeammateWithKey
global function GetNameOfTeammateWithVaultKey

global function ForceVaultOpen

global function HasVaultKey

#if CLIENT
global function VaultPanel_ServerToClient_SetVaultMarkerClientEnt
global function MinimapPackage_VaultPanel
global function MinimapPackage_VaultPanelOpen
#endif

#if SERVER
global function CreateWaypoint_DataVault
global function MaybeActivateVaultDefense_Thread
global function SetupVaultPanels

global function ShowDataVaultsToTeam
global function HideDataVaultsFromTeam
global function ShowDataVaultsToPlayer
global function HideDataVaultsFromPlayer
global function RefreshDataVaultsForPlayer
global function ShowDataVaultWaypointsToTeam
global function RemoveDataVaultWaypointsForTeam
global function VaultPanel_ClientToServer_PingVaultFromMap
global function SetMinimapObjectVisibleToPlayer

                  
global function ShipVaultKeyPickupRandomVO
                        
#endif // SERVER

#if SERVER && DEVELOPER
global function DEV_ShowVaults
global function DEV_ShowVaultKeys
global function DEV_GiveVaultKeys
global function DEV_ShowVaultPanelInfos
global function DEV_TPToVaultKeys
#endif

const string LOOT_VAULT_PANEL_SCRIPTNAME = "LootVaultPanel"
const string LOOT_VAULT_DOOR_SCRIPTNAME = "LootVaultDoor"
const string LOOT_VAULT_DOOR_SCRIPTNAME_RIGHT = "LootVaultDoorRight"

                  
const string SHIP_VAULT_PANEL_SCRIPTNAME = "ShipVaultPanel"
const string SHIP_VAULT_DOOR_SCRIPTNAME = "ShipVaultDoor"
const string SHIP_VAULT_BODY_SCRIPTNAME = "ship_vault_corpse"

const asset SHIP_VAULT_PANEL_OPEN_FX = $"P_door_lock_IMC_open"
const asset SHIP_VAULT_PANEL_LOCKED_FX = $"P_door_lock_IMC_locked"
                        

const string LOOT_VAULT_MARKER_SCRIPTNAME = "LootVaultMarker"

const string LOOT_VAULT_AUDIO_OPEN = "LootVault_Open"
const string LOOT_VAULT_AUDIO_ACCESS = "LootVault_Access"
const string LOOT_VAULT_AUDIO_STATUSBAR = "LootVault_StatusBar"
const string VAULT_ALARM_SOUND = "Loba_Ultimate_Staff_VaultAlarm"

const float PANEL_TO_DOOR_RADIUS_SQR = 15000.0
const float VAULT_PANEL_USE_TIME = 3.0

const float DATAVAULT_WAYPOINT_DURATION = 10.0
const float DATAVAULT_WAYPOINT_REVEAL_DELAY = 3.0

const string FUNCNAME_PingVaultFromMap = "VaultPanel_ClientToServer_PingVaultFromMap"
const string FUNCNAME_VaultPanelMarkerEntSet = "VaultPanel_ServerToClient_SetVaultMarkerClientEnt"

enum ePanelState
{
	LOCKED,
	UNLOCKING,
	UNLOCKED
}

struct VaultData
{
	entity panel
	int    panelState = ePanelState.LOCKED

	array<entity> vaultDoors

	entity vaultMarkerEnt

	#if SERVER
		                  
			entity panelLockedFX
			entity panelOpenFX
                          
		void functionref( entity, entity ) openDoorCallback
		entity doorDirector
	#endif //SERVER

	entity minimapObj
	entity openMinimapObj
}

#if DEVELOPER
struct SpecialVolumeDimensions
{
	vector center
	vector endFront
	vector endBack

	float radius
	float heightAbove
	float heightBelow
}
#endif // DEVELOPER

global struct UniqueVaultData
{
	string 	panelScriptName
	string	vaultKeylootType
	string	hasVaultKeyString

	string 	hintVaultUnlocking
	string 	hintVaultKeyNeeded
	string 	hintVaultKeyUse
	string 	hintVaultNeedTimestamp
	string	vaultUITitleString

	string 	bcGotVaultKey
	string 	bcVaultOpened

	int 	commsPingVault
	int		commsPingVaultOpen
	int		commsPingVaultHasKeySquad
	int 	commsPingVaultHasKeySelf

	int 	pingVault
	int 	pingTypeReveal
	int		pingVaultHasKeySelf
	int		pingVaultHasKeySquad
	string	pingVaultReveal

	float	lootToPanelDistSqr
	vector	alarmVFXVec
	vector	alarmVFXAngle
	asset 	vaultAlarmVFX

	string onOpenPinEvent
	string onPickupPinEvent
}

global const UniqueVaultData LOOT_VAULT_DATA = {
	panelScriptName				= LOOT_VAULT_PANEL_SCRIPTNAME,
	vaultKeylootType			= "data_knife",
	hasVaultKeyString			= "hasDataKnife",

	hintVaultUnlocking 			= "#HINT_VAULT_UNLOCKING",
	hintVaultKeyNeeded 			= "#HINT_VAULT_NEED",
	hintVaultKeyUse				= "#HINT_VAULT_USE",
	hintVaultNeedTimestamp		= "#HINT_VAULT_NEED_TIMESTAMP",
	vaultUITitleString			= "#LOOT_VAULT_UI_TITLE",

	bcGotVaultKey				= "bc_vaultKeyGot",
	bcVaultOpened				= "bc_vaultOpened",

	commsPingVault				= eCommsAction.PING_LOOT_VAULT,
	commsPingVaultOpen			= eCommsAction.PING_LOOT_VAULT_OPEN,
	commsPingVaultHasKeySquad 	= eCommsAction.PING_LOOT_VAULT_HAS_KEY_SQUAD,
	commsPingVaultHasKeySelf	= eCommsAction.PING_LOOT_VAULT_HAS_KEY_SELF,

	pingVault					= ePingType.LOOT_VAULT,
	pingTypeReveal				= ePingType.LOOT_VAULT_REVEAL,
	pingVaultHasKeySelf			= ePingType.LOOT_VAULT_HAS_KEY_SELF,
	pingVaultHasKeySquad		= ePingType.LOOT_VAULT_HAS_KEY_SQUAD,
	pingVaultReveal				= "#PING_LOOT_VAULT_REVEAL",

	lootToPanelDistSqr 			= 800000.0,
	alarmVFXVec					= < 0, 0, 0 >,
	alarmVFXAngle				= < 0, -90, 0 >,
	vaultAlarmVFX				= $"P_vault_door_alarm"

	onOpenPinEvent					= "MapToy_loot_vault_open"
	onPickupPinEvent				= "MapToy_loot_vault_key_pickup"
}

                  
global const UniqueVaultData SHIP_VAULT_DATA = {
	panelScriptName				= SHIP_VAULT_PANEL_SCRIPTNAME,
	vaultKeylootType			= "ship_keycard",
	hasVaultKeyString			= "hasShipKeycard",

	hintVaultUnlocking 			= "#HINT_SHIP_VAULT_UNLOCKING",
	hintVaultKeyNeeded 			= "#HINT_SHIP_VAULT_NEED",
	hintVaultKeyUse				= "#HINT_SHIP_VAULT_USE",
	hintVaultNeedTimestamp		= "#HINT_SHIP_VAULT_NEED_TIMESTAMP",
	vaultUITitleString			= "#SHIP_VAULT_UI_TITLE",

	bcGotVaultKey				= "bc_keyCardGot",
	bcVaultOpened				= "bc_vaultOpened",

	commsPingVault				= eCommsAction.PING_SHIP_VAULT,
	commsPingVaultOpen			= eCommsAction.PING_LOOT_VAULT_OPEN,
	commsPingVaultHasKeySquad 	= eCommsAction.PING_SHIP_VAULT_HAS_KEY_SQUAD,
	commsPingVaultHasKeySelf	= eCommsAction.PING_SHIP_VAULT_HAS_KEY_SELF,

	pingVault					= ePingType.SHIP_VAULT,
	pingTypeReveal				= ePingType.SHIP_VAULT_REVEAL,
	pingVaultHasKeySelf			= ePingType.SHIP_VAULT_HAS_KEY_SELF,
	pingVaultHasKeySquad		= ePingType.SHIP_VAULT_HAS_KEY_SQUAD,
	pingVaultReveal				= "#PING_SHIP_VAULT_REVEAL",

	lootToPanelDistSqr 			= 1000000.0,
	alarmVFXVec					= < -5, 0, 0 >,
	alarmVFXAngle				= < 0, 180, 0 >,
	vaultAlarmVFX				= $"P_vault_door_alarm_oly_mu1"

	onOpenPinEvent					= "MapToy_ship_vault_open"
	onPickupPinEvent				= "MapToy_ship_vault_key_pickup"
}
                        

struct
{
	array< void functionref( VaultData, int ) > vaultPanelUnlockingStateCallbacks
	array< void functionref( VaultData, int ) > vaultPanelUnlockedStateCallbacks

	array< entity >				vaultDoors
	array< VaultData > 			vaultControlPanels
	array< UniqueVaultData > 	uniqueVaultDatas =
	[
		LOOT_VAULT_DATA,
	                  
		SHIP_VAULT_DATA
                         
	]

	#if SERVER
		                  
			array< vector >		keycardLocations
                          
		array<entity> 			vaultWaypoints
		array< entity >			vaultPanels
		entity					panelVFX
		table< entity, array< entity > > noPlaceVolumes_ByPanel
		
		#if DEVELOPER
			array< entity > dev_VaultKeys
			table <entity, SpecialVolumeDimensions > dev_noPlaceVolDmensions_ByPanel
		#endif // DEVELOPER
	#endif // SERVER
} file

bool function LootVault_Enabled()
{
	return GetCurrentPlaylistVarBool( "loot_vaults_enabled", true )
}

void function Sh_Loot_Vault_Panel_Init()
{
	if ( !LootVault_Enabled() )
	{
		#if SERVER
			AddSpawnCallback( "prop_dynamic", VaultDoorSpawned_Vaults_Disabled )
			AddSpawnCallback( "prop_door", VaultDoorSpawned_Vaults_Disabled )
			AddSpawnCallback( "prop_dynamic", VaultPanelSpawned_Vaults_Disabled )
		#endif
		return
	}

	PrecacheParticleSystem( LOOT_VAULT_DATA.vaultAlarmVFX )
	                  
		PrecacheParticleSystem( SHIP_VAULT_DATA.vaultAlarmVFX )
		PrecacheParticleSystem( SHIP_VAULT_PANEL_OPEN_FX )
		PrecacheParticleSystem( SHIP_VAULT_PANEL_LOCKED_FX )
                         

	#if CLIENT
		                  
			AddCreateCallback( "prop_dynamic", VaultDoorSpawned )
                          
		AddCreateCallback( "prop_dynamic", VaultPanelSpawned )
		AddCreateCallback( "prop_door", VaultDoorSpawned )

		if( VaultPanels_PingFromMap_Enabled() )
			AddCallback_OnFindFullMapAimEntity( GetVaultUnderAim, PingVaultUnderAim )
	#endif //CLIENT

	if( VaultPanels_PingFromMap_Enabled() )
	{
		//Remote_RegisterServerFunction( FUNCNAME_PingVaultFromMap, "typed_entity", "prop_dynamic" )
		Remote_RegisterClientFunction( FUNCNAME_VaultPanelMarkerEntSet, "entity", "entity" )
	}


	#if SERVER
		                  
			AddSpawnCallback( "prop_dynamic", ShipVaultKeycardSpawned )
			AddSpawnCallback( "prop_dynamic", VaultDoorSpawned )
        
		AddSpawnCallback( "prop_dynamic", VaultPanelSpawned )
		AddSpawnCallback( "prop_door", VaultDoorSpawned )
		AddCallback_GameStateEnter( eGameState.Playing, VaultPanel_InitClientTrackingEnts )

		AddSpawnCallback_ScriptName( LOOT_VAULT_PANEL_SCRIPTNAME, SURVIVAL_AddVaultPanel )
		                  
			AddSpawnCallback_ScriptName( SHIP_VAULT_PANEL_SCRIPTNAME, SURVIVAL_AddVaultPanel )
        

		AddCallback_EntitiesDidLoad( EntitiesDidLoad )

		LootVaultPanels_AddCallback_OnVaultPanelStateChangedToUnlocked( VaultPanelUnlocked )
	#endif //SERVER

	LootVaultPanels_AddCallback_OnVaultPanelStateChangedToUnlocking( VaultPanelUnlocking )
}

#if SERVER
                  
void function ShipVaultKeycardSpawned( entity keycard )
{
	if ( keycard.GetScriptName() != SHIP_VAULT_BODY_SCRIPTNAME )
		return

	// Store keycard position, then destroy model
	file.keycardLocations.append( keycard.GetOrigin() )
	keycard.Destroy()
}
                        
#endif // SERVER

void function VaultPanelSpawned( entity panel )
{
	if ( !IsVaultPanel( panel ) )
		return

	VaultData data
	data.panel = panel

	UniqueVaultData uniqueData = GetUniqueVaultData( panel )

	#if SERVER
		entity vaultMarker = CreatePropDynamic( $"mdl/dev/empty_model.rmdl", panel.GetOrigin(), <0, 0, 0>, 0 )
		vaultMarker.SetScriptName( LOOT_VAULT_MARKER_SCRIPTNAME )
		vaultMarker.SetOrigin( panel.GetOrigin() )
		vaultMarker.SetAngles( panel.GetAngles() )
		data.vaultMarkerEnt = vaultMarker

		if ( uniqueData.panelScriptName == LOOT_VAULT_PANEL_SCRIPTNAME )
		{
			data.doorDirector = CreatePropScript( $"mdl/dev/empty_model.rmdl", panel.GetOrigin() )
			SpecialVolumes_Create_ByType( panel, LOOT_VAULT_PANEL_SCRIPTNAME )
		}
		                  
		else if ( uniqueData.panelScriptName == SHIP_VAULT_PANEL_SCRIPTNAME && panel.LookupAttachment( "light0" ) > 0 )
		{
			data.panelLockedFX = StartParticleEffectOnEntity_ReturnEntity( panel, GetParticleSystemIndex( SHIP_VAULT_PANEL_LOCKED_FX ), FX_PATTACH_POINT_FOLLOW, panel.LookupAttachment( "light0" ) )
			SpecialVolumes_Create_ByType( panel, SHIP_VAULT_PANEL_SCRIPTNAME )
		}
                          

		panel.SetSkin( 1 )
		GradeFlagsSet( panel, eGradeFlags.IS_LOCKED )
	#endif // SERVER

	file.vaultControlPanels.append( data )

	SetVaultPanelUsable( panel )
}

#if SERVER
void function VaultPanelSpawned_Vaults_Disabled( entity panel )
{
	if ( !IsVaultPanel( panel ) )
		return

	panel.Destroy()
}

void function SURVIVAL_AddVaultPanel( entity panel )
{
	file.vaultPanels.append( panel )
}

void function SetupVaultPanels()
{
	foreach ( panel in file.vaultPanels )
	{
		entity minimapObj = CreatePropScript( $"mdl/dev/empty_model.rmdl", panel.GetOrigin() )
		SetTargetName( minimapObj, "VaultPanel" )
		minimapObj.Minimap_SetCustomState( eMinimapObject_prop_script.VAULT_PANEL )
		minimapObj.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
		SetVaultPanelMinimapObj( panel, minimapObj )
		foreach ( player in GetPlayerArray() )
			minimapObj.Minimap_Hide( 0, player )

		entity openMinimapObj = CreatePropScript( $"mdl/dev/empty_model.rmdl", panel.GetOrigin() )
		SetTargetName( openMinimapObj, "VaultPanel" )
		openMinimapObj.Minimap_SetCustomState( eMinimapObject_prop_script.VAULT_PANEL_OPEN )
		openMinimapObj.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
		SetVaultPanelOpenMinimapObj( panel, openMinimapObj )
		foreach ( player in GetPlayerArray() )
			openMinimapObj.Minimap_Hide( 0, player )
	}
}

void function ShowDataVaultsToTeam( int team )
{
	foreach ( panel in file.vaultPanels )
	{
		entity minimapObj = GetVaultPanelMinimapObj( panel )
		foreach ( player in GetPlayerArrayOfTeam( team ) )
		{
			if ( IsValid( minimapObj ) )
				minimapObj.Minimap_AlwaysShow( 0, player )
		}
	}
}

void function HideDataVaultsFromTeam( int team )
{
	foreach ( panel in file.vaultPanels )
	{
		entity minimapObj = GetVaultPanelMinimapObj( panel )
		foreach ( player in GetPlayerArrayOfTeam( team ) )
		{
			if ( IsValid( minimapObj ) )
				minimapObj.Minimap_Hide( 0, player )
		}
	}
}

void function ShowDataVaultsToPlayer( entity player )
{
	array<entity> mapObjs = VaultPanel_GetBestMinimapObjs()
	foreach ( obj in mapObjs )
	{
		if ( IsValid( obj ) )
			obj.Minimap_AlwaysShow( 0, player )
	}
}

void function HideDataVaultsFromPlayer( entity player )
{
	array<entity> mapObjs = VaultPanel_GetAllMinimapObjs()
	foreach ( obj in mapObjs )
	{
		if ( IsValid( obj ) )
			obj.Minimap_Hide( 0, player )
	}
}

void function RefreshDataVaultsForPlayer( entity player )
{
	HideDataVaultsFromPlayer( player )

	WaitFrame()

	ShowDataVaultsToPlayer( player )
}

void function ShowDataVaultWaypointsToTeam( int team )
{
	foreach ( player in GetPlayerArrayOfTeam( team ) )
	{
		thread ShowDataVaultWaypointsToPlayer( player )
	}

	wait DATAVAULT_WAYPOINT_DURATION

	RemoveDataVaultWaypointsForTeam( team )
}

void function ShowDataVaultWaypointsToPlayer( entity player )
{
	if ( !player.IsPlayer() )
		return

	if ( player.IsBot() )
		return

	foreach ( panel in file.vaultPanels )
	{
		if ( !IsValid( panel ) )
			continue

		wait DATAVAULT_WAYPOINT_REVEAL_DELAY
		entity wp = CreateWaypoint_DataVault( player, panel, DATAVAULT_WAYPOINT_DURATION )
		file.vaultWaypoints.append( wp )
	}
}

void function RemoveDataVaultWaypointsForTeam( int team )
{
	foreach ( player in GetPlayerArrayOfTeam( team ) )
	{
		foreach ( waypoint in file.vaultWaypoints )
		{
			if ( IsValid( waypoint ) )
				waypoint.Destroy()
		}
	}
}

void function VaultPanel_InitClientTrackingEnts( )
{
	foreach( player in GetPlayerArray() )
	{
		foreach( vaultData in file.vaultControlPanels )
		{
			entity panel = vaultData.panel
			entity markerEnt = vaultData.vaultMarkerEnt

			if( !IsValid( markerEnt ) || !IsValid( panel ) )
			{
				continue
			}

			if( VaultPanels_PingFromMap_Enabled() )
				Remote_CallFunction_NonReplay( player, FUNCNAME_VaultPanelMarkerEntSet, panel, markerEnt )
		}
	}
}
#endif // SERVER

void function VaultDoorSpawned( entity door )
{
	if ( !IsVaultDoor( door ) )
		return

	string doorScriptName = door.GetScriptName()
	if ( doorScriptName == LOOT_VAULT_DOOR_SCRIPTNAME || doorScriptName == LOOT_VAULT_DOOR_SCRIPTNAME_RIGHT)
	{
		door.SetSkin( 1 )
		#if SERVER
			door.UnsetUsable()
			door.SetTakeDamageType( DAMAGE_NO )
			door.e.canBurn = false
			door.SetCanBeMeleed( false )
			door.SetDoorLocked( true )
			door.e.isDisabled = true
			door.SetUsePrompts( "", "" )
		#endif // SERVER
	}

	file.vaultDoors.append( door )
}

#if SERVER
void function VaultDoorSpawned_Vaults_Disabled( entity door )
{
	if ( !IsVaultDoor( door ) )
		return

	string doorScriptName = door.GetScriptName()
	if ( doorScriptName == LOOT_VAULT_DOOR_SCRIPTNAME || doorScriptName == LOOT_VAULT_DOOR_SCRIPTNAME_RIGHT || doorScriptName == SHIP_VAULT_DOOR_SCRIPTNAME )
		door.Destroy()
}

void function EntitiesDidLoad()
{
	#if DEVELOPER
		array< entity > usedDoors
	#endif // DEVELOPER

	foreach ( panelData in file.vaultControlPanels )
	{
		                  
			if ( panelData.panel.GetScriptName() == SHIP_VAULT_PANEL_SCRIPTNAME )
			{
				// Spawn keycard at randomized location
				file.keycardLocations.randomize()
				vector keycardLocation = file.keycardLocations.pop()

				entity vaultKey = SpawnVaultKey( "ship_keycard", keycardLocation )
				#if DEVELOPER
					file.dev_VaultKeys.append( vaultKey )
				#endif // DEVELOPER
			}
                          

		foreach ( entity door in file.vaultDoors )
		{
			if ( panelData.panel.GetScriptName() == LOOT_VAULT_PANEL_SCRIPTNAME )
			{
				if ( DistanceSqr( panelData.panel.GetOrigin(), door.GetOrigin() ) > PANEL_TO_DOOR_RADIUS_SQR )
					continue

				panelData.openDoorCallback = OpenLootVaultDoor
			}
			                  
			else if ( panelData.panel.GetScriptName() == SHIP_VAULT_PANEL_SCRIPTNAME )
			{
				panelData.openDoorCallback = OpenShipVaultDoor

				// Match position of panel in ob_nightrun_linear_assault_fixed_defend.nut
				vector doorCenter = door.GetCenter()
				vector panelOriginNew = < doorCenter.x, doorCenter.y, doorCenter.z >
				panelData.panel.SetOrigin( PositionOffsetFromOriginAngles( panelOriginNew, panelData.panel.GetAngles(), -4, 4, -70 ) )

				// Attach panel to door so it can open with the door's open anim
				bool addToParentRealms = true
				panelData.panel.SetParent( door, "ATT_R_DOOR", true, 0 )
			}

                           

			if ( !panelData.vaultDoors.contains( door ) )
			{
				#if DEVELOPER
					Assert( !usedDoors.contains( door ), "Door is already being used by a vault panel." )
				#endif // DEVELOPER

					panelData.vaultDoors.append( door )

				#if DEVELOPER
					usedDoors.append( door )
				#endif // DEVELOPER
			}
		}

		#if DEVELOPER
			Assert( file.vaultDoors.len() != 0 ? panelData.vaultDoors.len() != 0 : true, "There are no vault doors in panelData. A vault panel exists but there are no doors assigned to it." )
		#endif // DEVELOPER
	}
}
#endif // SERVER

UniqueVaultData function GetUniqueVaultData( entity panel )
{
	UniqueVaultData data

	if ( IsValid( panel ) )
	{
		if ( panel.GetScriptName() == LOOT_VAULT_PANEL_SCRIPTNAME )
			data = LOOT_VAULT_DATA
		                  
		else if ( panel.GetScriptName() == SHIP_VAULT_PANEL_SCRIPTNAME )
			data = SHIP_VAULT_DATA
                          
	}

	return data
}


UniqueVaultData function GetUniqueVaultDataByLootItem( int lootType )
{
	UniqueVaultData data

	if ( lootType == eLootType.DATAKNIFE )
		data = LOOT_VAULT_DATA
	                  
	else if ( lootType == eLootType.SHIPKEYCARD )
		data = SHIP_VAULT_DATA


	return data
}


UniqueVaultData function GetVaultTypeByPanelData( VaultData panelData )
{
	UniqueVaultData data

	entity door = panelData.vaultDoors.top()
	string doorScriptName = door.GetScriptName()

	if ( doorScriptName == LOOT_VAULT_DOOR_SCRIPTNAME || doorScriptName == LOOT_VAULT_DOOR_SCRIPTNAME_RIGHT )
		data = LOOT_VAULT_DATA
	                  
	else if ( doorScriptName == SHIP_VAULT_DOOR_SCRIPTNAME )
		data = SHIP_VAULT_DATA
                         

	return data
}


bool function HasVaultKey( entity player )
{
	array< ConsumableInventoryItem > playerInventory = SURVIVAL_GetPlayerInventory( player )
	
	foreach ( item in playerInventory )
	{
		LootData lootData = SURVIVAL_Loot_GetLootDataByIndex( item.type )
		if ( lootData.lootType == eLootType.DATAKNIFE )
		{
			 return true
		}
                  
		else if ( lootData.lootType == eLootType.SHIPKEYCARD &&  LootVault_Enabled() )
		{
			 return true
		}
                        
	}
	return false
}


void function SetVaultPanelState( VaultData panelData, int panelState )
{
	if ( panelState == panelData.panelState )
		return

	printf( "LootVaultPanelDebug: Changing panel state from %i to %i.", panelData.panelState, panelState )

	panelData.panelState = panelState

	switch ( panelState )
	{
		case ePanelState.LOCKED:
			return

		case ePanelState.UNLOCKING:
			LootVaultPanelState_Unlocking( panelData, panelState )

		case ePanelState.UNLOCKED:
			LootVaultPanelState_Unlocked( panelData, panelState )

		default:
			return
	}
}


void function LootVaultPanels_AddCallback_OnVaultPanelStateChangedToUnlocking( void functionref( VaultData, int ) callbackFunc )
{
	Assert( !file.vaultPanelUnlockingStateCallbacks.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with LootVaultPanels_AddCallback_OnVaultPanelStateChanged" )
	file.vaultPanelUnlockingStateCallbacks.append( callbackFunc )
}


void function LootVaultPanelState_Unlocking( VaultData panelData, int panelState )
{
	foreach ( func in file.vaultPanelUnlockingStateCallbacks )
		func( panelData, panelData.panelState )
}

#if SERVER
void function LootVaultPanels_AddCallback_OnVaultPanelStateChangedToUnlocked( void functionref( VaultData, int ) callbackFunc )
{
	Assert( !file.vaultPanelUnlockedStateCallbacks.contains( callbackFunc ), "Already added " + string( callbackFunc ) + " with LootVaultPanels_AddCallback_OnVaultPanelStateChanged" )
	file.vaultPanelUnlockedStateCallbacks.append( callbackFunc )
}
#endif

void function LootVaultPanelState_Unlocked( VaultData panelData, int panelState )
{
	foreach ( func in file.vaultPanelUnlockedStateCallbacks )
		func( panelData, panelData.panelState )
}


bool function LootVaultPanel_CanUseFunction( entity playerUser, entity panel, int useFlags )
{
	if ( Bleedout_IsBleedingOut( playerUser ) )
		return false

	if ( playerUser.ContextAction_IsActive() )
		return false

	entity activeWeapon = playerUser.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( IsValid( activeWeapon ) && activeWeapon.IsWeaponOffhand() )
		return false

	if ( panel.e.isBusy )
		return false

	if ( GetVaultPanelDataFromEntity( panel ).panelState != ePanelState.LOCKED )
		return false

	return true
}


void function OnVaultPanelUse( entity panel, entity playerUser, int useInputFlags )
{
	if ( !IsBitFlagSet( useInputFlags, USE_INPUT_LONG ) )
		return

	UniqueVaultData data = GetUniqueVaultData( panel )

	if ( !HasVaultKey( playerUser ) )
		return

	ExtendedUseSettings settings

	settings.duration = VAULT_PANEL_USE_TIME
	settings.useInputFlag = IN_USE_LONG
	settings.successSound = LOOT_VAULT_AUDIO_ACCESS
	settings.successFunc = VaultPanelUseSuccess

	#if CLIENT
		settings.loopSound = LOOT_VAULT_AUDIO_STATUSBAR
		settings.displayRuiFunc = DisplayRuiForLootVaultPanel
		settings.displayRui = $"ui/health_use_progress.rpak"
		settings.icon = $"rui/hud/gametype_icons/survival/data_knife"
		settings.hint = data.hintVaultUnlocking
	#endif //CLIENT

	#if SERVER
		settings.exclusiveUse = true
		settings.movementDisable = true
		settings.holsterWeapon = true
		settings.holsterViewModelOnly = true
	#endif //SERVER

	thread ExtendedUse( panel, playerUser, settings )
}


void function ForceVaultOpen( entity panel )
{
	VaultData panelData = GetVaultPanelDataFromEntity( panel )

	if ( panelData.panelState != ePanelState.UNLOCKING )
		SetVaultPanelState( panelData, ePanelState.UNLOCKING )
}


void function VaultPanelUseSuccess( entity panel, entity player, ExtendedUseSettings settings )
{
	VaultData panelData = GetVaultPanelDataFromEntity( panel )
	UniqueVaultData data = GetUniqueVaultData( panel )

	#if SERVER
		SURVIVAL_RemoveFromPlayerInventory( player, data.vaultKeylootType, 1 )
		if ( SURVIVAL_CountItemsInInventory( player, data.vaultKeylootType ) == 0 )
		{
			HideDataVaultsFromPlayer( player )
		}

		thread PlayBattleChatterLineDelayedToSpeakerAndTeam( player, data.bcVaultOpened, 0.75 )
		PIN_Interact( player, data.onOpenPinEvent, panel.GetOrigin() )

		                    
			//UpgradeCore_GrantXp_VaultOpened( player )
        
	#endif

	if ( panelData.panelState != ePanelState.UNLOCKING )
		SetVaultPanelState( panelData, ePanelState.UNLOCKING )
}


void function VaultPanelUnlocking( VaultData panelData, int panelState )
{
	if ( panelState != ePanelState.UNLOCKING )
		return

	#if SERVER
		panelData.panel.UnsetUsable()
	#endif //SERVER

	thread HideVaultPanel_Thread( panelData )
}

#if SERVER
void function VaultPanelUnlocked( VaultData panelData, int panelState )
{
	if ( panelState != ePanelState.UNLOCKED )
		return

	SpecialVolumes_Destroy( panelData.panel )

	UniqueVaultData vaultData = GetVaultTypeByPanelData( panelData )

	foreach ( door in panelData.vaultDoors )
		panelData.openDoorCallback( door, panelData.doorDirector )

	array<entity> playerArray = GetPlayerArray()
	foreach ( player in playerArray )
	{
		if ( SURVIVAL_CountItemsInInventory( player, vaultData.vaultKeylootType ) > 0 )
			thread RefreshDataVaultsForPlayer( player )
	}
}


void function OpenLootVaultDoor( entity door, entity director )
{
	EmitSoundAtPosition( TEAM_ANY, director.GetOrigin(), LOOT_VAULT_AUDIO_OPEN, director )

	if ( IsCodeDoor( door ) )
	{
		door.OpenDoor( director )
		return
	}

	if ( door.e.isOpen )
		return
	Signal( door, "ScriptCalled", { player = director } )
}

                  
void function OpenShipVaultDoor( entity door, entity doorDirector )
{
	thread function() : ( door )
	{
		//Logic taken from sh_doors.nut, SurvivalDoorThink()
		door.EndSignal( "OnDestroy" )
		vector defaultAngles = door.GetAngles()

		OnThreadEnd( function() : ( door, defaultAngles ) {
			if ( IsValid( door ) )
				door.SetAngles( defaultAngles )
		} )

		door.Anim_SetSafePushMode( false )
		PlayAnimNoWait( door, "open" )
		WaittillAnimDone( door )
	}()
}
                        

void function SpecialVolumes_Create_ByType( entity panel, string panelType, bool debug = false )
{
	Assert( IsValid( panel ), FUNC_NAME() + "(): ERROR! panel is null." )

	vector center = panel.GetOrigin()
	vector intoDir
	float vaultDepth
	float heightAbove
	float heightBelow
	float radius 
	int numVols

	switch( panelType )
	{
		case SHIP_VAULT_PANEL_SCRIPTNAME:
			intoDir = panel.GetForwardVector()
			vaultDepth = 1200
			heightAbove = 800
			heightBelow = 400
			radius = 1200
			numVols = 5
			break
		default:
			intoDir = -panel.GetRightVector()
			vaultDepth = 800
			heightAbove = 800
			heightBelow = 200
			radius = 750
			numVols = 5
			break
	}
	SpecialVolumes_Create( panel, radius, intoDir, vaultDepth, heightAbove, heightBelow, numVols, debug )
}

void function SpecialVolumes_Create( entity panel, float volRadius, vector intoDir, float vaultDepth, float heightAbove, float heightBelow, int numVols, bool debug = false )
{
	Assert( IsValid( panel ), FUNC_NAME() + "(): ERROR! invalid panel given." )
	
	vector center = panel.GetOrigin()
	
	vector endFront = center
	vector endBack = center + intoDir * vaultDepth

	float doorwayWidth = Distance( endFront, endBack )

	array< vector > volLocs = GetPointsAlongLine( endFront, endBack, numVols )

	array< entity > specialVols
	foreach( loc in volLocs )
	{
		entity vol = CreateTriggerCylinderNetworked_NoRadiusNoObjectPlacementSpecial( loc, volRadius, heightAbove, heightBelow, < 0, 0, 0 > )
		specialVols.append( vol )
	}
	file.noPlaceVolumes_ByPanel[ panel ] <- specialVols

	#if DEVELOPER
		printt( FUNC_NAME() + "(): Special Volumes Created for Vault Panel @ " + center )

		SpecialVolumeDimensions dims
		dims.center = center
		dims.endFront = endFront
		dims.endBack = endBack
		dims.radius = volRadius
		dims.heightAbove = heightAbove
		dims.heightBelow = heightBelow

		file.dev_noPlaceVolDmensions_ByPanel[ panel ] <- dims

		if( debug )
		{
			DEV_ShowVaultPanelInfo_Single( panel, true, false, 120 )
		}
	#endif // DEVELOPER
}

void function SpecialVolumes_Destroy( entity panel )
{
	if( !( panel in file.noPlaceVolumes_ByPanel ) )
		return

	#if DEVELOPER
		if( IsValid( panel ) )
		{
			printt( FUNC_NAME() + "(): Destroying Special Volumes for Vault Panel @ " + panel.GetOrigin() )
		}
		else
		{
			printt( FUNC_NAME() + "(): Destroying Special Volumes for Deleted Vault Panel." )
		}
	#endif

	foreach( vol in file.noPlaceVolumes_ByPanel[ panel ] )
	{
		vol.Destroy()
	}
	file.noPlaceVolumes_ByPanel[ panel ] <- []
}

#endif // SERVER

void function HideVaultPanel_Thread( VaultData panelData )
{
	VaultData savedData = GetVaultPanelDataFromEntity( panelData.panel )

	#if SERVER
		GradeFlagsClear( panelData.panel, eGradeFlags.IS_LOCKED )

		if ( panelData.panel.GetScriptName() == LOOT_VAULT_PANEL_SCRIPTNAME )
		{
			panelData.panel.SetSkin( 0 )
			panelData.panel.Dissolve( ENTITY_DISSOLVE_CORE, panelData.panel.GetOrigin(), 200 )
		}
		                  
		else if ( panelData.panel.GetScriptName() == SHIP_VAULT_PANEL_SCRIPTNAME )
		{
			EmitSoundOnEntity( panelData.panel, "SQ_Door_Large_Unlock" )
			wait 2.0
			panelData.panel.SetSkin( 2 )

			if ( IsValid( panelData.panelLockedFX ) )
				EffectStop( panelData.panelLockedFX )

			panelData.panelOpenFX = StartParticleEffectOnEntity_ReturnEntity( panelData.panel, GetParticleSystemIndex( SHIP_VAULT_PANEL_OPEN_FX ), FX_PATTACH_POINT_FOLLOW, panelData.panel.LookupAttachment( "light0" ) )

			// Make the panel & fx ent NotSolid so the player won't catch on their collision
			panelData.panelOpenFX.NotSolid()
			panelData.panel.NotSolid()
		}
                          
	#endif // SERVER

	wait 2.0

	SetVaultPanelState( savedData, ePanelState.UNLOCKED )
}

#if CLIENT
string function VaultPanel_TextOverride( entity panel )
{
	UniqueVaultData data = GetUniqueVaultData( panel )

	entity player = GetLocalViewPlayer()
	string textOverride 

	int currentUnixTime           = GetUnixTimestamp()
	int ornull keyAccessTimeStamp = GetCurrentPlaylistVarTimestamp( "loot_vault_key_availability_unixtime", 1566864000 )
	if ( keyAccessTimeStamp != null )
	{
		if ( currentUnixTime < expect int( keyAccessTimeStamp ) )
		{
			int timeDelta        = expect int(keyAccessTimeStamp) - currentUnixTime
			TimeParts timeParts  = GetUnixTimeParts( timeDelta )
			string timeString    = GetDaysHoursMinutesSecondsString( timeDelta )

			textOverride = Localize( data.hintVaultNeedTimestamp, timeString )
		}
	}

	if ( IsVaultPanelLocked( panel ) )
	{
		if ( HasVaultKey( player ) )
			textOverride = data.hintVaultKeyUse
		else
			textOverride = data.hintVaultKeyNeeded
	}

	return textOverride
}


void function DisplayRuiForLootVaultPanel( entity ent, entity player, var rui, ExtendedUseSettings settings )
{
	DisplayRuiForLootVaultPanel_Internal( rui, settings.icon, Time(), Time() + settings.duration, settings.hint )
}


void function DisplayRuiForLootVaultPanel_Internal( var rui, asset icon, float startTime, float endTime, string hint )
{
	RuiSetBool( rui, "isVisible", true )
	RuiSetImage( rui, "icon", icon )
	RuiSetGameTime( rui, "startTime", startTime )
	RuiSetGameTime( rui, "endTime", endTime )
	RuiSetString( rui, "hintKeyboardMouse", hint )
	RuiSetString( rui, "hintController", hint )
}
#endif //CLIENT

VaultData function GetVaultPanelDataFromEntity( entity panel )
{
	foreach ( panelData in file.vaultControlPanels )
	{
		if ( panelData.panel == panel )
			return panelData
	}

	Assert( false, "Invalid Loot Vault Panel ( " + string( panel ) + " )." )

	unreachable
}

VaultData function GetVaultDataFromMarkerEntity( entity panel )
{
	foreach ( panelData in file.vaultControlPanels )
	{
		if ( panelData.vaultMarkerEnt == panel  )
			return panelData
	}

	Assert( false, "Invalid Loot Vault Marker ( " + string( panel ) + " )." )

	unreachable
}


void function SetVaultPanelUsable( entity panel )
{
	#if SERVER
		panel.SetUsable()
		panel.SetUsableByGroup( "pilot" )
		panel.AddUsableValue( USABLE_CUSTOM_HINTS )
		AddCallback_OnUseEntity_ClientServer( panel, OnVaultPanelUse )
	#endif //SERVER

	SetCallback_CanUseEntityCallback_Retail( panel, LootVaultPanel_CanUseFunction )

	#if CLIENT
		AddEntityCallback_GetUseEntOverrideText( panel, VaultPanel_TextOverride )
		AddCallback_OnUseEntity_ClientServer( panel, OnVaultPanelUse )
	#endif //CLIENT
}


void function SetVaultPanelMinimapObj( entity panel, entity minimapObj )
{
	VaultData panelData = GetVaultPanelDataFromEntity( panel )

	panelData.minimapObj = minimapObj
}


void function SetVaultPanelOpenMinimapObj( entity panel, entity minimapObj )
{
	VaultData panelData = GetVaultPanelDataFromEntity( panel )

	panelData.openMinimapObj = minimapObj
}


entity function GetVaultPanelMinimapObj( entity panel )
{
	VaultData panelData = GetVaultPanelDataFromEntity( panel )

	return panelData.minimapObj
}


#if SERVER
void function DestroyVaultPanelMinimapObj( entity panel )
{
	VaultData panelData = GetVaultPanelDataFromEntity( panel )

	if ( IsValid( panelData.minimapObj ) )
		panelData.minimapObj.Destroy()
}


entity function CreateWaypoint_DataVault( entity player, entity vaultPanel, float duration )
{
	UniqueVaultData data = GetUniqueVaultData( vaultPanel )

	entity wp = CreateWaypoint_Ping_Location( player, data.pingTypeReveal, vaultPanel, vaultPanel.GetOrigin(), -1, false )

	wp.SetParent( vaultPanel )

	return wp
}
#endif

bool function IsVaultDoor( entity ent )
{
	if ( !IsValid( ent ) )
		return false

	string scriptName = ent.GetScriptName()

	if ( scriptName == LOOT_VAULT_DOOR_SCRIPTNAME || scriptName == LOOT_VAULT_DOOR_SCRIPTNAME_RIGHT )
		return true

	                  
		if ( scriptName == SHIP_VAULT_DOOR_SCRIPTNAME )
			return true

		entity parentEnt = ent.GetParent()
		if ( IsValid( parentEnt ) && parentEnt.GetScriptName() == SHIP_VAULT_PANEL_SCRIPTNAME )
			return true
                         

	return false
}


bool function IsVaultPanel( entity ent )
{
	if ( !IsValid( ent ) )
		return false

	if ( ent.GetScriptName() == LOOT_VAULT_PANEL_SCRIPTNAME )
		return true

	                  
		if ( ent.GetScriptName() == SHIP_VAULT_PANEL_SCRIPTNAME )
			return true
                         

	return false
}


entity function GetVaultDoorForHitEnt( entity hitEnt )
{
	entity hitEntParent = hitEnt.GetParent()
	if ( !IsVaultDoor( hitEntParent ) )
		return null

	foreach ( vaultDoor in file.vaultDoors )
	{
		if ( vaultDoor == hitEntParent )
			return vaultDoor
	}
	return null

}

entity function GetVaultPanelFromDoor( entity door )
{
	foreach ( panelData in file.vaultControlPanels )
	{
		if ( !IsValid( panelData.panel ) )
			return null

		#if SERVER
			foreach ( vaultDoor in panelData.vaultDoors )
			{
				if ( vaultDoor == door )
					return panelData.panel
			}
		#endif

		#if CLIENT
			if ( DistanceSqr( panelData.panel.GetOrigin(), door.GetOrigin() ) <= PANEL_TO_DOOR_RADIUS_SQR )
				return panelData.panel
		#endif
	}

	return null
}


bool function IsVaultPanelLocked( entity vaultPanel )
{
	return GradeFlagsHas( vaultPanel, eGradeFlags.IS_LOCKED )
}


entity function VaultPanel_GetTeammateWithKey( int teamIdx )
{
	array< entity > squad = GetPlayerArrayOfTeam( teamIdx )

	foreach ( player in squad )
	{
		if ( HasVaultKey( player ) )
			return player
	}

	return null
}


string function GetNameOfTeammateWithVaultKey( int team )
{
	foreach ( player in GetPlayerArrayOfTeam( team ) )
	{
		if ( HasVaultKey( player ) )
			return player.GetPlayerName()
	}

	return ""
}


array< entity > function VaultPanel_GetBestMinimapObjs()
{
	array<entity> mapObjs
	foreach ( data in file.vaultControlPanels )
	{
		entity minimapObj
		if ( data.panelState == ePanelState.LOCKED )
			minimapObj = data.minimapObj
		else
			minimapObj = data.openMinimapObj

		if ( IsValid( minimapObj ) )
			mapObjs.append( minimapObj )
	}

	return mapObjs
}


array< entity > function VaultPanel_GetAllMinimapObjs()
{
	array<entity> mapObjs
	foreach ( data in file.vaultControlPanels )
	{
		mapObjs.append( data.minimapObj )
		mapObjs.append( data.openMinimapObj )
	}

	return mapObjs
}


entity function GetVaultPanelForLoot( entity lootEnt )
{
	foreach ( panelData in file.vaultControlPanels )
	{
		if ( !IsValid( panelData.panel ) )
			continue

		UniqueVaultData vaultData = GetUniqueVaultData( panelData.panel )

		vector lootEntToPanel = panelData.panel.GetOrigin() - lootEnt.GetOrigin()

		if ( LengthSqr( lootEntToPanel ) < vaultData.lootToPanelDistSqr )
		{
			if ( vaultData.panelScriptName == LOOT_VAULT_PANEL_SCRIPTNAME )
			{
				vector panelFwd = panelData.panel.GetRightVector() // Panel was created with it's forward facing sideways - really we want the dir vector of the panel face so we're using the right vector instead
				if ( DotProduct( panelFwd, Normalize( lootEntToPanel ) ) > 0 )
					return panelData.panel
			}
			                  
			else if ( vaultData.panelScriptName == SHIP_VAULT_PANEL_SCRIPTNAME )
			{
				vector panelFwd = -panelData.panel.GetForwardVector() // Negated so the vector points to the outside
				if ( DotProduct( panelFwd, Normalize( lootEntToPanel ) ) > 0 )
					return panelData.panel
			}
                           
		}
	}

	return null
}

#if SERVER
void function MaybeActivateVaultDefense_Thread( entity pickup, entity device, entity player )
{
	// todo(dw): make this function better

	entity vaultPanel = GetVaultPanelForLoot( pickup )
	if ( !IsValid( vaultPanel ) || !IsVaultPanelLocked( vaultPanel ) )
		return

	EndSignal( vaultPanel, "OnDestroy" )

	RegisterSignal( "MaybeActivateVaultDefense_Thread" )
	Signal( vaultPanel, "MaybeActivateVaultDefense_Thread" )
	EndSignal( vaultPanel, "MaybeActivateVaultDefense_Thread" )

	if ( IsValid( device ) )
		GradeFlagsSet( device, eGradeFlags.IS_BUSY )

	WaitFrame()

	if ( IsValid( device ) )
	{
		device.TakeDamage( 9999, null, null, {} )

		vector explosionCenter           = device.GetOrigin()
		float damage                     = 2
		float damageHeavyArmor           = damage
		float innerRadius                = 100
		float outerRadius                = 120
		int flags                        = DF_EXPLOSION
		vector projectileLaunchPos       = explosionCenter
		float explosionForce             = 110
		int scriptDamageFlags            = damageTypes.explosive
		int scriptDamageSourceIdentifier = eDamageSourceId.vault_defense
		string impactEffectTableName     = "superSpectre_groundSlam_impact"
		Explosion( explosionCenter, vaultPanel, vaultPanel, damage, damageHeavyArmor, innerRadius, outerRadius, flags, projectileLaunchPos, explosionForce, scriptDamageFlags, scriptDamageSourceIdentifier, impactEffectTableName )
	}

	UniqueVaultData vaultData = GetUniqueVaultData( vaultPanel )

	entity[1] fxEnts
	OnThreadEnd( void function() : ( vaultPanel, fxEnts ) {
		if ( IsValid( fxEnts[0] ) )
			fxEnts[0].Destroy()
		if ( IsValid( vaultPanel ) )
			StopSoundOnEntity( vaultPanel, VAULT_ALARM_SOUND )
	} )

	wait 0.2
	float startTime = Time()
	while ( Time() < startTime + 14.0 )
	{
		EmitSoundOnEntity( vaultPanel, VAULT_ALARM_SOUND )

		fxEnts[0] = StartParticleEffectInWorld_ReturnEntity(
			GetParticleSystemIndex( vaultData.vaultAlarmVFX ),
			LocalPosToWorldPos( vaultData.alarmVFXVec, vaultPanel ), LocalAngToWorldAng( vaultData.alarmVFXAngle, vaultPanel ) )
		fxEnts[0].SetStopType( "destroyImmediately" )

		wait 1.5
		fxEnts[0].Destroy()
		wait 1.5
	}
}

                  
void function ShipVaultKeyPickupRandomVO( entity player )
{
	float rand = RandomFloat( 1.0 )
	if ( rand > 0.75 )
	{
		ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_CharacterClass())
		string characterRef  = ItemFlavor_GetHumanReadableRef( character ).tolower()

		if ( characterRef == "character_bloodhound" )
			thread PlayBattleChatterLineToSpeakerAndTeam( player, "bc_locationOSC_bloodhound" )
		else if ( characterRef == "character_caustic" )
			thread PlayBattleChatterLineToSpeakerAndTeam( player, "bc_locationOSC_caustic" )
		else if ( characterRef == "character_lifeline" )
			thread PlayBattleChatterLineToSpeakerAndTeam( player, "bc_locationOSC_lifeline" )
	}
}

void function SetMinimapObjectVisibleToPlayer( entity player, entity minimapObj, bool visible )
{
	if( visible )
		minimapObj.Minimap_AlwaysShow( 0, player )
	else
		minimapObj.Minimap_Hide( 0, player )
}

#endif // SERVER


#if SERVER && DEVELOPER
void function DEV_ShowVaults()
{
	foreach ( entity lootEnt in SURVIVAL_Loot_GetAllLoot() )
	{
		if ( IsValid( lootEnt ) && GetVaultPanelForLoot( lootEnt ) )
			DebugDrawLine( lootEnt.GetOrigin(), lootEnt.GetOrigin() + <0, 0, 64>, 255,0,0, true, 60.0 )
	}
}

void function DEV_ShowVaultKeys()
{
	foreach( vaultKey in file.dev_VaultKeys )
	{
		if( IsValid( vaultKey ) )
		{
			DebugDrawSphere( vaultKey.GetOrigin(), 64, 102,0,204, true, 60 )
		}
		else
		{
			file.dev_VaultKeys.fastremovebyvalue( vaultKey )
		}
	}
}

void function DEV_TPToVaultKeys()
{
	foreach( vaultKey in file.dev_VaultKeys )
	{
		if( IsValid( vaultKey ) )
		{
			gp()[0].SetOrigin(vaultKey.GetOrigin())
		}
		else
		{
			file.dev_VaultKeys.fastremovebyvalue( vaultKey )
		}
	}
}

void function DEV_GiveVaultKeys( entity player )
{
	if( !IsValidPlayer( player ) )
		return

	array< LootData > allKeyData = SURVIVAL_Loot_GetByType( eLootType.DATAKNIFE )
	allKeyData.extend( SURVIVAL_Loot_GetByType( eLootType.SHIPKEYCARD ) )

	foreach( keyData in allKeyData )
	{
		GiveLoot( player, keyData.ref )
	}
}

void function DEV_ShowVaultPanelInfos( bool showRmDimsThroughGeo = true, bool showVolsThroughGeo = true, float duration = 60 )
{
	foreach( panel in file.vaultPanels )
	{
		DEV_ShowVaultPanelInfo_Single( panel, showRmDimsThroughGeo, showVolsThroughGeo, duration )
	}
}

void function DEV_ShowVaultPanelInfo_Single( entity panel, bool showRmDimsThroughGeo = true, bool showVolsThroughGeo = false, float duration = 60 )
{
	if( !IsValid( panel ) )
		return

	if( !( panel in file.noPlaceVolumes_ByPanel ) )
		return

	vector loc = panel.GetOrigin()

	DebugDrawSphere( loc, 64, 255,255,0, true, duration )

	SpecialVolumeDimensions dims = file.dev_noPlaceVolDmensions_ByPanel[ panel ]

	float volHeightTotal = dims.heightAbove + dims.heightBelow
	DebugDrawSphere( dims.center, 64, 255,255,0, showRmDimsThroughGeo, duration)
	DebugDrawSphere( dims.endFront, 128, 0,255,0, showRmDimsThroughGeo, duration )
	DebugDrawSphere( dims.endBack, 128, 255,0,0, showRmDimsThroughGeo, duration )
	DebugDrawLine( dims.center, dims.endFront, 0,255,0, showRmDimsThroughGeo, duration )
	DebugDrawLine( dims.center, dims.endBack, 255,0,0, showRmDimsThroughGeo, duration )

	float radius = dims.radius
	float heightAbove = dims.heightAbove
	float heightBelow = dims.heightBelow

	foreach( specialVol in file.noPlaceVolumes_ByPanel[ panel ] )
	{
		if( !IsValid( specialVol ) )
			continue

		DebugDrawCylinder( specialVol.GetOrigin() - < 0, 0, dims.heightBelow >, < -90, 0, 0 >, dims.radius, volHeightTotal, 255,0,0, showVolsThroughGeo, duration )
	}
}
#endif // SERVER && DEVELOPER

#if CLIENT
void function MinimapPackage_VaultPanel( entity ent, var rui )
{
	//#if MINIMAP_DEBUG
		//printt( "Adding 'rui/hud/gametype_icons/survival/data_knife_vault' icon to minimap" )
	//#endif
	RuiSetImage( rui, "defaultIcon", $"rui/hud/gametype_icons/survival/data_knife_vault" )
	RuiSetFloat3( rui, "iconColor", (GetKeyColor( COLORID_LOOT_TIER5 ) / 255.0) )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )
}

void function MinimapPackage_VaultPanelOpen( entity ent, var rui )
{
	//#if MINIMAP_DEBUG
		//printt( "Adding 'rui/hud/gametype_icons/survival/data_knife_vault_open' icon to minimap" )
	//#endif
	RuiSetImage( rui, "defaultIcon", $"rui/hud/gametype_icons/survival/data_knife_vault_open" )
	RuiSetImage( rui, "smallIcon", $"rui/hud/gametype_icons/survival/data_knife_vault_small" )
	RuiSetBool( rui, "hasSmallIcon", true )
	RuiSetFloat3( rui, "iconColor", (GetKeyColor( COLORID_LOOT_TIER5 ) / 255.0) )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )
}
#endif

#if CLIENT||SERVER
bool function VaultPanels_PingFromMap_Enabled()
{
	return GetCurrentPlaylistVarBool( "VaultPanels_pingfrommap_enabled", true )
}
#endif

#if CLIENT
void function VaultPanel_ServerToClient_SetVaultMarkerClientEnt( entity panel, entity targetEnt )
{
	if ( !IsValid( targetEnt ) )
		return

	foreach( data in file.vaultControlPanels )
	{
		if( data.panel == panel )
		{
			data.vaultMarkerEnt = targetEnt
		}
	}
}


entity function GetVaultUnderAim( vector worldPos, float worldRange )
{
	float closestDistSqr        = FLT_MAX
	float worldRangeSqr = worldRange * worldRange
	float extendedRange = worldRange * 2
	entity closestEnt = null

	entity player = GetLocalViewPlayer()

	entity vault

	if( MapPing_Modify_DistanceCheck_Enabled() )
	{
		float modifier = MapPing_DistanceCheck_GetModifier()

		if( worldRange >= MapPing_DistanceCheck_GetDistanceRange() )
			modifier *= 0.5

		worldRangeSqr = ( worldRange * modifier ) * ( worldRange * modifier )
	}

	foreach ( vaultData in file.vaultControlPanels )
	{
		if ( vaultData.panelState != ePanelState.LOCKED )
		{
			if( IsValid( vaultData.vaultMarkerEnt ) )
			{
				vault = vaultData.vaultMarkerEnt
			}
		}
		else
		{
			vault = vaultData.panel
		}

		if ( !IsValid( vault ) )
			continue

		if ( !HasVaultKey( player ) )
			continue

		vector vaultOrigin = vault.GetOrigin()

		float distSqr = Distance2DSqr( vaultOrigin, worldPos )
		if ( distSqr < ( worldRangeSqr * 2 ) && distSqr < closestDistSqr  )
		{
			closestDistSqr = distSqr
			closestEnt     = vault
		}
	}

	if ( !IsValid( closestEnt ) )
	{
		return null
	}

	return closestEnt
}

bool function PingVaultUnderAim( entity vault )
{
	entity player = GetLocalClientPlayer()

	if ( !IsValid( player ) || !IsAlive( player ) )
		return false

	if ( !IsPingEnabledForPlayer( player ) )
		return false

	if( VaultPanels_PingFromMap_Enabled() )
		ScriptRemote_RegisterClientFunction( FUNCNAME_PingVaultFromMap, vault ) //const string FUNCNAME_PingVaultFromMap = "VaultPanel_ClientToServer_PingVaultFromMap"

	EmitSoundOnEntity( GetLocalViewPlayer(), PING_SOUND_LOCAL_CONFIRM )

	return true
}
#endif

#if SERVER
void function VaultPanel_ClientToServer_PingVaultFromMap( entity player, entity vault )
{
	if ( IsValid( player ) && IsValid( vault ) )
	{
		//early out if player is not player
		if( !player.IsPlayer() )
			return

		string vaultScript = vault.GetScriptName()

		//if the passed vault entity's script name doesn't match any of the vaults we validate, early out.
		if( vaultScript != LOOT_VAULT_MARKER_SCRIPTNAME && !IsVaultPanel( vault ) )
			return

		bool vaultOpen = false

		VaultData vaultData

		if( vault.GetScriptName() == SHIP_VAULT_PANEL_SCRIPTNAME )
		{
			CreateWaypoint_Ping_Location( player, ePingType.SHIP_VAULT_HAS_KEY_SELF, vault, vault.GetOrigin() + <0, 0, 50>, -1, false )

			return
		}
		else
		{
			//The GetVaultData checks will assert if the vault is doesn't have a panel or marker related to it.
			if( vault.GetScriptName() == LOOT_VAULT_MARKER_SCRIPTNAME )
				vaultData = GetVaultDataFromMarkerEntity( vault )

			if( vault.GetScriptName() == LOOT_VAULT_PANEL_SCRIPTNAME )
				vaultData = GetVaultPanelDataFromEntity( vault )


			if ( vaultData.panelState == ePanelState.LOCKED )
				vaultOpen = false

			if ( vaultData.panelState != ePanelState.LOCKED )
				vaultOpen = true

			if( vaultOpen )
			{
				CreateWaypoint_Ping_Location( player, ePingType.AREA_VISITED, vault, vault.GetOrigin() + <0, 0, 50>, -1, false )
			}
			else
			{
				CreateWaypoint_Ping_Location( player, ePingType.LOOT_VAULT_HAS_KEY_SELF, vault, vault.GetOrigin() + <0, 0, 50>, -1, false )
			}
		}
	}
}
#endif // SERVER


 