
global function ShExplosiveHold_Init
global function ExplosiveHold_IsOpen
global function ExplosiveHold_PlayerHasGrenadeInInventory

#if SERVER || CLIENT
global function ExplosiveHold_IsPlayerPlantingGrenade
global function GetExplosiveHoldProxyForLoot
#endif // SERVER || CLIENT

#if SERVER
global function MaybeActivateExplosiveHoldDefense_Thread
#endif // SERVER

global const asset EXPLOSIVE_HOLD_PROXY = $"mdl/props/explosivehold_container_01/explosivehold_container_01_proxy.rmdl"
global const string EXPLOSIVE_HOLD_PANEL_SCRIPTNAME = "explosive_hold_panel"

const string EXPLOSIVE_HOLD_SCRIPTNAME = "explosive_hold"
const string EXPLOSIVE_HOLD_MOVER_SCRIPTNAME = "explosive_hold_door_mover"
const string EXPLOSIVE_HOLD_GUN_RACK_SCRIPTNAME = "explosive_hold_gun_rack"
const string EXPLOSIVE_HOLD_PANEL_HOUSING = "explosive_hold_panel_housing"
const string EXPLOSIVE_HOLD_DOOR_RIGHT = "explosive_hold_door_right"
const string EXPLOSIVE_HOLD_DOOR_LEFT = "explosive_hold_door_left"
const string EXPLOSIVE_HOLD_VENT_SMOKE_SCRIPTNAME = "explosive_hold_vent_fx_helper"
const string EXPLOSIVE_HOLD_ATTACHMENTS_PARENT_SCRIPTNAME = "explosive_hold_attachments_parent"

const string EXPLOSIVE_HOLD_WEAPON_LOOT_GROUP = "Weapon_Medium"
global const string EXPLOSIVE_HOLD_ATTACHMENTS_LOOT_GROUP = "Explosive_Hold_Attachments"

const string DOOR_DENY_SOUND = "menu_deny"
const string GRENADE_DETONATE_SOUND = "Loot_ExplosiveHold_Explosion_3p"
const string ARC_PLACEMENT_SOUND = "weapon_arcstar_explosivewarningbeep"
const string PANEL_ALARM_SOUND = "Loot_ExplosiveHold_PanelAlarm_3p"
const string OPEN_DOOR_DAMAGED_SOUND = "Loot_ExplosiveHold_Door_Damaged_Open_3p"
const string OPEN_DOOR_SOUND = "Loot_ExplosiveHold_Door_Back_Open_3p"
const string LOBA_BLACK_MARKET_ALARM_SOUND = "Loba_Ultimate_Staff_VaultAlarm"

const float GRENADE_FUSE = 2.0
const float PANEL_UPWARD_OFFSET = 69.0
const float PANEL_USABLE_DISTANCE_OVERRIDE = 20.0
const float PANEL_USABLE_HEIGHT = 80.0
const float DOOR_TOTAL_TRAVEL_DIST = 50.0
const float EXPLOSIVE_HOLD_MAX_LOOT_DISTANCE = 130

const asset EXPLOSIVE_HOLD_PANEL_ANIM_IDLE = $"animseq/props/explosivehold_panel_animated/explosivehold_panel_idle.rseq"
const asset EXPLOSIVE_HOLD_EXPLOSION_FX = $"P_impact_exp_smll_metal"
const asset EXPLOSIVE_HOLD_VENT_SMOKE_FX = $"P_exp_hold_vent_smk_linger_sm"

const int EXPLOSIVE_HOLD_WEAPONS_NEEDED = 6 // needs to be greater or equal to the number of gun racks in the hold
const int EXPLOSIVE_HOLD_CRATE_WEAPON_LOOT_TIER = 5

// No-Place Volume Stuff
const int EXPLOSIVEHOLD_NOPLACEVOL_RADIUS = 220
const int EXPLOSIVEHOLD_NOPLACEVOL_HEIGHT = 150
const int EXPLOSIVEHOLD_NOPLACEVOL_COUNT = 1

// Breach Volumes Stuff
const int EXPLOSIVEHOLD_BREACHTRIGGER_RADIUS = 75
const int EXPLOSIVEHOLD_BREACHTRIGGER_HEIGHT = 75
const int EXPLOSIVEHOLD_BREACHTRIGGER_COUNT = 3
const string EXPLOSIVEHOLD_BREACH_ALARM = "Loba_Ultimate_Staff_VaultAlarm"

global const string GRENADE_EMP_WEAPON_NAME = "mp_weapon_grenade_emp"

#if SERVER
const int EXPLOSIVE_HOLD_PANEL_USE_PARAMS = USABLE_CUSTOM_HINTS | USABLE_BY_OWNER | USABLE_BY_PILOTS | USABLE_BY_ENEMIES

const vector PANEL_BOUNDING_BOX_MIN = <-10,-10,60>
const vector PANEL_BOUNDING_BOX_MAX = <10,10,70>

#if DEVELOPER
global function DEV_GiveGrenades
global function DEV_LootHold_ShowAll
global function DEV_LootHold_GotoNearest
#endif // DEVELOPER

#endif // SERVER

const asset EXPLOSIVE_HOLD_ARC_GRENADE_MODEL = $"mdl/weapons_r5/loot/w_loot_wep_iso_shuriken.rmdl"

struct ExplosiveHoldGrenadeData
{
	asset  panelOpenAnim
	string thirdPersonAnim
	string firstPersonAnim
	asset  modelName
	string weaponName
	string targetName

	asset panelOpenAnim_Fuse
	string firstPersonAnim_Fuse
}
const ExplosiveHoldGrenadeData fragGrenadeData = {
	panelOpenAnim = $"animseq/props/explosivehold_panel_animated/explosivehold_panel_open_frag.rseq",
	thirdPersonAnim = "pilot_explosive_hold_start_thermite",
	firstPersonAnim = "ptpov_explosive_hold_start_frag",
	modelName = $"mdl/weapons/grenades/m20_f_grenade.rmdl",
	weaponName = "mp_weapon_frag_grenade",
	targetName = "explosive_hold_frag_grenade",

	panelOpenAnim_Fuse = $"animseq/props/explosivehold_panel_animated/explosivehold_panel_open_frag_fuse.rseq",
	firstPersonAnim_Fuse = "ptpov_explosive_hold_start_frag_fuse"
}

const ExplosiveHoldGrenadeData thermiteGrenadeData = {
	panelOpenAnim = $"animseq/props/explosivehold_panel_animated/explosivehold_panel_open_thermite.rseq",
	thirdPersonAnim = "pilot_explosive_hold_start_thermite",
	firstPersonAnim = "ptpov_explosive_hold_start_thermite",
	modelName = $"mdl/weapons/grenades/w_thermite_grenade.rmdl",
	weaponName = "mp_weapon_thermite_grenade",
	targetName = "explosive_hold_thermite_grenade",

	panelOpenAnim_Fuse = $"animseq/props/explosivehold_panel_animated/explosivehold_panel_open_thermite_fuse.rseq",
	firstPersonAnim_Fuse = "ptpov_explosive_hold_start_thermite_fuse"
}

const ExplosiveHoldGrenadeData arcGrenadeData = {
	panelOpenAnim = $"animseq/props/explosivehold_panel_animated/explosivehold_panel_open_shuriken.rseq",
	thirdPersonAnim = "pilot_explosive_hold_start_thermite",
	firstPersonAnim = "ptpov_explosive_hold_start_shuriken",
	modelName = EXPLOSIVE_HOLD_ARC_GRENADE_MODEL,
	weaponName = GRENADE_EMP_WEAPON_NAME,
	targetName = "explosive_hold_arc_grenade",

	panelOpenAnim_Fuse = $"animseq/props/explosivehold_panel_animated/explosivehold_panel_open_shuriken_fuse.rseq",
	firstPersonAnim_Fuse = "ptpov_explosive_hold_start_shuriken_fuse"
}

struct ExplosiveHoldData
{
	array<entity> panels
	array<entity> panelHousings
	array<entity> lootEnts
	entity rightDoor
	entity leftDoor
	array<entity> ventFXHelpers
	entity holdProxy

