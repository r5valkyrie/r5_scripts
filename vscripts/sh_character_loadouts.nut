global function CharacterLoadouts_Init

global function CharacterLoadouts_GetDefaultWeaponLoadoutArray
global function CharacterLoadouts_GetDefaultConsumableLoadoutArray
global function CharacterLoadouts_GetDefaultEquipmentLoadoutArray

global function CharacterLoadouts_GetWeaponLoadoutArray
global function CharacterLoadouts_GetConsumableLoadoutArray
global function CharacterLoadouts_GetEquipmentLoadoutArray
global function CharacterLoadouts_SetIdenticalLoadoutIndex

global function ParseWeaponLoadoutText
global function ParseEquipmentLoadoutText
global function ParseConsumableLoadoutText

#if SERVER
global function CharacterLoadouts_GiveCurrentCharacterLoadoutToPlayer
global function CharacterLoadouts_GiveWeaponLoadoutToPlayer
global function CharacterLoadouts_GiveEquipmentLoadoutToPlayer
global function CharacterLoadouts_GiveConsumableLoadoutToPlayer

global function Ensure_Min_Loadout
global function Ensure_Min_Weapon
global function Ensure_Min_Ammo
global function Ensure_Min_Consumables
global function Get_Weapon_Datas
global function Remove_Weapons
global function Restore_Shields

#endif

global struct WeaponLoadout {
	array< string > weaponRefs
	table< string, array< string > > weaponAttachmentsByWeapon
}

struct {
	table< string, WeaponLoadout >				   characterFlavorToWeaponLoadout
	table< string, array<string> >                 characterFlavorToConsumableLoadout
	table< string, array<string> >                 characterFlavorToEquipmentLoadout

	array<string>								   	weaponLoadoutDefault
	array<string>								  	consumableLoadoutDefault
	array<string>							   		equipmentLoadoutDefault
	array<string>								   	loadoutDisplayIgnoreItemsDefault

	table< string, array<string> >				   characterFlavorToDisplayedWeaponLoadout
	table< string, array<string> >                 characterFlavorToDisplayedConsumableLoadout
	table< string, array<string> >                 characterFlavorToDisplayedEquipmentLoadout

	int identicalLoadoutIndex = -1

	#if CLIENT
		var           loadoutInfoRui = null
		array<var>    loadoutRuiElements
		table<int,string> characterClassToLoadoutNameTable

		bool		  isDetailsPanelShowing = false
		bool          is16x10 = false
	#endif
} file

