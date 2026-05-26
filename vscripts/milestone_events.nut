#if SERVER || CLIENT || UI
global function MilestoneEvents_Init
#endif

#if SERVER || CLIENT || UI
global function GetActiveMilestoneEvent
global function GetActiveEventTabMilestoneEvent
global function GetActiveStoreOnlyMilestoneEvents
global function GetAllMilestoneEvents
global function IsMilestoneEventStoreOnly
global function GetAllActiveMilestoneEvents
global function MilestoneEvent_GetEventId
global function MilestoneEvent_GetEventById
global function MilestoneEvent_IsEventStoreOnly
global function MilestoneEvent_GetFrontPageRewardBoxTitle
global function MilestoneEvent_GetMainPackFlav
global function MilestoneEvent_IsMilestonePackFlav
global function MilestoneEvent_GetMainPackImage
global function MilestoneEvent_GetFrontPageGRXOfferLocation
global function MilestoneEvent_GetAboutText
global function MilestoneEvent_GetMainIcon
global function MilestoneEvent_GetMilestoneGrantRewards
global function MilestoneEvent_GetStoreEventSectionMainImage
global function MilestoneEvent_GetStoreEventSectionMainText
global function MilestoneEvent_GetStoreEventSectionSubText
global function MilestoneEvent_IsChaseItem
global function MilestoneEvent_IsItemInPool
global function MilestoneEvent_GetEventItems
global function MilestoneEvent_GetEventItemsInPool
global function MilestoneEvent_GetMythicEventItems
global function MilestoneEvent_GetRewardGroups
global function MilestoneEvent_GetGuaranteedPackFlav
global function MilestoneEvent_IsItemEventItem
#endif

#if SERVER || UI
global function MilestoneEvent_GetCurrentMaxEventPackPurchaseCount
#endif

#if UI
global function MilestoneEvent_IsPlaylistVarEnabled
global function MilestoneEvent_UseOriginalEventTabLayout
global function MilestoneEvent_GetGuaranteedMultiPackOffers
global function MilestoneEvent_GetSinglePackOffers
global function MilestoneEvent_GetMultiPackOffers
global function MilestoneEvent_GetCustomIconForItemIdx
global function MilestoneEvent_GetCarouselItemDescriptionText
global function MilestoneEvent_GetRemainingCompletionItemsForCurrentMilestone
global function MilestoneEvent_GetDisclaimerBoxColor
global function MilestoneEvent_GetMilestoneBoxTitleColor
global function MilestoneEvent_GetTitleBGColor
global function MilestoneEvent_GetFullscreenBGDarkening
global function MilestoneEvent_GetGridSizeOverride
global function MilestoneEvent_GetChaseItemUnlockDescription
global function MilestoneEvent_GetChaseItemIcon
global function MilestoneEvent_GetMainPackShortPluralName
global function MilestoneEvent_GetFeaturedItems
global function MilestoneEvent_GetEventDescription
global function MilestoneEvent_GetTitleCol
global function MilestoneEvent_GetPackOffers
global function MilestoneEvent_IsItemFlavorFromEvent
global function MilestoneEvent_IsMythicEventItem
global function MilestoneEvent_IsMilestoneGrantReward
global function MilestoneEvent_IsMilestoneRewardCeremonyDue
global function MilestoneEvent_DecrementMilestoneRewardCeremonyCount
global function MilestoneEvent_MoveToLobbyForMilestoneRewardCeremony
global function MilestoneEvent_TryDisplayMilestoneRewardCeremony
global function MilestoneEvent_TryMoveToMilestonePostRewardCeremony
global function ServerCallback_MilestoneEvent_MilestoneRewardCeremonyIsDue
global function MilestoneEvent_GetEventIcon
global function MilestoneEvent_GetEventKeyArt
global function MilestoneEvent_GetCollectionBoxBGImage
global function MilestoneEvent_GetCollectionBoxBlur
global function MilestoneEvent_GetCollectionBoxBlurImage
global function MilestoneEvent_GetTrackerBoxBGImage
global function MilestoneEvent_GetTrackerBoxBlur
global function MilestoneEvent_GetTrackerBoxBlurImage
global function MilestoneEvent_GetInfoBoxBGImage
global function MilestoneEvent_GetInfoBoxBlur
global function MilestoneEvent_GetInfoBoxBlurImage
global function MilestoneEvent_GetMilestoneTrackerProgressBarColor
global function MilestoneEvent_GetMilestoneTrackerProgressBarBGColor
global function MilestoneEvent_GetPackInfoModalInfo
global function MilestoneEvent_EventAwardsArtifact

//Pack Info Dialog Getters
global function MilestoneEvent_GetEventItemsRatesSectionHeader
global function MilestoneEvent_GetEventItemRatesData
global function MilestoneEvent_GetStandardItemRatesData
global function MilestoneEvent_GetMultiItemRatesData
global function MilestoneEvent_GetPricePackRangesData
global function MilestoneEvent_GetLegalTextData
global function MilestoneEvent_GetGuaranteedPackText

global function MilestoneEvent_GetTitleHeaderText
global function MilestoneEvent_GetTitleSubheaderText
global function MilestoneEvent_GetTitleMainIcon
global function MilestoneEvent_GetTitleUseBackgroundBlur
global function MilestoneEvent_GetTitleBlurImage
global function MilestoneEvent_GetTitleBackgroundDarkening
global function MilestoneEvent_GetTitleBackgroundImage
global function MilestoneEvent_GetTitleHeaderColor
global function MilestoneEvent_GetTitleSubheaderColor
global function MilestoneEvent_GetPackProbabilitiesStrings

global function SetStoreOnlyEventsFilter
#endif

#if SERVER || CLIENT || UI
global struct MilestoneEventGrantReward
{
	int         grantingLevel
	ItemFlavor& rewardFlav
	asset 		customImage
	string		customName
}
#endif

#if UI
global struct RTKPackPurchaseSelectionButtonData
{
	string price
	asset image
	int discount
}

global struct RTKPurchasePackRateInfo
{
	string title
	string rate
	int quality
}

global struct RTKPurchasePackRowRatesInfo
{
	array<RTKPurchasePackRateInfo> rates
}

global struct RTKPurchasePackRateSectionInfo
{
	string title
	vector color
	array<RTKPurchasePackRowRatesInfo> rows
}

global struct RTKPurchasePackPriceInfo
{
	string title
	string originalPrice
	string price
	string craftingPrice
	string discount
	float discountBGAlpha
}

