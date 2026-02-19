global function MpAbilityValkJets_Init

global function OnWeaponActivate_ability_valk_jets
global function OnWeaponDeactivate_ability_valk_jets
global function OnWeaponPrimaryAttack_ability_valk_jets
global function OnWeaponAttemptOffhandSwitch_ability_valk_jets

#if SERVER
global function Thread_ValkJetHud
#endif

#if CLIENT
global function Valk_EnableHudColorCorrection
global function Valk_DisableHudColorCorrection
global function Valk_CreateJetPackRui
global function Valk_GetJetPackRui
global function Valk_DestroyJetPackRui
#endif

global function CodeCallback_OnPlayerJetpackStop
global function CodeCallback_OnPlayerJetpackStart

const float SLOW_FALL_TIME = 0.5
const float VALK_JETPACK_SPEED = 250
const float VALK_JETPACK_REACTIVATION_DELAY = 0.25
const asset SKYWARD_JUMPJETS_FRIENDLY = $"P_valk_jet_fly_ON"
const asset SKYWARD_JUMPJETS_ENEMY = $"P_valk_jet_fly_ON"

const asset VALK_AMB_EXHAUST_FP = $"P_valk_spear_thruster_idle"
const asset VALK_AMB_EXHAUST_3P = $"P_valk_spear_thruster_idle_3P"

struct
{
	#if CLIENT
		int  colorCorrection
		bool colorCorrectionActive

		int                       valkTrackersActive
		array<entity>             valkEnemiesTracked
		table<entity, int>        valkEnemiesTrackedCount

		var jetPackRui
	#endif

	table<entity, float>                  valkToJumpHeldStartTime
	table<entity, array<entity> >         valkToJumpJetFXs


	#if SERVER
		table<entity, float>  valkPassiveVODebounce
		table<entity, vector> valkStatTrackerPassiveLocation
		table<entity, float>  valkStatTrackerDistanceTravelled
	#endif
} file


void function MpAbilityValkJets_Init()
{
	PrecacheWeapon( "mp_ability_valk_jets" )

	RegisterSignal( "JetpackPassiveRemoved" )
	RegisterSignal( "JetpackOff" )
	RegisterSignal( "ValkFreefallEnd" )
	RegisterSignal( "ValkFlightReveal" )
	RegisterSignal( "ValkTeammateStartTracking" )

	RegisterNetworkedVariable( "valkTrackingActive", SNDC_PLAYER_GLOBAL, SNVT_BOOL, false )

	#if SERVER
		Survival_AddCallback_PlayerFreefallBegin( ValkUlt_FreefallBegin )
		Survival_AddCallback_PlayerFreefallEnd( ValkUlt_FreefallEnd )
	#endif
	#if CLIENT
		//RegisterNetVarBoolChangeCallback( "valkTrackingActive", OnValkTrackingChanged )
		AddCallback_CreatePlayerPassiveRui( Valk_CreateJetPackRui )
		AddCallback_DestroyPlayerPassiveRui( Valk_DestroyJetPackRui )
		file.colorCorrection = ColorCorrection_Register( "materials/correction/launch_hud.raw_hdr" )
	#endif

	AddCallback_OnPassiveChanged( ePassives.PAS_VALK, OnPassiveChanged )
	
	PrecacheParticleSystem( VALK_AMB_EXHAUST_FP )
	PrecacheParticleSystem( VALK_AMB_EXHAUST_3P )
}