	// Special volume stuff
	array< vector > entranceLocs // Base of the doorways. Used to calculate dynamically-spawned volumes such as No-Place Volumes and Breach Triggers.
	array< entity > noPlaceVolumes // Special Volumes created by CreateTriggerCylinderNetworked_NoObjectPlacementSpecial() between the panels to avoid Alter exploits into unopened vaults.
	array< entity > breachTriggers // Special Volumes created to detect pre-open intrusions into the Explosive Loot Hold.

	entity currentUser // Player using panel, if any. Need this to kick them off if an Alter breaches before the anim is done.
}

struct DoorInfo
{
	vector moveDir
	entity door
	entity mover
}

struct
{
	array< entity > explosiveHoldEnts // GetEntArrayByScriptName( EXPLOSIVE_HOLD_SCRIPTNAME )

	array < ExplosiveHoldGrenadeData > grenadeDatas = [ fragGrenadeData, thermiteGrenadeData, arcGrenadeData ]

	#if SERVER
		table< entity, ExplosiveHoldData >	explosiveHoldDataGroups
		string 							rackLootGroup
		array<string> 					weaponClasses
		table< string, array<string> > 	weaponsByClass
	#endif //SERVER
} file

void function ShExplosiveHold_Init()
{
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )

	#if SERVER
		//AddCallback_OnClientConnectionLost( ExplosiveHold_OnPlayerConnectionChanged ) // If we are disconnected midway through the animation, we need to disconnect
	#endif // SERVER

	#if CLIENT
		AddCreateCallback( "prop_dynamic", OnPanelCreated )
	#endif // CLIENT

	RegisterSignal( "LootHoldUseDone" )
	RegisterSignal( "LootHoldUseFail" )
	RegisterSignal( "LootHoldUserBootedByBreach" )
	RegisterSignal( "LootHoldConnectionChanged" )
	RegisterSignal( "MaybeActivateExplosiveHoldDefense_Thread" )
}

array< entity > function _ExplosiveHoldEnts_Get()
{
	return( file.explosiveHoldEnts )
}

void function EntitiesDidLoad()
{
	file.explosiveHoldEnts = GetEntArrayByScriptName( EXPLOSIVE_HOLD_SCRIPTNAME )
	if( file.explosiveHoldEnts.len() == 0 )
		return

	//PrecacheScriptString( EXPLOSIVE_HOLD_MOVER_SCRIPTNAME )
	PrecacheParticleSystem( EXPLOSIVE_HOLD_EXPLOSION_FX )
	PrecacheParticleSystem( EXPLOSIVE_HOLD_VENT_SMOKE_FX )

#if SERVER
	PrecacheModel( EXPLOSIVE_HOLD_PROXY )

	CreateGunRackLootData()

	bool explosiveHoldStartsOpen = ExplosiveHold_GetStartEmpty()

	foreach ( entity explosiveHold in file.explosiveHoldEnts )
	{
		ExplosiveHoldData  				data

		array<string> weaponClasses = GetRandomWeaponClasses() // return a copy of the weapon classes that exist
		array<string> selectedWeapons

		foreach ( entity linkEnt in explosiveHold.GetLinkEntArray() )
		{
			string scriptName = linkEnt.GetScriptName()

			if ( scriptName == EXPLOSIVE_HOLD_PANEL_SCRIPTNAME )
			{
				linkEnt.SetParent( explosiveHold )
				linkEnt.SetUsable()
				linkEnt.SetBoundingBox( PANEL_BOUNDING_BOX_MIN, PANEL_BOUNDING_BOX_MAX )
				linkEnt.SetUsablePriority( USABLE_PRIORITY_MEDIUM )
				linkEnt.AddUsableValue( EXPLOSIVE_HOLD_PANEL_USE_PARAMS )
				linkEnt.Anim_PlayOnly( EXPLOSIVE_HOLD_PANEL_ANIM_IDLE )

				AddCallback_OnUseEntity_ClientServer( linkEnt, ExplosiveHoldDoor_OnUse )
				SetCallback_CanUseEntityCallback_Retail( linkEnt, ExplosiveHoldDoor_CanUse )

				foreach ( entity panelLinkEnt in linkEnt.GetLinkEntArray() )
				{
					if ( panelLinkEnt.GetScriptName() == EXPLOSIVE_HOLD_DOOR_RIGHT )
					{
						data.rightDoor = panelLinkEnt
						data.rightDoor.SetParent( linkEnt )
					}
					else if ( panelLinkEnt.GetScriptName() == EXPLOSIVE_HOLD_DOOR_LEFT )
					{
						data.leftDoor = panelLinkEnt
						data.leftDoor.SetParent( linkEnt )
					}
					else if ( panelLinkEnt.GetScriptName() == EXPLOSIVE_HOLD_PANEL_HOUSING )
					{
						entity panelHousing = panelLinkEnt
						//Avoids issues with the panel moving while grenades are stuck to it
						panelHousing.e.preventStickyEnts = true
						panelHousing.SetParent( linkEnt )
						data.panelHousings.append( panelHousing )
					}
					else if ( panelLinkEnt.GetScriptName() == EXPLOSIVE_HOLD_VENT_SMOKE_SCRIPTNAME )
					{
						entity ventFX = panelLinkEnt
						ventFX.SetParent( linkEnt )
						data.ventFXHelpers.append( ventFX )
					}
				}

				if( explosiveHoldStartsOpen )
				{
					data.rightDoor.ClearParent()
					data.rightDoor.SetAbsOrigin( data.rightDoor.GetOrigin() - data.rightDoor.GetRightVector() * DOOR_TOTAL_TRAVEL_DIST )
					data.leftDoor.ClearParent()
					data.leftDoor.SetAbsOrigin( data.leftDoor.GetOrigin() + data.leftDoor.GetRightVector() * DOOR_TOTAL_TRAVEL_DIST )
					linkEnt.Destroy()
				}
				else
				{
					data.panels.append( linkEnt )
					data.entranceLocs.append( linkEnt.GetOrigin() )
				}
			}
			else if ( scriptName == "explosive_hold_proxy" )
			{
				data.holdProxy = CreateExplosiveHoldPingProp( linkEnt.GetOrigin(), linkEnt.GetAngles(), explosiveHold )
				linkEnt.Destroy()
			}
			else if ( scriptName == EXPLOSIVE_HOLD_GUN_RACK_SCRIPTNAME )
			{
				if( !explosiveHoldStartsOpen )
				{
					string weaponClass = (weaponClasses.len() == 0) ?  "" : weaponClasses.pop()
					if ( weaponClass != "" )
					{
						string weapon
						int attempts = 0
						do {
							// if we do have two of the same weapon classes, ensure we are not selecting the same weapon
							weapon = SURVIVAL_GetWeightedItemFromGroup( EXPLOSIVE_HOLD_WEAPON_LOOT_GROUP )
							attempts++
						} while ( selectedWeapons.contains( weapon ) && attempts <= 3 )

						selectedWeapons.append( weapon )
						entity lootEnt = GunRacks_CreateAndSetupUpWeapon( linkEnt, weapon )
						GunRacks_AddLootItemToRack( linkEnt, lootEnt )
						data.lootEnts.append( lootEnt )
					}
					else
					{
						GunRacks_SetRackOff( linkEnt )
					}
				}
			}
			else if ( scriptName == EXPLOSIVE_HOLD_ATTACHMENTS_PARENT_SCRIPTNAME )
			{
				if( !explosiveHoldStartsOpen )
				{
					string floorLootGroup = GetCurrentPlaylistVarString( "explosive_hold_floor_loot_group", EXPLOSIVE_HOLD_ATTACHMENTS_LOOT_GROUP ).tolower()
					array< string > lootRefs = SURVIVAL_GetMultipleWeightedItemsFromGroup( floorLootGroup, 6 )
					int spawnCount = 0

					foreach ( target in linkEnt.GetLinkEntArray() )
					{
						entity attachment = SpawnLoot( lootRefs[ spawnCount ], target.GetOrigin(), false )
						data.lootEnts.append( attachment )
						spawnCount++
						target.Destroy()
					}
				}
				else
				{
					foreach ( target in linkEnt.GetLinkEntArray() )
					{
						target.Destroy()
					}
				}

				linkEnt.Destroy()
			}
		}

		if( explosiveHoldStartsOpen )
		{
			StatusEffect_AddEndless( explosiveHold, eStatusEffect.hold_is_open, 1.0 )
			GradeFlagsClear( data.holdProxy, eGradeFlags.IS_LOCKED )
		}
		else
		{
			GradeFlagsSet( data.holdProxy, eGradeFlags.IS_LOCKED )
		}

		file.explosiveHoldDataGroups[ explosiveHold ] <- data

		if( !explosiveHoldStartsOpen )
		{
			SpecialVolumes_Create( explosiveHold )
		}
	}
#endif //SERVER
}

