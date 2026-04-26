#if SERVER || CLIENT || UI
global function EventShop_Init
#endif

#if UI
global function EventShop_IsPlaylistVarEnabled
#endif

#if SERVER || CLIENT || UI
global function EventShop_GetCurrentActiveEventShop
global function EventShop_CurrentActiveEventShopHasDailyChallenges
global function EventShop_GetCurrentActiveEventShopDailyChallenges
global function EventShop_CurrentActiveEventShopHasEventChallenges
global function EventShop_GetCurrentActiveEventShopEventChallenges
global function EventShop_GetShowEventChallengesInLobby
global function EventShop_GetEventShopCurrency
global function EventShop_GetEventShopGRXCurrency
global function EventShop_HasSweepstakesOffers
global function EventShop_GetGRXOfferLocation
global function EventShop_GetGridToolTipBodyText
global function EventShop_GetGridToolTipBodySetsText
global function EventShop_GetGridToolTipBodyInsufficientText
global function EventShop_GetGridToolTipSubtitleDailyLimitText
global function EventShop_GetGridToolTipCounterAvailableText
global function EventShop_GetGridToolTipCounterDailyLimitText
global function EventShop_GetGridToolTipBodySweepstakesText
global function EventShop_GetGridToolTipBody2Text
global function EventShop_GetEventMainIcon
global function EventShop_GetShopPageItemsBackground
global function EventShop_GetSweepstakesPrizeImage
global function EventShop_GetLobbyButtonImage
global function EventShop_GetEventShopData
global function EventShop_GetBadges
global function EventShop_GetRewards
global function EventShop_GetRadioPlays
global function EventShop_GetOffers
global function EventShop_GetOfferData
global function EventShop_GetOfferByCoreItem
global function EventShop_GetTutorials
global function EventShop_GetCurrencyProgressionType
global function EventShop_GetMainChallenge
global function EventShop_GetTierRewards
global function EventShop_GetTierBadges
global function EventShop_GetTierRadioPlays
global function EventShop_GetTierUnlockValue
global function EventShop_GetTiersData
global function EventShop_GetGridTitle
global function EventShop_GetRewardsTitle
global function EventShop_GetBarsColor
global function EventShop_GetLinesColor
global function EventShop_GetLeftPanelTitleColor
global function EventShop_GetLeftPanelEventNameColor
global function EventShop_GetLeftPanelTimeRemainingColor
global function EventShop_GeTooltipsColor
global function EventShop_GetRightPanelOpacity
global function EventShop_GetLeftPanelOpacity
global function EventShop_GetCurrencyRewardSequence
global function EventShop_GetTotalCurrencyPersistenceVar
global function EventShop_GetTotalCurrencyStat
global function EventShop_IsEventShopActive
global function EventShop_GetCurrentEventCurrencyLifetimeTotal
#endif

#if SERVER
global function EventShop_GetCurrentMaxEventCurrencyInOneGrant
#endif // SERVER

#if UI
global function EventShop_GetWeeklyResetsTimestamps
global function EventShop_GetCoreItemFlav
global function EventShop_GetItemPrice
global function EventShop_GetCoreItemQuantity
global function EventShop_GetChallengeHeaderImage
global function EventShop_HasMilestoneEventPack
#endif

//////////////////////
//////////////////////
//// Global Types ////
//////////////////////
//////////////////////

#if SERVER || CLIENT || UI
global struct EventShopBadgeData
{
	ItemFlavor& badge
	int         size = 118
}

global struct EventShopRewardData
{
	ItemFlavor& reward
}

global struct EventShopRadioPlayData
{
	ItemFlavor& radioPlay
}

global struct EventShopTutorialData
{
	asset icon
	string title
	string desc
}

global struct EventShopOfferData
{
	ItemFlavor& offer
	bool isSweepstakesOffer
	bool isLockedOffer
	bool isFeaturedOffer
	asset gridIcon
}

global struct EventShopTierData
{
	array<ItemFlavor> rewards
	array<ItemFlavor> badges
	array<ItemFlavor> radioPlays
	int unlockValue
}

global struct EventShopData
{
	ItemFlavor ornull mainChallengeFlav
	array<EventShopBadgeData> badges
	array<EventShopRewardData> rewards
	array<EventShopRadioPlayData> radioPlays
	array<EventShopTutorialData> tutorials
	array<EventShopOfferData> offers
	array<ItemFlavor> dailyChallenges
	array<ItemFlavor> eventChallenges
	ItemFlavor ornull eventCurrency
	string eventShopButtonText
}
#endif


///////////////////////
///////////////////////
//// Private Types ////
///////////////////////
///////////////////////

#if SERVER || CLIENT || UI
struct FileStruct_LifetimeLevel
{
	table<ItemFlavor, EventShopData> eventShopDataMap

	int eventShopStaleTimestamp
	ItemFlavor ornull activeEventShop

