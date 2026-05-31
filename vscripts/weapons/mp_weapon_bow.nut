global function MpWeaponBow_Init
global function OnWeaponActivate_weapon_bow
global function OnWeaponDeactivate_weapon_bow
global function OnWeaponPrimaryAttack_weapon_bow
global function OnProjectileCollision_weapon_bow
global function OnWeaponChargeBegin_weapon_bow
global function OnWeaponChargeEnd_weapon_bow
global function OnWeaponChargeLevelIncreased_weapon_bow
global function OnWeaponCustomActivityStart_weapon_bow
global function OnWeaponCustomActivityEnd_weapon_bow

#if CLIENT
global function AttemptCancelCharge
#endif

#if SERVER
global function Remote_CancelCharge
#endif

#if CLIENT
global function WeaponBow_UpdateArrowColor
#endif

global function ArrowsCanBePickedUp

const bool DEBUG_INFINITE_SPECIAL_ARROWS = false

const string HELPER_DOT_RUI_ABORT_SIGNAL = "bow_helper_dot_rui_abort"
const string HELPER_DOT_FIRE_ANIM = "fire_fullyCharged"
const string HELPER_DOT_HIDE_ANIM_EVENT = "hide_helper_dot"

const string BOW_MOVER_SCRIPTNAME = "bow_mover"

enum eArrowTypes
{
	STANDARD,
	SHATTER,

	_count
}
const array<int> STANDARD_ARROWS_AVAILABLE_DMG_LEVELS = [0, 1, 2, 3, 4, 5]
const array<int> SHATTER_ARROWS_AVAILABLE_DMG_LEVELS = [0, 3, 5]

//TODO: remove hacky charge level mod thing when we get code features
const string CHARGE_MODS_BASE_STR = "charge_lv"
const string STANDARD_CHARGE_DMG_MODS_BASE_STR = "std_charge_dmg_lv"
const int CHARGE_MODS_MAX_LEVEL = 5
const string CHARGE_COMPLETE_SOUND_SETTING = "charge_complete_sound_1p"

const string CENTER_DOT_MIN_CHARGE_SETTING = "center_dot_helper_min_charge_level"

const string BOW_DEACTIVATE_SIGNAL = "BowDeactivate"

const string SPECIAL_ARROWS_REQUIRED_STRING = "#WPN_BOW_SPECIAL_ARROWS_REQUIRED"
const string NEXT_ARROW_TYPE_SOUND = "weapon_mastiff_first_draw_mech_piece"
const string ARROW_COLOR_STANDARD_SETTING = "arrows_standard_color"
const string ARROW_COLOR_SHATTER_SETTING = "arrows_shatter_color"

const asset SINGLE_ARROW_MODEL = $"mdl/weapons/bullets/w_arrow_projectile.rmdl"
const asset SINGLE_ARROW_MODEL_PICKUP = $"mdl/weapons_r5/loot/_master/w_loot_wep_arrow_single.rmdl"
const float ARROWS_STICK_CHANCE_DEFAULT = 1.0
const int ARROWS_STICK_MAX_PLAYER_DEFAULT = 4
const int ARROWS_STICK_MAX_WORLD_DEFAULT = 750
const int ARROWS_STICK_MAX_ZONE_DEFAULT = 40
const int ARROWS_STICK_MAX_UNKNOWN_ZONE_DEFAULT = 80
const float ARROWS_STICK_INTO_PLAYER_DIST_DEFAULT = 9
const float ARROWS_STICK_LIFETIME_PLAYER_DEFAULT = 90
const float ARROWS_STICK_LIFETIME_WORLD_DEFAULT = 90
const bool ARROWS_CAN_BE_PICKED_UP_DEFAULT = false

const string SHATTER_ARROWS_DMG_MODS_BASE_STR = "arrows_shatter_dmg_lv"

                               
const string VALENTINES_COLOR = "255 119 188 255"
const vector VALENTINES_COLOR_VEC = <255, 119, 188>
      

const string FX_BOW_LIGHT_PREFIX = "fx_bow_light_"
const int FX_BOW_LIGHT_COUNT = 3
const table< string, array<string> > fxLightPointsForOptic =
{
	["ironsights"] = ["SIGHT_LIGHT_01", "SIGHT_LIGHT_02", "SIGHT_LIGHT_03"],
	["optic_cq_hcog_classic"] = ["HCOG_OG_LIGHT_01", "HCOG_OG_LIGHT_02", "HCOG_OG_LIGHT_03"],
	["optic_cq_hcog_bruiser"] = ["HCOG_OG_LIGHT_01", "HCOG_OG_LIGHT_02", "HCOG_OG_LIGHT_03"],
	["optic_cq_holosight"] = ["HOLO_LIGHT_01", "HOLO_LIGHT_02", "HOLO_LIGHT_03"],
	["optic_cq_holosight_variable"] = ["HOLOMAG_LIGHT_01", "HOLOMAG_LIGHT_02", "HOLOMAG_LIGHT_03"],
	["optic_ranged_hcog"] = ["ACGS_LIGHT_01", "ACGS_LIGHT_02", "ACGS_LIGHT_03"]
}

