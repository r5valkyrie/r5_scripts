// The loadout selection system allows gamemodes to use a Loadout Selection Menu that contains loadout slots
// Each Loadout slot can contain weapons, ordnance, and equipment ( note currently only 2 weapons are supported, single weapon loadouts don't work)
// ToDo Dswieczko: Add support for loadouts with single or even no weapons

// Loadouts are defined in a csv like loadoutselection_selectable_loadouts.csv ( used for Control Mode, please do not alter that file unless you are making changes for Control)
// Loadout Rotations ( which loadouts populate the menu, how often they rotate) are defined in a csv like loadoutselection_loadout_rotations.csv ( also used for Control Mode)
// The attachment definitions for weapon tiers ( what attachments appear on the weapon) are defined in a csv like loadoutselection_weapon_data.csv ( also used for Control Mode)
// If you want different loadouts, rotations, or attachments for your mode you can make your own csv and then set the system to use it in LoadoutSelection_SetDataTableAssets()
// See the Winter Express Example there to help you.

// In order to use the Loadout Selection Menu in your mode you will need to set these 2 playlist vars:
// loadoutselection_enable_loadouts 1
// loadoutselection_rotation_start  "2021-07-21 10:00:00 -08:00" ( This should coincide with when your mode goes live, it is used to calculate the loadout slot rotations)
// ToDo Dswieczko: Update to not require the rotation start

// Additional vars:
// loadoutselection_disable_all_tiers_for_disabledweapons 1 ( when a weapon or item is disabled through playlist vars should that specific tier be disabled or 1 if all variations should be disabled)
// loadoutselection_avoid_duplicate_weapons_in_loadouts 1 ( when set to 0, multiple loadouts in a rotation can have the same weapons, when set to 1 if a loadout has the same weapon as a previous loadout it will automatically rotate until it finds a loadout with no dupes)
// See loadoutselection_dt_override_ in playlist vars for examples of overriding loadouts, weapons, equipments, names, and even attachments

// You must also update the loadout menu for players on reconnect using this function: LoadoutSelection_UpdateLoadoutInfoForMenus( player )
// In order to give players their loadout, this function is used on respawn: LoadoutSelection_GivePlayerInventoryAndLoadout( player )

// There are a few other edge cases for updating loadout info on screens or menus that show the currently selected loadout.
// To see examples of how this system is used, check out sh_gamemode_control.nut and search for LoadoutSelection ( this gamemode shows the loadout option on a spawn screen )
// Another example can be seen in sh_gamemode_winterexpress which shows the loadout option when a player is spectating or when they spawn on the hovertank

global function LoadoutSelection_Init

#if CLIENT || SERVER
global function LoadoutSelection_RegisterNetworking
global function LoadoutSelection_GetWeaponLootTierForMenu
global function ModeUsesLoadoutWeapons
#endif // CLIENT || SERVER

#if SERVER
global function AddCallback_LoadoutSelection_OnLoadoutUpdated
global function AddCallback_LoadoutSelection_OnLoadoutMenuClosed
global function AddCallback_LoadoutSelection_OnLoadoutSelected
global function LoadoutSelection_GetSelectedLoadoutSlotIndex_Server
global function ClientCallback_LoadoutSelection_OnLoadoutSelectMenuClose
global function ClientCallback_LoadoutSelection_OnLoadoutSelectMenuLoadoutSelected
global function ClientCallback_LoadoutSelection_SetOpticPreference
global function LoadoutSelection_GivePlayerInventoryAndLoadout
global function LoadoutSelection_UpdateLoadoutInfoForMenus
global function LoadoutSelection_GetEquipmentLoadoutByLoadoutSlotIndex
global function LoadoutSelection_ShuffleLoadoutRotation
#endif // SERVER

#if CLIENT
global function UICallback_LoadoutSelection_BindOpticSlotButton
global function UICallback_LoadoutSelection_BindWeaponElement
global function UICallback_LoadoutSelection_OnRequestOpenScopeSelection
global function ServerCallback_LoadoutSelection_FinishedProcessingClickEvent
global function ServerCallback_LoadoutSelection_UpdateLoadoutInfo
global function ServerCallback_LoadoutSelection_UpdateSelectedLoadoutInfo
global function ServerCallback_LoadoutSelection_RefreshUILoadoutInfo
global function ServerCallback_LoadoutSelection_RepopulateLoadouts
global function UICallback_LoadoutSelection_OnOpticSlotButtonClick
global function UICallback_LoadoutSelection_OpticSelectDialogueClose
global function UICallback_LoadoutSelection_BindWeaponRui
global function UICallback_LoadoutSelection_BindItemIcon
global function UICallback_LoadoutSelection_SetConsumablesCountRui
global function LoadoutSelection_GetItemIcon
global function LoadoutSelection_GetWeaponLootTeir
global function LoadoutSelection_RefreshAllUILoadoutInfo
const string SOUND_SELECT_OPTIC = "ui_arenas_ingame_inventory_Select_Optic"
#endif // CLIENT

#if UI
global function LoadoutSelection_UpdateLoadoutInfo_UI
global function LoadoutSelection_SetSelectedLoadoutSlotIndex_UI
global function LoadoutSelection_GetSelectedLoadoutSlotIndex_UI
global function LoadoutSelection_SetLoadoutCounts_UI
global function LoadoutSelection_GetLoadoutCounts_UI
#endif // UI

global function IsUsingLoadoutSelectionSystem
global function LoadoutSelection_GetWeaponCountByLoadoutIndex





global const int LOADOUTSELECTION_MAX_LOADOUT_COUNT_REGULAR = 6





global const int LOADOUTSELECTION_MAX_TOTAL_LOADOUT_SLOTS = LOADOUTSELECTION_MAX_LOADOUT_COUNT_REGULAR


global const int LOADOUTSELECTION_MAX_WEAPONS_PER_LOADOUT = 2
global const int LOADOUTSELECTION_MAX_CONSUMABLES_PER_LOADOUT = 5
global const int LOADOUTSELECTION_MAX_SCOPE_INDEX = 9

#if CLIENT || UI
global function LoadoutSelection_GetLocalizedLoadoutHeader
global function LoadoutSelection_GetLoadoutSlotTypeForLoadoutIndex
global function LoadoutSelection_GetSelectedLoadoutSlotIndex_CL_UI
#endif // CLIENT || UI

#if CLIENT || SERVER
global function LoadoutSelection_GetWeaponSetStringForTier
global function LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex
global function LoadoutSelection_GetAvailableWeaponUpgradesForWeaponRef
global function LoadoutSelection_GetAvailableLoadoutCount
global function LoadoutSelection_RepopulateLoadouts

const string LOADOUTSELECTION_ROTATION_OVERRIDE_KEY = "rotation"
const string LOADOUTSELECTION_LOADOUT_OVERRIDE_KEY = "loadout"
const string LOADOUTSELECTION_WEAPONDATA_OVERRIDE_KEY = "weapondata"
const asset LOADOUTSELECTION_ROTATIONS_DATATABLE = $"datatable/loadoutselection_loadout_rotations.rpak"
const asset LOADOUTSELECTION_LOADOUTS_DATATABLE = $"datatable/loadoutselection_selectable_loadouts.rpak"
#endif // CLIENT || SERVER

const asset LOADOUTSELECTION_WEAPON_DATA_DATATABLE = $"datatable/loadoutselection_weapon_data.rpak"

#if CLIENT || SERVER
const table<string, asset> CUSTOM_VARIANT_ROTATIONS_DATATABLE = {

		[ "WINTER_EXPRESS" ] = $"datatable/gamemode_winterexpress_loadout_rotations.rpak",


		[ "TDM" ] = $"datatable/gamemode_tdm_loadout_rotations.rpak",
		[ "SWAT" ] = $"datatable/gamemode_tdm_swat_loadout_rotations.rpak",
		[ "SHOTTYSNIPERS" ] = $"datatable/gamemode_tdm_shottysnipers_loadout_rotations.rpak",

}

const table<string, asset> CUSTOM_VARIANT_LOADOUTS_DATATABLE = {

		[ "WINTER_EXPRESS" ] = $"datatable/gamemode_winterexpress_selectable_loadouts.rpak",


		[ "TDM" ] = $"datatable/gamemode_tdm_selectable_loadouts.rpak",
		[ "SWAT" ] = $"datatable/gamemode_tdm_swat_selectable_loadouts.rpak",
		[ "SHOTTYSNIPERS" ] = $"datatable/gamemode_tdm_shottysnipers_selectable_loadouts.rpak",

}

global const string NETVAR_LOADOUT_CURRENT_MANUAL_ROTATION_INDEX_NAME = "manualLoadoutCurrentRotationIndex" // This is the index used for manual rotations ( the same index is used for all the loadout categories and it can change mid game )
global const string NETVAR_TIME_SINCE_EVENT_STARTED_NAME = "timeSinceEventStarted" // This is the Unix time difference between the match starting and the time the loadout rotations started ( season start ). It is used to determine what loadout index to use for loadouts determined by time

const array<string> LOADOUTSELECTION_WEAPON_SET_STRINGS_FOR_TIER = [ WEAPON_LOCKEDSET_SUFFIX_WHITESET, WEAPON_LOCKEDSET_SUFFIX_WHITESET, WEAPON_LOCKEDSET_SUFFIX_BLUESET, WEAPON_LOCKEDSET_SUFFIX_PURPLESET, WEAPON_LOCKEDSET_SUFFIX_GOLD ]

// This is set in the Loadouts_datatables and determines how weapons and equipment in loadouts affect loot in the world ( airdrops, lootbins, ground loot etc)
// None - World loot can contain the same items as loadouts
// Rarity - World loot can contain different rarities of items in loadouts but not the same ( if a loadout has blue armor only blue armor is blocked from spawning in loot )
// All - World loot cannot contain any rarity of items in loadouts ( if a loadout has blue armor all rarities of armor are blocked from spawning in loot)
global enum eLoadoutSelectionExclusivity
{
	NONE,
	RARITY,
	ALL,
	_count
}

// This is set in Rotations_datatables and determines how frequently loadout slots rotate ( an Assault Loadout can have multiple different variations, how often do we cycle between them)
// Game - Every 15 mins
// Hourly - Every 1 hour
// Daily - Every 24 hours
// Weekly - Every 7 days
// Permanent - Do not rotate
global enum eLoadoutSelectionRotationStyle
{
	GAME,
	HOURLY,
	DAILY,
	WEEKLY,
	PERMANENT,
	MANUAL,
	_count
}
#endif // CLIENT || SERVER

// This is set in Rotations_datatables and determines what type of loadout slot this is.
// Regular - Applies to most loadout slots
// Featured - WIP a special slot
// Challenge - WIP a special slot
global enum eLoadoutSelectionSlotType
{
	INVALID,
	REGULAR,





	_count
}

#if CLIENT || SERVER
struct LoadoutSelectionItem
{
	string ref
	asset icon
	string name
	string desc
}

struct LoadoutSelectionLoadoutContents
{
	string loadoutNameText
	array< LoadoutSelectionItem > weaponLoadoutSelectionItemsInLoadout
	array< string > weaponsInLoadout
	string weaponLoadoutString
	int weaponExclusivityStyle
	string consumablesLoadoutString
	array< string > consumablesInLoadout
	array< LoadoutSelectionItem > consumableLoadoutSelectionItemsInLoadout
	int consumableExclusivityStyle
	array< string > equipmentInLoadout
	int equipmentExclusivityStyle

	#if SERVER
		table < entity, int > playerToWeapon0ScopePreferenceTable
		table < entity, int > playerToWeapon1ScopePreferenceTable
	#endif // SERVER

	#if CLIENT
		table < int, int > weaponIndexToScopePreferenceTable
	#endif // CLIENT
}

struct LoadoutSelectionCategory
{
	int index
	string loadoutSlot
	int rotationStyle
	int loadoutSlotType

	table< string, LoadoutSelectionLoadoutContents > loadoutContentsByNameTable
	array< string > loadoutContentNames
	string activeLoadoutName = ""
}
#endif // CLIENT || SERVER

struct {
	#if SERVER
		table< entity, int > playerToSelectedLoadoutTable
		table< entity, int > playerToLastUsedLoadoutTable
		table< int, array< string > > loadoutSlotIndexToConsumableLoadoutTable
		table< int, array< string > > loadoutSlotIndexToEquipmentLoadoutTable
		array<void functionref( entity )> callbacks_LoadoutSelection_OnLoadoutUpdated
		array<void functionref( entity )> callbacks_LoadoutSelection_OnLoadoutMenuClosed
		array<void functionref( entity )> callbacks_LoadoutSelection_OnLoadoutSelected
	#endif // SERVER

	#if CLIENT || SERVER
		asset rotationsDataTable = LOADOUTSELECTION_ROTATIONS_DATATABLE
		asset loadoutsDataTable = LOADOUTSELECTION_LOADOUTS_DATATABLE
		table<int, LoadoutSelectionCategory > loadoutSlotIndexToCategoryDataTable
		array<LoadoutSelectionCategory> loadoutCategories
		int maxLoadoutsPerCategory = 0
		bool areLoadoutsPopulated = false
		table< int, WeaponLoadout > loadoutSlotIndexToWeaponLoadoutTable
		table<string, array<string> > weaponUpgrades
		table<string, array<string> > weaponOptics
	#endif // CLIENT || SERVER

	asset weaponDataDataTable = LOADOUTSELECTION_WEAPON_DATA_DATATABLE
	// Data used for the loadout selection menu itself
	table < int, int > loadoutSlotIndexToWeaponCountTable
	table < int, string > loadoutSlotIndexToHeaderTable
	table < int, int > loadoutSlotIndexToLoadoutTypeTable

	#if CLIENT || UI
		int playerSelectedLoadout = 0
		// ToDo Dswieczko: make loadout count an array indexed by enum instead of 3 different variables
		int maxLoadoutCountRegular = -1




	#endif // CLIENT || UI

	#if CLIENT
		int selectedLoadoutForOptic = -1
		bool isProcessingClickEvent = false
	#endif // CLIENT
} file

void function LoadoutSelection_Init()
{
	if ( !IsUsingLoadoutSelectionSystem() )
		return

	#if CLIENT || SERVER
		LoadoutSelection_SetDataTableAssets()
	#endif // CLIENT || SERVER

	LoadoutSelection_InitWeaponData()

	#if CLIENT || SERVER
		LoadoutSelection_RegisterLoadoutData()
		LoadoutSelection_RegisterLoadoutDistribution()
		#if SERVER
			


			LoadoutSelection_HandleItemExclusivity() // This has to happen after populate loadouts so we know what loadouts got picked ( and can disable the items from those in loot)
			RegisterSignal( "LoadoutSelection_LoadoutSelectMenuClosed" )
		#endif // SERVER

		#if CLIENT || SERVER
			AddCallback_EntitiesDidLoad( LoadoutSelection_PopulateLoadouts ) // requires that Netvars are enabled, which requires entities to have been created
		#endif
		
		#if SERVER
			AddCallback_EntitiesDidLoad( LoadoutSelection_SetUnixTimeSinceEventStarted ) // requires that Netvars are enabled, which requires entities to have been created
		#endif

		Remote_RegisterUIFunction( "LoadoutSelectionMenu_OpenLoadoutMenu", "bool" )
		Remote_RegisterUIFunction( "LoadoutSelectionMenu_CloseLoadoutMenu" )
	#endif // CLIENT || SERVER
}


bool function IsUsingLoadoutSelectionSystem()
{
	return GetCurrentPlaylistVarBool( "loadoutselection_enable_loadouts", false )
}

