global function LootRollers_Init
global function LootRollers_ForceAddLootRefToRandomLootRollers
global function LootRollers_CreateLootRoller
               
global function LootRollers_CreatePathTTLootRoller
      
global function LootRollers_CreatePhaseDriverLootRoller
                      
global function LootRollers_CreateLootRoller_Armory
      
                    
                                                        
      
global function HACK_AwakenLootRoller
global function LaunchLootRoller
global function LaunchLootRoller_SpinControl
global function GetLootRollerDataFromRollerModel
global function StartLootRollerNotificationSounds

global function AddCallback_LootRollerDamaged
global function RemoveCallback_LootRollerDamaged
global function AddCallback_LootRollerKilled
global function RemoveCallback_LootRollerKilled

global function GetAllLootRollers
global function GetAllLootRollerData

global function DestroyLootRoller
global function LootRollerDestructionSequenceInternal

#if DEV
global function DEV_SpawnLootRollerAtCrosshair
global function DEV_SpawnPartyRoller
global function DEV_SpawnLaunchingRoller
global function DEV_PathfinderTT_Roller
#endif

//Loot Roller Model is now defined in sh_loot_rollers.nut
//const asset LOOT_ROLLER_MODEL = $"mdl/weapons_r5/loot/w_loot_msc_iso_sphere_v1.rmdl" //$"mdl/test/davis_test/loot_ball_blockout.rmdl"

const float LOOT_ROLLER_HEALTH = 100.0
const int NUM_LOOT_ROLLER_LOOT_TO_SPAWN = 5
const int NUM_LOOT_ROLLER_LOOT_TABLES = 5
const float LOOT_ROLLER_RELEASE_DAMAGE_DEBOUNCE_TIME = 1.5

const float LOOT_ROLLER_LOOT_REMOVAL_TIMER = 0.25

const array<string> LOOT_ROLLER_LOOT_TABLES_STANDARD		= [	"loot_roller_contents_01",
	"loot_roller_contents_02",
	"loot_roller_contents_03"]

const array<string> LOOT_ROLLER_LOOT_TABLES_COMMON		= [	"loot_roller_contents_common" ]

const array<string> LOOT_ROLLER_LOOT_TABLES_RARE		= [	"loot_roller_contents_common",
	"loot_roller_contents_common",
	"loot_roller_contents_rare" ]

const array<string> LOOT_ROLLER_LOOT_TABLES_EPIC		= [	"loot_roller_contents_common",
	"loot_roller_contents_rare",
	"loot_roller_contents_epic"]

const array<string> LOOT_ROLLER_LOOT_TABLES_LEGENDARY		= [	"loot_roller_contents_common",
	"loot_roller_contents_rare",
	"loot_roller_contents_epic",
	"loot_roller_contents_legendary"]

               
const array<string> PATHTT_LOOT_ROLLER_LOOT_TABLES_COMMON = [ "pathtt_loot_roller_contents_common" ]

const array<string> PATHTT_LOOT_ROLLER_LOOT_TABLES_RARE	= [
	"pathtt_loot_roller_contents_common",
	"pathtt_loot_roller_contents_common",
	"pathtt_loot_roller_contents_rare" ]

const array<string> PATHTT_LOOT_ROLLER_LOOT_TABLES_EPIC	= [
	"pathtt_loot_roller_contents_common",
	"pathtt_loot_roller_contents_rare",
	"pathtt_loot_roller_contents_epic"]

const array<string> PATHTT_LOOT_ROLLER_LOOT_TABLES_LEGENDARY = [
	"pathtt_loot_roller_contents_common",
	"pathtt_loot_roller_contents_rare",
	"pathtt_loot_roller_contents_epic",
	"pathtt_loot_roller_contents_legendary"]
      

const array<string> PHASEDRIVER_LOOT_ROLLER_LOOT_TABLES_COMMON = [ "telephaser_loot_roller_contents_common" ]

const array<string> PHASEDRIVER_LOOT_ROLLER_LOOT_TABLES_RARE =
[
	"telephaser_loot_roller_contents_common",
	"telephaser_loot_roller_contents_common",
	"telephaser_loot_roller_contents_rare"
]

const array<string> PHASEDRIVER_LOOT_ROLLER_LOOT_TABLES_EPIC =
[
	"telephaser_loot_roller_contents_common",
	"telephaser_loot_roller_contents_rare",
	"telephaser_loot_roller_contents_epic"
]

const array<string> PHASEDRIVER_LOOT_ROLLER_LOOT_TABLES_LEGENDARY =
[
	"telephaser_loot_roller_contents_common",
	"telephaser_loot_roller_contents_rare",
	"telephaser_loot_roller_contents_epic",
	"telephaser_loot_roller_contents_legendary"
]

                      
const array<string> IMC_ARMORY_LOOT_ROLLER_LOOT_TABLE_LEGENDARY =
[
	"loot_roller_contents_legendary"
]
      

const string LOOT_ROLLER_FX_KILL_SERVER_CALLBACK = "ServerCallback_StopLootRollerFX"

const string LOOT_ROLLER_AUDIO_EXPLOSION				= "LootBall_Explode"
const string LOOT_ROLLER_AUDIO_LONG_RANGE_ALERT 		= "LootBall_Roll_Default"
const string LOOT_ROLLER_AUDIO_CQB_ALERT 				= "LootBall_Roll_Default"
const string LOOT_ROLLER_AUDIO_ROLLING					= "LootBall_Roll_Default"
const string LOOT_ROLLER_TICK_AUDIO_SUPER_CQB_ALERT		= "LootBall_Roll_Default"
const string LOOT_ROLLER_TICK_AUDIO_LOOP	 			= "LootBall_Roll_Default"

const float LOOT_ROLLER_LONG_RANGE_ALERT_INTERVAL	= 9.0
const float LOOT_ROLLER_LONG_RANGE_ALERT_VARIANCE	= 2.0
const float LOOT_ROLLER_CQB_ALERT_INTERVAL			= 2.0
const float LOOT_ROLLER_CQB_ALERT_VARIANCE			= 5.0
const float LOOT_ROLLER_SUPER_CQB_ALERT_INTERVAL	= 1.0
const float LOOT_ROLLER_SUPER_CQB_ALERT_VARIANCE	= 5.0

const float LOOT_ROLLER_HIDE_AND_SEEK_DIST_SUPER_CQB_SQ 	= 176.0 * 176.0
const float LOOT_ROLLER_HIDE_AND_SEEK_DIST_CQB_SQ 			= 768.0 * 768.0

const int LOOT_ROLLER_AUDIO_STATE_NOALERT						= 0
const int LOOT_ROLLER_AUDIO_STATE_LONG_RANGE_ALERT				= 1
const int LOOT_ROLLER_AUDIO_STATE_CQB_ALERT						= 2
const int LOOT_ROLLER_AUDIO_STATE_SUPER_CQB_ALERT				= 3

const float LOOT_ROLLER_AWAKEN_DIST						= 384.0
const float LOOT_ROLLER_AWAKEN_DIST_SQ					= LOOT_ROLLER_AWAKEN_DIST * LOOT_ROLLER_AWAKEN_DIST
const float LOOT_ROLLER_HIDE_AND_SEEK_TRIGGER_RADIUS 	= 1024.0

