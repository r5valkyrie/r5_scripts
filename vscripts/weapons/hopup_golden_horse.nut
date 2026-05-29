                    
global function HopupGoldenHorse_Init
global function HopupGoldenHorse_Switcheroo
global function HopupGoldenHorse_Switcheroo_LockedSets

global function GoldenHorseGreen_OnWeaponActivate
global function GoldenHorseGreen_OnWeaponDeactivate
global function GoldenHorseGreen_OnWeaponReload
global function GoldenHorseGreen_OnWeaponReloadFinished

global function GoldenHorsePurple_OnWeaponPrimaryAttack
global function GoldenHorsePurple_PostFire
global function GoldenHorsePurple_HasMod

global function GoldenHorseBlue_HasMod

global function HopupGoldenHorse_GetEnabledList

#if CLIENT || UI
global function HopupGoldenHorse_SwapLootTier
#endif

#if SERVER
global function HopupGoldenHorse_TryDisplayLootHint
#endif

#if CLIENT
global function ServerToClient_TryDisplayLootHint
global function GoldenHorseGreen_CockpitExplodeVFX
global function GoldenHorseGreen_StartWeaponVFX
global function GoldenHorseGreen_StopWeaponVFX
global function GoldenHorseGreen_StartHUD
global function GoldenHorseGreen_StopHUD
global function GoldenHorseGreen_HUDExplode

global function GoldenHorseRed_ShowRui
global function GoldenHorseRed_HideRui
#endif

#if DEVELOPER
#if SERVER
global function DEV_SpawnGoldenHorseHopups
global function DEV_SpawnGoldenHorseHopupsWithWeapons
global function DEV_TestGoldenHorseRedSpawn
global function DEV_SpawnGoldenHorseSummon
#endif
#endif

//COLORS
const string GH_BLUE = "blue"
const string GH_GREEN = "green"
const string GH_YELLOW = "yellow"
const string GH_PURPLE = "purple"
const string GH_RED = "red"

//Playlist
//TO ENABLE OR DISABLE A HOPUP... "golden_horse_enabled_color"
const string PVAR_GOLDEN_HORSE_HOPUP_ENABLED = "golden_horse_enabled_"
const string PVAR_GOLDEN_HORSE_RED_USE = "golden_horse_red_allow_use"

const string PVAR_GOLDEN_HORSE_RED_FOLLOW_MOVE = "golden_horse_red_follow_move"
const string PVAR_GOLDEN_HORSE_RED_FOLLOW_COMBAT = "golden_horse_red_follow_combat"
const string PVAR_GOLDEN_HORSE_RED_FOLLOW_GOAL = "golden_horse_red_follow_goal"
const string PVAR_GOLDEN_HORSE_RED_ENEMY_DIST = "golden_horse_red_enemy_dist"
const string PVAR_GOLDEN_HORSE_RED_COOLDOWN = "golden_horse_red_cooldown_sec"
const string PVAR_GOLDEN_HORSE_RED_TELEPORT_DIST = "golden_horse_red_teleport_dist"
const string PVAR_GOLDEN_HORSE_RED_TELEPORT_COMBAT_DIST = "golden_horse_red_teleport_combat_dist"

//Names
const string GOLDEN_HORSE_MOD = "hopup_golden_horse_"

const string GOLDEN_HORSE_MOD_BLUE = GOLDEN_HORSE_MOD + GH_BLUE
const string GOLDEN_HORSE_MOD_GREEN = GOLDEN_HORSE_MOD + GH_GREEN
const string GOLDEN_HORSE_MOD_YELLOW = GOLDEN_HORSE_MOD + GH_YELLOW
const string GOLDEN_HORSE_MOD_PURPLE = GOLDEN_HORSE_MOD + GH_PURPLE
const string GOLDEN_HORSE_MOD_RED = GOLDEN_HORSE_MOD + GH_RED

const string GOLDEN_HORSE_ACTIVE_MOD = "hopup_golden_horse_active_"

//Signals
const string SIG_GOLDEN_HORSE_RED_EMPTY = "golden_horse_red_empty"
const string SIG_GOLDEN_HORSE_RED_HIDE_RUI = "golden_horse_red_hide_rui"
const string SIG_GOLDEN_HORSE_GREEN_STOP_HURT_VFX = "golden_horse_green_stop_screen_vfx"
const string SIG_GOLDEN_HORSE_GREEN_STOP_HUD = "golden_horse_green_stop_hud"

//DEV
const bool DEBUG_REQUIRE_HOPUP = false

//VARS
const float GOLDEN_HORSE_RED_MAX_SUMMON_PER_PLAYER = 2
const float GOLDEN_HORSE_RED_SUMMON_SPAWN_TIME_SEC = 1
const float GOLDEN_HORSE_RED_SUMMON_COOLDOWN_TIME_SEC = 15
const float GOLDEN_HORSE_RED_DIST_TIME_SEC = 5
const float GOLDEN_HORSE_RED_MAX_DIST = 75 * METERS_TO_INCHES
const float GOLDEN_HORSE_RED_MAX_DIST_COMBAT = 200 * METERS_TO_INCHES
const float GOLDEN_HORSE_RED_MAX_DIST_SQR = GOLDEN_HORSE_RED_MAX_DIST * GOLDEN_HORSE_RED_MAX_DIST
const float GOLDEN_HORSE_RED_MAX_DIST_COMBAT_SQR = GOLDEN_HORSE_RED_MAX_DIST_COMBAT * GOLDEN_HORSE_RED_MAX_DIST_COMBAT
const float GOLDEN_HORSE_RED_FOLLOW_MOVE = 256 //128
const float GOLDEN_HORSE_RED_FOLLOW_COMBAT = 1024 //12000
const float GOLDEN_HORSE_RED_FOLLOW_GOAL = 500 //500
const float GOLDEN_HORSE_RED_ENEMY_DIST = 150 * METERS_TO_INCHES
//NPCFollowsPlayer( summon, owner, 128, 12000, 500 )

//MDL
const asset MDL_GOLDEN_HORSE_NESSIE = $"mdl/props/nessie/nessie_ragold_w.rmdl"

//VFX
//const asset VFX_GOLDEN_HORSE_GREEN_CHARGE_1P = $"P_emp_explosion" //Do we need a 1P effect???
const asset VFX_GOLDEN_HORSE_GREEN_CHARGE_3P = $"P_Gmat_exp_buildup" //Want it to be like sucking in effects before it shockwaves out
//const asset VFX_GOLDEN_HORSE_GREEN_HURT_1P = $"P_cryo_1p"
//const asset VFX_GOLDEN_HORSE_GREEN_HURT_3P = FX_EMP_BODY_HUMAN //Using the emp 3P for temp
const asset VFX_GOLDEN_HORSE_GREEN_EXPLODE_COCKPIT = $"P_gmat_exp_FP_shockwave"//$"P_emp_explosion"
const asset VFX_GOLDEN_HORSE_GREEN_EXPLODE_1P = $"P_gmat_exp_FP_dlight"//$"P_emp_explosion"
const asset VFX_GOLDEN_HORSE_GREEN_EXPLODE_3P = $"P_Gmat_exp_shockwave"//$"P_emp_explosion"
const asset VFX_GOLDEN_HORSE_GREEN_WEAPON_3P = $"P_Gmat_Gun_arcs"

const asset VFX_GOLDEN_HORSE_RED_SUMMON = $"P_Rmat_warp_spawn"  // Nessie Spawn In
const asset VFX_GOLDEN_HORSE_RED_TELEPORT_START = $"P_Rmat_warp_out" // distance = warp start
const asset VFX_GOLDEN_HORSE_RED_TELEPORT_END = $"P_Rmat_warp_in" // distance = warp end

const asset VFX_GOLDEN_HORSE_RED_USE = $"P_Rmat_emote" // emote = pet nessie

//SFX
const string SFX_GOLDEN_HORSE_GREEN_CHARGE_1P = "materia_green_emp_charge_start_1P"
const string SFX_GOLDEN_HORSE_GREEN_CHARGE_3P = "materia_green_emp_charge_start_3P"
const string SFX_GOLDEN_HORSE_GREEN_EXPLODE_1P = "materia_green_emp_charge_explode_1P"
const string SFX_GOLDEN_HORSE_GREEN_EXPLODE_3P = "materia_green_emp_charge_explode_3P"
//const string SFX_GOLDEN_HORSE_GREEN_HURT_1P = "cryogrenade_freeze_1p"
//const string SFX_GOLDEN_HORSE_GREEN_HURT_3P = "cryogrenade_freeze_3p"

const string SFX_GOLDEN_HORSE_RED_SUMMON = "materia_red_nessie_spawn_3P"
const string SFX_GOLDEN_HORSE_RED_TELEPORT_START = "afltm_vocal_death"
const string SFX_GOLDEN_HORSE_RED_TELEPORT_END = "afltm_den_spawn_pt1"

const string SFX_GOLDEN_HORSE_RED_USE = "materia_red_nessie_cuddle_3P"

const string SFX_GOLDEN_HORSE_PURPLE_SUCCESS = "lootmarvin_dispenseloot"

//RUI
const asset RUI_GOLDEN_HORSE_RED_HUD = $"ui/weapon_hud_charged_nessie.rpak"

