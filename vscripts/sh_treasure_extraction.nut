global function ShTreasureExtractionInit

const string TREASURE_BUTTON_MODEL_SCRIPTNAME = "genericTreasureExtractButton"
const string TREASURE_BOX_SCRIPTNAME = "treasureBoxForQuests"
const float TREASURE_EXTRACT_USE_TIME = 6.0
const float TREASURE_EXTRACT_USE_TIME_SOLO = 3.5
const float MINI_HARVESTER_DEPLOY_TIME = 1.6

#if SERVER
	global function MiniHarvesterCreate
	global function MiniHarvesterDestroy
	global function MiniHarvesterFinishExtraction
	global function CreateTreasureExtraction
	global function CreateTreasureExtractionUsePoint
	global function AddCallback_OnTreasureExtractionApproached
	global function AddCallback_OnTreasureExtractionStarted
	global function AddCallback_OnTreasureExtractionFinished
	global function AddCallback_OnTreasureRetrieved
	global function TreasureBoxCreate

global struct MiniHarvesterData
{
	entity mainModel
	entity fxControlPointEnt
	array<entity> extractionFx
	array<string> extractionSounds
	vector origin
	vector angles
}

global struct TreasureExtractionData
{
	vector origin
	vector angles
	entity playerButton
	entity treasureModel
	array <entity> extractionFx
	float extractionDuration
	entity playerWhoPickedUpTreasure
	bool treasurePickedUp
	bool treasureApproached
	array<void functionref( TreasureExtractionData )> callbacksOnExtractionStarted
	array<void functionref( TreasureExtractionData )> callbacksOnExtractionApproached
	array<void functionref( TreasureExtractionData )> callbacksOnExtractionFinished
	array<void functionref( entity, TreasureExtractionData )> callbacksOnTreasureRetrieved
	MiniHarvesterData &miniHarvester
}
#endif //SERVER

//SHARED
void function ShTreasureExtractionInit()
{
	PrecacheScriptString( TREASURE_BOX_SCRIPTNAME )
	PrecacheScriptString( TREASURE_BUTTON_MODEL_SCRIPTNAME )

	RegisterSignal( "TreasureButtonReprogram_Success" )
	#if SERVER
		RegisterSignal( "MiniHarvesterFinishExtraction" )
		AddSpawnCallback_ScriptName( TREASURE_BUTTON_MODEL_SCRIPTNAME, OnTreasureUsableButtonSpawn )
	#endif //SERVER

	#if CLIENT
		AddCreateCallback( "prop_dynamic", OnTreasureUsableButtonSpawn )
		AddCreateCallback( "prop_dynamic", Client_OnTreasureBoxCreated )
	#endif //SERVER
}
//END SHARED


#if SERVER
TreasureExtractionData function CreateTreasureExtraction( vector origin, vector angles, float treasureRadius, float treasureHeight, float extractionTime )
{
	TreasureExtractionData treasureExtractionData

	////////////////////////////////////////
	// Trigger for when player gets close
	////////////////////////////////////////
	entity trigger = SpawnRadiusTrigger( origin, treasureRadius, treasureHeight, 10 )
	trigger.ConnectOutput( "OnStartTouch", void function ( entity trigger, entity activator, entity caller, var value ) : ( treasureExtractionData )
	{
		if ( !IsValid( trigger ) )
			return

		if ( !IsValid( activator ) )
			return

		if ( !activator.IsPlayer() )
			return

		if ( treasureExtractionData.treasureApproached )
			return

		treasureExtractionData.treasureApproached = true
		trigger.Destroy()

		foreach ( callbackFunc in treasureExtractionData.callbacksOnExtractionApproached )
			callbackFunc( treasureExtractionData )
	} )


	///////////////////////////////////////////
	// Invisible button for player to activate
	///////////////////////////////////////////
	entity button = CreateTreasureExtractionUsePoint( origin, angles )
	treasureExtractionData.playerButton = button

	//Other vars
	treasureExtractionData.extractionDuration = extractionTime
	treasureExtractionData.origin = origin
	treasureExtractionData.angles = angles

	thread TreasureExtractionThink( treasureExtractionData )

	return treasureExtractionData
}
#endif //SERVER



