global function Caustic_TT_Init
global function Caustic_TT_RegisterNetworking
global function IsCausticTTEnabled
global function GetCausticTTCanisterFrameForLoot
global function AreCausticTTCanistersClosed
global function CausticTT_SetGasFunctionInvertedValue

#if SERVER
global function MaybeActivateCausticTTDefense_Thread
global function GetCausticTTAssetsToPrecache
#endif // SERVER

#if CLIENT
global function Caustic_TT_ServerCallback_SetCanistersOpen
global function Caustic_TT_ServerCallback_SetCanistersClosed
global function Caustic_TT_ServerCallback_SetSwitchesEnabled
global function Caustic_TT_ServerCallback_SetSwitchesDisabled
global function Caustic_TT_ServerCallback_ToxicWaterEmitterOn
global function Caustic_TT_ServerCallback_ToxicWaterEmitterOff

const string CAUSTIC_TT_TOXIC_WATER_AUDIO_EMIT = "caustic_tt_floor_ambient_generic"
const string CAUSTIC_TT_TURBINE_SCRIPTNAME = "caustic_tt_turbine"
#endif // CLIENT

const string CAUSTIC_TT_SWITCH_SCRIPTNAME = "caustic_tt_switch"
const string CAUSTIC_TT_CANISTER_FRAME_SCRIPTNAME = "caustic_tt_canister_frame"

const float CANISTER_TIMER_START = 15.0
const float CANISTER_TIMER_END = 10.0

const int CANISTER_DISTANCE_FRAME_TO_LOOT_SQR = 4900

#if SERVER
const string CAUSTIC_TT_CANISTER_MOVER_SCRIPTNAME = "caustic_tt_canister_mover"
const string CAUSTIC_TT_TOXIC_WATER_MOVER_SCRIPTNAME = "caustic_tt_toxic_water_mover"
const string CAUSTIC_TT_GAS_FOUNTAIN_MOVER_SCRIPTNAME = "caustic_tt_fountain_mover"
const string CAUSTIC_TT_WATER_SMOKE = "caustic_tt_steam_fx_helper"
const string CAUSTIC_TT_GAS_FOUNTAIN = "caustic_tt_fountain_fx_helper"
const string CAUSTIC_TT_SMOKE_PLUME = "caustic_tt_smoke_plume_fx_helper"
const string CAUSTIC_TT_LOOT_SCRIPTNAME = "caustic_tt_loot_helper"
const string CAUSTIC_TT_WINDOW_HIGHLIGHTS_SCRIPTNAME = "caustic_tt_window_highlights"
const string CAUSTIC_TT_SPEAKER_SCRIPTNAME = "caustic_tt_audio_speaker"
const string CAUSITC_TT_TRIGGER_SCRIPTNAME = "caustic_tt_canister_trigger"

const string CAUSTIC_TT_GAS_ALARM_SFX = "Canyonlands_Mu3_CausticTT_GasAlarm"
const string CAUSTIC_TT_GAS_TIMER_SFX = "Canyonlands_Mu3_CausticTT_GasTimer"
const string CAUSTIC_TT_CANISTER_LOWER_SFX = "Canyonlands_Mu3_CausticTT_Trap_Lower"
const string CAUSTIC_TT_CANISTER_RISE_SFX = "Canyonlands_Mu3_CausticTT_Trap_Rise"
const string CAUSTIC_TT_GAS_REFILL_SFX = "Canyonlands_Mu3_CausticTT_GasRefill"
const string CAUSTIC_TT_LOBA_ALARM_SFX = "Canyonlands_Mu3_CausticTT_LobaUltAlarm"
const string CAUSTIC_TT_SWITCH_DISABLED_SFX = "menu_deny"

const string CANISTER_TRAP_DEACTIVATED_VO = "diag_mp_caustic_tt_gasDeactivate_3p"
const string CANISTER_TRAP_WARNING_VO = "diag_mp_caustic_tt_timer10sec_3p"
const string CANISTER_TRAP_ACTIVATED_VO = "diag_mp_caustic_tt_timer00sec_3p"

                        
const string CAUSTIC_TT_GAS_ALARM_SFX_CONTROL_MODE = "Canyonlands_Mu3_CausticTT_GasAlarm_Control"
const string CAUSTIC_TT_GAS_TIMER_SFX_CONTROL_MODE = "Canyonlands_Mu3_CausticTT_GasTimer_Control"
                              

const float CAUSTIC_TT_CANISTER_MOVE_TO_DURATION_OPEN = 3.0
const float CAUSTIC_TT_CANISTER_MOVE_TO_DURATION_CLOSE = 2.0
const float CAUSTIC_TT_TOXIC_WATER_MOVE_TO_DRAIN = 10.0
const float CAUSTIC_TT_TOXIC_WATER_MOVE_TO_FILL = 5.0

const vector CAUSTIC_TT_CANISTER_MOVE_TO_OFFSET = < 0, 0, -225 >
const vector CAUSTIC_TT_TOXIC_WATER_MOVE_TO_OFFSET = < 0, 0, -50 >

const string CAUSTIC_TT_FOUNTAIN_FX = "P_caustic_tt_geyser_idle"
const string CAUSTIC_TT_WATER_SMOKE_FX = "P_caustic_tt_env_steam_slow"
const string CAUSTIC_TT_CANISTER_GLOW_FX = "P_caustic_tt_canister"

// PushAway Parameters
const float CAUSTIC_TT_PLAYERPUSHAWAYTRIGGER_RADIUS = 64
const float CAUSTIC_TT_PLAYERPUSHAWAYTRIGGER_HEIGHT = 256

const int TYPE_WEAPON = 1
const int TYPE_INCAPSHIELD = 5
const int TYPE_BACKPACK = 10
#endif // SERVER

#if SERVER
struct LootCanisterData
{
	entity 	canisterMover
	entity 	canisterBrush
	entity 	lootEnt
	entity 	lootGlowEnt
	entity 	trigger
	entity 	playerPushOutTrigger
	int		playersInCanister
	vector 	canisterMoverStartOrigin
}

struct ToxicWaterData
{
	entity toxicWater
	entity toxicWaterMover
	vector toxicWaterMoverStartOrigin
	entity toxicWaterHurtTrigger
}
#endif // SERVER

