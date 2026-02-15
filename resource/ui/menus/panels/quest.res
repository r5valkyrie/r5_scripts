"resource/ui/menus/panels/quest.res"
{
    PanelFrame
    {
		ControlName				Label
		xpos					0
		ypos					0
		wide					%100
		tall					%100
		labelText				""
		visible				    0
        bgcolor_override        "0 0 0 0"
        paintbackground         1
    }

	CenterFrame
	{
		ControlName				RuiPanel
        xpos					0
        ypos					0
        wide					1920
		tall					%100
		labelText				""
	    bgcolor_override		"70 30 70 64"
		visible					0
		paintbackground			1
        rui					    "ui/basic_image.rpak"
        proportionalToParent    1

        pin_to_sibling			PanelFrame
        pin_corner_to_sibling	TOP
        pin_to_sibling_corner	TOP
	}

	QuestInfoBox
	{
	    ControlName				RuiPanel

	    pin_to_sibling			CenterFrame
	    pin_corner_to_sibling	TOP_LEFT
	    pin_to_sibling_corner	TOP_LEFT
	    xpos					-284
	    ypos					-30
	    wide					1351
	    tall					685
	    visible					1
	    rui					    "ui/quest_info_box.rpak"
	}

    //////////////////////////////////////
    // REWARD BUTTONS + PURCHASE BUTTON //
    //////////////////////////////////////

    RewardsPanel
    {
        ControlName				CNestedPanel
        pin_to_sibling		    QuestInfoBox
        pin_corner_to_sibling   TOP_LEFT
        pin_to_sibling_corner   TOP_LEFT
        xpos					0
        ypos					0
        wide					1351    // Match size to QuestInfoBox
        tall					685
        visible					1
        clip                    1
        controlSettingsFile		"resource/ui/menus/panels/quest_rewards.res"
    }

    /////////////////////
    //  INTRO BUTTON   //
    /////////////////////

    IntroButton
    {
        ControlName			    RuiButton
        classname               "MenuButton"
        labelText               ""
        pin_to_sibling			QuestInfoBox
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_LEFT
        xpos					-371
        ypos					-200
        wide				    464
        tall				    100
        visible                 0
        scriptID                0
        rui					    "ui/battle_pass_purchase_button.rpak"
        sound_focus             "UI_Menu_Focus_Large"
        cursorVelocityModifier  0.7
        proportionalToParent	1

        navUp AboutButton
    }

    /////////////////////
    // MISSION BUTTONS //
    /////////////////////

    MissionButton0
    {
        ControlName				RuiButton
		classname				ComicPageSelect
        pin_to_sibling			QuestInfoBox
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_LEFT
        xpos					-817
        ypos					-50
        wide					122
        tall					122
        visible					1
        enabled					1
        navRight                MissionButton1
        navDown                 MissionButton4
        rui                     "ui/mission_button.rpak"
    }

    MissionButton1
    {
        ControlName				RuiButton
		classname				ComicPageSelect
        pin_to_sibling			MissionButton0
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_RIGHT
        xpos					4
        ypos					0
        wide					122
        tall					122
        visible					1
        enabled					1
        navLeft                 MissionButton0
        navRight                MissionButton2
        navDown                 MissionButton5
        rui                     "ui/mission_button.rpak"
    }

    MissionButton2
    {
        ControlName				RuiButton
		classname				ComicPageSelect
        pin_to_sibling			MissionButton1
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_RIGHT
        xpos					4
        ypos					0
        wide					122
        tall					122
        visible					1
        enabled					1
        navLeft                 MissionButton1
        navRight                MissionButton3
        navDown                 MissionButton6
        rui                     "ui/mission_button.rpak"
    }

    MissionButton3
    {
        ControlName				RuiButton
		classname				ComicPageSelect
        pin_to_sibling			MissionButton2
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_RIGHT
        xpos					4
        ypos					0
        wide					122
        tall					122
        visible					1
        enabled					1
        navLeft                 MissionButton2
        navRight                MissionButton4
        navDown                 MissionButton7
        rui                     "ui/mission_button.rpak"
    }

    MissionButton4
    {
        ControlName				RuiButton
		classname				ComicPageSelect
        pin_to_sibling			MissionButton0
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT
        xpos					0
        ypos					4
        wide					122
        tall					122
        visible					1
        enabled					1

        navUp                   MissionButton0
        navLeft                 MissionButton3
        navRight                MissionButton5
        navDown                 MissionButton8
        rui                     "ui/mission_button.rpak"
    }

    MissionButton5
    {
        ControlName				RuiButton
		classname				ComicPageSelect
        pin_to_sibling			MissionButton4
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_RIGHT
        xpos					4
        ypos					0
        wide					122
        tall					122
        visible					1
        enabled					1
        navUp                   MissionButton1
        navLeft                 MissionButton4
        navRight                MissionButton6
        navDown                 MissionButton9
        rui                     "ui/mission_button.rpak"
    }

    MissionButton6
    {
        ControlName				RuiButton
		classname				ComicPageSelect
        pin_to_sibling			MissionButton5
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_RIGHT
        xpos					4
        ypos					0
        wide					122
        tall					122
        visible					1
        enabled					1
        navUp                   MissionButton2
        navLeft                 MissionButton5
        navRight                MissionButton7
        navDown                 MissionButton10
        rui                     "ui/mission_button.rpak"
    }

    MissionButton7
    {
        ControlName				RuiButton
		classname				ComicPageSelect
        pin_to_sibling			MissionButton6
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_RIGHT
        xpos					4
        ypos					0
        wide					122
        tall					122
        visible					1
        enabled					1
        navUp                   MissionButton3
        navLeft                 MissionButton6
        navRight                MissionButton8
        navDown                 MissionButton10
        rui                     "ui/mission_button.rpak"
    }

    MissionButton8
    {
        ControlName				RuiButton
		classname				ComicPageSelect
        pin_to_sibling			MissionButton4
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT
        xpos					-61
        ypos					4
        wide					122
        tall					122
        visible					1
        enabled					1
        navUp                   MissionButton4
        navLeft                 MissionButton7
        navRight                MissionButton9
        navDown                 RewardButton0
        rui                     "ui/mission_button.rpak"
    }

    MissionButton9
    {
        ControlName				RuiButton
		classname				ComicPageSelect
        pin_to_sibling			MissionButton8
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_RIGHT
        xpos					4
        ypos					0
        wide					122
        tall					122
        visible					1
        enabled					1
        navUp                   MissionButton5
        navLeft                 MissionButton8
        navRight                MissionButton10
        navDown                 RewardButton0
        rui                     "ui/mission_button.rpak"
    }
	MissionButton10
    {
        ControlName				RuiButton
        classname				ComicPageSelect
        pin_to_sibling			MissionButton9
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_RIGHT
        xpos					4
        ypos					0
        wide					122
        tall					122
        visible					1
        enabled					1
        navUp                   MissionButton6
        navLeft                 MissionButton9
        navDown                 CompletionRewardButton1
        rui                     "ui/mission_button.rpak"
    }
    ///////////////////
    // COMICS LOCKED //
    ///////////////////

                          
    LockedComicsPanel
    {
        ControlName				RuiPanel

        pin_to_sibling			MissionButton3
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_LEFT
        xpos					0
        ypos					-41
        wide					500
        tall					40
        visible					0
        rui				        "ui/quest_locked_comics_panel.rpak"
    }
      

    ///////////////////////////
    // FINAL MISSION REWARDS //
    ///////////////////////////

    CompletionRewardButton1
    {
        ControlName				RuiButton
		classname				CompletionReward
        pin_to_sibling			QuestInfoBox
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_LEFT
        xpos					-770 //-755
        ypos					-635
        wide					75
        tall					75
        visible					1
        enabled					1
        navRight                CompletionRewardButton2
        navUp                   PurchaseButton
        rui                     "ui/quest_reward_button.rpak"
        sound_focus             "UI_Menu_Focus_Small"
    }

    CompletionRewardButton2
    {
        ControlName				RuiButton
		classname				CompletionReward
        pin_to_sibling			CompletionRewardButton1
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_RIGHT
        xpos					5
        ypos					0
        wide					75
        tall					75
        visible					1
        enabled					1
        navLeft                 CompletionRewardButton1
        navRight                CompletionRewardButton3
        navUp                   PurchaseButton
        rui                     "ui/quest_reward_button.rpak"
        sound_focus             "UI_Menu_Focus_Small"
    }

    CompletionRewardButton3
    {
        ControlName				RuiButton
		classname				CompletionReward
        pin_to_sibling			CompletionRewardButton2
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_RIGHT
        xpos					5
        ypos					0
        wide					75
        tall					75
        visible					0
        enabled					1
        navLeft                 CompletionRewardButton2
        navUp                   PurchaseButton
        rui                     "ui/quest_reward_button.rpak"
        sound_focus             "UI_Menu_Focus_Small"
    }

    ///////////////////////////////
    // ARTIFACT PROGRESS BUTTONS //
    ///////////////////////////////


//    ArtifactButton0
//    {
//        ControlName				RuiButton
//		classname				ArtifactButton
//        pin_to_sibling			QuestInfoBox
//        pin_corner_to_sibling	BOTTOM_LEFT
//        pin_to_sibling_corner	BOTTOM_RIGHT
//        xpos					45
//        ypos					-8
//        wide					88
//        tall					88
//        visible					1
//        enabled					1
//        navLeft                 MissionButton9
//        navRight                ArtifactButton1
//        rui                     "ui/mission_button.rpak"
//        sound_focus             "UI_Menu_Focus_Small"
//    }
//
//    ArtifactButton1
//    {
//        ControlName				RuiButton
//		classname				ArtifactButton
//        pin_to_sibling			ArtifactButton0
//        pin_corner_to_sibling	TOP_LEFT
//        pin_to_sibling_corner	TOP_RIGHT
//        xpos					8
//        ypos					0
//        wide					88
//        tall					88
//        visible					1
//        enabled					1
//        navLeft                 ArtifactButton0
//        navRight                ArtifactButton2
//        rui                     "ui/mission_button.rpak"
//        sound_focus             "UI_Menu_Focus_Small"
//    }
//
//    ArtifactButton2
//    {
//        ControlName				RuiButton
//		classname				ArtifactButton
//        pin_to_sibling			ArtifactButton1
//        pin_corner_to_sibling	TOP_LEFT
//        pin_to_sibling_corner	TOP_RIGHT
//        xpos					8
//        ypos					0
//        wide					88
//        tall					88
//        visible					1
//        enabled					1
//        navLeft                 ArtifactButton1
//        navRight                ArtifactButton3
//        rui                     "ui/mission_button.rpak"
//        sound_focus             "UI_Menu_Focus_Small"
//    }
//
//    ArtifactButton3
//    {
//        ControlName				RuiButton
//		classname				ArtifactButton
//        pin_to_sibling			ArtifactButton2
//        pin_corner_to_sibling	TOP_LEFT
//        pin_to_sibling_corner	TOP_RIGHT
//        xpos					8
//        ypos					0
//        wide					88
//        tall					88
//        visible					1
//        enabled					1
//        navLeft                 ArtifactButton2
//        navRight                ArtifactButton4
//        rui                     "ui/mission_button.rpak"
//        sound_focus             "UI_Menu_Focus_Small"
//    }
//
//    ArtifactButton4
//    {
//        ControlName				RuiButton
//		classname				ArtifactButton
//        pin_to_sibling			ArtifactButton3
//        pin_corner_to_sibling	TOP_LEFT
//        pin_to_sibling_corner	TOP_RIGHT
//        xpos					8
//        ypos					0
//        wide					88
//        tall					88
//        visible					1
//        enabled					1
//        navLeft                 ArtifactButton3
//        navRight                ArtifactButton5
//        rui                     "ui/mission_button.rpak"
//        sound_focus             "UI_Menu_Focus_Small"
//   }
//
//    ArtifactButton5
//    {
//        ControlName				RuiButton
//		classname				ArtifactButton
//        pin_to_sibling			ArtifactButton4
//        pin_corner_to_sibling	TOP_LEFT
//        pin_to_sibling_corner	TOP_RIGHT
//        xpos					8
//        ypos					0
//        wide					88
//        tall					88
//        visible					1
//        enabled					1
//        navLeft                 ArtifactButton4
//        navRight                ArtifactButton6
//        rui                     "ui/mission_button.rpak"
//        sound_focus             "UI_Menu_Focus_Small"
//    }
//
//    ArtifactButton6
//    {
//        ControlName				RuiButton
//		classname				ArtifactButton
//        pin_to_sibling			ArtifactButton5
//        pin_corner_to_sibling	TOP_LEFT
//        pin_to_sibling_corner	TOP_RIGHT
//        xpos					8
//        ypos					0
//        wide					88
//        tall					88
//        visible					1
//        enabled					1
//        navLeft                 ArtifactButton5
//        navRight                ArtifactButton7
//        rui                     "ui/mission_button.rpak"
//        sound_focus             "UI_Menu_Focus_Small"
//    }
//
//    ArtifactButton7
//    {
//        ControlName				RuiButton
//		classname				ArtifactButton
//        pin_to_sibling			ArtifactButton6
//        pin_corner_to_sibling	TOP_LEFT
//        pin_to_sibling_corner	TOP_RIGHT
//        xpos					8
//        ypos					0
//        wide					88
//        tall					88
//        visible					1
//        enabled					1
//        navLeft                 ArtifactButton6
//        navRight                ArtifactButton8
//        rui                     "ui/mission_button.rpak"
//        sound_focus             "UI_Menu_Focus_Small"
//    }
//
//    ArtifactButton8
//    {
//        ControlName				RuiButton
//		classname				ArtifactButton
//        pin_to_sibling			ArtifactButton7
//        pin_corner_to_sibling	TOP_LEFT
//        pin_to_sibling_corner	TOP_RIGHT
//        xpos					8
//        ypos					0
//        wide					88
//        tall					88
//        visible					1
//        enabled					1
//        navLeft                 ArtifactButton7
//        rui                     "ui/mission_button.rpak"
//        sound_focus             "UI_Menu_Focus_Small"
//    }


     ///////////////////
    // MODEL PREVIEW //
    ///////////////////

    ModelRotateMouseCapture
    {
        ControlName				CMouseMovementCapturePanel
        xpos                    0
        ypos					0
        zpos                    0
        wide                    780
        tall                    630

        pin_to_sibling			QuestInfoBox
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	TOP_RIGHT

    }


    ///////////////////
    //  DEBUG STUFF  //
    ///////////////////

   	debugText0
	{
		ControlName				Label
		auto_wide_tocontents	1
		tall					17
		visible					1
		labelText				""
		font					Default_19_DropShadow

        xpos					1000
        ypos					150
        zpos					30
	}
	debugText1
	{
		ControlName				Label
		auto_wide_tocontents	1
		tall					17
		visible					1
		labelText				""
		font					Default_19_DropShadow
        zpos					30
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT
        pin_to_sibling			debugText0
	}
	debugText2
	{
		ControlName				Label
		auto_wide_tocontents	1
		tall					17
		visible					1
		labelText				""
		font					Default_19_DropShadow
        zpos					30
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT
        pin_to_sibling			debugText1
	}
	debugText3
	{
		ControlName				Label
		auto_wide_tocontents	1
		tall					17
		visible					1
		labelText				""
		font					Default_19_DropShadow
        zpos					30
        pin_corner_to_sibling	TOP_LEFT
        pin_to_sibling_corner	BOTTOM_LEFT
        pin_to_sibling			debugText2
	}
}