#if CLIENT
void function ValkTeammateStartTracking( entity valk )
{
	valk.EndSignal( "OnDeath" )
	valk.EndSignal( "OnDestroy" )
	valk.EndSignal( "ValkTeammateStartTracking" )

	file.valkTrackersActive++
	if ( file.valkTrackersActive == 1 )
	{
		thread Thread_ValkFlightReveal()
	}

	array<entity> targetsShown = []

	OnThreadEnd(
		function() : ( valk, targetsShown )
		{
			file.valkTrackersActive--
			if ( file.valkTrackersActive == 0 )
			{
				Signal( clGlobal.levelEnt, "ValkFlightReveal" )
			}

			foreach ( enemy in targetsShown )
			{
				StopValkFlightRevealForTeam( enemy )
			}
		}
	)

	var rui
	// dklein: for ease of tuning, you can set a reveal distance in playlist. Remember that it's distance SQUARED, and that
	// distance is measured in inches, for reasons. 69,000,000 translates to 8,306 inches or 210 meters. Nice.

	float valkPasRevealDistance = GetCurrentPlaylistVarFloat( "valkpas_enemy_reveal_distance", 69000000 )
	while ( true )
	{
		int valkTeam				= valk.GetTeam()
		array<entity> enemyPlayers 	= GetPlayerArrayOfEnemies( valkTeam )
		array<entity> decoyArray 	= GetPlayerDecoyArray()
		//decoyArray.extend( GetEntArrayByScriptName( MIRAGE_DECOY_DROP_SCRIPTNAME ) )

		/*if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		{
			array<entity> dummies = GetEntArrayByScriptName( FIRING_RANGE_DUMMIE_SCRIPT_NAME )
			dummies.extend( GetEntArrayByScriptName( FIRING_RANGE_COMBAT_DUMMIE_SCRIPT_NAME ) )
			
			enemyPlayers.extend( dummies )
		}*/

		foreach ( decoy in decoyArray )
		{
			if( !IsValid(decoy) )
				continue

			int decoyTeam = decoy.GetTeam()
			if( decoyTeam != valkTeam )
				enemyPlayers.append( decoy )
		}

		foreach ( enemy in enemyPlayers )
		{
			bool dropThisEnemy
			bool isDropDecoy
			string scriptName

			if( IsValid( enemy ) )
			{
				scriptName = enemy.GetScriptName()
				//isDropDecoy = ( scriptName == MIRAGE_DECOY_DROP_SCRIPTNAME )
			}

			/*if ( IsAlive( enemy ) || isDropDecoy )
			{
				dropThisEnemy = false

				if ( DistanceSqr( valk.GetOrigin(), enemy.GetOrigin() ) < valkPasRevealDistance )
				{
					vector enemyTracePos = enemy.GetOrigin()
					if( !isDropDecoy )
						enemyTracePos = enemy.EyePosition()

					TraceResults trace = TraceLine( valk.EyePosition(), enemyTracePos, [ valk ], TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )
					if ( trace.fraction == 1.0 && ValkThreatVisionShouldRevealEnemy( enemy ) )
					{
						if ( !(targetsShown.contains( enemy )) )
						{
							StartValkFlightRevealForTeam( enemy )
							targetsShown.append( enemy )
						}
					}
					else
					{
						// lost LOS, no longer reveal this enemy
						dropThisEnemy = true
					}
				}
				else
				{
					// out of range, no longer reveal this enemy
					dropThisEnemy = true
				}
			}
			else*/
			{
				// disconnected
				dropThisEnemy = true
			}

			if ( dropThisEnemy )
			{
				if ( targetsShown.contains( enemy ) )
				{
					targetsShown.removebyvalue( enemy )
					StopValkFlightRevealForTeam( enemy )
				}
			}

			WaitFrame()
		}

		WaitFrame()
	}
}

void function Valk_CreateJetPackRui( entity player )
{
	if ( PlayerHasPassive( player, ePassives.PAS_VALK ) )
	{
		if ( file.jetPackRui != null )
			return

		file.jetPackRui = CreateCockpitRui( $"ui/valk_jets_meter.rpak" )

		RuiTrackFloat( file.jetPackRui, "chargeFrac", player, RUI_TRACK_GLIDE_METER_FRACTION )
		RuiTrackFloat( file.jetPackRui, "bleedoutEndTime", player, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "bleedoutEndTime" ) )
		RuiTrackFloat( file.jetPackRui, "reviveEndTime", player, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "reviveEndTime" ) )
	}
}

var function Valk_GetJetPackRui()
{
	return file.jetPackRui
}

void function Valk_DestroyJetPackRui( entity player )
{
	if( !PlayerHasPassive( player, ePassives.PAS_VALK ) )
	{
		if ( file.jetPackRui != null )
		{
			RuiDestroyIfAlive( file.jetPackRui )
			file.jetPackRui = null
		}
	}
}