const table<string, float> UI_OPTIC_CLAMP_OPTICS =
{
	["ironsights"] = 0.05,
	["optic_cq_holosight"] = 0.1
}

struct
{
	bool fileStructInitialized = false

	float fullChargeSpeed
	float fullChargeSpeedSplit

	string chargeCompleteSound

	MarksmansTempoSettings& bowTempoSettings

	table<string, array<asset> > fxLightAssets1p

	array<vector> arrowTypeColors

	int centerDotHelperMinChargeLvl
	int centerDotHelperMinChargeLvlOpticClamp

	float arrowsStickChance
	int   arrowsStickMaxPlayer
	int   arrowsStickMaxWorld
	int   arrowsStickMaxZone
	int   arrowsStickMaxUnknownZone
	float arrowsStickIntoPlayerDist
	float arrowsStickLifetimePlayer
	float arrowsStickLifetimeWorld
	bool  arrowsCanBePickedUp

	#if SERVER
		RingBufferEntity&            arrowsInWorld
		table<int, RingBufferEntity> arrowsInZones
	#endif
	int ammoStackSize

	LootData& singleArrowLootData

	#if CLIENT
		bool inspectDOF
	#endif

} file


void function MpWeaponBow_Init()
{
	PrecacheWeapon( $"mp_weapon_bow" )

	RegisterSignal( BOW_DEACTIVATE_SIGNAL )
	RegisterSignal( HELPER_DOT_RUI_ABORT_SIGNAL )

	PrecacheModel( SINGLE_ARROW_MODEL )
	PrecacheModel( SINGLE_ARROW_MODEL_PICKUP )

	#if SERVER
		AddWeaponModChangedCallback( "mp_weapon_bow", OnWeaponModChanged_WeaponBow )
	#endif

	file.fxLightAssets1p = {}
	string settingStr
	foreach ( string optic, array<string> attachments in fxLightPointsForOptic )
	{
		array<asset> fxLightArr = []
		for ( int i = 0; i < FX_BOW_LIGHT_COUNT; i++ )
		{
			settingStr = FX_BOW_LIGHT_PREFIX + optic + "_" + i
			asset fx1p = GetWeaponInfoFileKeyFieldAsset_Global( "mp_weapon_bow", settingStr + "_1p" )
			#if SERVER
				PrecacheEffect( fx1p )
			#endif
			fxLightArr.append( fx1p )
		}
		file.fxLightAssets1p[optic] <- fxLightArr
	}

	Remote_RegisterServerFunction( "Remote_CancelCharge" )

	#if CLIENT
		RegisterConCommandTriggeredCallback( "+weaponcycle", AttemptCancelCharge )
		//RegisterConCommandTriggeredCallback( "+speed", AttemptCancelCharge )
		RegisterConCommandTriggeredCallback( "+reload", AttemptCancelCharge )
	#endif


	file.arrowsStickChance         = GetPlaylistVarFloat( GetCurrentPlaylistName(), "arrows_stick_chance", ARROWS_STICK_CHANCE_DEFAULT )
	file.arrowsStickMaxPlayer      = GetPlaylistVarInt( GetCurrentPlaylistName(), "arrows_stick_max_player", ARROWS_STICK_MAX_PLAYER_DEFAULT )
	file.arrowsStickMaxWorld       = GetPlaylistVarInt( GetCurrentPlaylistName(), "arrows_stick_max_world", ARROWS_STICK_MAX_WORLD_DEFAULT )
	file.arrowsStickMaxZone        = GetPlaylistVarInt( GetCurrentPlaylistName(), "arrows_stick_max_per_zone", ARROWS_STICK_MAX_ZONE_DEFAULT )
	file.arrowsStickMaxUnknownZone = GetPlaylistVarInt( GetCurrentPlaylistName(), "arrows_stick_max_unknown_zone", ARROWS_STICK_MAX_ZONE_DEFAULT )
	file.arrowsStickIntoPlayerDist = GetPlaylistVarFloat( GetCurrentPlaylistName(), "arrows_stick_into_player_dist", ARROWS_STICK_INTO_PLAYER_DIST_DEFAULT )
	file.arrowsStickLifetimePlayer = GetPlaylistVarFloat( GetCurrentPlaylistName(), "arrows_stick_lifetime_player", ARROWS_STICK_LIFETIME_PLAYER_DEFAULT )
	file.arrowsStickLifetimeWorld  = GetPlaylistVarFloat( GetCurrentPlaylistName(), "arrows_stick_lifetime_world", ARROWS_STICK_LIFETIME_WORLD_DEFAULT )
	file.arrowsCanBePickedUp       = GetPlaylistVarBool( GetCurrentPlaylistName(), "arrows_can_be_picked_up", ARROWS_CAN_BE_PICKED_UP_DEFAULT )

	#if CLIENT
		file.inspectDOF = GetPlaylistVarBool( GetCurrentPlaylistName(), "bow_inspect_dof", true )
	#endif
	#if SERVER
		file.arrowsInWorld = RingBufferEntity_Init( file.arrowsStickMaxWorld )
	#endif
}