	int currentMaxEventCurrencyInOneGrant
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
//// Initialization /////
/////////////////////////
/////////////////////////

#if SERVER || CLIENT || UI
void function EventShop_Init()
{
	#if UI
		FileStruct_LifetimeLevel newFileLevel
		fileLevel = newFileLevel
	#endif

	AddCallback_OnItemFlavorRegistered( eItemType.calevent_event_shop, void function( ItemFlavor event ) {
		EventShopData eventShopData
		bool expired = false

		#if CLIENT || UI
			Assert( IsConnected(), "We're not connected to a server. This will result in excess challenges being loaded. This won't break anything, but it also shouldn't happen." )
			if ( IsConnected() )
		#endif // SERVER always has access to clock time; scoping brackets for readability here...
			{
				expired = CalEvent_GetFinishUnixTime( event ) < GetUnixTimestamp()
			}

		foreach ( int index, var badgeBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), "badgeFlavs" ) )
		{
			ItemFlavor ornull badgeFlav = RegisterItemFlavorFromSettingsAsset( GetSettingsBlockAsset( badgeBlock, "badgeFlav" ) )

			if ( badgeFlav != null )
			{
				expect ItemFlavor( badgeFlav )

				EventShopBadgeData badge
				badge.badge = badgeFlav
				badge.size  = GetSettingsBlockInt( badgeBlock, "badgeSize" )

				eventShopData.badges.append( badge )
			}
		}

		foreach ( int index, var rewardBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), "rewardFlavs" ) )
		{
			ItemFlavor ornull rewardFlav = RegisterItemFlavorFromSettingsAsset( GetSettingsBlockAsset( rewardBlock, "rewardFlav" ) )

			if ( rewardFlav != null )
			{
				expect ItemFlavor( rewardFlav )

				EventShopRewardData reward
				reward.reward = rewardFlav

				eventShopData.rewards.append( reward )
			}
		}

		foreach ( int index, var radioPlayBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), "radioPlayFlavs" ) )
		{
			ItemFlavor ornull radioPlayFlav = RegisterItemFlavorFromSettingsAsset( GetSettingsBlockAsset( radioPlayBlock, "radioPlayFlav" ) )

			if ( radioPlayFlav != null )
			{
				expect ItemFlavor( radioPlayFlav )

				EventShopRadioPlayData radioPlay
				radioPlay.radioPlay = radioPlayFlav

				eventShopData.radioPlays.append( radioPlay )
			}
		}

		foreach ( int index, var offerBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), "offerFlavs" ) )
		{
			ItemFlavor ornull offerFlav = RegisterItemFlavorFromSettingsAsset( GetSettingsBlockAsset( offerBlock, "offerFlav" ) )

			if ( offerFlav != null )
			{
				expect ItemFlavor( offerFlav )

				EventShopOfferData offer
				offer.offer = offerFlav
				offer.isLockedOffer = GetSettingsBlockBool( offerBlock, "isLockedOffer" )
				offer.isSweepstakesOffer = GetSettingsBlockBool( offerBlock, "isSweepstakesOffer" )
				offer.isFeaturedOffer = GetSettingsBlockBool( offerBlock, "isFeaturedOffer" )
				offer.gridIcon = GetSettingsBlockAsset( offerBlock, "offerGridIcon" )
				eventShopData.offers.append( offer )
			}
		}

		asset eventCurrencyAsset = GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "eventShopCurrencyFlav" )
		if ( eventCurrencyAsset != $"" )
		{
			eventShopData.eventCurrency = expect ItemFlavor( RegisterItemFlavorFromSettingsAsset( eventCurrencyAsset ) )
		}

		if ( expired )
		{
			printt( "EventShop_Init: skipping registration of nonessential subassets for expired event ", ItemFlavor_GetGUIDString( event ) )
			return // EventShops Events don't require any of the following sub-assets once they expire.
		}

		foreach ( int index, var tutorialBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), "tutorialItems" ) )
		{
			EventShopTutorialData tutorial
			tutorial.icon = GetSettingsBlockAsset( tutorialBlock, "tutorialIcon" )
			tutorial.title = GetSettingsBlockString( tutorialBlock, "tutorialTitleLocString" )
			tutorial.desc = GetSettingsBlockString( tutorialBlock, "tutorialBodyTextLocString" )

			eventShopData.tutorials.append( tutorial )
		}

		eventShopData.mainChallengeFlav = RegisterItemFlavorFromSettingsAsset( GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "mainChallengeFlav" ) )
		if ( eventShopData.mainChallengeFlav != null )
			RegisterChallengeSource( expect ItemFlavor( eventShopData.mainChallengeFlav ), event, 0 )
		else
			Warning( "Event Shop '%s' refers to bad challenge asset: %s", string(ItemFlavor_GetAsset( event )), string( GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "mainChallengeFlav" ) ) )

		foreach ( int index, var challengeBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), "dailyChallengeFlavs" ) )
		{
			ItemFlavor ornull challengeFlav = RegisterItemFlavorFromSettingsAsset( GetSettingsBlockAsset( challengeBlock, "dailyChallengeFlav" ) )
			Assert( challengeFlav != null, "Bad daily challenge in event shop: " + string(ItemFlavor_GetAsset( event )) )
			if ( challengeFlav != null )
			{
				Assert( Challenge_GetTimeSpanKind( expect ItemFlavor( challengeFlav ) ) == eChallengeTimeSpanKind.EVENTSHOP_DAILY_CHALLENGE, "Event shop daily challenges must be configured with timespan EVENTSHOP_DAILY_CHALLENGE." )

				eventShopData.dailyChallenges.append( expect ItemFlavor( challengeFlav ) )
				RegisterChallengeSource( expect ItemFlavor( challengeFlav ), event, 0 )
			}
		}

		foreach ( int index, var challengeBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), "eventChallengeFlavs" ) )
		{
			ItemFlavor ornull challengeFlav = RegisterItemFlavorFromSettingsAsset( GetSettingsBlockAsset( challengeBlock, "eventChallengeFlav" ) )
			Assert( challengeFlav != null, "Bad event challenge in event shop: " + string(ItemFlavor_GetAsset( event )) )
			if ( challengeFlav != null )
			{
				Assert( Challenge_GetTimeSpanKind( expect ItemFlavor( challengeFlav ) ) == eChallengeTimeSpanKind.EVENTSHOP_EVENT_CHALLENGE, "Event shop event challenges must be configured with timespan EVENTSHOP_EVENT_CHALLENGE." )

				eventShopData.eventChallenges.append( expect ItemFlavor( challengeFlav ) )
				RegisterChallengeSource( expect ItemFlavor( challengeFlav ), event, 0 )
			}
		}

		eventShopData.eventShopButtonText = GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventShopButtonText" )

		fileLevel.eventShopDataMap[event] <- eventShopData
	} )

	#if SERVER
		AddCallback_QueueServersideScriptGRXOperations( TryGrantCurrentEventCurrencyToPlayer )
		AddCallback_OnClientDisconnected( OnPlayerDisconnected )
	#endif // SERVER
}
#endif