//Taken From firing range loot
const array<string> VALID_WEAPONS = [
	"mp_weapon_wingman", //WINGMAN GOING INTO CRATE
	"mp_weapon_wingman_crate", //WINGMAN GOING INTO CRATE
	"mp_weapon_semipistol",
	"mp_weapon_autopistol",
	"mp_weapon_shotgun_pistol",
	"mp_weapon_shotgun",
	"mp_weapon_energy_shotgun",
	"mp_weapon_mastiff",
	"mp_weapon_alternator_smg",
	"mp_weapon_r97",
	"mp_weapon_pdw",
	"mp_weapon_pdw_crate",
	"mp_weapon_vinson",
	"mp_weapon_rspn101",
	"mp_weapon_energy_ar",
	"mp_weapon_hemlok",
	"mp_weapon_esaw",
	"mp_weapon_lstar", //LSTAR COMING OUT OF CRATE
	"mp_weapon_lstar_crate", //LSTAR COMING OUT OF CRATE
	"mp_weapon_lmg",
	"mp_weapon_g2",
	"mp_weapon_dmr",
	"mp_weapon_defender",
	"mp_weapon_doubletake",
	"mp_weapon_sentinel",
	"mp_weapon_volt_smg",
	"mp_weapon_bow",
	"mp_weapon_3030",
	"mp_weapon_sniper",
	"mp_weapon_dragon_lmg",
	"mp_weapon_car",
	"mp_weapon_nemesis",
]


#if SERVER
struct SummonData
{
	float         nextAvailableSummon = -1
	array<entity> summons
	int           maxSummons = 0
}
#endif

struct CritData
{
	float critChance
	float whiffs
}

struct {
	#if SERVER
		table<entity, SummonData> summoners
		table<entity, float>      yellows
	#endif
	table<entity, CritData>   crits
	#if CLIENT
		var redRui
		var greenRui
	#endif
}file

bool function IsEnabled( string color )
{
	return GetCurrentPlaylistVarBool( PVAR_GOLDEN_HORSE_HOPUP_ENABLED + color, true )
}

bool function HasMod( entity weapon, string mod, string color )
{
	if ( weapon == null )
		return false

	return weapon.HasMod( mod + color )
}

bool function ProjectileHasMod( entity projectile, string mod, string color )
{
	return projectile.HasWeaponMod( mod + color )
}

bool function IsValidProjectileWithMod( entity projectile, string mod, string color )
{
	if ( !IsValid( projectile ) )
		return false

	if ( !projectile.IsProjectile() )
		return false

	if ( !ProjectileHasMod( projectile, mod, color ) )
		return false

	return true
}

void function AddMod( entity weapon, string mod, string color )
{
	weapon.AddMod( mod + color )
}

void function RemoveMod( entity weapon, string mod, string color )
{
	weapon.RemoveMod( mod + color )
}

array<string> function HopupGoldenHorse_GetEnabledList()
{
	array<string> hopups
	if ( IsEnabled( GH_BLUE ) ) //TUNE
		hopups.append( GOLDEN_HORSE_MOD + GH_BLUE )
	if ( IsEnabled( GH_GREEN ) ) //TUNE
		hopups.append( GOLDEN_HORSE_MOD + GH_GREEN )
	if ( IsEnabled( GH_YELLOW ) ) //TUNE
		hopups.append( GOLDEN_HORSE_MOD + GH_YELLOW )
	if ( IsEnabled( GH_PURPLE ) ) //TUNE
		hopups.append( GOLDEN_HORSE_MOD + GH_PURPLE )
	if ( IsEnabled( GH_RED ) ) //NEEDS CODE SUPPORT
		hopups.append( GOLDEN_HORSE_MOD + GH_RED )

	return hopups
}

void function HopupGoldenHorse_Init()
{
	//TODO Hey Dingus did you forget what happened with april fools?
	//Make sure the build can see all the assets we need, it's no good if it's gated behind this playlist
	if ( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_GOLDEN_HORSE ) )
	{
		HopupGoldenHorse_DisableAll()
		return
	}

                   
                                              
       

	if ( IsEnabled( GH_BLUE ) ) //TUNE
		GoldenHorseBlue_Init()
	if ( IsEnabled( GH_GREEN ) ) //TUNE
		GoldenHorseGreen_Init()
	if ( IsEnabled( GH_YELLOW ) ) //TUNE
		GoldenHorseYellow_Init()
	if ( IsEnabled( GH_PURPLE ) ) //TUNE
		GoldenHorsePurple_Init()
	if ( IsEnabled( GH_RED ) ) //NEEDS CODE SUPPORT
		GoldenHorseRed_Init()

	var dt      = GetDataTable( LOOT_DATATABLE )
	int numRows = GetDataTableRowCount( dt )
	Remote_RegisterClientFunction( "ServerToClient_TryDisplayLootHint", "int", 0, numRows )

	#if SERVER
		//Loot_AddCallback_OnLootSpawn( GoldenHorse_OnLootSpawned )
	#endif

	#if CLIENT || UI
		AddCallback_EditLootDesc( HopupGoldenHorse_EditWeaponDescription )
	#endif
}

void function HopupGoldenHorse_DisableAll()
{
	SURVIVAL_Loot_AddDisabledRef( GOLDEN_HORSE_MOD + GH_BLUE )
	SURVIVAL_Loot_AddDisabledRef( GOLDEN_HORSE_MOD + GH_YELLOW )
	SURVIVAL_Loot_AddDisabledRef( GOLDEN_HORSE_MOD + GH_PURPLE )
	SURVIVAL_Loot_AddDisabledRef( GOLDEN_HORSE_MOD + GH_GREEN )
	SURVIVAL_Loot_AddDisabledRef( GOLDEN_HORSE_MOD + GH_RED )
}

//Oh no I fell for the ol' switcheroo!
void function HopupGoldenHorse_Switcheroo( LootData wData )
{
	if ( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_GOLDEN_HORSE ) )
		return

	//If we're assuming a hopup slot on every weapon...

	//Special cases for crate weapons - build the hopups into it
	switch( wData.ref )
	{
		case "mp_weapon_bow":
			//Doesn't play nice with crits
			wData.supportedAttachments.append( "hopup" )
			wData.supportedAttachments.fastremovebyvalue( "hopupMulti_a" )
			wData.baseMods.fastremovebyvalue( "hopup_shatter_rounds" )
			wData.baseMods.append( GOLDEN_HORSE_MOD + GH_PURPLE )
			break

		case "mp_weapon_wingman_crate":
			//wData.supportedAttachments.fastremovebyvalue( "hopupMulti_a" )
			//wData.supportedAttachments.fastremovebyvalue( "hopupMulti_b" )
			wData.baseMods.fastremovebyvalue( "hopup_headshot_dmg_elite" )
			wData.baseMods.fastremovebyvalue( "hopup_smart_reload" )
			wData.baseMods.append( "hopup_headshot_dmg_elite_ghorse" )
			wData.baseMods.append( GOLDEN_HORSE_MOD + GH_BLUE )
			break

		case "mp_weapon_lstar_crate":
			wData.baseMods.append( GOLDEN_HORSE_MOD + GH_GREEN )
			break

		case "mp_weapon_pdw_crate":
			//wData.baseMods.fastremovebyvalue( "hopup_selectfire" )
			wData.supportedAttachments.fastremovebyvalue( "hopup" )
			wData.supportedAttachments.append( "hopupMulti_a" )
			wData.supportedAttachments.append( "hopupMulti_b" )
			wData.baseMods.append( GOLDEN_HORSE_MOD + GH_GREEN )
			break

		case "mp_weapon_sniper":
			wData.supportedAttachments.append( "hopup" )
			wData.baseMods.append( GOLDEN_HORSE_MOD + GH_RED )
			break

		default:
			if ( VALID_WEAPONS.contains( wData.ref ) )
			{
				if ( !wData.supportedAttachments.contains( "hopup" ) )
					wData.supportedAttachments.append( "hopup" )
			}
			else
			{
				if ( wData.supportedAttachments.contains( "hopup" ) )
					wData.supportedAttachments.fastremovebyvalue( "hopup" )
			}
			break
	}
}

void function HopupGoldenHorse_Switcheroo_LockedSets( LootData wData )
{
	if ( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_GOLDEN_HORSE ) )
		return

	if ( wData.baseWeapon == wData.ref )
		return

	string weaponRef = wData.ref
	bool isGold      = weaponRef.find( "_gold" ) != -1 && weaponRef.find( "_paint" ) == -1

	if ( isGold )
	{
		//Remove default hopup
		for ( int i = 0; i < wData.baseMods.len(); ++i )
		{
			if ( wData.baseMods[i].find( "hopup" ) != -1 )
			{
				wData.baseMods.remove( i )
				--i
			}
		}

		array<string> hopups = GetAttachmentsForPoint( "hopup", wData.baseWeapon )

		//Add proper ghorse hopup
		foreach ( string hopup in hopups )
		{
			if ( hopup.find( GOLDEN_HORSE_MOD ) != -1 )
			{
				wData.baseMods.append( hopup )
				break
			}
		}

		if ( VALID_WEAPONS.contains( wData.baseWeapon ) )
		{
			if ( !wData.supportedAttachments.contains( "hopup" ) )
				wData.supportedAttachments.append( "hopup" )
		}
		else
		{
			if ( wData.supportedAttachments.contains( "hopup" ) )
				wData.supportedAttachments.fastremovebyvalue( "hopup" )
		}
	}
}

