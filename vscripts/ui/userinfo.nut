global function UserInfoPanels_LevelInit
//global function UpdateUserInfoWithXP

// Custom number formatting functions
string function FormatAndLocalizeNumber( string formatStr, float number, bool shouldShorten )
{
	if ( number == 0.0 )
		return "0"

	string lang = GetLanguage()
	string thousandsSeparator = lang == "english" || lang == "korean" || lang == "schinese" || lang == "tchinese" || lang == "thai" || lang == "japanese" ? "," : "."
	string decimalSeparator = thousandsSeparator == "," ? "." : ","

	float integral = floor( number )
	float decimal = number - integral
	string integralString = ""
	integralString = format( "%0.0f", integral )
	string decimalString = ""

	if ( decimal > 0 )
		decimalString = format( "%s%02f", decimalSeparator, decimal ).slice( 0, 3 )

	if ( shouldShorten )
	{
		int digits = int( floor( log10( integral + 1.0 ) ) )
		if ( digits > 6 )
		{
			float displayValue = number / 1000000.0
			return format( "%.1fM", displayValue )
		}
		else if ( digits > 3 )
		{
			float displayValue = number / 1000.0
			return format( "%.1fK", displayValue )
		}
	}

	if ( integralString.len() > 3 )
	{
		string separatedString = ""
		int count = 0
		for ( int i = integralString.len() - 1; i >= 0; i-- )
		{
			if ( count == 3 )
			{
				separatedString = thousandsSeparator + separatedString
				count = 0
			}
			separatedString = integralString.slice( i, i + 1 ) + separatedString
			count++
		}
		integralString = separatedString
	}

	return integralString + decimalString
}

string function LocalizeAndShortenNumber_Int( int number )
{
	if ( number == 0 )
		return "0"

	return FormatAndLocalizeNumber( "1", float( number ), true )
}

struct SingleCurrencyBalanceElement
{
	var         element
	ItemFlavor& currency
}

struct FileStruct_LifetimeLevel
{
	table<var, bool>                    activeUserInfoPanelSet
	array<SingleCurrencyBalanceElement> singleCurrencyBalanceElementList
}
FileStruct_LifetimeLevel& fileLevel

void function UserInfoPanels_LevelInit()
{
	FileStruct_LifetimeLevel newFileLevel
	fileLevel = newFileLevel

//	SetupUserInfoPanelToolTips()
	AddCallbackOrMaybeCallNow_OnAllItemFlavorsRegistered( SetupUserInfoPanels )
}

//void function UserInfoPanels_LevelShutdown()
//{
//	//
//}


void function SetupUserInfoPanelToolTips( int currency1 = 0, int currency2 = 0, int currency3 = 0 )
{
	ToolTipData ttd
	ttd.tooltipStyle = eTooltipStyle.CURRENCY
	ttd.actionHint1 = FormatAndLocalizeNumber( "1", float( currency1 ), true )
	ttd.actionHint2 = FormatAndLocalizeNumber( "1", float( currency2 ), true )
	ttd.actionHint3 = FormatAndLocalizeNumber( "1", float( currency3 ), true )

	int nextExpirationAmount = 1//GRX_GetNextCurrencyExpirationAmt()
	if( nextExpirationAmount > 0 )
		ttd.descText = Localize( "#CURRENCIES_TOOLTIP_EXPIRATION", nextExpirationAmount, ( GetUnixTimestamp() - GetUnixTimestamp() ) / SECONDS_PER_DAY )
	else
		ttd.descText = ""

	foreach ( var menu in uiGlobal.allMenus )
	{
		array<var> userInfoElemList = GetElementsByClassname( menu, "UserInfo" )

		foreach ( var elem in userInfoElemList )
			Hud_SetToolTipData( elem, ttd )
	}
}


