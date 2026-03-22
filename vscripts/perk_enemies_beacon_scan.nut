global function Perk_EnemyBeaconScan_Init

#if SERVER
global function SurveyBeacons_AddEnemyBeacon
global function BeaconScanEnemy_GetSpawnedBeacons
global function AddCallback_OnSurveyBeaconScanned

global function BeaconScanEnemy_RevealPlayerOnMinimapAndStartSonar

const float BEACON_SCAN_KILL_ENEMIES_CHALLENGE_DURATION = 180
#endif


#if CLIENT
global function BeaconScanEnemy_ShowBeaconLocationOnMinimap
global function BeaconScanEnemy_ShowEnemiesOnMinimap
global function BeaconScanEnemy_ClearEnemiesOnMinimap
global function ServerToClient_BeaconScanEnemy_Notifications
global function PlayEffects_SurveyBeacon_Laser
global function StopEffects_SurveyBeacon_Laser
                        
                                                 
      
#endif

struct
{
	#if SERVER
		array<entity> surveyBeacons
		array<int> recentTeamScans
		array< void functionref( entity, entity ) > onBeaconScannedCallbacks
	#endif

	#if CLIENT
		array< var > fullMapRuis
		array< var > minimapRuis
                         
                                
       
	#endif
} file

void function Perk_EnemyBeaconScan_Init()
{
	#if SERVER || CLIENT //
		Remote_RegisterClientFunction( "BeaconScanEnemy_ShowEnemiesOnMinimap", "entity", "entity", "entity", "float", -1.0, 50000.0, 15, "float", -1.0, 60.0, 6  )
		Remote_RegisterClientFunction( "BeaconScanEnemy_ShowBeaconLocationOnMinimap", "typed_entity", "player", "vector", -MAX_MAP_BOUNDS, MAX_MAP_BOUNDS, 32 )
		Remote_RegisterClientFunction( "ServerToClient_BeaconScanEnemy_Notifications", "entity", "entity" )
		Remote_RegisterClientFunction( "StopEffects_SurveyBeacon_Laser", "entity", "entity" )
	#endif

	if ( !(GetCurrentPlaylistVarBool( "disable_perk_beacon_scan_enemy", false ) ) )
	{
		PerkInfo beaconScanEnemy
		beaconScanEnemy.perkId          = ePerkIndex.BEACON_ENEMY_SCAN
		#if SERVER || CLIENT
			beaconScanEnemy.activateCallback = OnActivate_BeaconScan_Enemy
			beaconScanEnemy.deactivateCallback = OnDeactivate_BeaconScan
			beaconScanEnemy.minimapStateIndex = eMinimapObject_prop_script.SURVEY_BEACON
			beaconScanEnemy.minimapPingType = ePingType.SURVEYBEACON
			beaconScanEnemy.mapFeatureTitle = "#PERK_FEATURE_SURVEY_BEACON"
			beaconScanEnemy.mapFeatureDescription = "#PERK_FEATURE_SURVEY_BEACON_DESC"
		#endif
		#if CLIENT
			beaconScanEnemy.worldspaceIconUpOffset = 96

                          
                                                  
    
                                                                              
    
        
		#endif
		Perks_RegisterClassPerk( beaconScanEnemy )

		#if SERVER || CLIENT
		if( EnemyBeaconScan_UseNewBeaconModel() )
		{
			PrecacheModel( $"mdl/props/recon_beacon_dish/recon_beacon_dish.rmdl" )
		}

		                    
			AddCallback_OnPassiveChanged( ePassives.PAS_UPGRADE_BEACON_SCAN, OnPassiveChangedBeaconScanUpgrade )
        
		#endif

		#if SERVER
			AddCallback_OnPlayerKilled( BeaconScanEnemy_EnemyKilled )
		#endif
	}

	bool shouldUseSeperateNextZoneScanProp = SurveyBeacons_ShouldUseNextZoneSurveyBeaconProp()
	if ( !(GetCurrentPlaylistVarBool( "disable_perk_beacon_scan", false ) ) && !shouldUseSeperateNextZoneScanProp )
	{
		PerkInfo beaconScan
		beaconScan.perkId          = ePerkIndex.BEACON_SCAN
		#if SERVER || CLIENT
			beaconScan.activateCallback = OnActivate_BeaconScan_Circle
			beaconScan.deactivateCallback = OnDeactivate_BeaconScan
		#endif
		#if CLIENT
			beaconScan.worldspaceIconUpOffset = 96
		#endif
		Perks_RegisterClassPerk( beaconScan )
	}
}

                    
#if SERVER || CLIENT
void function OnPassiveChangedBeaconScanUpgrade( entity player, int passive, bool didHave, bool nowHas )
{
	if( nowHas )
	{
		Perks_AddPerk( player, ePerkIndex.BEACON_ENEMY_SCAN )
	}
}
#endif
      

