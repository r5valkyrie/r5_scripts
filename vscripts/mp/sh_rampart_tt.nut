global function Rampart_TT_Init
global function Rampart_TT_RegisterNetworking
global function IsRampartTTPanelLocked
global function GetRampartTTPanelForLoot
global function CheckRampartTTMuralLegends
global function IsRampartTTEnabled


#if SERVER
global function MaybeActivateRampartTTDefense_Thread
global function GetRampartTTAssetsToPrecache
#endif // SERVER

#if CLIENT
global function ServertoClientCallback_VendingMachineTimerDone
global function ServertoClientCallback_PlayerUsedVendingMachine
global function ServertoClientCallback_VendingMachineInUse
global function ServertoClientCallback_RampartTT_SetCustomSpeakerIdx
global function ServertoClientCallback_RampartTT_BroadcastSystemPlay
#endif

//VENDING MACHINES-----//
global const string VEND_PANEL = "rampart_tt_vend_panel"
const string VEND_WEAPON_TARGET = "rampart_tt_vend_weapon_target"
const string VEND_SHIELD = "rampart_tt_vend_shield"
const string VEND_BLOCKER_VOLUME = "rampart_tt_vend_blocker"
const string VEND_SHIELD_AMBGENERIC = "rampart_tt_vend_shield_ambGen"
const string VEND_INST_BLUE = "rampart_tt_vend_blue"
const string VEND_INST_PURPLE = "rampart_tt_vend_purple"
const string VEND_INST_GOLD = "rampart_tt_vend_gold"
const string VEND_LOOT_TABLE_BLUE = "rampart_tt_blue_weapons"
const string VEND_LOOT_TABLE_PURPLE = "rampart_tt_purple_weapons"
const string VEND_LOOT_TABLE_GOLD = "rampart_tt_gold_weapons"
global const string VEND_SPAWNED_WEAPON =  "rampart_tt_vend_spawnedWeapon"
const string VEND_SPAWNED_AMMO =  "rampart_tt_vend_spawnedAmmo"
const float DISTANCE_PANEL_TO_LOOT_SQR = 3500
const string ALARM_SFX_POSITION = "rampart_tt_alarm_sfx_pos"
const string ALARM_VFX_POSITION = "rampart_tt_alarm_vfx_pos"
const float VEND_PICKUP_GRACE_PERIOD = 5.0


const string SFX_ALARM = "Loba_Ultimate_Staff_VaultAlarm"
const string SFX_PANEL_DENY = "menu_deny"
const string SFX_PANEL_SUCCESS = "ui_menu_store_purchase_success"
const string SFX_PANEL_LOOP = "survival_titan_linking_loop"
const string SFX_PANEL_SPEAKER = "diag_mp_rampart_tt_vendMachine"
const string SFX_VEND_POWERDOWN = "VendingMachine_Shield_PowerDown"
const string SFX_VEND_SUSTAIN = "VendingMachine_Shield_Sustain"

//rui tracking
const int RUI_TRACK_INDEX_CAPTURE_END_TIME = 0 //gametime
const int RUI_TRACK_INDEX_REQUIRED_TIME = 1 //float
const int RUI_TRACK_INDEX_ACTIVATOR_TEAM = 4 //int
const int RUI_TRACK_INDEX_COLOR = 0 //float3
const vector BIGMAUDE_DISPENSER_CRAFTING_COLOR = < 165, 255, 243 > / 255.0
const asset BIGMAUDE_DISPENSER_CRAFTING_ICON_ASSET = $"rui/hud/gametype_icons/survival/item_bigmaude_timer"
const asset BIGMAUDE_DISPENSER_FILL_BG_ICON_ASSET = $"rui/hud/gametype_icons/survival/obj_background_bigmaude_crafting"
const asset BIGMAUDE_DISPENSER_FILL_ICON_ASSET = $"rui/hud/gametype_icons/survival/obj_background_bigmaude_crafting_fill"

//SFX
const asset RAMPART_TT_CSV_DIALOGUE = $"datatable/dialogue/desertlands_rampart_tt_dialogue.rpak"
const float BIG_MAUDE_AUDIO_RADIUS = 7500.0
const string SFX_WELCOME = "diag_mp_rampart_tt_vendMachineWelcome_3p"
const string SFX_PANEL_PLAYER_ALREADY_PURCHASED = "diag_mp_rampart_tt_vendMachineWeaponClaimed_3p"
const string SFX_VEND_DONE = "VendingMachine_VendComplete_Shop"
const string SFX_VEND_DONE_POI_WIDE = "VendingMachine_VendComplete_Broadcast"
const array <string> SFX_RAMPART_VO_PURCHASE = [ "diag_mp_rampart_tt_vendMachine_07",
												"diag_mp_rampart_tt_vendMachine_08",
												"diag_mp_rampart_tt_vendMachine_09",
												"diag_mp_rampart_tt_vendMachine_10",
												"diag_mp_rampart_tt_vendMachine_11",
												"diag_mp_rampart_tt_vendMachine_12",
												"diag_mp_rampart_tt_vendMachine_13",
												"diag_mp_rampart_tt_vendMachine_14",
												"diag_mp_rampart_tt_vendMachine_15",
												"diag_mp_rampart_tt_vendMachine_19",
												"diag_mp_rampart_tt_vendMachine_20",
												"diag_mp_rampart_tt_vendMachine_21",
												"diag_mp_rampart_tt_vendMachine_22",
												"diag_mp_rampart_tt_vendMachine_23",
												"diag_mp_rampart_tt_vendMachine_24",
												"diag_mp_rampart_tt_vendMachine_25",
												"diag_mp_rampart_tt_vendMachine_26",
												"diag_mp_rampart_tt_vendMachine_27",
												"diag_mp_rampart_tt_vendMachine_28",
												"diag_mp_rampart_tt_vendMachine_29",
												"diag_mp_rampart_tt_vendMachine_30",
												"diag_mp_rampart_tt_vendMachine_31",
												"diag_mp_rampart_tt_vendMachine_32",
												"diag_mp_rampart_tt_vendMachine_33",
												"diag_mp_rampart_tt_vendMachine_34",
												"diag_mp_rampart_tt_vendMachine_35",
												"diag_mp_rampart_tt_vendMachine_36" ]

//VFX
const asset VFX_VEND_COMPLETE = $"P_Maude_Vending_Done"

const string VFX_SHIELD_DISABLE = "P_rampart_vendit_shield_disable"
const string VFX_ALARM_LIGHT = "P_vault_door_alarm_oly_mu1_sm"
const string VFX_ALARM_LIGHT_NAME = "rampart_tt_vfx_alarm_light"
const string MODEL_VEND_SHIELD = "mdl/desertlands/rampart_tt_vendit_01_energyfield_01.rmdl"