#if SERVER
ExplosiveHoldData ornull function ExplosiveHoldData_Get( entity explosiveHold )
{
	if( !( explosiveHold in file.explosiveHoldDataGroups ) )
		return null

	return( file.explosiveHoldDataGroups[ explosiveHold ] )
}

ExplosiveHoldData ornull function ExplosiveHoldData_Get_ByPanel( entity panel )
{
	entity explosiveHold = panel.GetParent()
	return( ExplosiveHoldData_Get( explosiveHold ) )
}

// -------------------
// --- SPECIAL VOLUME ( NoPlace and Breach Trigger ) Functions
// -------------------

void function SpecialVolumes_Create( entity explosiveHold )
{
	if( !IsValid( explosiveHold ) )
		return

	if( ExplosiveHold_NoPlaceVols_Enabled() )
	{
		NoPlaceVols_Create( explosiveHold )
	}

	if( ExplosiveHold_BreachTriggers_Enabled() )
	{
		BreachTriggers_Create( explosiveHold )
	}
}

void function SpecialVolumes_Destroy( entity explosiveHold )
{
	if( !IsValid( explosiveHold ) )
		return

	if( ExplosiveHold_NoPlaceVols_Enabled() )
	{
		NoPlaceVols_Destroy( explosiveHold )
	}

	if( ExplosiveHold_BreachTriggers_Enabled() )
	{
		BreachTriggers_Destroy( explosiveHold )
	}
}

// -------------------
// --- NO-PLACE VOLUME Functions
// -------------------

array< entity > function NoPlaceVols_Get( entity explosiveHold )
{
	ExplosiveHoldData ornull data = ExplosiveHoldData_Get( explosiveHold )

	if( data == null )
		return []

	expect ExplosiveHoldData( data )
	return( data.noPlaceVolumes )
}

void function NoPlaceVols_Create( entity explosiveHold )
{
	Assert( IsValid( explosiveHold ), FUNC_NAME() + "(): ERROR! Explosive Hold is null." )

	ExplosiveHoldData ornull data = ExplosiveHoldData_Get( explosiveHold )

	Assert( data != null, FUNC_NAME() + "(): ERROR! Explosive Hold Data is null for Hold @ " + explosiveHold.GetOrigin() )

	expect ExplosiveHoldData( data )
	array< vector > endPoints = data.entranceLocs

	Assert( endPoints.len() == 2, FUNC_NAME() + "(): ERROR! Need 2 End Points to Properly Create No-Place Volume for Loot Hold @ " + explosiveHold.GetOrigin()  )

	// Create no-place volumes between the endpoints.
	int numPoints = EXPLOSIVEHOLD_NOPLACEVOL_COUNT + 2 // # volumes needed + 2 endpoints.
	array< vector > noPlaceLocs = GetPointsAlongLine( endPoints[ 0 ], endPoints[ 1 ], numPoints )

	for( int i = 1; i <= EXPLOSIVEHOLD_NOPLACEVOL_COUNT; i++ ) // Use the points inside between the end points, from index 1 to index EXPLOSIVEHOLD_NOPLACEVOL_COUNT.
	{
		vector loc = noPlaceLocs[ i ]
		entity noPlaceVol = CreateTriggerCylinderNetworked_NoObjectPlacementSpecial( loc, EXPLOSIVEHOLD_NOPLACEVOL_RADIUS, EXPLOSIVEHOLD_NOPLACEVOL_HEIGHT, 0.0, < 0, 0, 0 > )
		data.noPlaceVolumes.append( noPlaceVol )
	}
}

void function NoPlaceVols_Destroy( entity explosiveHold )
{
	ExplosiveHoldData ornull data = ExplosiveHoldData_Get( explosiveHold )

	if( data == null )
		return

	expect ExplosiveHoldData( data )
	foreach( vol in data.noPlaceVolumes )
	{
		vol.Destroy()
	}
	data.noPlaceVolumes = []
}

// -------------------
// --- BREACH TRIGGER Functions
// -------------------

array< entity > function BreachTriggers_Get( entity explosiveHold )
{
	ExplosiveHoldData ornull data = ExplosiveHoldData_Get( explosiveHold )

	if( data == null )
		return []

	expect ExplosiveHoldData( data )
	return( data.breachTriggers )
}

void function BreachTriggers_Create( entity explosiveHold )
{
	Assert( IsValid( explosiveHold ), FUNC_NAME() + "(): ERROR! Explosive Hold is null." )

	ExplosiveHoldData ornull data = ExplosiveHoldData_Get( explosiveHold )

	Assert( data != null, FUNC_NAME() + "(): ERROR! Explosive Hold Data is null for Hold @ " + explosiveHold.GetOrigin() )

	expect ExplosiveHoldData( data )
	array< vector > endPoints = data.entranceLocs

	Assert( endPoints.len() == 2, FUNC_NAME() + "(): ERROR! Need 2 End Points to Properly Create No-Place Volume for Loot Hold @ " + explosiveHold.GetOrigin()  )

	// Create no-place volumes between the endpoints.
	int numPoints = EXPLOSIVEHOLD_BREACHTRIGGER_COUNT + 2 // # volumes needed + 2 endpoints.
	array< vector > noPlaceLocs = GetPointsAlongLine( endPoints[ 0 ], endPoints[ 1 ], numPoints )

	for( int i = 1; i <= EXPLOSIVEHOLD_BREACHTRIGGER_COUNT; i++ ) // Use the points inside between the end points, from index 1 to index EXPLOSIVEHOLD_NOPLACEVOL_COUNT.
	{
		vector loc = noPlaceLocs[ i ]

		entity breachTrigger = CreateTriggerCylinderNoCylinderRadius( loc, EXPLOSIVEHOLD_BREACHTRIGGER_RADIUS, EXPLOSIVEHOLD_BREACHTRIGGER_HEIGHT, 0 )
		breachTrigger.SetOwner( explosiveHold )
		breachTrigger.SetEnterCallback( BreachTrigger_OnEnter )
		data.breachTriggers.append( breachTrigger )
	}
}

void function BreachTriggers_Destroy( entity explosiveHold )
{
	ExplosiveHoldData ornull data = ExplosiveHoldData_Get( explosiveHold )

	if( data == null )
		return

	expect ExplosiveHoldData( data )
	foreach( vol in data.breachTriggers )
	{
		vol.Destroy()
	}
	data.breachTriggers = []
}

void function BreachTrigger_OnEnter( entity trigger, entity player )
{
	if( !IsValidPlayer( player ) )
		return

	if( !IsValid( trigger ) )
		return

	entity explosiveHold = trigger.GetOwner()

	Assert( IsValid( explosiveHold ), FUNC_NAME() + "(): ERROR! Explosive Loot Hold is NULL" )

	thread ForcedBreach_Thread( explosiveHold )
}

