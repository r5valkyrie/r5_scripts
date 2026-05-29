global function AirdropExtra_Init
global function AirdropExtravaganza_RegisterNetworking

#if SERVER
global function AirdropExtravaganza_ThrowExtraLootForPod
global function AirdropExtravaganza_ThrowThrowExtraLootForPodDoor
global function AirdropExtravaganzaDropRespawnCluster
global function AirdropExtravaganzaAirdropCluster
global function AirdropExtravaganzaRunInitialDropList
global function AirdropExtravaganza_CreateNewClusterEntity
global function AirdropExtravaganza_GetClusterEntities
global function AirdropExtravaganazaAddAirdropPodToTrackedArray
global function AirdropExtravaganza_GetTrackedAirdropPods
global function AirdropExtravaganazaCleanupPod
#endif

struct
{
#if SERVER
	//Cluster data
	//int standardClusterCount
	int upgradeClusterCount
	//int initialClusterCount
	int lootConfettiCount

	float clusterDelayBase
	float clusterDelayVariance
	float clusterDelayBetweenPods
	float clusterBaseDistance
	float clusterFailAddDistance

	array<int> clusterCountByRarity
	array< array<string> >  clusterContentsByTier
	array<entity> clusterZoneEnts
	array<entity> airdropPods
	array< array<vector> > clusterAirdropPositions

	//hotzone
	bool hotzoneEnabled
	bool hotzoneLaunched
	array<string> clusterContentsHotzone

	array<int> airdropSuccess

#endif

} file


global const string AIRDROPEXTRA_ANIMATION 		= "droppod_loot_drop_multi"
const int AIRDROPEXTRA_CLUSTER_COUNT 			= 1
const int AIRDROPEXTRA_LOOT_CONFETTI_COUNT 		= 3
const float AIRDROPEXTRA_CLUSTER_DELAY_BASE		= 6.0
const float AIRDROPEXTRA_CLUSTER_DELAY_VARIANCE	= 1.5
const float AIRDROPEXTRA_CLUSTER_DELAY_BETWEEN	= 1.0
const float AIRDROPEXTRA_CLUSTER_DISTANCE		= 800.0
const float AIRDROPEXTRA_CLUSTER_FAIL_MOD_DIST	= 150.0
const int AIRDROPEXTRA_CLUSTER_PLACEMENT_TRIES 	= 10
const float AIRDROPEXTRA_CLUSTER_MIN_DIST		= 30.0

void function AirdropExtra_Init()
{
	#if SERVER
		Survival_AddCallback_OnAirdropRoundMessaging( AirdropExtravaganzaAirdropRoundMessaging )
		Survival_AddCallback_OnAirdropRoundLaunchRequest( AirdropExtravaganzaAirdropLaunchRequest )
		Survival_AddCallback_OnAirdropLaunched( AirdropExtravaganazaAddAirdropPodToTrackedArray )
		if ( GetCurrentPlaylistVarBool( "airdrop_ltm_custom_UI_enabled", false ) )
			Survival_AddCallback_OnAirdropPositionsDetermined( AirdropExtravaganazaDetermineClusterPositions )

		if ( GetCurrentPlaylistVarBool( "airdrop_ltm_airdrop_on_respawn_enabled", false ) )
			AddCallback_OnTeammatesRespawned( AirdropExtravaganzaDropRespawnCluster )
		if ( GetCurrentPlaylistVarBool( "airdrop_ltm_airdrop_on_landing_enabled", false ) )
			Survival_AddCallback_OnPlayerLandedFromDropshipFreefall( AirdropExtravaganzaPlayerLandedFromFreefall )

		//file.standardClusterCount = GetCurrentPlaylistVarInt( "airdrop_ltm_standard_cluster_count", AIRDROPEXTRA_CLUSTER_COUNT )
		file.upgradeClusterCount = GetCurrentPlaylistVarInt( "airdrop_ltm_upgrade_cluster_count", AIRDROPEXTRA_CLUSTER_COUNT )
		//file.initialClusterCount = GetCurrentPlaylistVarInt( "airdrop_ltm_initial_cluster_count", AIRDROPEXTRA_CLUSTER_COUNT )
		file.lootConfettiCount = GetCurrentPlaylistVarInt( "airdrop_ltm_lootconfetti_count", AIRDROPEXTRA_LOOT_CONFETTI_COUNT )

		if ( file.lootConfettiCount > 0 )
			Survival_AddCallback_OnAirdropOpened( AirdropExtravaganzaPodOpened )

		ParseClusterContent()
	#endif

	#if CLIENT
		if ( GetCurrentPlaylistVarBool( "airdrop_ltm_custom_UI_enabled", false ) )
		{
			SURVIVAL_SetGameStateAssetOverrideCallback( AirdropExtravaganzaOverrideGamestateUI )
		}
	#endif

	AirdropExtravaganza_RegisterNetworking()
}