#if SERVER
table< entity, bool > tbl_eventCurrencyGrants = {}

void function OnPlayerDisconnected( entity player )
{
	if ( player in tbl_eventCurrencyGrants )
	{
		delete tbl_eventCurrencyGrants[ player ]
	}
}

void function TryGrantCurrentEventCurrencyToPlayer( entity player )
{
	thread ServerThread_TryGrantCurrentEventCurrencyToPlayer( player )
}

void function ServerThread_TryGrantCurrentEventCurrencyToPlayer( entity player )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "OnDisconnecting" )

	if ( player in tbl_eventCurrencyGrants && tbl_eventCurrencyGrants[ player ] )
	{
		return
	}

	OnThreadEnd(
		function() : ( player )
		{
			tbl_eventCurrencyGrants[ player ] <- false
		}
	)

	ItemFlavor ornull activeEventShop = EventShop_GetCurrentActiveEventShop()
	if ( activeEventShop == null )
	{
		return
	}
	expect ItemFlavor( activeEventShop )

	tbl_eventCurrencyGrants[ player ] <- true

	while ( !GRX_IsInventoryReady( player ) )
	{
		WaitFrame()
	}

	string currencyRewardSeq = EventShop_GetCurrencyRewardSequence( activeEventShop )

	int targetCurrency = player.GetPersistentVarAsInt( EventShop_GetTotalCurrencyPersistenceVar( activeEventShop ) )
	if ( targetCurrency <= 0 )
	{
		return
	}

	int currentCurrency = GRX_GetSequenceNumber( player, currencyRewardSeq )
	if ( currentCurrency >= targetCurrency )
	{
		return
	}

	int grantAmount = targetCurrency - currentCurrency
	Assert( grantAmount <= EventShop_GetCurrentMaxEventCurrencyInOneGrant(), "Beyond limit of expected single-time currency grant: " + string( grantAmount ) )

	ItemFlavor eventCurrencyFlav = EventShop_GetEventShopCurrency( activeEventShop )
	ItemFlavorBag rewards = MakeItemFlavorBag( { [ eventCurrencyFlav ] = grantAmount } )

	ScriptGRXOperationInfo op
	op.expectedQueryGoal = GRX_HTTPQUERYGOAL_GIVE_EVENT_SEQUENCE_REWARD
	op.doOperationFunc = ( void function ( int opID ) : ( player, currencyRewardSeq, currentCurrency, targetCurrency, rewards ) {
		GRX_GiveSequenceRewardEasy(
			player,
			opID,
			GRX_HTTPQUERYGOAL_GIVE_EVENT_SEQUENCE_REWARD,
			currencyRewardSeq,
			currentCurrency,
			targetCurrency,
			rewards
		)
	} )
	op.onDoneCallback = ( void function ( int opID ) : ( player, grantAmount, activeEventShop ) {
		StatHook_UpdateCurrentEventCurrencyStat( player, grantAmount, activeEventShop )
	} )

	QueueGRXOperation( player, op )
	while ( !IsGRXOperationDone( op ) )
	{
		WaitFrame()
	}

	if ( op.status != eScriptGRXOperationStatus.DONE_SUCCESS )
	{
		Warning( "Failed to grant event currency rewards from challenge completion!" )
	}
}
#endif