bool function LoadoutSelection_ShouldAvoidDuplicateWeaponsInLoadoutRotation()
{
	return GetCurrentPlaylistVarBool( "loadoutselection_avoid_duplicate_weapons_in_loadouts", false )
}













string function GetCustomLoadoutName()
{
	return GetCurrentPlaylistVarString( "loadoutselection_custom_loadout", "" )
}


#if CLIENT || SERVER
// Allow us to overwrite the datatables if different modes want to use different tables
void function LoadoutSelection_SetDataTableAssets()
{
	// These are the datatables to set if different than the default. Tried doing this through playlist var overrides and had it working.
	// There was unfortunately an issue where a datatable only defined in script in the playlist file wouldn't get added to rsons correctly.
	// To avoid issues it is best to just manually add the datatables here for each mode that needs to override them.


		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_WINTEREXPRESS ) )
		{
			file.rotationsDataTable = GetCustomLoadoutRotationsDataTable_Asset( "WINTER_EXPRESS" )
			file.loadoutsDataTable = GetCustomLoadoutDataTable_Asset( "WINTER_EXPRESS" )
		}



	if ( GameModeVariant_IsActive( eGameModeVariants.FREEDM_TDM ) )
	{
		string customLoadoutName = GetCustomLoadoutName()
		if ( customLoadoutName != "" )
		{
			asset customLoadoutRotation = GetCustomLoadoutRotationsDataTable_Asset( customLoadoutName )
			asset customLoadout = GetCustomLoadoutDataTable_Asset( customLoadoutName )
			file.rotationsDataTable = GetCustomLoadoutRotationsDataTable_Asset( customLoadoutName )
			file.loadoutsDataTable = GetCustomLoadoutDataTable_Asset( customLoadoutName )
		}
	}

}

asset function GetCustomLoadoutRotationsDataTable_Asset( string customName ) {
	return CUSTOM_VARIANT_ROTATIONS_DATATABLE[ customName ]
}