void function AirdropExtravaganza_RegisterNetworking()
{
	RegisterNetworkedVariable( "AirdropExtra_AirdropTier", SNDC_GLOBAL, SNVT_INT, -1 )
	RegisterNetworkedVariable( "AirdropExtra_AirdropProgress", SNDC_GLOBAL, SNVT_INT, -1 )
	RegisterNetworkedVariable( "AirdropExtra_AirdropCount", SNDC_GLOBAL, SNVT_INT, -1 )


	#if CLIENT
		if ( GetCurrentPlaylistVarBool( "airdrop_ltm_custom_UI_enabled", false ) )
		{
			RegisterNetVarIntChangeCallback( "AirdropExtra_AirdropTier", OnServerVarChanged_AirdropExtra_AirdropTier )
			RegisterNetVarIntChangeCallback( "AirdropExtra_AirdropProgress", OnServerVarChanged_AirdropExtra_AirdropProgress )
			RegisterNetVarIntChangeCallback( "AirdropExtra_AirdropCount", OnServerVarChanged_AirdropExtra_AirdropProgress )
		}
	#endif
}

#if SERVER

void function ParseClusterContent()
{
	for ( int i = 0; i < eLootTier._count; i++ )
	{
		string clusterLootDataTier = GetCurrentPlaylistVarString( "airdrop_ltm_cluster_contents_" + i, "" )
		int clusterCountData = GetCurrentPlaylistVarInt("airdrop_ltm_cluster_count_" + i, 0)

		if ( clusterLootDataTier == "" )
			printf( "Cluster loot data for tier " + i + " does not exist." )

		array<string> clusterLootData = GetTrimmedSplitString( clusterLootDataTier, ":" )
		file.clusterContentsByTier.append( clusterLootData )
		file.clusterCountByRarity.append( clusterCountData )
	}

	file.clusterDelayBase = GetCurrentPlaylistVarFloat( "airdrop_cluster_delayBase_override", AIRDROPEXTRA_CLUSTER_DELAY_BASE )
	file.clusterDelayVariance = GetCurrentPlaylistVarFloat( "airdrop_cluster_delayVar_override", AIRDROPEXTRA_CLUSTER_DELAY_VARIANCE )
	file.clusterDelayBetweenPods = GetCurrentPlaylistVarFloat( "airdrop_cluster_delayBetween_override", AIRDROPEXTRA_CLUSTER_DELAY_BETWEEN )
	file.clusterBaseDistance = GetCurrentPlaylistVarFloat( "airdrop_cluster_distance_base", AIRDROPEXTRA_CLUSTER_DISTANCE )
	file.clusterFailAddDistance = GetCurrentPlaylistVarFloat( "airdrop_cluster_distance_failMod", AIRDROPEXTRA_CLUSTER_FAIL_MOD_DIST )

	file.hotzoneEnabled = GetCurrentPlaylistVarBool( "airdrop_ltm_hotzone_enabled", false )
	if ( file.hotzoneEnabled )
	{
		string clusterHotzoneData = GetCurrentPlaylistVarString( "airdrop_ltm_hotzone_contents", "" )
		if ( clusterHotzoneData != "" )
			file.clusterContentsHotzone = GetTrimmedSplitString( clusterHotzoneData, ":" )
		else
			printf( "Cluster loot data for hotzone does not exist." )
	}
}

