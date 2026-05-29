global function MpWeaponRiotDrill_Init

global function OnWeaponActivate_riot_drill
global function OnWeaponDeactivate_riot_drill
//global function OnWeaponTossCancel_weapon_riot_drill
global function OnWeaponTossCancel_weapon_riot_drill
global function OnWeaponTossReleaseAnimEvent_weapon_riot_drill
global function OnProjectileCollision_weapon_riot_drill

global function CodeCallback_BreachTraceEarlyExitOnEnt
global function CodeCallback_BreachTraceIsValidPos

#if SERVER
global function ClientCallback_DrillError_On
global function ClientCallback_DrillError_Off
#endif

#if CLIENT
global function ServerCallback_CancelPlacement
global function OnClientAnimEvent_weapon_riot_drill
#endif

global const string RIOT_DRILL_SCRIPT_NAME = "riot_drill_spike"
global const string RIOT_DRILL_DANGERZONE_TARGETNAME = "riot_drill_dangerzone_threat"
const string RIOT_DRILL_MOVER_SCRIPTNAME = "riot_drill_mover"

// DEFAULT PLACEMENT VARS
const float WALL_THICKNESS_MAX 			= 512.0			// maximum geo thickness
const float WALL_THICKNESS_MIN 			= 0.18
const float MAX_RANGE 					= 1750.0		// range until projectile falloff kicks in signficantly (based on projectile_ values in the WeaponData) and we can no longer accurately predict the drill data

// DEFAULT EFFECT VARS
const float RIOT_DRILL_FIRE_DELAY 	= 1.0			// delay between when the drill is planted and when the damage zone is created
const float RIOT_DRILL_DURATION 	= 8.0			// duration of the damage zone
const float RIOT_DRILL_BLAST_LENGTH = 224.0			// length of the damage zone
const float RIOT_DRILL_BLAST_RADIUS = 130.0			// radius of the damage zone
const int	RIOT_DRILL_DAMAGE 		= 4				// damage per tick
const int 	RIOT_DRILL_IMPACT_DAMAGE = 5			// damage when the drill projectile hits a player target
const int	RIOT_DRILL_OBJECT_DAMAGE = 1				// damage dealt to "nonplayer" targets
const float RIOT_DRILL_DAMAGE_TICK 	= 0.2			// tick rate of damage

const float RIOT_DRILL_DURATION_UPGRADE					= 6.0 // upgrade_maggie_extra_drill_charge (reduce duration with extra charge)
const float RIOT_DRILL_BLAST_LENGTH_UPGRADE_MULTIPLIER 	= 1.5 // upgrade_maggie_drill_depth_and_range
const float RIOT_DRILL_BLAST_RADIUS_UPGRADE_MULTIPLIER 	= 1.5 // upgrade_maggie_drill_depth_and_range


// MODELS
const asset RIOT_DRILL_SPIKE 					= $"mdl/props/madmaggie_tactical_drill_bit/madmaggie_tactical_drill_bit.rmdl"
const asset RIOT_DRILL_DRILL		 			= $"mdl/props/madmaggie_tactical_drill_bit/madmaggie_tactical_drill_bit.rmdl"
const asset RIOT_DRILL_DRILL_FIZZLE		 		= $"mdl/robots/drone_frag/drone_frag.rmdl"

/// FX/PARTICLES
const asset RIOT_DRILL_EMPTY_MODEL				= $"mdl/dev/empty_model.rmdl"
const asset RIOT_DRILL_PLACEMENT_ENTER 			= $"_none_FX_test"
const asset RIOT_DRILL_PLACEMENT_EXIT 			= $"_none_FX_test"
const asset RIOT_DRILL_BLAST_BEAM_FX 			= $"P_mm_breach_beam"
const asset RIOT_DRILL_BLAST_BEAM_WARN_FX 		= $"P_mm_breach_beam_warn"
const asset RIOT_DRILL_AOE_WARNING_01_FX 		= $"P_mm_breach_exit"

    const asset RIOT_DRILL_BLAST_BEAM_WARN_FX_UPGRADE 		= $"P_mm_breach_beam_warn_big"
    const asset RIOT_DRILL_AOE_WARNING_01_FX_UPGRADE 		= $"P_mm_breach_exit_big"

const asset RIOT_DRILL_FRONT_FX 				= $"P_mm_breach_enter"
const asset RIOT_DRILL_SPRAY_TEST_CONE	 		= $"_none_FX_test"
const asset RIOT_DRILL_SPRAY_TEST_COLUMN 		= $"_none_FX_test"
const asset RIOT_DRILL_DECAL					= $"P_mm_breach_decal"
const asset RIOT_DRILL_DAMAGE_FX_1P				= $"fissure_breach_CH_hex_flash"
const asset RIOT_DRILL_FIZZLE_EXPLODE_FX		= $"fissure_breach_fizzle_explosion"
const asset RIOT_DRILL_FIZZLE_SPARKS_FX			= $"fissure_breach_fizzle_spray"
const asset RIOT_DRILL_ENTER_FX_DEFAULT			= $"P_mm_breach_imp_enter_default"
const vector RIOT_DRILL_PLACEMENT_VALID_COLOR 	= <128, 188, 255>
const vector RIOT_DRILL_PLACEMENT_CAUTION_COLOR = <255, 200, 40>
const vector RIOT_DRILL_PLACEMENT_ERROR_COLOR 	= <255, 40, 40>

/// SFX/SOUND
const string RIOT_DRILL_DAMAGE_SOUND_1P 		= "flesh_thermiteburn_3p_vs_1p"					// on local player
const string RIOT_DRILL_DAMAGE_SOUND_3P 		= "flesh_thermiteburn_3p_vs_3p"				// on local player - should be?
const string RIOT_DRILL_EXIT_DRILLING 			= "Maggie_Tac_Drill_Exit_Drilling"
const string RIOT_DRILL_ENTRANCE_DRILLING 		= "Maggie_Tac_Drill_Entrance_Drilling"  //firebomb_damaging_loop_3p

const string RIOT_DRILL_EXIT_DRILLING_UPGRADE	= "Maggie_Tac_Drill_Exit_Drilling_Short"


const bool DEBUG_INFO = false

enum eBreachPlacementResult
{
	SUCCESS = BREACH_TRACE_RESULT_SUCCESS,
	FAILED_WALL_TOO_THIN = BREACH_TRACE_RESULT_WALL_TOO_THIN,
	FAILED_WALL_TOO_THICK = BREACH_TRACE_RESULT_WALL_TOO_THICK,
	FAILED_OUT_OF_RANGE = BREACH_TRACE_RESULT_COUNT,
	FAILED_SAFETY_CATCH = BREACH_TRACE_RESULT_INVALID_END_POINT,
	FAILED_GENERIC = BREACH_TRACE_RESULT_FAILURE,
}

global struct RiotDrillPlacementInfo
{
	vector startOrigin
	vector startAngles
	vector startSurfaceNormal
	vector endSurfaceNormal
	int    placementResult
	bool   hide
	entity hitEnt

	vector endOrigin
	vector endAngles
}

struct RiotDrillSystem
{
	entity riotDrillStart
	entity riotDrillEnd
	entity riotDrillDrillMover
	entity riotDrillDrillModel
	entity riotDrillStuckEntity
	entity damageTrigger
	entity riotDrillSoundDummy

	vector dangerZoneOrigin
	vector dangerZoneAngle
	vector breachAngle

	RiotDrillPlacementInfo& placementInfo
}

struct
{
	bool balance_riotDrillAllowThick
	bool balance_riotDrillAllowOutRange
	bool balance_riotDrillProjCollision
	float balance_riotDrillDelay
	float balance_riotDrillDuration
	int balance_riotDrillDamage
	int balance_riotDrillImpactDamage
	int balance_riotDrillObjectDamage
	float balance_riotDrillMaxThickness
	float balance_riotDrillRadius
	float balance_riotDrillLength
	float balance_riotDrillRange
	bool balance_riotDrillAfterDeath
	bool balance_riotDrillPlayerCollide

	array<string> shieldScriptNames
	array<string> bounceOffSpecialCaseNames

	#if CLIENT
		bool breachChargeDeployed = false
		var depthRui
	#endif

	table riotDrillDamageParams 		= { damageSourceId = eDamageSourceId.mp_weapon_concussive_breach, damageType = DMG_BURN }
	table riotDrillImpactDamageParams 	= { damageSourceId = eDamageSourceId.mp_weapon_concussive_breach }

	// FX/Sound controls
	bool fxOption_hideModels
	float fxOption_impactTableFXEnterRefire
	float fxOption_impactTableFXExitRefire
}
file

