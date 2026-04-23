global function InitCharacterSkinsPanel

                                           

struct
{
	var               panel
	var               headerRui
	var               listPanel
	array<ItemFlavor> characterSkinList

	var equipButton
	var blurbPanel
                          
                   
                                

	var mythicPanel
	var mythicSelection
	var mythicLeftButton
	var mythicRightButton
	var mythicTrackingButton
	var mythicEquipButton
	var mythicGridButton

	int activeMythicSkinTier = 0
} file

                         
struct
{
	ItemFlavor&       character
	LoadoutEntry&     loadoutSlot
	var               button
	array<ItemFlavor> selectableMeleeSkins
	int               selectedIndex = -1

	bool  onShowCallbacksRegistered = false
	bool  onFocusCallbacksRegistered = false
	float stickDeflection = 0
	int   lastStickState = eStickState.NEUTRAL

} meleeSkinData
                               

void function InitCharacterSkinsPanel( var panel )
{
	file.panel = panel
	file.listPanel = Hud_GetChild( panel, "CharacterSkinList" )
	file.headerRui = Hud_GetRui( Hud_GetChild( panel, "Header" ) )

	SetPanelTabTitle( panel, "#SKINS" )
	RuiSetString( file.headerRui, "title", Localize( "#OWNED" ).toupper() )

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, CharacterSkinsPanel_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, CharacterSkinsPanel_OnHide )
	AddPanelEventHandler_FocusChanged( panel, CharacterSkinsPanel_OnFocusChanged )

	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )
	AddPanelFooterOption( panel, LEFT, BUTTON_A, false, "#A_BUTTON_SELECT", "", null, CustomizeMenus_IsFocusedItem )
	AddPanelFooterOption( panel, LEFT, BUTTON_X, false, "#X_BUTTON_UNLOCK_LEGEND", "#X_BUTTON_UNLOCK_LEGEND", null, CustomizeMenus_IsFocusedItemParentItemLocked )
	AddPanelFooterOption( panel, LEFT, BUTTON_X, false, "#X_BUTTON_EQUIP", "#X_BUTTON_EQUIP", null, CustomizeMenus_IsFocusedItemEquippable )
	AddPanelFooterOption( panel, LEFT, BUTTON_X, false, "#X_BUTTON_UNLOCK", "#X_BUTTON_UNLOCK", null, CustomizeMenus_IsFocusedItemLocked )
	#if NX_PROG || PC_PROG_NX_UI
		AddPanelFooterOption( panel, LEFT, BUTTON_STICK_LEFT, false, "#MENU_ZOOM_CONTROLS_GAMEPAD", "#MENU_ZOOM_CONTROLS" )
	#else
		AddPanelFooterOption( panel, RIGHT, BUTTON_STICK_LEFT, false, "#MENU_ZOOM_CONTROLS_GAMEPAD", "#MENU_ZOOM_CONTROLS" )
	#endif
	var listPanel = file.listPanel
	void functionref( var ) func = (
		void function( var button ) : ( listPanel )
		{
			SetOrClearFavoriteFromFocus( listPanel )
		}
	)

	#if NX_PROG || PC_PROG_NX_UI
		AddPanelFooterOption( panel, LEFT, BUTTON_Y, false, "#Y_BUTTON_SET_FAVORITE", "#Y_BUTTON_SET_FAVORITE", func, CustomizeMenus_IsFocusedItemFavoriteable )
		AddPanelFooterOption( panel, LEFT, BUTTON_Y, false, "#Y_BUTTON_CLEAR_FAVORITE", "#Y_BUTTON_CLEAR_FAVORITE", func, CustomizeMenus_IsFocusedItemFavorite )
	#else
		AddPanelFooterOption( panel, RIGHT, BUTTON_Y, false, "#Y_BUTTON_SET_FAVORITE", "#Y_BUTTON_SET_FAVORITE", func, CustomizeMenus_IsFocusedItemFavoriteable )
		AddPanelFooterOption( panel, RIGHT, BUTTON_Y, false, "#Y_BUTTON_CLEAR_FAVORITE", "#Y_BUTTON_CLEAR_FAVORITE", func, CustomizeMenus_IsFocusedItemFavorite )
	#endif

                                                         
                                                                                                        
      

	file.mythicEquipButton =  Hud_GetChild( panel, "EquipMythicButton" )
	HudElem_SetRuiArg( file.mythicEquipButton, "centerText", "EQUIP" )
	Hud_AddEventHandler( file.mythicEquipButton, UIE_CLICK, MythicEquipButton_OnActivate )

	file.mythicPanel = Hud_GetChild( panel, "MythicSkinInfo" )
	file.mythicSelection = Hud_GetChild( panel, "MythicSkinSelection" )
	file.mythicTrackingButton = Hud_GetChild( panel, "TrackMythicButton" )
	Hud_AddEventHandler( file.mythicTrackingButton, UIE_CLICK, MythicTrackingButton_OnClick )

	file.mythicLeftButton = Hud_GetChild( panel, "MythicSkinLeftButton" )
	Hud_AddEventHandler( file.mythicLeftButton, UIE_CLICK, LeftMythicSkinButton_OnActivate )
	file.mythicRightButton = Hud_GetChild( panel, "MythicSkinRightButton" )
	Hud_AddEventHandler( file.mythicRightButton, UIE_CLICK, RightMythicSkinButton_OnActivate )

	Hud_SetVisible( file.mythicSelection, false )
	Hud_SetVisible( file.mythicLeftButton, false )
	Hud_SetVisible( file.mythicRightButton, false )
	Hud_SetVisible( file.mythicTrackingButton, false )
	Hud_SetVisible( file.mythicPanel, false )

	file.equipButton = Hud_GetChild( panel, "ActionButton" )
	file.blurbPanel = Hud_GetChild( panel, "SkinBlurb" )

	Hud_SetVisible( file.blurbPanel, false )
}


