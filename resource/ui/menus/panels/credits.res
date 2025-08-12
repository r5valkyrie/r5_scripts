"scripts/resource/ui/menus/panels/credits.res"
{
    PanelFrame
    {
        ControlName             Label
        xpos                    0
        ypos                    0
        wide                   %100
        tall                   %100
        labelText              ""
        visible                 0
        bgcolor_override       "0 0 0 0"
        paintbackground        1
    }

    CreditsList
    {
        ControlName				GridButtonListPanel
        xpos                    -500
        ypos                    0
        columns                 1
        rows                    12
        buttonSpacing           6
        scrollbarSpacing        6
        scrollbarOnLeft         0
        visible					1
        tabPosition             1
        selectOnDpadNav         1

        pin_to_sibling			    PanelFrame

		pin_corner_to_sibling	CENTER
		pin_to_sibling_corner	CENTER

        ButtonSettings
        {
            rui                     "ui/generic_item_button.rpak"
            clipRui                 1
            wide					350
            tall					50
            cursorVelocityModifier  0.7
            rightClickEvents		1
			doubleClickEvents       1
            sound_focus             "UI_Menu_Focus_Small"
            sound_accept            ""
            sound_deny              ""
        }
    }

    Header
    {
        "ControlName"			"Label"
		"xpos"                  "-10"
		"ypos"					"15"
        zpos                    20
		"auto_wide_tocontents"	"1"
		"tall"					"40"
		"visible"				"1"
		"wrap"					"0"
		"fontHeight"			"40"
		"zpos"					"5"
		"textAlignment"			"north-west"
		"labelText"				"Credits"
		"font"					"TitleBoldFont"
		"allcaps"				"1"
		"fgcolor_override"		"255 255 255 255"

        pin_to_sibling			CreditsList
		pin_corner_to_sibling	BOTTOM
		pin_to_sibling_corner	TOP
    }

    "RightLine"
	{
		"ControlName"			"ImagePanel"
		"xpos"					"0"
		"ypos"					"3"
		"tall"					"1"
		"wide" 					"330"
		"fillColor"				"255 255 255 255"
        "drawColor"				"255 255 255 255"
		"wrap"					"1"
		"visible"				"1"
		"zpos"					"3"

		"pin_to_sibling"		"Header"
		"pin_corner_to_sibling"	"TOP"
		"pin_to_sibling_corner"	"BOTTOM"
	}

    CreditsBlurb
    {
        ControlName             RuiPanel
        xpos                    50
        ypos                    0
        zpos                    0
        wide                    890
        tall                    660
        rui                     "ui/generic_popup_button.rpak"
        visible                 1

        ruiArgs
        {
            buttonText ""
        }

        pin_to_sibling			CreditsList
        pin_corner_to_sibling	LEFT
        pin_to_sibling_corner	RIGHT
    }

    "CenterLine"
	{
		"ControlName"			"ImagePanel"
		"xpos"					"0"
		"ypos"					"0"
		"tall"					"630"
		"wide" 					"1"
		"fillColor"				"255 255 255 255"
        "drawColor"				"255 255 255 255"
		"wrap"					"1"
		"visible"				"1"
		"zpos"					"3"

		"pin_to_sibling"		"CreditsBlurb"
		"pin_corner_to_sibling"	"CENTER"
		"pin_to_sibling_corner"	"CENTER"
	}

    ProfilePicture
	{
		ControlName				RuiPanel
		rui                     "ui/basic_image.rpak"
        ypos                    -15
        xpos                    -15
        wide			        415
        tall			        415
		visible					1
	    scaleImage              1

        ruiArgs
        {
            basicImage "rui/menu/character_skills/background"
        }

        pin_to_sibling			CreditsBlurb
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_LEFT
	}

    Name
    {
        "ControlName"			"Label"
		"xpos"                  "0"
		"ypos"					"15"
        zpos                    20
		"auto_wide_tocontents"	"1"
		"tall"					"40"
		"visible"				"1"
		"wrap"					"0"
		"fontHeight"			"35"
		"zpos"					"5"
		"textAlignment"			"north-west"
		"labelText"				"User Name"
		"font"					"TitleBoldFont"
		"allcaps"				"1"
		"fgcolor_override"		"255 255 255 255"

        pin_to_sibling			ProfilePicture
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT
    }

    DescriptionShort
    {
        "ControlName"			"Label"
		"xpos"                  "0"
		"ypos"					"5"
        zpos                    20
        auto_wide_tocontents    1
		"visible"				"1"
		"fontHeight"			"20"
		"zpos"					"5"
		"textAlignment"			"left"
		"labelText"				"Desc"
		"font"					"TitleBoldFont"
		"allcaps"				"1"
		"fgcolor_override"		"255 255 255 255"

        pin_to_sibling			Name
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT
    }

    Github
    {
        "ControlName"			"Label"
		"xpos"                  "0"
		"ypos"					"10"
        zpos                    20
		"auto_wide_tocontents"	"1"
		"tall"					"30"
		"visible"				"1"
		"wrap"					"0"
		"fontHeight"			"25"
		"zpos"					"5"
		"textAlignment"			"north-west"
		"labelText"				"Github"
		"font"					"TitleFont"
		"allcaps"				"1"
		"fgcolor_override"		"255 255 255 255"

        pin_to_sibling			DescriptionShort
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT
    }

    Twitter
    {
        "ControlName"			"Label"
		"xpos"                  "0"
		"ypos"					"5"
        zpos                    20
		"auto_wide_tocontents"	"1"
		"tall"					"30"
		"visible"				"1"
		"wrap"					"0"
		"fontHeight"			"25"
		"zpos"					"5"
		"textAlignment"			"north-west"
		"labelText"				"Twitter"
		"font"					"TitleFont"
		"allcaps"				"1"
		"fgcolor_override"		"255 255 255 255"

        pin_to_sibling			Github
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT
    }

    Description
	{
		ControlName				RichText
		ypos                    -14
        xpos                    220
		wide					415
		tall					630
        font 					DefaultRegularFont
		fontHeight				22
		bgcolor_override		"0 0 0 192"
		paintbackground			1
		text					"TEXT OF WHAT THEY HAVE DONE HERE"
		maxchars				-1

		pin_to_sibling			CreditsBlurb
		pin_corner_to_sibling	TOP
		pin_to_sibling_corner	TOP
	}

}