global struct RTKPurchasePackRowPriceInfo
{
	array<RTKPurchasePackPriceInfo> prices
}


global struct RTKPurchasePackPriceSectionInfo
{
	string title
	vector color
	array<RTKPurchasePackRowPriceInfo> rows
}

global struct RTKPurchasePackInformationLines
{
	array<string> text
}

global struct RTKPackProbabilitiesStrings
{
	string eventItemRatesHeader
	string eventItemRatesLine1
	string eventItemRatesLine2
	string eventItemRatesLine3
	string standardItemRatesHeader
	string standardItemRatesLine1
}

global struct AboutPacksInfoModal
{
	string packInfoModalHeaderText
	string packInfoDetailsText1
	string packInfoDetailsText2
	string packInfoDetailsText3
	string packInfoDetailsText4

	string eventItemsRowLabel

	array<RTKPurchasePackRowRatesInfo> itemRates
	RTKPurchasePackRowPriceInfo& packPriceThresholds

	bool hasMultiPackOffers
	bool hasCraftingOffers
}
#endif

#if SERVER || CLIENT || UI
struct FileStruct_LifetimeLevel
{
	EntitySet chasePackGrantQueued
	int milestoneEvents_MilestoneRewardCount = 0
	bool storeOnlyEvents = false
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


#if SERVER || CLIENT || UI
void function MilestoneEvents_Init()
{
	#if UI
		FileStruct_LifetimeLevel newFileLevel
		fileLevel = newFileLevel
	#endif

	#if SERVER
		AddCallback_QueueServersideScriptGRXOperations( QueueServersideScriptGRXOperations )
		AddCallback_OnClientDisconnected( MilestoneEvent_OnPlayerDisconnected )
	#endif
}
#endif

#if SERVER || CLIENT || UI
ItemFlavor ornull function GetActiveMilestoneEvent( int t )
{
	Assert( IsItemFlavorRegistrationFinished() )


#if SERVER || CLIENT
	// todo (kk): R5DEV-591645 : Remove this when clients can get an active milestone event via Bakery setting
	ItemFlavor ornull event = null
	foreach ( ItemFlavor ev in GetAllItemFlavorsOfType( eItemType.calevent_milestone ) )
	{
		if ( !CalEvent_IsActive( ev, t ) )
			continue

		Assert( event == null, format( "Multiple milestone events are active!! (%s, %s)", string(ItemFlavor_GetAsset( expect ItemFlavor(event) )), string(ItemFlavor_GetAsset( ev )) ) )

		event = ev
	}

	return event
#endif

#if UI
	// limiting this part to UI since storeOnlyEvents value can only be updated in UI
	if ( fileLevel.storeOnlyEvents )
	{
		array<ItemFlavor> activeStoreOnlyMilestoneEvents = GetActiveStoreOnlyMilestoneEvents( t )
		if ( activeStoreOnlyMilestoneEvents.len() > 0 )
		{
			ItemFlavor ornull event = activeStoreOnlyMilestoneEvents[0]
			return event
		}
		else
			return null
	}
	else
	{
		return GetActiveEventTabMilestoneEvent( t )
	}
#endif

	unreachable
}
#endif

#if UI
void function SetStoreOnlyEventsFilter( bool storeOnlyEvents )
{
	fileLevel.storeOnlyEvents = storeOnlyEvents
}
#endif

#if SERVER || CLIENT || UI
ItemFlavor ornull function GetActiveEventTabMilestoneEvent( int t )
{
	Assert( IsItemFlavorRegistrationFinished() )
	ItemFlavor ornull event = null
	foreach ( ItemFlavor ev in GetAllItemFlavorsOfType( eItemType.calevent_milestone ) )
	{
		if ( !CalEvent_IsActive( ev, t ) )
			continue

		bool isStoreOnly = GetGlobalSettingsBool( ItemFlavor_GetAsset( ev ), "isStoreOnlyMilestoneEvent" )
		if ( isStoreOnly )
			continue

		Assert( event == null, format( "Multiple collection events are active!! (%s, %s)", string(ItemFlavor_GetAsset( expect ItemFlavor(event) )), string(ItemFlavor_GetAsset( ev )) ) )
		event = ev
	}
	return event
}
#endif

#if SERVER || CLIENT || UI
array<ItemFlavor> function GetActiveStoreOnlyMilestoneEvents( int t )
{
	Assert( IsItemFlavorRegistrationFinished() )
	array<ItemFlavor> activeStoreOnlyMilestoneEvents
	foreach ( ItemFlavor ev in GetAllItemFlavorsOfType( eItemType.calevent_milestone ) )
	{
		if ( !CalEvent_IsActive( ev, t ) )
			continue

		bool isStoreOnly = GetGlobalSettingsBool( ItemFlavor_GetAsset( ev ), "isStoreOnlyMilestoneEvent" )
		if ( !isStoreOnly )
			continue

		activeStoreOnlyMilestoneEvents.append( ev )
	}
	return activeStoreOnlyMilestoneEvents
}
#endif

#if SERVER || CLIENT || UI
array<ItemFlavor> function GetAllMilestoneEvents( bool includeEventTab = true, bool includeStoreOnly = false )
{
	Assert( IsItemFlavorRegistrationFinished() )
	array<ItemFlavor> storeOnlyMilestoneEvents
	foreach ( ItemFlavor ev in GetAllItemFlavorsOfType( eItemType.calevent_milestone ) )
	{
		bool isStoreOnly = GetGlobalSettingsBool( ItemFlavor_GetAsset( ev ), "isStoreOnlyMilestoneEvent" )

		if ( !includeEventTab && !isStoreOnly )
			continue

		if ( !includeStoreOnly && isStoreOnly )
			continue

		storeOnlyMilestoneEvents.append( ev )
	}
	return storeOnlyMilestoneEvents
}
#endif

#if SERVER || CLIENT || UI
bool function IsMilestoneEventStoreOnly( ItemFlavor ornull event )
{
	if ( event == null )
		return false

	expect ItemFlavor( event )

	Assert( IsItemFlavorRegistrationFinished() )
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsBool( ItemFlavor_GetAsset( event ), "isStoreOnlyMilestoneEvent" )
}
#endif

#if SERVER || CLIENT || UI
array<ItemFlavor> function GetAllActiveMilestoneEvents( int t )
{
	Assert( IsItemFlavorRegistrationFinished() )
	array<ItemFlavor> activeMilestoneEvents

	ItemFlavor ornull activeEvent = GetActiveMilestoneEvent( t )
	if ( activeEvent != null )
	{
		expect ItemFlavor( activeEvent )
		activeMilestoneEvents.append( activeEvent )
	}

	foreach ( ItemFlavor event in GetActiveStoreOnlyMilestoneEvents( t ) )
	{
		activeMilestoneEvents.append( event )
	}

	return activeMilestoneEvents
}
#endif

#if SERVER || CLIENT || UI
string function MilestoneEvent_GetEventId( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return ItemFlavor_GetGUIDString( event )
}
#endif

#if SERVER || CLIENT || UI
ItemFlavor ornull function MilestoneEvent_GetEventById( string id, bool activeOnly = false )
{
	Assert( IsItemFlavorRegistrationFinished() )
	Assert( id != "" )
	ItemFlavor ornull event = null
	int unixTimeNow = GetUnixTimestamp()
	foreach ( ItemFlavor ev in GetAllItemFlavorsOfType( eItemType.calevent_milestone ) )
	{
		if ( activeOnly && !CalEvent_IsActive( ev, unixTimeNow ) )
			continue

		if ( MilestoneEvent_GetEventId( ev ) == id )
			return ev
	}
	return null
}
#endif

#if SERVER || CLIENT || UI
bool function MilestoneEvent_IsEventStoreOnly(  ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsBool( ItemFlavor_GetAsset( event ), "isStoreOnlyMilestoneEvent" )
}
#endif

#if SERVER || CLIENT || UI
array<ItemFlavor> function MilestoneEvent_GetLoginRewards( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )

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
string function MilestoneEvent_GetFrontPageRewardBoxTitle( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "frontPageRewardBoxTitle" )
}
#endif