#if CLIENT || UI
string function HopupGoldenHorse_EditWeaponDescription( string lootRef, entity player, string originalDesc )
{
	if ( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_GOLDEN_HORSE ) )
		return originalDesc

	array<string> hopups = GetAttachmentsForPoint( "hopup", lootRef )

	foreach ( string hopup in hopups )
	{
		switch( hopup )
		{
			case GOLDEN_HORSE_MOD + GH_GREEN:
				return originalDesc + "\n" + Localize( "#WPN_HOPUP_GOLDEN_HORSE_GREEN_APPEND" )

			case GOLDEN_HORSE_MOD + GH_BLUE:
				return originalDesc + "\n" + Localize( "#WPN_HOPUP_GOLDEN_HORSE_BLUE_APPEND" )

			case GOLDEN_HORSE_MOD + GH_YELLOW:
				return originalDesc + "\n" + Localize( "#WPN_HOPUP_GOLDEN_HORSE_YELLOW_APPEND" )

			case GOLDEN_HORSE_MOD + GH_PURPLE:
				return originalDesc + "\n" + Localize( "#WPN_HOPUP_GOLDEN_HORSE_PURPLE_APPEND" )

			case GOLDEN_HORSE_MOD + GH_RED:
				return originalDesc + "\n" + Localize( "#WPN_HOPUP_GOLDEN_HORSE_RED_APPEND" )
		}
	}

	return originalDesc
}
#endif

#if SERVER
void function HopupGoldenHorse_TryDisplayLootHint( entity weapon )
{
	if ( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_GOLDEN_HORSE ) )
		return

	if ( !IsValid( weapon ) )
		return

	string weaponRef = GetWeaponClassNameWithLockedSet( weapon )
	if ( weaponRef.find( "_paint" ) >= 0 ) //Paintball guns
		return

	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return

	string hopupToFind   = ""
	array<string> hopups = GetAttachmentsForPoint( "hopup", weapon.GetWeaponClassName() )
	foreach ( string hopup in hopups )
	{
		if ( hopup.find( GOLDEN_HORSE_MOD ) >= 0 )
		{
			hopupToFind = hopup
			break
		}
	}

	if ( hopupToFind == "" )
		return

	if ( !weapon.GetMods().contains( hopupToFind ) )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByRef( hopupToFind )
		Remote_CallFunction_NonReplay( player, "ServerToClient_TryDisplayLootHint", data.index )
	}
}
#endif

#if CLIENT || UI
bool function HopupGoldenHorse_SwapLootTier( var rui, string ref, int tier, string ruiVar = "lootTier" )
{
	if ( ref == GOLDEN_HORSE_MOD + GH_GREEN )
	{
		RuiSetInt( rui, ruiVar, GOLDEN_HORSE_SPECIAL_EVENT_LOOT_TIER )
		return true
	}
	RuiSetInt( rui, ruiVar, tier )
	return false
}
#endif

#if CLIENT
void function ServerToClient_TryDisplayLootHint( int lootIndex )
{
	Assert( SURVIVAL_Loot_IsLootIndexValid( lootIndex ) )

	if ( !SURVIVAL_Loot_IsLootIndexValid( lootIndex ) )
		return

	LootData lootData = SURVIVAL_Loot_GetLootDataByIndex( lootIndex )
	string localize   = "#WPN_" + lootData.ref.toupper() + "_SEARCH"

	HidePlayerHint( "#WPN_HOPUP_GOLDEN_HORSE_BLUE_SEARCH" )
	HidePlayerHint( "#WPN_HOPUP_GOLDEN_HORSE_GREEN_SEARCH" )
	HidePlayerHint( "#WPN_HOPUP_GOLDEN_HORSE_YELLOW_SEARCH" )
	HidePlayerHint( "#WPN_HOPUP_GOLDEN_HORSE_PURPLE_SEARCH" )
	HidePlayerHint( "#WPN_HOPUP_GOLDEN_HORSE_RED_SEARCH" )

	AddPlayerHint( 6, 0.5, lootData.hudIcon, localize )
}
#endif

asset function HopupGoldenHorse_GetIconFor( string color )
{
	switch( color )
	{
		case GH_GREEN:
			return $"rui/pilot_loadout/mods/hopup_golden_horse_green"

		case GH_BLUE:
			return  $"rui/pilot_loadout/mods/hopup_golden_horse_blue"

		case GH_PURPLE:
			return  $"rui/pilot_loadout/mods/hopup_golden_horse_purple"

		case GH_YELLOW:
			return $"rui/hud/ultimate_icons/hopup_golden_horse_yellow"

		case GH_RED:
			return $"rui/hud/ultimate_icons/hopup_golden_horse_red"
	}

	return $"rui/pilot_loadout/mods/empty_hopup"
}

//BLUE!
void function GoldenHorseBlue_Init()
{
	//Doesn't need anything, everything is built into _lifesteal
}

bool function GoldenHorseBlue_HasMod( entity weapon )
{
	return HasMod( weapon, GOLDEN_HORSE_MOD, GH_BLUE )
}

//GREEN!
void function GoldenHorseGreen_Init()
{
	PrecacheParticleSystem( VFX_GOLDEN_HORSE_GREEN_CHARGE_3P )
	PrecacheParticleSystem( VFX_GOLDEN_HORSE_GREEN_EXPLODE_COCKPIT )
	PrecacheParticleSystem( VFX_GOLDEN_HORSE_GREEN_EXPLODE_1P )
	PrecacheParticleSystem( VFX_GOLDEN_HORSE_GREEN_EXPLODE_3P )
	PrecacheParticleSystem( VFX_GOLDEN_HORSE_GREEN_WEAPON_3P )

	RegisterSignal( SIG_GOLDEN_HORSE_GREEN_STOP_HURT_VFX )
	RegisterSignal( SIG_GOLDEN_HORSE_GREEN_STOP_HUD )
	Remote_RegisterClientFunction( "GoldenHorseGreen_StartWeaponVFX", "entity" )
	Remote_RegisterClientFunction( "GoldenHorseGreen_StopWeaponVFX", "entity" )
	Remote_RegisterClientFunction( "GoldenHorseGreen_StartHUD", "entity" )
	Remote_RegisterClientFunction( "GoldenHorseGreen_StopHUD", "entity" )
	Remote_RegisterClientFunction( "GoldenHorseGreen_HUDExplode" )
	Remote_RegisterClientFunction( "GoldenHorseGreen_CockpitExplodeVFX" )

	#if SERVER
		Loot_AddCallback_OnWeaponAttachmentChanged( GoldenHorseGreen_OnWeaponAttachmentChanged )
		AddDamageCallbackSourceID( eDamageSourceId.golden_horse_green, GoldenHorseGreen_OnDamagedBy )
	#endif
}

void function GoldenHorseGreen_StartWeaponVFX( entity weapon )
{
	weapon.PlayWeaponEffect( $"", VFX_GOLDEN_HORSE_GREEN_WEAPON_3P, "muzzle_flash" )
}

void function GoldenHorseGreen_StopWeaponVFX( entity weapon )
{
	weapon.StopWeaponEffect( $"", VFX_GOLDEN_HORSE_GREEN_WEAPON_3P )
}

void function GoldenHorseGreen_OnWeaponActivate( entity weapon )
{
	if ( !HasMod( weapon, GOLDEN_HORSE_MOD, GH_GREEN ) )
		return

	GoldenHorseGreen_StartWeaponVFX( weapon )
	#if CLIENT
		if ( weapon.IsReadyToFire() /*IsWeaponActivated not in S3*/ )
			GoldenHorseGreen_StartHUD( weapon )
	#endif
}

void function GoldenHorseGreen_OnWeaponDeactivate( entity weapon )
{
	if ( !HasMod( weapon, GOLDEN_HORSE_MOD, GH_GREEN ) )
		return

	GoldenHorseGreen_StopWeaponVFX( weapon )
	#if CLIENT
		GoldenHorseGreen_StopHUD( weapon )
	#endif
}

#if CLIENT
void function GoldenHorseGreen_StartHUD( entity weapon )
{
	thread GoldenHorseGreen_HUDThread( weapon )
}

void function GoldenHorseGreen_HUDThread( entity weapon )
{
	if ( !IsValid( weapon ) || !HasMod( weapon, GOLDEN_HORSE_MOD, GH_GREEN ) )
		return

	entity player = weapon.GetWeaponOwner()

	if ( !IsValid( player ) || !IsLocalViewPlayer( player ) )
		return

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	weapon.Signal( SIG_GOLDEN_HORSE_GREEN_STOP_HUD )
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( SIG_GOLDEN_HORSE_GREEN_STOP_HUD )

	var crosshairRui = CreateCockpitRui( $"ui/ammo_status_hint.rpak", HUD_Z_BASE )
	var chargeBarRui = CreateCockpitRui( $"ui/gh_green_crosshair.rpak" )
	if ( chargeBarRui == null || crosshairRui == null )
		return

	file.greenRui = chargeBarRui

	OnThreadEnd(
		function() : ( crosshairRui, chargeBarRui )
		{
			RuiDestroy( crosshairRui )
			RuiDestroy( chargeBarRui )
			file.greenRui = null
		}
	)

	int clipCount
	int maxClipCount
	float clipCountFrac = 1.0
	float delay         = GetWeaponInfoFileKeyField_GlobalFloat( weapon.GetWeaponClassName(), "golden_horse_green_delay_sec" )

	RuiSetFloat( chargeBarRui, "flashDelay", delay )

	while ( true )
	{
		if ( chargeBarRui == null || crosshairRui == null )
			break

		bool showHud = IsValid( weapon ) && HasMod( weapon, GOLDEN_HORSE_MOD, GH_GREEN )
		RuiSetBool( chargeBarRui, "isVisible", showHud )
		RuiSetBool( crosshairRui, "isVisible", showHud )

		if ( !showHud )
		{
			WaitFrame()
			continue
		}

		clipCount    = weapon.GetWeaponPrimaryClipCount()
		maxClipCount = weapon.GetWeaponPrimaryClipCountMax()
		if ( weapon.GetWeaponClassName() == "mp_weapon_lstar" ) //lstar overheats
		{
			clipCountFrac = 1.0 - weapon.GetWeaponChargeFraction()
		}
		else
		{
			clipCountFrac = float( clipCount) / float( maxClipCount )
		}

		if ( clipCountFrac == 0.0 )
			ClWeaponStatus_OverrideReloadHintText( "#WPN_HOPUP_GOLDEN_HORSE_GREEN_RELOAD_HINT" )
		else
			ClWeaponStatus_OverrideReloadHintText( "" )

		RuiSetFloat( chargeBarRui, "clipCountFrac", clipCountFrac )

		WaitFrame()
	}
}