asset function GetCustomLoadoutDataTable_Asset( string customName ) {
	return CUSTOM_VARIANT_LOADOUTS_DATATABLE[ customName ]
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
void function LoadoutSelection_RegisterNetworking()
{
	if ( !IsUsingLoadoutSelectionSystem() )
		return

	Remote_RegisterClientFunction( "ServerCallback_LoadoutSelection_FinishedProcessingClickEvent" )
	Remote_RegisterClientFunction( "ServerCallback_LoadoutSelection_UpdateLoadoutInfo", "int", 0, LOADOUTSELECTION_MAX_TOTAL_LOADOUT_SLOTS + 1, "int", -1, LOADOUTSELECTION_MAX_SCOPE_INDEX + 1, "int", -1, LOADOUTSELECTION_MAX_SCOPE_INDEX + 1 )
	Remote_RegisterClientFunction( "ServerCallback_LoadoutSelection_RefreshUILoadoutInfo" )
	Remote_RegisterClientFunction( "ServerCallback_LoadoutSelection_UpdateSelectedLoadoutInfo", "int", 0, LOADOUTSELECTION_MAX_TOTAL_LOADOUT_SLOTS + 1 )
	Remote_RegisterClientFunction( "ServerCallback_LoadoutSelection_RepopulateLoadouts")
	Remote_RegisterServerFunction( "ClientCallback_LoadoutSelection_OnLoadoutSelectMenuClose" )
	Remote_RegisterServerFunction( "ClientCallback_LoadoutSelection_OnLoadoutSelectMenuLoadoutSelected", "int", 0, LOADOUTSELECTION_MAX_TOTAL_LOADOUT_SLOTS + 1 )
	Remote_RegisterServerFunction( "ClientCallback_LoadoutSelection_SetOpticPreference", "int", 0, LOADOUTSELECTION_MAX_TOTAL_LOADOUT_SLOTS + 1, "int", 0, 2, "int", 0, LOADOUTSELECTION_MAX_SCOPE_INDEX + 1 )

	RegisterNetworkedVariableSafe( NETVAR_LOADOUT_CURRENT_MANUAL_ROTATION_INDEX_NAME, SNDC_GLOBAL, SNVT_INT, 0)
	RegisterNetworkedVariableSafe( NETVAR_TIME_SINCE_EVENT_STARTED_NAME, SNDC_GLOBAL, SNVT_BIG_INT, 0)
}
#endif // CLIENT || SERVER

/*
   _____ ______ _______   _____       _______         ______ _____   ____  __  __   _______       ____  _      ______  _____
  / ____|  ____|__   __| |  __ \   /\|__   __|/\     |  ____|  __ \ / __ \|  \/  | |__   __|/\   |  _ \| |    |  ____|/ ____|
 | |  __| |__     | |    | |  | | /  \  | |  /  \    | |__  | |__) | |  | | \  / |    | |  /  \  | |_) | |    | |__  | (___
 | | |_ |  __|    | |    | |  | |/ /\ \ | | / /\ \   |  __| |  _  /| |  | | |\/| |    | | / /\ \ |  _ <| |    |  __|  \___ \
 | |__| | |____   | |    | |__| / ____ \| |/ ____ \  | |    | | \ \| |__| | |  | |    | |/ ____ \| |_) | |____| |____ ____) |
  \_____|______|  |_|    |_____/_/    \_\_/_/    \_\ |_|    |_|  \_\\____/|_|  |_|    |_/_/    \_\____/|______|______|_____/
  Get Data from Tables
*/

#if CLIENT || SERVER
// Get data for the loadout categories which contain all the different loadouts themselves
void function LoadoutSelection_RegisterLoadoutData()
{
	var dataTable = GetDataTable( file.rotationsDataTable )
	int numRows = minint( GetDataTableRowCount( dataTable ), LOADOUTSELECTION_MAX_TOTAL_LOADOUT_SLOTS )
	int index = 0
	int row = 0

	for ( int i = 0; i < numRows; i++ )
	{
		LoadoutSelectionCategory item
		row = i
		item.loadoutSlot = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "loadoutSlot" ) )

		// Check if this slot is disabled through playlist vars
		bool isSlotDisabled = GetCurrentPlaylistVarBool( "loadoutselection_dt_override_" + item.loadoutSlot + "_disable", false )
		if ( isSlotDisabled )
		{
			#if DEVELOPER
				printt( "LOADOUT SELECTION: RegisterLoadoutData skipping " + item.loadoutSlot + " because it is disabled through playlist vars" )
			#endif // DEVELOPER

			continue
		}

		// Check if this slot is being overridden by another slot through playlist vars
		string loadoutSlotToUseAsOverride = GetCurrentPlaylistVarString( "loadoutselection_dt_override_" + item.loadoutSlot + "_loadouts", "" )
		if ( loadoutSlotToUseAsOverride != "" )
		{
			#if DEVELOPER
				printt( "LOADOUT SELECTION: Overriding Loadout Slot: " + item.loadoutSlot + " with " + loadoutSlotToUseAsOverride )
			#endif // DEVELOPER

			row = GetDataTableRowMatchingStringValue( dataTable, GetDataTableColumnByName( dataTable, "loadoutSlot" ), loadoutSlotToUseAsOverride )
			Assert( row > -1, "Attempted to override a Loadout Slot through playlist vars using an invalid Loadout Slot or a Slot that is not in the Rotations DataTable" )
			item.loadoutSlot = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "loadoutSlot" ) )
		}

		item.index = index

		string loadoutSlotType = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "loadoutSlotType" ) )
		item.loadoutSlotType = LoadoutSelection_GetLoadoutSlotTypeEnumFromString( loadoutSlotType )

		string rotationStyle = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "rotationStyle" ) )
		item.rotationStyle = LoadoutSelection_GetRotationStyleEnumFromString( rotationStyle )
		string loadoutContentsString = GetDataTableString( dataTable, row, GetDataTableColumnByName( dataTable, "loadoutContentsList" ) )
		array<string> loadouts = GetTrimmedSplitString( loadoutContentsString, " " )
		foreach( loadout in loadouts )
		{
			// Check if an individual loadout is being overridden through playlist vars
			string loadoutToUseAsOverride = GetCurrentPlaylistVarString( "loadoutselection_dt_override_loadout_" + loadout, "" )
			if ( loadoutToUseAsOverride != "" )
			{
				#if DEVELOPER
					printt( "LOADOUT SELECTION: Overriding Loadout: " + loadout + " with " + loadoutToUseAsOverride )
				#endif // DEVELOPER

				loadout = loadoutToUseAsOverride
			}

			LoadoutSelectionLoadoutContents newLoadoutStruct
			item.loadoutContentsByNameTable[loadout] <- newLoadoutStruct
			item.loadoutContentNames.append( loadout )
		}

		file.loadoutSlotIndexToCategoryDataTable[ index ] <- item
		file.loadoutCategories.append( item )
		if ( item.loadoutContentNames.len() >  file.maxLoadoutsPerCategory)
			file.maxLoadoutsPerCategory = item.loadoutContentNames.len()
		index++
	}

	#if DEVELOPER
		printt( "LOADOUT SELECTION: RegisterLoadoutData Completed" )
	#endif // DEVELOPER
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Get data for the actual loadouts themselves ( what they should contain ) and disable loadouts if they contain disabled weapons
void function LoadoutSelection_RegisterLoadoutDistribution()
{
	var distributionTable = GetDataTable( file.loadoutsDataTable )
	int numRows = GetDataTableRowCount( distributionTable )
	array<string> displayIgnoredItems
	array<string> loadoutsToDisable

	foreach ( item in file.loadoutCategories )
	{
		#if DEVELOPER
			printt( "LOADOUT SELECTION: Getting datatable for loadout " + item.loadoutSlot )
		#endif // DEVELOPER

		foreach ( name, loadout in item.loadoutContentsByNameTable )
		{
			int startingRow = GetDataTableRowMatchingStringValue( distributionTable, GetDataTableColumnByName( distributionTable, "loadout" ), name )
			loadout.loadoutNameText = GetDataTableString( distributionTable, startingRow, GetDataTableColumnByName( distributionTable, "loadoutText" ) )
			string weaponExclusivityStyle = GetDataTableString( distributionTable, startingRow, GetDataTableColumnByName( distributionTable, "exclusivityStyleWeapons" ) )
			loadout.weaponExclusivityStyle = LoadoutSelection_GetExclusivityStyleEnumFromString( weaponExclusivityStyle )
			string consumableExclusivityStyle = GetDataTableString( distributionTable, startingRow, GetDataTableColumnByName( distributionTable, "exclusivityStyleConsumables" ) )
			loadout.consumableExclusivityStyle = LoadoutSelection_GetExclusivityStyleEnumFromString( consumableExclusivityStyle )
			string equipmentExclusivityStyle = GetDataTableString( distributionTable, startingRow, GetDataTableColumnByName( distributionTable, "exclusivityStyleEquipment" ) )
			loadout.equipmentExclusivityStyle = LoadoutSelection_GetExclusivityStyleEnumFromString( equipmentExclusivityStyle )

			bool didOverrideWeapons = false
			bool didOverrideConsumables = false
			bool didOverrideEquipment = false
			bool didDisableWeapon = false

			string loadoutNameTextOverride = GetCurrentPlaylistVarString( "loadoutselection_dt_override_loadout_" + name + "_name_text", "" )
			if ( loadoutNameTextOverride != "" )
			{
				loadout.loadoutNameText = loadoutNameTextOverride
			}
			// Check if there is a playlist override for the weapons in this loadout
			string loadoutPlaylistCheckWeapons = GetCurrentPlaylistVarString( "loadoutselection_dt_override_loadout_" + name + "_weapons", "" )
			if ( loadoutPlaylistCheckWeapons != "" )
			{
				loadout.weaponLoadoutString = loadoutPlaylistCheckWeapons
				array<string> weaponsInLoadout = GetTrimmedSplitString( loadoutPlaylistCheckWeapons, " " )
				foreach( weapon in weaponsInLoadout )
				{
					if ( LoadoutSelection_IsRefValidWeapon( weapon ) )
					{
						// Make sure this weapon is not disabled through playlist vars before adding it to the loadout
						LootData data = SURVIVAL_Loot_GetLootDataByRef( weapon )
						if ( !SURVIVAL_Loot_IsRefDisabled( data.baseWeapon ) )
						{
							loadout.weaponsInLoadout.append( weapon )
						}
						else
						{
							didDisableWeapon = true
							Warning( "LOADOUT SELECTION: Attempting to override a weapon for loadout: " + name + " but the override weapon: " + data.baseWeapon + " is disabled (likely through playlist vars)" )
						}
					}
				}

				didOverrideWeapons = true
			}

			// Check if there is a playlist override for the consumables in this loadout
			string loadoutPlaylistCheckConsumables = GetCurrentPlaylistVarString( "loadoutselection_dt_override_loadout_" + name + "_consumables", "" )
			if ( loadoutPlaylistCheckConsumables != "" )
			{
				loadout.consumablesLoadoutString = loadoutPlaylistCheckConsumables
				array<string> consumablesInLoadout = ParseConsumableLoadoutText( loadoutPlaylistCheckConsumables, false )
				foreach( consumable in consumablesInLoadout )
				{
					if ( SURVIVAL_Loot_IsRefValid( consumable ) )
					{
						// Make sure this consumable is not disabled through playlist vars before adding it to the loadout
						if ( !SURVIVAL_Loot_IsRefDisabled( consumable ) )
							loadout.consumablesInLoadout.append( consumable )
					}
				}
				didOverrideConsumables = true
			}

			// Check if there is a playlist override for the equipment in this loadout
			string loadoutPlaylistCheckEquipment = GetCurrentPlaylistVarString( "loadoutselection_dt_override_loadout_" + name + "_equipment", "" )
			if ( loadoutPlaylistCheckEquipment != "" )
			{
				array<string> equipmentInLoadout = ParseEquipmentLoadoutText( loadoutPlaylistCheckEquipment, false, displayIgnoredItems )
				foreach( equipment in equipmentInLoadout )
				{
					if ( SURVIVAL_Loot_IsRefValid( equipment ) )
					{
						// Make sure this equipment is not disabled through playlist vars before adding it to the loadout
						if ( !SURVIVAL_Loot_IsRefDisabled( equipment ) )
							loadout.equipmentInLoadout.append( equipment )
					}
				}
				didOverrideEquipment = true
			}

			if ( startingRow == -1 )
				continue

			// If we used overrides for everything in this loadout, don't bother parsing through the table for it
			if ( didOverrideWeapons && didOverrideConsumables && didOverrideEquipment )
				continue

			// If we already disabled a weapon, remove this loadout and try the next one ( can't have a loadout with just 1 or 0 weapons)
			if ( didDisableWeapon )
			{
				loadoutsToDisable.append( name )
				continue
			}

			// Populate loadout items
			int currentRow = startingRow
			while ( ( currentRow < numRows && GetDataTableString( distributionTable, currentRow, GetDataTableColumnByName( distributionTable, "loadout" ) ) == "" ) || currentRow == startingRow )
			{
				string loadoutItem = GetDataTableString( distributionTable, currentRow, GetDataTableColumnByName( distributionTable, "contents" ) )
				if ( loadoutItem == "" || !SURVIVAL_Loot_IsRefValid( loadoutItem ) )
				{
					currentRow++
					continue
				}

				LootData data = SURVIVAL_Loot_GetLootDataByRef( loadoutItem )

				// Based on the item type, put them in the correct lists
				if ( !didOverrideWeapons && data.lootType == eLootType.MAINWEAPON )
				{
					// Make sure this weapon is not disabled through playlist vars before adding it to the loadout
					if ( !SURVIVAL_Loot_IsRefDisabled( data.baseWeapon ) )
					{
						loadout.weaponsInLoadout.append( loadoutItem )

						if ( loadout.weaponLoadoutString == "" )
						{
							loadout.weaponLoadoutString = loadoutItem
						}
						else
						{
							loadout.weaponLoadoutString += " " + loadoutItem
						}
					}
					else
					{
						didDisableWeapon = true
					}
				}
				else if ( !didOverrideEquipment && ( data.lootType == eLootType.ARMOR || data.lootType == eLootType.BACKPACK || data.lootType == eLootType.INCAPSHIELD || data.lootType == eLootType.HELMET ) )
				{
					// Make sure this equipment is not disabled through playlist vars before adding it to the loadout
					if ( !SURVIVAL_Loot_IsRefDisabled( data.ref ) )
						loadout.equipmentInLoadout.append( loadoutItem )
				}
				else if ( !didOverrideConsumables )
				{
					// Make sure this consumable is not disabled through playlist vars before adding it to the loadout
					if ( !SURVIVAL_Loot_IsRefDisabled( data.ref ) )
					{
						loadout.consumablesInLoadout.append( loadoutItem )
						if ( loadout.consumablesLoadoutString == "" )
						{
							loadout.consumablesLoadoutString = loadoutItem
						}
						else
						{
							loadout.consumablesLoadoutString += " " + loadoutItem
						}
					}
				}
				// If we disabled a weapon, remove this loadout and try the next one ( can't have a loadout with just 1 or 0 weapons)
				if ( didDisableWeapon )
				{
					loadoutsToDisable.append( name )
					break
				}

				currentRow++
			}
		}
	}

	// Send any loadouts that contain disabled weapons to have them removed from loadout categories
	LoadoutSelection_RemoveLoadoutsWithDisabledWeaponsFromCategory( loadoutsToDisable )
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Remove loadouts that contain a weapon disabled through playlist vars since we don't want any loadouts with missing weapons
void function LoadoutSelection_RemoveLoadoutsWithDisabledWeaponsFromCategory( array<string> loadoutsToDisable )
{
	// Remove the disabled loadouts
	array< LoadoutSelectionCategory > loadoutCategories = clone file.loadoutCategories
	foreach ( name in loadoutsToDisable )
	{
		foreach ( loadoutCategory in loadoutCategories )
		{
			int loadoutCategoryIndex = loadoutCategory.index
			if ( name in file.loadoutCategories[ loadoutCategoryIndex ].loadoutContentsByNameTable )
				delete file.loadoutCategories[ loadoutCategoryIndex ].loadoutContentsByNameTable[ name ]

			if ( file.loadoutCategories[ loadoutCategoryIndex ].loadoutContentNames.contains( name ) )
				file.loadoutCategories[ loadoutCategoryIndex ].loadoutContentNames.removebyvalue( name )

			if ( file.loadoutCategories[ loadoutCategoryIndex ].activeLoadoutName == name )
				file.loadoutCategories[ loadoutCategoryIndex ].activeLoadoutName = ""
		}
	}

	// Check if any categories are now fully empty
	array< LoadoutSelectionCategory > emptyLoadoutCategories
	foreach ( loadoutCategory in file.loadoutCategories )
	{
		if ( loadoutCategory.loadoutContentNames.len() == 0 )
			emptyLoadoutCategories.append( loadoutCategory )
	}

	// Remove empty loadout categories
	if ( emptyLoadoutCategories.len() > 0 )
	{
		file.loadoutSlotIndexToCategoryDataTable.clear()

		foreach ( loadoutCategory in emptyLoadoutCategories )
		{
			if ( file.loadoutCategories.contains( loadoutCategory ) )
				file.loadoutCategories.removebyvalue( loadoutCategory )
		}

		// Reset the indexes for categories since we removed some
		for ( int index = 0; index < file.loadoutCategories.len(); index++ )
		{
			file.loadoutCategories[ index ].index = index
			file.loadoutSlotIndexToCategoryDataTable[ index ] <- file.loadoutCategories[ index ]
		}
	}
}
#endif // CLIENT || SERVER

// Parse the weapon data datatable to set what weapon upgrades and scopes will be on the weapons at different tiers
void function LoadoutSelection_InitWeaponData()
{
	var dataTable    	= GetDataTable( file.weaponDataDataTable )
	int numRows      	= GetDataTableRowCount( dataTable )
	int col_supportedAttachmentOverride = GetDataTableColumnByName( dataTable, "supportedAttachmentOverride" )
	int col_weaponRef   = GetDataTableColumnByName( dataTable, "weaponRef" )

	#if CLIENT || SERVER
		int col_attachments = GetDataTableColumnByName( dataTable, "attachmentOverride" )
		int col_optics      = GetDataTableColumnByName( dataTable, "availableOptics" )
		int col_defaultOptic= GetDataTableColumnByName( dataTable, "defaultOptic" )
	#endif // CLIENT || SERVER

		for( int i = 0; i < numRows; ++i )
		{
			string weaponRef = strip( GetDataTableString( dataTable, i, col_weaponRef ) ).tolower()

			if ( weaponRef != "" )
			{
				#if CLIENT || SERVER
					if ( !( weaponRef in file.weaponUpgrades ) )
					{
						string upgrades = GetDataTableString( dataTable, i, col_attachments )
						upgrades = GetCurrentPlaylistVarString( "loadoutselection_" + weaponRef + "_attachment_override", upgrades )
						file.weaponUpgrades[ weaponRef ] <- split( upgrades, WHITESPACE_CHARACTERS )
						if( file.weaponUpgrades[ weaponRef ].len() == 0 )
							file.weaponUpgrades[ weaponRef ] = SURVIVAL_Weapon_GetBaseMods( weaponRef )

						string defaultOptic = GetDataTableString( dataTable, i, col_defaultOptic )
						if( defaultOptic != "" )
							ReplaceOpticInMods( file.weaponUpgrades[ weaponRef ], defaultOptic )
					}
					else
					{
						Warning( "LoadoutSelection_InitWeaponData - weapon upgrades for %s already exists!", weaponRef )
					}

					if ( !( weaponRef in file.weaponOptics ) )
					{
						string optics = GetDataTableString( dataTable, i, col_optics )
						optics = GetCurrentPlaylistVarString( "loadoutselection_" + weaponRef + "_optic_override", optics )
						file.weaponOptics[ weaponRef ] <- split( optics, WHITESPACE_CHARACTERS )
					}
					else
					{
						Warning( "LoadoutSelection_InitWeaponData - available optics for %s already exists!", weaponRef )
					}
				#endif // CLIENT || SERVER

				// Override the supported weapon attachments
				string supportedAttachmentOverrides = GetDataTableString( dataTable, i, col_supportedAttachmentOverride )
				supportedAttachmentOverrides = GetCurrentPlaylistVarString( "loadoutselection_" + weaponRef + "_supported_attachment_override", supportedAttachmentOverrides )
				if ( supportedAttachmentOverrides != "" )
				{
					#if DEVELOPER
						printt( "LOADOUT SELECTION: Overriding supported attachments for " + weaponRef )
					#endif // DEVELOPER
					LoadoutSelection_OverrideSupportedWeaponAttachmentsForWeaponRef( weaponRef, supportedAttachmentOverrides )
				}

			}
			else
			{
				Warning( "LoadoutSelection_InitWeaponData - Error reading LoadoutSelection_weapon_upgrades datatable. Expected weaponRef!" )
			}
		}
}

// Override the supported attachments for a weapon.
// This needs to be done when we override an attachment for a weapon in order for the attachment to appear properly in places where the weapon attachments are displayed.
// Example: A Purple Tier Eva-8 normally supports the Double Tap Hop-Up but a Blue Tier one does not.
// If we override the Blue Tier Eva-8 to have the Double Tap Hop-Up it will have it but the Hop-Up will not appear on the weapon HUD or in the Loadout Selection Menu on the Weapon icon
// So we override the Blue Tier Eva-8 here to support the Hop-Up so it displays properly
void function LoadoutSelection_OverrideSupportedWeaponAttachmentsForWeaponRef( string weaponRef, string supportedAttachmentsString )
{
	table< string, LootData > data = SURVIVAL_Loot_GetLootDataTable()

	if ( weaponRef in data )
	{
		array<string> supportedAttachments = SURVIVAL_Loot_GetSortedStringArrayFromSupportedAttachmentsString( supportedAttachmentsString )
		data[ weaponRef ].supportedAttachments = supportedAttachments
	}
	else
	{
		Warning( "LoadoutSelection_OverrideSupportedWeaponAttachmentsForWeaponRef - weaponRef %s not found in the LootData table, failed to override supported attachments", weaponRef )
	}
}

#if CLIENT || SERVER
// Generate a LoadoutSelectionItem from the survival loot data table
LoadoutSelectionItem function LoadoutSelection_GetLoadoutSelectionItemDataFromRef( string ref )
{
	table<string, LootData> allLootData = SURVIVAL_Loot_GetLootDataTable()
	LoadoutSelectionItem item
	if ( !( ref in allLootData ) )
		return item

	LootData data = allLootData[ ref ]
	item.ref = ref

	if( data.lootType == eLootType.MAINWEAPON )
	{
		item.name = GetWeaponInfoFileKeyField_GlobalString( data.baseWeapon, "shortprintname" )
	}
	else
	{
		item.name = ref
	}

	item.desc = data.desc
	item.icon = data.hudIcon
	return item
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Convert the exclusivity string from the datatable in enum form
int function LoadoutSelection_GetExclusivityStyleEnumFromString( string input )
{
	int exclusivityStyle
	bool exclusivityStyleFound = false

	for ( int i = 0; i < eLoadoutSelectionExclusivity._count; i++ )
	{
		string enumStyle = GetEnumString( "eLoadoutSelectionExclusivity", i )
		if ( enumStyle == input )
		{
			exclusivityStyle = i
			exclusivityStyleFound = true
			break
		}
	}

	Assert( exclusivityStyleFound, "Loadout Selection System Exclusivity Style '" + input + "' is not a specified enumerator." )

	return exclusivityStyle
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Get the rotation style string from the datatable in enum form
int function LoadoutSelection_GetRotationStyleEnumFromString( string input )
{
	int rotationStyle
	bool rotationStyleFound = false

	for ( int i = 0; i < eLoadoutSelectionRotationStyle._count; i++ )
	{
		string enumStyle = GetEnumString( "eLoadoutSelectionRotationStyle", i )
		if ( enumStyle == input )
		{
			rotationStyle = i
			rotationStyleFound = true
			break
		}
	}
	Assert( rotationStyleFound, "Loadout Selection System Rotation Pattern '" + input + "' is not a specified enumerator." )

	return rotationStyle
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Get the loadout slot type string from the datatable in enum form
int function LoadoutSelection_GetLoadoutSlotTypeEnumFromString( string input )
{
	int slotType
	bool slotTypeFound = false

	for ( int i = 0; i < eLoadoutSelectionSlotType._count; i++ )
	{
		string enumStyle = GetEnumString( "eLoadoutSelectionSlotType", i )
		if ( enumStyle == input )
		{
			slotType = i
			slotTypeFound = true
			break
		}
	}
	Assert( slotTypeFound, "Loadout Selection System Loadout Slot Type '" + input + "' is not a specified enumerator." )

	return slotType
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Get an array of attachment strings that are available for this weapon ref
array<string> function LoadoutSelection_GetAvailableWeaponUpgradesForWeaponRef( string weaponRef )
{
	array<string> availableUpgrades = []

	if ( weaponRef in file.weaponUpgrades )
		availableUpgrades = file.weaponUpgrades[ weaponRef ]

	return availableUpgrades
}
#endif // CLIENT || SERVER

#if SERVER
// Add the items from the loadouts to a disabled loot list so they are not spawned in the loot pool as well
void function LoadoutSelection_HandleItemExclusivity()
{
	if ( !IsUsingLoadoutSelectionSystem() )
		return

	string tieredItemRef
	array<string> itemsToDisable
	// Survival disables the base weapon but we want to also disable all tiers of the weapon for airdrops etc
	if ( GetCurrentPlaylistVarBool( "loadoutselection_disable_all_tiers_for_disabledweapons", false ) )
	{
		array<string> weaponsToDisable = split( GetCurrentPlaylistVarString( "global_disabled_loot", "" ).tolower(), WHITESPACE_CHARACTERS )

		foreach ( weapon in weaponsToDisable )
		{
			for ( int weaponTier = 1; weaponTier < LOADOUTSELECTION_WEAPON_SET_STRINGS_FOR_TIER.len(); weaponTier++ )
			{
				tieredItemRef = weapon + LoadoutSelection_GetWeaponSetStringForTier( weaponTier )
				if ( !itemsToDisable.contains( tieredItemRef ) )
					itemsToDisable.append( tieredItemRef )
			}
		}
	}

	string activeLoadoutName
	foreach ( item in file.loadoutCategories )
	{
		#if DEVELOPER
			printt( "LOADOUT SELECTION: Getting datatable for loadout " + item.loadoutSlot )
		#endif // DEVELOPER

		// Only disable loot items for loadouts actually in use
		activeLoadoutName = item.activeLoadoutName
		if ( !( activeLoadoutName in item.loadoutContentsByNameTable ) )
			continue

		LoadoutSelectionLoadoutContents loadout = item.loadoutContentsByNameTable[ activeLoadoutName ]
		// Handle Weapon Exclusivity
		if ( loadout.weaponExclusivityStyle == eLoadoutSelectionExclusivity.RARITY ) // If disabled based on rarity, disable the specific weapon
		{
			foreach( weapon in loadout.weaponsInLoadout )
			{
				if ( !itemsToDisable.contains( weapon ) )
					itemsToDisable.append( weapon )
			}
		}
		else if ( loadout.weaponExclusivityStyle == eLoadoutSelectionExclusivity.ALL ) // If all variations of this weapon are meant to be disabled, disable the base weapon
		{
			foreach( weapon in loadout.weaponsInLoadout )
			{
				for ( int weaponTier = 1; weaponTier < LOADOUTSELECTION_WEAPON_SET_STRINGS_FOR_TIER.len(); weaponTier++ )
				{
					tieredItemRef = GetBaseWeaponRef( weapon ) + LoadoutSelection_GetWeaponSetStringForTier( weaponTier )
					if ( !itemsToDisable.contains( tieredItemRef ) )
						itemsToDisable.append( tieredItemRef )
				}
			}
		}
		// if eLoadoutSelectionExclusivity.NONE, we do nothing

		// Handle Consumable Exclusivity, there is no consumable rarity so just disable them
		Assert( loadout.consumableExclusivityStyle != eLoadoutSelectionExclusivity.RARITY, "LoadoutSelection_HandleItemExclusivity consumables exclusivity is set to RARITY, there is no concept of loot tiers for consumables, please use ALL or NONE")
		if ( loadout.consumableExclusivityStyle == eLoadoutSelectionExclusivity.ALL )
		{
			foreach( consumable in loadout.consumablesInLoadout )
			{
				if ( !itemsToDisable.contains( consumable ) )
					itemsToDisable.append( consumable )
			}
		}
		// if eLoadoutSelectionExclusivity.NONE, we do nothing

		// Handle Equipment Exclusivity
		Assert( loadout.equipmentExclusivityStyle != eLoadoutSelectionExclusivity.ALL, "LoadoutSelection_HandleItemExclusivity equipment exclusivity is set to ALL, we currently only support RARITY or NONE, talk to David Swieczko if you need ALL functionality")
		if ( loadout.equipmentExclusivityStyle == eLoadoutSelectionExclusivity.RARITY ) // Disable the specific rarity of equipment
		{
			foreach( equipment in loadout.equipmentInLoadout )
			{
				if ( !itemsToDisable.contains( equipment ) )
					itemsToDisable.append( equipment )
			}
		}/*
		else if ( loadout.equipmentExclusivityStyle == eLoadoutSelectionExclusivity.ALL ) // Disable all tiers of this equipment
		{
			foreach( equipment in loadout.equipmentInLoadout )
			{
				if ( !itemsToDisable.contains( equipment ) )
					itemsToDisable.append( GetBaseWeaponRef( equipment ) ) // This is totally wrong, need to loop over all the tiers of equipment and add them to the disabled list
			}
		}
		*/
		// if eLoadoutSelectionExclusivity.NONE, we do nothing

	}

	// Take all the items we want to disable and set them to be disabled
	foreach( item in itemsToDisable )
	{
		#if DEVELOPER
			printt( "LOADOUT SELECTION: Adding the following to the Disabled Loot List because it is available in a Loadout: " + item )
		#endif // DEVELOPER

		SURVIVAL_Loot_AddDisabledRef( item )
	}
}
#endif


/*
  _____   ____  _____  _    _ _            _______ ______   _      ____          _____   ____  _    _ _______ _____
 |  __ \ / __ \|  __ \| |  | | |        /\|__   __|  ____| | |    / __ \   /\   |  __ \ / __ \| |  | |__   __/ ____|
 | |__) | |  | | |__) | |  | | |       /  \  | |  | |__    | |   | |  | | /  \  | |  | | |  | | |  | |  | | | (___
 |  ___/| |  | |  ___/| |  | | |      / /\ \ | |  |  __|   | |   | |  | |/ /\ \ | |  | | |  | | |  | |  | |  \___ \
 | |    | |__| | |    | |__| | |____ / ____ \| |  | |____  | |___| |__| / ____ \| |__| | |__| | |__| |  | |  ____) |
 |_|     \____/|_|     \____/|______/_/    \_\_|  |______| |______\____/_/    \_\_____/ \____/ \____/   |_| |_____/

 Populate Loadouts
*/

#if CLIENT || SERVER
// Pick a loadout for the specified loadout slot
LoadoutSelectionLoadoutContents function LoadoutSelection_GenerateLoadoutByLoadoutSlot( int loadoutIndex )
{
	Assert( loadoutIndex in file.loadoutSlotIndexToCategoryDataTable, "Running LoadoutSelection_GenerateLoadoutByLoadoutSlot and " + loadoutIndex + " is not a key for the file.loadoutSlotIndexToCategoryDataTable table" )
	LoadoutSelectionCategory loadoutCategory = file.loadoutSlotIndexToCategoryDataTable[ loadoutIndex ]
	loadoutCategory.activeLoadoutName = LoadoutSelection_GetActiveLoadoutForCategory( loadoutCategory )

	LoadoutSelectionLoadoutContents loadout
	loadout = loadoutCategory.loadoutContentsByNameTable[ loadoutCategory.activeLoadoutName ]
	loadout.weaponLoadoutSelectionItemsInLoadout.clear()
	loadout.consumableLoadoutSelectionItemsInLoadout.clear()

	foreach( weapon in loadout.weaponsInLoadout )
	{
		LoadoutSelectionItem weaponItem = LoadoutSelection_GetLoadoutSelectionItemDataFromRef( weapon )
		loadout.weaponLoadoutSelectionItemsInLoadout.append( weaponItem )
	}

	foreach( consumable in loadout.consumablesInLoadout )
	{
		if ( SURVIVAL_Loot_IsRefValid( consumable ) )
		{
			LootData consumableData = SURVIVAL_Loot_GetLootDataByRef( consumable )
			if ( consumableData.lootType == eLootType.HEALTH ) // Don't display health consumables
				continue
			LoadoutSelectionItem consumableItem = LoadoutSelection_GetLoadoutSelectionItemDataFromRef( consumable )
			loadout.consumableLoadoutSelectionItemsInLoadout.append( consumableItem )
		}
	}

	return loadout
}

// Populate loadouts based on the datatables and update menu text
void function LoadoutSelection_PopulateLoadouts()
{
	// There are a few places that could trigger this function, want to make sure it only runs once on Server and once on Client
	if ( file.areLoadoutsPopulated )
		return

	#if CLIENT
		// Make sure loadout counts on the Client are set to default values
		file.maxLoadoutCountRegular = 0




	#endif // CLIENT

	int loadoutIndex = 0
	bool didLoadoutCategoryFailToPopulate = false

	file.loadoutSlotIndexToWeaponLoadoutTable.clear()
#if SERVER
	file.loadoutSlotIndexToConsumableLoadoutTable.clear()
	file.loadoutSlotIndexToEquipmentLoadoutTable.clear()
#endif // SERVER
	file.loadoutSlotIndexToHeaderTable.clear()
	file.loadoutSlotIndexToLoadoutTypeTable.clear()
	file.loadoutSlotIndexToWeaponCountTable.clear()

	foreach ( loadoutCategory in file.loadoutCategories )
	{
		loadoutIndex = loadoutCategory.index
		// Store which Weapons will be given for this loadout
		LoadoutSelectionLoadoutContents loadout = LoadoutSelection_GenerateLoadoutByLoadoutSlot( loadoutIndex )
		file.loadoutSlotIndexToWeaponLoadoutTable[ loadoutIndex ] <- ParseWeaponLoadoutText( loadout.weaponLoadoutString, false )

		#if SERVER
			// Store which consumables will be given for this loadout
			file.loadoutSlotIndexToConsumableLoadoutTable[ loadoutIndex ] <- loadout.consumablesInLoadout

			// Store what equipment will be given for this loadout
			file.loadoutSlotIndexToEquipmentLoadoutTable[ loadoutIndex ] <- loadout.equipmentInLoadout
		#endif // SERVER

		// Store the header text for this loadout
		file.loadoutSlotIndexToHeaderTable[ loadoutIndex ] <- loadout.loadoutNameText

		// Store the slot type for this loadout
		file.loadoutSlotIndexToLoadoutTypeTable[ loadoutIndex ] <- loadoutCategory.loadoutSlotType

		// Check if the loadout ended up with items, this prevents us from saying loadouts got populated in a situation where they actually didn't
		if ( loadout.weaponLoadoutSelectionItemsInLoadout.len() <= 0 )
			didLoadoutCategoryFailToPopulate = true

		file.loadoutSlotIndexToWeaponCountTable[ loadoutIndex ] <- loadout.weaponLoadoutSelectionItemsInLoadout.len()

		#if CLIENT
			// Store Loadout Counts on the Client to be used by the UI
			switch( loadoutCategory.loadoutSlotType )
			{
				case  eLoadoutSelectionSlotType.REGULAR:
						file.maxLoadoutCountRegular++
					break








				default:
					break
			}
		#endif // CLIENT
	}

	if ( !didLoadoutCategoryFailToPopulate )
		file.areLoadoutsPopulated = true
	#if CLIENT
		// Update the loadout info on the UI
		LoadoutSelection_RefreshAllUILoadoutInfo()
	#endif // CLIENT
}

// Get the weapon loadout by the slot index of the loadout
WeaponLoadout function LoadoutSelection_GetWeaponLoadoutByLoadoutSlotIndex( int loadoutIndex )
{
	WeaponLoadout loadout
	if ( loadoutIndex in file.loadoutSlotIndexToWeaponLoadoutTable )
	loadout = file.loadoutSlotIndexToWeaponLoadoutTable[ loadoutIndex ]

	return loadout
}

// Get the appropriate weapon set for the tier ( used to define what loot is spawned)
string function LoadoutSelection_GetWeaponSetStringForTier( int tier )
{
	return LOADOUTSELECTION_WEAPON_SET_STRINGS_FOR_TIER[ tier ]
}

// Get the weapon ref for the passed in loadout and weapon index
string function LoadoutSelection_GetWeaponRefByIndex( int loadoutIndex, int weaponIndex )
{
	WeaponLoadout weaponLoadoutData = LoadoutSelection_GetWeaponLoadoutByLoadoutSlotIndex( loadoutIndex )
	array<string> weaponRefs = weaponLoadoutData.weaponRefs

	// In Dev Assert if there is no valid weapon ref, in retail return a blank ref so we just don't have a weapon but the game won't crash
	Assert( weaponRefs.len() > weaponIndex, "LoadoutSelection_GetWeaponRefByIndex the weapon index ( " + weaponIndex + " ) passed in is greater than the number of weapon refs " + weaponRefs.len() + " in slot " + loadoutIndex )

	if ( weaponRefs.len() <= weaponIndex )
		return ""

	return weaponRefs[weaponIndex]
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
// Get the loot tier of the weapon. Should match locked set, crate, or 0 for non locked set weapons
int function LoadoutSelection_GetWeaponLootTierForMenu( LootData data )
{
	bool isLockedSet = data.baseMods.contains( "crate" ) || SURVIVAL_Weapon_IsAttachmentLocked( data.ref ) || data.baseMods.contains( "hopup_april_fools_light" ) || data.baseMods.contains( "hopup_april_fools_heavy" ) || data.baseMods.contains( "hopup_april_fools_sniper" ) || data.baseMods.contains( "hopup_april_fools_energy" )
	return isLockedSet ? data.tier : 0
}

bool function ModeUsesLoadoutWeapons()
{
	if( IsUsingLoadoutSelectionSystem() )
		return true


	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_BATTLE_RUSH ) )
		return true



	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) )
		return true


	return false
}
#endif // CLIENT || SERVER

#if SERVER
// Set which loadout is selected by the player on the Server
void function LoadoutSelection_SetSelectedLoadoutSlotIndex_Server( entity player, int loadoutIndex )
{
	if ( !IsValid( player ) || loadoutIndex < 0 || loadoutIndex >= file.loadoutCategories.len() )
		return

	file.playerToSelectedLoadoutTable[player] <- loadoutIndex
}

// Get which loadout is selected for this player on the Server
int function LoadoutSelection_GetSelectedLoadoutSlotIndex_Server( entity player )
{
	int index = 0

	if ( IsValid( player ) )
	{
		if ( !player.IsBot() )
		{
			if ( player in file.playerToSelectedLoadoutTable )
				index = file.playerToSelectedLoadoutTable[player]
		}
		else // Give AI random loadouts
		{
			if ( file.loadoutCategories.len() > 0 )
				index = RandomIntRange( 0, file.loadoutCategories.len() )
		}
	}

	return index
}
#endif // SERVER

#if CLIENT || UI
// Get which loadout is selected for this player on the Client or UI
int function LoadoutSelection_GetSelectedLoadoutSlotIndex_CL_UI()
{
	return file.playerSelectedLoadout
}
#endif // CLIENT || UI

#if SERVER
// Get the equipment loadout by the slot index of the loadout
array< string > function LoadoutSelection_GetEquipmentLoadoutByLoadoutSlotIndex( int loadoutIndex )
{
	array< string > loadout = []
	if ( loadoutIndex in file.loadoutSlotIndexToEquipmentLoadoutTable )
		loadout = file.loadoutSlotIndexToEquipmentLoadoutTable[ loadoutIndex ]

	return loadout
}
#endif // SERVER

#if SERVER
// Get the consumable loadout by the slot index of the loadout
array< string > function LoadoutSelection_GetConsumableLoadoutByLoadoutSlotIndex( int loadoutIndex )
{
	array< string > loadout = []
	if ( loadoutIndex in file.loadoutSlotIndexToConsumableLoadoutTable )
		loadout = file.loadoutSlotIndexToConsumableLoadoutTable[ loadoutIndex ]

	return loadout
}
#endif // SERVER

#if SERVER
// Set time since the event started ( time difference between these loadout rotations starting ( usually season start ) and the start of this match )
// This value is used to determine which rotation index to use in loadout categories that are determined by this time value
// The value has to be consistent between server and client to prevent issues where there is a mismatch between the players rotation on the Client and the rotation on the Server ( could happen if the player joins late for example )
void function LoadoutSelection_SetUnixTimeSinceEventStarted()
{
	int loadoutIndex = RandomInt( file.maxLoadoutsPerCategory )
	SetGlobalNetIntSafe( NETVAR_LOADOUT_CURRENT_MANUAL_ROTATION_INDEX_NAME, loadoutIndex )
	string unixTimeEventStartString = GetCurrentPlaylistVarString( "loadoutselection_rotation_start", "2021-07-21 10:00:00 -08:00" )
	int unixTimeNow = GetUnixTimestamp()

	int ornull unixTimeEventStart = DateTimeStringToUnixTimestamp( unixTimeEventStartString )
	Assert( unixTimeEventStart != null, format( "Bad format in playlist for setting 'loadoutselection_rotation_start': '%s'", unixTimeEventStartString ) )
	expect int( unixTimeEventStart )

	int unixTimeSinceEventStarted = ( unixTimeNow - unixTimeEventStart )
	SetGlobalNetIntSafe( NETVAR_TIME_SINCE_EVENT_STARTED_NAME, unixTimeSinceEventStarted )
}
#endif // SERVER

#if SERVER
void function LoadoutSelection_ShuffleLoadoutRotation()
{
	if ( file.maxLoadoutsPerCategory <= 1 )
		return

	array<int> loadoutIndices
	for (int i = 0; i < file.maxLoadoutsPerCategory; i++ )
	{
		loadoutIndices.append(i)
	}
	loadoutIndices.remove(GetGlobalNetIntSafe( NETVAR_LOADOUT_CURRENT_MANUAL_ROTATION_INDEX_NAME ))
	int selectedLoadoutIndex = loadoutIndices.getrandom()
	SetGlobalNetIntSafe( NETVAR_LOADOUT_CURRENT_MANUAL_ROTATION_INDEX_NAME, selectedLoadoutIndex )
	LoadoutSelection_RepopulateLoadouts()
	foreach( player in GetPlayerArray() )
	{
		if ( IsValid( player ) )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_LoadoutSelection_RepopulateLoadouts" )
		}
	}
}
#endif // SERVER

#if SERVER || CLIENT
void function LoadoutSelection_RepopulateLoadouts()
{
	file.areLoadoutsPopulated = false
	LoadoutSelection_PopulateLoadouts()
}
#endif // SERVER || CLIENT

#if CLIENT
void function ServerCallback_LoadoutSelection_RepopulateLoadouts()
{
	LoadoutSelection_RepopulateLoadouts()
}
#endif // CLIENT

// Get a count of weapons in the loadout by its index
int function LoadoutSelection_GetWeaponCountByLoadoutIndex( int loadoutIndex )
{
	int weaponCount = 0
	if ( loadoutIndex in file.loadoutSlotIndexToWeaponCountTable )
		weaponCount = file.loadoutSlotIndexToWeaponCountTable[ loadoutIndex ]

	return weaponCount
}

#if SERVER || CLIENT
// Get a loadout using the loadoutCategory data
string function LoadoutSelection_GetActiveLoadoutForCategory( LoadoutSelectionCategory loadoutCategory )
{
	int loadoutRotation = loadoutCategory.rotationStyle
	int rotationIndex

	if ( loadoutRotation == eLoadoutSelectionRotationStyle.MANUAL )
	{
		int indexToUse = GetGlobalNetIntSafe( NETVAR_LOADOUT_CURRENT_MANUAL_ROTATION_INDEX_NAME )
		while (indexToUse >= loadoutCategory.loadoutContentNames.len())
			indexToUse -= loadoutCategory.loadoutContentNames.len()

		if ( indexToUse < 0 )
			indexToUse = 0

		if ( LoadoutSelection_ShouldAvoidDuplicateWeaponsInLoadoutRotation() )
			indexToUse = LoadoutSelection_GetLoadoutForCategoryWithoutDupeWeapons( indexToUse, loadoutCategory )

		#if DEVELOPER
			printt( "LOADOUT SELECTION: loadout rotation is set to manual, using loadout index: " + indexToUse + " for category: " + loadoutCategory.loadoutSlot )
		#endif // DEVELOPER

		return loadoutCategory.loadoutContentNames[ indexToUse ]
	}

	//check categories that aren't based on timestamps to short circuit
	if ( loadoutRotation == eLoadoutSelectionRotationStyle.PERMANENT )
	{
		Assert( loadoutCategory.loadoutContentsByNameTable.len() != 0, "LOADOUT SELECTION: Loadout Contents list in loadout slot " + loadoutCategory.loadoutSlot + " is empty" )
		// Used to just return loadoutCategory.loadoutContentNames.top() so get the last index
		rotationIndex = loadoutCategory.loadoutContentNames.len() - 1

		// If this category is in fact set to permanent there is likely only 1 loadout, if there are others see if we can get one without dupe weapons
		if ( loadoutCategory.loadoutContentNames.len() > 1 && LoadoutSelection_ShouldAvoidDuplicateWeaponsInLoadoutRotation() )
			rotationIndex = LoadoutSelection_GetLoadoutForCategoryWithoutDupeWeapons( rotationIndex, loadoutCategory )

		#if DEVELOPER
			printt( "LOADOUT SELECTION: loadout rotation is set to permanent, using loadout index: " + rotationIndex + " for category: " + loadoutCategory.loadoutSlot )
		#endif // DEVELOPER

		return loadoutCategory.loadoutContentNames[ rotationIndex ]
	}

	//remainder of categories are based on rotations
	int unixTimeSinceEventStarted = GetGlobalNetIntSafe( NETVAR_TIME_SINCE_EVENT_STARTED_NAME )
	int hourQuartersSinceEventStarted = int( floor( unixTimeSinceEventStarted / ( SECONDS_PER_HOUR * 0.25 ) ) )
	int hoursSinceEventStarted = int( floor( unixTimeSinceEventStarted / SECONDS_PER_HOUR ) )
	int daysSinceEventStarted =  int( floor( unixTimeSinceEventStarted / SECONDS_PER_DAY ) )
	int weeksSinceEventStarted = int( floor( unixTimeSinceEventStarted / SECONDS_PER_WEEK ) )

	int rotationRaw = 1
	if ( loadoutRotation == eLoadoutSelectionRotationStyle.WEEKLY )
	{
		rotationRaw = weeksSinceEventStarted
	}
	else if ( loadoutRotation == eLoadoutSelectionRotationStyle.DAILY )
	{
		rotationRaw = daysSinceEventStarted
	}
	else if ( loadoutRotation == eLoadoutSelectionRotationStyle.HOURLY )
	{
		rotationRaw = hoursSinceEventStarted
	}
	else if ( loadoutRotation == eLoadoutSelectionRotationStyle.GAME )
	{
		rotationRaw = hourQuartersSinceEventStarted
	}

	rotationIndex = abs( rotationRaw % ( loadoutCategory.loadoutContentNames.len() ) )

	// If we want the script to try and prevent duplicate weapons in loadouts check the rotation index to make sure we don't get dupes and get a different rotation if there would be dupes
	if ( LoadoutSelection_ShouldAvoidDuplicateWeaponsInLoadoutRotation() )
		rotationIndex = LoadoutSelection_GetLoadoutForCategoryWithoutDupeWeapons( rotationIndex, loadoutCategory )

	#if DEVELOPER
		printt( "LOADOUT SELECTION: loadouts using a rotation, loadout index: " + rotationIndex + " for category: " + loadoutCategory.loadoutSlot )
	#endif // DEVELOPER

	return loadoutCategory.loadoutContentNames[ rotationIndex ]
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
// Return a loadout rotation index that tries to avoid duplicate weapons
int function LoadoutSelection_GetLoadoutForCategoryWithoutDupeWeapons( int startingRotationIndex, LoadoutSelectionCategory loadoutCategory )
{
	int rotationIndex = startingRotationIndex
	// Make a list of weapons used by other active loadouts so we can try to avoid using a new loadout with the same weapons
	array < string > dupeWeapons
	string activeLoadoutNameToTest
	LoadoutSelectionLoadoutContents contentsToTest
	foreach ( category in file.loadoutCategories )
	{
		if ( category.activeLoadoutName != "" )
		{
			activeLoadoutNameToTest = category.activeLoadoutName
			if ( activeLoadoutNameToTest in category.loadoutContentsByNameTable )
			{
				contentsToTest = category.loadoutContentsByNameTable[ activeLoadoutNameToTest ]
				foreach ( weaponRef in contentsToTest.weaponsInLoadout )
				{
					string baseRef = GetBaseWeaponRef( weaponRef )
					if ( !dupeWeapons.contains( baseRef ) )
						dupeWeapons.append( baseRef )
				}
			}
		}
	}

	// Look through loadouts, starting at the starting loadout, until you find one without weapon dupes
	bool doesLoadoutContainDupes
	bool didFindValidLoadout = false
	for ( int index = startingRotationIndex; index < loadoutCategory.loadoutContentNames.len(); index++ )
	{
		doesLoadoutContainDupes = false
		activeLoadoutNameToTest = loadoutCategory.loadoutContentNames[ index ]
		if ( activeLoadoutNameToTest in loadoutCategory.loadoutContentsByNameTable )
		{
			contentsToTest  = loadoutCategory.loadoutContentsByNameTable[ activeLoadoutNameToTest ]
			foreach ( weaponRef in contentsToTest.weaponsInLoadout )
			{
				string baseRef = GetBaseWeaponRef( weaponRef )
				if ( dupeWeapons.contains( baseRef ) )
					doesLoadoutContainDupes = true
			}

			if ( !doesLoadoutContainDupes )
			{
				rotationIndex = index
				didFindValidLoadout = true
				break
			}
		}
	}

	// Found a valid loadout with no dupes, return it
	if ( didFindValidLoadout )
		return rotationIndex

	// Didn't find a loadout without dupe weapons but the starting loadout wasn't 0 so test for earlier loadouts
	if ( !didFindValidLoadout && startingRotationIndex != 0 )
	{
		for ( int index = 0; index < startingRotationIndex; index++ )
		{
			doesLoadoutContainDupes = false
			activeLoadoutNameToTest = loadoutCategory.loadoutContentNames[ index ]
			if ( activeLoadoutNameToTest in loadoutCategory.loadoutContentsByNameTable )
			{
				contentsToTest  = loadoutCategory.loadoutContentsByNameTable[ activeLoadoutNameToTest ]
				foreach ( weaponRef in contentsToTest.weaponsInLoadout )
				{
					string baseRef = GetBaseWeaponRef( weaponRef )
					if ( dupeWeapons.contains( baseRef ) )
						doesLoadoutContainDupes = true
				}

				if ( !doesLoadoutContainDupes )
				{
					rotationIndex = index
					didFindValidLoadout = true
					break
				}
			}
		}
	}

	// If we ended up with a non dupe loadout great it will return here, if not, too bad but dupe weapons can happen
	return rotationIndex
}
#endif // #if CLIENT || SERVER

#if SERVER
// Trigger a callback function when loadouts get populated or updated so the menus know to update the text
void function AddCallback_LoadoutSelection_OnLoadoutUpdated( void functionref( entity ) func )
{
	Assert( !file.callbacks_LoadoutSelection_OnLoadoutUpdated.contains( func ) )
	file.callbacks_LoadoutSelection_OnLoadoutUpdated.append( func )
}

// Trigger a callback function when the loadout menu is closed so the menus know to update the text
void function AddCallback_LoadoutSelection_OnLoadoutMenuClosed( void functionref( entity ) func )
{
	Assert( !file.callbacks_LoadoutSelection_OnLoadoutMenuClosed.contains( func ) )
	file.callbacks_LoadoutSelection_OnLoadoutMenuClosed.append( func )
}

// Trigger a callback function when a loadout has been selected from the loadout menu
void function AddCallback_LoadoutSelection_OnLoadoutSelected( void functionref( entity ) func )
{
	Assert( !file.callbacks_LoadoutSelection_OnLoadoutSelected.contains( func ) )
	file.callbacks_LoadoutSelection_OnLoadoutSelected.append( func )
}

// Use the stored player data to give players back their inventory on respawn
void function LoadoutSelection_GivePlayerInventoryAndLoadout( entity player, bool giveEquipmentOnly = false, bool giveWeaponsOnly = false, bool shouldReplaceOldWeaponsIfPresent = true, bool giveWeaponsInReverseOrder = true )
{
	if ( !IsValid( player ) )
		return

	int loadoutIndex = LoadoutSelection_GetSelectedLoadoutSlotIndex_Server( player )

	// Give Equipment
	if ( !giveWeaponsOnly )
		CharacterLoadouts_GiveEquipmentLoadoutToPlayer( player, LoadoutSelection_GetEquipmentLoadoutByLoadoutSlotIndex( loadoutIndex ) )

	if ( giveEquipmentOnly )
		return

	// Give Consumables
	CharacterLoadouts_GiveConsumableLoadoutToPlayer( player, LoadoutSelection_GetConsumableLoadoutByLoadoutSlotIndex( loadoutIndex ) )


	// In case the player already has weapons, destroy them first or exit out
	int activeWeaponSlot = SURVIVAL_GetActiveWeaponSlot( player )
	int secondaryWeaponSlot =  SURVIVAL_GetStowedWeaponSlot( player )
	entity activePrimaryWeapon = player.GetNormalWeapon( activeWeaponSlot )
	entity activeSecondaryWeapon = player.GetNormalWeapon( secondaryWeaponSlot )

	if ( IsValid( activePrimaryWeapon ) )
	{
		if ( shouldReplaceOldWeaponsIfPresent )
		{
			SURVIVAL_DropWeapon( player, activePrimaryWeapon, <0, 0, 0>, <0, 0, 0> )
			activePrimaryWeapon.Destroy()
		}
		else
		{
			return
		}

	}

	if ( IsValid( activeSecondaryWeapon ) )
	{
		if ( shouldReplaceOldWeaponsIfPresent )
		{
			SURVIVAL_DropWeapon( player, activeSecondaryWeapon, <0, 0, 0>, <0, 0, 0> )
			activeSecondaryWeapon.Destroy()
		}
		else
		{
			return
		}

	}

	// Give the player weapons. Set the preferred scope for each weapon and equip the primary weapon
	int numWeaponsInLoadout = LoadoutSelection_GetWeaponCountByLoadoutIndex( loadoutIndex )
	if ( !giveWeaponsInReverseOrder )
	{
		for ( int i = numWeaponsInLoadout - 1; i > -1; i-- )
		{
			LoadoutSelection_GivePlayerWeapon( player, loadoutIndex, i )
		}
	}
	else
	{
		for ( int i = 0; i < numWeaponsInLoadout; i++ )
		{
			LoadoutSelection_GivePlayerWeapon( player, loadoutIndex, i )
		}
	}

	player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_0 )

	LoadoutSelection_CheckForMidMatchLoadoutChange( player )
}

// Check if the player changed loadouts to update PIN data
void function LoadoutSelection_CheckForMidMatchLoadoutChange( entity player )
{
	if ( !IsValid( player ) )
		return

	int loadoutIndex = LoadoutSelection_GetSelectedLoadoutSlotIndex_Server( player )
	array< string > _classes_offered
	foreach( loadoutCategory in file.loadoutCategories )
	{
		LoadoutSelectionLoadoutContents loadoutContents = loadoutCategory.loadoutContentsByNameTable[ loadoutCategory.activeLoadoutName ]
		string weaponLoadoutText = loadoutContents.weaponLoadoutString
		string consumableLoadoutText = "" // loadoutContents.consumablesLoadoutString  Removed consumable text because the string gets too long, can update how it gets populated if we need it
		string loadoutHeaderText = loadoutContents.loadoutNameText
		_classes_offered.append( loadoutHeaderText + ": " + weaponLoadoutText + " " + consumableLoadoutText )
	}

	array< string > previousWeapons
	string currentLoadout = _classes_offered[ loadoutIndex ]
	if ( player in file.playerToLastUsedLoadoutTable )
	{
		if ( loadoutIndex != file.playerToLastUsedLoadoutTable[ player ] )
		{
			previousWeapons.append( _classes_offered[ file.playerToLastUsedLoadoutTable[ player ] ] )

			//PIN_PlayerWeaponLoadoutChange( player, _classes_offered, previousWeapons, currentLoadout, true )
			file.playerToLastUsedLoadoutTable[ player ] = loadoutIndex
		}
	}
	else
	{
		//PIN_PlayerWeaponLoadoutChange( player, _classes_offered, previousWeapons, currentLoadout, false )
		file.playerToLastUsedLoadoutTable[ player ] <- loadoutIndex
	}
}
#endif // SERVER

/*
  __  __ ______ _   _ _    _   _____ _   _ _______ ______ _____            _____ _______ _____ ____  _   _  _____
 |  \/  |  ____| \ | | |  | | |_   _| \ | |__   __|  ____|  __ \     /\   / ____|__   __|_   _/ __ \| \ | |/ ____|
 | \  / | |__  |  \| | |  | |   | | |  \| |  | |  | |__  | |__) |   /  \ | |       | |    | || |  | |  \| | (___
 | |\/| |  __| | . ` | |  | |   | | | . ` |  | |  |  __| |  _  /   / /\ \| |       | |    | || |  | | . ` |\___ \
 | |  | | |____| |\  | |__| |  _| |_| |\  |  | |  | |____| | \ \  / ____ \ |____   | |   _| || |__| | |\  |____) |
 |_|  |_|______|_| \_|\____/  |_____|_| \_|  |_|  |______|_|  \_\/_/    \_\_____|  |_|  |_____\____/|_| \_|_____/

// Menu Interactions
*/
#if SERVER
// Trigger callbacks letting scripts know that the loadout select menu has been closed
void function ClientCallback_LoadoutSelection_OnLoadoutSelectMenuClose( entity player )
{
		// Let any scripts that need to know when the menu has closed, that it has closed
		if ( IsValid( player ) )
		{
			foreach ( func in file.callbacks_LoadoutSelection_OnLoadoutMenuClosed )
				func( player )

			Signal( player, "LoadoutSelection_LoadoutSelectMenuClosed" )
		}
}

// Trigger callbacks letting scripts know that a loadout has been selected from the loadout select menu
void function ClientCallback_LoadoutSelection_OnLoadoutSelectMenuLoadoutSelected( entity player, int buttonIndex )
{
	if ( !IsValid( player ) || buttonIndex < 0 || buttonIndex >= file.loadoutCategories.len() )
		return

	LoadoutSelection_SetSelectedLoadoutSlotIndex_Server( player, buttonIndex )
	LoadoutSelection_UpdateLoadoutInfoForMenus( player )

	if ( IsValid( player ) )
	{
		// Let any scripts that need to know when the loadout has been selected, that it has been selected
		foreach ( func in file.callbacks_LoadoutSelection_OnLoadoutSelected )
			func( player )
	}
}

// Update the loadout info stored on the player UI for all loadouts and then refresh it on the menu
void function LoadoutSelection_UpdateLoadoutInfoForMenus( entity player )
{
	if ( !IsValid( player ) )
		return

	foreach ( loadoutCategory in file.loadoutCategories )
	{
		LoadoutSelectionLoadoutContents loadoutContents = LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex( loadoutCategory.index )
		string loadoutHeaderText = loadoutContents.loadoutNameText
		int weapon0ScopePref = -1
		int weapon1ScopePref = -1

		if ( player in loadoutContents.playerToWeapon0ScopePreferenceTable )
			weapon0ScopePref = loadoutContents.playerToWeapon0ScopePreferenceTable[ player ]

		if ( player in loadoutContents.playerToWeapon1ScopePreferenceTable )
			weapon1ScopePref = loadoutContents.playerToWeapon1ScopePreferenceTable[ player ]

		Remote_CallFunction_NonReplay( player, "ServerCallback_LoadoutSelection_UpdateLoadoutInfo", loadoutCategory.index, weapon0ScopePref, weapon1ScopePref )
	}

	Remote_CallFunction_NonReplay( player, "ServerCallback_LoadoutSelection_UpdateSelectedLoadoutInfo", LoadoutSelection_GetSelectedLoadoutSlotIndex_Server( player ) )
	Remote_CallFunction_NonReplay( player, "ServerCallback_LoadoutSelection_RefreshUILoadoutInfo" )

	// Let any scripts that need to know when the loadout gets updated, that it got updated
	foreach ( func in file.callbacks_LoadoutSelection_OnLoadoutUpdated )
	{
		func( player )
	}
}
#endif // SERVER


#if UI
// The Client triggers this function so the loadout info can be updated on the UI ( data was originally passed to the client through a server callback)
void function LoadoutSelection_UpdateLoadoutInfo_UI( int loadoutIndex, string loadoutHeaderText, int weaponCount, int loadoutType )
{
	file.loadoutSlotIndexToHeaderTable[ loadoutIndex ] <- loadoutHeaderText
	file.loadoutSlotIndexToWeaponCountTable[ loadoutIndex ] <- weaponCount
	file.loadoutSlotIndexToLoadoutTypeTable[ loadoutIndex ] <- loadoutType
}
#endif // UI

#if UI
// Set which loadout is selected by the player on the UI
void function LoadoutSelection_SetSelectedLoadoutSlotIndex_UI( int loadoutIndex )
{
	if ( loadoutIndex < 0 || loadoutIndex >= LOADOUTSELECTION_MAX_TOTAL_LOADOUT_SLOTS )
		return

	file.playerSelectedLoadout = loadoutIndex
}
#endif // UI

#if UI
int function LoadoutSelection_GetSelectedLoadoutSlotIndex_UI()
{
	return file.playerSelectedLoadout
}
#endif // UI

#if UI
// Set loadout count on the UI
void function LoadoutSelection_SetLoadoutCounts_UI( int loadoutType, int loadoutCount )
{
	switch( loadoutType )
	{
		case  eLoadoutSelectionSlotType.REGULAR:
			if ( loadoutCount >= 0 && loadoutCount <= LOADOUTSELECTION_MAX_LOADOUT_COUNT_REGULAR )
				file.maxLoadoutCountRegular = loadoutCount
			break










		default:
			break
	}
}
#endif // UI

#if UI
// Get loadout count on the UI
int function LoadoutSelection_GetLoadoutCounts_UI( int loadoutType )
{
	int loadoutCount = -1
	switch( loadoutType )
	{
		case  eLoadoutSelectionSlotType.REGULAR:
			loadoutCount = file.maxLoadoutCountRegular
			break








		default:
			break
	}
	return loadoutCount
}
#endif // UI

#if CLIENT || UI
// Get the localized text for the loadout name
string function LoadoutSelection_GetLocalizedLoadoutHeader( int loadoutSlotIndex )
{
	string header = ""

	if ( !( loadoutSlotIndex in file.loadoutSlotIndexToHeaderTable ) )
		return header

	return Localize( file.loadoutSlotIndexToHeaderTable[ loadoutSlotIndex ] )
}

// Get the loadout Slot type for the loadout ( determines where on the menu this loadout belongs)
int function LoadoutSelection_GetLoadoutSlotTypeForLoadoutIndex( int loadoutSlotIndex )
{
	int slotType = eLoadoutSelectionSlotType.INVALID

	if ( loadoutSlotIndex in file.loadoutSlotIndexToLoadoutTypeTable )
		slotType = file.loadoutSlotIndexToLoadoutTypeTable[ loadoutSlotIndex ]

	return slotType
}
#endif // CLIENT || UI

#if CLIENT
// The server passes updated information through this function so we can display up to date information on the Client and UI
void function ServerCallback_LoadoutSelection_UpdateLoadoutInfo( int loadoutIndex, int weapon0ScopePref, int weapon1ScopePref )
{
	LoadoutSelectionLoadoutContents	data = LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex( loadoutIndex )
	if ( weapon0ScopePref > -1 && weapon0ScopePref <= LOADOUTSELECTION_MAX_SCOPE_INDEX )
		data.weaponIndexToScopePreferenceTable[ 0 ] <- weapon0ScopePref

	if ( weapon1ScopePref > -1 && weapon1ScopePref <= LOADOUTSELECTION_MAX_SCOPE_INDEX )
		data.weaponIndexToScopePreferenceTable[ 1 ] <- weapon1ScopePref

	LoadoutSelection_RefreshAllUILoadoutInfo()
}
#endif // CLIENT

#if CLIENT
// Allow the server to trigger a refresh of the loadout info on the UI
void function ServerCallback_LoadoutSelection_RefreshUILoadoutInfo()
{
	LoadoutSelection_RefreshAllUILoadoutInfo()
}
#endif // CLIENT

#if CLIENT
// Run through and update loadout info on the UI from the stored info on the Client then tell the UI to refresh the loadout info.
// This is currently needed to address an issue where the loadouts don't refresh properly after a screen resolution change while on the spawn select screen.
void function LoadoutSelection_RefreshAllUILoadoutInfo()
{
	string loadoutHeaderText
	int weaponCount
	int loadoutType
	int loadoutIndex

	// Update loadout counts on the UI
	RunUIScript( "LoadoutSelection_SetLoadoutCounts_UI", eLoadoutSelectionSlotType.REGULAR, file.maxLoadoutCountRegular )





	foreach ( loadoutCategory in file.loadoutCategories )
	{
		loadoutHeaderText = ""
		weaponCount = -1
		loadoutType = eLoadoutSelectionSlotType.INVALID
		loadoutIndex = loadoutCategory.index

		if ( loadoutIndex in file.loadoutSlotIndexToHeaderTable )
		{
			loadoutHeaderText = file.loadoutSlotIndexToHeaderTable[ loadoutIndex ]
		}

		if ( loadoutIndex in file.loadoutSlotIndexToWeaponCountTable )
		{
			weaponCount = file.loadoutSlotIndexToWeaponCountTable[ loadoutIndex ]
		}

		if ( loadoutIndex in file.loadoutSlotIndexToLoadoutTypeTable )
		{
			loadoutType = file.loadoutSlotIndexToLoadoutTypeTable[ loadoutIndex ]
		}

		if ( loadoutType != eLoadoutSelectionSlotType.INVALID && weaponCount != -1 && loadoutHeaderText != "")
			RunUIScript( "LoadoutSelection_UpdateLoadoutInfo_UI", loadoutIndex, loadoutHeaderText, weaponCount, loadoutType )
	}

	RunUIScript( "LoadoutSelectionMenu_ResetLoadoutButtons" )
}
#endif // CLIENT

#if CLIENT
// The server passes updated information through this function so the Client and UI know which loadout was selected by the player
void function ServerCallback_LoadoutSelection_UpdateSelectedLoadoutInfo( int selectedLoadout )
{
	if ( !file.areLoadoutsPopulated )
	{
		LoadoutSelection_PopulateLoadouts()
	}
	if ( selectedLoadout < 0 || selectedLoadout >= LOADOUTSELECTION_MAX_TOTAL_LOADOUT_SLOTS )
		return

	file.playerSelectedLoadout = selectedLoadout
	RunUIScript( "LoadoutSelection_SetSelectedLoadoutSlotIndex_UI", selectedLoadout )
}
#endif // CLIENT

#if CLIENT
// Callback to set the icons and info for weapon buttons ( these include icons for attachments and scopes)
void function UICallback_LoadoutSelection_BindWeaponRui( var element, int loadoutIndex, int weaponIndex )
{
	if ( weaponIndex == -1 || loadoutIndex == -1 )
		return

	if ( IsLobby() )
		return

	var rui = Hud_GetRui( element )
	if ( !IsValid( rui ) )
		return

	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) )
		return

	Hud_ClearToolTipData( element )
	string entVar = Hud_GetScriptID( element )

	LoadoutSelectionLoadoutContents	data = LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex( loadoutIndex )
	int opticsIndex = -1

	if ( weaponIndex in data.weaponIndexToScopePreferenceTable  )
		opticsIndex = data.weaponIndexToScopePreferenceTable[ weaponIndex ]
	thread LoadoutSelection_BindWeaponButton_Thread( player, element, rui, loadoutIndex, weaponIndex, entVar, opticsIndex )
}
#endif // CLIENT

