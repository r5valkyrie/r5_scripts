global function Perk_NextZoneBeaconScan_Init
global function SurveyBeacons_ShouldUseNextZoneSurveyBeaconProp

#if CLIENT
global function PlayEffects_RingConsole_Pulse
#endif

#if SERVER || CLIENT
global function OnActivate_BeaconScan_Circle
global function Perk_NextZoneSurveyBeacon_GetNextZoneBeaconForEntHit
#endif

#if SERVER
global function SurveyBeacons_AddNextZoneBeacon
global function SurveyBeacons_SpawnBeacons
global function Perk_NextZoneSurveyBeacon_GetSpawnedBeacons
global function Perk_NextZoneSurveyBeacon_ListenForScannedZoneEntered
global function AddCallback_OnRingConsoleScanned
global function SurveyBeacons_SpawnBeaconAtLocation


struct
{
	bool useEditorPlacedBeacons
	array<entity> surveyBeacons
	array< void functionref( entity, entity ) > onRingConsoleScannedCallbacks
} file
#endif



void function Perk_NextZoneBeaconScan_Init()
{
	if ( !(GetCurrentPlaylistVarBool( "disable_perk_beacon_scan", false ) ) )
	{
		PerkInfo beaconScan
		beaconScan.perkId          = ePerkIndex.BEACON_SCAN
		#if SERVER || CLIENT
			beaconScan.activateCallback = OnActivate_BeaconScan_Circle
			beaconScan.deactivateCallback = OnDeactivate_BeaconScan
			beaconScan.minimapStateIndex = eMinimapObject_prop_script.NEXT_ZONE_SURVEY_BEACON
			beaconScan.minimapPingType = ePingType.ENCRYPTED_CONSOLE
			beaconScan.mapFeatureTitle = "#PERK_FEATURE_RING_CONSOLE"
			beaconScan.mapFeatureDescription = "#PERK_FEATURE_RING_CONSOLE_DESC"
		#endif
		#if CLIENT
			beaconScan.worldspaceIconUpOffset = 96
			beaconScan.ruiThinkThread = SurveyBeacons_RingConsole_RuiUpdate
		#endif
		Perks_RegisterClassPerk( beaconScan )

		#if SERVER || CLIENT
		if( SurveyBeacons_UseNewNextZoneBeaconModel() )
		{
			PrecacheModel($"mdl/props/controller_console/controller_console.rmdl")
		}


			AddCallback_OnPassiveChanged( ePassives.PAS_UPGRADE_CONSOLE_SCAN, OnPassiveChangedConsoleScanUpgrade )

		#endif

		#if CLIENT
		PrecacheParticleSystem( $"P_ring_console_pulse" )
		#endif
	}

	#if SERVER
		//Fix for [R5DEV-576600 & R5DEV-577043] prevents hard coded consoles from spawning in when the Map file doesn't have any consoles placed/authored.
		file.useEditorPlacedBeacons = true
	#endif

}


#if SERVER || CLIENT
void function OnPassiveChangedConsoleScanUpgrade( entity player, int passive, bool didHave, bool nowHas )
{
	if( nowHas )
	{
		Perks_AddPerk( player, ePerkIndex.BEACON_SCAN )
	}
}
#endif



bool function SurveyBeacons_ShouldUseNextZoneSurveyBeaconProp()
{
	#if SERVER || CLIENT
	if( GetMapName().find( "mp_rr_box" ) >= 0 )
	{
		return true
	}
	#endif
	return  GetCurrentPlaylistVarBool("use_seperate_controller_perk_beacon_scan_prop", true )
}

bool function SurveyBeacons_UseNewNextZoneBeaconModel()
{
	return  GetCurrentPlaylistVarBool("perk_next_zone_beacon_use_new_model", true )
}