// BreachTrace implementation - traces through geometry to find an exit point
// This simulates the native engine function for breaching through walls
BreachTraceResults function BreachTrace( vector startPos, vector direction, vector hullMin, vector hullMax, float maxDist )
{
	BreachTraceResults results
	results.result = BREACH_TRACE_RESULT_FAILURE
	results.endPos = startPos
	results.surfaceNormal = -direction

	const float STEP_SIZE = 4.0
	const float MIN_THICKNESS = WALL_THICKNESS_MIN
	const float MAX_THICKNESS = 512.0

	vector currentPos = startPos
	vector endPos = startPos + (direction * maxDist)
	float distanceTraveled = 0.0
	bool foundStart = false
	vector startSurfaceNormal

	// First, find the entry point
	TraceResults entryTrace = TraceHull( startPos, endPos, hullMin, hullMax, [], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
	if ( entryTrace.startSolid || entryTrace.allSolid )
	{
		// Starting inside solid - invalid
		results.result = BREACH_TRACE_RESULT_INVALID_END_POINT
		return results
	}

	// Check if we hit anything
	if ( entryTrace.fraction >= 1.0 )
	{
		// Didn't hit anything - too thin
		results.result = BREACH_TRACE_RESULT_WALL_TOO_THIN
		return results
	}

	// We hit something - this is our entry point
	foundStart = true
	startSurfaceNormal = entryTrace.surfaceNormal
	currentPos = entryTrace.endPos
	distanceTraveled = Distance( startPos, currentPos )

	// Now trace forward from slightly past the entry point to find the exit
	vector searchStart = currentPos + (direction * 2.0)
	vector searchEnd = currentPos + (direction * (maxDist + 10.0))

	// Use a smaller hull for the internal trace to ensure we can pass through
	vector internalHullMin = hullMin * 0.5
	vector internalHullMax = hullMax * 0.5

	TraceResults exitTrace = TraceHull( searchStart, searchEnd, internalHullMin, internalHullMax, [entryTrace.hitEnt], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

	if ( exitTrace.fraction >= 1.0 )
	{
		// No exit found - wall too thick
		results.result = BREACH_TRACE_RESULT_WALL_TOO_THICK
		results.endPos = currentPos
		results.surfaceNormal = startSurfaceNormal
		return results
	}

	// Found exit point
	float wallThickness = Distance( currentPos, exitTrace.endPos )

	if ( wallThickness < MIN_THICKNESS )
	{
		// Wall too thin
		results.result = BREACH_TRACE_RESULT_WALL_TOO_THIN
		results.endPos = exitTrace.endPos
		results.surfaceNormal = exitTrace.surfaceNormal
		return results
	}

	if ( wallThickness > MAX_THICKNESS )
	{
		// Wall too thick
		results.result = BREACH_TRACE_RESULT_WALL_TOO_THICK
		results.endPos = currentPos
		results.surfaceNormal = startSurfaceNormal
		return results
	}

	// Check if exit position is valid
	if ( !CodeCallback_BreachTraceIsValidPos( exitTrace.endPos ) )
	{
		results.result = BREACH_TRACE_RESULT_INVALID_END_POINT
		results.endPos = currentPos
		results.surfaceNormal = startSurfaceNormal
		return results
	}

	// Success - found valid exit point
	results.result = BREACH_TRACE_RESULT_SUCCESS
	results.endPos = exitTrace.endPos
	results.surfaceNormal = exitTrace.surfaceNormal
	return results
}

void function MpWeaponRiotDrill_Init()
{
	/*PrecacheParticleSystem( RIOT_DRILL_FRONT_FX )
	PrecacheParticleSystem( RIOT_DRILL_AOE_WARNING_01_FX )

	    PrecacheParticleSystem( RIOT_DRILL_BLAST_BEAM_WARN_FX_UPGRADE )
	    PrecacheParticleSystem( RIOT_DRILL_AOE_WARNING_01_FX_UPGRADE )

	PrecacheParticleSystem( RIOT_DRILL_SPRAY_TEST_CONE )
	PrecacheParticleSystem( RIOT_DRILL_SPRAY_TEST_COLUMN )
	PrecacheParticleSystem( RIOT_DRILL_BLAST_BEAM_FX )
	PrecacheParticleSystem( RIOT_DRILL_BLAST_BEAM_WARN_FX )
	PrecacheParticleSystem( RIOT_DRILL_PLACEMENT_ENTER )
	PrecacheParticleSystem( RIOT_DRILL_PLACEMENT_EXIT )
	PrecacheParticleSystem( RIOT_DRILL_DAMAGE_FX_1P )
	PrecacheParticleSystem( RIOT_DRILL_DECAL )
	PrecacheParticleSystem( RIOT_DRILL_FIZZLE_EXPLODE_FX )
	PrecacheParticleSystem( RIOT_DRILL_FIZZLE_SPARKS_FX )
	PrecacheParticleSystem( RIOT_DRILL_ENTER_FX_DEFAULT )

	PrecacheModel( RIOT_DRILL_SPIKE )
	PrecacheModel( RIOT_DRILL_DRILL )
	PrecacheModel( RIOT_DRILL_DRILL_FIZZLE )
	PrecacheModel( RIOT_DRILL_EMPTY_MODEL )*/

	RegisterSignal( "DeployableBreachChargePlacement_End" )
	RegisterSignal( "RiotDrill_TempAnimWindDown" )
	RegisterSignal( "RiotDrill_StuckEntDissolving" )

	file.balance_riotDrillAfterDeath	= GetCurrentPlaylistVarBool( "breaching_spike_after_death_override", true )										// CLEANUP allows the damage zone to continue while Maggie is dead
	file.balance_riotDrillAllowThick 	= GetCurrentPlaylistVarBool( "breaching_spike_allow_thick_override", true )										// CLEANUP allows the damage zone to be created even if the wall is deemed too thick
	file.balance_riotDrillAllowOutRange = GetCurrentPlaylistVarBool( "breaching_spike_allow_out_range_override", true )									// CLEANUP allows the weapon to be fired even if the expected target is out of range
	file.balance_riotDrillProjCollision = GetCurrentPlaylistVarBool( "breaching_spike_allow_projectile_collision_override", true )						// moves the damage zone creation to when the projectile hits a target, instead of instantly when fired
	file.balance_riotDrillDelay 		= max( GetCurrentPlaylistVarFloat( "breaching_spike_delay_override", RIOT_DRILL_FIRE_DELAY ), 0.25 )		// delay before the damage zone is created
	file.balance_riotDrillDuration 		= max( GetCurrentPlaylistVarFloat( "riot_drill_duration_override", RIOT_DRILL_DURATION ), 0.0 )			// duration of the damage zone
	file.balance_riotDrillDamage 		= maxint( GetCurrentPlaylistVarInt( "breaching_spike_damage_override", RIOT_DRILL_DAMAGE ), 0 )				// damage per tick in the damage zone
	file.balance_riotDrillImpactDamage	= maxint( GetCurrentPlaylistVarInt( "breaching_spike_impact_damage_override", RIOT_DRILL_IMPACT_DAMAGE ), 0 )		// damage on projectile impact with player target
	file.balance_riotDrillObjectDamage 	= maxint( GetCurrentPlaylistVarInt( "breaching_spike_stuck_damage_override", RIOT_DRILL_OBJECT_DAMAGE ), 0 )		// damage per tick to stuck targets
	file.balance_riotDrillMaxThickness 	= max( GetCurrentPlaylistVarFloat( "breaching_spike_max_thickness_override", WALL_THICKNESS_MAX ), 400.0 )		// max distance the drill will travel through geo before being considered too thick
	file.balance_riotDrillRadius 		= max( GetCurrentPlaylistVarFloat( "breaching_spike_radius_override", RIOT_DRILL_BLAST_RADIUS ), 64.0 )		// radius of the damage zone
	file.balance_riotDrillLength 		= max( GetCurrentPlaylistVarFloat( "breaching_spike_length_override", RIOT_DRILL_BLAST_LENGTH ), 64.0 )		// length of the damage zone
	file.balance_riotDrillRange 		= GetCurrentPlaylistVarFloat( "breaching_spike_range_override", MAX_RANGE )										// range before the initial shot is considered out of range
	file.balance_riotDrillPlayerCollide = GetCurrentPlaylistVarBool( "breaching_spike_allow_player_collision_override", true )							// whether or not the riot drill projectile collides with players

	// FX/Sound controls for production
	file.fxOption_hideModels				= GetCurrentPlaylistVarBool( "breaching_spike_hide_models", true )
	file.fxOption_impactTableFXEnterRefire	= GetCurrentPlaylistVarFloat( "breaching_spike_impact_fx_enter_refire", 0.2 )
	file.fxOption_impactTableFXExitRefire	= GetCurrentPlaylistVarFloat( "breaching_spike_impact_fx_exit_refire", 0.2 )

	//file.shieldScriptNames.append( MOBILE_SHIELD_SCRIPTNAME )
	file.shieldScriptNames.append( BUBBLE_SHIELD_SCRIPTNAME )
	file.shieldScriptNames.append( AMPED_WALL_SCRIPT_NAME )
	//file.shieldScriptNames.append( ECHO_LOCATOR_SCRIPT_NAME )

	file.bounceOffSpecialCaseNames.append( "pathfinder_tt_ring_shield" )
	file.bounceOffSpecialCaseNames.append( DEATHBOX_FLYER_SCRIPT_NAME )

	#if SERVER
		PrecacheImpactEffectTable( "mm_breach_start" )
		PrecacheImpactEffectTable( "mm_breach_enter" )
		PrecacheImpactEffectTable( "mm_breach_exit" )

		//
		//investigation into http://jiratf.respawn.net:8080/browse/R5DEV-325796
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_concussive_breach, RiotDrill_OnDamage )
	#endif

	#if CLIENT
		AddTargetNameCreateCallback( RIOT_DRILL_DANGERZONE_TARGETNAME, RiotDrill_AddThreatIndicator )
	#endif //CLIENT

	//Remote_RegisterServerFunction( "ClientCallback_DrillError_On" )
	//Remote_RegisterServerFunction( "ClientCallback_DrillError_Off" )

	Remote_RegisterClientFunction( "ServerCallback_CancelPlacement", "entity" )
}

void function RestoreRiotDrillAmmo( entity owner )
{
	if ( IsAlive( owner ) )
	{
		entity weapon = owner.GetOffhandWeapon( OFFHAND_SPECIAL )
		if ( IsValid( weapon ) && weapon.GetWeaponClassName() == "mp_weapon_riot_drill" )
			Weapon_AddSingleCharge( weapon )
	}
}


float function RiotDrill_GetReducedDuration()
{
	return GetCurrentPlaylistVarFloat( "riot_drill_reduced_duration", RIOT_DRILL_DURATION_UPGRADE )
}

float function RiotDrill_GetUpgradedRadiusMultiplier()
{
	return GetCurrentPlaylistVarFloat( "riot_drill_upgraded_radius", RIOT_DRILL_BLAST_RADIUS_UPGRADE_MULTIPLIER )
}

float function RiotDrill_GetUpgradedLengthMultiplier()
{
	return GetCurrentPlaylistVarFloat( "riot_drill_upgraded_length", RIOT_DRILL_BLAST_LENGTH_UPGRADE_MULTIPLIER )
}


float function RiotDrill_GetDuration( entity player )
{
	float result = file.balance_riotDrillDuration

		if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_ONE ) ) // upgrade_maggie_extra_drill_charge
			result = RiotDrill_GetReducedDuration()

	return result
}