bool function ArrowsCanBePickedUp()
{
	return file.arrowsCanBePickedUp
}


void function OnWeaponActivate_weapon_bow( entity weapon )
{
	//this isn't in Init because many refs aren't loaded or initialized at that time, lame
	if ( !file.fileStructInitialized )
	{
		file.fileStructInitialized = true

		file.fullChargeSpeed      = GetWeaponInfoFileKeyField_GlobalFloat( "mp_weapon_bow", "projectile_launch_speed_full_charge" )
		file.fullChargeSpeedSplit = GetWeaponInfoFileKeyField_GlobalFloat( "mp_weapon_bow", "projectile_launch_speed_full_charge_shatter_arrows" )

		file.chargeCompleteSound = GetWeaponInfoFileKeyField_GlobalString( "mp_weapon_bow", CHARGE_COMPLETE_SOUND_SETTING )

		MarksmansTempoSettings settings
		settings.requiredShots             = GetWeaponInfoFileKeyField_GlobalInt( "mp_weapon_bow", MARKSMANS_TEMPO_REQUIRED_SHOTS_SETTING )
		settings.graceTimeBuildup          = GetWeaponInfoFileKeyField_GlobalFloat( "mp_weapon_bow", MARKSMANS_TEMPO_GRACE_TIME_SETTING )
		settings.graceTimeInTempo          = GetWeaponInfoFileKeyField_GlobalFloat( "mp_weapon_bow", MARKSMANS_TEMPO_GRACE_TIME_IN_TEMPO_SETTING )
		settings.fadeoffMatchGraceTime     = GetWeaponInfoFileKeyField_GlobalInt( "mp_weapon_bow", MARKSMANS_TEMPO_FADEOFF_MATCH_GRACE_TIME )
		settings.fadeoffOnPerfectMomentHit = GetWeaponInfoFileKeyField_GlobalFloat( "mp_weapon_bow", MARKSMANS_TEMPO_FADEOFF_ON_PERFECT_MOMENT_SETTING )
		settings.fadeoffOnFire             = GetWeaponInfoFileKeyField_GlobalFloat( "mp_weapon_bow", MARKSMANS_TEMPO_FADEOFF_ON_FIRE_SETTING )
		settings.weaponDeactivateSignal    = BOW_DEACTIVATE_SIGNAL
		file.bowTempoSettings              = settings

		file.centerDotHelperMinChargeLvl           = GetWeaponInfoFileKeyField_GlobalInt( "mp_weapon_bow", CENTER_DOT_MIN_CHARGE_SETTING )
		file.centerDotHelperMinChargeLvlOpticClamp = GetWeaponInfoFileKeyField_GlobalInt( "mp_weapon_bow", CENTER_DOT_MIN_CHARGE_SETTING + "_optic_clamp" )

		Assert( eArrowTypes._count == 2 )    //make sure to add new logic for new arrow tips here
		file.arrowTypeColors.append( GetWeaponInfoFileKeyField_GlobalVectorInt( "mp_weapon_bow", ARROW_COLOR_STANDARD_SETTING ) )
		file.arrowTypeColors.append( GetWeaponInfoFileKeyField_GlobalVectorInt( "mp_weapon_bow", ARROW_COLOR_SHATTER_SETTING ) )

		//file.ammoStackSize = SURVIVAL_Loot_GetLootDataByRef( SURVIVAL_Loot_GetLootDataByRef( "mp_weapon_bow" ).ammoType ).inventorySlotCount

		file.singleArrowLootData = SURVIVAL_Loot_GetLootDataByRef( ARROWS_AMMO )

		if ( ArrowsCanBePickedUp() )
			SetCallback_LootTypeExtraCanUseFunction( file.singleArrowLootData, StuckArrow_ExtraCanUseFunction )

		#if SERVER
			file.arrowsInZones[-1] <- RingBufferEntity_Init( file.arrowsStickMaxUnknownZone )
			foreach ( int id in MapZones_GetAllZoneIDs() )
			{
				file.arrowsInZones[id] <- RingBufferEntity_Init( file.arrowsStickMaxZone )
			}
		#endif
	}

	entity player = weapon.GetWeaponOwner()


	thread ShatterRounds_UpdateShatterRoundsThink( weapon )
	#if SERVER
		if ( weapon.HasMod( SHATTER_ROUNDS_ALTFIRE_MOD ) )
			thread ShatterRounds_ADSThink ( player, weapon )
		else
			weapon.RemoveMod( SHATTER_ROUNDS_HIPFIRE_MOD )
	#endif
	thread MarksmansTempo_OnActivate( weapon, file.bowTempoSettings )

	                               
		#if SERVER
		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_VALENTINES_S15 ) )
			Valentines_ShowRangeFX( weapon.GetOwner() )
		#endif
       
}