//////////////////////////
//////////////////////////
//// Global functions ////
//////////////////////////
//////////////////////////

#if UI
bool function EventShop_IsPlaylistVarEnabled()
{
	return GetCurrentPlaylistVarBool( "enable_event_shop", true )
}
#endif

#if SERVER || CLIENT || UI
ItemFlavor ornull function EventShop_GetCurrentActiveEventShop()
{
	Assert( IsItemFlavorRegistrationFinished() )

	int now = GetUnixTimestamp()
	if ( now > fileLevel.eventShopStaleTimestamp )
	{
		RefreshActiveEventShopIfRequired( now )
	}

	return fileLevel.activeEventShop
}
#endif

#if SERVER || CLIENT || UI
bool function EventShop_CurrentActiveEventShopHasDailyChallenges()
{
	Assert( IsItemFlavorRegistrationFinished() )
	ItemFlavor ornull currentShop = EventShop_GetCurrentActiveEventShop()
	return currentShop != null && fileLevel.eventShopDataMap[ expect ItemFlavor( currentShop ) ].dailyChallenges.len() > 0
}
#endif

#if SERVER || CLIENT || UI
array< ItemFlavor > function EventShop_GetCurrentActiveEventShopDailyChallenges()
{
	Assert( IsItemFlavorRegistrationFinished() )

	ItemFlavor ornull currentEventShop = EventShop_GetCurrentActiveEventShop()
	array< ItemFlavor > challenges     = []
	if ( currentEventShop != null )
	{
		challenges.extend( fileLevel.eventShopDataMap[ expect ItemFlavor( currentEventShop ) ].dailyChallenges )
	}

	return challenges
}
#endif

#if SERVER || CLIENT || UI
bool function EventShop_CurrentActiveEventShopHasEventChallenges()
{
	Assert( IsItemFlavorRegistrationFinished() )
	ItemFlavor ornull currentShop = EventShop_GetCurrentActiveEventShop()
	return currentShop != null && fileLevel.eventShopDataMap[ expect ItemFlavor( currentShop ) ].eventChallenges.len() > 0
}
#endif

#if SERVER || CLIENT || UI
array< ItemFlavor > function EventShop_GetCurrentActiveEventShopEventChallenges()
{
	Assert( IsItemFlavorRegistrationFinished() )

	ItemFlavor ornull currentEventShop = EventShop_GetCurrentActiveEventShop()
	array< ItemFlavor > challenges     = []
	if ( currentEventShop != null )
	{
		challenges.extend( fileLevel.eventShopDataMap[ expect ItemFlavor( currentEventShop ) ].eventChallenges )
	}

	return challenges
}
#endif

#if SERVER || CLIENT || UI
bool function EventShop_GetShowEventChallengesInLobby( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsBool( ItemFlavor_GetAsset( event ), "showEventChallengesInLobby" )
}
#endif

#if SERVER || CLIENT || UI
ItemFlavor function EventShop_GetEventShopCurrency( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetItemFlavorByAsset( GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "eventShopCurrencyFlav" ) )
}
#endif

#if SERVER || CLIENT || UI
ItemFlavor function EventShop_GetEventShopGRXCurrency()
{
	return GRX_CURRENCIES[GRX_CURRENCY_PREMIUM] // no event currency, fallback to premium
}
#endif

#if UI
bool function EventShop_HasMilestoneEventPack()
{
	ItemFlavor ornull currentEventShop = EventShop_GetCurrentActiveEventShop()

	if (currentEventShop == null)
		return false

	expect ItemFlavor(currentEventShop)

	Assert( ItemFlavor_GetType( currentEventShop ) == eItemType.calevent_event_shop )

	string offerLocation = EventShop_GetGRXOfferLocation( currentEventShop )
	if ( !GRX_IsLocationActive( offerLocation ) )
		return false

	array<GRXScriptOffer> offers = GRX_GetLocationOffers( offerLocation )
	foreach ( GRXScriptOffer eventShopOffer in offers )
	{
		ItemFlavor ornull coreItemFlav = EventShop_GetCoreItemFlav( eventShopOffer )
		if ( coreItemFlav == null )
		{
			continue
		}

		expect ItemFlavor(coreItemFlav)

		if ( IsValid( coreItemFlav )
				&& ItemFlavor_GetType( coreItemFlav ) == eItemType.account_pack
				&& ItemFlavor_GetAccountPackType( coreItemFlav ) == eAccountPackType.SIRNGE
		)
		{
			return true
		}
	}

	return false
}
#endif

#if SERVER || CLIENT || UI
bool function EventShop_HasSweepstakesOffers( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	foreach ( EventShopOfferData offer in fileLevel.eventShopDataMap[event].offers )
	{
		if ( offer.isSweepstakesOffer )
			return true
	}
	return false
}
#endif