struct
{
	bool 				canistersClosed = true
	bool				switchesEnabled = true
	array < entity >	canisterFrames
	array < entity >	canisterSwitches
	array < entity >	windowHighlights
	array < string >	canisterLootRefs

	bool isGasFunctionInverted = false

	#if CLIENT
		array < entity >	toxicWaterEmitters
	#endif

	#if SERVER
		entity							gasFountainMover
		vector 							gasFountainMoverOrigin
		entity							audioSpeaker
		array < entity > 				gasFountainEnts
		array < entity >				waterSmokeEnts
		array < entity >				canisterLootEnts
		table < entity, LootCanisterData >	lootCanisterDataMap
		ToxicWaterData& 				toxicWaterData

		bool shouldToxicWaterEmitterBeOn = true
	#endif // SERVER
} file

void function Caustic_TT_Init()
{
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	#if CLIENT
		AddCreateCallback( "prop_dynamic", CausticCanisterSwitchSpawned )
	#endif

	#if SERVER
		AddCallback_OnPlayerRespawned( Caustic_TT_OnPlayerRespawned )
	#endif // SERVER
}

void function Caustic_TT_RegisterNetworking()
{
	Remote_RegisterClientFunction( "Caustic_TT_ServerCallback_SetCanistersOpen" )
	Remote_RegisterClientFunction( "Caustic_TT_ServerCallback_SetCanistersClosed" )
	Remote_RegisterClientFunction( "Caustic_TT_ServerCallback_SetSwitchesEnabled" )
	Remote_RegisterClientFunction( "Caustic_TT_ServerCallback_SetSwitchesDisabled" )
	Remote_RegisterClientFunction( "Caustic_TT_ServerCallback_ToxicWaterEmitterOn" )
	Remote_RegisterClientFunction( "Caustic_TT_ServerCallback_ToxicWaterEmitterOff" )
}


void function CausticCanisterSwitchSpawned( entity panel )
{
	if( panel.GetScriptName() != CAUSTIC_TT_SWITCH_SCRIPTNAME )
		return

	//need to reapply button settings since this may have spawned after entitiesloaded has already been called
	//in which it already processed the ones that were there
	Caustic_TT_SetButtonUsable( panel )
}

void function Caustic_TT_SetButtonUsable( entity canisterSwitch )
{
	#if SERVER
		canisterSwitch.AllowMantle()
		canisterSwitch.SetForceVisibleInPhaseShift( true )
		canisterSwitch.SetUsable()
		canisterSwitch.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER | USABLE_BY_PILOTS | USABLE_BY_ENEMIES )
		canisterSwitch.SetUsablePriority( USABLE_PRIORITY_MEDIUM )
		canisterSwitch.SetSkin( 0 )
	#endif // SERVER
	#if CLIENT
		//need a way to prevent from adding callbacks on existing canisters on client side
		//this is mostly a hack for console as this dynamic prop spawns after the entitiesloaded callback 
		//and therefore need to map the buttons properly for the UI prompts to pop up
		//similar fix to sh_crypto_tt_common for the crypto map podium 
		if( canisterSwitch.e.canUseEntityCallback != null )
			return
	#endif // CLIENT
	SetCallback_CanUseEntityCallback_Retail( canisterSwitch, CanisterSwitch_CanUse )
	AddCallback_OnUseEntity_ClientServer( canisterSwitch, CanisterSwitch_OnUse )
	#if CLIENT
		AddEntityCallback_GetUseEntOverrideText( canisterSwitch, GetCanisterSwitchUseTextOverride )
	#endif // CLIENT
}