#if CLIENT
// Set weapon info and icons on a weapon button ( this includes icons for attachments and scopes)
void function LoadoutSelection_BindWeaponButton_Thread( entity player, var element, var rui, int loadoutIndex, int weaponIndex, string entVar, int opticsIndex )
{
	Assert( IsNewThread(), "Must be threaded off" )
	player.EndSignal( "OnDestroy" )

	// Define all the Rui vars we will be setting at the end of the function
	string weaponName = ""
	table < string, asset > ruiImageNameToImageTable =
	{
		iconImage = $"",
		ammoTypeImage = $"",
		barrelIcon = $"",
		magIcon = $"",
		sightIcon = $"rui/pilot_loadout/mods/empty_sight",
		gripIcon = $"",
		hopupIcon = $"",
		hopupMultiAIcon = $"",
		hopupMultiBIcon = $"",
	}

	table < string, int > ruiIntNameToIntTable =
	{
		lootTier = 0,
		barrelSlot = 0,
		magSlot = 0,
		sightSlot = 0,
		gripSlot = 0,
		hopupSlot = 0,
		hopupMultiASlot = 0,
		hopupMultiBSlot = 0,
		barrelTier = 0,
		magTier = 0,
		sightTier = 0,
		gripTier = 0,
		hopupTier = 0,
		hopupMultiATier = 0,
		hopupMultiBTier = 0,
	}

	table < string, bool > ruiBoolNameToBoolTable =
	{
		barrelAllowed = false,
		magAllowed = false,
		sightAllowed = false,
		gripAllowed = false,
		hopupAllowed = false,
		hopupMultiAAllowed = false,
		hopupMultiBAllowed = false,
	}

	string attachmentIconName = ""
	string attachmentSlotName = ""
	string attachmentTierName = ""
	string attachmentAllowedName = ""

	// Check if we should populate the icons with Valid icons, otherwise the icons will be set to defaults at the bottom of the function
	if ( weaponIndex >= 0 && weaponIndex < LOADOUTSELECTION_MAX_WEAPONS_PER_LOADOUT && loadoutIndex >= 0 && loadoutIndex < LOADOUTSELECTION_MAX_TOTAL_LOADOUT_SLOTS )
	{
		while ( !file.areLoadoutsPopulated )
		{
			LoadoutSelection_PopulateLoadouts()
			wait 1.0
		}

		if ( IsValid( rui ) )
		{
			LoadoutSelectionLoadoutContents loadoutContents = LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex( loadoutIndex )
			if ( LoadoutSelection_GetWeaponCountByLoadoutIndex( loadoutIndex ) > 0 )
			{
				LoadoutSelectionItem item
				if ( LoadoutSelection_GetWeaponCountByLoadoutIndex( loadoutIndex ) > weaponIndex )
				{
					item = loadoutContents.weaponLoadoutSelectionItemsInLoadout[ weaponIndex ]
					LoadoutSelection_AttemptToSetValueInRuiImageTable( "iconImage", ruiImageNameToImageTable, item.icon )

					if ( element != null )
					{
						Hud_SetWidth( element, Hud_GetBaseWidth( element ) )
						Hud_SetVisible( element, true )
					}

					if ( SURVIVAL_Loot_IsRefValid( item.ref ) )
					{
						LootData data = SURVIVAL_Loot_GetLootDataByRef( item.ref )
						int lootTier = LoadoutSelection_GetWeaponLootTierForMenu( data )
						LoadoutSelection_AttemptToSetValueInRuiIntTable( "lootTier", ruiIntNameToIntTable, lootTier )

						if ( data.lootType == eLootType.MAINWEAPON )
						{
							LootData baseWeaponData = SURVIVAL_Loot_GetLootDataByRef( data.baseWeapon )
							string ammoType = GetWeaponAmmoType( data.baseWeapon )
							if ( GetWeaponInfoFileKeyField_GlobalBool( data.baseWeapon, "uses_ammo_pool" ) )
							{
								LootData ammoData = SURVIVAL_Loot_GetLootDataByRef( ammoType )
								LoadoutSelection_AttemptToSetValueInRuiImageTable( "ammoTypeImage", ruiImageNameToImageTable, ammoData.hudIcon )
							}

							weaponName = data.pickupString
							if ( lootTier == 0 )
							{
								for ( int i = 0; i < baseWeaponData.supportedAttachments.len(); ++i )
								{
									string attachment = baseWeaponData.supportedAttachments[i]
									if ( attachment == "hopupMulti_a" )
									{
										attachment = "hopupMultiA"
									}
									else if ( attachment == "hopupMulti_b" )
									{
										attachment = "hopupMultiB"
									}

									attachmentAllowedName = attachment + "Allowed"
									LoadoutSelection_AttemptToSetValueInRuiBoolTable( attachmentAllowedName, ruiBoolNameToBoolTable, true )

									attachmentSlotName = attachment + "Slot"
									LoadoutSelection_AttemptToSetValueInRuiIntTable( attachmentSlotName, ruiIntNameToIntTable, i )

									string attachStyle = GetAttachmentPointStyle( baseWeaponData.supportedAttachments[i], baseWeaponData.ref )

									// Hacky fix for displaying sniper stock on empty attach slots since
									// CanAttachToWeapon() will fail inside GetAttachmentPointStyle because the weapon is locked
									if ( attachStyle == "grip" && ( baseWeaponData.lootTags.contains( "sniper" ) || baseWeaponData.lootTags.contains( "marksman" ) ) )
										attachStyle = "stock_sniper"

									attachmentIconName =  attachment + "Icon"
									LoadoutSelection_AttemptToSetValueInRuiImageTable( attachmentIconName, ruiImageNameToImageTable, emptyAttachmentSlotImages[attachStyle] )
								}
							}
							else if ( item.ref in file.weaponUpgrades )
							{
								array<string> upgrades = file.weaponUpgrades[ item.ref ]
								int attachIndex = 0
								for ( int i = 0; i < upgrades.len(); ++i )
								{
									if ( !SURVIVAL_Loot_IsRefValid( upgrades[i] ) )
										continue

									LootData lootData  = SURVIVAL_Loot_GetLootDataByRef( upgrades[i] )
									string attachStyle = GetAttachPointForAttachmentOnWeapon( item.ref, upgrades[i] )

									if ( attachStyle == "hopupMulti_a" )
									{
										attachStyle = "hopupMultiA"
									}
									else if ( attachStyle == "hopupMulti_b" )
									{
										attachStyle = "hopupMultiB"
									}

									if ( attachStyle == "" )
										continue

									if ( attachStyle == "sight" )
									{
										if ( opticsIndex > -1 && opticsIndex <= LOADOUTSELECTION_MAX_SCOPE_INDEX )
										{
											array<string> optics = LoadoutSelection_GetAvailableOptics( loadoutIndex, weaponIndex, true )
											if ( opticsIndex < optics.len() )
											{
												if ( SURVIVAL_Loot_IsRefValid( optics[ opticsIndex ] ) )
												{
													lootData = SURVIVAL_Loot_GetLootDataByRef( optics[ opticsIndex ] )
												}
												else if ( optics[ opticsIndex ] == "" )
												{
													attachmentAllowedName = attachStyle + "Allowed"
													LoadoutSelection_AttemptToSetValueInRuiBoolTable( attachmentAllowedName, ruiBoolNameToBoolTable, true )

													attachmentSlotName = attachStyle + "Slot"
													LoadoutSelection_AttemptToSetValueInRuiIntTable( attachmentSlotName, ruiIntNameToIntTable, attachIndex )
													continue
												}
											}
										}
									}

									attachmentIconName = attachStyle + "Icon"
									LoadoutSelection_AttemptToSetValueInRuiImageTable( attachmentIconName, ruiImageNameToImageTable, lootData.hudIcon )

									attachmentAllowedName = attachStyle + "Allowed"
									LoadoutSelection_AttemptToSetValueInRuiBoolTable( attachmentAllowedName, ruiBoolNameToBoolTable, true )

									attachmentSlotName = attachStyle + "Slot"
									LoadoutSelection_AttemptToSetValueInRuiIntTable( attachmentSlotName, ruiIntNameToIntTable, attachIndex )

									attachmentTierName = attachStyle + "Tier"
									LoadoutSelection_AttemptToSetValueInRuiIntTable( attachmentTierName, ruiIntNameToIntTable, lootData.tier )

									if ( attachStyle != "sight" ) // sights are handled special for this UI elemement
										attachIndex++
								}
							}
						}
					}
				}
			}
		}
	}

	// Set the values on the RUI
	RuiSetString( rui, "weaponName", weaponName )
	foreach ( key, value in ruiImageNameToImageTable )
	{
		RuiSetImage( rui, key, value )
	}

	foreach ( key, value in ruiIntNameToIntTable )
	{
		RuiSetInt( rui, key, value )
	}

	foreach ( key, value in ruiBoolNameToBoolTable )
	{
		RuiSetBool( rui, key, value )
	}
}
#endif // CLIENT

