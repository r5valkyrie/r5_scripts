"scripts/resource/ui/menus/panels/freeroam_map_select.res"
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
        wide					%100
        tall					500
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

	MapButton2
	{
		ControlName				RuiButton
        wide					350
        tall					197
        ypos                    0
        xpos                    0
        zpos                    10
        rui                     "ui/gamemode_select_v2_lobby_button.rpak"
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

        pin_to_sibling			ContentRui
        pin_corner_to_sibling	CENTER
        pin_to_sibling_corner	CENTER
	}

	MapButton0
	{
		ControlName				RuiButton
        wide					350
        tall					197
        ypos                    0
        xpos                    15
        zpos                    10
        rui                     "ui/gamemode_select_v2_lobby_button.rpak"
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

        pin_to_sibling			MapButton1
        pin_corner_to_sibling	RIGHT
        pin_to_sibling_corner	LEFT
	}

	MapButton1
	{
		ControlName				RuiButton
        wide					350
        tall					197
        ypos                    0
        xpos                    15
        zpos                    10
        rui                     "ui/gamemode_select_v2_lobby_button.rpak"
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

        pin_to_sibling			MapButton2
        pin_corner_to_sibling	RIGHT
        pin_to_sibling_corner	LEFT
	}

	MapButton3
	{
		ControlName				RuiButton
        wide					350
        tall					197
        ypos                    0
        xpos                    15
        zpos                    10
        rui                     "ui/gamemode_select_v2_lobby_button.rpak"
        labelText               ""
        visible					1
        scaleImage              1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"3"

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }

        pin_to_sibling			MapButton2
        pin_corner_to_sibling	LEFT
        pin_to_sibling_corner	RIGHT
	}

	MapButton4
	{
		ControlName				RuiButton
        wide					350
        tall					197
        ypos                    0
        xpos                    15
        zpos                    10
        rui                     "ui/gamemode_select_v2_lobby_button.rpak"
        labelText               ""
        visible					1
        scaleImage              1
        sound_accept            "UI_Menu_GameMode_Select"
		"scriptID"					"4"

        ruiArgs
        {
            lockIconEnabled 0
            modeNameText "Map Name"
            modeDescText ""
            alwaysShowDesc 0
            modeImage ""
        }

        pin_to_sibling			MapButton3
        pin_corner_to_sibling	LEFT
        pin_to_sibling_corner	RIGHT
	}
}