void function GoldenHorseGreen_HUDExplode()
{
	if ( file.greenRui == null )
		return

	RuiSetGameTime( file.greenRui, "flashStartTime", Time() )
	RuiSetBool( file.greenRui, "flashState", true )
}

void function GoldenHorseGreen_StopHUD( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	weapon.Signal( SIG_GOLDEN_HORSE_GREEN_STOP_HUD )
}
#endif

#if SERVER
void function GoldenHorseGreen_OnWeaponAttachmentChanged( entity player, entity weapon, string modToAdd, string modToRemove )
{
	if ( !IsValid( player ) )
		return

	if ( !IsValid( weapon ) )
		return

	if ( !weapon.IsWeaponX() )
		return

	if ( modToAdd == GOLDEN_HORSE_MOD + GH_GREEN )
	{
		GoldenHorseGreen_StartWeaponVFX( weapon )
		Remote_CallFunction_Replay( player, "GoldenHorseGreen_StartWeaponVFX", weapon )
		if ( weapon.IsReadyToFire() /*IsWeaponActivated not in S3*/ )
			Remote_CallFunction_NonReplay( player, "GoldenHorseGreen_StartHUD", weapon )
	}
	else if ( modToRemove == GOLDEN_HORSE_MOD + GH_GREEN )
	{
		GoldenHorseGreen_StopWeaponVFX( weapon )
		Remote_CallFunction_Replay( player, "GoldenHorseGreen_StopWeaponVFX", weapon )
		Remote_CallFunction_Replay( player, "GoldenHorseGreen_StopHUD", weapon )
	}
}
#endif

void function GoldenHorseGreen_OnPlayerRemoveWeaponMod( entity player, entity weapon, string mod )
{
	printt( "WEAPON MOD REMOVED: " + weapon + " :: " + mod )

	if ( mod == GOLDEN_HORSE_MOD + GH_GREEN )
	{
		if ( !IsValid( weapon ) )
			return

		if ( !weapon.IsWeaponX() )
			return

		GoldenHorseGreen_StopWeaponVFX( weapon )
		#if CLIENT
			GoldenHorseGreen_StopHUD( weapon )
		#endif
	}
}

void function GoldenHorseGreen_OnWeaponReload( entity weapon, int milestoneIndex )
{
	#if SERVER
		if ( !HasMod( weapon, GOLDEN_HORSE_MOD, GH_GREEN ) )
			return

		//LSTAR COOLING DOWN
		if ( weapon.GetWeaponClassName() == "mp_weapon_lstar" && weapon.GetWeaponChargeFraction() < 1.0 )
			return

		//Weapon hasn't gotten more ammo yet
		if ( weapon.GetWeaponPrimaryClipCount() != 0 )
			return

		if ( weapon.w.isGreen )
			return

		printt( "RELOADING: " + weapon.GetWeaponClassName() + " " + milestoneIndex )
		entity owner = weapon.GetWeaponOwner()

		thread Explode_Thread( owner, weapon )
	#endif
}

void function GoldenHorseGreen_OnWeaponReloadFinished( entity weapon )
{
	//Do nothing right now cuz it's broken
	return

	if ( !HasMod( weapon, GOLDEN_HORSE_MOD, GH_GREEN ) )
		return

	#if SERVER
		weapon.w.isGreen = false
	#endif
}

#if SERVER
void function Explode_Thread( entity player, entity weapon )
{
	if ( !IsValid( player ) )
		return

	if ( !IsValid( weapon ) )
		return

	if ( !player.IsPlayer() )
		return

	if ( weapon.w.isGreen )
		return

	weapon.w.isGreen = true

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "BleedOut_OnStartDying" )

	weapon.EndSignal( "OnDestroy" )

	thread ExplosionCooldown_Thread( weapon )

	//Get min bullets/max bullets
	//Change damage
	//Get explody radius
	float dmgScale = 1.0
	/*if ( weapon.GetWeaponClassName() == "mp_weapon_lstar" ) //lstar always blows up on overheat
		dmgScale = 1.0
	else
		dmgScale = 1.0 - float(weapon.GetWeaponPrimaryClipCount()) / float(weapon.GetWeaponPrimaryClipCountMax())
*/
	float dmgMin   = GetWeaponInfoFileKeyField_GlobalFloat( weapon.GetWeaponClassName(), "golden_horse_green_dmg_min" )
	float dmgMax   = GetWeaponInfoFileKeyField_GlobalFloat( weapon.GetWeaponClassName(), "golden_horse_green_dmg_max" )
	float delay    = GetWeaponInfoFileKeyField_GlobalFloat( weapon.GetWeaponClassName(), "golden_horse_green_delay_sec" )
	int inner      = GetWeaponInfoFileKeyField_GlobalInt( weapon.GetWeaponClassName(), "golden_horse_green_inner_radius" )
	int outer      = GetWeaponInfoFileKeyField_GlobalInt( weapon.GetWeaponClassName(), "golden_horse_green_outer_radius" )

	float damage = GraphCapped( dmgScale, 0.0, 1.0, dmgMin, dmgMax )

	entity chargeFx3p = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( VFX_GOLDEN_HORSE_GREEN_CHARGE_3P ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "CHESTFOCUS" ) )
	chargeFx3p.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE | ENTITY_VISIBLE_EXCLUDE_PARENT_PLAYER
	chargeFx3p.SetOwner( player )

	EmitSoundOnEntityOnlyToPlayer( player, player, SFX_GOLDEN_HORSE_GREEN_CHARGE_1P )
	EmitSoundOnEntityExceptToPlayer( player, player, SFX_GOLDEN_HORSE_GREEN_CHARGE_3P )

	entity threatIndicator = CreateThreatIndicator( player.GetCenter(), eThreatIndicatorID.GRENADE_INDICATOR_GENERIC, outer + 50.0, <0, 0, 0>, eThreatIndicatorVisibility.INDICATOR_SHOW_TO_ENEMIES, player )
	CopyRealmsFromTo( player, threatIndicator )
	threatIndicator.SetParent( player )

	Remote_CallFunction_Replay( player, "GoldenHorseGreen_HUDExplode" )

	OnThreadEnd( void function() : ( weapon, chargeFx3p, player, threatIndicator ) {
		if ( IsValid( chargeFx3p ) )
			EffectStop( chargeFx3p )

		if ( IsValid( player ) )
		{
			StopSoundOnEntity( player, SFX_GOLDEN_HORSE_GREEN_CHARGE_1P )
			StopSoundOnEntity( player, SFX_GOLDEN_HORSE_GREEN_CHARGE_3P )
		}

		if ( IsValid( threatIndicator ) )
		{
			threatIndicator.ClearParent()
			threatIndicator.Destroy()
		}
	} )

	wait delay //Wait explodey duration

	Explode( player, damage, inner, outer )
}

void function ExplosionCooldown_Thread( entity weapon )
{
	weapon.EndSignal( "OnDestroy" )

	while( GoldenHorseGreen_ExplosionOnCooldown( weapon ) )
	{
		WaitFrame()
	}

	weapon.w.isGreen = false
}

bool function GoldenHorseGreen_ExplosionOnCooldown( entity weapon )
{
	//LSTAR COOLING DOWN
	if ( weapon.GetWeaponClassName() == "mp_weapon_lstar" )
	{
		printt( "LSTAR COOLDOWN: " + weapon.GetWeaponChargeFraction() )
		return false
	}
	//Weapon hasn't gotten more ammo yet
	if ( weapon.GetWeaponPrimaryClipCount() == 0 )
		return true

	return false
}

void function Explode( entity player, float damage, int inner, int outer )
{
	int attachID  = player.LookupAttachment( "CHESTFOCUS" )
	vector origin = player.GetAttachmentOrigin( attachID )

	entity chargeFx1p = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( VFX_GOLDEN_HORSE_GREEN_EXPLODE_1P ), origin, player.GetAngles() )
	SetTeam( chargeFx1p, player.GetTeam() )
	chargeFx1p.SetOwner( player )
	chargeFx1p.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
	CopyRealmsFromTo( player, chargeFx1p )

	entity chargeFx3p = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( VFX_GOLDEN_HORSE_GREEN_EXPLODE_3P ), origin, player.GetAngles() )
	SetTeam( chargeFx3p, player.GetTeam() )
	chargeFx3p.SetOwner( player )
	chargeFx3p.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
	CopyRealmsFromTo( player, chargeFx3p )

	//Remote_CallFunction_Replay( player, "GoldenHorseGreen_CockpitExplodeVFX" )

	EmitSoundAtPositionOnlyToPlayer( TEAM_UNASSIGNED, origin, player, SFX_GOLDEN_HORSE_GREEN_EXPLODE_1P )
	EmitSoundAtPositionExceptToPlayer( TEAM_UNASSIGNED, origin, player, SFX_GOLDEN_HORSE_GREEN_EXPLODE_3P )
	entity shake = CreateAirShake( origin, 8, 50, 0.5, 800 )
	CopyRealmsFromTo( player, shake )

	//CreateShake( player.GetOrigin(), 10, 105, chargeTimeSec, 1500 )

	RadiusDamage(
		origin,
		player,
		player,
		damage,
		damage,
		inner,
		outer,
		SF_ENVEXPLOSION_NO_DAMAGEOWNER,
		0,
		0,
		DF_RAGDOLL | DF_EXPLOSION,
		eDamageSourceId.golden_horse_green )
}