bool function EnemyBeaconScan_UseNewBeaconModel()
{
	return GetCurrentPlaylistVarBool( "perk_enemy_beacon_use_new_model", true )
}

bool function EnemyBeaconScan_RevealScannerLocation()
{
                         
                                                
              
       

	return GetCurrentPlaylistVarBool( "perk_enemy_beacon_use_scanner_location", true )
}

#if SERVER || CLIENT
float function EnemyBeaconScan_WarningRange()
{
	return GetCurrentPlaylistVarFloat( "perk_enemy_beacon_warning_range", 15000 )
}

float function EnemyBeaconScan_GetBeaconScanDuration()
{
                         
                                                
  
                                                       
  
       

	return GetCurrentPlaylistVarFloat( "perk_enemy_beacon_scan_duration", 30.0 )
}
#endif

#if SERVER
float function EnemyBeaconScan_WarningDuration()
{
	return GetCurrentPlaylistVarFloat( "perk_enemy_beacon_warning_duration", 4.5 )
}
#endif

#if SERVER || CLIENT
void function OnActivate_BeaconScan_Enemy( entity player, string characterName )
{
	string calloutLine, player1pAnim, player3pAnim, panelAnim

	calloutLine  = "bc_revealEnemyPosition"

	switch ( characterName )
	{
		case "pathfinder":
		{
			player1pAnim = "pathfinder"
			player3pAnim = "pathfinder"
			panelAnim    = "pathfinder"
			break
		}
		case "crypto":
		{
			if ( HasCryptoSword ( player ) )
			{
				player1pAnim = "crypto_heirloom"
				panelAnim    = "crypto_heirloom"				
				player3pAnim = "crypto"
			}
			else
			{
				player3pAnim = "crypto"
			}
			break
		}
		case "seer":
		{
				if ( HasSeerBlades ( player ) )
				{
					player1pAnim = "seer_heirloom"
					panelAnim    = "seer_heirloom"
					//Turn this on if he has a 3P anim, example "seer_antenna_hack_start"
					//player3pAnim = "seer"
				}
				else
				{
					player1pAnim = "seer"
				}
			break
		}
		case "vantage":
		{
			player1pAnim = "vantage"
			panelAnim    = "vantage"
			break
		}

		default:
			calloutLine  = "bc_revealEnemyPosition"
			break
	}

	RegisterEnemySurveyBeaconData( player, calloutLine, player1pAnim, player3pAnim, panelAnim )
}

void function RegisterEnemySurveyBeaconData(  entity player, string calloutLine, string player1pAnim, string player3pAnim, string panelAnim )
{
	SurveyBeaconData data
	data.canUseFunc = BeaconScanEnemy_CanUseBeacon
	#if SERVER
		data.successFunc = BeaconScanEnemy_SurveySuccess
	#endif
	data.calloutLine = calloutLine
	data.scanType = eBeaconScanType.BEACON_SCAN_ENEMY

	#if SERVER
		if ( player1pAnim != "" )
			player1pAnim += "_"

		if ( player3pAnim == "" )
			player3pAnim = "pilot"

		if ( panelAnim != "" )
			panelAnim += "_"

		data.anims.playerAnimation1pStart = "pov_"+ player1pAnim + "antenna_hack_start"
		data.anims.playerAnimation1pIdle  = "pov_"+ player1pAnim + "antenna_hack_mid"
		data.anims.playerAnimation1pEnd   = "pov_"+ player1pAnim + "antenna_hack_end"

		data.anims.playerAnimation3pStart = player3pAnim +"_antenna_hack_start"
		data.anims.playerAnimation3pIdle  = player3pAnim +"_antenna_hack_mid"
		data.anims.playerAnimation3pEnd   = player3pAnim +"_antenna_hack_end"

		data.anims.panelAnimation3pStart  = "beacon_" + panelAnim + "antenna_hack_start"
		data.anims.panelAnimation3pIdle   = "beacon_" + panelAnim + "antenna_hack_mid"
		data.anims.panelAnimation3pEnd    = "beacon_" + panelAnim + "antenna_hack_end"

		data.anims.parentBlendTime = .3
	#endif

	RegisterSurveyBeaconData( player, data )
}

