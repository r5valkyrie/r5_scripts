global function ShMythics_LevelInit

global function RegisterMythicBundlesForCharacter

global function Mythics_CharacterHasMythic
global function Mythics_SkinHasCustomExecution
global function Mythics_IsCustomExecutionUnlocked
global function Mythics_ShouldForceCustomExecution
global function Mythics_GetChallengeForCharacter
global function Mythics_IsItemFlavorMythic
global function Mythics_IsItemFlavorMythicSkin
global function Mythics_GetSkinTierForCharacter
global function Mythics_GetItemTierForSkin
global function Mythics_GetSkinTierIntForSkin
global function Mythics_GetAllSkinsFromBase
global function Mythics_GetChallengeGUIDForSkinGUID
global function Mythics_GetChallengeForSkin
global function Mythics_GetNumTiersUnlockedForSkin
global function Mythics_GetCustomExecutionForCharacterOrSkin
global function Mythics_IsCustomExecutionInMythicBundle
global function Mythics_GetCharacterSkinForCustomExecution
global function Mythics_GetCharacterForSkin
global function Mythics_GetMythicSkinGUIDsForCharacter
global function Mythics_GetStoreImageForCharacter
global function Mythics_GetSkinBaseNameForCharacter
global function Mythics_SkinHasCustomSkydivetrail
global function Mythics_GetCustomSkydivetrailForCharacterOrSkin
global function Mythics_IsExecutionUsableOnTier1AndTier2

#if SERVER
global function Mythics_RegisterBoostedMythicChallengeForPlayer
global function Mythics_UnregisterBoostedMythicChallengesForPlayer
global function Mythics_GetPlayerBoostedMythicChallenges
global function Mythics_GetBoostEnabledChallengeProgressMade
#endif // SERVER

#if UI
global function Mythics_ToggleTrackChallenge
global function Mythics_UpdateTrackingButton
#endif
struct FileStruct_LifetimeLevel
{
	table< int, int > mythicSkinsGUIDToCustomExecutionGUID
	table< int, int > mythicSkinsGUIDToCustomSkydivetrailGUID
	table< int, int > mythicCharactersGUIDToChallengesGUID
	table< int, bool > mythicCharactersGUIDToExecutionUsableOnTier1And2
	table< int, int > customExecutionGUIDToMythicSkinsGUID

	table< int, array< int > > charactersGUIDToMythicSkinGUIDs
	table< int, array< asset > > charactersGUIDToStoreImages
	table< int, string > charactersGUIDToSkinBaseName
	ItemFlavor ornull currentChallenge
	table< entity, array< ItemFlavor > > mythicBoostedChallenges
}
FileStruct_LifetimeLevel& fileLevel

global struct Mythic_ChallengeProgress
{
	ItemFlavor& challenge
	int challengeProgress
	int statMarker
}

const int CHALLENGE_SORT_ORDINAL = 0 // only support a single challenge per mythic for now
const int FINAL_TIER = 3

void function ShMythics_LevelInit()
{
	FileStruct_LifetimeLevel newFileLevel
	fileLevel = newFileLevel
}

