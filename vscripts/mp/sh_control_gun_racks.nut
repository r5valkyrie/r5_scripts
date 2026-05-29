global function ControlGunRacks_Init
global function ControlGunRacks_GetCoolDownDuration
global function ControlGunRacks_GetPickupGracePeriodDuration

global const string CONTROL_GUN_RACK_CLASS_NAME = "control_gun_rack"

#if SERVER
global function ControlGunRacks_SetLootTierForGunRackGroup
global function ControlGunRacks_ResetGunRackLootOnAllGunRacksInGroup
global function ControlGunRacks_GetAllUniqueGunRackGroups

#if DEVELOPER
global function ControlGunRacks_DumpGunRackContent
#endif

const asset GUNRACK_MODEL = $"mdl/industrial/gun_rack_arm_down.rmdl"
const asset GUNRACK_MODEL_OFF = $"mdl/industrial/gun_rack_arm_down_new_off.rmdl"
const float DELAY_BEFORE_RETRY_RESET_GUNRACK = 5.0
const float MIN_CLEARANCE_FOR_GUNRACK_RESET = 100.0
#endif // SERVER
const float DELAY_BEFORE_RESET_GUNRACK = 1.0
const float CONTROL_GUNRACK_PICKUP_GRACE_PERIOD = 5.0

struct
{
#if SERVER
	array<entity> allGunRacks
	array<int> uniqueGunRackGroups
	table< int,array<string> > gunRackGroupToAvailableWeaponsTable
	table<entity,entity> lootToRackTable
	bool doGunRacksSelfReplenish
	bool resetAllLootInGroupOnPickup
	bool onMovingGeo
	float delayBeforeResetGunRackOnLootPickup
	table<entity,entity> rackToLootTable
	table<entity,string> rackToLootRefTable
	table< int, array<entity> > gunRackGroupToMemberArrayTable
	table<int,int> gunRackGroupToLootTierTable
#endif
	float delayBeforeResetGunRack
	float controlGunRackPickupGracePeriod
} file


void function ControlGunRacks_Init()
{
		if ( !GetCurrentPlaylistVarBool( "control_enable_gunracks", false ) )
		{
			#if SERVER
				BlockMapEntityParseCreationOf( "prop_dynamic", "", CONTROL_GUN_RACK_CLASS_NAME )
			#endif // SERVER
			return
		}

		#if SERVER
		PrecacheModel( GUNRACK_MODEL )
		PrecacheModel( GUNRACK_MODEL_OFF )
		AddSpawnCallbackEditorClass( "prop_dynamic", CONTROL_GUN_RACK_CLASS_NAME, ControlGunRacks_OnGunRackSpawned )
		AddCallback_EntitiesDidLoad( OnEntitiesDidLoad )
		Loot_AddCallback_OnPlayerLootPickup( ControlGunRacks_OnPlayerLootPickedUp )
		file.doGunRacksSelfReplenish = GetCurrentPlaylistVarBool( "control_gunracks_self_replenish", false )
		file.resetAllLootInGroupOnPickup = GetCurrentPlaylistVarBool( "control_gunracks_reset_all_group_loot_on_pickup", false )
		file.delayBeforeResetGunRackOnLootPickup = GetCurrentPlaylistVarFloat( "control_gunracks_delay_before_reset_onpickup", DELAY_BEFORE_RESET_GUNRACK )
		#endif // SERVER
		file.delayBeforeResetGunRack = GetCurrentPlaylistVarFloat( "control_gunracks_delay_before_reset", DELAY_BEFORE_RESET_GUNRACK )
		file.controlGunRackPickupGracePeriod = GetCurrentPlaylistVarFloat( "control_gunracks_pickup_grace_period", CONTROL_GUNRACK_PICKUP_GRACE_PERIOD )
}

#if SERVER
// When a Gun Rack spawns, assign it to its gun rack group
void function ControlGunRacks_OnGunRackSpawned( entity gunRack )
{
	gunRack.SetModel( GUNRACK_MODEL_OFF )
	file.allGunRacks.append( gunRack )

	int gunRackGroup = ControlGunRacks_GetGunRackGroup( gunRack )
	ControlGunRacks_AddGunRackToGunRackGroup( gunRack, gunRackGroup )
}

