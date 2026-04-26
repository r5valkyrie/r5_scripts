global function CollectionEvents_Init
global function GetActiveCollectionEvent
global function CollectionEvent_GetChallenges // TODO - R5DEV-413761: duped in themeshop
global function CollectionEvent_GetFrontPageRewardBoxTitle
global function CollectionEvent_GetCollectionName
global function CollectionEvent_GetMainPackFlav
global function CollectionEvent_GetMainPackShortPluralName
global function CollectionEvent_GetMainPackImage
global function CollectionEvent_GetFrontPageGRXOfferLocation
global function CollectionEvent_GetRewardGroups
global function CollectionEvent_IsGivenItemFlavorReward
global function CollectionEvent_GetAboutText // TODO - R5DEV-413761: duped in themeshop
global function CollectionEvent_GetStoreEventSectionMainImage
global function CollectionEvent_GetStoreEventSectionMainText
global function CollectionEvent_GetStoreEventSectionSubText
global function CollectionEvent_GetMainIcon
global function CollectionEvent_GetMainThemeCol
global function CollectionEvent_GetFrontPageBGTintCol
global function CollectionEvent_GetFrontPageTitleCol
global function CollectionEvent_GetFrontPageSubtitleCol
global function CollectionEvent_GetFrontPageTimeRemainingCol
global function CollectionEvent_GetBGPatternImage
global function CollectionEvent_GetBGTabPatternImage
global function CollectionEvent_GetTabLeftSideImage // TODO - R5DEV-413761: duped in themeshop
global function CollectionEvent_GetTabCenterImage // TODO - R5DEV-413761: duped in themeshop
global function CollectionEvent_GetTabRightSideImage // TODO - R5DEV-413761: duped in themeshop
global function CollectionEvent_GetTabImageSelectedAlpha
global function CollectionEvent_GetTabImageUnselectedAlpha
global function CollectionEvent_GetTabCenterRui // TODO - R5DEV-413761: duped in themeshop
global function CollectionEvent_GetTabBGDefaultCol // TODO - R5DEV-413761: duped in themeshop 
global function CollectionEvent_GetTabBarDefaultCol // TODO - R5DEV-413761: duped in themeshop
global function CollectionEvent_GetTabBGFocusedCol // TODO - R5DEV-413761: duped in themeshop
global function CollectionEvent_GetTabTextDefaultCol // TODO - R5DEV-413761: duped in themeshop
global function CollectionEvent_GetTabBarFocusedCol // TODO - R5DEV-413761: duped in themeshop
global function CollectionEvent_GetTabGlowFocusedCol // TODO - R5DEV-413761: duped in themeshop
global function CollectionEvent_GetTabBGSelectedCol // TODO - R5DEV-413761: duped in themeshop
global function CollectionEvent_GetTabBarSelectedCol // TODO - R5DEV-413761: duped in themeshop
global function CollectionEvent_GetTabTextSelectedCol // TODO - R5DEV-413761: duped in themeshop
global function CollectionEvent_GetAboutPageSpecialTextCol // TODO - R5DEV-413761: duped in themeshop
global function CollectionEvent_GetHeaderIcon // TODO - R5DEV-413761: duped in themeshop

// HEIRLOOM EVENTS - THEMED SHOP *OR* COLLECTION EVENT *OR* MILESTONE EVENT
global function HeirloomEvent_GetItemCount
global function HeirloomEvent_GetCurrentRemainingItemCount
global function HeirloomEvent_GetPrimaryCompletionRewardItem
global function HeirloomEvent_GetCompletionRewardPack
global function HeirloomEvent_GetCompletionSequenceName
global function HeirloomEvent_AwardHeirloomShards
global function HeirloomEvent_IsRewardMythicSkin

#if UI
global function HeirloomEvent_GetHeirloomButtonImage
global function HeirloomEvent_GetMythicButtonImage
global function HeirloomEvent_GetHeirloomHeaderText
global function HeirloomEvent_GetHeirloomUnlockDesc
global function HeirloomEvent_IsCompletionRewardOwned
global function HeirloomEvent_IsRewardHeirloom

global function CollectionEvent_IsV2PlaylistVarEnabled

global function CollectionEvent_GetPackOffer
global function CollectionEvent_GetPackOffers
global function CollectionEvent_GetLobbyButtonImage // TODO - R5DEV-413761: duped in themeshop
global function CollectionEvent_HasLobbyTheme // TODO - R5DEV-413761: duped in themeshop
global function CollectionEvent_IsItemFlavorFromEvent
global function CollectionEvent_GetEventItems
global function CollectionEvent_GetCustomIconForItemIdx
global function CollectionEvent_GetSinglePackOffers
#endif

#if CLIENT || UI
global function CollectionEvent_GetFrontTabText
#endif

#if SERVER || UI
global function CollectionEvent_GetCurrentMaxEventPackPurchaseCount
//global function CollectionEvent_IsHeirloomDirectPurchaseCurrentlyAllowed
#endif

#if SERVER
global function CollectionEvent_RevokeHeirloomMisgrant
global function GetEventPINData
#endif

//////////////////////
//////////////////////
//// Global Types ////
//////////////////////
//////////////////////