void function GoldenHorseGreen_OnDamagedBy( entity victim, var damageInfo )
{
	const float SLOWTURN = 0.0//0.7
	const float duration = 2.5
	const float fadeout = 1.0

	//int effectHandle = StatusEffect_AddTimed( victim, eStatusEffect.golden_horse_green, 0.5, duration, fadeout )

	//if ( victim.IsPlayer() )
	//	victim.p.empStatusEffectsToClearForPhaseShift.append( effectHandle )

	//thread EMP_FX( VFX_GOLDEN_HORSE_GREEN_HURT_3P, victim, "CHESTFOCUS", duration, -1, SIG_GOLDEN_HORSE_GREEN_STOP_HURT_VFX, SFX_GOLDEN_HORSE_GREEN_HURT_3P )
	//thread GoldenHorseGreen_HurtVFX_Thread( victim, duration )

	//A little hacky but all green values are the same
	const string weaponRef = "mp_weapon_shotgun"

	float slowCap = GetWeaponInfoFileKeyField_GlobalFloat( weaponRef, "golden_horse_green_slow_cap" )
	float slowMin = GetWeaponInfoFileKeyField_GlobalFloat( weaponRef, "golden_horse_green_slow_min" )
	float slowMax = GetWeaponInfoFileKeyField_GlobalFloat( weaponRef, "golden_horse_green_slow_max" )
	float dmgMax  = GetWeaponInfoFileKeyField_GlobalFloat( weaponRef, "golden_horse_green_dmg_max" )
	float dmg     = DamageInfo_GetDamage( damageInfo )

	float dmgScale = dmg / dmgMax

	float slow = GraphCapped( dmgScale, slowCap, 1.0, slowMin, slowMax )

	Electricity_DamagedPlayerOrNPC( victim, damageInfo, duration )
	GiveEMPStunStatusEffects( victim, duration, fadeout, SLOWTURN, slow )

	/*float dmgMin = GetWeaponInfoFileKeyField_GlobalFloat( weapon.GetWeaponClassName(), "golden_horse_green_dmg_min" )
	float dmgMax = GetWeaponInfoFileKeyField_GlobalFloat( weapon.GetWeaponClassName(), "golden_horse_green_dmg_max" )
	float delay  = GetWeaponInfoFileKeyField_GlobalFloat( weapon.GetWeaponClassName(), "golden_horse_green_delay_sec" )
	int inner    = GetWeaponInfoFileKeyField_GlobalInt( weapon.GetWeaponClassName(), "golden_horse_green_inner_radius" )
	int outer    = GetWeaponInfoFileKeyField_GlobalInt( weapon.GetWeaponClassName(), "golden_horse_green_outer_radius" )

	float reverseScale = GraphCapped( dmgScale, 0.0, 1.0, dmgMin, dmgMax )*/
}
#endif