global struct LootRollerData
{
	entity                      lootRollerModel
	entity                      lootDrone
	int                         lootTier
	array<string> lootRefs
	table< int, array<string> > lootTables
	int							minLootTableIdx
	int							maxLootTableIdx
	int                         lastLootTableIdx
	bool                        hasVaultKey
	float                       damageReceived
	array<entity> eyeFXEnts
	bool                        hasReceivedGroundBoost
	int                         rollerAudioState
	float                       lastDamagedTime
	float                       timeOfRelease
	bool                        isPartyRoller
}

struct
{
	table<entity, LootRollerData> lootRollerToData
	table< entity, array< void functionref( entity, var ) > > Callbacks_OnLootRollerDamaged
	table< entity, array< void functionref( entity, var ) > > Callbacks_OnLootRollerKilled
	int allLootRollerSciptManagedEntArrayID

	#if DEV
		bool dev_pathfinderTT_roller = false
		int dev_pathfinderTT_roller_lootTier = 4
		string dev_pathfinderTT_roller_lootGroup = "gold_weapons"
	#endif // DEV
} file

void function LootRollers_Init()
{
	Assert( !Flag( "EntitiesDidLoad" ), "Warning! You need to call LootRollers_Init() before entities loaded!" )
	PrecacheScriptString( LOOT_ROLLER_SCRIPTNAME )
	PrecacheParticleSystem( FX_LOOT_ROLLER_EXPLOSION )
	PrecacheModel( LOOT_ROLLER_MODEL )

	RegisterSignal( "ParentDroneDestroyed" )

	file.allLootRollerSciptManagedEntArrayID = CreateScriptManagedEntArray()

	AddSpawnCallback_ScriptName( "partyball_rotator", OnSpawnPartyBallRotator )
}

array<entity> function GetAllLootRollers()
{
	int arrayID = file.allLootRollerSciptManagedEntArrayID
	array<entity> lootRollers = GetScriptManagedEntArray( arrayID )
	return lootRollers
}

array<LootRollerData> function GetAllLootRollerData()
{
	array<entity> rollers = GetAllLootRollers()
	array<LootRollerData> rollerDatas
	foreach( roller in rollers )
	{
		if ( roller in file.lootRollerToData )
			rollerDatas.append( file.lootRollerToData[ roller ] )
	}

	return rollerDatas
}

bool function GetLootRollersCycleOnDamage()
{
	return GetCurrentPlaylistVarBool( "loot_rollers_damage_cycle_loot_tables", false )
}

bool function GetLootRollersCycleOnTimer()
{
	return GetCurrentPlaylistVarBool( "loot_rollers_timer_cycle_loot_tables", true )
}

bool function GetVaultKeysBlockLootCycling()
{
	return GetCurrentPlaylistVarBool( "loot_rollers_vault_keys_block_loot_cycling", false )
}

int function GetLootRollerNumLootToSpawn()
{
	return GetCurrentPlaylistVarInt( "loot_rollers_num_loot_to_spawn", NUM_LOOT_ROLLER_LOOT_TO_SPAWN)
}

LootRollerData function LootRollers_CreateLootRoller( vector origin, vector angles, int forcedLootTier = -1 )
{
	return CreateLootRoller_Internal( origin, angles, forcedLootTier, true, LootRoller_PopulateLootTables_Default )
}

LootRollerData function CreateLootRoller_Internal( vector origin, vector angles, int forcedLootTier, bool hasPhysics, void functionref( LootRollerData ) populateLootTablesFunc, array<string> customLootRefs = [], void functionref( LootRollerData, array<string> ) populateLootTablesCustomFunc = null )
{
	string classType = "prop_lootroller"
	entity lootRollerModel = CreateEntity( classType )
	lootRollerModel.SetValueForModelKey( LOOT_ROLLER_MODEL )
	lootRollerModel.kv.spawnflags = hasPhysics ? 0 : SF_NPC_NO_PLAYER_PUSHAWAY
	lootRollerModel.kv.fadedist = 30000
	lootRollerModel.kv.renderamt = 255
	lootRollerModel.kv.rendercolor = "255 255 255"
	lootRollerModel.kv.solid = SOLID_VPHYSICS
	lootRollerModel.kv.massscale = 2.5
	lootRollerModel.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	SetTeam( lootRollerModel, TEAM_TICK )	// need to have a team other then 0 or it won't take impact damage
	lootRollerModel.SetScriptName( LOOT_ROLLER_SCRIPTNAME )

	//lootRollerModel.DisableHibernation()
	lootRollerModel.SetMaxHealth( LOOT_ROLLER_HEALTH )
	lootRollerModel.SetHealth( LOOT_ROLLER_HEALTH )
	lootRollerModel.SetDamageNotifications( true )
	lootRollerModel.SetDeathNotifications( true )
	lootRollerModel.SetTakeDamageType( DAMAGE_YES )
	lootRollerModel.SetTouchTriggers( true )

	lootRollerModel.SetOrigin( origin )
	lootRollerModel.SetAngles( angles )
	DispatchSpawn( lootRollerModel )

	lootRollerModel.EnableAttackableByAI( AI_PRIORITY_NO_THREAT, 0, AI_AP_FLAG_NONE ) //Allows burn damage by forcing the entity to be "alive"
	lootRollerModel.e.canBurn = true
	lootRollerModel.e.canBeDamagedFromGas = true
	lootRollerModel.e.canStickArrows = true
	lootRollerModel.SetCanBeMeleed( true )
	//lootRollerModel.SetNeverCrush( true )

	if ( hasPhysics )
	{
		lootRollerModel.PhysicsSetDamping( 1.0, 1.5 )
		lootRollerModel.PhysicsSetFriction( 100.0 )
	}

	AddEntityCallback_OnDamaged( lootRollerModel, OnLootRollerDamaged )
	AddEntityCallback_OnPostDamaged( lootRollerModel, OnLootRollerPostDamaged )
	//AddEntityCallback_OnKilled( lootRollerModel, LootDrones_OnLootRollerKilled )

	LootRollerData data
	data.lootRollerModel = lootRollerModel

	if ( customLootRefs.len() > 0 )
	{
		Assert( populateLootTablesCustomFunc != null, "Passing in custom loot refs, but not a function to handle them!" )
		populateLootTablesCustomFunc( data, customLootRefs )
	}
	else
	{
		populateLootTablesFunc( data )
	}

	bool cycleLootRollersOnTimer   = GetLootRollersCycleOnTimer()
	bool vaultKeysBlockLootCycling = GetVaultKeysBlockLootCycling()
	bool hasVaultKey               = data.hasVaultKey
	bool doBlockCycling            = hasVaultKey && vaultKeysBlockLootCycling
	bool canCycleLoot              = cycleLootRollersOnTimer && !doBlockCycling && forcedLootTier == -1

	if ( canCycleLoot )
	{
		thread CycleLootRollerLootTablesOverTime( data )
	}
	else if ( cycleLootRollersOnTimer && doBlockCycling )
	{
		SetLootRollerFXFromHighestLootTier( data, data.lootTables[3] )
	}
	else if ( forcedLootTier != -1 )
	{
		SetLootRollerFXFromHighestLootTier( data, data.lootTables[ forcedLootTier ] )
	}

	// Highlight
	lootRollerModel.Highlight_Enable()
	//GetAndSetHighlightForLootRoller( data )
	SetLootRollerLootFX( data )

	// Meleeable
	lootRollerModel.SetCanBeMeleed( true )
	SetVisibleEntitiesInConeQueriableEnabled( lootRollerModel, true )

	int arrayID = file.allLootRollerSciptManagedEntArrayID
	AddToScriptManagedEntArray( arrayID, lootRollerModel )

	if ( hasPhysics )
		data.lootRollerModel.SetRollSoundName( LOOT_ROLLER_AUDIO_ROLLING )

	file.lootRollerToData[ lootRollerModel ] <- data
	return data
}