#if SERVER || CLIENT || UI
global struct CollectionEventRewardGroup
{
	string ref
	int    quality = -1
	//string infoSquareTitle
	//string infoSquareSubtitle

	array<ItemFlavor> rewards
}
#endif
                    
	global const array< int > HEIRLOOM_EVENTS = [ eItemType.calevent_collection, eItemType.calevent_themedshop, eItemType.calevent_milestone ]
     
                                                                                                             
      
///////////////////////
///////////////////////
//// Private Types ////
///////////////////////
///////////////////////

#if SERVER || CLIENT || UI
struct FileStruct_LifetimeLevel
{
	#if SERVER
		EntitySet loginRewardsChecked
		EntitySet heirloomPackGrantQueued
	#endif

	table<ItemFlavor, array<ItemFlavor> > eventChallengesMap
}
#endif
#if SERVER || CLIENT
FileStruct_LifetimeLevel fileLevel // resets every level change
#elseif UI
FileStruct_LifetimeLevel& fileLevel // resets every level change

struct {
	//
} fileVM // resets every UI VM reset
#endif



/////////////////////////
/////////////////////////
//// Initialiszation ////
/////////////////////////
/////////////////////////

#if SERVER || CLIENT || UI
void function CollectionEvents_Init()
{
	#if UI
		FileStruct_LifetimeLevel newFileLevel
		fileLevel = newFileLevel
	#endif

	AddCallback_OnItemFlavorRegistered( eItemType.calevent_collection, void function( ItemFlavor ev ) {
		fileLevel.eventChallengesMap[ev] <- RegisterReferencedItemFlavorsFromArray( ev, "challenges", "flavor" )
		foreach ( int challengeSortOrdinal, ItemFlavor challengeFlav in fileLevel.eventChallengesMap[ev] )
			RegisterChallengeSource( challengeFlav, ev, challengeSortOrdinal )
	} )

	#if SERVER
		AddCallback_QueueServersideScriptGRXOperations( QueueServersideScriptGRXOperations )
		AddCallback_OnClientDisconnected( CollectionEvent_OnPlayerDisconnected )
	#endif
}
#endif

//////////////////////////
//////////////////////////
//// Global functions ////
//////////////////////////
//////////////////////////

#if SERVER || CLIENT || UI
ItemFlavor ornull function GetActiveCollectionEvent( int t )
{
	Assert( IsItemFlavorRegistrationFinished() )
	ItemFlavor ornull event = null
	foreach ( ItemFlavor ev in GetAllItemFlavorsOfType( eItemType.calevent_collection ) )
	{
		if ( !CalEvent_IsActive( ev, t ) )
			continue

		Assert( event == null, format( "Multiple collection events are active!! (%s, %s)", string(ItemFlavor_GetAsset( expect ItemFlavor(event) )), string(ItemFlavor_GetAsset( ev )) ) )
		event = ev
	}
	return event
}
#endif


#if SERVER || CLIENT || UI
array<ItemFlavor> function CollectionEvent_GetLoginRewards( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )

	array<ItemFlavor> rewards = []
	foreach ( var rewardBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), "loginRewards" ) )
	{
		asset rewardAsset = GetSettingsBlockAsset( rewardBlock, "flavor" )
		if ( IsValidItemFlavorSettingsAsset( rewardAsset ) )
			rewards.append( GetItemFlavorByAsset( rewardAsset ) )
	}
	return rewards
}
#endif


#if SERVER || CLIENT || UI
array<ItemFlavor> function CollectionEvent_GetChallenges( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )

	return fileLevel.eventChallengesMap[event]
}
#endif


#if SERVER || CLIENT || UI
string function CollectionEvent_GetFrontPageRewardBoxTitle( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "frontPageRewardBoxTitle" )
}
#endif

#if UI
array<GRXScriptOffer> function CollectionEvent_GetSinglePackOffers( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	array<GRXScriptOffer> offers = GRX_GetItemDedicatedStoreOffers( CollectionEvent_GetMainPackFlav( event ), CollectionEvent_GetFrontPageGRXOfferLocation( event, GRX_IsOfferRestricted() ) )

	int index = 0
	foreach( offer in offers )
	{
		if ( offer.items.len() > 1 )
		{
			offers.remove( index )
		}
		index++
	}

	return offers
}
#endif

#if SERVER || CLIENT || UI
string function CollectionEvent_GetCollectionName( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "collectionName" )
}
#endif

#if SERVER || CLIENT || UI
ItemFlavor function CollectionEvent_GetMainPackFlav( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetItemFlavorByAsset( GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "mainPackFlav" ) )
}
#endif


#if SERVER || CLIENT || UI
string function CollectionEvent_GetMainPackShortPluralName( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "mainPackShortPluralName" )
}
#endif


#if SERVER || CLIENT || UI
asset function CollectionEvent_GetMainPackImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "mainPackImage" )
}
#endif


#if SERVER || CLIENT || UI
bool function HeirloomEvent_AwardHeirloomShards( ItemFlavor event )
{
	Assert( HEIRLOOM_EVENTS.contains( ItemFlavor_GetType( event ) ) )
	return GetGlobalSettingsBool( ItemFlavor_GetAsset( event ), "awardHeirloomShards" )
}
#endif


