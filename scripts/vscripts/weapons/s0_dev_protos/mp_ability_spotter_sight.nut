
global function MpAbilitySpotterSight_Init

global function OnWeaponChargeBegin_ability_spotter_sight
global function OnWeaponChargeEnd_ability_spotter_sight
global function OnWeaponPrimaryAttack_ability_spotter_sight

struct
{
	#if CLIENT
	int colorCorrection
	var overlayRui
	#endif //CLIENT
} file

void function MpAbilitySpotterSight_Init()
{
	#if CLIENT
		RegisterSignal( "SpotterSightStop" )
		StatusEffect_RegisterEnabledCallback( eStatusEffect.spotter_sight, SpotterSight_StartVisualEffect )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.spotter_sight, SpotterSight_StopVisualEffect )
		file.colorCorrection = ColorCorrection_Register( "materials/correction/area_sonar_scan.raw_hdr" )
	#endif
}

bool function OnWeaponChargeBegin_ability_spotter_sight( entity weapon )
{
	weapon.SetForcedADS()
	#if SERVER
		entity owner = weapon.GetWeaponOwner()
		StatusEffect_AddEndless( owner, eStatusEffect.spotter_sight, 1.0 )
		if ( owner.IsPlayer() )
			PlayerUsedOffhand( owner, weapon )
	#endif
	return true
}

void function OnWeaponChargeEnd_ability_spotter_sight( entity weapon )
{
	weapon.ClearForcedADS()
	#if SERVER
		entity owner = weapon.GetWeaponOwner()
		StatusEffect_StopAllOfType( owner, eStatusEffect.spotter_sight )
	#endif
}

var function OnWeaponPrimaryAttack_ability_spotter_sight( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return 0
}

#if CLIENT
void function SpotterSight_StartVisualEffect( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	int team = ent.GetTeam()
	HighlightContext highlight = GetHighlight( "caustic_gas_threat" )
	HighlightContext_SetAfterPostProcess( highlight, true )
	HighlightContext_SetFarFadeDistance( highlight, 999999.0 )
	HighlightContext_SetNearFadeDistance( highlight, 0.0 )
	HighlightContext_SetDrawFunc( highlight, eHighlightDrawFunc.ALWAYS )
	HighlightContext_SetFill( highlight, HIGHLIGHT_FILL_INTERACT_BUTTON )

	foreach ( player in GetPlayerArray() )
	{
		ManageHighlightEntity( player )
	}

	ColorCorrection_SetExclusive( file.colorCorrection, true )
	ColorCorrection_SetWeight( file.colorCorrection, 1.0 )

	file.overlayRui = CreateFullscreenRui( $"ui/spotter_sight.rpak" )

	thread ProphetSpotterRuiManagement( ent )
}

void function SpotterSight_StopVisualEffect( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged && GetLocalViewPlayer() == GetLocalClientPlayer() )
		return

	if ( ent != GetLocalViewPlayer() )
		return

	foreach ( player in GetPlayerArray() )
	{
		ManageHighlightEntity( player )
	}

	ent.Signal( "SpotterSightStop" )

	RuiDestroyIfAlive( file.overlayRui )

	ColorCorrection_SetWeight( file.colorCorrection, 0.0 )
	ColorCorrection_SetExclusive( file.colorCorrection, false )
}

//Hacky Script Management - Going to create 6 ruis ( up to two squads ) and move them to players Seer can see.
void function ProphetSpotterRuiManagement( entity ent )
{
	ent.EndSignal( "OnDestroy" )
	ent.EndSignal( "SpotterSightStop" )

	array<var> ruis
	for( int i = 0; i < 6; i++ )
	{
		var rui = CreateCockpitRui( $"ui/prophetpassive.rpak", RuiCalculateDistanceSortKey( ent.EyePosition(), <0,0,0> ) )
		ruis.append( rui )
	}

	OnThreadEnd(
	function() : ( ruis )
		{
			foreach ( rui in ruis )
			{
				RuiDestroy( rui )
			}
		}
	)

	while( true )
	{
		array<entity> enemiesInSight
		foreach ( player in GetPlayerArray() )
		{
			if ( ent.GetTeam() == player.GetTeam() )
				continue

			if ( !IsAlive( player ) )
				continue

			if ( PlayerCanSee( ent, player, true, ent.GetFOV() ) )
				enemiesInSight.append( player )
		}

		for( int i = 0; i < 6; i++ )
		{
			if ( i < enemiesInSight.len() )
			{
				entity target = enemiesInSight[i]
				RuiTrackFloat3( ruis[i], "pos", target, RUI_TRACK_POINT_FOLLOW, target.LookupAttachment( "ORIGIN" ) )
				RuiSetBool( ruis[i], "activeTarget", true )
				RuiSetFloat( ruis[i], "healthFrac", GetHealthFrac( target ) )
				entity equipmentEntity = target.IsPlayerDecoy() ? target.GetBossPlayer() : target
				if ( !IsValid( equipmentEntity ) )
					continue
				RuiSetInt( ruis[i], "armorTier", EquipmentSlot_GetEquipmentTier( equipmentEntity, "armor" ) )
				RuiSetInt( ruis[i], "helmetTier", EquipmentSlot_GetEquipmentTier( equipmentEntity, "helmet" ) )
				RuiSetInt( ruis[i], "backpackTier", EquipmentSlot_GetEquipmentTier( equipmentEntity, "backpack" ) )
				RuiSetInt( ruis[i], "incapshieldTier", EquipmentSlot_GetEquipmentTier( equipmentEntity, "incapshield" ) )

				string bonusString = target.GetPlayerName()
				if ( GradeFlagsHas( target, eTargetGrade.CHAMPION ) || GradeFlagsHas( target, eTargetGrade.CHAMP_KILLLEADER ) )
					bonusString = "#SURVIVAL_CHAMPION"
				else if ( GradeFlagsHas( target, eTargetGrade.KILLLEADER ) )
					bonusString = "#SURVIVAL_KILLLEADER"

				if ( target.IsPlayerDecoy() )
					bonusString = "#WPN_HOLOPILOT_DECOY"

				RuiSetString( ruis[i], "bonusString", Localize( bonusString ) )
			}
			else
			{
				RuiSetBool( ruis[i], "activeTarget", false )
			}
		}

		WaitFrame()
	}
}
#endif