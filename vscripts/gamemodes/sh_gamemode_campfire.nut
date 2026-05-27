                         

// okirkham: this file is slightly weird because the glow zones LTM also inits this mode as a mechanic
// because of this, i've had to add a Campfire_IsEnabled toggle for this case that returns whether the mode is active
// we can't just use GameModeVariant_IsActive here since for the glow zone LTM, the campfire ltm won't be active!

global function Campfire_Init

#if SERVER
global function Campfire_IsEnabled
global function Campfire_ToggleAOE
global function Campfire_PlaceCampfire
global function Campfire_IsPlayerInCampfire
global function BeginAOEHeal
#endif


const asset CAMPFIRE_RADIUS_FX = $"P_campfire_radius"
const asset CAMPFIRE_HOLO_FX = $"P_campfire_holo"
const asset FX_HEAL_HEALED3P = $"P_heal_3p_loop"
global const string CAMPFIRE_TARGET_NAME = "prop_campfire"

const string CAMPFIRE_LOOP_SOUND_1P = "CampFire_AOE_Bubble_1P"
const string CAMPFIRE_LOOP_SOUND_3P = "CampFire_AOE_Bubble_3P"

const string CAMPFIRE_HEAL_START_1P = "CampFire_Healing_Start_1P"
const string CAMPFIRE_HEAL_LOOP_1P = "CampFire_Healing_Loop_1P"
const string CAMPFIRE_HEAL_END_1P = "CampFire_Healing_End_1P"

const string CAMPFIRE_HEAL_START_3P = "CampFire_Healing_Start_3P"
const string CAMPFIRE_HEAL_LOOP_3P = "CampFire_Healing_Loop_3P"
const string CAMPFIRE_HEAL_END_3P = "CampFire_Healing_End_3P"

const asset CAMPFIRE_MODEL = $"mdl/Robots/mobile_hardpoint/mobile_hardpoint_static.rmdl"
const asset CAMPFIRE_ICON = $"rui/hud/gametype_icons/survival/campfire"
const asset CAMPFIRE_ICON_SMALL = $"rui/hud/gametype_icons/survival/crafting_small_alternate"

const float CAMPFIRE_RADIUS = 512.0
const float USE_TIME_INFINITE = -1.0

const string CAMPFIRE_REGEN_SOURCE = "campfire"

struct CampfireData
{
	float radius = CAMPFIRE_RADIUS
}

struct {
	bool enabled

	array<entity>					campfireList

	#if SERVER
		table<entity, CampfireData> 	campfireToData

		table<entity, int> 				playerToDroneStatusEffectTable
		table<entity, int>				playerToCampfireStatusEffectTable
		table<entity, entity>			beaconToFXTable
		table<entity, entity>			beaconToTriggerTable

		table<entity, bool>				isPlayerInCampfire
	#endif

	#if CLIENT
		var								localRui
		float							lastDamageTime
		bool							isInCampfire = false
	#endif
} file




///// Initialization /////
void function Campfire_Init()
{
	file.enabled = true

	PrecacheParticleSystem( CAMPFIRE_RADIUS_FX )
	PrecacheParticleSystem( CAMPFIRE_HOLO_FX )
	PrecacheParticleSystem( FX_HEAL_HEALED3P )

	#if SERVER
		AddCallback_EntitiesDidLoad( Campfire_TryManuallySpawnCampfires )
		AddSpawnCallback( "prop_script", OnRespawnChamberSpawned )
		AddSpawnCallback( "prop_script", OnCampfireSpawned )

		AddCallback_OnPlayerKilled( Campfire_OnPlayerKilled )
		RegisterSignal( "Campfire_PlayerLeftTrigger" )
		RegisterSignal( "Campfire_StopHealing" )

		AddCallback_OnHealRegenMPStateChanged( Campfire_OnHealthRegenStateChanged )
		AddDamageCallback( "player", Campfire_OnPlayerDamaged )
	#endif

	#if CLIENT
		AddCreateCallback( "prop_script", OnCampfireCreated )
		StatusEffect_RegisterEnabledCallback( eStatusEffect.in_campfire_radius, Campfire_InRadius_Enabled )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.in_campfire_radius, Campfire_InRadius_Disabled )
		AddLocalPlayerTookDamageCallback( OnPlayerDamaged )

		AddCallback_LocalClientPlayerSpawned( Campfire_OnLocalClientPlayerSpawned )
		AddCallback_GameStateEnter( eGameState.Playing, Campfire_OnGameStatePlaying )

		if ( GetCurrentPlaylistVarBool( "campfire_should_display_on_minimap", true ) )
		{
			RegisterMinimapPackages()
			SetMapFeatureItem( 1000, "#CAMPFIRE_NAME", "#CAMPFIRE_DESC", CAMPFIRE_ICON )
		}

		RegisterSignal( "Campfire_InsideRadius" )
		RegisterSignal( "Campfire_OutsideRadius" )
	#endif
}

