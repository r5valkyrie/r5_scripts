global function ControlGunRackPanels_Init

global const string CONTROLGUNRACKPANEL_CLASS_NAME = "control_gun_rack_panel"
const float CONTROLGUNRACKPANEL_INTERACT_DURATION = 1.0

#if SERVER
global const asset CONTROLGUNRACKPANEL_MODEL = $"mdl/communication/terminal_usable_imc_01.rmdl"
#endif // SERVER

#if CLIENT
const string CONTROLGUNRACKPANEL_USE_LOOP_SOUND = "survival_titan_linking_loop"
const string CONTROLGUNRACKPANEL_USE_SUCCESS_SOUND = "ui_menu_store_purchase_success"
const string CONTROLGUNRACKPANEL_USE_FAIL_SOUND = "menu_deny"
const asset GUNRACKPANEL_MAP_ICON = $"rui/menu/buttons/battlepass/weapon_skin"
#endif // CLIENT

struct
{
#if SERVER
	array<entity> allGunRackPanels
#endif // SERVER
	table <entity, int> gunRackPanelToLootTierTable
} file

void function ControlGunRackPanels_Init()
{
	if ( !GameMode_IsActive( eGameModes.CONTROL ) || !GetCurrentPlaylistVarBool( "control_enable_gunracks", false ) || GetCurrentPlaylistVarBool( "control_gunracks_self_replenish", false ) || GetCurrentPlaylistVarBool( "control_gunracks_reset_all_group_loot_on_pickup", false ) )
	{
		#if SERVER
			BlockMapEntityParseCreationOf( "prop_dynamic", "", CONTROLGUNRACKPANEL_CLASS_NAME )
		#endif // SERVER
		return
	}

	#if SERVER
		PrecacheModel( CONTROLGUNRACKPANEL_MODEL )
		AddSpawnCallbackEditorClass( "prop_dynamic", CONTROLGUNRACKPANEL_CLASS_NAME, OnControlGunRackPanelSpawned )
		AddCallback_EntitiesDidLoad( OnEntitiesDidLoad )
	#endif // SERVER

	#if CLIENT
		AddCreateCallback( "prop_dynamic", OnControlGunRackPanelSpawned )
		RegisterSignal( "ControlGunRackPanels_ExtendedUseSuccess" )
	#endif // CLIENT
}

#if SERVER
// Set use settings for each panel once they are loaded in
void function OnEntitiesDidLoad()
{
	//INTERACTION PANEL
	foreach ( entity gunRackPanel in file.allGunRackPanels )
	{
		string instName = gunRackPanel.GetInstanceName()

		gunRackPanel.SetUsable()
		gunRackPanel.SetUsablePriority( USABLE_PRIORITY_MEDIUM )
		gunRackPanel.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER | USABLE_BY_PILOTS | USABLE_BY_ENEMIES )
		AddCallback_OnUseEntity_ClientServer( gunRackPanel, ControlGunRackPanels_OnUse )
		SetCallback_CanUseEntityCallback( gunRackPanel, ControlGunRackPanels_CanUse )
	}
}
#endif // SERVER

// Set initial settings and callbacks for each panel when it spawns
void function OnControlGunRackPanelSpawned( entity gunRackPanel )
{
	if ( gunRackPanel.GetScriptName() != CONTROLGUNRACKPANEL_CLASS_NAME )
		return

	int lootTier = GetCurrentPlaylistVarInt( "control_gunrack_starting_tier", 0 )
	file.gunRackPanelToLootTierTable[ gunRackPanel ] <- lootTier

	#if SERVER
		file.allGunRackPanels.append( gunRackPanel )
	#endif // SERVER


	#if CLIENT
		AddCallback_OnUseEntity_ClientServer( gunRackPanel, ControlGunRackPanels_OnUse )
		SetCallback_CanUseEntityCallback( gunRackPanel, ControlGunRackPanels_CanUse )
		AddEntityCallback_GetUseEntOverrideText( gunRackPanel, ControlGunRackPanels_UseTextOverride )
		thread ControlGunRackPanels_CreateMapIcon_Thread( gunRackPanel, lootTier )
	#endif // CLIENT
}