void function CharacterLoadouts_Init()
{
	if ( !IsCharacterLoadoutsEnabled() )
		return

	if ( GetCurrentPlaylistVarBool( "character_loadouts_identical", false ) )
		CharacterLoadouts_SetIdenticalLoadoutIndex( 0 ) //initialize index

	#if CLIENT
		if ( GetCurrentPlaylistVarBool( "character_loadouts_class_based", false ) )
			Init_CharacterClassToLoadoutNameTable()

	#endif

	SetDefaultLoadouts()

	PopulateCharacterLoadouts()

	#if SERVER
		AddCallback_OnPlayerMatchStateChanged( OnPlayerMatchStateChanged )
		AddCallback_OnPlayerPostRespawned( OnPlayerRespawned )
	#endif

	#if CLIENT
		file.loadoutInfoRui = RuiCreate( $"ui/loadout_selection_info.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 1 )

		AddCallback_OnCharacterSelectMenuOpened( Callback_OnCharacterSelectOpened )
		AddCallback_OnCharacterSelectMenuClosed( Callback_OnCharacterSelectClosed )
		AddCallback_CharacterSelectMenu_OnCharacterFocused( Callback_OnCharacterFocusChanged )
		AddCallback_CharacterSelectMenu_OnCharacterLocked( Callback_OnCharacterLocked )
		AddCallback_OnCharacterSelectDetailsToggled( Callback_OnCharacterDetailsToggled )
	#endif
}

void function SetDefaultLoadouts()
{
	if ( GetCurrentPlaylistVarBool( "starter_kit_enabled", true ) )
	{
		string defaultweaponLoadoutsPlaylist    = GetCurrentPlaylistVarString( "default_loadout_weapons",
			"" )
		string defaultconsumableLoadoutPlaylist = GetCurrentPlaylistVarString( "default_loadout_consumables",
			"health_pickup_health_small:2 health_pickup_combo_small:2" )
		string defaultequipmentLoadoutPlaylist  = GetCurrentPlaylistVarString ( "default_loadout_equipment",
			"armor_pickup_lv1_evolving helmet_pickup_lv1 incapshield_pickup_lv1" )


			if( UpgradeCore_ArmorTiedToUpgrades() )
			{
				defaultequipmentLoadoutPlaylist = GetCurrentPlaylistVarString ( "default_loadout_equipment",
					"armor_core_pickup_lv1 helmet_pickup_lv1 incapshield_pickup_lv1" )
			}


		file.weaponLoadoutDefault = GetTrimmedSplitString( defaultweaponLoadoutsPlaylist, " " )
		file.consumableLoadoutDefault = GetTrimmedSplitString( defaultconsumableLoadoutPlaylist, " " )
		file.equipmentLoadoutDefault = GetTrimmedSplitString( defaultequipmentLoadoutPlaylist, " " )

		file.loadoutDisplayIgnoreItemsDefault.extend( file.weaponLoadoutDefault )
		file.loadoutDisplayIgnoreItemsDefault.extend( file.equipmentLoadoutDefault )


		foreach ( itemType in file.consumableLoadoutDefault )
		{
			array<string> tokens = GetTrimmedSplitString( itemType, ":" )
			string itemRef       = tokens[0]

			file.loadoutDisplayIgnoreItemsDefault.append( itemRef )
		}
	}
	else
	{
		file.weaponLoadoutDefault = []
		file.consumableLoadoutDefault = []
		file.equipmentLoadoutDefault = []
		file.loadoutDisplayIgnoreItemsDefault = []
	}


}

bool function CharacterLoadouts_GetHasInfiniteClips()
{
	return GetCurrentPlaylistVarBool( "has_infinite_clips", true )
}

bool function IsCharacterLoadoutsEnabled()
{
	if ( !GetCurrentPlaylistVarBool( "character_loadouts_enabled", true ) )
		return false

	int startTime = expect int( GetCurrentPlaylistVarTimestamp( "character_loadouts_enabled_unixTimeStart", UNIX_TIME_FALLBACK_2038 ) )
	int endTime   = expect int( GetCurrentPlaylistVarTimestamp( "character_loadouts_enabled_unixTimeEnd", UNIX_TIME_FALLBACK_2038 ) )

	if ( startTime != UNIX_TIME_FALLBACK_2038 )
	{
		int unixTimeNow = GetUnixTimestamp()
		if ( (unixTimeNow >= startTime) && (unixTimeNow < endTime) )
		{
			return true
		}
		else
		{
			return false
		}
	}

	return true
}


void function CharacterLoadouts_SetIdenticalLoadoutIndex( int index )
{
	//define loadouts in playlist
	//default loadout 1
	//character_loadout_weapons_0         "mp_weapon_vinson:optic_cq_hcog_bruiser:highcal_mag_l2:stock_tactical_l3 mp_weapon_shotgun:hopup_double_tap:optic_cq_hcog_classic"
	//character_loadout_consumables_0     "health_pickup_health_small:1 health_pickup_combo_small:1 mp_weapon_grenade_emp:2"
	//character_loadout_equipment_0       "backpack_pickup_lv2 armor_pickup_lv2 helmet_pickup_lv1 incapshield_pickup_lv1"

	Assert( index > -1 )
	file.identicalLoadoutIndex = index
}

string function GetCharacterLoadoutRef( string characterRef )
{
	array<ItemFlavor> characterList = clone GetAllCharacters()
	characterList.sort( SortByMenuButtonIndex )

	////////////////////////////////////////////
	// loadout defaults (day zero of the event)
	////////////////////////////////////////////
	table<string, int> characterDefaultLoadoutList
	for( int i = 0; i<characterList.len(); i++ )
	{
		characterDefaultLoadoutList[ ItemFlavor_GetCharacterRef( characterList[i] ).tolower() ] <- i
	}

	int characterLoadoutRefInt = 0 //default to loadout 0 if not in this list
	if ( GetCurrentPlaylistVarBool( "character_loadouts_identical", false ) )
	{
		Assert( file.identicalLoadoutIndex != -1, "Need to call CharacterLoadouts_SetIdenticalLoadoutIndex() to define character loadout for match" )
		characterLoadoutRefInt = file.identicalLoadoutIndex
		return characterLoadoutRefInt.tostring()
	}
	else if ( characterRef in characterDefaultLoadoutList )
	{
		characterLoadoutRefInt = characterDefaultLoadoutList[ characterRef ]
	}

	//////////////////////////////////////////////////////////////////////
	// increment loadout number based on number of days we've been playing
	///////////////////////////////////////////////////////////////////////
	string unixTimeEventStartString = GetCurrentPlaylistVarString( "character_loadouts_daily_cycle_start_date", "" )
	if ( unixTimeEventStartString != "" )
	{
		int unixTimeNow = GetUnixTimestamp()
		int ornull unixTimeEventStart = DateTimeStringToUnixTimestamp( unixTimeEventStartString )
		if ( unixTimeEventStart == null )
		{
			Assert( false, format( "Bad format in playlist for setting 'character_loadouts_daily_cycle_start_date': '%s'", unixTimeEventStartString ) )
			return characterLoadoutRefInt.tostring()
		}

		int maxCharacterLoadouts
		for( int i = 0; i<100; i++ )
		{
			string testVal = GetCurrentPlaylistVarString( "character_loadout_weapons_" + i, "NULL" )
			if ( testVal == "NULL" )
			{
				maxCharacterLoadouts = i
				break
			}
		}

		expect int( unixTimeEventStart )
		if ( unixTimeNow > unixTimeEventStart ) //only increment loadouts if we are actually past the start of the event
		{
			int unixTimeSinceEventStarted = ( unixTimeNow - unixTimeEventStart )
			int daysSinceEventStarted =  int( floor( unixTimeSinceEventStarted / SECONDS_PER_DAY ) )
			//daysSinceEventStarted = 5 //hardcode to test
			characterLoadoutRefInt = ( ( characterLoadoutRefInt + daysSinceEventStarted ) % maxCharacterLoadouts )
		}
	}

	return characterLoadoutRefInt.tostring()
}

WeaponLoadout function ParseWeaponLoadoutText( string loadoutText, bool useDefaultLoadout )
{
	WeaponLoadout weaponLoadout
	array< string > weaponLoadoutArray = []
	if ( loadoutText != "" )
		weaponLoadoutArray = GetTrimmedSplitString( loadoutText, " " )
	else if ( useDefaultLoadout )
		weaponLoadoutArray = file.weaponLoadoutDefault
	foreach( weapon in weaponLoadoutArray )
	{
		array<string> weaponTokens = GetTrimmedSplitString( weapon, ":" )
		string weaponRef           = weaponTokens[0]
		weaponLoadout.weaponRefs.append( weaponRef )

		weaponTokens.remove( 0 )
		array<string> attachmentsToAdd = weaponTokens

		weaponLoadout.weaponAttachmentsByWeapon[weaponRef] <- attachmentsToAdd
	}

	return weaponLoadout
}

array< string > function ParseEquipmentLoadoutText( string loadoutText, bool useDefaultLoadout, array<string> displayIgnoredItems )
{
	array<string> equipmentToAdd = []
	if ( loadoutText != "" )
		equipmentToAdd = GetTrimmedSplitString( loadoutText, " " )
	else if ( useDefaultLoadout )
		equipmentToAdd = file.equipmentLoadoutDefault

	if ( GetCurrentPlaylistVarBool( "should_give_lvl0_evo_armor", true ) )
	{
		bool give0Armor = true
		foreach ( string equipmentRef in equipmentToAdd )
		{
			if ( SURVIVAL_Loot_GetLootDataByRef( equipmentRef ).lootType == eLootType.ARMOR )
			{
				give0Armor = false
				break
			}
		}
		if ( give0Armor )
		{
			equipmentToAdd.append( "armor_pickup_lv0_evolving" )
			displayIgnoredItems.append( "armor_pickup_lv0_evolving" )
		}
	}

	return equipmentToAdd
}

array< string > function ParseConsumableLoadoutText( string loadoutText, bool useDefaultLoadout )
{
	array<string> consumableTokens = []
	if ( loadoutText != "" )
		consumableTokens = GetTrimmedSplitString( loadoutText, " " )
	else if ( useDefaultLoadout )
		consumableTokens = file.consumableLoadoutDefault
	array<string> consumablesToAdd
	foreach( itemType in consumableTokens )
	{
		array<string> tokens = GetTrimmedSplitString( itemType, ":" )
		string itemRef       = tokens[0]
		int numItems         = int( tokens[1] )

		for ( int i = 0; i < numItems; i++ )
		{
			consumablesToAdd.append( itemRef )
		}
	}

	return consumablesToAdd
}

void function PopulateCharacterLoadouts()
{
	array<ItemFlavor> characterList = GetAllCharacters()
	bool useClassBasedLoadout = GetCurrentPlaylistVarBool( "character_loadouts_class_based", false )
	table <int, string> characterClassToWeaponLoadoutTable
	table <int, string> characterClassToConsumableLoadoutTable
	table <int, string> characterClassToEquipmentLoadoutTable
	if ( useClassBasedLoadout )
	{
		string prefixWeapons = "class_loadout_weapons_"
		string prefixConsumables = "class_loadout_consumables_"
		string prefixEquipment = "class_loadout_equipment_"
		foreach ( key, value in eCharacterClassRole )
		{
			string keyString = key.tolower()
			string plString = prefixWeapons + keyString
			characterClassToWeaponLoadoutTable[ value ] <- GetCurrentPlaylistVarString( plString, "" )
			plString = prefixConsumables + keyString
			characterClassToConsumableLoadoutTable[ value ] <- GetCurrentPlaylistVarString( plString, "" )
			plString = prefixEquipment + keyString
			characterClassToEquipmentLoadoutTable[ value ] <- GetCurrentPlaylistVarString( plString, "" )
		}
	}

	foreach( character in characterList )
	{
		string characterRef = ItemFlavor_GetCharacterRef( character ).tolower()
		string characterLoadoutRef = GetCharacterLoadoutRef( characterRef )
		printf( "CHARACTER LOADOUT: Populating info for characterRef " + characterRef + " with matching loadout ref " + characterLoadoutRef )
		string weaponLoadoutsPlaylist
		string consumableLoadoutPlaylist
		string equipmentLoadoutPlaylist
		// Using a character based loadout
		if ( !useClassBasedLoadout )
		{
			weaponLoadoutsPlaylist    = GetCurrentPlaylistVarString( "character_loadout_weapons_" + characterLoadoutRef, "" )
			consumableLoadoutPlaylist = GetCurrentPlaylistVarString( "character_loadout_consumables_" + characterLoadoutRef, "" )
			equipmentLoadoutPlaylist  = GetCurrentPlaylistVarString ( "character_loadout_equipment_" + characterLoadoutRef, "" )
		}
		else // Using a character class/role based loadout
		{
			int role = CharacterClass_GetRole( character )

			Assert( role in characterClassToWeaponLoadoutTable, "Attempting to populate WeaponLoadoutsPlaylist using a Character Class that is not in characterClassToWeaponLoadoutTable" )
			Assert( role in characterClassToConsumableLoadoutTable, "Attempting to populate consumableLoadoutPlaylist using a Character Class that is not in characterClassToConsumableLoadoutTable" )
			Assert( role in characterClassToEquipmentLoadoutTable, "Attempting to populate equipmentLoadoutPlaylist using a Character Class that is not in characterClassToEquipmentLoadoutTable" )
			weaponLoadoutsPlaylist    = characterClassToWeaponLoadoutTable[ role ]
			consumableLoadoutPlaylist = characterClassToConsumableLoadoutTable[ role ]
			equipmentLoadoutPlaylist  = characterClassToEquipmentLoadoutTable[ role ]
		}

		bool useDefaultLoadout = GetCurrentPlaylistVarBool( "character_loadout_use_default", true )

		string displayIgnoreItemsRaw = GetCurrentPlaylistVarString ( "character_loadout_display_ignore_items", "" )
		array<string> displayIgnoredItems
		if ( displayIgnoreItemsRaw != "" )
			displayIgnoredItems = GetTrimmedSplitString( displayIgnoreItemsRaw, " " )
		else if ( !GetCurrentPlaylistVarBool( "character_loadout_ignore_default", false ) )
			displayIgnoredItems = file.loadoutDisplayIgnoreItemsDefault

		//parse equipment loadout
		file.characterFlavorToEquipmentLoadout[characterRef] <- ParseEquipmentLoadoutText( equipmentLoadoutPlaylist, useDefaultLoadout, displayIgnoredItems )
		array<string> equipmentToDisplay = []
		foreach ( string equipment in file.characterFlavorToEquipmentLoadout[characterRef] )
		{
			if ( !displayIgnoredItems.contains( equipment ) )
				equipmentToDisplay.append( equipment )
		}
		file.characterFlavorToDisplayedEquipmentLoadout[characterRef] <- equipmentToDisplay

		//parse weapon loadout
		file.characterFlavorToWeaponLoadout[characterRef] <- ParseWeaponLoadoutText( weaponLoadoutsPlaylist, useDefaultLoadout )
		array<string> weaponsToDisplay
		foreach( string weaponRef in file.characterFlavorToWeaponLoadout[characterRef].weaponRefs )
		{
			if ( !displayIgnoredItems.contains( weaponRef ) )
				weaponsToDisplay.append( weaponRef )
		}
		file.characterFlavorToDisplayedWeaponLoadout[characterRef] <- weaponsToDisplay


		//parse consumable loadout
		file.characterFlavorToConsumableLoadout[characterRef] <- ParseConsumableLoadoutText( consumableLoadoutPlaylist, useDefaultLoadout )
		array<string> consumablesToDisplay
		foreach( itemRef in file.characterFlavorToConsumableLoadout[characterRef] )
		{
			if ( !displayIgnoredItems.contains( itemRef ) )
				consumablesToDisplay.append( itemRef )
		}

		file.characterFlavorToDisplayedConsumableLoadout[characterRef] <- consumablesToDisplay
	}

	printf( "CHARACTER LOADOUTS: Character Loadouts populated" )
}

#if CLIENT
void function Init_CharacterClassToLoadoutNameTable()
{
	string prefix = "#CHARACTER_CLASS_LOADOUT_"
	foreach ( key, value in eCharacterClassRole )
	{
		string loadoutName = prefix + key.toupper()
		file.characterClassToLoadoutNameTable[ value ] <- loadoutName
	}
}
#endif // CLIENT

#if SERVER
void function OnPlayerMatchStateChanged( entity player, int oldValue, int newValue )
{
	bool defaultSetting = GetCurrentPlaylistVarBool( "should_give_lvl0_evo_armor", true )

	if ( !GetCurrentPlaylistVarBool( "should_give_character_loadout_on_survival_ship_skydive", defaultSetting ) )
		return

	if ( IsValid( player ) && newValue == ePlayerMatchState.SKYDIVE_FALLING && GetTotalNumberOfDeaths( player ) == 0 ) // For modes with respawns, make sure this isn't a respawn skydive ( those loadouts should be awarded through the should_give_character_loadout_on_spawn_and_respawn playlist var )
	{
		CharacterLoadouts_GiveCurrentCharacterLoadoutToPlayer( player, true )
	}
}


void function OnPlayerRespawned( entity player )
{
	bool defaultSetting = GetCurrentPlaylistVarBool( "should_give_lvl0_evo_armor", true )
	if ( !GetCurrentPlaylistVarBool( "should_give_character_loadout_on_spawn_and_respawn", defaultSetting ) )
		return








	// If we're running the option of not resetting the inventory on a dev playlist with the playlist var "dev_loadout_bypass_match_state",
	// repeated respawns calling GrantLoadoutOnRespawnThread will accumulate heals and cells.
	if( !Survival_ShouldResetInventoryOnRespawn( player ) )
		return










	GrantLoadoutOnRespawnThread( player )
}

void function GrantLoadoutOnRespawnThread( entity player )
{
	if ( IsValid( player ) )
	{
		bool doGranting = GetCurrentPlaylistVarBool( "dev_loadout_bypass_match_state", false )
		CharacterLoadouts_GiveCurrentCharacterLoadoutToPlayer( player, doGranting )
	}
}
#endif


#if SERVER
void function CharacterLoadouts_GiveCurrentCharacterLoadoutToPlayer( entity player, bool bypassMatchStateCheck = false )
{
	Assert( IsValidPlayer( player ), "CHARACTER LOADOUTS: Trying to give loadout to invalid player" )
	Assert( IsAlive( player ), "CHARACTER LOADOUTS: Trying to give loadout to player who is not alive" )

	if ( !bypassMatchStateCheck && PlayerMatchState_GetFor( player ) != ePlayerMatchState.NORMAL )
		return

	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	string characterRef  = ItemFlavor_GetCharacterRef( character ).tolower()

	if ( !(characterRef in file.characterFlavorToWeaponLoadout) )
	{
		printf( "CHARACTER LOADOUTS: Player Character " + characterRef + " does not have a playlist-defined loadout" )
		return
	}

	CharacterLoadouts_GiveWeaponLoadoutToPlayer( player, file.characterFlavorToWeaponLoadout[characterRef], characterRef )
	CharacterLoadouts_GiveEquipmentLoadoutToPlayer( player, file.characterFlavorToEquipmentLoadout[characterRef] )
	CharacterLoadouts_GiveConsumableLoadoutToPlayer( player, file.characterFlavorToConsumableLoadout[characterRef] )

	player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_0 )
}
#endif