//LORE-----//
const string RAMPART_LORE_DATAPAD = "rampart_tt_datapad"
const array <string> SFX_DATAPAD_BANG = [ "diag_mp_bangalore_rtt_a1_1_3p", "diag_mp_bangalore_rtt_a1_2_3p", "diag_mp_bangalore_rtt_a1_3_3p" ]
const array <string> SFX_DATAPAD_BLISK = ["diag_mp_blisk_rtt_a1_1_3p", "diag_mp_blisk_rtt_a1_2_3p" ]
const array <string> SFX_DATAPAD_FRANCIS = [ "diag_mp_francis_rtt_a1_1_3p", "diag_mp_francis_rtt_a1_2_3p" ]
const array <string> SFX_DATAPAD_GIBRALTAR = [ "diag_mp_gibraltar_rtt_a1_1_3p", "diag_mp_gibraltar_rtt_a1_2_3p" ]
const array <string> SFX_DATAPAD_MIRAGE = [ "diag_mp_mirage_rtt_a1_1_3p", "diag_mp_mirage_rtt_a1_2_3p", "diag_mp_mirage_rtt_a1_3_3p" ]
const array <string> SFX_DATAPAD_SEER = [ "diag_mp_seer_rtt_a1_1_3p","diag_mp_seer_rtt_a1_2_3p" ]
const array <string> SFX_DATAPAD_VALK = [ "diag_mp_valkyrie_rtt_a1_1_3p","diag_mp_valkyrie_rtt_a1_2_3p","diag_mp_valkyrie_rtt_a1_3_3p" ]

const string RAMPART_LORE_MENSIGN = "rampart_tt_lore_mensign"
const string RAMPART_LORE_SHOPSIGN = "rampart_tt_lore_shopsign"
const string RAMPART_LORE_PORTRAIT = "rampart_tt_lore_portrait"
const string RAMPART_LORE_SISTER = "rampart_tt_lore_sister"

const string SFX_LORE_MENSIGN = "bc_mirage_rrtReactMSign"
const string SFX_LORE_SHOPSIGN = "bc_rampart_rrtReactSign"
const string SFX_LORE_PORTRAIT = "bc_rampart_rrtReactPortrait"
const string SFX_LORE_SISTER = "bc_rampart_rrtReactSister"

const array <string> RAMPART_TT_S10_MURAL_LEGENDS = [ "character_bloodhound",
													  "character_gibraltar",
													  "character_bangalore",
													  "character_caustic",
													  "character_lifeline",
													  "character_mirage",
													  "character_pathfinder",
													  "character_wraith",
													  "character_octane",
													  "character_wattson",
													  "character_crypto",
													  "character_revenant",
													  "character_loba",
													  "character_rampart",
													  "character_horizon",
													  "character_fuse",
													  "character_valkyrie",
													  "character_seer" ]
struct
{
	entity alarm_sfxPos
	bool alarmActive = false
	float alarmTime
	array < array <string> > datapadDialogue = []

	float vendPickupGracePeriod

	table<entity, bool> isVending
	table<entity, bool> hasPurchased
	table<entity, bool> hasEntered
	bool speakerOnCooldown
	bool welcomeOnCooldown

	int 	customQueueIdx
	#if CLIENT
	float 	rampartLineFinishedPlayingTime = -1.0
	array<entity> customSpeakers
	#endif
}file


//....................................
//.IIIII.NNNN...NNNN.IIIII.TTTTTTTTT..
//.IIIII.NNNNN..NNNN.IIIII.TTTTTTTTT..
//.IIIII.NNNNN..NNNN.IIIII.TTTTTTTTT..
//.IIIII.NNNNNN.NNNN.IIIII....TTTT....
//.IIIII.NNNNNN.NNNN.IIIII....TTTT....
//.IIIII.NNNNNNNNNNN.IIIII....TTTT....
//.IIIII.NNNNNNNNNNN.IIIII....TTTT....
//.IIIII.NNNNNNNNNNN.IIIII....TTTT....
//.IIIII.NNNNNNNNNNN.IIIII....TTTT....
//.IIIII.NNNN.NNNNNN.IIIII....TTTT....
//.IIIII.NNNN..NNNNN.IIIII....TTTT....
//.IIIII.NNNN..NNNNN.IIIII....TTTT....
//.IIIII.NNNN...NNNN.IIIII....TTTT....
//....................................
void function Rampart_TT_Init()
{
	if ( !IsRampartTTEnabled() )
		return

	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	#if SERVER
		AddCallback_OnPlayerRespawned( Rampart_TT_OnPlayerStateChanged )
		//AddCallback_OnClientConnectionLost( Rampart_TT_OnPlayerStateChanged )
		//AddCallback_OnClientConnectionRestored( Rampart_TT_OnPlayerStateChanged )

		file.customQueueIdx = RequestCustomDialogueQueueIndex()
		AddCallback_OnClientConnected( Rampart_TT_SpeakerSetupOnClientConnected )
		//AddCallback_OnClientConnectionRestored( Rampart_TT_SpeakerSetupOnClientConnected )
		RegisterSignal( "MaybeActivateRampartTTDefense_Thread" )

		file.vendPickupGracePeriod = GetCurrentPlaylistVarFloat( "crafting_pickup_grace_period", VEND_PICKUP_GRACE_PERIOD )
	#endif //SERVER

	#if CLIENT
		AddCreateCallback( "prop_dynamic", OnPanelCreated )
		AddCreateCallback( "prop_dynamic", OnLoreCreated )
		AddCreateCallback( PLAYER_WAYPOINT_CLASSNAME, SetupVendWaypoint )
	#endif // CLIENT
}

//ON ALL ENTITIES LOADED
void function EntitiesDidLoad()
{
	if ( !IsRampartTTEnabled() )
		return

	RegisterCSVDialogue( RAMPART_TT_CSV_DIALOGUE )

	#if SERVER
	PrecacheParticleSystem( VFX_VEND_COMPLETE )

	//ALARM SFX POSITIONS
	file.alarm_sfxPos = GetEntByScriptName( ALARM_SFX_POSITION )

	SetupVendPanels()
	SetupLoreEvents()
	SetUpWelcomeTrigger()

	//PLAYLIST DISABLE MACHINES
	if( !RampartHasStock() )
	{
		Vend_DisableAll()
	}
	#endif //SERVER
}

//DISABLES VENDING MACHINES FROM THE PLAYLIST
#if SERVER || CLIENT
bool function RampartHasStock()
{
	return GetCurrentPlaylistVarBool( "rampart_tt_stocked", true )
}

//CHECK IF THE TT EXISTS IN THE MAP
bool function IsRampartTTEnabled()
{
	if ( GetCurrentPlaylistVarBool( "rampart_tt_enabled", true ) )
	{
		if ( GetMapName() == "mp_rr_desertlands_mu3_tt"  )
			return true
	}

	return false
}
#endif //SERVER || CLIENT

void function Rampart_TT_RegisterNetworking()
{
	Remote_RegisterClientFunction( "ServertoClientCallback_VendingMachineTimerDone", "entity" )
	Remote_RegisterClientFunction( "ServertoClientCallback_PlayerUsedVendingMachine", "entity", "entity" )
	Remote_RegisterClientFunction( "ServertoClientCallback_VendingMachineInUse", "entity" )
	Remote_RegisterClientFunction( "ServertoClientCallback_RampartTT_SetCustomSpeakerIdx", "int", 0, NUM_TOTAL_DIALOGUE_QUEUES )
	Remote_RegisterClientFunction( "ServertoClientCallback_RampartTT_BroadcastSystemPlay", "int", -1, SFX_RAMPART_VO_PURCHASE.len() - 1, "bool" )
}




