global function Perk_BeaconScan_Init

#if SERVER || CLIENT
global function SurveyBeacon_GetBeaconIcon
global function SurveyBeacon_IsSurveyBeacon
global function PlayerShouldSeeSurveyBeaconMarkers
global function SurveyBeacon_CanUseFunction
global function SurveyBeacon_CanActivate
global function HasCryptoSword
global function HasSeerBlades
global function RegisterSurveyBeaconData
global function OnDeactivate_BeaconScan
#if SERVER
global function SurveyBeacon_PopulateHackPanelAnims
global function OnPanelUse_SurveyBeacon
global function AddSurveyBeaconSpawnCallbacks
global function SurveyBeacon_RandomizeBeaconArray
global function GetRingConsoleGoalNumber
global function SurveyBeacon_SetBeaconGoalCount
global function RingConsole_SetConsoleGoalCount
#endif

#if CLIENT
global function SurveyBeacon_CreateHUDMarker
global function SurveyBeacon_AddSurveyBeaconMinimapPackage
global function OnSurveyBeaconCreated
#endif

#endif


global struct SurveyBeaconData
{
	bool functionref( entity, entity  ) canUseFunc
	string calloutLine
	int scanType

	#if SERVER
		void functionref( entity, entity, SurveyBeaconData ) successFunc
		HackPanelAnims anims
	#endif
}

global enum eBeaconScanType
{
	DEFAULT,
	BEACON_SCAN_CIRCLE,
	BEACON_SCAN_ENEMY,
	BEACON_SCAN_DROPPOD,

	_count
}

struct
{
	#if SERVER || CLIENT
	table< entity, table<int, SurveyBeaconData > > surveyBeaconData
	#endif

	#if SERVER
	int defaultBeaconGoalCount = 12
	int	defaultConsoleGoalCount = 12
	#endif
} file

void function Perk_BeaconScan_Init()
{
	Perk_NextZoneBeaconScan_Init()
	Perk_EnemyBeaconScan_Init()

	#if CLIENT
	RegisterSignal( "BeaconIconReset" )
	#endif
}

float function GetBaseSurveyBeaconExclusionDistance()
{
	return GetCurrentPlaylistVarFloat( "survey_beacon_exclusion_distance", 12000 )
}

#if SERVER
int function GetEnemyScanBeaconGoalNumber()
{
	return GetCurrentPlaylistVarInt( "enemy_scan_beacon_goal_number", file.defaultBeaconGoalCount )
}

void function SurveyBeacon_SetBeaconGoalCount( int goal )
{
	file.defaultBeaconGoalCount = goal
}

int function GetRingConsoleGoalNumber()
{
	return GetCurrentPlaylistVarInt( "ring_console_goal_number", file.defaultConsoleGoalCount )
}

void function RingConsole_SetConsoleGoalCount( int goal )
{
	file.defaultConsoleGoalCount = goal
}
#endif
#if SERVER || CLIENT
asset function SurveyBeacon_GetBeaconIcon( entity beacon )
{
	if( beacon.GetScriptName() == NEXT_ZONE_SURVEY_BEACON_SCRIPTNAME )
		return Perks_GetIconForPerk( ePerkIndex.BEACON_SCAN )
	return Perks_GetIconForPerk( ePerkIndex.BEACON_ENEMY_SCAN )
}

bool function SurveyBeacon_IsSurveyBeacon( entity beacon )
{
	return beacon.GetScriptName() == ENEMY_SURVEY_BEACON_SCRIPTNAME || beacon.GetScriptName() == NEXT_ZONE_SURVEY_BEACON_SCRIPTNAME
}

bool function HasCryptoSword( entity player )
{

	string meleeSkinName

	#if SERVER
		meleeSkinName = Survival_GetMeleeWeaponName( player )
	#elseif CLIENT
		entity meleeWeapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_2 )
		if ( meleeWeapon != null )
			meleeSkinName = meleeWeapon.GetWeaponClassName()
	#endif

	if ( meleeSkinName == "mp_weapon_crypto_heirloom_primary" )
		return true

	return false
}