float function RiotDrill_GetRadius( entity player )
{
	float result = file.balance_riotDrillRadius

	if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_TWO ) ) // upgrade_maggie_drill_depth_and_range
		result *= RiotDrill_GetUpgradedRadiusMultiplier()

	return result
}

float function RiotDrill_GetLength( entity player )
{
	float result = file.balance_riotDrillLength

		if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_TWO ) ) // upgrade_maggie_drill_depth_and_range
			result *= RiotDrill_GetUpgradedLengthMultiplier()

	return result
}

#if SERVER

asset function RiotDrill_GetAOEWarningFX( entity player )
{
	asset result = RIOT_DRILL_AOE_WARNING_01_FX

		if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_TWO ) ) // upgrade_maggie_drill_depth_and_range
			result = RIOT_DRILL_AOE_WARNING_01_FX_UPGRADE

	return result
}

asset function RiotDrill_GetBlastBeamWarnFX( entity player )
{
	asset result = RIOT_DRILL_BLAST_BEAM_WARN_FX

		if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_TWO ) ) // upgrade_maggie_drill_depth_and_range
			result = RIOT_DRILL_BLAST_BEAM_WARN_FX_UPGRADE

	return result
}

string function RiotDrill_GetExitSoundFX( entity player )
{
	string result = RIOT_DRILL_EXIT_DRILLING

		if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_ONE ) ) // upgrade_maggie_extra_drill_charge
			result = RIOT_DRILL_EXIT_DRILLING_UPGRADE

	return result
}

/////////////////////////////////////
////// CORE BREACH FUNCTIONS ////////
/////////////////////////////////////

void function RiotDrill_CreateBreachingCharge_System( RiotDrillPlacementInfo placementInfo, entity owner, entity hitEnt )
{
	if( placementInfo.placementResult != eBreachPlacementResult.SUCCESS || !IsValid( hitEnt ) )
	{
		RestoreRiotDrillAmmo( owner )
		return
	}

	const float BREACH_SPIKE_OFFSET_TO_WALL = 0.0
	const float BREACH_SPIKE_SOUND_OFFSET = 10.0
	RiotDrillSystem fbs
	array <entity> riotDrillElements
	vector spikeStartAngles = AnglesCompose( placementInfo.startAngles, <90,0,0> )
	vector spikeEndAngles = AnglesCompose( placementInfo.startAngles, <-90,0,0> )

	fbs.dangerZoneAngle = spikeStartAngles
	fbs.placementInfo = placementInfo
	fbs.breachAngle = placementInfo.startAngles

	// Start Model
	fbs.riotDrillStart = CreatePropScript( RIOT_DRILL_DRILL, placementInfo.startOrigin + (BREACH_SPIKE_OFFSET_TO_WALL * AnglesToUp( spikeEndAngles )), spikeEndAngles, SOLID_CYLINDER )
	fbs.riotDrillStart.SetScriptName( RIOT_DRILL_SCRIPT_NAME )
	fbs.riotDrillStart.SetModelScale( 3.0 )
	riotDrillElements.append( fbs.riotDrillStart )

	//Drill Model and Mover (clean up when real projectile/animation is set up?)
	//Not sure how to set up a mover parented to an entity such that the drill can move through a moving Ent, hacking around it for now
	fbs.riotDrillDrillMover = CreateScriptMover_NEW( RIOT_DRILL_MOVER_SCRIPTNAME, placementInfo.startOrigin, spikeEndAngles )
	if ( hitEnt.GetScriptName() == WRECKING_BALL_BALL_SCRIPT_NAME )
	{
		fbs.riotDrillDrillModel = CreatePropScript( RIOT_DRILL_DRILL, fbs.placementInfo.endOrigin + (-30.0 * AnglesToUp( spikeEndAngles )), spikeEndAngles )
		fbs.riotDrillDrillMover.SetParent( fbs.riotDrillStart )
	}
	else
	{
		fbs.riotDrillDrillModel = CreatePropScript( RIOT_DRILL_DRILL, placementInfo.startOrigin, spikeEndAngles )
	}
	fbs.riotDrillDrillModel.SetParent( fbs.riotDrillDrillMover )
	fbs.riotDrillDrillModel.Hide()
	//Highlight_SetOwnedHighlight( fbs.riotDrillDrillModel, HIGHLIGHT_BLOODHOUND_SONAR )
	//Highlight_SetFriendlyHighlight( fbs.riotDrillDrillModel, HIGHLIGHT_BLOODHOUND_SONAR )
	riotDrillElements.append( fbs.riotDrillDrillModel )

	// End Model
	fbs.riotDrillEnd = CreatePropScript( RIOT_DRILL_SPIKE, placementInfo.endOrigin, spikeStartAngles, SOLID_CYLINDER )
	fbs.riotDrillEnd.SetParent( fbs.riotDrillStart )
	fbs.riotDrillEnd.Hide()
	riotDrillElements.append( fbs.riotDrillEnd )
	SetTargetName( fbs.riotDrillEnd, RIOT_DRILL_DANGERZONE_TARGETNAME )

	// Sound dummy ( R5DEV-331260 )
	fbs.riotDrillSoundDummy = CreatePropScript( $"mdl/dev/empty_model.rmdl", placementInfo.endOrigin - (BREACH_SPIKE_SOUND_OFFSET * AnglesToUp( spikeEndAngles )) )
	fbs.riotDrillSoundDummy.SetParent( fbs.riotDrillStart )
	riotDrillElements.append( fbs.riotDrillEnd )

	foreach ( bs in riotDrillElements )
		RiotDrill_SetBreachingChargeElementInfo( bs, owner, hitEnt )

	if ( IsValid( hitEnt ) && !hitEnt.IsWorld() )
	{
		if ( EntityShouldStick( fbs.riotDrillStart, hitEnt ) )
		{
			fbs.riotDrillStart.SetParent( hitEnt )
		}
		else
		{
			// TODO: investigate if this still works as intended - ideally never happens
			RestoreRiotDrillAmmo( owner )
			fbs.riotDrillStart.Destroy()
			fbs.riotDrillDrillMover.Destroy()
			return
		}

		if ( hitEnt.GetTargetName() != RESPAWN_CHAMBER_TARGETNAME )
			EndSignal( hitEnt, "OnDestroy" )

		if ( hitEnt.IsEntAlive() )
			EndSignal( hitEnt, "OnDeath" )

		fbs.riotDrillStuckEntity = hitEnt
	}

	array<entity> initialFX = RiotDrill_CreateInitialFX( fbs )

	thread RiotDrill_InitialImpactFX_Think( fbs, BREACH_SPIKE_OFFSET_TO_WALL, AnglesToUp( spikeEndAngles ) )

	EmitSoundOnEntity( fbs.riotDrillStart, RIOT_DRILL_ENTRANCE_DRILLING )
	EmitSoundOnEntity( fbs.riotDrillSoundDummy, RiotDrill_GetExitSoundFX( owner ) )

	//Animation Start
	thread RiotDrill_DrillModelAnimationThink( fbs )

	if ( !file.balance_riotDrillAfterDeath )
		EndSignal( owner, "OnDeath", "OnDestroy" )

	OnThreadEnd(
		function() : ( initialFX, fbs, owner )
		{

			if ( IsValid( owner ) )
			{
				entity weapon = owner.GetOffhandWeapon( OFFHAND_TACTICAL )
				if ( IsValid( weapon ) && weapon.HasMod( "ability_in_effect_regen_paused" ) )
					weapon.RemoveMod( "ability_in_effect_regen_paused" )
			}

			if ( IsValid (fbs.riotDrillEnd) )
				fbs.riotDrillEnd.Destroy()

			if ( IsValid (fbs.riotDrillStart) )
			{
				Signal( fbs.riotDrillStart, "RiotDrill_TempAnimWindDown" )
				Signal( fbs.riotDrillStart, "MaggieCommon_StopImpactTableFX" )
			}
			if ( IsValid (fbs.riotDrillDrillMover) )
				fbs.riotDrillDrillMover.Destroy()

			foreach ( entity fxEnt in initialFX )
			{
				if ( IsValid( fxEnt ) )
					fxEnt.Destroy()
			}
		}
	)

	wait file.balance_riotDrillDelay

	thread RiotDrill_CreateFrontMarker( fbs )

	waitthread RiotDrill_CreateDangerZone( fbs )
}