#if SERVER
void function TreasureExtractionThink( TreasureExtractionData treasureExtractionData )
{
	entity button = treasureExtractionData.playerButton
	vector treasurePos = treasureExtractionData.origin
	vector treasureAng = treasureExtractionData.angles

	CreateAirdropBadPlace( button, treasurePos, 128 )
	///////////////////////////
	// Player activated panel
	///////////////////////////
	button.WaitSignal( "TreasureButtonReprogram_Success" )

	foreach ( callbackFunc in treasureExtractionData.callbacksOnExtractionStarted )
		callbackFunc( treasureExtractionData )

	foreach( fx in treasureExtractionData.extractionFx )
	{
		if ( IsValid( fx ) )
			fx.Destroy()
	}
	///////////////////////////////////////////////////////////
	// Create Mini Harvester, extracting treasure for X seconds
	///////////////////////////////////////////////////////////
	treasureExtractionData.miniHarvester = MiniHarvesterCreate( treasurePos, treasureAng )
	entity miniHarvester = treasureExtractionData.miniHarvester.mainModel
	treasureExtractionData.treasureModel = TreasureBoxCreate( treasurePos, treasureAng )
	treasureExtractionData.treasureModel.UnsetUsable()
	treasureExtractionData.treasureModel.SetParent( treasureExtractionData.miniHarvester.mainModel, "BOX_POINT", false, 0.0 )

	float startIntensity = 0.1
	float endIntensity = 1.0
	thread PROTO_FadeModelIntensityOverTime( treasureExtractionData.treasureModel, treasureExtractionData.extractionDuration, startIntensity, endIntensity )
	thread PROTO_FadeModelIntensityOverTime( treasureExtractionData.miniHarvester.mainModel, treasureExtractionData.extractionDuration, startIntensity, endIntensity )

	float totalTimeToWait = treasureExtractionData.extractionDuration + MINI_HARVESTER_DEPLOY_TIME

	thread PlayDrillExtractionMusic( treasureExtractionData.extractionDuration )

	wait ( totalTimeToWait - 10 )
	string soundDrillAlmostDone = "SQ_Extractor_FinalExtraction_Start"
	EmitSoundOnEntity( treasureExtractionData.treasureModel, soundDrillAlmostDone )
	wait 10
	StopSoundOnEntity( treasureExtractionData.treasureModel, soundDrillAlmostDone )

	foreach ( callbackFunc in treasureExtractionData.callbacksOnExtractionFinished )
		callbackFunc( treasureExtractionData )

	///////////////////////////////////////////////////////////
	// Extraction done. Make treasure usable, wait for player pickup
	////////////////////////////////////////////////////////////
	//base harvester wires stop glowing
	startIntensity = 1.0
	endIntensity = 0.1
	thread PROTO_FadeModelIntensityOverTime( treasureExtractionData.miniHarvester.mainModel, 5.0, startIntensity, endIntensity )

	MiniHarvesterFinishExtraction( treasureExtractionData.miniHarvester )
	treasureExtractionData.treasurePickedUp = false
	EmitSoundOnEntity( treasureExtractionData.treasureModel, "SQ_Extractor_ItemLoop" )
	treasureExtractionData.treasureModel.SetUsable()
	treasureExtractionData.treasureModel.AddUsableValue( USABLE_CAN_USE_OVERRIDE ) //player-as-shadow zombie can pick this up too
	Highlight_SetNeutralHighlight( treasureExtractionData.treasureModel, "sp_interact_object" )
	Highlight_SetFriendlyHighlight( treasureExtractionData.treasureModel, "sp_interact_object" )
	Highlight_SetEnemyHighlight( treasureExtractionData.treasureModel, "sp_interact_object" )

	AddCallback_OnUseEntity_ServerOnly( treasureExtractionData.treasureModel, void function( entity treasureModel, entity player, int useInputFlags ) : ( treasureExtractionData, miniHarvester )
	{
		if ( !IsValid( player ) )
			return

		if ( !player.IsPlayer() )
			return

		treasureExtractionData.playerWhoPickedUpTreasure = player
		EmitSoundOnEntityOnlyToPlayer( player, player, "SQ_Retrieve_Extracted_1p" )
		EmitSoundOnEntityToTeamExceptPlayer( miniHarvester, "SQ_Retrieve_Extracted_3p", player.GetTeam(), player )
		treasureExtractionData.treasurePickedUp = true
	} )

	while( !treasureExtractionData.treasurePickedUp )
		wait 0.1

	///////////////////////////////
	// Player picked up treasure
	///////////////////////////////
	treasureExtractionData.treasureModel.Destroy()
	foreach ( callbackFunc in treasureExtractionData.callbacksOnTreasureRetrieved )
		callbackFunc( treasureExtractionData.playerWhoPickedUpTreasure, treasureExtractionData )

}
#endif //SERVER


