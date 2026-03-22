global function ShEmotes_Init
global function ShEmotes_Lobby_Init
global function AreEmotesEnabled
global function GetPlayerGroundEmoteEnabled
global function GetPlayerIsEmoting
global function GetPlayerIs3pEmoting
global function CheckPlayerCanEmote

#if SERVER
global function SetPlayerCanGroundEmote
global function RequestPlayerPerformEmote
global function SetPlayerStopEmoting
global function Emote_StopEmoteNow
global function Emote_AnimEvent_SpawnModelInWorld
global function Emote_AnimEvent_SpawnSprayInWorld
global function ClientCallback_RequestEmote
global function ClientCallback_RequestStopEmote
global function ClientCallback_PlayerPerformPodiumScreenEmote
global function ClientCallback_PlayerPerformPodiumScreenFlourish
#endif

#if CLIENT
global function RequestCharacterEmote
global function ServerCallback_PlayerPerformPodiumScreenEmote
global function ServerCallback_PlayerPerformPodiumScreenFlourish
global function GetOptionTextForEmote
global function ModelPerformEmote
global function IsEmoteEnabledForPodiumScreen
#endif

#if CLIENT
const string SIGNAL_CL_END_EMOTE_OUTRO 		= "ClEndEmoteOutro"
const string SIGNAL_CL_END_EMOTE_NOW 		= "ClEndEmoteNow"
const string SIGNAL_CL_EMOTE_ENDED 			= "ClEmoteEnded"
const string SIGNAL_CL_NEXT_CAMERA_ATTACHMENT 			= "ClNextCameraAttachment"
const string SIGNAL_CL_PREV_CAMERA_ATTACHMENT 			= "ClPrevCameraAttachment"
#endif // CLIENT

#if SERVER
const array< int > STOP_EMOTE_INPUTS = 	[ IN_JUMP
										, IN_SPEED
										, IN_DODGE
										, IN_ATTACK
										, IN_ZOOM
										, IN_ZOOM_TOGGLE
										, IN_MELEE
										, IN_RELOAD
										, IN_USE
										, IN_USE_AND_RELOAD
										, IN_OFFHAND0
										, IN_DUCKTOGGLE
										, IN_DUCK ]

const int IN_EMOTE_FLOURISH = IN_JUMP
#endif

const string SIGNAL_END_EMOTE_PERFORMANCE 			= "StopEmote"
const string SIGNAL_END_EMOTE_ENDED 				= "EmoteEnded"
const string SIGNAL_EMOTE_START_PROPMOVE			= "EmoteStartPropMove"
global const string SIGNAL_STARTING_EMOTE 			= "StartingEmote"
const string SIGNAL_EMOTE_COMPLETED_FULLY			= "EmoteCompleted"
const string SIGNAL_EMOTE_FLOURISH					= "EmoteFlourish"

#if CLIENT
const string CLIENT_EMOTE_PROMPT_COMMAND = "+jump"
#endif

const string EMOTE_PIN_ACTION_BEGIN 				= "begin"
const string EMOTE_PIN_ACTION_COMPLETE				= "complete"
const string EMOTE_PIN_ACTION_INTERRUPT 			= "interrupted"

#if SERVER
const string SIGNAL_EMOTE_HOLOGRAM_FORCE_END_DESTROYED_WAIT 	= "EmoteHoloForceEndDestroyedWait"

const asset SPAWNEDPROP_MODEL_WATTSON_NESSIE = $"mdl/props/nessie/nessie.rmdl"
const asset SPAWNEDPROP_MODEL_VANTAGE_CARVING = $"mdl/props/carving_01/carving_01_w.rmdl"
const asset SPAWNEDPROP_MODEL_LANTERN = $"mdl/props/lantern_korean/lantern_korean.rmdl"
const asset SPAWNEDPROP_MODEL_CONDUIT_FLOWER = $"mdl/props/flower_hibiscus_prop/flower_hibiscus_prop.rmdl"

const string SIG_PLAYER_SPRAY = "EmotePlayerNewSpray"
const asset WRAITH_INSIGNIA_MODEL = $"mdl/fx/wraith_Kunai_w_all.rmdl"
const float SPRAY_SURFACE_LIFETIME_SEC = 30
const float SPRAY_AIR_LIFETIME_SEC = 2.5

const string SFX_WRAITH_INSIGNIA_LOOP = "Wraith_Mvmt_Kunai_Inspect_Insignia_W_Shimmer"
const string SFX_WRAITH_INSIGNIA_OUTRO = "Wraith_Mvmt_Kunai_Inspect_Insignia_W_FadesOut"

const asset VFX_WRAITH_INSIGNIA_OUTRO = $"P_kunai_w_end_breach_outro"

//---------------------
// Spawned Props
//---------------------
const float SPAWNEDPROP_MOVEDIST_DEFAULT = 7874.02
const float SPAWNEDPROP_MOVESPEED_DEFAULT = 39.37

const float SPAWNEDPROP_LANTERN_MOVE_SPEED 		= 39.37	// Overall speed. ( 39.37 inches/second = 1m/s. )
const float SPAWNEDPROP_LANTERN_MOVE_EASEIN 	= 0.05	// Ramp-Up time to full speed at the start of move. ( seconds )
const float SPAWNEDPROP_LANTERN_MOVE_EASEOUT 	= 0.0	// Ramp-Down time to 0 before ending move. ( seconds )
const asset VFX_LANTERN							= $"P_emt_latern_light"

#endif

//---------------------
// Emote menu
//---------------------
const string EMOTE_CHAT_SUFFIX_FRIENDLY 		= "_CHAT_FRIENDLY"
const string EMOTE_CHAT_SUFFIX_ENEMY 			= "_CHAT_ENEMY"

//---------------------
// Emote performance
//---------------------
const float STATIC_EMOTE_MAX_MOVE_SPEED = 260.0			// At or below this 2D speed, player will stop moving and emote.

const table< string, int > DEV_CUSTOM_ANIM_DURATIONS = 	{	  [ "bangalore_menu_select_ready_up" ] 	= 70
															, [ "mirage_menu_select_ready_up" ]	 	= 100
															, [ "caustic_menu_ready_up" ]		 	= 124
															, [ "wattson_menu_select_ready_up" ] 	= 60
															, [ "octane_menu_select_ready_up" ] 	= 133
														}

const vector CLEARANCE_HULL_MAXS = < 28, 28, 2 >
const vector CLEARANCE_HULL_MINS = -1 * CLEARANCE_HULL_MAXS
const vector CLEARANCE_HULL_ORIGIN_OFFSET = <0,0,54>

const int MAX_PROPS_ALLOWED_IN_WORLD = 20

//---------------------
// Emote camera ( script controlled )
//---------------------
const float CAMPOS_MAX_PITCH_TO_PLAYER 				= 17.5        // Max pitch angle of camera's height above player
const float CAMPOS_MIN_PITCH_TO_PLAYER 				= -25

const float CAM_PITCH_SPEED 						= 0//12				// Higher this is, faster accel to max is
const float CAM_PITCH_SPEED_MAX 					= 5

const float CAM_YAW_SPEED 							= 0//15					// Higher this is, faster accel to max is
const float CAM_YAW_SPEED_MAX 						= 8

const float CAM_SPEED_DRAG 							= 0.95

const float CAM_DIST_SCALAR 						= 128.0

const vector EYE_HEIGHT_OFFSET_APPROX 				= < 0, 0, 64 >

const float DOF_FAR_DISTANCE						= 2750
const float DOF_VARIABLE_BLUR						= 20

const float CAM_BASE_OFFSET_HEIGHT					= -24
const float CAM_OUTRO_EASE_TIME						= 0.2
const float CAM_OUTRO_NO_PREDICT_DEV_BUFFER_TIME	= 0.2

const float EMOTE_CAMERA_BLEND_OUT_TIME = 1.0

global enum eCanEmoteCheckReults
{
	SUCCESS,
	FAIL_TOO_CLOSE_TO_WALL,
	FAIL_GENERIC
}

global struct EmoteCameraData
{
	entity camera
	entity mover

	// Animation controlled camera - Camera parented to attachment
	int emoteFlavorIndex				= -1
	bool animationControlled 			= false
	string activeCameraAttachment		= ""

	// Script controlled camera - Used for orbit, intro, outro
	float maxPitch				= CAMPOS_MAX_PITCH_TO_PLAYER
	float minPitch				= CAMPOS_MIN_PITCH_TO_PLAYER
	float pitchSpeed			= CAM_PITCH_SPEED
	float pitchSpeedMax			= CAM_PITCH_SPEED_MAX
	float yawSpeed				= CAM_YAW_SPEED
	float yawSpeedMax			= CAM_YAW_SPEED_MAX
	float camSpeedDrag			= CAM_SPEED_DRAG
	float camDistScalar			= CAM_DIST_SCALAR
	vector posAnchorOffset		= EYE_HEIGHT_OFFSET_APPROX		// Offset applied to local camera position and, for collision trace, anchor position. Used to get a rough position similar to look target, when an attachment isn't available.
	bool useLookTarget			= true
	float __currentPitchSpeed	= 0
	float __currentYawSpeed		= 0
	string posAnchorAttach		= "ORIGIN"			// Camera is parented to this
	string lookTargetAttach		= "HEADFOCUS"		// Camera looks at this

	float dofFarDistance		= DOF_FAR_DISTANCE
	float dofVariableBlur		= DOF_VARIABLE_BLUR
}

//---------------------
// File struct
//---------------------
struct
{
	bool emotesInitialized = false

	table<entity, ItemFlavor> emotingPlayers            //TODO: Replace with a better system for tracking. Store data on players?

	#if SERVER
		table< entity, array<entity> >	playerSpawnedProps

		float sprayAirLifetime = SPRAY_AIR_LIFETIME_SEC
		float spraySurfaceLifetime = SPRAY_SURFACE_LIFETIME_SEC
	#endif

	#if CLIENT
		string							lastUsedEmoteAttachment
		table< entity, bool >			characterPodiumModelIsEmoting
	#endif // CLIENT

	table<ItemFlavor, ItemFlavor> characterBaseEmoteMap
} file

//---------------------
// Client callbacks
//---------------------
const string CMD_REQUEST_EMOTE_START 			= "ClientCallback_RequestEmote"
const string CMD_REQUEST_EMOTE_STOP 			= "ClientCallback_RequestStopEmote"