void function RegisterMythicBundlesForCharacter( ItemFlavor characterClass )
{
	int characterGUID = ItemFlavor_GetGUID( characterClass )

	array<ItemFlavor> mythicBundlesList = RegisterReferencedItemFlavorsFromArray( characterClass, "mythicBundles", "flavor" )

	Assert ( mythicBundlesList.len() <= 1, "Character " + string(ItemFlavor_GetAsset( characterClass )) + " has more than one Mythic bundle registered." )

	if ( mythicBundlesList.len() == 0 )
		return

	ItemFlavor mythicBundleFlav = mythicBundlesList[0]
	asset mythicBundleAsset = ItemFlavor_GetAsset( mythicBundleFlav )
	var settingsBlock = GetSettingsBlockForAsset( mythicBundleAsset )
	asset challengeAsset = GetSettingsBlockAsset( settingsBlock, "challengeAsset" )
	asset executionAsset = GetSettingsBlockAsset( settingsBlock, "executionAsset" )
	asset skydivetrailAsset = GetSettingsBlockAsset( settingsBlock, "skydivetrailAsset" )
	var skinDataArray = GetSettingsBlockArray( settingsBlock, "skinsByTier" )

	array< asset > skinAssets
	array< int > skinGUIDs
	int tierIdx = 1
	int preRegGUID
	foreach ( var skinBlock in IterateSettingsArray( skinDataArray ) )
	{
		asset entryAsset = GetSettingsBlockAsset( skinBlock, "skinAsset" )
		skinAssets.append( entryAsset )
		skinGUIDs.append( GetUniqueIdForSettingsAsset( entryAsset ) )

		if ( tierIdx == 1 )
		{
			preRegGUID = GetUniqueIdForSettingsAsset( entryAsset )
			if ( skydivetrailAsset != $"" )
			{
				SettingsAssetGUID skydiveGUID = GetUniqueIdForSettingsAsset( skydivetrailAsset )
				ItemFlavor ornull skydiveFlavOrNull = RegisterItemFlavorFromSettingsAsset( skydivetrailAsset )
				if ( skydiveFlavOrNull != null && IsValidItemFlavorGUID( skydiveGUID ) )
					fileLevel.mythicSkinsGUIDToCustomSkydivetrailGUID[ preRegGUID ] <- skydiveGUID
			}
		}
		else if ( tierIdx == FINAL_TIER )
		{
			int skinGUID = GetUniqueIdForSettingsAsset( entryAsset )
			int executionGUID = GetUniqueIdForSettingsAsset( executionAsset )
			fileLevel.mythicSkinsGUIDToCustomExecutionGUID[ skinGUID ] <- executionGUID
			fileLevel.customExecutionGUIDToMythicSkinsGUID[ executionGUID ] <- skinGUID
		}

		tierIdx++
	}

	if ( tierIdx > 1 )
	{
		fileLevel.charactersGUIDToMythicSkinGUIDs[ characterGUID ] <- skinGUIDs
	}

	foreach ( var storeImage in IterateSettingsArray( GetSettingsBlockArray( settingsBlock, "storeImagesByTier" ) ) )
	{
		asset entryAsset = GetSettingsBlockAsset( storeImage, "storeImage" )

		if( !( characterGUID in fileLevel.charactersGUIDToStoreImages ) )
			fileLevel.charactersGUIDToStoreImages[ characterGUID ] <- []

		fileLevel.charactersGUIDToStoreImages[ characterGUID ].append( entryAsset )
	}

	ItemFlavor ornull challengeFlavOrNull = RegisterItemFlavorFromSettingsAsset( challengeAsset )
	if ( challengeFlavOrNull != null )
	{
		ItemFlavor challengeFlav = expect ItemFlavor( challengeFlavOrNull )
		RegisterChallengeSource( challengeFlav, mythicBundleFlav, CHALLENGE_SORT_ORDINAL )

		table<string, string> ornull metaData = ItemFlavor_GetMetaData( challengeFlav )
		expect table<string, string>(metaData)

		metaData[ HAS_MYTHIC_PREREQ ] <- string( preRegGUID )

		fileLevel.mythicCharactersGUIDToChallengesGUID[ characterGUID ] <- ItemFlavor_GetGUID( challengeFlav )
	}

	fileLevel.charactersGUIDToSkinBaseName[ characterGUID ] <- GetSettingsBlockString( settingsBlock, "baseSkinName" )

	fileLevel.mythicCharactersGUIDToExecutionUsableOnTier1And2[ characterGUID ] <- GetGlobalSettingsBool( ItemFlavor_GetAsset( mythicBundleFlav ), "isExecutionUsableOnTier1AndTier2" )
}

bool function Mythics_CharacterHasMythic( ItemFlavor character )
{
	Assert( IsItemFlavorStructValid( character.guid, eValidation.DONT_ASSERT ), eValidation.ASSERT )
	Assert( ItemFlavor_GetType( character ) == eItemType.character )

	int characterGUID = ItemFlavor_GetGUID( character )

	return ( characterGUID in fileLevel.mythicCharactersGUIDToChallengesGUID )
}

// Use this to check for 1:1 skin-executions (v1 prestige finishers)
bool function Mythics_SkinHasCustomExecution( ItemFlavor skin )
{
	Assert( IsItemFlavorStructValid( skin.guid, eValidation.DONT_ASSERT ), eValidation.ASSERT )

	int skinGUID = GetUniqueIdForSettingsAsset( ItemFlavor_GetAsset( skin ) )

	return ( skinGUID in fileLevel.mythicSkinsGUIDToCustomExecutionGUID )
}

// Use this to check if a character has a custom execution at all
bool function Mythics_CharacterHasCustomExecution( ItemFlavor character )
{
	Assert( IsItemFlavorStructValid( character.guid, eValidation.DONT_ASSERT ), eValidation.ASSERT )

	array<int> skinGUIDs = Mythics_GetMythicSkinGUIDsForCharacter( character )

	foreach ( int skinGUID in skinGUIDs )
	{
		if ( skinGUID in fileLevel.mythicSkinsGUIDToCustomExecutionGUID )
			return true
	}
	return false
}