#if SERVER || CLIENT
entity function Perk_NextZoneSurveyBeacon_GetNextZoneBeaconForEntHit( entity ent )
{
	if( ent.GetScriptName() == NEXT_ZONE_SURVEY_BEACON_SCRIPTNAME )
		return ent
	entity entParent = ent.GetParent()
	if( IsValid( entParent ) && entParent.GetScriptName() == NEXT_ZONE_SURVEY_BEACON_SCRIPTNAME )
		return entParent
	return null
}

void function OnActivate_BeaconScan_Circle( entity player, string characterName )
{
	string calloutLine, player1pAnim, player3pAnim, panelAnim

	calloutLine = "bc_revealNextRingLocation"

	switch ( characterName )
	{
		// fill in character specific scan animations here
		default:
			break
	}

	RegisterNextZoneSurveyBeaconData( player, calloutLine, player1pAnim, player3pAnim, panelAnim )
}

void function RegisterNextZoneSurveyBeaconData( entity player, string calloutLine, string player1pAnim, string player3pAnim, string panelAnim )
{
	SurveyBeaconData data
	data.canUseFunc = Recon_CanUseBeacon
	#if SERVER
		data.successFunc = Recon_SurveySuccess
	#endif
	data.calloutLine = calloutLine
	data.scanType = eBeaconScanType.BEACON_SCAN_CIRCLE

	#if SERVER

		if ( player1pAnim != "" )
			player1pAnim += "_"

		if ( player3pAnim == "" )
			player3pAnim = "pilot"

		if ( panelAnim != "" )
			panelAnim += "_"

		if( SurveyBeacons_UseNewNextZoneBeaconModel() )
		{
			data.anims.playerAnimation1pStart = "pov_"+ player1pAnim + "console_hack_start"
			data.anims.playerAnimation1pIdle  = "pov_"+ player1pAnim + "console_hack_mid"
			data.anims.playerAnimation1pEnd   = "pov_"+ player1pAnim + "console_hack_end"

			data.anims.playerAnimation3pStart = player3pAnim +"_console_hack_start"
			data.anims.playerAnimation3pIdle  = player3pAnim +"_console_hack_mid"
			data.anims.playerAnimation3pEnd   = player3pAnim +"_console_hack_end"

			data.anims.panelAnimation3pStart  = "controller_" + panelAnim + "console_hack_start"
			data.anims.panelAnimation3pIdle   = "controller_" + panelAnim + "console_hack_mid"
			data.anims.panelAnimation3pEnd    = "controller_" + panelAnim + "console_hack_end"
		}
		else if( SurveyBeacons_ShouldUseNextZoneSurveyBeaconProp() )
		{
			data.anims.playerAnimation1pStart = "ptpov_data_knife_console_leech_start"

			data.anims.playerAnimation1pIdle = "ptpov_data_knife_console_leech_idle"
			data.anims.playerAnimation1pEnd  = "ptpov_data_knife_console_leech_end"

			data.anims.playerAnimation3pStart = "pt_data_knife_console_leech_start"
			data.anims.playerAnimation3pIdle  = "pt_data_knife_console_leech_idle"
			data.anims.playerAnimation3pEnd   = "pt_data_knife_console_leech_end"

			data.anims.panelAnimation3pStart = "tm_data_knife_console_leech_start"
			data.anims.panelAnimation3pIdle  = "tm_data_knife_console_leech_idle"
			data.anims.panelAnimation3pEnd   = "tm_data_knife_console_leech_end"
		}
		else
		{
			data.anims.playerAnimation1pStart = "pov_"+ player1pAnim + "antenna_hack_start"
			data.anims.playerAnimation1pIdle  = "pov_"+ player1pAnim + "antenna_hack_mid"
			data.anims.playerAnimation1pEnd   = "pov_"+ player1pAnim + "antenna_hack_end"

			data.anims.playerAnimation3pStart = player3pAnim +"_antenna_hack_start"
			data.anims.playerAnimation3pIdle  = player3pAnim +"_antenna_hack_mid"
			data.anims.playerAnimation3pEnd   = player3pAnim +"_antenna_hack_end"

			data.anims.panelAnimation3pStart  = "beacon_" + panelAnim + "antenna_hack_start"
			data.anims.panelAnimation3pIdle   = "beacon_" + panelAnim + "antenna_hack_mid"
			data.anims.panelAnimation3pEnd    = "beacon_" + panelAnim + "antenna_hack_end"
		}

		data.anims.parentBlendTime = .3
	#endif

	RegisterSurveyBeaconData( player, data )
}