bool function HasSeerBlades( entity player )
{
	string meleeSkinName

	#if SERVER
		meleeSkinName = Survival_GetMeleeWeaponName( player )
	#elseif CLIENT
		entity meleeWeapon = player.GetNormalWeapon( WEAPON_INVENTORY_SLOT_PRIMARY_2 )
		if ( meleeWeapon != null )
			meleeSkinName = meleeWeapon.GetWeaponClassName()
	#endif

	if ( meleeSkinName == "mp_weapon_seer_heirloom_primary" )
		return true

	return false
}

void function RegisterSurveyBeaconData( entity player, SurveyBeaconData data )
{
	if( !( player in file.surveyBeaconData ) )
	{
		table<int, SurveyBeaconData > emptyTable
		file.surveyBeaconData[player] <- emptyTable
	}
	file.surveyBeaconData[ player ][data.scanType] <- data
}

int function BeaconEntToScanType( entity beacon )
{
	string scriptName = beacon.GetScriptName()
	if( scriptName == NEXT_ZONE_SURVEY_BEACON_SCRIPTNAME )
		return eBeaconScanType.BEACON_SCAN_CIRCLE
	if( scriptName == ENEMY_SURVEY_BEACON_SCRIPTNAME )
		return eBeaconScanType.BEACON_SCAN_ENEMY
	return eBeaconScanType.DEFAULT
}

#if DEVELOPER
bool function SurveyBeacon_IgnoreCanUseCheck()
{
	return GetCurrentPlaylistVarBool( "survey_beacon_ignore_can_use_check", false )
}
#endif

bool function SurveyBeacon_CanUseFunction( entity player, entity beacon, int useFlags )
{
	if ( GetGameState() < eGameState.Playing )
		return false

	if ( !ControlPanel_CanUseFunction( player, beacon ) )
		return false

	return true
}

bool function SurveyBeacon_CanActivate( entity player, entity beacon )
{
	if ( !PlayerShouldSeeSurveyBeaconMarkers( player, beacon ) )
	{
		return false
	}

	int beaconType = BeaconEntToScanType( beacon )
	table<int, SurveyBeaconData> usableBeacons = file.surveyBeaconData[ player ]


	#if DEVELOPER
	if( !SurveyBeacon_IgnoreCanUseCheck() )
	#endif
	{
		if( beaconType in usableBeacons )
		{
			SurveyBeaconData data = usableBeacons[beaconType]
			if ( data.canUseFunc != null )
			{
				if ( !data.canUseFunc( player, beacon ) )
				{
					return false
				}
			}
		}
	}

	return true
}

             
                                                                
 
                                                   
  
            
                                                                                        
                 
              
  

            
 
      

bool function PlayerHasAccessToBeacons( entity player, entity beacon )
{
	if( !( player in file.surveyBeaconData ) )
		return false;
	if( beacon == null )
		return true;
	int beaconType =  BeaconEntToScanType( beacon )
	return beaconType in file.surveyBeaconData[player]
}

bool function PlayerShouldSeeSurveyBeaconMarkers( entity player, entity beacon )
{
	return PlayerHasAccessToBeacons( player, beacon ) || player.GetTeam() == TEAM_SPECTATOR
}
#if CLIENT
void function OnSurveyBeaconCreated( entity beacon )
{
	if ( !IsValid( beacon ) )
		return

	if ( SurveyBeacon_IsSurveyBeacon( beacon ) )
	{
		CreateCallback_Panel( beacon )
		ClearCallback_CanUseEntityCallback( beacon )
		SetCallback_CanUseEntityCallback_Retail( beacon, SurveyBeacon_CanUseFunction )

		string scriptName = beacon.GetScriptName()
		if( scriptName == ENEMY_SURVEY_BEACON_SCRIPTNAME )
		{
			AddAnimEvent( beacon, "PlayEffects_SurveyBeacon_Laser", PlayEffects_SurveyBeacon_Laser)
			Perks_AddMinimapEntityForPerk( ePerkIndex.BEACON_ENEMY_SCAN, beacon )
		}
		else if( scriptName == NEXT_ZONE_SURVEY_BEACON_SCRIPTNAME )
		{
			AddAnimEvent( beacon, "PlayEffects_RingConsole_Pulse", PlayEffects_RingConsole_Pulse )
			Perks_AddMinimapEntityForPerk( ePerkIndex.BEACON_SCAN, beacon )
		}
		AddEntityCallback_GetUseEntOverrideText( beacon, GetSurveyBeaconHoldUseTextOverride )

		thread SurveyBeacon_UpdateWorldspaceIconVisibility( beacon )
	}
}