void function CharacterSkinsPanel_OnShow( var panel )
{
	SetCurrentTabForPIN( Hud_GetHudName( panel ) )
	UI_SetPresentationType( ePresentationType.CHARACTER_SKIN )

	AddCallback_OnTopLevelCustomizeContextChanged( panel, CharacterSkinsPanel_Update )
	RunClientScript( "EnableModelTurn" )
	thread TrackIsOverScrollBar( file.listPanel )
	CharacterSkinsPanel_Update( panel )
              
                                

	UpdateMythicTrackingButton()
	FocusOnMythicSkinIfAnyTierEquiped()
}


void function CharacterSkinsPanel_OnHide( var panel )
{
	RemoveCallback_OnTopLevelCustomizeContextChanged( panel, CharacterSkinsPanel_Update )
	Signal( uiGlobal.signalDummy, "TrackIsOverScrollBar" )
	RunClientScript( "EnableModelTurn" )
	CharacterSkinsPanel_Update( panel )

}


void function CharacterSkinsPanel_Update( var panel )
{
	var scrollPanel = Hud_GetChild( file.listPanel, "ScrollPanel" )

	          
	foreach ( int flavIdx, ItemFlavor unused in file.characterSkinList )
	{
		var button = Hud_GetChild( scrollPanel, "GridButton" + flavIdx )
		CustomizeButton_UnmarkForUpdating( button )
	}
	file.characterSkinList.clear()

	CustomizeMenus_SetActionButton( null )

	RunMenuClientFunction( "ClearAllCharacterPreview" )

	Hud_SetVisible( file.blurbPanel, false )
	Hud_SetVisible( file.mythicPanel, false )
	Hud_SetVisible( file.mythicSelection, false )
	Hud_SetVisible( file.mythicLeftButton, false )
	Hud_SetVisible( file.mythicRightButton, false )
	Hud_SetVisible( file.mythicTrackingButton, false )

	void functionref( ItemFlavor, var ) customButtonUpdateFunc

	customButtonUpdateFunc = (void function( ItemFlavor itemFlav, var rui )
	{
		bool isMythic = Mythics_IsItemFlavorMythicSkin( itemFlav )
		if ( isMythic )
		{
			RuiSetInt( rui, "highestMythicTier", Mythics_GetNumTiersUnlockedForSkin( GetLocalClientPlayer(), itemFlav ) )
		}
		else
		{
			RuiSetInt( rui, "highestMythicTier", 0 )
		}
		RuiSetBool( rui, "showMythicIcons", isMythic )
	})

	                                  
	if ( IsPanelActive( file.panel ) && IsTopLevelCustomizeContextValid() )
	{
		LoadoutEntry entry = Loadout_CharacterSkin( GetTopLevelCustomizeContext() )
		file.characterSkinList = GetLoadoutItemsSortedForMenu( entry, CharacterSkin_GetSortOrdinal )
		FilterCharacterSkinList( file.characterSkinList )

		Hud_InitGridButtons( file.listPanel, file.characterSkinList.len() )
		foreach ( int flavIdx, ItemFlavor flav in file.characterSkinList )
		{
			var button = Hud_GetChild( scrollPanel, "GridButton" + flavIdx )
			if( Mythics_IsItemFlavorMythicSkin( flav ) )
			{
				int maxUnlockedTier = Mythics_GetNumTiersUnlockedForSkin( GetLocalClientPlayer(), flav ) - 1                                                                                
				int tierToDisplay = ClampInt( file.activeMythicSkinTier, 0, maxUnlockedTier )
				flav = expect ItemFlavor( Mythics_GetSkinTierForCharacter( GetTopLevelCustomizeContext(), tierToDisplay ) )
				file.mythicGridButton = button
			}

			CustomizeButton_UpdateAndMarkForUpdating( button, [entry], flav, PreviewCharacterSkin, CanEquipCanBuyCharacterItemCheck,false, customButtonUpdateFunc )
		}

		CustomizeMenus_SetActionButton( Hud_GetChild( panel, "ActionButton" ) )
		RuiSetString( file.headerRui, "collected", GetCollectedString( entry, false, false ) )
	}
}


