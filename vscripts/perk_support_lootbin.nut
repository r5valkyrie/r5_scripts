global function Perk_SupportLootbin_Init
global function SupportBin_ShouldProvideSurvivalAssitance
global function SupportBin_UseBasicLootConfiguration

#if SERVER || CLIENT
global function SupportBin_ShouldUseDiscreteSupportBins
global function SupportBin_ShouldEveryoneAccessSupportBins
global function SupportBin_CanUseSupportBin
global function SupportBin_ShouldSpawnSupportBins
global function SupportBin_EntityIsSupportBin

#if SERVER
global function SupportBin_CreateSupportBins
global function SupportBin_SpawnSupportBinFromExistingBin
global function SupportBin_SpawnSupportBin
global function SupportBin_MaybeAddSurvivalLootBinOnOpen
global function SupportBin_ClientToServer_MarkSupportBoxLoot

global function SupportBin_RotatingLoot_RefillBins_BothCompartments

#endif
#if CLIENT
global function Perk_SupportBin_SupportBinHasHudMarker
global function Perk_SupportBin_ServerToClient_DisplayOpenedSupportBoxPrompt
#endif
#endif


#if SERVER || CLIENT
global const string LOOT_BIN_SUPPORT_SKIN = "SecretLoot"
global const string LOOT_BIN_DEFAULT_SKIN = "(default)"

global const float SURVIVAL_ASSISTANCE_COOLDOWN_DURATION = 10.0
global const int SURVIVAL_ASSISTANCE_MAX_COUNT = 3
#endif

const string LOOT_ITEM_MEDKIT_NAME = "health_pickup_health_large"
const string LOOT_ITEM_BATTERY_NAME = "health_pickup_combo_large"
const string LOOT_ITEM_PHEONIX_NAME = "health_pickup_combo_full"
const string LOOT_ITEM_CELL_NAME = "health_pickup_combo_small"
const string LOOT_ITEM_SYRINGE_NAME = "health_pickup_health_small"

const string SUPPORT_BIN_INGAME_LOCKED_HINT = "Support Bins can be used by Support Legends"

#if SERVER
const array<string> scaledRegularLootTables =
[
	"support_bin_loot_tier_1",
	"support_bin_loot_tier_2",
	"support_bin_loot_tier_3",
	"support_bin_loot_tier_4",
	"support_bin_loot_tier_5",
	"support_bin_loot_tier_5",
	"support_bin_loot_tier_5",
	"support_bin_loot_tier_5"
]

const array<string> scaledSecretLootTables =
[
	"secret_bin_loot_tier_1",
	"secret_bin_loot_tier_2",
	"secret_bin_loot_tier_3",
	"secret_bin_loot_tier_4",
	"secret_bin_loot_tier_5",
	"secret_bin_loot_tier_5",
	"secret_bin_loot_tier_5",
	"secret_bin_loot_tier_5"
]

const array<string> armorAdditionLootTables =
[
	"Armor_Low",
	"Armor_Medium",
	"Armor_Medium",
	"Armor_Medium",
	"Armor_High",
	"Armor_High",
	"Armor_High",
	"Armor_High",
]
#endif

enum SurvivalNeedType
{
	SURIVIAL_LOOT_NEED_MRB,
	SURIVIAL_LOOT_NEED_HS,
	SURIVIAL_LOOT_NEED_ANY,
	SURIVIAL_LOOT_NEED_NONE
}

enum SurvivalStatusType
{
	SURIVIAL_LOOT_HAS_MRB,
	SURIVIAL_LOOT_HAS_HS,
	SURIVIAL_LOOT_HAS_EVAC,
	SURIVIAL_LOOT_HAS_NONE
}

#if SERVER
struct PlayerSupportAssistData
{
	bool playerAssistOnCooldown
	float playerAssistCurrentCooldown

	bool playerRecievedAssist
	int playerAssistCount

	int playerHeatShieldCount
	bool playerHasEnteredRing
}

struct
{
	array<entity> activeSupportBins
	table<entity, entity> playerToOpenedBin

	table< entity, PlayerSupportAssistData > playerSupportBinRegistry
	table< entity, int > playerMedkitsGiven
}file

#endif

void function Perk_SupportLootbin_Init()
{
	if ( !SupportBin_ShouldUseDiscreteSupportBins() )
		return

	PerkInfo extraBinLoot
	extraBinLoot.perkId          = ePerkIndex.EXTRA_BIN_LOOT
	#if SERVER || CLIENT
		extraBinLoot.activateCallback = null
		extraBinLoot.deactivateCallback = null
		extraBinLoot.minimapStateIndex = eMinimapObject_prop_script.SUPPORT_BIN
		extraBinLoot.minimapPingType = ePingType.SUPPORT_BOX
		extraBinLoot.mapFeatureTitle = "#PERK_FEATURE_SUPPORT_LOOTBIN"
		extraBinLoot.mapFeatureDescription = "#PERK_FEATURE_SUPPORT_LOOTBIN_DESC"
		extraBinLoot.trackEntityPosition = true
	#endif
	#if CLIENT
		extraBinLoot.worldspaceIconUpOffset = 20
		extraBinLoot.ruiThinkThread = Perk_SupportBin_RuiThinkThread
		extraBinLoot.staticPingDistance = 1500
	#endif

	Perks_RegisterClassPerk( extraBinLoot )

	#if SERVER || CLIENT
		if ( !SupportBin_ShouldSpawnSupportBins() )
			return
	#endif

	#if SERVER
		RegisterSignal( "Support_Bin_EnteredRing" )

		if(SupportBin_UseScalingLoot())
			SURVIVAL_AddCallback_OnDeathFieldStopShrink( SupportBin_Callback_RoundChangeUpdate )
	#endif

	#if CLIENT
		AddCreateCallback( "prop_dynamic", SupportBin_OnPropScriptCreated )
		AddCreateCallback( "prop_script", SupportBin_OnPropScriptCreated )
	#endif

	#if SERVER || CLIENT
		PrecacheModel( LOOT_BIN_MODEL )
		PrecacheParticleSystem( LOOT_BIN_OPEN_REGULAR_FX )
		PrecacheParticleSystem( LOOT_BIN_OPEN_SECRET_FX )

		Remote_RegisterClientFunction( "Perk_SupportBin_ServerToClient_DisplayOpenedSupportBoxPrompt" )
		Remote_RegisterServerFunction( "SupportBin_ClientToServer_MarkSupportBoxLoot" )

		#if SERVER
			if( GameMode_IsActive( eGameModes.SURVIVAL ) )
				AddCallback_GameStateEnter( eGameState.Playing, SupportBin_CreateSupportBins )

			AddCallback_OnLootBinOpening( Perk_SupportBin_UpdateBinAfterOpening )

		#endif

	#endif
}

#if SERVER || CLIENT
bool function SupportBin_ShouldSpawnSupportBins()
{
	if( GetCurrentPlaylistVarBool("survival_block_lootbin_creation", false ) )
		return false

	                      
	if( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_WINTEREXPRESS ) )
		return false
       

	                        
	if( GameModeVariant_IsActive( eGameModeVariants.FREEDM_GUNGAME ) )
		return false
       

	                        
		if( GameMode_IsActive( eGameModes.CONTROL ) )
			return false
                               

                        
                                            
               
                              

	return true
}
#endif

bool function SupportBin_ShouldUseDiscreteSupportBins()
{
	#if SERVER || CLIENT
	if( GetMapName().find( "mp_rr_box" ) >= 0 )
	{
		return true
	}
	#endif

	return ( GetCurrentPlaylistVarBool("use_discrete_support_bins", true ) )
}

bool function Perk_SupportBin_SupportBinHasHudMarker()
{
	return ( GetCurrentPlaylistVarBool("supportbin_enable_hud_marker", true ) )
}

bool function Perk_SupportBin_ShouldShowEveryoneSupportBins()
{
	return ( GetCurrentPlaylistVarBool("supportbin_show_everyone", false ) )
}

bool function SupportBin_ShouldLimitAllSurvivalItems()
{
	return ( GetCurrentPlaylistVarBool("supportbin_enable_survival_rate_limiting", false ) )
}

bool function SupportBin_HardLimitSurvivalAssistanceCount()
{
	return ( GetCurrentPlaylistVarBool("supportbin_enable_hard_survival_count_limiting", false ) )
}

bool function SupportBin_ShouldProvideSurvivalAssitance()
{
	return ( GetCurrentPlaylistVarBool("supportbin_enable_survival_assistance", true ) )
}

int function SupportBin_Get_RandomizeExclusionDistance()
{
	return ( GetCurrentPlaylistVarInt("supportbin_exclusion_radius", 13000*13000 ) )
}

int function SupportBin_Get_MaxBigHealInSecretLoot()
{
	return ( GetCurrentPlaylistVarInt("supportbin_max_bigheal_count", 2 ) )
}

bool function SupportBin_ShouldEveryoneAccessSupportBins()
{
	return ( GetCurrentPlaylistVarBool("supportbin_inclusive_class_access", true ) )
}

bool function SupportBin_UseBasicLootConfiguration()
{
	return ( GetCurrentPlaylistVarBool("supportbin_use_basic_loot", true ) )
}

bool function SupportBin_UseScalingLoot()
{
	return ( GetCurrentPlaylistVarBool("supportbin_use_scaling_loot", false ) )
}

bool function SupportBin_OnlyScaleSecretLoot()
{
	return ( GetCurrentPlaylistVarBool("supportbin_disable_scaling_regular_loot", true ) )
}

bool function SupportBin_MedkitLimitingEnabled()
{
	return ( GetCurrentPlaylistVarBool("supportbin_medkit_limiting", true ) )
}

int function SupportBin_Get_MaxBinGivenMedkitLimit()
{
	return ( GetCurrentPlaylistVarInt("supportbin_bin_given_medkit_limit", 2 ) )
}

int function SupportBin_Get_MaxMedkitLimit()
{
	return ( GetCurrentPlaylistVarInt("supportbin_medkit_limit_max", 1 ) )
}

bool function SupportBin_HeatShieldAssistanceLimiting()
{
	return ( GetCurrentPlaylistVarBool("supportbin_heatshield_limiting", true ) )
}

int function SupportBin_HeatShieldAssistanceMax()
{
	return ( GetCurrentPlaylistVarInt("supportbin_heatshield_assistance_max", 3 ) )
}

bool function SupportBin_RotatingLoot_Refill_SecretLoot()
{
	return ( GetCurrentPlaylistVarBool("supportbin_dispenses_rotatingloot_only_secret_compartment", false ) )
}

bool function SupportBin_RotatingLoot_Refill_MainLoot()
{
	return ( GetCurrentPlaylistVarBool("supportbin_dispenses_rotatingloot_only_secret_compartment", true ) )
}

bool function SupportBin_RotatingLoot_MainLoot_AllowGearSpawns()
{
	return ( GetCurrentPlaylistVarBool("supportbin_dispenses_rotatingloot_main_compartment_spawns_gear", true ) )
}

bool function SupportBin_AllowArmorLootInBins()
{
	return ( GetCurrentPlaylistVarBool("supportbin_enable_armor_loot", false ) )
}

bool function SupportBin_ResepectGroundLootRotation()
{
	return ( GetCurrentPlaylistVarBool("supportbin_enforce_ground_loot_rotation", true ) )
}

bool function SupportBin_ValidateSurvivalNeedAgainstTeamInvetory( )
{
	return ( GetCurrentPlaylistVarBool("supportbin_validate_survival_using_team_inventory", false ) )
}

bool function SupportBin_RemoveSurvivalItemsFromBaseRoll()
{
	return ( GetCurrentPlaylistVarBool("supportbin_remove_survival_items", true ) )
}