bool function Campfire_IsEnabled()
{
	return file.enabled
}

#if SERVER
void function Campfire_TryManuallySpawnCampfires()
{
                           
                                                                         
   
                                             
         
   
       

	if ( !GetCurrentPlaylistVarBool( "campfire_should_manually_spawn", false ) )
		return

	switch ( GetMapName() )
	{
		case "mp_rr_canyonlands_mu2":
			//todo (McCord): Set coordinates here
			//The Cage
			Campfire_PlaceCampfire( <15440, -1414, 4572>, 2500 )
			//Swamps
			Campfire_PlaceCampfire( <35610, -329, 2824>, 2800 )
			//Repulsor
			Campfire_PlaceCampfire( <27000, -15183, 4664>, 2500 )
			//Water Treatment
			Campfire_PlaceCampfire( <8823, -20229, 1990>, 2200 )
			//Caves
			Campfire_PlaceCampfire( <4128, -6132, 2951>, 2750 )
			//Water Treatment Proper *****
			Campfire_PlaceCampfire( <8136, -29921, 3008>, 2500 )
			//Skull Town Rig *****
			Campfire_PlaceCampfire( <-5756, -14401, 3200>, 2600 )
			//Octane TT ******
			Campfire_PlaceCampfire( <-20742, -12166, 2545>, 2450 )
			//Airbase
			Campfire_PlaceCampfire( <-25026, -4208, 2512>, 2500 )
			//Containment
			Campfire_PlaceCampfire( <-5337, 17490, 2688>, 2600 )
			//Slum Lakes
			Campfire_PlaceCampfire( <-22681, 23306, 2002>, 2400 )
			//Runoff
			Campfire_PlaceCampfire( <-24037, 11519, 3028>, 2500 )
			//Hill Town
			Campfire_PlaceCampfire( <-17505, 3191, 2800>, 2800 )
			//Cascades
			Campfire_PlaceCampfire( <4734, 9794, 4251>, 2200 )
			//Capacitor *******
			Campfire_PlaceCampfire( <23078, 11124, 2488>, 2500 )
			//Two Spines Forest
			Campfire_PlaceCampfire( <11276, 18110, 5033>, 2800 )
			//Artillery
			Campfire_PlaceCampfire( <6423, 28706, 4882>, 2350 )
			//Relay ******
			Campfire_PlaceCampfire( <23882, 23169, 4170>, 2550 )
			//Wetlands Rig *****
			Campfire_PlaceCampfire( <36181, 21909, 4160>, 2650 )
			break

		case "mp_rr_olympus":
			break
	}

	int idx = 0
	while ( true )
	{
		string s = GetCurrentPlaylistVarString( "campfire_create_" + (idx++), "" )
		if ( s == "" )
			break

		array<string> tokens = split( s, WHITESPACE_CHARACTERS )
		if ( tokens.len() < 4 )
			continue

		float x = float( tokens[0] )
		float y = float( tokens[1] )
		float z = float( tokens[2] )
		float r = float( tokens[3] )


		//DebugDrawCircle( <x, y, z>, <0,0,0>, r, COLOR_RED, true, 300.0 )
		Campfire_PlaceCampfire( <x, y, z>, r, < 0, 0, 0> )
	}

	entity randomCampfire = file.campfireList.getrandom()
	if (IsValid( randomCampfire ))
	{
		printf( "CAMPFIRE MODE: Forcing final circle to close at " + randomCampfire.GetOrigin() )
		SURVIVAL_AddOverrideCircleLocation( randomCampfire.GetOrigin(), 0, true )
	}
}

                          
                                                 
 
                                       

                                                             
                                              
  
                                                                    
  
 
      

