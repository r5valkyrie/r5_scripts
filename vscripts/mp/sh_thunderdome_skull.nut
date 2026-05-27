global function ThunderdomeSkull_Init

#if CLIENT
global function ServerToClient_ThunderdomeSkullInteractionPlayGroundSmokeSound
#endif

#if DEV
#if SERVER
global function DEV_ThunderdomeSkullResetButton
#endif // SERVER
#endif // DEV

#if SERVER
const string FLAG_SKULL_INTERACTION_ENABLED			= "thunderdome_skull_interaction_enabled"
const string FLAG_THUNDERDOME_SKULL_GROUND_SMOKE	= "smokescreen_script"
const string FLAG_THUNDERDOME_SKULL_EYE_SMOKE		= "thunderdome_skull_eye_smoke"
const string FLAG_SMOKE_SKULL_IDLE					= "nozzle_idle"
const string FLAG_SMOKE_SKULL_ACTIVE				= "nozzle_active"
const string FLAG_FLAME_IDLE						= "nose_fire_idle"
const string FLAG_FLAME_ACTIVE						= "nose_fire_active"

const string SCRIPT_NAME_SKULL_BUTTON 		= "thunderdome_skull_interaction_button"
const string SCRIPT_NAME_SMOKE_FX 			= "thunderdome_skull_interaction_smoke_fx_point"
const string SCRIPT_NAME_SKULL_SOUND_POINT	= "thunderdome_skull_interaction_sound_fx_point"
const string SCRIPT_NAME_SKULL_HIGHLIGHTS	= "thunderdome_skull_highlights"

const asset ASSET_FX_SMOKE = $"P_smokescreen_FD"

const string SOUND_ALARM					= "Thunderdome_SmokeAlarm"
const string SOUND_BUTTON_ACTIVATE			= "Thunderdome_SkullSmoke_Switch_Activate"
const string SOUND_BUTTON_DENY				= "Olympus_Horizon_Screen_Deny"
const string SOUND_FLAME_BURST				= "Thunderdome_Skull_Fire_Burst_3p"

const vector ORIGIN_SOUND_FLAME_BURST		= < 318, -350, 1357 >

const int TOTAL_FLAME_BURSTS = 2

const float TIME_COOLDOWN_BUTTON		= 120.0
const float TIME_SOUND_BUTTON			= 0.25
const float TIME_SOUND_GROWL			= 1.0
const float TIME_FX_FLAME_1_START		= 1.5
const float TIME_FX_FLAME_1_END			= 2.2
const float TIME_FX_FLAME_2_START		= 2.5
const float TIME_FX_FLAME_2_END			= 3.2
const float TIME_FX_SMOKE_MOUTH_START	= 3.5
const float TIME_FX_SMOKE_MOUTH_END		= 5.2
const float TIME_FX_SMOKE_SKULL_START	= 4.8
const float TIME_FX_SMOKE_SKULL_END		= 33.5
#endif // SERVER

const float TIME_FX_SMOKE_GROUND_START	= 3.5
const float TIME_FX_SMOKE_GROUND_END	= 33.5

#if CLIENT
// sethg: NOTE!!! Not set in the map yet
const string SCRIPT_NAME_FIRE_AUDIO		= "Thunderdome_skull_fire_audio_emitter"
const string SCRIPT_NAME_SMOKE_AUDIO	= "Thunderdome_skull_smoke_audio_emitter"
#endif // CLIENT

struct
{
	#if SERVER
		float cooldown_button
		float sound_button
		float sound_growl
		float fx_flame_1_start
		float fx_flame_1_end
		float fx_flame_2_start
		float fx_flame_2_end
		float fx_smoke_mouth_start
		float fx_smoke_mouth_end
		float fx_smoke_skull_start
		float fx_smoke_skull_end
	#endif // SERVER

	float fx_smoke_ground_start
	float fx_smoke_ground_end
	float fx_smoke_ground_lifetime
} times

struct
{
	#if SERVER
		array< entity >	smokeFXPoints
		array< entity >	skullSoundPoints
		array< entity > skullHighlights
	#endif //SERVER
} file