//---------------------
// Init
//---------------------
void function ShEmotes_Init()
{
	RegisterNetworkedVariable( "canGroundEmote", SNDC_PLAYER_EXCLUSIVE, SNVT_BOOL, true )
	RegisterNetworkedVariable( "isEmoting", SNDC_PLAYER_EXCLUSIVE, SNVT_BOOL, false )
	RegisterNetworkedVariable( "emoteFlourishAvailable", SNDC_PLAYER_EXCLUSIVE, SNVT_BOOL, false )

	if ( !AreEmotesEnabled() )
		return

	RegisterSignal( "EndAntiPeekAfterDelay" )
	RegisterSignal( SIGNAL_END_EMOTE_PERFORMANCE )
	RegisterSignal( SIGNAL_STARTING_EMOTE )
	RegisterSignal( SIGNAL_END_EMOTE_ENDED )
	RegisterSignal( SIGNAL_EMOTE_FLOURISH )

	AddCallback_OnItemFlavorRegistered( eItemType.character, OnItemFlavorRegistered_Character )

	Remote_RegisterServerFunction( CMD_REQUEST_EMOTE_START, "int", INT_MIN, INT_MAX )
	Remote_RegisterServerFunction( CMD_REQUEST_EMOTE_STOP )

#if SERVER
	RegisterSignal( SIGNAL_EMOTE_HOLOGRAM_FORCE_END_DESTROYED_WAIT )

	Bleedout_AddCallback_OnPlayerStartBleedout( CharacterEmote_OnPlayerBleedout )
	Bleedout_AddCallback_OnPlayerStopBleedout( CharacterEmote_OnPlayerGotFirstAid )

	AddCallback_GameStateEnter( eGameState.PickLoadout, CharacterEmote_OnEnterGamestate_PickLoadout )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, CharacterEmote_OnEnterGameState_WinnerDetermined )
	AddCallback_GameStateEnter( eGameState.Resolution, CharacterEmote_OnEnterGameState_Resolution )

	AddCallback_PlayerClassChanged( StandingEmote_OnPlayerClassChanged )

	PrecacheModel( SPAWNEDPROP_MODEL_WATTSON_NESSIE )
	PrecacheModel( SPAWNEDPROP_MODEL_VANTAGE_CARVING )
	PrecacheModel( SPAWNEDPROP_MODEL_LANTERN )
	PrecacheModel( SPAWNEDPROP_MODEL_CONDUIT_FLOWER )

	PrecacheModel( WRAITH_INSIGNIA_MODEL )
	PrecacheParticleSystem( VFX_WRAITH_INSIGNIA_OUTRO )
	PrecacheParticleSystem( VFX_LANTERN )

	RegisterSignal( SIG_PLAYER_SPRAY )
	RegisterSignal( "SpawnedProp_StopFX" )

	file.sprayAirLifetime = GetCurrentPlaylistVarFloat( "spray_air_lifetime_sec", SPRAY_AIR_LIFETIME_SEC )
	file.spraySurfaceLifetime = GetCurrentPlaylistVarFloat( "spray_surface_lifetime_sec", SPRAY_SURFACE_LIFETIME_SEC )
#endif // SERVER

#if CLIENT
	RegisterSignal( SIGNAL_CL_END_EMOTE_OUTRO )
	RegisterSignal( SIGNAL_CL_END_EMOTE_NOW )
	RegisterSignal( SIGNAL_CL_EMOTE_ENDED )
	RegisterSignal( SIGNAL_CL_NEXT_CAMERA_ATTACHMENT )
	RegisterSignal( SIGNAL_CL_PREV_CAMERA_ATTACHMENT )

	array<string> bonesToTry = [
		"CHESTFOCUS",
		"HEADFOCUS",
		"R_FOREARM",
		"L_FOREARM",
		"ORIGIN"
	]

	bool testDistance = GetCurrentPlaylistVarBool( "emotes_antipeek_testDistance", true )
	bool testFoV = GetCurrentPlaylistVarBool( "emotes_antipeek_testFov", false )
	bool testFriendlies = false

	float nearDist = GetCurrentPlaylistVarFloat( "emotes_antipeek_nearDist", 150 )
	float farDist = GetCurrentPlaylistVarFloat( "emotes_antipeek_farDist", 5000 )

	// InitAntiPeekSettings — CLIENT native not in S3
	//InitAntiPeekSettings( nearDist, farDist, 2.0, testDistance, testFoV, testFriendlies, bonesToTry )

	RegisterNetVarBoolChangeCallback( "isEmoting", Cl_OnPlayerEmoteStateChanged )
	RegisterNetVarBoolChangeCallback( "emoteFlourishAvailable", ToggleFlourishPrompt )

	AddCallback_OnVictoryCharacterModelSpawned( OnPodiumCharacterModelSpawned )
	AddCallback_OnIntroPodiumCharacterModelSpawned( OnPodiumCharacterModelSpawned )
#endif // CLIENT

	file.emotesInitialized = true
}

void function ShEmotes_Lobby_Init()
{
	RegisterSignal( SIGNAL_STARTING_EMOTE )
	RegisterSignal( SIGNAL_EMOTE_FLOURISH )

	#if CLIENT
		RegisterSignal( "BaseEmoteMapInitialized" )
	#elseif SERVER
		AddCallback_Lobby_OnClientConnected( Emotes_OnConnected )
	#endif
}

void function OnItemFlavorRegistered_Character( ItemFlavor characterClass )
{
	if ( ItemFlavor_GetType( characterClass ) != eItemType.character )
		return
}

#if SERVER
void function Emotes_OnConnected( entity player )
{
	bool hasHadBaseStandingEmotesAutoEquipped =  bool( player.GetPersistentVar( "hasHadBaseStandingEmotesAutoEquipped" ) )

	if ( !hasHadBaseStandingEmotesAutoEquipped )
	{
		thread AutoEquipBaseEmotes( player )
	}
}

bool function AreLoadoutSlotsValid( entity player )
{
	array<ItemFlavor> characters = GetAllCharacters()

	foreach ( ItemFlavor character in characters )
	{
		for ( int i = 0; i < MAX_QUIPS_EQUIPPED; i++ )
		{
			LoadoutEntry entry = Loadout_CharacterQuip( character, i )

			if ( !LoadoutSlot_IsReady( ToEHI( player ), entry ) )
				return false
		}
	}

	return true
}

void function AutoEquipBaseEmotes( entity player )
{
	player.EndSignal( "OnDestroy" )

	while ( !AreLoadoutSlotsValid( player ) )
		WaitFrame()

	foreach ( ItemFlavor character in GetAllCharacters() )
	{
		EquipBaseEmoteForCharacter( player, character )
	}

	player.SetPersistentVar( "hasHadBaseStandingEmotesAutoEquipped", true )
}

void function EquipBaseEmoteForCharacter( entity player, ItemFlavor character )
{
	EHI playerEHI = ToEHI( player )
	array<int> possibleIndices
	array<LoadoutEntry> allEntries
	int slotToSet = 0

	LoadoutEntry firstEntry = Loadout_CharacterQuip( character, 0 )
	ItemFlavor baseEmote = firstEntry.defaultItemFlavor
	#if ASSERTS
	if ( CharacterClass_GetIsShippingCharacter( character ) )
		Assert( ItemFlavor_GetGRXMode( baseEmote ) == eItemFlavorGRXMode.NONE )
	#endif // #if ASSERTS

	if ( CharacterQuip_IsTheEmpty( baseEmote ) )
		return

	for ( int i = 0; i < MAX_QUIPS_EQUIPPED; i++ )
	{
		LoadoutEntry entry = Loadout_CharacterQuip( character, i )

		// TODO - R5DEV-350895: START - Loadouts Perf Improvements
		if ( GetCurrentPlaylistVarBool( "loadouts_performance_ops_v1", true ) )
		{
			int guid = LoadoutSlot_GetRawStorageContents( playerEHI, entry )
			if ( IsValidItemFlavorGUID( guid ) )
			{
				ItemFlavor quip = LoadoutSlot_GetItemFlavor( playerEHI, entry )
				if ( quip == baseEmote )
					return
			}
		} // END - Loadouts Perf Improvements
		else
		{
			ItemFlavor quip = LoadoutSlot_GetItemFlavor( playerEHI, entry )
			if ( quip == baseEmote )
				return
		}
	}

	for ( int i = 0; i < MAX_QUIPS_EQUIPPED; i++ )
	{
		LoadoutEntry entry = Loadout_CharacterQuip( character, i )

		// TODO - R5DEV-350895: START - Loadouts Perf Improvements
		if ( GetCurrentPlaylistVarBool( "loadouts_performance_ops_v1", true ) )
		{
			int guid = LoadoutSlot_GetRawStorageContents( playerEHI, entry )
			if ( IsValidItemFlavorGUID( guid ) == false )
			{
				SetItemFlavorLoadoutSlot( playerEHI, entry, baseEmote )
				return
			}
		}
		// END - Loadouts Perf Improvements

		ItemFlavor quip = LoadoutSlot_GetItemFlavor( playerEHI, entry )
		if ( CharacterQuip_IsTheEmpty( quip ) )
		{
			SetItemFlavorLoadoutSlot( playerEHI, entry, baseEmote )
			return
		}
	}

	int rarityBar = eRarityTier.COMMON
	while ( possibleIndices.len() < 1 && rarityBar < eRarityTier._COUNT)
	{
		for ( int i = 0; i < MAX_QUIPS_EQUIPPED; i++ )
		{
			LoadoutEntry entry = Loadout_CharacterQuip( character, i )
			ItemFlavor quip    = LoadoutSlot_GetItemFlavor( playerEHI, entry )

			if ( ItemFlavor_GetQuality( quip, eRarityTier.COMMON ) <= rarityBar )
			{
				SetItemFlavorLoadoutSlot( playerEHI, Loadout_CharacterQuip( character, i ), baseEmote )
				return
			}
		}

		rarityBar++
	}

	SetItemFlavorLoadoutSlot( playerEHI, Loadout_CharacterQuip( character, 0 ), baseEmote )
}
#endif // SERVER

#if CLIENT
void function OnPodiumCharacterModelSpawned( entity characterModel, ItemFlavor character, int eHandle )
{
	file.characterPodiumModelIsEmoting[ characterModel ] <- false

	if ( LocalClientEHI() == eHandle )
	{
		thread TryPromptPodiumScreenEmote( characterModel )
	}
}

bool function CanLocalClientPerformPodiumScreenEmote()
{
	entity localClientPlayer = GetLocalClientPlayer()

	if ( !IsValid( localClientPlayer ) )
		return false

	// Check used by TryPerformPodiumScreenEmote to prevent Shadows from emoting on the Podium in Shadow Royale.
	// They are not allowed to emote so the prompt shouldn't display either
	if ( !CanPlayerSpeak( localClientPlayer ) )
		return false

	if ( GetPlayerIsEmoting( localClientPlayer ) )
		return false

	EHI playerEHI = LocalClientEHI()
	ItemFlavor character = LoadoutSlot_GetItemFlavor( playerEHI, Loadout_Character() )

	if ( ItemFlavor_GetQuipArrayForCharacter( localClientPlayer, character, true ).len() == 0 && ItemFlavor_GetFavoredQuipArrayForCharacter( character, true ).len() == 0 )
		return false

	if ( IsEmoteEnabledForPodiumScreen() )
	{
		entity characterModel = GetPodiumScreenCharacterModelForEHI( playerEHI )

		if ( !IsValid( characterModel ) )
			return false

		if ( ! ( characterModel in file.characterPodiumModelIsEmoting ) )
		{
			return false
		}
		else if ( file.characterPodiumModelIsEmoting[ characterModel ] )
		{
			return false
		}
	}
	else
	{
		return false
	}

	return true
}

