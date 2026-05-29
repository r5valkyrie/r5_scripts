global function CodeCallback_PreMapInit
global function CodeCallback_MapInit

void function CodeCallback_PreMapInit()
{

}

void function CodeCallback_MapInit()
{
	MapZones_RegisterDataTable( $"datatable/map_zones/zones_mp_rr_olympus_mu2.rpak" )
	mp_rr_olympus_mu2_SurvivalPreprocess()

	Olympus_MapInit_Common()
	CommonStoryEvents_Init()

	PhaseDriver_Init()

	SURVIVAL_SetPlaneHeight( 12500)
	SURVIVAL_SetAirburstHeight( 2500 )
	Survival_SetMapFloorZ( -10000 )

	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	AddSpawnCallbackEditorClass( "trigger_multiple", "trigger_warp_gate", CreatePhaseRunnerPings )

	SURVIVAL_SetMapCenter( <-7833.5498, 3691.55078, 0> )

	if ( GetCurrentPlaylistVarInt( "deathfield_end_on_script_locations", 0 ) == 1 )
		AddCircleOverrideLocations()

	//INTRO CAMERAS------------------------------------//
	IntroCameraSettings view

	//CONTROL INTRO CAMERA
	if( GameMode_IsActive( eGameModes.CONTROL ) )
	{
		//HAMMOND LABS
		view.origin = <  -1543.487549, -2138.820801, -5774.206055 >
		view.angles = <  -14.419999, 162.672440, 0 >
		view.fov = 90
	}
	else //SURVIVAL INTRO CAMERAS
	{
		int select = RandomInt( 11 )
		switch( select )
		{
			// Gardens
			case 0:
				view.origin = <  16304.199, 8768.416, -3585.755 >
				view.angles = <  -8.096, -28.855, 0.000 >
				view.fov = 90
				break
			// Bonsai Plaza
			case 1:
				view.origin = < -2003.459473, -27822.595703, -4700.567871 >
				view.angles = < -25.986853, -133.921249, 0.000 >
				view.fov = 90
				break
			// Terminal
			case 2:
				view.origin = < -7632.929688, -9332.978516, -5390.995605 >
				view.angles = <  -13.916187, -154.117233, 0.000000 >
				view.fov = 90
				break
			// Glitched Terrain Crash (zone 16)
			case 3:
				view.origin = < -7964.891113, -17304.951172, -6000.189941 >
				view.angles = <  -18.358257, -155.296707, 0.000000 >
				view.fov = 90
				break
			// Hammond Labs
			case 4:
				view.origin = < -4599.596191, 1747.056641, -6074.203613 >
				view.angles = <  -16.389942, -84.758087, 0.000000 >
				view.fov = 90
				break
			// Ghost Ship (Interior)
			case 5:
				view.origin = < 9735.015625, -27359.310547, -5300.137207 >
				view.angles = <  -1.781646, -107.014275, 0.000 >
				view.fov = 90
				break
			// Teleported Ship Skybox
			case 6:
				view.origin = < -26059.683594, -20992.939453, -4850.262695 >
				view.angles = <  -16.254917, -88.276131, 0.000000 >
				view.fov = 90
				break
			// Rift
			case 7:
				view.origin = < 3623.342, 24724.410, -6600.804 >
				view.angles = <  -22.174934, -29.661617, 0.000000 >
				view.fov = 90
				break
			// Phase Driver
			case 8:
				view.origin = < -15477.714844, -21333.376953, -4850.213379 >
				view.angles = <  -24.925219, -156.384293, 0.000000 >
				view.fov = 90
				break
			// Oasis
			case 9:
				view.origin = <  -30363.324, 15079.857, -5520.880 >
				view.angles = <  -21.736, -140.125, 0.000 >
				view.fov = 90
				break
			// Lifeline Clinic
			case 10:
				view.origin = <  22524.603516, 9775.801758, -2972.398193 >
				view.angles = <  -3.850041, -56.162212, 0.000 >
				view.fov = 90
				break
		}
	}
	SetIntroCameraSettings( view )

	thread ManageJitterVFX_Thread()

                      
                                                          

                  
                                                                                       
                                                                                   
                                                                                          
                                                                                          
                                                                               
                                                                                           
                                                                                          
                                                                                           
                                                                                           
                                                                                   
                                                                                             
                                                                                           
                                                                                     
                                                                                            
                                                                                     
                                                                                            
                                                                                 
                                                                                           
                                                                                               
                                                                                                    
                                                                                                 
                            
}