#if SERVER
void function PlayDrillExtractionMusic( float extractTime )
{
	int musicTrackId = eMusicTrack.DrillExtraction45sec
	if ( extractTime > 45 )
		musicTrackId = eMusicTrack.DrillExtraction80sec

	wait MINI_HARVESTER_DEPLOY_TIME

	foreach( player in GetPlayerArray() )
	{
		if ( !IsValid( player ) )
			continue
		ClientMusic_PlayCustomTrackOnClient( player, musicTrackId )
	}
}
#endif //SERVER


#if SERVER
entity function TreasureBoxCreate( vector origin, vector angles )
{
	entity treasureModel = CreatePropDynamic_NoDispatchSpawn( GetObjectiveAsset_Model( "TREASUREEXTRACT_MODEL_TREASURE_CASE" ), origin, angles )
	treasureModel.SetUsable()
	treasureModel.SetUsePrompts( "#FREELANCE_TREASURE_PICKUP_USESTRING", "#FREELANCE_TREASURE_PICKUP_USESTRING" )
	treasureModel.AddUsableValue( USABLE_USE_COLLISION_ORIGIN | USABLE_USE_VERTICAL_LINE | USABLE_HORIZONTAL_FOV | USABLE_HIGH_DETAIL_TRACE )
	treasureModel.AddUsableValue( USABLE_CAN_USE_OVERRIDE ) //player-as-shadow zombie can pick this up too
	treasureModel.EnableRenderAlways()
	treasureModel.kv.fadedist = 10000
	treasureModel.kv.solid = 6
	treasureModel.Highlight_Enable()
	treasureModel.SetScriptName( TREASURE_BOX_SCRIPTNAME )
	DispatchSpawn( treasureModel )

	SetCallback_CanUseEntityCallback( treasureModel, SurvivalBasicUsable_CanUseFunction )

	return treasureModel
}
#endif //SERVER

#if SERVER
void function AddCallback_OnTreasureExtractionApproached( TreasureExtractionData treasureExtractionData, void functionref( TreasureExtractionData ) callbackFunc )
{

	#if DEVELOPER
		foreach ( func in treasureExtractionData.callbacksOnExtractionApproached )
		{
			Assert( func != callbackFunc, "Already added " + string( callbackFunc ) + " to treasureExtractionData" )
		}
	#endif

	treasureExtractionData.callbacksOnExtractionApproached.append( callbackFunc )
}
#endif //SERVER


#if SERVER
void function AddCallback_OnTreasureExtractionStarted( TreasureExtractionData treasureExtractionData, void functionref( TreasureExtractionData ) callbackFunc )
{

	#if DEVELOPER
		foreach ( func in treasureExtractionData.callbacksOnExtractionStarted )
		{
			Assert( func != callbackFunc, "Already added " + string( callbackFunc ) + " to treasureExtractionData" )
		}
	#endif

	treasureExtractionData.callbacksOnExtractionStarted.append( callbackFunc )
}
#endif //SERVER


#if SERVER
void function AddCallback_OnTreasureExtractionFinished( TreasureExtractionData treasureExtractionData, void functionref( TreasureExtractionData ) callbackFunc )
{

	#if DEVELOPER
		foreach ( func in treasureExtractionData.callbacksOnExtractionFinished )
		{
			Assert( func != callbackFunc, "Already added " + string( callbackFunc ) + " to treasureExtractionData" )
		}
	#endif

	treasureExtractionData.callbacksOnExtractionFinished.append( callbackFunc )
}
#endif //SERVER


#if SERVER
void function AddCallback_OnTreasureRetrieved( TreasureExtractionData treasureExtractionData, void functionref( entity, TreasureExtractionData ) callbackFunc )
{

	#if DEVELOPER
		foreach ( func in treasureExtractionData.callbacksOnTreasureRetrieved )
		{
			Assert( func != callbackFunc, "Already added " + string( callbackFunc ) + " to treasureExtractionData" )
		}
	#endif

	treasureExtractionData.callbacksOnTreasureRetrieved.append( callbackFunc )
}
#endif //SERVER