void function RiotDrill_InitialImpactFX_Think( RiotDrillSystem fbs, float offset, vector angles )
{
	const float RIOT_DRILL_ANIM_TIME = 0.4
	float secondFXDelay = (file.balance_riotDrillDelay - RIOT_DRILL_ANIM_TIME)

	wait RIOT_DRILL_ANIM_TIME

	if ( IsValid ( fbs.riotDrillStart ) )
	{
		thread MaggieCommon_ImpactTableFX_Think( fbs.riotDrillStart, "mm_breach_start", file.fxOption_impactTableFXEnterRefire, secondFXDelay, offset, angles,
			RIOT_DRILL_ENTER_FX_DEFAULT, -fbs.placementInfo.startSurfaceNormal )
	}

	wait (file.balance_riotDrillDelay - RIOT_DRILL_ANIM_TIME)

	if ( IsValid ( fbs.riotDrillStart ) )
	{
		thread MaggieCommon_ImpactTableFX_Think( fbs.riotDrillStart, "mm_breach_enter", file.fxOption_impactTableFXEnterRefire, RiotDrill_GetDuration( fbs.riotDrillStart.GetBossPlayer() ), offset, angles,
			RIOT_DRILL_ENTER_FX_DEFAULT, -fbs.placementInfo.startSurfaceNormal )
	}
}

void function RiotDrill_DrillModelAnimationThink( RiotDrillSystem fbs )
{
	EndSignal( fbs.riotDrillStart, "OnDeath", "OnDestroy", "RiotDrill_StuckEntDissolving" )
	entity drillParent = fbs.riotDrillStart.GetParent()

	if ( IsValid( drillParent ) && drillParent.GetTargetName() != RESPAWN_CHAMBER_TARGETNAME )
		EndSignal( drillParent, "OnDestroy" )

	OnThreadEnd(
		function() : ( fbs, drillParent )
		{
			if( IsValid( fbs.riotDrillStart ) )
				fbs.riotDrillStart.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 200 )
		}
	)

	fbs.riotDrillStart.Anim_DisableUpdatePosition()
	fbs.riotDrillStart.Anim_DisableAnimDelta()

	fbs.riotDrillStart.Anim_PlayOnly( "prop_madmaggie_tac_drill_deploy" )
	WaittillAnimDone( fbs.riotDrillStart )

	fbs.riotDrillStart.Anim_PlayOnly( "prop_madmaggie_tac_drill_deploy_trans" )
	WaittillAnimDone( fbs.riotDrillStart )

	fbs.riotDrillStart.Anim_PlayOnly( "prop_madmaggie_tac_drill_idle" )

	WaitSignal( fbs.riotDrillStart, "RiotDrill_TempAnimWindDown" )

	fbs.riotDrillStart.Anim_PlayOnly( "prop_madmaggie_tac_drill_shutdown" )
	WaittillAnimDone( fbs.riotDrillStart )
}

void function RiotDrill_SetBreachingChargeElementInfo( entity riotDrillEnt, entity owner, entity hitEnt )
{
	EndSignal( riotDrillEnt, "OnDestroy" )

	riotDrillEnt.DisableHibernation()
	riotDrillEnt.SetMaxHealth( 9999 )
	riotDrillEnt.SetHealth( 9999 )
	riotDrillEnt.SetDamageNotifications( false )
	riotDrillEnt.SetDeathNotifications( false )
	riotDrillEnt.SetArmorType( ARMOR_TYPE_HEAVY )
	riotDrillEnt.SetBlocksRadiusDamage( false )
	riotDrillEnt.SetBossPlayer( owner )
	riotDrillEnt.SetOwner( owner )
	riotDrillEnt.e.noOwnerFriendlyFire = false
	riotDrillEnt.RemoveFromAllRealms()
	riotDrillEnt.AddToOtherEntitysRealms( owner )
	SetTeam( riotDrillEnt, owner.GetTeam() )
	riotDrillEnt.SetTakeDamageType( DAMAGE_NO )
	riotDrillEnt.NotSolid()

	thread TrapDestroyOnRoundEnd( owner, riotDrillEnt )
}

void function RiotDrill_StopOnAttachedEntDissolve( RiotDrillSystem fbs )
{
	if ( !IsValid( fbs.riotDrillStuckEntity ) )
		return

	if ( !( fbs.riotDrillStuckEntity instanceof CBaseAnimating ) )
		return

	while( IsValid( fbs.riotDrillStuckEntity ) )
	{
		if ( fbs.riotDrillStuckEntity.IsDissolving() )
		{
			Signal( fbs.riotDrillStart, "RiotDrill_StuckEntDissolving" )
			break
		}

		wait 0.1
	}
}

void function RiotDrill_CreateDangerZone( RiotDrillSystem fbs )
{
	EndSignal( fbs.riotDrillEnd, "OnDeath", "OnDestroy" )
	EndSignal( fbs.riotDrillStart, "RiotDrill_StuckEntDissolving" )

	if ( IsValid( fbs.riotDrillStuckEntity ) && fbs.riotDrillStuckEntity.GetTargetName() != RESPAWN_CHAMBER_TARGETNAME )
	{
		EndSignal( fbs.riotDrillStuckEntity, "OnDeath", "OnDestroy" )
		thread RiotDrill_StopOnAttachedEntDissolve( fbs )
	}

	vector endOrigin = fbs.riotDrillEnd.GetOrigin()
	vector endAngles = fbs.riotDrillEnd.GetAngles()
	entity ownerPlayer = fbs.riotDrillStart.GetBossPlayer()

	if ( !IsValid( ownerPlayer ) )
		return

	int ownerPlayerTeam = ownerPlayer.GetTeam()
	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetOwner( ownerPlayer )
	trigger.SetRadius( RiotDrill_GetRadius( ownerPlayer ) )
	trigger.SetAboveHeight( RiotDrill_GetLength( ownerPlayer ) )
	trigger.SetBelowHeight( 0 )
	trigger.SetOrigin( endOrigin )
	trigger.SetAngles( endAngles )
	trigger.RemoveFromAllRealms()
	trigger.AddToOtherEntitysRealms( ownerPlayer )
	trigger.kv.triggerFilterNpc = "all"
	trigger.kv.triggerFilterPlayer = "all"
	trigger.kv.triggerFilterNonCharacter = 1
	trigger.kv.triggerFilterTeamOther = 1

	trigger.SetParent( fbs.riotDrillEnd )

	DispatchSpawn( trigger )
	fbs.damageTrigger = trigger
	trigger.SearchForNewTouchingEntity()

	array<entity> fxEnts = RiotDrill_CreateDangerZoneFX( fbs )

	thread MaggieCommon_ImpactTableFX_Think( fbs.riotDrillEnd, "mm_breach_exit", file.fxOption_impactTableFXExitRefire, RiotDrill_GetDuration( ownerPlayer ) )

	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_MAGGIE_RIOT_DRILL_START, fbs.riotDrillStart, fbs.placementInfo.startOrigin, ownerPlayerTeam, fbs.riotDrillStart )
	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_MAGGIE_RIOT_DRILL_END, fbs.riotDrillEnd, fbs.placementInfo.endOrigin, ownerPlayerTeam, fbs.riotDrillEnd )

	float dangerousAreaRadius = RiotDrill_GetRadius( ownerPlayer ) * 0.5
	vector dangerousAreaOffset = VectorRotate( <dangerousAreaRadius, 0, 0>, fbs.breachAngle )
	AI_CreateDangerousArea_Static( fbs.riotDrillStart, fbs.riotDrillStart, dangerousAreaRadius, TEAM_INVALID, true, true, fbs.riotDrillStart.GetOrigin() + dangerousAreaOffset )

	OnThreadEnd(
		function () : ( trigger, fbs, fxEnts )
		{
			if ( IsValid( fbs.riotDrillStart ) )
				StopSoundOnEntity( fbs.riotDrillStart, RIOT_DRILL_ENTRANCE_DRILLING )

			if ( IsValid( fbs.riotDrillEnd ) )
			{
				StopSoundOnEntity( fbs.riotDrillEnd, RIOT_DRILL_EXIT_DRILLING )

					StopSoundOnEntity( fbs.riotDrillEnd, RIOT_DRILL_EXIT_DRILLING_UPGRADE )

			}

			if ( IsValid( trigger ) )
				trigger.Destroy()

			foreach ( ent in fxEnts )
			{
				if ( IsValid( ent ) )
					ent.Destroy()
			}
		}
	)

	float endDangerZoneTime = Time() + RiotDrill_GetDuration( ownerPlayer )
	while ( Time() < endDangerZoneTime && IsValid( fbs.damageTrigger ) )
	{
		array<entity> hitEnts = fbs.damageTrigger.GetTouchingEntities()
		if ( IsValid( fbs.riotDrillStuckEntity ) && !hitEnts.contains( fbs.riotDrillStuckEntity ) )
			hitEnts.append( fbs.riotDrillStuckEntity )

		foreach ( entity ent in hitEnts )
		{
			if( ent.IsPlayer() || ent.IsNPC() )
			{
				vector hitEntCenter = ent.GetCenter()
				vector damageTriggerOrigin = fbs.damageTrigger.GetOrigin()

				// Player targets that are occluded behind other geo are only damaged if they're close enough, or within "LOS" of the drill
				// this helps to iron out edge cases where players can be in the damaging trigger without obviously being in danger from the FX/angle of the drill
				//bool hasLOS = TraceLineHighDetail( hitEntCenter, damageTriggerOrigin, [], TRACE_MASK_SHOT_BRUSHONLY, TRACE_COLLISION_GROUP_NONE, ownerPlayer ).fraction < 0.9
				bool farDistance = Distance( hitEntCenter, damageTriggerOrigin ) > RiotDrill_GetRadius( ownerPlayer ) / 1.5

				if (ent.IsPlayer() && !RiotDrillExit_HasLOSToPlayer( fbs, ent ) && farDistance )
					continue

				ent.TakeDamage( file.balance_riotDrillDamage, ownerPlayer, ownerPlayer, file.riotDrillDamageParams )
			}
			// "object" target takes less damage
			else
			{
				ent.TakeDamage( file.balance_riotDrillObjectDamage, ownerPlayer, ownerPlayer, file.riotDrillDamageParams )
			}
			if ( ent.IsPlayer() )
			{
				if ( !ent.IsPhaseShifted() )
				{
					EmitSoundOnEntityOnlyToPlayer( ent, ent, RIOT_DRILL_DAMAGE_SOUND_1P )
					EmitSoundOnEntityExceptToPlayer( ent, ent, RIOT_DRILL_DAMAGE_SOUND_3P )
				}
			}
			else
			{
				EmitSoundOnEntity( ent, RIOT_DRILL_DAMAGE_SOUND_3P )
			}
		}
		wait RIOT_DRILL_DAMAGE_TICK
	}
}