#if CLIENT
// Support function used by LoadoutSelection_BindWeaponButton_Thread to populate a table with Rui Images that can be set at the end of the function
void function LoadoutSelection_AttemptToSetValueInRuiImageTable( string key, table< string, asset > imageTable, asset image )
{
	if ( key in imageTable )
	{
		imageTable[ key ] = image
	}
	else
	{
		Warning( "LoadoutSelection_AttemptToSetValueInRuiImageTable tried to set %s in imageTable but it is not defined as a key in the Table", key )
	}
}
#endif // CLIENT

#if CLIENT
// Support function used by LoadoutSelection_BindWeaponButton_Thread to populate a table with Rui Ints that can be set at the end of the function
void function LoadoutSelection_AttemptToSetValueInRuiIntTable( string key, table< string, int > intTable, int intVal )
{
	if ( key in intTable )
	{
		intTable[ key ] = intVal
	}
	else
	{
		Warning( "LoadoutSelection_AttemptToSetValueInRuiIntTable tried to set %s in intTable but it is not defined as a key in the Table", key )
	}
}
#endif // CLIENT

#if CLIENT
// Support function used by LoadoutSelection_BindWeaponButton_Thread to populate a table with Rui Bools that can be set at the end of the function
void function LoadoutSelection_AttemptToSetValueInRuiBoolTable( string key, table< string, bool > boolTable, bool boolVal )
{
	if ( key in boolTable )
	{
		boolTable[ key ] = boolVal
	}
	else
	{
		Warning( "LoadoutSelection_AttemptToSetValueInRuiBoolTable tried to set %s in boolTable but it is not defined as a key in the Table", key )
	}
}
#endif // CLIENT

