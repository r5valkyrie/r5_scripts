global function CodeCallback_MapInit
global function CodeCallback_PreMapInit

const asset BUNKER_MODEL_SCALE_DOWN = $"mdl/props/bunker_hatch/bunker_hatch_scale_down.rmdl"
const asset BUNKER_BUTTON_MODEL = $"mdl/props/global_access_panel_button/global_access_panel_button_console.rmdl"
const asset BUNKER_MODEL = $"mdl/props/bunker_hatch/bunker_hatch.rmdl"

struct {
	array<entity> bunkerDoorsScaleDown
	array<entity> bunkerDoors
} file

void function CodeCallback_PreMapInit()
{
	if (GetMapName() == "mp_rr_canyonlands_mu2_tt" )
		CryptoTT_PreMapInit()
}

void function CodeCallback_MapInit()
{
	SetVictorySequencePlatformModel( $"mdl/rocks/victory_platform.rmdl", < 0, 0, -10 >, < 0, 0, 0 > )
	SURVIVAL_SetPlaneHeight( 24000 )
	SURVIVAL_SetAirburstHeight( 8000 )
	SURVIVAL_SetMapCenter( <0, 0, 0> )
    SURVIVAL_SetMapDelta( 4900 )

	if (GetMapName() == "mp_rr_canyonlands_mu2_mv" )
		MapZones_RegisterDataTable( $"datatable/map_zones/zones_mp_rr_canyonlands_mu2_mv.rpak" )
	else if (GetMapName() == "mp_rr_canyonlands_mu2_tt" )
	{
		MapZones_RegisterDataTable( $"datatable/map_zones/zones_mp_rr_canyonlands_mu2_tt.rpak" )
	}
	else if (GetMapName() == "mp_rr_canyonlands_mu3" )
	{
		MapZones_RegisterDataTable( $"datatable/map_zones/zones_mp_rr_canyonlands_mu3.rpak" )
	}
	else
		MapZones_RegisterDataTable( $"datatable/map_zones/zones_mp_rr_canyonlands_mu2.rpak" )

	//Clean up unused ents
	AddCallback_EntitiesDidLoad( KCMU2_OnEntitiesDidLoad )
	Canyonlands_MapInit_Common()
}

void function KCMU2_OnEntitiesDidLoad()
{
	if ( GetMapName() == "mp_rr_canyonlands_mu2_tt" )
	{
		PrecacheCryptoMapAssets()
		InitCryptoMap()
		InitCryptoSquadTVs()
	}

	array<entity> props = GetEntArrayByClass_Expensive( "prop_dynamic" )
	printt( "Processing " + props.len() + " prop_dynamic entities" )
	foreach( prop in props )
		InitPropDynamic( prop )

	SetupBunkersDoors()
}

void function InitPropDynamic( entity prop )
{
	if( prop.GetModelName() == BUNKER_MODEL )
		file.bunkerDoors.append( prop )

	if( prop.GetModelName() == BUNKER_MODEL_SCALE_DOWN )
		file.bunkerDoorsScaleDown.append( prop )

	if( ShouldDestroyPropDynamic( prop.GetModelName() ) )
	{
		printt( "Destroying prop: " + prop.GetModelName() + " at " + prop.GetOrigin() )
		prop.Destroy()
	}
}

bool function ShouldDestroyPropDynamic( string model )
{
	switch( model )
	{
		case "mdl/props/proxy_r5/pvp_currency_container.rmdl":
		//case "mdl/props/crafting_siphon/crafting_siphon.rmdl":
		//case "mdl/props/crafting_replicator/crafting_replicator.rmdl":
		//case "mdl/props/global_access_panel_button/global_access_panel_button_console_w_stand.rmdl":
		return true
	}

	return false
}

void function SetupBunkersDoors()
{
	array<entity> allDoors
	allDoors.extend( file.bunkerDoorsScaleDown )
	allDoors.extend( file.bunkerDoors )

	foreach( entity door in allDoors )
	{
		entity button
		foreach( link in door.GetLinkEntArray() )
		{
			// printt( door, link, link.GetOrigin() )
			if( link.GetScriptName() == "bunker_hatch_panel_model" )
				button = link
		}

		door.Anim_PlayOnly( "bunker_hatch_close_idle" )
		door.SetCycle( 1.0 )

		if( IsValid( button ) )
		{
			button.kv.solid = 0 //fixes crash
			button.SetUsableByGroup( "pilot" )
			button.SetUsePrompts( "%use% To Open Hatch", "%use% To Open Hatch" )

			if( file.bunkerDoorsScaleDown.contains( door ) )
				AddCallback_OnUseEntity( button, BunkerDoorSmall_OnOpen )
			else
				AddCallback_OnUseEntity( button, BunkerDoor_OnOpen )

		} else //There is not button only for Ash Teaser bunker, leave it open.
		{
			thread function() : ( door )
			{
				door.Anim_PlayOnly( "bunker_hatch_open" )
				wait door.GetSequenceDuration( "bunker_hatch_open" )
				door.Anim_PlayOnly( "bunker_hatch_open_idle" )
			}()
		}
	}
}