bool function IsEmoteEnabledForPodiumScreen()
{
	bool isEmoteEnabled = false

	if ( IsShowingVictorySequence() || ( IsShowingIntroPodiumSequence() && GetCurrentPlaylistVarBool( "podium_allow_intro_screen_emotes", false ) ) )
		isEmoteEnabled = true

	return isEmoteEnabled
}

void function TryPromptPodiumScreenEmote( entity characterModel )
{
	EndSignal( GetLocalClientPlayer(), "OnDestroy" )
	EndSignal( characterModel, "OnDestroy" )
	EndSignal( characterModel, SIGNAL_STARTING_EMOTE )

	if ( CanLocalClientPerformPodiumScreenEmote() )
	{
		RegisterConCommandTriggeredCallback( CLIENT_EMOTE_PROMPT_COMMAND, TryPerformPodiumScreenEmote )
		RuiSetBool( GetPodiumSequenceRui(), "emoteAvailable", true )

		OnThreadEnd(
			function() : ()
			{
				DeregisterConCommandTriggeredCallback( CLIENT_EMOTE_PROMPT_COMMAND, TryPerformPodiumScreenEmote )
			}
		)

		WaitForever()
	}
}

void function TryPerformPodiumScreenEmote( entity player )
{
	if ( player != GetLocalClientPlayer() )
		return

	int selectedIndex = -1

	EHI playerEHI        = LocalClientEHI()
	ItemFlavor character = LoadoutSlot_GetItemFlavor( playerEHI, Loadout_Character() )

	array<ItemFlavor> favoredEmotes = ItemFlavor_GetFavoredQuipArrayForCharacter( character, true )
	bool pickFromFavored = favoredEmotes.len() > 0

	array<ItemFlavor> options
	table<ItemFlavor, int> optionToIndex

	entity localPlayer = FromEHI( playerEHI )
	if ( IsValid( localPlayer ) && !CanPlayerSpeak( localPlayer ) )
		return

	entity spawnedCharacterModel = GetPodiumScreenCharacterModelForEHI( playerEHI )

	if ( !IsValid( spawnedCharacterModel ) )
		return

	if ( pickFromFavored )
	{
		for ( int i = 0; i < MAX_FAVORED_QUIPS; i++ )
		{
			LoadoutEntry entry = Loadout_FavoredQuip( character, i )
			ItemFlavor emote    = LoadoutSlot_GetItemFlavor( playerEHI, entry )
			if ( !CharacterQuip_IsTheEmpty( emote ) && ItemFlavor_GetType( emote ) == eItemType.character_emote )
			{
				options.append( emote )
				optionToIndex[ emote ] <- i
			}
		}
	}
	else
	{
		for ( int i = 0; i < MAX_QUIPS_EQUIPPED; i++ )
		{
			LoadoutEntry entry = Loadout_CharacterQuip( character, i )
			ItemFlavor emote    = LoadoutSlot_GetItemFlavor( playerEHI, entry )
			if ( !CharacterQuip_IsTheEmpty( emote ) && ItemFlavor_GetType( emote ) == eItemType.character_emote )
			{
				options.append( emote )
				optionToIndex[ emote ] <- i
			}
		}
	}

	string promptString = "#PING_SAY_CELEBRATE_EMOTE"

	if ( options.len() > 0 )
	{
		ItemFlavor flav = options.getrandom()

		entity emotePlayer = FromEHI( playerEHI )

		if ( !IsValid( emotePlayer ) )
			return

		selectedIndex = optionToIndex[ flav ]
	}

	if ( selectedIndex >= 0 )
	{
		if ( pickFromFavored )
		{
			PodiumScreenPerformFavoredEmoteByIndex( spawnedCharacterModel, selectedIndex, playerEHI )
		}
		else
		{
			PodiumScreenPerformEmoteByIndex( spawnedCharacterModel, selectedIndex, playerEHI )
		}
	}
}

void function PodiumScreenPerformEmoteByIndex( entity characterModel, int quipIndex, EHI playerEHI, bool sendCallback = true )
{
	ItemFlavor character = LoadoutSlot_GetItemFlavor( playerEHI, Loadout_Character() )
	ItemFlavor emote     = LoadoutSlot_WaitForItemFlavor( playerEHI, Loadout_CharacterQuip( character, quipIndex ) )

	thread PodiumScreenPerformEmote_Thread( characterModel, emote, playerEHI, sendCallback )
}

void function PodiumScreenPerformFavoredEmoteByIndex( entity characterModel, int quipIndex, EHI playerEHI, bool sendCallback = true )
{
	ItemFlavor character = LoadoutSlot_GetItemFlavor( playerEHI, Loadout_Character() )
	ItemFlavor emote     = LoadoutSlot_WaitForItemFlavor( playerEHI, Loadout_FavoredQuip( character, quipIndex ) )

	thread PodiumScreenPerformEmote_Thread( characterModel, emote, playerEHI, sendCallback )
}

void function PodiumScreenPerformEmoteByGUID( entity characterModel, int emoteGUID, EHI playerEHI, bool sendCallback = true )
{
	ItemFlavor emote = GetItemFlavorByGUID( emoteGUID )

	thread PodiumScreenPerformEmote_Thread( characterModel, emote, playerEHI, sendCallback )
}

void function PodiumScreenPerformEmote_Thread( entity characterModel, ItemFlavor emote, EHI playerEHI, bool sendCallback = true )
{
	Assert( IsNewThread(), "Must be threaded off" )

	entity mover = CreateClientsideScriptMover( $"mdl/dev/empty_model.rmdl", characterModel.GetOrigin(), characterModel.GetAngles() )
	mover.MakeSafeForUIScriptHack()
	characterModel.SetParent( mover )

	if ( sendCallback )
	{
		int emoteGUID = ItemFlavor_GetGUID( emote )
		Remote_ServerCallFunction( "ClientCallback_PlayerPerformPodiumScreenEmote", playerEHI, emoteGUID )
	}

	OnThreadEnd(
		function() : ( characterModel, playerEHI, mover )
		{
			if ( IsValid( characterModel ) )
				characterModel.ClearParent()
		}
	)

	file.characterPodiumModelIsEmoting[ characterModel ] <- true

	vector savedAngles = mover.GetAngles()

	// SPECIAL CASE
	if ( string(ItemFlavor_GetAsset( emote )) == CAUSTIC_SPECIAL_CASE_EMOTE_ASSET_PATH )
	{
		mover.SetAngles( mover.GetAngles() + <0,45,0> )
	}

	waitthread ModelPerformEmote( characterModel, emote, mover, true, false, playerEHI )

	file.characterPodiumModelIsEmoting[ characterModel ] <- false

	if ( GetBugReproNum() == 451 )
		thread TryPromptPodiumScreenEmote( characterModel )

	mover.SetAngles( savedAngles )
	thread VictoryScreenEmoteCleanup( characterModel, playerEHI, mover )
}

void function VictoryScreenEmoteCleanup( entity characterModel, EHI playerEHI, entity mover )
{
	if ( !IsValid( characterModel ) )
		return

	EndSignal( characterModel, "OnDestroy" )

	thread FlashMenuModel( characterModel, eMenuModelFlashType.VICTORY_SEQUENCE, MENU_MODELS_DEFAULT_HIGHLIGHT_COLOR / 255 )

	characterModel.SetParent( mover )

	string victoryAnim = GetVictorySquadFormationActivity( characterModel, playerEHI )
	waitthread PlayAnim( characterModel, victoryAnim, mover )

	characterModel.ClearParent()
}
#endif // CLIENT

#if SERVER
void function ClientCallback_PlayerPerformPodiumScreenEmote( entity player, int performingPlayerEHI, int emoteGUID )
{
	if ( !IsValidItemFlavorGUID( emoteGUID ) )
	{
		Warning( "PlayerPerformPodiumScreenEmote: emoteGUID is not a valid itemflavor" )
		return
	}

	entity performingPlayerEnt = FromEHI( EncodedEHandleToEHI( performingPlayerEHI ) )

	PIN_EmoteUse ( player, ItemFlavor_GetHumanReadableRefForPIN_Slow( GetItemFlavorByGUID( emoteGUID ) ), player.GetOrigin(), EMOTE_PIN_ACTION_BEGIN )

	foreach ( entity otherPlayer in GetPlayerArrayIncludingSpectators() )
	{
		if ( otherPlayer == performingPlayerEnt )
			continue

		Remote_CallFunction_NonReplay( otherPlayer, "ServerCallback_PlayerPerformPodiumScreenEmote", performingPlayerEHI, emoteGUID )
	}
}
#endif // SERVER

#if CLIENT
void function ServerCallback_PlayerPerformPodiumScreenEmote( int performingPlayerEHI, int emoteGUID )
{
	entity characterModel = GetPodiumScreenCharacterModelForEHI( performingPlayerEHI )

	if ( !IsValid( characterModel ) )
		return

	if ( ! ( characterModel in file.characterPodiumModelIsEmoting ) )
		return

	if ( file.characterPodiumModelIsEmoting[ characterModel ] )
		return

	thread PodiumScreenPerformEmoteByGUID( characterModel, emoteGUID, performingPlayerEHI, false )
}
#endif // CLIENT

#if CLIENT
void function PodiumPromptFlourish()
{
	EHI playerEHI = LocalClientEHI()
	entity player = GetLocalClientPlayer()
	entity characterModel = GetPodiumScreenCharacterModelForEHI( playerEHI )

	if ( !player || !characterModel )
		return

	EndSignal( characterModel, SIGNAL_END_EMOTE_PERFORMANCE )
	EndSignal( characterModel, SIGNAL_END_EMOTE_ENDED )
	EndSignal( characterModel, SIGNAL_EMOTE_FLOURISH )
	EndSignal( characterModel, "OnDestroy" )

	OnThreadEnd(
		function() : ( player )
		{
			DeregisterConCommandTriggeredCallback( CLIENT_EMOTE_PROMPT_COMMAND, RequestPodiumFlourish )
			ToggleFlourishPrompt( player, false )
		}
	)

	ToggleFlourishPrompt( player, true )
	RegisterConCommandTriggeredCallback( CLIENT_EMOTE_PROMPT_COMMAND, RequestPodiumFlourish )

	WaitForever()
}

