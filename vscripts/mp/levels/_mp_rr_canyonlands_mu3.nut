global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	SetVictorySequencePlatformModel( $"mdl/rocks/victory_platform.rmdl", < 0, 0, -10 >, < 0, 0, 0 > )
	SURVIVAL_SetPlaneHeight( 24000 )
	SURVIVAL_SetAirburstHeight( 8000 )
	SURVIVAL_SetMapCenter( <0, 0, 0> )

	PrecacheModel( $"mdl/levels_terrain/mp_rr_canyonlands/crypto_holo_map_01_mu3.rmdl")
	PrecacheModel( $"mdl/levels_terrain/mp_rr_canyonlands/crypto_holo_map_03_mu3.rmdl")
	PrecacheModel( $"mdl/levels_terrain/mp_rr_canyonlands/crypto_holo_map_04_mu3.rmdl")
	PrecacheModel( $"mdl/levels_terrain/mp_rr_canyonlands/crypto_holo_map_05_mu3.rmdl")
	MapZones_RegisterDataTable( $"datatable/map_zones/zones_mp_rr_canyonlands_mu3.rpak" )

	//Clean up unused ents
	AddCallback_EntitiesDidLoad( KCMU3_OnEntitiesDidLoad )

	AddCallback_OnPlayerRespawned( OnPlayerCreated )
	Canyonlands_MapInit_Common()
}

void function OnPlayerCreated( entity player )
{
	thread warningprint( player )
}

void function warningprint( entity player )
{
	wait 1
	Dev_PrintMessage(
    player,
    "THIS MAP IS WORK IN PROGRESS",
    "Detected map: " + GetMapName() +
	"\n\nKnown Bugs: Missing audiolog in caustic town takeover\nSome flickery textures." + "\n\nPlease report any glitch you see outside of known bugs\nto our discord server!",
    25, "SQ_UI_InGame_10SecondTimeWarning" )
}

void function CleanupEnt( entity ent )
{
	if( !IsValid( ent ) )
		return

	ent.Destroy()
}

void function InitInfoTarget( entity infotarget )
{
	if( GetEditorClass( infotarget ) == "info_warp_gate_path_node" || infotarget.GetScriptName() == "apex_screen" )
		return

	if( ShouldDestroyInfoTarget( infotarget ) )
	{
		// printt( "Destroyed useless info target ent leftover" )
		infotarget.Destroy()
	}
}

bool function ShouldDestroyInfoTarget( entity infotarget )
{
	if( GetEditorClass( infotarget ) == "" && infotarget.GetScriptName() == "" && infotarget.GetTargetName() == "" )
		return true

	if( GetEditorClass( infotarget ) == "info_warp_gate_path_node" || infotarget.GetScriptName() == "apex_screen" )
		return false

	if( infotarget.GetModelName() == $"mdl/test/loot_box_half_01.rmdl" || infotarget.GetModelName() == $"mdl/vehicle/droppod_fireteam/droppod_fireteam.rmdl" )
		return true

	return false
}

void function InitScriptRef( entity scriptref )
{
	array<string> stringCats

	if( GetEditorClass( scriptref ) != "" )
	{
		stringCats = split( GetEditorClass( scriptref ), "_" )

		if( stringCats[1] != "survival" )
		{
			// printt( "Removed Unused Script Ref Ent. Editor: ", GetEditorClass( scriptref ), " ScriptRef: ", scriptref.GetScriptName()," Target: ", scriptref.GetTargetName() )
			scriptref.Destroy()
			return
		}
	}

	if( GetEditorClass( scriptref ) == "" && scriptref.GetScriptName() == "" && scriptref.GetTargetName() == "" || GetEditorClass( scriptref ) == "info_survival_circle_end_location" || scriptref.GetModelName() == $"mdl/dev/editor_ref.rmdl" )
	{
		// printt( "Destroyed useless script ref ent leftover" )
		scriptref.Destroy()
	}
}

void function KCMU3_OnEntitiesDidLoad()
{
	printt( "KCMU3_OnEntitiesDidLoad" )

	array<entity> scriptRefs = GetEntArrayByClass_Expensive( "script_ref" )
	foreach( ref in scriptRefs )
		InitScriptRef( ref )

	array<entity> infoTargets = GetEntArrayByClass_Expensive( "info_target" )
	foreach( target in infoTargets )
		InitInfoTarget( target )

	array<entity> props = GetEntArrayByClass_Expensive( "prop_dynamic" )
	foreach( prop in props )
		InitPropDynamic( prop )
}

void function InitPropDynamic( entity prop )
{
	if( ShouldDestroyPropDynamic( prop.GetModelName() ) )
		prop.Destroy()
}

bool function ShouldDestroyPropDynamic( string model )
{
	switch( model )
	{
		case "mdl/props/proxy_r5/pvp_currency_container.rmdl":
		case "mdl/props/crafting_siphon/crafting_siphon.rmdl":
		case "mdl/props/crafting_replicator/crafting_replicator.rmdl":
		return true
	}

	return false
}