//.....................................................................................
//.VVVV....VVVVVEEEEEEEEEEE.NNNN...NNNN..DDDDDDDDD...DIIII.NNNN...NNNN.....GGGGGGG.....
//.VVVV....VVVV.EEEEEEEEEEE.NNNNN..NNNN..DDDDDDDDDD..DIIII.NNNNN..NNNN...GGGGGGGGGG....
//.VVVV....VVVV.EEEEEEEEEEE.NNNNN..NNNN..DDDDDDDDDDD.DIIII.NNNNN..NNNN..GGGGGGGGGGGG...
//.VVVVV..VVVV..EEEE........NNNNNN.NNNN..DDDD...DDDD.DIIII.NNNNNN.NNNN..GGGGG..GGGGG...
//..VVVV..VVVV..EEEE........NNNNNN.NNNN..DDDD....DDDDDIIII.NNNNNN.NNNN.NGGGG....GGG....
//..VVVV..VVVV..EEEEEEEEEE..NNNNNNNNNNN..DDDD....DDDDDIIII.NNNNNNNNNNN.NGGG............
//..VVVVVVVVV...EEEEEEEEEE..NNNNNNNNNNN..DDDD....DDDDDIIII.NNNNNNNNNNN.NGGG..GGGGGGGG..
//...VVVVVVVV...EEEEEEEEEE..NNNNNNNNNNN..DDDD....DDDDDIIII.NNNNNNNNNNN.NGGG..GGGGGGGG..
//...VVVVVVVV...EEEE........NNNNNNNNNNN..DDDD....DDDDDIIII.NNNNNNNNNNN.NGGGG.GGGGGGGG..
//...VVVVVVV....EEEE........NNNN.NNNNNN..DDDD...DDDDDDIIII.NNNN.NNNNNN..GGGGG....GGGG..
//....VVVVVV....EEEEEEEEEEE.NNNN..NNNNN..DDDDDDDDDDD.DIIII.NNNN..NNNNN..GGGGGGGGGGGG...
//....VVVVVV....EEEEEEEEEEE.NNNN..NNNNN..DDDDDDDDDD..DIIII.NNNN..NNNNN...GGGGGGGGGG....
//....VVVVV.....EEEEEEEEEEE.NNNN...NNNN..DDDDDDDDD...DIIII.NNNN...NNNN.....GGGGGGG.....
//.....................................................................................

#if SERVER
void function SetupVendPanels()
{
	//INTERACTION PANEL
	foreach ( entity panel in GetEntArrayByScriptName( VEND_PANEL ) )
	{
		//IF CRAFTING IS OFF, DISABLE VENDING MACHINES AND DESTROY BLOCKER
		{
			panel.SetSkin( 2 )
			Vend_DestroyBlocker( panel )
		}

	}
}
#endif //SERVER

#if CLIENT
void function OnPanelCreated( entity panel )
{
	if ( panel.GetScriptName() != VEND_PANEL )
		return

	AddCallback_OnUseEntity_ClientServer( panel, Vend_OnUse )
	SetCallback_CanUseEntityCallback( panel, Vend_CanUse )
	AddEntityCallback_GetUseEntOverrideText( panel, Vend_UseTextOverride )
}
#endif // CLIENT

bool function Vend_CanUse( entity player, entity panel, int useFlags)
{
	if ( !SURVIVAL_PlayerCanUse_AnimatedInteraction( player, panel ) )
		return false

	return true
}

#if CLIENT
string function Vend_UseTextOverride( entity panel )
{
	entity player = GetLocalViewPlayer()
	if ( !IsValid (player) )
	{
		return ""
	}

	string str = Localize( "#RAMPART_TT_BUY", Vend_GetCost( panel ) )
	return str
}
#endif //CLIENT

//ON USE INITIAL PRESS
void function Vend_OnUse( entity panel, entity player, int useInputFlags )
{
	if( Vend_CostCheck( panel, player ) )
	{
		if ( IsBitFlagSet( useInputFlags, USE_INPUT_LONG ) )
		{
			thread Vend_UseThink_Thread( panel, player )
		}
	}
	else
	{
		#if SERVER
		EmitSoundOnEntityOnlyToPlayer( panel, player, SFX_PANEL_DENY )
		#endif // SERVER
	}
}

//WHILE HOLDING USE
void function Vend_UseThink_Thread( entity ent, entity playerUser )
{

	ExtendedUseSettings settings
	settings.duration = 0.3

	#if SERVER
	settings.successFunc = Vend_ExtendedUseSuccess
	#endif //SERVER

	#if CLIENT || UI
	settings.icon = $""
	settings.hint = Localize( "#RAMPART_TT_BUYING" )

	settings.displayRui = $"ui/extended_use_hint.rpak"
	settings.displayRuiFunc = Vend_DisplayRui
	settings.loopSound = SFX_PANEL_LOOP
	#endif //CLIENT || UI

	ent.EndSignal( "OnDestroy" )
	playerUser.EndSignal( "OnDeath" )

	waitthread ExtendedUse( ent, playerUser, settings )
}

//DISPLAY UI
#if CLIENT || UI
void function Vend_DisplayRui( entity ent, entity player, var rui, ExtendedUseSettings settings )
{
	RuiSetString( rui, "holdButtonHint", settings.holdHint )
	RuiSetString( rui, "hintText", settings.hint )
	RuiSetGameTime( rui, "startTime", Time() )
	RuiSetGameTime( rui, "endTime", Time() + settings.duration )
}
#endif //CLIENT || UI

//ON USED
#if SERVER
void function Vend_ExtendedUseSuccess( entity panel, entity player, ExtendedUseSettings settings )
{
	int ammoCount
	foreach ( entity linkEnt in panel.GetLinkEntArray() )
	{
		if ( linkEnt.GetScriptName() == VEND_SPAWNED_WEAPON )
		{
			//GET WEAPON'S MATCHING AMMO TYPE FOR COUNT
			string ammoRef    = GetWeaponAmmoType( GetWeaponClassName( linkEnt ) )
			LootData ammoData = SURVIVAL_Loot_GetLootDataByRef( ammoRef )
			ammoCount = ammoData.countPerDrop

			Vend_Open( panel, ammoCount, player, false )
		}
	}
}
#endif //SERVER