#if UI
array<GRXScriptOffer> function MilestoneEvent_GetGuaranteedMultiPackOffers( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	array<GRXScriptOffer> offers = GRX_GetItemDedicatedStoreOffers( MilestoneEvent_GetGuaranteedPackFlav( event ), MilestoneEvent_GetFrontPageGRXOfferLocation( event, GRX_IsOfferRestricted() ) )
	return offers
}
#endif

#if UI
array<GRXScriptOffer> function MilestoneEvent_GetSinglePackOffers( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	array<GRXScriptOffer> singlePackOffers = []

	// Main Pack Offers
	array<GRXScriptOffer> mainPackOffers = GRX_GetItemDedicatedStoreOffers( MilestoneEvent_GetMainPackFlav( event ), MilestoneEvent_GetFrontPageGRXOfferLocation( event, GRX_IsOfferRestricted() ) )
	foreach( offer in mainPackOffers )
	{
		int count = 0
		foreach ( quantity in offer.output.quantities )
			count += quantity

		if ( count == 1 )
			singlePackOffers.append( offer )
	}

	// Guaranteed Pack Offers
	array<GRXScriptOffer> guaranteedPackOffers = GRX_GetItemDedicatedStoreOffers( MilestoneEvent_GetGuaranteedPackFlav( event ), MilestoneEvent_GetFrontPageGRXOfferLocation( event, GRX_IsOfferRestricted() ) )
	foreach( offer in guaranteedPackOffers )
	{
		int count = 0
		foreach ( quantity in offer.output.quantities )
			count += quantity

		if ( count == 1 )
			singlePackOffers.append( offer )
	}

	return singlePackOffers
}
#endif

#if UI
array<GRXScriptOffer> function MilestoneEvent_GetMultiPackOffers( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	array<GRXScriptOffer> multiPackOffers = []

	// Main Pack Offers
	array<GRXScriptOffer> mainPackOffers = GRX_GetItemDedicatedStoreOffers( MilestoneEvent_GetMainPackFlav( event ), MilestoneEvent_GetFrontPageGRXOfferLocation( event, GRX_IsOfferRestricted() ) )
	foreach( offer in mainPackOffers )
	{
		int count = 0
		foreach ( quantity in offer.output.quantities )
			count += quantity

		if ( count > 1 )
			multiPackOffers.append( offer )
	}

	// Guaranteed Pack Offers
	array<GRXScriptOffer> guaranteedPackOffers = GRX_GetItemDedicatedStoreOffers( MilestoneEvent_GetGuaranteedPackFlav( event ), MilestoneEvent_GetFrontPageGRXOfferLocation( event, GRX_IsOfferRestricted() ) )
	foreach( offer in guaranteedPackOffers )
	{
		int count = 0
		foreach ( quantity in offer.output.quantities )
			count += quantity

		if ( count > 1 )
			multiPackOffers.append( offer )
	}

	return multiPackOffers
}
#endif

#if SERVER || CLIENT || UI
ItemFlavor function MilestoneEvent_GetMainPackFlav( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetItemFlavorByAsset( GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "mainPackFlav" ) )
}
#endif

#if SERVER || CLIENT || UI
bool function MilestoneEvent_IsMilestonePackFlav( ItemFlavor pack, bool checkEventTab, bool checkStoreOnly )
{
	array<ItemFlavor> milstoneEvents = GetAllMilestoneEvents( checkEventTab, checkStoreOnly )

	foreach ( ItemFlavor event in milstoneEvents )
	{
		ItemFlavor packFlav = MilestoneEvent_GetMainPackFlav( event )
		if ( packFlav == pack )
			return true
	}
	return false
}
#endif

#if UI
string function MilestoneEvent_GetCarouselItemDescriptionText( ItemFlavor item )
{
	string descText = ""
	descText = GetLocalizedItemFlavorDescriptionForOfferButton( item, false )
	descText += " - "
	descText += Localize( GRX_IsInventoryReady() ? (GRX_IsItemOwnedByPlayer( item ) ? "#OWNED" : "#LOCKED") : "" )
	return descText
}
#endif

#if UI
int function MilestoneEvent_GetRemainingCompletionItemsForCurrentMilestone( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	array<MilestoneEventGrantReward> milestones = MilestoneEvent_GetMilestoneGrantRewards( event, GRX_IsOfferRestricted() )

	array<ItemFlavor> items = MilestoneEvent_GetEventItemsInPool( event, GRX_IsOfferRestricted() )
	items.extend( MilestoneEvent_GetMythicEventItems( event, GRX_IsOfferRestricted() ) )
	int collectionProgress 							= GRX_GetNumberOfOwnedItemsByPlayer( items )

	foreach( milestone in milestones )
	{
		if ( milestone.grantingLevel > collectionProgress )
			return milestone.grantingLevel - collectionProgress
	}
	return 0
}
#endif