void function AirdropExtravaganzaRunInitialDropList( array <AirdropRoundData> pregameAirdropData )
{
	foreach ( apData in pregameAirdropData )
	{
		wait apData.preWait

		if (!apData.launched)
		{
			waitthread Survival_LaunchAirdropsFromAirdropData( apData )
			apData.launched = true
		}
		else
			printf("Pregame airdrop data already launched. Skipping.")
	}
}

void function AirdropExtravaganza_ThrowExtraLootForPod( entity dropPod, int lootCountPerDoor )
{
	array<string> doors = [ "L", "R", "C" ]

	wait 0.75

	for ( int i = 0; i < doors.len(); i++ )
	{
		string lootAttachmentRef = "LOOT_" + doors[i] + "_MID"
		int lootAttachmentPoint  = dropPod.LookupAttachment( lootAttachmentRef )
		vector attachmentAngles  = dropPod.GetAttachmentAngles( lootAttachmentPoint )
		vector lootAngles        = AnglesCompose( attachmentAngles, <0,0,0> )
		vector lootOrigin        = dropPod.GetAttachmentOrigin( lootAttachmentPoint ) + ( AnglesToForward( lootAngles ) * 10)

		vector up     = AnglesToUp( attachmentAngles )
		vector fwd    = AnglesToForward( attachmentAngles )
		vector rgt    = AnglesToRight( attachmentAngles )
		vector offset = < (fwd.x * lootOrigin.x), (rgt.y * lootOrigin.y ), ( up.z * lootOrigin.z) >

		if ( i == 0 )
			thread AirdropExtravaganza_ThrowThrowExtraLootForPodDoor ( lootOrigin, fwd, "Airdrop_LTM_Health_Confetti", lootCountPerDoor )
		else if ( i == 1 )
			thread AirdropExtravaganza_ThrowThrowExtraLootForPodDoor ( lootOrigin, fwd, "Airdrop_LTM_Ammo_Confetti", lootCountPerDoor )
		else if ( i == 2 )
			thread AirdropExtravaganza_ThrowThrowExtraLootForPodDoor ( lootOrigin, fwd, "Airdrop_LTM_AmmoOrd_Confetti", lootCountPerDoor )
		wait 0.1
	}
}

void function AirdropExtravaganza_CreateNewClusterEntity( vector origin, int rarity, float clusterRadius = 2000.0 )
{
	entity clusterEnt = CreateEntity ( "prop_script" )

	file.clusterZoneEnts.append( clusterEnt )

	clusterEnt.SetValueForModelKey( $"mdl/dev/empty_model.rmdl" )
	clusterEnt.kv.fadedist = -1
	clusterEnt.kv.renderamt = 255
	clusterEnt.kv.rendercolor = "255 255 255"
	clusterEnt.kv.solid = 6
	clusterEnt.SetOrigin( origin )
	clusterEnt.SetAngles( <0, 0, 0> )
	clusterEnt.NotSolid()
	clusterEnt.Hide()
	clusterEnt.DisableHibernation()
	float radius = min( 65536.0, clusterRadius )
	clusterEnt.Minimap_SetObjectScale( radius / SURVIVAL_MINIMAP_RING_SCALE )
	clusterEnt.Minimap_SetAlignUpright( true )
	clusterEnt.Minimap_SetZOrder( MINIMAP_Z_OBJECTIVE )
	clusterEnt.Minimap_SetClampToEdge( true )
	clusterEnt.Minimap_SetCustomState( eMinimapObject_prop_script.OBJECTIVE_AREA )
	foreach ( entity player in GetPlayerArray() )
		clusterEnt.Minimap_AlwaysShow( 0, player )

	string targetName
	switch ( rarity )
	{
		case eLootTier.COMMON:
			targetName = "airdropClusterWhite"
			break
		case eLootTier.RARE:
			targetName = "airdropClusterBlue"
			break
		case eLootTier.EPIC:
			targetName = "airdropClusterPurple"
			break
		case eLootTier.LEGENDARY:
			targetName = "airdropClusterGold"
			break
		case eLootTier.MYTHIC:
			targetName = "airdropClusterRed"
			break
	}

	SetTargetName( clusterEnt, targetName )
	DispatchSpawn( clusterEnt )
}