#if CLIENT
void function GoldenHorseGreen_CockpitExplodeVFX()
{
	entity player = GetLocalViewPlayer()

	entity cockpit = player.GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	//Assert( !EffectDoesExist( file.greenCockpitFxHandle ), "tried to start a second screen fx" )

	int fxID   = GetParticleSystemIndex( VFX_GOLDEN_HORSE_GREEN_EXPLODE_COCKPIT )
	int handle = StartParticleEffectOnEntity( cockpit, fxID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	EffectSetIsWithCockpit( handle, true )
}
#endif

//YELLOW!
void function GoldenHorseYellow_Init()
{
	#if SERVER
		AddDamageCallback( "player", GoldenHorseYellow_OnPlayerDamaged )
	#endif
}

#if SERVER
void function GoldenHorseYellow_OnPlayerDamaged( entity player, var damageInfo )
{
	entity inflictor = DamageInfo_GetInflictor( damageInfo )

	if ( !IsValidProjectileWithMod( inflictor, GOLDEN_HORSE_MOD, GH_YELLOW ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( attacker ) )
		return

	if ( Bleedout_IsBleedingOut( player ) )
		return

	const float duration = 3

	Remote_CallFunction_Replay( attacker, "ServerToClient_ShowHealthRUI", attacker, player, duration )

	//This is just for tracking stats... could we do this with a status effect instead?
	if ( !(player in file.yellows) )
	{
		file.yellows[player] <- Time()
		thread GoldenHorseYellow_TimeTracked_Thread( attacker, player, duration )
	}
}

void function GoldenHorseYellow_TimeTracked_Thread( entity attacker, entity victim, float duration )
{
	victim.EndSignal( "OnDeath" )
	victim.EndSignal( "OnDestroy" )
	victim.EndSignal( "BleedOut_OnStartDying" )

	OnThreadEnd(
		function() : ( attacker, victim )
		{
			if ( victim in file.yellows )
			{
				float timeTracked = Time() - file.yellows[victim]
				int time          = int( RoundToNearestInt( timeTracked ) )
				delete file.yellows[victim]
			}
		}
	)

	while( Time() < file.yellows[victim] + duration && IsAlive( victim ) && !Bleedout_IsBleedingOut( victim ) )
	{
		WaitFrame()
	}
}
#endif

//PURPLE!
void function GoldenHorsePurple_Init()
{
	#if SERVER
		AddDamageCallback( "player", GoldenHorsePurple_OnPlayerDamaged )
	#endif
}


var function GoldenHorsePurple_OnWeaponPrimaryAttack( entity weapon, WeaponPrimaryAttackParams params )
{
	#if CLIENT
		if ( !InPrediction() )
			return
	#endif

	if ( !HasMod( weapon, GOLDEN_HORSE_MOD, GH_PURPLE ) )
		return

	float baseChance = GetWeaponInfoFileKeyField_GlobalFloat( weapon.GetWeaponClassName(), "golden_horse_purple_chance" )
	float growth     = GetWeaponInfoFileKeyField_GlobalFloat( weapon.GetWeaponClassName(), "golden_horse_purple_growth" )
	float whiffMax   = GetWeaponInfoFileKeyField_GlobalFloat( weapon.GetWeaponClassName(), "golden_horse_purple_whiff" )
	float reset      = GetWeaponInfoFileKeyField_GlobalFloat( weapon.GetWeaponClassName(), "golden_horse_purple_reset_sec" )

	float rand = RandomFloat( 1.0 )

	CritData data
	if ( !(weapon in file.crits) )
	{
		data.critChance = baseChance
		file.crits[weapon] <- data
		//We can potentially add these to weapon entity struct instead
		AddEntityDestroyedCallback( weapon, GoldenHorsePurple_OnEntityDestroyed )
	}

	data = file.crits[weapon]

	//Little cooldown on the crit chance if they haven't fired in a while (so we can't "store" crits)
	const float GOLDEN_HORSE_PURPLE_CRIT_RESET_SEC = 5
	const float GOLDEN_HORSE_PURPLE_CRIT_GROWTH = 0.1

	if ( Time() - weapon.GetNextAttackAllowedTime() /*GetLastWeaponFireTime not in S3*/ > reset )
		data.critChance = baseChance

	//printt( "CRIT CALC: " + data.critChance + " : " + (Time() - weapon.GetNextAttackAllowedTime() /*GetLastWeaponFireTime not in S3*/) )

	if ( rand < data.critChance )
	{
		//printt( "CRIT!" )
		if ( !HasMod( weapon, GOLDEN_HORSE_ACTIVE_MOD, GH_PURPLE ) )
		{
			AddMod( weapon, GOLDEN_HORSE_ACTIVE_MOD, GH_PURPLE )
			data.critChance = baseChance //we got a crit so reset the chance
			data.whiffs     = 0
			//This is very annoying atm
			//EmitSoundOnEntity( weapon, SFX_GOLDEN_HORSE_PURPLE_SUCCESS )
		}
	}
	else
	{
		data.critChance += growth //we want the crit to grow with each miss
		data.whiffs += 1 //check how many times we whiff

		//If we miss too many times, the next one is a crit for sure
		if ( data.whiffs >= whiffMax )
			data.critChance = 1.0
	}
}


void function GoldenHorsePurple_OnEntityDestroyed( entity weapon )
{
	delete file.crits[weapon]
	//RemoveEntityDestroyedCallback( weapon, GoldenHorsePurple_OnEntityDestroyed ) //not in S3
	printt( "Weapon Crit recently removed - size: " + file.crits.len() )
}


void function GoldenHorsePurple_PostFire( entity weapon )
{
	#if CLIENT
		if ( !InPrediction() )
			return
	#endif

	if ( !HasMod( weapon, GOLDEN_HORSE_MOD, GH_PURPLE ) )
		return

	if ( HasMod( weapon, GOLDEN_HORSE_ACTIVE_MOD, GH_PURPLE ) )
		RemoveMod( weapon, GOLDEN_HORSE_ACTIVE_MOD, GH_PURPLE )
}

bool function GoldenHorsePurple_HasMod( entity weapon )
{
	return HasMod( weapon, GOLDEN_HORSE_MOD, GH_PURPLE )
}

#if SERVER
void function GoldenHorsePurple_OnPlayerDamaged( entity player, var damageInfo )
{
	entity inflictor = DamageInfo_GetInflictor( damageInfo )

	if ( !IsValidProjectileWithMod( inflictor, GOLDEN_HORSE_ACTIVE_MOD, GH_PURPLE ) )
		return

	//If it's already a headshot, return
	if ( IsValidHeadShot( damageInfo, player ) )
		return

	DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
	DamageInfo_AddCustomDamageType( damageInfo, DF_HEADSHOT )


	float critScale = GetHeadshotDamageMultiplierFromDamageInfo( damageInfo )
	//critScale -= 0.05 //do we want to make crits worse than a normal headshot?
	DamageInfo_ScaleDamage( damageInfo, critScale )
	OnPlayerTookHeadshot( player, damageInfo )


	entity attacker = DamageInfo_GetAttacker( damageInfo )
	int damage      = int(ceil( DamageInfo_GetDamage( damageInfo ) ))
}
#endif

//RED!
void function GoldenHorseRed_Init()
{
	PrecacheParticleSystem( VFX_GOLDEN_HORSE_RED_SUMMON )
	PrecacheParticleSystem( VFX_GOLDEN_HORSE_RED_TELEPORT_START )
	PrecacheParticleSystem( VFX_GOLDEN_HORSE_RED_TELEPORT_END )
	PrecacheParticleSystem( VFX_GOLDEN_HORSE_RED_USE )

	PrecacheModel( MDL_GOLDEN_HORSE_NESSIE )

	Remote_RegisterClientFunction( "GoldenHorseRed_ShowRui", "entity" )
	Remote_RegisterClientFunction( "GoldenHorseRed_HideRui", "entity" )

	#if SERVER
		//TODO THIS ISN"T GOOD ENOUGH
		//Maybe an activation period or recall button
		//Should make nessie fight the target the owner shoots at if nessie doesnt already have a target
		//Nessies knock you off the zipline if they spawn in front of you LOL

		AddCallback_OnPlayerInventoryChanged( GoldenHorseRed_OnPlayerInventoryChanged )
		AddDamageByCallback( "player", Summon_OnDamagedByPlayer )
		Loot_AddCallback_OnWeaponAttachmentChanged( GoldenHorseRed_OnWeaponAttachmentChanged )

		RegisterSignal( SIG_GOLDEN_HORSE_RED_EMPTY )
	#endif

	#if CLIENT
		RegisterSignal( SIG_GOLDEN_HORSE_RED_HIDE_RUI )
		StatusEffect_RegisterEnabledCallback( eStatusEffect.golden_horse_red, GoldenHorseRed_OnStatusEffectEnabled )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.golden_horse_red, GoldenHorseRed_OnStatusEffectDisabled )
		AddCallback_OnPlayerWeaponSwitched( GoldenHorseRed_OnPlayerWeaponSwitched )
	#endif
}

float function GoldenHorseRed_GetCooldown()
{
	return GetCurrentPlaylistVarFloat( PVAR_GOLDEN_HORSE_RED_COOLDOWN, GOLDEN_HORSE_RED_SUMMON_COOLDOWN_TIME_SEC )
}


bool function GoldenHorseRed_HasMod( entity weapon )
{
	return HasMod( weapon, GOLDEN_HORSE_MOD, GH_RED )
}

#if SERVER
void function GoldenHorseRed_OnWeaponAttachmentChanged( entity player, entity weapon, string modToAdd, string modToRemove )
{
	if ( !IsValid( player ) )
		return

	if ( !IsValid( weapon ) )
		return

	if ( !weapon.IsWeaponX() )
		return

	if ( modToAdd == GOLDEN_HORSE_MOD + GH_RED )
	{
		Remote_CallFunction_Replay( player, "GoldenHorseRed_ShowRui", player )
	}
	else if ( modToRemove == GOLDEN_HORSE_MOD + GH_RED )
	{
		Remote_CallFunction_Replay( player, "GoldenHorseRed_HideRui", player )
	}
}

void function GoldenHorseRed_OnPlayerInventoryChanged( entity player )
{
	bool exists = false
	foreach ( entity weapon in player.GetMainWeapons() )
	{
		if ( DoesModExist( weapon, GOLDEN_HORSE_MOD + GH_RED ) )
		{
			exists = true
			break
		}
	}
	if ( exists )
	{
		if ( !(player in file.summoners) )
		{
			SummonData summoner
			file.summoners[player] <- summoner

			thread GoldenHorseRed_Heartbeat_Thread( player )
		}
	}
	else if ( player in file.summoners && file.summoners[player].nextAvailableSummon == -1 )
	{
		if ( file.summoners[player].maxSummons > 0 )
		{
			file.summoners[player].nextAvailableSummon = Time() + GoldenHorseRed_GetCooldown()
			StartSummonCooldown( player, GoldenHorseRed_GetCooldown() )
			thread SummonerCooldown_Thread( player, GoldenHorseRed_GetCooldown() )
		}
		else
			player.Signal( SIG_GOLDEN_HORSE_RED_EMPTY )
	}
}

//This checks for red hopups
//We do it like this to check for swaps between guns, etc, to make sure the hopup count adds up
void function GoldenHorseRed_Heartbeat_Thread( entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( SIG_GOLDEN_HORSE_RED_EMPTY )

	OnThreadEnd( void function() : ( player ) {
		delete file.summoners[player]
	} )

	while( IsValidSummoner( player ) )
	{
		SummonData summoner = file.summoners[player]

		summoner.maxSummons = 0
		foreach ( entity weapon in player.GetMainWeapons() )
		{
			if ( HasMod( weapon, GOLDEN_HORSE_MOD, GH_RED ) )
				summoner.maxSummons += 1
		}

		int diff = summoner.summons.len() - summoner.maxSummons
		if ( diff > 0 ) //Too many, remove summons
		{
			int num = 0
			foreach ( entity summon in summoner.summons )
			{
				thread HACK_SummonKill_Thread( summon )
				++num
				if ( num == diff )
					break
			}
		}
		else if ( diff < 0 && summoner.nextAvailableSummon == -1 )
		{
			thread SummonerCooldown_Thread( player, 0 )
		}

		WaitFrame()
		//printt( "SUMMONER HEARTBEAT: " + summoner.summons.len() + " :: " + summoner.maxSummons + " :: " + summoner.nextAvailableSummon )
	}
}
#endif


bool function HasSummonCooldown( entity player )
{
	return StatusEffect_HasSeverity( player, eStatusEffect.golden_horse_red )
}

#if SERVER
bool function IsValidSummoner( entity player )
{
	return IsValid( player ) && player in file.summoners
}

void function StartSummonCooldown( entity player, float duration )
{
	StatusEffect_AddTimed( player, eStatusEffect.golden_horse_red, 1.0, duration, 0.0 )
}

void function Summon( entity player )
{
	if ( !IsValidSummoner( player ) )
		return

	SummonData summoner = file.summoners[player]

	if ( summoner.summons.len() >= summoner.maxSummons )
		return

	vector spawnLocation = GetPetSpawnLocation( player )

	//Make the NPC and wait for it to die
	entity summon = CreateSummonNPC( spawnLocation, player.GetAngles(), player.GetTeam(), player )

	AddEntityCallback_OnKilled( summon, Summon_OnKilled )

	entity summonFx = StartParticleEffectOnEntity_ReturnEntity( summon, GetParticleSystemIndex( VFX_GOLDEN_HORSE_RED_SUMMON ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	//entity summonFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( VFX_GOLDEN_HORSE_RED_SUMMON ), summon.GetOrigin(), summon.GetAngles() )
	CopyRealmsFromTo( summon, summonFx )

	EmitSoundAtPosition( TEAM_UNASSIGNED, summon.GetOrigin(), SFX_GOLDEN_HORSE_RED_SUMMON, summon )

	summoner.summons.append( summon )
	printt( "SUMMON ADDED: " + summoner.summons.len() + " :: " + summoner.maxSummons )
	thread SummonLifetime_Thread( player, summon )
}

void function SummonLifetime_Thread( entity player, entity summon )
{
	summon.EndSignal( "OnDeath" )
	summon.EndSignal( "OnDestroy" )

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( SIG_GOLDEN_HORSE_RED_EMPTY )

	OnThreadEnd( void function() : ( player, summon ) {
		thread HACK_SummonKill_Thread( summon )
	} )

	while( true )
	{
		float distSqr = DistanceSqr( player.GetOrigin(), summon.GetOrigin() )
		bool hasEnemy = IsValid( summon.GetEnemy() )
		if ( (hasEnemy && distSqr > GOLDEN_HORSE_RED_MAX_DIST_COMBAT_SQR) || (!hasEnemy && distSqr > GOLDEN_HORSE_RED_MAX_DIST_SQR) )
		{
			bool waitingForValidSpawn = false
			while( !PlayerCanSpawnPet( player ) )
			{
				waitingForValidSpawn = true
				WaitFrame()
			}

			if ( waitingForValidSpawn )
			{
				waitingForValidSpawn = false
				distSqr              = DistanceSqr( player.GetOrigin(), summon.GetOrigin() )
				if ( distSqr <= GOLDEN_HORSE_RED_MAX_DIST_SQR )
				{
					continue
				}
			}

			entity startFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( VFX_GOLDEN_HORSE_RED_TELEPORT_START ), summon.GetOrigin(), summon.GetAngles() )
			CopyRealmsFromTo( summon, startFx )

			EmitSoundAtPosition( TEAM_UNASSIGNED, summon.GetOrigin(), SFX_GOLDEN_HORSE_RED_TELEPORT_START, summon )

			vector spawnLocation = GetPetSpawnLocation( player )
			summon.SetOrigin( spawnLocation )

			entity endFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( VFX_GOLDEN_HORSE_RED_TELEPORT_END ), summon.GetOrigin(), summon.GetAngles() )
			CopyRealmsFromTo( summon, endFx )

			//Remove enemy from memory
			summon.ClearEnemy()
			summon.ClearAllEnemyMemory()

			EmitSoundAtPosition( TEAM_UNASSIGNED, summon.GetOrigin(), SFX_GOLDEN_HORSE_RED_TELEPORT_END, summon )
		}
		wait GOLDEN_HORSE_RED_DIST_TIME_SEC
	}
}

//Logic to make summons attack your current target
void function Summon_OnDamagedByPlayer( entity hitEnt, var damageInfo )
{
	if ( !hitEnt.IsEntAlive() )
		return

	if ( !hitEnt.IsPlayer() )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !IsValidSummoner( attacker ) )
		return

	SummonData summoner = file.summoners[attacker]

	foreach ( entity summon in summoner.summons )
	{
		if ( !IsValid( summon ) )
			continue

		if ( IsValid( summon.GetEnemy() ) )
			continue

		//TODO: This is a slight improvement but it kinda seems like they still need LoS
		//And then they jump around in place
		summon.SetEnemy( hitEnt )
	}
}