/*
=================================================================================================================================================
=================================================================================================================================================
=================================================================================================================================================

######## ##     ## ######## ########     ###     ######  ########       ########  ##     ## ######## ########  #######  ##    ##
##        ##   ##     ##    ##     ##   ## ##   ##    ##    ##          ##     ## ##     ##    ##       ##    ##     ## ###   ##
##         ## ##      ##    ##     ##  ##   ##  ##          ##          ##     ## ##     ##    ##       ##    ##     ## ####  ##
######      ###       ##    ########  ##     ## ##          ##          ########  ##     ##    ##       ##    ##     ## ## ## ##
##         ## ##      ##    ##   ##   ######### ##          ##          ##     ## ##     ##    ##       ##    ##     ## ##  ####
##        ##   ##     ##    ##    ##  ##     ## ##    ##    ##          ##     ## ##     ##    ##       ##    ##     ## ##   ###
######## ##     ##    ##    ##     ## ##     ##  ######     ##          ########   #######     ##       ##     #######  ##    ##

=================================================================================================================================================
=================================================================================================================================================
=================================================================================================================================================
*/

#if SERVER
entity function CreateTreasureExtractionUsePoint( vector origin, vector angles )
{
	entity panel = CreatePropDynamic_NoDispatchSpawn( GetObjectiveAsset_Model( "TREASUREEXTRACT_MODEL_USABLE_BUTTON" ), origin, angles, SOLID_VPHYSICS )
	panel.SetOrigin( origin )
	panel.SetAngles( angles)
	panel.SetScriptName( TREASURE_BUTTON_MODEL_SCRIPTNAME )
	DispatchSpawn( panel )

	return panel
}
#endif //SERVER


#if CLIENT
void function Client_OnTreasureBoxCreated( entity treasureBox )
{
	if ( treasureBox.GetScriptName() != TREASURE_BOX_SCRIPTNAME )
		return

	AddCallback_OnUseEntity_ClientServer( treasureBox, OnUseTreasureBox )
}
#endif //CLIENT

#if CLIENT
void function OnUseTreasureBox( entity vehicle, entity player, int pickupFlags )
{
	//TODO: This should really trigger a generic callback that does this instead of being hardcoded here
	//Minimap_SetDeathFieldRadius( 60000 )
	Minimap_DeathFieldDisableDraw()
}
#endif //CLIENT


//SHARED
void function OnTreasureUsableButtonSpawn( entity panel )
{
	if ( panel.GetScriptName() != TREASURE_BUTTON_MODEL_SCRIPTNAME )
		return

#if SERVER
	//panel.AllowMantle()
	//panel.SetForceVisibleInPhaseShift( true )
	panel.SetUsable()
	panel.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER | USABLE_BY_PILOTS | USABLE_BY_ENEMIES )
	panel.AddUsableValue( USABLE_CAN_USE_OVERRIDE ) //player-as-shadow zombie can use this too
	panel.SetUsablePriority( USABLE_PRIORITY_HIGH )
	panel.SetUsePrompts( "#FREELANCE_TREASURE_EXTRACT_USESTRING", "#FREELANCE_TREASURE_EXTRACT_USESTRING" )
	panel.MakeInvisible()
	//panel.NotSolid()
	panel.kv.rendermode = 3
	panel.kv.renderamt = 1
#elseif CLIENT
	AddEntityCallback_GetUseEntOverrideText( panel, ExtendedUseTextOverride )
	thread ShowGhostedModelWhenClose( panel )
#endif

	AddCallback_OnUseEntity_ClientServer( panel, OnTreasureButtonUse )
}
//END SHARED