//LOOT SETUP-----------------------------------------------------------------------------------//
#if SERVER
void function Vend_Spawn_Loot( string lootTable, entity panel, entity weaponTarget )
{
	//GET WEAPON TYPE BASED ON VENDING INSTANCE TYPE
	string weaponRef = SURVIVAL_GetWeightedItemFromGroup( lootTable )
	LootData lootData = SURVIVAL_Loot_GetLootDataByRef( weaponRef )

	//GET WEAPON'S MATCHING AMMO TYPE
	string ammoRef = GetWeaponAmmoType( lootData.baseWeapon )
	LootData ammoData = SURVIVAL_Loot_GetLootDataByRef( ammoRef )
	int ammoCount = ammoData.countPerDrop

	//SPAWN WEAPON ENTITY
	entity weaponEnt = SpawnGenericLoot( weaponRef, weaponTarget.GetOrigin() , weaponTarget.GetAngles() )
	weaponEnt.SetScriptName( VEND_SPAWNED_WEAPON )
	weaponEnt.AddUsableValue( USABLE_USE_DISTANCE_OVERRIDE )
	weaponEnt.SetUsableDistanceOverride( 0 )
	panel.LinkToEnt( weaponEnt ) //LINK TO PANEL FOR AMMO CREATION LATER


	//SPAWN MATCHING AMMO
	foreach ( entity linkEnt in weaponTarget.GetLinkEntArray() )
	{
		entity ammoEnt = SpawnGenericLoot( ammoRef, linkEnt.GetOrigin() , linkEnt.GetAngles(), ammoCount )
		ammoEnt.SetScriptName( VEND_SPAWNED_AMMO )
		ammoEnt.AddUsableValue( USABLE_USE_DISTANCE_OVERRIDE )
		ammoEnt.SetUsableDistanceOverride( 0 )
		panel.LinkToEnt( ammoEnt ) //LINK TO PANEL
	}
}
#endif //SERVER

#if SERVER
void function Vend_Open( entity panel, int ammoCount, entity player, bool isStolen )
{
	panel.SetSkin( 2 )
	panel.UnsetUsable()
	GradeFlagsClear( panel, eGradeFlags.IS_LOCKED )
	EmitSoundOnEntity( panel, SFX_PANEL_SPEAKER )
	EmitSoundOnEntity( panel, SFX_VEND_POWERDOWN )

	Vend_DestroyBlocker( panel )

	foreach ( entity linkEnt in panel.GetLinkEntArray() )
	{
		string scriptName = linkEnt.GetScriptName()
		switch ( scriptName )
		{
			case VEND_SHIELD:
			{
				//PLAY VFX
				thread PlayVendDisableVFX_Thread( linkEnt )

				linkEnt.Destroy()
				break
			}
			case VEND_SPAWNED_WEAPON:
			{
				if(IsValid(player) && player.IsPlayer())
				{
					//(player, linkEnt, file.vendPickupGracePeriod)
				}
				linkEnt.SetUsableDistanceOverride( 64 )
				break
			}
			case VEND_SPAWNED_AMMO:
			{
				if(IsValid(player) && player.IsPlayer())
				{
					//Crafting_CreateHolderEnt(player, linkEnt, file.vendPickupGracePeriod)
				}
				linkEnt.SetUsableDistanceOverride( 64 )
				break
			}
			case VEND_SHIELD_AMBGENERIC:
			{
				linkEnt.Destroy()
				break
			}
		}
	}
}

void function PlayVendDisableVFX_Thread( entity linkEnt )
{
	entity vendFX = CreateEntity( "info_particle_system" )
	vendFX.SetValueForEffectNameKey( GetAssetFromString( VFX_SHIELD_DISABLE ) )
	vendFX.kv.start_active = 1
	vendFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	vendFX.SetOrigin( linkEnt.GetOrigin() )
	vendFX.SetAngles( linkEnt.GetAngles() + <0, 180, 0> )
	DispatchSpawn( vendFX )

	OnThreadEnd(
		function() : ( vendFX )
		{
			if ( IsValid( vendFX ) )
			{
				vendFX.Destroy()
			}
		}
	)

	wait 2.0
}
#endif //SERVER

#if SERVER
void function Vend_DestroyBlocker( entity panel )
{
	//If the panel has a linked blocker volume destroy it.
	foreach ( entity linkEnt in panel.GetLinkEntArray() )
	{
		if( linkEnt.GetScriptName() == VEND_BLOCKER_VOLUME )
		{
			linkEnt.Destroy()
			printt("RAMPART TT - DESTROY BLOCKER VOLUME")
		}
	}
}
#endif //SERVER


//CHECKS TO SEE IF THE PLAYER CAN AFFORD TO BUY
bool function Vend_CostCheck( entity panel, entity player )
{
	return false
}

//FETCHES THE COST BASED ON THE INSTANCE NAME
int function Vend_GetCost( entity panel )
{
	return 0
}

//....................................................
//.LLLL.........OOOOOOO.....BBBBBBBBBB......AAAAA.....
//.LLLL........OOOOOOOOOO...BBBBBBBBBBB.....AAAAA.....
//.LLLL.......OOOOOOOOOOOO..BBBBBBBBBBB....AAAAAA.....
//.LLLL.......OOOOO..OOOOO..BBBB...BBBB....AAAAAAA....
//.LLLL......LOOOO....OOOOO.BBBB...BBBB...AAAAAAAA....
//.LLLL......LOOO......OOOO.BBBBBBBBBBB...AAAAAAAA....
//.LLLL......LOOO......OOOO.BBBBBBBBBB....AAAA.AAAA...
//.LLLL......LOOO......OOOO.BBBBBBBBBBB..AAAAAAAAAA...
//.LLLL......LOOOO....OOOOO.BBBB....BBBB.AAAAAAAAAAA..
//.LLLL.......OOOOO..OOOOO..BBBB....BBBB.AAAAAAAAAAA..
//.LLLLLLLLLL.OOOOOOOOOOOO..BBBBBBBBBBBBBAAA....AAAA..
//.LLLLLLLLLL..OOOOOOOOOO...BBBBBBBBBBB.BAAA.....AAA..
//.LLLLLLLLLL....OOOOOO.....BBBBBBBBBB.BBAAA.....AAA..
//....................................................

//CHECK IF THE PANEL IS IN A LOCKED STATE (UNOPENED)
bool function IsRampartTTPanelLocked ( entity vendPanel )
{
	return GradeFlagsHas( vendPanel, eGradeFlags.IS_LOCKED )
}

//GET THE PANEL ATTACHED TO THE LOOT
entity function GetRampartTTPanelForLoot( entity lootEnt )
{
	array<entity> linkedEnts = lootEnt.GetLinkParentArray()
	if ( linkedEnts.len() > 0 )
	{
		foreach (entity linkedEnt in linkedEnts)
		{
			if ( linkedEnt.GetScriptName() == VEND_PANEL )
			{
				return linkedEnt
			}
		}
	}

	/***
	* lootEnt has no linked parents when this function is called by the black market, so we
	* instead compare the locations of lootEnt with the locations of the rampart paintball
	* weapons that are attached to a panel. If it has the same location, we have found the
	* weapon and return it's panel.
	**/
	vector lootLocation = lootEnt.GetOrigin()

	foreach (entity panel in GetEntArrayByScriptName( VEND_PANEL ))
	{
		foreach ( entity child in panel.GetLinkEntArray() )
		{
			if ( child.GetOrigin() == lootLocation )
				return panel
		}
	}

	return null
}