void function RequestPodiumFlourish( entity player )
{
	if ( player != GetLocalClientPlayer() )
		return

	EHI playerEHI = LocalClientEHI()
	entity spawnedCharacterModel = GetPodiumScreenCharacterModelForEHI( playerEHI )

	//Signal local anim
	if ( spawnedCharacterModel )
		Signal( spawnedCharacterModel, SIGNAL_EMOTE_FLOURISH )

	//Signal other clients
	Remote_ServerCallFunction( "ClientCallback_PlayerPerformPodiumScreenFlourish", playerEHI )
}
#endif // CLIENT

#if SERVER
void function ClientCallback_PlayerPerformPodiumScreenFlourish( entity callingPlayer, int performingPlayerEHI )
{
	entity performingPlayerEnt = FromEHI( EncodedEHandleToEHI( performingPlayerEHI ) )

	if ( !performingPlayerEnt )
		return

	foreach ( entity otherPlayer in GetPlayerArrayIncludingSpectators() )
	{
		if ( otherPlayer == performingPlayerEnt )
			continue

		Remote_CallFunction_NonReplay( otherPlayer, "ServerCallback_PlayerPerformPodiumScreenFlourish", performingPlayerEHI )
	}
}
#endif // SERVER

#if CLIENT
void function ServerCallback_PlayerPerformPodiumScreenFlourish( int performingPlayerEHI )
{
	entity characterModel = GetPodiumScreenCharacterModelForEHI( performingPlayerEHI )

	if ( !IsValid( characterModel ) )
		return

	if ( ! ( characterModel in file.characterPodiumModelIsEmoting ) )
		return

	if ( !file.characterPodiumModelIsEmoting[ characterModel ] )
		return

	Signal( characterModel, SIGNAL_EMOTE_FLOURISH )
}
#endif // CLIENT

#if CLIENT
string function GetOptionTextForEmote( ItemFlavor flavor )
{
	return Localize( ItemFlavor_GetShortName( flavor ) )
}

void function RequestCharacterEmote( entity player, int flavorGUID )
{
	Assert ( file.emotesInitialized )
	Remote_ServerCallFunction( CMD_REQUEST_EMOTE_START, flavorGUID )
}
#endif // CLIENT

bool function AreEmotesEnabled()
{
	return GetCurrentPlaylistVarBool( "emotes_enable", true )
}

#if CLIENT
void function Cl_OnPlayerEmoteStateChanged( entity player, bool playerIsEmoting )
{
	if ( player != GetLocalViewPlayer() )
		return

	bool antiPeekEnabled = true

	#if DEVELOPER
		if ( GetBugReproNum() == 1234 )
		{
			antiPeekEnabled = false
		}
	#endif

	// player.Set3PWeaponClonesVisibility( !playerIsEmoting ) // not in S3

	if ( !playerIsEmoting )
	{
		Signal( player, SIGNAL_CL_END_EMOTE_NOW )			// Safety
		thread EndAntiPeekAfterDelay( player )
	}
	else
	{
		vector initialEyeAngles = player.EyeAngles()

		if ( antiPeekEnabled )
		{
			// StartAntiPeekTesting not in S3
			//player.Signal( "EndAntiPeekAfterDelay" )
			//player.StartAntiPeekTesting()
			//thread AntiPeekHintThink( player )
		}
	}
}

void function ToggleFlourishPrompt( entity player, bool show )
{
	if ( player != GetLocalViewPlayer() )
		return

	if ( show )
	{
		AddPlayerHint( 9999.0, 0.25, $"", "#FLOURISH_EMOTE_HINT" )
	}
	else
	{
		HidePlayerHint( "#FLOURISH_EMOTE_HINT" )
	}
}

void function EndAntiPeekAfterDelay( entity player )
{
	player.Signal( "EndAntiPeekAfterDelay" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "EndAntiPeekAfterDelay" )

	OnThreadEnd(
		function () : ( player )
		{
			if ( IsValid( player ) )
			{
				// player.EndAntiPeekTesting() // not in S3
			}
		}
	)

	wait CAM_OUTRO_EASE_TIME
}

void function AntiPeekHintThink( entity player )
{
	Signal( player, SIGNAL_CL_END_EMOTE_NOW )
	EndSignal( player, SIGNAL_CL_END_EMOTE_NOW )

	var rui = CreateFullscreenRui( $"ui/anti_peek_hint.rpak", 100 )

	OnThreadEnd(
		function() : ( rui )
		{
			foreach ( p in GetPlayerArray() )
			{
				p.EnableDraw()
			}

			RuiDestroy( rui )
		}
	)

	player.EndSignal( "OnDeath" )
	while ( IsAlive( player ) )
	{
		RuiSetBool( rui, "isVisible", GetGameState() == eGameState.Playing )
		wait 0.1
	}
}

bool function ShouldCullPlayer( entity localPlayer, entity p, vector initialEyeAngles )
{
	if ( p.p.nextTraceCheckTime > Time() )
		return false

	if ( !IsEnemyTeam( localPlayer.GetTeam(), p.GetTeam() ) )
		return false

	if ( !IsInCameraFOV( localPlayer, p ) )
		return false

	float distToPlayer = Distance2D( localPlayer.GetOrigin(), p.GetOrigin() )
	if ( distToPlayer < 400 ) // too close, chalk it up to "i can sense him"
		return false

	if ( distToPlayer > 5000 ) // too far, don't bother
		return false

	array<string> bonesToTry = [
		"CHESTFOCUS",
		"HEADFOCUS",
		"R_FOREARM",
		"L_FOREARM",
		"ORIGIN"
	]

	foreach ( bone in bonesToTry )
	{
		int attachIndex = p.LookupAttachment( bone )
		TraceResults result = TraceLine( localPlayer.EyePosition(), p.GetAttachmentOrigin( attachIndex ), GetPlayerArray(), TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )

		if ( result.fraction >= 0.95 )
		{
			//DebugDrawLine( localPlayer.EyePosition(), p.GetAttachmentOrigin( attachIndex ), COLOR_RED, true, 0.05 )
			p.p.nextTraceCheckTime = Time() + 3.0
			return false
		}
		else
		{
			//DebugDrawLine( localPlayer.EyePosition(), result.endPos, COLOR_GREEN, true, 0.05 )
		}
	}

	return true
}

bool function IsInCameraFOV( entity player, entity ent )
{
	float minDot = deg_cos( DEFAULT_FOV )

	// On screen?
	float dot = DotProduct( Normalize( ent.GetWorldSpaceCenter() - player.CameraPosition() ), AnglesToForward( player.CameraAngles() ) )
	if ( dot < minDot )
		return false

	return true
}

bool function IsInFrontLockedFOV( entity player, entity ent, vector initialEyeAngles )
{
	float minDot = deg_cos( DEFAULT_FOV )

	float dot = DotProduct( Normalize( ent.GetWorldSpaceCenter() - player.GetOrigin() ), AnglesToForward( initialEyeAngles ) )
	if ( dot < minDot )
		return false

	return true
}
#endif // CLIENT

// ----------------------------------------------------------------------------------------------------------
//
// ██████╗ ███████╗██████╗ ███████╗ ██████╗ ██████╗ ███╗   ███╗    ███████╗███╗   ███╗ ██████╗ ████████╗███████╗
// ██╔══██╗██╔════╝██╔══██╗██╔════╝██╔═══██╗██╔══██╗████╗ ████║    ██╔════╝████╗ ████║██╔═══██╗╚══██╔══╝██╔════╝
// ██████╔╝█████╗  ██████╔╝█████╗  ██║   ██║██████╔╝██╔████╔██║    █████╗  ██╔████╔██║██║   ██║   ██║   █████╗
// ██╔═══╝ ██╔══╝  ██╔══██╗██╔══╝  ██║   ██║██╔══██╗██║╚██╔╝██║    ██╔══╝  ██║╚██╔╝██║██║   ██║   ██║   ██╔══╝
// ██║     ███████╗██║  ██║██║     ╚██████╔╝██║  ██║██║ ╚═╝ ██║    ███████╗██║ ╚═╝ ██║╚██████╔╝   ██║   ███████╗
// ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═╝╚═╝     ╚═╝    ╚══════╝╚═╝     ╚═╝ ╚═════╝    ╚═╝   ╚══════╝
//
// ----------------------------------------------------------------------------------------------------------


bool function GetPlayerGroundEmoteEnabled( entity player )
{
	return player.GetPlayerNetBool( "canGroundEmote" )
}

bool function GetPlayerIsEmoting( entity player )
{
	return player.GetPlayerNetBool( "isEmoting" )
}

bool function GetPlayerIs3pEmoting( entity player )
{
	return player.GetPlayerNetBool( "isEmoting" )
}

ItemFlavor function GetEmotingPlayerEmote( entity player )
{
	return file.emotingPlayers[ player ]
}

int function CheckPlayerCanEmote( entity player )
{
	if ( !GetPlayerGroundEmoteEnabled( player ) )
		return eCanEmoteCheckReults.FAIL_GENERIC
	if ( player.Anim_IsActive() )
		return eCanEmoteCheckReults.FAIL_GENERIC
	if ( player.ContextAction_IsBusy() )
		return eCanEmoteCheckReults.FAIL_GENERIC
	if ( player.ContextAction_IsActive() )
		return eCanEmoteCheckReults.FAIL_GENERIC
	if ( !player.IsOnGround() )
		return eCanEmoteCheckReults.FAIL_GENERIC
	if ( player.IsTraversing() )
		return eCanEmoteCheckReults.FAIL_GENERIC
	if ( player.IsMantling() )
		return eCanEmoteCheckReults.FAIL_GENERIC
	if ( player.IsWallRunning() )
		return eCanEmoteCheckReults.FAIL_GENERIC
	if ( player.IsWallHanging() )
		return eCanEmoteCheckReults.FAIL_GENERIC
	if ( player.IsPhaseShifted() )
		return eCanEmoteCheckReults.FAIL_GENERIC
	if ( player.Player_IsSkywardFollowing() )
		return eCanEmoteCheckReults.FAIL_GENERIC
	// if ( player.Player_IsSkywardLaunching() ) // not in S3
		return eCanEmoteCheckReults.FAIL_GENERIC
	if ( StatusEffect_HasSeverity( player, eStatusEffect.placing_phase_tunnel ) )
		return eCanEmoteCheckReults.FAIL_GENERIC
	if ( player.GetParent() != null )
		return eCanEmoteCheckReults.FAIL_GENERIC
	if ( player.GetPlayerNetBool( "isHealing" ) )
		return eCanEmoteCheckReults.FAIL_GENERIC
	if ( player.IsUsingOffhandWeapon( eActiveInventorySlot.mainHand ) )
	{
		entity offhandWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
		var offhandAllowsInteract = offhandWeapon.GetWeaponInfoFileKeyField( "offhand_allow_player_interact" )
		if ( !offhandAllowsInteract || offhandAllowsInteract <= 0 )
			return eCanEmoteCheckReults.FAIL_GENERIC
	}
	if ( player.IsUsingOffhandWeapon( eActiveInventorySlot.altHand ) )
		return eCanEmoteCheckReults.FAIL_GENERIC
	//if ( IsPlayerMovingTooQuicklyForEmote( player ) )
	//	return false
	if ( player.PlayerMelee_GetState() != PLAYER_MELEE_STATE_NONE )
		return eCanEmoteCheckReults.FAIL_GENERIC
	#if SERVER
	if ( AreWeaponsLockedOrDisabled( player ) )
		return eCanEmoteCheckReults.FAIL_GENERIC
	#elseif CLIENT
	if ( IsValid( player.GetPlayerNetEnt( "Translocation_ActiveProjectile" ) ) )
		return eCanEmoteCheckReults.FAIL_GENERIC
	#endif
	// IsSlipping() not in S3
	//if ( player.IsSlipping() )
	//	return eCanEmoteCheckReults.FAIL_GENERIC
	if ( player.IsCrouched() && !player.CanStand() )
		return eCanEmoteCheckReults.FAIL_TOO_CLOSE_TO_WALL
	int playerMatchState = PlayerMatchState_GetFor( player )
	if ( playerMatchState < ePlayerMatchState.NORMAL && playerMatchState != ePlayerMatchState.STAGING_AREA )
		return eCanEmoteCheckReults.FAIL_GENERIC
	if ( IsPlayerTooCloseToWall( player ) )
	{
		return eCanEmoteCheckReults.FAIL_TOO_CLOSE_TO_WALL
	}

	return eCanEmoteCheckReults.SUCCESS
}