void function LootRoller_PopulateLootTables_Default( LootRollerData data )
{
	data.lootTables[0] <- GenerateLootRefsFromLootTable( LOOT_ROLLER_LOOT_TABLES_STANDARD, GetLootRollerNumLootToSpawn() )
	SetLootRollerFXFromHighestLootTier( data, data.lootTables[0] )
	data.lastLootTableIdx = 0
	if ( GetLootRollersCycleOnTimer() || GetLootRollersCycleOnDamage() )
	{
		data.lootTables[1] <- GenerateLootRefsFromLootTable( LOOT_ROLLER_LOOT_TABLES_COMMON, GetLootRollerNumLootToSpawn() )
		data.lootTables[2] <- GenerateLootRefsFromLootTable( LOOT_ROLLER_LOOT_TABLES_RARE, GetLootRollerNumLootToSpawn())
		data.lootTables[3] <- GenerateLootRefsFromLootTable( LOOT_ROLLER_LOOT_TABLES_EPIC, GetLootRollerNumLootToSpawn() )
		data.lootTables[4] <- GenerateLootRefsFromLootTable( LOOT_ROLLER_LOOT_TABLES_LEGENDARY, GetLootRollerNumLootToSpawn() )

		data.minLootTableIdx = 2
		data.maxLootTableIdx = 4
	}
}

               
void function LootRoller_PopulateLootTables_PathTT( LootRollerData data )
{
	data.lootTables[0] <- []

	data.lootTables[1] <- GenerateLootRefsFromLootTable( PATHTT_LOOT_ROLLER_LOOT_TABLES_COMMON, GetLootRollerNumLootToSpawn() )
	LootRoller_PopulateLootTableWithWeaponAndAmmo( data.lootTables[1], SURVIVAL_GetWeightedItemFromGroup( "weapon_low" ) )

	data.lootTables[2] <- GenerateLootRefsFromLootTable( PATHTT_LOOT_ROLLER_LOOT_TABLES_RARE, GetLootRollerNumLootToSpawn() )
	LootRoller_PopulateLootTableWithWeaponAndAmmo( data.lootTables[2], SURVIVAL_GetWeightedItemFromGroup( "weapon_low" ) )

	data.lootTables[3] <- GenerateLootRefsFromLootTable( PATHTT_LOOT_ROLLER_LOOT_TABLES_EPIC, GetLootRollerNumLootToSpawn() )
	LootRoller_PopulateLootTableWithWeaponAndAmmo( data.lootTables[3], SURVIVAL_GetWeightedItemFromGroup( "weapon_low" ) )

	data.lootTables[4] <- GenerateLootRefsFromLootTable( PATHTT_LOOT_ROLLER_LOOT_TABLES_LEGENDARY, GetLootRollerNumLootToSpawn() )
	string lootGroup = RandomFloat( 1.0 ) < 0.3 ? "gold_weapons" : "weapon_high"
	// TODO: Remove this after debugging.
	#if DEV
		if( file.dev_pathfinderTT_roller )
			lootGroup = file.dev_pathfinderTT_roller_lootGroup
	#endif
	LootRoller_PopulateLootTableWithWeaponAndAmmo( data.lootTables[4], SURVIVAL_GetWeightedItemFromGroup( lootGroup ) )

	SetLootRollerFXFromHighestLootTier( data, data.lootTables[1] )
	data.lastLootTableIdx = 1
	data.minLootTableIdx = 2
	data.maxLootTableIdx = 4
}

void function LootRoller_PopulateLootTableWithWeaponAndAmmo( array<string> lootTable, string weaponRef )
{
	string ammoRef = SURVIVAL_Loot_GetLootDataByRef( weaponRef ).ammoType

	// Prevent adding of blank entries into the Loot Table caused by crate weapons with no additional ammo:
	if( ammoRef != "" )
		lootTable.extend( [ ammoRef, ammoRef ] )
	else
	{
		printt( format( "LootRoller: %s():  Weapon %s does not have valid ammoRef.", FUNC_NAME(), weaponRef) )
		printt(		    "LootRoller:    To prevent asserts and issues, blank entries for missing ammo NOT added to loot table." )
	}

	lootTable.append( weaponRef )
}
      

void function LootRoller_PopulateLootTables_PhaseDriver( LootRollerData data )
{
	data.lootTables[0] <- GenerateLootRefsFromLootTable( LOOT_ROLLER_LOOT_TABLES_STANDARD, GetLootRollerNumLootToSpawn())
	SetLootRollerFXFromHighestLootTier( data, data.lootTables[0] )
	data.lastLootTableIdx = 0
	if ( GetLootRollersCycleOnTimer() || GetLootRollersCycleOnDamage() )
	{
		data.lootTables[1] <- GenerateLootRefsFromLootTable( PHASEDRIVER_LOOT_ROLLER_LOOT_TABLES_COMMON, GetLootRollerNumLootToSpawn() )
		data.lootTables[2] <- GenerateLootRefsFromLootTable( PHASEDRIVER_LOOT_ROLLER_LOOT_TABLES_RARE, GetLootRollerNumLootToSpawn() )
		data.lootTables[3] <- GenerateLootRefsFromLootTable( PHASEDRIVER_LOOT_ROLLER_LOOT_TABLES_EPIC, GetLootRollerNumLootToSpawn() )
		data.lootTables[4] <- GenerateLootRefsFromLootTable( PHASEDRIVER_LOOT_ROLLER_LOOT_TABLES_LEGENDARY, GetLootRollerNumLootToSpawn() )

		data.minLootTableIdx = 2
		data.maxLootTableIdx = 4
	}
}

                    
                                                                                                      
 
                               
                               

                          
                         
                         
 
      

                      
void function LootRoller_PopulateLootTables_Armory( LootRollerData data )
{
	//data.lootTables[0] <- 	[
	//	//"armor_pickup_lv4_all_fast",
	//	"helmet_pickup_lv4_abilities",
	//	"backpack_pickup_lv4_revive_boost",
	//	"incapshield_pickup_lv4_selfrevive"
	//]

	// Generate from the loot table .
	data.lootTables[0] <- GenerateLootRefsFromLootTable( IMC_ARMORY_LOOT_ROLLER_LOOT_TABLE_LEGENDARY, 3 )

	SetLootRollerFXFromHighestLootTier( data, data.lootTables[0] )
	data.lastLootTableIdx = 0
	data.minLootTableIdx = 0
	data.maxLootTableIdx = 0
}
                            