bool function RiotDrillExit_HasLOSToPlayer( RiotDrillSystem fbs, entity player )
{
	vector startOrigin = fbs.riotDrillEnd.GetOrigin() + ( 5.0 * fbs.riotDrillEnd.GetUpVector() )

	array<entity> ignoreEnts = GetPlayerArray_AliveConnected()
	ignoreEnts.append( fbs.riotDrillEnd )

	array<vector> testEndVectors = [
		player.EyePosition(),
		(player.EyePosition() + player.GetWorldSpaceCenter()) / 2,
		((player.EyePosition() + player.GetWorldSpaceCenter()) / 2) + (player.GetRightVector() * 8),
		((player.EyePosition() + player.GetWorldSpaceCenter()) / 2) + (player.GetRightVector() * -8),
		player.GetWorldSpaceCenter(),
	]

	foreach ( testVector in testEndVectors )
	{
		vector traceStart = startOrigin
		vector traceEnd   = testVector

		TraceResults traceResults = TraceLineHighDetail( traceStart, traceEnd, ignoreEnts, TRACE_MASK_BLOCKLOS, TRACE_COLLISION_GROUP_BLOCK_WEAPONS, fbs.riotDrillEnd )

		if ( traceResults.fraction > 0.995 )
			return true
	}

	return false
}

//////////////////////////
////// FX FUNCTIONS //////
//////////////////////////

array<entity> function RiotDrill_CreateInitialFX( RiotDrillSystem fbs )
{
	entity ownerPlayer = fbs.riotDrillStart.GetBossPlayer()
	vector origin = fbs.riotDrillStart.GetOrigin()
	vector forward = AnglesToForward( fbs.breachAngle )

	// FRONT FX
	entity fx_front = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( RIOT_DRILL_FRONT_FX ),
		fbs.riotDrillStart.GetOrigin() + ( -20.0 * forward ), fbs.riotDrillStart.GetAngles() )
	fx_front.SetParent( fbs.riotDrillStart )

	// inside-geo beam
	vector blastOrigin = fbs.riotDrillStart.GetOrigin()
	vector blastTarget = fbs.riotDrillEnd.GetOrigin()

	entity internalControlPoint = CreateEntity( "info_placement_helper" )
	SetTargetName( internalControlPoint, UniqueString( "translocation_endPos" ) )
	internalControlPoint.SetOrigin( blastTarget )
	if ( IsValid( fbs.riotDrillStuckEntity ) )
		internalControlPoint.SetParent( fbs.riotDrillStuckEntity )
	DispatchSpawn( internalControlPoint )

	entity internalBeamFX = CreateEntity( "info_particle_system" )
	internalBeamFX.RemoveFromAllRealms()
	internalBeamFX.AddToOtherEntitysRealms( fbs.riotDrillDrillModel )
	internalBeamFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	internalBeamFX.SetValueForEffectNameKey( RIOT_DRILL_BLAST_BEAM_FX )
	internalBeamFX.kv.cpoint1 = internalControlPoint.GetTargetName()
	internalBeamFX.kv.start_active = 1
	internalBeamFX.SetOrigin( blastOrigin )
	if ( IsValid( fbs.riotDrillStuckEntity ) )
		internalBeamFX.SetParent( fbs.riotDrillStuckEntity )
	DispatchSpawn( internalBeamFX )
	//beam is a one-shot, so run the cleanup now
	thread MaggieCommon_CleanUpFX( internalBeamFX, RiotDrill_GetDuration( fbs.riotDrillStart.GetBossPlayer() ) )

	// exit beam
	vector exitTarget = blastTarget + (forward * RiotDrill_GetLength( ownerPlayer ) )
	TraceResults exitBeam_tr = TraceLineHighDetail( blastTarget, exitTarget, [], TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE, fbs.riotDrillStart.GetOwner() )

	entity exitControlPoint = CreateEntity( "info_placement_helper" )
	SetTargetName( exitControlPoint, UniqueString( "translocation_endPos" ) )
	exitControlPoint.SetOrigin( exitBeam_tr.endPos )
	if ( IsValid( fbs.riotDrillStuckEntity ) )
		exitControlPoint.SetParent( fbs.riotDrillStuckEntity )
	DispatchSpawn( exitControlPoint )

	entity exitBeamFX = CreateEntity( "info_particle_system" )
	exitBeamFX.RemoveFromAllRealms()
	exitBeamFX.AddToOtherEntitysRealms( fbs.riotDrillDrillModel )
	exitBeamFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	exitBeamFX.SetValueForEffectNameKey( RiotDrill_GetBlastBeamWarnFX( ownerPlayer ) )
	exitBeamFX.kv.cpoint1 = exitControlPoint.GetTargetName()
	exitBeamFX.kv.start_active = 1
	exitBeamFX.SetOrigin( blastTarget )
	exitBeamFX.SetAngles( VectorToAngles( forward ) )
	if ( IsValid( fbs.riotDrillStuckEntity ) )
		exitBeamFX.SetParent( fbs.riotDrillStuckEntity )
	DispatchSpawn( exitBeamFX )
	//beam is a one-shot, so run the cleanup now
	thread MaggieCommon_CleanUpFX( exitBeamFX, file.balance_riotDrillDelay )

	return [ fx_front, internalControlPoint, exitControlPoint ]
}

array<entity> function RiotDrill_CreateDangerZoneFX( RiotDrillSystem fbs )
{
	const float FX_SCALE_BASE = 100.0 //scaling based on the ability_breaching_charge.pcf median value of 100.0
	array<entity> fxEnts

	vector origin = fbs.riotDrillEnd.GetOrigin()
	vector angles = fbs.riotDrillEnd.GetAngles()

	entity ownerPlayer = fbs.riotDrillStart.GetBossPlayer()
	float scaleOverride = ( RiotDrill_GetRadius( ownerPlayer ) / FX_SCALE_BASE )
	entity fx_01 	= StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( RiotDrill_GetAOEWarningFX( ownerPlayer ) ), origin, angles )
	fx_01.SetParent( fbs.riotDrillEnd )
	EffectSetControlPointVector( fx_01, 1, <scaleOverride, 0, 0> )
	fxEnts.append( fx_01 )

	if ( fbs.placementInfo.placementResult != eBreachPlacementResult.FAILED_WALL_TOO_THICK )
	{
		entity fx_decal_end = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( RIOT_DRILL_DECAL ),
			fbs.placementInfo.endOrigin, fbs.placementInfo.endSurfaceNormal )
		fx_decal_end.RemoveFromAllRealms()
		fx_decal_end.AddToOtherEntitysRealms( fbs.riotDrillDrillModel )
		fxEnts.append( fx_decal_end )
	}

	if( DEBUG_INFO )
		DebugDrawCylinder( origin, VectorToAngles( Normalize( origin - fbs.riotDrillStart.GetOrigin() ) ), RiotDrill_GetRadius( ownerPlayer ), RiotDrill_GetLength( ownerPlayer ), <0, 200, 0>, true, RiotDrill_GetDuration( ownerPlayer ) )

	return fxEnts
}