array<entity> function AirdropExtravaganza_GetClusterEntities()
{
	return file.clusterZoneEnts
}

array<entity> function AirdropExtravaganza_GetTrackedAirdropPods()
{
	return file.airdropPods
}

void function AirdropExtravaganza_ThrowThrowExtraLootForPodDoor( vector origin, vector forwardVector, string lootgroup, int count )
{
	for ( int i = 0; i < count; i++ )
	{
		string lootRef = SURVIVAL_GetWeightedItemFromGroup( lootgroup )
		LootData ld = SURVIVAL_Loot_GetLootDataByRef( lootRef )
		int itemCount = 1
		if ( ld.lootType == eLootType.AMMO )
			itemCount = ld.countPerDrop
		SURVIVAL_ThrowLootFromPoint( origin, ((forwardVector + < RandomFloatRange( -1.0, 1.0 ), 0, 0.75>) * 0.5), lootRef, itemCount )
		wait 0.15
	}
}


void function AirdropExtravaganzaAirdropClusterFromAirdropData ( AirdropRoundData aData, int index, int rarityTier, int count )
{
	if ( count <= 0 )
		return

	if ( aData.airdropSpeed == eAirdropSpeed.STANDARD )
	{
		float delayMin = max( ( file.clusterDelayBase - file.clusterDelayVariance ), 1.0 )
		float delayMax = max( ( file.clusterDelayBase + file.clusterDelayVariance ), 0.0 )
		wait RandomFloatRange( delayMin, delayMax )
	}

	array<vector> clusterAirdropOrigins = aData.clusterOriginArray[ index ]

	AirdropItemsOptionalInfo optionInfo
	optionInfo.animatePod = ( aData.airdropSpeed != eAirdropSpeed.INSTANT )
	optionInfo.animationName = aData.animation

	foreach ( or in clusterAirdropOrigins )
	{
		array< array<string> > contents = DetermineClusterAirdropContents( aData.rarityArray[ index ] )

		thread AirdropItems( or, aData.anglesArray[ index ], contents, optionInfo )

		if ( optionInfo.animatePod )
			wait file.clusterDelayBetweenPods
	}
}

void function AirdropExtravaganzaAirdropCluster ( string animation, vector origin, vector angles, int rarityTier, int count, int airdropSpeed = eAirdropSpeed.STANDARD )
{
	if ( count <= 0 )
		return

	if ( airdropSpeed == eAirdropSpeed.STANDARD )
	{
		float delayMin = max( ( file.clusterDelayBase - file.clusterDelayVariance ), 1.0 )
		float delayMax = max( ( file.clusterDelayBase + file.clusterDelayVariance ), 0.0 )
		wait RandomFloatRange( delayMin, delayMax )
	}

	array<vector> clusterAirdropOrigins = FindClusterAirdropPositions ( origin, file.clusterBaseDistance, file.clusterFailAddDistance, count )

	AirdropItemsOptionalInfo optionInfo
	optionInfo.animatePod = ( airdropSpeed != eAirdropSpeed.INSTANT )
	optionInfo.animationName = animation

	foreach ( or in clusterAirdropOrigins )
	{
		array< array<string> > contents = DetermineClusterAirdropContents( rarityTier )

		thread AirdropItems( or, angles, contents, optionInfo )

		if ( optionInfo.animatePod )
			wait file.clusterDelayBetweenPods
	}
}