//LOBA DEFENSE RESPONSE THREAD
#if SERVER
void function MaybeActivateRampartTTDefense_Thread( entity pickup, entity device, entity player )
{
	//IF IT'S NOT RAMPART LOOT RETURN
	if ( pickup.GetScriptName() != VEND_SPAWNED_WEAPON )
		return

	entity vendPanel = GetRampartTTPanelForLoot( pickup ) //GET THIS PICKUP'S PANEL
	if ( !IsValid( vendPanel ) || !IsRampartTTPanelLocked( vendPanel ) ) //CHECK IF IT'S OPEN
		return

	EndSignal( vendPanel, "OnDestroy" )

	Signal( vendPanel, "MaybeActivateRampartTTDefense_Thread" )
	EndSignal( vendPanel, "MaybeActivateRampartTTDefense_Thread" )

	if ( IsValid( device ) )
		GradeFlagsSet( device, eGradeFlags.IS_BUSY )

	//GET AMMO FOR STOLEN WEAPON
	string ammoRef = GetWeaponAmmoType( GetWeaponClassName( pickup ) )
	LootData ammoData = SURVIVAL_Loot_GetLootDataByRef( ammoRef )
	int ammoCount = ammoData.countPerDrop
	//OPEN VENDING MACHINE - Must be before frame wait.
	Vend_Open( vendPanel, ammoCount, player, true )
	Vend_DisableAll()

	WaitFrame()

	//DESTROY BLACK MARKET
	if ( IsValid( device ) )
	{
		device.TakeDamage( 9999, null, null, {} )

		vector explosionCenter           = device.GetOrigin()
		float damage                     = 2
		float damageHeavyArmor           = damage
		float innerRadius                = 100
		float outerRadius                = 120
		int flags                        = DF_EXPLOSION
		vector projectileLaunchPos       = explosionCenter
		float explosionForce             = 110
		int scriptDamageFlags            = damageTypes.explosive
		int scriptDamageSourceIdentifier = eDamageSourceId.vault_defense
		string impactEffectTableName     = "superSpectre_groundSlam_impact"
		Explosion( explosionCenter, pickup, pickup, damage, damageHeavyArmor, innerRadius, outerRadius, flags, projectileLaunchPos, explosionForce, scriptDamageFlags, scriptDamageSourceIdentifier, impactEffectTableName )
	}

	//ALARM STATE
	file.alarmTime = Time() + 14.0 //SET ALARM TIME
	if(!file.alarmActive)
	{
		//START ALARM
		Vend_Alarm_Sequence()
	}
}

bool function GetRampartTTAssetsToPrecache( array< string > models, array< string > particles )
{
	if ( IsRampartTTEnabled() == false )
		return false

	models.append( MODEL_VEND_SHIELD )

	particles.append( VFX_SHIELD_DISABLE )
	particles.append( VFX_ALARM_LIGHT )

	return true
}
#endif //SERVER

#if SERVER
void function Vend_Alarm_Sequence()
{
	int particleId = GetParticleSystemIndex( GetAssetFromString( VFX_ALARM_LIGHT ) )

	//OPEN STATE
	file.alarmActive = true

	//HOLD WHILE ALARM IS GOING
	while ( Time() < file.alarmTime ) // 14.0 float
	{
		//START ALARM
		EmitSoundAtPosition( TEAM_UNASSIGNED, file.alarm_sfxPos.GetOrigin(), SFX_ALARM, file.alarm_sfxPos )

		//CREATE VFX LIGHTS
		foreach ( entity alarm_vfxPos in GetEntArrayByScriptName( ALARM_VFX_POSITION ) )
		{
			entity alarm_light
			alarm_light = StartParticleEffectInWorld_ReturnEntity( particleId, LocalPosToWorldPos( < -12, 0, 0 >, alarm_vfxPos ), LocalAngToWorldAng( < -10, 180, 180 >, alarm_vfxPos ) )
			alarm_light.SetStopType( "destroyImmediately" )
			alarm_light.SetScriptName( VFX_ALARM_LIGHT_NAME )
		}

		wait 1.5
		//DESTROY VFX LIGHTS
		foreach ( entity alarm_light in GetEntArrayByScriptName( VFX_ALARM_LIGHT_NAME ) )
		{
			alarm_light.Destroy()
		}
		wait 1.5
	}

	//STOP ALARM AND ENABLE VENDING MACHINES AGAIN
	Vend_EnableAll()
	StopSoundAtPosition( file.alarm_sfxPos.GetOrigin(), SFX_ALARM )

	//CLEAN UP VFX LIGHTS
	foreach ( entity alarm_light in GetEntArrayByScriptName( VFX_ALARM_LIGHT_NAME ) )
	{
		alarm_light.Destroy()
	}

	//CLOSE STATE
	file.alarmActive = false
}
#endif //SERVER

#if SERVER
//ENABLE VENDING MACHINES THAT ARE STILL CLOSED
void function Vend_EnableAll()
{
	foreach ( entity panel in GetEntArrayByScriptName( VEND_PANEL ) )
	{
		if( IsRampartTTPanelLocked( panel ) )
		{
			panel.SetSkin( 0 )
			panel.SetUsable()
			panel.SetUsablePriority( USABLE_PRIORITY_LOW )
			panel.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER | USABLE_BY_PILOTS | USABLE_BY_ENEMIES )
		}
	}
}
#endif //SERVER

#if SERVER
//DISABLE VENDING MACHINES THAT ARE STILL CLOSED
void function Vend_DisableAll()
{
	foreach ( entity panel in GetEntArrayByScriptName( VEND_PANEL ) )
	{
		if( IsRampartTTPanelLocked( panel ) )
		{
			panel.SetSkin( 1 )
			panel.UnsetUsable()
		}
	}
}
#endif //SERVER

//....................................................
//.LLLL.........OOOOOOO.....RRRRRRRRRR...EEEEEEEEEEE..
//.LLLL........OOOOOOOOOO...RRRRRRRRRRR..EEEEEEEEEEE..
//.LLLL.......OOOOOOOOOOOO..RRRRRRRRRRR..EEEEEEEEEEE..
//.LLLL.......OOOOO..OOOOO..RRRR...RRRRR.EEEE.........
//.LLLL......LOOOO....OOOOO.RRRR...RRRRR.EEEE.........
//.LLLL......LOOO......OOOO.RRRRRRRRRRR..EEEEEEEEEE...
//.LLLL......LOOO......OOOO.RRRRRRRRRRR..EEEEEEEEEE...
//.LLLL......LOOO......OOOO.RRRRRRRR.....EEEEEEEEEE...
//.LLLL......LOOOO....OOOOO.RRRR.RRRR....EEEE.........
//.LLLL.......OOOOO..OOOOO..RRRR..RRRR...EEEE.........
//.LLLLLLLLLL.OOOOOOOOOOOO..RRRR..RRRRR..EEEEEEEEEEE..
//.LLLLLLLLLL..OOOOOOOOOO...RRRR...RRRRR.EEEEEEEEEEE..
//.LLLLLLLLLL....OOOOOO.....RRRR....RRRR.EEEEEEEEEEE..
//....................................................

