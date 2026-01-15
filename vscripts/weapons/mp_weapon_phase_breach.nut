global function MpWeaponPhaseBreach_Init
global function OnWeaponActivate_weapon_phase_breach
global function OnWeaponDeactivate_weapon_phase_breach
global function OnWeaponPrimaryAttack_ability_phase_breach
global function OnWeaponPrimaryAttackAnimEvent_ability_phase_breach
global function OnWeaponAttemptOffhandSwitch_weapon_phase_breach
#if SERVER && DEV
global function DEV_PhaseBreach_DestroyAll
#endif
#if CLIENT
global function ServerToClient_PhaseBreachPortalCancelled

    global function ServerToClient_NotifyAshCooldownReduction


#if DEV
global function DEV_ClearTargetingData
global function DEV_ToggleAshValidation
#endif
#endif

const string SOUND_PORTAL_ENTRANCE_OPEN_1P = "Ash_PhaseBreach_Activate_1p"
const string SOUND_PORTAL_ENTRANCE_OPEN_3P = "Ash_PhaseBreach_Activate_3p"
const string SOUND_PORTAL_EXIT_OPEN = "Ash_PhaseBreach_PortalOpen_Exit_3p"
const string SOUND_PORTAL_LOOP = "Ash_PhaseBreach_Portal_Loop" // Play (to everyone) when second gate is created and gates connect.  Should play on each gate.  Stop when gates expire.
const string SOUND_PORTAL_CLOSE = "Ash_PhaseBreach_Portal_Expire" // Play (to everyone) when gates expire.  Should play on each gate.

const string SIGNAL_PHASE_BREACH_STOP_PLACEMENT = "PhaseBreach_StopPlacement"

const string FUNCNAME_ENEMY_BREACHED_NEARBY = "PhaseBreach_EnemyBreachedNearby"

const string ABILITY_USED_MOD = "ability_used_mod"

const vector BREACH_OFFSET = <0, 0, 42>
const vector BREACH_HULLCHECK_MINS   = <-5.0, -5.0, 36.0 - 5.0>
const vector BREACH_HULLCHECK_MAXS   = < 5.0,  5.0, 36.0 + 5.0>

const float PHASE_BREACH_SPEED = 1200.0
const float PHASE_BREACH_TRAVEL_TIME_MIN = 0.3


const float PHASE_BREACH_TRAVEL_TIME_MAX_UPGRADED = 1.4

const float PHASE_BREACH_PORTAL_LIFETIME = 15.0




const float PHASE_BREACH_TRAVEL_TIME_MAX = 1.8
const float PHASE_BREACH_MAX_2D_DIST_DEFAULT = 3000.0

const float PHASE_BREACH_MAX_ANGLE_FOR_FULL_DIST_DEFAULT = 45.0
const bool  PHASE_BREACH_ALLOW_START_ON_MOVERS_DEFAULT = true
const bool  PHASE_BREACH_ALLOW_END_ON_MOVERS_DEFAULT = true
const float PHASE_BREACH_MOVERS_MAX_SPEED_FOR_END_DEFAULT = 12.0

const bool  PHASE_BREACH_ALLOW_END_ON_OOB = false



const float PHASE_BREACH_MIN_VIEW_DOT = deg_cos(15.0)

const bool DEBUG_DRAW_TARGETING = false
const bool DEBUG_DRAW_PLACEMENT_TRACES = false
const bool DEBUG_DRAW_ENDING_SCORES    = false
const bool DEBUG_DRAW_PUSHER_MOVEMENT  = false

bool DEV_DO_VALIDATION = true
const bool LOG_VALIDATION_DATA = true
const bool DEBUG_DRAW_VALIDATION = false

const asset BREACH_TARGET_FX = $"P_ar_ping_squad_CP_altZ"
const asset BREACH_STARTPOINT_FX = $"P_ash_breach_start"
const asset BREACH_ENDPOINT_FX = $"P_ash_breach_end"
const asset BREACH_AIM_FX = $"P_wrp_trl_end"

const asset BREACH_FX_AR_DIR = $"P_ar_ping_wall_dir_CP"
const asset BREACH_FX_AR_INVALID = $"P_mm_breach_arc_end_fail"
const asset BREACH_RANGE_FX = $"P_ar_zipline_range"

const string FUNC_BREACH_FAILED = "ServerToClient_PhaseBreachPortalCancelled"
const string PLACEMENT_FAILED_HINT = "#PHASE_BREACH_CANT_PLACE"
global const string PHASE_BREACH_BLOCKER_SCRIPTNAME = "phase_breach_blocker"


struct PhaseBreachTargetInfo
{
	array<vector> posList
	vector        finalPos
	float         pathDistance

	vector        startPos
	bool 		  startCrouched
	bool 		  startBlocked

	vector		eyeTracePos
	vector		eyeTraceNormal

	float         portalQuality
}

struct PhaseBreachTraceResults
{
	TraceResults& results
	vector        adjustedEndPos
	bool          foundValidEnd
}

struct
{
	table<entity, PhaseTunnelPortalData>          triggerStartpoint
	table<entity, PhaseBreachTargetInfo>          portalTargetTable
	table<entity, PhaseTunnelData>                tunnelData

	#if SERVER
		table<entity, bool>						  didOwnerStartTunneling
		bool 									  doAnnouncePing
	#elseif CLIENT
		int		targetingFxHandle
		int    	targetingFxHandleDir
		int    	targetingInvalidFxHandle
		string targetingHint
	#endif

	float maxDist
	float maxAngleForFullDist
	float maxEndingMoverSpeedSqr
	bool allowStartOnMovers
	bool allowEndOnMovers
	array<string> invalidTriggerEndingTypes = ["trigger_slip"]

	bool breachPersistsWhenAshDies

	#if DEV
		int numTargetingRuns
		int newTargetingHits
		int oldTargetingHits

		table<int, string> newTargetingWins
		table<int, string> oldTargetingWins
		table<int, string> oldTargetingBetter

		float newAvgScore
		float oldAvgScore


	#endif
} file

void function MpWeaponPhaseBreach_Init()
{
	PrecacheParticleSystem( BREACH_ENDPOINT_FX )
	PrecacheParticleSystem( BREACH_TARGET_FX )
	PrecacheParticleSystem( BREACH_AIM_FX )
	PrecacheParticleSystem( BREACH_STARTPOINT_FX )
	PrecacheParticleSystem( BREACH_FX_AR_DIR )
	PrecacheParticleSystem( BREACH_FX_AR_INVALID )
	PrecacheParticleSystem( BREACH_RANGE_FX )

	RegisterSignal( SIGNAL_PHASE_BREACH_STOP_PLACEMENT )

	file.maxDist = GetCurrentPlaylistVarFloat( "ash_phase_breach_max_2d_dist", PHASE_BREACH_MAX_2D_DIST_DEFAULT )
	file.maxAngleForFullDist = GetCurrentPlaylistVarFloat( "ash_phase_breach_max_angle_for_full_dist", PHASE_BREACH_MAX_ANGLE_FOR_FULL_DIST_DEFAULT )
	file.maxEndingMoverSpeedSqr = pow( GetCurrentPlaylistVarFloat( "ash_phase_breach_max_mover_speed", PHASE_BREACH_MOVERS_MAX_SPEED_FOR_END_DEFAULT ), 2.0)
	file.allowStartOnMovers = GetCurrentPlaylistVarBool( "ash_phase_breach_allow_start_on_movers", PHASE_BREACH_ALLOW_START_ON_MOVERS_DEFAULT )
	file.allowEndOnMovers = GetCurrentPlaylistVarBool( "ash_phase_breach_allow_end_on_movers", PHASE_BREACH_ALLOW_END_ON_MOVERS_DEFAULT )
	#if SERVER
		file.doAnnouncePing = GetCurrentPlaylistVarBool( "ash_phase_breach_do_announce_ping", true )
	#endif

	if ( PHASE_BREACH_ALLOW_END_ON_OOB == false )
	{
		file.invalidTriggerEndingTypes.append( "trigger_out_of_bounds" )
		file.invalidTriggerEndingTypes.append( "trigger_networked_out_of_bounds" )
	}

	Remote_RegisterClientFunction( FUNC_BREACH_FAILED )

		Remote_RegisterClientFunction( "ServerToClient_NotifyAshCooldownReduction" )

	file.breachPersistsWhenAshDies = GetCurrentPlaylistVarBool( "ash_ult_persists_past_ash_death", true )
}


float function GetUpgradedMaxPhaseTravelTime()
{
	return GetCurrentPlaylistVarFloat( "ash_upgraded_max_phase_travel_time", PHASE_BREACH_TRAVEL_TIME_MAX_UPGRADED )
}

