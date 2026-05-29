/**************************************************************************************************************
***************************************************************************************************************
**
**		███████╗██╗  ██╗██████╗ ██╗      ██████╗ ██████╗ ███████╗    ███╗   ███╗ ██████╗ ██████╗ ███████╗
**		██╔════╝╚██╗██╔╝██╔══██╗██║     ██╔═══██╗██╔══██╗██╔════╝    ████╗ ████║██╔═══██╗██╔══██╗██╔════╝
**		█████╗   ╚███╔╝ ██████╔╝██║     ██║   ██║██████╔╝█████╗      ██╔████╔██║██║   ██║██║  ██║█████╗
**		██╔══╝   ██╔██╗ ██╔═══╝ ██║     ██║   ██║██╔══██╗██╔══╝      ██║╚██╔╝██║██║   ██║██║  ██║██╔══╝
**		███████╗██╔╝ ██╗██║     ███████╗╚██████╔╝██║  ██║███████╗    ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████╗
**		╚══════╝╚═╝  ╚═╝╚═╝     ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝    ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝
**
**		State: Prototype
**		Feature Flag: HAS_GAMEMODE_EXPLORE
**		Target: 7.0
*/


global function ShGameModeExplore_Init

const string EXPLOREMODE_MOVER_SCRIPTNAME 		= "exploremode_mover"

#if CLIENT
	global function ShGameModeExplore_ServerCallbackAnnouncementSplash
	global function ShGameModeExplore_ServerCallbackClearAnnouncement
	global function ShGameModeExplore_UpdateDeathfieldUI

	const string EXPLOREMODESOUND_INTRO 			= "ui_ingame_shadowsquad_finalsquadmessage"
	const string EXPLOREMODESOUND_RING_CLOSING 		= "ui_ingame_shadowsquad_shipincoming"
	const string EXPLOREMODESOUND_EXIT 				= "UI_InGame_KillLeader"
#endif

#if SERVER && DEVELOPER

#endif

#if SERVER
	global function ShGameModeExplore_GetPlanePassNumber
	global function ShGameModeExplore_SpawnExitPlane
#endif

enum eGameModeExploreAnnounceType
{
	INTRO,
	RING_CLOSING,
	RING_CLOSING_LAST_TIME,
	DROPSHIP_ARRIVING,
	DROPSHIP_ARRIVING_LAST_TIME,
	DROPSHIP_EMBARKING,
	DROPSHIP_EMBARKING_LAST_TIME,

	_count
}

struct
{
	#if SERVER
		bool ringIsClosing
		int planePassNumber
		float planePassLaunchTime
		bool allPlayersLandedFirstTime

		entity exitPlane
		entity exitPlaneMover
	#endif
	int planePassMax
}file

void function ShGameModeExplore_Init()
{
	file.planePassMax = GetCurrentPlaylistVarInt( "max_plane_passes", 3 )

	#if SERVER
		file.planePassNumber = 1
		SetTeamRelationshipRulesForPVE()
		AddDamageCallback( "player", ShGameModeExplore_OnPlayerDamaged )

		Survival_AddCallback_OnPlayerLaunchedFromPlane( ShGameModeExplore_OnPlayerLaunchedFromPlane )
		SURVIVAL_AddCallback_OnDeathFieldStartShrink( ShGameModeExplore_OnDeathFieldStartShrink )
		SURVIVAL_AddCallback_OnDeathFieldStopShrink( ShGameModeExplore_OnDeathFieldStopShrink )
	#endif // SERVER

	#if CLIENT
		AddCallback_GameStateEnter( eGameState.Resolution, OnGamestateResolution )
	#endif

	ShGameModeExplore_RegisterNetworking()
}


//SHARED
void function ShGameModeExplore_RegisterNetworking()
{
	Remote_RegisterClientFunction( "ShGameModeExplore_ServerCallbackAnnouncementSplash", "int", 0, eGameModeExploreAnnounceType._count, "int", 0, 10 )
	Remote_RegisterClientFunction( "ShGameModeExplore_ServerCallbackClearAnnouncement" )
	Remote_RegisterClientFunction( "ShGameModeExplore_UpdateDeathfieldUI" )
}
//END SHARED