void function Campfire_PlaceCampfire( vector coordinates, float radius = CAMPFIRE_RADIUS, vector angles = <0,0,0>, string overrideName = "" )
{
	entity campfire = CreatePropScript_NoDispatchSpawn( CAMPFIRE_MODEL, coordinates , angles, 6 )
	campfire.SetSkin( 1 )
	SetTargetName( campfire, CAMPFIRE_TARGET_NAME )
	campfire.SetCanBeMeleed( false )

                           
                                                                         
   
                                        
                  
   
       

	float radToUse = GetCurrentPlaylistVarFloat( "campfire_override_radius_" + overrideName, radius )

	CampfireData data
	data.radius = radToUse
	file.campfireToData[campfire] <- data

	DispatchSpawn( campfire )
	campfire.SetFadeDistance( 15000 )
}


bool function Campfire_IsPlayerInCampfire( entity player )
{
	if ( player in file.isPlayerInCampfire )
	{
		printf( "CAMPFIRE: Returning " + file.isPlayerInCampfire[player] + " for player " + player )
		return file.isPlayerInCampfire[player]
	}

	printf( "CAMPFIRE: Returning " + false + " for player " + player )
	return false
}


void function Campfire_ToggleAOE( entity ent, bool isActive )
{
	//handle FX
	if ( ent in file.beaconToFXTable )
	{
		if ( !isActive )
		{
			file.beaconToFXTable[ent].Destroy()
			delete file.beaconToFXTable[ent]
		}
	} else
	{
		if ( isActive )
		{
			int attachId = ent.LookupAttachment( "FX_EMITTER" )
			vector attachPos = ent.GetAttachmentOrigin( attachId )

			CampfireData data
			if ( ent in file.campfireToData )
				data = file.campfireToData[ent]

			entity radiusFx = StartParticleEffectOnEntityWithPos_ReturnEntity( ent, GetParticleSystemIndex( CAMPFIRE_RADIUS_FX ), FX_PATTACH_POINT_FOLLOW_NOROTATE, attachId, <0, 0, 0>, <-90, 0, 0> )
			EffectSetControlPointVector( radiusFx, 1, <data.radius, 0, 0> )
			file.beaconToFXTable[ent] <- radiusFx
		}
	}

	//handle trigger
	if ( ent in file.beaconToTriggerTable )
	{
		entity trigger = file.beaconToTriggerTable[ent]
		if ( trigger.IsEnabled() && !isActive )
			trigger.Disable()

		if ( !trigger.IsEnabled() && isActive )
			trigger.Enable()
	}
}


void function OnRespawnChamberSpawned( entity ent )
{
	if ( !GetCurrentPlaylistVarBool( "campfire_should_replace_respawn_beacons", false ) )
		return

	if ( ent.GetTargetName() != RESPAWN_CHAMBER_TARGETNAME )
		return

	vector origin = ent.GetOrigin()
	vector angles = ent.GetAngles()
	asset model = ent.GetModelName()

	ent.Destroy()

	//spawn campfire in place of respawn chamber
	entity campfire = CreatePropScript_NoDispatchSpawn( model, origin , angles, 6 )
	campfire.SetSkin( 1 )
	SetTargetName( campfire, CAMPFIRE_TARGET_NAME )
	campfire.SetCanBeMeleed( false )
	campfire.SetTakeDamageType( DAMAGE_NO )

	CampfireData data
	data.radius = CAMPFIRE_RADIUS
	file.campfireToData[campfire] <- data

	DispatchSpawn( campfire )
	campfire.SetFadeDistance( 15000 )
}


