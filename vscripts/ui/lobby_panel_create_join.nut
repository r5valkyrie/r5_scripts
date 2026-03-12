global function InitCreateJoinPanel

struct
{
	var panel

	int activeTabIndex = 0
} file


void function InitCreateJoinPanel( var panel )
{
	file.panel = panel

	SetPanelTabTitle( panel, "CREATE & JOIN" )

	AddPanelEventHandler( panel, eUIEvent.PANEL_SHOW, CreateJoinPanel_OnShow )
	AddPanelEventHandler( panel, eUIEvent.PANEL_HIDE, CreateJoinPanel_OnHide )

	{
		var childPanel = Hud_GetChild( file.panel, "CreatePanel" )
		TabDef tab = AddTab( file.panel, childPanel, "#SB_CREATE" )
		SetTabBaseWidth( tab, 160 )
	}
	{
		var childPanel = Hud_GetChild( file.panel, "ServerBrowserPanel" )
		TabDef tab = AddTab( file.panel, childPanel, "#SB_SERVERS" )
		SetTabBaseWidth( tab, 160 )
	}

	TabData tabData = GetTabDataForPanel( file.panel )
	tabData.centerTabs = true
	SetTabBackground( tabData, Hud_GetChild( file.panel, "TabsBackground" ), eTabBackground.STANDARD )
	SetTabDefsToSeasonal(tabData)
}


void function CreateJoinPanel_OnShow( var panel )
{
	TabData tabData = GetTabDataForPanel( panel )

	DeactivateTab( tabData )
	SetTabNavigationEnabled( file.panel, false )
	SetTabNavigationEnabled( file.panel, true )

	if ( GetLastMenuNavDirection() == MENU_NAV_FORWARD )
	{
		ActivateTab( tabData, 0 )
		thread AnimateInSmallTabBar( tabData )
	}
	else
	{
		ActivateTab( tabData, file.activeTabIndex )
	}

	UI_SetPresentationType( ePresentationType.CHARACTER_SELECT )
}


void function CreateJoinPanel_OnHide( var panel )
{
	file.activeTabIndex = GetMenuActiveTabIndex( panel )
}