bool function BeaconScanEnemy_CanUseBeacon( entity player, entity beacon )
{
	// usability is determined by minimap visibility, so that we don't have to network additional state
	bool isUsable
	#if CLIENT
	// Minimap_GetRuiMinimapFlags not available in S3
	isUsable = true
	#endif
	#if SERVER
	//int team = player.GetTeam()
	//isUsable = beacon.Minimap_IsVisibleFor( team, null ) // S3: entity method not available
	isUsable = true
	#endif
	if ( !isUsable )
	{
		return false
	}

	if( beacon.GetScriptName() != ENEMY_SURVEY_BEACON_SCRIPTNAME )
		return false

	return true
}

#if SERVER
void function BeaconScanEnemy_EnemyKilled( entity victim, entity attacker, var damageInfo )
{
	if( !IsValid( victim ) || !IsValid( attacker ) )
		return

	int victimTeam = victim.GetTeam()
	int alivePlayers = GetPlayerArrayOfTeam_Alive( victimTeam ).len()
	if( alivePlayers > 0 )
		return

	int attackerTeam = attacker.GetTeam()
	if( !file.recentTeamScans.contains( attackerTeam ) )
		return

	array<entity> teamPlayers = GetPlayerArrayOfTeam( attackerTeam )

	foreach( teammate in teamPlayers )
	{
		if( !IsAlive( teammate ) )
			continue
		if( !Perks_DoesPlayerHavePerk( teammate, ePerkIndex.BEACON_ENEMY_SCAN ) )
			continue
		StatsHook_ScannedSquadKilled( teammate )
	}
}

array<entity> function BeaconScanEnemy_GetSpawnedBeacons()
{
	return file.surveyBeacons
}

void function AddCallback_OnSurveyBeaconScanned( void functionref( entity, entity ) func )
{
	Assert( !file.onBeaconScannedCallbacks.contains( func ), "Already added " + string( func ) + " with AddCallback_OnSurveyBeaconScanned" )
	file.onBeaconScannedCallbacks.append( func )
}

void function SurveyBeacons_AddEnemyBeacon( entity beaconMarker )
{
	if( EnemyBeaconScan_UseNewBeaconModel() )
	{
		entity newMarker = CreateEntity( "prop_script" )
		newMarker.SetOrigin( beaconMarker.GetOrigin() )
		newMarker.SetAngles( beaconMarker.GetAngles() )
		newMarker.SetValueForModelKey( $"mdl/props/recon_beacon_dish/recon_beacon_dish.rmdl" )
		newMarker.kv.solid = 6
		newMarker.Solid()
		newMarker.SetScriptName( beaconMarker.GetScriptName() )
		DispatchSpawn( newMarker )
		beaconMarker.Destroy()
		beaconMarker = newMarker
	}

	file.surveyBeacons.append( beaconMarker )
	SurveyBeacons_AddBeacon( beaconMarker, ENEMY_SURVEY_BEACON_SCRIPTNAME )
	SetControlPanelUsePrompts( beaconMarker, "#SURVEY_BEACON_HOLD_PROMPT", "#SURVEY_BEACON_PRESS_PROMPT" )
	Perks_AddMinimapEntityForPerk( ePerkIndex.BEACON_ENEMY_SCAN, beaconMarker )
	PIN_Perks_SurveyBeaconCreated( beaconMarker, beaconMarker.GetOrigin() )
}