#if SERVER || CLIENT || UI
string function EventShop_GetGRXOfferLocation( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventShopGRXOfferLocation" )
}
#endif

#if SERVER || CLIENT || UI
string function EventShop_GetGridToolTipBodyText( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventShopGridToolTipBodyText" )
}
#endif // SERVER || CLIENT || UI

#if SERVER || CLIENT || UI
string function EventShop_GetGridToolTipBodySetsText( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventShopGridToolTipBodySetsText" )
}
#endif // SERVER || CLIENT || UI

#if SERVER || CLIENT || UI
string function EventShop_GetGridToolTipBodyInsufficientText( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventShopGridToolTipBodyInsufficientText" )
}
#endif // SERVER || CLIENT || UI

#if SERVER || CLIENT || UI
string function EventShop_GetGridToolTipSubtitleDailyLimitText( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventShopGridToolTipSubtitleDailyLimitText" )
}
#endif // SERVER || CLIENT || UI

#if SERVER || CLIENT || UI
string function EventShop_GetGridToolTipCounterAvailableText( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventShopGridToolTipCounterAvailableText" )
}
#endif // SERVER || CLIENT || UI

#if SERVER || CLIENT || UI
string function EventShop_GetGridToolTipCounterDailyLimitText( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventShopGridToolTipCounterDailyLimitText" )
}
#endif // SERVER || CLIENT || UI

#if SERVER || CLIENT || UI
string function EventShop_GetGridToolTipBodySweepstakesText( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventShopGridToolTipBodySweepstakesText" )
}
#endif // SERVER || CLIENT || UI

#if SERVER || CLIENT || UI
string function EventShop_GetGridToolTipBody2Text( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventShopGridToolTipBody2Text" )
}
#endif // SERVER || CLIENT || UI

#if SERVER || CLIENT || UI
asset function EventShop_GetEventMainIcon( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "eventMainIcon" )
}
#endif

#if UI
asset function EventShop_GetChallengeHeaderImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "eventShopLobbyHeaderBackgroundImage" )
}
#endif

#if SERVER || CLIENT || UI
asset function EventShop_GetShopPageItemsBackground( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "eventShopPageItemsBg" )
}
#endif

#if SERVER || CLIENT || UI
asset function EventShop_GetLobbyButtonImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "eventShopLobbyButtonImage" )
}
#endif

#if SERVER || CLIENT || UI
asset function EventShop_GetSweepstakesPrizeImage( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsAsset( ItemFlavor_GetAsset( event ), "sweepstakesPrizeImage" )
}
#endif

#if SERVER || CLIENT || UI
EventShopData function EventShop_GetEventShopData( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return fileLevel.eventShopDataMap[event]
}
#endif

#if SERVER || CLIENT || UI
array<EventShopBadgeData> function EventShop_GetBadges( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return fileLevel.eventShopDataMap[event].badges
}
#endif

#if SERVER || CLIENT || UI
array<EventShopRewardData> function EventShop_GetRewards( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return fileLevel.eventShopDataMap[event].rewards
}
#endif

#if SERVER || CLIENT || UI
array<EventShopRadioPlayData> function EventShop_GetRadioPlays( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return fileLevel.eventShopDataMap[event].radioPlays
}
#endif

#if SERVER || CLIENT || UI
array<EventShopOfferData> function EventShop_GetOffers( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return fileLevel.eventShopDataMap[event].offers
}
#endif

#if SERVER || CLIENT || UI
EventShopOfferData ornull function EventShop_GetOfferData( ItemFlavor event, int index )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )

	if ( index >= fileLevel.eventShopDataMap[event].offers.len() )
	{
		return null
	}

	return fileLevel.eventShopDataMap[event].offers[index]
}
#endif

#if SERVER || CLIENT || UI
EventShopOfferData function EventShop_GetOfferByCoreItem( ItemFlavor event, ItemFlavor flavor )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )

	foreach ( EventShopOfferData offer in fileLevel.eventShopDataMap[event].offers )
	{
		if ( offer.offer == flavor )
		{
			return offer
		}
	}

	// Error messaging
	string eventName	= ItemFlavor_GetAssetName( event )
	string flavorName	= ItemFlavor_GetAssetName( flavor )

	if ( !( event in fileLevel.eventShopDataMap ) )
	{
		Assert( false, format( "No event_shop could be found for event '%s'. Ensure an event_shop Bakery Asset exists for the event.", eventName ) )
	}
	else if ( fileLevel.eventShopDataMap[event].offers.len() == 0 )
	{
		Assert( false, format( "No event_shop offers have been created in the event_shop Bakery Asset for event '%s'.", eventName ) )
	}
	else
	{
		Assert( false, format( "No event_shop offer could be found for item '%s' in event '%s'. Make sure the item has an entry in the event_shop's Offers array in Bakery.", flavorName, eventName ) )
	}

	return fileLevel.eventShopDataMap[event].offers[0]
}
#endif