bool function ValkThreatVisionShouldRevealEnemy( entity enemy )
{
	if ( !enemy.IsPlayer() && !enemy.IsPlayerDecoy() )
	{
		return false
	}

	if( !enemy.IsPlayerDecoy() )
	{
		if ( BleedoutState_GetPlayerBleedoutState( enemy ) != BS_NOT_BLEEDING_OUT )
			return false
	}

                      
                                                              
               
       

	return true
}

void function StartValkFlightRevealForTeam( entity enemy )
{
	array<entity> trackedEnemies = file.valkEnemiesTracked

	if ( ! (enemy in file.valkEnemiesTrackedCount) )
	{
		file.valkEnemiesTrackedCount[ enemy ] <- 0
	}

	file.valkEnemiesTrackedCount[ enemy ] += 1

	if ( file.valkEnemiesTrackedCount[ enemy ] == 1 )
		file.valkEnemiesTracked.append( enemy )
}

void function StopValkFlightRevealForTeam( entity enemy )
{
	file.valkEnemiesTrackedCount[ enemy ] -= 1

	if ( file.valkEnemiesTrackedCount[ enemy ] == 0 )
	{
		file.valkEnemiesTracked.fastremovebyvalue( enemy )
	}
}

void function Thread_ValkFlightReveal()
{
	entity player = GetLocalViewPlayer()
	Signal( clGlobal.levelEnt, "ValkFlightReveal" )
	EndSignal( clGlobal.levelEnt, "ValkFlightReveal" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "OnDeath" )

	array<entity> activeEnts

	while ( true )
	{
		foreach ( ent in file.valkEnemiesTracked )
		{
			if ( !activeEnts.contains( ent ) )
			{
				activeEnts.append( ent )
				thread _ValkFlightReveal( ent )
			}
		}

		foreach ( ent in clone activeEnts )
		{
			if ( !file.valkEnemiesTracked.contains( ent ) )
			{
				Signal( ent, "ValkFlightReveal" )
				activeEnts.fastremovebyvalue( ent )
			}
		}

		wait 0.5
	}
}

void function _ValkFlightReveal( entity victim )
{
	if ( !IsValid( victim ) )
		return
	
	Signal( victim, "ValkFlightReveal" )

	EndSignal( clGlobal.levelEnt, "ValkFlightReveal" )
	entity player = GetLocalViewPlayer()
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "ValkFreefallEnd" )
	EndSignal( victim, "ValkFlightReveal" )
	EndSignal( victim, "OnDestroy" )
	var rui = RuiCreate( $"ui/recon_overview_scan_target.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
	InitHUDRui( rui )

	EmitSoundOnEntity( GetLocalViewPlayer(), "Valk_Ultimate_AcquireTarget_1P" )

	RuiSetBool( rui, "isVisible", true )
	RuiSetBool( rui, "pinToEdge", true )
	RuiSetBool( rui, "showClampArrow", true )
	RuiSetString( rui, "hint", "" )

	int attachment = victim.LookupAttachment( "CHESTFOCUS" )
	RuiTrackFloat3( rui, "pos", victim, RUI_TRACK_POINT_FOLLOW, attachment )
	bool isChampion   = false//GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) && victim.IsNPC() ? false : GradeFlagsHas( victim, eTargetGrade.CHAMPION )
	bool isKillLeader = false//GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) && victim.IsNPC() ? false : GradeFlagsHas( victim, eTargetGrade.CHAMP_KILLLEADER )
	RuiSetBool( rui, "isChampion", isChampion )
	RuiSetBool( rui, "isKillLeader", isKillLeader )

	                        
		/*if ( GameMode_IsActive( eGameModes.CONTROL ) )
		{
			bool isEXPLeader = GradeFlagsHas( victim, eTargetGrade.EXP_LEADER )
			RuiSetBool( rui, "isEXPLeader", isEXPLeader )
		}*/
                               


	var fRui = FullMap_AddEnemyLocation( victim )
	var mRui = Minimap_AddEnemyToMinimap( victim )

	OnThreadEnd (
		function() : ( victim, rui, fRui, mRui )
		{
			RuiDestroy( rui )
			Fullmap_RemoveRui( fRui )
			RuiDestroy( fRui )
			Minimap_CommonCleanup( mRui )
		}
	)
                                  
		while( true )
		{
			bool scanBlocked = false//FerroWall_BlockScan( player.EyePosition(), victim.GetWorldSpaceCenter() )
			RuiSetBool( rui, "isVisible", !scanBlocked )
			WaitFrame()
		}
      
               
       
}