void function EntitiesDidLoad()
{
	if ( !IsCausticTTEnabled() )
		return

	//PrecacheScriptString( "caustic_tt_loot" )

	#if SERVER
		GetCanisterLootToSpawn()

		foreach ( entity windowHighlight in GetEntArrayByScriptName( CAUSTIC_TT_WINDOW_HIGHLIGHTS_SCRIPTNAME ) )
		{
			windowHighlight.SetSkin( 0 )
			file.windowHighlights.append( windowHighlight )
		}

		file.audioSpeaker = GetEntByScriptName( CAUSTIC_TT_SPEAKER_SCRIPTNAME )
		//Had to create a dupe to make it dynamic prop without affecting it's adjusted scale in leveled, so need to hide the dupe
		file.audioSpeaker.Hide()
	#endif // SERVER

	#if CLIENT
		// Ambient Generics are placed in level & connected to ambient_generic_vertex; they act only on Client
		foreach ( entity emitter in GetEntArrayByScriptName( CAUSTIC_TT_TOXIC_WATER_AUDIO_EMIT ) )
			file.toxicWaterEmitters.append( emitter )

		// Rotate exterior turbines
		foreach ( entity turbine in GetEntArrayByScriptName( CAUSTIC_TT_TURBINE_SCRIPTNAME ) )
		{
			entity turbineRotator = CreateClientsideScriptMover( $"mdl/dev/empty_model.rmdl", turbine.GetOrigin(), turbine.GetAngles() )
			turbine.SetParent( turbineRotator )
			turbineRotator.NonPhysicsRotate( < 0, 0, 1 >, 60 )
		}
	#endif // CLIENT

	foreach ( entity canisterSwitch in GetEntArrayByScriptName( CAUSTIC_TT_SWITCH_SCRIPTNAME ) )
	{
		Caustic_TT_SetButtonUsable( canisterSwitch )
		file.canisterSwitches.append( canisterSwitch )
	}

	// Get canister frame for Loba's Black Market logic to test if lootEnt is within the mins/maxs
	foreach ( entity canisterFrame in GetEntArrayByScriptName( CAUSTIC_TT_CANISTER_FRAME_SCRIPTNAME ) )
		file.canisterFrames.append( canisterFrame )

	#if SERVER
		foreach ( entity canisterMover in GetEntArrayByScriptName( CAUSTIC_TT_CANISTER_MOVER_SCRIPTNAME ) )
		{
			LootCanisterData data

			data.canisterMover = canisterMover
			data.canisterMover.SetPusher( true )
			//data.canisterMover.SetPusherMovesNearbyVehicles( true )
			data.canisterMover.EnableNonPhysicsMoveInterpolation( false )
			data.canisterMoverStartOrigin = data.canisterMover.GetOrigin()

			data.lootGlowEnt = CreateEntity( "info_particle_system" )
			data.lootGlowEnt.SetValueForEffectNameKey( GetAssetFromString( CAUSTIC_TT_CANISTER_GLOW_FX ) )
			data.lootGlowEnt.kv.start_active = 1
			data.lootGlowEnt.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
			data.lootGlowEnt.SetOrigin( data.canisterMoverStartOrigin )
			DispatchSpawn( data.lootGlowEnt )

			foreach ( entity moverLinkEnt in data.canisterMover.GetLinkEntArray() )
			{
				string scriptName = moverLinkEnt.GetScriptName()

				if ( moverLinkEnt.GetClassName() == "func_brush" )
				{
					data.canisterBrush = moverLinkEnt
					data.canisterBrush.SetParent( data.canisterMover )
				}
				else if ( scriptName == CAUSTIC_TT_LOOT_SCRIPTNAME )
				{
					entity lootEntHelper = moverLinkEnt

					data.lootEnt = SpawnCanisterLoot( lootEntHelper )
					data.lootEnt.SetScriptName( "caustic_tt_loot" )
					data.lootEnt.AddUsableValue( USABLE_USE_DISTANCE_OVERRIDE )
					file.canisterLootEnts.append( data.lootEnt )
				}
				else if ( scriptName == CAUSITC_TT_TRIGGER_SCRIPTNAME )
				{
					data.trigger = moverLinkEnt
					data.trigger.RemoveFromAllRealms()
					data.trigger.AddToOtherEntitysRealms( data.canisterMover )
					data.trigger.SetEnterCallback( LootCanister_PlayerEnterCanister )
					data.trigger.SetLeaveCallback( LootCanister_PlayerLeaveCanister )
				}
			}

			data.canisterMover.SetParent( data.lootEnt )
			data.playersInCanister = 0

			data.trigger.SetParent( data.lootEnt )
			data.lootGlowEnt.SetParent( data.lootEnt )

			// [ JIRA: R5DEV-340882] Trigger to push players out of loot area if cage is closing
			data.playerPushOutTrigger = CreateEntity( "trigger_cylinder" )
			data.playerPushOutTrigger.RemoveFromAllRealms()
			data.playerPushOutTrigger.AddToOtherEntitysRealms( data.lootEnt )
			data.playerPushOutTrigger.SetRadius( CAUSTIC_TT_PLAYERPUSHAWAYTRIGGER_RADIUS )
			data.playerPushOutTrigger.SetAboveHeight( CAUSTIC_TT_PLAYERPUSHAWAYTRIGGER_HEIGHT / 2 )
			data.playerPushOutTrigger.SetBelowHeight( CAUSTIC_TT_PLAYERPUSHAWAYTRIGGER_HEIGHT / 2 )
			data.playerPushOutTrigger.SetOrigin( data.lootEnt.GetOrigin() )
			//data.playerPushOutTrigger.SetEnterCallback( PushOutOfTrigger( 350.0 ) )
			data.playerPushOutTrigger.kv.triggerFilterNpc = "all"
			data.playerPushOutTrigger.kv.triggerFilterPlayer = "all"
			data.playerPushOutTrigger.kv.triggerFilterNonCharacter = 0
			DispatchSpawn( data.playerPushOutTrigger )

			file.lootCanisterDataMap[ data.lootEnt ] <- data
		}

		ToxicWaterData waterData
		waterData.toxicWaterMover = GetEntByScriptName( CAUSTIC_TT_TOXIC_WATER_MOVER_SCRIPTNAME )
		waterData.toxicWaterMoverStartOrigin = waterData.toxicWaterMover.GetOrigin()
		foreach ( entity moverLinkEnt in waterData.toxicWaterMover.GetLinkEntArray() )
		{
			if ( moverLinkEnt.GetClassName() == "func_brush" )
			{
				waterData.toxicWater = moverLinkEnt
				waterData.toxicWater.SetParent( waterData.toxicWaterMover )
			}
			else if ( moverLinkEnt.GetClassName() == "trigger_hurt" )
			{
				waterData.toxicWaterHurtTrigger = moverLinkEnt
				waterData.toxicWaterHurtTrigger.SetParent( waterData.toxicWaterMover )
			}
		}

		file.toxicWaterData = waterData

		file.gasFountainMover = GetEntByScriptName( CAUSTIC_TT_GAS_FOUNTAIN_MOVER_SCRIPTNAME )
		file.gasFountainMoverOrigin = file.gasFountainMover.GetOrigin()
		foreach ( entity gasFountainHelper in GetEntArrayByScriptName( CAUSTIC_TT_GAS_FOUNTAIN ) )
		{
			entity gasFountainEnt = CreateEntity( "info_particle_system" )
			gasFountainEnt.SetValueForEffectNameKey( GetAssetFromString( CAUSTIC_TT_FOUNTAIN_FX ) )
			gasFountainEnt.kv.start_active = 1
			gasFountainEnt.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
			gasFountainEnt.SetOrigin( gasFountainHelper.GetOrigin() )
			gasFountainEnt.SetParent( file.gasFountainMover )

			DispatchSpawn( gasFountainEnt )

			file.gasFountainEnts.append( gasFountainEnt )
			EffectSleep( gasFountainEnt )
		}

		foreach ( entity waterSmokeHelper in GetEntArrayByScriptName( CAUSTIC_TT_WATER_SMOKE ) )
		{
			entity waterSmokeEnt = CreateEntity( "info_particle_system" )
			waterSmokeEnt.SetValueForEffectNameKey( GetAssetFromString( CAUSTIC_TT_WATER_SMOKE_FX ) )
			waterSmokeEnt.kv.start_active = 1
			waterSmokeEnt.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
			waterSmokeEnt.SetOrigin( waterSmokeHelper.GetOrigin() )
			waterSmokeEnt.SetAngles( waterSmokeHelper.GetAngles() )

			DispatchSpawn( waterSmokeEnt )

			file.waterSmokeEnts.append( waterSmokeEnt )
		}
		Caustic_TT_SetLootUsability ( false )
	#endif // SERVER

	if ( file.isGasFunctionInverted )
		thread CanisterSwitch_TrapActivate_Thread( null, true ) //if inverted, run base trap function without expiration to setup
}

bool function CanisterSwitch_CanUse ( entity player, entity canisterSwitch, int useFlags )
{
	if ( !SURVIVAL_PlayerCanUse_AnimatedInteraction( player, canisterSwitch ) )
		return false

	return true
}