#if SERVER || CLIENT || UI
ItemFlavor function HeirloomEvent_GetPrimaryCompletionRewardItem( ItemFlavor event )
{
	Assert( HEIRLOOM_EVENTS.contains( ItemFlavor_GetType( event ) ) )

	if ( HeirloomEvent_AwardHeirloomShards( event ) )
		return GetItemFlavorByAsset( $"settings/itemflav/currency_bundle/heirloom.rpak" )

	return GetItemFlavorByAsset( GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "primaryCompletionRewardItem" ) )
}
#endif

#if SERVER || CLIENT || UI
bool function HeirloomEvent_IsRewardMythicSkin( ItemFlavor event )
{
	ItemFlavor primaryRewardItem =  HeirloomEvent_GetPrimaryCompletionRewardItem( event )
	return Mythics_IsItemFlavorMythicSkin( primaryRewardItem )
}
#endif


#if SERVER || CLIENT || UI
ItemFlavor function HeirloomEvent_GetCompletionRewardPack( ItemFlavor event )
{
	Assert( HEIRLOOM_EVENTS.contains( ItemFlavor_GetType( event ) ) )

	if ( HeirloomEvent_AwardHeirloomShards( event ) )
		return GetItemFlavorByAsset( $"settings/itemflav/pack/heirloom_shards.rpak" )

	return GetItemFlavorByAsset( GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "completionRewardPack" ) )
}
#endif


#if SERVER || CLIENT || UI
string function HeirloomEvent_GetCompletionSequenceName( ItemFlavor event )
{
	Assert( HEIRLOOM_EVENTS.contains( ItemFlavor_GetType( event ) ) )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "completionSequenceName" )
}
#endif


#if SERVER || CLIENT || UI
string function CollectionEvent_GetFrontPageGRXOfferLocation( ItemFlavor event, bool isRestricted = false )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "frontGRXOfferLocation" ) // Collection events always use frontGRXOfferLocation. if that changes use: isRestricted ? "restrictedGRXOfferLocation" : "frontGRXOfferLocation"
}
#endif

#if SERVER || CLIENT || UI
array<CollectionEventRewardGroup> function CollectionEvent_GetRewardGroups( ItemFlavor event )
{
                     
		//Miletone Event has the exact same reward structure as Collection Event.
		Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection || ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
      
                                                                        
       
	array<CollectionEventRewardGroup> groups = []
	foreach ( var groupBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), "rewardGroups" ) )
	{
		CollectionEventRewardGroup group
		group.ref = GetSettingsBlockString( groupBlock, "ref" )
		group.quality = eRarityTier[GetSettingsBlockString( groupBlock, "quality" )]
		//group.infoSquareTitle = GetSettingsBlockString( groupBlock, "infoSquareTitle" )
		//group.infoSquareSubtitle = GetSettingsBlockString( groupBlock, "infoSquareSubtitle" )
		foreach ( var rewardBlock in IterateSettingsArray( GetSettingsBlockArray( groupBlock, "rewards" ) ) )
			group.rewards.append( GetItemFlavorByAsset( GetSettingsBlockAsset( rewardBlock, "flavor" ) ) )

		groups.append( group )
	}
	return groups
}
#endif

#if SERVER || CLIENT || UI
bool function CollectionEvent_IsGivenItemFlavorReward( ItemFlavor event, ItemFlavor item )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )

	array<CollectionEventRewardGroup> rewardGroups = CollectionEvent_GetRewardGroups( event )

	foreach( CollectionEventRewardGroup group in rewardGroups )
	{
		foreach( ItemFlavor flav in group.rewards )
		{
			if ( flav.guid == item.guid )
			{
				return true
			}
		}
	}

	return false
}
#endif // SERVER || CLIENT || UI


#if SERVER || CLIENT || UI
array<string> function CollectionEvent_GetAboutText( ItemFlavor event, bool restricted )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )

	array<string> aboutText = []
	string key              = (restricted ? "aboutTextRestricted" : "aboutTextStandard")
	foreach ( var aboutBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), key ) )
		aboutText.append( GetSettingsBlockString( aboutBlock, "text" ) )
	return aboutText
}
#endif

#if SERVER || CLIENT || UI
asset function CollectionEvent_GetStoreEventSectionMainImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "storeEventSectionMainImage" )
}
#endif // SERVER || CLIENT || UI

#if SERVER || CLIENT || UI
string function CollectionEvent_GetStoreEventSectionMainText( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "storeEventSectionMainText" )
}
#endif // SERVER || CLIENT || UI

#if SERVER || CLIENT || UI
string function CollectionEvent_GetStoreEventSectionSubText( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "storeEventSectionSubText" )
}
#endif // SERVER || CLIENT || UI

#if SERVER || CLIENT || UI
void function CollectionEvent_GetMainIcon( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
}
#endif


#if SERVER || CLIENT || UI
vector function CollectionEvent_GetMainThemeCol( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "mainThemeCol" )
}
#endif


#if SERVER || CLIENT || UI
vector function CollectionEvent_GetFrontPageBGTintCol( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "frontPageBGTintCol" )
}
#endif


#if SERVER || CLIENT || UI
vector function CollectionEvent_GetFrontPageTitleCol( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "frontPageTitleCol" )
}
#endif