#if CLIENT
//Writes the number of consumables a loadout has
void function UICallback_LoadoutSelection_SetConsumablesCountRui( var element, int loadoutIndex )
{
	LoadoutSelectionLoadoutContents loadoutContents = LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex( loadoutIndex )

	array< LoadoutSelectionItem > ConsumablesInLoadout = loadoutContents.consumableLoadoutSelectionItemsInLoadout

	var rui = Hud_GetRui( element )
	if ( !IsValid( rui ) )
		return

	RuiSetInt( rui, "consumablesCount", ConsumablesInLoadout.len() )
}
#endif // CLIENT

#if CLIENT
// UI Callback to Set the icon for consumables or weapons
void function UICallback_LoadoutSelection_BindItemIcon( var icon, int loadoutIndex, int weaponIndex, int consumableIndex )
{
	if ( IsLobby() )
		return

	if ( icon == null )
		return

	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) )
		return

	var rui = Hud_GetRui( icon )
	if ( !IsValid( rui ) )
		return

	thread LoadoutSelection_BindItemIcon_Thread( player, icon, rui, loadoutIndex, weaponIndex, consumableIndex )
}
#endif // CLIENT

#if CLIENT
// Set the icon for consumables or weapons ( currently only ordnance for consumables )
void function LoadoutSelection_BindItemIcon_Thread( entity player, var icon, var rui, int loadoutIndex, int weaponIndex, int consumableIndex )
{
	Assert( IsNewThread(), "Must be threaded off" )
	player.EndSignal( "OnDestroy" )
	RuiSetImage( rui, "basicImage", $"" )

	while ( !file.areLoadoutsPopulated )
	{
		LoadoutSelection_PopulateLoadouts()
		wait 1.0
	}

	// Test for Invalid Loadout Index
	if ( loadoutIndex < 0 || loadoutIndex >= LOADOUTSELECTION_MAX_TOTAL_LOADOUT_SLOTS )
		return

	if ( icon == null )
		return

	LoadoutSelectionLoadoutContents loadoutContents = LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex( loadoutIndex )
	LoadoutSelectionItem item

	if ( weaponIndex >= 0 ) // Set a weapon Icon
	{
		if ( LoadoutSelection_GetWeaponCountByLoadoutIndex( loadoutIndex ) == 0 )
			return


		if ( LoadoutSelection_GetWeaponCountByLoadoutIndex( loadoutIndex ) > weaponIndex )
		{
			item = loadoutContents.weaponLoadoutSelectionItemsInLoadout[ weaponIndex ]
			RuiSetImage( rui, "basicImage", item.icon )
			Hud_SetVisible( icon, true )
		}
	}
	else if ( consumableIndex >= 0 ) // Set a consumable icon
	{
		array< LoadoutSelectionItem > ConsumablesInLoadout = loadoutContents.consumableLoadoutSelectionItemsInLoadout

		if ( ConsumablesInLoadout.len() == 0 )
			return


		if ( ConsumablesInLoadout.len() > consumableIndex )
		{
			item = ConsumablesInLoadout[ consumableIndex ]
			RuiSetImage( rui, "basicImage", item.icon )
			Hud_SetVisible( icon, true )
		}
	}
}
#endif // CLIENT