#if CLIENT
string function GetCanisterSwitchUseTextOverride( entity canisterSwitch )
{
	if ( file.switchesEnabled )
	{
		if ( !file.isGasFunctionInverted )
			return "#CAUSTIC_TT_SWITCH_ON"
		else
			return "#CAUSTIC_TT_SWITCH_ON_INVERTED"
	}

	return ""
}
#endif // CLIENT

void function CanisterSwitch_OnUse( entity canisterSwitch, entity player, int useInputFlags )
{
	if ( file.switchesEnabled && IsBitFlagSet( useInputFlags, USE_INPUT_LONG ) )
			thread CanisterSwitch_UseThink_Thread( canisterSwitch, player )
	else
	{
		#if SERVER
			EmitSoundOnEntityOnlyToPlayer ( canisterSwitch, player, CAUSTIC_TT_SWITCH_DISABLED_SFX )
		#endif // SERVER
	}
}

void function CanisterSwitch_UseThink_Thread( entity ent, entity playerUser )
{
	ent.EndSignal( "OnDestroy" )

	ExtendedUseSettings settings
	settings.loopSound = "survival_titan_linking_loop"
	settings.successSound = "ui_menu_store_purchase_success"
	settings.duration = 1.0
	settings.successFunc = CanisterSwitch_ExtendedUseSuccess

	#if CLIENT || UI
		settings.icon = $""
		settings.hint = !file.isGasFunctionInverted ? Localize ( "#CAUSTIC_TT_ACTIVATE" ) : Localize ( "#CAUSTIC_TT_ACTIVATE_INVERTED" )
		settings.displayRui = $"ui/extended_use_hint.rpak"
		settings.displayRuiFunc = CanisterSwitch_DisplayRui
	#endif // CLIENT || UI

	waitthread ExtendedUse( ent, playerUser, settings )
}

void function CanisterSwitch_DisplayRui( entity ent, entity player, var rui, ExtendedUseSettings settings )
{
	#if CLIENT || UI
		RuiSetString( rui, "holdButtonHint", settings.holdHint )
		RuiSetString( rui, "hintText", settings.hint )
		RuiSetGameTime( rui, "startTime", Time() )
		RuiSetGameTime( rui, "endTime", Time() + settings.duration )
	#endif // CLIENT || UI
}

void function CanisterSwitch_ExtendedUseSuccess( entity canisterSwitch, entity player, ExtendedUseSettings settings )
{
	if ( !file.switchesEnabled )
		return

	if ( !IsValid( player ) )
		return

	if ( !IsValid( canisterSwitch ) )
		return

	CanisterSwitches_Disabled()
	SetCanistersOpen()

	if ( !file.isGasFunctionInverted )
		thread CanisterSwitch_TrapActivate_Thread( player )
	else
		thread CanisterSwitch_TrapActivate_Inverted_Thread( player )
}

void function CanisterSwitch_TrapActivate_Thread( entity player, bool isInvertedSetup = false )
{
	#if SERVER
		EmitSoundAtPosition( TEAM_UNASSIGNED, file.audioSpeaker.GetOrigin(), CAUSTIC_TT_GAS_ALARM_SFX, file.audioSpeaker )
		// Need EmitSoundOnEntity() to play "timer" sfx in predetermined space (interior of building), EmitSoundAtPosition() plays automatically in a radius
		EmitSoundOnEntity( file.audioSpeaker, CAUSTIC_TT_GAS_TIMER_SFX )

		file.gasFountainMover.NonPhysicsMoveTo( file.gasFountainMoverOrigin + < 0, 0, -50 >, 2.0, 0, 0 )

		file.toxicWaterData.toxicWaterMover.NonPhysicsMoveTo( file.toxicWaterData.toxicWaterMoverStartOrigin + CAUSTIC_TT_TOXIC_WATER_MOVE_TO_OFFSET, CAUSTIC_TT_TOXIC_WATER_MOVE_TO_DRAIN, 0, 0 )

		foreach ( entity waterSmokeEnt in file.waterSmokeEnts )
			EffectSleep( waterSmokeEnt )

		if ( !isInvertedSetup )
		{
			foreach ( windowHighlight in file.windowHighlights )
				windowHighlight.SetSkin( 1 )

			foreach ( entity lootEnt in file.canisterLootEnts )
			{
				if ( IsValid( lootEnt ) )
				{
					LootCanisterData data = file.lootCanisterDataMap[ lootEnt ]

					data.canisterMover.NonPhysicsMoveTo( data.canisterMoverStartOrigin + CAUSTIC_TT_CANISTER_MOVE_TO_OFFSET, CAUSTIC_TT_CANISTER_MOVE_TO_DURATION_OPEN, 0, 0 )
					EmitSoundAtPosition( TEAM_UNASSIGNED, data.canisterMoverStartOrigin, CAUSTIC_TT_CANISTER_LOWER_SFX, lootEnt )
				}
			}
		}
	#endif // SERVER

	wait 2.0

	#if SERVER
		file.shouldToxicWaterEmitterBeOn = false

		foreach ( alivePlayer in GetPlayerArray_AliveConnected() )
			Remote_CallFunction_NonReplay( alivePlayer, "Caustic_TT_ServerCallback_ToxicWaterEmitterOff" )

		if ( !isInvertedSetup )
			EmitSoundAtPosition( TEAM_UNASSIGNED, file.audioSpeaker.GetOrigin(), CANISTER_TRAP_DEACTIVATED_VO, file.audioSpeaker )
	#endif // SERVER

	if ( isInvertedSetup )
		return

	wait 7.5

	#if SERVER
		if ( IsPlayerCaustic( player ) )
			thread PlayBattleChatterLineToSpeakerAndTeam( player, "bc_ttPAReact" )
	#endif // SERVER

	wait 7.5 //CANISTER_TIMER_START

	#if SERVER
		EmitSoundAtPosition( TEAM_UNASSIGNED, file.audioSpeaker.GetOrigin(), CANISTER_TRAP_WARNING_VO, file.audioSpeaker )
	#endif // SERVER

	wait CANISTER_TIMER_END

	thread CanisterSwitch_TrapExpired_Thread()
}