#if SERVER || CLIENT || UI
vector function CollectionEvent_GetFrontPageSubtitleCol( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "frontPageSubtitleCol" )
}
#endif


#if SERVER || CLIENT || UI
vector function CollectionEvent_GetFrontPageTimeRemainingCol( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "frontPageTimeRemainingCol" )
}
#endif

#if CLIENT || UI
string function CollectionEvent_GetFrontTabText( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return ItemFlavor_GetShortName( event )
}
#endif

#if SERVER || CLIENT || UI
asset function CollectionEvent_GetTabLeftSideImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "leftSideImage" )
}
#endif

#if SERVER || CLIENT || UI
asset function CollectionEvent_GetTabCenterImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "centerImage" )
}
#endif

#if SERVER || CLIENT || UI
asset function CollectionEvent_GetTabRightSideImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "rightSideImage" )
}
#endif

#if SERVER || CLIENT || UI
float function CollectionEvent_GetTabImageSelectedAlpha( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsFloat( ItemFlavor_GetAsset( event ), "imageSelectedAlpha" )
}
#endif

#if SERVER || CLIENT || UI
float function CollectionEvent_GetTabImageUnselectedAlpha( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsFloat( ItemFlavor_GetAsset( event ), "imageUnselectedAlpha" )
}
#endif

#if SERVER || CLIENT || UI
asset function CollectionEvent_GetTabCenterRui( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsStringAsAsset( ItemFlavor_GetAsset( event ), "centerRuiAsset" )
}
#endif

#if SERVER || CLIENT || UI
vector function CollectionEvent_GetTabBGDefaultCol( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "tabBGDefaultCol" )
}
#endif


#if SERVER || CLIENT || UI
vector function CollectionEvent_GetTabBarDefaultCol( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "tabBarDefaultCol" )
}
#endif


#if SERVER || CLIENT || UI
vector function CollectionEvent_GetTabTextDefaultCol( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "tabTextDefaultCol" )
}
#endif

#if SERVER || CLIENT || UI
vector function CollectionEvent_GetTabBGFocusedCol( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "tabBGFocusedCol" )
}
#endif


#if SERVER || CLIENT || UI
vector function CollectionEvent_GetTabBarFocusedCol( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "tabBarFocusedCol" )
}
#endif

#if SERVER || CLIENT || UI
vector function CollectionEvent_GetTabGlowFocusedCol( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "tabGlowFocusedCol" )
}
#endif


#if SERVER || CLIENT || UI
vector function CollectionEvent_GetTabBGSelectedCol( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "tabBGSelectedCol" )
}
#endif


#if SERVER || CLIENT || UI
vector function CollectionEvent_GetTabBarSelectedCol( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "tabBarSelectedCol" )
}
#endif

#if SERVER || CLIENT || UI
vector function CollectionEvent_GetTabTextSelectedCol( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "tabTextSelectedCol" )
}
#endif

#if SERVER || CLIENT || UI
vector function CollectionEvent_GetAboutPageSpecialTextCol( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "aboutPageSpecialTextCol" )
}
#endif

#if SERVER || CLIENT || UI
asset function CollectionEvent_GetBGPatternImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "bgPatternImage" )
}
#endif

#if SERVER || CLIENT || UI
asset function CollectionEvent_GetBGTabPatternImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "bgTabPatternImage" )
}
#endif


#if SERVER || CLIENT || UI
asset function CollectionEvent_GetHeaderIcon( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "headerIcon" )
}
#endif


#if UI
asset function HeirloomEvent_GetHeirloomButtonImage( ItemFlavor event )
{
	Assert( HEIRLOOM_EVENTS.contains( ItemFlavor_GetType( event ) ) )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "heirloomButtonImage" )
}
#endif

#if UI
asset function HeirloomEvent_GetMythicButtonImage( ItemFlavor event, int tier )
{
	Assert( HEIRLOOM_EVENTS.contains( ItemFlavor_GetType( event ) ) )

	if ( tier == 1 )
		return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "prestigeButtonImage2" )
	else if ( tier == 2 )
		return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "prestigeButtonImage3" )

	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "heirloomButtonImage" )
}
#endif


#if UI
string function HeirloomEvent_GetHeirloomHeaderText( ItemFlavor event )
{
	Assert( HEIRLOOM_EVENTS.contains( ItemFlavor_GetType( event ) ) )

	string headerText = "#COLLECTION_EVENT_HEIRLOOM_BOX_TITLE"
	if ( HeirloomEvent_AwardHeirloomShards( event ) )
		headerText = "#CURRENCY_HEIRLOOM_NAME_SHORT"
	else if ( HeirloomEvent_IsRewardMythicSkin( event ) )
		headerText = "#COLLECTION_EVENT_MYTHIC_BOX_TITLE"
	else if ( !HeirloomEvent_IsRewardHeirloom( event ) )
		headerText = "#COLLECTION_EVENT_REACTIVE_BOX_TITLE"

	return Localize( headerText ).toupper()
}
#endif