void function Summon_OnKilled( entity summon, var damageInfo )
{
	entity player = summon.GetBossPlayer()
	if ( !IsValidSummoner( player ) )
		return

	SummonData summoner = file.summoners[player]
	summoner.summons.fastremovebyvalue( summon )

	if ( summoner.nextAvailableSummon == -1 )
	{
		summoner.nextAvailableSummon = Time() + GoldenHorseRed_GetCooldown()
		StartSummonCooldown( player, GoldenHorseRed_GetCooldown() )
		thread SummonerCooldown_Thread( player, GoldenHorseRed_GetCooldown() )
	}

	printt( "SUMMON REMOVED: " + summoner.summons.len() + " :: " + summoner.maxSummons + " SUMMON TIME: " + summoner.nextAvailableSummon )
}

void function SummonerCooldown_Thread( entity player, float cooldown )
{
	if ( !IsValidSummoner( player ) )
		return

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( SIG_GOLDEN_HORSE_RED_EMPTY )

	wait cooldown

	printt( "SUMMON COOLDOWN HIT" )

	//Wait until we're not doing crazy stuff that will get the nessie broke
	while( !PlayerCanSpawnPet( player ) )
	{
		WaitFrame()
	}

	//Summon until we're full of summons, and then when we're done reset the clock
	while( IsValidSummoner( player ) )
	{
		//If we finished the cooldown, check if we have a weapon that can still put on a red hopup
		if ( file.summoners[player].maxSummons <= 0 )
		{
			bool exists = false
			foreach ( entity weapon in player.GetMainWeapons() )
			{
				if ( DoesModExist( weapon, GOLDEN_HORSE_MOD + GH_RED ) )
				{
					exists = true
					break
				}
			}
			if ( !exists ) //It doesn't exist, so let the threads know we're empty
			{
				player.Signal( SIG_GOLDEN_HORSE_RED_EMPTY )
				break
			}
		}
		Summon( player )

		if ( file.summoners[player].summons.len() >= file.summoners[player].maxSummons )
		{
			file.summoners[player].nextAvailableSummon = -1
			break
		}
		else
			wait 0.7 //wait a beat in between summons
	}
}

void function HACK_SummonKill_Thread( entity summon )
{
	if ( !IsValid( summon ) )
		return

	if ( !summon.IsEntAlive() )
		return

	summon.EndSignal( "OnDeath" )
	summon.EndSignal( "OnDestroy" )
	//Hey gang
	//This is the stupidest hack I've done
	//Looks like there's some race conditions mumbo jumbo around entities getting killed on map despawn
	WaitFrame()
	if ( IsValid( summon ) && summon.IsEntAlive() ) //THIS WOULD OTHERWISE CRASH WHEN THE MAP UNLOADS
		summon.TakeDamage( 9999, null, null, {} )
}

entity function CreateSummonNPC( vector origin, vector angles, int team, entity owner )
{
	entity summon = Nessie_SpawnNPC( team, owner, origin, angles )
	if ( summon == null )
		return null

	//probably a smarter way to do this
	foreach ( entity child in GetChildren( summon ) )
	{
		if ( child.GetScriptName() == NESSIE_SPIDER_SCRIPT_NAME )
			child.SetModel( MDL_GOLDEN_HORSE_NESSIE )
	}

	summon.kv.alwaysalert = true

	summon.SetTitle( "#GOLDEN_HORSE_NESSIE_TITLE" )

	summon.SetEnemyChangeCallback( OnEnemyChanged )

	PetStartFollowingOwner( summon, owner )

	float enemyDist = GetCurrentPlaylistVarFloat( PVAR_GOLDEN_HORSE_RED_ENEMY_DIST, GOLDEN_HORSE_RED_ENEMY_DIST )
	summon.SetMaxEnemyDistOverride( enemyDist )
	summon.SetMaxEnemyDistHeavyArmorOverride( enemyDist )

	if ( GetCurrentPlaylistVarBool( PVAR_GOLDEN_HORSE_RED_USE, true ) )
		CreateUsableNessie( summon )

	//Causing a couple false positives, but not covering all the negatives
	//thread NessieStuckMonitor_Thread( summon )

	Highlight_SetEnemyHighlight( summon, "enemy_ai" )

	return summon
}

//TODO: move to _ai_nessie after golden horse...
void function CreateUsableNessie( entity nessie )
{
	nessie.SetUsable()
	nessie.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER | USABLE_BY_TEAMMATES | USABLE_BLOCK_CONTINUOUS_USE )
	nessie.RemoveUsableValue( USABLE_BY_ENEMIES )
	nessie.SetUsablePriority( USABLE_PRIORITY_LOW )
	nessie.SetUsePrompts( "#WPN_HOPUP_GOLDEN_HORSE_RED_USE_PROMPT", "#WPN_HOPUP_GOLDEN_HORSE_RED_USE_PROMPT" )

	AddCallback_OnUseEntity_ServerOnly( nessie, Nessie_OnUse )
}

void function Nessie_OnUse( entity summon, entity player, int useInputFlags )
{
	if ( !IsValid( summon ) )
		return

	summon.UnsetUsable()

	if ( IsValid( summon ) && summon.IsInterruptable() )
	{
		string anim
		int index = RandomInt( 3 )
		switch( index )
		{
			case 0:
			case 1:
				anim = "spdr_idle_react_threatA_noloop"
				break

			case 2:
				anim = "spdr_pain_small"
				break

			default:
				anim = "spdr_idle_react_threatA_noloop"
				break
		}

		thread PlayAnim( summon, anim )
	}

	vector origin = summon.GetOrigin()

	entity useFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( VFX_GOLDEN_HORSE_RED_USE ), origin + <0, 0, 50>, player.GetAngles() )
	CopyRealmsFromTo( player, useFx )

	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, SFX_GOLDEN_HORSE_RED_USE, player )

	summon.SetHealth( summon.GetMaxHealth() )

	thread Nessie_DebounceUse_Thread( summon )
}

void function Nessie_DebounceUse_Thread( entity summon )
{
	summon.EndSignal( "OnDeath" )
	summon.EndSignal( "OnDestroy" )

	wait 5

	summon.SetUsable()

	if ( GetCurrentPlaylistVarBool( "golden_horse_red_remove_use_enemy", true ) )
	{
		summon.RemoveUsableValue( USABLE_BY_ENEMIES )
		summon.SetUsablePriority( USABLE_PRIORITY_LOW )
	}
}

void function NessieStuckMonitor_Thread( entity nessie )
{
	nessie.EndSignal( "OnDeath", "OnDestroy" )
	const string IDLE_WANDER_SCHEDULE = "SCHED_IDLE_WANDER"
	array< string > stationarySchedules = [
		"SCHED_FOLLOWER_IDLE_STAND",
		"SCHED_WAIT_FOR_SCRIPT_ANIM_END",
		"SCHED_COMBAT_FACE",
		"SCHED_RANGE_ATTACK1"
	]

	bool maybeTryingToMove    = false
	float stuckCheckStartTime = 0
	vector stuckCheckStartPos
	while ( true )
	{
		WaitFrame()
		if ( stationarySchedules.contains( nessie.GetCurScheduleName() ) )
		{
			maybeTryingToMove = false

			wait 0.5
			continue
		}

		if ( !maybeTryingToMove )
		{
			maybeTryingToMove   = true
			stuckCheckStartPos  = nessie.GetOrigin()
			stuckCheckStartTime = Time()
		}

		float temp = Distance2DSqr( stuckCheckStartPos, nessie.GetOrigin() )
		if ( Distance2DSqr( stuckCheckStartPos, nessie.GetOrigin() ) < 5 )
		{
			if ( (Time() - stuckCheckStartTime) > 1.0 )
			{
				printf( "NESSIE - we're stuck :(" )
			}
		}
		else
		{
			wait 1
			maybeTryingToMove = false
		}
	}
}
#endif

//NESSIE FOLLOW -- modified from sh_player_pet