void function OnCampfireSpawned( entity ent )
{
	if ( ent.GetTargetName() != CAMPFIRE_TARGET_NAME )
		return

	int attachId = ent.LookupAttachment( "FX_EMITTER" )
	vector attachPos = ent.GetAttachmentOrigin( attachId )

	CampfireData data
	if ( ent in file.campfireToData )
		data = file.campfireToData[ent]

	ent.SetShieldHealthMax( data.radius )
	ent.SetShieldHealth( data.radius )

	//spawn cylinder trigger around campfire
	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetCylinderRadius( data.radius )
	trigger.SetAboveHeight( data.radius )
	trigger.SetBelowHeight( data.radius )
	trigger.SetOrigin( attachPos )
	trigger.SetAngles( <0, 0, 0> )
	trigger.kv.triggerFilterPlayer = "all"
	DispatchSpawn( trigger )

	trigger.SetEnterCallback( Campfire_OnTriggerEnter )
	trigger.SetLeaveCallback( Campfire_OnTriggerExit )
	file.beaconToTriggerTable[ent] <- trigger

	entity radiusFx = StartParticleEffectOnEntityWithPos_ReturnEntity( ent, GetParticleSystemIndex( CAMPFIRE_RADIUS_FX ), FX_PATTACH_POINT_FOLLOW_NOROTATE, attachId, <0, 0, 0>, <-90, 0, 0> )
	EffectSetControlPointVector( radiusFx, 1, <data.radius, 0, 0> )
	file.beaconToFXTable[ent] <- radiusFx

                           
                                                                          
       
		{
			entity holoFx = StartParticleEffectOnEntityWithPos_ReturnEntity( ent, GetParticleSystemIndex( CAMPFIRE_HOLO_FX ), FX_PATTACH_POINT_FOLLOW_NOROTATE, attachId, <0, 0, 0>, <-90, 0, 0> )
		}
	//endif !HAS_GAMEMODE_WAR_GAMES

	/*entity ambGen = CreateEntity( "ambient_generic" )
	ambGen.SetOrigin( holoFx.GetOrigin() )
	ambGen.SetSoundName( CAMPFIRE_LOOP_SOUND_3P )
	ambGen.SetEnabled( true )
	DispatchSpawn( ambGen )*/

	//spawn minimap obj
	entity minimapObj = CreatePropScript( $"mdl/dev/empty_model.rmdl", ent.GetOrigin() )
	minimapObj.Minimap_SetCustomState( eMinimapObject_prop_script.CAMPFIRE )
	minimapObj.Minimap_SetObjectScale( 1 )
	minimapObj.SetParent( ent )
	minimapObj.Minimap_SetAlignUpright( true )
	SetTargetName( minimapObj, "campfireIcon" )
	minimapObj.Minimap_AlwaysShow( TEAM_UNASSIGNED, null )
	minimapObj.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
	minimapObj.DisableHibernation()

	// Minimap Radius Entity
	entity radiusMinimapEnt = CreateEntity( "prop_script" )
	radiusMinimapEnt.SetValueForModelKey( $"mdl/dev/empty_model.rmdl" )
	radiusMinimapEnt.kv.fadedist = -1
	radiusMinimapEnt.kv.renderamt = 255
	radiusMinimapEnt.kv.rendercolor = "255 255 255"
	radiusMinimapEnt.kv.solid = 6
	radiusMinimapEnt.SetOrigin( ent.GetOrigin() )
	radiusMinimapEnt.SetAngles( <0, 0, 0> )
	radiusMinimapEnt.NotSolid()
	radiusMinimapEnt.Hide()
	radiusMinimapEnt.DisableHibernation()
	float radius = min( 65536.0, data.radius )
	radiusMinimapEnt.Minimap_SetObjectScale( radius / SURVIVAL_MINIMAP_RING_SCALE )
	radiusMinimapEnt.Minimap_SetAlignUpright( true )
	radiusMinimapEnt.Minimap_SetZOrder( MINIMAP_Z_OBJECTIVE )
	radiusMinimapEnt.Minimap_SetClampToEdge( true )
	radiusMinimapEnt.Minimap_SetCustomState( eMinimapObject_prop_script.OBJECTIVE_AREA )
	foreach ( entity player in GetPlayerArray() )
		radiusMinimapEnt.Minimap_AlwaysShow( 0, player )
	SetTargetName( radiusMinimapEnt, "campfireZone" )
	DispatchSpawn( radiusMinimapEnt )

	file.campfireList.append( ent )
}


void function Campfire_OnTriggerEnter( entity trigger, entity ent )
{
	if ( !IsValidPlayer( ent ) )
		return

	thread Campfire_RadiusTrackingThread( trigger, ent )
}