void function ForcedBreach_Thread( entity explosiveHold )
{
	if( StatusEffect_HasSeverity( explosiveHold, eStatusEffect.hold_is_open ) )
		return

	ExplosiveHold_MarkOpened( explosiveHold )

	// Kick off any players animating to place a grenade.
	entity player = CurrentUser_Get( explosiveHold )
	if( IsValidPlayer( player ) )
	{
		player.Signal( "LootHoldUserBootedByBreach" )
	}

	ExplosiveHoldData ornull data = ExplosiveHoldData_Get( explosiveHold )

	Assert( data != null, FUNC_NAME() + "(): ERROR! Explosive Hold Data is null for Hold @ " + explosiveHold.GetOrigin() )

	expect ExplosiveHoldData( data )

	// Explode and open doors.
	foreach( panel in data.panels )
	{
		thread ForcedBreach_OpenPanel_Thread( panel )
	}

	thread ForcedBreach_Alarm_Thread( explosiveHold )
}

void function ForcedBreach_Alarm_Thread( entity explosiveHold )
{
	if( !IsValid( explosiveHold ) )
		return

	explosiveHold.EndSignal( "OnDestroy" )

	PassByReferenceVector loc
	loc.value = explosiveHold.GetOrigin()

	OnThreadEnd(
		function() : ( loc  )
		{
			StopSoundAtPosition( loc.value, EXPLOSIVEHOLD_BREACH_ALARM )
		}
	)

	wait ( 1.0 )

	// Play the alarm sound for 14 seconds at 3 second intervals to match Loot Hold alarm.
	float startTime = Time()
	while ( Time() < startTime + 14.0 )
	{
		EmitSoundAtPosition( TEAM_ANY, loc.value, EXPLOSIVEHOLD_BREACH_ALARM, explosiveHold )
		wait 3.0
	}
}

void function ForcedBreach_OpenPanel_Thread( entity panel )
{
	panel.UnsetUsable()

	float randomDelay = RandomFloatRange( 1.0, 1.35 )
	wait( randomDelay )

	vector explosionPos = panel.GetOrigin() + < 0, 0, 50 >

	//// Uncomment to debug.
	//#if DEVELOPER
	//	DebugDrawSphere( explosionPos, 32, <255, 0, 0>, true, 15 )
	//#endif // DEVELOPER

	PlayFX( EXPLOSIVE_HOLD_EXPLOSION_FX, explosionPos, panel.GetAngles(), null)

	EmitSoundAtPosition( TEAM_ANY, explosionPos, GRENADE_DETONATE_SOUND, panel )
	EmitSoundAtPosition( TEAM_ANY, explosionPos, OPEN_DOOR_DAMAGED_SOUND, panel )

	thread ExplosiveHoldDoor_DoorResponse_Thread( panel, true )
}

#endif // SERVER

#if CLIENT
void function OnPanelCreated( entity panel )
{
	if ( panel.GetScriptName() != EXPLOSIVE_HOLD_PANEL_SCRIPTNAME )
		return

	AddCallback_OnUseEntity_ClientServer( panel, ExplosiveHoldDoor_OnUse )
	SetCallback_CanUseEntityCallback_Retail( panel, ExplosiveHoldDoor_CanUse )
	AddEntityCallback_GetUseEntOverrideText( panel, GetExplosiveHoldUseTextOverride )
}
#endif // CLIENT

#if SERVER
entity function CreateExplosiveHoldPingProp( vector origin, vector angles, entity explosiveHold )
{
	entity explosiveHoldProp = CreateEntity( "prop_dynamic" )
	explosiveHoldProp.SetModel( EXPLOSIVE_HOLD_PROXY )
	explosiveHoldProp.SetOrigin( origin )
	explosiveHoldProp.SetAngles( angles )

	explosiveHoldProp.kv.SpawnAsPhysicsMover = false
	explosiveHoldProp.SetValueForModelKey( EXPLOSIVE_HOLD_PROXY )
	explosiveHoldProp.kv.solid = SOLID_VPHYSICS
	explosiveHoldProp.kv.DisableBoneFollowers = 1
	explosiveHoldProp.kv.fadedist = 100000
	explosiveHoldProp.kv.collide_bullet = 0
	explosiveHoldProp.kv.contents = CONTENTS_BLOCK_PING
	explosiveHoldProp.Code_SetTeam( TEAM_NPC_HOSTILE_TO_ALL )

	DispatchSpawn( explosiveHoldProp )
	explosiveHoldProp.Highlight_Enable()
	explosiveHoldProp.Hide()
	explosiveHoldProp.SetParent( explosiveHold )
	explosiveHold.LinkToEnt( explosiveHoldProp )

	return explosiveHoldProp
}
#endif // SERVER

bool function ExplosiveHold_IsAnimatedInteraction( entity player, entity panel )
{
	vector playerToPanel = panel.GetOrigin() - player.GetOrigin()

	// Animated interaction only occurs outside the hold to plant the grenade
	if ( DotProduct( panel.GetForwardVector(), playerToPanel ) < 0 )
		return true

	return false
}

bool function ExplosiveHoldDoor_CanUse( entity player, entity panel, int useFlags )
{
	if ( ExplosiveHold_IsAnimatedInteraction( player, panel ) && !SURVIVAL_PlayerCanUse_AnimatedInteraction( player, panel ) )
		return false

	vector playerToPanel = panel.GetOrigin() - player.GetOrigin()
	if ( DotProduct( panel.GetUpVector(), playerToPanel ) < -PANEL_USABLE_HEIGHT )
		return false

	return true
}

#if CLIENT
string function GetExplosiveHoldUseTextOverride( entity panel )
{
	entity player = GetLocalClientPlayer()

	if ( ExplosiveHold_IsAnimatedInteraction( player, panel ) )
	{
		if ( !ExplosiveHold_IsOpen( panel ) )
		{
			if ( !ExplosiveHold_PlayerHasGrenadeInInventory( player ) )
				return "#EXPLOSIVEHOLD_HINT_MISSING_GRENADE"
			else
				return "#EXPLOSIVEHOLD_HINT"
		}
		else
			return ""
	}

	return "#EXPLOSIVEHOLD_HINT_INTERIOR"
}
#endif //CLIENT

void function ExplosiveHoldDoor_OnUse( entity panel, entity player, int useInputFlags )
{
	if( player.IsInventoryOpen() )
		return

	if ( ExplosiveHold_IsAnimatedInteraction( player, panel ) )
	{

		if ( !ExplosiveHold_IsOpen( panel ) )
		{
			if ( IsBitFlagSet( useInputFlags, USE_INPUT_LONG ) )
			{
				if ( !ExplosiveHold_PlayerHasGrenadeInInventory( player ) )
				{
					#if SERVER
						EmitSoundOnEntityOnlyToPlayer( panel, player, DOOR_DENY_SOUND )
					#endif // SERVER
					return
				}
				thread ExplosiveHoldDoor_UseThink_Thread( panel, player )
			}
		}
		#if SERVER
		else
		{
			EmitSoundOnEntityOnlyToPlayer( panel, player, DOOR_DENY_SOUND )
		}
		#endif // SERVER
	}
	#if SERVER
	else
		thread ExplosiveHoldDoor_DoorResponse_Thread( panel, false )
	#endif // SERVER
}

void function ExplosiveHoldDoor_UseThink_Thread( entity ent, entity playerUser )
{
	if( playerUser.IsInventoryOpen() )
		return

	ExtendedUseSettings settings
	settings.duration = 0.3

	#if SERVER
		thread LootHoldDisableWeaponsAndInventory_Thread(  playerUser )
		settings.successFunc = ExplosiveHoldDoor_ExtendedUsePlantGrenade
		settings.failureFunc = ExplosiveHoldDoor_Use_Failure
	#endif // SERVER

	#if CLIENT || UI
		settings.loopSound = "survival_titan_linking_loop"
		settings.successSound = "ui_menu_store_purchase_success"
		settings.icon = $""
		settings.hint = Localize( "#EXPLOSIVEHOLD_ACTIVATE" )
		settings.displayRui = $"ui/extended_use_hint.rpak"
		settings.displayRuiFunc = ExplosiveHoldDoor_DisplayRui
	#endif // CLIENT || UI

	waitthread ExtendedUse( ent, playerUser, settings )
}