float function GetMaxPhaseTravelTime( entity player )
{
	float result = PHASE_BREACH_TRAVEL_TIME_MAX

	return result
}


void function OnWeaponActivate_weapon_phase_breach( entity weapon )
{
	bool serverOrPredicted = IsServer() || (InPrediction() && IsFirstTimePredicted())
	if ( serverOrPredicted )
	{
		weapon.RemoveMod( ABILITY_USED_MOD )
	}

	#if CLIENT
		entity player = weapon.GetWeaponOwner()
		if ( player == GetLocalViewPlayer() )
			thread PhaseBreachPlacement_Thread( weapon )
	#endif

	#if SERVER
	thread PhaseBreachCrosshair_Thread( weapon )
	#endif
}


void function OnWeaponDeactivate_weapon_phase_breach( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	if ( player in file.portalTargetTable )
		delete file.portalTargetTable[player]

	#if SERVER
		if ( player in file.didOwnerStartTunneling )
		{
			if ( !file.didOwnerStartTunneling[ player ] )
				weapon.SetWeaponPrimaryClipCount( minint(weapon.GetWeaponPrimaryClipCount() + weapon.GetAmmoPerShot(), weapon.GetWeaponPrimaryClipCountMax() ) )

			delete file.didOwnerStartTunneling[ player ]
		}
	#elseif CLIENT
		if ( player == GetLocalViewPlayer() )
			weapon.Signal( SIGNAL_PHASE_BREACH_STOP_PLACEMENT )
	#endif
}


bool function OnWeaponAttemptOffhandSwitch_weapon_phase_breach( entity weapon )
{
	return true
}


var function OnWeaponPrimaryAttack_ability_phase_breach( entity weapon, WeaponPrimaryAttackParams params )
{
	entity player = weapon.GetWeaponOwner()

	if ( !IsValid( player ) || player.IsPhaseShifted() )
		return 0

	PhaseBreachTargetInfo info = GetPhaseBreachTargetInfo( player )

	if ( info.portalQuality <= 0 )
		return 0

	file.portalTargetTable[player] <- info

	StatusEffect_AddTimed( player, eStatusEffect.move_slow, 0.5, 0.5, 0.0 )

	#if SERVER
		PlayBattleChatterLineToSpeakerAndTeam( player, "bc_super" )
		file.didOwnerStartTunneling[player] <- false
	#endif

	return weapon.GetAmmoPerShot()
}


var function OnWeaponPrimaryAttackAnimEvent_ability_phase_breach( entity weapon, WeaponPrimaryAttackParams params )
{
	entity player = weapon.GetWeaponOwner()

	if ( !IsValid( player ) || !(player in file.portalTargetTable) )
		return 0

	if ( player.IsPhaseShifted() )
	{
		delete file.portalTargetTable[player]
		return 0
	}

	bool serverOrPredicted = IsServer() || (InPrediction() && IsFirstTimePredicted())
	if ( serverOrPredicted )
	{
		weapon.AddMod( ABILITY_USED_MOD )
	}

	PhaseBreachTargetInfo info = file.portalTargetTable[player]

	PlayerUsedOffhand( player, weapon, false )
	#if SERVER
		PIN_PlayerAbility( player, weapon.GetWeaponClassName(), ABILITY_TYPE.ULTIMATE, null, {tunnel_start = player.GetOrigin(), tunnel_end = info.finalPos} )
	#endif

	#if SERVER
		file.didOwnerStartTunneling[ player ] <- true

		vector angles = VectorToAngles( info.finalPos - player.GetOrigin() )
		angles = <0, angles.y, 0>

		PhaseTunnelPathData data

		foreach ( pos in info.posList )
		{
			PhaseTunnelPathNodeData p
			p.origin = pos
			p.angles = angles

			data.pathNodes.insert( 0, p )
		}

		data.pathNodes[ data.pathNodes.len() - 1 ].wasCrouched = info.startCrouched
		data.pathDistance = info.pathDistance

			PhaseTunnel_CleanAndFinalizePath( data, PHASE_BREACH_SPEED, PHASE_BREACH_TRAVEL_TIME_MIN, GetMaxPhaseTravelTime( player ), true )

		thread MoveEntAndCreateTunnel( player, data, info.finalPos )
	#endif

	#if CLIENT
		if ( player == GetLocalViewPlayer() )
			weapon.Signal( SIGNAL_PHASE_BREACH_STOP_PLACEMENT )
	#endif

	return 0
}

#if SERVER
void function MoveEntAndCreateTunnel( entity player, PhaseTunnelPathData data, vector endpoint )
{
	const int THREAT_INDICATOR_RADIUS = 1200
	const float THREAT_INDIATOR_DURATION = 2.0

	if ( !file.breachPersistsWhenAshDies )
	{
		player.EndSignal( "OnDeath" )
	}

	player.EndSignal( "PlayerChangedClass" )

	entity endpointFxEnt = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( BREACH_ENDPOINT_FX ), endpoint + BREACH_OFFSET, data.pathNodes[0].angles + <0, 90, -90> )
	endpointFxEnt.RemoveFromAllRealms()
	endpointFxEnt.AddToOtherEntitysRealms( player )

	entity threatIndicator = CreateThreatIndicator( endpoint, eThreatIndicatorID.GRENADE_INDICATOR_GENERIC, THREAT_INDICATOR_RADIUS, <0,0,0>, eThreatIndicatorVisibility.INDICATOR_SHOW_TO_ENEMIES, player )
	threatIndicator.RemoveFromAllRealms()
	threatIndicator.AddToOtherEntitysRealms( player )

	thread DestroyAfterDelay( threatIndicator, THREAT_INDIATOR_DURATION )

	entity traceBlocker = CreateTraceBlockerVolume( endpoint + BREACH_OFFSET, 24.0, false, CONTENTS_BLOCK_PING, player.GetTeam(), PHASE_BREACH_BLOCKER_SCRIPTNAME )
	traceBlocker.RemoveFromAllRealms()
	traceBlocker.AddToOtherEntitysRealms( player )
	traceBlocker.SetTouchTriggers( true )
	traceBlocker.SetOwner( player )


	//VoidVisionSetExitEnt( data, traceBlocker )


	EmitSoundAtPositionExceptToPlayer( TEAM_ANY, endpoint, player, SOUND_PORTAL_EXIT_OPEN )

	PhaseTunnelPortalData startPortal = PhaseBreach_CreatePortalData( data )
	startPortal.portalFX.RemoveFromAllRealms()
	startPortal.portalFX.AddToOtherEntitysRealms( player )

	PhaseTunnelData tunnelData
	tunnelData.startPortal = startPortal
	tunnelData.shiftStyle  = eShiftStyle.PHASETYPE_BREACH
	tunnelData.tunnelEnt = CreatePropScript( $"mdl/dev/empty_model.rmdl", tunnelData.startPortal.startOrigin )

	PhaseTunnelTravelState travelState
	travelState.shiftStyle               = eShiftStyle.PHASETYPE_BREACH
	travelState.holsterRemoveDelay       = 0.4
	travelState.endSeekCheckOverrideFunc = PhaseBreach_PathNodeCheck

	OnThreadEnd(
		function() : ( endpointFxEnt, traceBlocker, tunnelData, threatIndicator )
		{
			if ( IsValid( tunnelData.startPortal.portalFX ) )
				EffectStop( tunnelData.startPortal.portalFX )

			if ( IsValid( endpointFxEnt ) )
				EffectStop( endpointFxEnt )

			if ( IsValid( traceBlocker ) )
				traceBlocker.Destroy()

			if( IsValid( threatIndicator ) )
				threatIndicator.Destroy()
		}
	)

	thread PhaseBreach_PhaseEntity( player, tunnelData.tunnelEnt, tunnelData, startPortal, travelState )

	float portalOpenTime = Time() + 0.29	// Not quite 0.3 to account for floating point issues
	while( Time() < portalOpenTime )
	{
		WaitFrame()

		if ( !IsValid( player ) )
			return

		if ( !PhaseTunnel_IsPortalExitPointValid( player, endpoint, player, true, false, DEBUG_DRAW_PLACEMENT_TRACES ) )
		{
			Signal( player, "PhaseTunnel_CancelPhaseTunnelUse" )
			entity weapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
			if ( IsValid( weapon ) && weapon.GetWeaponClassName() == "mp_weapon_phase_breach" )
			{
				Weapon_AddSingleCharge( weapon )
			}

			if ( player.IsPhaseShifted() )
				CancelPhaseShift( player )

			EmitSoundOnEntityOnlyToPlayer( player, player, "survival_ui_ability_notready" )
			Remote_CallFunction_NonReplay( player, FUNC_BREACH_FAILED )

			return
		}
	}

	//TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_ASH_PORTAL_ENTER, player, player.GetOrigin(), player.GetTeam(), player )
	//TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_ASH_PORTAL_EXIT, player, endpoint, player.GetTeam(), player )

	waitthread CreateTunnelAndWaitForExpiration( player, tunnelData )
}