void function OnValkTrackingChanged( entity player, bool new )
{
	if ( !IsValid( GetLocalViewPlayer() ) )
		return

	if ( player.GetTeam() != GetLocalViewPlayer().GetTeam() )
	{
		// If we are in a mode where we allow communication between players near each other that are on the same team (but not the same squad); show the targets to them as well by not breaking out of this function
		/*if ( !AllianceProximity_ShouldTryToTransmitPingOrIconToAlliance( false ) || !IsValid( player ) || !IsFriendlyTeam( player.GetTeam(), GetLocalViewPlayer().GetTeam() ) || !IsPositionWithinRadius( AllianceProximity_GetMaxDistForProximity(), GetLocalViewPlayer().GetOrigin(), player.GetOrigin() ) )
			return*/
	}

	if ( new )
	{
		//thread ValkTeammateStartTracking( player )
	}
	else
	{
		//player.Signal( "ValkTeammateStartTracking" )
	}
}

void function Valk_EnableHudColorCorrection()
{
	// Doing this as a thread so we can lerp it in
	if ( !file.colorCorrectionActive )
	{
		ColorCorrection_SetExclusive( file.colorCorrection, true )
		file.colorCorrectionActive = true
		for ( float intensity = 0.0; intensity <= 1.0; intensity += 0.05 )
		{
			ColorCorrection_SetWeight( file.colorCorrection, intensity )
			Wait( 0.05 )
		}
	}
}

void function Valk_DisableHudColorCorrection()
{
	// Doing this as a thread so we can lerp it in
	if ( file.colorCorrectionActive )
	{
		file.colorCorrectionActive = false
		for ( float intensity = 1.0; intensity >= 0.0; intensity -= 0.05 )
		{
			ColorCorrection_SetWeight( file.colorCorrection, intensity )
			Wait( 0.05 )
		}
		ColorCorrection_SetExclusive( file.colorCorrection, false )
	}
	OnThreadEnd(
		function()
		{
			//file.colorCorrectionActive = false
		}
	)
}

#endif

#if SERVER
void function Thread_ValkJetpackSlowMonitor( entity player )
{
	Assert ( IsNewThread(), "Must be threaded off" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "JetpackPassiveRemoved" )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{

				if ( HasPlayerSettingMod( player, "valk_jetpack_stun" ) )
					TakePlayerSettingsMods( player, [ "valk_jetpack_stun" ] )
			}
		}
	)

	while ( true )
	{
		bool hasMod = HasPlayerSettingMod( player, "valk_jetpack_stun" )
		if ( StatusEffect_HasSeverity( player, eStatusEffect.move_slow ) )
		{
			if ( !hasMod )
			{
				GivePlayerSettingsMods( player, [ "valk_jetpack_stun" ] )
			}
		}
		else
		{
			if ( hasMod )
			{
				TakePlayerSettingsMods( player, [ "valk_jetpack_stun" ] )
			}
		}

		WaitFrame()
	}
}

void function Thread_ValkJetHud( entity valk )
{
	// dklein: cover my ass: if valk pas enemy reveal is busted strong, we can turn off in playlist
	bool valkPasEnemyReveal = GetCurrentPlaylistVarBool( "valkpas_enemy_reveal", true )
	if ( !valkPasEnemyReveal )
		return

	if ( valk.GetPlayerNetBool( "valkTrackingActive" ) )
		return

	valk.EndSignal( "ValkFreefallEnd" )
	valk.EndSignal( "OnDeath" )
	valk.EndSignal( "BleedOut_OnStartDying" )
	valk.EndSignal( "DeathTotem_PreRecallPlayer" )
	valk.EndSignal( "OnDestroy" )
	valk.EndSignal( "OnConnectionLost" )

	EndThreadOn_PlayerChangedClass( valk )

	if ( IsValid( svGlobal.levelEnt ) )
	{
		EndSignal( svGlobal.levelEnt, "RoundEnd" )
	}

	valk.SetPlayerNetBool( "valkTrackingActive", true )

	OnThreadEnd(
		function() : ( valk )
		{
			valk.SetPlayerNetBool( "valkTrackingActive", false )
		}
	)

	WaitForever()
}
#endif //SERVER

