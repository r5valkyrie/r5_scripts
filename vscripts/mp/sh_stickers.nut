global function ShStickers_LevelInit
global function Loadout_Sticker

#if CLIENT || SERVER
global function GetStickerObjectType
global function GetStickerObjectModel
#endif // CLIENT || SERVER

global function GetMaxStickersForObjectType
#if UI
global function GetAllStickerObjectTypes
global function GetStickerObjectName
global function GetStickerPresentationType
// CreateNestedRuiForSticker already in sh_items.gnut
#endif // UI

// Sticker_IsTheEmpty, Sticker_GetStoryBlurbBodyText, Sticker_HasStoryBlurb already in sh_items.gnut
global function Sticker_GetDecalMaterialAsset
global function Sticker_GetReplacementMaterialAsset
// Sticker_GetSortOrdinal already in sh_items.gnut
global function Sticker_GetDecalScale

#if SERVER
global function DEV_StickerTestSetupForPlayer
#endif // SERVER

#if CLIENT
global function Sticker_SetMaterialModForLocalPlayer
global function Sticker_PlaceDecalForLocalPlayer
global function Sticker_OnPlaced
global function Sticker_CreateFlashData
global function Sticker_FlashOnLoadComplete
#endif

#if SERVER && DEVELOPER
global function DEV_StickerTestSetup
#endif // SERVER && DEVELOPER

#if CLIENT && DEVELOPER
global function DEV_TestCreateStickerMesh
global function DEV_TestCreateStickerDecal
global function DEV_StickerTestSetupForLocalPlayer
global function DEV_ReturnRandomStickerFlavs
#endif

#if UI && DEVELOPER
global function DEV_PrintStickerLoadout
#endif // UI && DEVELOPER

global enum eStickerObjectType
{
	injector,
	shield_cell,
	shield_battery,
	phoenix_kit,
}

#if CLIENT || SERVER
global const asset UNAPPLIED_STICKER_MODEL = $"mdl/props/stickers/flat_sticker.rmdl"
global const asset FLAT_STICKER_MODEL = $"mdl/props/stickers/flat_sticker.rmdl"

const asset SHIELD_CELL_MODEL = $"mdl/weapons/shield_battery/ptpov_shield_battery_small_held.rmdl"
const asset SHIELD_BATTERY_MODEL = $"mdl/weapons/shield_battery/ptpov_shield_battery_held.rmdl"
const asset HEALTH_INJECTOR_MODEL = $"mdl/weapons/health_injector/ptpov_health_injector.rmdl"
#endif // CLIENT || SERVER

struct StickerFlashData
{
	entity flashEnt
	int    flashType
	vector flashColor
}

struct FileStruct_LifetimeLevel
{
	table<int, array<LoadoutEntry> > stickerSlotMap
	table<ItemFlavor, int>           stickerSortOrdinalMap

	table<int, StickerFlashData> stickerFlashData
}
FileStruct_LifetimeLevel& fileLevel


void function ShStickers_LevelInit()
{
	FileStruct_LifetimeLevel newFileLevel
	fileLevel = newFileLevel

	#if SERVER || CLIENT
		PrecacheModel( UNAPPLIED_STICKER_MODEL )

		PrecacheModel( SHIELD_CELL_MODEL )
		PrecacheModel( SHIELD_BATTERY_MODEL )
		PrecacheModel( HEALTH_INJECTOR_MODEL )
	#endif

	AddCallback_RegisterRootItemFlavors( RegisterStickers )

	#if (SERVER || CLIENT)
		DEV_SetupStickerNetworking()
	#endif

// GetStickerSlot not available
// #if CLIENT
// 	thread AutoLoadViewPlayerStickers()
// #endif
}