void function ThunderdomeSkull_Init()
{
	RegisterSignal( "ThunderdomeSkullButtonReset" )

	#if SERVER
		FlagInit( FLAG_SKULL_INTERACTION_ENABLED )
		FlagInit( FLAG_THUNDERDOME_SKULL_GROUND_SMOKE )
		FlagInit( FLAG_THUNDERDOME_SKULL_EYE_SMOKE )
		FlagInit( FLAG_SMOKE_SKULL_IDLE )
		FlagInit( FLAG_SMOKE_SKULL_ACTIVE )
		FlagInit( FLAG_FLAME_IDLE )
		FlagInit( FLAG_FLAME_ACTIVE )

		PrecacheParticleSystem( ASSET_FX_SMOKE )
		PrecacheScriptString( BANGALORE_SMOKESCREEN_SCRIPTNAME )

		AddCallback_EntitiesDidLoad( EntitiesDidLoad )

		FlagSet( FLAG_FLAME_IDLE )
	#endif // SERVER

	Remote_RegisterClientFunction( "ServerToClient_ThunderdomeSkullInteractionPlayGroundSmokeSound" )

	ThunderdomeSkullInteractionInitTimes()
}

void function ThunderdomeSkullInteractionInitTimes()
{
	#if SERVER
		times.cooldown_button = GetCurrentPlaylistVarFloat( "thunderdome_skull_interaction_time_cooldown_button", TIME_COOLDOWN_BUTTON )
		times.sound_button = GetCurrentPlaylistVarFloat( "thunderdome_skull_interaction_time_sound_button", TIME_SOUND_BUTTON )
		times.sound_growl = GetCurrentPlaylistVarFloat( "thunderdome_skull_interaction_time_sound_growl", TIME_SOUND_GROWL )
		times.fx_flame_1_start = GetCurrentPlaylistVarFloat( "thunderdome_skull_interaction_time_fx_flame_1_start", TIME_FX_FLAME_1_START )
		times.fx_flame_1_end = GetCurrentPlaylistVarFloat( "thunderdome_skull_interaction_time_fx_flame_1_end", TIME_FX_FLAME_1_END )
		times.fx_flame_2_start = GetCurrentPlaylistVarFloat( "thunderdome_skull_interaction_time_fx_flame_2_start", TIME_FX_FLAME_2_START )
		times.fx_flame_2_end = GetCurrentPlaylistVarFloat( "thunderdome_skull_interaction_time_fx_flame_2_end", TIME_FX_FLAME_2_END )
		times.fx_smoke_mouth_start = GetCurrentPlaylistVarFloat( "thunderdome_skull_interaction_time_fx_smoke_mouth_start", TIME_FX_SMOKE_MOUTH_START )
		times.fx_smoke_mouth_end = GetCurrentPlaylistVarFloat( "thunderdome_skull_interaction_time_fx_smoke_mouth_end", TIME_FX_SMOKE_MOUTH_END )
		times.fx_smoke_skull_start = GetCurrentPlaylistVarFloat( "thunderdome_skull_interaction_time_fx_smoke_skull_start", TIME_FX_SMOKE_SKULL_START )
		times.fx_smoke_skull_end = GetCurrentPlaylistVarFloat( "thunderdome_skull_interaction_time_fx_smoke_skull_end", TIME_FX_SMOKE_SKULL_END )
	#endif // SERVER

	times.fx_smoke_ground_start = GetCurrentPlaylistVarFloat( "thunderdome_skull_interaction_time_cooldown_button", TIME_FX_SMOKE_GROUND_START )
	times.fx_smoke_ground_end = GetCurrentPlaylistVarFloat( "thunderdome_skull_interaction_time_cooldown_button", TIME_FX_SMOKE_GROUND_END )

	times.fx_smoke_ground_lifetime = times.fx_smoke_ground_end - times.fx_smoke_ground_start
}

#if SERVER
void function EntitiesDidLoad()
{
	if ( !IsThunderdomeSkullInteractionEnabled() )
		return

	file.smokeFXPoints = GetEntArrayByScriptName( SCRIPT_NAME_SMOKE_FX )
	file.skullSoundPoints = GetEntArrayByScriptName( SCRIPT_NAME_SKULL_SOUND_POINT )
	file.skullHighlights = GetEntArrayByScriptName( SCRIPT_NAME_SKULL_HIGHLIGHTS )

	entity interactionButton = InitInteractionButton()

	// initial state
	SetThunderdomeSkullInteractionButtonInactive( interactionButton )
}
#endif // SERVER