void function RiotDrill_CreateFrontMarker( RiotDrillSystem fbs )
{
	const float OFFSET_TEXT = -20.0

	vector origin = fbs.riotDrillStart.GetOrigin()
	vector forward = AnglesToForward( fbs.breachAngle )

	entity marker = CreatePropScript( $"mdl/dev/empty_model.rmdl", origin + ( OFFSET_TEXT * forward ), fbs.breachAngle )
	marker.SetScriptName( "concussive_breach_marker" )
	marker.DisableHibernation()
	marker.SetParent( fbs.riotDrillStart )

	OnThreadEnd(
		function() : ( marker )
		{
			if ( IsValid( marker ) )
				marker.Destroy()
		}
	)

	wait RiotDrill_GetDuration( fbs.riotDrillStart.GetBossPlayer() )
}

void function RiotDrill_DrillOutOfRange_Think( entity owner, vector pos, vector dir )
{
	entity fizzledDrill = CreateEntity( "prop_physics" )
	fizzledDrill.SetOwner( owner )
	fizzledDrill.SetModel( RIOT_DRILL_DRILL_FIZZLE )
	fizzledDrill.SetOrigin( pos )
	fizzledDrill.SetAngles( <0,0,0> )
	fizzledDrill.kv.inertiaScale = 1.0
	fizzledDrill.kv.gravity = 1
	fizzledDrill.kv.solid = SOLID_VPHYSICS
	fizzledDrill.RemoveFromAllRealms()
	fizzledDrill.AddToOtherEntitysRealms( owner )
	DispatchSpawn( fizzledDrill )

	fizzledDrill.SetVelocity( 1000 * Normalize( dir ) )

	// why is this "wait" required for creating these FX?
	wait 0.1

	StartParticleEffectInWorld( GetParticleSystemIndex( RIOT_DRILL_FIZZLE_EXPLODE_FX ), pos, <0,0,0> )
	if ( IsValid( fizzledDrill ) )
		StartParticleEffectOnEntity( fizzledDrill, GetParticleSystemIndex( RIOT_DRILL_FIZZLE_SPARKS_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )

	wait 3.0

	if ( IsValid( fizzledDrill ) )
		fizzledDrill.Destroy()
}

void function ClientCallback_DrillError_On( entity player )
{
	if ( !IsAlive( player ) )
		return

	entity weapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )
	if ( IsValid( weapon ) && !weapon.HasMod( "drill_error" ) )
		weapon.AddMod( "drill_error" )
}

void function ClientCallback_DrillError_Off( entity player )
{
	if ( !IsAlive( player ) )
		return

	entity weapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )
	if ( IsValid( weapon ) && weapon.HasMod( "drill_error" ) )
		weapon.RemoveMod( "drill_error" )
}

//investigation into http://jiratf.respawn.net:8080/browse/R5DEV-325796
void function RiotDrill_OnDamage( entity victim, var damageInfo )
{





}
#endif //SERVER

#if CLIENT

//////////////////////////////
////// CLIENT FUNCTIONS //////
//////////////////////////////

void function OnClientAnimEvent_weapon_riot_drill( entity weapon, string name )
{
	if ( !IsValid( weapon ) )
		return

	const float SHAKE_AMPLITUDE = 2.0
	const float SHAKE_FREQUENCY = 10.0
	const float SHAKE_DURATION = 0.2
	const vector SHAKE_DIRECTION = < 0.0, 0.0, 1.0 >

	if ( name == "riot_drill_screen_shake" )
		ClientScreenShake( SHAKE_AMPLITUDE, SHAKE_FREQUENCY, SHAKE_DURATION, SHAKE_DIRECTION )
}

void function ServerCallback_CancelPlacement( entity player )
{
	player.Signal( "DeployableBreachChargePlacement_End" )
}

void function SetBreachChargeDeployed( bool state )
{
	file.breachChargeDeployed = state
}

void function DestroyBreachChargeProxy( entity ent )
{
	Assert( IsNewThread(), "Must be threaded off" )
	EndSignal( ent, "OnDestroy" )

	if ( file.breachChargeDeployed )
		wait 0.225

	ent.Destroy()
}

void function RiotDrill_OnPropScriptCreated( entity ent )
{
	switch ( ent.GetScriptName() )
	{
		case "concussive_breach_marker":
			thread RiotDrill_CreateHUDMarker( ent )
			break
	}
}

void function RiotDrill_CreateHUDMarker( entity marker )
{
	entity localClientPlayer = GetLocalClientPlayer()

	EndSignal( marker, "OnDestroy" )

	if ( !GamePlayingOrSuddenDeath() )
		return

	var topology = CreateRUITopology_Worldspace( <0,0,0>, <0,0,0>, 32, 32 )
	var ruiPlane = RuiCreate( $"ui/concussive_breach_timer.rpak", topology, RUI_DRAW_WORLD, 0 )
	RuiTopology_SetParent( topology, marker )

	RuiSetGameTime( ruiPlane, "startTime", Time() )
	RuiSetFloat( ruiPlane, "lifeTime", RiotDrill_GetDuration( marker.GetBossPlayer() ) )

	OnThreadEnd(
		function() : ( ruiPlane, topology )
		{
			RuiDestroy( ruiPlane )
			RuiTopology_Destroy( topology )
		}
	)

	WaitForever()
}