#if SERVER || CLIENT || UI
array<EventShopTutorialData> function EventShop_GetTutorials( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return fileLevel.eventShopDataMap[event].tutorials
}
#endif

#if SERVER || CLIENT || UI
int ornull function EventShop_GetCurrencyProgressionType( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsInt( ItemFlavor_GetAsset( event ), "eventShopCurrencyProgression" )
}
#endif

#if SERVER || CLIENT || UI
ItemFlavor ornull function EventShop_GetMainChallenge( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return fileLevel.eventShopDataMap[event].mainChallengeFlav
}
#endif

#if SERVER || CLIENT || UI
array<ItemFlavor> function EventShop_GetTierRewards( ItemFlavor event, int tier )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )

	var tierBlock = Challenge_GetTierDataBlock( expect ItemFlavor(EventShop_GetMainChallenge( event )), tier )

	array<ItemFlavor> rewards = []
	var rewardsArray          = GetSettingsBlockArray( tierBlock, "rewards" )
	foreach ( var rewardBlock in IterateSettingsArray( rewardsArray ) )
	{
		asset rewardAsset = GetSettingsBlockAsset( rewardBlock, "flavor" )
		if ( IsValidItemFlavorSettingsAsset( rewardAsset ) )
		{
			ItemFlavor item = GetItemFlavorByAsset( rewardAsset )

			if ( ItemFlavor_GetType( item ) != eItemType.gladiator_card_badge && ItemFlavor_GetType( item ) != eItemType.radio_play  )
				rewards.append( item )
		}
	}

	return rewards
}
#endif

#if SERVER || CLIENT || UI
array<ItemFlavor> function EventShop_GetTierBadges( ItemFlavor event, int tier )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )

	var tierBlock = Challenge_GetTierDataBlock( expect ItemFlavor(EventShop_GetMainChallenge( event )), tier )

	array<ItemFlavor> badges = []
	var rewardsArray          = GetSettingsBlockArray( tierBlock, "rewards" )
	foreach ( var rewardBlock in IterateSettingsArray( rewardsArray ) )
	{
		asset rewardAsset = GetSettingsBlockAsset( rewardBlock, "flavor" )
		if ( IsValidItemFlavorSettingsAsset( rewardAsset ) )
		{
			ItemFlavor item = GetItemFlavorByAsset( rewardAsset )

			if ( ItemFlavor_GetType( item ) == eItemType.gladiator_card_badge )
				badges.append( item )
		}
	}

	return badges
}
#endif

#if SERVER || CLIENT || UI
array<ItemFlavor> function EventShop_GetTierRadioPlays( ItemFlavor event, int tier )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )

	var tierBlock = Challenge_GetTierDataBlock( expect ItemFlavor(EventShop_GetMainChallenge( event )), tier )

	array<ItemFlavor> radioPlays = []
	var rewardsArray          = GetSettingsBlockArray( tierBlock, "rewards" )
	foreach ( var rewardBlock in IterateSettingsArray( rewardsArray ) )
	{
		asset rewardAsset = GetSettingsBlockAsset( rewardBlock, "flavor" )
		if ( IsValidItemFlavorSettingsAsset( rewardAsset ) )
		{
			ItemFlavor item = GetItemFlavorByAsset( rewardAsset )

			if ( ItemFlavor_GetType( item ) == eItemType.radio_play )
				radioPlays.append( item )
		}
	}

	return radioPlays
}
#endif

#if SERVER || CLIENT || UI
int function EventShop_GetTierUnlockValue( ItemFlavor event, int tier )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )

	var tierBlock = Challenge_GetTierDataBlock( expect ItemFlavor(EventShop_GetMainChallenge( event )), tier )
	return GetSettingsBlockInt( tierBlock, "goalVal" )
}
#endif

#if SERVER || CLIENT || UI
array<EventShopTierData> function EventShop_GetTiersData( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )

	var settingsBlock = ItemFlavor_GetSettingsBlock( expect ItemFlavor(EventShop_GetMainChallenge( event )) )
	var tiersArray = GetSettingsBlockArray( settingsBlock, "tiers" )

	array<EventShopTierData> tiersData = []
	for ( int i = 0; i < GetSettingsArraySize( tiersArray ); i++ )
	{
		EventShopTierData tierData

		tierData.rewards = EventShop_GetTierRewards( event, i )
		tierData.badges = EventShop_GetTierBadges( event, i )
		tierData.radioPlays = EventShop_GetTierRadioPlays( event, i )
		tierData.unlockValue = EventShop_GetTierUnlockValue( event, i )

		tiersData.push(tierData)
	}

	return tiersData
}
#endif

#if SERVER || CLIENT || UI
string function EventShop_GetGridTitle( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "gridLocString" )
}
#endif

#if SERVER || CLIENT || UI
string function EventShop_GetRewardsTitle( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "rewardsLocString" )
}
#endif