#if SERVER
bool function IsThunderdomeSkullInteractionEnabled()
{
	if ( !GetCurrentPlaylistVarBool( "thunderdome_skull_interaction_enabled", true ) )
	{
		return false
	}

	array<string> entScriptnamesToCheck
	entScriptnamesToCheck.append( SCRIPT_NAME_SKULL_BUTTON )
	entScriptnamesToCheck.append( SCRIPT_NAME_SMOKE_FX )
	entScriptnamesToCheck.append( SCRIPT_NAME_SKULL_SOUND_POINT )

	bool allEntsPresent = true
	foreach ( string scriptName in entScriptnamesToCheck )
	{
		array<entity> entsToCheck = GetEntArrayByScriptName( scriptName )
		if ( entsToCheck.len() == 0 )
		{
			allEntsPresent = false
			break
		}
	}

	return allEntsPresent
}
#endif // SERVER

#if SERVER
entity function InitInteractionButton()
{
	entity button = GetEntByScriptName( SCRIPT_NAME_SKULL_BUTTON )

	button.AllowMantle()
	button.SetForceVisibleInPhaseShift( true )
	button.SetUsable()
	button.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER | USABLE_BY_PILOTS | USABLE_BY_ENEMIES )
	button.SetUsablePriority( USABLE_PRIORITY_LOW )
	button.SetUsePrompts( "#THUNDERDOME_SKULL_INTERACTION_HINT", "#THUNDERDOME_SKULL_INTERACTION_HINT" )
	button.SetSkin( 0 )
	AddCallback_OnUseEntity_ServerOnly( button, ThunderdomeSkullInteractionButtonFunc( button ) )

	return button
}
#endif // SERVER

#if SERVER
void functionref( entity button, entity player, int useInputFlags ) function ThunderdomeSkullInteractionButtonFunc( entity button )
{
	return void function( entity button, entity player, int useInputFlags ) : ()
	{
		thread OnThunderdomeSkullInteractionButtonPress( button, player, useInputFlags )
	}
}
#endif // SERVER

#if SERVER
void function OnThunderdomeSkullInteractionButtonPress( entity button, entity player, int useInputFlags )
{
	if ( Flag( FLAG_SKULL_INTERACTION_ENABLED ) )
	{
		EmitSoundOnEntityOnlyToPlayer( button, player, SOUND_BUTTON_DENY )
		return
	}

	player.EndSignal( "ThunderdomeSkullButtonReset" )

	OnThreadEnd(
		function() : ( button )
		{
			SetThunderdomeSkullInteractionButtonInactive( button )
		}
	)

	SetThunderdomeSkullInteractionButtonActive( button )

	// Button sequence
	{
		thread ThunderdomeSkullInteractionPlayButton( button )
		thread ThunderdomeSkullInteractionPlayAlarm( button )
		thread ThunderdomeSkullInteractionPlayFlameBursts( button )
		thread ThunderdomeSkullInteractionPlayGroundSmoke()
		thread ThunderdomeSkullInteractionPlayMouthSmoke()
	}

	wait times.cooldown_button
}
#endif // SERVER

#if SERVER
void function SetThunderdomeSkullInteractionButtonActive( entity button )
{
	FlagSet( FLAG_SKULL_INTERACTION_ENABLED )

	button.SetUsePrompts( "#THUNDERDOME_SKULL_INTERACTION_INACTIVE_HINT", "#THUNDERDOME_SKULL_INTERACTION_INACTIVE_HINT" )
	button.SetSkin( 1 )

	foreach ( entity currentHighlight in file.skullHighlights )
	{
		currentHighlight.SetSkin( 1 )
	}
}
#endif // SERVER

#if SERVER
void function SetThunderdomeSkullInteractionButtonInactive( entity button )
{
	button.SetUsePrompts( "#THUNDERDOME_SKULL_INTERACTION_HINT", "#THUNDERDOME_SKULL_INTERACTION_HINT" )
	button.SetSkin( 0 )

	foreach ( entity currentHighlight in file.skullHighlights )
	{
		currentHighlight.SetSkin( 0 )
	}

	FlagClear( FLAG_SKULL_INTERACTION_ENABLED )
}
#endif // SERVER

#if SERVER
void function ThunderdomeSkullInteractionPlayButton( entity button )
{
	wait times.sound_button

	EmitSoundOnEntity( button, SOUND_BUTTON_ACTIVATE )
}
#endif // SERVER