#if SERVER || CLIENT
bool function SupportBin_CanUseSupportBin( entity player, entity lootBin )
{
	bool playerHasPerk = Perks_DoesPlayerHavePerk( player, ePerkIndex.EXTRA_BIN_LOOT )
	if ( !playerHasPerk && !SupportBin_ShouldEveryoneAccessSupportBins() )
	{
		#if CLIENT
			AddPlayerHint( 0.1, 0, Perks_GetIconForPerk( ePerkIndex.EXTRA_BIN_LOOT ), SUPPORT_BIN_INGAME_LOCKED_HINT )
		#endif
		return false
	}

	return true
}

bool function SupportBin_EntityIsSupportBin( entity ent )
{
	if( ent.GetScriptName() != LOOT_BIN_SCRIPTNAME && ent.GetScriptName() != LOOT_BIN_MARKER_SCRIPTNAME )
		return false
	if( !LootBin_HasSecretCompartment( ent ) )
		return false
	return ent.GetSkin() == ent.GetSkinIndexByName( SUPPORT_LOOT_BIN_SKIN_NAME )
}
#endif

#if SERVER
void function SupportBin_CreateSupportBins()
{
	string mapName = GetMapName()
	if( mapName.find( "mp_rr_box" ) >= 0 )
	{
		SupportBin_SpawnSupportBin( <179.446655, -1803.945679, 128.031250>, <1.367292, 90, 0.000000> )
		SupportBin_SpawnSupportBin( <379.446655, -1803.945679, 128.031250>, <1.367292, 90, 0.000000> )
		SupportBin_SpawnSupportBin( <579.446655, -1803.945679, 128.031250>, <1.367292, 90, 0.000000> )
		SupportBin_SpawnSupportBin( <779.446655, -1803.945679, 128.031250>, <1.367292, 90, 0.000000> )
		SupportBin_SpawnSupportBin( <979.446655, -1803.945679, 128.031250>, <1.367292, 90, 0.000000> )
		SupportBin_SpawnSupportBin( <1079.446655, -1632.418823, 128.031250>, <-0.889343, 180, 0.000000> )
	}
	else if( mapName.find( "mp_rr_qv_map_test_gym" ) >= 0 )
	{
		SupportBin_SpawnSupportBin( <-3264.000000, -16688.000000, 512.000000>, <-0.770010, -0.609985, 0.000000> )
		SupportBin_SpawnSupportBin( <-3264.000000, -16464.000000, 512.000000>, <-0.770010, -0.609985, 0.000000> )
		SupportBin_SpawnSupportBin( <-3264.000000, -16240.000000, 512.000000>, <-0.770010, -0.609985, 0.000000> )
		SupportBin_SpawnSupportBin( <-3264.000000, -16016.000000, 512.000000>, <-0.770010, -0.609985, 0.000000> )
	}
	
	if( LootBin_RandomizePerkBinsFromExistingBins() )
		return

	else if( mapName.find( "mp_rr_divided_moon" ) >= 0 )
	{
		SupportBin_SpawnSupportBin(<-1131.295288, -16441.085938, 2989.774658>, <0.0000, -169.281891, 0.000000>)
		SupportBin_SpawnSupportBin(<-2207.332520, -6445.345703, 2723.428223>, <0, -105.336555, 0.000000>)
		SupportBin_SpawnSupportBin(<-3287.038818, 8349.546875, 2336.331299>, <0, 151.994446, 0.000000>)
		SupportBin_SpawnSupportBin(<15194.943359, -11396.934570, 6186.732910>, <0, -156.720367, 0.000000>)
		SupportBin_SpawnSupportBin(<10280.941406, -27620.144531, 7508.353516>, <0, 90.67, 0.000000>)
		SupportBin_SpawnSupportBin(<24200.550781, -33105.859375, 6639.407715>, <0, 165.346542, 0.000000>)
		SupportBin_SpawnSupportBin(<30209.523438, -20844.626953, 4958.303711>, <0, 90.125641, 0.000000>)
		SupportBin_SpawnSupportBin(<31910.818359, -4768.576172, 3297.541260>, <0, -29.829338, 0.000000>)
		SupportBin_SpawnSupportBin(<31594.734375, -2472.635254, 3369.531250>, <0, 146.910446, 0.000000>)
		SupportBin_SpawnSupportBin(<13668.012695, 17171.294922, 2433.739258>, <0, 23.530317, 0.000000>)
		SupportBin_SpawnSupportBin(<4892.390137, 21310.974609, 1600.834595>, <0, -25.024914, 0.000000>)
		SupportBin_SpawnSupportBin(<-6510.536133, 19632.035156, 1847.278442>, <0, 170.651581, 0.000000>)
		SupportBin_SpawnSupportBin(<-18023.000000, 19507.162109, 1719.548950>, <0, 6.178782, 0.000000>)
		SupportBin_SpawnSupportBin(<15426.090820, 34055.097656, 2208.062500>, <0, -91.393150, 0.000000>)
		SupportBin_SpawnSupportBin(<32500.304688, 25150.093750, 3392.972412>, <0, -178.949936, 0.000000>)
		SupportBin_SpawnSupportBin(<24587.826172, 20216.937500, 1573.870483>, <0, -101.929329, 0.000000>)
		SupportBin_SpawnSupportBin(<15407.572266, -2687.660889, 3788.507813>, <0, -94.417023, 0.000000>)
		SupportBin_SpawnSupportBin(<545.198364, -23320.798828, 5381.545898>, <0, -27.456804, 0.000000>)
		SupportBin_SpawnSupportBin(<-13480.587891, -23919.732422, 2611.364258>, <0, -68.616203, 0.000000>)
		SupportBin_SpawnSupportBin(<-11105.507813, -16638.322266, 3375.657959>, <0, -130.306244, 0.000000>)
		SupportBin_SpawnSupportBin(<-18938.882813, -31725.613281, 3074.123535>, <0, 21.067886, 0.000000>)
		SupportBin_SpawnSupportBin(<-27767.283203, -21271.160156, 2743.257324>, <0, 70.847786, 0.000000>)
		SupportBin_SpawnSupportBin(<-21332.806641, -12092.392578, 2216.011963>, <0, 156.613602, 0.000000>)
		SupportBin_SpawnSupportBin(<-40581.230469, -1767.478149, 969.196533>, <0, -15.319971, 0.000000>)
		SupportBin_SpawnSupportBin(<-22996.919922, 5014.534668, 1397.216919>, <0, -34.429543, 0.000000>)
		SupportBin_SpawnSupportBin(<-29730.507813, 17446.091797, 525.470642>, <0, -100.725731, 0.000000>)
		SupportBin_SpawnSupportBin(<-31889.714844, 29521.134766, 48.016830>, <0, 138.449188, 0.000000>)
		SupportBin_SpawnSupportBin(<-10986.181641, -2659.009277, 2035.547119>, <0, -13.953963, 0.000000>)
		SupportBin_SpawnSupportBin(<-3498.294189, 631.758545, 2112.031250>, <0, 48.335941, 0.000000>)
		SupportBin_SpawnSupportBin(<21301.574219, -9135.566406, 5185.922852>, <0, -129.681396, 0.000000>)
		SupportBin_SpawnSupportBin(<13616.505859, -19409.511719, 5851.642578>, <0, -10.361487, 0.000000>)
		SupportBin_SpawnSupportBin(<14866.543945, -33904.207031, 6387.881836>, <0, 134.808502, 0.000000>)
		SupportBin_SpawnSupportBin(<2777.677734, -32535.339844, 6387.751953>, <0, 42.188553, 0.000000>)
		SupportBin_SpawnSupportBin(<36726.949219, -28859.636719, 5705.067871>, <0, 150.508560, 0.000000>)
		SupportBin_SpawnSupportBin(<28938.462891, -30887.634766, 5288.214355>, <0, 81.538704, 0.000000>)
		SupportBin_SpawnSupportBin(<26754.794922, 10527.109375, 1157.776611>, <0, 17.828911, 0.000000>)
		SupportBin_SpawnSupportBin(<24184.177734, 5068.251465, 1572.940674>, <0, 70.768982, 0.000000>)
		SupportBin_SpawnSupportBin(<7668.509277, 9592.189453, 1147.140259>, <0, 76.808495, 0.000000>)
		SupportBin_SpawnSupportBin(<916.269714, 32348.375000, 1156.496704>, <0, 127.408234, 0.000000>)
		SupportBin_SpawnSupportBin(<8059.892578, 30112.841797, 638.687439>, <0, 99.438324, 0.000000>)
		SupportBin_SpawnSupportBin(<27291.146484, 38029.121094, 3417.316162>, <0, 171.358673, 0.000000>)
		SupportBin_SpawnSupportBin(<32514.691406, 29086.677734, 3655.437500>, <0, -98.611397, 0.000000>)
		SupportBin_SpawnSupportBin(<-10693.644531, 25631.845703, 1975.425049>, <0, -122.731552, 0.000000>)
		SupportBin_SpawnSupportBin(<-39747.996094, 27516.291016, -759.645691>, <0, 134.528351, 0.000000>)
		SupportBin_SpawnSupportBin(<-24844.820313, 7758.928711, 1024.758667>, <0, 164.528442, 0.000000>)
		SupportBin_SpawnSupportBin(<-22242.263672, -4681.000488, 2373.172607>, <0, -161.401749, 0.000000>)
		SupportBin_SpawnSupportBin(<-35116.484375, -8384.340820, 1256.021606>, <0, -14.001414, 0.000000>)
		SupportBin_SpawnSupportBin(<-24148.980469, -36291.910156, 1857.340698>, <0, 69.878914, 0.000000>)
	}
	else if( mapName.find( "mp_rr_desertlands" ) >= 0 )
	{
		SupportBin_SpawnSupportBin(<-1131.295288, -16441.085938, 2989.774658>, <0.0000, -169.281891, 0.000000>)
		SupportBin_SpawnSupportBin(<-2507.887207, -20609.703125, -3644.238770>,<0, -90.753822, 0.000000>)
		SupportBin_SpawnSupportBin(<22508.722656, -21739.658203, -3261.006104>,<0, -68.724442, 0.000000>)
		SupportBin_SpawnSupportBin(<14219.619141, -33921.289063, -2864.185791>,<0, -170.881134, 0.000000>)
		SupportBin_SpawnSupportBin(<19950.296875, -44590.574219, -1980.600586>,<0, 90.370369, 0.000000>)
		SupportBin_SpawnSupportBin(<11299.068359, -41233.277344, -2787.406006>,<0, -57.109642, 0.000000>)
		SupportBin_SpawnSupportBin(<7672.629395, -33124.156250, -2639.817383>,<0, -57.109642, 0.000000>)
		SupportBin_SpawnSupportBin(<-2652.923584, -32583.884766, -3598.341309>,<0, -131.251450, 0.000000>)
		SupportBin_SpawnSupportBin(<-6414.291992, -26529.304688, -4209.006836>,<0, -108.948685, 0.000000>)
		SupportBin_SpawnSupportBin(<-14720.363281, -30385.865234, -2745.981934>,<0, 110.175972, 0.000000>)
		SupportBin_SpawnSupportBin(<-23980.470703, -26507.279297, -4248.076660>,<0, -70.383476, 0.000000>)
		SupportBin_SpawnSupportBin(<-11984.763672, -18942.248047, -3535.951660>,<0, 87.881645, 0.000000>)
		SupportBin_SpawnSupportBin(<-24756.912109, -16708.037109, -3934.081055>,<0, -178.809097, 0.000000>)
		SupportBin_SpawnSupportBin(<-20092.578125, -17657.675781, -4312.118652>,<0, -90.339127, 0.000000>)
		SupportBin_SpawnSupportBin(<-15425.739258, -15977.747070, -2497.843750>,<0, 90.339127, 0.000000>)
		SupportBin_SpawnSupportBin(<-21988.578125, -7874.345215, -2817.488770>,<0, 122.022003, 0.000000>)
		SupportBin_SpawnSupportBin(<-11962.629883, -10890.164063, -3706.232422>,<0, -2.137766, 0.000000>)
		SupportBin_SpawnSupportBin(<-27190.830078, -902.398926, -4428.874512>,<0, -110.094658, 0.000000>)
		SupportBin_SpawnSupportBin(<-26269.595703, 4941.934570, -3169.033447>,<0, -90.263039, 0.000000>)
		SupportBin_SpawnSupportBin(<-29896.224609, 17652.390625, -3008.799805>,<0, -100.727623, 0.000000>)
		SupportBin_SpawnSupportBin(<-8559.703125, 14760.194336, -3113.074219>,<0, 118.835480, 0.000000>)
		SupportBin_SpawnSupportBin(<11732.499023, -13442.250977, -3717.500488>,<0, 177.206497, 0.000000>)
		SupportBin_SpawnSupportBin(<22721.382813, -11067.866211, -4139.164063>,<0, -65.602654, 0.000000>)
		SupportBin_SpawnSupportBin(<-22003.531250, 28748.960938, -3421.124756>,<0, -42.572868, 0.000000>)
		SupportBin_SpawnSupportBin(<-13713.994141, 32031.816406, -3687.968750>,<0, -90.924881, 0.000000>)
		SupportBin_SpawnSupportBin(<-1376.557373, 29901.876953, -2792.153320>,<0, -154.100372, 0.000000>)
		SupportBin_SpawnSupportBin(<5666.501953, 24751.576172, -4496.815430>,<0, -39.788544, 0.000000>)
		SupportBin_SpawnSupportBin(<18652.855469, 19595.984375, -3887.968750>,<0, -135.062332, 0.000000>)
		SupportBin_SpawnSupportBin(<16053.322266, 33918.011719, -4640.163574>,<0, 90.540894, 0.000000>)
		SupportBin_SpawnSupportBin(<26259.822266, 18086.902344, -3933.979492>,<0, 2.396671, 0.000000>)
		SupportBin_SpawnSupportBin(<26203.947266, 8576.843750, -3055.968750>,<0, -179.859879, 0.000000>)
		SupportBin_SpawnSupportBin(<22942.687500, -3422.002197, -3983.968750>,<0, 171.725998, 0.000000>)
		SupportBin_SpawnSupportBin(<7960.348145, -492.535736, -3540.766846>,<0, 37.812256, 0.000000>)
	}
	else if( mapName.find( "mp_rr_canyonlands" ) >= 0 )
	{
		SupportBin_SpawnSupportBin(<7968.597168, -25598.923828, 2936.031250>, <0.0000, -2.850097, 0.000000>)
		SupportBin_SpawnSupportBin(<15172.991211, -25694.015625, 2705.086670>, <0.0000, -150.109863, 0.000000>)
		SupportBin_SpawnSupportBin(<27833.433594, -14875.214844, 4664.031250>, <0.0000, -1.804599, 0.000000>)
		SupportBin_SpawnSupportBin(<2653.785400, -26037.021484, 2816.031250>, <0.0000, 133.804599, 0.000000>)
		SupportBin_SpawnSupportBin(<-1429.526123, -17122.904297, 2916.031250>, <0.0000, -60.240002, 0.000000>)
		SupportBin_SpawnSupportBin(<-15984.072266, -20517.234375, 3000.062500>, <0.0000, 106.051552, 0.000000>)
		SupportBin_SpawnSupportBin(< -6729.582031, -22326.443359, 3000.062500>, <0.0000, 151.041595, 0.000000>)
		SupportBin_SpawnSupportBin(< -15655.551758, -8602.662109, 3080.062500>, <0.0000, 178.211609, 0.000000>)
		SupportBin_SpawnSupportBin(<-18230.671875, -7249.030273, 2755.555420>, <0.0000, -29.248476, 0.000000>)
		SupportBin_SpawnSupportBin(<-9302.790039, -2356.756104, 2899.133789>, <0.0000, 55.231728, 0.000000>)
		SupportBin_SpawnSupportBin(< -22863.091797, -70.969933, 3192.031250>, <0.0000, 179.971619, 0.000000>)
		SupportBin_SpawnSupportBin(< -20367.527344, 2323.329102, 3007.62207>, <0.0000, -88.648422, 0.000000>)
		SupportBin_SpawnSupportBin(< -1243.412109, 240.910645, 2056.031250>, <0.0000, -83.321159, 0.000000>)
		SupportBin_SpawnSupportBin(< -5010.971191, 4579.810547, 2172.372070>, <0.0000, -54.671257, 0.000000>)
		SupportBin_SpawnSupportBin(<-14621.654297, 11480.054688, 3231.154053>, <0.0000, 179.738876, 0.000000>)
		SupportBin_SpawnSupportBin(<-29800.642578, 12102.803711, 3123.829346>, <0.0000, 177.035950, 0.000000>)
		SupportBin_SpawnSupportBin(<-25917.246094, 11075.884766, 2918.406006>, <0.0000, 85.546005, 0.000000>)
		SupportBin_SpawnSupportBin(<-29538.591797, 15013.742188, 3359.130859>, <0.0000, 57.376492, 0.000000>)
		SupportBin_SpawnSupportBin(<-26752.515625, 25249.009766, 1772.031250>, <0.0000, -137.043610, 0.000000>)
		SupportBin_SpawnSupportBin(<-23329.658203, 24078.873047, 1661.025024>, <0.0000, 137.486267, 0.000000>)
		SupportBin_SpawnSupportBin(<-14257.627930, 27270.779297, 3182.959717>, <0.0000, 144.556503, 0.000000>)
		SupportBin_SpawnSupportBin(<-10019.028320, 11197.424805, 2752.031250>, <0.0000, 89.853569, 0.000000>)
		SupportBin_SpawnSupportBin(<-9263.607422, 11974.882813, 2752.031250>, <0.0000, -89.996376, 0.000000>)
		SupportBin_SpawnSupportBin(<-9350.210938, 21377.601563, 2815.406250>, <0.0000, -46.264122, 0.000000>)
		SupportBin_SpawnSupportBin(<-12772.659180, 35478.699219, 4984.031250>, <0.0000, -90.863869, 0.000000>)
		SupportBin_SpawnSupportBin(<-14309.606445, 38517.164063, 5092.406250>, <0.0000, 131.636139, 0.000000>)
		SupportBin_SpawnSupportBin(<-1054.112183, 36745.625000, 5200.031250>, <0.0000, -46.093758, 0.000000>)
		SupportBin_SpawnSupportBin(<4774.536133, 38401.390625, 5081.177734>, <0.0000, 134.526321, 0.000000>)
		SupportBin_SpawnSupportBin(<7941.716797, 26224.746094, 4896.004395>, <0.0000, 107.716354, 0.000000>)
		SupportBin_SpawnSupportBin(<9495.489258, 18609.105469, 5187.321289>, <0.0000, -9.184677, 0.000000>)
		SupportBin_SpawnSupportBin(<15709.515625, 23592.726563, 4992.889648>, <0.0000, -161.615509, 0.000000>)
		SupportBin_SpawnSupportBin(<24441.726563, 22399.390625, 3844.031250>, <0.0000, 179.104385, 0.000000>)
		SupportBin_SpawnSupportBin(<27678.902344, 25186.755859, 4032.187988>, <0.0000, 88.494911, 0.000000>)
		SupportBin_SpawnSupportBin(<31331.908203, 18485.242188, 3648.031250>, <0.0000, 179.905731, 0.000000>)
		SupportBin_SpawnSupportBin(<35535.808594, 13242.381836, 3456.031250>, <0.0000, 43.981094, 0.000000>)
		SupportBin_SpawnSupportBin(<36634.695313, 9708.471680, 2856.031250>, <0.0000, 104.781097, 0.000000>)
		SupportBin_SpawnSupportBin(<35409.632813, 7443.637695, 2810.979248>, <0.0000, -92.278587, 0.000000>)
		SupportBin_SpawnSupportBin(<34944.855469, 1462.285034, 3469.078125>, <0.0000, -58.978134, 0.000000>)
		SupportBin_SpawnSupportBin(<31397.005859, -1698.781006, 3145.031250>, <0.0000, 16.122026, 0.000000>)
		SupportBin_SpawnSupportBin(<21128.242188, -3485.387451, 4200.031250>, <0.0000, -90.608055, 0.000000>)
		SupportBin_SpawnSupportBin(<19240.029297, -4238.026367, 4976.018066>, <0.0000, -150.327148, 0.000000>)
		SupportBin_SpawnSupportBin(<9958.283203, -10305.747070, 1918.909424>, <0.0000, 15.886454, 0.000000>)
		SupportBin_SpawnSupportBin(<15660.795898, -14668.745117, 3672.031250>, <0.0000, -58.553730, 0.000000>)
	}
	else if( mapName.find( "mp_rr_olympus" ) >= 0 )
	{
		SupportBin_SpawnSupportBin(<-6419.283691, -19572.191406, -5664.288574>, <0.0000, -36.912457, 0.000000>)
		SupportBin_SpawnSupportBin(<-11105.683594, -25883.556641, -4230.865234>, <0.0000, -159.482513, 0.000000>)
		SupportBin_SpawnSupportBin(<-11391.077148, -29610.689453, -4040.519043>, <0.0000, -47.832642, 0.000000>)
		SupportBin_SpawnSupportBin(<2854.115723, -24198.509766, -6055.937500>, <0.0000, 33.097179, 0.000000>)
		SupportBin_SpawnSupportBin(<14514.232422, -29065.494141, -5724.968750>, <0.0000, 32.437592, 0.000000>)
		SupportBin_SpawnSupportBin(<20298.691406, -29592.419922, -6072.968750>, <0.0000, 158.687851, 0.000000>)
		SupportBin_SpawnSupportBin(<22436.740234, -27015.480469, -5895.578125>, <0.0000, -103.276398, 0.000000>)
		SupportBin_SpawnSupportBin(<12316.646484, -18334.302734, -5683.968750>, <0.0000, -175.432190, 0.000000>)
		SupportBin_SpawnSupportBin(<3990.484619, -29141.009766, -4686.337891>, <0.0000, 23.527582, 0.000000>)
		SupportBin_SpawnSupportBin(<23539.193359, -10466.150391, -5439.968750>, <0.0000, -81.552544, 0.000000>)
		SupportBin_SpawnSupportBin(<23242.255859, -11488.252930, -5439.900391>, <0.0000, -80.922569, 0.000000>)
		SupportBin_SpawnSupportBin(<11059.781250, -7439.607910, -5231.968750>, <0.0000, -52.794338, 0.000000>)
		SupportBin_SpawnSupportBin(<7179.551758, -9889.008789, -5231.968750>, <0.0000, -44.574554, 0.000000>)
		SupportBin_SpawnSupportBin(<24495.847656, 45.160534, -3706.553467>, <0.0000, 14.055574, 0.000000>)
		SupportBin_SpawnSupportBin(<16473.248047, 1973.831177, -4727.968750>, <0.0000, -115.084457, 0.000000>)
		SupportBin_SpawnSupportBin(<12942.961914, 16076.003906, -3797.015625>, <0.0000, -47.904583, 0.000000>)
		SupportBin_SpawnSupportBin(<16789.416016, 17580.636719, -4608.199219>, <0.0000, -89.154488, 0.000000>)
		SupportBin_SpawnSupportBin(<20701.742188, 19580.187500, -4848.095215>, <0.0000, 160.765625, 0.000000>)
		SupportBin_SpawnSupportBin(<11408.005859, 25920.894531, -5205.714355>, <0.0000, -161.203918, 0.000000>)
		SupportBin_SpawnSupportBin(<8886.485352, 27719.496094, -5073.925781>, <0.0000, 148.745224, 0.000000>)
		SupportBin_SpawnSupportBin(<1149.983643, 26341.941406, -5895.968750>, <0.0000, 65.885078, 0.000000>)
		SupportBin_SpawnSupportBin(<25567.207031, 13644.332031, -3693.049072>, <0.0000, 70.285225, 0.000000>)
		SupportBin_SpawnSupportBin(<28600.892578, 13800.724609, -3693.048828>, <0.0000, 115.685295, 0.000000>)
		SupportBin_SpawnSupportBin(<22463.927734, 6859.916992, -3453.985840>, <0.0000, 179.045486, 0.000000>)
		SupportBin_SpawnSupportBin(<-19223.019531, -29527.337891, -4663.968750>, <0.0000, 88.104950, 0.000000>)
		SupportBin_SpawnSupportBin(<-24886.494141, -23462.019531, -5049.739258>, <0.0000, -105.714920, 0.000000>)
		SupportBin_SpawnSupportBin(<-23758.882813, -19713.421875, -5211.968750>, <0.0000, 74.105080, 0.000000>)
		SupportBin_SpawnSupportBin(<-21938.478516, -11719.400391, -5235.955566>, <0.0000, -15.324977, 0.000000>)
		SupportBin_SpawnSupportBin(<-16055.066406, -14594.179688, -5232.750977>, <0.0000, -89.574989, 0.000000>)
		SupportBin_SpawnSupportBin(<-13270.079102, -12405.007813, -5299.979492>, <0.0000, -98.265007, 0.000000>)
		SupportBin_SpawnSupportBin(<-12372.312500, -18934.445313, -5047.940430>, <0.0000, -122.715179, 0.000000>)
		SupportBin_SpawnSupportBin(<-7728.701172, -22508.105469, -5095.942871>, <0.0000, 56.994846, 0.000000>)
		SupportBin_SpawnSupportBin(<-9952.277344, -17969.576172, -5395.848633>, <0.0000, -39.475193, 0.000000>)
		SupportBin_SpawnSupportBin(<-7491.967773, -12350.956055, -5519.968750>, <0.0000, -85.344986, 0.000000>)
		SupportBin_SpawnSupportBin(<-3958.018066, -9276.017578, -5627.141602>, <0.0000, -74.455009, 0.000000>)
		SupportBin_SpawnSupportBin(<-28110.910156, -8164.302246, -4312.611816>, <0.0000, 69.144928, 0.000000>)
		SupportBin_SpawnSupportBin(<-35367.109375, -1255.551758, -4345.968750>, <0.0000, 36.394691, 0.000000>)
		SupportBin_SpawnSupportBin(<-33265.136719, 104.255669, -4343.968750>, <0.0000, -52.815117, 0.000000>)
		SupportBin_SpawnSupportBin(<-39533.589844, -4015.149414, -3879.968750>, <0.0000, -8.375250, 0.000000>)
		SupportBin_SpawnSupportBin(<-38106.410156, -10305.999023, -4007.952881>, <0.0000, 53.774868, 0.000000>)
		SupportBin_SpawnSupportBin(<-36947.882813, -7080.143555, -4271.968750>, <0.0000, 3.914944, 0.000000>)
		SupportBin_SpawnSupportBin(<-17988.699219, 3431.349854, -5355.96875>, <0.0000, -120.855026, 0.000000>)
		SupportBin_SpawnSupportBin(<-32155.013672, 2279.446045, -5001.609375>, <0.0000, 102.242966, 0.000000>)
		SupportBin_SpawnSupportBin(<-36212.570313, 11638.897461, -5563.968750>, <0.0000, -174.486755, 0.000000>)
		SupportBin_SpawnSupportBin(<-27668.265625, 9517.651367, -6122.968750>, <0.0000, 89.513489, 0.000000>)
		SupportBin_SpawnSupportBin(<-20977.222656, 11274.329102, -5719.957520>, <0.0000, -91.986557, 0.000000>)
		SupportBin_SpawnSupportBin(<-36182.847656, 13933.032227, -5563.968750>, <0.0000, 161.314163, 0.000000>)
		SupportBin_SpawnSupportBin(<-33592.476563, 23565.576172, -6729.246094>, <0.0000, 140.994186, 0.000000>)
		SupportBin_SpawnSupportBin(<-29791.666016, 20584.812500, -6511.968750>, <0.0000, 128.534225, 0.000000>)
		SupportBin_SpawnSupportBin(<-33328.191406, 20597.041016, -6727.946777>, <0.0000, 39.544392, 0.000000>)
		SupportBin_SpawnSupportBin(<-18670.404297, 14245.001953, -6407.948242>, <0.0000, -55.935673, 0.000000>)
		SupportBin_SpawnSupportBin(<-12099.025391, 21809.068359, -6402.744629>, <0.0000, 2.804365, 0.000000>)
		SupportBin_SpawnSupportBin(<-24900.863281, 32841.804688, -6807.955078>, <0.0000, -10.836228, 0.000000>)
		SupportBin_SpawnSupportBin(<-20666.722656, 37932.953125, -6807.955078>, <0.0000, -68.396164, 0.000000>)
		SupportBin_SpawnSupportBin(<-4013.237549, 32739.851563, -6147.940430>, <0.0000, -176.936172, 0.000000>)
		SupportBin_SpawnSupportBin(<-840.971863, 31834.414063, -5732.968750>, <0.0000, -100.375931, 0.000000>)
		SupportBin_SpawnSupportBin(<-289.259308, 16815.800781, -5143.968750>, <0.0000, 42.813908, 0.000000>)
		SupportBin_SpawnSupportBin(<-5772.169922, 14610.381836, -5838.206055>, <0.0000, 33.669971, 0.000000>)
		SupportBin_SpawnSupportBin(<-8190.692383, 11732.327148, -5884.218262>, <0.0000, 23.630043, 0.000000>)
		SupportBin_SpawnSupportBin(<-16141.055664, 7685.586914, -6397.514648>, <0.0000, 23.629854, 0.000000>)
	}
	else if( mapName.find( "mp_rr_tropic_island" ) >= 0 )
	{
		SupportBin_SpawnSupportBin(<-3498.294189, 631.758545, 2112.031250>, <0, 48.335941, 0.000000>)
		SupportBin_SpawnSupportBin(<7481.141113, 43295.332031, 4139.373535>, <0, 27.100258, 0.000000>)
		SupportBin_SpawnSupportBin(<12412.999023, 47340.574219, 5673.526855>, <0, -88.736092, 0.000000>)
		SupportBin_SpawnSupportBin(<18581.382813, 43577.578125, 8641.759766>, <0, 89.873932, 0.000000>)
		SupportBin_SpawnSupportBin(<29326.267578, 36272.179688, 9886.513672>, <0, 10.924163, 0.000000>)
		SupportBin_SpawnSupportBin(<25539.710938, 37497.539063, 9952.062500>, <0, 44.061832, 0.000000>)
		SupportBin_SpawnSupportBin(<20130.986328, 31682.884766, 7980.347656>, <0, -81.398430, 0.000000>)
		SupportBin_SpawnSupportBin(<22071.808594, 30866.363281, 8348.805664>, <0, -39.348362, 0.000000>)
		SupportBin_SpawnSupportBin(<28506.646484, 31855.486328, 10395.987305>, <0, -5.828393, 0.000000>)
		SupportBin_SpawnSupportBin(<36587.058594, 33163.785156, 10976.654297>, <0, 126.801758, 0.000000>)
		SupportBin_SpawnSupportBin(<41672.886719, 27460.916016, 10141.734375>, <0, 30.771755, 0.000000>)
		SupportBin_SpawnSupportBin(<43224.476563, 23115.587891, 9973.734375>, <0, -1.348097, 0.000000>)
		SupportBin_SpawnSupportBin(<39880.632813, 21342.744141, 9776.783203>, <0, 162.191818, 0.000000>)
		SupportBin_SpawnSupportBin(<27646.451172, 26252.003906, 9412.061523>, <0, 74.332169, 0.000000>)
		SupportBin_SpawnSupportBin(<26074.843750, 16899.488281, 5498.048340>, <0, -75.187881, 0.000000>)
		SupportBin_SpawnSupportBin(<31151.453125, 12106.083008, 5721.152832>, <0, 71.962112, 0.000000>)
		SupportBin_SpawnSupportBin(<31214.271484, 8626.111328, 5958.042969>, <0, 164.001968, 0.000000>)
		SupportBin_SpawnSupportBin(<41156.187500, 13555.677734, 7560.031250>, <0, -8.782520, 0.000000>)
		SupportBin_SpawnSupportBin(<42875.210938, 13287.451172, 7560.031250>, <0, 171.147659, 0.000000>)
		SupportBin_SpawnSupportBin(<41586.019531, 11678.125000, 7520.031250>, <0, -40.602432, 0.000000>)
		SupportBin_SpawnSupportBin(<36326.191406, 1731.707275, 2688.909180>, <0, 91.587669, 0.000000>)
		SupportBin_SpawnSupportBin(<31986.142578, -4450.061035, 1704.062500>, <0, -20.202381, 0.000000>)
		SupportBin_SpawnSupportBin(<34285.949219, -4104.206055, 1565.392456>, <0, -19.102551, 0.000000>)
		SupportBin_SpawnSupportBin(<20723.218750, -2968.361328, 462.031250>, <0, 71.837631, 0.000000>)
		SupportBin_SpawnSupportBin(<21488.617188, -3188.899902, 462.031250>, <0, 73.347534, 0.000000>)
		SupportBin_SpawnSupportBin(<17471.755859, -4054.220703, 274.031250>, <0, 156.422653, 0.000000>)
		SupportBin_SpawnSupportBin(<33404.027344, -14408.582031, 208.569244>, <0, -30.137720, 0.000000>)
		SupportBin_SpawnSupportBin(<20800.380859, -18989.542969, 269.024536>, <0, -143.578003, 0.000000>)
		SupportBin_SpawnSupportBin(<28979.568359, -18448.310547, 1670.031250>, <0, -78.958099, 0.000000>)
		SupportBin_SpawnSupportBin(<34582.300781, -30642.115234, 64.062027>, <0, 90.961884, 0.000000>)
		SupportBin_SpawnSupportBin(<15084.445313, -32281.460938, 1113.888672>, <0, -34.805885, 0.000000>)
		SupportBin_SpawnSupportBin(<4771.704590, -28609.976563, 1280.684814>, <0, 32.578663, 0.000000>)
		SupportBin_SpawnSupportBin(<4288.205566, -22280.814453, 736.031250>, <0, -18.76732, 0.000000>)
		SupportBin_SpawnSupportBin(<2505.546631, -13384.299805, 736.031250>, <0, 43.016151, 0.000000>)
		SupportBin_SpawnSupportBin(<14628.573242, -14814.434570, 752.031250>, <0, -163.167450, 0.000000>)
		SupportBin_SpawnSupportBin(<4349.117676, -41883.800781, 814.785217>, <0, -75.555519, 0.000000>)
		SupportBin_SpawnSupportBin(<-17115.380859, -38120.179688, 893.895508>, <0, -2.907555, 0.000000>)
		SupportBin_SpawnSupportBin(<-36782.746094, -25692.052734, 153.358246>, <0, 75.684784, 0.000000>)
		SupportBin_SpawnSupportBin(<-40226.085938, -8530.501953, 12.081218>, <0, -54.355427, 0.000000>)
		SupportBin_SpawnSupportBin(<-35988.496094, -1174.541138, 108.189926>, <0, 3.394802, 0.000000>)
		SupportBin_SpawnSupportBin(<-32309.167969, -9146.125000, 70.286629>, <0, 83.584641, 0.000000>)
		SupportBin_SpawnSupportBin(<-25813.429688, -4310.500977, 54.963413>, <0, -3.315724, 0.000000>)
		SupportBin_SpawnSupportBin(<-38376.773438, 5870.051270, 443.407440>, <0, -29.681482, 0.000000>)
		SupportBin_SpawnSupportBin(<-30725.429688, 15990.987305, 55.648987>, <0, 83.605743, 0.000000>)
		SupportBin_SpawnSupportBin(<-7726.445313, 1381.983643, 440.407501>, <0, 0.408512, 0.000000>)
		SupportBin_SpawnSupportBin(<-482.527649, 1931.501831, 659.127014>, <0, 90.566933, 0.000000>)
		SupportBin_SpawnSupportBin(<9070.375977, 6762.979004, 1464.031250>, <0, 156.757004, 0.000000>)
		SupportBin_SpawnSupportBin(<-4283.150879, 18491.214844, 1486.733643>, <0, 14.645768, 0.000000>)
		SupportBin_SpawnSupportBin(<778.918335, 23580.654297, 2727.015137>, <0, 34.115971, 0.000000>)
		SupportBin_SpawnSupportBin(<-16765.685547, 31967.636719, 66.158211>, <0, -101.954063, 0.000000>)
		SupportBin_SpawnSupportBin(<-26639.621094, 36542.937500, 192.627243>, <0, 121.206093, 0.000000>)
		SupportBin_SpawnSupportBin(<-17290.115234, 14352.173828, 1775.495850>, <0, -25.018740, 0.000000>)
		SupportBin_SpawnSupportBin(<6245.505859, -39324.292969, 854.992737>, <0, 172.675537, 0.000000>)
		SupportBin_SpawnSupportBin(<-15161.300781, -13802.977539, 10.668710>, <0, 31.190575, 0.000000>)
		SupportBin_SpawnSupportBin(<-7091.320801, -18410.662109, 46.253666>, <0, -93.689774, 0.000000>)
		SupportBin_SpawnSupportBin(<-26572.804688, 25032.068359, 67.434151>, <0, 123.394386, 0.000000>)
		SupportBin_SpawnSupportBin(<17190.835938, -27044.013672, 47.617672>, <0, 50.179958, 0.000000>)
	}

	SupportBin_RandomizeAvailableSupportBins()

	printt( "[SUPPORT BIN COUNT]: " + file.activeSupportBins.len() )
}