#if SERVER
void function SetupLoreEvents()
{
	//DATAPAD-----//
	foreach ( entity datapad in GetEntArrayByScriptName( RAMPART_LORE_DATAPAD ) )
	{
		DataPad_SetUse( datapad )
		AddCallback_OnUseEntity_ServerOnly( datapad, DataPad_OnUse )
		SetCallback_CanUseEntityCallback( datapad, DataPad_CanUse )
	}

	//APPEND DATAPAD VO TO ARRAY`
	file.datapadDialogue.append( SFX_DATAPAD_BANG )
	file.datapadDialogue.append( SFX_DATAPAD_BLISK )
	file.datapadDialogue.append( SFX_DATAPAD_FRANCIS )
	file.datapadDialogue.append( SFX_DATAPAD_GIBRALTAR )
	file.datapadDialogue.append( SFX_DATAPAD_MIRAGE )
	file.datapadDialogue.append( SFX_DATAPAD_SEER )
	file.datapadDialogue.append( SFX_DATAPAD_VALK )


	//MENS ROOM SIGN MIRAGE ONLY-----//
	foreach ( entity menSign in GetEntArrayByScriptName( RAMPART_LORE_MENSIGN ) )
	{
		LoreEnt_SetUse( menSign )
		AddCallback_OnUseEntity_ClientServer( menSign, Lore_OnUse )
		SetCallback_CanUseEntityCallback( menSign, Lore_CanUse )
	}

	//PORTRAIT RAMPART ONLY-----//
	foreach ( entity portrait in GetEntArrayByScriptName( RAMPART_LORE_PORTRAIT ) )
	{
		LoreEnt_SetUse( portrait )
		AddCallback_OnUseEntity_ClientServer( portrait, Lore_OnUse )
		SetCallback_CanUseEntityCallback( portrait, Lore_CanUse )
	}

	//SISTER TARGET RAMPART ONLY-----//
	foreach ( entity sister in GetEntArrayByScriptName( RAMPART_LORE_SISTER ) )
	{
		LoreEnt_SetUse( sister )
		AddCallback_OnUseEntity_ClientServer( sister, Lore_OnUse )
		SetCallback_CanUseEntityCallback( sister, Lore_CanUse )
	}
	//SHOP SIGN RAMPART ONLY-----//
	foreach ( entity shopSign in GetEntArrayByScriptName( RAMPART_LORE_SHOPSIGN ) )
	{
		LoreEnt_SetUse( shopSign )
		AddCallback_OnUseEntity_ClientServer( shopSign, Lore_OnUse )
		SetCallback_CanUseEntityCallback( shopSign, Lore_CanUse )
	}

}
#endif //SERVER

#if SERVER
void function DataPad_SetUse( entity datapad )
{
	datapad.SetUsable()
	datapad.SetUsablePriority( USABLE_PRIORITY_LOW )
	datapad.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER | USABLE_BY_PILOTS | USABLE_BY_ENEMIES )
	datapad.SetUsePrompts( "#RAMPART_TT_LORE_DATAPAD", "#RAMPART_TT_LORE_DATAPAD" )
	datapad.AddUsableValue( USABLE_USE_DISTANCE_OVERRIDE )
	datapad.SetUsableDistanceOverride( 64 )
}
#endif //SERVER

bool function DataPad_CanUse( entity player, entity datapad, int useFlags)
{
	if ( !SURVIVAL_PlayerCanUse_AnimatedInteraction( player, datapad ) )
		return false

	return true
}

#if SERVER
void function DataPad_OnUse( entity datapad, entity player, int useInputFlags )
{
	datapad.UnsetUsable()
	thread DataPad_Dialogue_Thread( datapad )
}
#endif //SERVER

#if SERVER
void function DataPad_Dialogue_Thread( entity datapad )
{
	int vo_index
	if(file.datapadDialogue.len() > 1)
	{
		vo_index = RandomIntRange( 0, file.datapadDialogue.len() - 1 )
	}
	else
	{
		vo_index = 0
	}

	foreach ( line in file.datapadDialogue[vo_index] )
	{
		float duration = EmitSoundOnEntity( datapad, line )
		wait duration
	}
	wait 3

	//REMOVE PLAYED LINE FROM ARRAY AND RE-ENABLE
	file.datapadDialogue.fastremove( vo_index )
	if( file.datapadDialogue.len() > 0 )
	{
		DataPad_SetUse( datapad )
	}
}
#endif //SERVER

//LORE--------------------------------//
#if CLIENT
void function OnLoreCreated( entity loreEnt )
{
	switch( loreEnt.GetScriptName() )
	{
		case RAMPART_LORE_MENSIGN:
		{
			AddEntityCallback_GetUseEntOverrideText( loreEnt, MirageOnly_UseTextOverride )
			break
		}
		case RAMPART_LORE_PORTRAIT:
		{
			AddEntityCallback_GetUseEntOverrideText( loreEnt, RampartOnly_UseTextOverride )
			break
		}
		case RAMPART_LORE_SISTER:
		{
			AddEntityCallback_GetUseEntOverrideText( loreEnt, RampartOnly_UseTextOverride )
			break
		}
		case RAMPART_LORE_SHOPSIGN:
		{
			AddEntityCallback_GetUseEntOverrideText( loreEnt, RampartOnly_UseTextOverride )
			break
		}
		default:
		{
			return
		}
	}
}
#endif // CLIENT

#if SERVER
void function LoreEnt_SetUse( entity ent )
{
	ent.SetUsable()
	ent.SetUsablePriority( USABLE_PRIORITY_LOW )
	ent.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER | USABLE_BY_PILOTS | USABLE_BY_ENEMIES )
	ent.AddUsableValue( USABLE_USE_DISTANCE_OVERRIDE )
	ent.SetUsableDistanceOverride( 64 )
}
#endif //SERVER

#if SERVER
void function Lore_Cooldown_Thread( entity ent )
{
	ent.EndSignal( "OnDestroy" )

	wait 30
	LoreEnt_SetUse( ent )
}
#endif //SERVER

bool function Lore_CanUse( entity player, entity loreEnt, int useFlags)
{
	if ( !SURVIVAL_PlayerCanUse_AnimatedInteraction( player, loreEnt ) )
		return false

	return true
}

#if CLIENT
string function MirageOnly_UseTextOverride( entity loreEnt )
{
	entity player = GetLocalViewPlayer()
	if ( !IsValid (player) )
	{
		return ""
	}

	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	string characterRef  = ItemFlavor_GetHumanReadableRef( character ).tolower()
	if ( characterRef != "character_mirage" )
	{
		return "#RAMPART_TT_REQ_MIRAGE"
	}

	return "#RAMPART_TT_LORE_INTERACT"
}
#endif //CLIENT

#if CLIENT
string function RampartOnly_UseTextOverride( entity loreEnt )
{
	entity player = GetLocalViewPlayer()
	if ( !IsValid (player) )
	{
		return ""
	}

	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	string characterRef  = ItemFlavor_GetHumanReadableRef( character ).tolower()
	if ( characterRef != "character_rampart" )
	{
		return "#RAMPART_TT_REQ_RAMPART"
	}

	return "#RAMPART_TT_LORE_INTERACT"
}
#endif //CLIENT