LootRollerData function CreatePartyRoller( vector origin, vector angles )
{
	LootRollerData rollerData = CreateLootRoller_Internal( origin, angles, -1, false, LootRoller_PopulateLootTables_Default )
	rollerData.lootRollerModel.SetMaxHealth( 1 )
	rollerData.lootRollerModel.SetHealth( 1 )
	rollerData.lootRollerModel.SetModelScale( 0.5 )

	rollerData.isPartyRoller = true

	return rollerData
}

               
// Guaranteed weapon and blue armor per roller
LootRollerData function LootRollers_CreatePathTTLootRoller( vector origin, vector angles )
{
	int rollerLootTier = RandomFloat( 100.0 ) < 30.0 ? 4 : 3
	// TODO: Remove DEV stuff after debugging.
	#if DEV
		if( file.dev_pathfinderTT_roller )
			rollerLootTier = file.dev_pathfinderTT_roller_lootTier
	#endif
	return CreateLootRoller_Internal( origin, angles, rollerLootTier, true, LootRoller_PopulateLootTables_PathTT )
}
      

LootRollerData function LootRollers_CreatePhaseDriverLootRoller( vector origin, vector angles, int forcedLootTier = -1  )
{
	return CreateLootRoller_Internal( origin, angles, forcedLootTier, true, LootRoller_PopulateLootTables_PhaseDriver )
}

                      
LootRollerData function LootRollers_CreateLootRoller_Armory( vector origin, vector angles, int forcedLootTier = -1  )
{
	return CreateLootRoller_Internal( origin, angles, forcedLootTier, true, LootRoller_PopulateLootTables_Armory )
}
                            


                    
                                                                                                                                              
 
                       
                                           
  
                                              
                               
      
                                                                    
  

                                                                                                                                                                      
 
      

array<string> function GenerateLootRefsFromLootTable( array<string> lootTable, int numRefsToGenerate = NUM_LOOT_ROLLER_LOOT_TO_SPAWN )
{
	array<string> lootRefs
	int numTables = lootTable.len()
	for ( int k; k < numRefsToGenerate; k++ )
	{
		int idx = k % numTables
		lootRefs.append( SURVIVAL_GetWeightedItemFromGroup( lootTable[ idx ] ))
	}

	return lootRefs
}

void function SetLootRollerFXFromHighestLootTier( LootRollerData data, array<string> refTable )
{
	data.lootRefs = clone refTable

	data.lootTier = 0
	foreach( lootRef in refTable )
	{
		int refTier = SURVIVAL_Loot_GetLootDataByRef( lootRef ).tier
		if ( refTier > data.lootTier && lootRef != "data_knife" )
			data.lootTier = refTier
	}

	SetLootRollerLootFX( data )
}

array<string> function SelectRandomLootTable( LootRollerData data )
{
	int lootTableCount = data.lootTables.len()
	int randomIdx = RandomIntRange( 0, (lootTableCount - 1) )

	if ( randomIdx == data.lastLootTableIdx )
	{
		randomIdx++
		if ( randomIdx >=  lootTableCount )
			randomIdx = 0
	}

	data.lastLootTableIdx = randomIdx

	return data.lootTables[randomIdx]
}

const float MIN_TIME_BETWEEN_LOOT_CYCLES = 1.0
const float MAX_TIME_BETWEEN_LOOT_CYCLES = 3.0
const float MIN_TIME_BETWEEN_LOOT_CYCLES_TIER2 = 3.0
const float MIN_TIME_BETWEEN_LOOT_CYCLES_TIER3 = 1.0
const float MIN_TIME_BETWEEN_LOOT_CYCLES_TIER4 = 0.5
const float MAX_TIME_BETWEEN_LOOT_CYCLES_TIER2 = 7.0
const float MAX_TIME_BETWEEN_LOOT_CYCLES_TIER3 = 2.0
const float MAX_TIME_BETWEEN_LOOT_CYCLES_TIER4 = 1.0
void function CycleLootRollerLootTablesOverTime( LootRollerData data )
{
	entity lootRollerModel = data.lootRollerModel
	entity lootDrone = lootRollerModel.GetParent()

	EndSignal( lootRollerModel, "OnDeath" )
	EndSignal( lootRollerModel, "OnDestroy" )
	EndSignal( lootRollerModel, "ParentDroneDestroyed" )

	float lastTime = Time()
	float minTime = MIN_TIME_BETWEEN_LOOT_CYCLES
	float maxTime = MAX_TIME_BETWEEN_LOOT_CYCLES
	bool isCycleSequential = GetPlaylistVarInt( GetCurrentPlaylistName(), "loot_rollers_sequential_loot_cycling", 1 ) == 1
	bool isCycleDescending = GetPlaylistVarInt( GetCurrentPlaylistName(), "loot_rollers_sequential_loot_descending", 1 ) == 1
	while( true )
	{
		bool vaultKeysBlockLootCycling = GetVaultKeysBlockLootCycling()
		if ( data.hasVaultKey && vaultKeysBlockLootCycling )
		{
			SetLootRollerFXFromHighestLootTier( data, data.lootTables[3] )
			break
		}

		switch( data.lootTier )
		{
			case 5:
			case 4:
				minTime = MIN_TIME_BETWEEN_LOOT_CYCLES_TIER4
				maxTime = MAX_TIME_BETWEEN_LOOT_CYCLES_TIER4
				break
			case 3:
				minTime = MIN_TIME_BETWEEN_LOOT_CYCLES_TIER3
				maxTime = MAX_TIME_BETWEEN_LOOT_CYCLES_TIER3
				break
			case 2:
				minTime = MIN_TIME_BETWEEN_LOOT_CYCLES_TIER2
				maxTime = MAX_TIME_BETWEEN_LOOT_CYCLES_TIER2
				break
			default:
				minTime = MIN_TIME_BETWEEN_LOOT_CYCLES
				maxTime = MAX_TIME_BETWEEN_LOOT_CYCLES
		}
		float delay = RandomFloatRange( minTime, maxTime )

		if ( Time() >= lastTime + delay )
		{
			if ( isCycleSequential )
			{
				int nextIdx = data.lastLootTableIdx
				nextIdx = isCycleDescending ? (nextIdx - 1) : nextIdx++

				if ( nextIdx > data.maxLootTableIdx )
					nextIdx = data.minLootTableIdx

				if ( nextIdx < data.minLootTableIdx && isCycleDescending )
					nextIdx = data.maxLootTableIdx// - 1

				data.lastLootTableIdx = nextIdx

				SetLootRollerFXFromHighestLootTier( data, data.lootTables[ nextIdx ] )
			}
			else
			{
				SetLootRollerFXFromHighestLootTier( data, SelectRandomLootTable( data ) )
			}

			lastTime = Time()
		}

		WaitFrame()
	}
}