bool function UpdateAshAbilityCooldowns( entity player )
{
	// refresh Tactical
	entity tacWeapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )
	if( !IsValid( tacWeapon ) )
		return false
	int ammo = tacWeapon.GetWeaponPrimaryClipCount()
	int ammoReq = tacWeapon.GetAmmoPerShot()
	int ammoMax = tacWeapon.GetWeaponPrimaryClipCountMax()
	tacWeapon.SetWeaponPrimaryClipCount( minint( ammo + ammoReq, ammoMax ) )

	// reduce Ultimate cooldown
	entity ultWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
	if( !IsValid( ultWeapon ) )
		return false

	bool reducedCooldown = true

	if ( ultWeapon.HasMod( "cooldown_reduction_1" ) )
	{
		ultWeapon.RemoveMod( "cooldown_reduction_1" )
		ultWeapon.AddMod( "cooldown_reduction_2" )
	}
	else if ( ultWeapon.HasMod( "cooldown_reduction_2" ) )
	{
		ultWeapon.RemoveMod( "cooldown_reduction_2" )
		ultWeapon.AddMod( "cooldown_reduction_3" )
	}
	else if ( ultWeapon.HasMod( "cooldown_reduction_3" ) )
	{
		ultWeapon.RemoveMod( "cooldown_reduction_3" )
		ultWeapon.AddMod( "cooldown_reduction_4" )
	}
	else if ( ultWeapon.HasMod( "cooldown_reduction_4" ) )
	{
		ultWeapon.RemoveMod( "cooldown_reduction_4" )
		ultWeapon.AddMod( "cooldown_reduction_5" )
	}
	else if ( ultWeapon.HasMod( "cooldown_reduction_5" ) )
	{
		ultWeapon.RemoveMod( "cooldown_reduction_5" )
		ultWeapon.AddMod( "cooldown_reduction_6" )
	}
	else if ( ultWeapon.HasMod( "cooldown_reduction_6" ) )
	{
		reducedCooldown = false
	}
	else
	{
		ultWeapon.AddMod( "cooldown_reduction_1" )
	}

	if( reducedCooldown )
		thread UpdateAshAbilityCooldowns_Thread( player )

	return true
}

void function UpdateAshAbilityCooldowns_Thread( entity player )
{
	player.EndSignal( "OnDestroy" )

	// for some reason this notication doesn't display if you do it the frame we're entering phase.
	// so wait until the player is out of phase to display it (which might be the better time anyways since their screen isn't blue)
	WaitFrame()
	while( player.IsPhaseShiftedOrPending() )
	{
		WaitFrame()
	}
	Remote_CallFunction_NonReplay( player, "ServerToClient_NotifyAshCooldownReduction" )
}

#endif

#if CLIENT
void function ServerToClient_PhaseBreachPortalCancelled()
{
	entity localPlayer = GetLocalViewPlayer()
	if ( !IsValid( localPlayer ) )
		return

	AddPlayerHint( 3.0, 0.5, $"", "Phase Breach Failed" )

	StopSoundOnEntity( localPlayer, "Ash_PhaseBreach_Enter_1p" )
}


void function ServerToClient_NotifyAshCooldownReduction()
{
	entity localViewPlayer = GetLocalViewPlayer()
	if ( IsValid( localViewPlayer ) && PlayerHasPassive( localViewPlayer, ePassives.PAS_ULT_UPGRADE_TWO ) )
	{
		string hintStr = "#PHASE_BREACH_COOLDOWN_REDUCED"
		AddPlayerHint( 2.5, 0.25, $"rui/hud/ultimate_icons/ultimate_ash", hintStr )
	}
}

#endif

#if SERVER
PhaseTunnelPortalData function PhaseBreach_CreatePortalData( PhaseTunnelPathData pathData )
{
	int pathLength                        = pathData.pathNodes.len()
	PhaseTunnelPathNodeData startingPoint = pathData.pathNodes[ pathLength - 1 ]
	PhaseTunnelPathNodeData endingPoint   = pathData.pathNodes[ 0 ]

	asset portalFX = BREACH_STARTPOINT_FX


	int fxid = GetParticleSystemIndex( portalFX )
	PhaseTunnelPortalData portalData
	portalData.startOrigin  = startingPoint.origin
	portalData.startAngles  = startingPoint.angles
	portalData.endOrigin    = endingPoint.origin
	portalData.endAngles    = endingPoint.angles
	portalData.crouchPortal = startingPoint.wasCrouched
	portalData.portalFX     = StartParticleEffectInWorld_ReturnEntity( fxid, startingPoint.origin + BREACH_OFFSET, startingPoint.angles )

	//TO DO: READ START AND END POSITION OUT OF THE PATH DATA.
	portalData.pathData = pathData

	return portalData
}

void function DEV_DestroyAllPortals()
{
	foreach ( ent, portal in file.tunnelData )
	{
		Signal( portal.tunnelEnt, "PhaseTunnel_DestroyTunnel" )
	}
}

void function CreateTunnelAndWaitForExpiration( entity player, PhaseTunnelData tunnelData )
{
	int team         = player.GetTeam()
	entity tunnelEnt = tunnelData.tunnelEnt

	player.EndSignal( "PlayerChangedClass" )
	tunnelEnt.EndSignal( "OnDeath" )

	tunnelData.tunnelEnt = tunnelEnt
	file.tunnelData[ tunnelEnt ] <- tunnelData

	entity wpStart
	//if ( file.doAnnouncePing )
		//wpStart = CreateWaypoint_Ping_Location( player, ePingType.OPENED_PHASE_BREACH, null, tunnelData.startPortal.startOrigin, -1, true )

	OnThreadEnd(
		function() : ( tunnelData, tunnelEnt, wpStart )
		{
			if ( IsValid( tunnelEnt ) )
			{
				if ( tunnelEnt in file.tunnelData )
					delete file.tunnelData[ tunnelEnt ]

				tunnelEnt.Destroy()
			}

			if ( IsValid( wpStart ) )
				wpStart.Destroy()
		}
	)

	tunnelEnt.RemoveFromAllRealms()
	tunnelEnt.AddToOtherEntitysRealms( player )
	tunnelEnt.DisableHibernation()
	SetTeam( tunnelEnt, team )
	tunnelEnt.SetOwner( player )
	thread PhaseTunnel_CreateTriggerArea( tunnelEnt, tunnelData.startPortal )

	waitthread PhaseTunnel_WaitForPhaseTunnelExpiration( player, tunnelData, PHASE_BREACH_PORTAL_LIFETIME )
}

#if DEV
void function DEV_PhaseBreach_DestroyAll()
{
	foreach ( ent, portal in file.tunnelData )
	{
		Signal( portal.tunnelEnt, "PhaseTunnel_DestroyTunnel" )
	}
}
#endif