//array<string> function CharacterEmote_GetCameraAttachmentList( ItemFlavor flavor )
//{
//	Assert( ItemFlavor_GetType( flavor ) == eItemType.character_emote )
//
//	array<string> attachmentList = []
//
//	var flavorBlock = ItemFlavor_GetSettingsBlock( flavor )
//	var cameraAttachmentBlockArray = GetSettingsBlockArray( flavorBlock, "cameraAttachmentList" )
//	for( int i = 0; i < GetSettingsArraySize( cameraAttachmentBlockArray ); i++ )
//	{
//		var cameraAttachmentBlock = GetSettingsArrayElem( cameraAttachmentBlockArray, i )
//		attachmentList.append( GetSettingsBlockString( cameraAttachmentBlock, "attachmentIDString" ) )
//	}
//
//	return attachmentList
//}

bool function IsPlayerTooCloseToWall( entity player )
{
	TraceResults result = TraceHull( player.GetOrigin() + CLEARANCE_HULL_ORIGIN_OFFSET, player.GetOrigin() + CLEARANCE_HULL_ORIGIN_OFFSET, CLEARANCE_HULL_MINS, CLEARANCE_HULL_MAXS, GetPlayerArray_AliveConnected(), TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )

	if ( IsValid( result.hitEnt ) )
		return true

	return false
}

#if CLIENT
void function ModelPerformEmote( entity model, ItemFlavor item, entity mover, bool oneShot = true, bool autoFlourish = false, EHI modelPlayerEHI = EHI_null )
{
	EndSignal( model, "OnDestroy" )
	EndSignal( mover, "OnDestroy" )

	Signal( model, SIGNAL_STARTING_EMOTE )
	EndSignal( model, SIGNAL_STARTING_EMOTE )

	OnThreadEnd(
		function() : ( model )
		{
			if ( IsValid( model ) && IsEmoteEnabledForPodiumScreen() )
			{
				Signal( model, SIGNAL_END_EMOTE_ENDED )
			}
		}
	)

	int flashType = IsEmoteEnabledForPodiumScreen() ? eMenuModelFlashType.VICTORY_SEQUENCE : eMenuModelFlashType.DEFAULT
	vector flashColor = MENU_MODELS_DEFAULT_HIGHLIGHT_COLOR / 255
	thread FlashMenuModel( model, flashType, flashColor )

	if ( IsEmoteEnabledForPodiumScreen() && !CanLocalClientPerformPodiumScreenEmote() )
		RuiSetBool( GetPodiumSequenceRui(), "emoteAvailable", false )

	EHI lcPlayer 			= LocalClientEHI()
	bool isLocalPlayerModel = ( GetPodiumScreenCharacterModelForEHI( lcPlayer ) == model )
	ItemFlavor character    = isLocalPlayerModel || modelPlayerEHI == EHI_null ? LoadoutSlot_GetItemFlavor( lcPlayer, Loadout_Character() ) : LoadoutSlot_GetItemFlavor( modelPlayerEHI, Loadout_Character() )

	string anim3p     = CharacterQuip_GetAnim3p( item, character )
	string loopAnim3p = CharacterQuip_GetAnimLoop3p( item )

	Assert( model.LookupSequence( anim3p ) != -1, "Victory sequence " + anim3p + "doesn't exist on model " + model.GetModelName() +
	"Likely an issue with grabbing the wrong sequence from CharacterQuip_GetAnim3p" )

	bool usesLoop = loopAnim3p != ""

	waitthread PlayAnim( model, anim3p, mover )

	float BASE_WAIT = 0.2
	float LOOP_WAIT = 0.3

	wait BASE_WAIT // weird random wait to smooth out the transition, not sure why this is needed

	if ( usesLoop )
	{
		float loopTime = 0

		loopTime = DEV_CharacterEmote_GetCustomAnimSequenceTime( loopAnim3p )
		if ( loopTime < 0 )
			loopTime = model.GetSequenceDuration( loopAnim3p )

		while ( true )
		{
			string flourishSeq = ""
			var flourishBlock = CharacterQuip_SelectWeightedAnimFlourish3p( item )

			if ( flourishBlock )
				flourishSeq = GetSettingsBlockString( flourishBlock, "sequence" )

			if ( flourishSeq == "" )
			{
				//No flourish - just loop anim and end thread
				waitthread PlayAnim( model, loopAnim3p, mover )
				break
			}

			float flourishTime = DEV_CharacterEmote_GetCustomAnimSequenceTime( flourishSeq )
			if ( flourishTime < 0 )
				flourishTime = model.GetSequenceDuration( flourishSeq )

			thread PlayAnim( model, loopAnim3p, mover )

			if ( autoFlourish )
			{
				wait loopTime
			}
			else
			{
				if ( isLocalPlayerModel )
					thread PodiumPromptFlourish()

				WaitSignal( model, SIGNAL_EMOTE_FLOURISH )
			}

			thread PlayAnim( model, flourishSeq, mover )
			wait flourishTime

			if ( !autoFlourish && GetSettingsBlockBool( flourishBlock, "flourishEndsLoop" ) )
				break
		}
	}
	else if ( !oneShot )
	{
		wait LOOP_WAIT - BASE_WAIT

		while ( true )
		{
			waitthread PlayAnim( model, anim3p, mover )
			wait LOOP_WAIT
		}
	}
}
#endif // CLIENT


#if SERVER
void function AddStopEmoteCallbacks( entity player )
{
	for( int i = 0; i < STOP_EMOTE_INPUTS.len(); i++ )
	{
		AddButtonPressedPlayerInputCallback( player, STOP_EMOTE_INPUTS[ i ], Emote_StopEmoteNow )
	}

	AddEntityCallback_OnPostDamaged( player, OnEmotingPlayerDamaged )
	AddEntityCallback_OnPostShieldDamage( player, OnEmotingPlayerShieldDamaged )
}

void function RemoveStopEmoteCallbacks( entity player )
{
	for( int i = 0; i < STOP_EMOTE_INPUTS.len(); i++ )
	{
		RemoveButtonPressedPlayerInputCallback( player, STOP_EMOTE_INPUTS[ i ], Emote_StopEmoteNow )
	}

	RemoveEntityCallback_OnPostDamaged( player, OnEmotingPlayerDamaged )
	RemoveEntityCallback_OnPostShieldDamage( player, OnEmotingPlayerShieldDamaged )
}

void function SetPlayerCanGroundEmote( entity player, bool canEmote )
{
	player.SetPlayerNetBool( "canGroundEmote", canEmote )
}

//string function CharacterEmote_GetPrototypeSound( ItemFlavor flavor )
//{
//	Assert( ItemFlavor_GetType( flavor ) == eItemType.character_emote )
//
//	return GetGlobalSettingsString( ItemFlavor_GetAsset( flavor ), "prototypeSound" )
//}


void function SetPlayerEmoting( entity player, ItemFlavor flavor )
{
	Assert( IsValid( player ), "Warning, attempted to set invalid player to emoting!" )
	Assert( IsAlive( player ), "Warning, tried to set dead player to emoting!" )
	Assert( !(player in file.emotingPlayers), "Attempted to set already emoting player!" )

	file.emotingPlayers[ player ] <- flavor
	player.SetPlayerNetBool( "isEmoting", true )
	AddStopEmoteCallbacks( player )
}

void function SetPlayerStopEmoting( entity player )
{
	Assert( IsValid( player ), "Warning, attempted to set invalid player to emoting!" )
	Assert( player in file.emotingPlayers, "Attempted to remove non-emoting player!" )

	delete file.emotingPlayers[ player ]
	player.SetPlayerNetBool( "isEmoting", false )
	RemoveStopEmoteCallbacks( player )
}

void function ClientCallback_RequestEmote( entity player, int flavorGUID )
{
	if ( !AreEmotesEnabled() )
		return

	if ( !IsValid( player ) )
		return

	if ( !IsValidItemFlavorGUID( flavorGUID ) )
		return

	ItemFlavor flavor = GetItemFlavorByGUID( flavorGUID )
	RequestPlayerPerformEmote( player, flavor )
}

void function ClientCallback_RequestStopEmote( entity player )
{
	if ( !IsValid( player ) )
		return

	Emote_StopEmoteNow( player )
}

void function Emote_StopEmoteNow( entity player )
{
	if ( !AreEmotesEnabled() )
		return

	Signal( player, SIGNAL_END_EMOTE_PERFORMANCE )
}

void function CharacterEmote_OnEnterGamestate_PickLoadout()
{
	StopEmoteForAllPlayersNow()
}

void function CharacterEmote_OnEnterGameState_WinnerDetermined()
{
	foreach ( entity player in GetPlayerArray_AliveConnected() )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_PromptTaunt" )
	}
}

void function CharacterEmote_OnEnterGameState_Resolution()
{
	StopEmoteForAllPlayersNow()
}

void function StopEmoteForAllPlayersNow()
{
	array<entity> allPlayers = GetPlayerArray_Alive()
	foreach( player in allPlayers )
	{
		if ( !IsValid( player ) )
			continue

		if ( !GetPlayerIsEmoting( player ) )
			continue

		Emote_StopEmoteNow( player )
	}
}