void function CanisterSwitch_TrapExpired_Thread()
{
	#if SERVER
		// Need EmitSoundOnEntity() to play "refill" sfx in predetermined space (interior of building), EmitSoundAtPosition() plays automatically in a radius
		EmitSoundOnEntity( file.audioSpeaker, CAUSTIC_TT_GAS_REFILL_SFX )

		foreach ( windowHighlight in file.windowHighlights )
			windowHighlight.SetSkin( 0 )

		foreach ( entity gasFountainEnt in file.gasFountainEnts )
			EffectWake( gasFountainEnt )

		file.gasFountainMover.NonPhysicsMoveTo( file.gasFountainMoverOrigin, CAUSTIC_TT_TOXIC_WATER_MOVE_TO_FILL, 0, 0 )

		file.toxicWaterData.toxicWaterMover.NonPhysicsMoveTo( file.toxicWaterData.toxicWaterMoverStartOrigin, CAUSTIC_TT_TOXIC_WATER_MOVE_TO_FILL, 0, 0 )

		foreach ( entity waterSmokeEnt in file.waterSmokeEnts )
			EffectWake( waterSmokeEnt )

		foreach ( entity lootEnt in file.canisterLootEnts )
		{
			if ( IsValid( lootEnt ) )
			{
				LootCanisterData data = file.lootCanisterDataMap[ lootEnt ]

				if ( data.playersInCanister == 0 )
				{
					if ( IsValid( data.trigger ) )
						CanisterCleanupTouchingEnts( data.trigger )

					data.canisterMover.NonPhysicsMoveTo( data.canisterMoverStartOrigin, CAUSTIC_TT_CANISTER_MOVE_TO_DURATION_CLOSE, 0, 0 )
					EmitSoundAtPosition( TEAM_UNASSIGNED, data.canisterMoverStartOrigin, CAUSTIC_TT_CANISTER_RISE_SFX, data.canisterMover )
				}
			}
		}

		foreach ( alivePlayer in GetPlayerArray_AliveConnected() )
			Remote_CallFunction_NonReplay( alivePlayer, "Caustic_TT_ServerCallback_ToxicWaterEmitterOn" )

		file.shouldToxicWaterEmitterBeOn = true
	#endif // SERVER

	SetCanistersClosed()

	wait 2.0

	#if SERVER
		EmitSoundAtPosition( TEAM_UNASSIGNED, file.audioSpeaker.GetOrigin(), CANISTER_TRAP_ACTIVATED_VO, file.audioSpeaker )
	#endif // SERVER

	wait 5.0

	#if SERVER
		foreach ( entity gasFountainEnt in file.gasFountainEnts )
			EffectSleep( gasFountainEnt )
	#endif // SERVER

	wait 3.0

	CanisterSwitches_Enabled()
}

const float CAUSTIC_TT_INVERTED_WAIT_TO_DRAIN = 20.0
const float CAUSTIC_TT_INVERTED_WAIT_TO_DRAIN_EXTENDED = 25.0
void function CanisterSwitch_TrapActivate_Inverted_Thread( entity player )
{
	bool useDefaultSFX = true

	                        
		//if ( GameMode_IsActive( eGameModes.CONTROL ) )
			//useDefaultSFX = false
                               

	#if SERVER

		if ( useDefaultSFX )
		{
			EmitSoundAtPosition( TEAM_UNASSIGNED, file.audioSpeaker.GetOrigin(), CAUSTIC_TT_GAS_ALARM_SFX, file.audioSpeaker )
			// Need EmitSoundOnEntity() to play "timer" sfx in predetermined space (interior of building), EmitSoundAtPosition() plays automatically in a radius
			EmitSoundOnEntity( file.audioSpeaker, CAUSTIC_TT_GAS_TIMER_SFX )
		}
		                        
		else
		{
			EmitSoundAtPosition( TEAM_UNASSIGNED, file.audioSpeaker.GetOrigin(), CAUSTIC_TT_GAS_ALARM_SFX_CONTROL_MODE, file.audioSpeaker )
			// Need EmitSoundOnEntity() to play "timer" sfx in predetermined space (interior of building), EmitSoundAtPosition() plays automatically in a radius
			EmitSoundOnEntity( file.audioSpeaker, CAUSTIC_TT_GAS_TIMER_SFX_CONTROL_MODE )
		}
                                

		foreach ( windowHighlight in file.windowHighlights )
			windowHighlight.SetSkin( 1 )

		foreach ( entity gasFountainEnt in file.gasFountainEnts )
			EffectWake( gasFountainEnt )

		file.gasFountainMover.NonPhysicsMoveTo( file.gasFountainMoverOrigin, CAUSTIC_TT_TOXIC_WATER_MOVE_TO_FILL, 0, 0 )

		file.toxicWaterData.toxicWaterMover.NonPhysicsMoveTo( file.toxicWaterData.toxicWaterMoverStartOrigin, CAUSTIC_TT_TOXIC_WATER_MOVE_TO_FILL, 0, 0 )

		foreach ( entity waterSmokeEnt in file.waterSmokeEnts )
			EffectWake( waterSmokeEnt )

		foreach ( entity lootEnt in file.canisterLootEnts )
		{
			if ( IsValid( lootEnt ) )
			{
				LootCanisterData data = file.lootCanisterDataMap[ lootEnt ]

				data.canisterMover.NonPhysicsMoveTo( data.canisterMoverStartOrigin + CAUSTIC_TT_CANISTER_MOVE_TO_OFFSET, CAUSTIC_TT_CANISTER_MOVE_TO_DURATION_OPEN, 0, 0 )
				EmitSoundAtPosition( TEAM_UNASSIGNED, data.canisterMoverStartOrigin, CAUSTIC_TT_CANISTER_LOWER_SFX, lootEnt )
			}
		}

		foreach ( alivePlayer in GetPlayerArray_AliveConnected() )
			Remote_CallFunction_NonReplay( alivePlayer, "Caustic_TT_ServerCallback_ToxicWaterEmitterOn" )

		file.shouldToxicWaterEmitterBeOn = true
	#endif // SERVER

	wait 7.0

	#if SERVER
		foreach ( entity gasFountainEnt in file.gasFountainEnts )
			EffectSleep( gasFountainEnt )
	#endif // SERVER

	// Default SFX are 5 secs shorter
	if ( useDefaultSFX )
	{
		wait CAUSTIC_TT_INVERTED_WAIT_TO_DRAIN
	}
	else
	{
		wait CAUSTIC_TT_INVERTED_WAIT_TO_DRAIN_EXTENDED
	}

	thread CanisterSwitch_TrapExpired_Inverted_Thread()
}