string function GetSurveyBeaconHoldUseTextOverride( entity ent )
{
	string text = Localize( GetBaseHintTextOverride( ent ) )
	if( text == "" )
		return text
	asset icon = SurveyBeacon_GetBeaconIcon( ent )
	return "%$" + icon + "% " + text
}

string function GetBaseHintTextOverride( entity ent )
{
	entity player = GetLocalViewPlayer()
	if( !PlayerShouldSeeSurveyBeaconMarkers( player, ent ) )
	{
		entity beaconUser = GetTeamSurveyBeaconUser( player.GetTeam() )
		if ( HasActiveSurveyZone( beaconUser ) && ent.GetScriptName() == NEXT_ZONE_SURVEY_BEACON_SCRIPTNAME && IsValid( beaconUser ) )
			return "#SURVEY_ALREADY_ACTIVE"
		else
		{
			if( ent.GetScriptName() == NEXT_ZONE_SURVEY_BEACON_SCRIPTNAME )
				return "#CONTROLLER_SURVEY_TEAM_MESSAGE"
			else
				return "#SURVEY_TEAM_MESSAGE"
		}
	}
	else
	{
		int beaconType =  BeaconEntToScanType( ent )
		if( beaconType in file.surveyBeaconData[player] )
		{
			SurveyBeaconData data = file.surveyBeaconData[ player ][beaconType]
			if ( data.canUseFunc != null )
			{
				if ( data.canUseFunc( player, ent ) )
				{
					if( ent.GetScriptName() == NEXT_ZONE_SURVEY_BEACON_SCRIPTNAME )
						return "#RING_CONSOLE_HOLD_PROMPT"
					else
						return "#SURVEY_BEACON_HOLD_PROMPT"
				}
				else
				{
					if( ent.GetScriptName() == NEXT_ZONE_SURVEY_BEACON_SCRIPTNAME )
						return "#SURVEY_ALREADY_ACTIVE"
					else
						return "#SURVEY_ENEMY_ALREADY_ACTIVE"
				}
			}
		}
	}
	return ""
}

void function SurveyBeacon_UpdateWorldspaceIconVisibility( entity beacon )
{
	beacon.EndSignal( "OnDestroy" )

	while( true )
	{
		entity player = expect entity( beacon.WaitSignal( "OnPlayerUse", "OnPlayerUseLong" ).player )
		entity localPlayer = GetLocalViewPlayer()
		if( player != localPlayer )
			continue
		beacon.Signal( "BeaconIconReset" )
		Perks_SetWorldspaceIconVisibility( beacon, false )
		thread SurveyBeacon_ResetWorldSpaceIconVisibilityEndUse( player, beacon )
		thread SurveyBeacon_ResetWorldSpaceIconVisibilityTimer( beacon )
	}
}

void function SurveyBeacon_ResetWorldSpaceIconVisibilityEndUse( entity player, entity beacon )
{
	beacon.EndSignal( "OnDestroy" )
	beacon.EndSignal( "BeaconIconReset" )
	while ( ( player.IsInputCommandHeld( IN_USE ) || player.IsInputCommandHeld( IN_USE_LONG )) && !player.IsPhaseShifted() )
		WaitFrame()
	Perks_SetWorldspaceIconVisibility( beacon, true )
	beacon.Signal( "BeaconIconReset" )
}

void function SurveyBeacon_ResetWorldSpaceIconVisibilityTimer( entity beacon )
{
	beacon.EndSignal( "OnDestroy" )
	beacon.EndSignal( "BeaconIconReset" )
	Wait( 10 )
	Perks_SetWorldspaceIconVisibility( beacon, true )
	beacon.Signal( "BeaconIconReset" )
}