void function CreatePhaseRunnerPings( entity trig )
{
	array<entity> phaseRiftTrigArr = GetEntArrayByScriptName( "amb_diag_rift" )
	if ( phaseRiftTrigArr.len() != 1 )
	{
		Warning( "Warning! Found more than one trigger with name amb_diag_rift, exiting out of phase runner ping volume creation" )
		return
	}
	entity phaseRiftTrig = phaseRiftTrigArr[ 0 ]

	bool isPhaseRiftTrigger = phaseRiftTrig.ContainsPoint( trig.GetOrigin() )
	if ( isPhaseRiftTrigger )
	{
		entity traceBlocker = CreateTraceBlockerVolume( trig.GetOrigin(), 640.0, false, CONTENTS_BLOCK_PING | CONTENTS_NOGRAPPLE, TEAM_MILITIA, "pr_pingvol" )
	}
	else
	{
		entity traceBlocker = CreateTraceBlockerVolume( trig.GetOrigin(), 640, false, CONTENTS_BLOCK_PING | CONTENTS_NOGRAPPLE, TEAM_MILITIA, "pr_pingvol" )

		// On olympus, the warp exit hints indicate trigger orientation. On CLands, they don't.
		entity warpExitHint
		array<entity> linkedEnts = trig.GetLinkEntArray()
		foreach( entity linkedEnt in linkedEnts )
		{
			if ( linkedEnt.GetLinkEntArray().len() > 0 )
				continue
			if ( linkedEnt.GetClassName() != "info_target" )
				continue

			warpExitHint = linkedEnt
			break
		}

		vector forward = warpExitHint.GetForwardVector()
		vector newOrg = trig.GetOrigin() + ( forward * -512 )
		traceBlocker.SetOrigin( newOrg )
	}

}

void function EntitiesDidLoad()
{
	int unixTimeNow = GetUnixTimestamp()
	if ( unixTimeNow >=  expect int( GetCurrentPlaylistVarTimestamp( "s09e03_active", UNIX_TIME_FALLBACK_2038 ) ) )
	{
		array<entity> skyboxShips =  GetEntArrayByScriptName( "skybox_infected_ships" )
		if ( skyboxShips.len() != 0 )
		{
			foreach ( skyboxShip in skyboxShips )
				skyboxShip.Destroy()
		}
	}
}

void function AddCircleOverrideLocations()
{
	SURVIVAL_AddOverrideCircleLocation( <-18165, 30989, -6171>, 0, true )    // Docks
	SURVIVAL_AddOverrideCircleLocation( <-14786, 22705, -6672>, 0, true )    // Docks - Pathfinder
	SURVIVAL_AddOverrideCircleLocation( <-27500, 23265, -6504>, 0, true )    // Carrier
	SURVIVAL_AddOverrideCircleLocation( <-34216, 14719, -5528>, 0, true )    // Oasis
	SURVIVAL_AddOverrideCircleLocation( <-24134, 12428, -5760>, 0, true )    // East of Oasis
	SURVIVAL_AddOverrideCircleLocation( <-22569, 153, -5568>, 0, true )    // Estates
	SURVIVAL_AddOverrideCircleLocation( <-34150, -523, -4344>, 0, true )    // Marina-ish
	SURVIVAL_AddOverrideCircleLocation( <-33188, -16372, -3496>, 0, true )    // Hydroponics
	SURVIVAL_AddOverrideCircleLocation( <-25588, -10407, -4455>, 0, true )	// NE of Hydroponics
	SURVIVAL_AddOverrideCircleLocation( <-2946, -24898, -4464>, 0, true )    // Bonsai Plaza
	SURVIVAL_AddOverrideCircleLocation( <-13309, -20101, -4383>, 0, true )    // Houses NW of Bonsai
	SURVIVAL_AddOverrideCircleLocation( <563, -14158, -6061>, 0, true )    // Solar Array
	SURVIVAL_AddOverrideCircleLocation( <22762, -16177, -4998>, 0, true )    // Orbital Cannon
	SURVIVAL_AddOverrideCircleLocation( <11516, -18020, -5684>, 0, true )		// NW of Cannon
	SURVIVAL_AddOverrideCircleLocation( <17913, -2511, -5112>, 0, true )    // Grow Towers
	SURVIVAL_AddOverrideCircleLocation( <16907, 8456, -3624>, 0, true )    // Gardens
	SURVIVAL_AddOverrideCircleLocation( <9012, 18621, -5865>, 0, true )    // Rift (outer)
	SURVIVAL_AddOverrideCircleLocation( <650, 8502, -5000>, 0, true )    // Energy Depot
	SURVIVAL_AddOverrideCircleLocation( <5237, -4233, -4301>, 0, true )    // Near Phase Runner
	SURVIVAL_AddOverrideCircleLocation( <-3920, -3602, -6122>, 0, true )    // Hammond Labs
	SURVIVAL_AddOverrideCircleLocation( <-14139, -4043, -5552>, 0, true )    // Between Labs and Estates
	SURVIVAL_AddOverrideCircleLocation( <-13504, 11612, -6558>, 0, true )    // Turbine
	SURVIVAL_AddOverrideCircleLocation( <-4818, 27611, -6108>, 0, true )    // Power Grid (outer)
	SURVIVAL_AddOverrideCircleLocation( <-4969, 18418, -5892>, 0, true )    // Power Grid (inner)
} 