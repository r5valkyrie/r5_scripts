"resource/ui/menus/panels/quest_rewards.res"
{
	////////////////////
	// REWARD BUTTONS //
	////////////////////

	RewardButton0
	{
		ControlName				RuiButton
		classname				RewardButton
		xpos					562
		ypos				    467

		navUp                   MissionButton0
		navRight                RewardButton1
		navDown                 PurchaseButton

		wide					88
		tall					88
		visible					1
		enabled					1
		rui					    "ui/quest_reward_button.rpak"
		clipRui					1
		clip                    1

		cursorVelocityModifier  0.7
		sound_focus             "UI_Menu_Focus_Small"
		rightClickEvents		0
		doubleClickEvents       0
	}

	RewardButton1
	{
		ControlName				RuiButton
		classname				RewardButton
		pin_to_sibling			RewardButton0
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_RIGHT
		xpos					8
		ypos					0

		navUp                   MissionButton0
		navLeft                 RewardButton0
		navRight                RewardButton2
		navDown                 PurchaseButton

		wide					88
		tall					88
		visible					1
		enabled					1
		rui					    "ui/quest_reward_button.rpak"
		clipRui					1
		clip                    1

		cursorVelocityModifier  0.7
		sound_focus             "UI_Menu_Focus_Small"
		rightClickEvents		0
		doubleClickEvents       0
	}

	RewardButton2
	{
		ControlName				RuiButton
		classname				RewardButton
		pin_to_sibling			RewardButton1
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_RIGHT
		xpos					8
		ypos					0

		navUp                   MissionButton0
		navLeft                 RewardButton1
		navRight                RewardButton3
		navDown                 PurchaseButton

		wide					88
		tall					88
		visible					1
		enabled					1
		rui					    "ui/quest_reward_button.rpak"
		clipRui					1
		clip                    1

		cursorVelocityModifier  0.7
		sound_focus             "UI_Menu_Focus_Small"
		rightClickEvents		0
		doubleClickEvents       0
	}

	RewardButton3
	{
		ControlName				RuiButton
		classname				RewardButton
		pin_to_sibling			RewardButton2
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_RIGHT
		xpos					8
		ypos					0

		navUp                   MissionButton0
		navLeft                 RewardButton2
		navRight                RewardButton4
		navDown                 PurchaseButton

		wide					88
		tall					88
		visible					1
		enabled					1
		rui					    "ui/quest_reward_button.rpak"
		clipRui					1
		clip                    1

		cursorVelocityModifier  0.7
		sound_focus             "UI_Menu_Focus_Small"
		rightClickEvents		0
		doubleClickEvents       0
	}

	RewardButton4
	{
		ControlName				RuiButton
		classname				RewardButton
		pin_to_sibling			RewardButton3
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_RIGHT
		xpos					8
		ypos					0

		navUp                   MissionButton0
		navLeft                 RewardButton3
		navRight                RewardButton5
		navDown                 PurchaseButton

		wide					88
		tall					88
		visible					1
		enabled					1
		rui					    "ui/quest_reward_button.rpak"
		clipRui					1
		clip                    1

		cursorVelocityModifier  0.7
		sound_focus             "UI_Menu_Focus_Small"
		rightClickEvents		0
		doubleClickEvents       0
	}

	RewardButton5
	{
		ControlName				RuiButton
		classname				RewardButton
		pin_to_sibling			RewardButton4
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_RIGHT
		xpos					8
		ypos					0

		navUp                   MissionButton0
		navLeft                 RewardButton4
		navRight                RewardButton6
		navDown                 PurchaseButton

		wide					88
		tall					88
		visible					1
		enabled					1
		rui					    "ui/quest_reward_button.rpak"
		clipRui					1
		clip                    1

		cursorVelocityModifier  0.7
		sound_focus             "UI_Menu_Focus_Small"
		rightClickEvents		0
		doubleClickEvents       0
	}

	RewardButton6
	{
		ControlName				RuiButton
		classname				RewardButton
		pin_to_sibling			RewardButton5
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_RIGHT
		xpos					8
		ypos					0

		navUp                   MissionButton0
		navLeft                 RewardButton5
		navRight                RewardButton7
		navDown                 PurchaseButton

		wide					88
		tall					88
		visible					1
		enabled					1
		rui					    "ui/quest_reward_button.rpak"
		clipRui					1
		clip                    1

		cursorVelocityModifier  0.7
		sound_focus             "UI_Menu_Focus_Small"
		rightClickEvents		0
		doubleClickEvents       0
	}

	RewardButton7
	{
		ControlName				RuiButton
		classname				RewardButton
		pin_to_sibling			RewardButton6
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_RIGHT
		xpos					8
		ypos					0

		navUp                   MissionButton0
		navLeft                 RewardButton6
		navDown                 PurchaseButton

		wide					88
		tall					88
		visible					1
		enabled					1
		rui					    "ui/quest_reward_button.rpak"
		clipRui					1
		clip                    1

		cursorVelocityModifier  0.7
		sound_focus             "UI_Menu_Focus_Small"
		rightClickEvents		0
		doubleClickEvents       0
	}

	RewardButton8 // Peeking button (clipped to the size of QuestInfoBox)
	{
		ControlName				RuiButton
		classname				RewardButton
		pin_to_sibling			RewardButton7
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	TOP_RIGHT
		xpos					8
		ypos					0

		wide					88
		tall					88
		visible					1
		enabled					1
		rui					    "ui/quest_reward_button.rpak"
		clipRui					1
		clip                    1

		cursorVelocityModifier  0.7
		sound_focus             "UI_Menu_Focus_Small"
		rightClickEvents		0
		doubleClickEvents       0
	}

	///////////////////////
	//  PURCHASE BUTTON  //
	///////////////////////

	PurchaseButton
	{
		ControlName			    RuiButton
		classname               "MenuButton"
		labelText               ""
		xpos				    0
		ypos				    12
		wide				    160
		tall				    50
		visible                 1
		scriptID                0
		rui					    "ui/quest_buy_box_button.rpak" // store_inspect_purchase_button
		sound_focus             "UI_Menu_Focus_Large"
		cursorVelocityModifier  0.7
		proportionalToParent	1
		pin_to_sibling			RewardButton7
		pin_corner_to_sibling	TOP_RIGHT
		pin_to_sibling_corner	BOTTOM_RIGHT

		navUp                   RewardButton0
		navDown                 CompletionRewardButton1
	}
}