bool function OnWeaponAttemptOffhandSwitch_ability_valk_jets( entity weapon )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	entity lastWpn     = weaponOwner.GetLatestPrimaryWeapon( eActiveInventorySlot.mainHand )
	if ( !IsValid( lastWpn ) )
		return false


	entity primaryMelee = weaponOwner.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_2 )


	if ( weaponOwner.GetPlayerNetBool( "isHealing" ) )
		return false

	float now = Time()
	if ( now < weaponOwner.p.lastTimeDeactivatedJetpack + VALK_JETPACK_REACTIVATION_DELAY )
		return false

	bool result = weaponOwner.CanUseJetpack( weaponOwner.GetVelocity() )
	#if CLIENT
		if ( result == false)
		{
			EmitSoundOnEntity( weaponOwner, "Valk_Hover_Start_Fail_1P" )
		}
	#endif

	return result == true//JETPACK_ENGAGE_SUCCEED
}

var function OnWeaponPrimaryAttack_ability_valk_jets( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return 0
}

void function OnWeaponActivate_ability_valk_jets( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()

	owner.SetActivateJetpack( true )
	//owner.Signal("JumpPadStart") //Ends grav cannon/jump pad threads

	#if CLIENT
		if ( GetLocalViewPlayer() != owner )
			return

		ClientScreenShake( 5, 12, 0.3, <0, 0, 1> )

	#endif

	#if SERVER
		array<string> attachments = [ "vent_left", "vent_right" ]
		CreateValkJumpJetEffects( owner, attachments, SKYWARD_JUMPJETS_FRIENDLY, SKYWARD_JUMPJETS_ENEMY, false ) // todo: don't use a single file struct field for all players
		// todo: Do FX in thread?
	#endif

	#if CLIENT
		if ( GetLocalViewPlayer() == owner )
		{
			//thread ValkTacShowTargetLocsThread( owner )
		}
	#endif

	if ( weapon.HasMod( "heirloom" ) )
	{
		weapon.PlayWeaponEffect( VALK_AMB_EXHAUST_FP, VALK_AMB_EXHAUST_3P, "fx_l_thruster_top" , true )
		weapon.PlayWeaponEffect( VALK_AMB_EXHAUST_FP, VALK_AMB_EXHAUST_3P, "fx_l_thruster_bot" , true )
		weapon.PlayWeaponEffect( VALK_AMB_EXHAUST_FP, VALK_AMB_EXHAUST_3P, "fx_r_thruster_top" , true )
		weapon.PlayWeaponEffect( VALK_AMB_EXHAUST_FP, VALK_AMB_EXHAUST_3P, "fx_r_thruster_bot" , true )
	}
}

#if SERVER
void function ValkUlt_FreefallBegin( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( !PlayerHasPassive( player, ePassives.PAS_VALK ))
		return

	thread Thread_ValkJetHud( player )
}
#endif //SERVER


#if SERVER
void function ValkUlt_FreefallEnd( entity player )
{
	if ( !IsValid( player ) )
		return

	player.Signal( "ValkFreefallEnd" )
}
#endif // SERVER


void function OnWeaponDeactivate_ability_valk_jets( entity weapon )
{
	entity valk = weapon.GetWeaponOwner() // todo: check owner is valid
	if ( !IsValid( valk ) )
		return

	valk.Signal( "JetpackOff" )
	valk.SetActivateJetpack( false )
	valk.p.lastTimeDeactivatedJetpack = Time()
	#if SERVER
		DestroyValkJumpJetEffects( valk )
	#endif
}