#if SERVER
void function CharacterLoadouts_GiveWeaponLoadoutToPlayer( entity player, WeaponLoadout weaponLoadout, string debugLoadoutName = "", bool doFirstDeploy = true )
{
	const int MAX_MAIN_WEAPON_COUNT = 2
	Assert( weaponLoadout.weaponRefs.len() <= MAX_MAIN_WEAPON_COUNT, "CHARACTER LOADOUTS: More than " + MAX_MAIN_WEAPON_COUNT + " weapons defined in playlist for loadout " + debugLoadoutName )

	array<entity> mainSlotWeapons = player.GetMainWeapons()
	entity meleeWeapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_2 )
	mainSlotWeapons.removebyvalue( meleeWeapon )

	int currentWeaponCount = mainSlotWeapons.len()
	int weaponsToAdd = weaponLoadout.weaponRefs.len()

	if ( ( weaponsToAdd + currentWeaponCount ) > MAX_MAIN_WEAPON_COUNT )
	{
		Warning( "CHARACTER LOADOUTS: Attempting to add " + weaponsToAdd + " weapons to a character that already has " + currentWeaponCount + " weapons, skipping weapon loadout." )
		foreach ( weapon in mainSlotWeapons )
			Warning( "Current weapon: " + weapon.GetWeaponClassName() )
		foreach ( ref in weaponLoadout.weaponRefs )
			Warning( "Will not add: " + ref )
		return
	}

	for ( int i = 0; i < weaponLoadout.weaponRefs.len(); i++ )
	{
		string weaponRef = weaponLoadout.weaponRefs[i]

		LootData ld    = SURVIVAL_Loot_GetLootDataByRef( weaponRef )
		weaponRef = ld.baseWeapon

		entity weapon   = player.GiveWeapon( weaponRef, ( i + currentWeaponCount ), ld.baseMods, doFirstDeploy )

		// Ensure we set the weapon properly to a locked set weapon if this mode uses locked sets
		if ( ShouldRestoreKittedWeapons() )
			SetWeaponLockedSetFromLootTags( ld.lootTags, weapon )

		if ( weaponRef in weaponLoadout.weaponAttachmentsByWeapon )
		{
			array<string> mods = []
			mods.extend( SURVIVAL_Weapon_GetBaseMods( weaponRef ) )
			weapon.SetMods( mods )

			mods = weapon.GetMods()
			array<string> modsCopy = clone mods
			foreach ( mod in modsCopy )
			{
				if ( !SURVIVAL_Loot_IsRefValid( mod ) )
					continue

				LootData data = SURVIVAL_Loot_GetLootDataByRef( mod )
				if ( data.lootType == eLootType.ATTACHMENT && CanAttachmentEquipToOneOfAttachPoints( mod, ["hopup", "hopupMulti_a", "hopupMulti_b"] ) )
					ApplyDefaultToggledMods( weapon.GetWeaponClassName(), mod, mods )
			}
			VerifyToggleMods( mods )

			weapon.SetMods( mods )

			foreach( attachmentRef in weaponLoadout.weaponAttachmentsByWeapon[weaponRef] )
			{
				AttachToWeapon( player, weapon, attachmentRef, "", false, false, true, false, null, false )
			}
		}

		if ( weapon.GetActiveAmmoSource() == AMMOSOURCE_STOCKPILE && weapon.UsesClipsForAmmo() )
		{
			weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )

			if ( CharacterLoadouts_GetHasInfiniteClips() )
				SetInfiniteAmmoForWeapon ( player, weapon, true )
		}
		else
		{
			if ( weapon.UsesClipsForAmmo() )
			{
				weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
			}

			if ( CharacterLoadouts_GetHasInfiniteClips() )
				SetInfiniteAmmoForWeapon ( player, weapon, true )

			string ammoRef = GetWeaponAmmoType( weaponRef )
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

		//skins and charms for weapon
		ItemFlavor ornull weaponItemOrNull = GetWeaponItemFlavorByClass( weaponRef )
		ItemFlavor ornull weaponSkinOrNull = null
		if ( weapon.e.skinItemFlavorGUID != ASSET_SETTINGS_UNIQUE_ID_INVALID )
		{
			weaponSkinOrNull = GetItemFlavorByGUID( weapon.e.skinItemFlavorGUID )
		}
		else
		{
			if ( weaponItemOrNull != null )
			{
				weaponSkinOrNull = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_WeaponSkin( expect ItemFlavor(weaponItemOrNull) ) )
			}
		}

		ItemFlavor ornull weaponCharmOrNull = null
		if ( weapon.e.charmItemFlavorGUID != ASSET_SETTINGS_UNIQUE_ID_INVALID )
		{
			weaponCharmOrNull = GetItemFlavorByGUID( weapon.e.charmItemFlavorGUID )
		}
		else
		{
			if ( weaponItemOrNull != null )
			{
				weaponCharmOrNull = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_WeaponCharm( expect ItemFlavor(weaponItemOrNull) ) )
			}
		}

		if ( weaponSkinOrNull != null || weaponCharmOrNull != null )
			WeaponCosmetics_Apply( weapon, weaponSkinOrNull, weaponCharmOrNull )
	}
}
#endif