bool function Recon_CanUseBeacon( entity player, entity beacon )
{
	if ( HasActiveSurveyZone( player ) )
	{
		return false
	}

	if( SurveyBeacons_ShouldUseNextZoneSurveyBeaconProp() && beacon.GetScriptName() != NEXT_ZONE_SURVEY_BEACON_SCRIPTNAME )
		return false

	return true
}

#if SERVER
void function Perk_NextZoneSurveyBeacon_ListenForScannedZoneEntered( entity player, entity zone, float radius )
{
	player.EndSignal( "OnDestroy" )
	zone.EndSignal( "OnDestroy" )

	vector zoneOrigin = zone.GetOrigin()
	while( Distance2DSqr( player.GetOrigin(), zoneOrigin ) > radius * radius )
	{
		Wait( .5 )
	}
	StatsHook_ScannedRingLocationReached( player )
}

array<entity> function Perk_NextZoneSurveyBeacon_GetSpawnedBeacons()
{
	return file.surveyBeacons
}

void function SurveyBeacons_SpawnBeacons()
{
	if( file.useEditorPlacedBeacons )
		return

	string mapName = GetMapName()

	if( mapName.find( "mp_rr_box" ) >= 0 )
	{
		SurveyBeacons_SpawnBeaconAtLocation( <-282.345337, -38.402081, 128.031250> )
	}
	else if( mapName.find( "mp_rr_divided_moon" ) >= 0 )
	{
		SurveyBeacons_SpawnBeaconAtLocation( <-32692.738281, 30145.658203, -719.988770> )
		SurveyBeacons_SpawnBeaconAtLocation( <-28606.027344, 10021.839844, 1120.031250> )
		SurveyBeacons_SpawnBeaconAtLocation( <-32948.554688, -3831.805176, 1135.623657> )
		SurveyBeacons_SpawnBeaconAtLocation( <-30356.632813, -33632.890625, 1729.311279> )
		SurveyBeacons_SpawnBeaconAtLocation( <-10617.759766, -34367.460938, 3359.158203> )
		SurveyBeacons_SpawnBeaconAtLocation( <25439.869141, -14881.503906, 5313.961426> )
		SurveyBeacons_SpawnBeaconAtLocation( <9117.036133, 13695.792969, 1382.184204> )
		SurveyBeacons_SpawnBeaconAtLocation( <24766.591797, 13175.923828, 1099.031250> )
		SurveyBeacons_SpawnBeaconAtLocation( <-8301.664063, 15601.999023, 2103.147461> )
	}
	else if( mapName.find( "mp_rr_desertlands" ) >= 0 )
	{
		SurveyBeacons_SpawnBeaconAtLocation( <-9958.700195, 25837.388672, -3917.968750  > )
		SurveyBeacons_SpawnBeaconAtLocation( <-18893.453125, 22937.664063, -4039.968750> )
		SurveyBeacons_SpawnBeaconAtLocation( <-28710.753906, 13417.854492, -3168.968750> )
		SurveyBeacons_SpawnBeaconAtLocation( <-14722.307617, 5024.457031, -3364.917969> )
		SurveyBeacons_SpawnBeaconAtLocation( <-28161.132813, -1234.975098, -4353.517578> )
		SurveyBeacons_SpawnBeaconAtLocation( <-15601.272461, -6609.960449, -3791.968750> )
		SurveyBeacons_SpawnBeaconAtLocation( <-22971.960938,-20435.048828, -4080.118652> )
		SurveyBeacons_SpawnBeaconAtLocation( <-17631.423828, -29836.792969, -3471.968750> )
		SurveyBeacons_SpawnBeaconAtLocation( <-7203.204590, -32773.761719, -3469.771484> )
		SurveyBeacons_SpawnBeaconAtLocation( <-3498.500732, 19415.720703, -2674.899658> )
		SurveyBeacons_SpawnBeaconAtLocation( <-3220.896240, -11570.229492, -3679.937012> )
		SurveyBeacons_SpawnBeaconAtLocation( <12391.808594, 19926.253906, -5071.968750> )
		SurveyBeacons_SpawnBeaconAtLocation( <9581.823242, 5713.517578, -4295.968750> )
		SurveyBeacons_SpawnBeaconAtLocation( <4567.571777, -18824.855469, -3191.842285> )
		SurveyBeacons_SpawnBeaconAtLocation( <2305.183350, -39548.160156, -2735.968750> )
		SurveyBeacons_SpawnBeaconAtLocation( <17055.146484, 29126.835938, -4841.968750> )
		SurveyBeacons_SpawnBeaconAtLocation( <19595.105469, 656.310791, -3975.968750> )
		SurveyBeacons_SpawnBeaconAtLocation( <23853.941406, -26807.742188, -3511.968750> )
		SurveyBeacons_SpawnBeaconAtLocation( <19009.162109, -40457.265625, -2220.297363> )
		SurveyBeacons_SpawnBeaconAtLocation( <27660.658203, 11547.723633, -3333.049805> )
	}
	else if( mapName.find( "mp_rr_canyonlands" ) >= 0 )
	{
		SurveyBeacons_SpawnBeaconAtLocation( <-8618.167969, 37934.683594, 6402.031250 > )
		SurveyBeacons_SpawnBeaconAtLocation( <3337.708008, 30744.855469, 4772.031250> )
		SurveyBeacons_SpawnBeaconAtLocation( <-18928.746094, 23178.765625, 2227.729248> )
		SurveyBeacons_SpawnBeaconAtLocation( <-4826.879395, 19045.326172, 2782.031250> )
		SurveyBeacons_SpawnBeaconAtLocation( <-23603.609375, 10020.175781, 3028.031250> )
		SurveyBeacons_SpawnBeaconAtLocation( <-23922.341797, -206.924576, 2520.031250> )
		SurveyBeacons_SpawnBeaconAtLocation( <-9966.645508, 5182.722656, 2847.031250> )
		SurveyBeacons_SpawnBeaconAtLocation( <-12212.005859, -16029.654297, 2429.584961> )
		SurveyBeacons_SpawnBeaconAtLocation( <2152.102539, -10889.414063, 2760.031250> )
		SurveyBeacons_SpawnBeaconAtLocation( <-4291.857422, 8945.756836, 3476.031250> )
		SurveyBeacons_SpawnBeaconAtLocation( <-3758.779541, -730.926086, 2330.011230> )
		SurveyBeacons_SpawnBeaconAtLocation( <7929.795410, -30701.068359, 3440.031250> )
		SurveyBeacons_SpawnBeaconAtLocation( <14120.239258, -18030.107422, 4016.031250> )
		SurveyBeacons_SpawnBeaconAtLocation( <26901.416016, -13969.294922, 4668.031250> )
		SurveyBeacons_SpawnBeaconAtLocation( <26906.619141, -4561.704590, 4336.031250> )
		SurveyBeacons_SpawnBeaconAtLocation( <15557.487305, -1399.980347, 3868.031250> )
		SurveyBeacons_SpawnBeaconAtLocation( <36031.734375, 3025.425293, 3088.031250> )
		SurveyBeacons_SpawnBeaconAtLocation( <27371.652344, 6520.413086, 2873.305176> )
		SurveyBeacons_SpawnBeaconAtLocation( <20309.058594, 9640.453125, 4088.031250> )
		SurveyBeacons_SpawnBeaconAtLocation( <15093.144531, 14202.695313, 5040.031250> )
		SurveyBeacons_SpawnBeaconAtLocation( <25577.574219, 25455.869141, 4072.031250> )
	}
	else if( mapName.find( "mp_rr_tropic_island" ) >= 0 )
	{
		SurveyBeacons_SpawnBeaconAtLocation(< -32812.449219, 20702.289063, 517.335815> )
		SurveyBeacons_SpawnBeaconAtLocation(< -24481.128906, 34110.089844, 193.184082> )
		SurveyBeacons_SpawnBeaconAtLocation(< 7395.680664, 39618.992188, 3994.031250> )
		SurveyBeacons_SpawnBeaconAtLocation(< 38003.320313, 36679.453125, 11010.530273> )
		SurveyBeacons_SpawnBeaconAtLocation(< -17043.871094, 19441.771484, 2864.031250> )
		SurveyBeacons_SpawnBeaconAtLocation(< 3418.176025, 23813.466797, 3014.020508> )
		SurveyBeacons_SpawnBeaconAtLocation(< 23034.109375, 27392.988281, 12226.931641> )
		SurveyBeacons_SpawnBeaconAtLocation(< 30519.750000, 25006.048828, 8984.031250> )
		SurveyBeacons_SpawnBeaconAtLocation(< 25457.894531, 12028.933594, 6502.053711> )
		SurveyBeacons_SpawnBeaconAtLocation(< 368.096741, 13255.941406, 1855.111206> )
		SurveyBeacons_SpawnBeaconAtLocation(< 9175.887695, 2191.105225, 742.031250> )
		SurveyBeacons_SpawnBeaconAtLocation(< -32739.035156, 2223.849854, 701.260559 > )
		SurveyBeacons_SpawnBeaconAtLocation(< 17694.437500, -6117.665039, 967.485840> )
		SurveyBeacons_SpawnBeaconAtLocation(< -1759.881592, -12188.732422, 1103.456299> )
		SurveyBeacons_SpawnBeaconAtLocation(< 29908.943359, -11805.055664, 208.627213> )
		SurveyBeacons_SpawnBeaconAtLocation(< 8695.030273, -18243.406250, 632.031250> )
		SurveyBeacons_SpawnBeaconAtLocation(< -36032.207031, -24483.685547, 440.370270> )
		SurveyBeacons_SpawnBeaconAtLocation(< -41232.011719, -13500.082031, 213.562759> )
		SurveyBeacons_SpawnBeaconAtLocation(< -11817.183594, -25290.904297, 376.020264> )
		SurveyBeacons_SpawnBeaconAtLocation(< 2285.602539, -32918.742188, 902.831238> )
		SurveyBeacons_SpawnBeaconAtLocation(< 32733.869141, -34774.046875, 218.031250> )
	}
	else if( mapName.find( "mp_rr_olympus" ) >= 0 )
	{
		SurveyBeacons_SpawnBeaconAtLocation( < -19103.269531, 28385.769531, -6367.208984 > )
		SurveyBeacons_SpawnBeaconAtLocation( < 3805.853271, 20377.441406, -6016.344727 > )
		SurveyBeacons_SpawnBeaconAtLocation( < -5407.738770, 22033.958984, -6140.381348 > )
		SurveyBeacons_SpawnBeaconAtLocation( < -26473.984375, 22668.082031, -6511.968750 > )
		SurveyBeacons_SpawnBeaconAtLocation( < -32411.898438, 10620.551758, -5511.968750 > )
		SurveyBeacons_SpawnBeaconAtLocation( < -14108.798828, 11559.426758, -6562.038574 > )
		SurveyBeacons_SpawnBeaconAtLocation( < -139.025558, 9824.157227, -4992.672852 > )
		SurveyBeacons_SpawnBeaconAtLocation( < 16023.904297, 10350.119141, -3577.609375 > )
		SurveyBeacons_SpawnBeaconAtLocation( < -23517.605469, 519.045959, -5545.552246 > )
		SurveyBeacons_SpawnBeaconAtLocation( < -5687.911621, -958.784241, -6119.968750 > )
		SurveyBeacons_SpawnBeaconAtLocation( < 15552.840820, -643.055969, -4704.652832 > )
		SurveyBeacons_SpawnBeaconAtLocation( < -44106.371094, -9354.555664, -3334.743896 > )
		SurveyBeacons_SpawnBeaconAtLocation( < -36673.941406, -15100.648438, -3469.937500 > )
		SurveyBeacons_SpawnBeaconAtLocation( < -17946.802734, -25454.884766, -4731.928711 > )
		SurveyBeacons_SpawnBeaconAtLocation( < -531.367432, -35409.812500, -4447.943359 > )
		SurveyBeacons_SpawnBeaconAtLocation( < 11482.638672, -26330.173828, -5404.838867 > )
		SurveyBeacons_SpawnBeaconAtLocation( < 892.178162, -15378.271484, -5854.968750 > )
		SurveyBeacons_SpawnBeaconAtLocation( < 24013.253906, -18174.181641, -5191.968750 > )
	}

	SurveyBeacon_RandomizeBeaconArray( file.surveyBeacons, ePropPlacementType.RING_CONSOLE )
	SurveyBeacon_PruneInvalidBeacons()
}