#if UI
asset function MilestoneEvent_GetEventIcon( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "eventIcon" )
}
#endif

#if UI
asset function MilestoneEvent_GetEventKeyArt( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "milestoneEventKeyArt" )
}
#endif

#if SERVER || CLIENT || UI
ItemFlavor function MilestoneEvent_GetGuaranteedPackFlav( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetItemFlavorByAsset( GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "guaranteedPackFlav" ) )
}
#endif

#if SERVER || CLIENT || UI
bool function MilestoneEvent_IsChaseItem( ItemFlavor event, int grxIdx, bool isRestricted = false )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )

	string rewardPath = isRestricted ? "restrictedRewardGroups" : "rewardGroups"
	foreach ( var groupBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), rewardPath ) )
	{
		foreach ( var rewardBlock in IterateSettingsArray( GetSettingsBlockArray( groupBlock, "rewards" ) ) )
		{
			ItemFlavor item = GetItemFlavorByAsset( GetSettingsBlockAsset( rewardBlock, "flavor" ) )
			if ( item.grxIndex == grxIdx )
			{
				return GetSettingsBlockBool( rewardBlock, "milestoneItemIsChaseItem" )
			}
		}
	}
	unreachable
}
#endif

#if SERVER || CLIENT || UI
bool function MilestoneEvent_IsItemInPool( ItemFlavor event, int grxIdx, bool isRestricted = false )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )

	string rewardPath = isRestricted ? "restrictedRewardGroups" : "rewardGroups"
	foreach ( var groupBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), rewardPath ) )
	{
		foreach ( var rewardBlock in IterateSettingsArray( GetSettingsBlockArray( groupBlock, "rewards" ) ) )
		{
			ItemFlavor item = GetItemFlavorByAsset( GetSettingsBlockAsset( rewardBlock, "flavor" ) )
			if ( item.grxIndex == grxIdx )
			{
				return GetSettingsBlockBool( rewardBlock, "milestoneItemIsInItemPool" )
			}
		}
	}
	unreachable
}
#endif

#if UI
vector function MilestoneEvent_GetGridSizeOverride( ItemFlavor event, int grxIdx, bool isRestricted = false )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )

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
				int cols = GetSettingsBlockInt( rewardBlock, "milestoneItemGridSizeOverrideCols" )
				int rows = GetSettingsBlockInt( rewardBlock, "milestoneItemGridSizeOverrideRows" )
				return <cols, rows, 0>
			}
		}
	}
	unreachable
}
#endif

#if UI
string function MilestoneEvent_GetChaseItemUnlockDescription( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), GRX_IsOfferRestricted() ? "chaseItemUnlockDescRestrict" : "chaseItemUnlockDesc" )
}
#endif

#if UI
asset function MilestoneEvent_GetChaseItemIcon( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "chaseItemButtonImage" )
}
#endif

#if UI
string function MilestoneEvent_GetMainPackShortPluralName( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "mainPackShortPluralName" )
}
#endif


#if SERVER || CLIENT || UI
asset function MilestoneEvent_GetMainPackImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "mainPackImage" )
}
#endif

#if SERVER || CLIENT || UI
string function MilestoneEvent_GetFrontPageGRXOfferLocation( ItemFlavor event, bool isRestricted )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), isRestricted ? "restrictedGRXOfferLocation" : "frontGRXOfferLocation" )
}
#endif

#if SERVER || CLIENT || UI
array<string> function MilestoneEvent_GetAboutText( ItemFlavor event, bool restricted )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )

	array<string> aboutText = []
	string key              = (restricted ? "aboutTextRestricted" : "aboutTextStandard")
	foreach ( var aboutBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), key ) )
		aboutText.append( GetSettingsBlockString( aboutBlock, "text" ) )
	return aboutText
}
#endif

#if SERVER || CLIENT || UI
void function MilestoneEvent_GetMainIcon( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
}
#endif

#if SERVER || CLIENT || UI
array<MilestoneEventGrantReward> function MilestoneEvent_GetMilestoneGrantRewards( ItemFlavor event, bool isRestricted )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )

	array<MilestoneEventGrantReward> groups = []
	string rewardsGroupVar                  = isRestricted ? "restrictedMilestoneGroups" : "milestoneGroups"
	foreach ( var groupBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), rewardsGroupVar ) )
	{
		MilestoneEventGrantReward group
		group.grantingLevel = GetSettingsBlockInt( groupBlock, "milestoneLevel" )
		group.rewardFlav    = GetItemFlavorByAsset( GetSettingsBlockAsset( groupBlock, "reward" ) )
		group.customName 	= GetSettingsBlockString( groupBlock, "milestoneRewardCustomName" )
		group.customImage 	= GetSettingsBlockAsset( groupBlock, "milestoneRewardCustomImage" )
		groups.append( group )
	}
	return groups
}
#endif

#if SERVER || CLIENT || UI
asset function MilestoneEvent_GetStoreEventSectionMainImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "storeEventSectionMainImage" )
}
#endif // SERVER || CLIENT || UI

#if SERVER || CLIENT || UI
string function MilestoneEvent_GetStoreEventSectionMainText( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "storeEventSectionMainText" )
}
#endif // SERVER || CLIENT || UI

#if SERVER || CLIENT || UI
string function MilestoneEvent_GetStoreEventSectionSubText( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "storeEventSectionSubText" )
}
#endif // SERVER || CLIENT || UI

#if UI
string function MilestoneEvent_GetEventDescription( ItemFlavor event, bool isRestricted = false )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), isRestricted ? "milestoneEventDescriptionRestricted" : "milestoneEventDescription" )
}
#endif

#if UI
vector function MilestoneEvent_GetTitleCol( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "titleCol" )
}
#endif

#if UI
vector function MilestoneEvent_GetTitleBGColor( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "titleBackCol" )
}
#endif

#if UI
float function MilestoneEvent_GetFullscreenBGDarkening( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsFloat( ItemFlavor_GetAsset( event ), "fullscreenBgDarkeningOpacity" )
}
#endif

#if UI
vector function MilestoneEvent_GetMilestoneBoxTitleColor( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "titleMilestoneCol" )
}
#endif

#if UI
vector function MilestoneEvent_GetDisclaimerBoxColor( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "milestoneDisclaimerBoxCol" )
}
#endif