void function RequestPlayerPerformEmote( entity player, ItemFlavor flavor )
{
	if ( CheckPlayerCanEmote( player ) != eCanEmoteCheckReults.SUCCESS )
		return

	if ( GetPlayerIsEmoting( player ) )
	{
		ItemFlavor currentEmote = GetEmotingPlayerEmote( player )
		if ( currentEmote == flavor )
			return    // keep going

		Emote_StopEmoteNow( player )
		return
	}

	PIN_EmoteUse( player, ItemFlavor_GetHumanReadableRefForPIN_Slow( flavor ), player.GetOrigin(), EMOTE_PIN_ACTION_BEGIN )

	if ( GetGameState() < eGameState.Resolution )
	{
		thread PlayerPerformEmote( player, flavor )
	}
	else
	{
		foreach ( entity client in GetPlayerArray() )
		{
			Remote_CallFunction_NonReplay( client, "ServerCallback_PlayerPerformPodiumScreenEmote", EHIToEncodedEHandle( ToEHI( player ) ), ItemFlavor_GetGUID( flavor ) )
		}
	}
}

void function PlayerPerformEmote( entity player, ItemFlavor flavor )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "OnSyncedMelee" )
	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "StartHeal" )
	EndSignal( player, SIGNAL_END_EMOTE_PERFORMANCE )

	SetPlayerEmoting( player, flavor )
	Signal( player, SIGNAL_STARTING_EMOTE )
	HolsterAndDisableWeapons( player )
	int forceStandHandle = player.PushForcedStance( FORCE_STANCE_STAND )

	bool wasAlreadyInShoulderMode = IsValid( player.GetTrackEntity() )

	OnThreadEnd(
		function() : ( player, wasAlreadyInShoulderMode, forceStandHandle ) //, emote3pSound )
		{
			if ( IsValid( player ) )
			{
				player.RemoveForcedStance( forceStandHandle )

				if ( GetPlayerIsEmoting( player ) )
				{
					player.Anim_Stop()

					// S3: Track entity camera methods not available
					//if ( !wasAlreadyInShoulderMode )
					//{
					//	if ( player.Player_IsSkywardLaunching() )
					//	{
					//		player.SetTrackEntityOffsetRight( 0 )
					//		player.SetTrackEntityBlendInTimes( 1.0, 0.0, 0.0 )
					//		player.SetTrackEntityBlendOutTime( 1.0 )
					//		player.SetTrackEntitySpringViewToCenterRate( 0 )
					//	}
					//	else
					//	{
					//		player.ClearTrackEntitySettings()
					//	}
					//}

					DeployAndEnableWeaponsWithSlowDeploy( player, CAM_OUTRO_EASE_TIME )
					MovementEnable( player )
					// player.ContextAction_ClearEmoting() // not in S3
					//thread Delayed_DeployAndEnableWeapons( player, 1.0 )

					SetPlayerStopEmoting( player )
					Signal( player, SIGNAL_END_EMOTE_ENDED )

					if( IsBallisticUltActive( player ) )
					{
						int backpackChargeParam = player.LookupPoseParameterIndex( "characterScriptParam" )
						if ( player.GetPoseParameter( backpackChargeParam ) == 0 )
							player.SetPoseParameter( backpackChargeParam, 1.0 )
					}
				}
			}
		}
	)

	// Listens to input, ends emote if player moves
	thread WatchPlayerEmoteForInterrupt( player )

	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
	Assert( CharacterQuip_GetAnim3p( flavor, character ) != "", "Warning! Character emote has no 3p animation!" )
	string anim3p = CharacterQuip_GetAnim3p( flavor, character )
	string loopAnim3p = CharacterQuip_GetAnimLoop3p( flavor )

	float emoteTime = DEV_CharacterEmote_GetCustomAnimSequenceTime( anim3p )
	if ( emoteTime < 0 )
		emoteTime = player.GetSequenceDuration( anim3p )

	float seqTime = emoteTime
	float startTime = Time()

	vector eyeAngles = player.EyeAngles()
	player.SnapFeetToEyes()
	player.SnapEyeAngles( eyeAngles )
	// player.ContextAction_SetEmoting() // not in S3
	vector viewAngles = player.EyeAngles()
	player.Anim_PlayWithRefPoint( anim3p, player.GetOrigin(), viewAngles, 2 )
	player.Anim_EnablePlanting()
	player.Anim_EnableCollision()
	MovementDisable( player )

	const float PITCH = 50.0
	const float YAW = 180.0

	const float MIN_PLAYER_FOV = 70
	const float MAX_PLAYER_FOV = 110
	const float CAM_FOLLOW_DISTANCE_AT_MIN_FOV = 120
	const float CAM_FOLLOW_DISTANCE_AT_MAX_FOV = 70

	float cameraHeightOffset = CharacterQuip_GetCameraHeightOffset( flavor )
	float trackDist = GraphCapped( DEFAULT_FOV, MIN_PLAYER_FOV, MAX_PLAYER_FOV, CAM_FOLLOW_DISTANCE_AT_MIN_FOV, CAM_FOLLOW_DISTANCE_AT_MAX_FOV ) // GetDefaultFOV() not in S3

	if ( !wasAlreadyInShoulderMode )
	{
		player.SetTrackEntityDistanceMode( "scriptOffset" )
		player.SetTrackEntityShouldViewAnglesFollowTrackedEntity( true )
		// player.SetTrackEntityPitchLookMode( "orbit" ) // not in S3
		// player.SetTrackEntityYawLookMode( "orbit" ) // not in S3
		// player.SetTrackEntityMinYaw( -YAW ) // not in S3
		// player.SetTrackEntityMaxYaw( YAW ) // not in S3
		// player.SetTrackEntityMinPitch( -PITCH ) // not in S3
		// player.SetTrackEntityMaxPitch( PITCH ) // not in S3
		// player.SetTrackEntityOffsetDistance( trackDist ) // not in S3
		// player.SetTrackEntityOffsetHeight( cameraHeightOffset + CAM_BASE_OFFSET_HEIGHT ) // not in S3
		// player.SetTrackEntityOffsetRight( 12.0 ) // not in S3
		// player.SetTrackEntityBlendInTimes( 0.2,0.0,0.0 ) // not in S3
		// player.SetTrackEntityBlendOutTime( CAM_OUTRO_EASE_TIME ) // not in S3
		// player.SetTrackEntity( player ) // not in S3
	}

	if ( loopAnim3p == "" )
		thread HACK_ForceEmoteNoLoop( player, emoteTime, flavor, startTime )
	else
	{
		thread EmoteTransitionToLoop( player, flavor, seqTime, viewAngles )
	}

	if( IsBallisticUltActive( player ) )
	{
		int backpackChargeParam = player.LookupPoseParameterIndex( "characterScriptParam" )
		if ( player.GetPoseParameter( backpackChargeParam ) > 0 && anim3p == "ballistic_ground_emote_violin" )
			player.SetPoseParameter( backpackChargeParam, 0.0 )
	}

	WaitSignal( player, SIGNAL_END_EMOTE_PERFORMANCE )
	// player.SetTrackEntitySpringViewToCenterRate( 1.0 ) // not in S3
}

void function Delayed_DeployAndEnableWeapons( entity player, float delay )
{
	player.EndSignal("OnDeath")
	player.EndSignal( SIGNAL_STARTING_EMOTE )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{
				MovementEnable( player )
				DeployAndEnableWeapons( player )
			}
		}
	)

	wait delay
}

// Search for and return any players the emoting player is looking at ( called when player starts emote )
entity function CharacterEmote_GetTextChatTarget( entity player )
{
	const float CAN_SEE_FOV = 30.0

	// All players in direction player is roughly looking
	array<entity> playersInViewConeNoTrace
	array<entity> allPlayers = GetPlayerArray()
	foreach( p in allPlayers )
	{
		if ( !IsAlive( p ) || !IsValid( p ) || ( p == player ) )
			continue

		if ( PlayerCanSee( player, p, false, CAN_SEE_FOV ) )
			playersInViewConeNoTrace.append( p )
	}

	// All players that player can actually see
	array<entity> playersInViewConeWithTrace
	foreach( p in playersInViewConeNoTrace )
	{
		if ( PlayerCanSee( player, p, true, CAN_SEE_FOV ) )
			playersInViewConeWithTrace.append( p )
	}

	// TODO: Refactor to balance what's closest to player view angle + closest in world space.. code solution probably best.
	// If multiple options that player can see, pick closest (TEMP)
	int numViablePlayers = playersInViewConeWithTrace.len()
	if ( numViablePlayers > 0 )
	{
		if ( numViablePlayers == 1 )
		{
			return playersInViewConeWithTrace[ 0 ]
		}
		else
		{
			float closestDistSq = (999999.0 * 999999.0)
			int closestIdx      = -1
			for ( int idx = 0; idx < numViablePlayers; idx++ )
			{
				float distSq = LengthSqr( playersInViewConeWithTrace[ idx ].GetWorldSpaceCenter() - player.EyePosition() )
				if ( distSq < closestDistSq )
				{
					closestDistSq = distSq
					closestIdx = idx
				}
			}

			if ( closestIdx >= 0 )
				return playersInViewConeWithTrace[ closestIdx ]
		}
	}

	return null
}

void function EmoteTransitionToLoop( entity player, ItemFlavor flavor, float startAnimTime, vector viewAngles )
{
	EndSignal( player, SIGNAL_END_EMOTE_PERFORMANCE )
	EndSignal( player, SIGNAL_END_EMOTE_ENDED )
	EndSignal( player, "OnDestroy" )

	wait startAnimTime

	string loopSeq = CharacterQuip_GetAnimLoop3p( flavor )

	while ( true )
	{
		//Loop anim
		player.Anim_PlayWithRefPoint( loopSeq, player.GetOrigin(), viewAngles, 2 )
		player.Anim_EnablePlanting()
		player.Anim_EnableCollision()

		string flourishSeq = ""

		var flourishBlock = CharacterQuip_SelectWeightedAnimFlourish3p( flavor )

		if ( flourishBlock )
			flourishSeq = GetSettingsBlockString( flourishBlock, "sequence" )

		if ( flourishSeq == "" )
			break;

		float flourishTime = DEV_CharacterEmote_GetCustomAnimSequenceTime( flourishSeq )
		if ( flourishTime < 0 )
			flourishTime = player.GetSequenceDuration( flourishSeq )

		thread PromptFlourish( player, flourishTime )

		WaitSignal( player, SIGNAL_EMOTE_FLOURISH )

		player.Anim_PlayWithRefPoint( flourishSeq, player.GetOrigin(), viewAngles, 2 )
		player.Anim_EnablePlanting()
		player.Anim_EnableCollision()

		wait flourishTime

		if ( GetSettingsBlockBool( flourishBlock, "flourishEndsLoop" ) )
			Emote_StopEmoteNow( player )
	}
}

