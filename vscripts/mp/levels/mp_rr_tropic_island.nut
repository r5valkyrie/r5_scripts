global function CodeCallback_MapInit

const asset FX_LIGHTING_STRIKE = $"P_trop_elec_tower"
const asset FX_LIGHTING_STRIKE_SKYBOX = $"P_trop_elec_tower_sb"

void function CodeCallback_MapInit()
{
	MapZones_RegisterDataTable( $"datatable/map_zones/zones_mp_rr_tropic_island.rpak" )

	Tropics_MapInit_Common()

	SURVIVAL_SetPlaneHeight( 26000 )
	SURVIVAL_SetAirburstHeight( 2500 )
	SURVIVAL_SetMapCenter( <5000,9000,0> )
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )

	//--Lightning strike
	PrecacheParticleSystem( FX_LIGHTING_STRIKE )
	PrecacheParticleSystem( FX_LIGHTING_STRIKE_SKYBOX )

	if ( GetCurrentPlaylistVarInt( "deathfield_end_on_script_locations", 0 ) == 1 )
		AddCircleOverrideLocations()

	int flyerCount = minint( GetCurrentPlaylistVarInt( "wildlife_ai_flyer_count", 21 ), WILDLIFE_MAX_FLYER_COUNT )
	if ( flyerCount < 0 )
	{
		flyerCount = 0
	}
	Flyers_SetFlyersToSpawn( flyerCount )
}


void function EntitiesDidLoad()
{
	thread lightningStrike()
}

void function lightningStrike()
{
	//Zone 7 Lightning Rod
	vector Origin = < 37246.1, 35927.2, 18699.5 >
	vector Angles = < -60, 10, 10 >

	//skybox Lightning
	vector Origin_skyboxFX = < -30531.25, 45048, -27703.5 >
	vector Angles_skyboxFX = < -62.584, 18, -85.4297 >
	entity LIGHTING_STRIKE_SKYBOX = null

	//skybox lightning audio emitter location
	vector Origin_Audio = < 37323.828125, 36011.734375, 19882.410156 >

	while(true )
	{
		wait RandomFloatRange( 80, 120 )
		EmitSoundAtPosition( TEAM_ANY, Origin_Audio, "Tropics_scr_LightningRod_Strike" )
		wait 0.5
		StartParticleEffectInWorld( GetParticleSystemIndex( FX_LIGHTING_STRIKE ), Origin, Angles )

		//SkyBox effects
		LIGHTING_STRIKE_SKYBOX = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( FX_LIGHTING_STRIKE_SKYBOX ), Origin_skyboxFX, Angles_skyboxFX )
		LIGHTING_STRIKE_SKYBOX.kv.in_skybox = true
	}
}


