"resource/ui/menus/panels/private_match_game_team_overview.res"
{
	PanelFrame
	{
		ControlName				Label
		xpos					0
		ypos					0
		wide					%100
		tall					%100
		labelText				""
		bgcolor_override		"255 16 255 32"
		visible					0
		paintbackground			0
		proportionalToParent    1
	}

	ToolTip
    {
        ControlName				RuiPanel
        InheritProperties       ToolTip
        zpos                    999
    }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////
    // Row 1 (team 0 - team 9)
    ///////////////////////////////

	TeamOverview01
    {
        ControlName             GridButtonListPanel

		xpos                    -120
		ypos                    50

		pin_to_sibling              PanelFrame
		pin_corner_to_sibling       BOTTOM_LEFT
		pin_to_sibling_corner       BOTTOM_LEFT

        columns                 1
        rows                    3
        buttonSpacing           12
        scrollbarSpacing        0
        scrollbarOnLeft         0
        selectOnDpadNav         1

        ButtonSettings
        {
            rui                     "ui/private_match_team_overview.rpak"
            clipRui                 1
            wide                    742
            tall                    91
            cursorVelocityModifier  0.7
            sound_focus             "UI_Menu_Focus_Small"
            sound_accept            ""
            sound_deny              ""
        }
    }

    TeamOverviewHeader01
    {
        ControlName					RuiPanel

        rui							"ui/private_match_team_overview_header.rpak"

        pin_to_sibling              TeamOverview01
        pin_corner_to_sibling       BOTTOM_LEFT
        pin_to_sibling_corner       TOP_LEFT

		xpos                    0
		ypos                    10

        wide					742
        tall 					48
    }

    TeamOverviewLarge2
    {
        ControlName					RuiPanel

        rui							"ui/private_match_team_overview_large.rpak"

        pin_to_sibling              TeamOverviewHeader01
        pin_corner_to_sibling       BOTTOM_LEFT
        pin_to_sibling_corner       TOP_LEFT

        xpos                    0
        ypos                    20

        wide					742
        tall 					198
    }

	TeamOverviewLarge1
	{
		ControlName					RuiPanel

		rui							"ui/private_match_team_overview_large.rpak"

		pin_to_sibling              TeamOverviewLarge2
		pin_corner_to_sibling       BOTTOM_LEFT
		pin_to_sibling_corner       TOP_LEFT

		xpos                    0
		ypos                    5

		wide					742
		tall 					278
	}


	///////////////////////////////
    // Row 2 (team 6 - team 13)
    ///////////////////////////////

	TeamOverview02
    {
        ControlName             GridButtonListPanel

        xpos                    -100
        ypos                    -20

        pin_to_sibling          PanelFrame
        pin_corner_to_sibling   TOP_RIGHT
        pin_to_sibling_corner   TOP_RIGHT

        columns                 1
        rows                    8
        buttonSpacing           9
        scrollbarSpacing        0
        scrollbarOnLeft         0

        selectOnDpadNav         1

        ButtonSettings
        {
            rui                     "ui/private_match_team_overview.rpak"
            clipRui                 0
            wide                    742
            tall                    48
            cursorVelocityModifier  0.7
            sound_focus             "UI_Menu_Focus_Small"
            sound_accept            ""
            sound_deny              ""
        }
    }

	///////////////////////////////
    // Row 2 (team 14 - team 20)
    ///////////////////////////////

    TeamOverview03
    {
        ControlName             GridButtonListPanel

        //xpos                    -100
        ypos                    9

        pin_to_sibling          TeamOverview02
        pin_corner_to_sibling   TOP_LEFT
        pin_to_sibling_corner   BOTTOM_LEFT

        columns                 1
        rows                    7
        buttonSpacing           9
        scrollbarSpacing        0
        scrollbarOnLeft         0
        selectOnDpadNav         1

        ButtonSettings
        {
            rui                     "ui/private_match_team_overview.rpak"
            clipRui                 0
            wide                    742
            tall                    48
            cursorVelocityModifier  0.7
            sound_focus             "UI_Menu_Focus_Small"
            sound_accept            ""
            sound_deny              ""
        }
    }
}