void function PromptFlourish( entity player, float flourishTime )
{
	EndSignal( player, SIGNAL_END_EMOTE_PERFORMANCE )//command
	EndSignal( player, SIGNAL_END_EMOTE_ENDED )//event
	EndSignal( player, SIGNAL_EMOTE_FLOURISH )
	EndSignal( player, "OnDestroy" )

	OnThreadEnd(
		function() : ( player, flourishTime )
		{
			RemoveButtonPressedPlayerInputCallback( player, IN_EMOTE_FLOURISH, PerformFlourish )

			//Only re-register if we haven't already ended the emote
			if ( player.GetPlayerNetBool( "isEmoting" ) )
				AddButtonPressedPlayerInputCallback( player, IN_EMOTE_FLOURISH, Emote_StopEmoteNow )

			player.SetPlayerNetBool( "emoteFlourishAvailable", false )
		}
	)

	player.SetPlayerNetBool( "emoteFlourishAvailable", true )

	RemoveButtonPressedPlayerInputCallback( player, IN_EMOTE_FLOURISH, Emote_StopEmoteNow )
	AddButtonPressedPlayerInputCallback( player, IN_EMOTE_FLOURISH, PerformFlourish )

	WaitForever()
}

void function PerformFlourish( entity player )
{
	Signal( player, SIGNAL_EMOTE_FLOURISH )
}

void function HACK_ForceEmoteNoLoop( entity player, float animTime, ItemFlavor flavor, float startTime )
{
	EndSignal( player, SIGNAL_END_EMOTE_PERFORMANCE )
	EndSignal( player, SIGNAL_END_EMOTE_ENDED )
	EndSignal( player, "OnDestroy" )

	table< string, bool > e
	e["completed"] <- false

	OnThreadEnd(
		function() : ( player, e, flavor, startTime )
		{
			if ( ! e["completed"] )
				PIN_EmoteUse( player, ItemFlavor_GetHumanReadableRefForPIN_Slow( flavor ), player.GetOrigin(), EMOTE_PIN_ACTION_INTERRUPT, Time() - startTime )
		}
	)

	wait animTime

	e["completed"] = true

	Emote_StopEmoteNow( player )
}

void function WatchPlayerEmoteForInterrupt( entity player )
{
	EndSignal( player, SIGNAL_END_EMOTE_PERFORMANCE )
	EndSignal( player, SIGNAL_END_EMOTE_ENDED )
	EndSignal( player, "OnDestroy" )

	float vertAxis
	float horizAxis

	bool inputsHaveZeroed = false

	const float EMOTE_MOVEMENT_THRESHOLD = 0.2
	while ( true )
	{
		vertAxis  = player.GetInputAxisForward()
		horizAxis = player.GetInputAxisRight()

		if ( inputsHaveZeroed )
		{
			if ( fabs( vertAxis ) > EMOTE_MOVEMENT_THRESHOLD || fabs( horizAxis ) > EMOTE_MOVEMENT_THRESHOLD )
				break
		}
		else
		{
			if ( fabs( vertAxis ) < EMOTE_MOVEMENT_THRESHOLD && fabs( horizAxis ) < EMOTE_MOVEMENT_THRESHOLD )
				inputsHaveZeroed = true
		}

		if ( !player.IsOnGround() )
			break

		WaitFrame()
	}

	Emote_StopEmoteNow( player )
}

void function CharacterEmote_OnPlayerBleedout( entity player, entity attacker, var damageInfo )
{
	SetPlayerCanGroundEmote( player, false )

	if ( GetPlayerIsEmoting( player ) )
		Emote_StopEmoteNow( player )
}

void function CharacterEmote_OnPlayerGotFirstAid( entity player )
{
	SetPlayerCanGroundEmote( player, true )
}

void function CharacterEmote_OnPlayerDeath( entity player, var damageInfo )
{
	SetPlayerCanGroundEmote( player, false )
}

void function StandingEmote_OnPlayerClassChanged( entity player )
{
	if ( GetPlayerIsEmoting( player ) )
		Emote_StopEmoteNow( player )
}

void function OnEmotingPlayerDamaged( entity player, var damageInfo )
{
	if ( DamageInfo_GetDamage( damageInfo ) <= 0 )
		return

	Emote_StopEmoteNow( player )
}

void function OnEmotingPlayerShieldDamaged( entity player, var damageInfo, float actualShieldDamage )
{
	if ( actualShieldDamage == 0 )
		return

	Emote_StopEmoteNow( player )
}
#endif // SERVER

// ----------------------------------------------------------------------------------------------------------
//
// ██╗   ██╗████████╗██╗██╗     ██╗████████╗██╗   ██╗
// ██║   ██║╚══██╔══╝██║██║     ██║╚══██╔══╝╚██╗ ██╔╝
// ██║   ██║   ██║   ██║██║     ██║   ██║    ╚████╔╝
// ██║   ██║   ██║   ██║██║     ██║   ██║     ╚██╔╝
// ╚██████╔╝   ██║   ██║███████╗██║   ██║      ██║
//  ╚═════╝    ╚═╝   ╚═╝╚══════╝╚═╝   ╚═╝      ╚═╝
// ----------------------------------------------------------------------------------------------------------

bool function IsPlayerMovingTooQuicklyForEmote( entity player )
{
	vector playerVel = player.GetVelocity()
	float player2DSpeed = Length2D( playerVel )

	return player2DSpeed > STATIC_EMOTE_MAX_MOVE_SPEED
}

float function DEV_CharacterEmote_GetCustomAnimSequenceTime( string animName )
{
	const float FRAMERATE = 30.0
	if ( animName in DEV_CUSTOM_ANIM_DURATIONS )
		return DEV_CUSTOM_ANIM_DURATIONS[ animName ] / FRAMERATE
	else
		return -1

	unreachable
}

#if SERVER
int function Emote_CountPlayerSpawnedProps ()
{
	int result
	array< entity > playersWithNoProps = []
	foreach ( player, props in file.playerSpawnedProps )
	{
		if ( props.len() == 0 )
			playersWithNoProps.append( player )
		else
			result += props.len()
	}
	foreach ( entity playerWithNoProps in playersWithNoProps )
	{
		delete file.playerSpawnedProps[playerWithNoProps]
	}
	return result
}

void function Emote_AnimEvent_SpawnModelInWorld( entity player, string attachPoint, string modelKey )
{
	int atchIndex = player.LookupAttachment( attachPoint )
	if( atchIndex <= 0 )
	{
		Assert( false, "Emote_AnimEvent_SpawnModelInWorld - Attach point '" + attachPoint + "' is not valid on player " + player )
		return
	}
	asset model = GetModelFor_Emote_SpawnModel( modelKey )

	entity spawnedProp

	int realm = player.GetRealms()[ 0 ]

	// Behaviors, if there are any
	switch( modelKey )
	{
		case "lantern":
			spawnedProp = CreateScriptMoverModel( model, player.GetAttachmentOrigin( atchIndex ), player.GetAttachmentAngles( atchIndex ), SOLID_VPHYSICS, 50000 )
			SpawnedProp_PutInRealm( spawnedProp, realm )
			thread SpawnedProp_Behavior_Move_Thread( player, spawnedProp, < 0 ,0, 1 >, true, SPAWNEDPROP_MOVEDIST_DEFAULT,
				SPAWNEDPROP_LANTERN_MOVE_SPEED,
				SPAWNEDPROP_LANTERN_MOVE_EASEIN,
				SPAWNEDPROP_LANTERN_MOVE_EASEOUT )
			thread SpawnedProp_Behavior_VFX_Thread( spawnedProp, VFX_LANTERN, < 255, 210, 60 >, FX_PATTACH_POINT_FOLLOW, "Base" )
			break
		default:
			spawnedProp = CreatePropDynamicLightweight( model, player.GetAttachmentOrigin( atchIndex ), player.GetAttachmentAngles( atchIndex ) )
			SpawnedProp_PutInRealm( spawnedProp, realm )
			// Behavior(s)
			thread SpawnedProp_Behavior_Sit_Thread( player, spawnedProp )
			break
	}

	// DebugDrawEntityModelCollision not in S3
}

void function SpawnedProp_PutInRealm( entity spawnedProp, int realm )
{
	if( !IsValid( spawnedProp ) )
		return

	spawnedProp.RemoveFromAllRealms()
	spawnedProp.AddToRealm( realm )
}

asset function GetModelFor_Emote_SpawnModel( string modelKey )
{
	//Potentially Temporary until we decide to create an item flavor for spawned emote props
	switch( modelKey )
	{
		case "lantern":
			return SPAWNEDPROP_MODEL_LANTERN
			break
		case "nessie":
			return SPAWNEDPROP_MODEL_WATTSON_NESSIE
			break
		case "vantageCarving":
			return SPAWNEDPROP_MODEL_VANTAGE_CARVING
			break
		case "wraithInsignia":
			return WRAITH_INSIGNIA_MODEL
			break
		case "flowerHibiscus":
			return SPAWNEDPROP_MODEL_CONDUIT_FLOWER
			break
		default:
		{
			Assert(false, "GetModelFor_Emote_SpawnModel: No model found for modelKey: '" + modelKey + "'. Using Empty Model")
			return EMPTY_MODEL
		}
	}

	unreachable
}

void function SpawnedProp_Behavior_Sit_Thread( entity player, entity spawnedProp )
{
	EndSignal( spawnedProp, "OnDestroy" )
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )


	TraceResults result = TraceLine( spawnedProp.GetOrigin() + <0,0,30>, spawnedProp.GetOrigin() - <0,0,30>, spawnedProp, TRACE_MASK_SHOT_BRUSHONLY, TRACE_COLLISION_GROUP_NONE  )

	if ( IsValid( result.hitEnt ) )
	{
		spawnedProp.SetParent( result.hitEnt )

		WaitSignal( player, SIGNAL_END_EMOTE_ENDED )

		result = TraceLine( spawnedProp.GetOrigin() + <0,0,30>, spawnedProp.GetOrigin() - <0,0,30>, spawnedProp, TRACE_MASK_SHOT_BRUSHONLY, TRACE_COLLISION_GROUP_NONE  )

		spawnedProp.SetAbsOrigin( result.endPos )

		SpawnedProp_Tracking_Add( player, spawnedProp )
	}
	else
	{
		WaitSignal( player, SIGNAL_END_EMOTE_ENDED )
		SpawnedProp_Despawn( spawnedProp )
	}
}

