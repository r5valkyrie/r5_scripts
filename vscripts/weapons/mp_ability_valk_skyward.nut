global function MpAbilityValkSkyward_Init
global function OnWeaponAttemptOffhandSwitch_ability_valk_skyward
global function OnWeaponPrimaryAttack_ability_valk_skyward
global function OnWeaponActivate_ability_valk_skyward
global function OnWeaponDeactivate_ability_valk_skyward


#if CLIENT
global function ServerToClient_PlayPleaseWaitSound
global function UpdateValkFlightRui
global function DestroyValkLaunchRui
global function ServerToClient_ValkUltCanceled
global function ServerToClient_SetSkydiveAfterUlt
global function ServerToClient_RemoveFromPlayersWaiting
global function ClientCodeCallback_OnSkywardLaunchStateChanged
#endif

global function ValkUlt_Canceled_ClearOffhand
global function ValkUlt_Canceled_Keypress_Wrapper

global function ValkUlt_AllyCancel

global function GetValkUltMaxHeight

global function CodeCallback_PlayerSkywardDeployBegin
global function CodeCallback_PlayerSkywardLaunchBegin
global function CodeCallback_PlayerSkywardLaunchEnd

const asset SKYWARD_JUMPJETS_FRIENDLY = $"P_valk_jet_fly_ON"
const asset SKYWARD_JUMPJETS_ENEMY = $"P_valk_jet_fly_ON"
const asset SKYWARD_AFTERBURNER_FX = $"P_valk_launch_eng"
const asset SKYWARD_RADIUS_FX = $"P_radius_marker"
const float SKYWARD_LAUNCH_TIME = 5.0
const float SKYWARD_LAUNCH_SLOW_TIME = 1.83
const float SKYWARD_TEAMMATE_ALIGN_TIME = 1



const float SKYWARD_REFUND_AMOUNT = 0.75



const float SKYWARD_ALLY_USE_DEBOUNCE_TIME = 1
const float SKYWARD_VALK_USE_DEBOUNCE_TIME = 0.5

const float SKYWARD_RADIUS = 300.0
const float SKYWARD_MAX_HEIGHT = 4500

const float SKYWARD_WAIT_TIME_BEFORE_LAUNCH = 2.0

const float SKYWARD_TRANSITION_TIME = 1.2
const float SKYWARD_TRANSITIOIN_SPEED_SCALE = 0.5

const string SKYWARD_PROXY_SCRIPT_NAME = "valk_ult_proxy"

const asset VALK_SKYWARD_USE_MODEL = $"mdl/props/revenant_totem/revenant_totem.rmdl"

//const asset VALK_SKYWARD_USE_MODEL = $"mdl/props/revenant_totem/revenant_totem.rmdl"//"mdl/props/caustic_gas_tank/caustic_gas_tank.rmdl"

const array<vector> attachPositions = [<-10, -50, -40>, <-10, 50, -40>, <-50, 25, -60>, <-20, -50, -60>]

struct
{
	#if CLIENT
		var countdownRui
		var launchRui
		var flightRui
	#endif
	float                 ultStartTime
	table<entity, bool>   isInLaunchingState
	table<entity, float>	 valkUltDebounce


	#if SERVER
		entity                   ultProxy
		table<entity, bool>      isFollower
		table<entity, entity>    leaderPlayer
		table<entity, float>     valkNopeSoundDebounce
		table<entity, int>		 playerToAttachIndex
	#endif

} file

void function MpAbilityValkSkyward_Init()
{
	PrecacheParticleSystem( SKYWARD_JUMPJETS_FRIENDLY )
	PrecacheParticleSystem( SKYWARD_JUMPJETS_ENEMY )
	PrecacheParticleSystem( SKYWARD_AFTERBURNER_FX )
	PrecacheParticleSystem( SKYWARD_RADIUS_FX )
	PrecacheParticleSystem( $"P_valk_launch_engage" )
	PrecacheParticleSystem( $"P_valk_launch_eng" )

	PrecacheModel( VALK_SKYWARD_USE_MODEL )
	//PrecacheScriptString( SKYWARD_PROXY_SCRIPT_NAME )

	PrecacheMaterial( $"models/cable/drone_medic_cable" )

	RegisterSignal( "OnSkywardLaunched" )
	RegisterSignal( "OnSkywardCanceled" )
	RegisterSignal( "OnSkywardDone" )
	RegisterSignal( "AllyCanceledSkyward" )
	RegisterSignal( "ValkUltAllyLaunchFinished" )
	RegisterSignal( "OnSkywardInterrupted" )
	RegisterSignal( "OnSkywardAllyUse" )

	// this is used for the state management thread to tell the VFX/SFX to turn off, either when the thread ends or when Valk takes off
	RegisterSignal( "OnSkywardDeployStateEnd" )

	Remote_RegisterClientFunction( "ServerToClient_PlayPleaseWaitSound", "entity" )
	Remote_RegisterClientFunction( "ServerToClient_ValkUltCanceled", "entity" )
	Remote_RegisterClientFunction( "ServerToClient_SetSkydiveAfterUlt", "entity", "bool" )
	Remote_RegisterClientFunction( "ServerToClient_RemoveFromPlayersWaiting", "entity", "entity" )


	#if SERVER
		//Survival_AddCallback_PlayerFreefallEnd( OnPlayerFreefallEnd )
		AddCallback_PlayerCanUseZipline( ValkUlt_CanUseZipline )
		AddCallback_OnClientDisconnected( OnPlayerDisconnected )
		AddCallback_OnPlayerKilled( OnPlayerKilled )
	#else
		StatusEffect_RegisterEnabledCallback( eStatusEffect.skyward_embark, ValkUlt_ShowEmbarkUI )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.skyward_embark, ValkUlt_DestroyEmbarkUI )
		AddCreateCallback( "prop_script", OnPropScriptCreated )
		AddCallback_PlayerClassChanged( OnPlayerClassChanged )
		AddOnSpectatorTargetChangedCallback( OnSpectatorTargetChanged )
	#endif

	AddCallback_GameStateEnter( eGameState.Epilogue, ValkUlt_EnterGameStateResolution)
}

void function OnSpectatorTargetChanged( entity player, entity prevTarget, entity newTarget )
{
	if ( player.GetTeam() != TEAM_SPECTATOR )
		return

	if ( IsValid( newTarget ) && PlayerHasPassive( newTarget, ePassives.PAS_VALK ) )
	{
		bool isPlayerInAir = StatusEffect_HasSeverity( newTarget, eStatusEffect.skyward_embark )
		UpdateValkFlightRui( newTarget, isPlayerInAir )
	}
	else if ( IsValid( prevTarget ) && PlayerHasPassive( prevTarget, ePassives.PAS_VALK ) )
	{
		UpdateValkFlightRui( newTarget, false );
	}
}

// clean up incase class is changed mid ultimate
void function OnPlayerClassChanged( entity player )
{
#if CLIENT
	if ( player != GetLocalViewPlayer() )
		return

	// would also like to check if is valk or not to destroy mid flight, but not needed.
	if ( !player.p.isSkydiving )
		UpdateValkFlightRui( player, false )
#endif

	#if SERVER
		if ( PlayerHasPassive( player, ePassives.PAS_VALK ) )
		{
			if ( IsThisPlayerInDeployState( player ) )
				player.Signal( "OnSkywardCanceled" )

			if ( IsThisPlayerInLaunchingState( player ) )
				player.Signal( "OnSkywardInterrupted" )
		}
	#endif

}


// taking damage ends the deploy state
void function OnPostTakeDamage( entity owner, var damageInfo )
{
	if ( !IsThisPlayerInDeployState( owner ) )
		return

	#if SERVER
		entity attacker = DamageInfo_GetAttacker( damageInfo )
		if ( attacker.IsPlayer() || (attacker.IsNPC() && !attacker.IsNonCombatAI()) )
		{
			if ( !file.isFollower[owner] )
			{
				ValkUlt_Canceled_ClearOffhand( owner )
			}
			else
			{
				owner.Signal( "AllyCanceledSkyward" )
			}
		}
	#endif
}