bool function Mythics_IsExecutionUsableOnTier1AndTier2( ItemFlavor skinOrCharacter )
{
	ItemFlavor character = ItemFlavor_GetType( skinOrCharacter ) == eItemType.character_skin ? Mythics_GetCharacterForSkin( skinOrCharacter ) : skinOrCharacter
	Assert( ItemFlavor_GetType( character ) == eItemType.character, eValidation.ASSERT )

	int characterGUID = ItemFlavor_GetGUID( character )
	if ( characterGUID in fileLevel.mythicCharactersGUIDToExecutionUsableOnTier1And2 )
		return fileLevel.mythicCharactersGUIDToExecutionUsableOnTier1And2[ characterGUID ]
	return false
}

bool function Mythics_IsCustomExecutionUnlocked( entity player, ItemFlavor skin )
{
	if ( Mythics_IsExecutionUsableOnTier1AndTier2( skin ) )
		return Mythics_GetNumTiersUnlockedForSkin( player, skin ) == FINAL_TIER

	return Mythics_SkinHasCustomExecution( skin )
}

bool function Mythics_ShouldForceCustomExecution( entity player, ItemFlavor skin )
{
	if ( Mythics_IsExecutionUsableOnTier1AndTier2( skin ) )
		return false

	return Mythics_SkinHasCustomExecution( skin )
}

ItemFlavor function Mythics_GetCustomExecutionForCharacterOrSkin( ItemFlavor characterOrSkin )
{
	Assert( IsItemFlavorStructValid( characterOrSkin.guid, eValidation.DONT_ASSERT ), eValidation.ASSERT )

	if ( ItemFlavor_GetType( characterOrSkin ) == eItemType.character_skin && Mythics_IsExecutionUsableOnTier1AndTier2( characterOrSkin ) )
		characterOrSkin = Mythics_GetCharacterForSkin( characterOrSkin )

	int skinGUID = Mythics_GetSkinGUIDFromItem( characterOrSkin )
	int executionGUID = fileLevel.mythicSkinsGUIDToCustomExecutionGUID[ skinGUID ]

	Assert( IsValidItemFlavorGUID( executionGUID ) )
	Assert( ItemFlavor_GetType( GetItemFlavorByGUID( executionGUID ) ) == eItemType.character_execution )

	return GetItemFlavorByGUID( executionGUID )
}

bool function Mythics_IsCustomExecutionInMythicBundle( ItemFlavor execution )
{
	Assert( IsItemFlavorStructValid( execution.guid, eValidation.DONT_ASSERT ), eValidation.ASSERT )
	Assert( ItemFlavor_GetType( execution ) == eItemType.character_execution )

	return ( execution.guid in fileLevel.customExecutionGUIDToMythicSkinsGUID )
}

ItemFlavor function Mythics_GetCharacterSkinForCustomExecution( ItemFlavor execution )
{
	Assert( IsItemFlavorStructValid( execution.guid, eValidation.DONT_ASSERT ), eValidation.ASSERT )
	Assert( ItemFlavor_GetType( execution ) == eItemType.character_execution )
	Assert( Mythics_IsCustomExecutionInMythicBundle( execution ) )

	int characterSkinGUID = fileLevel.customExecutionGUIDToMythicSkinsGUID[ execution.guid ]

	return GetItemFlavorByGUID( characterSkinGUID )
}

bool function Mythics_SkinHasCustomSkydivetrail( ItemFlavor skin )
{
	Assert( IsItemFlavorStructValid( skin.guid, eValidation.DONT_ASSERT ), eValidation.ASSERT )

	int skinGUID = GetUniqueIdForSettingsAsset( ItemFlavor_GetAsset( skin ) )

	return ( skinGUID in fileLevel.mythicSkinsGUIDToCustomSkydivetrailGUID )
}


ItemFlavor function Mythics_GetCustomSkydivetrailForCharacterOrSkin( ItemFlavor item )
{
	if ( ItemFlavor_GetType( item ) == eItemType.character )
		item = expect ItemFlavor( Mythics_GetSkinTierForCharacter( item, 0 ) )

	int skinGUID = Mythics_GetSkinGUIDFromItem( item )
	int skydivetrailGUID = fileLevel.mythicSkinsGUIDToCustomSkydivetrailGUID[ skinGUID ]

	Assert( IsValidItemFlavorGUID( skydivetrailGUID ) )
	Assert( ItemFlavor_GetType( GetItemFlavorByGUID( skydivetrailGUID ) ) == eItemType.skydive_trail )

	return GetItemFlavorByGUID( skydivetrailGUID )
}