bool function SupportBin_GuaranteeBattery()
{
	return GetCurrentPlaylistVarBool( "support_bin_guarantee_battery", true )
}

bool function SupportBin_SmartEquipment()
{
	return GetCurrentPlaylistVarBool( "support_bin_smart_equipment", true )
}

entity function SupportBin_SpawnSupportBinFromExistingBin( entity bin )
{
	entity newBin = SupportBin_SpawnSupportBin(bin.GetOrigin(), bin.GetAngles())
	if (IsValid(bin.GetParent()))
		newBin.SetParent( bin.GetParent() )
	LootBin_TransferLootBinServerData( bin, newBin, eLootBinCompartment.REGULAR )
	return newBin
}

entity function SupportBin_SpawnSupportBin( vector origin, vector angles )
{
	entity lootBin = CreateLootBin(origin, angles, false, false, true)

	if( IsValid( lootBin ) )
	{
		InitLootBin( lootBin )

		lootBin.SetSkin( lootBin.GetSkinIndexByName( SUPPORT_LOOT_BIN_SKIN_NAME ) )

		if( !LootBin_RandomizePerkBinsFromExistingBins() )
		{
			// Logic for filling regular compartment
			array<string> regularLootRefs

			if ( !SupportBin_UseBasicLootConfiguration() )
			{
				regularLootRefs = SURVIVAL_GetMultipleWeightedItemsFromGroup( "secret_bin_loot", 5 ) //grab the loot that will load into the regular compartment of the bin
			}
			else
			{
				regularLootRefs = SURVIVAL_GetMultipleWeightedItemsFromGroup( "Zone_Medium", 4 ) //grab basic loot that will load into the regular compartment of the bin
				regularLootRefs.extend( SURVIVAL_GetMultipleWeightedItemsFromGroup( "secret_bin_loot", 1 ) ) //add potential for survival/big heals if using basic loot configuration.
			}
			LootBin_PutMultipleLootItemsInside( lootBin, eLootBinCompartment.REGULAR, regularLootRefs )
		}

		// Logic for filling secret compartment
		int numSurvivalItems 		= GetCurrentPlaylistVarInt( "survival_lootbins_survival_items", 1 ) //set the number of potential survival items in the bin. no guarantees.
		int numSecretSlots           = GetCurrentPlaylistVarInt( "survival_lootbins_secret_slots", 3 ) //set the number of slots of secret loot the secret compartment will have
		int numSecretSlotsNoSurvival = GetCurrentPlaylistVarInt( "survival_lootbins_secret_slots_no_survival_item", 4 )
		array<string> secretLootRefs

		if(!SupportBin_UseBasicLootConfiguration())
		{
			secretLootRefs = SURVIVAL_GetMultipleWeightedItemsFromGroup( "secret_bin_loot_survival", numSurvivalItems ) //grab the loot that will load into the secret compartment of the bin
			secretLootRefs.extend( SURVIVAL_GetMultipleWeightedItemsFromGroup( "secret_bin_loot", numSecretSlots ) )
		}
		else if ( SupportBin_RemoveSurvivalItemsFromBaseRoll() )
		{
			secretLootRefs = SURVIVAL_GetMultipleWeightedItemsFromGroup( "secret_bin_loot_improved", numSecretSlotsNoSurvival )
		}
		else
		{
			secretLootRefs= SURVIVAL_GetMultipleWeightedItemsFromGroup( "secret_bin_loot_survival", numSurvivalItems ) //grab the loot that will load into the secret compartment of the bin
			secretLootRefs.extend( SURVIVAL_GetMultipleWeightedItemsFromGroup( "secret_bin_loot_improved", numSecretSlots ) )
		}

		//if we want to remove survival items and secrete loot that may be restricted from ground loot based on rotation. iterate over the items and check against the disable loot lists.
		if( SupportBin_ResepectGroundLootRotation() )
		{
			int secretLootCount = secretLootRefs.len()
			array<string> disabledLootRefs = Crafting_GetDisabledGroundLoot()

			for ( int i = 0; i < secretLootCount; ++i )
			{
				if( disabledLootRefs.contains( secretLootRefs[i] ) || SURVIVAL_Loot_IsRefDisabled( secretLootRefs[i] ) )
				{
					if( LootBin_RotatingLoot_RefilledInPerkBins_Enabled() )
					{
						secretLootRefs[i] = SURVIVAL_GetWeightedItemFromGroup( "secret_bin_loot_improved" )
					}
					else
					{
						secretLootRefs[i] = SURVIVAL_GetWeightedItemFromGroup( "secret_bin_loot_meds" )
					}
				}
			}
		}

		SupportBin_SmoothSecretLootContents( secretLootRefs )

		LootBin_PutMultipleLootItemsInside( lootBin, eLootBinCompartment.SECRET, secretLootRefs )

		AddCallback_CanOpenLootBin( lootBin, SupportBin_CanUseSupportBin )

		LootBin_SetAddItemsToBinOnOpenCallback( lootBin, SupportBin_MaybeAddSurvivalLootBinOnOpen )

		Perks_AddMinimapEntityForPerk( ePerkIndex.EXTRA_BIN_LOOT, lootBin )

		file.activeSupportBins.append(lootBin)
	}

	return lootBin
}