void function OnWeaponDeactivate_weapon_bow( entity weapon )
{
	ClearChargeAndDmgLevelMods( weapon )
	#if CLIENT
		weapon.Signal( BOW_DEACTIVATE_SIGNAL )

		weapon.Signal( SHATTER_ROUNDS_THINK_END_SIGNAL )

		#if SERVER
			weapon.Signal( SHATTER_ROUNDS_ADS_THINK_THREAD_ABORT_SIGNAL )
		#endif

	#endif
	MarksmansTempo_OnDeactivate( weapon, file.bowTempoSettings )

	                               
	#if SERVER
		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_VALENTINES_S15 ) )
		{
			entity player = weapon.GetOwner()
			if ( IsValid( player ) )
				weapon.GetOwner().Signal( VALENTINES_S15_HEAL_CANCELED_SIGNAL )
		}
		#endif
       
}


var function OnWeaponPrimaryAttack_weapon_bow( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	if ( !IsValid( weapon ) )
		return 0

	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) || !player.IsPlayer() )
		return 0

	#if CLIENT
		if ( !(InPrediction() && weapon.ShouldPredictProjectiles()) )
			return 0
	#endif

	ApplyModsForChargeLevel( weapon, weapon.GetWeaponChargeLevel() )

	weapon.SetSoundCodeControllerValue( 100.0 * weapon.GetWeaponChargeFractionCurved() )

	//charge varying vals
	float adjustedChargeFrac = max( 0.0, min( weapon.GetWeaponChargeFractionCurved(), 1.0 ) )

	float baseSpeed       = weapon.GetWeaponSettingFloat( eWeaponVar.projectile_launch_speed )
	float speedMultiplier = 0.0
	bool ignoreSpread     = false

	if ( weapon.HasMod( SHATTER_ROUNDS_HIPFIRE_MOD ) )
	{
		speedMultiplier = GraphCapped( adjustedChargeFrac, 0.0, 1.0, baseSpeed, file.fullChargeSpeedSplit )
		ignoreSpread    = true
	}
	else
	{
		speedMultiplier = GraphCapped( adjustedChargeFrac, 0.0, 1.0, baseSpeed, file.fullChargeSpeed )
	}
	speedMultiplier /= baseSpeed        //the code multiplies by projectile_launch_speed internally, the speed is meant to be a multipler of that base speed


	                    
		GoldenHorsePurple_OnWeaponPrimaryAttack( weapon, attackParams )
       
	weapon.FireWeapon_Default( attackParams.pos, attackParams.dir, speedMultiplier, 1.0, ignoreSpread )
	                    
		GoldenHorsePurple_PostFire( weapon )
       

	MarksmansTempo_OnFire( weapon, file.bowTempoSettings, true )

	thread ClearChargeAfterFrame( weapon )

	#if CLIENT
		if ( InPrediction() )
		{
			int slot     = GetSlotForWeapon( player, weapon )
			string optic = ""
			if ( slot >= 0 )
			{
				optic = SURVIVAL_GetWeaponAttachmentForPoint( player, slot, "sight" )
			}
			else
			{
				Warning( "Invalid weapon slot " + slot + " for bow on player " + player )
				return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
			}

			if ( optic == "" )
				optic = "ironsights"
			bool isClampedOptic   = optic in UI_OPTIC_CLAMP_OPTICS
			float clampOpticDelay = isClampedOptic ? UI_OPTIC_CLAMP_OPTICS[optic] : 0.0
			int minChargeLevel    = isClampedOptic ? file.centerDotHelperMinChargeLvlOpticClamp : file.centerDotHelperMinChargeLvl
			int chargeLvl         = weapon.GetWeaponChargeLevel() - 1
			if ( chargeLvl >= minChargeLevel )
			{
				weapon.Signal( HELPER_DOT_RUI_ABORT_SIGNAL )
				float seqDur   = weapon.GetSequenceDuration( HELPER_DOT_FIRE_ANIM )
				float frac     = weapon.GetScriptedAnimEventCycleFrac( HELPER_DOT_FIRE_ANIM, HELPER_DOT_HIDE_ANIM_EVENT )
				float duration = seqDur * frac
				float delay    = 0.0
				if ( isClampedOptic && chargeLvl < file.centerDotHelperMinChargeLvl && chargeLvl >= file.centerDotHelperMinChargeLvlOpticClamp )
				{
					duration -= clampOpticDelay
					delay = clampOpticDelay
				}
				thread DisplayCenterDotRui( weapon, HELPER_DOT_RUI_ABORT_SIGNAL, delay, duration, 0.7, 0.05, 0.1 )
			}
		}
	#endif

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}


