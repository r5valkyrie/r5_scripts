"scripts/resource/ui/menus/panels/home.res"
{
    Screen
    {
        ControlName				Label
        wide			        %100
        tall			        %100
        labelText				""
        visible					0
    }

    PanelFrame
    {
		ControlName				Label
		xpos					0
		ypos					0
		wide					%100
		tall					%100
		labelText				""
		visible				    0
        bgcolor_override        "0 0 0 64"
        paintbackground         1

        proportionalToParent    1
    }
    
	ChatRoomTextChat
	{
		ControlName				CBaseHudChat
		xpos					32
		wide					992
		tall					208
		visible 				0
		enabled					0

		destination				"chatroom"
		interactive				1
		chatBorderThickness		1
		messageModeAlwaysOn		1
        setUnusedScrollbarInvisible 1
		hideInputBox			1 [$GAMECONSOLE]
		font 					Default_27
		zpos                    2

		bgcolor_override 		"0 0 0 0"
		chatHistoryBgColor		"24 27 30 10"
		chatEntryBgColor		"24 27 30 100"
		chatEntryBgColorFocused	"24 27 30 120"

        pin_to_sibling			ReadyButton
        pin_corner_to_sibling	BOTTOM_LEFT
        pin_to_sibling_corner	BOTTOM_RIGHT
	}

    AccessibilityHint
    {
        ControlName             RuiPanel
        classname               "MenuButton"
        wide                    300
        tall                    40
        visible                 0

        rui                     "ui/accessibility_hint.rpak"

        ruiArgs
        {
            buttonText          "#MENU_ACCESSIBILITY_CHAT_HINT" [!$PC]
            buttonText          "#MENU_ACCESSIBILITY_CHAT_HINT_PC" [$PC] // controller chat option only on console
            buttonTextPC        "#MENU_ACCESSIBILITY_CHAT_HINT_PC"
        }

        pin_corner_to_sibling	BOTTOM_LEFT
        pin_to_sibling			ChatRoomTextChat
        pin_to_sibling_corner	TOP_LEFT
    }

    FillButton
    {
        ControlName				RuiButton
        classname               "MenuButton"
        wide					367
        tall					38
        ypos                    16
        rui                     "ui/generic_button.rpak"
        labelText               ""
        visible					0
        cursorVelocityModifier  0.7

        navUp                   InviteFriendsButton0
        navRight                InviteFriendsButton0
        navDown                 ModeButton

        proportionalToParent    1

        pin_to_sibling			ModeButton
        pin_corner_to_sibling	BOTTOM_LEFT
        pin_to_sibling_corner	TOP_LEFT
    }
    
	"DarkenBackground"
	{
		"ControlName"			"Label"
		"xpos"					"0"
		"ypos"					"0"
		"zpos"					"0"
		"wide"					"%100"
		"tall"					"%100"
		"labelText"				""
		"bgcolor_override"		"0 0 0 0"
		"visible"				"1"
		"paintbackground"		"1"
	}

	TopRightContentAnchor
    {
        ControlName				Label
        wide					308
        tall					45
        labelText               ""
        //visible					1
        //bgcolor_override        "0 255 0 64"
        //paintbackground         1
		xpos					-50

        pin_to_sibling			DarkenBackground
        pin_corner_to_sibling	TOP_RIGHT
        pin_to_sibling_corner	TOP_RIGHT
    }

	MiniPromo
    {
        ControlName				RuiButton
        wide                    308
        tall                    106
		ypos					25
        rui                     "ui/mini_promo.rpak"
        visible					1
        cursorVelocityModifier  0.7

        proportionalToParent    1

        pin_to_sibling          R5RVersionButton
        pin_corner_to_sibling   TOP_LEFT
        pin_to_sibling_corner   BOTTOM_LEFT

        sound_focus             "UI_Menu_Focus_Large"
        sound_accept            ""
    }

	ReadyButton
    {
        ControlName				RuiButton
        classname               "MenuButton MatchmakingStatusRui"
        wide					367
        tall					112
        rui                     "ui/generic_ready_button.rpak"
        labelText               ""
        visible					1
		cursorVelocityModifier  0.7
		ypos					-150
		xpos					-50

		navUp                   ModeButton

        proportionalToParent    1

        pin_to_sibling			DarkenBackground
        pin_corner_to_sibling	BOTTOM_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT

        sound_focus             "UI_Menu_Focus_Large"
    }

	GamemodeSelectV2Button
    {
        ControlName				RuiButton
        classname               "MenuButton MatchmakingStatusRui"
        wide					367
        tall					168
        ypos                    13
        zpos                    10
        rui                     "ui/gamemode_select_v2_lobby_button.rpak"
        labelText               ""
        visible					1
        cursorVelocityModifier  0.7
        sound_accept            "UI_Menu_SelectMode_Extend"

        navUp                   InviteFriendsButton0
        navDown                 ReadyButton
        navRight                InviteFriendsButton0

        proportionalToParent    1

        pin_to_sibling			ReadyButton
        pin_corner_to_sibling	BOTTOM_LEFT
        pin_to_sibling_corner	TOP_LEFT
    }

    InviteFriendsButton0
    {
        ControlName				RuiButton
        InheritProperties       InviteButton
        xpos                    -374
        
		visible					0
        
        ypos                    -90

        navUp                   FriendButton0
        navRight                FriendButton0
        navLeft                 InviteLastPlayedUnitframe0

        pin_to_sibling			PanelFrame
        pin_corner_to_sibling	CENTER
        pin_to_sibling_corner	CENTER
    }

    InviteFriendsButton1
    {
        ControlName				RuiButton
        InheritProperties       InviteButton
        xpos                    374
        ypos                    -90

        navLeft                 FriendButton1

		visible					0

        pin_to_sibling			PanelFrame
        pin_corner_to_sibling	CENTER
        pin_to_sibling_corner	CENTER
    }

    InviteLastSquadHeader
	{
		ControlName				RuiPanel
		//xpos					-30
		ypos					-155
		wide					245
		tall					24
		visible					0
        rui					    "ui/invite_last_squad_header.rpak"

        pin_to_sibling			PanelFrame
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	LEFT
	}

    InviteLastPlayedUnitframe0
    {
        ControlName             RuiButton

        pin_to_sibling			InviteLastSquadHeader
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT
        rightClickEvents		1

        ypos                    14
        
		visible					0

        navRight                InviteFriendsButton0
        navDown                 InviteLastPlayedUnitframe1

        scriptID                0

        wide                    245
        tall                    47

        rui					    "ui/unitframe_lobby_invite_last_squad.rpak"
    }

    InviteLastPlayedUnitframe1
    {
        ControlName             RuiButton

        pin_to_sibling			InviteLastPlayedUnitframe0
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT
        rightClickEvents		1

        ypos                    20
        
		visible					0

        navUp                   InviteLastPlayedUnitframe0
        navRight                InviteFriendsButton0
        navDown                 FillButton

        scriptID                1

        wide                    245
        tall                    47

        rui					    "ui/unitframe_lobby_invite_last_squad.rpak"
    }

    SelfButton
    {
        ControlName				RuiButton
        wide					340
        tall					88
        xpos                    0
        ypos                    -30
        rui                     "ui/lobby_friend_button.rpak"
        labelText               ""
        visible					1
        cursorVelocityModifier  0.7
        scriptID                -1
        rightClickEvents		0
        tabPosition             1

        navDown                 FriendButton0
        navLeft                 FriendButton0
        navRight                FriendButton1

        proportionalToParent    1

        pin_to_sibling			PanelFrame
        pin_corner_to_sibling	TOP
        pin_to_sibling_corner	TOP
    }


    FriendButton0
    {
        ControlName				RuiButton
        wide					340
        tall					88
        xpos                    -376
        ypos                    -74
        rui                     "ui/lobby_friend_button.rpak"
        labelText               ""
        visible					0
        cursorVelocityModifier  0.7
        scriptID                0
        rightClickEvents		1

        navLeft                 InviteFriendsButton0
        navRight                SelfButton

        proportionalToParent    1

        pin_to_sibling			PanelFrame
        pin_corner_to_sibling	TOP
        pin_to_sibling_corner	TOP
    }

    FriendButton1
    {
        ControlName				RuiButton
        wide					340
        tall					88
        xpos                    376
        ypos                    -74
        rui                     "ui/lobby_friend_button.rpak"
        labelText               ""
        visible					0
        cursorVelocityModifier  0.7
        scriptID                1
        rightClickEvents		1

        navLeft                 SelfButton
        navRight                InviteFriendsButton1

        proportionalToParent    1

        pin_to_sibling			PanelFrame
        pin_corner_to_sibling	TOP
        pin_to_sibling_corner	TOP
    }

	HDTextureProgress
	{
		ControlName				RuiPanel
		xpos					0
		ypos					70
		zpos					10
		wide					300
		tall					24
		visible					0
		proportionalToParent    1
		rui 					"ui/lobby_hd_progress.rpak"

		pin_to_sibling			TabsCommon
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_LEFT
	}

	TopRightContentAnchor
    {
        ControlName				Label
        wide					308
        tall					45
        labelText               ""
        //visible					1
        //bgcolor_override        "0 255 0 64"
        //paintbackground         1

        pin_to_sibling			PanelFrame
        pin_corner_to_sibling	TOP_RIGHT
        pin_to_sibling_corner	TOP_RIGHT
    }

	GameMenuButton
        {
            ControlName				RuiButton
            InheritProperties		CornerButton
            zpos                    5
			ypos					-150
			xpos					-50
			

            pin_to_sibling			DarkenBackground
            pin_corner_to_sibling	BOTTOM_RIGHT
            pin_to_sibling_corner	BOTTOM_RIGHT
        }

	PlayersButton
        {
            ControlName				RuiButton
            InheritProperties		CornerButton
            xpos                    13
            zpos                    5

            pin_to_sibling			GameMenuButton
            pin_corner_to_sibling	BOTTOM_RIGHT
            pin_to_sibling_corner	BOTTOM_LEFT
        }

	ServersButton
        {
            ControlName				RuiButton
            InheritProperties		CornerButton
            xpos                    13
            zpos                    5

            pin_to_sibling			PlayersButton
            pin_corner_to_sibling	BOTTOM_RIGHT
            pin_to_sibling_corner	BOTTOM_LEFT
        }

	NewsButton
        {
            ControlName				RuiButton
            InheritProperties		CornerButton
            xpos                    13
            zpos                    5

            pin_to_sibling			ServersButton
            pin_corner_to_sibling	BOTTOM_RIGHT
            pin_to_sibling_corner	BOTTOM_LEFT
        }
}