void function RegisterStickers()
{
	array<ItemFlavor> stickerItemList = []
	foreach ( asset stickerAsset in GetBaseItemFlavorsFromArray( "stickers" ) )
	{
		if ( stickerAsset == $"" )
			continue

		ItemFlavor ornull stickerItem = RegisterItemFlavorFromSettingsAsset( stickerAsset )
		if ( stickerItem == null )
			continue

		expect ItemFlavor( stickerItem )
		stickerItemList.append( stickerItem )
	}

	MakeItemFlavorSet( stickerItemList, fileLevel.stickerSortOrdinalMap )

	foreach ( int stickerObjectType in eStickerObjectType )
	{
		fileLevel.stickerSlotMap[stickerObjectType] <- []
		string stickerObjectName = GetEnumString( "eStickerObjectType", stickerObjectType )

		for ( int i = 0; i < GetMaxStickersForObjectType( stickerObjectType ); i++ )
		{
			LoadoutEntry entry = RegisterLoadoutSlot( eLoadoutEntryType.ITEM_FLAVOR, stickerObjectName + "_sticker_" + i, eLoadoutEntryClass.ACCOUNT )
			entry.category     = eLoadoutCategory.STICKERS
			#if DEVELOPER
				entry.DEV_name       = "Sticker " + stickerObjectName + " " + i
			#endif
			entry.defaultItemFlavor   = stickerItemList[0]
			entry.validItemFlavorList = stickerItemList
			entry.isSlotLocked        = bool function( EHI playerEHI ) { return !IsLobby()	}
			entry.networkTo           = eLoadoutNetworking.PLAYER_EXCLUSIVE

			fileLevel.stickerSlotMap[stickerObjectType].append( entry )

			// Server pushes sticker loadouts to players through a specific data table. When the loadout changes fill up this table to be propegated
			// to other players.
			// SetStickerSlot/GetStickerSlot entity functions not available
			// #if SERVER
			// AddCallback_ItemFlavorLoadoutSlotDidChange_AnyPlayer( entry,
			// 	void function ( EHI playerEHI, ItemFlavor flavor ) : ( i, stickerObjectType )
			// 	{
			// 		entity player = FromEHI( playerEHI )
			// 		SettingsAssetGUID guid = ItemFlavor_GetGUID( flavor )
			// 		player.SetStickerSlot( stickerObjectType * GetMaxStickersForObjectType( stickerObjectType ) + i, guid )
			// 	}
			// );
			// #endif
		}
	}

	// The local player can setup an optimization to load the stickers needed for their loadout right away, rather than waiting until using the item.
#if CLIENT
	foreach ( int stickerObjectType in eStickerObjectType )
	{
		foreach( LoadoutEntry entry in fileLevel.stickerSlotMap[stickerObjectType] )
		{
			AddCallback_ItemFlavorLoadoutSlotDidChange_AnyPlayer( entry, OnStickerLocalPlayerItemLoadoutChanged )
		}
	}
#endif
}

#if CLIENT
void function OnStickerLocalPlayerItemLoadoutChanged( EHI playerEHI, ItemFlavor flavor )
{
	if ( !IsLocalClientEHIValid() )
		return

	if ( LocalClientEHI() != playerEHI )
		return

	if ( !Sticker_IsTheEmpty( flavor ) )
	{
		// RequestLoadStickerPak not available
		// asset stickerAsset = Sticker_GetDecalMaterialAsset( flavor )
		// RequestLoadStickerPak( stickerAsset )
	}
}