void function Campfire_RadiusTrackingThread( entity trigger, entity ent )
{
	bool isHealing = false
	ent.EndSignal( "Campfire_PlayerLeftTrigger" )
	ent.EndSignal( "OnDeath" )
	ent.EndSignal( "OnDestroy" )

	OnThreadEnd( function() : ( ent, isHealing ) {
		EndAOEHeal( ent )
	} )

	CampfireData data
	foreach ( key, value in file.beaconToTriggerTable )
	{
		if ( value == trigger && key in file.campfireToData )
			data = file.campfireToData[key]
	}

	while ( true )
	{
		//check radius for sphere
		float playerDistance = Distance( trigger.GetOrigin(), ent.GetOrigin() )
		if ( playerDistance <= data.radius && PlayerMatchState_GetFor( ent ) == ePlayerMatchState.NORMAL )
		{
			file.isPlayerInCampfire[ent] <- true

			if ( !isHealing &&  BleedoutState_GetPlayerBleedoutState( ent ) == BS_NOT_BLEEDING_OUT )
			{
				BeginAOEHeal( ent )
				isHealing = true
			}
		}

		if ( playerDistance > data.radius )
		{
			file.isPlayerInCampfire[ent] <- false
			delete file.isPlayerInCampfire[ent]

			if ( isHealing )
			{
				EndAOEHeal( ent )
				isHealing = false
			}
		}

		WaitFrame()
	}

	unreachable
}

void function Campfire_OnTriggerExit( entity trigger, entity ent )
{
	if ( !IsValidPlayer( ent ) )
		return

	ent.Signal( "Campfire_PlayerLeftTrigger" )

	file.isPlayerInCampfire[ent] <- false
	delete file.isPlayerInCampfire[ent]
	EndAOEHeal( ent )
}

void function Campfire_OnPlayerKilled( entity victim, entity attacker, var attackerDamageInfo )
{
	victim.Signal( "Campfire_PlayerLeftTrigger" )
}

void function BeginAOEHeal( entity ent )
{
	int regenSource = eRegenSource.CAMPFIRE
	float regenHealthPerSec = GetPlaylistVar_CampfireHealthPerSec()
	float regenShieldPerSec = GetPlaylistVar_CampfireHealthPerSec()
	float regenStartDelay = GetPlaylistVar_CampfireRegenDelay()
	thread HealthRegen_Thread( ent, regenSource, regenHealthPerSec, regenShieldPerSec, regenStartDelay, false )

	if ( !( ent in file.playerToCampfireStatusEffectTable ) )
	{
		file.playerToCampfireStatusEffectTable[ent] <- StatusEffect_AddEndless( ent, eStatusEffect.in_campfire_radius, 0.15 )
	}
}

void function EndAOEHeal( entity ent )
{
	if ( IsValid( ent ) )
	{
		HealthRegen_End( ent )

		if ( ent in file.playerToCampfireStatusEffectTable )
		{
			StatusEffect_Stop( ent, file.playerToCampfireStatusEffectTable[ent] )
			delete file.playerToCampfireStatusEffectTable[ent]
		}

		if ( HealthRegen_IsOctane( ent ) )
		{
			HealthRegen_StartOctanePassive( ent )
		}
	}
}