int function Mythics_GetSkinGUIDFromItem( ItemFlavor item )
{
	Assert( IsItemFlavorStructValid( item.guid, eValidation.DONT_ASSERT ), eValidation.ASSERT )
	Assert( ItemFlavor_GetType( item ) == eItemType.character || ItemFlavor_GetType( item ) == eItemType.character_skin )

	int skinGUID

	if ( ItemFlavor_GetType( item ) == eItemType.character )
	{
		int characterGUID = ItemFlavor_GetGUID( item )
		skinGUID = fileLevel.charactersGUIDToMythicSkinGUIDs[ characterGUID ][ FINAL_TIER - 1 ]
	}
	else // eItemType == character_skin
	{
		skinGUID = ItemFlavor_GetGUID( item )
	}

	return skinGUID
}

ItemFlavor function Mythics_GetChallengeForCharacter( ItemFlavor character )
{
	Assert( IsItemFlavorStructValid( character.guid, eValidation.DONT_ASSERT ), eValidation.ASSERT )

	int characterGUID = ItemFlavor_GetGUID( character )
	int challengeGUID = fileLevel.mythicCharactersGUIDToChallengesGUID[ characterGUID ]

	Assert( IsValidItemFlavorGUID( challengeGUID ) )
	Assert( ItemFlavor_GetType( GetItemFlavorByGUID( challengeGUID ) ) == eItemType.challenge )

	return GetItemFlavorByGUID( challengeGUID )
}

bool function Mythics_IsItemFlavorMythic( ItemFlavor item )
{
	return ItemFlavor_GetQuality( item ) == eRarityTier.MYTHIC
}

bool function Mythics_IsItemFlavorMythicSkin( ItemFlavor item )
{
	return ItemFlavor_GetType( item ) == eItemType.character_skin && ItemFlavor_GetQuality( item ) == eRarityTier.MYTHIC
}

#if UI
void function Mythics_ToggleTrackChallenge( ItemFlavor challenge, var button, bool isSkinPanel = false )
{
	fileLevel.currentChallenge = challenge
	SettingsAssetGUID challengeGUID = ItemFlavor_GetGUID( challenge )
	var rui = Hud_GetRui( button )

	if ( IsChallengeValidAsFavorite( GetLocalClientPlayer(), challenge ) )
		Remote_ServerCallFunction( "ClientCallback_ToggleFavoriteChallenge", challengeGUID )
}

void function Mythics_UpdateTrackingButton()
{
	if ( fileLevel.currentChallenge == null )
		return

	var skinsPanel = GetPanel( "CharacterSkinsPanel" )
	var celebrationMenu = GetMenu( "LootBoxOpen" )

	var trackChallengeButton = Hud_GetChild( celebrationMenu, "TrackChallengeButton" )
	var mythicTrackingButton = Hud_GetChild( skinsPanel, "TrackMythicButton" )

	var skinPanelRui = Hud_GetRui( mythicTrackingButton )
	var celebrationMenuRui = Hud_GetRui( trackChallengeButton )


	bool isChallengeTracked = IsFavoriteChallenge( expect ItemFlavor( fileLevel.currentChallenge )  )

	RuiSetString( skinPanelRui, "descText", isChallengeTracked ? "#CHALLENGE_TRACKED"  : "#CHALLENGE_TRACK" )
	RuiSetString( skinPanelRui, "bigText", isChallengeTracked ? "`1%$rui/hud/check_selected%" : "`1%$rui/borders/key_border%" )
	HudElem_SetRuiArg( trackChallengeButton, "buttonText", isChallengeTracked ?  "#CHALLENGE_TRACKED" : "#CHALLENGE_TRACK")
	HudElem_SetRuiArg( trackChallengeButton, "isChallengeTracked", isChallengeTracked )

}
#endif

int function Mythics_GetSkinTierIntForSkin( ItemFlavor skin )
{
	Assert( IsItemFlavorStructValid( skin.guid, eValidation.DONT_ASSERT ), eValidation.ASSERT )

	int skinGUID =  ItemFlavor_GetGUID( skin )
	int characterGUID = ItemFlavor_GetGUID( expect ItemFlavor( GetItemFlavorAssociatedCharacterOrWeapon( skin ) ) )

	for ( int tier = 1;  tier <= FINAL_TIER; tier++ )
	{
		if ( fileLevel.charactersGUIDToMythicSkinGUIDs[ characterGUID ][tier-1] == skinGUID)
			return tier
	}
	return -1
}