void function SurveyBeacons_SpawnBeaconAtLocation( vector position )
{
	entity beacon = CreateEntity( "prop_script" )
	beacon.SetOrigin( position )
	beacon.SetModel( $"mdl/communication/terminal_usable_imc_01.rmdl" )
	beacon.kv.solid = 6
	beacon.Solid()
	DispatchSpawn( beacon )

	SurveyBeacons_AddNextZoneBeacon_Internal( beacon )
}

void function SurveyBeacons_AddNextZoneBeacon( entity beaconMarker )
{
	file.useEditorPlacedBeacons = true
	SurveyBeacons_AddNextZoneBeacon_Internal( beaconMarker )
}

void function SurveyBeacons_AddNextZoneBeacon_Internal( entity beaconMarker )
{
	if( !SurveyBeacons_ShouldUseNextZoneSurveyBeaconProp() )
	{
		beaconMarker.Destroy()
		return
	}

	if( SurveyBeacons_UseNewNextZoneBeaconModel() )
	{
		entity newMarker = CreateEntity( "prop_script" )
		newMarker.SetOrigin( beaconMarker.GetOrigin() )
		newMarker.SetAngles( beaconMarker.GetAngles() )
		newMarker.SetValueForModelKey( $"mdl/props/controller_console/controller_console.rmdl"  )
		newMarker.kv.solid = 6
		newMarker.Solid()
		newMarker.SetScriptName( beaconMarker.GetScriptName() )
		DispatchSpawn( newMarker )
		beaconMarker.Destroy()
		beaconMarker = newMarker
	}
	else
	{
		vector forward = beaconMarker.GetForwardVector()
		entity radarProp = CreateEntity( "prop_script" )
		radarProp.SetValueForModelKey( $"mdl/communication/radar_tower_imc_01_animated.rmdl" )
		radarProp.SetOrigin( beaconMarker.GetOrigin() - forward * 20 )
		radarProp.SetAngles( beaconMarker.GetAngles() )
		radarProp.SetModelScale( .4 )
		DispatchSpawn( radarProp )
		radarProp.Anim_Play( "communication/radar_tower_imc_01_animated/idle_spinning" )

		entity spaceBlocker = CreateEntity( "prop_script" )
		spaceBlocker.SetValueForModelKey( beaconMarker.GetModelName() )
		spaceBlocker.SetOrigin( beaconMarker.GetOrigin() - forward * 25 )
		spaceBlocker.SetAngles( beaconMarker.GetAngles() )
		spaceBlocker.kv.solid = 6
		spaceBlocker.Solid()
		spaceBlocker.MakeInvisible()
		DispatchSpawn( spaceBlocker )
	}

	file.surveyBeacons.append( beaconMarker )

	SurveyBeacons_AddBeacon( beaconMarker, NEXT_ZONE_SURVEY_BEACON_SCRIPTNAME )
	SetControlPanelUsePrompts( beaconMarker, "#RING_CONSOLE_HOLD_PROMPT", "#RING_CONSOLE_HOLD_PROMPT" )
	Perks_AddMinimapEntityForPerk( ePerkIndex.BEACON_SCAN, beaconMarker )
	PIN_Perks_RingConsoleCreated( beaconMarker, beaconMarker.GetOrigin() )
}