void function OnLootRollerDamaged( entity lootRoller, var damageInfo )
{
	if ( !( lootRoller in file.lootRollerToData ) )
		return

	LootRollerData data = file.lootRollerToData[ lootRoller ]

	entity lootRollerModel = data.lootRollerModel
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	// Give the roller a boost when it hits the ground for the first time
	if ( IsWorldSpawn( attacker ) && !data.hasReceivedGroundBoost )
	{
		vector flatVel = Normalize( FlattenVec( lootRollerModel.GetVelocity() ) )
		lootRollerModel.SetVelocity( lootRollerModel.GetVelocity() + ( flatVel * 300 ) )
		data.hasReceivedGroundBoost = true
	}

	if ( !IsValid( attacker ) || IsWorldSpawn( attacker ) || attacker == data.lootDrone )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

}

void function OnLootRollerPostDamaged( entity lootRoller, var damageInfo )
{
	float damage = DamageInfo_GetDamage( damageInfo )
	if ( damage <= 0 )
		return

	if ( !( lootRoller in file.lootRollerToData ) )
		return

	LootRollerData data = file.lootRollerToData[ lootRoller ]

	entity lootRollerModel = data.lootRollerModel
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	entity lootRollerParentIfDrone = null
	bool isRollerAttachedToDrone = ShDrones_IsValidDroneMover( lootRoller.GetParent() )
	if ( isRollerAttachedToDrone )
	{
		lootRollerParentIfDrone = lootRoller.GetParent()
	}
	bool isRollerAttachedButDamagable = false

                     
                                                                   
   
                                      
   
       

	bool canDamageFreeRoller = Time() > (data.timeOfRelease + LOOT_ROLLER_RELEASE_DAMAGE_DEBOUNCE_TIME)
	if ( isRollerAttachedToDrone || !canDamageFreeRoller )
	{
		float health = max((lootRoller.GetHealth() - damage), 1)

		if ( isRollerAttachedButDamagable )
		{
			health = max((lootRoller.GetHealth() - damage), 0)
		}
		lootRoller.SetHealth( health )
	}
	else
	{
		lootRoller.SetHealth( 0 )
	}

	if ( IsValid( attacker ) && attacker.IsPlayer() && IsAlive( attacker ) )
	{
		attacker.NotifyDidDamage( lootRollerModel, DamageInfo_GetHitBox( damageInfo ),
			DamageInfo_GetDamagePosition( damageInfo ),
			DamageInfo_GetCustomDamageType( damageInfo ),
			DamageInfo_GetDamage( damageInfo ),
			DamageInfo_GetDamageFlags( damageInfo ),
			DamageInfo_GetHitGroup( damageInfo ),
			DamageInfo_GetWeapon( damageInfo ),
			DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
	}

	float damageTimeDelta = Time() - data.lastDamagedTime
	if ( GetPlaylistVarInt( GetCurrentPlaylistName(), "loot_rollers_damage_removes_loot", 0 ) == 1 )
	{
		if ( IsValid(data.lootRollerModel.GetParent()) && damageTimeDelta >= LOOT_ROLLER_LOOT_REMOVAL_TIMER )
		{
			RemoveHighestTierLootRollerLoot( data )

			if( data.lootTier > 0 )
				lootRoller.SetHealth( lootRoller.GetMaxHealth() )
			else
				lootRoller.SetHealth( 0 )

			data.lastDamagedTime = Time()
		}
	}

	if ( GetLootRollersCycleOnDamage() && !isRollerAttachedButDamagable )
	{
		if ( IsValid( data.lootRollerModel.GetParent() ) && damageTimeDelta >= LOOT_ROLLER_LOOT_REMOVAL_TIMER )
		{
			SetLootRollerFXFromHighestLootTier( data, SelectRandomLootTable( data ) )
		}
	}

	if ( lootRoller.GetHealth() < 10 && isRollerAttachedToDrone && !isRollerAttachedButDamagable )
	{
		lootRoller.SetHealth( 10 )
		data.timeOfRelease = Time()

		DroneData ornull droneData = Drones_GetDroneDataFromRollerModelEnt( lootRoller )
		if ( droneData != null )
		{
			expect DroneData( droneData )
			switch ( droneData.droneType )
			{
                    
                                       
      
                      
                                  
      
				case eDroneType.LOOT_DRONE:
					LootDrones_DetachLootRollerAndCleanUpData( data, droneData, true )
					break

				default:
					printf( "DroneDebug: Should be damaging a drone but no logic setup for drone of type: " + droneData.droneType )
					break
			}
		}
	}

	// Kill loot roller, send killed OR damage callbacks
	if ( lootRoller.GetHealth() <= 0 )
	{
		if ( lootRoller in file.Callbacks_OnLootRollerKilled )
		{
			foreach ( callbackFunc in file.Callbacks_OnLootRollerKilled[ lootRoller ] )
				callbackFunc( lootRoller, damageInfo )
		}

		if ( data.isPartyRoller )
		{
			if ( IsValid( lootRoller.GetParent() ) )
				lootRoller.GetParent().Destroy()
		}

		if ( IsValid( attacker ) && attacker.IsPlayer() )
		{
			table item_attr = GetLootRollerContentsForPINData( data )
			PIN_PlayerItemDestruction( attacker, ITEM_DESTRUCTION_TYPES.LOOT_ROLLER, item_attr )
		}

		DestroyLootRoller( data )
	}
	else
	{
		if ( lootRoller in file.Callbacks_OnLootRollerDamaged )
		{
			foreach ( callbackFunc in file.Callbacks_OnLootRollerDamaged[ lootRoller ] )
				callbackFunc( lootRoller, damageInfo )
		}
	}
}

void function AddCallback_LootRollerDamaged( LootRollerData rollerData, void functionref( entity, var ) callbackFunc )
{
	Assert( IsValid( rollerData.lootRollerModel ), "Trying to register damage callback for loot roller, but model is invalid!" )
	entity model = rollerData.lootRollerModel

	if ( model in file.Callbacks_OnLootRollerDamaged )
	{
		Assert( !file.Callbacks_OnLootRollerDamaged[ model ].contains( callbackFunc ), "Already added " + string( callbackFunc ) + ", likely with LootDrones_AddCallback_OnLootDroneDamaged" )
	}
	else
		file.Callbacks_OnLootRollerDamaged[ model ] <- []

	file.Callbacks_OnLootRollerDamaged[ model ].append( callbackFunc )
}

void function RemoveCallback_LootRollerDamaged( entity ent, void functionref( entity, var ) callbackFunc )
{
	Assert( ent in file.Callbacks_OnLootRollerDamaged, "Entity: " + ent + " not in callback table Callbacks_OnLootRollerDamaged!" )

	int index = file.Callbacks_OnLootRollerDamaged[ ent ].find( callbackFunc )
	//Assert( index != -1, "Requested loot roller damaged callback " + string( callbackFunc ) + " to be removed not found! " )

	if ( index != -1 ) //Defensive Fix for R5DEV-107042
		file.Callbacks_OnLootRollerDamaged[ ent ].fastremove( index )
}

void function AddCallback_LootRollerKilled( LootRollerData rollerData, void functionref( entity, var ) callbackFunc )
{
	Assert( IsValid( rollerData.lootRollerModel ), "Trying to register damage callback for loot roller, but model is invalid!" )
	entity model = rollerData.lootRollerModel

	if ( model in file.Callbacks_OnLootRollerKilled )
	{
		Assert( !file.Callbacks_OnLootRollerKilled[ model ].contains( callbackFunc ), "Already added " + string( callbackFunc ) + ", likely with LootDrones_AddCallback_OnLootDroneDamaged" )
	}
	else
		file.Callbacks_OnLootRollerKilled[ model ] <- []

	file.Callbacks_OnLootRollerKilled[ model ].append( callbackFunc )
}

void function RemoveCallback_LootRollerKilled( entity model, void functionref( entity, var ) callbackFunc )
{
	Assert( model in file.Callbacks_OnLootRollerKilled, "Entity: " + model + " not in callback table Callbacks_OnLootRollerKilled!" )

	int index = file.Callbacks_OnLootRollerKilled[ model ].find( callbackFunc )
	Assert( index != -1, "Requested loot roller killed callback " + string( callbackFunc ) + " to be removed not found! " )

	file.Callbacks_OnLootRollerKilled[ model ].fastremove( index )
}

void function DestroyLootRoller( LootRollerData data, bool isDetonating = true )
{
	SpawnLootRollerLoot( data )
	LootRollerDestructionSequence( data )
	CleanUpLootRollerData( data )
}

void function CleanUpLootRollerData( LootRollerData data )
{
	foreach( ent in data.eyeFXEnts )
		ent.Destroy()

	delete file.lootRollerToData[ data.lootRollerModel ]

	if( data.lootRollerModel in file.Callbacks_OnLootRollerDamaged )
		delete file.Callbacks_OnLootRollerDamaged[ data.lootRollerModel ]

	if ( data.lootRollerModel in file.Callbacks_OnLootRollerKilled )
		delete file.Callbacks_OnLootRollerKilled[ data.lootRollerModel ]

	if ( IsValid( data.lootRollerModel ) )
		data.lootRollerModel.Destroy()
	if ( IsValid( data.lootRollerModel ) )
		data.lootRollerModel.Destroy()
}

void function LootRollerDestructionSequence( LootRollerData data )
{
	entity lootRollerModel = data.lootRollerModel
	int lootRollerHandle = lootRollerModel.GetEncodedEHandle()
	array<entity> playerArray = GetPlayerArray()
	foreach ( player in playerArray )
		Remote_CallFunction_Replay( player, LOOT_ROLLER_FX_KILL_SERVER_CALLBACK, lootRollerHandle )

	LootRollerDestructionSequenceInternal( lootRollerModel, data.lootTier )
}
void function LootRollerDestructionSequenceInternal( entity lootRollerModel, int lootTier )
{
	vector fxOrg = lootRollerModel.GetOrigin()
	int expFX = GetParticleSystemIndex( FX_LOOT_ROLLER_EXPLOSION )
	entity fx = StartParticleEffectInWorld_ReturnEntity( expFX, fxOrg, lootRollerModel.GetAngles() )
	EffectSetControlPointColorById( fx, 1, (COLORID_FX_LOOT_TIER0 + lootTier) )

	thread DestroyAfterDelay( fx, 3.0 )

	EmitSoundAtPosition( TEAM_UNASSIGNED, fxOrg, LOOT_ROLLER_AUDIO_EXPLOSION, fx )
}

const float LOOT_ROLLER_THROW_SPEED_GROUNDED = 1.0
const float LOOT_ROLLER_THROW_SPEED_PARENTED = 3.0
const vector LOOT_ROLLER_LOOT_SPAWN_OFFSET = <0,0,25>
void function SpawnLootRollerLoot( LootRollerData rollerData )
{
	array<string> itemRefs = rollerData.lootRefs

	int numToSpawn = itemRefs.len()

	LootThrowData throwData

	for( int i; i < numToSpawn; i++ )
	{
		string itemRef = itemRefs[ i ]

		if ( itemRef == "blank" )
			continue

		LootData data = SURVIVAL_Loot_GetLootDataByRef( itemRef )

		vector throwDir = Normalize( <sin( throwData.throwAngle ), cos( throwData.throwAngle ), sin( throwData.throwAngle )> )
		float speed = IsValid( rollerData.lootRollerModel.GetParent() ) ? LOOT_ROLLER_THROW_SPEED_PARENTED : LOOT_ROLLER_THROW_SPEED_GROUNDED
		vector vel = throwDir * speed
		vector spawnOffset = rollerData.isPartyRoller ? <0,0,0> : LOOT_ROLLER_LOOT_SPAWN_OFFSET
		vector spawnPos = rollerData.lootRollerModel.GetOrigin() + spawnOffset

		SURVIVAL_ThrowLootFromPoint( spawnPos, vel, itemRef, data.countPerDrop )

		throwData = SURVIVAL_DropLoot_IncrementThrowAngle( throwData )
	}
}

void function RemoveHighestTierLootRollerLoot( LootRollerData rollerData )
{
	array<string> itemRefs = rollerData.lootRefs
	itemRefs.sort( SortLootRollerLootByTier )
	//printf( "LootRollerDebug: Roller damaged while still attached to parent! Removing %s from roller loot table.", itemRefs[0] )
	itemRefs.remove( 0 )

	rollerData.lootTier = 0
	for( int i; i < itemRefs.len(); i++ )
	{
		int lootTier = SURVIVAL_Loot_GetLootDataByRef( itemRefs[i] ).tier
		if ( lootTier > rollerData.lootTier )
			rollerData.lootTier = lootTier
	}

	if ( itemRefs.len() == 0 )
	{
		rollerData.lootTier = 0
	}
	else
	{
		//GetAndSetHighlightForLootRoller( rollerData )
		SetLootRollerLootFX( rollerData )
	}
}

void function GetAndSetHighlightForLootRoller( LootRollerData rollerData )
{
	//printf( "LootRollerDebug: Setting Highlight for roller with highest loot tier %i", rollerData.lootTier )
	string highlight = SURVIVAL_GetHighlightForTier( rollerData.lootTier, true )

	entity lootRollerModel = rollerData.lootRollerModel
	Highlight_SetNeutralHighlight( lootRollerModel, highlight )
	Highlight_SetFriendlyHighlight( lootRollerModel, highlight )
	Highlight_SetEnemyHighlight( lootRollerModel, highlight )

	SetSurvivalPropHighlight( lootRollerModel, highlight, false, eHighlightGenericType.NEUTRAL )
	SetSurvivalPropHighlight( lootRollerModel, highlight, false, eHighlightGenericType.FRIENDLY )
	SetSurvivalPropHighlight( lootRollerModel, highlight, false, eHighlightGenericType.ENEMY )
}

void function SetLootRollerLootFX( LootRollerData rollerData )
{
	//FX exist on the client
	entity lootRollerModel = rollerData.lootRollerModel

	if ( !IsValid( rollerData.lootRollerModel ) )
		return

	lootRollerModel.kv.lootTier = rollerData.lootTier
	lootRollerModel.kv.hasVaultKey = rollerData.hasVaultKey
}

int function SortLootRollerLootByTier( string lootA, string lootB )
{
	int tierA = SURVIVAL_Loot_GetLootDataByRef( lootA ).tier
	int tierB = SURVIVAL_Loot_GetLootDataByRef( lootB ).tier

	if ( tierA > tierB )
		return -1
	else if ( tierA < tierB )
		return 1

	return 0
}

void function HACK_AwakenLootRoller( LootRollerData rollerData )
{
	entity lootRollerModel = rollerData.lootRollerModel
	lootRollerModel.SetVelocity( lootRollerModel.GetVelocity() + < 0, 0, 1 > )
}

void function LaunchLootRoller( LootRollerData rollerData, vector launchDirection = <0, 0, 1>, float speed = 2500.0 )
{
	entity rollerModel = rollerData.lootRollerModel

	rollerModel.SetVelocity( launchDirection * speed )
	rollerModel.SetAngularVelocity( launchDirection.x * speed, launchDirection.y * speed, launchDirection.z * speed )
}

void function LaunchLootRoller_SpinControl( LootRollerData rollerData, vector velocityDirection = <0, 0, 1>, float velocitySpeed = 2500.0, vector angularDirection = <0, 0, 1>, float angularSpeed = 2500.0 )
{
	entity rollerModel = rollerData.lootRollerModel

	rollerModel.SetVelocity( velocityDirection * velocitySpeed )
	rollerModel.SetAngularVelocity( angularDirection.x * angularSpeed, angularDirection.y * angularSpeed, angularDirection.z * angularSpeed )
}

LootRollerData function GetLootRollerDataFromRollerModel( entity model )
{
	Assert( model in file.lootRollerToData, "Warning! Attempted to locate Loot Roller Data for a model that isn't known to script!" )
	return file.lootRollerToData[ model ]
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Audio functionality. Taken from loot ticks.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void function StartLootRollerNotificationSounds( LootRollerData rollerData )
{
	//rollerData.lootRollerModel.SetRollSoundName( LOOT_ROLLER_AUDIO_ROLLING )
	thread LootRollerAudioStateController( rollerData )
}

void function LootRollerAudioStateController( LootRollerData data )
{
	entity lootRollerModel = data.lootRollerModel
	EndSignal( lootRollerModel, "OnDeath" )
	EndSignal( lootRollerModel, "OnDestroy" )

	entity trig = CreateLootRollerTrigger( lootRollerModel )
	thread LootRollerAudioDriver( data )

	OnThreadEnd(
		function() : ( trig )
		{
			trig.Destroy()
		}
	)

	int prevNumTouchingEntities
	bool lootRollerWasAwake
	float lastStateChangeTime = 0.0
	int numTouchingEntities = trig.GetTouchingEntities().len()
	while ( true )
	{
		if ( numTouchingEntities == 0 )
		{
			if ( prevNumTouchingEntities != 0 )
				data.rollerAudioState = LOOT_ROLLER_AUDIO_STATE_NOALERT//TICK_AUDIO_STATE_LONG_RANGE_ALERT

			data.lootRollerModel.LagCompensate( false )
			lootRollerWasAwake = false
			trig.WaitSignal( "OnStartTouch", "OnEndTouch" )
		}
		else
			wait 0.1

		if ( !lootRollerWasAwake )
		{
			lootRollerWasAwake = true
			data.lootRollerModel.LagCompensate( true )
		}

		array<entity> touchingEnts = trig.GetTouchingEntities()
		ArrayRemoveInvalid( touchingEnts )
		prevNumTouchingEntities = numTouchingEntities
		numTouchingEntities = touchingEnts.len()

		entity closestPlayer = GetClosest( touchingEnts, lootRollerModel.GetOrigin() )

		if ( IsValid( closestPlayer ) && closestPlayer.IsPlayer() )
		{
			float distSQ = DistanceSqr( closestPlayer.GetOrigin(), lootRollerModel.GetOrigin() )

			if ( ( distSQ > LOOT_ROLLER_HIDE_AND_SEEK_DIST_CQB_SQ ) )
			{
				if ( data.rollerAudioState != LOOT_ROLLER_AUDIO_STATE_LONG_RANGE_ALERT )
					data.rollerAudioState = LOOT_ROLLER_AUDIO_STATE_LONG_RANGE_ALERT
			}
			else if ( ( distSQ > LOOT_ROLLER_HIDE_AND_SEEK_DIST_SUPER_CQB_SQ ) )
			{
				if ( data.rollerAudioState != LOOT_ROLLER_AUDIO_STATE_CQB_ALERT )
					data.rollerAudioState = LOOT_ROLLER_AUDIO_STATE_CQB_ALERT
			}
			else if ( ( distSQ < LOOT_ROLLER_HIDE_AND_SEEK_DIST_SUPER_CQB_SQ ) )
			{
				if ( data.rollerAudioState != LOOT_ROLLER_AUDIO_STATE_SUPER_CQB_ALERT )
					data.rollerAudioState = LOOT_ROLLER_AUDIO_STATE_SUPER_CQB_ALERT
			}
		}

	}
}

void function LootRollerAudioDriver( LootRollerData data )
{
	entity lootRollerModel = data.lootRollerModel
	EndSignal( lootRollerModel, "OnDeath" )
	EndSignal( lootRollerModel, "OnDestroy" )

	// Hack. Wait until loot roller is non-null.
	while( !IsValid( lootRollerModel ) )
		WaitFrame()

	int curRollerAudioState            = LOOT_ROLLER_AUDIO_STATE_NOALERT
	float lastAlertTime				   = -1000
	float nextLongRangeAlertWaitTime   = GetLootRollerNextLongRangeAlertWaitTime()
	float nextCQBAlertWaitTime         = GetLootRollerNextCQBAlertWaitTime()
	float nextSuperCQBAlertWaitTime    = GetLootRollerNextSuperCQBAlertWaitTime()
	float lastCQBLoopStartTime         = Time()
	float CQB_LOOP_SOUND_DURATION_HACK = 15.0

	// Hack to ensure there are players when the idle loop sound tries to start
	wait 10

	EmitSoundOnEntity( lootRollerModel, LOOT_ROLLER_TICK_AUDIO_LOOP )

	while ( true )
	{
		float timeSinceLastAlert = Time() - lastAlertTime
		curRollerAudioState = data.rollerAudioState
		switch( curRollerAudioState )
		{
			case LOOT_ROLLER_AUDIO_STATE_NOALERT:
				break

			case LOOT_ROLLER_AUDIO_STATE_LONG_RANGE_ALERT:
				if ( ( timeSinceLastAlert - nextLongRangeAlertWaitTime ) > 0 )
				{
					EmitSoundOnEntity( lootRollerModel, LOOT_ROLLER_AUDIO_LONG_RANGE_ALERT )
					nextLongRangeAlertWaitTime = GetLootRollerNextLongRangeAlertWaitTime()
					lastAlertTime = Time()
				}
				break

			case LOOT_ROLLER_AUDIO_STATE_CQB_ALERT:
				if ( ( timeSinceLastAlert - nextCQBAlertWaitTime ) > 0 )
				{
					EmitSoundOnEntity( lootRollerModel, LOOT_ROLLER_AUDIO_CQB_ALERT )
					nextCQBAlertWaitTime = GetLootRollerNextCQBAlertWaitTime()
					lastAlertTime = Time()
				}
				break

			case LOOT_ROLLER_AUDIO_STATE_SUPER_CQB_ALERT:
				if ( ( timeSinceLastAlert - nextCQBAlertWaitTime ) > 0 )
				{
					EmitSoundOnEntity( lootRollerModel, LOOT_ROLLER_TICK_AUDIO_SUPER_CQB_ALERT )
					nextSuperCQBAlertWaitTime = GetLootRollerNextSuperCQBAlertWaitTime()
					lastAlertTime = Time()
				}
				break
		}

		wait 0.099
	}

}

float function GetLootRollerNextLongRangeAlertWaitTime()
{
	return LOOT_ROLLER_LONG_RANGE_ALERT_INTERVAL + ( RandomFloatRange( -LOOT_ROLLER_LONG_RANGE_ALERT_VARIANCE, LOOT_ROLLER_LONG_RANGE_ALERT_VARIANCE ) * 0.5 )
}

float function GetLootRollerNextCQBAlertWaitTime()
{
	return LOOT_ROLLER_CQB_ALERT_INTERVAL + ( RandomFloatRange( -LOOT_ROLLER_CQB_ALERT_VARIANCE, LOOT_ROLLER_CQB_ALERT_VARIANCE ) * 0.5 )
}
float function GetLootRollerNextSuperCQBAlertWaitTime()
{
	return LOOT_ROLLER_SUPER_CQB_ALERT_INTERVAL + ( RandomFloatRange( -LOOT_ROLLER_SUPER_CQB_ALERT_VARIANCE, LOOT_ROLLER_SUPER_CQB_ALERT_VARIANCE ) * 0.5 )
}

entity function CreateLootRollerTrigger( entity lootRollerlootRollerModel )
{
	entity trig = CreateEntity( "trigger_cylinder" )
	trig.SetCylinderRadius( LOOT_ROLLER_HIDE_AND_SEEK_TRIGGER_RADIUS )
	trig.SetAboveHeight( LOOT_ROLLER_AWAKEN_DIST )
	trig.SetBelowHeight( LOOT_ROLLER_AWAKEN_DIST )
	trig.SetOrigin( lootRollerlootRollerModel.GetOrigin() )
	trig.kv.triggerFilterNpc = "none"
	trig.kv.triggerFilterPlayer = "all"
	trig.kv.triggerFilterNonCharacter = "0"
	trig.SetOwner( lootRollerlootRollerModel )
	DispatchSpawn( trig )
	trig.SetParent( lootRollerlootRollerModel )

	return trig
}

#if DEV
void function DEV_SpawnLootRollerAtCrosshair( entity player, int forcedLootTier = -1 )
{
	Assert( IsNewThread(), "Must be threaded off due to precache issues" )

	if ( !IsValid( player ) )
		return

	vector origin = GetPlayerCrosshairOrigin( player )
	origin += <0,0,50>
	vector angles = <0,0,0>
	LootRollerData roller = LootRollers_CreateLootRoller( origin, angles, forcedLootTier )
}

void function DEV_SpawnPartyRoller( entity player )
{
	Assert ( IsNewThread(), "Must be threaded off due to precache issues" )

	if ( !IsValid( player ) )
		return

	vector origin = player.GetOrigin() + (player.GetForwardVector() * 75) + <0, 0, 75>
	vector angles = player.GetAngles()

	LootRollerData data = CreatePartyRoller( origin, angles )
}

void function DEV_SpawnLaunchingRoller( entity player )
{
	Assert ( IsNewThread(), "Must be threaded off due to precache issues" )

	if ( !IsValid( player ) )
		return

	thread DEV_SpawnLootRollerAtCrosshair( player, 4 )
	LootRollerData rollerData = GetAllLootRollerData()[ GetAllLootRollerData().len() - 1 ]

	//ForceLootRollerLootTable( rollerData, 4 )
	LaunchLootRoller( rollerData )
}

// Call this during Legend Select for dev tier and lootgroup.
void function DEV_PathfinderTT_Roller( bool isOn = true, int lootTier = 4, string lootGroup = "gold_weapons" )
{
	file.dev_pathfinderTT_roller = isOn
	file.dev_pathfinderTT_roller_lootTier = lootTier
	file.dev_pathfinderTT_roller_lootGroup = lootGroup
}
#endif //DEV


void function OnSpawnPartyBallRotator( entity mover )
{
	vector origin = mover.GetOrigin() - <0,0,15>
	vector angles = <0,0,0>
	LootRollerData partyBall = CreatePartyRoller( origin, angles )
	partyBall.lootRollerModel.SetParent( mover )
}

#if SERVER
table function GetLootRollerContentsForPINData( LootRollerData rollerData )
{
	int rarityTier = rollerData.lootTier
	array<string> lootRefs = rollerData.lootRefs

	table rollerContents =
	{
		//rarity = PIN_GetRarityFromTier( rarityTier )
		loot = lootRefs
	}

	return rollerContents
}
#endif // SERVER

void function LootRollers_ForceAddLootRefToRandomLootRollers( string lootRef, int numRollers )
{
	int expectedRollerCount = GetCurrentPlaylistVarInt( "loot_drones_spawn_count", 12 )

	if ( expectedRollerCount == 0 )
		return
	Assert( numRollers <= expectedRollerCount, format( "Loot Roller Assert: Attempted to force loot ref %s on %i rollers, when expected roller count is %i", lootRef, numRollers, expectedRollerCount ) )

	array<entity> selectedRollers = GetAllLootRollers()
	float waitForRollersStartTime = Time()
	float waitForRollersCurrentTime = Time()
	while ( selectedRollers.len() < expectedRollerCount )
	{
		selectedRollers.clear()
		selectedRollers = GetAllLootRollers()
		WaitFrame()

		waitForRollersCurrentTime = Time()
		if ( waitForRollersCurrentTime - waitForRollersStartTime > 3.0 )
		{
			printf( "LootRollerDebug: We've waited too long for rollers to appear. Ending the waiting period." )
			break
		}
	}

	if ( !GetCurrentPlaylistVarBool( "mirage_party_roller_can_have_vault_key", false ) )
	{
		for ( int i = selectedRollers.len() - 1; i >= 0; i-- )
		{
			LootRollerData rollerData = GetLootRollerDataFromRollerModel( selectedRollers[i] )
			if ( rollerData.isPartyRoller )
			{
				selectedRollers.fastremove( i )
				break
			}
		}
	}

	printf( "LootRollerDebug: Adding %s to %i loot rollers.", lootRef, numRollers )
	selectedRollers.randomize()

	if( selectedRollers.len() > numRollers )
		selectedRollers.resize( numRollers )

	foreach ( roller in selectedRollers )
	{
		printf( "LootRollerDebug: Adding %s to loot roller.", lootRef )
		LootRollerData rollerData = GetLootRollerDataFromRollerModel( roller )
		rollerData.lootRefs.append( lootRef )

		rollerData.lootTables[0].append( lootRef )
		if ( GetLootRollersCycleOnTimer() || GetLootRollersCycleOnDamage() )
		{
			rollerData.lootTables[1].append( lootRef )
			rollerData.lootTables[2].append( lootRef )
			rollerData.lootTables[3].append( lootRef )
			rollerData.lootTables[4].append( lootRef )
		}

		if ( lootRef == "data_knife" )
		{
			rollerData.hasVaultKey = true
		}
	}

	printf( "LootRollerDebug: Added %s to %i loot rollers", lootRef, numRollers )
}