array<ItemFlavor> function Mythics_GetAllSkinsFromBase( ItemFlavor baseSkin )
{
	Assert( ItemFlavor_GetType( baseSkin ) == eItemType.character_skin )

	array<ItemFlavor> mythicSkins

	ItemFlavor character = expect ItemFlavor( GetItemFlavorAssociatedCharacterOrWeapon( baseSkin ) )
	int characterGUID = ItemFlavor_GetGUID( character )

	if ( !( characterGUID in fileLevel.charactersGUIDToMythicSkinGUIDs ) )
		return mythicSkins

	foreach ( int skinGUID in fileLevel.charactersGUIDToMythicSkinGUIDs[ characterGUID ] )
	{
		mythicSkins.append( GetItemFlavorByGUID( skinGUID ) )
	}

	return mythicSkins
}

ItemFlavor ornull function Mythics_GetItemTierForSkin( ItemFlavor skin, int tier )
{
	Assert( ItemFlavor_GetType( skin ) == eItemType.character_skin )

	ItemFlavor character = Mythics_GetCharacterForSkin( skin )

	if ( tier == FINAL_TIER )
		return Mythics_GetCustomExecutionForCharacterOrSkin( character )

	return Mythics_GetSkinTierForCharacter ( character , tier )
}

ItemFlavor ornull function Mythics_GetSkinTierForCharacter( ItemFlavor character, int tier )
{
	Assert( IsItemFlavorStructValid( character.guid, eValidation.DONT_ASSERT ), eValidation.ASSERT )

	int characterGUID = ItemFlavor_GetGUID( character )
	int skinGUID

	if( characterGUID in fileLevel.charactersGUIDToMythicSkinGUIDs && fileLevel.charactersGUIDToMythicSkinGUIDs[ characterGUID ].len() > tier )
		skinGUID = fileLevel.charactersGUIDToMythicSkinGUIDs[ characterGUID ][tier]
	else
		return null

	Assert( IsValidItemFlavorGUID( skinGUID ) )
	Assert( ItemFlavor_GetType( GetItemFlavorByGUID( skinGUID ) ) == eItemType.character_skin )

	return GetItemFlavorByGUID( skinGUID )
}

ItemFlavor function Mythics_GetCharacterForSkin( ItemFlavor skin )
{
	Assert( IsItemFlavorStructValid( skin.guid, eValidation.DONT_ASSERT ), eValidation.ASSERT )

	int skinGUID =  ItemFlavor_GetGUID( skin )
	ItemFlavor character = expect ItemFlavor( GetItemFlavorAssociatedCharacterOrWeapon( skin ) )
	return character
}

array<int> function Mythics_GetMythicSkinGUIDsForCharacter( ItemFlavor character )
{
	int characterGUID =  ItemFlavor_GetGUID( character )
	if( characterGUID in fileLevel.charactersGUIDToMythicSkinGUIDs )
	{
		return fileLevel.charactersGUIDToMythicSkinGUIDs[ characterGUID ]
	}
	return []
}

SettingsAssetGUID function Mythics_GetChallengeGUIDForSkinGUID( SettingsAssetGUID skinGUID )
{
	ItemFlavor skin             = GetItemFlavorByGUID( skinGUID )
	ItemFlavor character = Mythics_GetCharacterForSkin( skin )
	ItemFlavor challenge = Mythics_GetChallengeForCharacter( character )
	SettingsAssetGUID challengeGUID = ItemFlavor_GetGUID( challenge )
	return challengeGUID

}

ItemFlavor function Mythics_GetChallengeForSkin( ItemFlavor skin )
{
	Assert( ItemFlavor_GetType( skin ) == eItemType.character_skin )

	return Mythics_GetChallengeForCharacter( Mythics_GetCharacterForSkin ( skin ) )
}

int function Mythics_GetNumTiersUnlockedForSkin( entity player, ItemFlavor skin )
{
	if ( !IsValid( player ) )
		return 0

	ItemFlavor character = Mythics_GetCharacterForSkin( skin )
	array< int > allSkinGUIDs = fileLevel.charactersGUIDToMythicSkinGUIDs[ ItemFlavor_GetGUID( character ) ]
	int ownedCount = 0
	foreach ( int skinGUID in allSkinGUIDs )
	{
		if ( GRX_IsItemOwnedByPlayer_AllowOutOfDateData( GetItemFlavorByGUID( skinGUID ), player ) )
			ownedCount++
	}

	return ownedCount
}