#if UI
vector function MilestoneEvent_GetMilestoneTrackerProgressBarColor( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "milestoneTrackerProgressBarCol" )
}
#endif

#if UI
vector function MilestoneEvent_GetMilestoneTrackerProgressBarBGColor( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "milestoneTrackerProgressBarBGCol" )
}
#endif

#if UI
asset function MilestoneEvent_GetCollectionBoxBGImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "milestoneCollectionBoxBgImage" )
}
#endif

#if UI
bool function MilestoneEvent_GetCollectionBoxBlur( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsBool( ItemFlavor_GetAsset( event ), "milestoneCollectionBoxUseBgBlur" )
}
#endif

#if UI
asset function MilestoneEvent_GetCollectionBoxBlurImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "milestoneCollectionBoxBlurImage" )
}
#endif

#if UI
asset function MilestoneEvent_GetTrackerBoxBGImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "milestoneTrackerBoxBgImage" )
}
#endif

#if UI
bool function MilestoneEvent_GetTrackerBoxBlur( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsBool( ItemFlavor_GetAsset( event ), "milestoneTrackerUseBgBlur" )
}
#endif

#if UI
asset function MilestoneEvent_GetTrackerBoxBlurImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "milestoneTrackerBlurImage" )
}
#endif

#if UI
asset function MilestoneEvent_GetInfoBoxBGImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "milestoneInfoBoxBgImage" )
}
#endif

#if UI
bool function MilestoneEvent_GetInfoBoxBlur( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsBool( ItemFlavor_GetAsset( event ), "milestoneInfoBoxUseBgBlur" )
}
#endif

#if UI
asset function MilestoneEvent_GetInfoBoxBlurImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "milestoneInfoBoxBlurImage" )
}
#endif

#if UI
array<ItemFlavor> function MilestoneEvent_GetFeaturedItems( ItemFlavor event, bool isRestricted = false )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )

	array<ItemFlavor> items = []
	foreach ( var rewardBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), "featuredItems" ) )
	{
		items.append( GetItemFlavorByAsset( GetSettingsBlockAsset( rewardBlock, "featuredItem" ) ) )
	}
	return items
}
#endif

#if UI
AboutPacksInfoModal function MilestoneEvent_GetPackInfoModalInfo( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )

	AboutPacksInfoModal info
	info.packInfoModalHeaderText = GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "packInfoModalHeaderText" )
	info.packInfoDetailsText1 = GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "packInfoDetailsText1" )
	info.packInfoDetailsText2 = GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "packInfoDetailsText2" )
	info.packInfoDetailsText3 = GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "packInfoDetailsText3" )
	info.packInfoDetailsText4 = GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "packInfoDetailsText4" )

	info.eventItemsRowLabel   = MilestoneEvent_GetEventItemsRatesSectionHeader( event )

	info.itemRates = MilestoneEvent_GetEventItemRatesData( event )
	info.packPriceThresholds = MilestoneEvent_GetPricePackRangesData( event )

	info.hasMultiPackOffers = GRX_EventHasMultiPackOffers( event )
	info.hasCraftingOffers = GRX_EventHasCraftingOffers( event )

	return info
}
#endif



#if SERVER || CLIENT || UI
array<ItemFlavor> function MilestoneEvent_GetEventItems( ItemFlavor event, bool isRestricted = false )
{
	array<ItemFlavor> chaseItems
	array<ItemFlavor> eventItems
	if ( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	{
		array<CollectionEventRewardGroup> rewardGroups = MilestoneEvent_GetRewardGroups( event, isRestricted )
		foreach ( CollectionEventRewardGroup rewardGroup in rewardGroups )
		{
			// We want to flip the order of the items so the most important ones come first
			rewardGroup.rewards.reverse()
			foreach ( ItemFlavor reward in rewardGroup.rewards )
			{
				// We'll put the chase items in a separate list to be added at the end
				if ( MilestoneEvent_IsChaseItem( event, reward.grxIndex, isRestricted ) )
					chaseItems.append( reward )
				else
					eventItems.append( reward )
			}
		}

		foreach ( ItemFlavor chaseItem in chaseItems )
		{
			eventItems.append( chaseItem )
		}
		chaseItems.clear()
	}
	return eventItems
}
#endif

#if SERVER || CLIENT || UI
array<ItemFlavor> function MilestoneEvent_GetEventItemsInPool( ItemFlavor event, bool isRestricted = false )
{
	array<ItemFlavor> chaseItems
	array<ItemFlavor> eventItems
	if ( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	{
		array<CollectionEventRewardGroup> rewardGroups = MilestoneEvent_GetRewardGroups( event, isRestricted )
		foreach ( CollectionEventRewardGroup rewardGroup in rewardGroups )
		{
			// We want to flip the order of the items so the most important ones come first
			rewardGroup.rewards.reverse()
			foreach ( ItemFlavor reward in rewardGroup.rewards )
			{
				if ( !MilestoneEvent_IsItemInPool( event, reward.grxIndex, isRestricted ) )
					continue

				// We'll put the chase items in a separate list to be added at the end
				if ( MilestoneEvent_IsChaseItem( event, reward.grxIndex, isRestricted ) )
					chaseItems.append( reward )
				else
					eventItems.append( reward )
			}
		}

		foreach ( ItemFlavor chaseItem in chaseItems )
		{
			eventItems.append( chaseItem )
		}
		chaseItems.clear()
	}
	return eventItems
}
#endif

#if SERVER || CLIENT || UI
array<ItemFlavor> function MilestoneEvent_GetMythicEventItems( ItemFlavor event, bool isRestricted = false )
{
	array<ItemFlavor> eventItems
	if ( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	{
		array<CollectionEventRewardGroup> rewardGroups = MilestoneEvent_GetRewardGroups( event, isRestricted )
		foreach ( CollectionEventRewardGroup rewardGroup in rewardGroups )
		{
			if ( rewardGroup.quality == eRarityTier.MYTHIC )
			{
				foreach ( ItemFlavor reward in rewardGroup.rewards )
				{
					eventItems.append( reward )
				}
			}
		}
	}
	return eventItems
}
#endif


#if SERVER || CLIENT || UI
array<CollectionEventRewardGroup> function MilestoneEvent_GetRewardGroups( ItemFlavor event, bool isRestricted = false )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )

	array<CollectionEventRewardGroup> groups = []
	string rewardPath = isRestricted ? "restrictedRewardGroups" : "rewardGroups"
	foreach ( var groupBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), rewardPath ) )
	{
		CollectionEventRewardGroup group
		group.ref = GetSettingsBlockString( groupBlock, "ref" )
		group.quality = eRarityTier[GetSettingsBlockString( groupBlock, "quality" )]
		foreach ( var rewardBlock in IterateSettingsArray( GetSettingsBlockArray( groupBlock, "rewards" ) ) )
			group.rewards.append( GetItemFlavorByAsset( GetSettingsBlockAsset( rewardBlock, "flavor" ) ) )

		groups.append( group )
	}
	return groups
}
#endif