#if SERVER
void function CharacterLoadouts_GiveEquipmentLoadoutToPlayer( entity player, array < string > equipmentLoadout )
{
	foreach( equipment in equipmentLoadout )
	{
		LootData data    = SURVIVAL_Loot_GetLootDataByRef( equipment )
		Assert( GetLootTypeData( data.lootType ).equipmentSlot != "", "Non-equipment item specified in default equipment loadout. Try using the default weapon or consumable loadout instead." )

		SURVIVAL_GivePlayerEquipment( player, equipment, 0, null, "", false )
	}

	string itemRef = EquipmentSlot_GetLootRefForSlot( player, "armor" )
	if ( SURVIVAL_Loot_IsRefValid( itemRef ) )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByRef( itemRef )
		player.SetShieldHealthMax( SURVIVAL_GetCharacterShieldHealthMaxForArmor( player, data ) )
		player.SetShieldHealth( SURVIVAL_GetCharacterShieldHealthMaxForArmor( player, data ) )

		if ( EvolvingArmor_IsEquipmentEvolvingArmor( itemRef ) )
			EvolvingArmor_SetEvolutionProgress( player, EvolvingArmor_GetRequirementForEvolution( data.tier ) )
	}
}
#endif

#if SERVER
void function CharacterLoadouts_GiveConsumableLoadoutToPlayer( entity player, array < string > consumableLoadout )
{
	foreach( consumable in consumableLoadout )
	{
		SURVIVAL_AddToPlayerInventory( player, consumable, 1 )

		// Bug fix (http://jiratf.respawn.net:8080/browse/R5DEV-145402)
		// so we don't auto-equip an mrb after respawning.
		if ( consumable == "mp_ability_mobile_respawn_beacon" )
		{
			continue
		}

		LootData data = SURVIVAL_Loot_GetLootDataByRef( consumable )
		if ( data.lootType == eLootType.ORDNANCE )
		{
			SURVIVAL_EquipOrdnanceFromInventory( player, consumable, true )
		}
	}
}
#endif