//state management for handling sounds and effects
void function Campfire_OnHealthRegenStateChanged( entity player, bool oldHealState, bool newHealState, int regenSource )
{
	if ( regenSource != eRegenSource.CAMPFIRE )
		return

	entity BodyFX3p = null

	//healing has started, start loop
	if ( !oldHealState && newHealState )
	{
		//add screen effect
		file.playerToDroneStatusEffectTable[player] <- StatusEffect_AddEndless( player, eStatusEffect.drone_healing, 0.15 )
		//1P sound start and loop
		StopSoundOnEntity( player, CAMPFIRE_HEAL_END_1P )
		EmitSoundOnEntityOnlyToPlayer( player, player, CAMPFIRE_HEAL_START_1P )
		EmitSoundOnEntityOnlyToPlayer( player, player, CAMPFIRE_HEAL_LOOP_1P )
		//3P sound start and loop
		StopSoundOnEntity( player, CAMPFIRE_HEAL_END_3P )
		EmitSoundOnEntityExceptToPlayer( player, player, CAMPFIRE_HEAL_START_3P )
		EmitSoundOnEntityExceptToPlayer( player, player, CAMPFIRE_HEAL_LOOP_3P )
		thread PlayHealFX3P( player )

	}

	//healing has stopped, end loop
	if ( oldHealState && !newHealState )
	{
		if( !IsValid( player ) )
			return

		player.Signal( "Campfire_StopHealing" )

		//remove screen effect
		if ( player in file.playerToDroneStatusEffectTable)
		{
			StatusEffect_Stop( player, file.playerToDroneStatusEffectTable[player] )
			delete file.playerToDroneStatusEffectTable[player]
		}

		//stop sounds 1p and fire end sound
		StopSoundOnEntity( player, CAMPFIRE_HEAL_START_1P )
		StopSoundOnEntity( player, CAMPFIRE_HEAL_LOOP_1P  )
		EmitSoundOnEntityOnlyToPlayer( player, player, CAMPFIRE_HEAL_END_1P )

		//stop sounds on 3p and fire end sound
		StopSoundOnEntity( player, CAMPFIRE_HEAL_START_3P )
		StopSoundOnEntity( player, CAMPFIRE_HEAL_LOOP_3P  )
		EmitSoundOnEntityExceptToPlayer( player, player, CAMPFIRE_HEAL_END_3P )
	}
}

void function PlayHealFX3P( entity player )
{
	player.EndSignal( "Campfire_PlayerLeftTrigger" )
	player.EndSignal( "HealthRegen_StartThread" )
	player.EndSignal( "Campfire_StopHealing" )

	entity BodyFX3p = null

	if ( !IsValid( BodyFX3p ) )
	{
		BodyFX3p = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( FX_HEAL_HEALED3P ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "CHESTFOCUS" ) )
		BodyFX3p.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_EVERYONE | ENTITY_VISIBLE_EXCLUDE_PARENT_PLAYER)
	}

	OnThreadEnd(
		function() : ( BodyFX3p )
		{
			if ( IsValid( BodyFX3p ) )
				EffectStop( BodyFX3p )
		}
	)

	WaitForever()
}

void function Campfire_OnPlayerDamaged( entity victim, var damageInfo )
{
	//
}
#endif






#if CLIENT
void function OnCampfireCreated( entity target )
{
	if ( target.GetTargetName() != CAMPFIRE_TARGET_NAME )
		return

	file.campfireList.append( target )
}

void function CreateCampfireWorldIcon( entity campfire )
{
	entity localViewPlayer = GetLocalViewPlayer()
	vector pos             = campfire.GetOrigin() + (campfire.GetUpVector() * 100)
	var rui                = CreateCockpitRui( $"ui/survey_beacon_marker_icon.rpak", RuiCalculateDistanceSortKey( localViewPlayer.EyePosition(), pos ) )
	RuiSetImage( rui, "beaconImage", CAMPFIRE_ICON )
	RuiSetGameTime( rui, "startTime", Time() )
	RuiSetFloat3( rui, "pos", pos )
	RuiSetFloat( rui, "minAlphaDist", 1000 )
	RuiSetFloat( rui, "maxAlphaDist", 3000 )
	RuiKeepSortKeyUpdated( rui, true, "pos" )
}

void function RegisterMinimapPackages()
{
	RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.CAMPFIRE, MINIMAP_OBJECT_RUI, MinimapPackage_Campfire, FULLMAP_OBJECT_RUI, MinimapPackage_Campfire )
}

void function MinimapPackage_Campfire( entity ent, var rui )
{
	RuiSetImage( rui, "defaultIcon", CAMPFIRE_ICON )
	RuiSetImage( rui, "clampedDefaultIcon", $"" )
	RuiSetBool( rui, "useTeamColor", false )
}

void function Campfire_InRadius_Enabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( ent != GetLocalViewPlayer() )
		return

	entity cockpit = GetLocalViewPlayer().GetCockpit()
	if ( !IsValid( cockpit ) )
		return

	if ( !actuallyChanged )
		return

	ent.Signal( "Campfire_InsideRadius" )

	Campfire_HintEnabled()
	thread Campfire_1PSoundThread()
	file.isInCampfire = true
}