#if CLIENT
void function ShowGhostedModelWhenClose( entity panel )
{
	float distToShow = 300
	float distToShowSq = distToShow * distToShow

	////////////////////////////////////////////////////
	// Show a client ghosted model whan a player gets close
	////////////////////////////////////////////////////
	vector origin = panel.GetOrigin()
	vector angles = panel.GetAngles()
	entity ghostedDrillModel = CreateClientSidePropDynamic( origin, angles, GetObjectiveAsset_Model( "TREASUREEXTRACT_MODEL_DRILL_BASE" ) )
	entity ghostedDrillBox = CreateClientSidePropDynamic( origin, angles, GetObjectiveAsset_Model( "TREASUREEXTRACT_MODEL_TREASURE_CASE" ) )
	ghostedDrillBox.SetParent( ghostedDrillModel, "BOX_POINT", false, 0.0 )
	array<entity> ghostedDrillParts
	ghostedDrillParts.append( ghostedDrillModel )
	ghostedDrillParts.append( ghostedDrillBox )
	foreach( model in ghostedDrillParts )
	{
		model.EnableRenderAlways()
		model.kv.rendermode = 3
		model.kv.renderamt = 0
		model.kv.fadedist = distToShow
		DeployableModelHighlight( model )
	}

	//panel.EndSignal( "TreasureButtonReprogram_Success" )
	ghostedDrillModel.EndSignal( "OnDestroy" )
	panel.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( ghostedDrillParts )
		{
			foreach( model in ghostedDrillParts )
			{
				if ( IsValid( model ) )
				{
					model.ClearParent()
					model.Destroy()
				}
			}
		}
	)

	while ( IsValid( panel ) )
	{
		wait 0.25
		entity player = GetLocalClientPlayer()
		if ( !IsValid( player ) )
			continue

		if ( DistanceSqr( player.GetOrigin(), origin ) > distToShowSq )
		{
			foreach( model in ghostedDrillParts )
			{
				model.kv.renderamt = 0
			}
		}
		else
		{
			foreach( model in ghostedDrillParts )
			{
				model.kv.renderamt = 1
			}
		}

	}

}
#endif //CLIENT

//SHARED
void function OnTreasureButtonUse( entity panel, entity player, int useInputFlags )
{
	if ( IsBitFlagSet( useInputFlags, USE_INPUT_LONG ) )
	{
		thread TreasureButtonUseThink( panel, player )
	}
}
//END SHARED

//SHARED
void function TreasureButtonUseThink( entity ent, entity playerUser )
{

	ExtendedUseSettings settings
	#if CLIENT
		settings.loopSound = "SQ_Item_Use_Loop"
		settings.successSound = "SQ_Item_Use_Complete"
		settings.displayRui = $"ui/extended_use_hint.rpak"
		settings.displayRuiFunc = DefaultExtendedUseRui
		settings.icon = $""
		settings.hint = "#FREELANCE_DEPLOYING_DRILL"
	#elseif SERVER
		settings.exclusiveUse = true
		settings.holsterWeapon = true
		settings.movementDisable = true
	#endif

	settings.successFunc = OnTreasureButtonUseSuccess
	settings.duration = TREASURE_EXTRACT_USE_TIME
	if ( GetPlayerArray().len() == 1 )
		settings.duration = TREASURE_EXTRACT_USE_TIME_SOLO
	settings.requireMatchingUseEnt = false
	settings.useInputFlag = IN_USE_LONG
	ent.EndSignal( "OnDestroy" )

	waitthread ExtendedUse( ent, playerUser, settings )

}
//END SHARED

//SHARED
void function OnTreasureButtonUseSuccess( entity panel, entity player, ExtendedUseSettings settings )
{
	#if SERVER
		panel.Signal( "TreasureButtonReprogram_Success" )
		panel.Destroy()
	#endif //SERVER
}
//END SHARED




#if SERVER
MiniHarvesterData function MiniHarvesterCreate( vector origin, vector angles )
{
	MiniHarvesterData miniHarvesterData

	// HARVESTER_COLOR_FULL			= <126,188,236>
	// HARVESTER_COLOR_MED			= <242,172,50>
	// HARVESTER_COLOR_LOW			= <255,74,44>

	miniHarvesterData.mainModel = CreatePropDynamic( GetObjectiveAsset_Model( "TREASUREEXTRACT_MODEL_DRILL_BASE" ), origin, angles, SOLID_VPHYSICS )
	miniHarvesterData.mainModel.DisableHibernation()
	miniHarvesterData.fxControlPointEnt = CreateEntity( "info_placement_helper" )
	SetTargetName( miniHarvesterData.fxControlPointEnt, UniqueString( "treasure_extraction_fx_colors" ) )
	DispatchSpawn( miniHarvesterData.fxControlPointEnt )
	EmitSoundOnEntity( miniHarvesterData.mainModel, "SQ_Extractor_Deploy" )
	thread CreateAirShake( origin, 2, 20, 0.5, 1024 )

	miniHarvesterData.extractionSounds.append( "SQ_Extractor_Activate" )
	miniHarvesterData.extractionSounds.append( "SQ_Extractor_Loop" )

	miniHarvesterData.origin = origin
	miniHarvesterData.angles = angles

	thread MiniHarvesterThink( miniHarvesterData )

	return miniHarvesterData
}
#endif //SERVER