asset function Mythics_GetStoreImageForCharacter( ItemFlavor character, int tier )
{
	Assert( IsItemFlavorStructValid( character.guid, eValidation.DONT_ASSERT ), eValidation.ASSERT )
	return fileLevel.charactersGUIDToStoreImages[ ItemFlavor_GetGUID( character ) ][ tier ]
}

string function Mythics_GetSkinBaseNameForCharacter( ItemFlavor character )
{
	Assert( IsItemFlavorStructValid( character.guid, eValidation.DONT_ASSERT ), eValidation.ASSERT )
	return fileLevel.charactersGUIDToSkinBaseName[ ItemFlavor_GetGUID( character ) ]
}

#if SERVER
void function Mythics_RegisterBoostedMythicChallengeForPlayer( entity player )
{
	if ( Boost_IsBoostModifierTypeActive( player, eBoostModifierType.MYTHIC_PROGRESS ) )
	{
		array<ItemFlavor> allMythic = clone GetAllChallengesOfTimespan( eChallengeTimeSpanKind.MYTHIC )

		foreach ( ItemFlavor challenge in allMythic )
		{
			if ( Challenge_IsBoostEnabled( challenge ) && Challenge_IsAssigned( player, challenge ) )
			{
				if ( player in fileLevel.mythicBoostedChallenges )
				{
					fileLevel.mythicBoostedChallenges[player].append( challenge )
				}
				else
				{
					array< ItemFlavor > flavors
					flavors.append( challenge )

					fileLevel.mythicBoostedChallenges[player] <- flavors
				}
			}
		}
	}
}
#endif // SERVER

#if SERVER
void function Mythics_UnregisterBoostedMythicChallengesForPlayer( entity player )
{
	if ( player in fileLevel.mythicBoostedChallenges )
	{
		delete fileLevel.mythicBoostedChallenges[player]
	}
}
#endif // SERVER

#if SERVER
array< ItemFlavor > function Mythics_GetPlayerBoostedMythicChallenges( entity player )
{
	if ( player in fileLevel.mythicBoostedChallenges )
	{
		return fileLevel.mythicBoostedChallenges[player]
	}

	array< ItemFlavor > emptyArray
	return emptyArray
}
#endif // SERVER

#if SERVER
array<Mythic_ChallengeProgress> function Mythics_GetBoostEnabledChallengeProgressMade( entity player, array<ItemFlavor> boostEnabledChallenges )
{
	array<Mythic_ChallengeProgress> progressedBoostEnabledChallenges

	foreach ( ItemFlavor challengeFlav in boostEnabledChallenges)
	{
		if ( !Challenge_IsBoostEnabled( challengeFlav ) )
			continue

		PlayerChallengesState pcs = GetPlayerChallengesState( player )
		ChallengeState cs = pcs.challengeStateMap[ challengeFlav ]

		int statMarker = player.GetPersistentVarAsInt( "challenges[" + cs.persistenceIdx + "].statMarker" )

		int pIdx = Challenge_GetPostGamePersistenceIndex( player,challengeFlav.guid )
		if ( pIdx < 0 )
			continue

		int startProgress = player.GetPersistentVarAsInt( "postGameChallengesProgress[" + pIdx + "].progressMatchStart" )
		int currentProgress = 0
		int currentTier = Challenge_GetCurrentTier( player, challengeFlav )

		if ( currentTier >= Challenge_GetTierCount( challengeFlav ) )
		{
			continue
		}

		array<string> statRefs = Challenge_GetStatRefs( challengeFlav, currentTier ) // 19.0 Boost Enabled Challenges do not use Alt conditions.
		foreach ( string statRef in statRefs )
		{
			StatEntry entry = GetStatEntryByRef( statRef )
			currentProgress += GetStat_Int( player, entry, eStatGetWhen.CURRENT )
		}

		startProgress   = startProgress - statMarker
		currentProgress = currentProgress - statMarker

		int progressMade = currentProgress - startProgress

		if ( progressMade > 0 )
		{
			Mythic_ChallengeProgress entry

			entry.challenge = challengeFlav
			entry.challengeProgress = progressMade
			entry.statMarker = statMarker

			progressedBoostEnabledChallenges.append( entry )
		}
	}

	return progressedBoostEnabledChallenges
}
#endif // SERVER 