void function AddCallback_OnRingConsoleScanned( void functionref( entity, entity ) func )
{
	Assert( !file.onRingConsoleScannedCallbacks.contains( func ), "Already added " + string( func ) + " with AddCallback_OnRingConsoleScanned" )
	file.onRingConsoleScannedCallbacks.append( func )
}

void function Recon_SurveySuccess( entity beacon, entity player, SurveyBeaconData data )
{
	int team = player.GetTeam()

	string calloutLine = data.calloutLine

	if ( calloutLine != "" )
		PlayBattleChatterLineToSpeakerAndTeam( player, calloutLine )

	SURVIVAL_ShowSurveyRegionOnSquadMaps( player )





	Remote_CallFunction_NonReplay( player, "ServerCallback_SurveyBeaconNotifications", beacon, ePathfinderNotifications.TEAM_SUCCESS )

	StatsHook_RingConsoleScanned( player )
	PIN_Perks_RingConsoleScanned( player, beacon.GetOrigin() )

	if ( PlayerHasPassive( player, ePassives.PAS_PATHFINDER ) )
	{
		GrantPathfinderCooldownReduction( player )
	}

	foreach( func in file.onRingConsoleScannedCallbacks )
	{
		func( player, beacon )
	}
}


#endif
#endif // #if SERVER || CLIENT