void function SupportBin_SmoothSecretLootContents( array<string> lootRefs )
{
	int bigHealCount = 0
	int medKitCount = 0
	int battCount = 0
	int pheonixCount = 0

	for( int i = 0; i < lootRefs.len(); i++ )
	{
		bool isBigHeal = false
		bool isMedKit = false
		bool isBatt = false
		bool isPheonix = false

		string ref = lootRefs[i]

		LootData lootItem = SURVIVAL_Loot_GetLootDataByRef( ref )

		if( ref.find( LOOT_ITEM_MEDKIT_NAME ) >= 0 || ref.find( LOOT_ITEM_BATTERY_NAME ) >= 0 || ref.find( LOOT_ITEM_PHEONIX_NAME ) >= 0 )
		{
			isBigHeal = true
			bigHealCount++

			if( ref.find( LOOT_ITEM_MEDKIT_NAME ) >= 0 )
			{
				isMedKit = true
				medKitCount++
			}

			if( ref.find( LOOT_ITEM_BATTERY_NAME ) >= 0 )
			{
				isBatt = true
				battCount++
			}

			if( ref.find( LOOT_ITEM_PHEONIX_NAME ) >= 0 )
			{
				isPheonix = true
				pheonixCount++
			}
		}

		if( isPheonix && pheonixCount > 1 ) //never more than 1 pheonix, re-roll big heal to replace it
		{
			if( bigHealCount < SupportBin_Get_MaxBigHealInSecretLoot() )
			{
				string newRef = SURVIVAL_GetWeightedItemFromGroup( "secret_bin_loot_big_heal" )

				if( newRef.find( LOOT_ITEM_MEDKIT_NAME ) >= 0 )
				{
					isMedKit = true
					medKitCount++
				}

				if( newRef.find( LOOT_ITEM_BATTERY_NAME ) >= 0 )
				{
					isBatt = true
					battCount++
				}

				lootRefs[i] = newRef

				isPheonix = false
				pheonixCount--
			}
			else
			{
				lootRefs[i] = SURVIVAL_GetWeightedItemFromGroup( "secret_bin_loot_small_heal" )
				isPheonix = false
				pheonixCount--
				bigHealCount--
			}
		}

		if( isBigHeal && bigHealCount > SupportBin_Get_MaxBigHealInSecretLoot() ) //if too many big heals re-roll as small heal
		{
			lootRefs[i] = SURVIVAL_GetWeightedItemFromGroup( "secret_bin_loot_small_heal" )
			isMedKit = false
			isBatt = false
			isBigHeal = false
			bigHealCount--
		}

		if( pheonixCount == 1 && !isPheonix && isMedKit && medKitCount > 0) //if pheonix and medkit spawned at the same time re-roll the medkit for chance at a batt
		{
			string newRef = SURVIVAL_GetWeightedItemFromGroup( "secret_bin_loot_big_heal" )

			if( newRef.find( LOOT_ITEM_MEDKIT_NAME ) >= 0 )
			{
				isMedKit = true
			}

			if( newRef.find( LOOT_ITEM_BATTERY_NAME ) >= 0 )
			{
				isBatt = true
				isMedKit = false
				battCount++
				medKitCount--
			}

			lootRefs[i] = newRef
		}

	}

	if( SupportBin_GuaranteeBattery() )
	{

		bool foundBat = false
		for( int i = 0; i < lootRefs.len(); i++ )
		{
			string ref = lootRefs[i]
			if( ref.find( LOOT_ITEM_BATTERY_NAME ) >= 0 )
			{
				foundBat = true
				break
			}
		}

		if( !foundBat )
		{
			lootRefs[RandomIntRange(0, lootRefs.len())] = LOOT_ITEM_BATTERY_NAME
		}
	}
}