void function OnWeaponCustomActivityStart_weapon_bow( entity weapon )
{
	#if CLIENT
		if ( !file.inspectDOF )
			return

		//Logic so the bow doesn't look blurry on inspect
		if ( weapon.GetWeaponActivity() == ACT_VM_WEAPON_INSPECT )
		{
			DoF_LerpNearDepth( 0.5, 6.4, 0.3 )
		}
	#endif
}


void function OnWeaponCustomActivityEnd_weapon_bow( entity weapon)
{
	#if CLIENT
		if ( !file.inspectDOF )
			return

		if ( weapon.GetWeaponActivity() == ACT_VM_WEAPON_INSPECT )
		{
			DoF_LerpNearDepthToDefault( 0.3 )
		}
	#endif
}

void function ClearChargeAfterFrame( entity weapon )
{
	//we clear mods after a frame so that the mod still is on the weapon when the shot is fired, so viewkick and such is still scaled
	AssertIsNewThread()
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( BOW_DEACTIVATE_SIGNAL )

	OnThreadEnd(
		function() : ( weapon )
		{
			if ( IsValid( weapon ) )
				ClearChargeAndDmgLevelMods( weapon )
		}
	)

	WaitFrame()
}


bool function OnWeaponChargeBegin_weapon_bow( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) || !IsAlive( player ) )
		return false

	#if CLIENT
		weapon.Signal( HELPER_DOT_RUI_ABORT_SIGNAL )
		PlayChargeFX( player, weapon )
	#endif

	MarksmansTempo_AbortFadeoff( weapon, file.bowTempoSettings )
	return true
}


void function OnWeaponChargeEnd_weapon_bow( entity weapon )
{
	StopChargeFX( weapon )
}


bool function OnWeaponChargeLevelIncreased_weapon_bow( entity weapon )
{
	if ( weapon.GetWeaponChargeLevel() == weapon.GetWeaponChargeLevelMax() )
	{
		entity player = weapon.GetWeaponOwner()
		if ( !IsValid( player ) )
			return true

		#if CLIENT
			weapon.EmitWeaponSound_1p3p( file.chargeCompleteSound, "" )

			if ( IsValid( player ) && IsLocalClientPlayer( player ) )
			{
				Rumble_Play( "rumble_bow_max_charge", {} )
			}
		#endif

		MarksmansTempo_SetPerfectTempoMoment( weapon, file.bowTempoSettings, player, Time(), true )
	}

	//apply mods every charge up to show spread
	ApplyModsForChargeLevel( weapon, weapon.GetWeaponChargeLevel() )

	return true
}

// --------------------------------------------------------------------------------------
//
//	ARROW STICK
//
// --------------------------------------------------------------------------------------