void function CharacterSkinsPanel_OnFocusChanged( var panel, var oldFocus, var newFocus )
{
	if ( !IsValid( panel ) )                  
		return
	if ( GetParentMenu( panel ) != GetActiveMenu() )
		return

	UpdateFooterOptions()

	if ( IsControllerModeActive() )
		CustomizeMenus_UpdateActionContext( newFocus )
}


void function PreviewCharacterSkin( ItemFlavor flav )
{
	#if DEVELOPER
		if ( InputIsButtonDown( KEY_LSHIFT ) )
		{
			string locedName = Localize( ItemFlavor_GetLongName( flav ) )
			printt( "\"" + locedName + "\" grx ref is: " + GetGlobalSettingsString( ItemFlavor_GetAsset( flav ), "grxRef" ) )
			printt( "\"" + locedName + "\" body model is: " +  CharacterSkin_GetBodyModel( flav ) )

		}
	#endif       

	                   
	if ( CharacterSkin_HasStoryBlurb( flav ) )
	{
		Hud_SetVisible( file.blurbPanel, true )
		ItemFlavor characterFlav = CharacterSkin_GetCharacterFlavor( flav )

		asset portraitImage = ItemFlavor_GetIcon( characterFlav )
		CharacterHudUltimateColorData colorData = CharacterClass_GetHudUltimateColorData( characterFlav )

		var rui = Hud_GetRui( file.blurbPanel )
		RuiSetString( rui, "characterName", ItemFlavor_GetShortName( characterFlav ) )
		RuiSetString( rui, "skinNameText", ItemFlavor_GetLongName( flav ) )
		RuiSetString( rui, "bodyText", CharacterSkin_GetStoryBlurbBodyText( flav ) )
		RuiSetImage( rui, "portraitIcon", portraitImage )
		RuiSetFloat3( rui, "characterColor", SrgbToLinear( colorData.ultimateColor ) )
		RuiSetGameTime( rui, "startTime", ClientTime() )
	}
	else
	{
		Hud_SetVisible( file.blurbPanel, false )
	}

	if( Mythics_IsItemFlavorMythicSkin( flav ) )
	{
		Hud_SetVisible( file.mythicPanel, true )
		Hud_SetVisible( file.mythicSelection, true )
		Hud_SetVisible( file.mythicLeftButton, true )
		Hud_SetVisible( file.mythicRightButton, true )
		UpdateMythicSkinInfo()
		flav = expect ItemFlavor( Mythics_GetItemTierForSkin( flav, file.activeMythicSkinTier ) )
	}
	else
	{
		Hud_SetVisible( file.mythicPanel, false )
		Hud_SetVisible( file.mythicSelection, false )
		Hud_SetVisible( file.mythicLeftButton, false )
		Hud_SetVisible( file.mythicRightButton, false )
		Hud_SetVisible( file.mythicTrackingButton, false )
	}

	RunClientScript( "UIToClient_PreviewCharacterSkinFromCharacterSkinPanel", ItemFlavor_GetGUID( flav ), ItemFlavor_GetGUID( GetTopLevelCustomizeContext() ) )
}