void function SetupUserInfoPanels()
{
	foreach ( var menu in uiGlobal.allMenus )
	{
		array<var> userInfoElemList = GetElementsByClassname( menu, "UserInfo" )

		if ( userInfoElemList.len() > 0 )
		{
			foreach ( var elem in userInfoElemList )
			{
				var rui = Hud_GetRui( elem )
				RuiSetImage( rui, "symbol1", ItemFlavor_GetIcon( GRX_CURRENCIES[GRX_CURRENCY_PREMIUM] ) )
				RuiSetImage( rui, "symbol2", ItemFlavor_GetIcon( GRX_CURRENCIES[GRX_CURRENCY_CREDITS] ) )
				RuiSetImage( rui, "symbol3", ItemFlavor_GetIcon( GRX_CURRENCIES[GRX_CURRENCY_CRAFTING] ) )

				fileLevel.activeUserInfoPanelSet[elem] <- true // todo(dw)
			}

			//AddMenuEventHandler( menu, eUIEvent.MENU_OPEN, void function() : ( userInfoElemList ) {
			//	foreach( var elem in userInfoElemList )
			//		fileLevel.activeUserInfoPanelSet[elem] <- true
			//} )
			//
			//AddMenuEventHandler( menu, eUIEvent.MENU_CLOSE, void function() : ( userInfoElemList ) {
			//	foreach( var elem in userInfoElemList )
			//		delete fileLevel.activeUserInfoPanelSet[elem]
			//} )
		}
	}

	table<string, int> singleCurrencyElementTypesTable = {
		["PremiumBalance"] = GRX_CURRENCY_PREMIUM,
		["CreditBalance"] = GRX_CURRENCY_CREDITS,
		["CraftingBalance"] = GRX_CURRENCY_CRAFTING,
	}
	foreach( string classname, int currencyIndex in singleCurrencyElementTypesTable )
	{
		ItemFlavor currency = GRX_CURRENCIES[currencyIndex]
		foreach ( var elem in GetElementsByClassnameForMenus( classname, uiGlobal.allMenus ) )
		{
			var rui = Hud_GetRui( elem )
			RuiSetImage( rui, "symbol", ItemFlavor_GetIcon( currency ) )

			SingleCurrencyBalanceElement scbe
			scbe.element = elem
			scbe.currency = currency
			fileLevel.singleCurrencyBalanceElementList.append( scbe )
		}
	}

	AddCallbackAndCallNow_OnGRXInventoryStateChanged( UpdateActiveUserInfoPanels )
	AddCallbackAndCallNow_OnGRXOffersRefreshed( UpdateActiveUserInfoPanels )
}


void function UpdateActiveUserInfoPanels()
{
	bool isReady = GRX_IsInventoryReady() && GRX_AreOffersReady()
	int premiumBalance, creditsBalance, craftingBalance
	if ( isReady )
	{
		premiumBalance = GRXCurrency_GetPlayerBalance( GetLocalClientPlayer(), GRX_CURRENCIES[GRX_CURRENCY_PREMIUM] )
		creditsBalance = GRXCurrency_GetPlayerBalance( GetLocalClientPlayer(), GRX_CURRENCIES[GRX_CURRENCY_CREDITS] )
		craftingBalance = GRXCurrency_GetPlayerBalance( GetLocalClientPlayer(), GRX_CURRENCIES[GRX_CURRENCY_CRAFTING] )
	}

	foreach( var elem, bool unused in fileLevel.activeUserInfoPanelSet )
	{
		var rui = Hud_GetRui( elem )
		//RuiSetString( rui, "userName", GetPlayerName() )
		RuiSetBool( rui, "isQuerying", !isReady )

		if ( isReady )
		{
			#if DEVELOPER
				RuiSetBool( rui, "hasUnknownItems", GetConVarBool( "grx_hasUnknownItems" ) )
			#endif
			RuiSetString( rui, "count1",  FormatAndLocalizeNumber( "1", float( premiumBalance ), true ) )
			RuiSetString( rui, "count2", LocalizeAndShortenNumber_Int( creditsBalance ) )
			RuiSetString( rui, "count3", LocalizeAndShortenNumber_Int( craftingBalance ) )
		}
	}

	foreach( SingleCurrencyBalanceElement scbe in fileLevel.singleCurrencyBalanceElementList )
	{
		var rui = Hud_GetRui( scbe.element )
		RuiSetBool( rui, "isQuerying", !isReady )

		if ( isReady )
			RuiSetInt( rui, "count", GRXCurrency_GetPlayerBalance( GetLocalClientPlayer(), scbe.currency ) )
	}
}


/*void function UpdateUserInfoWithXP()
{
	EndSignal( uiGlobal.signalDummy, "CleanupInGameMenus" )

	while ( true )
	{
		entity player = GetUIPlayer()
		if ( player )
		{
			int accountXP    = player.GetPersistentVarAsInt( "xp" )
			int accountLevel = GetAccountLevelForXP( accountXP )
			int xpRangeStart = GetXPForAccountLevel( accountLevel )
			int xpRangeEnd   = GetXPForAccountLevel( accountLevel + 1 )
			Assert( accountXP >= xpRangeStart && accountXP < xpRangeEnd )
			float progressFrac = GraphCapped( accountXP, xpRangeStart, xpRangeEnd, 0.0, 1.0 )

			foreach( var elem, bool unused in fileLevel.activeUserInfoPanelSet )
			{
				var rui = Hud_GetRui( elem )
				RuiSetInt( rui, "rank", accountLevel )
				RuiSetFloat( rui, "progressFrac", progressFrac )
			}
		}

		WaitFrameOrUntilLevelLoaded()
	}
}*/