#if CLIENT
// Get the icon that should be displayed for a loadouts weapon or consumable (used when the scope and attachment info is not needed on the icon)
asset function LoadoutSelection_GetItemIcon( int loadoutIndex, int weaponIndex, int consumableIndex )
{
	asset image = $""

	// Check for a valid loadout Index
	if ( loadoutIndex < 0 || loadoutIndex >= LOADOUTSELECTION_MAX_TOTAL_LOADOUT_SLOTS )
		return image

	LoadoutSelectionLoadoutContents loadoutContents = LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex( loadoutIndex )
	LoadoutSelectionItem item

	if ( weaponIndex >= 0 ) // Set a weapon Icon
	{
		if ( LoadoutSelection_GetWeaponCountByLoadoutIndex( loadoutIndex ) == 0 )
		{
			LoadoutSelection_PopulateLoadouts()
			loadoutContents = LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex( loadoutIndex )
		}

		if ( LoadoutSelection_GetWeaponCountByLoadoutIndex( loadoutIndex ) > weaponIndex && weaponIndex < loadoutContents.weaponLoadoutSelectionItemsInLoadout.len())
			item = loadoutContents.weaponLoadoutSelectionItemsInLoadout[ weaponIndex ]
	}
	else if ( consumableIndex >= 0 ) // Set a consumable icon
	{
		array< LoadoutSelectionItem > ConsumablesInLoadout = loadoutContents.consumableLoadoutSelectionItemsInLoadout

		if ( ConsumablesInLoadout.len() == 0 )
		{
			LoadoutSelection_PopulateLoadouts()
			loadoutContents = LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex( loadoutIndex )
			ConsumablesInLoadout = loadoutContents.consumableLoadoutSelectionItemsInLoadout
		}

		if ( ConsumablesInLoadout.len() > 0 && consumableIndex < ConsumablesInLoadout.len())
			item = ConsumablesInLoadout[ consumableIndex ]
	}

	image = item.icon
	return image
}
#endif // CLIENT

#if CLIENT
// Get the icon that should be displayed for a loadouts weapon or consumable (used when the scope and attachment info is not needed on the icon)
int function LoadoutSelection_GetWeaponLootTeir( int loadoutIndex, int weaponIndex )
{
	int lootTier = 0

	// Check for a valid loadout Index
	if ( loadoutIndex < 0 || loadoutIndex >= LOADOUTSELECTION_MAX_TOTAL_LOADOUT_SLOTS || !file.areLoadoutsPopulated )
		return lootTier

	LoadoutSelectionLoadoutContents loadoutContents = LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex( loadoutIndex )
	LoadoutSelectionItem item

	if ( weaponIndex >= 0 ) // Set a weapon Icon
	{
		if ( LoadoutSelection_GetWeaponCountByLoadoutIndex( loadoutIndex ) == 0 )
		{
			LoadoutSelection_PopulateLoadouts()
			loadoutContents = LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex( loadoutIndex )
		}

		if ( LoadoutSelection_GetWeaponCountByLoadoutIndex( loadoutIndex ) > weaponIndex  && loadoutContents.weaponLoadoutSelectionItemsInLoadout.len() > 0)
			item = loadoutContents.weaponLoadoutSelectionItemsInLoadout[ weaponIndex ]
	}

	if ( SURVIVAL_Loot_IsRefValid( item.ref ) )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByRef( item.ref )
		lootTier = LoadoutSelection_GetWeaponLootTierForMenu( data )
	}

	return lootTier
}
#endif // CLIENT

/*
   ____  _____ _______ _____ _____  _____
  / __ \|  __ \__   __|_   _/ ____|/ ____|
 | |  | | |__) | | |    | || |    | (___
 | |  | |  ___/  | |    | || |     \___ \
 | |__| | |      | |   _| || |____ ____) |
  \____/|_|      |_|  |_____\_____|_____/

// Optics
*/


#if CLIENT
void function UICallback_LoadoutSelection_BindWeaponElement( var element, int selectedWeapon = -1 )
{
	if ( IsLobby() )
		return

	if ( file.selectedLoadoutForOptic == -1 || selectedWeapon == -1 )
		return

	if ( !file.areLoadoutsPopulated )
		return

	var rui = Hud_GetRui( element )

	RuiSetImage( rui, "iconImage", $"" )
	RuiSetInt( rui, "lootTier", -1 )
	RuiSetString( rui, "weaponName", "" )

	LoadoutSelectionLoadoutContents loadoutContents = LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex( file.selectedLoadoutForOptic )
	LoadoutSelectionItem item
	if ( LoadoutSelection_GetWeaponCountByLoadoutIndex( file.selectedLoadoutForOptic ) > selectedWeapon )
	{
		item = loadoutContents.weaponLoadoutSelectionItemsInLoadout[ selectedWeapon ]
	}
	else
	{
		return
	}

	RuiSetImage( rui, "iconImage", item.icon )
	if ( SURVIVAL_Loot_IsRefValid( item.ref ) )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByRef( item.ref )
		int lootTier = LoadoutSelection_GetWeaponLootTierForMenu( data )
		RuiSetInt( rui, "lootTier", lootTier )
		if ( data.lootType == eLootType.MAINWEAPON )
		{
			LootData baseWeaponData = SURVIVAL_Loot_GetLootDataByRef( data.baseWeapon )

			RuiSetString( rui, "weaponName", data.pickupString )
		}
	}

}
// Provide the optics overlay with updated info on which scopes to display as available and which ones to display as locked based on our datatables
void function UICallback_LoadoutSelection_BindOpticSlotButton( var button, int selectedWeapon = -1 )
{
	if ( IsLobby() )
		return

	if ( file.selectedLoadoutForOptic == -1 || selectedWeapon == -1 )
		return

	if ( !file.areLoadoutsPopulated )
		return

	var rui        = Hud_GetRui( button )
	int opticIndex = int( Hud_GetScriptID( button ))

	array<string> optics = LoadoutSelection_GetAvailableOptics( file.selectedLoadoutForOptic, selectedWeapon )

	if ( opticIndex >= optics.len() )
	{
		RuiSetFloat( rui, "baseAlpha", 0.0 )
		RuiSetBool( rui, "isActive", false )
		return
	}

	array<string> unlockedOptics = LoadoutSelection_GetAvailableOptics( file.selectedLoadoutForOptic, selectedWeapon, true )

	bool hasPreReq = opticIndex < unlockedOptics.len()
	Hud_SetLocked( button, !hasPreReq )
	bool isOpticRefValid = SURVIVAL_Loot_IsRefValid( optics[opticIndex] )

	if ( isOpticRefValid )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByRef( optics[opticIndex] )
		RuiSetImage( rui, "iconImage", data.hudIcon )
		RuiSetInt( rui, "tier", data.tier )
	}
	else
	{
		RuiSetImage( rui, "iconImage", $"rui/pilot_loadout/mods/empty_sight" )
		RuiSetInt( rui, "tier", 0 )
	}

	RuiSetFloat( rui, "baseAlpha", 1.0 )
	RuiSetBool( rui, "hasPreReq", hasPreReq )

	if ( !isOpticRefValid )
		return



	// which sight is equipped on the weapon for this loadout
	int equippedOptic = -1
	bool isActive = false

	LoadoutSelectionLoadoutContents loadoutContentsData = LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex( file.selectedLoadoutForOptic )

	if ( selectedWeapon in loadoutContentsData.weaponIndexToScopePreferenceTable  )
		equippedOptic = loadoutContentsData.weaponIndexToScopePreferenceTable[ selectedWeapon ]

	if ( equippedOptic > -1 )
	{
		isActive = equippedOptic == opticIndex
	}
	else
	{
		string weaponRef = LoadoutSelection_GetWeaponRefByIndex( file.selectedLoadoutForOptic, selectedWeapon )

		if ( SURVIVAL_Loot_IsRefValid( weaponRef ) )
		{
			foreach ( upgrade in file.weaponUpgrades[ weaponRef ] )
			{
				if ( !SURVIVAL_Loot_IsRefValid( upgrade ) )
					continue

				LootData attachData = SURVIVAL_Loot_GetLootDataByRef( upgrade )
				if ( attachData.attachmentStyle.find( "sight" ) >= 0 )
				{
					equippedOptic = attachData.index
					break
				}
			}

			if ( SURVIVAL_Loot_IsRefValid( optics[opticIndex] ) )
			{
				LootData data = SURVIVAL_Loot_GetLootDataByRef( optics[opticIndex] )
				isActive = equippedOptic == data.index
			}
		}
	}

	RuiSetBool( rui, "isActive", isActive )
}