void function OnEntitiesDidLoad()
{
	// If the gun racks are loot tier 1 or higher, spawn weapons on them. Loot tier 0 has empty gun racks
	array<entity> gunRackArray = ControlGunRacks_GetAllGunRacks()
	foreach( gunRack in gunRackArray )
	{
		int gunRackGroup = ControlGunRacks_GetGunRackGroup( gunRack )
		if ( ControlGunRacks_GetLootTierForGunRackGroup( gunRackGroup ) >= 1 )
			ControlGunRacks_SpawnLootOnRack( gunRack, null )
	}
}

// Spawn a gun on the gun rack
void function ControlGunRacks_SpawnLootOnRack( entity gunRack, entity triggeringPlayer, string lootRef = "" )
{
	file.onMovingGeo = false
	if ( gunRack.HasKey( "onMovingGeo" ) )
	{
		if ( gunRack.GetValueForKey( "onMovingGeo" ) == "1" )
			file.onMovingGeo = true
	}

	int gunRackGroup = ControlGunRacks_GetGunRackGroup( gunRack )
	int lootTier = ControlGunRacks_GetLootTierForGunRackGroup( gunRackGroup )
	string lootGroupString = ControlGunRacks_GetLootGroupString( lootTier )

	// If a specific lootRef wasn't passed in figure out what weapon to spawn, avoid spawning duplicates of weapons already spawned in the loot group
	if ( lootGroupString != "" && lootRef == "" )
	{
		lootRef = ControlGunRacks_GetUniqueLootRefForGunRackGroup( gunRackGroup, lootGroupString )

		if ( SURVIVAL_Loot_IsRefValid( lootRef ) )
			ControlGunRacks_RemoveWeaponFromAvailableWeaponsForGunRackGroup( gunRackGroup, lootRef )
	}
	
	// Turn off the Gun Rack if the loot ref is not valid, otherwise spawn the weapon on the rack
	if ( lootRef == "" || !SURVIVAL_Loot_IsRefValid( lootRef ) || SURVIVAL_Loot_GetLootDataByRef( lootRef ).lootType != eLootType.MAINWEAPON )
	{
		ControlGunRacks_SetGunRackOff( gunRack )
		return
	}
	else
	{
		entity lootEnt = GunRacks_CreateAndSetupUpWeapon( gunRack, lootRef )
		file.lootToRackTable[ lootEnt ] <- gunRack
		file.rackToLootTable[gunRack] <- lootEnt
		file.rackToLootRefTable[gunRack] <- lootRef

		// If the item was spawned through a Control Gun Rack Panel, don't allow players other than the player that spawned the weapon to pick it up for a grace period
		if ( triggeringPlayer != null && file.controlGunRackPickupGracePeriod > 0 )
		{
			lootEnt.SetParent( gunRack )
			Crafting_CreateHolderEnt( triggeringPlayer, lootEnt, file.controlGunRackPickupGracePeriod )
		}
		gunRack.SetModel( GUNRACK_MODEL )
	}
}

// Turn off this Gun Rack ( remove it from any active arrays or tables and set it to its turned off model)
void function ControlGunRacks_SetGunRackOff( entity gunRack )
{
	if ( gunRack in file.rackToLootTable )
	{
		entity lootEnt = file.rackToLootTable[ gunRack ]
		if ( lootEnt in file.lootToRackTable )
			delete file.lootToRackTable[ lootEnt ]

		delete file.rackToLootTable[ gunRack ]
		if ( IsValid( lootEnt ) )
			lootEnt.Destroy()
	}

	if ( gunRack in file.rackToLootRefTable )
	{
		delete file.rackToLootRefTable[ gunRack ]
	}

	gunRack.SetModel( GUNRACK_MODEL_OFF )
}

// Get All Control Gun Racks that have spawned
array<entity> function ControlGunRacks_GetAllGunRacks()
{
	return file.allGunRacks
}