#if SERVER
void function LootHoldDisableWeaponsAndInventory_Thread( entity player )
{
	Assert ( IsNewThread(), "Must be threaded off" )

	if ( !IsValid( player ) )
		return

	player.EndSignal( "DeathTotem_PreRecallPlayer" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "BleedOut_OnStartDying" )
	player.EndSignal( "Interrupted" )
	player.EndSignal( "LootHoldConnectionChanged" )
	player.EndSignal( "LootHoldUseDone" )
	player.EndSignal( "LootHoldUseFail" )
	player.EndSignal( "OnContinousUseStopped" )
	player.EndSignal( "OnDestroy" )


	DisableOffhandWeapons( player )
	DisableInventory( player )

	OnThreadEnd(
		function() : ( player )
		{
			Assert( IsValid ( player ) || (  !IsValid ( player ) && IsInvalidButMemberVarsStillValid ( player ) ), "LootHoldDisableWeaponsAndInventory_Thread(): player shouldn't be invalid!" )
			EnableOffhandWeapons( player )
			EnableInventory( player )
		}
	)

	while ( true )
	{
		WaitFrame()
	}
}
#endif // SERVER

void function ExplosiveHoldDoor_Use_Failure( entity ent, entity playerUser, ExtendedUseSettings settings )
{
	#if SERVER
	if( IsValid( playerUser ) )
	{
		playerUser.Signal( "LootHoldUseFail" )
	}
	#endif // SERVER
}

void function ExplosiveHoldDoor_DisplayRui( entity ent, entity player, var rui, ExtendedUseSettings settings )
{
	#if CLIENT || UI
		RuiSetString( rui, "holdButtonHint", settings.holdHint )
		RuiSetString( rui, "hintText", settings.hint )
		RuiSetGameTime( rui, "startTime", Time() )
		RuiSetGameTime( rui, "endTime", Time() + settings.duration )
	#endif //CLIENT || UI
}

#if SERVER
void function ExplosiveHoldDoor_ExtendedUsePlantGrenade( entity panel, entity player, ExtendedUseSettings settings )
{
	if ( !IsValid( player ) )
		return

	// In the event the ordnance slot is empty but there's a grenade in inventory, equip inventory grenade for interaction.
	// This appears to be a rare occurance, so far only reported as a result of the respawn in Second Chance mode.
	if ( !IsValid( player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_ANTI_TITAN ) ) )
		SURVIVAL_AutoEquipOrdnanceFromInventory( player, false )

	entity heldOrdnance = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_ANTI_TITAN )

	if ( !IsValid( heldOrdnance ) )
		return

	ExplosiveHoldGrenadeData ornull found = null
	if ( heldOrdnance )
	{
		foreach ( info in file.grenadeDatas )
		{
			if ( heldOrdnance.GetWeaponClassName() == info.weaponName )
			{
				found = info
				break
			}
		}
	}

	if ( found == null )
	{
		foreach ( info in file.grenadeDatas )
		{
			if ( SURVIVAL_HasSpecificItemInInventory( player, info.weaponName, 1 ) )
			{
				found = info
				break
			}
		}
	}

	if ( found != null )
	{
		expect ExplosiveHoldGrenadeData( found )
		thread ExplosiveHoldAnimation_Thread( panel, player, found )
	}
}

void function ExplosiveHold_GetOrdnance( entity panel, entity player, string weaponName )
{
	if ( !IsValid( panel ) )
		return

	entity explosiveHold = panel.GetParent()
	if ( !IsValid( explosiveHold ) )
		return

	SURVIVAL_RemoveFromPlayerInventory( player, weaponName, 1 )

	RefreshOrdnanceSlot( player, weaponName )

	if ( IsValid( panel ) )
		panel.UnsetUsable()
}

void function CurrentUser_Set( entity explosiveHold, entity player )
{
	if( !IsValid( explosiveHold ) )
		return

	ExplosiveHoldData ornull data = ExplosiveHoldData_Get( explosiveHold )

	Assert( data != null, FUNC_NAME() + "(): ERROR: ExplosiveHoldData is null for hold @ " + explosiveHold.GetOrigin() )

	expect ExplosiveHoldData( data )
	data.currentUser = player
}

entity function CurrentUser_Get( entity explosiveHold )
{
	entity result

	if( !IsValid( explosiveHold ) )
		return result

	ExplosiveHoldData ornull data = ExplosiveHoldData_Get( explosiveHold )

	Assert( data != null, FUNC_NAME() + "(): ERROR: ExplosiveHoldData is null for hold @ " + explosiveHold.GetOrigin() )

	expect ExplosiveHoldData( data )
	return( data.currentUser )
}

void function ExplosiveHold_BreachKickOffPlayer_Watch_Thread( entity explosiveHold, entity panel, entity player, table< string, bool> e )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "BleedOut_OnStartDying" )
	player.EndSignal( "DeathTotem_PreRecallPlayer" )
	player.EndSignal( "OnAnimationInterrupted" )
	player.EndSignal( "Interrupted" )
	panel.EndSignal( "OnDestroy" )

	player.EndSignal( "LootHoldUseDone" )

	player.WaitSignal( "LootHoldUserBootedByBreach" )
	e[ "kickedoff_bybreach" ] <- true
	player.Signal( "LootHoldUseDone" )
}

void function ExplosiveHoldAnimation_Thread( entity panel, entity player, ExplosiveHoldGrenadeData data )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "BleedOut_OnStartDying" )
	player.EndSignal( "DeathTotem_PreRecallPlayer" )
	player.EndSignal( "OnAnimationInterrupted" )
	player.EndSignal( "Interrupted" )
	panel.EndSignal( "OnDestroy" )
	player.EndSignal( "LootHoldUseDone" )

	if ( player.GetParent() != null ) // this is a null check to match a code-side check, don't change to IsValid
		return

	table<string, bool> e
	e["success"] <- false
	e[ "kickedoff_bybreach" ] <- false
	entity explosiveHold = panel.GetParent()
	thread ExplosiveHold_BreachKickOffPlayer_Watch_Thread( explosiveHold, panel, player, e )

	CurrentUser_Set( explosiveHold, player )

	panel.UnsetUsable()

	OnThreadEnd(
		function() : ( player, panel, e, explosiveHold )
		{
			if( IsValid( explosiveHold ) )
			{
				CurrentUser_Set( explosiveHold, null )
			}

			if ( IsValid( panel ) )
			{
				if (e["success"] )
				{
					PIN_Interact( player, "MapToy_open_explosive_hold", panel.GetOrigin() )


						//if( UpgradeCore_IsEnabled() )
							//UpgradeCore_GrantXp_ExplosiveHoldOpened( player )

				}
				else if ( e[ "kickedoff_bybreach" ] )
				{
					#if DEVELOPER
						printt( FUNC_NAME() + "(): Player kicked off panel animation by a breach: " + player.GetPlayerName() )
					#endif // DEVELOPER
				}
				else
				{
					panel.SetUsable()
					panel.AddUsableValue( EXPLOSIVE_HOLD_PANEL_USE_PARAMS ) // Is removed when achieving SUCCESS, so we need to put them back in. This allows the panel to be "findable" in the client again.  Use debug_use_areas 1 to see entities you can interact with.
					panel.Anim_PlayOnly( EXPLOSIVE_HOLD_PANEL_ANIM_IDLE )
				}
			}
			player.Signal( "LootHoldUseDone" )
			ExplosiveHold_DoAnimCleanupOnPlayer( player )
		}
	)

	string anim1p = data.firstPersonAnim
	string anim3p = data.thirdPersonAnim
	asset panelAnim = data.panelOpenAnim

	if ( player.HasPassive( ePassives.PAS_FUSE ) )
	{
		panelAnim = data.panelOpenAnim_Fuse
		anim1p = data.firstPersonAnim_Fuse
	}

	PlayBattleChatterLineToSpeakerAndTeam( player, "bc_explosiveHold" )

	AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
	AddCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD )

	vector grenadePos = panel.GetOrigin() + ( panel.GetUpVector() * PANEL_UPWARD_OFFSET )

	thread PanelAnimation_Thread( panel, panelAnim, player, grenadePos, data.modelName )
	player.SetAnimNearZ( 1 )
	PlayParentedFirstAndThirdPersonAnimation( player, panel, "ref", anim1p, anim3p )//, true
	waitthread WaittillAnimDone( player )
	StopPlayingAnimation( player )

	ExplosiveHold_GetOrdnance( panel, player, data.weaponName )

	PutPlayerInSafeSpot( player, null, null, player.GetOrigin(), player.GetOrigin() )

	// set hold as opened, note http://jiratf.respawn.net:8080/browse/R5DEV-289165 where explosiveHold was null
	// expect that this was caused by multiple usage of the hold causing this line of code to be run while the
	// panel was unparented
	ExplosiveHold_MarkOpened( explosiveHold )

	foreach ( entity panelEnt in GetChildren(explosiveHold) )
	{
		string scriptName = panelEnt.GetScriptName()
		if ( scriptName == EXPLOSIVE_HOLD_PANEL_SCRIPTNAME )
		{
			Assert( panelEnt.GetSkinIndexByName( "offline" ) != -1 )
			int index = panelEnt.GetSkinIndexByName( "offline" )
			panelEnt.SetSkin( index )
		}
	}

	thread ExplosiveHold_PlantGrenade_Thread( player, panel, grenadePos )
	e["success"] = true
}