void function SupportBin_Callback_RoundChangeUpdate( table<int, DeathFieldData> deathFieldData )
{
	SupportBin_RefillBins_ScaledLoot()
}

void function SupportBin_RefillBins_ScaledLoot()
{
	bool armorFillAllowed = SupportBin_AllowArmorLootInBins()
	bool onlyRefillSecret = SupportBin_OnlyScaleSecretLoot()

	foreach( lootBin in file.activeSupportBins )
	{
		if(!onlyRefillSecret)
			LootBin_EmptyBinOfLoot(lootBin, true, true)
		else
			LootBin_EmptyBinOfLoot(lootBin, false, true)

		array<string> lootRegularAlreadyInBin  //= LootBin_GetLootRefs( lootBin, true, false )
		array<string> lootSecretAlreadyInBin  //= LootBin_GetLootRefs( lootBin, false, true )

		array<string> lootToRefillRegularBin
		array<string> lootToRefillSecretBin

		int numRefillItems 		= GetCurrentPlaylistVarInt( "survival_lootbins_refill_itemscount", 5 )

		if (armorFillAllowed)
		{
			numRefillItems--
		}

		int numRefillSecretItems 		= GetCurrentPlaylistVarInt( "survival_lootbins_refill_secretitemscount", 3 )
		int currentStage = SURVIVAL_GetCurrentDeathFieldStage( 0 )

		lootToRefillRegularBin = SURVIVAL_GetMultipleWeightedItemsFromGroup( scaledRegularLootTables[currentStage], numRefillItems )
		lootToRefillSecretBin = SURVIVAL_GetMultipleWeightedItemsFromGroup( scaledSecretLootTables[currentStage], numRefillSecretItems )

		if(armorFillAllowed)
			lootToRefillRegularBin.append( SURVIVAL_GetWeightedItemFromGroup( armorAdditionLootTables[currentStage]) )

		if(!onlyRefillSecret)
			LootBin_PutMultipleLootItemsInside( lootBin, eLootBinCompartment.REGULAR, lootToRefillRegularBin )

		LootBin_PutMultipleLootItemsInside( lootBin, eLootBinCompartment.SECRET, lootToRefillSecretBin )
	}
}