void function OnProjectileCollision_weapon_bow( entity projectile, vector pos, vector normal, entity hitEnt, int hitBox, bool isCritical )
{
	#if SERVER
		if ( GetCurrentPlaylistVarBool( "arrows_stick_disable", false ) )
			return

		if ( projectile.HasWeaponMod( SHATTER_ROUNDS_HIPFIRE_MOD ) )
			return

		if ( !IsValid( hitEnt ) )
			return

		if ( !hitEnt.e.canStickArrows )
			return

		//float rand = RandomFloat( 1.0 )
		//if ( rand > file.arrowsStickChance )
		//	return

		if ( hitEnt.IsPlayer() || hitEnt.IsNPC() )
		{
			foreach ( entity arrow in hitEnt.e.arrowsInBody )
			{
				if ( !IsValid( arrow ) )
				{
					hitEnt.e.arrowsInBody.fastremovebyvalue( arrow )
				}
			}
			if ( hitEnt.e.arrowsInBody.len() >= file.arrowsStickMaxPlayer )
			{
				entity arrow = hitEnt.e.arrowsInBody.getrandom()
				hitEnt.e.arrowsInBody.fastremovebyvalue( arrow )
				arrow.Destroy()
			}

			vector position = pos + projectile.GetForwardVector() * file.arrowsStickIntoPlayerDist
			vector angles   = VectorToAngles( projectile.GetForwardVector() )
			entity moverEnt = CreateScriptMover( BOW_MOVER_SCRIPTNAME, position, angles, 0 )
			moverEnt.e.spawnTime = Time()
			MarkEntForCleanupOnRoundEnd( moverEnt )
			moverEnt.SetParentWithHitbox( hitEnt, hitBox, true )

			entity ent = CreatePropDynamic( SINGLE_ARROW_MODEL, position, angles, 0 )
			ent.kv.fadedist    = 3000
			ent.e.spawnTime    = Time()
			MarkEntForCleanupOnRoundEnd( ent )
			ent.SetParent( moverEnt, "", true )

			                               
				if ( projectile.HasWeaponMod( WEAPON_LOCKEDSET_MOD_CUPID ) )
				{
					ent.kv.rendercolor = VALENTINES_COLOR
				}
				else
         
			ent.kv.rendercolor = file.arrowTypeColors[ eArrowTypes.STANDARD ]

			if ( hitEnt.IsPlayer() )
				FiringRange_AddToRemoveOnCharacterChange( moverEnt, hitEnt )

			ent.RemoveFromAllRealms()
			if ( IsValid( projectile ) )
				ent.AddToOtherEntitysRealms( projectile )
			else
				ent.AddToOtherEntitysRealms( hitEnt )

			thread CleanupArrows( moverEnt, hitEnt, file.arrowsStickLifetimePlayer )

			hitEnt.e.arrowsInBody.append( moverEnt )
		}
		else if ( PositionIsInMapBounds( pos ) )
		{
			//we have a global ring buffer to limit the number of total arrows on the map
			if ( RingBufferEntity_IsFull( file.arrowsInWorld ) )
			{
				entity oldArrow = RingBufferEntity_Dequeue( file.arrowsInWorld )
				if ( IsValid( oldArrow ) )
					oldArrow.Destroy()
			}

			//and a ring buffer per zone to prevent too many arrows in one spot
			int zone                    = MapZones_GetZoneForOrigin( pos )
			RingBufferEntity zoneBuffer = file.arrowsInZones[zone]
			if ( RingBufferEntity_IsFull( zoneBuffer ) )
			{
				entity oldArrow = RingBufferEntity_Dequeue( zoneBuffer )
				if ( IsValid( oldArrow ) )
					oldArrow.Destroy()
			}


			entity ent

			if ( ArrowsCanBePickedUp() )
			{
				ent = CreateEntity( "prop_survival" )
				//ent.SetSurvivalPropFadeDist( 3000 )
				ent.SetValueForModelKey( SINGLE_ARROW_MODEL_PICKUP )

				ent.SetSurvivalInt( file.singleArrowLootData.index )

				ent.SetUsable()
				ent.SetUsableByGroup( "pilot" )
				ent.AddUsableValue( USABLE_USE_COLLISION_ORIGIN | USABLE_CUSTOM_HINTS | USABLE_HORIZONTAL_FOV | USABLE_PRIORITY_LOW )
				ent.EnableTouchAutoUse( AUTOPICKUP_DISTANCE_DEFAULT )

				ent.e.lootRef = ARROWS_AMMO

				ent.SetClipCount( 1 )
			}
			else
			{
				ent = CreateEntity( "prop_dynamic" )
				ent.SetValueForModelKey( SINGLE_ARROW_MODEL )
			}

			ent.kv.CollisionGroup = TRACE_COLLISION_GROUP_NONE
			ent.kv.fadedist       = 3000
			ent.kv.renderamt      = 255

			                               
				if ( projectile.HasWeaponMod( WEAPON_LOCKEDSET_MOD_CUPID ) )
				{
					ent.kv.rendercolor = VALENTINES_COLOR
				}
				else
         
			ent.kv.rendercolor    = "255 255 255"
			ent.kv.solid          = 0    // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
			SetForceDrawWhileParented( ent, true )

			DispatchSpawn( ent )
			MarkEntForCleanupOnRoundEnd( ent )

			ent.e.spawnTime = Time()
			SetItemSpawnSource( ent, eSpawnSource.PLAYER_DROP )

			//vector angles = VectorToAngles( projectile.GetForwardVector() )
			//angles = AnglesCompose( angles, <0, 90, 0> )
			//ent.SetAngles( angles )
			//ent.SetOrigin( pos )

			DeployableCollisionParams params
			params.pos        = pos
			params.normal     = projectile.GetForwardVector()
			params.hitEnt     = hitEnt
			params.hitBox     = 0    //prop survival's cant attach to hitboxes for networking optimization, so don't do it
			params.isCritical = isCritical

			vector angleOffset = <0, 0, 0>

			if ( ArrowsCanBePickedUp() )
				angleOffset = <0, 90, 0>

			if ( !PlantStickyEntity( ent, params, angleOffset, true ) )
			{
				ent.Destroy()
				return
			}

			ent.RemoveFromAllRealms()
			if ( IsValid( projectile ) )
				ent.AddToOtherEntitysRealms( projectile )
			else
				Warning( "Could not add arrow to realm because it hit world and projectile was null." )


			RingBufferEntity_Enqueue( file.arrowsInWorld, ent )
			RingBufferEntity_Enqueue( zoneBuffer, ent )

			thread CleanupArrows( ent, hitEnt, file.arrowsStickLifetimeWorld )
		}
	#endif

	return
}