void function OnPassiveChanged( entity player, int passive, bool didHave, bool nowHas )
{
	if ( didHave )
	{
		#if SERVER
		entity weapon = player.GetOffhandWeapon( OFFHAND_EQUIPMENT )

		if ( IsValid( weapon ) && weapon.GetWeaponClassName() == "mp_ability_valk_jets" )
			player.Signal( "JetpackPassiveRemoved" )
			//TakePlayerOffhandEquipment( player, "mp_ability_valk_jets" )
		#endif
	}
	if ( nowHas )
	{
		#if CLIENT
			//if ( player == GetLocalClientPlayer() )
				//UpdateAbilityToggleOrHoldBasedOnInput()
		#elseif SERVER
			//GivePlayerOffhandEquipment( player, "mp_ability_valk_jets" )
			//player.SetGlideMeter( player.GetPlayerSettingFloat( "glideDuration" ) )
		#endif
	}
}



void function CodeCallback_OnPlayerJetpackStop( entity player )
{
	player.SetActivateJetpack( false )

	#if SERVER

	#endif
}


void function CodeCallback_OnPlayerJetpackStart( entity player )
{
	#if SERVER
		if ( !(player in file.valkPassiveVODebounce) )
			file.valkPassiveVODebounce[player] <- 0

		float timeSinceLastVo = Time() - file.valkPassiveVODebounce[player]

		if ( (timeSinceLastVo > 6) && (player.GetGlideMeter() > 1.5) )
			PlayBattleChatterLineToPlayer( "bc_valk_passive", player, player )

		file.valkPassiveVODebounce[player] = Time()

		thread ValkStatTrackerPassiveDistance( player )
	#endif
}

#if SERVER
void function ValkStatTrackerPassiveDistance( entity valk )
{
	EndSignal( valk, "OnDestroy" )
	EndSignal( valk, "BleedOut_OnStartDying" )
	EndSignal( valk, "JetpackOff" )

	vector curPos                = valk.GetOrigin()
	float distanceSinceLastCheck = 0
	float totalDistance          = 0

	//TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_VALK_PASSIVE_START, valk, valk.GetOrigin(), valk.GetTeam(), valk )

	//valk.DisableWeaponTypes( WPT_MELEE )
	OnThreadEnd(
		function() : ( valk, totalDistance, curPos )
		{
			//valk.EnableWeaponTypes( WPT_MELEE )
			//TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_VALK_PASSIVE_END, valk, valk.GetOrigin(), valk.GetTeam(), valk )
			float distanceSinceLastCheck = (Distance( curPos, valk.GetOrigin() )) / 40
			float distanceToAdd          = totalDistance + distanceSinceLastCheck
			//StatsHook_ValkDistanceTravelledPassive( valk, distanceToAdd )
		}
	)

	while ( true )
	{
		distanceSinceLastCheck = (Distance( curPos, valk.GetOrigin() )) / 40
		totalDistance += distanceSinceLastCheck
		curPos                 = valk.GetOrigin()

		Wait( 0.5 )
	}
}
#endif

#if SERVER
void function CreateValkJumpJetEffects( entity player, array<string> attachments, asset friendlyVFX = SKYWARD_JUMPJETS_FRIENDLY, asset enemyVFX = SKYWARD_JUMPJETS_ENEMY, bool showToSelf = true )
{
	int team = player.GetTeam()
	file.valkToJumpJetFXs[player] <- []
	foreach ( attachment in attachments )
	{
		int friendlyID    = GetParticleSystemIndex( friendlyVFX )
		entity friendlyFX = StartParticleEffectOnEntity_ReturnEntity( player, friendlyID, FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( attachment ) )
		friendlyFX.SetOwner( player )
		SetTeam( friendlyFX, team )
		if ( showToSelf )
			friendlyFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_OWNER
		else
			friendlyFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
		friendlyFX.SetStopType( "destroyImmediately" )
		file.valkToJumpJetFXs[player].append( friendlyFX )

		int enemyID    = GetParticleSystemIndex( enemyVFX )
		entity enemyFX = StartParticleEffectOnEntity_ReturnEntity( player, enemyID, FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( attachment ) )
		SetTeam( enemyFX, team )
		enemyFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
		enemyFX.SetStopType( "destroyImmediately" )
		file.valkToJumpJetFXs[player].append( enemyFX )
	}
}
#endif

#if SERVER
void function DestroyValkJumpJetEffects( entity valk )
{
	foreach ( fx in file.valkToJumpJetFXs[valk] )
	{
		if ( IsValid( fx ) )
			fx.Destroy()
	}
	file.valkToJumpJetFXs[valk].clear()
}
#endif // SERVER