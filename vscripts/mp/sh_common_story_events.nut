#if SERVER
global function CommonStoryEvents_Init
#endif

#if CLIENT
global function ClCommonStoryEvents_Init
#endif

                 
#if SERVER
#if DEV
global function CreateBlipAtIndex
#endif
#endif

global function GetTelTeasePhase

const asset BLIP_MODEL_1 = $"mdl/vistas/olympus_blip1.rmdl"
const asset BLIP_MODEL_2 = $"mdl/vistas/olympus_blip2.rmdl"
const asset BLIP_MODEL_3 = $"mdl/vistas/olympus_blip3.rmdl"

global enum eTeleportPhase
{
	DISABLED,
	PHASE_1,
	PHASE_2,
	PHASE_3,

	_count
}

      

struct
{
	                 
		#if SERVER
			array< vector > blipOrigins = [ <0,0,0>, <0,0,0>, <0,0,0> ]
			array< vector > blipAngles = [ <0,0,0>, <0,0,0>, <0,0,0> ]
			entity olympus
			float min_tel_interval
			float max_tel_interval
			bool heightOverride = false
		#endif
       

	                    
		array < vector > blockBalloonCreationOrigins
       
} file


// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
//
//  #### ##    ## #### ########
//   ##  ###   ##  ##     ##
//   ##  ####  ##  ##     ##
//   ##  ## ## ##  ##     ##
//   ##  ##  ####  ##     ##
//   ##  ##   ###  ##     ##
//  #### ##    ## ####    ##
//
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================

#if SERVER
void function CommonStoryEvents_Init()
{
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	if ( IsNightMap() )
	{
		AddCallback_OnClientConnected( OnClientConnected )
		AddCallback_GameStateEnter( eGameState.WaitingForPlayers, OnWaitingForPlayers_Client )
	}

                 
	PrecacheModel( BLIP_MODEL_1 )
	PrecacheModel( BLIP_MODEL_2 )
	PrecacheModel( BLIP_MODEL_3 )
	PrecacheEffect( $"P_satellite_explosion" )
	PrecacheParticleSystem( $"P_satellite_blip" )
	PrecacheParticleSystem( $"P_satellite_debris" )

	AddCallback_GameStateEnter( eGameState.Playing, GameStartedPlaying )

	file.min_tel_interval = GetCurrentPlaylistVarFloat( "tel_air_freq_min", 4 )
	file.max_tel_interval = GetCurrentPlaylistVarFloat( "tel_air_freq_max", 9 )
      

	AddSpawnCallback( "prop_dynamic", OnCommonStoryEventPropCreated )
}
#endif

#if CLIENT
void function ClCommonStoryEvents_Init()
{
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )

	if ( IsNightMap() && GetCurrentPlaylistVarBool( "EnableBWScreen", true ))
	{
		AddCallback_GameStateEnter( eGameState.WaitingForPlayers, OnWaitingForPlayers_Client )
		AddCallback_GameStateEnter( eGameState.PickLoadout, OnPickLoadout_Client )
		AddCallback_OnPlayerDisconnected( OnPlayerDisconnected )
	}
}
#endif


                    
void function ParseBalloonPlaylist()
{
	int numBalloonBlock = GetCurrentPlaylistVarInt( "balloon_block_count", 0 )

	for ( int index = 0; index < numBalloonBlock; index++ )
	{
		string playlistName = "balloon_block_count_" + index
		vector balloonBlockOrigin = StringToVector( GetCurrentPlaylistVarString( playlistName, "0 0 0" ) )
		file.blockBalloonCreationOrigins.append( balloonBlockOrigin )
	}

}
      

#if SERVER || CLIENT
void function EntitiesDidLoad()
{
	if ( IsNightMap() && GetCurrentPlaylistVarBool( "UseNocAnnouncerAtNight", true ) )
	{
		SurvivalCommentary_SetHost( eSurvivalHostType.NOC )
	}

	                    
	#if SERVER
	bool balloonBounce = GetCurrentPlaylistVarBool( "anniversary_balloon_bounce", true )
	bool balloonEnable = GetCurrentPlaylistVarBool( "anniversary_balloon_enable", true )
	array< entity > celebrationBalloons = GetEntArrayByScriptName( "celebration_balloon" )

	float balloonBlockRadius = GetCurrentPlaylistVarFloat("balloon_block_radius", 5.0)

	if ( balloonEnable )
		ParseBalloonPlaylist()

	foreach ( balloon in celebrationBalloons )
	{
		if ( !balloonEnable )
		{
			balloon.Destroy()
			continue
		}

		if ( file.blockBalloonCreationOrigins.len() != 0 )
		{
			foreach ( origin in file.blockBalloonCreationOrigins )
			{
				if ( Distance2D( origin, balloon.GetOrigin() ) <= balloonBlockRadius )
				{
					balloon.Destroy()
					continue
				}
			}
		}

		if ( balloonBounce )
		{
			//DisableSkydiveEndOnEntity( balloon, true )
			//DisableSkydiveAnticipateOnEntity( balloon, true )
		}

		balloon.SetForceVisibleInPhaseShift( true )
		balloon.DisallowZiplines()
		balloon.kv.CollisionGroup = ( TRACE_COLLISION_GROUP_NONE | TRACE_COLLISION_GROUP_PLAYER_MOVEMENT )
	}
	#endif
       
}
#endif

#if SERVER
void function OnClientConnected( entity client )
{
	if ( !IsValid( client ) )
		return

	if ( GetGameState() != eGameState.WaitingForPlayers )
		return

	PlayMusicToPlayer( client, "Music_NightMaps_Intro_Stinger" )
}
#endif