bool function OnWeaponAttemptOffhandSwitch_ability_valk_skyward( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	entity tactical = owner.GetOffhandWeapon( OFFHAND_TACTICAL )

	#if CLIENT
		if ( !PlayerHasPassive( owner, ePassives.PAS_VALK ) )
			return false

	#endif

	table<string, float> launchParams = Helper_GetLaunchParams( owner )
	float fastUpSpeed     = (launchParams["totalUpDistance"] - launchParams["slowUpDistance"]) / launchParams["fastUpTime"]
	float transitionDist = fastUpSpeed * SKYWARD_TRANSITION_TIME * SKYWARD_TRANSITIOIN_SPEED_SCALE

	float traceDist      = GetValkUltMaxHeight( owner ) + 40 + transitionDist // plus deploy height and transition height

	TraceResults results = TraceHull( owner.GetOrigin(), owner.GetOrigin() + <0, 0, traceDist>, owner.GetPlayerMins(), owner.GetPlayerMaxs(), [ owner ], TRACE_MASK_PLAYERSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
	if ( results.fraction < 1.0 )
	{

		if( IsValid( tactical ) && !tactical.IsBurstFireInProgress() )
		{
			//owner.CancelOffhandWeapon( OFFHAND_TACTICAL )
		}

		#if CLIENT
			ValkUlt_ClearanceFailed( owner )
		#endif
		return false
	}


		/*if ( GondolasAreActive() && IsPlayerInsideGondola( owner ) )
		{
			if( IsValid( tactical ) && !tactical.IsBurstFireInProgress() )
			{
				owner.CancelOffhandWeapon( OFFHAND_TACTICAL )
			}

			#if CLIENT
				ValkUlt_ClearanceFailed( owner )
			#endif
			return false
		}*/


	bool blockBecauseDebounce = false

	// Accidental double press prevention
	if (owner in file.valkUltDebounce)
	{
		if (Time() < file.valkUltDebounce[owner] + SKYWARD_VALK_USE_DEBOUNCE_TIME)
		{
			blockBecauseDebounce = true
		}
	}

	if (blockBecauseDebounce)
		return false

	/*if (!owner.Player_IsSkywardLaunching())
	{
		file.valkUltDebounce[owner] <- Time()
	}*/

	// Check if we're in progress on tactical --
	if ( IsValid( tactical ) && tactical.IsBurstFireInProgress() )
		return false

	if ( owner.IsPhaseShifted() )
		return false

	//if (HoverVehicle_IsPlayerInAnyVehicle(owner))
		//return false

	if ( !owner.IsOnGround() )
		return false

	if ( owner.IsZiplining() )
		return false

	if ( StatusEffect_HasSeverity( owner, eStatusEffect.in_olympus_rift ) )
		return false

	if ( StatusEffect_HasSeverity( owner, eStatusEffect.in_black_hole_field ) )
		return false

	/*if ( owner.IsSlipping() )
		return false

	if( owner.Player_IsSkywardLaunching() )
		return false*/

	return true
}


#if CLIENT
void function ValkUlt_ClearanceFailed( entity player )
{
	AddPlayerHint( 1.0, 0.25, $"rui/hud/ultimate_icons/ultimate_valk", "#SKYWARD_CLEARANCE_FAIL" )
	EmitSoundOnEntity( player, "Valk_Hover_VerticalClearanceWarning_1P" )
}
#endif


void function OnWeaponActivate_ability_valk_skyward( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	//owner.Player_DeploySkywardLaunch( 20, 2.0 )

	#if SERVER
		thread ValkUlt_DeployToPeakStateForValk( owner, weapon )
	#endif

	#if CLIENT
		if ( owner == GetLocalViewPlayer() )
		{
			weapon.w.valkAlliesWaitingForLaunch.clear()
			Rumble_Play( "rumble_stim_activate", {} )
		}

	#endif
}


void function OnWeaponDeactivate_ability_valk_skyward( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()

	// question: in which cases would we hit this function but NOT one of the stopping conditions of the
	// one big state thread?

	Assert( owner.IsPlayer() )

	#if CLIENT
		if ( owner != GetLocalViewPlayer() )
			return
	#endif

	ValkUlt_Canceled( owner )

	//if ( IsValid( owner ) )
	//{
	//	if ( IsThisPlayerInDeployState( owner ) )
	//		ValkUlt_Canceled( owner )
	//}
}


var function OnWeaponPrimaryAttack_ability_valk_skyward( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()

	if ( Time() < weapon.w.valkUltStartTime + SKYWARD_WAIT_TIME_BEFORE_LAUNCH )
	{
		#if SERVER
			if ( !(owner in file.valkNopeSoundDebounce) )
			{
				file.valkNopeSoundDebounce[owner] <- Time()
			}

			if ( Time() > file.valkNopeSoundDebounce[owner] + 0.25 )
			{
				Remote_CallFunction_NonReplay( owner, "ServerToClient_PlayPleaseWaitSound", owner )
			}

			file.valkNopeSoundDebounce[owner] = Time()

		#endif
		return false

	}
	else
	{
		weapon.w.valkUltStartTime = Time()
	}
	// calculate speed and time
	{
		table<string, float> launchParams = Helper_GetLaunchParams( owner )

		float totalUpTime     = launchParams["totalUpTime"]
		float slowUpTime      = launchParams["slowUpTime"]
		float fastUpTime      = launchParams["fastUpTime"]
		float totalUpDistance = launchParams["totalUpDistance"]
		float slowUpDistance  = launchParams["slowUpDistance"]

		if ( IsValid( owner ) )
		{
			#if SERVER
				// Manually trigger the launch since Player_BeginSkywardLaunch native is not available
				// This triggers CodeCallback_PlayerSkywardLaunchBegin which signals the state thread
				thread CodeCallback_PlayerSkywardLaunchBegin( owner )
			#endif
		}
	}

	PlayerUsedOffhand( owner, weapon )
	return weapon.GetAmmoPerShot()

}

// ONE state thread; in its post OTE we have a waitsignal to wait for launch and handle the differences for launch in there
#if SERVER
void function ValkUlt_DeployToPeakStateForValk( entity valk, entity weapon )
{
	SkywardEndSignals( valk )

	// to handle in here:
	// * call initial VO
	// * damage callbacks
	// * button input bindings
	// * persistent VFX
	// * persistent sound 3p (probably also signal the client to start and end persistent 1p sound)

	// Set state tracking vars, tell code to begin deploy state
	file.isInLaunchingState[valk] <- false
	// valk.SkyDive_SetIsFromSkywardLaunch( false )
	Remote_CallFunction_NonReplay( valk, "ServerToClient_SetSkydiveAfterUlt", valk, false )
	// maybe after I kick myself out?

	// --- VO ---
	if ( Time() > weapon.w.voDebounceTime )
	{
		PlayBattleChatterLineToSpeakerAndTeam( valk, "bc_valk_ult_boarding" )
		weapon.w.voDebounceTime = Time() + RandomFloatRange( 10.0, 12.0 )
	}

	// --- dmg callback ---
	// (this could be an assert?)
	if ( !valk.e.entPostDamageCallbacks.contains( OnPostTakeDamage ) )
	{
		AddEntityCallback_OnPostDamaged( valk, OnPostTakeDamage )
	}

	// --- cleanup on state tracking and other persistent vars ---
	weapon.w.valkAlliesWaitingForLaunch.clear()
	file.isFollower[valk] <- false

	// --- status effect initializes RUI, redirects pings to self, disables tactical ---
	StatusEffect_AddEndless( valk, eStatusEffect.skyward_embark, 1.0 )


	// ==================== Set 3rd person settings ================//
	{
		vector oldFacing = valk.Player_GetWorldViewAngles()
		valk.SetTrackEntity( valk )
		valk.SetTrackEntityShouldViewAnglesFollowTrackedEntity( true )
		valk.SetTrackEntityPitchLookMode( "orbit" )
		valk.SetTrackEntityYawLookMode( "orbit" )
		valk.SetTrackEntityDistanceMode( "scriptOffset" )
		valk.SetTrackEntityMinYaw( -180 )
		valk.SetTrackEntityMaxYaw( 180 )
		valk.SetTrackEntityMinPitch( -180 )
		valk.SetTrackEntityMaxPitch( 180 )
		valk.SetTrackEntityOffsetDistance( 120.0 )
		valk.SetTrackEntityOffsetHeight( 35 )
		valk.SetTrackEntityShouldViewAnglesFollowTrackedEntity( true )
		valk.SnapEyeAngles( oldFacing )
	}
	// =================== Disable stuff ====================== //

	//Vehicle_KickPlayer_ForAbility( valk )


	// =================== Use Proxy ====================== //
	{
		entity ultProxy = CreatePropScript( VALK_SKYWARD_USE_MODEL, valk.GetOrigin(), valk.GetAngles(), 0 )

		ultProxy.SetScriptName( SKYWARD_PROXY_SCRIPT_NAME )
		ultProxy.RemoveFromAllRealms()
		ultProxy.AddToOtherEntitysRealms( valk )
		ultProxy.SetUsable()
		ultProxy.SetUsableByGroup( "pilot" )
		ultProxy.Hide()
		ultProxy.SetParent( valk )
		ultProxy.SetOwner( valk )
		ultProxy.AddUsableValue( USABLE_BY_TEAMMATES | USABLE_BLOCK_CONTINUOUS_USE | USABLE_NO_FOV_REQUIREMENTS | USABLE_CUSTOM_HINTS )
		valk.p.valkUltProxyEnt = ultProxy

		SetCallback_CanUseEntityCallback_Retail( ultProxy, ValkUlt_CanUseAlly )
		AddCallback_OnUseEntity_ClientServer( ultProxy, ValkUlt_AllyUse )
	}

	// --- Keybinds ---
	thread ValkUlt_AddKeybinds( valk )

	// ============= VFX, SFX, UI ================= //
	{
		// because this thread has a loop with 0.2s waits built in it has to run in parallel
		thread ValkUlt_DeployStateJetwashVFXAndSFX( valk )
	}

	table<string, bool> e
	e["launched"] <- false
	e["finishedSuccessfully"] <- false

	OnThreadEnd(
		function() : ( valk, e )
		{
			// --- some cleanup in case we get to thread end before we launched; otherwise this is done below ---
			if ( !e["launched"] )
			{
				// Stop hover animation (disabled - Anim_Play locks movement)
				// if ( valk.Anim_IsActive() )
				// 	valk.Anim_Stop()

				// Let client know we canceled
				Remote_CallFunction_NonReplay( valk, "ServerToClient_ValkUltCanceled", valk )

				// --- stop VFX and SFX; if we already launched, we cleared it there ---
				valk.Signal( "OnSkywardDeployStateEnd" )
				if ( valk.e.entPostDamageCallbacks.contains( OnPostTakeDamage ) )
				{
					RemoveEntityCallback_OnPostDamaged( valk, OnPostTakeDamage )
				}
				RemoveButtonPressedPlayerInputCallback( valk, IN_DUCK, ValkUlt_Canceled_Keypress_Wrapper )
				RemoveButtonPressedPlayerInputCallback( valk, IN_DUCKTOGGLE, ValkUlt_Canceled_Keypress_Wrapper )
				RemoveButtonPressedPlayerInputCallback( valk, IN_OFFHAND4, ValkUlt_Canceled_Keypress_Wrapper )

				StopSoundOnEntity(valk, "Valk_Ultimate_Activate_1P")

				entity ultProxy = valk.p.valkUltProxyEnt
				if ( IsValid( ultProxy ) )
					ultProxy.Destroy()

				// --- clear up status effect used by pings, rui, and tactical ---
				StatusEffect_StopAllOfType( valk, eStatusEffect.skyward_embark )
			}

			// --- one way or another, we're no longer in launching state ---
			file.isInLaunchingState[valk] = false


			// If you got cancelled out some other way, make sure to signal code to end skyward launch and signal client to destroy rui
			/*if ( valk.Player_IsSkywardLaunching() )
			{
				valk.Player_EndSkywardLaunch()
			}*/

			// --- if we launched, clean up buildup and blastoff sounds ---
			if ( e["launched"] )
			{
				StopSoundOnEntity( valk, "Valk_Ultimate_BuildUp_3P" )
				StopSoundOnEntity( valk, "Valk_Ultimate_BlastOff_3P" )
			}
			if ( e["finishedSuccessfully"] )
			{
				entity offhandWeapon = valk.GetOffhandWeapon( OFFHAND_ULTIMATE )
				thread PlayerSkyDive( valk, valk.GetViewVector(), offhandWeapon.w.valkLaunchedTeammates, valk, false )

				PlayBattleChatterLineToSpeakerAndTeam( valk, "bc_valk_ult_done" )
			}
			else
			{
				// --- end 3rd person ---
				valk.ClearTrackEntitySettings()

				// Something bad happened before we got to freefall - clear out this state here
				// If you die during freefall, these should get cleared via OnPlayerFreefallEnd
				//valk.SkyDive_SetIsFromSkywardLaunch( false )
				Remote_CallFunction_NonReplay( valk, "ServerToClient_SetSkydiveAfterUlt", valk, false )
			}
		}
	)
	// this signal comes from CodeCallback_PlayerSkywardLaunchBegin
	// we reach that callback from Player_BeginSkywardLaunch in primary attack
	WaitSignal( valk, "OnSkywardLaunched" )

	TraceResults groundTrace = TraceLine( valk.GetOrigin(), valk.GetOrigin() + <0, 0, -5000>, [ valk ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )

	//TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_VALK_ULTIMATE_START, valk, groundTrace.endPos, valk.GetTeam(), valk )

	// update state tracking vars
	file.isInLaunchingState[valk] = true
	e["launched"]                 = true

	// We need this set for survival_freefall to play nice
	Remote_CallFunction_NonReplay( valk, "ServerToClient_SetSkydiveAfterUlt", valk, true )
	//valk.SkyDive_SetIsFromSkywardLaunch( true )

	// --- cleanup deploy state specific settings ---
	// it's a little awkward that this is in two places, but it's still better than two threads
	{
		// make the copy pastad thing a function
		// --- stop VFX and SFX ---
		valk.Signal( "OnSkywardDeployStateEnd" )

		if ( valk.e.entPostDamageCallbacks.contains( OnPostTakeDamage ) )
		{
			RemoveEntityCallback_OnPostDamaged( valk, OnPostTakeDamage )
		}
		RemoveButtonPressedPlayerInputCallback( valk, IN_DUCK, ValkUlt_Canceled_Keypress_Wrapper )
		RemoveButtonPressedPlayerInputCallback( valk, IN_DUCKTOGGLE, ValkUlt_Canceled_Keypress_Wrapper )
		RemoveButtonPressedPlayerInputCallback( valk, IN_OFFHAND4, ValkUlt_Canceled_Keypress_Wrapper )

		entity ultProxy = valk.p.valkUltProxyEnt
		if ( IsValid( ultProxy ) )
			ultProxy.Destroy()

		// --- clear up status effect used by pings, rui, and tactical ---
		StatusEffect_StopAllOfType( valk, eStatusEffect.skyward_embark )
	}

	// --- update 3rd person view parameters ---
	valk.SetTrackEntityMinYaw( -180 )
	valk.SetTrackEntityMaxYaw( 180 )
	valk.SetTrackEntityMinPitch( -90 )
	valk.SetTrackEntityMaxPitch( 90 )

	// --- enable enhanced enemy finding on way up already ---
	thread Thread_ValkJetHud( valk )

	// --- do air shakes ---
	table<string, float> lp = Helper_GetLaunchParams( valk )
	float slowUpTime        = lp["slowUpTime"]
	float fastUpTime        = lp["fastUpTime"]

	// this thread has its own waits built in, so needs to run in parallel
	thread MiniShakesThread( valk, slowUpTime )

	// VO
	PlayBattleChatterLineToSpeakerAndTeam( valk, "bc_valk_ult_launching" )

	// --- manage sounds ---
	// Valk and allies that are hooked in are getting the 1P versions, everyone else gets 3P
	int myTeam = valk.GetTeam()
	EmitSoundOnEntityToEnemies( valk, "Valk_Ultimate_BuildUp_3P", myTeam )

	// this array tracks all players, including valk, that were launched by this ult. It's used for initiating skydive
	weapon.w.valkLaunchedTeammates.clear()
	weapon.w.valkLaunchedTeammates.append( valk )

	// sound is a little hard to wrap your mind around. Here's how it goes:
	// Valk should always hear 1p sounds for buildup/blastoff
	// Allies that ARE hooked in should also hear 1p sounds
	// Allies that are NOT hooked in should hear 3p sounds
	// We achieve this by playing 3p sounds to all enemies, 1p sounds to valk
	// and either 1p or 3p sounds to allies based on if they're hooked in

	array<entity> playersInMyTeam = GetPlayerArrayOfTeam( myTeam )
	string perspective
	foreach ( entity thisPlayer in playersInMyTeam )
	{
		if ( thisPlayer == valk )
			continue

		if ( !(weapon.w.valkAlliesWaitingForLaunch.contains( thisPlayer )) )
		{
			perspective = "3P"
		}
		else
		{
			perspective = "1P"
		}
		thread PlayValkUltSoundsOnePlayerOnly( thisPlayer, valk, slowUpTime, fastUpTime, perspective, false )
	}

	thread PlayValkUltSoundsOnePlayerOnly( valk, valk, slowUpTime, fastUpTime, perspective, true )

	// ============= wait for slow ascent =============
	wait(slowUpTime)

	// ============= do blastoff sounds, big shake, big VFX =============
	EmitSoundOnEntityToEnemies( valk, "Valk_Ultimate_BlastOff_3P", myTeam )
	// see above; allies get the 3p or 1p version of this sound based on whether they've joined the ult
	// this is handled in PlayValkUltSoundsOnePlayerOnly

	CreateAirShake( valk.GetOrigin(), 12, 400, 0.5, 800 )
	entity launchFx = StartParticleEffectOnEntity_ReturnEntity( valk, GetParticleSystemIndex( $"P_valk_launch_eng" ), FX_PATTACH_POINT_FOLLOW, valk.LookupAttachment( "vent_center" ) )
	launchFx.DisableHibernation()
	launchFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( $"P_valk_launch_engage" ), valk.GetOrigin(), valk.GetAngles() )
	launchFx.DisableHibernation()

	// ============= wait for rest of climb =============
	WaitSignal( valk, "OnSkywardDone" )
	e["finishedSuccessfully"] = true

	// and we're done; let thread end
}
#endif

// This thread runs on allies from the moment they opt in until the ult launches or they opt out
#if SERVER
void function SkywardEndSignals( entity ent )
{
	EndSignal( ent, "OnDeath", "BleedOut_OnStartDying", "OnSkywardCanceled", "OnSkywardInterrupted", "DeathTotem_PreRecallPlayer" )
	EndThreadOn_PlayerChangedClass( ent )
	EndSignal( svGlobal.levelEnt, "RoundEnd" )
}

void function ValkUlt_DeployToPeakStateForAlly( entity ally, entity valk, entity weapon )
{
	SkywardEndSignals( valk )
	EndSignal( ally, "AllyCanceledSkyward", "DeathTotem_PreRecallPlayer", "OnDeath", "OnDestroy", "OnSkywardInterrupted" )
	EndThreadOn_PlayerChangedClass( ally )

	EmitSoundOnEntityOnlyToPlayer( ally, ally, "Valk_Ultimate_Squadmate_Joined_1P" )
	EmitSoundOnEntityExceptToPlayer( ally, ally, "Valk_Ultimate_Squadmate_Joined_3P" )

	// state tracking vars
	file.isFollower[ally] <- true
	file.leaderPlayer[ally] <- valk
	file.isInLaunchingState[ally] <- false
	//ally.SkyDive_SetIsFromSkywardLaunch( false )
	Remote_CallFunction_NonReplay( ally, "ServerToClient_SetSkydiveAfterUlt", ally, false )

	table<string, bool> e
	e["launched"] <- false
	e["finishedSuccessfully"] <- false
	e["tautVFXCreated"] <- false

	//Travis - TODO - Seer's heartbeat sensor ADS on melee is not currently disabled when joining Valk ult.  Long term I think we should fix with this call:
	//HolsterAndDisableWeapons( ally )
	//Code is currently doing the disabling of weapons inside of Player_JoinSkywardLaunch.
	//Given that we're so close to 10.0 though I will go with this more conservative Seer specific fix.  To be revisited for 10.1 or later.
	//if ( PlayerHasPassive( ally, ePassives.PAS_PARIAH ) )
	{
	//	WeaponModDisableHeartbeatSensorADSMelee( ally )
	}
	//else if ( PlayerHasPassive( ally, ePassives.PAS_VANTAGE ) )
	{
	//	Vantage_EnableUnarmedADS( ally, false )
	}

	// tell code to attach this player to valk
	array<int> availableIndices
	foreach ( int index, vector attachPos in attachPositions )
		availableIndices.append( index )

	foreach ( player in weapon.w.valkAlliesWaitingForLaunch )
		availableIndices.removebyvalue( file.playerToAttachIndex[ player ] )

	int attachIndex = availableIndices[ 0 ]
	vector myOffset = attachPositions[ attachIndex ]
	file.playerToAttachIndex[ ally ] <- attachIndex
	//ally.Player_JoinSkywardLaunch( valk, myOffset, 600 )

	// ============= VFX, SFX, Input ================= //

	AddButtonPressedPlayerInputCallback( ally, IN_JUMP, ValkUlt_AllyCancel )

	int valkCableAttachID = valk.LookupAttachment( "valk_vent_center" )
	int allyCableAttachID = ally.LookupAttachment( "vent_center" )

	entity tautUltVFX
	table<string, entity> ent
	ent[ "tautUltVFX" ] <- tautUltVFX
	entity ultVFX = CreateRope( <0, 0, 0>, <0, 0, 0>, 178.0, valk, ally, valkCableAttachID, allyCableAttachID, 1, $"models/cable/drone_medic_cable", 10 )
	ultVFX.SetOwner( valk )
	ultVFX.RemoveFromAllRealms()
	ultVFX.AddToOtherEntitysRealms( valk )

	// ==================== Set 3rd person settings ================//
	{
		ally.SetTrackEntity( ally )
		ally.SetTrackEntityPitchLookMode( "orbit" )
		ally.SetTrackEntityYawLookMode( "orbit" )
		ally.SetTrackEntityDistanceMode( "scriptOffset" )

		ally.SetTrackEntityMinYaw( -180 )
		ally.SetTrackEntityMaxYaw( 180 )
		ally.SetTrackEntityMinPitch( -60 )
		ally.SetTrackEntityMaxPitch( 90 )

		ally.SetTrackEntityOffsetDistance( 120.0 )
		ally.SetTrackEntityOffsetHeight( 35 )
		ally.SetTrackEntityShouldViewAnglesFollowTrackedEntity( true )
	}

	// ally dmg callbacks
	if ( !ally.e.entPostDamageCallbacks.contains( OnPostTakeDamage ) )
	{
		AddEntityCallback_OnPostDamaged( ally, OnPostTakeDamage )
	}


	OnThreadEnd(
		function() : ( valk, ally, e, ent, ultVFX, weapon )
		{
			if ( ally in file.playerToAttachIndex )
				delete file.playerToAttachIndex[ ally ]

			if ( !e["launched"] )
			{
				RemoveButtonPressedPlayerInputCallback( ally, IN_JUMP, ValkUlt_AllyCancel )

				if( IsValid( ally ) )
				{
					StopSoundOnEntity( ally, "Valk_Ultimate_Squadmate_Joined_1P" )
					StopSoundOnEntity( ally, "Valk_Ultimate_Squadmate_Joined_3P" )

					Remote_CallFunction_NonReplay( ally, "ServerToClient_RemoveFromPlayersWaiting", ally, weapon )
				}

				weapon.w.valkAlliesWaitingForLaunch.fastremovebyvalue( ally )

				/*if (ally.Player_IsSkywardLaunching())
					ally.Player_StopFollowSkywardLaunch( true )*/
			}


			if ( !e["tautVFXCreated"] )
			{
				if ( IsValid( ultVFX ) )
					ultVFX.Destroy()
			}
			else
			{
				if ( IsValid( ent["tautUltVFX"] ) )
				{
					ent["tautUltVFX"].Destroy()
				}
			}

			if ( e["finishedSuccessfully"] )
			{
				// Does this want the full team?
				thread PlayerSkyDive( ally, valk.GetViewVector(), weapon.w.valkLaunchedTeammates, valk, false )
			}
			else
			{
				// remove me from the list of launched teammates only if we didn't finish successfully; this indicates
				// I got killed / disconnected during launch and shouldn't be passed into other players' skydive
				// also if you got removed from ascent for any other reason make sure you unparent
				if( IsValid( ally ) )
				{
					/*if (ally.Player_IsSkywardLaunching())
						ally.Player_StopFollowSkywardLaunch( true )*/

					weapon.w.valkLaunchedTeammates.fastremovebyvalue( ally )
					ally.ClearTrackEntitySettings()

					//ally.SkyDive_SetIsFromSkywardLaunch( false )
					Remote_CallFunction_NonReplay( ally, "ServerToClient_SetSkydiveAfterUlt", ally, false )
				}
			}

			//Travis - TODO - Again I think we should use this call, but doing Seer specific fix for now.
			//DeployAndEnableWeapons( ally )
			if ( IsValid( ally ) )
			{
				//if ( PlayerHasPassive( ally, ePassives.PAS_PARIAH ) )
				{
				//	WeaponModEnableHeartbeatSensorADSMelee( ally )
				}
				//else if( PlayerHasPassive( ally, ePassives.PAS_VANTAGE ) )
				{
				//	Vantage_EnableUnarmedADS( ally, true )
				}
			}
		}
	)
	WaitSignal( ally, "OnSkywardLaunched" )

	// build up and blastoff sounds for allies are handled in valk's thread

	// clean up dmg and input callbacks
	RemoveButtonPressedPlayerInputCallback( ally, IN_JUMP, ValkUlt_AllyCancel )
	RemoveButtonPressedPlayerInputCallback( ally, IN_USE, ValkUlt_AllyCancel )

	if ( ally.e.entPostDamageCallbacks.contains( OnPostTakeDamage ) )
	{
		RemoveEntityCallback_OnPostDamaged( ally, OnPostTakeDamage )
	}

	e["launched"]                 = true
	file.isInLaunchingState[ally] = true

	StopSoundOnEntity( ally, "Valk_Ultimate_Squadmate_Joined_1P" )
	StopSoundOnEntity( ally, "Valk_Ultimate_Squadmate_Joined_3P" )

	//ally.SkyDive_SetIsFromSkywardLaunch( true )
	Remote_CallFunction_NonReplay( ally, "ServerToClient_SetSkydiveAfterUlt", ally, true )


	weapon.w.valkLaunchedTeammates.append( ally )
	//StatsHook_ValkTeammatesCarriedSkyward( valk )

	// VFX need to be switched to taut cable after slowUpTime
	table<string, float> launchParams = Helper_GetLaunchParams( valk )

	float totalUpTime = launchParams["totalUpTime"]
	float slowUpTime  = launchParams["slowUpTime"]
	float fastUpTime  = launchParams["fastUpTime"]

	Wait( slowUpTime )


	// recreate the rope with fewers segments for flight so it's taut
	ultVFX.Destroy()
	ent["tautUltVFX"]   = CreateRope( <0, 0, 0>, <0, 0, 0>, 178.0, valk, ally, valkCableAttachID, allyCableAttachID, 1, $"models/cable/drone_medic_cable", 1 )
	ent["tautUltVFX"].SetOwner( valk )
	ent["tautUltVFX"].RemoveFromAllRealms()
	ent["tautUltVFX"].AddToOtherEntitysRealms( valk )
	e["tautVFXCreated"] = true

	WaitSignal( ally, "OnSkywardDone" )
	e["finishedSuccessfully"] = true
}
#endif

#if SERVER
void function ValkUlt_AddKeybinds( entity valk )
{
	SkywardEndSignals( valk )
	EndSignal( valk, "OnDestroy" )
	WaitFrame()
	/*if( valk.Player_IsSkywardLaunching() )
	{
		AddButtonPressedPlayerInputCallback( valk, IN_DUCK, ValkUlt_Canceled_Keypress_Wrapper )
		AddButtonPressedPlayerInputCallback( valk, IN_DUCKTOGGLE, ValkUlt_Canceled_Keypress_Wrapper )
		AddButtonPressedPlayerInputCallback( valk, IN_OFFHAND4, ValkUlt_Canceled_Keypress_Wrapper )
	}*/
}
#endif

// Keep doing jetwash VFX and SFX loop on valk while she's in deploy state
#if SERVER
void function ValkUlt_DeployStateJetwashVFXAndSFX( entity valk )
{
	// this comes from DeployToPeakState; this way, we inherit its end conditions
	EndSignal( valk, "OnSkywardDeployStateEnd" )

	EmitSoundOnEntityExceptToPlayer( valk, valk, "Valk_Ultimate_Activate_3P" )
	EmitSoundOnEntityExceptToPlayer( valk, valk, "Valk_Ultimate_Idle_Loop_3P" )

	OnThreadEnd(
		function() : ( valk )
		{
			StopSoundOnEntity( valk, "Valk_Ultimate_Activate_3P" )
			StopSoundOnEntity( valk, "Valk_Ultimate_Idle_Loop_3P" )
		}
	)

	while ( IsValid( valk ) )
	{
		TraceResults groundTrace = TraceLine( valk.GetOrigin(), valk.GetOrigin() + <0, 0, -500>, [ valk ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
		PlayImpactFXTable( groundTrace.endPos, valk, "human_land_jetwash" )
		wait 0.2
	}
}
#endif

// called by setting skyward_embark statuseffect
#if CLIENT
void function ValkUlt_ShowEmbarkUI( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return

	if ( !PlayerHasPassive( player, ePassives.PAS_VALK ) )
		return

	UpdateValkFlightRui( player, true )
	file.countdownRui = CreateFullscreenRui( $"ui/skyward_embark.rpak" )
	thread ValkUlt_ChargeBarSounds( player, SKYWARD_WAIT_TIME_BEFORE_LAUNCH )

	entity weapon = player.GetOffhandWeapon ( OFFHAND_ULTIMATE )
	RuiSetGameTime( file.countdownRui, "startTime", weapon.w.valkUltStartTime )
	RuiSetGameTime( file.countdownRui, "endTime", weapon.w.valkUltStartTime + SKYWARD_WAIT_TIME_BEFORE_LAUNCH + 0.1 )
}
#endif // CLIENT

// charge bar UI sounds
#if CLIENT
void function ValkUlt_ChargeBarSounds( entity valk, float chargeTime )
{
	EndSignal( valk, "OnDestroy" )
	EndSignal( valk, "OnSkywardCanceled" )
	EndSignal( valk, "BleedOut_OnStartDying" )
	EmitSoundOnEntity( valk, "Valk_Ultimate_ProgressBar_Charging" )
	OnThreadEnd(
		function() : ( valk )
		{
			StopSoundOnEntity( valk, "Valk_Ultimate_ProgressBar_Charging" )
			/*if ( valk.Player_IsSkywardLaunching() )
				EmitSoundOnEntity( valk, "Valk_Ultimate_ProgressBar_Complete" )*/
		}
	)
	Wait( chargeTime )
}
#endif

// called by disabling skyward_embark statuseffect
#if CLIENT
void function ValkUlt_DestroyEmbarkUI( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return

	if ( file.countdownRui != null )
	{
		RuiDestroyIfAlive( file.countdownRui )
		file.countdownRui = null
	}

	/*if ( !player.Player_IsSkywardLaunching() )
	{
		UpdateValkFlightRui( player, false )
	}*/
}
#endif

// tells the impatient player to wait until charge bar is full
#if CLIENT
void function ServerToClient_PlayPleaseWaitSound( entity player )
{
	EmitSoundOnEntity( player, "Menu.Invalid" )
}
#endif

#if CLIENT
void function ServerToClient_ValkUltCanceled( entity player )
{
	player.Signal( "OnSkywardCanceled" )
}
#endif

#if CLIENT
void function ServerToClient_SetSkydiveAfterUlt( entity player, bool inSkydive )
{
	if ( !IsValid ( player ) )
		return

	player.p.inSkydiveAfterUlt = inSkydive
}
#endif

#if CLIENT
void function ServerToClient_RemoveFromPlayersWaiting( entity player, entity weapon )
{
	if ( !IsValid( weapon ) )
		return

	weapon.w.valkAlliesWaitingForLaunch.fastremovebyvalue( player )
}
#endif

void function ValkUlt_Canceled_Keypress_Wrapper( entity owner )
{
	bool blockBecauseDebounce = false

	// Accidental double press prevention
	if (owner in file.valkUltDebounce)
	{
		if (Time() < (file.valkUltDebounce[owner] + SKYWARD_VALK_USE_DEBOUNCE_TIME))
		{
			blockBecauseDebounce = true
		}
		else
		{

		}
	}

	if (blockBecauseDebounce)
		return

	file.valkUltDebounce[owner] <- Time()
	ValkUlt_Canceled_ClearOffhand( owner )

}


void function ValkUlt_Canceled_ClearOffhand( entity player )
{
	if ( !IsValid ( player ) )
		return

	if ( IsValid( player ) && IsAlive( player ) )
	{
		player.ClearOffhand( eActiveInventorySlot.mainHand )
	}
}

void function ValkUlt_Canceled( entity player )
{
	if ( !IsThisPlayerInDeployState( player ) )
		return

	player.Signal( "OnSkywardCanceled" )

	#if CLIENT
		UpdateValkFlightRui( player, false )
	#endif


	entity offhandWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )

	if ( !IsValid( offhandWeapon ) )
		return

	string weaponName = offhandWeapon.GetWeaponClassName()
	if ( weaponName != "mp_ability_valk_skyward" )
		return

	float refundAmount = GetCurrentPlaylistVarFloat( "valk_ult_cancel_refund_amount", SKYWARD_REFUND_AMOUNT )

	if ( IsValid( offhandWeapon ) )
		offhandWeapon.SetWeaponPrimaryClipCount( int( offhandWeapon.GetWeaponPrimaryClipCountMax() * refundAmount ) )
}

// ======================================================================
// ========================= Ally Use Functions =========================
// ======================================================================

#if CLIENT
// set canuse and override use text for proxy on client
void function OnPropScriptCreated( entity proxy )
{
	if ( proxy.GetScriptName() != SKYWARD_PROXY_SCRIPT_NAME )
		return

	SetCallback_CanUseEntityCallback_Retail( proxy, ValkUlt_CanUseAlly )
	AddEntityCallback_GetUseEntOverrideText( proxy, ValkUlt_UseOverrideText )
}
#endif

#if CLIENT
// set proper use text based on current state
string function ValkUlt_UseOverrideText( entity proxy )
{
	entity user = GetLocalClientPlayer()
	entity valk = proxy.GetOwner()

	if ( IsPlayerAttachedToValkUlt( user, proxy ) )
	{
		return "#SKYWARD_ALLY_CANCEL_PROMPT"
	}

	if ( user == valk || !ValkUlt_CanUseAlly( user, proxy, 0 ) )
		return ""


	return "#SKYWARD_ALLY_USE_PROMPT"

}
#endif

// Can use function for use proxy
bool function ValkUlt_CanUseAlly( entity ally, entity proxy, int useFlags )
{
	entity valk = proxy.GetParent()

	// No double ulting on firing range
	/*if( ally.Player_IsSkywardLaunching() && !IsPlayerAttachedToValkUlt( ally, proxy ) )
		return false*/

	// Fix for R5DEV-257840
	if ( StatusEffect_HasSeverity( ally, eStatusEffect.placing_phase_tunnel ) )
		return false

	if ( Bleedout_IsBleedingOut( ally ) )
		return false

	/*if ( !ally.Player_IsSkywardLaunching() )
	{
		if ( ally.Player_IsSkydiving() )
			return false

		if ( !ally.IsOnGround() )
			return false
	}*/

	if ( ally.p.isInExtendedUse )
		return false

	if ( ally == valk )
	{
		return false
	}

	if ( IsEnemyTeam( ally.GetTeam(), valk.GetTeam() ) )
	{
		return false
	}

	entity weapon = valk.GetOffhandWeapon( OFFHAND_ULTIMATE )

	if ( Time() < ally.p.nextAllowUseValkUltTime )
		return false

	if ( ally.ContextAction_IsActive() )
		return false

	if ( ally.IsPhaseShiftedOrPending() )
		return false

	if ( weapon.w.valkAlliesWaitingForLaunch.len() >= GetExpectedSquadSize( ally ) - 1 )
		return false

	return true
}


void function ValkUlt_AllyUse( entity proxy, entity ally, int useInputFlags )
{
	//This function is written for both cases of joining and leaving valk's ult

	if ( ally.p.nextAllowUseValkUltTime > Time() )
		return

	if ( !ValkUlt_CanUseAlly( ally, proxy, useInputFlags ) )
		return

	entity valk = proxy.GetParent()
	if ( valk == ally )
	{
		return
	}

	#if SERVER
		if ( IsPlayerAttachedToValkUlt( ally, proxy ) )
		{
			ValkUlt_AllyCancel( ally )
			return
		}
	#endif

	entity weapon = valk.GetOffhandWeapon( OFFHAND_ULTIMATE )

	if( IsValid( ally ) )
		ally.Signal( "OnSkywardAllyUse" )

	#if SERVER
		ally.p.skydiveDecoysFired = 0 //Resetting Mirage's decoy counter so he can use his hidden passive with skydive towers.
		thread ValkUlt_DeployToPeakStateForAlly( ally, valk, weapon )
	#endif

	// this array used for attach positions and perspective correct sounds
	weapon.w.valkAlliesWaitingForLaunch.append( ally )

	// debounce time so you don't accidentally join in and cancel immediately (on long press / accidental double tap)
	ally.p.nextAllowUseValkUltTime = Time() + SKYWARD_ALLY_USE_DEBOUNCE_TIME
}


// cancel function plays sounds, tells code to unhook, sends signal to thread
void function ValkUlt_AllyCancel( entity ally )
{
	if( !IsValid( ally ) )
		return

	if ( ally.p.nextAllowUseValkUltTime > Time() )
		return

	//if (file.isInLaunchingState[ally])
		//ally.Player_StopFollowSkywardLaunch( true )

	ally.p.nextAllowUseValkUltTime = Time() + SKYWARD_ALLY_USE_DEBOUNCE_TIME

	#if SERVER
		entity valk = file.leaderPlayer[ally]

		EmitSoundOnEntityOnlyToPlayer( ally, ally, "Valk_Ultimate_Squadmate_Left_1P" )
		EmitSoundOnEntityExceptToPlayer( valk, ally, "Valk_Ultimate_Squadmate_Left_3P" )
	#endif
	ally.Signal( "AllyCanceledSkyward" )
}


// ==================================================================
// ========================= Code Callbacks =========================
// ==================================================================

void function CodeCallback_PlayerSkywardDeployBegin( entity owner )
{
	entity weapon = owner.GetOffhandWeapon ( OFFHAND_ULTIMATE )
	weapon.w.valkUltStartTime = Time()
	#if CLIENT
		if ( owner.HasPassive( ePassives.PAS_VALK ) )
		{
			if ( !(GetLocalViewPlayer() == owner) )
				return

			EmitSoundOnEntity( owner, "Valk_Ultimate_Activate_1P" )
			thread ValkUlt_ClientOnlyIdleLoop1P( owner )
			file.isInLaunchingState[owner] <- false
		}
	#endif
}


#if SERVER
void function ValkUlt_LaunchPlayerUpward( entity player )
{
	if ( !IsValid( player ) )
		return

	// NOTE: Anim_Play() locks player movement, so launch animation is disabled
	// The launch animation is handled by first-person view and VFX instead
	// if ( player.Anim_HasSequence( "valkyrie_ultimate_launch" ) )
	// {
	// 	player.Anim_Stop() // Stop the hover animation
	// 	player.Anim_Play( "valkyrie_ultimate_launch" )
	// 	player.Anim_DisableUpdatePosition()
	// }

	// Get launch parameters
	table<string, float> launchParams = Helper_GetLaunchParams( player )

	float totalUpTime     = launchParams["totalUpTime"]
	float slowUpTime      = launchParams["slowUpTime"]
	float fastUpTime      = launchParams["fastUpTime"]
	float totalUpDistance = launchParams["totalUpDistance"]
	float slowUpDistance  = launchParams["slowUpDistance"]

	// Calculate velocities for each phase
	float slowUpSpeed = slowUpDistance / slowUpTime
	float fastUpDistance = totalUpDistance - slowUpDistance
	float fastUpSpeed = fastUpDistance / fastUpTime

	float startTime = Time()
	float phase1EndTime = startTime + slowUpTime
	float phase2EndTime = phase1EndTime + fastUpTime

	// Phase 1: Slow upward movement
	while ( IsValid( player ) && Time() < phase1EndTime )
	{
		vector currentVel = player.GetVelocity()
		// Preserve horizontal velocity, set upward velocity
		player.SetVelocity( <currentVel.x, currentVel.y, slowUpSpeed> )
		WaitFrame()
	}

	if ( !IsValid( player ) )
		return

	// Phase 2: Fast upward movement (blastoff)
	while ( IsValid( player ) && Time() < phase2EndTime )
	{
		vector currentVel = player.GetVelocity()
		// Preserve horizontal velocity, set upward velocity
		player.SetVelocity( <currentVel.x, currentVel.y, fastUpSpeed> )
		WaitFrame()
	}

	if ( !IsValid( player ) )
		return

	// Stop the launch animation when done (disabled - Anim_Play locks movement)
	// if ( player.Anim_IsActive() )
	// 	player.Anim_Stop()

	// Signal that launch is complete
	player.Signal( "OnSkywardDone" )
}
#endif


void function CodeCallback_PlayerSkywardLaunchBegin( entity owner )
{
	if ( !IsValid( owner ) )
		return

	#if SERVER
		// Manually launch the player upward since native functions are not available
		thread ValkUlt_LaunchPlayerUpward( owner )
		owner.Signal( "OnSkywardLaunched" )
	#endif

	#if CLIENT
		// this is not perfect; ideally we'd replicate isLeader on the client
		// this means that in a theoretical world with more than one valk on your squad
		// a valk that joins in your passive gets the RUI as well
		if ( owner.HasPassive( ePassives.PAS_VALK ) )
		{
			if ( !(GetLocalViewPlayer() == owner) )
				return

			file.isInLaunchingState[owner] <- true
			table<string, float> launchParams = Helper_GetLaunchParams( owner )

			float totalUpTime     = launchParams["totalUpTime"]
			float slowUpTime      = launchParams["slowUpTime"]
			float fastUpTime      = launchParams["fastUpTime"]
			float totalUpDistance = launchParams["totalUpDistance"]
			float slowUpDistance  = launchParams["slowUpDistance"]

			thread ValkUlt_DoClientSoundsForLaunch( owner, slowUpTime, fastUpTime )
			thread UpdateLaunchRui( owner, totalUpDistance )
		}
		else
		{
			// FOLLOWER CASE do we need anything?
		}
	#endif
}


void function CodeCallback_PlayerSkywardLaunchEnd( entity owner, bool interrupted )
{
	if ( !IsValid( owner ) )
		return

	#if SERVER
		if ( !(owner in file.isFollower) )
			return

		// first, find out if we're skyward leader or follower
		if ( !file.isFollower[owner] )
		{
			// We're Valk! Okay, send appropriate signals based on success state
			if ( interrupted )
			{
				owner.Signal( "OnSkywardInterrupted" )
			}
			else
			{
				owner.Signal( "OnSkywardDone" )
			}
		}
		else
		{
			// FOLLOWER CASE: Do we need anything here?
			if ( interrupted )
			{
				owner.Signal( "OnSkywardInterrupted" )
			}
			else
			{
				owner.Signal( "OnSkywardDone" )
			}
		}
	#endif
}

#if CLIENT
void function ClientCodeCallback_OnSkywardLaunchStateChanged( entity owner, bool isInterrupted )
{
	if( owner != GetLocalClientPlayer() )
		return

	// GetSkywardLaunchState() is not available, use isInLaunchingState table instead
	bool isLaunching = false
	if ( owner in file.isInLaunchingState )
		isLaunching = file.isInLaunchingState[owner]

	if ( isLaunching )
	{
		// Launch state
		owner.Signal( "OnSkywardLaunched" )
	}
	else
	{
		// None state
		file.isInLaunchingState[owner] <- false
		if ( isInterrupted )
		{
			owner.Signal( "OnSkywardInterrupted" )
		}
		else
		{
			owner.Signal( "OnSkywardDone" )
		}
	}
}
#endif

// ============================================================================================
// ========================= VO, VFX, SFX, and other helper functions =========================
// ============================================================================================


#if SERVER
void function OnPlayerFreefallEnd( entity player )
{
	//if ( player.Skydive_IsFromSkywardLaunch() == false )
		//return

	//player.SkyDive_SetIsFromSkywardLaunch( false )
	Remote_CallFunction_NonReplay( player, "ServerToClient_SetSkydiveAfterUlt", player, false )

	TraceResults groundTrace = TraceLine( player.GetOrigin(), player.GetOrigin() + <0, 0, -5000>, [ player ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
	//TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_VALK_ULTIMATE_END, player, groundTrace.endPos, player.GetTeam(), player )
	//PIN_PlayerLandedOnGround( player, "valk_ult_land" )

	if ( PlayerHasPassive( player, ePassives.PAS_VALK ) )
	{
		float r = RandomFloat( 1 )
		if ( r < 0.05 )
		{
			PlayBattleChatterLineToSpeakerAndTeam( player, "bc_valk_ult_TD" )
		}
	}
}
#endif

#if SERVER
void function MiniShakesThread( entity owner, float slowUpTime )
{
	EndSignal( owner, "OnDeath", "BleedOut_OnStartDying", "OnSkywardDone", "OnSkywardInterrupted" )
	EndSignal( svGlobal.levelEnt, "RoundEnd" )
	EndThreadOn_PlayerChangedClass( owner )

	for ( float i = 0; i < 12; i++ )
	{
		CreateAirShake( owner.GetOrigin(), 6, 200, slowUpTime / 4, 800 )
		wait (slowUpTime / 12)
	}
}
#endif

#if CLIENT
void function ValkUlt_ClientOnlyIdleLoop1P( entity owner )
{
	EndSignal( owner, "OnDeath", "OnDestroy", "BleedOut_OnStartDying", "OnSkywardCanceled", "OnSkywardInterrupted", "OnSkywardLaunched",
		"OnSkywardDeployStateEnd" )
	//EndSignal( clGlobal.levelEnt, "RoundEnd" )
	//EndThreadOn_PlayerChangedClass( owner )
	// note: until we get the above, this will bug out on arena round end or class change in firing range. TO FIX LATER

	EmitSoundOnEntity( owner, "Valk_Ultimate_Idle_Loop_1P" )
	OnThreadEnd(
		function() : ( owner )
		{
			StopSoundOnEntity( owner, "Valk_Ultimate_Idle_Loop_1P" )
		}
	)
	/*while( owner.Player_IsSkywardLaunching() )
	{
		WaitFrame()
	}*/
	// while gamestate eGameState.PLAYING
}
#endif

#if SERVER
void function PlayValkUltSoundsOnePlayerOnly( entity owner, entity valk, float slowUpTime, float fastUpTime, string perspective, bool predicted )
{
	EndSignal( owner, "OnDeath", "OnDestroy" )
	EndSignal( valk, "OnDeath", "OnDestroy", "OnSkywardInterrupted", "OnSkywardDone" )

	string buildUp  = "Valk_Ultimate_BuildUp_" + perspective
	string blastOff = "Valk_Ultimate_BlastOff_" + perspective

	if ( predicted )
		EmitSoundOnEntityOnlyToPlayer( valk, owner, buildUp )
	else
		EmitSoundOnEntityOnlyToPlayer( valk, owner, buildUp )

	table<string, bool> e
	e["blastOffPlayed"] <- false

	OnThreadEnd(
		function() : ( owner, valk, buildUp, blastOff, e )
		{
			StopSoundOnEntity( valk, buildUp )

			if ( e["blastOffPlayed"] )
				StopSoundOnEntity( valk, blastOff )
		}
	)

	Wait( slowUpTime )

	if ( predicted )
		EmitSoundOnEntityOnlyToPlayer( valk, owner, blastOff )
	else
		EmitSoundOnEntityOnlyToPlayer( valk, owner, blastOff )

	e["blastOffPlayed"] = true
	Wait( fastUpTime )
}
#endif

#if CLIENT
void function ValkUlt_DoClientSoundsForLaunch( entity owner, float slowUpTime, float fastUpTime )
{
	EndSignal( owner, "OnDeath", "OnDestroy", "OnSkywardDone", "OnSkywardInterrupted" )
	EmitSoundOnEntity( owner, "Valk_Ultimate_BuildUp_1P" )
	OnThreadEnd(
		function() : ( owner )
		{
			StopSoundOnEntity( owner, "Valk_Ultimate_BuildUp_1P" )
			StopSoundOnEntity( owner, "Valk_Ultimate_BlastOff_1P" )
		}
	)

	Wait( slowUpTime )
	EmitSoundOnEntity( owner, "Valk_Ultimate_BlastOff_1P" )
	Wait( fastUpTime )
}
#endif

// =================================================================
// ========================= RUI functions =========================
// =================================================================

#if CLIENT
/*
 * When the player dies or starts bleeding out, clear out any RUI
 */
void function UpdateLaunchRui( entity owner, float totalUpDistance )
{
	owner.EndSignal( "OnDeath" )
	owner.EndSignal( "BleedOut_OnStartDying" )
	owner.EndSignal( "OnSkywardInterrupted" )

	file.launchRui = CreateFullscreenRui( $"ui/skyward_launch.rpak" )
	thread Valk_EnableHudColorCorrection()
	RuiSetFloat( file.launchRui, "seaHeight", GetSeaHeightForDisplay() )
	RuiTrackFloat3( file.launchRui, "playerPos", owner, RUI_TRACK_ABSORIGIN_FOLLOW )
	RuiSetFloat( file.launchRui, "maxHeight", totalUpDistance )

	OnThreadEnd ( function() : ( owner )
	{
		DestroyValkLaunchRui()
		UpdateValkFlightRui( owner, false )
	} )

	while( true )
	{
		if ( file.launchRui )
		{
			RuiSetFloat3( file.launchRui, "cameraAngle", owner.CameraAngles() )
			RuiSetFloat( file.launchRui, "seaHeight", GetSeaHeightForDisplay() )
			RuiSetBool( file.launchRui, "isFullmapOpen", Fullmap_IsVisible() || IsScoreboardShown())
		}
		WaitFrame()
	}
}
/*
 * Returns a bool for survival_freefall to let it know if valk was ulting to freefall
 * If she was, then it disables one of the skydive animate ins
 */
bool function DestroyValkLaunchRui()
{
	if ( file.launchRui )
	{
		RuiDestroyIfAlive( file.launchRui )
		file.launchRui = null
		return true
	}
	return false
}
#endif

void function UpdateValkFlightRui( entity player, bool isInAir )
{
	#if CLIENT
		bool isValk = false
		if ( LoadoutSlot_IsReady( ToEHI( player ), Loadout_Character() ) )
			isValk = ItemFlavor_GetAsset( LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() ) ) == $"settings/itemflav/character/valkyrie.rpak"

		bool showValkRui = isInAir && isValk

		RuiSetBool( GetDpadMenuRui(), "isValkAirborn", showValkRui )
		RuiSetBool( GetWeaponRui(), "isValkAirborn", showValkRui )
		RuiSetBool( GetTacticalRui(), "isValkAirborn", showValkRui )
		RuiSetBool( GetUltimateRui(), "isValkAirborn", showValkRui )
		RuiSetBool( GetMinimapFrameRui(), "isValkAirborn", showValkRui )
		RuiSetBool( GetMinimapYouRui(), "isValkAirborn", showValkRui )
		if ( Valk_GetJetPackRui() != null )
			RuiSetBool( Valk_GetJetPackRui(), "isValkAirborn", showValkRui )

		if ( showValkRui )
			thread Valk_EnableHudColorCorrection()
		else
			thread Valk_DisableHudColorCorrection()

		bool isValidMode = true




		if ( isValidMode && IsValid( GetCompassRui() ) )
			RuiSetBool( GetCompassRui(), "isValkAirborn", showValkRui )

		if ( isValk )
		{
			if ( isInAir && file.flightRui == null )
			{
				file.flightRui = CreatePermanentCockpitRui( $"ui/valk_flight.rpak" )
				RuiTrackFloat3( file.flightRui, "playerAngles", GetLocalViewPlayer(), RUI_TRACK_CAMANGLES_FOLLOW )
			}
			else if ( file.flightRui != null && !isInAir )
			{
				RuiSetBool( file.flightRui, "isFinished", true )
				file.flightRui = null
				DestroyValkLaunchRui()
			}
		}
		else
		{
			DestroyAllValkRui()
		}
	#endif
}

#if CLIENT
void function DestroyAllValkRui()
{
	if ( GetDpadMenuRui() != null )
		RuiSetBool( GetDpadMenuRui(), "isValkAirborn", false )
	if ( GetWeaponRui() != null )
		RuiSetBool( GetWeaponRui(), "isValkAirborn", false )
	if ( GetTacticalRui() != null )
		RuiSetBool( GetTacticalRui(), "isValkAirborn", false )
	if ( GetUltimateRui() != null )
		RuiSetBool( GetUltimateRui(), "isValkAirborn", false )
	if ( Valk_GetJetPackRui() != null )
		RuiSetBool( Valk_GetJetPackRui(), "isValkAirborn", false )
	if ( GetMinimapFrameRui() != null )
		RuiSetBool( GetMinimapFrameRui(), "isValkAirborn", false )
	if ( file.countdownRui != null )
		RuiDestroyIfAlive( file.countdownRui )

	DestroyValkLaunchRui()

	if ( file.flightRui != null )
	{
		RuiSetBool( file.flightRui, "isFinished", true )
		RuiDestroyIfAlive( file.flightRui )
	}
	thread Valk_DisableHudColorCorrection()
	file.flightRui    = null
	file.launchRui    = null
	file.countdownRui = null
}

#endif

#if SERVER
void function OnPlayerDisconnected( entity player )
{
	SkyLaunchCleanUp( player )
}
#endif

#if SERVER
void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	SkyLaunchCleanUp( victim )
}
#endif

// ==============================================================================
// ============================== HELPER FUNCTIONS ==============================
// ==============================================================================

#if SERVER
void function SkyLaunchCleanUp( entity player )
{
	if ( !IsValid( player ) )
		return

	/*if ( !player.Player_IsSkywardLaunching() )
		return*/

	ClearChildren( player, true )
	if ( IsThisPlayerInDeployState( player ) )
		player.Signal( "OnSkywardCanceled" )

	if ( IsThisPlayerInLaunchingState( player ) )
		player.Signal( "OnSkywardInterrupted" )
}
#endif

array<float> function GetValkLaunchTimes()
{
	array<float> launchTimes

	launchTimes.append( GetCurrentPlaylistVarFloat( "valk_ult_launch_time", SKYWARD_LAUNCH_TIME ) )
	launchTimes.append( GetCurrentPlaylistVarFloat( "valk_ult_slow_up_time", SKYWARD_LAUNCH_SLOW_TIME ) )

	return launchTimes
}


table<string, float> function Helper_GetLaunchParams( entity owner )
{
	table<string, float> res
	float totalUpTime     = GetValkLaunchTimes()[0]
	float slowUpTime      = GetValkLaunchTimes()[1]
	float fastUpTime      = totalUpTime - slowUpTime
	float totalUpDistance = GetValkUltMaxHeight( owner )
	float slowUpDistance  = (1.0 / 20.0) * totalUpDistance

	// this could be a struct
	res["totalUpTime"] <- totalUpTime
	res["slowUpTime"] <- slowUpTime
	res["fastUpTime"] <- fastUpTime
	res["totalUpDistance"] <- totalUpDistance
	res["slowUpDistance"] <- slowUpDistance

	return res
}


bool function IsPlayerAttachedToValkUlt( entity player, entity valkUlt )
{
	if ( IsValid( player.GetParent() ) && player.GetParent() == valkUlt.GetParent() )
		return true

	return false
}


bool function IsThisPlayerInLaunchingState( entity player )
{
	if ( !(player in file.isInLaunchingState) )
		return false

	return file.isInLaunchingState[player]
}


bool function IsThisPlayerInDeployState( entity player )
{
	/*if ( !player.Player_IsSkywardLaunching() )
		return false*/

	return !IsThisPlayerInLaunchingState( player )
}


float function GetValkUltMaxHeight( entity player )
{
	float result = GetCurrentPlaylistVarFloat( "valk_ult_up_distance", SKYWARD_MAX_HEIGHT )

	return result
}

#if SERVER
vector function GetSkydiveFormationOffset( entity player, array<entity> squadPlayers, entity leaderPlayer )
{
	if ( player == leaderPlayer )
		return < 0, 0, 0 >

	int index = 0
	foreach ( entity _player in squadPlayers )
	{
		if ( _player == leaderPlayer )
			continue
		if ( _player == player )
			break
		index++
	}

	int countBack = (index + 2) / 2
	vector offset = < -30, 30, -30 > * countBack

	if ( index % 2 == 0 )
		offset.y *= -1

	return offset

}
#endif // SERVER

bool function ValkUlt_CanUseZipline( entity player, entity zipline, vector ziplineClosestPoint )
{
	/*if ( player.Player_IsSkywardLaunching() )
		return false
*/
	return true
}


void function ValkUlt_EnterGameStateResolution()
{
	#if CLIENT
		UpdateValkFlightRui( GetLocalViewPlayer(), false )
	#endif

	#if SERVER
		foreach ( player in GetPlayerArray_Alive() )
		{
			if ( IsThisPlayerInDeployState( player ) )
				player.Signal( "OnSkywardCanceled" )

			else if ( IsThisPlayerInLaunchingState( player ) )
				player.Signal( "OnSkywardInterrupted" )
		}
	#endif
}
 