#if UI
bool function HeirloomEvent_IsRewardHeirloom( ItemFlavor event )
{
	Assert( HEIRLOOM_EVENTS.contains( ItemFlavor_GetType( event ) ) )
	ItemFlavor reward = HeirloomEvent_GetPrimaryCompletionRewardItem( event )

	if ( ItemFlavor_GetQuality( reward ) == eRarityTier.MYTHIC )
		return true

	return false
}
#endif

#if UI
string function HeirloomEvent_GetHeirloomUnlockDesc( ItemFlavor event )
{
	Assert( HEIRLOOM_EVENTS.contains( ItemFlavor_GetType( event ) ) )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "heirloomUnlockDesc" )
}
#endif

#if UI
bool function HeirloomEvent_IsCompletionRewardOwned( ItemFlavor event, bool isInventoryReady )
{
	Assert( HEIRLOOM_EVENTS.contains( ItemFlavor_GetType( event ) ) )

	bool isOwned = false

	if ( HeirloomEvent_AwardHeirloomShards( event ) )
	{
		return false
	}
	else
	{
		ItemFlavor completionRewardPack = HeirloomEvent_GetCompletionRewardPack( event )
		array<ItemFlavor> rewardPackContents = GRXPack_GetPackContents( completionRewardPack )
		foreach ( ItemFlavor flav in rewardPackContents )
		{
			isOwned = isInventoryReady && GRX_IsItemOwnedByPlayer( flav )

			if ( HeirloomEvent_IsRewardMythicSkin( event ) && isOwned == true )
			{
				// Even if player has unlocked only one of the three mythic skins, consider the reward is redeemed
				break
			}
		}
	}

	return isOwned
}
#endif

#if UI
bool function CollectionEvent_HasLobbyTheme( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsBool( ItemFlavor_GetAsset( event ), "themeLobby" )
}
#endif

#if UI
asset function CollectionEvent_GetLobbyButtonImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "lobbyButtonImage" )
}
#endif

//V2.0 Settings
#if UI
bool function CollectionEvent_IsV2PlaylistVarEnabled()
{
	return GetCurrentPlaylistVarBool( "enable_collection_event_v2", true )
}
#endif
//END V2.0 Settings

#if SERVER || CLIENT || UI
int function HeirloomEvent_GetItemCount( ItemFlavor event, bool onlyOwned, entity player = null, bool dontCheckInventoryReady = false )
{
	Assert( dontCheckInventoryReady || !onlyOwned || ( player != null && GRX_IsInventoryReady( player ) ) )

	int count = 0
	array < ItemFlavor > eventItems
                    
	if ( ItemFlavor_GetType( event ) == eItemType.calevent_collection || ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
     
                                                                    
      
	{
		eventItems = []
		array<CollectionEventRewardGroup> rewardGroups = CollectionEvent_GetRewardGroups( event )
		foreach ( CollectionEventRewardGroup rewardGroup in rewardGroups )
		{
			foreach ( ItemFlavor reward in rewardGroup.rewards )
			{
				eventItems.append( reward )
			}
		}
	}
	else if ( ItemFlavor_GetType( event ) == eItemType.calevent_themedshop )
	{
		eventItems = GRXPack_GetPackContents( GetItemFlavorByAsset( ThemedShopEvent_GetAssociatedPack( event ) ) )
	}

	foreach ( ItemFlavor item in eventItems )
	{
		// use the Code-native GRX_HasItem here because we want the MOST restrictive interpretation possible around ownership here to prevent miscalculation
		#if SERVER
			if ( !onlyOwned || GRX_HasItem( player, ItemFlavor_GetGRXIndex( item ) ) )
				count++

			// for PIN tracking only - this will fire the PIN event if we *would* have accidentally miscounted
			if ( onlyOwned && player != null && GRX_IsInventoryReady( player ) && GetCurrentPlaylistVarBool( "grx_collection_event_pin_reporting", false ) )
				GRX_IsItemOwnedByPlayer_AllowOutOfDateData( item, player )
		#endif
		#if CLIENT || UI
			if ( !onlyOwned || GRX_HasItem( ItemFlavor_GetGRXIndex( item ) ) )
				count++
		#endif
	}

	return count
}
#endif

#if UI
array<ItemFlavor> function CollectionEvent_GetEventItems( ItemFlavor event )
{
	array<ItemFlavor> eventItems
                    
	if ( ItemFlavor_GetType( event ) == eItemType.calevent_collection || ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
     
                                                                    
      
	{
		array<CollectionEventRewardGroup> rewardGroups = CollectionEvent_GetRewardGroups( event )
		foreach ( CollectionEventRewardGroup rewardGroup in rewardGroups )
		{
			foreach ( ItemFlavor reward in rewardGroup.rewards )
			{
				eventItems.append( reward )
			}
		}
	}
	return eventItems
}

asset function CollectionEvent_GetCustomIconForItemIdx( ItemFlavor event, int grxIdx, bool isRestricted = false )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_collection )

	array<CollectionEventRewardGroup> groups = []
	string rewardPath = isRestricted ? "restrictedRewardGroups" : "rewardGroups"
	foreach ( var groupBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), rewardPath ) )
	{
		CollectionEventRewardGroup group
		group.ref = GetSettingsBlockString( groupBlock, "ref" )
		group.quality = eRarityTier[GetSettingsBlockString( groupBlock, "quality" )]
		foreach ( var rewardBlock in IterateSettingsArray( GetSettingsBlockArray( groupBlock, "rewards" ) ) )
		{
			ItemFlavor item = GetItemFlavorByAsset( GetSettingsBlockAsset( rewardBlock, "flavor" ) )
			if ( item.grxIndex == grxIdx )
			{
				return GetSettingsBlockAsset( rewardBlock, "collectionItemCustomImage" )
			}
		}
	}
	Assert( false )
	unreachable
}