void function CanisterSwitch_TrapExpired_Inverted_Thread()
{
	#if SERVER
		// Need EmitSoundOnEntity() to play "refill" sfx in predetermined space (interior of building), EmitSoundAtPosition() plays automatically in a radius
		EmitSoundOnEntity( file.audioSpeaker, CAUSTIC_TT_GAS_REFILL_SFX )

		foreach ( windowHighlight in file.windowHighlights )
			windowHighlight.SetSkin( 0 )

		file.gasFountainMover.NonPhysicsMoveTo( file.gasFountainMoverOrigin + < 0, 0, -50 >, 2.0, 0, 0 )

		file.toxicWaterData.toxicWaterMover.NonPhysicsMoveTo( file.toxicWaterData.toxicWaterMoverStartOrigin + CAUSTIC_TT_TOXIC_WATER_MOVE_TO_OFFSET, CAUSTIC_TT_TOXIC_WATER_MOVE_TO_DRAIN, 0, 0 )

		foreach ( entity waterSmokeEnt in file.waterSmokeEnts )
			EffectSleep( waterSmokeEnt )

		foreach ( entity lootEnt in file.canisterLootEnts )
		{
			if ( IsValid( lootEnt ) )
			{
				LootCanisterData data = file.lootCanisterDataMap[ lootEnt ]

				if ( data.playersInCanister == 0 )
				{
					if ( IsValid( data.trigger ) )
						CanisterCleanupTouchingEnts( data.trigger )

					data.canisterMover.NonPhysicsMoveTo( data.canisterMoverStartOrigin, CAUSTIC_TT_CANISTER_MOVE_TO_DURATION_CLOSE, 0, 0 )
					EmitSoundAtPosition( TEAM_UNASSIGNED, data.canisterMoverStartOrigin, CAUSTIC_TT_CANISTER_RISE_SFX, data.canisterMover )
				}
			}
		}
	#endif // SERVER

	SetCanistersClosed()

	wait 2.0

	#if SERVER
		file.shouldToxicWaterEmitterBeOn = false

		foreach ( alivePlayer in GetPlayerArray_AliveConnected() )
			Remote_CallFunction_NonReplay( alivePlayer, "Caustic_TT_ServerCallback_ToxicWaterEmitterOff" )
	#endif // SERVER

	wait 5.0

	#if SERVER
		foreach ( entity gasFountainEnt in file.gasFountainEnts )
			EffectSleep( gasFountainEnt )
	#endif // SERVER

	wait 3.0

	//wait for reduced spam in inverted mode
	wait 30.0

	CanisterSwitches_Enabled()
}

void function CanisterSwitches_Disabled()
{
	#if SERVER
		foreach ( canisterSwitch in file.canisterSwitches )
		{
			canisterSwitch.SetSkin( 1 )
		}

		foreach ( alivePlayer in GetPlayerArray_AliveConnected() )
			Remote_CallFunction_NonReplay( alivePlayer, "Caustic_TT_ServerCallback_SetSwitchesDisabled" )

	#endif // SERVER

	file.switchesEnabled = false
}

void function CanisterSwitches_Enabled()
{
	#if SERVER
		// Check if there is still loot inside the canisters
		bool validLootEntPresent = false
		foreach ( entity lootEnt in file.canisterLootEnts )
		{
			if ( IsValid( lootEnt ) )
			{
				validLootEntPresent = true
			}
		}

		if ( validLootEntPresent || file.isGasFunctionInverted ) // If loot found, re-enable panel - if inverted, always re-enable
		{
			foreach ( canisterSwitch in file.canisterSwitches )
			{
				canisterSwitch.SetSkin( 0 )
			}

			file.switchesEnabled = true

			foreach ( alivePlayer in GetPlayerArray_AliveConnected() )
				Remote_CallFunction_NonReplay( alivePlayer, "Caustic_TT_ServerCallback_SetSwitchesEnabled" )

		}
		else if ( !validLootEntPresent ) // If no loot found, disable the panel
		{
			foreach ( canisterSwitch in file.canisterSwitches )
			{
				canisterSwitch.SetSkin( 1 )
				canisterSwitch.UnsetUsable()
			}
		}
	#endif // SERVER
}

void function SetCanistersClosed()
{
	file.canistersClosed = true
	#if SERVER
		Caustic_TT_SetLootUsability( false )

		foreach ( alivePlayer in GetPlayerArray_AliveConnected() )
			Remote_CallFunction_NonReplay( alivePlayer, "Caustic_TT_ServerCallback_SetCanistersClosed" )

		UpdateCanisterLootData()
	#endif
}

void function SetCanistersOpen()
{
	file.canistersClosed = false
	#if SERVER
		Caustic_TT_SetLootUsability( true )

		foreach ( alivePlayer in GetPlayerArray_AliveConnected() )
			Remote_CallFunction_NonReplay( alivePlayer, "Caustic_TT_ServerCallback_SetCanistersOpen" )

		UpdateCanisterLootData()
	#endif
}

#if SERVER
void function UpdateCanisterLootData()
{
	foreach ( entity lootEnt in file.canisterLootEnts )
	{
		if ( IsValid( lootEnt ) )
		{
			foreach ( alivePlayer in GetPlayerArray_AliveConnected() )
				Remote_CallFunction_NonReplay( alivePlayer, "ServerToClient_UpdateItem", lootEnt )
		}
	}
}
#endif

#if SERVER
void function LootCanister_PlayerEnterCanister( entity trigger, entity ent )
{
	if ( !IsValid( trigger ) )
		return

	entity lootEnt = trigger.GetParent()

	if ( IsValid( lootEnt ) )
	{
		LootCanisterData data = file.lootCanisterDataMap[ lootEnt ]

		if ( ent.DoesShareRealms( trigger ) && ent.IsPlayer() )
			data.playersInCanister ++
	}

}

void function LootCanister_PlayerLeaveCanister( entity trigger, entity ent )
{
	if ( !IsValid( trigger ) )
		return

	// Prevent canister from closing if there is a deathbox inside
	if( !ent.IsEntAlive() )
		return

	entity lootEnt = trigger.GetParent()

	if ( IsValid( lootEnt ) )
	{
		LootCanisterData data = file.lootCanisterDataMap[ lootEnt ]

		if ( ent.DoesShareRealms( trigger ) && ent.IsPlayer() )
		{
			Assert( data.playersInCanister > 0, "Caustic TT - There are less than 0 players in a loot canister" )

			data.playersInCanister --
		}
	}
}