#if SERVER || CLIENT || UI
bool function MilestoneEvent_IsItemEventItem( ItemFlavor event, int itemIdx )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	array<ItemFlavor> eventItems = MilestoneEvent_GetMythicEventItems( event )
	eventItems.extend( MilestoneEvent_GetEventItems( event, GRX_IsOfferRestricted() ) )
	foreach( ItemFlavor item in eventItems )
	{
		if ( item.grxIndex == itemIdx )
			return true
	}
	return false
}
#endif // SERVER || CLIENT || UI

#if UI
asset function MilestoneEvent_GetCustomIconForItemIdx( ItemFlavor event, int grxIdx, bool isRestricted = false )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )

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
				return GetSettingsBlockAsset( rewardBlock, "milestoneItemCustomImage" )
			}
		}
	}
	Assert( false )
	unreachable
}
#endif

#if UI
bool function MilestoneEvent_IsItemFlavorFromEvent( ItemFlavor event, int grxIdx )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	array<ItemFlavor> eventItems = MilestoneEvent_GetEventItems( event )
	foreach( ItemFlavor item in eventItems )
	{
		if ( item.grxIndex == grxIdx )
			return true
	}
	return false
}
#endif

#if UI
bool function MilestoneEvent_IsMythicEventItem( ItemFlavor event, int itemIdx )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	array<ItemFlavor> eventItems = MilestoneEvent_GetMythicEventItems( event )
	foreach( ItemFlavor item in eventItems )
	{
		if ( item.grxIndex == itemIdx )
			return true
	}
	return false
}
#endif

#if UI
bool function MilestoneEvent_EventAwardsArtifact( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	array<ItemFlavor> eventItems = MilestoneEvent_GetMythicEventItems( event )
	foreach( ItemFlavor item in eventItems )
	{
		if ( Artifacts_IsItemFlavorArtifact( item ) )
			return true
	}
	return false
}
#endif

#if UI
bool function MilestoneEvent_IsMilestoneGrantReward( ItemFlavor event, int itemIdx )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	array<MilestoneEventGrantReward> rewards = MilestoneEvent_GetMilestoneGrantRewards( event, GRX_IsOfferRestricted() )
	foreach( MilestoneEventGrantReward reward in rewards )
	{
		if ( ItemFlavor_GetGRXIndex( reward.rewardFlav ) == itemIdx )
			return true
	}
	return false
}
#endif

#if UI
array<GRXScriptOffer> ornull function MilestoneEvent_GetPackOffers( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	if ( GRX_IsOfferRestricted() )
		return null

	ItemFlavor packFlav          = MilestoneEvent_GetMainPackFlav( event )
	string offerLocation         = MilestoneEvent_GetFrontPageGRXOfferLocation( event, GRX_IsOfferRestricted() )
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
int function MilestoneEvent_GetCurrentMaxEventPackPurchaseCount( ItemFlavor event, entity player )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	//Note: There is a change this needs to be changed since on the 4 buy purchase we guarantee a Legendary or Iconic.
	//Not sure if that will mean that we have 2 pack flavor types but it points to that.
	#if SERVER
		if ( GRX_IsOfferRestricted( player ) )
			return 0
	#elseif UI
		if ( MilestoneEvent_GetPackOffers( event ) == null )
			return 0
	#endif


	ItemFlavor packFlav = MilestoneEvent_GetMainPackFlav( event )
	#if SERVER
		int ownedPackCount = GRX_GetPackCount( player, ItemFlavor_GetGRXIndex( packFlav ) )
	#elseif UI
		int ownedPackCount = GRX_GetPackCount( ItemFlavor_GetGRXIndex( packFlav ) )
	#endif

	return HeirloomEvent_GetCurrentRemainingItemCount( event, player ) - ownedPackCount
}
#endif

#if UI
bool function MilestoneEvent_IsPlaylistVarEnabled()
{
	return GetCurrentPlaylistVarBool( "enable_milestone_event", true )
}
#endif

#if UI
bool function MilestoneEvent_UseOriginalEventTabLayout()
{
	// R5DEV-587151 - Rarely, something hiccups causing the Playlist check to fail because we aren't connected to a server
	// We have playlists in the lobby, so this should in theory, always work, but to be safe, we'll just return out with the default if not connected
	if ( !IsFullyConnected() )
		return false

	return GetCurrentPlaylistVarBool( "use_original_event_tab_layout", false )
}
#endif

#if UI
void function ServerCallback_MilestoneEvent_MilestoneRewardCeremonyIsDue( int rewardCount )
{
	fileLevel.milestoneEvents_MilestoneRewardCount = rewardCount
}
#endif // UI

#if UI
void function MilestoneEvent_TryDisplayMilestoneRewardCeremony()
{
	if ( MilestoneEvent_IsMilestoneRewardCeremonyDue() )
	{
		MilestoneEvent_MoveToLobbyForMilestoneRewardCeremony()
	}
}
#endif // UI

#if UI
void function MilestoneEvent_DecrementMilestoneRewardCeremonyCount()
{
	if ( fileLevel.milestoneEvents_MilestoneRewardCount > 0 )
		fileLevel.milestoneEvents_MilestoneRewardCount--
}
#endif

#if UI
bool function MilestoneEvent_IsMilestoneRewardCeremonyDue()
{
	return fileLevel.milestoneEvents_MilestoneRewardCount > 0
}
#endif // UI

#if UI
void function MilestoneEvent_MoveToLobbyForMilestoneRewardCeremony()
{
	TabData lobbyTabData = GetTabDataForPanel( GetMenu( "LobbyMenu" ) )

	ActivateTabPrev( lobbyTabData )
}
#endif // UI