// When a player picks up a weapon from a Gun Rack turn the Gun Rack off and then decide if it should respawn loot
void function ControlGunRacks_OnPlayerLootPickedUp( entity player, entity lootEnt, string ref, int unitsPickedUp, bool willDestroy, entity deathBox, int pickupFlags )
{
	if ( lootEnt in file.lootToRackTable )
	{
		entity gunRack = file.lootToRackTable[ lootEnt ]
		ControlGunRacks_SetGunRackOff( gunRack )

		// If GunRacks are self replenishing, kick off the thread that will repopulate this one with loot
		if ( file.doGunRacksSelfReplenish && !file.resetAllLootInGroupOnPickup )
		{
			thread ControlGunRacks_ResetGunRackLoot_Thread( gunRack, file.delayBeforeResetGunRackOnLootPickup, null )
		}
		else if ( file.doGunRacksSelfReplenish && file.resetAllLootInGroupOnPickup )
		{
			// If we reset all loot in a group when loot is picked up. Get all members of a group then turn the racks off and repopulate with loot
			int gunRackGroup = ControlGunRacks_GetGunRackGroup( gunRack )

			Assert( gunRackGroup in file.gunRackGroupToMemberArrayTable, "Trying to Reset all loot in GunRack Group (" + gunRackGroup + ") but it is not in gunRackGroupToMemberArrayTable" )

			ControlGunRacks_ResetGunRackLootOnAllGunRacksInGroup( gunRackGroup, null )
		}
	}
}

// Wait a preset time and then attempt to respawn loot on the gun rack that was previously looted or turned off
void function ControlGunRacks_ResetGunRackLoot_Thread( entity gunRack, float delayBeforeReset, entity triggeringPlayer, string weaponRef = "" )
{
	bool isGunRackClear = true

	OnThreadEnd(
		function() : ( gunRack, isGunRackClear, weaponRef, triggeringPlayer )
		{
			if ( IsValid( gunRack ) && isGunRackClear && !( gunRack in file.rackToLootTable ) )
			{
				ControlGunRacks_SpawnLootOnRack( gunRack, triggeringPlayer, weaponRef )
			}
		}
	)

	wait( delayBeforeReset )

	// Keep re-checking if there is no one near the gun rack, in which case the loot can reset
	while ( IsValid( gunRack ) )
	{
		isGunRackClear = true
		foreach ( player in GetPlayerArray_Alive() )
		{
			if ( IsPositionWithinRadius( MIN_CLEARANCE_FOR_GUNRACK_RESET, gunRack.GetOrigin(), player.GetOrigin() ) )
			{
				isGunRackClear = false
				break
			}
		}

		if ( isGunRackClear )
		{
			break
		}

		wait( DELAY_BEFORE_RETRY_RESET_GUNRACK )
	}
}

// Populate a list of available (unique) weapons per gun rack group to avoid spawning duplicte weapons in a group
void function ControlGunRacks_PopulateAvailableWeaponsByGunRackGroup( int gunRackGroup, string lootGroupRef, array<string> dupesToCheck )
{
	array<string> availableWeapons
	array<string> lootGroupRefs = SURVIVAL_GetAllRefsInLootGroup( lootGroupRef, true, dupesToCheck )

	foreach ( lootRef in lootGroupRefs )
	{
		if ( lootRef != "" && SURVIVAL_Loot_IsRefValid( lootRef ) && SURVIVAL_Loot_GetLootDataByRef( lootRef ).lootType == eLootType.MAINWEAPON )
		{
			availableWeapons.append( lootRef )
		}
	}

	Assert( availableWeapons.len() > 0, "Could not get any valid weapons from lootGroupRef (" + lootGroupRef + ")" )
	file.gunRackGroupToAvailableWeaponsTable[ gunRackGroup ] <- availableWeapons
}

// Remove a weapon from the unique available weapons when the ref has been used (so a different rack in the gun rack group doesn't use the same ref)
void function ControlGunRacks_RemoveWeaponFromAvailableWeaponsForGunRackGroup( int gunRackGroup, string weaponRef )
{
	Assert( gunRackGroup in file.gunRackGroupToAvailableWeaponsTable, "Could not remove a weapon from the Available GunRack Group Weapons table because the group is not in the table" )
	array<string> availableWeapons = file.gunRackGroupToAvailableWeaponsTable[ gunRackGroup ]
	availableWeapons.fastremovebyvalue( weaponRef )
	file.gunRackGroupToAvailableWeaponsTable[ gunRackGroup ] <- availableWeapons
}