bool function CollectionEvent_IsItemFlavorFromEvent( ItemFlavor event, int itemIdx )
{
	array<ItemFlavor> eventItems = CollectionEvent_GetEventItems( event )
	foreach( ItemFlavor item in eventItems )
	{
		if ( item.grxIndex == itemIdx )
			return true
	}
	return false
}
#endif

#if SERVER || CLIENT || UI
int function HeirloomEvent_GetCurrentRemainingItemCount( ItemFlavor event, entity player )
{
	return HeirloomEvent_GetItemCount( event, false ) - HeirloomEvent_GetItemCount( event, true, player )
}
#endif

#if UI
GRXScriptOffer ornull function CollectionEvent_GetPackOffer( ItemFlavor event )
{
	array<GRXScriptOffer> ornull offers = CollectionEvent_GetPackOffers( event )
	if ( offers == null )
		return null
	expect array<GRXScriptOffer>( offers )
	if ( offers.len() == 0 )
		return null
	return offers[0]
}

array<GRXScriptOffer> ornull function CollectionEvent_GetPackOffers( ItemFlavor event )
{
	if ( GRX_IsOfferRestricted() )
		return null

	ItemFlavor packFlav          = CollectionEvent_GetMainPackFlav( event )
	string offerLocation         = CollectionEvent_GetFrontPageGRXOfferLocation( event )
	array<GRXScriptOffer> offers = GRX_GetItemDedicatedStoreOffers( packFlav, offerLocation )
	offers.sort( int function( GRXScriptOffer a, GRXScriptOffer b ){
		if ( a.items[0].itemQuantity > b.items[0].itemQuantity )
			return 1
		else if (  a.items[0].itemQuantity < b.items[0].itemQuantity )
			return -1
		return 0
	} )
	return offers.len() > 0 ? offers : null
}
#endif

#if SERVER || UI
int function CollectionEvent_GetCurrentMaxEventPackPurchaseCount( ItemFlavor event, entity player )
{
	#if SERVER
		if ( GRX_IsOfferRestricted( player ) )
			return 0
	#elseif UI
		if ( CollectionEvent_GetPackOffers( event ) == null )
			return 0
	#endif


	ItemFlavor packFlav = CollectionEvent_GetMainPackFlav( event )
	#if SERVER
		int ownedPackCount = GRX_GetPackCount( player, ItemFlavor_GetGRXIndex( packFlav ) )
	#elseif UI
		int ownedPackCount = GRX_GetPackCount( ItemFlavor_GetGRXIndex( packFlav ) )
	#endif

	return HeirloomEvent_GetCurrentRemainingItemCount( event, player ) - ownedPackCount
}
#endif