bool function StuckArrow_ExtraCanUseFunction( entity player, entity arrow, int useFlags )
{
	if ( Bleedout_IsBleedingOut( player ) )
		return false

	if ( !ArrowsCanBePickedUp() )
		return false

	if ( IsBitFlagSet( useFlags, USE_FLAG_AUTO) )
	{
		//auto pickup only if you have a bow
		array<entity> weapons = player.GetMainWeapons()
		bool hasBow           = false
		foreach ( entity weapon in weapons )
		{
			if ( weapon.GetWeaponClassName() == "mp_weapon_bow" )
			{
				hasBow = true
				break
			}
		}

		if ( !hasBow )
			return false

		//and if it won't create a new ammo stack if you already have arrows
		int poolCount = player.AmmoPool_GetCount( eAmmoPoolType.arrows )
		if ( poolCount > 0 && (poolCount % file.ammoStackSize) == 0 )
			return false
	}
	return true
}

#if SERVER
void function CleanupArrows( entity ent, entity hitEnt, float time )
{
	OnThreadEnd(
		function() : ( ent, hitEnt )
		{
			if ( IsValid( ent ) )
			{
				ent.Destroy()
			}
		}
	)

	if ( IsValid( hitEnt ) )
	{
		if ( (hitEnt.IsPlayer() || hitEnt.IsNPC()) && !IsAlive( hitEnt ) )
			return

		hitEnt.EndSignal( "OnDestroy" )
		hitEnt.EndSignal( "OnDeath" )
		hitEnt.EndSignal( ARROWS_UNSTICK_SIGNAL )
	}
	else
	{
		return
	}

	if ( IsValid( ent ) )
		ent.EndSignal( "OnDestroy" )
	else
		return

	if ( time >= 0 )
		wait time
	else
		WaitForever()
}
#endif

// --------------------------------------------------------------------------------------
//
//	ARROW TIPS
//
// --------------------------------------------------------------------------------------
#if CLIENT
void function WeaponBow_UpdateArrowColor( entity weapon, int shatterRoundsType )
{
	                               
		if ( weapon.HasMod( WEAPON_LOCKEDSET_MOD_CUPID ) )
		{
			weapon.kv.rendercolor = VALENTINES_COLOR
			return
		}
       

	if ( shatterRoundsType == eShatterRoundsTypes.STANDARD )
		weapon.kv.rendercolor = VectorToColorString( file.arrowTypeColors[ eArrowTypes.STANDARD ], 255 )
	else if ( shatterRoundsType == eShatterRoundsTypes.SHATTER_TRI )
		weapon.kv.rendercolor = VectorToColorString( file.arrowTypeColors[ eArrowTypes.SHATTER ], 255 )
}
#endif

// --------------------------------------------------------------------------------------
//
//	CHARGE
//
// --------------------------------------------------------------------------------------
void function ApplyModsForChargeLevel( entity weapon, int level )
{
	#if CLIENT
		if ( !InPrediction() )
			return
	#endif

	ClearChargeAndDmgLevelMods( weapon )

	if ( level - 1 > 0 )
		weapon.AddMod( CHARGE_MODS_BASE_STR + (level - 1) )

	int dmgModLevel
	string baseDmgModStr
	if ( weapon.HasMod( SHATTER_ROUNDS_HIPFIRE_MOD ) )
	{
		baseDmgModStr = SHATTER_ARROWS_DMG_MODS_BASE_STR
		dmgModLevel   = GetBestAvailableModLevel( SHATTER_ARROWS_AVAILABLE_DMG_LEVELS, level - 1 )
	}
	else
	{
		baseDmgModStr = STANDARD_CHARGE_DMG_MODS_BASE_STR
		dmgModLevel   = GetBestAvailableModLevel( STANDARD_ARROWS_AVAILABLE_DMG_LEVELS, level - 1 )
		//had to remove std_charge_dmg_lv0 to get more mod slots. It doesn't do anything anyway, we just use base values at that point
		if ( dmgModLevel == 0 )
			return
	}
	weapon.AddMod( baseDmgModStr + dmgModLevel )
}