void function Campfire_InRadius_Disabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( ent != GetLocalViewPlayer() )
		return

	if ( !actuallyChanged )
		return

	ent.Signal( "Campfire_OutsideRadius" )

	Campfire_HintDisabled()
	file.isInCampfire = false
}

void function Campfire_OnLocalClientPlayerSpawned( entity player )
{
	thread Campfire_3PSoundThread()
}

void function Campfire_OnGameStatePlaying()
{
	if ( GetCurrentPlaylistName().find( "dev" ) != -1 )
	{
		Campfire_OnLocalClientPlayerSpawned( null )
	}
}

void function Campfire_HintEnabled()
{
	file.localRui = CreateCockpitPostFXRui( $"ui/campfire_hint.rpak", HUD_Z_BASE )
	RuiSetGameTime( file.localRui, "lastDamageTime", file.lastDamageTime )
	RuiTrackFloat( file.localRui, "bleedoutEndTime", GetLocalViewPlayer(), RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( "bleedoutEndTime" ) )
}

void function Campfire_HintDisabled()
{
	if ( file.localRui != null )
		RuiDestroyIfAlive( file.localRui )

	file.localRui = null
}

void function OnPlayerDamaged( float damage, vector damageOrigin, int damageType, int damageSourceId, entity attacker )
{
	file.lastDamageTime = Time()

	if ( file.localRui != null )
		RuiSetGameTime( file.localRui, "lastDamageTime", Time() )
}


void function Campfire_1PSoundThread()
{
	entity player = GetLocalViewPlayer()
	player.EndSignal( "Campfire_OutsideRadius" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	EmitSoundOnEntity( player, CAMPFIRE_LOOP_SOUND_1P )

	OnThreadEnd(
		function() : ( player )
		{
			StopSoundOnEntity( player, CAMPFIRE_LOOP_SOUND_1P )
		}
	)

	WaitForever()
}

void function Campfire_3PSoundThread()
{
	entity player = GetLocalViewPlayer()
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	entity mover = CreateClientsideScriptMover( $"mdl/dev/empty_model.rmdl", player.GetOrigin(), <0, 0, 0> )
	EmitSoundOnEntity( mover, CAMPFIRE_LOOP_SOUND_3P )

	OnThreadEnd(
		function() : ( mover )
		{
			if ( !IsValid( mover ) )
				return

			StopSoundOnEntity( mover, CAMPFIRE_LOOP_SOUND_3P )
			mover.Destroy()
		}
	)

	while ( IsValid( player ) )
	{
		//if player is inside of campfire, disable mover and skip loop
		if ( file.isInCampfire )
		{
			mover.SetOrigin( <0,0,-50000> )
			WaitFrame()
			continue
		}

		if ( file.campfireList.len() <= 0 )
		{
			WaitFrame()
			continue
		}

		//get closest campfire and radius value
		entity closestCampfire = file.campfireList[0]
		if ( !IsValid( closestCampfire ) )
		{
			WaitFrame()
			continue
		}

		foreach( campfire in file.campfireList )
		{
			if ( !IsValid( campfire ) )
			{
				WaitFrame()
				continue
			}

			if ( Distance( player.GetOrigin(), closestCampfire.GetOrigin() ) > Distance( player.GetOrigin(), campfire.GetOrigin() ) )
				closestCampfire = campfire
		}

		if ( !IsValid( closestCampfire ) )
		{
			WaitFrame()
			continue
		}

		int radius = closestCampfire.GetShieldHealth()
		vector fwdToPlayer   = Normalize( player.GetOrigin() - closestCampfire.GetOrigin() )
		vector campfireEdgePos = closestCampfire.GetOrigin() + (fwdToPlayer * radius)

		if ( PositionIsInMapBounds( campfireEdgePos ) )
			mover.SetOrigin( campfireEdgePos )

		WaitFrame()
	}
}
#endif

float function GetPlaylistVar_CampfireHealthPerSec()
{
	return GetCurrentPlaylistVarFloat( "campfire_health_per_sec", 7.0 )
}

float function GetPlaylistVar_CampfireRegenDelay()
{
	return GetCurrentPlaylistVarFloat( "campfire_health_regen_delay", 0.5 )
}


       