// GetStickerSlot not available
// Function runs a check per frame to detect when the viewing player has changed. When the viewing player has changed
// load the stickers for that player.
// void function AutoLoadViewPlayerStickers()
// {
// 	entity currentPlayer = GetLocalViewPlayer()
//
// 	while(true)
// 	{
// 		// Check if the viewing player has changed.
// 		if ( currentPlayer != GetLocalViewPlayer() )
// 		{
// 			currentPlayer = GetLocalViewPlayer()
//
// 			foreach ( int stickerObjectType in eStickerObjectType )
// 			{
// 				int maxStickersForObjectType = GetMaxStickersForObjectType( stickerObjectType )
//
// 				for ( int i = 0; i < maxStickersForObjectType; i++ )
// 				{
// 					int stickerSlot = stickerObjectType * maxStickersForObjectType + i
//
// 					SettingsAssetGUID stickerLoadoutSlotGuid = currentPlayer.GetStickerSlot( stickerSlot )
// 					ItemFlavor ornull stickerItemOrNull = GetItemFlavorOrNullByGUID( stickerLoadoutSlotGuid )
//
// 					if (stickerItemOrNull == null)
// 						continue
//
// 					ItemFlavor stickerItem = expect ItemFlavor( stickerItemOrNull )
//
// 					if ( !Sticker_IsTheEmpty( stickerItem ) )
// 						RequestLoadStickerPak( Sticker_GetDecalMaterialAsset( stickerItem ) )
// 				}
// 			}
// 		}
//
// 		WaitFrame()
// 	}
// }
#endif

#if CLIENT || SERVER
int function GetStickerObjectType( string modName )
{
	switch ( modName )
	{
		case "shield_small":
			return eStickerObjectType.shield_cell

		case "shield_large":
			return eStickerObjectType.shield_battery

		case "phoenix_kit":
			return eStickerObjectType.phoenix_kit

		case "health_small":
		case "health_large":
			return eStickerObjectType.injector
	}

	return -1
}


asset function GetStickerObjectModel( int stickerObjectType )
{
	switch ( stickerObjectType )
	{
		case eStickerObjectType.shield_cell:
			return SHIELD_CELL_MODEL

		case eStickerObjectType.shield_battery:
		case eStickerObjectType.phoenix_kit:
			return SHIELD_BATTERY_MODEL

		case eStickerObjectType.injector:
			return HEALTH_INJECTOR_MODEL
	}

	Assert( false, "Unsupported stickerObjectType value " + stickerObjectType + " passed to GetStickerObjectModel()" )
	unreachable
}
#endif // CLIENT || SERVER

int function GetMaxStickersForObjectType( int stickerObjectType )
{
	if ( stickerObjectType == eStickerObjectType.injector )
		return 1

	return 3
}

#if UI
array<int> function GetAllStickerObjectTypes()
{
	array<int> stickerObjectTypes
	foreach ( int stickerObjectType in eStickerObjectType )
		stickerObjectTypes.append( stickerObjectType )

	return stickerObjectTypes
}


string function GetStickerObjectName( int stickerObjectType )
{
	switch ( stickerObjectType )
	{
		case eStickerObjectType.shield_cell:
			return "#SURVIVAL_PICKUP_HEALTH_COMBO_SMALL"

		case eStickerObjectType.shield_battery:
			return "#SURVIVAL_PICKUP_HEALTH_COMBO_LARGE"

		case eStickerObjectType.phoenix_kit:
			return "#SURVIVAL_PICKUP_HEALTH_COMBO_FULL"

		case eStickerObjectType.injector:
			return "#HEALTH_INJECTOR"
	}

	Assert( false, "Unsupported stickerObjectType value " + stickerObjectType + " passed to GetStickerObjectName()" )
	unreachable
}


int function GetStickerPresentationType( int stickerObjectType )
{
	switch ( stickerObjectType )
	{
		case eStickerObjectType.injector:
			return ePresentationType.APPLIED_STICKER_INJECTOR

		case eStickerObjectType.shield_cell:
			return ePresentationType.APPLIED_STICKER_SMALL_CELL

		case eStickerObjectType.shield_battery:
		case eStickerObjectType.phoenix_kit:
			return ePresentationType.APPLIED_STICKER_LARGE_CELL
	}

	Assert( false, "Unsupported stickerObjectType value " + stickerObjectType + " passed to GetStickerPresentationType()" )
	unreachable
}
// CreateNestedRuiForSticker implementation in sh_items.gnut
#endif // UI


LoadoutEntry function Loadout_Sticker( int stickerObjectType, int index )
{
	return fileLevel.stickerSlotMap[stickerObjectType][index]
}