void function UpdateMythicSkinInfo()
{
	ItemFlavor characterFlav = GetTopLevelCustomizeContext()
	asset portraitImage = ItemFlavor_GetIcon( characterFlav )
	ItemFlavor challenge = Mythics_GetChallengeForCharacter( characterFlav )

	var rui = Hud_GetRui( file.mythicPanel )
	RuiSetInt( rui, "activeTierIndex", file.activeMythicSkinTier + 1 )

	if(  file.activeMythicSkinTier - 1 < 0 )
		RuiSetString( rui, "challengeTierDesc", "#MYTHIC_SKIN_UNLOCK_DESC" )
	else
		RuiSetString( rui, "challengeTierDesc", Challenge_GetDescription( challenge, file.activeMythicSkinTier - 1 ) )

	entity player = GetLocalClientPlayer()

	int currentTier = -1
	int currentProgress = -1
	int goalProgress = -1

	int challengeTierCount = Challenge_GetTierCount( challenge )
	int ownedEvolvedSkinCount = 0
	for ( int skinTier = 1; skinTier <= challengeTierCount; skinTier++ )
	{
		                                                                                                                   
		ItemFlavor skin = expect ItemFlavor( Mythics_GetSkinTierForCharacter( characterFlav, skinTier ) )
		if ( GRX_IsItemOwnedByPlayer( skin ) )
			ownedEvolvedSkinCount++
	}

	if ( DoesPlayerHaveChallenge( player, challenge ) && ownedEvolvedSkinCount != challengeTierCount )
	{
		currentTier = Challenge_GetCurrentTier( player, challenge )

		if( !Challenge_IsComplete( player, challenge ) )
		{
			currentProgress = Challenge_GetProgressValue( player, challenge, currentTier )
			goalProgress    = Challenge_GetGoalVal( challenge, currentTier )
		}
	}



}

       

void function MythicEquipButton_OnActivate( var button )
{
	EHI playerEHI = LocalClientEHI()
	ItemFlavor character = GetTopLevelCustomizeContext()
	LoadoutEntry entry = Loadout_CharacterSkin( character )

	ItemFlavor characterSkin = LoadoutSlot_GetItemFlavor( playerEHI, entry )
	ItemFlavor previewSkin = expect ItemFlavor( Mythics_GetSkinTierForCharacter( character, file.activeMythicSkinTier ) )
	bool isEquiped = ( characterSkin == previewSkin )

	if( isEquiped )
		return

	PIN_Customization( character, previewSkin, "equip" )
	RequestSetItemFlavorLoadoutSlot( playerEHI, entry, previewSkin )
}

void function FilterCharacterSkinList( array<ItemFlavor> characterSkinList )
{
	for ( int i = characterSkinList.len() - 1; i >= 0; i-- )
	{
		if ( !ShouldDisplayCharacterSkin( characterSkinList[i] ) )
			characterSkinList.remove( i )
	}
}

bool function ShouldDisplayCharacterSkin( ItemFlavor characterSkin )
{
	if ( CharacterSkin_ShouldHideIfLocked( characterSkin ) )
	{
		LoadoutEntry entry = Loadout_CharacterSkin( CharacterSkin_GetCharacterFlavor( characterSkin ) )
		if ( !IsItemFlavorUnlockedForLoadoutSlot( LocalClientEHI(), entry, characterSkin ) )
			return false
	}

	if ( Mythics_IsItemFlavorMythicSkin( characterSkin ) )
	{
		if ( Mythics_GetSkinTierIntForSkin( characterSkin ) > 1 )
			return false
	}

	return true
}