void function ClearChargeAndDmgLevelMods( entity weapon )
{
	#if CLIENT
		if ( !InPrediction() )
			return
	#endif

	for ( int i = 0; i < CHARGE_MODS_MAX_LEVEL + 1; i++ )
	{
		weapon.RemoveMod( CHARGE_MODS_BASE_STR + i )

		weapon.RemoveMod( STANDARD_CHARGE_DMG_MODS_BASE_STR + i )
		weapon.RemoveMod( SHATTER_ARROWS_DMG_MODS_BASE_STR + i )
	}
}


int function GetBestAvailableModLevel( array<int> availableLevels, int desiredLevel )
{
	if ( availableLevels[0] >= desiredLevel )
		return availableLevels[0]

	for ( int i = 0; i < availableLevels.len(); i++ )
	{
		if ( availableLevels[i] > desiredLevel )
			return availableLevels[maxint( i - 1, 0 )]
	}

	return availableLevels[availableLevels.len() - 1]
}

#if CLIENT
void function AttemptCancelCharge( entity player )
{
	if ( !IsValid( player ) )
		return

	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( !IsValid( weapon ) )
		return

	if ( weapon.GetWeaponClassName() != "mp_weapon_bow" )
		return

	if ( !weapon.IsWeaponCharging() )
		return

	Remote_ServerCallFunction( "Remote_CancelCharge" )
}
#endif

#if SERVER
void function Remote_CancelCharge( entity player )
{
	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( !IsValid( weapon ) )
		return

	if ( weapon.GetWeaponClassName() != "mp_weapon_bow" )
		return

	weapon.ForceChargeEndNoAttack()
}
#endif


// --------------------------------------------------------------------------------------
//
//	FX
//
// --------------------------------------------------------------------------------------
#if CLIENT
void function PlayChargeFX( entity player, entity weapon )
{
	if ( !IsValid( weapon ) || !IsValid( player ) || !IsAlive( player ) )
		return

	entity vm = weapon.GetWeaponViewmodel()
	if ( !IsValid( vm ) )
		return

	string opticAttachment = GetInstalledWeaponAttachmentForPoint( weapon, "sight" )
	if ( opticAttachment == "" )
		opticAttachment = "ironsights"
	array<string> attachPoints = fxLightPointsForOptic[opticAttachment]
	for ( int i = 0; i < FX_BOW_LIGHT_COUNT; i++ )
	{
		asset fx1p = file.fxLightAssets1p[opticAttachment][i]

		//printt( "Playing " + fx1p + " from setting " + (FX_BOW_LIGHT_PREFIX + opticAttachment + "_" + i + "_1p") + " at pt " + attachPoints[i] )

		if ( fx1p == "" )
			continue

		int handle = weapon.PlayWeaponEffectNoCullReturnViewEffectHandle( fx1p, $"", attachPoints[i], true, FX_PATTACH_WEAPON_CHARGE_FRACTION_CURVED )


	                               
		if ( weapon.HasMod( WEAPON_LOCKEDSET_MOD_CUPID ) )
		{
			EffectSetControlPointVector( handle, 2, VALENTINES_COLOR_VEC )
		}
		else
       
		EffectSetControlPointVector( handle, 2, file.arrowTypeColors[ weapon.GetScriptInt0() ] )
	}
}
#endif

void function StopChargeFX( entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	entity vm = weapon.GetWeaponViewmodel()
	if ( !IsValid( vm ) )
		return

	string opticAttachment = GetInstalledWeaponAttachmentForPoint( weapon, "sight" )
	if ( opticAttachment == "" )
		opticAttachment = "ironsights"
	string settingStr
	for ( int i = 0; i < FX_BOW_LIGHT_COUNT; i++ )
	{
		settingStr = FX_BOW_LIGHT_PREFIX + opticAttachment + "_" + i
		asset fx1p = weapon.GetWeaponInfoFileKeyFieldAsset( settingStr + "_1p" )

		if ( fx1p == "" )
			continue

		weapon.StopWeaponEffect( fx1p, $"" )
	}
}


#if SERVER
void function OnWeaponModChanged_WeaponBow( entity weapon, string mod, bool modAdded )
{
	if ( mod ==  SHATTER_ROUNDS_ALTFIRE_MOD )
	{
		if ( !IsValid( weapon ) )
			return

		if ( !weapon.IsWeaponX() )
			return

		entity player = weapon.GetWeaponOwner()
		if ( !IsValid( player ) )
			return

		weapon.ForceChargeEndNoAttack()

		if ( modAdded )
			thread ShatterRounds_ADSThink ( player, weapon )
		else
			weapon.RemoveMod( SHATTER_ROUNDS_HIPFIRE_MOD )
	}
}
#endif