void function AirdropExtravaganzaAirdropCluster_Hotzone ( string animation, vector origin, vector angles, int airdropSpeed = eAirdropSpeed.STANDARD )
{
	file.hotzoneLaunched = true

	if ( airdropSpeed == eAirdropSpeed.STANDARD )
	{
		float delay = max( ( file.clusterDelayBase - file.clusterDelayVariance ), 1.0 ) / 2
		wait delay
	}

	float hotzoneFailModDist = GetCurrentPlaylistVarFloat( "airdrop_ltm_hotzone_distance_failMod", file.clusterFailAddDistance )

	array<vector> clusterAirdropOrigins = FindClusterAirdropPositions ( origin, GetCurrentPlaylistVarFloat( "airdrop_ltm_hotzone_distance_base_outer", ( file.clusterBaseDistance * 2.0 ) ), hotzoneFailModDist, file.upgradeClusterCount )
	clusterAirdropOrigins.extend( FindClusterAirdropPositions ( origin, GetCurrentPlaylistVarFloat( "airdrop_ltm_hotzone_distance_base_inner", file.clusterBaseDistance ), hotzoneFailModDist, file.upgradeClusterCount, ( ( 360.0 / file.upgradeClusterCount ) / 2.0 ) ) )

	AirdropItemsOptionalInfo optionInfo
	optionInfo.animatePod = ( airdropSpeed != eAirdropSpeed.INSTANT )
	optionInfo.animationName = animation

	foreach ( or in clusterAirdropOrigins )
	{
		array< array<string> > podContents
		for ( int i = 0; i < 3; i++ )
		{
			array<string> lootArray
			lootArray.append( SURVIVAL_GetWeightedItemFromGroup( file.clusterContentsHotzone[ i ] ) )
			podContents.append( lootArray )
		}

		thread AirdropItems( or, angles, podContents, optionInfo )

		wait file.clusterDelayBetweenPods
	}
}

array< array<string> > function DetermineClusterAirdropContents( int rarityTier )
{
	Assert( ( file.clusterContentsByTier.len() >= rarityTier ), "Missing tier " + rarityTier + " entry in AirdropExtravaganza cluster definitions." )

	array< array<string> > podContents
	array< string > clusterContent = file.clusterContentsByTier [ rarityTier ]
	for ( int i = 0; i < 3; i++ )
	{
		array<string> lootArray
		lootArray.append( SURVIVAL_GetWeightedItemFromGroup( clusterContent [ i ] ) )
		podContents.append( lootArray )
	}

	return podContents
}

void function AirdropExtravaganazaDetermineClusterPositions()
{
	foreach (apData in Survival_GetPregameAirdropDatas())
	{
		int airdropCountForRound = apData.dropCount

		for ( int i = 0; i < apData.dropCount; i++ )
		{
			array<vector> clusterPositions = FindClusterAirdropPositions( apData.originArray[ i ], file.clusterBaseDistance, file.clusterFailAddDistance, 3 )
			apData.clusterOriginArray.append( clusterPositions )
			airdropCountForRound += clusterPositions.len()
		}
		file.airdropSuccess.append( airdropCountForRound )
	}

	foreach (apData in Survival_GetAirdropDatas())
	{
		int airdropCountForRound = apData.dropCount

		for ( int i = 0; i < apData.dropCount; i++ )
		{
			array<vector> clusterPositions = FindClusterAirdropPositions( apData.originArray[ i ], file.clusterBaseDistance, file.clusterFailAddDistance, 3 )
			apData.clusterOriginArray.append( clusterPositions )
			airdropCountForRound += clusterPositions.len()
		}
		file.airdropSuccess.append( airdropCountForRound )
	}
}