#if UI
void function MilestoneEvent_TryMoveToMilestonePostRewardCeremony( array<BattlePassReward> awards )
{
	if ( !IsConnected() )
		return

	ItemFlavor ornull milestoneEvent = GetActiveMilestoneEvent( GetUnixTimestamp() )
	if ( milestoneEvent != null )
	{
		expect ItemFlavor( milestoneEvent )

		foreach ( BattlePassReward reward in awards )
		{
			if ( ItemFlavor_GetGRXMode( reward.flav ) == eItemFlavorGRXMode.NONE )
			{
				// Non-GRX rewards won't be milestone event grant rewards, so skip them
				continue
			}

			if ( MilestoneEvent_IsMilestoneGrantReward( milestoneEvent, ItemFlavor_GetGRXIndex( reward.flav ) ) )
			{
				if ( IsMilestoneEventStoreOnly( milestoneEvent ) )
				{
					//string milestoneId = MilestoneEvent_GetEventId( milestoneEvent )
					//JumpToStoreMilestoneEventsMenu( milestoneId )
					return
				}
				else
				{
					EventsPanel_SetOpenPageIndex( eEventsPanelPage.MILESTONES ) //Packs Page
					JumpToEventTab( "RTKEventsPanel" )
					return
				}
			}
		}
	}
}
#endif // UI

#if UI
string function MilestoneEvent_GetEventItemsRatesSectionHeader( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	string defaultHeader = Localize( "#MILESTONE_BUNDLE_EVENT_ITEMS_LABEL" )
	string header = GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventMilestonePackRatesHeader" )
	return Localize( header != "" ? header : defaultHeader )
}
#endif

#if UI
array<RTKPurchasePackRowRatesInfo> function MilestoneEvent_GetEventItemRatesData( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )

	array<RTKPurchasePackRowRatesInfo> rowsData
	foreach ( var rowBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), "eventMilestonePackRatesRows" ) )
	{
		RTKPurchasePackRowRatesInfo row
		foreach ( var rateBlock in IterateSettingsArray( GetSettingsBlockArray( rowBlock, "eventMilestoneQualityRates" ) ) )
		{
			RTKPurchasePackRateInfo rate
			rate.quality = eRarityTier[GetSettingsBlockString( rateBlock, "quality" )]

			string title = Localize( ItemQuality_GetQualityName( rate.quality ) ).toupper()
			string titleOverride = Localize( GetSettingsBlockString( rateBlock, "titleOverride" ) )
			if ( titleOverride != "" )
				title = titleOverride
			rate.title = title

			rate.rate = GetSettingsBlockString( rateBlock, "eventMilestoneItemRate" )
			row.rates.append( rate )
		}
		rowsData.append( row )
	}
	return rowsData
}
#endif

#if UI
array<RTKPurchasePackRowRatesInfo> function MilestoneEvent_GetStandardItemRatesData( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )

	array<RTKPurchasePackRowRatesInfo> rowsData
	foreach ( var rowBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), "standardMilestonePackRatesRows" ) )
	{
		RTKPurchasePackRowRatesInfo row
		foreach ( var rateBlock in IterateSettingsArray( GetSettingsBlockArray( rowBlock, "standardMilestoneQualityRates" ) ) )
		{
			RTKPurchasePackRateInfo rate
			rate.quality = eRarityTier[GetSettingsBlockString( rateBlock, "quality" )]
			rate.title = Localize( ItemQuality_GetQualityName( rate.quality ) ).toupper()
			rate.rate = GetSettingsBlockString( rateBlock, "standardMilestoneItemRate" )
			row.rates.append( rate )
		}
		rowsData.append( row )
	}
	return rowsData
}
#endif

#if UI
array<RTKPurchasePackRowRatesInfo> function MilestoneEvent_GetMultiItemRatesData( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )

	array<RTKPurchasePackRowRatesInfo> rowsData
	foreach ( var rowBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), "multiMilestonePackRatesRows" ) )
	{
		RTKPurchasePackRowRatesInfo row
		foreach ( var rateBlock in IterateSettingsArray( GetSettingsBlockArray( rowBlock, "multiMilestoneQualityRates" ) ) )
		{
			RTKPurchasePackRateInfo rate
			rate.quality = eRarityTier[GetSettingsBlockString( rateBlock, "quality" )]
			rate.rate = GetSettingsBlockString( rateBlock, "multiMilestoneItemRate" )
			rate.title = rate.rate == "" ? GetSettingsBlockString( rateBlock, "multiMilestoneItemInfo" ) : Localize( ItemQuality_GetQualityName( rate.quality ) ).toupper()

			row.rates.append( rate )
		}
		rowsData.append( row )
	}
	return rowsData
}
#endif

#if UI
RTKPurchasePackRowPriceInfo function MilestoneEvent_GetPricePackRangesData( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )

	RTKPurchasePackRowPriceInfo rowData
	string originalPrice = GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "milestonePackOriginalPrice" )
	string craftingPrice = GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "milestonePackCraftingPrice" )


	var assetBlock       = GetSettingsBlockForAsset( ItemFlavor_GetAsset( event ) )
	var arr              = GetSettingsBlockArray( assetBlock, "milestonePackPrices" )
	int arraySize        = GetSettingsArraySize( arr )
	float alphaFraction  = arraySize == 1 ? 1.0 : 1.0/(arraySize - 1 )

	int i = 0
	foreach ( var priceBlock in IterateSettingsArray( arr ) )
	{
		RTKPurchasePackPriceInfo price
		price.title = GetSettingsBlockString( priceBlock, "milestonePackTitleRange" )
		price.discount = GetSettingsBlockString( priceBlock, "milestonePackDiscount" )
		price.price = GetSettingsBlockString( priceBlock, "milestonePackPrice" )
		price.originalPrice = originalPrice
		price.craftingPrice = craftingPrice
		price.discountBGAlpha = 1 - (alphaFraction * i)
		rowData.prices.append( price )
		i++
	}
	return rowData
}
#endif

#if UI
array<RTKPurchasePackInformationLines> function MilestoneEvent_GetLegalTextData( ItemFlavor event )
{
	const int NUMBER_OF_SIDES = 2 //Only two sides
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )

	array<RTKPurchasePackInformationLines> linesData
	for ( int i = 1; i <= NUMBER_OF_SIDES; i++ )
	{
		RTKPurchasePackInformationLines lineSide
		bool isRight = i == NUMBER_OF_SIDES
		foreach ( var linesBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), isRight ? "milestonePackRightInfoText" : "milestonePackLeftInfoText" ) )
		{
			lineSide.text.append( GetSettingsBlockString( linesBlock, "milestonePackLegalText" ) )
		}
		linesData.append( lineSide )
	}
	return linesData
}
#endif
#if UI
string function MilestoneEvent_GetGuaranteedPackText( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "milestoneGuaranteedPackText" )
}
#endif