void function SupportBin_RotatingLoot_RefillBins_BothCompartments()
{
	if( !LootBin_RotatingLoot_RefilledInPerkBins_Enabled() )
		return

	bool rotatingGearAllowed = SupportBin_RotatingLoot_MainLoot_AllowGearSpawns()
	bool refillSecret = SupportBin_RotatingLoot_Refill_SecretLoot()
	bool refillMain = SupportBin_RotatingLoot_Refill_MainLoot()

	foreach( lootBin in file.activeSupportBins )
	{
		if( !SupportBin_EntityIsSupportBin( lootBin ) )
			continue

		if( refillMain )
			LootBin_EmptyBinOfLoot( lootBin, true, false )

		if( refillSecret )
			LootBin_EmptyBinOfLoot( lootBin, false, true )

		array<string> lootToRefillRegularBin
		array<string> lootToRefillSecretBin

		int numRefillItems 		= GetCurrentPlaylistVarInt( "supportbin_rotatingloot_refill_itemscount", 5 )

		if ( rotatingGearAllowed )
		{
			numRefillItems--
		}

		int numRefillSecretItems 		= GetCurrentPlaylistVarInt( "supportbin_rotatingloot_refill_secretitemscount", 4 )
		int currentStage = SURVIVAL_GetCurrentDeathFieldStage( 0 )

		if( refillMain )
		{
			lootToRefillRegularBin.append( SURVIVAL_GetWeightedItemFromGroup( "secret_bin_loot_big_heal" ) )
			lootToRefillRegularBin.extend( SURVIVAL_GetMultipleWeightedItemsFromGroup( "support_bin_rotating_main_loot", numRefillItems - 1 ) )
		}

		if( refillSecret )
			lootToRefillSecretBin = SURVIVAL_GetMultipleWeightedItemsFromGroup( "secret_bin_loot_survival", numRefillSecretItems )

		if( rotatingGearAllowed )
		{
			string lootRefToAdd = ""

			array<string> possibleRotatingGearToAdd = Crafting_GetCraftingItemsByCategoryName( "equipment" )

			if( possibleRotatingGearToAdd.len() > 0 )
			{
				for( int i = possibleRotatingGearToAdd.len() - 1; i >= 0; i-- )
				{

					string itemString
					printt( "Possible Equipment Item " + itemString )
					if( itemString == " " )
						possibleRotatingGearToAdd.fastremove( i )
				}

				lootRefToAdd = possibleRotatingGearToAdd[ RandomInt( possibleRotatingGearToAdd.len() - 1 ) ]
			}

			if( lootRefToAdd != "" )
				lootToRefillRegularBin.append( lootRefToAdd )
		}

		if( lootToRefillRegularBin.len() > 0 )
			LootBin_PutMultipleLootItemsInside( lootBin, eLootBinCompartment.REGULAR, lootToRefillRegularBin )

		if( lootToRefillSecretBin.len() > 0 )
			LootBin_PutMultipleLootItemsInside( lootBin, eLootBinCompartment.SECRET, lootToRefillSecretBin )
	}
}

bool function IsLootSurvivalItem( string lootRef )
{
                              
		if ( lootRef == VOID_RING_WEAPON_REF || lootRef == MRB_WEAPON_REF_NAME || lootRef == REDEPLOY_BALLOON_WEAPON_REF )
      
                                                                          
       
	{
		return true
	}

	return false
}

bool function SupportBin_HasSurvivalItemsAlready(entity lootBin)
{
	array<LootRef> lootAlreadyInBin = LootBin_GetLootRefs( lootBin, true, true )

	bool binHasHeatShield
	bool binHasMobileRespawn

	foreach ( LootRef existingLoot in lootAlreadyInBin )
	{
		if ( existingLoot.lootData.ref == VOID_RING_WEAPON_REF )
		{
			binHasHeatShield = true
			continue
		}
		else if(existingLoot.lootData.ref == MRB_WEAPON_REF_NAME)
		{
			binHasMobileRespawn = true
			continue
		}
	}

	return (binHasHeatShield || binHasMobileRespawn)
}

array<string> function SupportBin_UpdateLootForSurvivalItemLimiting( array<string> lootRefs) //update to check for multiple phoenix and too many batts or meds.
{
	int survivalItemCount = 0

	array<string> existingSurvivalItems
	array<string> newLootRefsForBin

	bool binHasHeatShield
	bool binHasMobileRespawn

	foreach ( string existingLoot in lootRefs )
	{
		if ( existingLoot == VOID_RING_WEAPON_REF )
		{
			binHasHeatShield = true
			existingSurvivalItems.append(existingLoot)
			survivalItemCount++
			continue
		}
		else if(existingLoot == MRB_WEAPON_REF_NAME)
		{
			binHasMobileRespawn = true
			existingSurvivalItems.append(existingLoot)
			survivalItemCount++
			continue
		}
	}

	if(survivalItemCount == 0) // if there are no survival items ensure at least 1 spawns and add it to the relevant arrays
	{
		lootRefs.remove(RandomIntRange( 0, lootRefs.len()))
		string itemRef = SURVIVAL_GetWeightedItemFromGroup( "secret_bin_loot_survival" )
		lootRefs.append( itemRef )
		survivalItemCount++
		existingSurvivalItems.append(itemRef)
	}

	int countOfItemsRemoved = 0

	while(existingSurvivalItems.len() > 1)
	{
		int lootIndex = RandomIntRange( 0, existingSurvivalItems.len() )
		foreach(string existingLoot in lootRefs)
		{
			if(existingLoot == existingSurvivalItems[lootIndex])
			{
				lootRefs.removebyvalue(existingLoot)
				existingSurvivalItems.remove(lootIndex)
				countOfItemsRemoved++
			}
		}
	}

	if(countOfItemsRemoved > 0)
	{
		newLootRefsForBin =  lootRefs
		array<string> newNonSurvivalLootToAdd = SURVIVAL_GetMultipleWeightedItemsFromGroup( "secret_bin_loot_meds", countOfItemsRemoved )
		foreach(string ref in newNonSurvivalLootToAdd)
			newLootRefsForBin.append( ref )
	}

	return newLootRefsForBin
}

void function SupportBin_RandomizeAvailableSupportBins()
{
	int lootBinCount = file.activeSupportBins.len()
	if ( lootBinCount == 0 )
		return

	array<entity> allLootBins = file.activeSupportBins
	allLootBins.randomize()
	array<entity> distributedSupportBins
	array<entity> nonDistributedSupportBins

	int goal = GetCurrentPlaylistVarInt( "maxSupportBinCount", 40 )

	distributedSupportBins.append( allLootBins[0] ) // add the first support loot bin

	for ( int i = 0; i < goal - 1; i++ )
	{
		for ( int j = 1; j < allLootBins.len(); j++ )
		{
			int count = 0
			foreach ( distributedBin in distributedSupportBins )
			{
				if ( DistanceSqr( allLootBins[j].GetOrigin(), distributedBin.GetOrigin() ) > SupportBin_Get_RandomizeExclusionDistance() )//make this variable driven by playlist var
				{
					count++
				}
			}
			if ( count == distributedSupportBins.len() )
			{
				distributedSupportBins.append( allLootBins[j] )
				allLootBins.remove( j )
				j--
				break
			}
			else
			{
				nonDistributedSupportBins.append( allLootBins[j] )
				allLootBins.remove( j )
				j--
			}
		}
	}

	foreach ( entity supportBin in nonDistributedSupportBins )
	{
		file.activeSupportBins.fastremovebyvalue( supportBin )
		supportBin.Destroy()
	}
}