void function DeployableBreachChargePlacementThink( entity player )
{
	EndSignal( player, "DeployableBreachChargePlacement_End", "OnDeath", "OnDestroy", SIGNAL_BLEEDOUT_STATE_CHANGED )

	const vector COLOR_DEPTH_UNKNOWN	= <255, 122, 0>
	const vector COLOR_DEPTH_START 		= <255, 122, 0>
	const vector COLOR_DEPTH_MID 		= <255, 210, 73>
	const vector COLOR_DEPTH_END 		= <255, 255, 255>

	asset breachStartModel				= RIOT_DRILL_SPIKE
	asset breachDrillModel				= RIOT_DRILL_DRILL
	string breachStartModelAttachment	= "muzzle_flash"
	string breachDrillModelAttachment	= "ORIGIN"

	if ( file.fxOption_hideModels )
	{
		breachStartModel = RIOT_DRILL_EMPTY_MODEL
		breachDrillModel = RIOT_DRILL_EMPTY_MODEL
		breachStartModelAttachment = "ORIGIN"
		breachDrillModelAttachment = "ORIGIN"
	}

	entity breachCharge_startProxy = CreateBreachChargeProxy( breachStartModel )
	breachCharge_startProxy.EnableRenderAlways()
	breachCharge_startProxy.Show()

	int placementFXhandle_Enter = StartParticleEffectOnEntity( breachCharge_startProxy, GetParticleSystemIndex( RIOT_DRILL_PLACEMENT_ENTER ),
		FX_PATTACH_POINT_FOLLOW, breachCharge_startProxy.LookupAttachment( breachStartModelAttachment ) )

	entity breachCharge_endProxy = CreateBreachChargeProxy( breachDrillModel )
	breachCharge_endProxy.EnableRenderAlways()
	breachCharge_endProxy.Show()

	int placementFXhandle_Exit = StartParticleEffectOnEntity( breachCharge_endProxy, GetParticleSystemIndex( RIOT_DRILL_PLACEMENT_EXIT ),
		FX_PATTACH_POINT_FOLLOW, breachCharge_endProxy.LookupAttachment( breachDrillModelAttachment ) )
	EffectSetControlPointVector( placementFXhandle_Exit, 1, ( RIOT_DRILL_PLACEMENT_VALID_COLOR / 255.0 ) )

	EffectAddTrackingForControlPoint( placementFXhandle_Enter, 1, breachCharge_endProxy, FX_PATTACH_POINT_FOLLOW, breachCharge_endProxy.LookupAttachment( breachDrillModelAttachment ), <0,0,0> )

	file.depthRui = null//CreateFullscreenRui( $"ui/mm_riot_drill.rpak" )

	OnThreadEnd(
		function() : ( breachCharge_startProxy, breachCharge_endProxy, placementFXhandle_Enter, placementFXhandle_Exit )
		{
			CleanupFXHandle( placementFXhandle_Enter, true, false )
			CleanupFXHandle( placementFXhandle_Exit, true, false )

			if ( IsValid( breachCharge_startProxy ) )
				thread DestroyBreachChargeProxy( breachCharge_startProxy )

			if ( IsValid( breachCharge_endProxy ) )
				thread DestroyBreachChargeProxy( breachCharge_endProxy )

			//Remote_ServerCallFunction( "ClientCallback_DrillError_Off" )

			if ( file.depthRui != null )
			{
				RuiDestroyIfAlive( file.depthRui )
				file.depthRui = null
			}
		}
	)

	int currentResult = -1

	while ( player.IsUsingOffhandWeapon( eActiveInventorySlot.altHand ) )
	{
		RiotDrillPlacementInfo placementInfo = GetRiotDrillPlacementInfo( player, [] )

		vector forward = AnglesToForward( placementInfo.startAngles )

		breachCharge_startProxy.SetOrigin( placementInfo.startOrigin + ( forward * -15.0 ) )
		breachCharge_startProxy.SetAngles( AnglesCompose( placementInfo.startAngles, <90,0,0> ) )

		breachCharge_endProxy.SetOrigin( placementInfo.endOrigin + ( -30.0 * AnglesToUp( AnglesCompose( placementInfo.endAngles, <-90,0,0> ) ) ) )
		breachCharge_endProxy.SetAngles( AnglesCompose( placementInfo.endAngles, -<90,0,0> ) )

		vector placementColor

		if ( placementInfo.placementResult == eBreachPlacementResult.SUCCESS )
			placementColor = ( RIOT_DRILL_PLACEMENT_VALID_COLOR / 255.0 )
		else if ( placementInfo.placementResult == eBreachPlacementResult.FAILED_WALL_TOO_THICK && file.balance_riotDrillAllowThick )
			placementColor = ( RIOT_DRILL_PLACEMENT_CAUTION_COLOR / 255.0 )
		else
			placementColor = ( RIOT_DRILL_PLACEMENT_ERROR_COLOR / 255.0 )

		if ( EffectDoesExist( placementFXhandle_Enter ) )
			EffectSetControlPointVector( placementFXhandle_Enter, 1, placementColor )

		currentResult = placementInfo.placementResult

		if ( placementInfo.hide || placementInfo.placementResult == eBreachPlacementResult.FAILED_GENERIC )
		{
			breachCharge_startProxy.Hide()
			breachCharge_endProxy.Hide()
		}
		else
		{
			float distance = Distance( placementInfo.startOrigin, placementInfo.endOrigin )
			float distanceFrac = distance / file.balance_riotDrillMaxThickness
			vector color = GetTriLerpColor( distanceFrac, COLOR_DEPTH_END, COLOR_DEPTH_MID, COLOR_DEPTH_START, 0.6, 0.3 )

			if ( placementInfo.placementResult == eBreachPlacementResult.FAILED_OUT_OF_RANGE
				|| placementInfo.placementResult == eBreachPlacementResult.FAILED_WALL_TOO_THICK
				|| placementInfo.placementResult == eBreachPlacementResult.FAILED_SAFETY_CATCH )
			{
				color = COLOR_DEPTH_UNKNOWN
				distance = -1.0
				breachCharge_startProxy.Hide()
				breachCharge_endProxy.Hide()
				//Remote_ServerCallFunction( "ClientCallback_DrillError_On" )
			}
			//else if ( placementInfo.placementResult == eBreachPlacementResult.FAILED_SAFETY_CATCH )
			//{
			//	color = COLOR_DEPTH_UNKNOWN
			//	distance = -11.0
			//	breachCharge_startProxy.Hide()
			//	breachCharge_endProxy.Hide()
			//}
			else
			{
				breachCharge_startProxy.Show()
				breachCharge_endProxy.Show()
				//Remote_ServerCallFunction( "ClientCallback_DrillError_Off" )
			}

			//RuiSetFloat( file.depthRui, "depth", distance )
			//RuiSetFloat3( file.depthRui, "infoTextColorRGB", ( color / 255.0 ) )

			DeployableModelHighlight( breachCharge_endProxy )
		}
		WaitFrame()
	}
}

entity function CreateBreachChargeProxy( asset modelName )
{
	entity breachCharge = CreateClientSidePropDynamic( <0, 0, 0>, <0, 0, 0>, modelName )
	breachCharge.kv.renderamt = 255
	breachCharge.kv.rendermode = 3
	breachCharge.kv.rendercolor = "255 255 255 255"

	breachCharge.Anim_Play( "ref" )
	breachCharge.Hide()

	return breachCharge
}

void function RiotDrill_AddThreatIndicator( entity dangerZone )
{
	entity player = GetLocalViewPlayer()

	entity owner = dangerZone.GetOwner()
	int team = player.GetTeam()
	int dangerZoneTeam = player.GetTeam()

	if( IsEnemyTeam( team, dangerZoneTeam ) || ( player == owner ) )
		ShowGrenadeArrow( player, dangerZone, RiotDrill_GetLength( owner ), 0, false )
}

#endif //CLIENT

//////////////////////////////////
////// ONWEAPON FUNCTIONS ////////
//////////////////////////////////

//apparently this doesn't get called on the Client, so have to do a callback function
var function OnWeaponTossCancel_weapon_riot_drill( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetOwner()

	#if SERVER
		Remote_CallFunction_Replay( player, "ServerCallback_CancelPlacement", player )
	#endif

	return 0
}

var function OnWeaponTossReleaseAnimEvent_weapon_riot_drill( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetOwner()

	RiotDrillPlacementInfo placementInfo = GetRiotDrillPlacementInfo( weapon.GetOwner(), [] )
	bool resultIsAllowedThickBreach = file.balance_riotDrillAllowThick && ( placementInfo.placementResult == eBreachPlacementResult.FAILED_WALL_TOO_THICK )
	bool resultIsAllowedOutRangeBreach = file.balance_riotDrillAllowOutRange && ( placementInfo.placementResult == eBreachPlacementResult.FAILED_OUT_OF_RANGE )
	bool resultIsAllowedPlayerTarget = file.balance_riotDrillPlayerCollide && ( placementInfo.placementResult == eBreachPlacementResult.FAILED_SAFETY_CATCH )

	if ( ( placementInfo.placementResult != eBreachPlacementResult.SUCCESS ) )
	{
		if ( !resultIsAllowedThickBreach && !resultIsAllowedOutRangeBreach && !resultIsAllowedPlayerTarget )
		{
			weapon.DoDryfire()
			return 0
		}
	}

	bool ignite = false
	#if SERVER
		if ( file.balance_riotDrillProjCollision )
		{
			ignite = true
		}
		else
		{
			if ( placementInfo.placementResult != eBreachPlacementResult.FAILED_OUT_OF_RANGE )
			{
				// create the fissure charge immediately, regardless of where the projectile is
				thread RiotDrill_CreateBreachingCharge_System( placementInfo, player, placementInfo.hitEnt )
				weapon.AddMod( "ability_in_effect_regen_paused" )
			}
			else
			{
				// disable the projectile in flight because the target is out of range
				thread RiotDrill_DrillOutOfRange_Think( player, placementInfo.startOrigin, player.GetViewVector() )
			}
		}
		PlayBattleChatterLineToSpeakerAndTeam( player, "bc_tactical" )
	#else //SERVER
		SetBreachChargeDeployed( true )
		player.Signal( "DeployableBreachChargePlacement_End" )
	#endif //CLIENT

	var result = RiotDrill_FireProjectile( weapon, attackParams, ignite )
	return result
}

// this is a Maggie-specific version of Grenade_OnWeaponToss
int function RiotDrill_FireProjectile( entity weapon, WeaponPrimaryAttackParams attackParams, bool ignite )
{
	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )
	bool projectilePredicted      = PROJECTILE_PREDICTED
	bool projectileLagCompensated = PROJECTILE_LAG_COMPENSATED
	#if SERVER
		if ( weapon.IsForceReleaseFromServer() )
		{
			projectilePredicted = false
			projectileLagCompensated = false
		}
	#endif
	entity grenade     = Grenade_Launch( weapon, attackParams.pos, (attackParams.dir), projectilePredicted, projectileLagCompensated, ZERO_VECTOR )
	entity weaponOwner = weapon.GetWeaponOwner()
	weaponOwner.Signal( "ThrowGrenade" )

	PlayerUsedOffhand( weaponOwner, weapon, true, grenade )

	if ( IsValid( grenade ) )
	{
		grenade.proj.savedDir = weaponOwner.GetViewForward()
		grenade.proj.savedOrigin = grenade.GetOrigin()
	}
	#if SERVER
	if ( IsValid( grenade ) )
	{
		grenade.SetIgnorePredictedTriggerTypes( TT_JUMP_PAD )
		if ( ignite )
		{
			grenade.GrenadeIgnite()
			grenade.SetDoesExplode( false )
		}
	}
	#endif

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

void function OnWeaponActivate_riot_drill( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if CLIENT
		SetBreachChargeDeployed( false )
		if ( !InPrediction() ) //Stopgap fix for Bug 146443
			return
		if ( ownerPlayer == GetLocalViewPlayer() )
			thread DeployableBreachChargePlacementThink( ownerPlayer )
	#endif
}
void function OnWeaponDeactivate_riot_drill( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if CLIENT
		if ( !InPrediction() ) //Stopgap fix for Bug 146443
			return
		if ( ownerPlayer == GetLocalViewPlayer() )
			ownerPlayer.Signal( "DeployableBreachChargePlacement_End" )
	#endif

	#if SERVER
		weapon.Signal( "WeaponDeactivateEvent" )
	#endif
}