#if UI
string function MilestoneEvent_GetTitleHeaderText( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "titleHeaderText" )
}
#endif

#if UI
string function MilestoneEvent_GetTitleSubheaderText( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "titleSubheaderText" )
}
#endif

#if UI
asset function MilestoneEvent_GetTitleMainIcon( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "titleMainIcon" )
}
#endif

#if UI
bool function MilestoneEvent_GetTitleUseBackgroundBlur( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsBool( ItemFlavor_GetAsset( event ), "titleUseBgBlur" )
}
#endif

#if UI
asset function MilestoneEvent_GetTitleBlurImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "titleBlurImage" )
}
#endif

#if UI
float function MilestoneEvent_GetTitleBackgroundDarkening( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsFloat( ItemFlavor_GetAsset( event ), "titleBgDarkening" )
}
#endif

#if UI
asset function MilestoneEvent_GetTitleBackgroundImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "titleBgImage" )
}
#endif

#if UI
vector function MilestoneEvent_GetTitleHeaderColor( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "titleHeaderColor" )
}
#endif

#if UI
vector function MilestoneEvent_GetTitleSubheaderColor( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "titleSubheaderColor" )
}
#endif

#if UI
RTKPackProbabilitiesStrings function MilestoneEvent_GetPackProbabilitiesStrings( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_milestone )
	RTKPackProbabilitiesStrings packProbabilitiesStrings
	packProbabilitiesStrings.eventItemRatesHeader = GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventItemRatesHeader" )
	packProbabilitiesStrings.eventItemRatesLine1 = GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventItemRatesLine1" )
	packProbabilitiesStrings.eventItemRatesLine2 = GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventItemRatesLine2" )
	packProbabilitiesStrings.eventItemRatesLine3 = GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventItemRatesLine3" )
	packProbabilitiesStrings.standardItemRatesHeader = GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "standardItemRatesHeader" )
	packProbabilitiesStrings.standardItemRatesLine1 = GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "standardItemRatesLine1" )
	return packProbabilitiesStrings
}
#endif

// Internals Server Only
#if SERVER
void function QueueServersideScriptGRXOperations( entity player )
{
	array<ItemFlavor> activeEvents = GetAllActiveMilestoneEvents( GetUnixTimestamp() )
	if ( activeEvents.len() > 0 )
	{
		foreach ( activeEvent in activeEvents )
		{
			array<ItemFlavor> items = MilestoneEvent_GetEventItemsInPool( activeEvent, GRX_IsOfferRestricted( player ) )
			items.extend( MilestoneEvent_GetMythicEventItems( activeEvent, GRX_IsOfferRestricted( player ) ) )
			// Auto-granting of milestone rewards
			int totalItems                                  = items.len()
			int collectionProgress 							= GRX_GetNumberOfOwnedItemsByPlayer( items, player )
			if ( totalItems > 0 )
			{
				AutoMilestoneGrant( player, collectionProgress, activeEvent )
			}
		}
	}
}
#endif

#if SERVER
void function AutoMilestoneGrant( entity player, int collectionProgress, ItemFlavor activeEvent )
{
	Assert( ItemFlavor_GetType( activeEvent ) == eItemType.calevent_milestone )

	array<MilestoneEventGrantReward> milestoneRewards = MilestoneEvent_GetMilestoneGrantRewards( activeEvent, GRX_IsOfferRestricted( player ) )
	for ( int i = 0; i < milestoneRewards.len(); i++ )
	{
		MilestoneEventGrantReward reward = milestoneRewards[i]
		if ( GRX_IsInventoryReady( player ) && !GRX_IsItemOwnedByPlayer( reward.rewardFlav, player ) ) //allowAlreadyOwned should take care of this check but just for sanity.
		{
			if ( collectionProgress >= reward.grantingLevel )
			{
				GrantRewardsConfig grc
				ItemFlavor flav = reward.rewardFlav
				grc.what = MakeItemFlavorBag( { [flav] = 1, } )
				grc.allowAlreadyOwned = false
				grc.showCeremony = true
				int result = GRX_GrantRewards( player, grc )
				#if DEVELOPER
					printf("\n %s should have been granted", ItemFlavor_GetHumanReadableRefForPIN_Slow(flav))
				#endif
				Assert( result == eGrantRewardsResult.DONE )

				Remote_CallFunction_UI( player, "ServerCallback_MilestoneEvent_MilestoneRewardCeremonyIsDue", milestoneRewards.len() )
			}
		}
	}
}
#endif

#if SERVER
void function AutoChaseItemPackGrant( entity player, int collectionProgress, int totalItems, ItemFlavor activeEvent )
{
	Assert( ItemFlavor_GetType( activeEvent ) == eItemType.calevent_milestone )

	if ( !(player in fileLevel.chasePackGrantQueued) )
	{
		if ( collectionProgress >= totalItems && totalItems > 0 )
		{
			string seqName = HeirloomEvent_GetCompletionSequenceName( activeEvent )
			int seqIdx     = GRX_GetSequenceNumber( player, seqName )
			#if DEVELOPER
				Assert( seqIdx != GRX_INVALID_SEQUENCE_NUMBER, seqName + " is not a valid reward sequence" )
			#endif

			if ( seqIdx < 1 && seqIdx != GRX_INVALID_SEQUENCE_NUMBER )
			{
				if ( GetCurrentPlaylistVarBool( "grx_collection_event_pin_reporting", false ) )
				{
					table scriptStateInfos = GRX_GetScriptStateInfoForPIN( player )
					table pinData = GetEventPINData( activeEvent, player )
					pinData[ "script_state_info" ] <- scriptStateInfos
					PIN_GRXPlayerGotCollectionHeirloom( player, pinData )
				}

				fileLevel.chasePackGrantQueued[ player ] <- IN_SET

				ItemFlavor heirloomPackFlav = HeirloomEvent_GetCompletionRewardPack( activeEvent )

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
void function MilestoneEvent_OnPlayerDisconnected( entity player )
{
	if ( IsLobby() )
	{
		if ( player in fileLevel.chasePackGrantQueued )
			delete fileLevel.chasePackGrantQueued[ player ]
	}
}
#endif