void function ExplosiveHold_MarkOpened( entity explosiveHold )
{
	if( !IsValid( explosiveHold ) )
		return

	StatusEffect_AddEndless( explosiveHold, eStatusEffect.hold_is_open, 1.0 )
	SpecialVolumes_Destroy( explosiveHold )
}

void function ExplosiveHold_DoAnimCleanupOnPlayer( entity player )
{
	if ( IsValid( player ) )
	{
		if( ExplosiveHold_IsPlayerPlantingGrenade( player ))
		{
			player.ClearAnimNearZ()
			player.Anim_Stop()

			player.ClearParent()
		}
		RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD_INSTANT )
		RemoveCinematicFlag( player, CE_FLAG_HIDE_PERMANENT_HUD )
	}
}

void function ExplosiveHold_OnPlayerConnectionChanged( entity player )
{
	player.Signal( "LootHoldConnectionChanged" )
	ExplosiveHold_DoAnimCleanupOnPlayer( player )
}

void function PanelAnimation_Thread( entity panel, asset panelAnim, entity player, vector grenadePos, string modelName )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "BleedOut_OnStartDying" )
	player.EndSignal( "DeathTotem_PreRecallPlayer" )
	player.EndSignal( "Interrupted" )
	panel.EndSignal( "OnDestroy" )

	wait 0.39

	if ( IsValid( panel ) )
		panel.Anim_PlayOnly( panelAnim )

	wait 1.84 // Wait until grenade has been embedded in the wires (mid-animation)

	//Fuse's anims have different timing than the other anims, offsetting the audio, need to add a delay specific to Fuse
	if ( player.HasPassive( ePassives.PAS_FUSE ) )
		wait 0.43 // (Fuse's animation needs an extra delay) Wait until grenade has been embedded in the wires (mid-animation)

	if ( IsValid( panel ) )
		EmitSoundAtPosition( TEAM_ANY, panel.GetOrigin(), PANEL_ALARM_SOUND, panel )

	if ( modelName == EXPLOSIVE_HOLD_ARC_GRENADE_MODEL )
		EmitSoundAtPosition( TEAM_ANY, grenadePos, ARC_PLACEMENT_SOUND, panel )
}

void function ExplosiveHold_PlantGrenade_Thread( entity player, entity panel, vector grenadePos )
{
	entity explosiveHold = panel.GetParent()
	SpecialVolumes_Destroy( explosiveHold )

	wait GRENADE_FUSE

	if ( IsValid( panel ) )
		PlayFX( EXPLOSIVE_HOLD_EXPLOSION_FX, grenadePos, panel.GetAngles(), null)

	EmitSoundAtPosition( TEAM_ANY, grenadePos, GRENADE_DETONATE_SOUND, panel )
	EmitSoundAtPosition( TEAM_ANY, grenadePos, OPEN_DOOR_DAMAGED_SOUND, panel )

	thread ExplosiveHoldDoor_DoorResponse_Thread ( panel, true )
}