// Sticker_HasStoryBlurb, Sticker_GetStoryBlurbBodyText, Sticker_IsTheEmpty implementations in sh_items.gnut

// Gets the material asset to use for a given sticker item flavor.
asset function Sticker_GetDecalMaterialAsset( ItemFlavor stickerItem )
{
	Assert( ItemFlavor_GetType( stickerItem ) == eItemType.sticker )

	return GetKeyValueAsAsset( { kn = GetGlobalSettingsAsset( ItemFlavor_GetAsset( stickerItem ), "stickerMaterial" ) + "_rgdu.rpak" }, "kn" );
}

// Gets the material asset to use for a given sticker item flavor.
asset function Sticker_GetReplacementMaterialAsset( ItemFlavor stickerItem )
{
	Assert( ItemFlavor_GetType( stickerItem ) == eItemType.sticker )

	return GetKeyValueAsAsset( { kn = GetGlobalSettingsAsset( ItemFlavor_GetAsset( stickerItem ), "nonDecalStickerMaterial" ) + "_rgdp.rpak" }, "kn" );
}

// Sticker_GetSortOrdinal implementation in sh_items.gnut

// 2-param signature (targetSlot not available)
float function Sticker_GetDecalScale( ItemFlavor stickerItem, int stickerObjectType )
{
	Assert( ItemFlavor_GetType( stickerItem ) == eItemType.sticker )

	switch ( stickerObjectType )
	{
		case eStickerObjectType.shield_cell:
			return GetGlobalSettingsFloat( ItemFlavor_GetAsset( stickerItem ), "shieldCellScale" )

		case eStickerObjectType.shield_battery:
			return GetGlobalSettingsFloat( ItemFlavor_GetAsset( stickerItem ), "shieldBatteryScale" )

		case eStickerObjectType.phoenix_kit:
			return GetGlobalSettingsFloat( ItemFlavor_GetAsset( stickerItem ), "phoenixKitScale" )

		case eStickerObjectType.injector:
			return GetGlobalSettingsFloat( ItemFlavor_GetAsset( stickerItem ), "injectorScale" )
	}

	return 0
}

#if SERVER

void function DEV_StickerTestSetupForPlayer( entity player )
{
#if DEVELOPER
	vector origin = player.GetOrigin()

	player.SetHealth( 10 )
	player.SetShieldHealth( 10 )
	SpawnGenericLoot( "health_pickup_combo_small", origin )
	SpawnGenericLoot( "health_pickup_combo_full", origin )
	SpawnGenericLoot( "health_pickup_combo_large", origin )
	SpawnGenericLoot( "health_pickup_health_small", origin )
	SpawnGenericLoot( "health_pickup_health_large", origin )
#endif
}

#endif // SERVER

#if (SERVER || CLIENT)
// This function is not in a dev block because its illegal to place Remote_RegisterServerFunction in a dev block, but we need to have
// server functions for doing the test. When calling this function only call from in a DEV block.
void function DEV_SetupStickerNetworking()
{
	Remote_RegisterServerFunction( "DEV_StickerTestSetupForPlayer" )
}
#endif

#if SERVER && DEVELOPER
void function DEV_StickerTestSetup()
{
	entity player = GP()
	vector origin = player.GetOrigin()

	player.SetHealth( 10 )
	player.SetShieldHealth( 10 )
	SpawnGenericLoot( "health_pickup_combo_small", origin )
	SpawnGenericLoot( "health_pickup_combo_full", origin )
	SpawnGenericLoot( "health_pickup_combo_large", origin )
	SpawnGenericLoot( "health_pickup_health_small", origin )
	SpawnGenericLoot( "health_pickup_health_large", origin )
}
#endif // SERVER && DEVELOPER