void function AddCircleOverrideLocations()
{
	{
		//Cascade Falls, Pitt, Ceto  #0
		switch ( RandomInt( 11 ) )
		{
			case 0:
				SURVIVAL_AddOverrideCircleLocation( <1438, 11994, 1602>, 50, true ) //Cascade Falls in town
				break

			case 1:
				SURVIVAL_AddOverrideCircleLocation( <-2669, 17064, 1233>, 50, true ) //Northside Field
				break

			case 2:
				SURVIVAL_AddOverrideCircleLocation( <-8708, 11864, 430>, 50, true )    //West - Double Houses near tunnel
				break

			case 3:
				SURVIVAL_AddOverrideCircleLocation( <9043, 3897, 998>, 50, true )    //East Cascade Falls
				break

			case 4:
				SURVIVAL_AddOverrideCircleLocation( <3538, 5467, 608>, 50, true )    //Closer East Cascade Falls
				break

			case 5:
				SURVIVAL_AddOverrideCircleLocation( <-12372, 2170, 382>, 50, true )  //Ceto Station
				break

			case 6:
				SURVIVAL_AddOverrideCircleLocation( <-18326, 1842, 381>, 50, true )  //West Ceto Station
				break

			case 7:
				SURVIVAL_AddOverrideCircleLocation( <-2841, -9629, 583>, 50, true )  //S Pitt
				break

			case 8:
				SURVIVAL_AddOverrideCircleLocation( <-1832, -5511, 671>, 50, true )  //N Pitt
				break

			case 9:
				SURVIVAL_AddOverrideCircleLocation( <1385, -4813, 735>, 50, true )  //NE Pitt
				break

			case 10:
				SURVIVAL_AddOverrideCircleLocation( <2666, 18336, 2454>, 50, true )  //North Falls crossroads
				break
		}
	}
	{
		//The Wall #1
		switch ( RandomInt( 7 ) )
		{
			case 0:
				SURVIVAL_AddOverrideCircleLocation( <860, 23634, 2727>, 50, true )    //South The Wall
				break

			case 1:
				SURVIVAL_AddOverrideCircleLocation( <8483, 36181, 3575>, 50, true ) //3 pills
				break

			case 2:
				SURVIVAL_AddOverrideCircleLocation( <-604, 46243, 365>, 50, true )    //Noth Wall under waterfall
				break

			case 3:
				SURVIVAL_AddOverrideCircleLocation( <14269, 43600, 6044>, 50, true )    //North East of Wall by huts
				break

			case 4:
				SURVIVAL_AddOverrideCircleLocation( <-6414, 35419, 176>, 50, true )    //West of Wall by huts
				break

			case 5:
				SURVIVAL_AddOverrideCircleLocation( <7624, 43361, 4143>, 50, true )    //West of Wall by respawn
				break

			case 6:
				SURVIVAL_AddOverrideCircleLocation( <6036, 33622, 3573>, 50, true )    //West middle of wall
				break
		}
	}
	{
		//Upper Right (Zeus, Lighting rod, thunder watch) #2
		switch ( RandomInt( 10 ) )
		{
			case 0:
				SURVIVAL_AddOverrideCircleLocation( <34118, 30074, 9198>, 50, true ) //N Lighting Rod
				break

			case 1:
				SURVIVAL_AddOverrideCircleLocation( <34937, 32185, 9971>, 50, true )    //N Lighting Rod #2
				break

			case 2:
				SURVIVAL_AddOverrideCircleLocation( <28925, 39091, 10016>, 50, true ) // E Zeus
				break

			case 3:
				SURVIVAL_AddOverrideCircleLocation( <24738, 38771, 9915>, 50, true ) //Front of Zeus
				break

			case 4:
				SURVIVAL_AddOverrideCircleLocation( <29988, 43162, 10016>, 50, true )    //Northest Zeus
				break

			case 5:
				SURVIVAL_AddOverrideCircleLocation( <28356, 41776, 10095>, 50, true )    //North Zeus
				break

			case 6:
				SURVIVAL_AddOverrideCircleLocation( <30150, 27966, 9159>, 50, true )    //North Thunder
				break

			case 7:
				SURVIVAL_AddOverrideCircleLocation( <36862, 24638, 9528>, 50, true )    //North East Thunder
				break

			case 8:
				SURVIVAL_AddOverrideCircleLocation( <41238, 22722, 9646>, 50, true )    //Far North East Thunder
				break

			case 9:
				SURVIVAL_AddOverrideCircleLocation( <39621, 21854, 9781>, 50, true )    //Far East Thunder
				break
		}
	}
	{
		//StormCatcher #3
		switch ( RandomInt( 9 ) )
		{
			case 0:
				SURVIVAL_AddOverrideCircleLocation( <26375, 16234, 5449>, 50, true )    // North Storm Catcher
				break

			case 1:
				SURVIVAL_AddOverrideCircleLocation( <24325, 7048, 4627>, 50, true )    // South Storm Catcher
				break

			case 2:
				SURVIVAL_AddOverrideCircleLocation( <30837, 9173, 5958>, 50, true ) // East Storm Catcher
				break

			case 3:
				SURVIVAL_AddOverrideCircleLocation( <22143, 12669, 6075>, 50, true ) // west Storm Catcher
				break

			case 4:
				SURVIVAL_AddOverrideCircleLocation( <37530, 9916, 6359>, 50, true ) // east Storm Catcher by Hut
				break

			case 5:
				SURVIVAL_AddOverrideCircleLocation( <41160, 12685, 7469>, 50, true ) // Far East Storm Catcher no name right
				break

			case 6:
				SURVIVAL_AddOverrideCircleLocation( <16639, 16355, 5733>, 50, true ) // Far West Storm Catcher outside command center
				break

			case 7:
				SURVIVAL_AddOverrideCircleLocation( <29117, 10918, 5958>, 50, true ) // slight West Storm
				break

			case 8:
				SURVIVAL_AddOverrideCircleLocation( <37802, 13881, 7336>, 50, true ) // Far East Storm Catcher no name left
				break
		}
	}
	{
		//Launch Pad + Fish Farm #4
		switch ( RandomInt( 14 ) )
		{
			case 0:
				SURVIVAL_AddOverrideCircleLocation( <24077, -13567, 49>, 50, true )    //Launch Pad Middle Prong
				break

			case 1:
				SURVIVAL_AddOverrideCircleLocation( <23301, -10158, 113>, 50, true )    //Launch Pad Upper Prong
				break

			case 2:
				SURVIVAL_AddOverrideCircleLocation( <26220, -15123, 49>, 50, true ) //Lanch Pad Lower Prong
				break

			case 3:
				SURVIVAL_AddOverrideCircleLocation( <20080, -5078, 346>, 50, true ) // Small POI West of Launch Pad
				break

			case 4:
				SURVIVAL_AddOverrideCircleLocation( <21684, -1193, 736>, 50, true ) // North West of Launch Pad
				break

			case 5:
				SURVIVAL_AddOverrideCircleLocation( <32868, -4379, 1615>, 50, true ) // North Launch Pad
				break

			case 6:
				SURVIVAL_AddOverrideCircleLocation( <32460, -13181, 209>, 50, true ) // South East Launch Pad
				break

			case 7:
				SURVIVAL_AddOverrideCircleLocation( <28225, -27109, -4>, 50, true ) //Fish Farm
				break

			case 8:
				SURVIVAL_AddOverrideCircleLocation( <38475, -20143, 243>, 50, true ) //far East Fish farm
				break

			case 9:
				SURVIVAL_AddOverrideCircleLocation( <25092, -26054, 658>, 50, true ) //North West Fish Farm
				break

			case 10:
				SURVIVAL_AddOverrideCircleLocation( <23743, -21823, -1>, 50, true ) //North Fish Farm
				break

			case 11:
				SURVIVAL_AddOverrideCircleLocation( <28517, -20147, 909>, 50, true ) //North Fish Farm new poi
				break

			case 12:
				SURVIVAL_AddOverrideCircleLocation( <33635, -25162, 9>, 50, true ) //East Fish Farm
				break

			case 13:
				SURVIVAL_AddOverrideCircleLocation( <25796, -20508, 1080>, 50, true ) //North FF new POI by bridge
				break
		}
	}
	{
		//Pylon + Coastal + ECHO + Barometer #5
		switch ( RandomInt( 19 ) )
		{
			case 0:
				SURVIVAL_AddOverrideCircleLocation( <13458, -14954, 1023>, 50, true )    //East Pylon Building
				break

			case 1:
				SURVIVAL_AddOverrideCircleLocation( <4472, -14759, 846>, 50, true )    //West Pylon Building
				break

			case 2:
				SURVIVAL_AddOverrideCircleLocation( <7628, -23159, 736>, 50, true ) //South Pylon Building
				break

			case 3:
				SURVIVAL_AddOverrideCircleLocation( <9825, -16710, 688>, 50, true ) // Center Pylon Building
				break

			case 4:
				SURVIVAL_AddOverrideCircleLocation( <2038, -35876, 1028>, 50, true ) // Coastal
				break

			case 5:
				SURVIVAL_AddOverrideCircleLocation( <1103, -38719, -26>, 50, true ) // South Coastal In water
				break

			case 6:
				SURVIVAL_AddOverrideCircleLocation( <-1805, -36765, 59>, 50, true ) // SW Costal
				break

			case 7:
				SURVIVAL_AddOverrideCircleLocation( <4057, -33651, 965>, 50, true ) // NE Costal
				break

			case 8:
				SURVIVAL_AddOverrideCircleLocation( <3963, -31213, 916>, 50, true ) // North Coastal
				break

			case 9:
				SURVIVAL_AddOverrideCircleLocation( <16238, -34220, 776>, 50, true ) // S Echo
				break

			case 10:
				SURVIVAL_AddOverrideCircleLocation( <21860, -28901, 33>, 50, true ) // E Echo
				break

			case 11:
				SURVIVAL_AddOverrideCircleLocation( <3770, -29042, 1088>, 50, true ) // Slightly North Costal
				break

			case 12:
				SURVIVAL_AddOverrideCircleLocation( <-15381, -27847, 249>, 50, true ) // S Barometer outside
				break

			case 13:
				SURVIVAL_AddOverrideCircleLocation( <-17994, -24949, 396>, 50, true ) // S Barometer near center
				break

			case 14:
				SURVIVAL_AddOverrideCircleLocation( <-9229, -27068, 53>, 50, true ) // E Barometer E of tower
				break

			case 15:
				SURVIVAL_AddOverrideCircleLocation( <-12589, -23171, -81>, 50, true ) // E Barometer W of tower
				break

			case 16:
				SURVIVAL_AddOverrideCircleLocation( <-14045, -25229, -81>, 50, true ) // E Barometer W of tower #2
				break

			case 17:
				SURVIVAL_AddOverrideCircleLocation( <-14679, -16371, 239>, 50, true ) // N Barometer
				break

			case 18:
				SURVIVAL_AddOverrideCircleLocation( <-9044, -32674, 286>, 50, true ) // SE Barometer in invalid zone
				break
		}
	}
	{
		//Cenote + Mill #6
		switch ( RandomInt( 13 ) )
		{
			case 0:
				SURVIVAL_AddOverrideCircleLocation( <-36502, -23249, 184>, 50, true ) //Cenote Cave
				break

			case 1:
				SURVIVAL_AddOverrideCircleLocation( <-41178, -10358, 441>, 50, true ) //North Cenote Cave Invalid Zone
				break

			case 2:
				SURVIVAL_AddOverrideCircleLocation( <-21679, -15713, -32>, 50, true ) //North East Cenote
				break

			case 3:
				SURVIVAL_AddOverrideCircleLocation( <-34495, -18468, 228>, 50, true ) //Center Cenote
				break

			case 4:
				SURVIVAL_AddOverrideCircleLocation( <-29548, -18065, 271>, 50, true ) //NC Cenote
				break

			case 5:
				SURVIVAL_AddOverrideCircleLocation( <-36552, -17208, 125>, 50, true ) //WC Cenote
				break

			case 6:
				SURVIVAL_AddOverrideCircleLocation( <-25745, -5839, 49>, 50, true )    //Far South East Mill
				break

			case 7:
				SURVIVAL_AddOverrideCircleLocation( <-27552, -3992, 53>, 50, true ) //Soth East Mill
				break

			case 8:
				SURVIVAL_AddOverrideCircleLocation( <-30489, 4364, 214>, 50, true ) //The Mill
				break

			case 9:
				SURVIVAL_AddOverrideCircleLocation( <-42150, 11338, 92>, 50, true ) //North West Mill
				break

			case 10:
				SURVIVAL_AddOverrideCircleLocation( <-35140, 9979, 545>, 50, true ) //North Mill
				break

			case 11:
				SURVIVAL_AddOverrideCircleLocation( <-37158, -1517, 108>, 50, true ) //west Mill
				break

			case 12:
				SURVIVAL_AddOverrideCircleLocation( <-34850, 3616, 616>, 50, true ) //middle of Mill
				break
		}
	}
	{
		//Morth Pad + Downed Beast + Checkpoint #7
		switch ( RandomInt( 17 ) )
		{
			case 0:
				SURVIVAL_AddOverrideCircleLocation( <-35068, 24386, 203>, 50, true )    //Downed Beast Backside
				break

			case 1:
				SURVIVAL_AddOverrideCircleLocation( <-33417, 17852, 614>, 50, true ) //Downed Beast Front Side
				break

			case 2:
				SURVIVAL_AddOverrideCircleLocation( <-38900, 15305, 512>, 50, true ) //South Downed Beast
				break

			case 3:
				SURVIVAL_AddOverrideCircleLocation( <-22860, 15648, 1523>, 50, true ) //Checkpoint
				break

			case 4:
				SURVIVAL_AddOverrideCircleLocation( <-23268, 32141, 335>, 50, true ) //North Pad
				break

			case 5:
				SURVIVAL_AddOverrideCircleLocation( <-26327, 37019, 193>, 50, true ) //North Pad Middle Prong
				break

			case 6:
				SURVIVAL_AddOverrideCircleLocation( <-26035, 27991, 418>, 50, true ) //North Downed Beast in hut
				break

			case 7:
				SURVIVAL_AddOverrideCircleLocation( <-12049, 28768, 506>, 50, true ) //North East North Pad (by Armory)
				break

			case 8:
				SURVIVAL_AddOverrideCircleLocation( <-39163, 20971, 194>, 50, true ) //downbeast
				break

			case 9:
				SURVIVAL_AddOverrideCircleLocation( <-37122, 15851, 273>, 50, true ) //downbeast mouth
				break

			case 10:
				SURVIVAL_AddOverrideCircleLocation( <-19587, 30869, 289>, 50, true ) //outside northpad
				break

			case 11:
				SURVIVAL_AddOverrideCircleLocation( <-10902, 27939, 436>, 50, true ) //by poi near armory
				break

			case 12:
				SURVIVAL_AddOverrideCircleLocation( <-18016, 14593, 1783>, 50, true ) //checkpoint 3 pills
				break

			case 13:
				SURVIVAL_AddOverrideCircleLocation( <-23321, 12041, 858>, 50, true ) //South Checkpoint
				break

			case 14:
				SURVIVAL_AddOverrideCircleLocation( <-14460, 32409, 418>, 50, true ) //Northpad inside north hut
				break

			case 15:
				SURVIVAL_AddOverrideCircleLocation( <-28824, 36365, 33>, 50, true ) //Northpad south prong
				break

			case 16:
				SURVIVAL_AddOverrideCircleLocation( <-24791, 38237, 33>, 50, true ) //Northpad north prong
				break
		}
	}
}