#if CLIENT
void function Callback_OnCharacterSelectOpened()
{
	file.is16x10 = GetNearestAspectRatio( GetScreenSize().width, GetScreenSize().height ) == 1.6

	RuiSetBool( file.loadoutInfoRui, "isVisible", true )
	RuiSetBool( file.loadoutInfoRui, "is16x10", file.is16x10 )

	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( GetLocalClientPlayer() ), Loadout_Character() )
	DisplayLoadoutForCharacter( character )
}

void function Callback_OnCharacterSelectClosed()
{
	RuiSetBool( file.loadoutInfoRui, "isVisible", false )

	foreach( ruiAsset in file.loadoutRuiElements )
	{
		RuiDestroy( ruiAsset )
	}
	file.loadoutRuiElements.clear()

}

void function Callback_OnCharacterFocusChanged( ItemFlavor character )
{
	DisplayLoadoutForCharacter( character )
}

void function Callback_OnCharacterLocked( ItemFlavor character )
{
	DisplayLoadoutForCharacter( character )
}

void function Callback_OnCharacterDetailsToggled( bool isDetailsPanelVisible )
{
	if ( file.loadoutInfoRui == null )
		return

	file.isDetailsPanelShowing = !isDetailsPanelVisible

	RuiSetBool( file.loadoutInfoRui, "isDetailMode", !isDetailsPanelVisible )
	foreach( rui in file.loadoutRuiElements )
	{
		RuiSetBool( rui, "isDetailMode", !isDetailsPanelVisible )
	}
}

string function GetIdenticalLoadoutCharSelectPrefix()
{
	string playlistName = GetCurrentPlaylistName()
	if ( playlistName.find( "freelance" ) >= 0 )
		return ""

	return Localize( "#DEFAULT_CHAR_SELECT_LOADOUT_PREFIX" )
}