// Handle the optics menu opening ( let the optics menu know which weapon in which loadout is having the optics changed)
void function UICallback_LoadoutSelection_OnRequestOpenScopeSelection( var button, int loadoutIndex )
{
	if ( IsLobby() || Hud_IsLocked( button ) || file.isProcessingClickEvent )
		return

	entity player = GetLocalClientPlayer()

	if ( loadoutIndex == -1 )
		return

	string weaponRef0 = LoadoutSelection_GetWeaponRefByIndex( loadoutIndex, 0 )
	string weaponRef1 = LoadoutSelection_GetWeaponRefByIndex( loadoutIndex, 1 )


	if ( !SURVIVAL_Loot_IsRefValid( weaponRef0 ) && !SURVIVAL_Loot_IsRefValid( weaponRef1 ) )
		return

	if ( !( weaponRef0 in file.weaponUpgrades ) && !( weaponRef1 in file.weaponUpgrades ) )
		return

	array<string> Weapon0Optics = LoadoutSelection_GetAvailableOptics( loadoutIndex, 0, true )
	array<string> Weapon1Optics = LoadoutSelection_GetAvailableOptics( loadoutIndex, 1, true )

	if ( Weapon0Optics.len() <= 1 && Weapon1Optics.len() <= 1)
		return

	int opticLootIndex = -1
	foreach ( upgrade in file.weaponUpgrades[ weaponRef0 ] )
	{
		if ( !SURVIVAL_Loot_IsRefValid( upgrade ) )
			continue

		LootData attachData = SURVIVAL_Loot_GetLootDataByRef( upgrade )
		if ( attachData.attachmentStyle.find( "sight" ) >= 0 )
		{
			opticLootIndex = attachData.index
			break
		}
	}

	file.isProcessingClickEvent = true
	file.selectedLoadoutForOptic = loadoutIndex
	RunUIScript( "ClientToUI_LoadoutSelectionOptics_OpenSelectOpticDialog", loadoutIndex )
}

// Once all data and audio is set for opening the optics menu, leave it available to be used again
void function ServerCallback_LoadoutSelection_FinishedProcessingClickEvent()
{
	file.isProcessingClickEvent = false
}

// When an optic is selected from the optics menu, set it as the preferred optic for that weapon in that loadout
void function UICallback_LoadoutSelection_OnOpticSlotButtonClick( var opticButton, var loadoutButton, int weaponIndex, var weaponButton )
{
	if ( file.selectedLoadoutForOptic == -1 || Hud_IsLocked( opticButton ) || weaponIndex == -1  )
		return

	// Store these here because they get reset before the BindWeaponButton function gets a chance to run
	int loadoutIndex = file.selectedLoadoutForOptic

	entity player = GetLocalClientPlayer()
	int opticIndex = int( Hud_GetScriptID( opticButton ) )
	array<string> optics = LoadoutSelection_GetAvailableOptics( loadoutIndex, weaponIndex, true )

	// Make sure the optic index is valid before proceeding
	if ( opticIndex >= optics.len() || opticIndex < 0 || opticIndex > LOADOUTSELECTION_MAX_SCOPE_INDEX )
		return

	if ( SURVIVAL_Loot_IsRefValid( optics[ opticIndex ] ) || optics[ opticIndex ] == "" )
	{
		EmitSoundOnEntity( GetLocalClientPlayer(), SOUND_SELECT_OPTIC )

		// Set the selected scope for the Client ( so we can display the correct icon on the menu each time it is opened in the future)
		LoadoutSelectionLoadoutContents	data = LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex( loadoutIndex )
		data.weaponIndexToScopePreferenceTable[ weaponIndex ] <- opticIndex

		// Set the selected scope on the server so we can attach it to the weapon when it is given
		Remote_ServerCallFunction( "ClientCallback_LoadoutSelection_SetOpticPreference", loadoutIndex, weaponIndex, opticIndex )

		if ( weaponButton != null )
		{
			var rui = Hud_GetRui( weaponButton )
			string entVar = Hud_GetScriptID( weaponButton )
			thread LoadoutSelection_BindWeaponButton_Thread( GetLocalClientPlayer(), weaponButton, rui, loadoutIndex, weaponIndex, entVar, opticIndex )
		}
	}
}

// Once the optic select menu is closed, set the temp weapon and loadout data we send to the optics menu back to default
void function UICallback_LoadoutSelection_OpticSelectDialogueClose()
{
	file.selectedLoadoutForOptic = -1
}
#endif // CLIENT


#if SERVER
// The optics menu tells the server which optic has been set for a specific weapon in a specific loadout
void function ClientCallback_LoadoutSelection_SetOpticPreference( entity player, int selectedLoadoutForOptic, int selectedWeapon1ForOptic, int opticLootIndex )
{
	if ( !IsValid( player ) )
		return

	// Our weapon indexes are 0 or 1, anything greater or lower is not valid
	if ( selectedWeapon1ForOptic > 1 || selectedWeapon1ForOptic < 0 )
		return

	// Scope Index needs to fall into a valid range as well
	if ( opticLootIndex < 0 || opticLootIndex > LOADOUTSELECTION_MAX_SCOPE_INDEX )
		return

	// Make sure the loadout falls into a valid range
	if ( selectedLoadoutForOptic < 0 || selectedLoadoutForOptic >= file.loadoutCategories.len() )
		return

	LoadoutSelectionLoadoutContents	data = LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex( selectedLoadoutForOptic )
	if ( selectedWeapon1ForOptic == 0 )
	{
		data.playerToWeapon0ScopePreferenceTable[player] <- opticLootIndex
	}
	else if ( selectedWeapon1ForOptic == 1 )
	{
		data.playerToWeapon1ScopePreferenceTable[player] <- opticLootIndex
	}
}

// Set the attachments on the weapon based on what is available in the datatables, set the scope based on what is available in datatables or what was set by the player. Then give the player the weapon.
void function LoadoutSelection_GivePlayerWeapon( entity player, int selectedLoadout, int selectedWeapon )
{
	// Our weapon indexes are 0 or 1, anything higher or lower is invalid
	if ( selectedWeapon > 1 || selectedWeapon < 0 )
		return

	LoadoutSelectionLoadoutContents	data = LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex( selectedLoadout )
	int opticIndex = -1

	if ( selectedWeapon == 0 )
	{
		if ( player in data.playerToWeapon0ScopePreferenceTable )
		{
			opticIndex = data.playerToWeapon0ScopePreferenceTable[player]
		}
	}
	else if ( selectedWeapon == 1 )
	{
		if ( player in data.playerToWeapon1ScopePreferenceTable )
		{
			opticIndex = data.playerToWeapon1ScopePreferenceTable[player]
		}
	}
	string weaponRef = data.weaponLoadoutSelectionItemsInLoadout[ selectedWeapon ].ref
	if( !LoadoutSelection_IsRefValidWeapon( weaponRef ) )
		return

	string optic = ""
	bool usedPreferredOptics = false
	bool replacedOptic = false

	// The player has set a preferred optic, make sure it is valid or iron sights before setting
	if ( opticIndex > -1 )
	{
		array<string> optics = LoadoutSelection_GetAvailableOptics( selectedLoadout, selectedWeapon, true )
		if ( opticIndex < optics.len() )
		{
			if ( SURVIVAL_Loot_IsRefValid( optics[ opticIndex ] ) )
			{
				LootData newOpticData = SURVIVAL_Loot_GetLootDataByRef( optics[ opticIndex ] )
				optic = newOpticData.ref
				usedPreferredOptics = true
			}
			else if ( optics[ opticIndex ] == "" )
			{
				optic = ""
				usedPreferredOptics = true
			}
		}
	}

	// The player didn't set a scope, select the weapon default
	if ( !usedPreferredOptics && weaponRef in file.weaponUpgrades )
	{
		for ( int i = 0; i < file.weaponUpgrades[ weaponRef ].len(); ++i )
		{
			if ( !SURVIVAL_Loot_IsRefValid( file.weaponUpgrades[ weaponRef ][ i ] ) )
				continue

			LootData attachData = SURVIVAL_Loot_GetLootDataByRef( file.weaponUpgrades[ weaponRef ][ i ] )
			if ( attachData.attachmentStyle.find( "sight" ) >= 0 )
			{
				optic = file.weaponUpgrades[ weaponRef ][ i ]
				break
			}
		}
	}

	array<string> upgrades = clone LoadoutSelection_GetAvailableWeaponUpgradesForWeaponRef( weaponRef )
	// In our list of upgrades, either replace the current optic with the one set by the player or remove any optic if the one selected was blank
	for ( int j = 0; j < upgrades.len(); ++j )
	{
		if( !SURVIVAL_Loot_IsRefValid( upgrades[ j ] ) )
			continue

		LootData attachData = SURVIVAL_Loot_GetLootDataByRef( upgrades[ j ] )
		if ( attachData.attachmentStyle.find( "sight" ) >= 0 )
		{
			if ( optic == "" )
			{
				upgrades.remove( j )
			}
			else
			{
				upgrades[ j ] = optic
			}

			replacedOptic = true
			break
		}
	}

	if( !replacedOptic && optic != "" )
	{
		upgrades.append( optic )
	}

	LootData weaponData = SURVIVAL_Loot_GetLootDataByRef( weaponRef )
	array<string> lootTags = weaponData.lootTags
	entity newActiveWeapon = SpawnGenericLoot( weaponData.baseWeapon, player.GetOrigin(), player.GetAngles(), -1 )
	newActiveWeapon.SetWeaponMods( upgrades )
	SURVIVAL_GiveMainWeapon( player, newActiveWeapon, lootTags, null, false, null, false, false, [], false )
	SetItemSpawnSource( newActiveWeapon, eSpawnSource.GAME, player )
	newActiveWeapon.Destroy()


	// Fill the weapon ammo and clip so the player doesn't have to reload the gun right away
	int activeWeaponSlot = SURVIVAL_GetActiveWeaponSlot( player )
	int secondaryWeaponSlot =  SURVIVAL_GetStowedWeaponSlot( player )
	entity activePrimaryWeapon = player.GetNormalWeapon( activeWeaponSlot )
	entity activeSecondaryWeapon = player.GetNormalWeapon( secondaryWeaponSlot )
	if ( IsValid( activePrimaryWeapon ) && GetWeaponClassName( activePrimaryWeapon ) == weaponData.baseWeapon )
		LoadoutSelection_GiveWeaponAmmo( player, activePrimaryWeapon )

	if ( IsValid( activeSecondaryWeapon ) && GetWeaponClassName( activeSecondaryWeapon ) == weaponData.baseWeapon )
		LoadoutSelection_GiveWeaponAmmo( player, activeSecondaryWeapon )
}

// Give weapons a correct starter ammo amount
void function LoadoutSelection_GiveWeaponAmmo( entity player, entity weapon )
{
	if ( weapon.GetActiveAmmoSource() == AMMOSOURCE_STOCKPILE && weapon.UsesClipsForAmmo() )
	{
		weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
		SetInfiniteAmmoForWeapon ( player, weapon, true )
	}
	else
	{
		if ( weapon.UsesClipsForAmmo() )
		{
			weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
		}
		SetInfiniteAmmoForWeapon ( player, weapon, true )

		string ammoRef = GetWeaponAmmoTypeFromWeaponEnt( weapon )
		if ( SURVIVAL_Loot_IsRefValid( ammoRef ) && !GetInfiniteAmmo( weapon ) )
		{
			int ammoType   = AmmoType_GetTypeFromRef( ammoRef )
			int currentPoolCount   = player.AmmoPool_GetCount( ammoType )
			int maxPoolCount = player.AmmoPool_GetCapacity()
			int desiredPoolCount = currentPoolCount
			int defaultMultiplier = 1
			int loadoutAmmoMultiplier = GetCurrentPlaylistVarInt( "loadout_ammo_multiplier", defaultMultiplier )
			LootData data = SURVIVAL_Loot_GetLootDataByRef( ammoRef )
			desiredPoolCount += data.countPerDrop * loadoutAmmoMultiplier

			int poolcountToGive = desiredPoolCount
			if ( desiredPoolCount > maxPoolCount )
				poolcountToGive = maxPoolCount
			player.AmmoPool_SetCount( ammoType, poolcountToGive )
		}
	}
}
#endif // SERVER

#if CLIENT || SERVER
// Get Loadout struct using the slot index
LoadoutSelectionLoadoutContents function LoadoutSelection_GetLoadoutContentsByLoadoutSlotIndex( int loadoutSlotIndex )
{
	LoadoutSelectionLoadoutContents	data
	if ( loadoutSlotIndex in file.loadoutSlotIndexToCategoryDataTable )
	{
		LoadoutSelectionCategory loadoutCategory = file.loadoutSlotIndexToCategoryDataTable[ loadoutSlotIndex ]
		string loadoutName = loadoutCategory.activeLoadoutName

		if ( loadoutName in loadoutCategory.loadoutContentsByNameTable )
			data = loadoutCategory.loadoutContentsByNameTable[loadoutName]
	}

	return data
}

// Get available weapon optics based on datatables from the passed in loadout and weapon index.
// Unlike attachments which only give the attachments for the current weapon tier, scopes return all available optics for the current weapon tier and lower tiers (if unlocked only is true) or all tiers ( if unlocked only is false)
array<string> function LoadoutSelection_GetAvailableOptics( int loadoutIndex, int weaponIndex, bool unlockedOnly = false )
{
	array<string> availableOptics = [ "" ]
	if ( loadoutIndex == -1 || weaponIndex == -1 )
		return availableOptics

	string ref = LoadoutSelection_GetWeaponRefByIndex( loadoutIndex, weaponIndex )
	if ( !SURVIVAL_Loot_IsRefValid( ref ) )
		return availableOptics

	LootData weaponData = SURVIVAL_Loot_GetLootDataByRef( ref )

	array<string> suffixes = [ "", WEAPON_LOCKEDSET_SUFFIX_WHITESET, WEAPON_LOCKEDSET_SUFFIX_BLUESET, WEAPON_LOCKEDSET_SUFFIX_PURPLESET, WEAPON_LOCKEDSET_SUFFIX_GOLD ]
	foreach ( suffix in suffixes )
	{
		string weaponRef = weaponData.baseWeapon + suffix
		if ( weaponRef in file.weaponOptics )
			availableOptics.extend( file.weaponOptics[ weaponRef ] )

		if ( unlockedOnly && ref == weaponRef )
			break
	}

	return availableOptics
}
#endif // CLIENT || SERVER

#if CLIENT || SERVER
int function LoadoutSelection_GetAvailableLoadoutCount()
{
	return file.loadoutCategories.len()
}
#endif // CLIENT || SERVER

// Figure out if the passed in weaponRef is valid and in fact a weapon
bool function LoadoutSelection_IsRefValidWeapon( string weaponRef )
{
	if( !SURVIVAL_Loot_IsRefValid( weaponRef ) )
		return false

	LootData lootData = SURVIVAL_Loot_GetLootDataByRef( weaponRef )
	return lootData.lootType == eLootType.MAINWEAPON
}