#if SERVER
void function Lore_OnUse( entity loreEnt, entity playerUser, int useInputFlags )
{
	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( playerUser ), Loadout_Character() )
	string characterRef  = ItemFlavor_GetHumanReadableRef( character ).tolower()
	string dialogueLine

	if ( characterRef == "character_rampart" )
	{
		switch ( loreEnt.GetScriptName() )
		{
			case RAMPART_LORE_SHOPSIGN:
			{
				dialogueLine = SFX_LORE_SHOPSIGN
				break
			}
			case RAMPART_LORE_PORTRAIT:
			{
				dialogueLine = SFX_LORE_PORTRAIT
				break
			}
			case RAMPART_LORE_SISTER:
			{
				dialogueLine = SFX_LORE_SISTER
				break
			}
			default:
			{
				return
			}
		}
	}
	else if ( characterRef == "character_mirage" && loreEnt.GetScriptName() == RAMPART_LORE_MENSIGN )
	{
		dialogueLine = SFX_LORE_MENSIGN
	}
	else
	{
		return
	}

	//ON LORE USED
	loreEnt.UnsetUsable()
	thread Lore_Cooldown_Thread( loreEnt )
	thread PlayBattleChatterLineToSpeakerAndTeam( playerUser, dialogueLine )
}
#endif //SERVER

#if SERVER
entity function CreateVendShieldWall( entity shieldTarget )
{
	entity shieldEnt = CreatePropShield( GetAssetFromString( MODEL_VEND_SHIELD ), COLORID_DIM_LOOT_TIER4, shieldTarget.GetOrigin(), shieldTarget.GetAngles(), SOLID_VPHYSICS )
	shieldEnt.SetScriptName( VEND_SHIELD )

	return shieldEnt
}
#endif //SERVER

bool function CheckRampartTTMuralLegends( entity player )
{
	//CHECK YOUR CHARACTER AGAINST VALID S10 LEGENDS
	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	string playerChar  = ItemFlavor_GetHumanReadableRef( character ).tolower()
	foreach ( validChar in RAMPART_TT_S10_MURAL_LEGENDS )
	{
		if( validChar == playerChar )
		{
			return true
		}
	}

	//else
	return false
}

bool function UseOneTimePurchaseVendingMachines()
{
	return GetCurrentPlaylistVarBool( "rampart_tt_single_use_vend", true )
}

float function BluePaintballVendTime()
{
	return GetCurrentPlaylistVarFloat( "rampart_tt_blue_vend_time", 8.0 )
}

float function PurpPaintballVendTime()
{
	return GetCurrentPlaylistVarFloat( "rampart_tt_purp_vend_time", 12.0 )
}

#if CLIENT
void function ServertoClientCallback_VendingMachineTimerDone ( entity vend )
{
	if ( vend in file.isVending )
		file.isVending [ vend ] = false
}

void function ServertoClientCallback_PlayerUsedVendingMachine ( entity player, entity panel )
{
	file.hasPurchased [ player ] <- true
}

void function ServertoClientCallback_VendingMachineInUse ( entity panel )
{
	file.isVending [ panel ] <- true
}
#endif

#if SERVER
void function Rampart_TT_OnPlayerStateChanged( entity player )
{
	return
}
void function Thread_TimedVend ( entity panel, entity player, int ammoCount )
{
	float duration
	int tier
	string instName = panel.GetInstanceName()
	switch( instName )
	{
		case VEND_INST_BLUE:
		{
			duration = BluePaintballVendTime()
			tier = 2
			break
		}

		case VEND_INST_PURPLE:
		{
			duration = BluePaintballVendTime()
			tier = 2
			break
		}

		case VEND_INST_GOLD:
		{
			duration = PurpPaintballVendTime()
			tier = 3
			break
		}
	}

	entity wp = CreateWaypoint_ObjectiveEntLocation( panel, ePingType.RAMPART_TT_VENDING )
	wp.SetParent( panel )
	wp.SetLocalOrigin( <20, 0, 70> )
	wp.SetWaypointInt( 5, tier )

	wp.SetWaypointGametime( RUI_TRACK_INDEX_CAPTURE_END_TIME, Time() + duration )
	wp.SetWaypointFloat( RUI_TRACK_INDEX_REQUIRED_TIME, duration )
	wp.SetWaypointInt( RUI_TRACK_INDEX_ACTIVATOR_TEAM, player.GetTeam() )
	wp.SetWaypointString( 0, "#RAMPART_TT_VENDING" )

	panel.SetOwner( wp )

	EmitSoundOnEntity( panel, SFX_PANEL_LOOP )
	wait duration
	StopSoundOnEntity( panel, SFX_PANEL_LOOP )

	file.isVending [ panel ] = false
	array<entity> players = GetPlayerArray()
	foreach (ent in players)
		Remote_CallFunction_NonReplay( ent, "ServertoClientCallback_VendingMachineTimerDone", panel )

	panel.SetOwner( null )
	wp.Destroy()
	Vend_Open( panel, ammoCount, player, false )
}

void function SetUpWelcomeTrigger()
{
	return

	vector origin   = file.alarm_sfxPos.GetOrigin() - < 0, 0, 120 >
	vector angles = file.alarm_sfxPos.GetAngles() + < 90, 0, 0 >
	int radius      = 600
	int aboveHeight = 70
	int belowHeight = 0

	entity trigger = CreateTriggerCylinder( origin, radius, aboveHeight, belowHeight )
	trigger.SetEnterCallback( Team_Entered_Rampart_TT_Trigger )
}

void function Team_Entered_Rampart_TT_Trigger( entity trigger, entity player )
{
	if ( !HasTeamEnteredRampartTT( player ) && file.welcomeOnCooldown == false )
	{
		EmitSoundAtPosition( TEAM_UNASSIGNED, file.alarm_sfxPos.GetOrigin(), SFX_WELCOME, file.alarm_sfxPos )
		thread Thread_WelcomeCooldown()
	}
	file.hasEntered [ player ] <- true
}

bool function HasTeamEnteredRampartTT( entity player )
{
	bool hasEntered = false

	array<entity> teammates = GetPlayerArrayOfTeam( player.GetTeam() )
	foreach( teammate in teammates )
	{
		if ( teammate in file.hasEntered )
		{
			hasEntered = true
			break
		}
	}
	return hasEntered
}

void function Thread_SpeakerCooldown()
{
	file.speakerOnCooldown = true

	wait 10.0

	file.speakerOnCooldown = false
}