void function PhaseTunnel_CreateTriggerArea( entity tunnelEnt, PhaseTunnelPortalData startPointData )
{
	Assert ( IsNewThread(), "Must be threaded off" )
	tunnelEnt.EndSignal( "OnDestroy" )
	startPointData.portalFX.EndSignal( "OnDestroy" )

	vector origin       = startPointData.portalFX.GetOrigin()
	vector angles       = startPointData.portalFX.GetAngles()
	float triggerHeight = startPointData.crouchPortal ? PHASE_TUNNEL_TRIGGER_HEIGHT_CROUCH : PHASE_TUNNEL_TRIGGER_HEIGHT

	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.RemoveFromAllRealms()
	trigger.AddToOtherEntitysRealms( tunnelEnt )
	trigger.SetOwner( tunnelEnt )
	trigger.SetRadius( PHASE_TUNNEL_TRIGGER_RADIUS )
	trigger.SetAboveHeight( triggerHeight )
	trigger.SetBelowHeight( triggerHeight )
	trigger.SetOrigin( origin )
	trigger.SetAngles( <0, 0, 0> )
	trigger.kv.triggerFilterPhaseShift   = "nonphaseshift"
	trigger.kv.triggerFilterNonCharacter = "0"
	DispatchSpawn( trigger )

	file.triggerStartpoint[ trigger ]    <- startPointData
	trigger.SetEnterCallback( OnPhaseBreachTriggerEnter )

	trigger.SetOrigin( origin )
	trigger.SetAngles( <0, 0, 0> )

	entity portalMarker = CreatePropScript( $"mdl/dev/empty_model.rmdl", origin, angles + <0, -90, -90> )
	portalMarker.SetScriptName( "portal_marker" )
	portalMarker.DisableHibernation()
	portalMarker.RemoveFromAllRealms()
	portalMarker.AddToOtherEntitysRealms( tunnelEnt )

	entity traceBlocker = CreateTraceBlockerVolume( origin, 24.0, false, CONTENTS_BLOCK_PING, tunnelEnt.GetTeam(), PHASE_BREACH_BLOCKER_SCRIPTNAME )
	traceBlocker.RemoveFromAllRealms()
	traceBlocker.AddToOtherEntitysRealms( tunnelEnt )
	traceBlocker.SetTouchTriggers( true )
	traceBlocker.SetOwner( tunnelEnt )

	EmitDifferentSoundsAtPositionForPlayerAndWorld( SOUND_PORTAL_ENTRANCE_OPEN_1P, SOUND_PORTAL_ENTRANCE_OPEN_3P, origin, tunnelEnt.GetOwner(), TEAM_ANY )
	EmitSoundOnEntity( portalMarker, SOUND_PORTAL_LOOP )

	OnThreadEnd(
		function() : ( trigger, portalMarker, traceBlocker )
		{
			if ( IsValid( trigger ) )
			{
				delete file.triggerStartpoint[ trigger ]
				trigger.Destroy()
			}

			if ( IsValid( portalMarker ) )
			{
				StopSoundOnEntity( portalMarker, SOUND_PORTAL_LOOP )
				EmitSoundAtPosition( TEAM_UNASSIGNED, portalMarker.GetOrigin(), SOUND_PORTAL_CLOSE, trigger )
				portalMarker.Destroy()
			}

			if ( IsValid( traceBlocker ) )
				traceBlocker.Destroy()
		} )

	WaitForever()
}


void function OnPhaseBreachTriggerEnter( entity trigger, entity ent )
{
	if ( PhaseTunnel_ShouldPhaseEnt( ent ) )
		OnPhaseTunnelTriggerEnter_Internal( trigger, ent )
}

void function OnPhaseTunnelTriggerEnter_Internal( entity trigger, entity player )
{
	entity tunnelEnt = trigger.GetOwner()

	if ( !(tunnelEnt in file.tunnelData) || !(trigger in file.triggerStartpoint) )
		return

	PhaseTunnelTravelState travelState	// Intentionally leaving out the holster time
	travelState.shiftStyle               = eShiftStyle.PHASETYPE_BREACH
	travelState.endSeekCheckOverrideFunc = PhaseBreach_PathNodeCheck
	thread PhaseBreach_PhaseEntity( player, tunnelEnt, file.tunnelData[ tunnelEnt ], file.triggerStartpoint[ trigger ], travelState )
}

void function PhaseBreach_PhaseEntity( entity ent, entity tunnelEnt, PhaseTunnelData tunnelData, PhaseTunnelPortalData portalData, PhaseTunnelTravelState travelState )
{

	if ( GetCurrentPlaylistVarBool( "ash_void_vision_enabled", true ) )
	{
		ent.EndSignal( "OnDestroy", "OnDeath" )

		//VoidVision_GrantVoidVision( ent )

		OnThreadEnd(
			function() : ( ent )
			{
				//VoidVision_TakeVoidVision( ent )
			} )
	}


	waitthread PhaseTunnel_PhaseEntity( ent, tunnelEnt, tunnelData, portalData, travelState )
}