array< string > function GetCanisterLootToSpawn()
{
	/*if ( GameMode_IsActive( eGameModes.CONTROL ) )
	{
		file.canisterLootRefs = SURVIVAL_GetAllRefsInLootGroup( "control_carepackage_center_tier_4" )
		file.canisterLootRefs.extend( SURVIVAL_GetAllRefsInLootGroup( "control_gold_kitted_weapons" ) )
	}
	else*/
	{
		//file.canisterLootRefs = SURVIVAL_GetAllRefsInLootGroup( "gold_items" )
		//file.canisterLootRefs.extend( SURVIVAL_GetAllRefsInLootGroup( "gold_weapons" ) )
		file.canisterLootRefs = SURVIVAL_GetAllRefsInLootGroup( "caustictt_loot" )
	}

	return file.canisterLootRefs
}

entity function SpawnCanisterLoot( entity lootEntHelper )
{
	if ( file.canisterLootRefs.len() != 0 )
	{
		entity lootEnt
		vector lootOrigin = lootEntHelper.GetOrigin()
		vector lootAngles = lootEntHelper.GetAngles()

		string lootRef = file.canisterLootRefs.getrandom()

		// Change rotation of particular loot types for better visibility
		int lootRefType = SURVIVAL_Loot_GetLootDataByRef( lootRef ).lootType

		if ( lootRefType == TYPE_WEAPON )
			lootAngles = lootAngles + < -90, 0, 0 >
		else if ( lootRefType == TYPE_INCAPSHIELD )
			lootAngles = lootAngles + < 90, 0, 0 >
		else if ( lootRefType == TYPE_BACKPACK )
			lootAngles = lootAngles + < 90, 0, 0 >

		lootEnt = SpawnGenericLoot( lootRef, lootOrigin, lootAngles )

		file.canisterLootRefs.removebyvalue( lootRef )

		return lootEnt
	}

	unreachable
}

void function CanisterCleanupTouchingEnts( entity trigger )
{
	trigger.SearchForNewTouchingEntity()

	foreach ( ent in trigger.GetTouchingEntities() )
	{
		string targetName = ent.GetTargetName()
		string scriptName = ent.GetScriptName()

		if ( targetName == TROPHY_SYSTEM_NAME || scriptName == TESLA_TRAP_NAME || scriptName == BLACKHOLE_PROP_SCRIPTNAME )
			ent.Destroy()
		else if ( targetName == DIRTY_BOMB_TARGETNAME )
			RemoveCausticDirtyBomb( ent, null )
		else if ( targetName == "death_totem" )
			ent.TakeDamage( 9999, null, null, {} )
		else if ( scriptName == PHASETUNNEL_BLOCKER_SCRIPTNAME )
		{
			entity tunnelEnt = ent.GetOwner()
			if ( IsValid( tunnelEnt ) )
			{
				entity ownerPlayer = tunnelEnt.GetOwner()

				if ( IsValid( ownerPlayer ) )
				{
					if ( ownerPlayer.IsPhaseShifted() )
						ownerPlayer.Signal( "PhaseTunnel_CancelPhaseTunnelUse" )

					ownerPlayer.Signal( "PhaseTunnel_DestroyPlacement" )
					ownerPlayer.Signal( "PhaseTunnel_DestroyTunnel" )
				}
			}
		}
	}
}

void function MaybeActivateCausticTTDefense_Thread( entity pickup, entity device, entity player )
{
	if ( !IsCausticTTEnabled() )
		return

	if ( pickup.GetScriptName() != "caustic_tt_loot" )
		return

	if ( !file.canistersClosed )
		return

	LootCanisterData data = file.lootCanisterDataMap[ pickup ]

	Caustic_TT_SetLootUsability_Single( pickup, true )
	file.canisterLootEnts.fastremovebyvalue( pickup )
	data.canisterMover.ClearParent()
	data.canisterMover.NonPhysicsMoveTo( data.canisterMoverStartOrigin + CAUSTIC_TT_CANISTER_MOVE_TO_OFFSET, 5.0, 0, 0 )

	// Copied logic from sh_loot_vault_panel.nut and modified to work for both canisterSwitches
	// todo(dw): make this function better
	foreach ( canisterSwitch in file.canisterSwitches )
	{
		if ( !IsValid( canisterSwitch ) )
			return

		EndSignal( canisterSwitch, "OnDestroy" )

		RegisterSignal( "MaybeActivateCausticTTDefense_Thread" )
		Signal( canisterSwitch, "MaybeActivateCausticTTDefense_Thread" )
		EndSignal( canisterSwitch, "MaybeActivateCausticTTDefense_Thread" )
	}

	if ( IsValid( device ) )
		GradeFlagsSet( device, eGradeFlags.IS_BUSY )

	WaitFrame()

	if ( IsValid( device ) )
	{
		device.TakeDamage( 9999, null, null, {} )

		vector explosionCenter           = device.GetOrigin()
		float damage                     = 2
		float damageHeavyArmor           = damage
		float innerRadius                = 100
		float outerRadius                = 120
		int flags                        = DF_EXPLOSION
		vector projectileLaunchPos       = explosionCenter//vaultPanel.GetOrigin()
		float explosionForce             = 110
		int scriptDamageFlags            = damageTypes.explosive
		int scriptDamageSourceIdentifier = eDamageSourceId.vault_defense
		string impactEffectTableName     = "superSpectre_groundSlam_impact"
		Explosion( explosionCenter, pickup, pickup, damage, damageHeavyArmor, innerRadius, outerRadius, flags, projectileLaunchPos, explosionForce, scriptDamageFlags, scriptDamageSourceIdentifier, impactEffectTableName )
	}


	OnThreadEnd(
		void function() : ( pickup )
		{
			CanisterSwitches_Enabled()

			foreach ( windowHighlight in file.windowHighlights )
				windowHighlight.SetSkin( 0 )

			StopSoundAtPosition( file.audioSpeaker.GetOrigin(), CAUSTIC_TT_LOBA_ALARM_SFX )
		}
	)

	wait 0.2

	// Disable switches but don't allow other canisters to be looted
	CanisterSwitches_Disabled()

	float startTime = Time()
	while ( Time() < startTime + 14.0 )
	{
		EmitSoundAtPosition( TEAM_UNASSIGNED, file.audioSpeaker.GetOrigin(), CAUSTIC_TT_LOBA_ALARM_SFX, file.audioSpeaker )

		foreach ( windowHighlight in file.windowHighlights )
			windowHighlight.SetSkin( 1 )

		wait 3.0
	}
}