void function SpawnedProp_Behavior_Move_Thread( entity player, entity spawnedProp, vector directionParm = < 0, 0, 1 >, bool doTrace = true,
											float moveDist = SPAWNEDPROP_MOVEDIST_DEFAULT, float moveSpeed = SPAWNEDPROP_MOVESPEED_DEFAULT,
											float easeIn = 0.5, float easeOut = 0.0 )
{
	// Default Parameters:
	//	- doTrace = true, which means function will do a trace check to see where the prop will end movement.
	//	- moveDist = 200 meters.
	//	- moveSpeed = 1 meter/seond

	EndSignal( spawnedProp, "OnDestroy", "OnFirstCollision" )
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )

	OnThreadEnd( function() : ( spawnedProp )
	{
		SpawnedProp_Tracking_Remove( spawnedProp )
	})

	SpawnedProp_Tracking_Add( player, spawnedProp )

	vector direction = Normalize( directionParm )

	// Figure out how high to float and for how long from results of trace.
	float destHeight = moveDist
	if( doTrace )
	{
		vector traceDirection = direction * moveDist
		TraceResults result = TraceLine( spawnedProp.GetOrigin(), spawnedProp.GetOrigin() + traceDirection, spawnedProp, TRACE_MASK_SHOT_BRUSHONLY, TRACE_COLLISION_GROUP_NONE  )
		destHeight = moveDist * result.fraction
	}

	float floatTime = destHeight / moveSpeed
	vector destination = spawnedProp.GetOrigin() + direction * destHeight

	spawnedProp.NonPhysicsMoveTo( destination, floatTime, easeIn, easeOut )

	wait( floatTime )
}

void function SpawnedProp_Behavior_VFX_Thread( entity spawnedProp, asset fxAsset, vector color = < -1, -1, -1 >, int attachType = FX_PATTACH_ABSORIGIN_FOLLOW, string attachName = "" )
{
	if ( !IsValid( spawnedProp ) )
		return

	spawnedProp.EndSignal( "SpawnedProp_StopFX" )
	spawnedProp.EndSignal( "OnDestroy" )

	int attachID = ATTACHMENTID_INVALID
	if ( attachName != "" )
	{
		attachID = spawnedProp.LookupAttachment( attachName )
	}

	int fxID = GetParticleSystemIndex( fxAsset )
	entity fxHandle = StartParticleEffectOnEntity_ReturnEntity( spawnedProp, fxID, attachType, attachID )
	fxHandle.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	if ( color != < -1, -1, -1 > )
	{
		EffectSetControlPointVector( fxHandle, 1, color )
	}

	OnThreadEnd( function() : ( fxHandle )
	{
		if ( IsValid( fxHandle ) )
		{
			EffectStop( fxHandle )
		}
	} )

	while( IsValid( spawnedProp ) )
	{
		wait 1
	}
}

void function SpawnedProp_Behavior_Spin( entity spawnedProp, int spinSpeed, vector axis = < 0, 0, 1 > )
{
	spawnedProp.NonPhysicsSetRotateModeLocal( true )
	spawnedProp.NonPhysicsRotate( axis, spinSpeed )
}

// ---

void function SpawnedProp_Tracking_Add( entity player, entity spawnedProp )
{
	if ( Emote_CountPlayerSpawnedProps() >= MAX_PROPS_ALLOWED_IN_WORLD )
	{
		entity playerToRemoveProp   = null
		int otherPlayerMaxPropCount = 0

		foreach ( otherPlayer, otherProps in file.playerSpawnedProps )
		{
			if ( otherPlayer == player && otherProps.len() > 0 )
			{
				playerToRemoveProp = player
				break
			}
			else if ( otherProps.len() > otherPlayerMaxPropCount )
			{
				playerToRemoveProp      = otherPlayer
				otherPlayerMaxPropCount = otherProps.len()
			}
		}

		if ( playerToRemoveProp != null )
		{
			entity propToRemove = file.playerSpawnedProps[playerToRemoveProp].pop()
			if ( IsValid( propToRemove ) )
			{
				SpawnedProp_Despawn( propToRemove )
			}
		}
		else
			Assert ( false, "Couldn't find a player to remove a prop from, and there are more than" + MAX_PROPS_ALLOWED_IN_WORLD + " player placed props." )
	}
	if ( ! (player in file.playerSpawnedProps) )
		file.playerSpawnedProps[player] <- []

	file.playerSpawnedProps[player].insert( 0, spawnedProp )
}

void function SpawnedProp_Tracking_Remove( entity prop )
{
	foreach ( players, propslist in file.playerSpawnedProps )
	{
		if( propslist.contains( prop ) )
		{
			propslist.removebyvalue( prop )
			break
		}
	}

	if( IsValid( prop ) )
	{
		SpawnedProp_Despawn( prop )
	}
}

void function SpawnedProp_Despawn( entity spawnedProp )
{
	if( !IsValid( spawnedProp ) )
		return

	spawnedProp.Signal( "SpawnedProp_StopFX" )
	spawnedProp.Dissolve( ENTITY_DISSOLVE_NONE, <0,0,0>, 0 )
}

// ---

void function Emote_AnimEvent_SpawnSprayInWorld( entity weapon, string modelKey, string airOffset, string surfaceDist)
{
	entity player = weapon.GetOwner()
	asset model   = GetModelFor_Emote_SpawnModel( modelKey )

	entity spawnedProp = CreatePropDynamicLightweight( model, player.GetOrigin(), player.GetAngles() )

	vector offset         = <0, 0, 35>
	float surfaceDistance = 60

	if ( airOffset.len() > 0 )
		offset = StringToVector( airOffset )

	if ( surfaceDist.len() > 0 )
		surfaceDistance = float(surfaceDist)

	Signal( player, SIG_PLAYER_SPRAY )
	thread VerifySprayPlacement( player, spawnedProp, offset, surfaceDistance )
}

void function VerifySprayPlacement( entity player, entity spawnedProp, vector airOffset, float surfaceDistance )
{
	EndSignal( spawnedProp, "OnDestroy" )
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( player, SIG_PLAYER_SPRAY )

	OnThreadEnd(
		function() : ( player, spawnedProp )
		{
			//Only necessary if we start using the props pool for sprays
			//if ( player in file.playerSpawnedProps && file.playerSpawnedProps[player].contains( spawnedProp ) )
			//	file.playerSpawnedProps[player].removebyvalue( spawnedProp )
			DestroySpray( spawnedProp )
		}
	)

	vector spawnStart = player.EyePosition()
	vector spawnEnd   = spawnStart + player.GetViewVector() * surfaceDistance

	TraceResults result = TraceLine( spawnStart, spawnEnd, [spawnedProp, player], TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )

	if ( IsValid( result.hitEnt ) )
	{
		bool isValidSpraySurface = IsValidSpraySurface( result.hitEnt )

		spawnedProp.SetParent( result.hitEnt )
		spawnedProp.SetAbsOrigin( result.endPos )
		EmitSoundOnEntity( spawnedProp, SFX_WRAITH_INSIGNIA_LOOP )

		//Set Angles
		vector finalAngles
		float dot = fabs( DotProduct( result.surfaceNormal, <0, 0, 1> ) )
		if ( dot > 0.25 ) //Check if it isn't a straight wall and apply a lil view flex to it
		{
			finalAngles = AnglesOnSurface( result.surfaceNormal, player.GetViewUp() )
			finalAngles = AnglesCompose( finalAngles, <-90, 180, 0> )
		}
		else
		{
			finalAngles = VectorToAngles( result.surfaceNormal )
		}
		spawnedProp.SetAbsAngles( finalAngles )

		//Edge Detection
		vector left   = spawnedProp.GetOrigin() + VectorRotate( <0, spawnedProp.GetBoundingMins().y, 0>, spawnedProp.GetAngles() )
		vector right  = spawnedProp.GetOrigin() + VectorRotate( <0, spawnedProp.GetBoundingMaxs().y, 0>, spawnedProp.GetAngles() )
		vector top    = spawnedProp.GetOrigin() + VectorRotate( <0, 0, spawnedProp.GetBoundingMaxs().z>, spawnedProp.GetAngles() )
		vector bottom = spawnedProp.GetOrigin() + VectorRotate( <0, 0, spawnedProp.GetBoundingMins().z>, spawnedProp.GetAngles() )

		array<vector>sides
		sides.append( left )
		sides.append( right )
		sides.append( top )
		sides.append( bottom )

		const float DIST_CHECK = 4 //need to make sure each side has a "wall" behind it to avoid vision blockers

		foreach ( vector side in sides )
		{
			TraceResults sideResult = SprayTraceHelper( spawnedProp, side, DIST_CHECK )
			if ( sideResult.fraction >= 1.0 || !IsValidSpraySurface( sideResult.hitEnt ) )
			{
				//DebugDrawMark( side, 3, COLOR_RED, true, 10.0 )
				isValidSpraySurface = false
				break
			}
			//DebugDrawMark( side, 3, COLOR_GREEN, true, 10.0 )
		}

		//Only necessary if we start using the props pool for sprays
		//SpawnedProp_Tracking_Add( player, spawnedProp )

		if ( isValidSpraySurface )
			wait file.spraySurfaceLifetime
		else
			wait file.sprayAirLifetime
	}
	else
	{
		vector playerViewAngles = VectorToAngles( player.GetViewVector() )
		spawnedProp.SetAbsOrigin( spawnStart + VectorRotate( airOffset, playerViewAngles ) )
		spawnedProp.SetAbsAngles( AnglesCompose( playerViewAngles, <0, 180, 0> ) )

		EmitSoundOnEntity( spawnedProp, SFX_WRAITH_INSIGNIA_LOOP )
		wait file.sprayAirLifetime
	}
}

void function DestroySpray( entity prop )
{
	if ( !IsValid( prop ) )
		return

	StopSoundOnEntity( prop, SFX_WRAITH_INSIGNIA_LOOP )
	EmitSoundAtPosition( TEAM_ANY, prop.GetOrigin(), SFX_WRAITH_INSIGNIA_OUTRO, prop )

	StartParticleEffectInWorld( GetParticleSystemIndex( VFX_WRAITH_INSIGNIA_OUTRO ), prop.GetOrigin(), prop.GetAngles() )
	prop.Destroy()
}

bool function IsValidSpraySurface( entity surface )
{
	if ( !IsValid( surface ) )
		return false

	if ( IsDoor( surface ) )
		return false

	//The giant sliding doors
	if ( surface.GetModelName() == "mdl/door/door_canyonlands_large_01_animated.rmdl" || surface.GetModelName() == "mdl/door/door_256x256x8_elevatorstyle02_animated.rmdl" )
		return false

	return true
}

TraceResults function SprayTraceHelper( entity prop, vector start, float dist )
{
	vector traceStart = start + VectorRotate( <-dist, 0, 0>, prop.GetAngles() )
	vector doTrace   = traceStart + VectorRotate( <dist * 2, 0, 0>, prop.GetAngles() )

	//DebugDrawLine( traceStart, doTrace, COLOR_RED, true, 10.0 )

	return TraceLineHighDetail( traceStart, doTrace, prop, TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )
}

#endif