#if SERVER
void function MiniHarvesterFinishExtraction( MiniHarvesterData miniHarvesterData )
{
	miniHarvesterData.mainModel.Signal( "MiniHarvesterFinishExtraction" )
}
#endif //SERVER

#if SERVER
void function MiniHarvesterThink( MiniHarvesterData miniHarvesterData )
{
	vector origin = miniHarvesterData.origin
	vector angles = miniHarvesterData.angles

	StartParticleEffectInWorld( GetParticleSystemIndex( GetObjectiveAsset_FX( "HARVESTER_FX_PLANT" ) ), origin, angles )

	wait MINI_HARVESTER_DEPLOY_TIME

	StartParticleEffectInWorld( GetParticleSystemIndex( GetObjectiveAsset_FX( "HARVESTER_FX_PLANT" ) ), origin, angles )

	thread CreateAirShake( origin, 2, 50, 1 )
	foreach( soundAlias in miniHarvesterData.extractionSounds )
		EmitSoundOnEntity( miniHarvesterData.mainModel, soundAlias )

	miniHarvesterData.fxControlPointEnt.SetOrigin( <100,100,123> )
	miniHarvesterData.fxControlPointEnt.DisableHibernation()

	entity extractionFxBeam
	extractionFxBeam = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( GetObjectiveAsset_FX( "HARVESTER_FX_EXTRACTION_BEAM" ) ), origin, <0,0,0> )
	extractionFxBeam.SetStopType( "playEndcap" )
	extractionFxBeam.DisableHibernation()
	miniHarvesterData.extractionFx.append( extractionFxBeam )


	miniHarvesterData.mainModel.EndSignal( "OnDestroy" )
	miniHarvesterData.mainModel.EndSignal( "MiniHarvesterFinishExtraction" )

	vector harvesterOrg = miniHarvesterData.origin

	OnThreadEnd(
		function() : ( miniHarvesterData )
		{
			foreach( soundAlias in miniHarvesterData.extractionSounds )
				StopSoundOnEntity( miniHarvesterData.mainModel, soundAlias )

			foreach( fx in miniHarvesterData.extractionFx )
			{
				if ( IsValid( fx ) )
				{
					fx.ClearParent()
					EffectStop( fx )
				}
			}
			EmitSoundAtPosition( TEAM_ANY, miniHarvesterData.origin, "SQ_Extractor_Complete", miniHarvesterData.mainModel )
			EmitSoundToTeamPlayers( "SQ_Extractor_Complete_UI", TEAM_ANY )
			thread CreateAirShake( miniHarvesterData.origin, 2, 50, 1, 2048 )
			StartParticleEffectInWorld( GetParticleSystemIndex( GetObjectiveAsset_FX( "TREASUREEXTRACT_FX_EXTRACTION_COMPLETE" ) ), miniHarvesterData.origin, miniHarvesterData.angles )
		}
	)

	while( true )
	{
		CreateAirShake( harvesterOrg, 2, 2, 0.5, 256 )
		wait 0.25
	}
}
#endif //SERVER


#if SERVER
void function MiniHarvesterDestroy( MiniHarvesterData miniHarvester )
{
	vector origin = miniHarvester.origin
	if ( IsValid( miniHarvester.mainModel ) )
	{
		EmitSoundAtPosition( TEAM_ANY, origin, "Lifeline_Drone_Dissolve", miniHarvester.mainModel )
		miniHarvester.mainModel.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 500 )
	}
	foreach( fx in miniHarvester.extractionFx )
	{
		if ( IsValid( fx ) )
			fx.Destroy()
	}
	if ( IsValid( miniHarvester.fxControlPointEnt ) )
		miniHarvester.fxControlPointEnt.Destroy()
}
#endif //SERVER
 