// Get a unique weapon ref for a gun rack to spawn
string function ControlGunRacks_GetUniqueLootRefForGunRackGroup( int gunRackGroup, string lootGroupRef )
{
	string lootRef = ""

	// Populate a list of weapons already on the racks in a group and avoid adding those to a new available weapons list
	array<string> dupesToCheck = []

	if ( !( gunRackGroup in file.gunRackGroupToAvailableWeaponsTable ) )
	{
		dupesToCheck = ControlGunRacks_GetLootRefsForSpawnedGunsInGunRackGroup( gunRackGroup )
		ControlGunRacks_PopulateAvailableWeaponsByGunRackGroup( gunRackGroup, lootGroupRef, dupesToCheck )
	}

	array<string> availableWeapons = file.gunRackGroupToAvailableWeaponsTable[ gunRackGroup ]

	if ( availableWeapons.len() == 0 )
	{
		if ( dupesToCheck.len() == 0 )
			dupesToCheck = ControlGunRacks_GetLootRefsForSpawnedGunsInGunRackGroup( gunRackGroup )

		ControlGunRacks_PopulateAvailableWeaponsByGunRackGroup( gunRackGroup, lootGroupRef, dupesToCheck )
		availableWeapons = file.gunRackGroupToAvailableWeaponsTable[ gunRackGroup ]
	}

	lootRef = availableWeapons.getrandom()
	return lootRef
}

// Return an array of lootrefs for all weapons currently spawned on the GunRacks in a GunRack Group
array<string> function ControlGunRacks_GetLootRefsForSpawnedGunsInGunRackGroup( int gunRackGroup )
{
	array<string> lootRefs = []
	Assert( gunRackGroup in file.gunRackGroupToMemberArrayTable, "Getting lootrefs in ControlGunRacks_GetLootRefsForSpawnedGunsInGunRackGroup but (" + gunRackGroup + ") is not in gunRackGroupToMemberArrayTable " )
	array<entity> gunRacksInGroup = file.gunRackGroupToMemberArrayTable[ gunRackGroup ]
	foreach ( gunRack in gunRacksInGroup )
	{
		if ( IsValid( gunRack ) && gunRack in file.rackToLootRefTable )
		{
			lootRefs.append( file.rackToLootRefTable[ gunRack ] )
		}
	}

	return lootRefs
}

// Add a GunRack to a gunrack group ( so we can determine which GunRacks don't spawn duplicate loot ).
// This can be set in the editor by setting the "gunRackGroup" variable or here through script
void function ControlGunRacks_AddGunRackToGunRackGroup( entity gunRack, int gunRackGroup )
{
	if ( gunRack.HasKey( "gunRackGroup" ) )
	{
		gunRack.kv.gunRackGroup = gunRackGroup
	}
	else
	{
		printt( "Running ControlGunRacks_AddGunRackToGunRackGroup, but gunRack does NOT have the gunRackGroup key" )
		Warning( "Running ControlGunRacks_AddGunRackToGunRackGroup, but gunRack does NOT have the gunRackGroup key" )
	}

	if ( gunRackGroup in file.gunRackGroupToMemberArrayTable )
	{
		if ( !file.gunRackGroupToMemberArrayTable[ gunRackGroup ].contains( gunRack ) )
			file.gunRackGroupToMemberArrayTable[ gunRackGroup ].append( gunRack )
	}
	else
	{
		array<entity> groupMembers = [ ]
		groupMembers.append( gunRack )
		file.gunRackGroupToMemberArrayTable[ gunRackGroup ] <- groupMembers
	}

	if ( !file.uniqueGunRackGroups.contains( gunRackGroup ) )
	{
		file.uniqueGunRackGroups.append( gunRackGroup )
		int gunRackLootTier = GetCurrentPlaylistVarInt( "control_gunrack_starting_tier", 0 )
		ControlGunRacks_SetLootTierForGunRackGroup( gunRackGroup, gunRackLootTier )
	}
}

// Return an array of all the unique gun rack groups
array<int> function ControlGunRacks_GetAllUniqueGunRackGroups()
{
	return file.uniqueGunRackGroups
}

// Get the loot group string for the current tier of the gun rack group
string function ControlGunRacks_GetLootGroupString( int lootTier )
{
	return GetCurrentPlaylistVarString( "control_gunrack_lootgroup_tier_" + lootTier, "" )
}

// Turn off all the gun racks in the group and then respawn loot on them
void function ControlGunRacks_ResetGunRackLootOnAllGunRacksInGroup( int gunRackGroup, entity triggeringPlayer, array<string> customWeaponRefs = [] )
{
	array< entity > gunRacksInGroup = clone file.gunRackGroupToMemberArrayTable[ gunRackGroup ]
	ControlGunRacks_TurnOffAndResetGunRacks( gunRacksInGroup, customWeaponRefs, triggeringPlayer )
}