#if SERVER
// Get the Gun Rack group that this panel affects
int function ControlGunRackPanels_GetPanelTargetGunRackGroup( entity gunRackPanel )
{
	int targetGunRackGroup = 0
	if ( gunRackPanel.HasKey( "targetGunRackGroup" ) )
	{
		targetGunRackGroup = int( gunRackPanel.GetValueForKey( "targetGunRackGroup" ) )
	}
	else
	{
		printt( "Running ControlGunRackPanels_GetPanelTargetGunRackGroup, but gunRackPanel does NOT have the targetGunRackGroup key" )
		Warning( "Running ControlGunRackPanels_GetPanelTargetGunRackGroup, but gunRackPanel does NOT have the targetGunRackGroup key" )
	}

	return targetGunRackGroup
}
#endif // SERVER

// Return whether the panel is usable
bool function ControlGunRackPanels_CanUse( entity player, entity gunRackPanel, int useFlags)
{
	if ( !SURVIVAL_PlayerCanUse_AnimatedInteraction( player, gunRackPanel ) )
		return false

	return true
}

#if CLIENT
// Determine what interact text to display based on the tier and availability of the panel
string function ControlGunRackPanels_UseTextOverride( entity gunRackPanel )
{
	string useText = ""

	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) || !IsValid( gunRackPanel ) )
		return useText

	if ( GradeFlagsHas( gunRackPanel, eGradeFlags.IS_LOCKED ) )
		return Localize( "#CONTROL_GUNRACKS_PANEL_ONCOOLDOWN", ControlGunRacks_GetCoolDownDuration() )

	int lootTier = file.gunRackPanelToLootTierTable[ gunRackPanel ]
	int useCost = ControlGunRackPanels_GetCost( gunRackPanel )

	if ( lootTier == 0 )
	{
		if ( ControlGunRackPanels_CostCheck( gunRackPanel, player ) )
		{
			useText = Localize( "#CONTROL_GUNRACKS_ACTIVATE", useCost )
		}
		else
		{
			useText = Localize( "#CONTROL_GUNRACKS_TOOEXPENSIVE_ACTIVATE", useCost )
		}
	}
	else if ( lootTier >= CONTROL_MAX_LOOT_TIER )
	{
		if ( ControlGunRackPanels_CostCheck( gunRackPanel, player ) )
		{
			useText = Localize( "#CONTROL_GUNRACKS_REFRESH", useCost )
		}
		else
		{
			useText = Localize( "#CONTROL_GUNRACKS_TOOEXPENSIVE_REFRESH", useCost )
		}
	}
	else
	{
		if ( ControlGunRackPanels_CostCheck( gunRackPanel, player ) )
		{
			useText = Localize( "#CONTROL_GUNRACKS_UPGRADE", useCost )
		}
		else
		{
			useText = Localize( "#CONTROL_GUNRACKS_TOOEXPENSIVE_UPGRADE", useCost )
		}
	}

	return useText
}
#endif //CLIENT

//On Panel use, initial press. Determine if the player can use the panel based on cost and player EXP
void function ControlGunRackPanels_OnUse( entity gunRackPanel, entity player, int useInputFlags )
{
	if( ControlGunRackPanels_CostCheck( gunRackPanel, player ) && !GradeFlagsHas( gunRackPanel, eGradeFlags.IS_LOCKED ) )
	{
		if ( IsBitFlagSet( useInputFlags, USE_INPUT_LONG ) )
			thread ControlGunRackPanels_UseThink_Thread( gunRackPanel, player )
	}
	else
	{
		#if CLIENT
			EmitSoundOnEntity( player, CONTROLGUNRACKPANEL_USE_FAIL_SOUND )
		#endif //CLIENT
	}
}

// Check if the player can afford to use the GunRack Panel
bool function ControlGunRackPanels_CostCheck( entity gunRackPanel, entity player )
{
	if( Control_GetPlayerExpTotal( player ) >= ControlGunRackPanels_GetCost( gunRackPanel ) )
	{
		return true
	}

	return false
}

// Get the cost to use the panel based on its current tier
int function ControlGunRackPanels_GetCost( entity gunRackPanel )
{
	int cost = 0
	int nextLootTier = file.gunRackPanelToLootTierTable[ gunRackPanel ] + 1

	if ( nextLootTier <= CONTROL_MAX_LOOT_TIER )
	{
		cost = GetCurrentPlaylistVarInt( "control_gunrack_exp_cost_tier" + nextLootTier, 0 )
	}
	else
	{
		cost = GetCurrentPlaylistVarInt( "control_gunrack_exp_cost_refresh", 0 )
	}

	return cost
}