#if SERVER
void function ThunderdomeSkullInteractionPlayAlarm( entity button )
{
	wait times.sound_growl

	foreach ( entity soundInfo in file.skullSoundPoints )
	{
		EmitSoundAtPosition( TEAM_UNASSIGNED, soundInfo.GetOrigin(), SOUND_ALARM, button )
	}
}
#endif // SERVER

#if SERVER
void function ThunderdomeSkullInteractionPlayFlameBursts( entity button )
{
	array< float > flameBurstStarts	= [ times.fx_flame_1_start,	times.fx_flame_2_start ]
	array< float > flameBurstEnds	= [ times.fx_flame_1_end, times.fx_flame_2_end ]

	for ( int i = 0; i < TOTAL_FLAME_BURSTS; i++ )
	{
		float startWaitTime = i > 0 ? (flameBurstStarts[ i ] - flameBurstEnds[ i-1 ]) : flameBurstStarts[ i ]
		wait startWaitTime

		// Sound
		{
			foreach ( entity soundInfo in file.skullSoundPoints )
			{
				EmitSoundAtPosition( TEAM_UNASSIGNED, ORIGIN_SOUND_FLAME_BURST, SOUND_FLAME_BURST, button )
			}
		}

		// FX
		FlagSet( FLAG_FLAME_ACTIVE )
		FlagClear( FLAG_FLAME_IDLE )

		float endWaitTime = flameBurstEnds[ i ] - flameBurstStarts[ i ]
		wait endWaitTime

		// FX
		FlagClear( FLAG_FLAME_ACTIVE )
		FlagSet( FLAG_FLAME_IDLE )
	}
}
#endif // SERVER

#if SERVER
void function ThunderdomeSkullInteractionPlayMouthSmoke()
{
	wait times.fx_smoke_mouth_start

	FlagSet( FLAG_SMOKE_SKULL_ACTIVE )
	FlagClear( FLAG_SMOKE_SKULL_IDLE )

	float timeFXSmokeMouthLifetime = times.fx_smoke_mouth_end - times.fx_smoke_mouth_start
	wait timeFXSmokeMouthLifetime

	FlagSet( FLAG_SMOKE_SKULL_IDLE )
	FlagClear( FLAG_SMOKE_SKULL_ACTIVE )
}
#endif // SERVER

#if SERVER
void function ThunderdomeSkullInteractionPlayGroundSmoke()
{
	wait times.fx_smoke_ground_start

	// Sound
	{
		array< entity > players = GetPlayerArray()
		foreach ( entity player in players )
		{
			Remote_CallFunction_NonReplay( player, "ServerToClient_ThunderdomeSkullInteractionPlayGroundSmokeSound" )
		}
	}

	bool playEyeSmoke = GetCurrentPlaylistVarBool( "thunderdome_skull_eye_smoke_enabled", true )

	// FX
	FlagSet( FLAG_THUNDERDOME_SKULL_GROUND_SMOKE )

	if ( playEyeSmoke )
		FlagSet( FLAG_THUNDERDOME_SKULL_EYE_SMOKE )


	wait times.fx_smoke_ground_lifetime

	// FX
	FlagClear( FLAG_THUNDERDOME_SKULL_GROUND_SMOKE )

	if ( playEyeSmoke )
		FlagClear( FLAG_THUNDERDOME_SKULL_EYE_SMOKE )
}
#endif // SERVER

#if CLIENT
void function ServerToClient_ThunderdomeSkullInteractionPlayGroundSmokeSound()
{
	thread Client_ThunderdomeSkullInteractionPlayAudioEmitters( SCRIPT_NAME_SMOKE_AUDIO, times.fx_smoke_ground_lifetime )
}
#endif

#if CLIENT
void function Client_ThunderdomeSkullInteractionPlayAudioEmitters( string scriptName, float lifetime )
{
	array<entity> audioEmitters = GetEntArrayByScriptName( scriptName )

	foreach ( entity emitter in audioEmitters )
	{
		if ( IsValid( emitter ) )
		{
			emitter.SetEnabled( true )
		}
	}

	wait lifetime

	foreach ( entity emitter in audioEmitters )
	{
		if ( IsValid( emitter ) )
		{
			emitter.SetEnabled( false )
		}
	}
}
#endif

#if DEV
#if SERVER
void function DEV_ThunderdomeSkullResetButton( entity player )
{
	if ( !IsValid( player ) )
		return

	player.Signal( "ThunderdomeSkullButtonReset" )
}
#endif // SERVER
#endif // DEV 