void function Thread_WelcomeCooldown()
{
	file.welcomeOnCooldown = true

	wait 10.0

	file.welcomeOnCooldown = false
}
void function Vend_PlayFinishedFX_Thread( entity panel )
{
	entity vendFinishFX = StartParticleEffectOnEntityWithPos_ReturnEntity( panel, GetParticleSystemIndex( VFX_VEND_COMPLETE ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <20, 0, 70>, <0, 0, 0> )
	EffectSetControlPointVector( vendFinishFX, 1, < 165, 255, 243 > )

	OnThreadEnd(
		function() : ( vendFinishFX )
		{
			if ( IsValid( vendFinishFX ) )
			{
				EffectStop( vendFinishFX )
			}
		}
	)

	wait 1.0
}

void function Vend_PlayAudioFinished_Thread( entity panel )
{
	int idxToPlay = RandomInt( SFX_RAMPART_VO_PURCHASE.len() )
	string chosenVO = SFX_RAMPART_VO_PURCHASE[idxToPlay]

	EmitSoundOnEntity( panel, SFX_VEND_DONE )
	if ( ShouldPlayBroadcast_RampartTT() )
	{
		foreach( player in GetPlayerArray_Alive() )
		{
			if ( IsPlayerInRange_Rampart_TT( player ) )
				Remote_CallFunction_NonReplay( player, "ServertoClientCallback_RampartTT_BroadcastSystemPlay", -1, true )
		}
	}

	wait 2.3

	EmitSoundOnEntity( panel, chosenVO )
	if ( ShouldPlayBroadcast_RampartTT() )
	{
		foreach ( player in GetPlayerArray_Alive() )
		{
			if ( IsPlayerInRange_Rampart_TT( player ) )
				Remote_CallFunction_NonReplay( player, "ServertoClientCallback_RampartTT_BroadcastSystemPlay", idxToPlay, false )
		}
	}
}

bool function ShouldPlayBroadcast_RampartTT()
{
	return GetCurrentPlaylistVarBool( "rampart_tt_should_play_broadcast", true )
}

bool function IsPlayerInRange_Rampart_TT( entity player )
{
	if ( !IsValid( player ) )
		return false

	float dist   = Distance( player.GetOrigin(), file.alarm_sfxPos.GetOrigin() )
	bool inRange = dist <= BIG_MAUDE_AUDIO_RADIUS

	return inRange
}

void function Rampart_TT_SpeakerSetupOnClientConnected( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServertoClientCallback_RampartTT_SetCustomSpeakerIdx", file.customQueueIdx )
}
#endif

#if CLIENT
// Borrowed the following functions from sh_crafting.nut
void function SetupVendWaypoint( entity waypoint )
{
	if ( waypoint.GetWaypointType() != eWaypoint.OBJECTIVE || Waypoint_GetPingTypeForWaypoint( waypoint ) != ePingType.RAMPART_TT_VENDING )
	{
		return
	}

	thread Thread_SetupVendWaypoint_Internal( waypoint )
}

void function Thread_SetupVendWaypoint_Internal( entity waypoint )
{
	if ( waypoint.GetWaypointType() != eWaypoint.OBJECTIVE || Waypoint_GetPingTypeForWaypoint( waypoint ) != ePingType.RAMPART_TT_VENDING )
	{
		return
	}

	int timeoutCounter = 0
	while ( IsValid( waypoint ) && waypoint.wp.ruiHud == null )
	{
		printf( "RAMPART_TT: Waypoint WaitFrame" )
		WaitFrame()
		timeoutCounter++
		if (timeoutCounter > 1000)
			return
	}

	if ( !IsValid( waypoint ) )
	{
		printf( "RAMPART_TT: Waypoint Invalid" )
		return
	}

	RuiSetFloat( waypoint.wp.ruiHud, "maxDrawDistance", 3000 )
	RuiSetFloat( waypoint.wp.ruiHud, "iconSize", 72.0 )
	RuiSetFloat( waypoint.wp.ruiHud, "iconSizePinned", 72.0 )
	RuiSetImage( waypoint.wp.ruiHud, "outerIcon", BIGMAUDE_DISPENSER_CRAFTING_ICON_ASSET )
	RuiSetImage( waypoint.wp.ruiHud, "innerIcon", BIGMAUDE_DISPENSER_CRAFTING_ICON_ASSET )
	//RuiSetImage( waypoint.wp.ruiHud, "fillBackgroundImage", BIGMAUDE_DISPENSER_FILL_BG_ICON_ASSET )
	RuiSetImage( waypoint.wp.ruiHud, "fillImage", BIGMAUDE_DISPENSER_FILL_ICON_ASSET )

	RuiSetInt( waypoint.wp.ruiHud, "yourObjectiveStatus", 2 )
	RuiSetInt( waypoint.wp.ruiHud, "yourTeamIndex", GetLocalViewPlayer().GetTeam() )
	RuiSetInt( waypoint.wp.ruiHud, "roundState", 0 )
	RuiSetString( waypoint.wp.ruiHud, "pingPrompt", Localize( "#RAMPART_TT_VENDING" ) )
	RuiSetString( waypoint.wp.ruiHud, "pingPromptForOwner", Localize( "#RAMPART_TT_VENDING" ) )
	RuiSetBool( waypoint.wp.ruiHud, "reverseProgress", false )
	RuiSetBool( waypoint.wp.ruiHud, "iconColorOverride", true )
	RuiSetFloat3( waypoint.wp.ruiHud, "iconColor", Rampart_TT_GetWaypointColor( waypoint ) )

	RuiTrackGameTime( waypoint.wp.ruiHud, "captureEndTime", waypoint, RUI_TRACK_WAYPOINT_GAMETIME, RUI_TRACK_INDEX_CAPTURE_END_TIME )
	RuiTrackFloat( waypoint.wp.ruiHud, "captureTimeRequired", waypoint, RUI_TRACK_WAYPOINT_FLOAT, RUI_TRACK_INDEX_REQUIRED_TIME )
	RuiTrackInt( waypoint.wp.ruiHud, "currentControllingTeam", waypoint, RUI_TRACK_WAYPOINT_INT, RUI_TRACK_INDEX_ACTIVATOR_TEAM )
}

vector function Rampart_TT_GetWaypointColor( entity waypoint )
{
	return ( GetKeyColor( COLORID_LOOT_TIER0 + waypoint.GetWaypointInt( 5 ) ) / 255.0 )
}

void function ServertoClientCallback_RampartTT_SetCustomSpeakerIdx( int customQueueIdx )
{
	file.customQueueIdx = customQueueIdx
	file.customSpeakers.extend( GetEntArrayByScriptName( "Rampart_TT_Speaker" ) )
	RegisterCustomDialogueQueueSpeakerEntities( customQueueIdx, GetEntArrayByScriptName( "Rampart_TT_Speaker" ) )
}

const float DIALOGUE_DEBOUNCE_TIME = 5.0
void function ServertoClientCallback_RampartTT_BroadcastSystemPlay( int idxToPlay, bool overlapAudio )
{
	if ( file.customSpeakers.len() < 1 )
		return

	if ( Time() < file.rampartLineFinishedPlayingTime )
		return

	string lineToPlay
	if ( idxToPlay == -1 )
	{
		lineToPlay =  SFX_VEND_DONE_POI_WIDE
	}
	else
	{
		lineToPlay = SFX_RAMPART_VO_PURCHASE[idxToPlay]
	}

	if ( !overlapAudio )
	{
		float duration = GetSoundDuration( GetAnyDialogueAliasFromName( lineToPlay ) )
		file.rampartLineFinishedPlayingTime = Time() + duration + DIALOGUE_DEBOUNCE_TIME
	}

	int dialogueFlags = eDialogueFlags.USE_CUSTOM_QUEUE | eDialogueFlags.USE_CUSTOM_SPEAKERS | eDialogueFlags.BLOCK_LOWER_PRIORITY_QUEUE_ITEMS
	SCB_PlayDialogueOnCustomSpeakers( GetAnyAliasIdForName( lineToPlay ), dialogueFlags, file.customQueueIdx )
}
#endif