array<vector> function FindClusterAirdropPositions ( vector origin, float distance, float failModDistance, int count, float initialAngleOffset = 0.0 )
{
	array<vector> clusterPositions

	float splitAngle = ( 360.0 / maxint( count, 3 ) ) + initialAngleOffset
	FlightPath flightPath = GetAnalysisForModel( DROPPOD_MODEL, AIRDROP_BASE_ANIM )
	const vector AIRDROP_MAXS = <80, 80, 256>
	const vector AIRDROP_MINS = <-80, -80, 0>
	int dataIndex = GetAnalysisDataIndex( flightPath )
	float attemptsPerAngle = ceil( AIRDROPEXTRA_CLUSTER_PLACEMENT_TRIES / 2.0 )
	bool oddCount = ( (count % 2) != 0 )

	for ( int i = 0; i < count; i++ )
	{
		int sign = -1
		float angle = splitAngle * i
		for ( int attempts = 0; attempts < AIRDROPEXTRA_CLUSTER_PLACEMENT_TRIES; attempts++ )
		{
			float correctedAttempt = ceil( attempts / 2.0 )
			float correctedDistance = distance + ( failModDistance * correctedAttempt * sign )

			if ( attempts >= attemptsPerAngle )
			{
				if ( oddCount )
					angle = ((splitAngle * i) + 180.0) % 360.0
				else
					angle = (((splitAngle * i) + 180.0 + (splitAngle / 2.0)) % 360.0)
			}

			float clusterX = origin.x + ( correctedDistance * deg_cos( angle )  )
			float clusterY = origin.y + ( correctedDistance * deg_sin( angle )  )
			vector startTrace = <clusterX, clusterY, 10000>
			vector endTrace = <clusterX, clusterY, -10000>
			//TraceResults traceL = TraceLine( startTrace, endTrace, null,  TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )
			TraceResults traceH = TraceHull( startTrace, endTrace, AIRDROP_MINS, AIRDROP_MAXS, null, TRACE_MASK_TITANSOLID, TRACE_COLLISION_GROUP_NONE )

			sign *= -1

			if ( traceH.fraction == 1 ) // ensure the airdrop finds the ground
				continue
			//else if ( fabs( traceH.endPos.z - traceL.endPos.z ) > 20.0 ) // ensure the airdrop doesn't appear to be "floating" in midair on certain geo
			//	continue
			else if ( IsPointOutOfBounds( traceH.endPos ) ) // ensure the airdrop isn't out of bounds
				continue
			//else if ( traceL.surfaceNormal.z < 0.8 ) // ensure airdrop isn't at too hard of a surface angle
			//	continue

			//clusterPositions.append( traceH.endPos )
			vector foundPos = GetClosestDrop_Internal( traceH.endPos, dataIndex ).origin

			if ( Distance2D( origin, foundPos ) < AIRDROPEXTRA_CLUSTER_MIN_DIST )
				continue

			foreach ( vec in clusterPositions )
				if ( Distance2D( vec, foundPos ) < AIRDROPEXTRA_CLUSTER_MIN_DIST )
					continue

			clusterPositions.append( foundPos )
			break
		}
	}
	return clusterPositions
}

void function AirdropExtravaganazaCleanupPod( entity pod, float delay )
{
	if ( delay > 0 )
		wait delay

	if ( !IsValid( pod ) )
		return

	if ( !file.airdropPods.contains( pod )  )
		return

	foreach ( ent in pod.e.attachedEnts )
		ent.NotSolid()

	pod.NotSolid()
	pod.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 600 )
}

void function AirdropExtravaganazaAddAirdropPodToTrackedArray ( entity airdropPod, vector origin )
{
	if ( airdropPod == null )
		return

	if ( GetCurrentPlaylistVarBool( "airdrop_ltm_custom_UI_enabled", false ) )
		SetGlobalNetInt( "AirdropExtra_AirdropProgress", ( GetGlobalNetInt("AirdropExtra_AirdropProgress") + 1 ) )

	file.airdropPods.append( airdropPod )
}

void function AirdropExtravaganzaAirdropRoundMessaging ( AirdropRoundData aData, int index )
{
	if ( GetCurrentPlaylistVarBool( "airdrop_ltm_custom_UI_enabled", false ) )
	{
		SetGlobalNetInt( "AirdropExtra_AirdropTier", aData.rarityArray [ index ] )
		SetGlobalNetInt( "AirdropExtra_AirdropCount", file.airdropSuccess[ aData.rarityArray [ index ] - 2 ] )
		SetGlobalNetInt( "AirdropExtra_AirdropProgress", 0 )
	}
	if ( file.hotzoneEnabled && !file.hotzoneLaunched ) // REALLY hacky - need to improve if we keep the airdrop LTM hotzone
		AirdropExtravaganza_CreateNewClusterEntity( aData.originArray [ index ], aData.rarityArray [ index ], GetCurrentPlaylistVarFloat( "airdrop_ltm_hotzone_distance_base_outer", (file.clusterBaseDistance * 2.0) ) + 300.0 )
	else
		AirdropExtravaganza_CreateNewClusterEntity( aData.originArray [ index ], aData.rarityArray [ index ] )
}