void function OnProjectileCollision_weapon_riot_drill( entity projectile, vector pos, vector normal, entity hitEnt, int hitBox, bool isCritical )
{
	bool isBounceTarget = ( hitEnt.IsPlayer() || hitEnt.IsNPC() || file.bounceOffSpecialCaseNames.contains( hitEnt.GetScriptName() ) )
	// check for entities parented to the target, e.g. Gibraltar Shield
	// rather not use file.bounceOffSpecialCaseNames for these cases, in order to help future-proof the system
	entity hitEntParent = hitEnt.GetParent()
	if ( IsValid( hitEntParent ) )
		isBounceTarget = isBounceTarget || hitEntParent.IsPlayer() || hitEntParent.IsNPC()

#if SERVER
	entity ownerPlayer = projectile.GetOwner()

	if ( !hitEnt.IsWorld() )
	{
		//entity shieldingVortexSphere = Trophy_EntInTrophyTrigger( hitEnt )
		//if ( IsValid( shieldingVortexSphere ) && Trophy_RemoteTryZapProjectile( shieldingVortexSphere, projectile ) )
			//return

		if ( !projectile.e.isDisabled )
		{
			hitEnt.TakeDamage( file.balance_riotDrillImpactDamage, ownerPlayer, ownerPlayer, file.riotDrillImpactDamageParams )
			projectile.e.isDisabled = true
		}
	}
#endif

	if ( file.balance_riotDrillPlayerCollide && isBounceTarget )
		return

#if SERVER
	if ( file.balance_riotDrillProjCollision && projectile.GrenadeHasIgnited() )
	{
		vector vel = projectile.GetVelocity()

		array<entity> ignoreArray = GetPlayerArray()
		ignoreArray.extend( GetPlayerDecoyArray() )
		ignoreArray.append( projectile )

		// work to fix R5DEV-324106
		// the projectile seems to register a hit off the geo, which can cause strange behavior at hard angles
		// therefore, need to correct the initial trace point back towards the geo
		vector traceStart = ( pos - ( normal * 6.0 ) )
		vector angleOfAttack = Normalize( traceStart - projectile.proj.savedOrigin )
		traceStart = traceStart - ( angleOfAttack * 5.0 )
		vector traceEnd	= traceStart + ( vel * 20.0 )

		TraceResults traceResults = TraceLineHighDetail( traceStart, traceEnd, ignoreArray, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE, projectile.GetOwner() )
		//DebugDrawLine( traceStart, traceEnd, <0, 250, 250>, true, 20 ) //green

		//entity potentialTrophy = Trophy_GetTrophyInRangeOfEntity( projectile )
		//if ( IsValid( potentialTrophy ) && Trophy_RemoteTryZapEntity( potentialTrophy, projectile ) )
			//return

		entity owner = projectile.GetOwner()
		if ( !IsValid( owner ) )
			return

		RiotDrillPlacementInfo placementInfo
		placementInfo.startOrigin = traceResults.endPos
		placementInfo.startAngles = VectorToAngles( vel )
		placementInfo.startSurfaceNormal = traceResults.surfaceNormal
		placementInfo.placementResult = eBreachPlacementResult.SUCCESS
		placementInfo.hide = true
		placementInfo.hitEnt = traceResults.hitEnt

		// potentially change this to use a more flexible version of GetRiotDrillPlacementInfo for consistency?
		int breachPlacementSuccess = FindEndSpikeLocation( ownerPlayer, placementInfo, false )

		if ( breachPlacementSuccess == eBreachPlacementResult.SUCCESS )
		{
			const float INCHES_PER_METER = 100 / 2.54
			int distance = int( RoundToNearestInt( Distance( placementInfo.startOrigin, placementInfo.endOrigin ) / INCHES_PER_METER ) )
			//StatsHook_MaggieRiotDrillMetersTraveled( owner, distance )
		}

		//fix for R5DEV-321772
		if ( breachPlacementSuccess == eBreachPlacementResult.FAILED_SAFETY_CATCH )
		{
			projectile.e.isDisabled = true
			return
		}

		thread RiotDrill_CreateBreachingCharge_System( placementInfo, owner, placementInfo.hitEnt )
	}

	projectile.Destroy()
#endif

#if CLIENT
	projectile.SetVelocity( <0, 0, 0> )
	projectile.StopPhysics()
#endif
}

///////////////////////////////////
////// PLACEMENT FUNCTIONS ////////
///////////////////////////////////

RiotDrillPlacementInfo function GetRiotDrillPlacementInfo( entity player, array<entity> ignoreEnts, bool debugDrawTrace = false )
{
	int placementResult = eBreachPlacementResult.SUCCESS

	array<entity> ignoreArray = file.balance_riotDrillPlayerCollide ? [ player ] : GetPlayerArray()
	ignoreArray.extend( GetPlayerDecoyArray() )
	ignoreArray.extend( ignoreEnts )

	vector traceStart = player.EyePosition()
	vector traceEnd	= traceStart + ( player.GetViewVector() * file.balance_riotDrillRange )

	TraceResults traceResults = TraceLineHighDetail( traceStart, traceEnd, ignoreArray, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE, player )
	entity testHitEnt = traceResults.hitEnt
	if ( IsValid( testHitEnt ) )
	{
		if ( IsValid( testHitEnt.GetParent() ) )
			testHitEnt = testHitEnt.GetParent()
	}

	if ( !IsValid( testHitEnt ) )
		placementResult = eBreachPlacementResult.FAILED_OUT_OF_RANGE
	else if ( testHitEnt.IsPlayer() || testHitEnt.IsNPC() || file.bounceOffSpecialCaseNames.contains( testHitEnt.GetScriptName() ) )
		placementResult = eBreachPlacementResult.FAILED_SAFETY_CATCH
	else if ( traceResults.hitEnt.GetPassThroughFlags() != 0 && ( CheckPassThroughDir( traceResults.hitEnt, traceResults.surfaceNormal, traceResults.endPos ) ) )
	{
		if ( ignoreEnts.len() == 0 )
			ignoreEnts = [ traceResults.hitEnt ]
		else
			ignoreEnts.append( traceResults.hitEnt )
		return GetRiotDrillPlacementInfo( player, ignoreEnts, debugDrawTrace )
	}

	RiotDrillPlacementInfo placementInfo
	placementInfo.startOrigin = traceResults.endPos
	placementInfo.startAngles = player.EyeAngles()
	placementInfo.startSurfaceNormal = traceResults.surfaceNormal
	placementInfo.placementResult = placementResult
	placementInfo.hide = false
	placementInfo.hitEnt = traceResults.hitEnt

	if ( placementInfo.placementResult == eBreachPlacementResult.SUCCESS)
		placementInfo.placementResult = FindEndSpikeLocation( player, placementInfo, debugDrawTrace )

	return placementInfo
}

int function FindEndSpikeLocation( entity player, RiotDrillPlacementInfo placementInfo, bool debugDrawTrace = false )
{
	const vector HULL_TRACE_MIN = <-4, -4, 0>
	const vector HULL_TRACE_MAX = <4, 4, 32>

	vector pos                             = placementInfo.startOrigin
	vector forward                         = AnglesToForward( placementInfo.startAngles )

	BreachTraceResults breachTraceTresults

	if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_TWO ) ) // upgrade_maggie_drill_depth_and_range
	{
		breachTraceTresults = BreachTrace( pos, forward, HULL_TRACE_MIN, HULL_TRACE_MAX, 728.0 )
	}
	else

	{
		breachTraceTresults = BreachTrace( pos, forward, HULL_TRACE_MIN, HULL_TRACE_MAX, 512.0 )
	}

	if ( breachTraceTresults.result == BREACH_TRACE_RESULT_SUCCESS )
	{
		placementInfo.endAngles        = placementInfo.startAngles
		placementInfo.endOrigin        = breachTraceTresults.endPos
		placementInfo.endSurfaceNormal = breachTraceTresults.surfaceNormal
	}
	else if ( breachTraceTresults.result == BREACH_TRACE_RESULT_WALL_TOO_THICK && file.balance_riotDrillAllowThick )
	{
		placementInfo.endAngles = placementInfo.startAngles
		placementInfo.endOrigin = placementInfo.startOrigin
	}

	return breachTraceTresults.result
}

bool function CodeCallback_BreachTraceEarlyExitOnEnt( entity ent )
{
	if ( IsValid( ent ) && file.shieldScriptNames.contains( ent.GetScriptName() ) )
	{
		return true
	}

	return false
}

bool function CodeCallback_BreachTraceIsValidPos( vector pos )
{
	#if SERVER
		//Fix for R5DEV-308748 -> found an endpoint, but it's inside Path TT or some other "special" zone
		array<entity> enterTrigArr = GetEntArrayByScriptName( "path_tt_ring_trig" )
		if ( enterTrigArr.len() == 1 )
		{
			if ( enterTrigArr[ 0 ].ContainsPoint( pos ) )
				return false
		}
	#endif

	return true
}