#if SERVER || CLIENT || UI
vector function EventShop_GetBarsColor( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "eventShopBarsColor" )
}
#endif

#if SERVER || CLIENT || UI
vector function EventShop_GetLinesColor( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "eventShopLinesColor" )
}
#endif

#if SERVER || CLIENT || UI
vector function EventShop_GetLeftPanelTitleColor( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "eventShopLeftPanelTitleColor" )
}
#endif

#if SERVER || CLIENT || UI
vector function EventShop_GetLeftPanelEventNameColor( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "eventShopLeftPanelEventNameColor" )
}
#endif

#if SERVER || CLIENT || UI
vector function EventShop_GetLeftPanelTimeRemainingColor( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "eventShopLeftPanelTimeRemainingColor" )
}
#endif

#if SERVER || CLIENT || UI
vector function EventShop_GeTooltipsColor( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsVector( ItemFlavor_GetAsset( event ), "eventShopTooltipsColor" )
}
#endif

#if SERVER || CLIENT || UI
float function EventShop_GetRightPanelOpacity( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsFloat( ItemFlavor_GetAsset( event ), "rightPanelOpacity" )
}
#endif

#if SERVER || CLIENT || UI
float function EventShop_GetLeftPanelOpacity( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsFloat( ItemFlavor_GetAsset( event ), "leftPanelOpacity" )
}
#endif

#if SERVER || CLIENT || UI
string function EventShop_GetCurrencyRewardSequence( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventShopCurrencyRewardSequence" )
}
#endif // SERVER|| CLIENT || UI

#if SERVER || CLIENT || UI
string function EventShop_GetTotalCurrencyPersistenceVar( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventShopTotalCurrencyPersistenceVar" )
}
#endif // SERVER|| CLIENT || UI

#if SERVER || CLIENT || UI
string function EventShop_GetTotalCurrencyStat( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsString( ItemFlavor_GetAsset( event ), "eventShopTotalCurrencyStat" )
}
#endif // SERVER|| CLIENT || UI

#if SERVER || CLIENT || UI
bool function EventShop_IsEventShopActive()
{
	ItemFlavor ornull eventFlav = EventShop_GetCurrentActiveEventShop()
	if ( eventFlav == null )
	{
		return false
	}
	expect ItemFlavor( eventFlav )

	return CalEvent_IsActive( eventFlav, GetUnixTimestamp() )
}
#endif // SERVER|| CLIENT || UI

#if CLIENT || UI || SERVER
int function EventShop_GetCurrentEventCurrencyLifetimeTotal( entity player )
{
	ItemFlavor ornull eventFlav = EventShop_GetCurrentActiveEventShop()
	if ( eventFlav == null )
	{
		return 0
	}
	expect ItemFlavor( eventFlav )
	string statRef = EventShop_GetTotalCurrencyStat( eventFlav )
	StatEntry entry = GetStatEntryByRef( statRef )

	if ( EventShop_IsEventShopActive() )
	{
		return GetStat_Int( player, entry , eStatGetWhen.CURRENT )
	}

	return 0
}
#endif // SERVER|| CLIENT || UI

#if SERVER
// As of 19.1, Event Currency is only granted by Daily Challenges. So we are summing the currency rewards of all Event Daily Challenges to determine the most currency a player can be granted at once.
int function EventShop_GetCurrentMaxEventCurrencyInOneGrant()
{
	Assert( IsItemFlavorRegistrationFinished() )

	int now = GetUnixTimestamp()
	if ( now > fileLevel.eventShopStaleTimestamp )
	{
		RefreshActiveEventShopIfRequired( now )
	}

	return fileLevel.currentMaxEventCurrencyInOneGrant
}
#endif // SERVER

#if SERVER
void function EventShop_CalculateCurrentMaxEventCurrencyInOneGrant()
{
	int maxDailyCurrencyRewards = 0

	ItemFlavor ornull currentEventShop = EventShop_GetCurrentActiveEventShop()
	if ( currentEventShop != null )
	{
		expect ItemFlavor( currentEventShop )
		ItemFlavor currencyVoucher = GetItemFlavorByAsset( GetGlobalSettingsAsset( ItemFlavor_GetAsset( currentEventShop ), "eventShopCurrencyVoucherFlav" ) )

		array< ItemFlavor > dailyChallenges = EventShop_GetCurrentActiveEventShopDailyChallenges()
		foreach ( ItemFlavor challenge in dailyChallenges )
		{
			for ( int tier = 0; tier < Challenge_GetTierCount( challenge ); tier++ )
			{
				ItemFlavorBag rewardsBag = Challenge_GetRewards( challenge, tier )

				foreach ( int bagIndex, ItemFlavor reward in rewardsBag.flavors )
				{
					if ( reward == currencyVoucher )
					{
						maxDailyCurrencyRewards += rewardsBag.quantities[ bagIndex ]
					}
				}
			}
		}
	}

	fileLevel.currentMaxEventCurrencyInOneGrant = maxDailyCurrencyRewards
}
#endif // SERVER

