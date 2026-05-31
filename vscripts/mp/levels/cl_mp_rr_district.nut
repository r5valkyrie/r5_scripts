global function ClientCodeCallback_MapInit

const asset VFX_FUSE_HOLO_SPRAY = $"P_kola_bottle_spray"

void function ClientCodeCallback_MapInit()
{
	SetMapSetting_BloomAmount( 3.0 ) 

	MapBloomSettings bloomSettings = GetMapBloomSettings()

	
	bloomSettings.characterSelect	= 1.0
	bloomSettings.podium			= 1.0
	bloomSettings.control			= 0.0

	
	bloomSettings.dropship			= -1.0
	bloomSettings.winterExpress		= -1.0
	bloomSettings.deathScreen		= -1.0

	District_MapInit_Common()

	MapZones_RegisterDataTable( $"datatable/map_zones/zones_mp_rr_district.rpak" )

	PrecacheParticleSystem( VFX_FUSE_HOLO_SPRAY )

	
	MapZones_AddMinimapLevelLabel( "Resort", 0.2, 0.2, 0.5 )
	MapZones_AddMinimapLevelLabel( "The Lotus", 0.45, 0.19, 0.5 )
	MapZones_AddMinimapLevelLabel( "Energy Bank", 0.526, 0.495, 0.5 )
	MapZones_AddMinimapLevelLabel( "Electro Dam", 0.67, 0.18, 0.5 )
	MapZones_AddMinimapLevelLabel( "Galleria", 0.62, 0.36, 0.5 )
	MapZones_AddMinimapLevelLabel( "Heights", 0.8, 0.39, 0.5 )
	MapZones_AddMinimapLevelLabel( "City Hall", 0.33, 0.35, 0.5 )
	MapZones_AddMinimapLevelLabel( "Blossom Drive", 0.13, 0.50, 0.5 )
	MapZones_AddMinimapLevelLabel( "Street Market", 0.21, 0.71, 0.5 )
	MapZones_AddMinimapLevelLabel( "Neon Square", 0.24, 0.56, 0.5 )
	MapZones_AddMinimapLevelLabel( "Draft Point", 0.435, 0.68, 0.5 )
	MapZones_AddMinimapLevelLabel( "Shipyard Arcade", 0.45, 0.88, 0.5 )
	MapZones_AddMinimapLevelLabel( "Humbert Labs", 0.66, 0.79, 0.5 )
	MapZones_AddMinimapLevelLabel( "Stadium", 0.765, 0.61, 0.5 )
	MapZones_AddMinimapLevelLabel( "Viaduct", 0.311, 0.79, 0.5 )
	MapZones_AddMinimapLevelLabel( "Old Town", 0.63, 0.89, 0.5 )
	MapZones_AddMinimapLevelLabel( "Boardwalk", 0.1, 0.35, 0.5 )

	AddCallback_EntitiesDidLoad( EntitiesDidLoad )

}

void function EntitiesDidLoad()
{
	if ( GetEntArrayByScriptName( "district_neon_square_holo_fuze" ).len() >= 1 )
	{
		array<entity> fuseHolos = GetEntArrayByScriptName( "district_neon_square_holo_fuze" )
		thread HandleHoloFacingPlayer_thread( fuseHolos[0] )
		thread HandleHoloVFX_thread( fuseHolos[0] )
	}
}

void function HandleHoloFacingPlayer_thread( entity hologram )
{
	hologram.EndSignal( "OnDestroy" )

	vector dir
	vector normalizedDir

	while ( true )
	{
		entity localPlayer = GetLocalViewPlayer()

		if ( IsValid( localPlayer ) )
		{
			dir = localPlayer.GetOrigin() - hologram.GetOrigin()
			if ( LengthSqr( dir ) < 0.001 )
			{
				hologram.SetAngles( <0, 0, 0> )
			}
			else
			{
				normalizedDir = Normalize( dir )
				vector turnAngle = VectorToAngles( normalizedDir )
				vector turnAngleClamped = < Clamp( turnAngle.x, 0, 0 ), turnAngle.y, turnAngle.z >
				hologram.SetAngles( turnAngleClamped )
			}
		}

		WaitFrame()
	}

}

void function HandleHoloVFX_thread( entity hologram )
{
	hologram.EndSignal( "OnDestroy" )

	int holoSpray = GetParticleSystemIndex( VFX_FUSE_HOLO_SPRAY )

	int effectHandleSpray = StartParticleEffectOnEntity( hologram, holoSpray, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )

	OnThreadEnd(
		function() : ( effectHandleSpray )
		{
			if ( EffectDoesExist( effectHandleSpray ) )
				EffectStop( effectHandleSpray, false, true )

		}
	)

	while( true )
	{
		wait 1.0
	}
}