void function AirdropExtravaganzaAirdropLaunchRequest ( AirdropRoundData aData, int index )
{
	if ( file.hotzoneEnabled && !file.hotzoneLaunched )
		thread AirdropExtravaganzaAirdropCluster_Hotzone( aData.animation, aData.originArray[ index ], aData.anglesArray[ index ] )
	else
	{
		if ( GetCurrentPlaylistVarBool( "airdrop_ltm_custom_UI_enabled", false ) )
			thread AirdropExtravaganzaAirdropClusterFromAirdropData( aData, index , aData.rarityArray[ index ], file.clusterCountByRarity[ aData.rarityArray[ index ] ] )
		else
			thread AirdropExtravaganzaAirdropCluster( aData.animation, aData.originArray[ index ], aData.anglesArray[ index ], aData.rarityArray[ index ], file.clusterCountByRarity[ aData.rarityArray[ index ] ], aData.airdropSpeed )
	}
}

void function AirdropExtravaganzaDropRespawnCluster ( entity beacon, entity respawnBeacon, array<entity> players )
{
	thread AirdropExtravaganzaAirdropCluster ( AIRDROPEXTRA_ANIMATION, beacon.GetOrigin(), beacon.GetAngles(), eLootTier.COMMON, 3, eAirdropSpeed.FAST )
}

void function AirdropExtravaganzaPodOpened (entity dropPod, entity player)
{
	if ( ( file.lootConfettiCount > 0 ) && ( dropPod.GetOwner() == null ) )
		thread  AirdropExtravaganza_ThrowExtraLootForPod ( dropPod, file.lootConfettiCount )
}

void function AirdropExtravaganzaPlayerLandedFromFreefall(entity player)
{
	vector pOrigin = player.GetOrigin()
	IssueAirdropPing ( pOrigin, 0.0, eLootTier.COMMON )
	thread AirdropExtravaganzaAirdropCluster ( AIRDROPEXTRA_ANIMATION, pOrigin, player.GetAngles(), eLootTier.COMMON, 1, eAirdropSpeed.FAST )
}

#endif // SERVER

#if CLIENT
void function AirdropExtravaganzaOverrideGamestateUI()
{
	ClGameState_RegisterGameStateAsset( $"ui/gamestate_info_airdropextra.rpak" )
}

void function OnServerVarChanged_AirdropExtra_AirdropTier( entity player, int new )
{
	if ( GetGameState() != eGameState.Playing )
		return

	printf( "AIRDROP EXTRAVAGANZA: server var changed: " + new )

	int colorID = GetAirdropPingColorIDFromRarityTier( new )
	string airdropText = GetAirdropTierTextFromTier( new )

	RuiSetColorAlpha( ClGameState_GetRui(), "airdropTierColor", SrgbToLinear( ColorPalette_GetColorFromID( colorID ) / 255.0 ), 1.0 )
	RuiSetString( ClGameState_GetRui(), "airdropTierText", airdropText )

	RuiSetInt( ClGameState_GetRui(), "airdropCount", GetGlobalNetInt("AirdropExtra_AirdropCount") )
}

void function OnServerVarChanged_AirdropExtra_AirdropProgress( entity player, int new )
{
	if ( GetGameState() != eGameState.Playing )
		return

	RuiSetInt( ClGameState_GetRui(), "airdropProgress", new )
}

string function GetAirdropTierTextFromTier( int tier )
{
	switch ( tier )
	{
		case eLootTier.COMMON:
			return "COMMON"
		case eLootTier.RARE:
			return "RARE"
		case eLootTier.EPIC:
			return "EPIC"
		case eLootTier.LEGENDARY:
			return "LEGENDARY"
		case eLootTier.MYTHIC:
			return "MYTHIC"
	}
	return ""
}
#endif // CLIENT