#if SERVER
vector function GetPetSpawnLocation( entity player )
{
	const float behind = -120
	const float side = -120

	vector spawnLocation = player.GetOrigin() + player.GetForwardVector() * -120
	if ( CoinFlip() )
	{
		spawnLocation += player.GetRightVector() * side
	}
	else
	{
		spawnLocation -= player.GetRightVector() * side
	}

	vector safeSpotOnNavmesh = NavMesh_GetClosestPoint( spawnLocation )
	//DebugDrawSphere( safeSpotOnNavmesh, 4.0, 0, 128, 0, true, 100.0, 4 )

	return safeSpotOnNavmesh
}

bool function PlayerCanSpawnPet( entity player, array<entity> squad = [] )
{
	if ( !IsValid( player ) )
		return false

	if ( !IsAlive( player ) )
		return false

	if ( player.IsZiplining() )
		return false

	//if ( player.IsSkydiving() /*Player_IsSkydiving not in S3*/ )
		return false

	if ( !player.IsOnGround() )
		return false

	if ( player.IsPhaseShifted() )
		return false

	if ( player.GetPlayerNetBool( "playerInPlane" ) )
		return false

	if ( player.IsNoclipping() )
		return false

	if ( player.IsMountingZipline() )
		return false

	//if ( player.Player_IsSkydiveAnticipating() )
		return false

	return true
}

void function OnEnemyChanged( entity pet )
{
	entity owner = PetGetOwner( pet )
	if ( !IsValid( owner ) )
		return

	entity enemy = pet.GetEnemy()

	if ( enemy == null )
		PetStartFollowingOwner( pet, owner )

	//Do we even need to check this? if it has an enemy, it should probably stop following owner to attack?
	else if ( enemy.IsNPC() || enemy.IsPlayer() || IsDoor( enemy ) )
		PetStopFollowingOwner( pet )

	else
		PetStartFollowingOwner( pet, owner )
}

void function PetStopFollowingOwner( entity pet )
{
	ClearFollowBehavior( pet )
}

entity function PetGetOwner( entity pet )
{
	return pet.GetBossPlayer()
}

void function PetStartFollowingOwner( entity pet, entity owner )
{
	if ( !IsAlive( pet ) )
		return

	if ( !IsAlive( owner ) )
		return

	//Set target move tolerance to change follow position when follow target moves
	float followTargetMoveTolerance = GetCurrentPlaylistVarFloat( PVAR_GOLDEN_HORSE_RED_FOLLOW_MOVE, GOLDEN_HORSE_RED_FOLLOW_MOVE )

	//Set goal tolerance when in combat
	float followGoalCombatTolerance = GetCurrentPlaylistVarFloat( PVAR_GOLDEN_HORSE_RED_FOLLOW_COMBAT, GOLDEN_HORSE_RED_FOLLOW_COMBAT )

	//Set goal tolerance when not in combat
	float followGoalTolerance = GetCurrentPlaylistVarFloat( PVAR_GOLDEN_HORSE_RED_FOLLOW_GOAL, GOLDEN_HORSE_RED_FOLLOW_GOAL )

	//float attackRadius = 1024				//will auto attack enemies within this radius

	//if ( GetCurrentPlaylistVarBool( "squad_pet_force_clear_enemy", true ) )
	//{
	pet.ClearEnemy()
	//}

	//if ( GetCurrentPlaylistVarBool( "squad_pet_force_clear_enemy_memory", true ) )
	//{
	pet.ClearAllEnemyMemory()
	//}

	NPCFollowsPlayer( pet, owner )

	//designate owner/pet relationship
	pet.SetBossPlayer( owner )
}
#endif //SERVER

#if CLIENT
void function GoldenHorseRed_OnPlayerWeaponSwitched( entity player, entity newWeapon, entity oldWeapon )
{
	if ( DoesModExist( newWeapon, GOLDEN_HORSE_MOD + GH_RED ) )
		GoldenHorseRed_ShowRui( player )
	else
		GoldenHorseRed_HideRui( player )
}

void function GoldenHorseRed_OnStatusEffectEnabled( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return

	if ( !actuallyChanged )
		return

	GoldenHorseRed_ShowRui( player )
}

void function GoldenHorseRed_OnStatusEffectDisabled( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return

	if ( !actuallyChanged )
		return

	GoldenHorseRed_HideRui( player )
}

void function GoldenHorseRed_ShowRui( entity player )
{
	thread GoldenHorseRed_SummonRui_Thread( player )
}

void function GoldenHorseRed_HideRui( entity player )
{
	player.Signal( SIG_GOLDEN_HORSE_RED_HIDE_RUI )
}

void function GoldenHorseRed_SummonRui_Thread( entity player )
{
	AssertIsNewThread()

	if ( !IsValid( player ) || !IsLocalViewPlayer( player ) )
		return

	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

	if ( !IsValid( weapon ) )
		return

	if ( !DoesModExist( weapon, GOLDEN_HORSE_MOD + GH_RED ) ) //current weapon does not have mod
		return

	if ( !HasSummonCooldown( player ) )
		return

	player.Signal( WEAPON_CHARGED_RUI_ABORT_SIGNAL )
	player.Signal( SIG_GOLDEN_HORSE_RED_HIDE_RUI )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( SIG_GOLDEN_HORSE_RED_HIDE_RUI )
	player.EndSignal( WEAPON_CHARGED_RUI_ABORT_SIGNAL )

	weapon.Signal( SIG_GOLDEN_HORSE_RED_HIDE_RUI )
	weapon.EndSignal( SIG_GOLDEN_HORSE_RED_HIDE_RUI )
	weapon.EndSignal( "OnDestroy" )

	var rui = ClWeaponStatus_GetWeaponHudRui( player )

	if ( rui == null )
		return

	RuiDestroyNestedIfAlive( rui, "chargedHandle" )

	var nestedRui = RuiCreateNested( rui, "chargedHandle", RUI_GOLDEN_HORSE_RED_HUD )
	if ( nestedRui == null )
		return

	file.redRui = nestedRui
	OnThreadEnd(
		function() : ( rui, nestedRui )
		{
			RuiSetBool( rui, "showChargeBar", false )
			RuiDestroyNested( rui, "chargedHandle" )
			file.redRui = null
		}
	)

	RuiSetBool( rui, "showChargeBar", true )
	RuiSetBool( nestedRui, "showChargeBar", true )

	while( HasSummonCooldown( player ) && file.redRui != null )
	{
		weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
		if ( !IsValid( weapon ) || !GoldenHorseRed_HasMod( weapon ) )
			break

		float timeRemaining = StatusEffect_GetTimeRemaining( player, eStatusEffect.golden_horse_red )
		float chargeFrac    = timeRemaining / GoldenHorseRed_GetCooldown()

		RuiSetFloat( nestedRui, "chargeBarTimeRemaining", timeRemaining )
		RuiSetFloat( nestedRui, "chargeBarFrac", chargeFrac )

		WaitFrame()
	}
}
#endif

#if SERVER
void function GoldenHorse_OnLootSpawned( entity ent, LootData data, int count )
{
	//We'll want to use this to hook into colors I think
	switch( data.ref )
	{
		case GOLDEN_HORSE_MOD + GH_GREEN:
			ent.kv.rendercolor = "0 255 0"
			break

		case GOLDEN_HORSE_MOD + GH_BLUE:
			ent.kv.rendercolor = "0 0 255"
			break

		case GOLDEN_HORSE_MOD + GH_PURPLE:
			ent.kv.rendercolor = "93 63 211"
			break

		case GOLDEN_HORSE_MOD + GH_YELLOW:
			ent.kv.rendercolor = "255 255 0"
			break

		case GOLDEN_HORSE_MOD + GH_RED:
			ent.kv.rendercolor = "255 0 0"
			break
	}
}
#endif

#if DEVELOPER
#if SERVER
void function DEV_SpawnGoldenHorseHopups( entity player )
{
	vector origin = player.GetOrigin()

	array<string> hopups = HopupGoldenHorse_GetEnabledList()

	const diff = 20
	origin.x += diff * (hopups.len() / 2.0)

	foreach ( string hopup in hopups )
	{
		SpawnGenericLoot( hopup, origin, < -1, -1, -1 >, -1 )
		origin.x -= diff
	}
}

void function DEV_SpawnGoldenHorseHopupsWithWeapons( entity player )
{
	vector origin = player.GetOrigin()

	array<string> hopups = HopupGoldenHorse_GetEnabledList()

	const diffX = 40
	const diffY = 60

	origin.x += diffX * (hopups.len() / 2.0)
	float startingX = origin.x

	foreach ( string hopup in hopups )
	{
		origin.x = startingX
		AttachmentData aData = GetAttachmentData( hopup )
		foreach ( string weapon in aData.compatibleWeapons )
		{
			SpawnLoot( weapon, origin, false )
			SpawnLoot( hopup, origin, false )
			origin.x -= diffX
		}
		origin.y -= diffY
	}
}

void function DEV_TestGoldenHorseRedSpawn( entity player, int numToKill = 99 )
{
	if ( !IsValidSummoner( player ) )
		return

	SummonData summons = file.summoners[player]

	int num = 0
	foreach ( entity summon in summons.summons )
	{
		thread HACK_SummonKill_Thread( summon )
		++num
		if ( num == numToKill )
			break
	}
}

void function DEV_SpawnGoldenHorseSummon( entity player )
{
	CreateSummonNPC( player.GetOrigin(), player.GetAngles(), player.GetTeam(), player )
}
#endif
#endif

                         