#if CLIENT && DEVELOPER
void function DEV_TestCreateStickerMesh( asset stickerMat )
{
	entity player = GP()
	vector origin = player.GetOrigin()
	vector angles = <0, 0, 0>

	entity model = CreateClientSidePropDynamic( origin, angles, UNAPPLIED_STICKER_MODEL )
	Sticker_SetMaterialModForLocalPlayer( model, stickerMat )
}

void function DEV_TestCreateStickerDecal( asset stickerMat, float scale )
{
	asset test_model = $"mdl/weapons/shield_battery/ptpov_shield_battery_held.rmdl"

	entity player = GP()
	vector origin = player.GetOrigin()
	vector angles = <0, 0, 0>

	entity model = CreateClientSidePropDynamic( origin, angles, test_model )
	Sticker_PlaceDecalForLocalPlayer( model, stickerMat, "STICKER_1", scale )
}

void function DEV_StickerTestSetupForLocalPlayer()
{
	Remote_ServerCallFunction( "DEV_StickerTestSetupForPlayer" )
}
#endif

// Sticker CLIENT function stubs — core sticker natives not available
#if CLIENT
int function Sticker_SetMaterialModForLocalPlayer( entity ent, asset stickerMat )
{
	// stub
	return -1
}

int function Sticker_PlaceDecalForLocalPlayer( entity ent, asset stickerMat, string attachment, float scale )
{
	// stub
	return -1
}

void function Sticker_OnPlaced( int stickerInstance, void functionref( int ) callbackFunc )
{
	// stub — immediately call callback
	callbackFunc( stickerInstance )
}

void function Sticker_CreateFlashData( int stickerInstance, entity flashEnt, int flashType, vector flashColor )
{
	// stub
}

void function Sticker_FlashOnLoadComplete( int stickerInstance )
{
	// stub
}
#endif

#if UI && DEVELOPER
void function DEV_PrintStickerLoadout()
{
	EHI playerEHI = ToEHI( GetLocalClientPlayer() )

	LoadoutEntry injectorStickerSlot = Loadout_Sticker( eStickerObjectType.injector, 0 )
	ItemFlavor injectorSticker = LoadoutSlot_GetItemFlavor( playerEHI, injectorStickerSlot )
	printt( "injectorStickerSlot contains:     ", string(ItemFlavor_GetAsset( injectorSticker )) )

	LoadoutEntry shieldCellStickerSlot = Loadout_Sticker( eStickerObjectType.shield_cell, 0 )
	ItemFlavor shieldCellSticker = LoadoutSlot_GetItemFlavor( playerEHI, shieldCellStickerSlot )
	printt( "shieldCellStickerSlot contains:   ", string(ItemFlavor_GetAsset( shieldCellSticker )) )

	LoadoutEntry shieldBatteryStickerSlot = Loadout_Sticker( eStickerObjectType.shield_battery, 0 )
	ItemFlavor shieldBatterySticker = LoadoutSlot_GetItemFlavor( playerEHI, shieldBatteryStickerSlot )
	printt( "shieldBatteryStickerSlot contains:", string(ItemFlavor_GetAsset( shieldBatterySticker )) )

	LoadoutEntry phoenixKitStickerSlot = Loadout_Sticker( eStickerObjectType.phoenix_kit, 0 )
	ItemFlavor phoenixKitSticker = LoadoutSlot_GetItemFlavor( playerEHI, phoenixKitStickerSlot )
	printt( "phoenixKitStickerSlot contains:   ", string(ItemFlavor_GetAsset( phoenixKitSticker )) )
}
#endif // UI && DEVELOPER

#if CLIENT && DEVELOPER
array<ItemFlavor>function DEV_ReturnRandomStickerFlavs( int numRandomStickers )
{
	array<ItemFlavor> stickers = GetAllItemFlavorsOfType( eItemType.sticker )
	Assert( numRandomStickers <= stickers.len(), "Tried to get more stickers than are available in the game.")
	stickers.randomize()
	return stickers.slice( 0, numRandomStickers )
}
#endif // CLIENT && DEVELOPER