void function ExplosiveHoldDoor_DoorResponse_Thread ( entity panel, bool wasExploded )
{
	if( !IsValid( panel ) )
		return

	entity explosiveHold = panel.GetParent()

	if( !IsValid( explosiveHold ) )
		return

	ExplosiveHoldData data = file.explosiveHoldDataGroups[ explosiveHold ]

	// Disable Panel
	panel.UnsetUsable()
	panel.Anim_Stop()

	// Get Door Info
	int maxDoors = 2
	array< DoorInfo > doors
	doors.resize( maxDoors )
	foreach ( entity door in GetChildren(panel) )
	{
		string scriptName = door.GetScriptName()
		bool isRightDoor  = ( scriptName == EXPLOSIVE_HOLD_DOOR_RIGHT )
		bool isLeftDoor   = ( scriptName == EXPLOSIVE_HOLD_DOOR_LEFT )
		if ( isRightDoor || isLeftDoor )
		{
			int idx       = isRightDoor ? 0 : 1
			DoorInfo info = doors[idx]
			info.door = door
			info.moveDir = isRightDoor ? -door.GetRightVector() : door.GetRightVector()
			info.mover = CreateScriptMover_NEW( EXPLOSIVE_HOLD_MOVER_SCRIPTNAME, door.GetOrigin(), door.GetAngles(), 0 )
			door.ClearParent()
			door.SetParent( info.mover )

			//ArrowsUnstick( door )

			if ( isRightDoor )
			{
				panel.ClearParent()
				panel.SetParent( info.mover )
			}
		}
	}

	GradeFlagsClear( data.holdProxy, eGradeFlags.IS_LOCKED )

	if ( wasExploded )
	{
		//Tag navmesh underneath the exploded doors as no longer requires a grenade
		//ToggleFlagFromPolygonsForEntities( doors[0].door, doors[1].door, DT_POLY_GRENADE_REQUIRED, false )

		entity otherLeftDoor = null
		entity otherRightDoor = null

		foreach ( entity otherPanel in GetChildren(explosiveHold) )
		{
			if ( otherPanel != panel && otherPanel.GetScriptName() == EXPLOSIVE_HOLD_PANEL_SCRIPTNAME )
			{
				foreach ( entity door in GetChildren(otherPanel) )
				{
					string scriptName = door.GetScriptName()

					if ( scriptName == EXPLOSIVE_HOLD_DOOR_LEFT )
					{
						otherLeftDoor = door
					}
					else if ( scriptName == EXPLOSIVE_HOLD_DOOR_RIGHT )
					{
						otherRightDoor = door
					}
				}
			}
		}

		//Tag navmesh underneath the other doors as no longer requires a grenade
		//But disable for autoplayers as those doors can only be opened from the outside
		if ( otherLeftDoor != null && otherRightDoor != null && IsValid( otherLeftDoor ) && IsValid( otherRightDoor ) )
		{
			//ToggleFlagFromPolygonsForEntities( otherLeftDoor, otherRightDoor, DT_POLY_GRENADE_REQUIRED, false );
			//ToggleFlagFromPolygonsForEntities( otherLeftDoor, otherRightDoor, DT_POLY_DISABLED_FOR_AUTOPLAYERS, true );
		}
	}
	else //If the other doors are opened (no explosion), just untag as blocked for autoplayers
	{
		//ToggleFlagFromPolygonsForEntities( doors[0].door, doors[1].door, DT_POLY_DISABLED_FOR_AUTOPLAYERS, false );
	}

	float totalDist = DOOR_TOTAL_TRAVEL_DIST
	vector panelOrigin = panel.GetOrigin() // get while we know panel is valid

	if ( wasExploded )
	{
		wait 0.1 // It was strange to see the doors open at the same time the vfx started playing - so adding a bit of a delay

		if( IsValid( panel ) )
		{
			entity shake = CreateShake( panelOrigin, 4, 105, 1.0, 250 )
			shake.RemoveFromAllRealms()
			shake.AddToOtherEntitysRealms( panel )
			shake.kv.spawnflags = 4 // SF_SHAKE_INAIR // Cam shake with impact
			//DebugDrawCircle( shake.GetOrigin(), <0,0,0>, 250, <255, 255, 255>, true, 30 )

			// Turn on vent smoke fx
			foreach ( entity vfxEntHelper in GetChildren(panel) )
			{
				string scriptName = vfxEntHelper.GetScriptName()
				if ( scriptName == EXPLOSIVE_HOLD_VENT_SMOKE_SCRIPTNAME )
				{
					entity ventFX = CreateEntity( "info_particle_system" )
					ventFX.SetValueForEffectNameKey( EXPLOSIVE_HOLD_VENT_SMOKE_FX )
					ventFX.kv.start_active    = 1
					ventFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
					ventFX.SetOrigin( vfxEntHelper.GetOrigin() )
					ventFX.SetAngles( vfxEntHelper.GetAngles() )
					DispatchSpawn( ventFX )
				}
			}

			// Stop animating any player who may be on the panel.
			array< entity > children = GetChildren(panel)
			foreach( child in children )
			{
				if( IsValidPlayer( child ) )
				{
					StopPlayingAnimation( child )
					child.Signal( "Interrupted" )
					child.ClearParent()
				}
			}
			// Panel is destroyed in the blast.
			panel.ClearParent()
			panel.Destroy()
		}

		float totalTime    = 0.8
		float part1DistPct = 0.2
		float part1Time    = 0.05

		// Open doors quickly initially to emulate explosion forcing doors open
		float distToTravel = totalDist * part1DistPct
		float timeToTravel = part1Time
		MoveDoors( doors, distToTravel, timeToTravel, 0.0, 0.0 )

		wait timeToTravel

		// The Jiggle - Add this slight delay to make it look like the mechanics are fighting back
		float jiggleDist = -1.0
		float jiggleTime = 0.5
		MoveDoors( doors, jiggleDist, jiggleTime, 0.0, 0.0 )

		wait jiggleTime

		// Now open linearly to emulate normal operation again
		distToTravel = totalDist - (distToTravel + jiggleDist)
		timeToTravel = totalTime - timeToTravel
		MoveDoors( doors, distToTravel, timeToTravel, 0.0, 0.3 * timeToTravel )

		wait timeToTravel + 0.1  // We are seeing doors not fully open this might be due to imprecise timing that can cause us to lose a frame - so adding a tiny fudge factor before killing the mover.
	}
	else
	{
		Assert( panel.GetSkinIndexByName( "unlocked" ) != -1 )
		int index = panel.GetSkinIndexByName( "unlocked" )
		panel.SetSkin( index )

		float distToTravel = totalDist*0.7
		float timeToTravel = 0.4
		EmitSoundAtPosition( TEAM_ANY, panelOrigin, OPEN_DOOR_SOUND, panel )
		MoveDoors( doors, distToTravel, timeToTravel, 0.0, 0.0 )

		wait timeToTravel

		distToTravel = totalDist - distToTravel
		timeToTravel = 0.5
		MoveDoors( doors, distToTravel, timeToTravel, 0.0, 0.0 )

		wait timeToTravel + 0.1 // We are seeing doors not fully open this might be due to imprecise timing that can cause us to lose a frame - so adding a tiny fudge factor before killing the mover.

		// To prevent the panel from destroying with it's parent mover in the cleanup
		if( IsValid( panel ) )
		{
			panel.ClearParent()
			panel.SetParent( data.holdProxy )
		}

		//After the doors open, panelHousing needs to be reparented to the holdProxy otherwise it will crash when pinged
		foreach( entity panelHousing in data.panelHousings )
		{
			if ( IsValid( panelHousing ) )
				panelHousing.SetParent( data.holdProxy )
		}
	}

	// Wait for doors to fully open before cleanup
	wait 2.0

	// Cleanup
	foreach ( doorInfo in doors )
	{
		doorInfo.door.ClearParent()
		doorInfo.mover.Destroy()
		// Reparent doors back to explosiveHold proxy otherwise pings aimed at doors will treat as location
		doorInfo.door.SetParent( data.holdProxy )
	}
}

void function MoveDoors( array< DoorInfo > doors, float distToTravel, float timeToTravel, float easeIn, float easeOut )
{
	foreach ( doorInfo in doors )
	{
		entity door = doorInfo.door
		doorInfo.mover.NonPhysicsMoveTo( door.GetOrigin() + ( doorInfo.moveDir * distToTravel ), timeToTravel, easeIn, easeOut )
	}
}

array<string> function GetRandomWeaponClasses()
{ // this should help support changes to the weapon classes (renames/additions/removals), and ensure 'smart' randomness between holds
	if ( file.weaponClasses.len() == 0 )
		return []

	array<string> weaponClasses = clone( file.weaponClasses )
	while( weaponClasses.len() < EXPLOSIVE_HOLD_WEAPONS_NEEDED )
	{
		weaponClasses.append(weaponClasses.getrandom())
	}
	while( weaponClasses.len() > EXPLOSIVE_HOLD_WEAPONS_NEEDED )
	{
		weaponClasses.remove( RandomInt( weaponClasses.len()-1 ) )
	}
	return weaponClasses
}

void function CreateGunRackLootData()
{
	string culledRackWeaponsStr = GetCurrentPlaylistVarString( "explosive_hold_culled_rack_weapon_classes", "pistol" )
	array<string> culledRackWeaponClasses = []
	culledRackWeaponClasses.extend( split( culledRackWeaponsStr, WHITESPACE_CHARACTERS ) )

	file.rackLootGroup = GetCurrentPlaylistVarString( "explosive_hold_rack_loot_group", EXPLOSIVE_HOLD_WEAPON_LOOT_GROUP ).tolower()
	array<string> weaponLootGroup = SURVIVAL_GetAllRefsInLootGroup( file.rackLootGroup, true )

	foreach( string weapon in weaponLootGroup )
	{
		if ( !SURVIVAL_Loot_IsRefDisabled( weapon ) )
		{
			if ( !SURVIVAL_Loot_IsRefValid( weapon ) )
				continue

			LootData data = SURVIVAL_Loot_GetLootDataByRef( weapon )

			// Avoid crash when indexing an empty lootTags array.  This can happen when overriding loot groups to include non weapons in a weapon group (ie Armed n Dangerous does this)
			if( data.lootType != eLootType.MAINWEAPON || data.lootTags.len() == 0 )
				continue

			string weaponClass = data.lootTags[0]
			if ( !culledRackWeaponClasses.contains( weaponClass ) && data.tier != EXPLOSIVE_HOLD_CRATE_WEAPON_LOOT_TIER )
			{
				if ( weaponClass in file.weaponsByClass )
				{
					file.weaponsByClass[weaponClass].append(data.ref);
				}
				else
				{
					file.weaponClasses.append( weaponClass )
					file.weaponsByClass[weaponClass] <- [data.ref]
				}
			}
		}
	}
}