// Display custom text and play sounds until the hold interaction is completed
void function ControlGunRackPanels_UseThink_Thread( entity gunRackPanel, entity playerUser )
{
	ExtendedUseSettings settings
	settings.duration = CONTROLGUNRACKPANEL_INTERACT_DURATION
	settings.successFunc = ControlGunRackPanels_ExtendedUseSuccess

	#if CLIENT
		string useText = ""
		int lootTier = file.gunRackPanelToLootTierTable[ gunRackPanel ]

		if ( lootTier == 0 )
		{
			useText = Localize( "#CONTROL_GUNRACKS_ACTIVATING" )
		}
		else if ( lootTier >= CONTROL_MAX_LOOT_TIER )
		{
			useText = Localize( "#CONTROL_GUNRACKS_REFRESHING" )
		}
		else
		{
			useText = Localize( "#CONTROL_GUNRACKS_UPGRADING", ( lootTier + 1 ) )
		}

		settings.icon = $""
		settings.hint = useText
		settings.displayRui = $"ui/extended_use_hint.rpak"
		settings.displayRuiFunc = ControlGunRackPanels_DisplayRui
		settings.loopSound = CONTROLGUNRACKPANEL_USE_LOOP_SOUND
		settings.successSound = CONTROLGUNRACKPANEL_USE_SUCCESS_SOUND
	#endif //CLIENT

	gunRackPanel.EndSignal( "OnDestroy" )
	playerUser.EndSignal( "OnDeath" )

	waitthread ExtendedUse( gunRackPanel, playerUser, settings )
}

// Display the interact prompt with custom text for the client
#if CLIENT
void function ControlGunRackPanels_DisplayRui( entity ent, entity player, var rui, ExtendedUseSettings settings )
{
	RuiSetString( rui, "holdButtonHint", settings.holdHint )
	RuiSetString( rui, "hintText", settings.hint )
	RuiSetGameTime( rui, "startTime", Time() )
	RuiSetGameTime( rui, "endTime", Time() + settings.duration )
}
#endif //CLIENT

// When the panel is used, upgrade and respawn weapons on the associated gun racks and put the panel into a cooldown until all the weapons are spawned
void function ControlGunRackPanels_ExtendedUseSuccess( entity gunRackPanel, entity player, ExtendedUseSettings settings )
{
	#if SERVER
		thread ControlGunRackPanels_StartCooldown_Thread( gunRackPanel )
	#endif //SERVER

	int lootTier = file.gunRackPanelToLootTierTable[ gunRackPanel ]
	int newLootTier = minint( lootTier + 1, CONTROL_MAX_LOOT_TIER )

	#if SERVER
		int useCost = ControlGunRackPanels_GetCost( gunRackPanel )
		Control_SubtractExp( player, useCost, CONTROL_EXPEVENT_GUNRACK_PURCHASE )
		int targetGunRackGroup = ControlGunRackPanels_GetPanelTargetGunRackGroup( gunRackPanel )
		ControlGunRacks_SetLootTierForGunRackGroup( targetGunRackGroup, newLootTier )
		array <string> playerWeaponRefs = ControlGunRackPanels_GetPlayerWeaponRefsArray( player )
		ControlGunRacks_ResetGunRackLootOnAllGunRacksInGroup( targetGunRackGroup, player, ControlGunRackPanels_GetWeaponRefsAtTier( playerWeaponRefs, newLootTier ) )
	#endif //SERVER

	#if CLIENT
		gunRackPanel.Signal( "ControlGunRackPanels_ExtendedUseSuccess" )
		thread ControlGunRackPanels_CreateMapIcon_Thread( gunRackPanel, newLootTier )
	#endif //CLIENT
	file.gunRackPanelToLootTierTable[ gunRackPanel ] = newLootTier
}