#if UI
ItemFlavor ornull function EventShop_GetCoreItemFlav( GRXScriptOffer offer )
{
	//Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	for ( int offerIndex = 0; offerIndex < offer.items.len(); offerIndex++ )
	{
		if ( offer.offerType != GRX_OFFERTYPE_BUNDLE || offer.items[offerIndex].itemType == GRX_OFFERITEMTYPE_CORE )
		{
			ItemFlavor coreItemFlav = GetItemFlavorByGRXIndex( offer.items[offerIndex].itemIdx )

			if (ItemFlavor_GetGRXMode( coreItemFlav ) == eItemFlavorGRXMode.REGULAR)
				return coreItemFlav
		}
	}

	// gotta add an Assert here
	return GetItemFlavorByGRXIndex( offer.items[0].itemIdx )
}
#endif

#if UI
int function EventShop_GetItemPrice( GRXScriptOffer offer )
{
	foreach ( ItemFlavorBag price in offer.prices )
	{
		Assert( price.flavors.len() == 1, "No price given for ItemFlavor bag in GRX offer." )
		if ( price.flavors[0] == EventShop_GetEventShopGRXCurrency() )
		{
			return price.quantities[0]
		}
	}
	return 0
}
#endif

#if UI
int function EventShop_GetCoreItemQuantity( GRXScriptOffer offer )
{
	for ( int offerIndex = 0; offerIndex < offer.items.len(); offerIndex++ )
	{
		if ( offer.offerType != GRX_OFFERTYPE_BUNDLE || offer.items[offerIndex].itemType == GRX_OFFERITEMTYPE_CORE )
		{
			ItemFlavor coreItemFlav = GetItemFlavorByGRXIndex( offer.items[offerIndex].itemIdx )

			if (ItemFlavor_GetGRXMode( coreItemFlav ) == eItemFlavorGRXMode.REGULAR)
				return offer.items[offerIndex].itemQuantity
		}
	}

	// gotta add an Assert here
	return offer.items[0].itemQuantity
}
#endif

void function RefreshActiveEventShopIfRequired( int timestamp )
{
	#if CLIENT || UI
		if ( !IsConnected() )
		{
			return
		}
	#endif

	if ( timestamp < fileLevel.eventShopStaleTimestamp )
	{
		return
	}

	fileLevel.eventShopStaleTimestamp = 0

	ItemFlavor ornull event = null
	foreach ( ItemFlavor ev in GetAllItemFlavorsOfType( eItemType.calevent_event_shop ) )
	{
		if ( !CalEvent_IsActive( ev, timestamp ) )
		{
			continue
		}

		Assert( event == null, format( "Multiple event shops are active!! (%s, %s)", string(ItemFlavor_GetAsset( expect ItemFlavor(event) )), string(ItemFlavor_GetAsset( ev )) ) )
		event = ev
	}
	fileLevel.activeEventShop = event

	if ( fileLevel.activeEventShop != null )
	{
		ItemFlavor eventShopCurrencyFlav = EventShop_GetEventShopCurrency( expect ItemFlavor( fileLevel.activeEventShop ) )
		fileLevel.eventShopStaleTimestamp = CalEvent_GetFinishUnixTime( expect ItemFlavor( fileLevel.activeEventShop ) )
		GRXCurrency_RegisterNewCurrencyAssetInEventSlot( eventShopCurrencyFlav )
		GRX_SetEventCurrency( ItemFlavor_GetGRXAlias( eventShopCurrencyFlav ) )
		#if SERVER
			EventShop_CalculateCurrentMaxEventCurrencyInOneGrant()
		#endif // SERVER
	}
}

#if UI
bool function EventShop_HasWeeklyResets( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )
	return GetGlobalSettingsBool( ItemFlavor_GetAsset( event ), "isWeeklyRotatingOffers" )
}
#endif
#if UI
array<int> function EventShop_GetWeeklyResetsTimestamps( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_event_shop )

	const int HOUR_IN_SECONDS = 3600
	const int DAY_IN_SECONDS = 24 * HOUR_IN_SECONDS
	const int WEEK_IN_SECONDS = 7 * DAY_IN_SECONDS
	int startTimestamp = CalEvent_GetStartUnixTime( event )
	int endTimestamp  = CalEvent_GetFinishUnixTime( event )
	int currentTimestamp = GetUnixTimestamp()
	array<int> resetTimestamps = []

	if ( !EventShop_HasWeeklyResets( event ) )
	{
		resetTimestamps.append( endTimestamp )
		return resetTimestamps
	}
	
	int weeks = abs( (endTimestamp - startTimestamp) ) / WEEK_IN_SECONDS
	for ( int i = 1; i <= weeks; i++ )
	{
		int nextWeekTimeStamp = startTimestamp + (WEEK_IN_SECONDS * i)
		if ( currentTimestamp < nextWeekTimeStamp )
		{
			resetTimestamps.append( nextWeekTimeStamp )
		}
	}
	return resetTimestamps
}
#endif