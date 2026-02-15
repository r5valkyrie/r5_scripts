"resource/ui/menus/panels/store_sku_shop.res"
{
	PanelFrame
	{
		ControlName				Label
		wide					%100
		tall					%100
		labelText				""
	    bgcolor_override		"0 0 0 192"
		visible					1
		paintbackground			1
        proportionalToParent    1
	}

	InfoBox
	{
	    ControlName				RuiPanel

	    pin_to_sibling			PanelFrame
	    pin_corner_to_sibling	TOP
	    pin_to_sibling_corner	TOP
	    xpos					0
	    ypos					-24
	    wide					600
	    tall					60

        visible                 1
	    rui					    "ui/sku_shop_header.rpak"
	}

	CenterFrame
	{
		ControlName				Label
        xpos					0
        ypos					0
	    ypos_nx_handheld		46		[$NX]
        wide					%100
        tall					700

		labelText				""
	    bgcolor_override		"9 12 20 255"
		visible					1
		paintbackground			1
        proportionalToParent    1

        pin_to_sibling			InfoBox
        pin_corner_to_sibling	TOP
        pin_to_sibling_corner	BOTTOM
	}

    SKUButtonList
    {
        ControlName				GridButtonListPanel
        xpos                    0
        ypos                    0
        columns                 4
        rows                    1
        buttonSpacing           30
        scrollbarSpacing        16
        scrollbarOnLeft         0
        visible                 1
        tabPosition             1
        selectOnDpadNav         0
        horizontalScroll        1

        pin_to_sibling			CenterFrame
        pin_corner_to_sibling	CENTER
        pin_to_sibling_corner	CENTER

        ButtonSettings
        {
            rui                     "ui/sku_shop_item_button.rpak"
            clipRui                 1
            wide                    326
            wide_nx_handheld        359		[$NX]
            tall                    572
            tall_nx_handheld        629		[$NX]
            cursorVelocityModifier  0.7
        }
    }
	
	TaxNoticeMessage [$NX]
	{
		ControlName				Label
		labelText				""
		ypos					24
		wide					800
		tall					81
		visible					0
		fontHeight				42
		textAlignment			center

		pin_to_sibling			SKUButtonList
		pin_corner_to_sibling	TOP
		pin_to_sibling_corner	BOTTOM
	}
	
	DiscountPanel
	{
		ControlName				RuiPanel
		xpos                    81 //[$PS4] // Layout is different on PS4 because of PS Store banner
		//xpos                    0 [!$PS4]
		ypos                    -91 //[$PS4] // Avoid overlapping the PS Store banner
		//ypos                    20 [!$PS4]
		wide					900
		tall					132
		visible					1
        rui                     "ui/sku_shop_discount_panel.rpak"

        proportionalToParent    1

        pin_to_sibling			CenterFrame
        pin_corner_to_sibling	TOP
        pin_to_sibling_corner	BOTTOM
	}
}