// Turn off all the GunRacks in the passed array with a delay between turning each one off and then respawning the loot on them.
void function ControlGunRacks_TurnOffAndResetGunRacks( array<entity> gunRacks, array<string> customWeaponRefs, entity triggeringPlayer )
{
	int maxCustomWeaponRefsIndex = customWeaponRefs.len() - 1
	int currentGunRackIndex = 0
	string weaponRef

	foreach ( gunRack in gunRacks )
	{
		weaponRef = ""
		if ( currentGunRackIndex <= maxCustomWeaponRefsIndex )
			weaponRef = customWeaponRefs[ currentGunRackIndex ]

		thread ControlGunRacks_TurnOffAndResetGunRack_Thread( gunRack, triggeringPlayer, weaponRef )
		currentGunRackIndex++
	}
}

// Turn off a single GunRack if there is no one near it. Then Respawn loot on it after a delay when there is no one near it
void function ControlGunRacks_TurnOffAndResetGunRack_Thread( entity gunRack, entity triggeringPlayer, string weaponRef )
{
	bool isGunRackClear = true

	OnThreadEnd(
		function() : ( gunRack, isGunRackClear, weaponRef, triggeringPlayer )
		{
			if ( IsValid( gunRack ) && isGunRackClear )
			{
				ControlGunRacks_SetGunRackOff( gunRack )
				thread ControlGunRacks_ResetGunRackLoot_Thread( gunRack, file.delayBeforeResetGunRack, triggeringPlayer, weaponRef )
			}
		}
	)

	// Keep re-checking if there is no one near the gun rack, in which case the loot can reset
	while ( IsValid( gunRack ) )
	{
		isGunRackClear = true
		foreach ( player in GetPlayerArray_Alive() )
		{
			if ( IsPositionWithinRadius( MIN_CLEARANCE_FOR_GUNRACK_RESET, gunRack.GetOrigin(), player.GetOrigin() ) )
			{
				isGunRackClear = false
				break
			}
		}

		if ( isGunRackClear )
		{
			break
		}

		wait( DELAY_BEFORE_RETRY_RESET_GUNRACK )
	}
}

// Get the GunRackGroup this GunRack belongs to. We can use groups to tell the gunRacks in them not to spawn duplicate loot.
int function ControlGunRacks_GetGunRackGroup( entity gunRack )
{
	int gunRackGroup = 0
	if ( gunRack.HasKey( "gunRackGroup" ) )
	{
		gunRackGroup = int( gunRack.GetValueForKey( "gunRackGroup" ) )
	}
	else
	{
		printt( "Running ControlGunRacks_SpawnLootOnRack with file.isAvoidingDupesInGunRackGroups set to true, but gunRack does NOT have the gunRackGroup key" )
		Warning( "Running ControlGunRacks_SpawnLootOnRack with file.isAvoidingDupesInGunRackGroups set to true, but gunRack does NOT have the gunRackGroup key" )
	}

	return gunRackGroup
}

// Set the current Loot Tier of this gun rack group
void function ControlGunRacks_SetLootTierForGunRackGroup( int gunRackGroup, int tier )
{
	if ( tier > CONTROL_MAX_LOOT_TIER )
		return

	if ( gunRackGroup in file.gunRackGroupToLootTierTable )
	{
		if ( file.gunRackGroupToLootTierTable[ gunRackGroup ] != tier )
		{
			file.gunRackGroupToLootTierTable[ gunRackGroup ] = tier
			if ( gunRackGroup in file.gunRackGroupToAvailableWeaponsTable )
				delete file.gunRackGroupToAvailableWeaponsTable[ gunRackGroup ]
		}
	}
	else
	{
		file.gunRackGroupToLootTierTable[ gunRackGroup ] <- tier
	}
}

// Get the current tier of this Gun Rack Group
int function ControlGunRacks_GetLootTierForGunRackGroup( int gunRackGroup )
{
	return file.gunRackGroupToLootTierTable[ gunRackGroup ]
}

#if DEVELOPER
void function ControlGunRacks_DumpGunRackContent()
{
	foreach( loot, rack in file.lootToRackTable )
	{
		printt( loot.GetModelName(), rack.GetOrigin() )
	}
}

#endif
#endif // SERVER

float function ControlGunRacks_GetCoolDownDuration()
{
	return file.controlGunRackPickupGracePeriod + file.delayBeforeResetGunRack
}

float function ControlGunRacks_GetPickupGracePeriodDuration()
{
	return file.controlGunRackPickupGracePeriod
}