#if SERVER
void function ShGameModeExplore_OnPlayerDamaged( entity damagedEnt, var damageInfo )
{
	int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	if ( !IsValid( damageSourceId ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( damageSourceId != eDamageSourceId.damagedef_despawn )
	{
		if ( !IsValid( attacker ) || !attacker.IsPlayer() )
			return
	}

	DamageInfo_SetDamage( damageInfo, 0 )
}


void function ShGameModeExplore_ResetPlayerThread( entity player )
{
	foreach ( trap in player.e.activeTraps )
	{
		if ( IsValid( trap ) )
			trap.Destroy()
	}
	foreach ( trap in player.e.activeUltimateTraps )
	{
		if ( IsValid( trap ) )
			trap.Destroy()
	}
	if ( !player.IsBot() && IsValid( player.p.decoy ) )
		player.p.decoy.Destroy()

	if ( !IsAlive( player ) )
		return

	if ( Bleedout_IsBleedingOut( player ) )
	{
		Bleedout_ForceStop( player )
		Bleedout_ReviveForceStop( player )
		WaitFrame()
	}

	Crafting_CloseCraftingMenu( player )

	player.Signal( "DeathTotem_PreRecallPlayer" )

	CancelPlayerStatesData states
	states.cancelZipline = true
	states.cancelGrapple = true
	states.cancelPhaseTunnel = true
	states.cancelPhaseWalk = true
	states.cancelRevive = true
	states.cancelCryptoDrone = true
	states.cancelTotem = true
	states.cancelMainOrAltHandAbility = true
	CancelPlayerStates( player, states )

	// try add these also, QA is still getting stuck back at tunnel
	player.Signal( "PhaseTunnel_EndPlacement" )
	player.Signal( "PhaseTunnel_DestroyPlacement" )
	player.Signal( "PhaseTunnel_CancelPhaseTunnelUse" )
	player.Signal( "HuntMode_ForceAbilityStop" )
	player.Signal( "ScriptAnimStop" )

	WaitFrame()

                     
	if ( HoverVehicle_IsPlayerInAnyVehicle( player ) )
	{
		Vehicle_KickPlayer_ForOtherReason( player )
		WaitFrame()
	}
      

	if ( player.Player_IsSkydiving() )
	{
		Signal( player, "PlayerSkyDive" )
		WaitFrame()
	}

	//if ( IsValid( player.GetTurret() ) )
	//{
	//	MountedTurretPlaceable_ClearDriver_ForOtherReason( player.GetTurret() )
	//	WaitFrame()
	//}
}
#endif // SERVER


/*****************************************************************************************
******************************************************************************************
**
**		██████╗ ██████╗  ██████╗ ██████╗     ██████╗ ██╗      █████╗ ███╗   ██╗███████╗
**		██╔══██╗██╔══██╗██╔═══██╗██╔══██╗    ██╔══██╗██║     ██╔══██╗████╗  ██║██╔════╝
**		██║  ██║██████╔╝██║   ██║██████╔╝    ██████╔╝██║     ███████║██╔██╗ ██║█████╗
**		██║  ██║██╔══██╗██║   ██║██╔═══╝     ██╔═══╝ ██║     ██╔══██║██║╚██╗██║██╔══╝
**		██████╔╝██║  ██║╚██████╔╝██║         ██║     ███████╗██║  ██║██║ ╚████║███████╗
**		╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝         ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝
*/


#if SERVER
void function ShGameModeExplore_OnPlayerLaunchedFromPlane( entity player )
{
	//printf( "ShGameModeExplore_OnPlayerLaunchedFromPlane()" )
	Remote_CallFunction_NonReplay( player, "ShGameModeExplore_ServerCallbackAnnouncementSplash",
			eGameModeExploreAnnounceType.INTRO, file.planePassNumber )
}


int function ShGameModeExplore_GetPlanePassNumber()
{
	return file.planePassNumber
}


void function ShGameModeExplore_RelaunchPlaneThread()
{
	printf( "ShGameModeExplore_RelaunchPlaneThread()" )

	SURVIVAL_RoundStartLootCleanup()
	CleanUpMarkedEntsOnRoundStart()
	DestroyAllLootBins()
	SURVIVAL_ResetAllDoors()
	SURVIVAL_PopulateSpecialZones()
	SURVIVAL_ChooseLootLocations()

	file.planePassNumber++
	file.planePassLaunchTime = Time()

	FlagClear( "PlaneStartMoving" )
	FlagClear( "PlaneDoorOpen" )
	FlagClear( "PlaneAtLaunchPoint" )

	thread Survival_RunPlaneLogic_Thread( Survival_GenerateSingleRandomPlanePath, Survival_RunSinglePlanePath_Thread, true )

	FillSkyWithClouds()
	FlagSet( "PlaneStartMoving" )

	RoundBased_ResetDeathfield()
	if ( Flag( "DeathFieldPaused" ) )
		FlagClear( "DeathFieldPaused" )
	if ( Flag( "DeathCircleActive" ) )
		FlagClear( "DeathCircleActive" )

	WaitFrame()
	thread SURVIVAL_RunArenaDeathField()

	foreach( entity player in GetPlayerArray() )
	{
		if ( !IsValid( player ) )
			continue

		waitthread ShGameModeExplore_ResetPlayerThread( player )

		if ( !IsAlive( player ) )
		{
			DoCommonRespawnForPlayer( player )
			player.p.respawnPodLanded = false // bad magic
			player.SetPlayerNetTime( "respawnBannerPickedUpTime", -1 )
			player.SetPlayerNetInt( "respawnStatus", eRespawnStatus.NONE )
		}

		// for playlist var "reset_player_inventory_on_respawn 0" to work
		if ( player.p.respawnCount < 2 )
			player.p.respawnCount = 2

		ShGameModeExplore_JoinPlane( player )
	}
	SetGlobalNetTime( "nextCircleStartTime", -1 )
}


void function ShGameModeExplore_JoinPlane( entity player )
{
	//printf( "ShGameModeExplore_JoinPlane()" )

	SetPlayerIntroDropSettings( player )
	player.ClearParent()
	ClearPlayerPlaneViewMode( player )
	player.p.survivalLandedOnGround = false

	Survival_PutPlayerInPlane( player )

	Remote_CallFunction_NonReplay( player, "ShGameModeExplore_ServerCallbackClearAnnouncement" )
	//Remote_CallFunction_NonReplay( player, "ShGameModeExplore_UpdateDeathfieldUI" ) Potential fix for 165373 but CNR, so leaving it out for now
}
#endif //SERVER


/*****************************************************************************************
******************************************************************************************
**
**		██████╗ ███████╗ █████╗ ████████╗██╗  ██╗███████╗██╗███████╗██╗     ██████╗
**		██╔══██╗██╔════╝██╔══██╗╚══██╔══╝██║  ██║██╔════╝██║██╔════╝██║     ██╔══██╗
**		██║  ██║█████╗  ███████║   ██║   ███████║█████╗  ██║█████╗  ██║     ██║  ██║
**		██║  ██║██╔══╝  ██╔══██║   ██║   ██╔══██║██╔══╝  ██║██╔══╝  ██║     ██║  ██║
**		██████╔╝███████╗██║  ██║   ██║   ██║  ██║██║     ██║███████╗███████╗██████╔╝
**		╚═════╝ ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝╚═════╝
*/


#if SERVER
void function ShGameModeExplore_OnDeathFieldStartShrink( table<int,DeathFieldData> deathFieldData )
{
	int stage = SURVIVAL_GetCurrentDeathFieldStage()
	printf( "ShGameModeExplore_OnDeathFieldStartShrink() - %i", stage )

	if ( stage == 0 )
	{
		printf( "ShGameModeExplore_OnDeathFieldStartShrink() - first ring closing" )
		file.ringIsClosing = true

		thread ShGameModeExplore_AnnounceRingClosing()
	}
}


void function ShGameModeExplore_AnnounceRingClosing()
{
	wait( 4.0 )

	foreach( entity player in GetPlayerArray() )
	{
		if ( file.planePassNumber >= file.planePassMax )
			Remote_CallFunction_NonReplay( player, "ShGameModeExplore_ServerCallbackAnnouncementSplash", eGameModeExploreAnnounceType.RING_CLOSING_LAST_TIME, file.planePassNumber )
		else
			Remote_CallFunction_NonReplay( player, "ShGameModeExplore_ServerCallbackAnnouncementSplash", eGameModeExploreAnnounceType.RING_CLOSING, file.planePassNumber )
	}
}


void function ShGameModeExplore_OnDeathFieldStopShrink( table<int,DeathFieldData> deathFieldData )
{
	int stage = SURVIVAL_GetCurrentDeathFieldStage()
	printf( "ShGameModeExplore_OnDeathFieldStopShrink() - %i", stage )

	if ( stage == 2 )
	{
		printf( "ShGameModeExplore_OnDeathFieldStopShrink() - spawning exit plane" )
		thread ShGameModeExplore_DelaySpawnExitPlaneThread()
	}
	else if ( stage == 3 )
	{
		FlagSet( "DeathFieldPaused" )

		if ( file.planePassNumber >= file.planePassMax )
		{
			foreach( entity player in GetPlayerArray() )
				Remote_CallFunction_NonReplay( player, "ShGameModeExplore_ServerCallbackAnnouncementSplash", eGameModeExploreAnnounceType.DROPSHIP_EMBARKING_LAST_TIME, file.planePassNumber )
			thread ShGameModeExplore_EndGameThread()
		}
		else
		{
			foreach( entity player in GetPlayerArray() )
				Remote_CallFunction_NonReplay( player, "ShGameModeExplore_ServerCallbackAnnouncementSplash", eGameModeExploreAnnounceType.DROPSHIP_EMBARKING, file.planePassNumber )
			thread ShGameModeExplore_NextRunThread()
		}
	}
}


void function ShGameModeExplore_NextRunThread()
{
	printf( "ShGameModeExplore_NextRunThread() - waiting" )
	wait( 4.0 )

	foreach( entity player in GetPlayerArray() )
	{
		if ( IsValid( player ) )
			ScreenFadeToBlack( player, 0.5, 1.0 )
	}

	wait( 1.0 )

	if ( IsValid( file.exitPlaneMover ) )
	{
		StopSoundOnEntity( file.exitPlaneMover, "Survival_DropSequence_Pegasus_Engine_ExploreMode" )
		file.exitPlaneMover.Destroy()

	}

	printf( "ShGameModeExplore_NextRunThread() - relaunching" )
	thread ShGameModeExplore_RelaunchPlaneThread()
}


void function ShGameModeExplore_EndGameThread()
{
	printf( "ShGameModeExplore_EndGameThread() - waiting" )
	wait( 5.0 )

	foreach( entity player in GetPlayerArray() )
	{
		if ( !IsValid( player ) )
			continue
		waitthread ShGameModeExplore_ResetPlayerThread( player )
	}

	printf( "ShGameModeExplore_EndGameThread() - setting winner" )
	SetWinner( TEAM_UNASSIGNED, eWinReason.TIME_LIMIT, "#GAMEMODE_TIME_LIMIT_REACHED", "#GAMEMODE_TIME_LIMIT_REACHED" )
}
#endif //SERVER


/*****************************************************************************************
******************************************************************************************
**
**		███████╗██╗  ██╗██╗████████╗    ██████╗ ██╗      █████╗ ███╗   ██╗███████╗
**		██╔════╝╚██╗██╔╝██║╚══██╔══╝    ██╔══██╗██║     ██╔══██╗████╗  ██║██╔════╝
**		█████╗   ╚███╔╝ ██║   ██║       ██████╔╝██║     ███████║██╔██╗ ██║█████╗
**		██╔══╝   ██╔██╗ ██║   ██║       ██╔═══╝ ██║     ██╔══██║██║╚██╗██║██╔══╝
**		███████╗██╔╝ ██╗██║   ██║       ██║     ███████╗██║  ██║██║ ╚████║███████╗
**		╚══════╝╚═╝  ╚═╝╚═╝   ╚═╝       ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝
*/


#if SERVER
void function ShGameModeExplore_DelaySpawnExitPlaneThread()
{
	printf( "ShGameModeExplore_DelaySpawnExitPlaneThread()" )
	wait( 6.0 )

	foreach( entity player in GetPlayerArray() )
	{
		if ( file.planePassNumber >= file.planePassMax )
			Remote_CallFunction_NonReplay( player, "ShGameModeExplore_ServerCallbackAnnouncementSplash", eGameModeExploreAnnounceType.DROPSHIP_ARRIVING_LAST_TIME, file.planePassNumber )
		else
			Remote_CallFunction_NonReplay( player, "ShGameModeExplore_ServerCallbackAnnouncementSplash", eGameModeExploreAnnounceType.DROPSHIP_ARRIVING, file.planePassNumber )
	}

	ShGameModeExplore_SpawnExitPlane()
}


void function ShGameModeExplore_SpawnExitPlane()
{
	printf( "ShGameModeExplore_SpawnExitPlane()" )

	if ( IsValid( file.exitPlane ) )
		file.exitPlane.Destroy()

	if ( IsValid( file.exitPlaneMover ) )
	{
		StopSoundOnEntity( file.exitPlaneMover, "Survival_DropSequence_Pegasus_Engine_ExploreMode" )
		file.exitPlaneMover.Destroy()
	}

	vector origin = SURVIVAL_GetNextCircleCenter( Survival_Loot_GetDefaultRealm() )
	origin.z = SURVIVAL_GetPlaneHeight() * 2.5
	vector angles = <0, 0, 0>

	entity mover = CreateScriptMover( EXPLOREMODE_MOVER_SCRIPTNAME, origin, angles, SOLID_VPHYSICS )

	entity plane = CreateEntity( "prop_script" )
	plane.SetValueForModelKey( SURVIVAL_PLANE_MODEL )
	plane.kv.fadedist = -1
	plane.kv.renderamt = 255
	plane.kv.rendercolor = "255 255 255"
	plane.kv.solid = 6 // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	plane.SetOrigin( origin )
	plane.SetAngles( angles )
	plane.NotSolid()
	plane.DisableHibernation()
	plane.Minimap_SetObjectScale( 1 )
	plane.Minimap_SetZOrder( MINIMAP_Z_OBJECTIVE )
	plane.Minimap_SetClampToEdge( false )
	SetTargetName( plane, SURVIVAL_PLANE_NAME )
	DispatchSpawn( plane )
	plane.SetParent( mover )
	plane.Show()

	file.exitPlane = plane
	file.exitPlaneMover = mover

	EmitSoundOnEntity( file.exitPlaneMover, "Survival_DropSequence_Pegasus_Engine_ExploreMode" )

	thread ShGameModeExplore_ExitPlaneThread( mover, origin )
}


void function ShGameModeExplore_ExitPlaneThread( entity planeMover, vector origin )
{
	printf( "ShGameModeExplore_ExitPlaneThread() - start height: %f", origin.z )

	vector endPos = origin
	endPos.z = -origin.z

	TraceResults traceResult = TraceHull( origin, endPos, <-2600.0, -2600.0, -1000.0>, <2600.0, 2600.0, 1000.0>, planeMover, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
	endPos = traceResult.endPos + <0, 0, 400>

	planeMover.NonPhysicsRotate( <0,0,1>, 3.0 )
	planeMover.NonPhysicsMoveTo( endPos, 30, 0, 5 )

	wait 30

	if ( IsValid( planeMover ) )
	{
		printf( "ShGameModeExplore_ExitPlaneThread() - end height: %f", planeMover.GetOrigin().z )

		planeMover.NonPhysicsStop()
		planeMover.NonPhysicsRotate( <0,0,1>, 0.3 )
	}
}
#endif //SERVER


/*****************************************************************************************
******************************************************************************************
**
**		 █████╗ ███╗   ██╗███╗   ██╗ ██████╗ ██╗   ██╗███╗   ██╗ ██████╗███████╗
**		██╔══██╗████╗  ██║████╗  ██║██╔═══██╗██║   ██║████╗  ██║██╔════╝██╔════╝
**		███████║██╔██╗ ██║██╔██╗ ██║██║   ██║██║   ██║██╔██╗ ██║██║     █████╗
**		██╔══██║██║╚██╗██║██║╚██╗██║██║   ██║██║   ██║██║╚██╗██║██║     ██╔══╝
**		██║  ██║██║ ╚████║██║ ╚████║╚██████╔╝╚██████╔╝██║ ╚████║╚██████╗███████╗
**		╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝  ╚═══╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝╚══════╝
*/


#if CLIENT
void function ShGameModeExplore_ServerCallbackAnnouncementSplash( int messageIndex, int currentPass )
{
	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) )
		return

	printf( "ShGameModeExplore_ServerCallbackAnnouncementSplash() - %i", messageIndex )

	string messageText = ""
	string subText     = ""
	float duration     = 8.0
	int style          = ANNOUNCEMENT_STYLE_SWEEP
	string soundAlias  = ""
	vector titleColor  = <0, 0, 0>

	//	TODO: three intros should just be one string with a suffix for drop number
	if ( messageIndex == eGameModeExploreAnnounceType.INTRO )
	{
		messageText = "#EXPLOREMODE_NAME"
		subText     = Localize( "#EXPLOREMODE_DESC_INGAME", currentPass, file.planePassMax )
		soundAlias  = EXPLOREMODESOUND_INTRO
	}
	else if ( messageIndex == eGameModeExploreAnnounceType.RING_CLOSING )
	{
		messageText = "#EXPLOREMODE_ANNOUNCE_RINGS"
		subText 	= "#EXPLOREMODE_ANNOUNCE_RINGS_SUB_A"
		soundAlias 	= EXPLOREMODESOUND_RING_CLOSING
	}
	else if ( messageIndex == eGameModeExploreAnnounceType.RING_CLOSING_LAST_TIME )
	{
		messageText = "#EXPLOREMODE_ANNOUNCE_RINGS"
		subText 	= "#EXPLOREMODE_ANNOUNCE_RINGS_SUB_B"
		soundAlias 	= EXPLOREMODESOUND_RING_CLOSING
	}
	else if ( messageIndex == eGameModeExploreAnnounceType.DROPSHIP_ARRIVING )
	{
		messageText = "#EXPLOREMODE_ANNOUNCE_DROPSHIP_IN"
		subText 	= "#EXPLOREMODE_ANNOUNCE_DROPSHIP_IN_SUB_A"
		duration 	= 8.0
		soundAlias 	= EXPLOREMODESOUND_EXIT
	}
	else if ( messageIndex == eGameModeExploreAnnounceType.DROPSHIP_ARRIVING_LAST_TIME )
	{
		messageText = "#EXPLOREMODE_ANNOUNCE_DROPSHIP_IN"
		subText 	= "#EXPLOREMODE_ANNOUNCE_DROPSHIP_IN_SUB_B"
		duration 	= 8.0
		soundAlias 	= EXPLOREMODESOUND_EXIT
	}
	else if ( messageIndex == eGameModeExploreAnnounceType.DROPSHIP_EMBARKING )
	{
		Minimap_DeathFieldDisableDraw()
		//SetGamestateCountdownClear()

		messageText = "#EXPLOREMODE_ANNOUNCE_DROPSHIP_OUT"
		subText 	= "#EXPLOREMODE_ANNOUNCE_DROPSHIP_OUT_SUB_A"
		duration 	= 5.0
		soundAlias 	= EXPLOREMODESOUND_EXIT
	}
	else if ( messageIndex == eGameModeExploreAnnounceType.DROPSHIP_EMBARKING_LAST_TIME )
	{
		CircleAnnouncementsEnable( false )

		messageText = "#EXPLOREMODE_ANNOUNCE_DROPSHIP_OUT"
		subText 	= "#EXPLOREMODE_ANNOUNCE_DROPSHIP_OUT_SUB_B"
		duration 	= 5.0
		soundAlias 	= EXPLOREMODESOUND_EXIT
	}

	AnnouncementData announcement = Announcement_Create( messageText )
	announcement.drawOverScreenFade = true
	Announcement_SetSubText( announcement, subText )
	Announcement_SetHideOnDeath( announcement, true )
	Announcement_SetDuration( announcement, duration )
	Announcement_SetPurge( announcement, true )
	Announcement_SetStyle( announcement, style )
	Announcement_SetSoundAlias( announcement, soundAlias )
	Announcement_SetTitleColor( announcement, titleColor )
	AnnouncementFromClass( player, announcement )
}


void function ShGameModeExplore_ServerCallbackClearAnnouncement()
{
	ClearAnnouncements()
}

void function ShGameModeExplore_UpdateDeathfieldUI()
{
	UpdateFullmapRuiTracks()
}

void function OnGamestateResolution()
{
	if ( CanGetLocalPlayer() )
		ScreenFade( GetLocalViewPlayer(), 0, 0, 0, 255, 0.5, 0, FFADE_OUT | FFADE_STAYOUT )

	Remote_ServerCallFunction( "ClientCallback_LeaveMatch" )
}

#endif //CLIENT 