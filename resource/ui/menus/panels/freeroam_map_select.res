"resource/ui/menus/panels/freeroam_map_select.res"
{
	"DarkenBackground"
	{
		"ControlName"			"Label"
		"xpos"					"0"
		"ypos"					"0"
		"zpos"					"0"
		"wide"					"f0"
		"tall"					"f0"
		"labelText"				""
		"bgcolor_override"		"0 0 0 200"
		"visible"				"1"
		"paintbackground"		"1"
	}

	ContentRui
    {
        ControlName				RuiPanel
        wide					1200
        tall					750
        visible				    1
        rui                     "ui/dialog_content.rpak"

		pin_to_sibling			DarkenBackground
		pin_corner_to_sibling	CENTER
		pin_to_sibling_corner	CENTER
    }

	HeaderPanel
    {
        ControlName				RuiPanel
        xpos                    0
        ypos                    -50
        wide					1100
        tall					140
        visible					1
        enabled					1
        proportionalToParent    1
        visible                 1
        rui 					"ui/generic_menu_header.rpak"

        ruiArgs
        {
            menuName "SELECT A MAP"
        }

        "pin_to_sibling"			"ContentRui"
		"pin_corner_to_sibling"		"TOP"
		"pin_to_sibling_corner"		"TOP"
    }

	PagesFooter
    {
        ControlName				RuiPanel
        xpos					0
        ypos					-50
        wide					480
        tall					48
        visible					1
        rui					    "ui/battle_pass_footer_bar_v2.rpak"

        ruiArgs
        {
            currentPage 0
            levelRangeText "Scroll to change pages"
            numPages 20
        }

        pin_to_sibling			ContentRui
        pin_corner_to_sibling	BOTTOM
        pin_to_sibling_corner	BOTTOM
    }

    PrevButton
    {
        ControlName				RuiButton
        ypos                    0
        wide					64
        tall					64
        rui                     "ui/arrow_button_square.rpak"
        labelText               ""
        visible					1
        cursorVelocityModifier  0.7
        proportionalToParent    1
        sound_focus             "UI_Menu_BattlePass_Level_Focus"
        sound_accept            ""

        ruiArgs
        {
            flipHorizontal 1
        }

        pin_to_sibling			ContentRui
        pin_corner_to_sibling	LEFT
        pin_to_sibling_corner	LEFT
    }

    NextButton
    {
        ControlName				RuiButton
        ypos                    0
        wide					64
        tall					64
        rui                     "ui/arrow_button_square.rpak"
        labelText               ""
        visible					1
        cursorVelocityModifier  0.7
        proportionalToParent    1
        sound_focus             "UI_Menu_BattlePass_Level_Focus"
        sound_accept            ""

        pin_to_sibling			ContentRui
        pin_corner_to_sibling	RIGHT
        pin_to_sibling_corner	RIGHT
    }

	// 5x5 Grid with absolute positioning
	// Button size: 200x112, spacing: 10px
	// Grid starts at x=260, y=150 (centered horizontally on 1920 screen)
	// Each row is y + 122 (112 height + 10 spacing)

	MapButton0
	{
		ControlName				RuiButton
		xpos					440
		ypos					260
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"0"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton1
	{
		ControlName				RuiButton
		xpos					650
		ypos					260
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"1"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton2
	{
		ControlName				RuiButton
		xpos					860
		ypos					260
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"2"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton3
	{
		ControlName				RuiButton
		xpos					1070
		ypos					260
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"3"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton4
	{
		ControlName				RuiButton
		xpos					1280
		ypos					260
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"4"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	// Row 2
	MapButton5
	{
		ControlName				RuiButton
		xpos					440
		ypos					382
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"5"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton6
	{
		ControlName				RuiButton
		xpos					650
		ypos					382
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"6"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton7
	{
		ControlName				RuiButton
		xpos					860
		ypos					382
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"7"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton8
	{
		ControlName				RuiButton
		xpos					1070
		ypos					382
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"8"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton9
	{
		ControlName				RuiButton
		xpos					1280
		ypos					382
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"9"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	// Row 3
	MapButton10
	{
		ControlName				RuiButton
		xpos					440
		ypos					504
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"10"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton11
	{
		ControlName				RuiButton
		xpos					650
		ypos					504
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"11"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton12
	{
		ControlName				RuiButton
		xpos					860
		ypos					504
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"12"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton13
	{
		ControlName				RuiButton
		xpos					1070
		ypos					504
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"13"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton14
	{
		ControlName				RuiButton
		xpos					1280
		ypos					504
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"14"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	// Row 4
	MapButton15
	{
		ControlName				RuiButton
		xpos					440
		ypos					626
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"15"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton16
	{
		ControlName				RuiButton
		xpos					650
		ypos					626
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"16"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton17
	{
		ControlName				RuiButton
		xpos					860
		ypos					626
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"17"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton18
	{
		ControlName				RuiButton
		xpos					1070
		ypos					626
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"18"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton19
	{
		ControlName				RuiButton
		xpos					1280
		ypos					626
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"19"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	// Row 5
	MapButton20
	{
		ControlName				RuiButton
		xpos					440
		ypos					748
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"20"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton21
	{
		ControlName				RuiButton
		xpos					650
		ypos					748
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"21"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton22
	{
		ControlName				RuiButton
		xpos					860
		ypos					748
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"22"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton23
	{
		ControlName				RuiButton
		xpos					1070
		ypos					748
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"23"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}

	MapButton24
	{
		ControlName				RuiButton
		xpos					1280
		ypos					748
        wide					200
        tall					112
        zpos                    10
        rui                     "ui/gamemode_select_lobby_button.rpak"
        labelText               ""
        visible					1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"24"
        scaleImage              1

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }
	}
}