void function OnWaitingForPlayers_Client()
{
#if SERVER
	foreach ( player in GetConnectedPlayers() )
	{
		if ( !IsValid( player ) )
			return

		PlayMusicToPlayer( player, "Music_NightMaps_Intro_Stinger" )
	}
#endif

#if CLIENT
	EmitUISound( "NightMaps_Intro_Static" )
	GfxDesaturateOn()
#endif
}

void function OnPickLoadout_Client()
{
#if CLIENT
	StopUISoundByName( "NightMaps_Intro_Static" )
	GfxDesaturateOff()
#endif
}

#if CLIENT
void function OnPlayerDisconnected( entity player )
{
	StopUISoundByName( "NightMaps_Intro_Static" )
}
#endif

#if SERVER
void function OnCommonStoryEventPropCreated( entity ent )
{
	                 
		switch ( ent.GetScriptName() )
		{
			case "olympus_blip1":
				file.blipOrigins[0] = ent.GetOrigin()
				file.blipAngles[0] = ent.GetAngles()
				ent.Destroy()
				break
			case "olympus_blip2":
				file.blipOrigins[1] = ent.GetOrigin()
				file.blipAngles[1] = ent.GetAngles()
				ent.Destroy()
				break
			case "olympus_blip3":
				file.blipOrigins[2] = ent.GetOrigin()
				file.blipAngles[2] = ent.GetAngles()
				ent.Destroy()
				break
			default:
				return
				break
		}

       
}
#endif

                 
int function GetTelTeasePhase()
{
	#if DEV
		int overridePhase =	GetCurrentPlaylistVarInt( "dev_tel_tease_phase", -1 )
		if ( overridePhase >= 0 && overridePhase < eTeleportPhase._count )
			return overridePhase
	#endif

	int unixTimeNow = GetUnixTimestamp()
	if ( unixTimeNow > expect int( GetCurrentPlaylistVarTimestamp( "tel_p3", UNIX_TIME_FALLBACK_2038 ) ) )
	{
		return eTeleportPhase.PHASE_3
	}
	else if ( unixTimeNow > expect int( GetCurrentPlaylistVarTimestamp( "tel_p2", UNIX_TIME_FALLBACK_2038 ) ) )
	{
		return eTeleportPhase.PHASE_2
	}
	else if ( unixTimeNow > expect int( GetCurrentPlaylistVarTimestamp( "tel_p1", UNIX_TIME_FALLBACK_2038 ) ) )
	{
		return eTeleportPhase.PHASE_1
	}

	return eTeleportPhase.DISABLED
}
#if SERVER
void function GameStartedPlaying()
{
	int phase = GetTelTeasePhase()
	if ( phase == eTeleportPhase.DISABLED )
		return

	if ( phase == eTeleportPhase.PHASE_1 )
		thread TeleportWithDelay( RandomFloatRange( 2.0, 5.0 ) )
	else if ( phase == eTeleportPhase.PHASE_2 )
		thread MultiTeleportThread()
}

void function TeleportWithDelay( float delay )
{
	wait delay
	file.heightOverride = true
	thread CreateBlipAtIndex( RandomInt( 3 ) )
	FlagWait( "DeathCircleActive" )
	file.heightOverride = false
	thread CreateBlipAtIndex( RandomInt( 3 ) )
}

void function MultiTeleportThread()
{
	thread SlowDownTeleportThread()
	file.heightOverride = true
	int lastTeleport = 2
	array<int> possibleTeleport = [ 0, 1 ]

	wait 4.0

	while ( true )
	{
		int possibleTeleportIndex = RandomInt( 2 )
		int teleportPos = possibleTeleport[ possibleTeleportIndex ]
		waitthread CreateBlipAtIndex ( teleportPos )
		possibleTeleport[ possibleTeleportIndex ] = lastTeleport
		lastTeleport = teleportPos
		wait RandomFloatRange( file.min_tel_interval, file.max_tel_interval )
	}
}

void function SlowDownTeleportThread()
{
	FlagWait( "DeathCircleActive" )
	file.min_tel_interval = GetCurrentPlaylistVarFloat( "tel_ground_freq_min", 120 )
	file.max_tel_interval = GetCurrentPlaylistVarFloat( "tel_ground_freq_max", 360 )
	file.heightOverride = false
}

void function CreateBlipAtIndex( int i )
{
	asset blip
	switch ( i )
	{
		case 0 :
			blip = BLIP_MODEL_1
			break
		case 1:
			blip = BLIP_MODEL_2
			break
		case 2:
			blip = BLIP_MODEL_3
			break
		default:
			return
			break
	}

	if ( IsValid(file.olympus) )
	{
		StopSoundAtPosition(file.olympus.GetOrigin(), "DividedMoon_Mu1_Tease_Portal_LP")
		StartParticleEffectInWorld( GetParticleSystemIndex( $"P_satellite_blip" ), file.olympus.GetOrigin(), file.olympus.GetAngles() )
		// wait some seconds for FX to finish
		wait 2.95
		file.olympus.Destroy()
		wait 1.0
	}

	EmitSoundAtPosition(TEAM_ANY, file.blipOrigins[i], "DividedMoon_Mu1_Tease_Portal_LP", GetPlayerArray()[0]  )
	float height = file.heightOverride ? SURVIVAL_GetPlaneHeight() : file.blipOrigins[i].z

	StartParticleEffectInWorld( GetParticleSystemIndex( $"P_satellite_blip" ), < file.blipOrigins[i].x, file.blipOrigins[i].y, height > , file.blipAngles[i] )
	// wait some seconds for FX to finish
	wait 2.95
	file.olympus = CreatePropScript( blip, < file.blipOrigins[i].x, file.blipOrigins[i].y, height >, file.blipAngles[i] )
}
#endif
       