var function SurveyBeacon_CreateHUDMarker( asset beaconImage, entity minimapObj )
{
	entity localViewPlayer = GetLocalViewPlayer()
	vector pos             = minimapObj.GetOrigin() + (minimapObj.GetUpVector() * 96)
	var rui                = CreateFullscreenRui( PERK_IN_WORLD_HUD_OBJECT, RuiCalculateDistanceSortKey( localViewPlayer.EyePosition(), pos ) )
	RuiSetImage( rui, "beaconImage", beaconImage )
	RuiSetGameTime( rui, "startTime", Time() )
	RuiSetFloat3( rui, "pos", pos )
	RuiKeepSortKeyUpdated( rui, true, "pos" )
	return rui
}

entity function GetTeamSurveyBeaconUser( int team )
{
	array<entity> teamArray = GetPlayerArrayOfTeam_AliveConnected( team )
	foreach ( teamMember in teamArray )
	{
		if ( PlayerHasAccessToBeacons( teamMember, null ) )
			return teamMember
	}
	return null
}
#endif

#if SERVER
void function AddSurveyBeaconSpawnCallbacks()
{
	AddSpawnCallbackEditorClass( "prop_dynamic", "script_survival_survey_beacon", SurveyBeacons_AddEnemyBeacon )
	AddSpawnCallbackEditorClass( "prop_script", "script_survival_survey_beacon", SurveyBeacons_AddEnemyBeacon )

	AddSpawnCallbackEditorClass( "prop_dynamic", "script_survival_next_zone_survey_beacon", SurveyBeacons_AddNextZoneBeacon )
	AddSpawnCallbackEditorClass( "prop_script", "script_survival_next_zone_survey_beacon", SurveyBeacons_AddNextZoneBeacon )


	if( SurveyBeacons_ShouldUseNextZoneSurveyBeaconProp() )
	{
		PrecacheModel( $"mdl/communication/terminal_usable_imc_01.rmdl" )
		PrecacheModel( $"mdl/communication/radar_tower_imc_01_animated.rmdl" )
		AddCallback_GameStateEnter( eGameState.Playing, SurveyBeacons_SpawnBeacons )
	}

}

void function OnPanelUse_SurveyBeacon( entity beacon, entity player, entity useEnt )
{
	if ( !( player in file.surveyBeaconData ) )
		return
	int beaconType =  BeaconEntToScanType( beacon )
	if( !( beaconType in file.surveyBeaconData[player] ) )
		return

	file.surveyBeaconData[ player ][beaconType].successFunc( beacon, player, file.surveyBeaconData[player][beaconType] )
}

bool function SurveyBeacon_PopulateHackPanelAnims( entity player, entity panel, HackPanelAnims anims )
{
	if ( !( player in file.surveyBeaconData ) )
		return false
	int beaconType =  BeaconEntToScanType( panel )
	if( !( beaconType in file.surveyBeaconData[player] ) )
		return false

	{
		anims.playerAnimation1pStart = file.surveyBeaconData[ player ][beaconType].anims.playerAnimation1pStart
		anims.playerAnimation1pIdle = file.surveyBeaconData[ player ][beaconType].anims.playerAnimation1pIdle
		anims.playerAnimation1pEnd = file.surveyBeaconData[ player ][beaconType].anims.playerAnimation1pEnd

		anims.playerAnimation3pStart = file.surveyBeaconData[ player ][beaconType].anims.playerAnimation3pStart
		anims.playerAnimation3pIdle = file.surveyBeaconData[ player ][beaconType].anims.playerAnimation3pIdle
		anims.playerAnimation3pEnd = file.surveyBeaconData[ player ][beaconType].anims.playerAnimation3pEnd

		anims.panelAnimation3pStart = file.surveyBeaconData[ player ][beaconType].anims.panelAnimation3pStart
		anims.panelAnimation3pIdle = file.surveyBeaconData[ player ][beaconType].anims.panelAnimation3pIdle
		anims.panelAnimation3pEnd = file.surveyBeaconData[ player ][beaconType].anims.panelAnimation3pEnd

		anims.parentBlendTime = file.surveyBeaconData[ player ][beaconType].anims.parentBlendTime
	}

	return true
}