void function BeaconScanEnemy_SurveySuccess( entity beacon, entity player, SurveyBeaconData data )
{
	int team = player.GetTeam()

	string calloutLine = data.calloutLine

	if ( calloutLine != "" )
		PlayBattleChatterLineToSpeakerAndTeam( player, calloutLine )

	//SURVIVAL_ShowSurveyRegionOnSquadMaps( player )
                         
                                                
  
                                                                                                                          
  
     
       
	{
		BeaconScanEnemy_RevealPlayerOnMinimapAndStartSonar( player, beacon )
	}
	Perks_HideMinimapVisibilityForTeam( beacon, ePerkIndex.BEACON_ENEMY_SCAN, team )

	array<entity> teamPlayers = GetPlayerArrayOfTeam( team )
	foreach ( playerOnTeam in teamPlayers )
	{
		Remote_CallFunction_NonReplay( playerOnTeam, "ServerToClient_BeaconScanEnemy_Notifications", player, beacon )//, ePathfinderNotifications.TEAM_SUCCESS )
	}

	thread BeaconScanEnemy_AddAndRemoveRecentScans( player )

	StatsHook_SurveyBeacon_OnSurveySuccess( player )
	PIN_Perks_SurveyBeaconScanned( player, beacon.GetOrigin() )

	if ( PlayerHasPassive( player, ePassives.PAS_PATHFINDER ) )
	{
		GrantPathfinderCooldownReduction( player )
	}

	foreach( func in file.onBeaconScannedCallbacks )
	{
		func( player, beacon )
	}
}

void function BeaconScanEnemy_AddAndRemoveRecentScans( entity player )
{
	int team = player.GetTeam()
	file.recentTeamScans.append( team )
	Wait( BEACON_SCAN_KILL_ENEMIES_CHALLENGE_DURATION )
	file.recentTeamScans.fastremovebyvalue( team )
}

void function BeaconScanEnemy_RevealPlayerOnMinimapAndStartSonar( 	entity player, entity beacon, bool forceScan = false, float rangeOverride = -1, float durationOverride = -1,
																	bool showTeammates = true, bool skipWarning = false )
{

	int team = player.GetTeam()
	array<entity> aliveEnemies = GetPlayerArrayOfEnemies_Alive( team )

	float warningRange = rangeOverride > 0 ? rangeOverride : EnemyBeaconScan_WarningRange()
	float scanDuration = durationOverride > 0 ? durationOverride : EnemyBeaconScan_GetBeaconScanDuration()

	if(( EnemyBeaconScan_RevealScannerLocation() || forceScan ) && !skipWarning )
	{
		float warningRangeSqr = warningRange * warningRange
		foreach( entity enemy in aliveEnemies )
		{
			float distToBeaconSqr = Distance2DSqr( enemy.GetOrigin(), beacon.GetOrigin() )
			if( distToBeaconSqr > warningRangeSqr )
				continue

                        
                                                  
             
         

			LockOnWarningStart( enemy )
			StatusEffect_AddTimed( enemy, eStatusEffect.perk_survey_beacon_scanned_visual, 1.0, scanDuration, 0.5 )
			thread BeaconScanEnemy_Reveal_Thread( enemy, beacon, scanDuration )
			PingForBeaconScanEnemyTriggered( enemy, beacon )
		}
	}

	array< entity > aliveTeammates
	if( showTeammates )
	{
		aliveTeammates = GetPlayerArrayOfTeam_Alive( team )
	}
	else
	{
		aliveTeammates =  [ player ]
	}

	foreach( entity ally in aliveTeammates)
	{
		Remote_CallFunction_NonReplay( ally, "BeaconScanEnemy_ShowEnemiesOnMinimap", player, ally, beacon, rangeOverride, durationOverride )
		StatusEffect_AddTimed( ally, eStatusEffect.perk_survey_beacon_enemies_scanned_visual, 1.0, EnemyBeaconScan_WarningDuration(), 0.5 )
	}
}