bool function GetCausticTTAssetsToPrecache( array< string > models, array< string > particles )
{
	if ( IsCausticTTEnabled() == false )
		return false

	particles.append( CAUSTIC_TT_FOUNTAIN_FX )
	particles.append( CAUSTIC_TT_WATER_SMOKE_FX )
	particles.append( CAUSTIC_TT_CANISTER_GLOW_FX )

	return true
}

void function Caustic_TT_SetLootUsability( bool isUsable )
{
	foreach ( entity loot in file.canisterLootEnts )
	{
		Caustic_TT_SetLootUsability_Single( loot, isUsable )
	}
}

void function Caustic_TT_SetLootUsability_Single( entity loot, bool isUsable )
{
	if ( !IsValid (loot) || loot.GetScriptName() != "caustic_tt_loot" )
		return

	// Grab the data associated with this loot.
	LootCanisterData data = file.lootCanisterDataMap[ loot ]

	if( isUsable )
	{
		// Set to default usable distance
		loot.SetUsableDistanceOverride( 85 )
		// *** DEV: Uncomment to debug trigger size.
		/*
		#if DEV
			 DebugDrawCylinder( loot.GetOrigin() - < 0, 0, CAUSTIC_TT_PLAYERPUSHAWAYTRIGGER_HEIGHT / 2 >, < 270 ,0 , 0 >, CAUSTIC_TT_PLAYERPUSHAWAYTRIGGER_RADIUS, CAUSTIC_TT_PLAYERPUSHAWAYTRIGGER_HEIGHT, COLOR_GREEN, false, 16  )
		#endif
		*/
		if( IsValid( data.playerPushOutTrigger ) )
			data.playerPushOutTrigger.Disable()
	}
	else if ( data.playersInCanister == 0 ) // Leave canister usable if player is in it when timer runs out
	{
		// Set to zero usable distance to players can't grab it through the wall
		loot.SetUsableDistanceOverride( 0 )
		// *** DEV: Uncomment to debug trigger size.
		/*
		#if DEV
			 DebugDrawCylinder( loot.GetOrigin() - < 0, 0, CAUSTIC_TT_PLAYERPUSHAWAYTRIGGER_HEIGHT / 2 >, < 270 ,0 , 0 >, CAUSTIC_TT_PLAYERPUSHAWAYTRIGGER_RADIUS, CAUSTIC_TT_PLAYERPUSHAWAYTRIGGER_HEIGHT, COLOR_RED, false, 16  )
		#endif
		*/
			if ( IsValid( data.playerPushOutTrigger ) )
				data.playerPushOutTrigger.Enable()
	}
}
#endif // SERVER

#if CLIENT
void function Caustic_TT_ServerCallback_SetCanistersOpen()
{
	file.canistersClosed = false
}

void function Caustic_TT_ServerCallback_SetCanistersClosed()
{
	file.canistersClosed = true
}

void function Caustic_TT_ServerCallback_SetSwitchesEnabled()
{
	file.switchesEnabled = true
}

void function Caustic_TT_ServerCallback_SetSwitchesDisabled()
{
	file.switchesEnabled = false
}

void function Caustic_TT_ServerCallback_ToxicWaterEmitterOff()
{
	foreach ( entity emitter in file.toxicWaterEmitters )
	{
		emitter.SetEnabled( false )
	}
}

void function Caustic_TT_ServerCallback_ToxicWaterEmitterOn()
{
	foreach ( entity emitter in file.toxicWaterEmitters )
	{
		emitter.SetEnabled( true )
	}
}
#endif

entity function GetCausticTTCanisterFrameForLoot( entity lootEnt )
{
	foreach ( canisterFrame in file.canisterFrames )
	{
		if ( IsValid( canisterFrame ) ) // Safety catch for 8.1 to prevent R5DEV-228287. TODO: MegC: Exact cause needs to be investigated further for a proper fix.
			if ( DistanceSqr( canisterFrame.GetOrigin(), lootEnt.GetOrigin() ) < CANISTER_DISTANCE_FRAME_TO_LOOT_SQR )
				return canisterFrame
	}

	return null
}

bool function AreCausticTTCanistersClosed( entity canisterPanel )
{
	return file.canistersClosed
}

#if SERVER
bool function IsPlayerCaustic( entity player )
{
	if ( !IsValidPlayer( player ) )
		return false

	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_CharacterClass() )
	string characterRef  = ItemFlavor_GetHumanReadableRef( character ).tolower()

	if ( characterRef != "character_caustic" )
		return false

	return true
}
#endif

bool function IsCausticTTEnabled()
{
	if ( GetCurrentPlaylistVarBool( "caustic_tt_enabled", true ) )
	{
		if (GetMapName() == "mp_rr_canyonlands_mu3" )
			return true
	}

	return false
}


bool function CausticTT_IsGasFunctionInverted()
{
	return file.isGasFunctionInverted
}

void function CausticTT_SetGasFunctionInvertedValue( bool val )
{
	Assert( !Flag( "EntitiesDidLoad" ), "Caustic TT: Trying to set inverted gas function after initialization has been completed" )

	file.isGasFunctionInverted = val
}

#if SERVER
// The Toxic Water emitter exists on the client and whether it plays audio is set by server callbacks. These are called on living players only.
// The normal setup works fine for BR because players aren't often dead and respawned. In a mode like Control players are constantly in changing dead to respawned states.
// Use the respawned callback to update the client state for players in modes with respawns ( and could also fix rare issues in BR).
void function Caustic_TT_OnPlayerRespawned( entity player )
{
	if ( !IsValid( player ) )
		return

	if ( GetGameState() != eGameState.Playing )
		return

	if ( file.shouldToxicWaterEmitterBeOn )
	{
		Remote_CallFunction_NonReplay( player, "Caustic_TT_ServerCallback_ToxicWaterEmitterOn" )
	}
	else
	{
		Remote_CallFunction_NonReplay( player, "Caustic_TT_ServerCallback_ToxicWaterEmitterOff" )
	}
}
#endif