#if CLIENT
void function PlayEffects_RingConsole_Pulse( entity beacon )
{
	array<entity> children = beacon.GetChildren()
	bool foundLocalPlayer = false
	entity localPlayer = GetLocalViewPlayer()
	foreach( entity child in children )
	{
		if( child == localPlayer )
		{
			foundLocalPlayer = true
			break
		}
	}

	if( !foundLocalPlayer )
		return

	EmitSoundOnEntity( beacon, "Controller_RingConsole_ScanPulse_3P" )

	int fxIdx = GetParticleSystemIndex( $"P_ring_console_pulse" )
	string attachPoint = "fx_disc_top"
	int attachIdx = beacon.LookupAttachment( attachPoint )
	StartParticleEffectOnEntity( beacon, fxIdx, FX_PATTACH_POINT_FOLLOW, attachIdx )
}

void function SurveyBeacons_RingConsole_RuiUpdate( var rui, entity ent )
{
	ent.EndSignal( "OnDestroy" )
	ent.EndSignal( "HidePerkMinimapVisibility" )
	clGlobal.levelEnt.EndSignal( "UpdatePerkMinimapVisibility" )

	while( true )
	{
		entity localPlayer = GetLocalViewPlayer()
		bool canUse = !HasActiveSurveyZone( localPlayer )
		vector color = canUse ? INTERACTIBLE_PERK_MINIMAP_COLOR : NON_INTERACTIBLE_PERK_MINIMAP_COLOR
		RuiSetFloat3( rui, "iconColor", color )
		Wait( .5 )
	}
}
#endif