void function DisplayLoadoutForCharacter( ItemFlavor character )
{
	string characterRef = ItemFlavor_GetCharacterRef( character ).tolower()

	//clear out old icons
	foreach( ruiAsset in file.loadoutRuiElements )
	{
		RuiDestroy( ruiAsset )
	}
	file.loadoutRuiElements.clear()

	bool shouldShowLoadout = file.characterFlavorToDisplayedWeaponLoadout[characterRef].len() > 0 ||
	file.characterFlavorToDisplayedConsumableLoadout[characterRef].len() > 0 ||
	file.characterFlavorToDisplayedEquipmentLoadout[characterRef].len() > 0

	//do not show loadout if character does not have one
	if ( !shouldShowLoadout )
	{
		RuiSetBool( file.loadoutInfoRui, "isVisible", false )
		return
	}
	else
	{
		RuiSetBool( file.loadoutInfoRui, "isVisible", true )
	}

	if ( GetCurrentPlaylistVarBool( "character_loadouts_identical", false ) )
	{
		RuiSetString( file.loadoutInfoRui, "characterLoadoutName", GetIdenticalLoadoutCharSelectPrefix() )
	}
	else if ( GetCurrentPlaylistVarBool( "character_loadouts_class_based", false ) )
	{
		int role = CharacterClass_GetRole( character )
		Assert( role in file.characterClassToLoadoutNameTable[ role ], "Attempting to DisplayLoadoutForCharacter using a Character Class that is not in characterClassToLoadoutNameTable" )
		RuiSetString( file.loadoutInfoRui, "characterLoadoutName", Localize( file.characterClassToLoadoutNameTable[ role ] ) )
	}
	else
	{
		RuiSetString( file.loadoutInfoRui, "characterLoadoutName", Localize( "#" + characterRef + "_NAME" ) )
	}

	//populate weapon inventory
	for ( int i = 0; i < file.characterFlavorToDisplayedWeaponLoadout[characterRef].len(); i++ )
	{
		string weaponRef    = file.characterFlavorToDisplayedWeaponLoadout[characterRef][i]
		LootData weaponData = SURVIVAL_Loot_GetLootDataByRef( weaponRef )
		var weaponRuiAsset  = RuiCreate( $"ui/loadout_selection_icon_weapon.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 1 )

		RuiSetBool( weaponRuiAsset, "isDetailMode", file.isDetailsPanelShowing )
		RuiSetAsset( weaponRuiAsset, "iconImage", weaponData.hudIcon )
		RuiSetInt( weaponRuiAsset, "weaponIndex", i )
		if ( ShouldShrinkWeaponIcon( weaponRef ) )
			RuiSetFloat2( weaponRuiAsset, "iconSize", <150, 75, 0.0> )

		string ammoRef = GetWeaponAmmoType( weaponRef )
		if ( ammoRef != "" )
		{
			//Crate weapons won't have ammoRefs
			LootData ammoData = SURVIVAL_Loot_GetLootDataByRef( ammoRef )
			RuiSetAsset( weaponRuiAsset, "ammoImage", ammoData.hudIcon )
		}

		RuiSetString( weaponRuiAsset, "weaponName", Localize( "#WPN_" + weaponData.baseWeapon.slice(10) + "_SHORT" ) )

		file.loadoutRuiElements.append( weaponRuiAsset )

		//populate attachments for weapon
		array<string> attachmentRefs
		if( !SURVIVAL_Weapon_IsAttachmentLocked ( weaponRef ) )
		{
			attachmentRefs = file.characterFlavorToWeaponLoadout[characterRef].weaponAttachmentsByWeapon[weaponRef]
		}
		else
		{
			attachmentRefs = SURVIVAL_Weapon_GetBaseMods( weaponRef )
		}
		int attachmentSlot = 0
		for ( int j = 0; j < attachmentRefs.len(); j++ )
		{
			if ( !SURVIVAL_Loot_IsRefValid( attachmentRefs[j] ) )
				continue
			LootData attachmentData = SURVIVAL_Loot_GetLootDataByRef( attachmentRefs[j] )
			var attachmentRuiAsset  = RuiCreate( $"ui/loadout_selection_icon_attachment.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 1 )

			RuiSetBool( attachmentRuiAsset, "isDetailMode", file.isDetailsPanelShowing )
			RuiSetAsset( attachmentRuiAsset, "iconImage", attachmentData.hudIcon )
			RuiSetInt( attachmentRuiAsset, "attachmentIndex", attachmentSlot )
			RuiSetInt( attachmentRuiAsset, "weaponIndex", i )
			RuiSetInt( attachmentRuiAsset, "lootTier", attachmentData.tier )

			attachmentSlot++

			file.loadoutRuiElements.append( attachmentRuiAsset )
		}
	}

	//populate equipment
	for ( int i = 0; i < file.characterFlavorToDisplayedEquipmentLoadout[characterRef].len(); i++ )
	{
		string equipmentRef    = file.characterFlavorToDisplayedEquipmentLoadout[characterRef][i]
		LootData equipmentData = SURVIVAL_Loot_GetLootDataByRef( equipmentRef )
		var equipmentRuiAsset  = RuiCreate( $"ui/loadout_selection_icon_equipment.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 1 )

		RuiSetBool( equipmentRuiAsset, "isDetailMode", file.isDetailsPanelShowing )
		RuiSetAsset( equipmentRuiAsset, "iconImage", equipmentData.hudIcon )
		RuiSetInt( equipmentRuiAsset, "lootTier", equipmentData.tier )
		RuiSetInt( equipmentRuiAsset, "equipmentIndex", i )

		file.loadoutRuiElements.append( equipmentRuiAsset )
	}

	//populate consumables
	table<string, int> trackedConsumableCount
	table<string, var> trackConsumableRuiAssets
	int consumableCounter = 0
	int equipmentIndex = -1
	for ( int i = 0; i < file.characterFlavorToDisplayedConsumableLoadout[characterRef].len(); i++ )
	{
		string consumableRef    = file.characterFlavorToDisplayedConsumableLoadout[characterRef][i]

		if ( consumableRef in trackedConsumableCount )
		{
			trackedConsumableCount[consumableRef]++
			RuiSetInt( trackConsumableRuiAssets[consumableRef], "itemCount", trackedConsumableCount[consumableRef] )
		}
		else
		{
			LootData consumableData = SURVIVAL_Loot_GetLootDataByRef( consumableRef )
			var consumableRuiAsset  = RuiCreate( $"ui/loadout_selection_icon_equipment.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 1 )
			if ( equipmentIndex == -1 )
				equipmentIndex = i
			else
				equipmentIndex++
			RuiSetBool( consumableRuiAsset, "isDetailMode", file.isDetailsPanelShowing )
			RuiSetAsset( consumableRuiAsset, "iconImage", consumableData.hudIcon )
			RuiSetInt( consumableRuiAsset, "lootTier", consumableData.tier )
			RuiSetInt( consumableRuiAsset, "equipmentIndex", equipmentIndex )
			RuiSetBool( consumableRuiAsset, "isConsumable", true )

			trackedConsumableCount[consumableRef] <- 1
			trackConsumableRuiAssets[consumableRef] <- consumableRuiAsset

			file.loadoutRuiElements.append( consumableRuiAsset )
			consumableCounter++
		}
	}

	foreach( ruiAsset in file.loadoutRuiElements )
		RuiSetBool( ruiAsset, "is16x10", file.is16x10 )

}

bool function ShouldShrinkWeaponIcon( string weaponRef )
{
	//if ( weaponRef == "mp_weapon_defender" )
		//return true

	return false
}
#endif

array<string> function CharacterLoadouts_GetDefaultWeaponLoadoutArray()
{
	return file.weaponLoadoutDefault
}

array<string> function CharacterLoadouts_GetDefaultConsumableLoadoutArray()
{
	return file.consumableLoadoutDefault
}

array<string> function CharacterLoadouts_GetDefaultEquipmentLoadoutArray()
{
	return file.equipmentLoadoutDefault
}

array<string> function CharacterLoadouts_GetWeaponLoadoutArray( ItemFlavor character )
{
	return file.characterFlavorToWeaponLoadout[ItemFlavor_GetCharacterRef( character ).tolower()].weaponRefs
}

array<string> function CharacterLoadouts_GetConsumableLoadoutArray( ItemFlavor character )
{
	return file.characterFlavorToConsumableLoadout[ItemFlavor_GetCharacterRef( character ).tolower()]
}

array<string> function CharacterLoadouts_GetEquipmentLoadoutArray( ItemFlavor character )
{
	return file.characterFlavorToEquipmentLoadout[ItemFlavor_GetCharacterRef( character ).tolower()]
}

// -------------------
// Minimum Equipment Functions: These functions can be used to ensure the player is given minimal items.
// -------------------

#if SERVER
void function Ensure_Min_Loadout( entity player )
{
	if( !IsValidPlayer( player ) )
		return

	Ensure_Min_Weapon( player )
	Ensure_Min_Consumables( player )

}
#endif // SERVER


#if SERVER
void function Ensure_Min_Weapon( entity player )
{
	if( !IsValidPlayer( player ) )
		return

	// Check for weapons. If no weapons, give a pistol.
	int weaponCount = SURVIVAL_GetPrimaryWeaponsSorted( player ).len()
	if( weaponCount == 0 )
	{
		string weaponRef = "mp_weapon_semipistol"
		LootData weaponData = SURVIVAL_Loot_GetLootDataByRef( weaponRef )

		entity newActiveWeapon = SpawnGenericLoot( weaponRef, player.GetOrigin(), player.GetAngles(), -1 )
		array<string> lootTags = weaponData.lootTags
		SURVIVAL_GiveMainWeapon( player, newActiveWeapon, lootTags, null, false, null, false, false, [], true )
		newActiveWeapon.Destroy()
	}
	Ensure_Min_Ammo( player )
}
#endif // SERVER

#if SERVER
// This function fills up the player's guns, and also gives them stacks of ammo for their weapons if the player does not have any.
void function Ensure_Min_Ammo( entity player )
{
	if( !IsValidPlayer( player ) )
		return

	// Only give ammo stacks if the player doesn't have infinite ammo
	if ( !player.p.infiniteGameModeAmmo && !player.p.infiniteAmmo )
	{
		// Full mag in each weapon.
		array< entity > playerWeapons = SURVIVAL_GetPrimaryWeaponsSorted( player )
		array< LootData > weaponDatas
		foreach( weaponEnt in playerWeapons )
		{
			string weaponName = weaponEnt.GetWeaponBaseClassName()
			if ( ( weaponName != "mp_weapon_lstar" ) && !weaponEnt.UsesClipsForAmmo() && weaponEnt.GetActiveAmmoSource() == AMMOSOURCE_POOL )
			{
				if ( weaponName == "mp_weapon_bow" )
				{
					weaponEnt.SetWeaponPrimaryAmmoCount( AMMOSOURCE_STOCKPILE, 30 )
				}
				else if ( weaponName == "mp_weapon_throwingknife" )
				{
					weaponEnt.SetWeaponPrimaryAmmoCount( AMMOSOURCE_STOCKPILE, 1 )
				}
			}
			else if( weaponName == "mp_weapon_lstar" )
			{
				weaponEnt.SetWeaponPrimaryAmmoCount( AMMOSOURCE_STOCKPILE, 80 )
				weaponDatas.append( SURVIVAL_Loot_GetLootDataByRef( weaponName ) )
			}
			else
			{
				int ammoCount = weaponEnt.GetWeaponPrimaryClipCountMax()
				weaponEnt.SetWeaponPrimaryClipCount( ammoCount )
				weaponDatas.append( SURVIVAL_Loot_GetLootDataByRef( weaponName ) )
			}

		}

		array< string > AmmoTypesForReload
		AmmoTypesForReload.append( "bullet" )
		AmmoTypesForReload.append( "highcal" )
		AmmoTypesForReload.append( "shotgun" )
		AmmoTypesForReload.append( "sniper" )
		AmmoTypesForReload.append( "special" )

		table< string, int > ammoBoxStackByType
		ammoBoxStackByType[ "bullet" ] 	<- 4 // was 3
		ammoBoxStackByType[ "highcal" ] <- 4 // was 3
		ammoBoxStackByType[ "shotgun" ] <- 3 // was 2
		ammoBoxStackByType[ "sniper" ] 	<- 3 // was 2
		ammoBoxStackByType[ "special" ] <- 4 // was 3


			if( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_BATTLE_RUSH ) )
			{
				ammoBoxStackByType[ "bullet" ] 	<- 2
				ammoBoxStackByType[ "highcal" ] <- 2
				ammoBoxStackByType[ "shotgun" ] <- 2
				ammoBoxStackByType[ "sniper" ] 	<- 2
				ammoBoxStackByType[ "special" ] <- 2
			}


		// Count ammo in inventory.
		array< ConsumableInventoryItem > playerInventory = SURVIVAL_GetPlayerInventory( player )
		array< string > refs_Inventory = SURVIVAL_ConsumableInventoryItems_To_ItemRefs( playerInventory )
		table< string, int > counts_Inventory = Count_Strings_IntoTable( refs_Inventory )

		// Give a full ammo stack by each weapon's ammo type if player has none.
		foreach( weaponData in weaponDatas )
		{
			int ammoBoxesStack
			string ammoType = weaponData.ammoType

			// If the ammo type isn't a reload type, skip to next weapon.
			if( !( ammoType in ammoBoxStackByType ) )
				continue

			bool playerHasAmmo = ammoType in counts_Inventory
			bool playerNeedsAmmo = !playerHasAmmo

			int ammoStacksToGive
			int ammoToGive

			int stackSize = SURVIVAL_Loot_GetLootDataByRef( ammoType ).countPerDrop
			if( playerHasAmmo )
			{

				int ammoInInventory = counts_Inventory[ ammoType ]
				int ammoMin = stackSize * ammoBoxStackByType[ ammoType ]

				if( ammoInInventory < ammoMin  )
				{
					playerNeedsAmmo = true
					ammoToGive = ammoMin - ammoInInventory
					ammoStacksToGive = ( ammoMin - ammoInInventory ) / stackSize
				}
			}
			else
			{
				playerNeedsAmmo = true
				ammoStacksToGive = ammoBoxStackByType[ ammoType ]
				ammoToGive = stackSize * ammoStacksToGive
			}

			if( playerNeedsAmmo )
			{
				GiveLoot( player, ammoType, ammoToGive )
			}
		}
	}
}
#endif // SERVER

#if SERVER
void function Ensure_Min_Consumables( entity player, array< string > refsInventoryParm = [], bool doDevOut = false )
{
	if( !IsValidPlayer( player ) )
		return

	// 		1. Get CharacterLoadouts_GetConsumableLoadoutArray() for player's current character, and count its occurrences of cells, syringes, etc.
	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	array< string > refs_Default = CharacterLoadouts_GetConsumableLoadoutArray( character )
	table< string, int > counts_Default = Count_Strings_IntoTable( refs_Default )

	// 		2. Get player's inventory and count its occurrences of cells, syringes, etc.
	array< ConsumableInventoryItem > playerInventory = SURVIVAL_GetPlayerInventory( player )
	array< string > refs_Inventory
	if( refsInventoryParm.len() == 0 )
	{
		refs_Inventory = SURVIVAL_ConsumableInventoryItems_To_ItemRefs( playerInventory )
	}
	else
	{
		refs_Inventory = refsInventoryParm
	}
	table< string, int > counts_Inventory = Count_Strings_IntoTable( refs_Inventory )

	// 		3. Compare counts and construct counts of items to top off.
	array< string > itemRefs_ToGive
	foreach( itemRef, itemCount_Default in counts_Default )
	{
		int itemCount_ToGive = 0
		if( !( itemRef in counts_Inventory ) )
		{
			itemCount_ToGive = itemCount_Default
		}
		else if( itemCount_Default > counts_Inventory[ itemRef ] )
		{
			itemCount_ToGive = itemCount_Default - counts_Inventory[ itemRef ]
		}
		else
		{
			itemCount_ToGive = 0
		}

		if( itemCount_ToGive > 0 )
		{
			#if DEVELOPER
				if( doDevOut )
				{
					printt( FUNC_NAME() + "(): Giving " + itemCount_ToGive + " " + itemRef )
				}
			#endif

			for( int i = 0; i < itemCount_ToGive; i++ )
			{
				itemRefs_ToGive.append( itemRef )
			}
		}
	}

	// 		4. Give items to top off.
	if( itemRefs_ToGive.len() > 0 )
	{
		CharacterLoadouts_GiveConsumableLoadoutToPlayer( player, itemRefs_ToGive )
	}
}

array< LootData > function Get_Weapon_Datas( entity player )
{
	array< LootData > weaponsDatas
	if( !IsValidPlayer( player ) )
		return weaponsDatas

	array< entity > weaponEnts = SURVIVAL_GetPrimaryWeapons( player )
	foreach( weaponEnt in weaponEnts )
	{
		LootData wData = SURVIVAL_GetLootDataFromWeapon( weaponEnt )
		weaponsDatas.append( wData )
	}

	return weaponsDatas
}

array< LootData > function Remove_Weapons( entity player, bool devOut = false )
{
	array< LootData > playerWeaponsData
	if( !IsValidPlayer( player ) )
		return playerWeaponsData

	#if DEVELOPER
		if( devOut )
		{
			printt( FUNC_NAME() + "(): Remove_Weapons for " + player.GetPlayerName() )
		}
	#endif // DEV

	playerWeaponsData  = Get_Weapon_Datas( player )
	array< string > playerWeaponRefs = LootDatas_To_LootRefs( playerWeaponsData )
	#if DEVELOPER
		if( devOut )
		{
			foreach( wpRef in playerWeaponRefs )
			{
				printt( FUNC_NAME() + "(): " + player.GetPlayerName() + " weapon == " + wpRef )
			}
			printt( "-----" )
		}
	#endif // DEV

	foreach( ref in playerWeaponRefs)
	{
		player.TakeWeaponNow( ref )
	}
	SURVIVAL_TryGivePlayerDefaultMeleeWeapons( player )

	// TODO: CLEANUP if not needed
	// Reset primary weapon netvars
	player.SetPlayerNetInt( "playerPrimaryWeapon0", -1 )
	player.SetPlayerNetInt( "playerPrimaryWeapon1", -1 )

	#if DEVELOPER
		if( devOut )
		{
			printt( FUNC_NAME() + "(): After Weapon Removal: " + player.GetPlayerName() )
			array< LootData > checkWeaponsData = Get_Weapon_Datas( player )
			foreach( wpData in checkWeaponsData )
			{
				printt( FUNC_NAME() + "(): " + player.GetPlayerName() + " weapon == " + wpData.ref )
			}
		}
	#endif // DEV

	return playerWeaponsData
}

void function Restore_Shields( entity player )
{
	if( !IsValidPlayer( player ) )
		return


		string ref = UpgradeCore_GetPlayerShieldCoreRef( player )
		Inventory_SetPlayerEquipment( player, ref, "armor" )



}


#endif // SERVER