void function BeaconScanEnemy_Reveal_Thread( entity enemy, entity beacon, float scanDuration )
{
	EndSignal( enemy, "OnDeath" )
	EndSignal( enemy, "OnDestroy" )

	if( !( IsValid( enemy ) ) || !( IsValid( beacon )) )
		return

	OnThreadEnd(
		function() : ( enemy )
		{
			if( (IsValid( enemy ) ) )
			{
				LockOnWarningEnd( enemy )
			}
		}
	)

	Remote_CallFunction_NonReplay( enemy, "BeaconScanEnemy_ShowBeaconLocationOnMinimap", enemy, beacon.GetOrigin() )

	wait EnemyBeaconScan_WarningDuration() //scanDuration
}

entity function PingForBeaconScanEnemyTriggered( entity player, entity beacon )
{
	if ( player.IsPlayer() )
		EmitSoundOnEntityOnlyToPlayer( player, player, "Recon_SurveyBeacon_ScannedBySurveyBeacon_UI_1P" )

	asset beaconIcon = $"rui/menu/character_select/utility/util_role_recon" //$"rui/hud/gametype_icons/survival/survey_beacon_only_pathfinder" // <<- This crashes game. String is too big! Using RECON for prototype //

	vector beaconPos = beacon.GetOrigin()
	vector wpPosition = beaconPos + <0, 0, 96>
	entity wp = CreateWaypoint_BasicPos( wpPosition, "", beaconIcon )
	wp.SetOwner( player )

	wp.SetOnlyTransmitToOnePlayer(player)

	thread DelayedDestroyWP( wp )
	//thread PlayBattleChatterLineDelayedToSpeakerAndTeam( player, "bc_tacticalTaunt", 0.0 ) "Kraber coming down"
	return wp
}

void function DelayedDestroyWP( entity wp )
{
	EndSignal( wp, "OnDestroy" )

	OnThreadEnd(
		function() : ( wp )
		{
			if ( IsValid( wp ) )
				wp.Destroy()
		}
	)

	wait EnemyBeaconScan_WarningDuration()
}
#endif //SERVER

#if CLIENT
void function BeaconScanEnemy_ShowBeaconLocationOnMinimap( entity enemy, vector pulseOrigin )
{
	if ( enemy != GetLocalViewPlayer() )
		return

	FullMap_PlayCryptoPulseSequence( pulseOrigin, false, EnemyBeaconScan_GetBeaconScanDuration() ) //reveals location of beacon used.
}

void function BeaconScanEnemy_ShowEnemiesOnMinimap( entity playerWhoScanned, entity player, entity beacon, float scanRangeParm, float scanDurationParm )
{
	if ( player != GetLocalViewPlayer() )
		return

	vector playerNameColor = <255, 255, 255>

	int teamMemberIndex = playerWhoScanned.GetTeamMemberIndex()
	if ( teamMemberIndex < 0 )
		Warning( "%s() - Invalid team member index (%d) for player: %s", FUNC_NAME(), teamMemberIndex, string( player ) )
	else
		playerNameColor = GetPlayerInfoColor( playerWhoScanned )

	string playerName = playerWhoScanned == player ? Localize( "#OBITUARY_YOU" ) : playerWhoScanned.GetPlayerName()

	Obituary_Print_Localized( Localize( "#SURVIVAL_HUD_REVEALED_ENEMIES", playerName ), playerNameColor )
	thread BeaconScanEnemy_DisplayEnemiesOnMinimap_Thread( player, beacon, scanRangeParm, scanDurationParm )
}

                        
                                                            
 
                           
 
      