void function LeftMythicSkinButton_OnActivate( var button )
{
	if( file.activeMythicSkinTier <= 0 )
		return

	file.activeMythicSkinTier--

	ItemFlavor character = GetTopLevelCustomizeContext()

	CharacterSkinsPanel_Update( file.panel )
	CustomizeButton_OnClick( file.mythicGridButton )
	Mythics_PreviewSkinForCharacter( character, file.activeMythicSkinTier )
	UpdateMythicSkinInfo()

}

void function RightMythicSkinButton_OnActivate( var button )
{
	if( file.activeMythicSkinTier >= 2 )
		return

	file.activeMythicSkinTier++

	ItemFlavor character = GetTopLevelCustomizeContext()

	CharacterSkinsPanel_Update( file.panel )
	CustomizeButton_OnClick( file.mythicGridButton )
	Mythics_PreviewSkinForCharacter( character, file.activeMythicSkinTier )
	UpdateMythicSkinInfo()

}

void function MythicTrackingButton_OnClick( var button )
{
	ItemFlavor challenge = Mythics_GetChallengeForCharacter( GetTopLevelCustomizeContext() )
	Mythics_ToggleTrackChallenge( challenge, file.mythicTrackingButton, true )
}

void function Mythics_PreviewSkinForCharacter( ItemFlavor character, int tier )
{
	ItemFlavor flav = expect ItemFlavor( Mythics_GetSkinTierForCharacter( character, tier ) )
	RunClientScript( "UIToClient_PreviewStoreItem", ItemFlavor_GetGUID( flav ) )
}

void function UpdateMythicTrackingButton()
{
	ItemFlavor character = GetTopLevelCustomizeContext()
	if ( !Mythics_CharacterHasMythic( character ) )
		return

	ItemFlavor challenge = Mythics_GetChallengeForCharacter( character )
	var rui = Hud_GetRui( file.mythicTrackingButton )
	bool isChallengeTracked = IsFavoriteChallenge( challenge )

	RuiSetString( rui, "buttonText", "#CHALLENGE" )
	RuiSetString( rui, "descText", isChallengeTracked ? "#CHALLENGE_TRACKED" : "#CHALLENGE_TRACK" )
	RuiSetString( rui, "bigText", isChallengeTracked ? "`1%$rui/hud/check_selected%" : "`1%$rui/borders/key_border%" )
}

void function FocusOnMythicSkinIfAnyTierEquiped()
{
	ItemFlavor equippedSkin = LoadoutSlot_GetItemFlavor( LocalClientEHI(), Loadout_CharacterSkin( GetTopLevelCustomizeContext() ) )
	if( Mythics_IsItemFlavorMythicSkin( equippedSkin ) )
		CustomizeButton_OnClick( file.mythicGridButton )
}

string function GetCollectedString( LoadoutEntry entry, bool ignoreDefaultItemForCount, bool shouldIgnoreOtherSlots )
{
	array< ItemFlavor > unlockedSkins = GetUnlockedItemFlavorsForLoadoutSlot( LocalClientEHI(), entry, shouldIgnoreOtherSlots )
	int owned = unlockedSkins.len()
	int total = file.characterSkinList.len()

	if ( Mythics_CharacterHasMythic( GetTopLevelCustomizeContext() ) )
	{
		foreach ( ItemFlavor skin in unlockedSkins )
		{
			if ( Mythics_IsItemFlavorMythicSkin( skin ) && Mythics_GetSkinTierIntForSkin( skin ) > 1 && GRX_IsItemOwnedByPlayer_AllowOutOfDateData( skin, GetLocalClientPlayer() ) )
				owned--
		}
	}

	if ( ignoreDefaultItemForCount )
	{
		owned--
		total--
	}

	if ( file.characterSkinList.contains( entry.favoriteItemFlavor ) )
	{
		owned--
		total--
	}

	return Localize( "#COLLECTED_ITEMS", owned, total )
}