#if DEVELOPER
void function DEV_GiveGrenades( entity player, int grenadeTypeNDX = 0, int grenadeCount = 3 )
{
	table< int, array<string> > lootNamesByType
	lootNamesByType[eLootType.MAINWEAPON] <- []
	lootNamesByType[eLootType.ATTACHMENT] <- []
	lootNamesByType[eLootType.ARMOR] <- []
	lootNamesByType[eLootType.HELMET] <- []
	lootNamesByType[eLootType.HEALTH] <- []
	lootNamesByType[eLootType.AMMO] <- []
	lootNamesByType[eLootType.ORDNANCE] <- []
	lootNamesByType[eLootType.BACKPACK] <- []

	table< string, LootData > lootDataTable = SURVIVAL_Loot_GetLootDataTable()
	foreach ( string lootName, LootData lootData in lootDataTable )
	{
		if ( !IsLootTypeValid( lootData.lootType ) )
			continue

		if ( !LootTypeHasAnyChanceToSpawn( lootName ) )
			continue
		if ( lootData.lootType in lootNamesByType )
			lootNamesByType[ lootData.lootType ].append( lootName )
	}

	foreach( string grenadeFlavor in lootNamesByType[eLootType.ORDNANCE])
	{
		printt( "Grenade Flavor == " + grenadeFlavor )
	}

	for ( int i = 0 ; i < grenadeCount ; i++ )
	{
		string grenadeName = lootNamesByType[eLootType.ORDNANCE][grenadeTypeNDX]
		printt( "grenadeName chosen == " + grenadeName )
		entity loot = SpawnLoot( grenadeName, player.GetOrigin(), false )
		Survival_PickupItem( loot, player )
	}
}

void function DEV_LootHold_ShowAll( float timeToShow = 30.0 )
{
	array< entity > explosiveHolds = _ExplosiveHoldEnts_Get()
	foreach ( entity explosiveHold in explosiveHolds )
	{
		DebugDrawSphere( explosiveHold.GetOrigin(), 256, 255, 0, 0, true, timeToShow  )

		ExplosiveHoldData ornull data = ExplosiveHoldData_Get( explosiveHold )
		if( data == null )
			continue

		expect ExplosiveHoldData( data )

		if( ExplosiveHold_NoPlaceVols_Enabled() )
		{
			foreach( vol in data.noPlaceVolumes )
			{
				DebugDrawCylinder( vol.GetOrigin(), < -90, 0, 0 >, EXPLOSIVEHOLD_NOPLACEVOL_RADIUS, EXPLOSIVEHOLD_NOPLACEVOL_HEIGHT, 255,255,0, true, timeToShow  )
			}
		}

		if( ExplosiveHold_BreachTriggers_Enabled() )
		{
			foreach( trig in data.breachTriggers )
			{
				DebugDrawCylinder( trig.GetOrigin(), < -90, 0, 0 >, EXPLOSIVEHOLD_BREACHTRIGGER_RADIUS, EXPLOSIVEHOLD_BREACHTRIGGER_HEIGHT, 255,128,0, true, timeToShow  )
			}
		}
	}
	printt( "Loot Holds Count: " + explosiveHolds.len() )
}

void function DEV_LootHold_GotoNearest( entity player )
{
	if( !IsValidPlayer( player ) )
		return

	array< entity > allHolds = _ExplosiveHoldEnts_Get()

	array< entity > openHolds

	foreach( hold in allHolds )
	{
		if( !StatusEffect_HasSeverity( hold, eStatusEffect.hold_is_open ) )
		{
			openHolds.append( hold )
		}
	}

	entity closestHold = ArrayClosest( openHolds, player.GetOrigin() )[ 0 ]

	vector safeSpot = closestHold.GetOrigin()

	PutPlayerInSafeSpot( player, null, null, safeSpot, safeSpot )
}

#endif // DEVELOPER
#endif //SERVER

bool function ExplosiveHold_PlayerHasGrenadeInInventory( entity player )
{
	foreach ( info in file.grenadeDatas )
	{
		int count = SURVIVAL_CountItemsInInventory( player, info.weaponName )
		if ( count > 0 )
			return true
	}

	return false
}

bool function ExplosiveHold_IsOpen( entity explosiveHoldEnt )
{
	// Occasionally hit this case on CLIENT vm when panel was open
	if ( !IsValid( explosiveHoldEnt ) )
		return true

	entity explosiveHold = explosiveHoldEnt.GetParent()
	bool isOpen = false

	if ( IsValid( explosiveHold ) )
		isOpen = StatusEffect_HasSeverity( explosiveHold, eStatusEffect.hold_is_open )

	return isOpen
}

#if SERVER || CLIENT
bool function ExplosiveHold_IsPlayerPlantingGrenade( entity player )
{
	entity possiblePanel = player.GetParent()
	if ( IsValid( possiblePanel ) && possiblePanel.HasKey( "script_name" ) && possiblePanel.GetScriptName() == EXPLOSIVE_HOLD_PANEL_SCRIPTNAME )
	{
		return true
	}

	return false
}
#endif // SERVER || CLIENT

bool function ExplosiveHold_GetStartEmpty()
{
	return GetCurrentPlaylistVarBool( "explosivehold_start_open_and_empty", false )
}

#if SERVER || CLIENT
entity function GetExplosiveHoldProxyForLoot( entity lootEnt )
{
	array< entity > explosiveHoldEnts = _ExplosiveHoldEnts_Get()
	foreach ( entity explosiveHold in explosiveHoldEnts )
	{
		if ( !IsValid( explosiveHold ) )
			continue

		foreach ( entity child in explosiveHold.GetLinkEntArray() )
		{
			if ( child.GetModelName() == EXPLOSIVE_HOLD_PROXY &&
				 sqrt( DistanceSqr( child.GetOrigin(), lootEnt.GetOrigin() ) ) < 2 * EXPLOSIVE_HOLD_MAX_LOOT_DISTANCE )
			{
				return child
			}
		}
	}

	return null
}
#endif //SERVER || CLIENT

#if SERVER
void function MaybeActivateExplosiveHoldDefense_Thread( entity pickup, entity device, entity player  )
{
	if ( !IsValid( pickup ) )
		return

	entity ornull explosiveHold = GetExplosiveHoldFromLoot( pickup )
	if ( explosiveHold == null )
		return

	expect entity( explosiveHold )
	if ( !( explosiveHold in file.explosiveHoldDataGroups ) )
		return

	ExplosiveHoldData explosiveHoldData = file.explosiveHoldDataGroups[ explosiveHold ]

	entity holdPanel = explosiveHoldData.panels[0]
	if ( ExplosiveHold_IsOpen( holdPanel ) )
		return

	EndSignal( holdPanel, "OnDestroy" )

	Signal( holdPanel, "MaybeActivateExplosiveHoldDefense_Thread" )
	EndSignal( holdPanel, "MaybeActivateExplosiveHoldDefense_Thread" )

	if ( IsValid( device ) )
		GradeFlagsSet( device, eGradeFlags.IS_BUSY )

	WaitFrame()

	//DESTROY BLACK MARKET
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
		Explosion( explosionCenter, pickup, pickup, damage, damageHeavyArmor, innerRadius, outerRadius, flags, projectileLaunchPos, explosionForce, scriptDamageFlags, scriptDamageSourceIdentifier, impactEffectTableName )
	}

	explosiveHoldData.lootEnts.fastremovebyvalue( pickup )

	wait 0.2
	float startTime = Time()
	while ( Time() < startTime + 14.0 )
	{
		EmitSoundAtPosition( TEAM_UNASSIGNED, holdPanel.GetOrigin(), LOBA_BLACK_MARKET_ALARM_SOUND, holdPanel )
		wait 3
	}
}

entity ornull function GetExplosiveHoldFromLoot( entity pickup )
{
	foreach ( entity explosiveHold, ExplosiveHoldData explosiveHoldData in file.explosiveHoldDataGroups )
	{
		if ( !IsValid( explosiveHold ) )
			continue

		if ( sqrt( DistanceSqr( explosiveHold.GetOrigin(), pickup.GetOrigin() ) ) < EXPLOSIVE_HOLD_MAX_LOOT_DISTANCE )
		{
			foreach ( entity lootEnt in explosiveHoldData.lootEnts )
			{
				if ( !IsValid( lootEnt ) )
					continue

				if ( lootEnt.GetOrigin() == pickup.GetOrigin() )
					return explosiveHold
			}
			return null
		}
	}

	return null
}
#endif //SERVER

bool function ExplosiveHold_NoPlaceVols_Enabled()
{
	return( GetCurrentPlaylistVarBool( "explosivehold_noplacevols_enabled", false ) )
}

bool function ExplosiveHold_BreachTriggers_Enabled()
{
	return( GetCurrentPlaylistVarBool( "explosivehold_breachtriggers_enabled", false ) )
}