int function PhaseBreach_PathNodeCheck( entity player, array<PhaseTunnelPathNodeData> pathNodes, int index, int nextIndex )
{
	// Check the final portal pos - if it's clear, we're happy
	TraceResults endResults = TraceHull( pathNodes[0].origin, pathNodes[0].origin + <0, 0, 1>, player.GetPlayerMins(), player.GetPlayerMaxs(), GetPlayerArray_Alive(), TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_NONE )
	if ( !endResults.startSolid )
		return 0

	// If the portal is blocked, see if we're blocked from our current pos to the next pos (using the smaller hull for breaching)
	TraceResults nextResults = TraceHull( pathNodes[index].origin, pathNodes[nextIndex].origin, BREACH_HULLCHECK_MINS, BREACH_HULLCHECK_MAXS, GetPlayerArray_Alive(), TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
	if ( nextResults.fraction == 1.0 )
		return nextIndex

	return index
}
#endif

const float DOWN_TRACE_DISTANCE = 1000.0
const float BACK_TRACE_STEP_DIST = 50.0
const float BACK_TRACE_MAX_STEP = 200.0
const float TUNNEL_STEP_DIST = 16.0

PhaseBreachTargetInfo function GetPhaseBreachTargetInfo( entity player )
{
	PhaseBreachTargetInfo info
	info.startPos   = player.GetOrigin()
	info.finalPos   = player.GetOrigin()
	info.startCrouched = player.IsCrouched()
	info.eyeTracePos = ZERO_VECTOR
	info.eyeTraceNormal = ZERO_VECTOR

	vector eyePos = player.EyePosition()
	vector eyeDir = player.GetViewVector()
	eyeDir          = Normalize( eyeDir )

	vector mins = player.GetPlayerMins()
	vector maxs = player.GetPlayerMaxs()

	// See if we're on a pusher and we're not allowed to be
	if ( !file.allowStartOnMovers )
	{
		entity groundEnt = player.GetGroundEntity()
		if ( IsValid( groundEnt ) && LengthSqr( groundEnt.GetVelocity() ) > file.maxEndingMoverSpeedSqr )
			return info
	}

	// Make sure the portal entrance position will be valid (otherwise the portal will instantly die)
	// These parameters should match the checks in PhaseTunnel_WaitForPhaseTunnelExpiration
	if ( ! PhaseTunnel_IsPortalExitPointValid( player, info.startPos, player, true, info.startCrouched ) )//,DEBUG_DRAW_TARGETING ) )
	{
		info.startBlocked = true
		return info
	}

	float rangeNormal = file.maxDist
	float rangeSqr    = rangeNormal * rangeNormal

	// Calculate effective range
	float pitchClamped   = clamp( player.EyeAngles().x, -file.maxAngleForFullDist, file.maxAngleForFullDist )
	float rangeEffective = rangeNormal / deg_cos( pitchClamped )

	array<entity> ignoredEnts = [ player ]

	//////////////////////////////////////////////////////////////
	// Step 1: Basic eye trace looking forward for solid ground
	PhaseBreachTraceResults eyeTrace = DoEyeTrace( eyePos, eyeDir, rangeEffective, ignoredEnts, mins, maxs )

	#if DEV
	if ( DEBUG_DRAW_TARGETING )
	{
		vector debugColor = eyeTrace.results.fraction < 1.0 ? COLOR_GREEN : COLOR_RED
		DebugDrawSphere(  eyeTrace.results.endPos, 10,debugColor, false,0.1 )

		vector adjustedColor = eyeTrace.foundValidEnd ? COLOR_GREEN : COLOR_ORANGE
		DebugDrawSphere(  eyeTrace.adjustedEndPos,5, adjustedColor, false,0.1 )

		float distMeters = Distance( eyeTrace.results.endPos, player.GetOrigin() ) * INCHES_TO_METERS
		string text = "Ash Ult: " +
						"\nRange " + distMeters + "/" + (file.maxDist*INCHES_TO_METERS) +
						"\nEffective: " + (rangeEffective*INCHES_TO_METERS)
		DebugDrawScreenText( 0.1, 0.6, text )
	}
	#endif

	info.eyeTracePos = eyeTrace.results.endPos
	info.eyeTraceNormal = eyeTrace.results.surfaceNormal
	// If we hit something and this is valid (solid ground, space avail, etc. ) then stop here
	if ( eyeTrace.foundValidEnd && IsBreachPositionValid( player, eyeTrace.adjustedEndPos, eyeTrace.results.hitEnt, eyeDir, eyeTrace.results.surfaceNormal ) )
	{
		bool success = GenerateBreachPathInfo( player, info, eyeTrace.adjustedEndPos )

		if ( success )
		{
			info.portalQuality = FLT_MAX
			return info
		}
	}

	if ( eyeTrace.results.fraction >= 1.0 )
	{
		vector lowerEyeDir = VectorRotateAxis( eyeDir, player.GetRightVector(), -1 )
		PhaseBreachTraceResults lowerEyeTrace = DoEyeTrace( eyePos, lowerEyeDir, rangeEffective, ignoredEnts, mins, maxs )
		#if DEV
			if ( DEBUG_DRAW_TARGETING )
			{
				DebugDrawText( eyeTrace.results.endPos, "Lower", false, 0.1 )
				vector debugColor = eyeTrace.results.fraction < 1.0 ? COLOR_GREEN : COLOR_RED
				DebugDrawSphere(  eyeTrace.results.endPos, 10,debugColor, false,0.1 )

				vector adjustedColor = eyeTrace.foundValidEnd ? COLOR_GREEN : COLOR_ORANGE
				DebugDrawSphere(  eyeTrace.adjustedEndPos,5, adjustedColor, false,0.1 )
			}
		#endif
		if ( lowerEyeTrace.results.fraction < 1.0 )
			eyeTrace = lowerEyeTrace
	}

	info.eyeTracePos = eyeTrace.results.endPos
	info.eyeTraceNormal = eyeTrace.results.surfaceNormal

	//STEP 2: If we didnt hit something perfect on the first trace, lets look for other options and then pick based on score.
	array<vector> possibleEndings

	if ( eyeTrace.results.fraction < 1.0 )
	{
		PerfStart( PerfIndexClient.PhaseBreach_WallToTop )
		bool surfaceIsWall = !IsNormalVertical( eyeTrace.results.surfaceNormal )

		if ( surfaceIsWall )
		{
			vector flattenedEyeDir = FlattenNormalizeVec( eyeDir )

			const float LEDGE_CHECK_UP = DOWN_TRACE_DISTANCE/2
			const float LEDGE_CHECK_BACK = 24//1 * METERS_TO_INCHES
			float debugDrawTime      = DEBUG_DRAW_TARGETING ? 0.1 : 0.0

			vector wallTraceMaxs = <maxs.x,maxs.y,PHASE_TUNNEL_CROUCH_HEIGHT>
			vector wallToTopNormal = -flattenedEyeDir

			float eyeVsWallDot = DotProduct( eyeTrace.results.surfaceNormal, -flattenedEyeDir )
			if ( eyeVsWallDot < 0.707106781187 )
				wallToTopNormal = eyeTrace.results.surfaceNormal

			WallToTopResults results
			float checkUpDistance = LEDGE_CHECK_UP
			while( !results.found && checkUpDistance > 0)
			{
				results = TraceFromWallToTop( eyeTrace.results.endPos, wallToTopNormal, [ player ], LEDGE_CHECK_BACK, checkUpDistance, TRACE_MASK_PLAYERSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER, debugDrawTime, true, mins, wallTraceMaxs )
				//results = TraceFromWallToTop( eyeTrace.results.endPos, wallToTopNormal, [ player ], LEDGE_CHECK_BACK, checkUpDistance, TRACE_MASK_PLAYERSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_PLAYER, debugDrawTime )
				checkUpDistance -= PHASE_TUNNEL_CROUCH_HEIGHT
			}

			//////////////////
			//WallToTopResults results = TraceFromWallToTop( eyeTrace.results.endPos, -flattenedEyeDir, [ player ], LEDGE_CHECK_BACK, LEDGE_CHECK_UP/2, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER, debugDrawTime, true, mins, wallTraceMaxs )
			//if ( !results.found )
			//{
			//	results = TraceFromWallToTop( eyeTrace.results.endPos, -flattenedEyeDir, [ player ], LEDGE_CHECK_BACK, LEDGE_CHECK_UP, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER, debugDrawTime, true, mins, wallTraceMaxs )
			//}
			//////////////////

			if ( results.found && IsBreachPositionValid( player, results.pos, results.hitEnt, eyeDir, results.normal ) )
			{
				possibleEndings.append( results.pos )
			}
		}
		PerfEnd( PerfIndexClient.PhaseBreach_WallToTop )
	}

	// Trace down looking for a ground hit
	{
		TraceResults downTrace = TraceHull( eyeTrace.adjustedEndPos, eyeTrace.adjustedEndPos - <0.0, 0.0, DOWN_TRACE_DISTANCE>, <-5,-5,-5>, <5,5,5>, ignoredEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
		DrawDebugSphereIfDebugging( downTrace.endPos, 0, 255, 0 )

		if ( downTrace.fraction < 1.0 )
		{
			TraceResults hullTrace = DoHullTraceForExit( mins, maxs, downTrace.endPos )

			if ( !hullTrace.startSolid && IsBreachPositionValid( player, hullTrace.endPos, hullTrace.hitEnt != null ? hullTrace.hitEnt : downTrace.hitEnt, eyeDir, downTrace.surfaceNormal ) )
			{
				possibleEndings.append( hullTrace.endPos )
			}
		}
	}

	// Keep going backwards in the air then down to see if we can find a position in view
	{
		vector airPos      = eyeTrace.adjustedEndPos - eyeDir * BACK_TRACE_STEP_DIST
		float airTraceDist = BACK_TRACE_STEP_DIST
		int i              = 0

		while ( possibleEndings.len() < 10 && airTraceDist < (rangeEffective - 250.0) && (DotProduct( eyeTrace.adjustedEndPos - eyePos, airPos - eyePos ) > 0) )
		{
			TraceResults airDownTrace = TraceHull( airPos, airPos - <0.0, 0.0, DOWN_TRACE_DISTANCE>, <-5,-5,-5>, <5,5,5>, ignoredEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
			DrawDebugSphereIfDebugging( airPos, 0, 255, 255 )
			DrawDebugSphereIfDebugging( airDownTrace.endPos, 255, 0, 255 )
			if ( airDownTrace.fraction < 1.0 )
			{
				TraceResults hullTrace = DoHullTraceForExit( mins, maxs, airDownTrace.endPos )

				if ( !hullTrace.startSolid && IsBreachPositionValid( player, hullTrace.endPos, hullTrace.hitEnt != null ? hullTrace.hitEnt : airDownTrace.hitEnt, eyeDir, airDownTrace.surfaceNormal ) )
				{
					possibleEndings.append( hullTrace.endPos )
				}
				else if ( DEBUG_DRAW_TARGETING )
				{
					if ( hullTrace.startSolid )
						DebugDrawText( hullTrace.endPos, "HT startSolid", false, 0.1 )
					else
						DebugDrawText( hullTrace.endPos, "BreachPos Invalid", false, 0.1 )
				}

			}

			i++
			float nextStepDist = min( BACK_TRACE_STEP_DIST * i, BACK_TRACE_MAX_STEP )
			airTraceDist += nextStepDist
			airPos -= eyeDir * nextStepDist
		}
	}
	PerfStart( PerfIndexClient.PhaseBreach_ScorePos )
	PortalEndingSortStruct end = GetBestEnding( possibleEndings, player,eyeDir, eyePos, info )
	PerfEnd( PerfIndexClient.PhaseBreach_ScorePos )
	return info
}


PhaseBreachTargetInfo function GetPhaseBreachTargetInfo_OLD( entity player )
{
	PhaseBreachTargetInfo info
	info.startPos   = player.GetOrigin()
	info.finalPos   = player.GetOrigin()
	info.startCrouched = player.IsCrouched()

	vector eyePos = player.EyePosition()
	vector eyeDir = player.GetViewVector()
	eyeDir          = Normalize( eyeDir )

	vector mins = player.GetPlayerMins()
	vector maxs = player.GetPlayerMaxs()

	// See if we're on a pusher and we're not allowed to be
	if ( !file.allowStartOnMovers )
	{
		entity groundEnt = player.GetGroundEntity()
		if ( IsValid( groundEnt ) && LengthSqr( groundEnt.GetVelocity() ) > file.maxEndingMoverSpeedSqr )
			return info
	}

	// Make sure the portal entrance position will be valid (otherwise the portal will instantly die)
	// These parameters should match the checks in PhaseTunnel_WaitForPhaseTunnelExpiration
	if ( ! PhaseTunnel_IsPortalExitPointValid( player, info.startPos, player, true, info.startCrouched,DEBUG_DRAW_TARGETING ) )
	{
		info.startBlocked = true
		return info
	}

	float rangeNormal = file.maxDist
	float rangeSqr    = rangeNormal * rangeNormal

	// Calculate effective range
	float pitchClamped   = clamp( player.EyeAngles().x, -file.maxAngleForFullDist, file.maxAngleForFullDist )
	float rangeEffective = rangeNormal / deg_cos( pitchClamped )

	array<entity> ignoredEnts = [ player ]

	// Basic eye trace looking for solid ground
	PhaseBreachTraceResults eyeTrace = DoEyeTrace( eyePos, eyeDir, rangeEffective, ignoredEnts, mins, maxs )
	if ( eyeTrace.foundValidEnd && IsBreachPositionValid( player, eyeTrace.adjustedEndPos, eyeTrace.results.hitEnt, eyeDir, eyeTrace.results.surfaceNormal ) )
	{
		bool success = GenerateBreachPathInfo( player, info, eyeTrace.adjustedEndPos )

		if ( success )
		{
			info.portalQuality = FLT_MAX
			return info
		}
	}

	array<vector> possibleEndings

	// See if we hit a ledge - goes forward a bit to see if we can find a reasonable landing spot
	{
		if ( eyeTrace.results.fraction < 1.0 )
		{
			vector ledgeTraceEndPos     = eyeTrace.results.endPos + 32 * Normalize( <eyeDir.x, eyeDir.y, 0> ) - <0, 0, 24>
			vector aboveLedgeEndPos     = ledgeTraceEndPos + <0, 0, 60>

			// First make sure we can see a spot above the ledge
			TraceResults eyeToAboveLedgeTrace = TraceHull( eyePos,aboveLedgeEndPos, <-5,-5,-5>, <5,5,5>, ignoredEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
			if ( eyeToAboveLedgeTrace.fraction == 1.0 )
			{
				TraceResults ledgeDownTrace = TraceHull( aboveLedgeEndPos, ledgeTraceEndPos, <-5,-5,-5>, <5,5,5>, ignoredEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
				DrawDebugSphereIfDebugging( ledgeDownTrace.endPos, 150, 150, 0 )

				if ( ledgeDownTrace.fraction < 1.0 )
				{
					TraceResults hullTrace = DoHullTraceForExit( mins, maxs, ledgeDownTrace.endPos )

					if ( !hullTrace.startSolid && IsBreachPositionValid( player, hullTrace.endPos, hullTrace.hitEnt != null ? hullTrace.hitEnt : ledgeDownTrace.hitEnt, eyeDir, ledgeDownTrace.surfaceNormal ) )
					{
						possibleEndings.append( hullTrace.endPos )
						if ( DEBUG_DRAW_TARGETING )
							DebugDrawText(hullTrace.endPos, "Old1", false, 0.1 )
					}
				}
			}
		}
	}

	// Lower the eye angle and try another ledge trace, so we aren't just relying on the back traces to hit places below our eye line
	{
		PhaseBreachTraceResults lowerEyeTrace = DoEyeTrace( eyePos, VectorRotateAxis( eyeDir, player.GetRightVector(), -1 ), rangeEffective, ignoredEnts, player.GetPlayerMins(), player.GetPlayerMaxs() )

		if ( lowerEyeTrace.results.fraction < 1.0 )
		{
			vector ledgeTraceEndPos     = lowerEyeTrace.results.endPos + 24 * Normalize( <eyeDir.x, eyeDir.y, 0> ) - <0, 0, 24>
			vector aboveLedgeEndPos     = ledgeTraceEndPos + <0, 0, 60>

			// First make sure we can see a spot above the ledge
			TraceResults eyeToAboveLedgeTrace = TraceHull( eyePos,aboveLedgeEndPos, <-5,-5,-5>, <5,5,5>, ignoredEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
			if ( eyeToAboveLedgeTrace.fraction == 1.0 )
			{
				TraceResults ledgeDownTrace = TraceHull( ledgeTraceEndPos + <0, 0, 60>, ledgeTraceEndPos, <-5,-5,-5>, <5,5,5>,ignoredEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
				DrawDebugSphereIfDebugging( ledgeDownTrace.endPos, 150, 150, 0 )

				if ( ledgeDownTrace.fraction < 1.0 )
				{
					TraceResults hullTrace = DoHullTraceForExit( mins, maxs, ledgeDownTrace.endPos )

					if ( !hullTrace.startSolid && IsBreachPositionValid( player, hullTrace.endPos, hullTrace.hitEnt != null ? hullTrace.hitEnt : ledgeDownTrace.hitEnt, eyeDir, ledgeDownTrace.surfaceNormal ) )
					{
						possibleEndings.append( hullTrace.endPos )
						if ( DEBUG_DRAW_TARGETING )
							DebugDrawText(hullTrace.endPos, "Old2", false, 0.1 )
					}
				}
			}
		}
	}

	// Trace down looking for a ground hit
	{
		TraceResults downTrace = TraceHull( eyeTrace.adjustedEndPos, eyeTrace.adjustedEndPos - <0.0, 0.0, DOWN_TRACE_DISTANCE>, <-5,-5,-5>, <5,5,5>, ignoredEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
		DrawDebugSphereIfDebugging( downTrace.endPos, 0, 255, 0 )

		if ( downTrace.fraction < 1.0 )
		{
			TraceResults hullTrace = DoHullTraceForExit( mins, maxs, downTrace.endPos )

			if ( !hullTrace.startSolid && IsBreachPositionValid( player, hullTrace.endPos, hullTrace.hitEnt != null ? hullTrace.hitEnt : downTrace.hitEnt, eyeDir, downTrace.surfaceNormal ) )
			{
				possibleEndings.append( hullTrace.endPos )
				if ( DEBUG_DRAW_TARGETING )
					DebugDrawText(hullTrace.endPos, "Olddown1", false, 0.1 )
			}
		}
	}

	// Keep going backwards in the air then down to see if we can find a position in view
	{
		vector airPos      = eyeTrace.adjustedEndPos - eyeDir * BACK_TRACE_STEP_DIST
		float airTraceDist = BACK_TRACE_STEP_DIST
		int i              = 0
		while ( airTraceDist < (rangeEffective - 250.0) && (DotProduct( eyeTrace.adjustedEndPos - eyePos, airPos - eyePos ) > 0) )
		{
			TraceResults airDownTrace = TraceHull( airPos, airPos - <0.0, 0.0, DOWN_TRACE_DISTANCE>, <-5,-5,-5>, <5,5,5>, ignoredEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
			DrawDebugSphereIfDebugging( airPos, 0, 255, 255 )
			DrawDebugSphereIfDebugging( airDownTrace.endPos, 255, 0, 255 )
			if ( airDownTrace.fraction < 1.0 )
			{
				TraceResults hullTrace = DoHullTraceForExit( mins, maxs, airDownTrace.endPos )

				if ( !hullTrace.startSolid && IsBreachPositionValid( player, hullTrace.endPos, hullTrace.hitEnt != null ? hullTrace.hitEnt : airDownTrace.hitEnt, eyeDir, airDownTrace.surfaceNormal ) )
				{
					possibleEndings.append( hullTrace.endPos )
					if ( DEBUG_DRAW_TARGETING )
						DebugDrawText(hullTrace.endPos, "Olddownset", false, 0.1 )
				}
			}

			i++
			float nextStepDist = min( BACK_TRACE_STEP_DIST * i, BACK_TRACE_MAX_STEP )
			airTraceDist += nextStepDist
			airPos -= eyeDir * nextStepDist
		}
	}

	PortalEndingSortStruct end = GetBestEnding( possibleEndings, player,eyeDir, eyePos, info )
	return info
}


PhaseBreachTraceResults function DoEyeTrace( vector eyePos, vector eyeDir, float effectiveRange, array<entity> ignoredEntities, vector mins, vector maxs )
{
	PhaseBreachTraceResults eyeTraceResults

	// Initial trace from eye - looking to hit something within range of the ability
	TraceResults initialTrace = TraceHull( eyePos, eyePos + (eyeDir * effectiveRange), <-5,-5,-5>, <5,5,5>, ignoredEntities, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
	eyeTraceResults.adjustedEndPos = initialTrace.endPos
	eyeTraceResults.results        = initialTrace

	DrawDebugSphereIfDebugging( initialTrace.endPos, 255, 0, 0 )

	if ( initialTrace.fraction < 1.0 )
	{
		if ( IsNormalVertical( initialTrace.surfaceNormal ) )
			eyeTraceResults.foundValidEnd = true
		else
			eyeTraceResults.adjustedEndPos = initialTrace.endPos - eyeDir * 30.0

		DrawDebugSphereIfDebugging( eyeTraceResults.adjustedEndPos, 150, 0, 0 )
	}

	if ( eyeTraceResults.foundValidEnd )
	{
		TraceResults hullTrace = DoHullTraceForExit( mins, maxs, eyeTraceResults.adjustedEndPos )

		if ( hullTrace.startSolid )
			eyeTraceResults.foundValidEnd = false
		else
			eyeTraceResults.adjustedEndPos = hullTrace.endPos
	}

	return eyeTraceResults
}


bool function IsBreachPositionValid( entity player, vector position, entity traceHitEnt, vector eyeDir, vector normal )
{
	if ( IsValid( traceHitEnt ) )
	{
		if ( traceHitEnt.IsPlayer() || traceHitEnt.IsNPC() || IsDeathboxFlyer( traceHitEnt ) )
			return false

		if ( traceHitEnt.GetScriptName() == CRYPTO_DRONE_SCRIPTNAME  )
			return false

		if ( traceHitEnt.IsProjectile() )
			return false

		// Check if hit entity is a mover by checking its velocity
		if ( LengthSqr( traceHitEnt.GetVelocity() ) > 0 )
		{
			if ( ! file.allowEndOnMovers )
				return false

			if ( DEBUG_DRAW_PUSHER_MOVEMENT )
			{
				vector pusherVelAtPoint = traceHitEnt.GetVelocity()
				//DebugDrawScreenText( 0.1,0.6, "Mover " + traceHitEnt + ", speed is " + Length(pusherVelAtPoint) + " , vel is " + pusherVelAtPoint )
			}

			if ( LengthSqr( traceHitEnt.GetVelocity() ) > file.maxEndingMoverSpeedSqr )	// Needs to be a bit above 0 since gondolas don't report velocity well on the client
				return false
		}
	}

	vector eyePos = player.EyePosition()
	if ( DotProduct( eyeDir, Normalize( position - eyePos ) ) < PHASE_BREACH_MIN_VIEW_DOT )
		return false

	if ( !IsNormalVertical( normal ) )
		return false

	// Trigger check for invalid ending types (out of bounds, etc) - disabled due to missing function
	// foreach ( entity trigger in GetTriggersByClassesInRealms_HullSize(
	// 	file.invalidTriggerEndingTypes,
	// 	position, position,
	// 	player.GetRealms(), TRACE_MASK_PLAYERSOLID,
	// 	player.GetPlayerMins(), player.GetPlayerMaxs() ) )
	// {
	// 	return false
	// }

	TraceResults eyeToDownTrace = TraceLine( eyePos, position + <0, 0, 48.0>, [player], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
	if ( eyeToDownTrace.fraction < 1.0 )
		return false

	return true
}


TraceResults function DoHullTraceForExit( vector mins, vector maxs, vector pos, float zClearance = 12.0 )
{
	TraceResults hullTrace = TraceHull( pos + <0, 0, zClearance>, pos, mins, maxs, null, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_NONE )
	//PrintTraceResults( hullTrace )
	return hullTrace
}

struct PortalEndingSortStruct
{
	vector pos
	float  val = -1.0
}

PortalEndingSortStruct function GetBestEnding( array<vector> possibleEndings, entity player, vector eyeDir, vector eyePos, PhaseBreachTargetInfo info )
{
	PortalEndingSortStruct failedEnding

	array<PortalEndingSortStruct> endings
	foreach ( vector pos in possibleEndings )
	{
		PortalEndingSortStruct end
		end.pos = pos

		end.val = ScoreEndPosition( pos, eyeDir, eyePos, DEBUG_DRAW_ENDING_SCORES )

		endings.append( end )
	}

	endings.sort( SortEndingStruct )



	foreach ( ending in endings )
	{
		bool success = GenerateBreachPathInfo( player, info, ending.pos )

		if ( success )
		{
			info.portalQuality = ending.val
			return ending
		}
		else
		{
			if ( DEBUG_DRAW_ENDING_SCORES )
				DebugDrawText( ending.pos + <0,0,5>, "No path", false, 0.1 )
		}
	}

	PortalEndingSortStruct emptyEnding
	return emptyEnding
}

float function ScoreEndPosition( vector pos, vector eyeDir, vector eyePos, bool debugDraw = false )
{
	vector dirToPortal 	= pos - eyePos
	float distance 		= Length( dirToPortal )

	float dot = DotProduct( eyeDir, dirToPortal / distance )

	const float WEIGHT_DOT = 75
	const float WEIGHT_DIST = 60

	float dotScore = GraphCapped( dot, PHASE_BREACH_MIN_VIEW_DOT, 1.0, 0, WEIGHT_DOT )

	float distScore = GraphCapped( distance, 0, file.maxDist, 0,   WEIGHT_DIST)

	float totalScore = dotScore + distScore

	// Highest val = close to my view angle and far away
	//end.val = ( dot - PHASE_BREACH_MIN_VIEW_DOT ) * ( distance + 500.0 )	// Bit of a magic number - higher numbers make the dot portion more impactful
	//endings.append( end )

	if ( debugDraw )
	{
		string scoreText = string( totalScore ) + "\nDotScore: " + dotScore + "\nDistScore: " + distScore

		DebugDrawText( pos + <0,0,-5>, scoreText, false, 0.1 )
	}

	return totalScore
}


int function SortEndingStruct( PortalEndingSortStruct a, PortalEndingSortStruct b )
{
	if ( a.val > b.val )
		return -1
	else if ( b.val > a.val )
		return 1

	return 0
}


bool function GenerateBreachPathInfo( entity player, PhaseBreachTargetInfo info, vector endPos )
{
	// We do the IsPortalExitPointValid check here instead of in IsBreachPositionValid since it should almost always succeed - trying to minimize the amount of hull traces we do
	// This is intended to catch some extreme edge cases that might have snunk through hull traces we do looking for ending positions
	if ( !PhaseTunnel_IsPortalExitPointValid( player, endPos, player, true, false, DEBUG_DRAW_TARGETING ) )
		return false

	PerfStart( PerfIndexClient.PhaseBreach_ScorePos_Generate )
	vector portalDir = Normalize( endPos - info.startPos )
	float distCheck  = Distance( info.startPos, endPos )

	if ( info.posList.len() > 0 )
		info.posList.clear()

	info.posList.append( info.startPos )

	while ( info.pathDistance < distCheck )
	{
		float step = min( TUNNEL_STEP_DIST, distCheck - info.pathDistance )

		vector newPos = info.startPos + (portalDir * step)
		info.pathDistance += step
		info.posList.append( newPos )
		info.startPos     = newPos
	}

	int posListCount = info.posList.len()
	info.posList[ posListCount - 1 ] = endPos
	info.finalPos   = endPos

	bool successful = (posListCount > 2) && info.pathDistance > 200.0

	#if CLIENT
		if ( successful )
			DrawDebugSphereIfDebugging( info.finalPos, 0, 0, 255 )
	#endif
	PerfEnd( PerfIndexClient.PhaseBreach_ScorePos_Generate )
	return successful
}

void function PhaseBreachCrosshair_Thread( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	player.EndSignal( "OnDeath" )

	weapon.EndSignal( SIGNAL_PHASE_BREACH_STOP_PLACEMENT )
	weapon.EndSignal( "OnDestroy" )

	while (true)
	{
		vector traceStart = player.EyePosition()
		vector traceEnd = player.EyePosition() + player.GetPlayerOrNPCViewVector() * (file.maxDist-15)
		TraceResults tr = TraceLine( traceStart, traceEnd , [ player ], TRACE_MASK_SOLID_BRUSHONLY , TRACE_COLLISION_GROUP_PLAYER, player )
		int pointInRange = tr.fraction < 1.0 ? 1 : -1

		if ( IsValid( weapon ) )
		{
			bool isPredictableEnt = false
			#if CLIENT
				//isPredictableEnt = weapon.GetPredictable()
			#endif
			#if SERVER
				isPredictableEnt = true
			#endif //SERVER
			if ( isPredictableEnt )
				weapon.SetScriptInt0( pointInRange )
		}

		WaitFrame()
	}

}


void function DrawDebugSphereIfDebugging( vector origin, int r, int g, int b )
{
	#if DEV
		if ( DEBUG_DRAW_PLACEMENT_TRACES )
			DebugDrawSphere( origin, 5.0, <r, g, b>, false, 0.1 )
	#endif
}


#if CLIENT
void function PhaseBreachPlacement_Thread( entity weapon )
{
	Signal( weapon, SIGNAL_PHASE_BREACH_STOP_PLACEMENT )

	weapon.EndSignal( SIGNAL_PHASE_BREACH_STOP_PLACEMENT )
	weapon.EndSignal( "OnDestroy" )

	entity player = weapon.GetWeaponOwner()
	player.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ()
		{
			if ( EffectDoesExist( file.targetingFxHandle ) )
				EffectStop( file.targetingFxHandle, true, true )
			if ( EffectDoesExist( file.targetingFxHandleDir ) )
				EffectStop( file.targetingFxHandleDir, true, true )
			if ( EffectDoesExist( file.targetingInvalidFxHandle ) )
				EffectStop( file.targetingInvalidFxHandle, true, true )

			if ( file.targetingHint != "'" )
				HidePlayerHint( file.targetingHint )
		}
	)

	int fxID		= GetParticleSystemIndex( BREACH_TARGET_FX )
	//int invalidFXID	= GetParticleSystemIndex(  BREACH_FX_AR_INVALID )
	int wallDownFXID	= GetParticleSystemIndex(BREACH_FX_AR_DIR )

	//RANGE INDICATOR
	const int OFFSET_CORRECTION = 290
	int rangeId = GetParticleSystemIndex( BREACH_RANGE_FX )
	int rangeVfx  = StartParticleEffectOnEntity( player, rangeId, FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	EffectSetControlPointVector( rangeVfx, 1, <PHASE_BREACH_MAX_2D_DIST_DEFAULT + OFFSET_CORRECTION, 0, 0> )

	OnThreadEnd(
		function() : ( rangeVfx )
		{
			if ( EffectDoesExist( rangeVfx ) )
				EffectStop( rangeVfx, false, true )
		}
	)

	while ( true )
	{
		if ( !IsValid( player ) )
			return

		PhaseBreachTargetInfo info
		if ( player in file.portalTargetTable )
			info = file.portalTargetTable[ player ]
		else
		{











			info = GetPhaseBreachTargetInfo_OLD( player  )


		}

		if ( info.portalQuality > 0 )
		{
			if ( !EffectDoesExist( file.targetingFxHandle ) )
			{
				file.targetingFxHandle = StartParticleEffectInWorldWithHandle( fxID, info.finalPos, <0,0,0> )
				EffectSetControlPointVector( file.targetingFxHandle, 1, TEAM_COLOR_FRIENDLY )
			}

			EffectSetControlPointVector( file.targetingFxHandle, 0, info.finalPos )


































			//if ( EffectDoesExist( file.targetingInvalidFxHandle ) )
			//{
			//	EffectStop( file.targetingInvalidFxHandle, true, false )
			//}


			HidePlayerHint( file.targetingHint )
			file.targetingHint = ""
		}
		else
		{
			if ( EffectDoesExist( file.targetingFxHandle ) )
			{
				EffectStop( file.targetingFxHandle, true, false )
			}
			if ( EffectDoesExist( file.targetingFxHandleDir ) )
			{
				EffectStop( file.targetingFxHandleDir, true, false )
			}

			//if ( !EffectDoesExist( file.targetingInvalidFxHandle ) )
			//{
			//	file.targetingInvalidFxHandle = StartParticleEffectInWorldWithHandle( invalidFXID, info.eyeTracePos, <0,0,0> )
			//	EffectSetControlPointVector( file.targetingInvalidFxHandle, 2, TEAM_COLOR_ENEMY )
			//}
			//vector fxNormal = info.eyeTraceNormal
			//if ( fxNormal == ZERO_VECTOR )
			//	fxNormal = -player.GetViewForward()
			//
			//vector endAngles = VectorToAngles( fxNormal )
			//EffectSetControlPointVector( file.targetingInvalidFxHandle, 0, info.eyeTracePos )
			//EffectSetControlPointAngles( file.targetingInvalidFxHandle, 0, endAngles )


			file.targetingHint = PLACEMENT_FAILED_HINT
			AddPlayerHint( 60.0, 0, $"", file.targetingHint )
		}

		WaitFrame()
	}
}
#endif



#if DEV
#if CLIENT
void function DEV_ValidateAgainstOldTargeting( entity player, PhaseBreachTargetInfo info )
{
	PerfStart( PerfIndexClient.PhaseBreach_GetPosition_OLD )
	PhaseBreachTargetInfo oldInfo = GetPhaseBreachTargetInfo_OLD( player )
	PerfEnd( PerfIndexClient.PhaseBreach_GetPosition_OLD )

	if ( LOG_VALIDATION_DATA )
	{
		file.numTargetingRuns++

		if ( info.portalQuality > 0 )
			file.newTargetingHits++

		if ( oldInfo.portalQuality > 0 )
			file.oldTargetingHits++

		// Old targeting found case where new could not.
		if ( info.portalQuality == 0 && oldInfo.portalQuality > 0 )
		{
			if ( DEBUG_DRAW_VALIDATION )
			{
				Warning("Ash Ult: Old algorithm found a point and the new one failed to at all.")
				DebugDrawSphere( oldInfo.finalPos, 20, COLOR_RED, false, 0.1 )
			}
			if ( DEV_LogValidationCase( player, file.oldTargetingWins ) )
			{
				//player.ClientCommand( "pause_dev" )
			}
		}

		// New targeting found case where old could not.
		if ( info.portalQuality > 0 && oldInfo.portalQuality == 0 )
		{
			DEV_LogValidationCase( player, file.newTargetingWins, false )
		}

		// if both good, compare them
		if ( info.portalQuality > 0 && oldInfo.portalQuality > 0 )
		{
			vector eyePos = player.EyePosition()
			vector eyeDir = player.GetViewVector()
			float newScore = ScoreEndPosition(info.finalPos, eyeDir, eyePos )
			float oldScore = ScoreEndPosition(oldInfo.finalPos, eyeDir, eyePos )

			float newOldDistance = Distance( info.finalPos, oldInfo.finalPos )

			vector eyeToNew = info.finalPos - eyePos
			vector eyeToOld = oldInfo.finalPos - eyePos

			float newOldDot = DotProduct( Normalize(eyeToNew), Normalize(eyeToOld) )
			if ( newOldDistance > 10 * METERS_TO_INCHES && newOldDot < DOT_4DEGREE)
			{
				//if ( newScore > oldScore )
					//file.newTargetingWins++


				if ( oldScore > newScore )
				{
					if ( DEBUG_DRAW_VALIDATION )
					{
						Warning( "Ash Ult: Old algorithm found a point which scored better than the new one. Distance between them is " + newOldDistance + ". Dot between " + newOldDot + ". newDotScore: " + newScore + " oldDotScore: " + oldScore )
						DebugDrawSphere( oldInfo.finalPos, 20, COLOR_RED, false, 0.1 )
					}
					DEV_LogValidationCase( player, file.oldTargetingBetter )
				}
			}

			file.newAvgScore = (file.newAvgScore * (file.numTargetingRuns-1)/file.numTargetingRuns) + (newScore/file.numTargetingRuns)
			file.oldAvgScore = (file.oldAvgScore * (file.numTargetingRuns-1)/file.numTargetingRuns) + (oldScore/file.numTargetingRuns)

		}

		if ( DEBUG_DRAW_VALIDATION )
		{
			float newSuccessRate = float(file.newTargetingHits) / float(file.numTargetingRuns) * 100.0
			float oldSuccessRate = float(file.oldTargetingHits) / float(file.numTargetingRuns) * 100.0

			string debugText = "Ash targeting accuracy:" +
			"\n New Success Rate " + newSuccessRate +
			"\n Old Success Rate " + oldSuccessRate +
			"\n New Avg Score " + file.newAvgScore +
			"\n Old Avg Score " + file.oldAvgScore +
			"\n New Wins " + file.newTargetingWins.len() +
			"\n Old Wins " + file.oldTargetingWins.len() +
			"\n Old better " + file.oldTargetingBetter.len()


			DebugDrawScreenText( 0.1, 0.3, debugText )
			DebugDrawScreenTextWithColor( 0.1, 0.28, "ASH VALIDATION ON", COLOR_LIGHT_RED )
		}
	}
}

bool function DEV_LogValidationCase( entity player, table<int,string> validationList, bool isBad = true )
{
	vector playerPos       = player.GetOrigin()
	vector playerEyeAngles = player.EyeAngles()

	string setPosString = "setpos " + playerPos.x + " " + playerPos.y + " " + playerPos.z + "; setang " + playerEyeAngles.x + " " + playerEyeAngles.y + " " + playerEyeAngles.z
	string setPosStringSimple = "setpos " + int(playerPos.x) + " " + int(playerPos.y) + " " + int(playerPos.z) + "; setang " + int(playerEyeAngles.x) + " " + int(playerEyeAngles.y) + " " + int(playerEyeAngles.z)

	int setPosHash = StringHash( setPosStringSimple )

	if ( !(setPosHash in validationList ) )
	{
		validationList[setPosHash] <- setPosString
		return true
	}
	if ( isBad )
		printt( setPosString )
	return false
}

void function DEV_ToggleAshValidation()
{
	DEV_DO_VALIDATION = !DEV_DO_VALIDATION
}
void function DEV_ClearTargetingData()
{
	file.numTargetingRuns = 0
	file.newTargetingHits = 0
	file.oldTargetingHits = 0

	file.newTargetingWins.clear()
	file.oldTargetingWins.clear()
	file.oldTargetingBetter.clear()

	file.newAvgScore = 0.0
	file.oldAvgScore = 0.0
}
#endif

#endif 