void function BeaconScanEnemy_SateliteScanEnemies( entity player, entity beacon, float scanRangeParm, float timeToStartFade, float timeToEndFade )
{
	int team = player.GetTeam()
	array<entity> aliveEnemies = GetPlayerArrayOfEnemies_Alive( team )

	// If given a scan range, only consider enemies in the scan range.
	if( scanRangeParm > 0 )
	{
		array<entity> enemiesToRemove
		float scanRange = scanRangeParm > 0 ? scanRangeParm : EnemyBeaconScan_WarningRange()
		float scanRangeSqr = scanRange * scanRange
		foreach( enemy in aliveEnemies )
		{
			float distToBeaconSqr = Distance2DSqr( enemy.GetOrigin(), beacon.GetOrigin() )
			if( distToBeaconSqr > scanRangeSqr )
			{
				enemiesToRemove.append( enemy )
			}
		}

		foreach( enemy in enemiesToRemove )
		{
			aliveEnemies.fastremovebyvalue( enemy )
		}
	}
                         
                                    
       

	foreach( entity enemy in aliveEnemies )
	{
                       
                                     
            
        

		// Full map
		var fRui = FullMap_AddEnemyLocation( enemy )
		file.fullMapRuis.append( fRui )

		// MiniMap
		var mRui = Minimap_AddEnemyToMinimap( enemy )
		file.minimapRuis.append( mRui )
		RuiSetGameTime( mRui, "fadeStartTime", timeToStartFade )
		RuiSetGameTime( mRui, "fadeEndTime", timeToEndFade )
	}
}

void function BeaconScanEnemy_DisplayEnemiesOnMinimap_Thread( entity player, entity beacon, float scanRangeParm, float scanDurationParm )
{
	if ( player != GetLocalViewPlayer() )
		return

	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	float scanDuration = scanDurationParm > 0 ? scanDurationParm : EnemyBeaconScan_GetBeaconScanDuration()
	float curTime = Time()
	float endTime =  curTime + scanDuration
	float timeToStartFade = curTime + ( scanDuration/2 ) //CRYPTO_TT_ENEMY_MINIMAP_ICON_TIME_BEFORE_FADE
	float timeToEndFade = endTime//timeToStartFade + CRYPTO_TT_ENEMY_MINIMAP_ICON_FADE_TIME
	
	OnThreadEnd(
		function() : ( player )
		{
			BeaconScanEnemy_ClearEnemiesOnMinimap( player )
		}
	)

                         
                                                  
                                                 
   
                                              
                                       
   
       

	BeaconScanEnemy_SateliteScanEnemies( player, beacon, scanRangeParm, timeToStartFade, timeToEndFade )

	vector pulseOrigin = beacon.GetOrigin()

                         
                                                
  
                                                                                                              
  
     
       
	{
		FullMap_PlayCryptoPulseSequence( pulseOrigin, true, EnemyBeaconScan_GetBeaconScanDuration() )
	}

                         
                                                          
       
	while ( Time() < endTime ) //timeToWait > 0 )
	{
		if( !IsValid(player) )
			break

                          
                  
                                                                         
   
                                    
                                                  
                                             
                                       
                                                                                                       
   
        

		WaitFrame()
	}
}

void function BeaconScanEnemy_ClearEnemiesOnMinimap( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	foreach( var ruiToDestroy in file.fullMapRuis )
	{
		Fullmap_RemoveRui( ruiToDestroy )
		RuiDestroyIfAlive( ruiToDestroy )
	}
	file.fullMapRuis = []

	foreach( var ruiToDestroy in file.minimapRuis)
	{
		Minimap_CommonCleanup( ruiToDestroy )
	}
	file.minimapRuis = []
}

void function ServerToClient_BeaconScanEnemy_Notifications( entity player, entity beacon )
{
	int team = player.GetTeam()
	// Shows "Squads Left" hud after scanning a beacon. Used in Hardcore BR - S.H
	bool showSquadInfo =  GetCurrentPlaylistVarBool( "beacon_show_squad_info", false )
	if (showSquadInfo)
		SurveyBeacon_ShowSquadInfo()

	EmitSoundOnEntity( beacon, "Recon_SurveyBeacon_EnemiesScanned_UI_1P" )
}
#endif // CLIENT
#endif // #if SERVER || CLIENT

#if CLIENT
void function PlayEffects_SurveyBeacon_Laser( entity beacon )
{
	EmitSoundOnEntity( beacon, "Recon_Hack_SurveyBeacon_LaserBeam_3P")
}


void function StopEffects_SurveyBeacon_Laser( entity player, entity soundEnt )
{
	StopSoundOnEntity( soundEnt, "Recon_Hack_SurveyBeacon_LaserBeam_3P" )
	StopSoundOnEntity( soundEnt, "Recon_Hack_SurveyBeacon_LaserBeam_Stereo_3P" )
}
#endif