void function SupportBin_MaybeAddSurvivalLootBinOnOpen( entity lootBin, entity player )
{
	if ( SupportBin_ShouldLimitAllSurvivalItems() && !ShouldPlayerGetSurvivalAssist( player ) )
	{
		if ( Crafting_IsDispenserCraftingEnabled() && SupportBin_SmartEquipment() ) //if they aren't getting survival assist, give them equipment if enabled anyways
			SupportBin_AddEquipmentToSecret( player, lootBin, "" )

		return
	}

	if( !file.activeSupportBins.contains( lootBin ) )
		return

	string itemToAdd = ""
	switch( SupportBin_GetPlayerSurvivalNeed(player) )
	{
		case SurvivalNeedType.SURIVIAL_LOOT_NEED_HS:
			if( SupportBin_ResepectGroundLootRotation() )
			{
				if ( !Crafting_GetDisabledGroundLoot().contains( VOID_RING_WEAPON_REF ) && !SURVIVAL_Loot_IsRefDisabled( VOID_RING_WEAPON_REF ) )
				{
					if ( SupportBin_HeatShieldAssistanceLimiting() ) // check if we are using the logic
					{
						if ( SupportBin_CanTeamReceiveHeatshield( player ) ) // check if the team can get heatshields from limiting logic
						{
							itemToAdd = VOID_RING_WEAPON_REF
							if ( player in file.playerSupportBinRegistry )
							{
								file.playerSupportBinRegistry[player].playerHeatShieldCount++
							}
							else
							{
								PlayerSupportAssistData playerData
								playerData.playerHeatShieldCount = 1

								file.playerSupportBinRegistry[player] <- playerData
							}
							thread Thread_SupportBin_TrackPlayerRinglocation( player )
						}
					}
					else // if we aren't using the limiting logic, just give them the heatshield
					{
						itemToAdd = VOID_RING_WEAPON_REF
					}
				}
			}
			else // if we aren't respecting disabled ground loot
			{
				if ( SupportBin_HeatShieldAssistanceLimiting() )
				{
					if ( SupportBin_CanTeamReceiveHeatshield( player ) )
					{
						itemToAdd = VOID_RING_WEAPON_REF
						if ( player in file.playerSupportBinRegistry )
						{
							file.playerSupportBinRegistry[player].playerHeatShieldCount++
						}
						else
						{
							PlayerSupportAssistData playerData
							playerData.playerHeatShieldCount = 1

							file.playerSupportBinRegistry[player] <- playerData
						}
						thread Thread_SupportBin_TrackPlayerRinglocation( player )
					}
				}
				else
				{
					itemToAdd = VOID_RING_WEAPON_REF
				}
			}
			break
		case SurvivalNeedType.SURIVIAL_LOOT_NEED_MRB:
			if( SupportBin_ResepectGroundLootRotation() )
			{
				if ( !Crafting_GetDisabledGroundLoot().contains( MRB_WEAPON_REF_NAME ) && !SURVIVAL_Loot_IsRefDisabled( MRB_WEAPON_REF_NAME ) )
				{
					itemToAdd = MRB_WEAPON_REF_NAME
				}
			}
			else
			{
				itemToAdd = MRB_WEAPON_REF_NAME
			}
			break
		case SurvivalNeedType.SURIVIAL_LOOT_NEED_ANY:
			if( SupportBin_ResepectGroundLootRotation() )
			{
				if ( !SupportBin_HasSurvivalItemsAlready( lootBin ) && !Crafting_GetDisabledGroundLoot().contains( MRB_WEAPON_REF_NAME ) && !Crafting_GetDisabledGroundLoot().contains( VOID_RING_WEAPON_REF ) && !SURVIVAL_Loot_IsRefDisabled( VOID_RING_WEAPON_REF ) && !SURVIVAL_Loot_IsRefDisabled( MRB_WEAPON_REF_NAME ) )
				{
					itemToAdd = SURVIVAL_GetWeightedItemFromGroup( "secret_bin_loot_survival" )
				}
				else if ( !SupportBin_HasSurvivalItemsAlready( lootBin ) && Crafting_GetDisabledGroundLoot().contains( MRB_WEAPON_REF_NAME ) && !Crafting_GetDisabledGroundLoot().contains( VOID_RING_WEAPON_REF ) && !SURVIVAL_Loot_IsRefDisabled( VOID_RING_WEAPON_REF ) && SURVIVAL_Loot_IsRefDisabled( MRB_WEAPON_REF_NAME ) )
				{
					itemToAdd = VOID_RING_WEAPON_REF
				}
				else if ( !SupportBin_HasSurvivalItemsAlready( lootBin ) && !Crafting_GetDisabledGroundLoot().contains( MRB_WEAPON_REF_NAME ) && Crafting_GetDisabledGroundLoot().contains( VOID_RING_WEAPON_REF ) && SURVIVAL_Loot_IsRefDisabled( VOID_RING_WEAPON_REF ) && !SURVIVAL_Loot_IsRefDisabled( MRB_WEAPON_REF_NAME )  )
				{
					itemToAdd = MRB_WEAPON_REF_NAME
				}
			}
			else
			{
				if ( !SupportBin_HasSurvivalItemsAlready( lootBin ) )
				{
					itemToAdd = SURVIVAL_GetWeightedItemFromGroup( "secret_bin_loot_survival" )
				}
			}
			break
	}

	array<LootRef> lootInside = LootBin_GetLootRefs( lootBin, true, true )

	if( itemToAdd != "" )
	{
		bool itemToAddFound = false

		// make sure the item isn't already in the bin
		foreach( LootRef loot in lootInside )
		{
			if( loot.lootData.ref == itemToAdd )
			{
				itemToAddFound = true

				break
			}

			//If there is already a different survival item inside. Remove it and replace it with a small heal item.
			if( IsLootSurvivalItem( loot.lootData.ref ) && loot.lootData.ref != itemToAdd )
			{
				Lootbin_RemoveSpecificLootFromInside( lootBin, eLootBinCompartment.SECRET, loot.lootData.ref )

				string newNonSurvivalLootToAdd = SURVIVAL_GetWeightedItemFromGroup( "secret_bin_loot_small_heal" )

				// If we are using smart equipment, don't use small heals
				if ( Crafting_IsDispenserCraftingEnabled() && SupportBin_SmartEquipment() )
				{
					newNonSurvivalLootToAdd = SURVIVAL_GetWeightedItemFromGroup( "secret_bin_loot_improved" )
				}

				LootBin_PutLootItemInside( lootBin, eLootBinCompartment.SECRET, newNonSurvivalLootToAdd, 1 )
			}
		}

		if( !itemToAddFound )
		{
			if ( SupportBin_ShouldLimitAllSurvivalItems() )
			{
				if( player in file.playerSupportBinRegistry )
				{
					PlayerSupportAssistData playerData = file.playerSupportBinRegistry[player]

					//If receiving assistance, add themn to the assistance registry.
					playerData.playerAssistOnCooldown = true
					playerData.playerAssistCurrentCooldown = Time()

					if( playerData.playerRecievedAssist )
					{
						playerData.playerAssistCount++
					}
				} //increment the number of assists
				else
				{
					PlayerSupportAssistData playerData

					playerData.playerRecievedAssist = true
					playerData.playerAssistCount = 1

					file.playerSupportBinRegistry[player] <- playerData
				}
			}

			LootBin_RemoveLootFromInside( lootBin, eLootBinCompartment.SECRET, 1 )

			LootBin_PutLootItemInside( lootBin, eLootBinCompartment.SECRET, itemToAdd, 1 )
		}
	}

	//if there are no batts and we want to guarantee them, add bats.
	if( SupportBin_GuaranteeBattery() )
	{
		lootInside = LootBin_GetLootRefs( lootBin, true, true )

		bool battFound = false

		foreach( LootRef loot in lootInside )
		{
			if( loot.lootData.ref == LOOT_ITEM_BATTERY_NAME )
			{
				battFound = true
				break
			}
		}

		if( !battFound )
		{
			lootInside = LootBin_GetLootRefs( lootBin, false, true ) //only get the loot inside the secret compartment
			foreach( LootRef loot in lootInside )
			{
				if( loot.lootData.ref != itemToAdd )
				{
					// remove anything from the bin that's not a battery to ensure there always is one
					Lootbin_RemoveSpecificLootFromInside( lootBin, eLootBinCompartment.SECRET, loot.lootData.ref )

					LootBin_PutLootItemInside( lootBin, eLootBinCompartment.SECRET, LOOT_ITEM_BATTERY_NAME, 1 )

					lootInside = LootBin_GetLootRefs( lootBin, true, true )

					break
				}
			}
		}
	}

	if ( Crafting_IsDispenserCraftingEnabled() && SupportBin_SmartEquipment() )
		SupportBin_AddEquipmentToSecret( player, lootBin, itemToAdd )

	//working to help prevent blood-demon strategies by limiting healing items
	if ( SupportBin_MedkitLimitingEnabled() )
	{
		lootInside = LootBin_GetLootRefs( lootBin, false, true ) //only get the loot inside the secret compartment
		foreach( LootRef loot in lootInside )
		{
			if ( loot.lootData.ref == LOOT_ITEM_MEDKIT_NAME )
			{
				if ( SupportBin_IsTeamAtMedkitLimit( player ) )
				{
					Lootbin_RemoveSpecificLootFromInside( lootBin, eLootBinCompartment.SECRET, loot.lootData.ref )

					LootBin_PutLootItemInside( lootBin, eLootBinCompartment.SECRET, LOOT_ITEM_BATTERY_NAME, 1 ) // replace with a battery
				}
				else if ( !( player in file.playerMedkitsGiven ) )
				{
					file.playerMedkitsGiven [ player ] <- 1
				}
				else
				{
					file.playerMedkitsGiven [ player ] ++
 				}
			}
		}
	}
}

bool function ShouldPlayerGetSurvivalAssist( entity player )
{
	if( player in file.playerSupportBinRegistry )
	{
		PlayerSupportAssistData playerData = file.playerSupportBinRegistry[player]

		// check if the player is in the assistance cooldown registry. If so, check the time delta agains the cooldown. If greater, allow assistance, if not. Return false.
		if( playerData.playerAssistOnCooldown )
		{
			float lastCooldownTime =  playerData.playerAssistCurrentCooldown

			if( !( Time() - lastCooldownTime > SURVIVAL_ASSISTANCE_COOLDOWN_DURATION ) )
			{
				return false
			}
			else
			{
				playerData.playerAssistOnCooldown = false
			}
		}

		// check if the player is in the assistance cooldown registry. If so, check the amount of assistance. If lesser than 3, allow assistance, if not Return false.
		if( playerData.playerRecievedAssist )
		{
			if( playerData.playerAssistCount >= SURVIVAL_ASSISTANCE_MAX_COUNT && SupportBin_HardLimitSurvivalAssistanceCount()  )
			{
				return false
			}
		}
	}

	int survivalNeed = SupportBin_GetPlayerSurvivalNeed( player )

	if( survivalNeed == SurvivalNeedType.SURIVIAL_LOOT_NEED_HS || survivalNeed == SurvivalNeedType.SURIVIAL_LOOT_NEED_MRB || survivalNeed == SurvivalNeedType.SURIVIAL_LOOT_NEED_ANY )
	{
		return true
	}

	if( survivalNeed == SurvivalNeedType.SURIVIAL_LOOT_NEED_NONE )
	{
		return false
	}

	return false
}

int function SupportBin_GetPlayerSurvivalItemStatus( entity player )
{

	LootData lootData = EquipmentSlot_GetEquippedLootDataForSlot( player, "gadgetslot" )

	//Additional Survival Items will need to be added here in the future.
	if ( lootData.ref == VOID_RING_WEAPON_REF )
	{
		return SurvivalStatusType.SURIVIAL_LOOT_HAS_HS
	}
	else if( lootData.ref == MRB_WEAPON_REF_NAME )
	{
		return SurvivalStatusType.SURIVIAL_LOOT_HAS_MRB
	}
	else if( lootData.ref == REDEPLOY_BALLOON_WEAPON_REF )
	{
		return SurvivalStatusType.SURIVIAL_LOOT_HAS_EVAC
	}

	return SurvivalStatusType.SURIVIAL_LOOT_HAS_NONE
}

bool function SupportBin_ShouldGrantMrb( entity player )
{
	int team = player.GetTeam()
	foreach ( teammate in GetPlayerArrayOfTeam( team ) )
	{
		if ( IsAlive( teammate ) )
			continue
		int respawnStatus = teammate.GetPlayerNetInt( "respawnStatus" )
		if ( respawnStatus == eRespawnStatus.WAITING_FOR_DELIVERY
				|| respawnStatus == eRespawnStatus.WAITING_FOR_PICKUP
				|| respawnStatus == eRespawnStatus.PICKUP_DESTROYED )
			return true
	}
	return false
}