#if SERVER
void function CollectionEvent_RevokeHeirloomMisgrant( entity player )
{
	Assert( false , "CollectionEvent_RevokeHeirloomMisgrant is currently not setup" ) // remove me when using
	return

	// leave this as bespoke internals but make it a generic function in case we need to do this again...
	// Reward Seq: rewardseq_s11e01_collection --> 1 if player is registered as having gotten the CE items
	// Check Valve: hasCheckedS11E01HeirloomMisgrant
	// Event: itemflav\calevent\s11e01\collection (GUID 234772736)
	// One-Time Make Good: rewardseq_s11e01_revocation_make_good
	// IF NEEDED: AddCallback_FirstTimeInventoryClean( CollectionEvent_RevokeHeirloomMisgrant )

	// have we already checked them - early out
	// *ADD* a new bool to Persistence if using
	if ( expect bool( player.GetPersistentVar( "" ) ) )
		return

	ItemFlavor revocationEvent = GetItemFlavorByGUID( 0 )

	int totalItems         = HeirloomEvent_GetItemCount( revocationEvent, false, player, true )
	int collectionProgress = HeirloomEvent_GetItemCount( revocationEvent, true, player, true )

	// do they have everything - early out
	if ( collectionProgress >= totalItems && totalItems > 0 )
		return

	string seqName = HeirloomEvent_GetCompletionSequenceName( revocationEvent )
	int seqIdx     = GRX_GetSequenceNumber( player, seqName )

	// if they don't register as having completed the event - early out
	if ( seqIdx < 1 )
		return

	ItemFlavor heirloomPackFlav = HeirloomEvent_GetCompletionRewardPack( revocationEvent )
	array<ItemFlavor> packContents = GRXPack_GetPackContents( heirloomPackFlav )
	Assert( packContents.len() > 0 )
	int numOwned = 0
	foreach ( packContent in packContents )
	{
		if ( GRX_HasItem( player, ItemFlavor_GetGRXIndex( packContent ) ) )
			++numOwned
	}

	// if somehow they don't actually own anything - early out
	if ( numOwned == 0 )
		return

	array<ItemFlavor> itemsToRemove = []

	foreach ( ItemFlavor flav in packContents )
	{
		if ( GRX_HasItem( player, ItemFlavor_GetGRXIndex( flav ) ) )
			itemsToRemove.append( flav )
	}

	if ( itemsToRemove.len() > 0 )
	{
		ScriptGRXOperationInfo operation
		operation.expectedQueryGoal = GRX_HTTPQUERYGOAL_DELETE_ITEMS
		operation.doOperationFunc = ( void function( int opID ) : ( player, itemsToRemove )
		{
			RemoveMisgrantedItems( player, opID, itemsToRemove )
		})

		operation.onDoneCallback = (void function( int status ) : ( player )
		{
			if ( status != eScriptGRXOperationStatus.DONE_SUCCESS )
				return
		})

		QueueGRXOperation( player, operation, false )
	}

	// now reset their status
	player.SetPersistentVar( "", true )
	player.SetPersistentVar( seqName, 0 )

	// ONLY ONCE - give them a CE pack to say sorry
	// *ADD* a new rewardseq to Marketplace & Persistence
	string oneTimeRewardSeq = ""
	int oneTimeSeqIdx = GRX_GetSequenceNumber( player, oneTimeRewardSeq )

	if ( oneTimeSeqIdx > 0 || oneTimeSeqIdx == GRX_INVALID_SEQUENCE_NUMBER )
		return

	ItemFlavor eventPack = CollectionEvent_GetMainPackFlav( revocationEvent )

	ScriptGRXOperationInfo operation
	operation.expectedQueryGoal = GRX_HTTPQUERYGOAL_GIVE_BONUS_UNKNOWN_SEQUENCE_REWARD
	operation.doOperationFunc = (void function( int opID ) : ( player, oneTimeRewardSeq, eventPack )
	{
		ItemFlavorBag what = MakeItemFlavorBag( { [eventPack] = 1, } )
		GRX_GiveSequenceRewardEasy( player, opID, GRX_HTTPQUERYGOAL_GIVE_BONUS_UNKNOWN_SEQUENCE_REWARD, oneTimeRewardSeq,
			0, 1, // current, desired
			what )
	})
	operation.onDoneCallback = null
	QueueGRXOperation( player, operation )

}
#endif

#if SERVER
void function RemoveMisgrantedItems( entity player, int opID, array<ItemFlavor> itemsToRemove )
{
	array<int> idxsToRemove = []
	foreach ( ItemFlavor flavor in itemsToRemove )
	{
		idxsToRemove.append( ItemFlavor_GetGRXIndex( flavor ) )
	}

	GRX_RemoveCosmetics( player, opID, idxsToRemove )

	// Reset the persistence state for each item we removed
	// This is done before we affirm the delete, to err on the side of not showing a popup for deleted items if the response arrives late.
	foreach ( ItemFlavor flavor in itemsToRemove )
	{
		// "new" red dot in menu titles
		SettingsAssetGUID GUID = ItemFlavor_GetGUID( flavor )
		Newness_MarkItemFlavorGUIDAsNotNewForPlayer( player, GUID )
	}
}
#endif

//#if SERVER || UI
//bool function CollectionEvent_IsHeirloomDirectPurchaseCurrentlyAllowed( ItemFlavor event, entity player )
//{
//	#if UI
//		if ( CollectionEvent_GetHeirloomOffer( event ) == null )
//			return false
//	#endif
//
//	ItemFlavor heirloomPrimaryFlav = CollectionEvent_GetPrimaryCompletionRewardItem( event )
//	if ( GRX_IsItemOwnedByPlayer( heirloomPrimaryFlav, player ) )
//		return false
//
//	ItemFlavor heirloomPurchaseFlav = CollectionEvent_GetHeirloomPurchaseItemFlav( event )
//	Assert( ItemFlavor_GetGRXMode( heirloomPurchaseFlav ) == eItemFlavorGRXMode.PACK )
//	#if SERVER
//		int purchaseFlavCount = GRX_GetPackCount( player, ItemFlavor_GetGRXIndex( heirloomPurchaseFlav ) )
//	#elseif UI
//		int purchaseFlavCount = GRX_GetPackCount( ItemFlavor_GetGRXIndex( heirloomPurchaseFlav ) )
//	#endif
//	if ( purchaseFlavCount > 0 )
//		return false
//
//	if ( CollectionEvent_GetCurrentRemainingItemCount( event, player ) > 0 )
//		return false
//
//	if ( GRX_IsOfferRestricted( player ) )
//		return false
//
//	return true
//}
//#endif



///////////////////////
///////////////////////
//// Dev functions ////
///////////////////////
///////////////////////

//



///////////////////
///////////////////
//// Internals ////
///////////////////
///////////////////