#if SERVER
// return an array of base weapon refs based on the weapons the player has equipped
array<string> function ControlGunRackPanels_GetPlayerWeaponRefsArray( entity player )
{
	array<string> playerWeaponRefs = []
	if ( IsValid( player ) )
	{
		entity primaryWeapon = SURVIVAL_GetLastActiveWeapon( player )
		entity secondaryWeapon = GetOtherWeapon( primaryWeapon, player )
		LootData primaryWeaponData = SURVIVAL_GetLootDataFromWeapon( primaryWeapon )
		LootData secondaryWeaponData = SURVIVAL_GetLootDataFromWeapon( secondaryWeapon )
		string activePrimaryWeaponRef = primaryWeaponData.baseWeapon
		string activeSecondaryWeaponRef = secondaryWeaponData.baseWeapon
		bool isActivePrimaryCrateWeapon = ( primaryWeaponData.tier == eLootTier.MYTHIC )
		bool isActiveSecondaryCrateWeapon = ( secondaryWeaponData.tier == eLootTier.MYTHIC )

		if ( !isActivePrimaryCrateWeapon && SURVIVAL_Loot_IsRefValid( activePrimaryWeaponRef ) )
			playerWeaponRefs.append( activePrimaryWeaponRef )

		if ( !isActiveSecondaryCrateWeapon && SURVIVAL_Loot_IsRefValid( activeSecondaryWeaponRef ) )
			playerWeaponRefs.append( activeSecondaryWeaponRef )
	}
	return playerWeaponRefs
}

// Take in an array of base weapon refs, return an array of the same weapon refs but kitted to the current tier
array<string> function ControlGunRackPanels_GetWeaponRefsAtTier( array<string> baseWeaponRefs, int weaponTier )
{
	if ( baseWeaponRefs.len() <= 0 )
		return baseWeaponRefs

	array<string> atTierWeaponRefs
	string weaponSet = ""
	switch ( weaponTier )
	{
		case 1:
			weaponSet = "_whiteset"
			break
		case 2:
			weaponSet = "_blueset"
			break
		case 3:
			weaponSet = "_purpleset"
			break
		case 4:
			weaponSet = "_gold"
			break
		default:
			weaponSet = ""
			break
	}

	string atTierWeaponRef
	foreach ( baseWeaponRef in baseWeaponRefs )
	{
		atTierWeaponRef = baseWeaponRef + weaponSet
		atTierWeaponRefs.append( atTierWeaponRef )
	}

	return atTierWeaponRefs
}


// Put the panel into a cooldown so it can't be used until all the weapons in the gun rack group have respawned
void function ControlGunRackPanels_StartCooldown_Thread( entity gunRackPanel )
{
	GradeFlagsSet( gunRackPanel, eGradeFlags.IS_LOCKED )
	OnThreadEnd(
		function() : ( gunRackPanel )
		{
			GradeFlagsClear( gunRackPanel, eGradeFlags.IS_LOCKED )
		}
	)

	int targetGunRackGroup = ControlGunRackPanels_GetPanelTargetGunRackGroup( gunRackPanel )

	wait ControlGunRacks_GetCoolDownDuration()
}
#endif //SERVER

#if CLIENT
// Create a map and minimap icon for the panel that shows its current tier
void function ControlGunRackPanels_CreateMapIcon_Thread( entity gunRackPanel, int lootTier )
{
	FlagWait( "EntitiesDidLoad" )
	entity player = GetLocalViewPlayer()
	if ( !IsValid( player ) || !IsValid( gunRackPanel ) )
		return

	player.EndSignal( "OnDestroy" )
	gunRackPanel.EndSignal( "OnDestroy" )
	gunRackPanel.EndSignal( "ControlGunRackPanels_ExtendedUseSuccess" )

	int iconColorID
	switch( lootTier )
	{
		case 0:
			iconColorID = COLORID_HUD_LOOT_TIER0
			break
		case 1:
			iconColorID = COLORID_HUD_LOOT_TIER1
			break
		case 2:
			iconColorID = COLORID_HUD_LOOT_TIER2
			break
		case 3:
			iconColorID = COLORID_HUD_LOOT_TIER3
			break
		case 4:
			iconColorID = COLORID_HUD_LOOT_TIER4
			break
		default:
			iconColorID = COLORID_HUD_LOOT_TIER0
			break
	}

	vector iconColor = GetKeyColor( iconColorID ) * ( 1.0 / 255.0 )
	var minimapRui = Minimap_AddIconAtPosition( gunRackPanel.GetOrigin(), <0,90,0>, GUNRACKPANEL_MAP_ICON, 1.0, iconColor )
	var fullmapRui = FullMap_AddIconAtPos( gunRackPanel.GetOrigin(), <0,0,0>, GUNRACKPANEL_MAP_ICON, 7.0, iconColor )

	OnThreadEnd(
		function() : ( minimapRui, fullmapRui )
		{
			Minimap_CommonCleanup( minimapRui )
			Fullmap_RemoveRui( fullmapRui )
			RuiDestroy( fullmapRui )
		}
	)

	WaitForever()
}
#endif //CLIENT 
 