void function SurveyBeacon_RandomizeBeaconArray( array<entity> surveyBeacons, string propType, vector optionalDebugColor = <0,255,255>, int goal = -1 )
{
	if( goal < 0 )
		goal = GetEnemyScanBeaconGoalNumber()
	array<entity> distributedBeacons
	if( GetIsUnifiedRandomizerEnabled() )
	{
		distributedBeacons = RandomizeNodeLocations( surveyBeacons, GetBaseSurveyBeaconExclusionDistance(), goal, true, propType, optionalDebugColor )
	}
	else
	{
		ArrayRemoveInvalid( surveyBeacons )
		surveyBeacons.randomize()
		array<entity> nonDistributedBeacons
		if ( surveyBeacons.len() >= goal )
		{
			float exclusionDistanceSquared = GetBaseSurveyBeaconExclusionDistance() * GetBaseSurveyBeaconExclusionDistance()
			distributedBeacons.append( surveyBeacons.pop() )

			for ( int i = 0; i < goal - 1; i++ )
			{
				for ( int j = surveyBeacons.len() - 1; j >= 0 ; j-- )
				{
					int count = 0
					entity beacon = surveyBeacons[j]
					foreach ( distributedBeacon in distributedBeacons )
					{
						if ( DistanceSqr( beacon.GetOrigin(), distributedBeacon.GetOrigin() ) > exclusionDistanceSquared )
						{
							count++
						}
					}

					if ( count == distributedBeacons.len() )
					{
						distributedBeacons.append( beacon )
						surveyBeacons.remove( j )
						break
					}
					else
					{
						nonDistributedBeacons.append( beacon )
						surveyBeacons.remove( j )
					}
				}
			}

			int validSpotsFound = distributedBeacons.len()
			if ( validSpotsFound < goal )
			{
				for ( int i = 0; i < goal - validSpotsFound; i++ )
				{
					distributedBeacons.append( nonDistributedBeacons[i] )
				}
			}
		}
		else
		{
			// if we have less then 10 lets just keep all of them.
			distributedBeacons = clone surveyBeacons
			surveyBeacons.clear()
		}

		printt( "[BEACONS PRE COUNT]: " + distributedBeacons.len() )

		//Destroying unused entities
		foreach ( beacon in surveyBeacons )
			beacon.Destroy()

		surveyBeacons.clear()

		for ( int i = nonDistributedBeacons.len() - 1 ; i >= 0 ; i-- )
		{
			if ( !distributedBeacons.contains( nonDistributedBeacons[i] ) )
			{
				nonDistributedBeacons[i].Destroy()
				nonDistributedBeacons.remove( i )
			}
		}

		ArrayRemoveInvalid( distributedBeacons )
	}

	surveyBeacons.clear()
	foreach ( beacon in distributedBeacons )
	{
		array< entity > players = GetPlayerArray()
		array< entity > beaconUsers
		foreach ( player in players )
		{
			beacon.Minimap_Hide( player.GetTeam(), null )
			if ( PlayerShouldSeeSurveyBeaconMarkers( player, beacon ) )
				beaconUsers.append( player )
		}

		foreach ( beaconUser in beaconUsers )
		{
			int team = beaconUser.GetTeam()
			beacon.Minimap_AlwaysShow( team, null )
		}

		surveyBeacons.append( beacon )
	}

	ArrayRemoveInvalid( surveyBeacons )

	printt( "[BEACONS COUNT]: " + surveyBeacons.len() )
}
#endif

#if SERVER
             
                                                                 
 
                            
                                                
                                                                         

                         
                                                              

                            

                                        
  
                                                        
           

                                                                       
           

                                                          
                                                        
  

                              

                                  
                                                                                                               

                           
 

                                                                               
 
                              

             
                                              
   
                                          
   
  

         
 
      
#endif

void function OnDeactivate_BeaconScan( entity player )
{
	if ( !( player in file.surveyBeaconData ) )
		return

	delete file.surveyBeaconData[ player ]
}
#endif

#if CLIENT
void function SurveyBeacon_AddSurveyBeaconMinimapPackage()
{
	// purposefully empty to support the live version of survey beacons, can remove once we're transitioned over to the perk beacons
}
#endif