entity function BunkerDoor_GetDoorForButton( entity button )
{
	foreach( door in file.bunkerDoorsScaleDown )
	{
		foreach( link in door.GetLinkEntArray() )
		{
			if( link == button )
				return door
		}
	}

	foreach( door in file.bunkerDoors )
	{
		foreach( link in door.GetLinkEntArray() )
		{
			if( link == button )
				return door
		}
	}

	return null
}

void function BunkerDoor_OnOpen( entity button, entity user, int input )
{
	button.SetSkin( 1 )
	button.UnsetUsable()

	entity door = BunkerDoor_GetDoorForButton( button )

	bool doorHasSpecialZiplineStart = false
	entity specialZipStartInfoTarget

	foreach( link in door.GetLinkEntArray() )
	{
		if( link.GetScriptName() == "hatch_special_zipline_start_target" )
		{
			doorHasSpecialZiplineStart = true
			specialZipStartInfoTarget = link
		}
	}

	vector forward = AnglesToForward( door.GetAngles() )
	vector right   = AnglesToRight( door.GetAngles() )
	vector up      = AnglesToUp( door.GetAngles() )

	// Define start offset relative to the door
	float startForwardOffset = -25
	float startRightOffset   = -60
	float startUpOffset      = 365

	vector startOffset = (forward * startForwardOffset) + (right * startRightOffset) + (up * startUpOffset)
	vector worldStart = door.GetOrigin() + startOffset

	// Define end offset relative to the door
	float endForwardOffset = -25
	float endRightOffset   = -60
	float endUpOffset      = -700

	vector endOffset = (forward * endForwardOffset) + (right * endRightOffset) + (up * endUpOffset)
	vector worldEnd = door.GetOrigin() + endOffset

	thread function() : ( door, button, worldStart, worldEnd )
	{
		door.Anim_PlayOnly( "bunker_hatch_open" )
		wait door.GetSequenceDuration( "bunker_hatch_open" )
		door.Anim_PlayOnly( "bunker_hatch_open_idle" )
		BunkerDoor_CreateZipline( worldStart, worldEnd, true, <0,0,0>, -1, true )
	}()
}

void function BunkerDoorSmall_OnOpen( entity button, entity user, int input )
{
	button.SetSkin( 1 )
	button.UnsetUsable()

	entity door = BunkerDoor_GetDoorForButton( button )

	bool doorHasSpecialZiplineStart = false
	entity specialZipStartInfoTarget

	foreach( link in door.GetLinkEntArray() )
	{
		if( link.GetScriptName() == "hatch_special_zipline_start_target" )
		{
			doorHasSpecialZiplineStart = true
			specialZipStartInfoTarget = link
		}
	}

	if( doorHasSpecialZiplineStart && specialZipStartInfoTarget )
	{
		thread BunkerDoor_CreateZipline( specialZipStartInfoTarget.GetOrigin() + <0,0,50>, < specialZipStartInfoTarget.GetOrigin().x, specialZipStartInfoTarget.GetOrigin().y, button.GetOrigin().z >, true, <0,0,0>, -1, true )
	}

	thread function() : ( door, button )
	{
		door.Anim_PlayOnly( "bunker_hatch_open" )
		wait door.GetSequenceDuration( "bunker_hatch_open" )
		door.Anim_PlayOnly( "bunker_hatch_open_idle" )

		BunkerDoor_CreateZipline( < door.GetOrigin().x, door.GetOrigin().y, door.GetOrigin().z + 200 > , < door.GetOrigin().x, door.GetOrigin().y, door.GetOrigin().z - 1000 >, true, <0,0,0>, -1, true )
	}()
}


array<vector> function Flowstate_GenerateSmoothPathForBasePath( array<vector> path )
{
	printt( "generating smooth points for path with len", path.len() )
	if( path.len() == 0 )
		return []

    array<vector> smoothPath
	array<vector> points = clone path

	int numPoints = 10

	points.insert( 0, points[0] )
	points.removebyvalue( points[points.len()-1] )
	if( path.len() == 7 )
		points.removebyvalue( points[points.len()-1] )
	points.insert( points.len(), points[points.len()-1] )

    for (int i = 0; i < points.len() - 3; i++)
    {
        for (int j = 0; j < numPoints; j++)
       {
            float t = float( j ) / float( numPoints )
            smoothPath.append( Flowstate_CatmullRom( points[i], points[i+1], points[i+2], points[i+3], t) )
        }
    }
    return smoothPath
}

//Catmull-Rom algo to smooth the path.
vector function Flowstate_CatmullRom( vector p0, vector p1, vector p2, vector p3, float t)
{
    vector v0 = p1
    vector v1 = 0.5 * (p2 - p0)
    vector v2 = p0 - 2.5 * p1 + 2 * p2 - 0.5 * p3
    vector v3 = 0.5 * (p3 - p0) + 1.5 * (p1 - p2)

    return v0 + v1 * t + v2 * t * t + v3 * t * t * t;
}