#if SERVER
void function QueueServersideScriptGRXOperations( entity player )
{
	ItemFlavor ornull activeHeirloomEvent = null
	ItemFlavor ornull activeCollectionEvent = GetActiveCollectionEvent( GetUnixTimestamp() )

	if ( activeCollectionEvent != null )
		activeHeirloomEvent = activeCollectionEvent

	if ( activeHeirloomEvent == null )
		return
	expect ItemFlavor(activeHeirloomEvent)

	// Only do login rewards for Collection Events, *not* Themed Shop Events
	if ( !(player in fileLevel.loginRewardsChecked) && activeCollectionEvent != null )
	{
		fileLevel.loginRewardsChecked[ player ] <- IN_SET

		foreach ( ItemFlavor reward in CollectionEvent_GetLoginRewards( activeHeirloomEvent ) )
		{
			if ( GRX_HasItem( player, ItemFlavor_GetGRXIndex( reward ) ) )
				continue

			table scriptStateInfos = GRX_GetScriptStateInfoForPIN( player )
			table pinData = { [ string( ItemFlavor_GetGRXIndex( reward ) ) ] = ItemFlavor_GetHumanReadableRefForPIN_Slow( reward ) }
			pinData[ "script_state_info" ] <- scriptStateInfos
			if ( GetCurrentPlaylistVarBool( "grx_collection_event_pin_reporting", false ) )
				PIN_GRXPlayerGotCollectionLogin( player, pinData )

			GrantRewardsConfig grc
			grc.what = MakeItemFlavorBag( { [reward] = 1, } )
			grc.sourceFlav = activeHeirloomEvent
			grc.showCeremony = true
			int result = GRX_GrantRewards( player, grc )
			Assert( result == eGrantRewardsResult.DONE )
		}
	}

	if ( !(player in fileLevel.heirloomPackGrantQueued) )
	{
		// Auto-granting of heirloom pack
		int totalItems         = HeirloomEvent_GetItemCount( activeHeirloomEvent, false, player, true )
		int collectionProgress = HeirloomEvent_GetItemCount( activeHeirloomEvent, true, player, true )

		if ( collectionProgress >= totalItems && totalItems > 0 )
		{
			string seqName = HeirloomEvent_GetCompletionSequenceName( activeHeirloomEvent )
			int seqIdx     = GRX_GetSequenceNumber( player, seqName )
			#if DEVELOPER
				Assert( seqIdx != GRX_INVALID_SEQUENCE_NUMBER, seqName + " is not a valid reward sequence" )
			#endif

			if ( seqIdx < 1 && seqIdx != GRX_INVALID_SEQUENCE_NUMBER )
			{
				if ( GetCurrentPlaylistVarBool( "grx_collection_event_pin_reporting", false ) )
				{
					table scriptStateInfos = GRX_GetScriptStateInfoForPIN( player )
					table pinData = GetEventPINData( activeHeirloomEvent, player )
					pinData[ "script_state_info" ] <- scriptStateInfos
					PIN_GRXPlayerGotCollectionHeirloom( player, pinData )
				}

				fileLevel.heirloomPackGrantQueued[ player ] <- IN_SET

				ItemFlavor heirloomPackFlav = HeirloomEvent_GetCompletionRewardPack( activeHeirloomEvent )

				ScriptGRXOperationInfo operation
				operation.expectedQueryGoal = GRX_HTTPQUERYGOAL_GIVE_HEIRLOOM_SEQUENCE_REWARD
				operation.doOperationFunc = (void function( int opID ) : ( player, seqName, heirloomPackFlav )
				{
					ItemFlavorBag what = MakeItemFlavorBag( { [heirloomPackFlav] = 1, } )
					GRX_GiveSequenceRewardEasy( player, opID, GRX_HTTPQUERYGOAL_GIVE_HEIRLOOM_SEQUENCE_REWARD, seqName,
						0, 1, // current, desired
						what )
				})
				operation.onDoneCallback = null
				QueueGRXOperation( player, operation )
			}
		}
	}
}
#endif

#if SERVER
table function GetEventPINData( ItemFlavor event, entity player )
{
	table pinData = {}

	array < ItemFlavor > eventItems
                    
	if ( ItemFlavor_GetType( event ) == eItemType.calevent_collection || ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
     
                                                                    
      
	{
		eventItems = []
		array<CollectionEventRewardGroup> rewardGroups = CollectionEvent_GetRewardGroups( event )
		foreach ( CollectionEventRewardGroup rewardGroup in rewardGroups )
		{
			foreach ( ItemFlavor reward in rewardGroup.rewards )
			{
				eventItems.append( reward )
			}
		}
	}
	else if ( ItemFlavor_GetType( event ) == eItemType.calevent_themedshop )
	{
		eventItems = GRXPack_GetPackContents( GetItemFlavorByAsset( ThemedShopEvent_GetAssociatedPack( event ) ) )
	}

	foreach ( ItemFlavor reward in eventItems )
	{
		if ( GRX_HasItem( player, ItemFlavor_GetGRXIndex( reward ) ) )
			pinData[ string( ItemFlavor_GetGRXIndex( reward ) ) ] <- ItemFlavor_GetHumanReadableRefForPIN_Slow( reward )
	}

	return pinData
}
#endif

#if SERVER
void function CollectionEvent_OnPlayerDisconnected( entity player )
{
	if ( IsLobby() )
	{
		if ( player in fileLevel.loginRewardsChecked )
			delete fileLevel.loginRewardsChecked[ player ]

		if ( player in fileLevel.heirloomPackGrantQueued )
			delete fileLevel.heirloomPackGrantQueued[ player ]
	}
}
#endif