int function SupportBin_GetPlayerSurvivalNeed( entity player )
{

	bool teamHasHS = false
	bool teamHasMRB = false

	if( SupportBin_ValidateSurvivalNeedAgainstTeamInvetory() )
	{
		foreach( teamMember in GetPlayerArrayOfTeam_Alive( player.GetTeam() ))
		{
			if( IsAlive( teamMember ) )
			{
				int survivalItemStatus = SupportBin_GetPlayerSurvivalItemStatus( teamMember )
				if( survivalItemStatus == SurvivalStatusType.SURIVIAL_LOOT_HAS_NONE )
				{
					continue
				}
				else if( survivalItemStatus == SurvivalStatusType.SURIVIAL_LOOT_HAS_HS )
				{
					teamHasHS = true
				}
				else if( survivalItemStatus == SurvivalStatusType.SURIVIAL_LOOT_HAS_MRB )
				{
					teamHasMRB = true
				}
			}
		}
	}

	int survivalItemStatus = SupportBin_GetPlayerSurvivalItemStatus( player )

	//if player does not have heat shield and is in the deathfield
	if( survivalItemStatus != SurvivalStatusType.SURIVIAL_LOOT_HAS_HS && ( DeathField_PointDistanceFromFrontier( player.GetOrigin() ) <= 0.0 ) )
	{
		if( !( SupportBin_ValidateSurvivalNeedAgainstTeamInvetory() && teamHasHS ) )
		{
			return SurvivalNeedType.SURIVIAL_LOOT_NEED_HS
		}
	}

	if( survivalItemStatus != SurvivalStatusType.SURIVIAL_LOOT_HAS_MRB && SupportBin_ShouldGrantMrb( player ) ) //if the player does not have mobi and has teammates waiting fro respawn
	{
		if( !( SupportBin_ValidateSurvivalNeedAgainstTeamInvetory() && teamHasMRB ) )
		{
			return SurvivalNeedType.SURIVIAL_LOOT_NEED_MRB
		}
	}

	if( survivalItemStatus == SurvivalStatusType.SURIVIAL_LOOT_HAS_NONE )
	{
		return SurvivalNeedType.SURIVIAL_LOOT_NEED_ANY
	}

	return SurvivalNeedType.SURIVIAL_LOOT_NEED_NONE
}

bool function SupportBin_IsTeamAtMedkitLimit( entity player )
{
	bool atLimit = false

	array<entity> teammates = GetPlayerArrayOfTeam( player.GetTeam() )
	foreach( teammate in teammates )
	{
		if ( SupportBin_IsPlayerAtMedkitLimit( teammate ) )
		{
			atLimit = true
			break
		}
	}
	return atLimit
}

bool function SupportBin_IsPlayerAtMedkitLimit( entity player )
{
	if ( !IsValid( player ) )
		return false

	int medkits = 0
	bool tooManyMedkits = false
	bool atLimit = false

	array<ConsumableInventoryItem> playerInventory = SURVIVAL_GetPlayerInventory( player )
	foreach ( ConsumableInventoryItem invItem in playerInventory )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByIndex( invItem.type )

		if ( data.ref == LOOT_ITEM_MEDKIT_NAME )
		{
			medkits++
		}

		if ( medkits > SupportBin_Get_MaxMedkitLimit() ) // count slots in intentory, so accounts for golden backpack. No more than 1 slot.
		{
			tooManyMedkits = true
			break
		}
	}

	if ( player in file.playerMedkitsGiven )
	{
		if ( file.playerMedkitsGiven[ player ] >= SupportBin_Get_MaxBinGivenMedkitLimit() )
			atLimit = true
	}

	if ( tooManyMedkits || atLimit )
		return true

	return false
}

bool function SupportBin_CanTeamReceiveHeatshield( entity player )
{
	bool canReceive = true

	array<entity> teammates = GetPlayerArrayOfTeam( player.GetTeam() )
	foreach( teammate in teammates )
	{
		if ( !SupportBin_CanPlayerReceiveHeatshield( teammate ) )
		{
			canReceive = false
			break
		}
	}
	return canReceive
}

bool function SupportBin_CanPlayerReceiveHeatshield( entity player )
{
	if( player in file.playerSupportBinRegistry )
	{
		PlayerSupportAssistData playerData = file.playerSupportBinRegistry[player]

		if ( playerData.playerHeatShieldCount >= SupportBin_HeatShieldAssistanceMax() )
			return false

		if ( playerData.playerHasEnteredRing == false )
			return false
	}
	return true
}

void function Thread_SupportBin_TrackPlayerRinglocation( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "Support_Bin_EnteredRing" )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{
				file.playerSupportBinRegistry[player].playerHasEnteredRing = true
			}
		}
	)

	file.playerSupportBinRegistry[player].playerHasEnteredRing = false

	while ( true )
	{
		if ( !IsValid( player ) )
			return

		if ( DeathField_PointDistanceFromFrontier( player.GetOrigin() ) >= 0.0 )
		{
			player.Signal( "Support_Bin_EnteredRing" )
		}
		WaitFrame()
	}
}

void function SupportBin_ClientToServer_MarkSupportBoxLoot( entity player )
{
	if( !( player in file.playerToOpenedBin ) )
		return

	entity box = file.playerToOpenedBin[player]
	CreateWaypoint_Ping_Location( player, ePingType.SUPPORT_BOX_LOOT, box, box.GetOrigin(), -1, false )
}

#endif

#if CLIENT
void function SupportBin_OnPropScriptCreated( entity ent )
{
	if( ent.GetScriptName() != LOOT_BIN_SCRIPTNAME && ent.GetScriptName() != LOOT_BIN_MARKER_SCRIPTNAME )
		return
	if( !LootBin_HasSecretCompartment( ent ) )
		return
	if( ent.GetSkin() != ent.GetSkinIndexByName( SUPPORT_LOOT_BIN_SKIN_NAME ) )
		return
	if( GradeFlagsHas( ent, eGradeFlags.IS_OPEN_SECRET ) )
		return

	Perks_AddMinimapEntityForPerk( ePerkIndex.EXTRA_BIN_LOOT, ent )
	AddCallback_CanOpenLootBin( ent, SupportBin_CanUseSupportBin )
}

void function Perk_SupportBin_ServerToClient_DisplayOpenedSupportBoxPrompt()
{
	AddOnscreenPromptFunction( "quickchat", InvokePingOpenedSupportBox, 6.0, Localize( "#PING_OPEN_SUPPORT_BOX" ) )
}

void function InvokePingOpenedSupportBox( entity player )
{
	Remote_ServerCallFunction( "SupportBin_ClientToServer_MarkSupportBoxLoot" )
}

void function Perk_SupportBin_RuiThinkThread( var rui, entity ent )
{
	RuiSetFloat( rui, "minAlphaDist", 1500 )
	RuiSetFloat( rui, "maxAlphaDist", 2000 )
}
#endif

#if SERVER

void function Perk_SupportBin_UpdateBinAfterOpening( entity player, entity lootbin, array<entity> regularLootEnts, array<entity> secretLootEnts, void functionref( bool, bool ) preventLootRevealFunc)
{
	if( !SupportBin_EntityIsSupportBin( lootbin ) )
		return
	if( !GradeFlagsHas( lootbin, eGradeFlags.IS_OPEN_SECRET ) )
		return
	Perks_HideMinimapVisibility( lootbin, ePerkIndex.EXTRA_BIN_LOOT )
	file.activeSupportBins.fastremovebyvalue( lootbin )

	if( IsValid( player) )
	{
		file.playerToOpenedBin[player] <- lootbin
		StatsHook_ExtendedSupplyBinLooted( player )
		array<LootRef> loot = LootBin_GetLootRefs( lootbin, false, true )
		//PIN_Perks_ExtendedSupplyBinLooted( player, loot, lootbin.GetOrigin() ) // telemetry not available

		Remote_CallFunction_NonReplay( player, "Perk_SupportBin_ServerToClient_DisplayOpenedSupportBoxPrompt" )
	}
}

void function SupportBin_AddEquipmentToSecret( entity player, entity lootBin, string itemToAdd )
{
	array<LootRef> lootInside = LootBin_GetLootRefs( lootBin, false, true ) // when the main compartment is opened before the secret, equipment can populate twice - prevent this
	LootRef previousEquipmentItem
	bool hasPreviousEquipment = false

	foreach ( LootRef loot in lootInside )
	{
		if ( LootHelper_IsLootEquipment( loot ) )
		{
			previousEquipmentItem = loot
			hasPreviousEquipment = true
			break
		}
	}

	array<string> potentialLoot
	array<entity> teammates = GetPlayerArrayOfTeam_Alive( player.GetTeam() )

	foreach( teammate in teammates )
	{
		if ( IsValid( teammate ) )
		{
			array<string> smartLoot = SmartLoot_GetLoot( teammate, true, false, [ eLootType.BACKPACK, eLootType.INCAPSHIELD, eLootType.HELMET ], [], [] )
			potentialLoot.extend( smartLoot )
		}
	}

	if ( SupportBin_ResepectGroundLootRotation() )
	{
		foreach ( loot in potentialLoot )
		{
			if ( SURVIVAL_Loot_IsRefDisabled( loot ) )
				potentialLoot.removebyvalue( loot )
		}
	}

	if( potentialLoot.len() != 0 )
	{
		string chosenLoot = LootHelper_ReturnLowestTieredOption( potentialLoot, true )

		if ( LootHelper_GetLootTier ( chosenLoot ) < 2 )
		{
			int maxInt = GetCurrentPlaylistVarInt( "support_bin_smart_equip_quickupgradeluck", 5 )
			if ( RandomIntRange( 1, maxInt ) == 1 ) // chance to grant a purple if you have white or nothing
			{
				chosenLoot = LootHelper_UpgradeLootRefToTier( chosenLoot, 3 )
			}
			else
			{
				chosenLoot = LootHelper_UpgradeLootRefToTier( chosenLoot, 2 )
			}
		}

		lootInside = LootBin_GetLootRefs( lootBin, false, true )

		if ( chosenLoot != "" )
		{
			if ( LootHelper_GetLootTier ( chosenLoot ) > 3 ) // don't guarentee gold loot
			{
				int maxInt = GetCurrentPlaylistVarInt( "support_bin_smart_equip_goldluck", 4 )
				if ( RandomIntRange( 1, maxInt ) != 1 )
					return
			}

			foreach ( LootRef loot in lootInside )
			{
				if ( hasPreviousEquipment == true ) //if equipment is already in there, replace it
				{
					Lootbin_RemoveSpecificLootFromInside( lootBin, eLootBinCompartment.SECRET, previousEquipmentItem.lootData.ref )

					LootBin_PutLootItemInside( lootBin, eLootBinCompartment.SECRET, chosenLoot, 1 )

					lootInside = LootBin_GetLootRefs( lootBin, false, true )
					break
				}

				else if ( loot.lootData.ref != LOOT_ITEM_BATTERY_NAME && loot.lootData.ref != itemToAdd ) // don't remove the battery or survival item we already have in there
				{
					Lootbin_RemoveSpecificLootFromInside( lootBin, eLootBinCompartment.SECRET, loot.lootData.ref )

					LootBin_PutLootItemInside( lootBin, eLootBinCompartment.SECRET, chosenLoot, 1 )

					lootInside = LootBin_GetLootRefs( lootBin, false, true )
					break
				}
			}
		}

		foreach ( LootRef loot in lootInside ) // only prevent small heals from being added if we get an equipment item
		{
			if ( loot.lootData.ref == LOOT_ITEM_CELL_NAME || loot.lootData.ref == LOOT_ITEM_SYRINGE_NAME )
			{
				string newNonSurvivalLootToAdd = SURVIVAL_GetWeightedItemFromGroup( "secret_bin_loot_improved" )

				Lootbin_RemoveSpecificLootFromInside( lootBin, eLootBinCompartment.SECRET, loot.lootData.ref )

				LootBin_PutLootItemInside( lootBin, eLootBinCompartment.SECRET, newNonSurvivalLootToAdd, 1 )

				lootInside = LootBin_GetLootRefs( lootBin, false, true )
			}
		}
	}
}
#endif
