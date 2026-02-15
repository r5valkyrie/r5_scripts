global function ShLootMarvin_Init

#if CLIENT
global function ServerCallback_PromptPingLootMarvin
#endif

#if SERVER
global function LootMarvin_OnDispenseLootAnimEvent
global function ClientCallback_PromptPingLootMarvin
global function AttemptPingNearestValidMarvinForPlayer
global function LootMarvinArm_OnPickup
#endif

#if SERVER && DEVELOPER
global function CreateMarvin_Loot
global function CreateMarvin_Story
global function SeeMarvinSpawnLocations
global function TeleportToRandomMarvinLocations
#endif

global const string STORY_MARVIN_SCRIPTNAME = "story_marvin"
global const string LOOT_MARVIN_SCRIPTNAME = "loot_marvin"
global const string ITEM_MARVIN_ARM_REF = "loot_marvin_arm"

const int MAX_NUM_MARVINS = 24
const int MAX_NUM_ARM_MARVINS = 5
const int MARVIN_DIST_BUFFER = 5000
const int MAX_LOOT_ITEMS_FROM_MARVIN = 3
const float DURATION_COOLDOWN = 90.0
const float DURATION_WAIT_FOR_PLAYERS_NEARBY = 30.0

const string WAYPOINTTYPE_COOLDOWN = "waypointType_MarvinCooldown"
const string WAYPOINTTYPE_SCREEN = "waypointType_MarvinScreen"

const float SLOT_MACHINE_CYCLE_LENGTH = 0.3

const asset STORY_MARVIN_CSV_DIALOGUE = $"datatable/dialogue/story_marvin_dialogue.rpak"
const asset VFX_LOT_MARVIN_DISPERSE = $"P_armor_3P_break_CP"
const asset VFX_LOT_MARVIN_SPARK_ARM = $"P_sparks_dir_SM_LOOP"

#if SERVER
const int LOOT_MARVIN_TRIGGER_RADIUS = 384

const string ANIM_LOOT_MARVIN_POWERDOWN_IDLE = "mrvn_powerdown_idle"
const string ANIM_LOOT_MARVIN_POWERUP = "mrvn_loot_activate"
const string ANIM_LOOT_MARVIN_ACTIVE_LOOP = "mrvn_loot_slotmachine_idle"
const string ANIM_LOOT_MARVIN_POWERDOWN = "mrvn_loot_powerdown"
const string ANIM_LOOT_MARVIN_SLOT_CRANK = "mrvn_loot_slotmachine_handle"
const string ANIM_LOOT_MARVIN_DISPENSE_SAD = "mrvn_giveloot_shrug"
const string ANIM_LOOT_MARVIN_DISPENSE_NEUTRAL = "mrvn_giveloot_gesture"
const string ANIM_LOOT_MARVIN_DISPENSE_PLEASED = "mrvn_giveloot_wave"
const string ANIM_LOOT_MARVIN_DISPENSE_VERY_HAPPY = "mrvn_giveloot_newhand"

const string ANIM_STORY_MARVIN_IDLE = "mrvn_storyteller_idle"
const string SFX_STORY_MARVIN_LOG = "diag_mp_amelie_audioLog_01_3p"

const string SFX_LOOT_MARVIN_SLOT_LOOP = "LootMarvin_Tumbler_Start_Loop"
const string SFX_LOOT_MARVIN_SLOT_INTERACT_SAD = "LootMarvin_Result_Grey"
const string SFX_LOOT_MARVIN_SLOT_INTERACT_NEUTRAL = "LootMarvin_Result_Blue"
const string SFX_LOOT_MARVIN_SLOT_INTERACT_PLEASED = "LootMarvin_Result_Purple"
const string SFX_LOOT_MARVIN_SLOT_INTERACT_VERY_HAPPY = "LootMarvin_Result_Gold"
const string SFX_LOOT_MARVIN_DISPERSE = "LootMarvin_DispenseLoot"
const string SFX_MARVIN_DENY = "Olympus_Horizon_Screen_Deny"
const string SFX_MARVIN_SPARKS = "LootMarvin_Arm_Sparks"

const string SIGNAL_PLAYER_ENTERED_MARVIN_TRIGGER = "OnEnterMarvinTrigger"
const string SIGNAL_MARVIN_ON_ACTIVATED = "OnMarvinActivated"
const string SIGNAL_MARVIN_ON_POWERDOWN = "OnMarvinPowerdown"

const string BODYGROUP_RIGHT_ARM = "removableRightForearm"
const int BODYGROUP_RIGHT_ARM_INDEX_ATTACHED_SPECIAL = 3
const int BODYGROUP_RIGHT_ARM_INDEX_DETACHED = 1

const string BODYGROUP_LEFT_ARM = "removableLeftForearm"
const int BODYGROUP_LEFT_ARM_INDEX_DETACHED = 1
#endif // SERVER


#if SERVER
enum eMarvinEmoticon
{
	SAD,
	NEUTRAL,
	PLEASED,
	VERY_HAPPY,
}
#endif

#if SERVER || CLIENT
global enum eMarvinState
{
	DISABLED,
	READY_FOR_POWERUP,
	POWERING_UP,
	ACTIVE,
	DISPENSING,
	POWERING_DOWN,
	PERMANENTLY_DISABLED,
}
#endif


#if SERVER
struct MarvinData
{
	Point  startPoint
	int    marvinState
	bool   hasDetachableArm = false
	bool   isStoryMarvin = false
	bool   hasMissingArmBeenAttached = false
	int    lootTypeState
	entity trigger
	entity chestWaypoint
	int    currentEmoticonIdx = eMarvinEmoticon.SAD
	bool   hasSlotMachineSettled = false
	entity armSparkFx
}
#endif //SERVER


struct
{
	#if SERVER
		table< entity, MarvinData > spawnedMarvinData
		array<entity>               marvinNodes
	#else // SERVER
		var    chestScreenTopo
		var    chestScreenRui
		var    cooldownRui
		entity topPriorityLootMarvin
	#endif // CLIENT
}file


// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
//
//  #### ##    ## #### ########
//   ##  ###   ##  ##     ##
//   ##  ####  ##  ##     ##
//   ##  ## ## ##  ##     ##
//   ##  ##  ####  ##     ##
//   ##  ##   ###  ##     ##
//  #### ##    ## ####    ##
//
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================


void function ShLootMarvin_Init()
{
	if( Gamemode() != eGamemodes.SURVIVAL )
	{
		#if SERVER
			// enable this callback so we can delete the dummy props already in the map
			AddSpawnCallbackEditorClass( "prop_dynamic", "script_loot_marvin", LootMarvin_OnScriptTargetSpawned )
		#endif
		return
	}
	RegisterCSVDialogue( STORY_MARVIN_CSV_DIALOGUE )
	PrecacheParticleSystem( VFX_LOT_MARVIN_DISPERSE )
	PrecacheParticleSystem( VFX_LOT_MARVIN_SPARK_ARM )

	#if SERVER
		RegisterSignal( SIGNAL_PLAYER_ENTERED_MARVIN_TRIGGER )
		RegisterSignal( SIGNAL_MARVIN_ON_ACTIVATED )
		RegisterSignal( SIGNAL_MARVIN_ON_POWERDOWN )


		AddSpawnCallbackEditorClass( "prop_dynamic", "script_loot_marvin", LootMarvin_OnScriptTargetSpawned )
		//RegisterCustomItemPickupAction( ITEM_MARVIN_ARM_REF, LootMarvinArm_OnPickup )
	#endif

	#if CLIENT
		AddCallback_OnPlayerLifeStateChanged( OnPlayerLifeStateChanged )

		Waypoints_RegisterCustomType( WAYPOINTTYPE_COOLDOWN, InstanceMarvinCooldownCreatedWP )
		Waypoints_RegisterCustomType( WAYPOINTTYPE_SCREEN, InstanceMarvinScreenCreatedWP )

		AddCreateCallback( "npc_marvin", ClOnMarvinSpawned )
	#endif
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
}


void function EntitiesDidLoad()
{
	if( Gamemode() != eGamemodes.SURVIVAL )
		return

	int maxNumMarvins      = GetCurrentPlaylistVarInt( "marvins_max_num", MAX_NUM_MARVINS )
	int maxNumArmedMarvins = GetCurrentPlaylistVarInt( "marvins_max_num_armed", MAX_NUM_ARM_MARVINS )

	bool lootMarvinsEnabled    = GetCurrentPlaylistVarBool( "loot_marvins_enabled", true )
	float marvinDistanceBuffer = GetCurrentPlaylistVarFloat( "marvins_distance_buffer", MARVIN_DIST_BUFFER )

	#if SERVER
		file.marvinNodes.randomize()
		array<entity> usedNodes

		if ( lootMarvinsEnabled )
		{
			int numSpawnedMarvins      = 0
			int numArmedMarvinsSpawned = 0

			foreach ( int idx, entity node in file.marvinNodes )
			{
				// don't spawn more than the max
				if ( numSpawnedMarvins >= maxNumMarvins )
					break

				// don't spawn if we're too close to another marvin that already spawned
				bool isTooCloseToAnotherNode = false

				foreach ( entity occupiedNode in usedNodes )
				{
					if ( Distance( occupiedNode.GetOrigin(), node.GetOrigin() ) <= marvinDistanceBuffer )
					{
						isTooCloseToAnotherNode = true
						break
					}
				}

				if ( isTooCloseToAnotherNode )
					continue

				// spawn the marvin
				usedNodes.append( node )
				bool hasDetachableArm = numArmedMarvinsSpawned < maxNumArmedMarvins

				ProcessLevelEdMarvinNode( node, false, hasDetachableArm )

				numSpawnedMarvins++
				numArmedMarvinsSpawned++
			}
		}

		foreach ( entity node in file.marvinNodes )
			node.Destroy()

		file.marvinNodes.clear()

		printf( "Total num story and loot marvins: %i", file.spawnedMarvinData.len() )
	#endif //SERVER
}


#if SERVER
void function LootMarvin_OnScriptTargetSpawned( entity ent )
{
	if( Gamemode() != eGamemodes.SURVIVAL )
	{
		ent.Destroy()
		return
	}

	bool storyMarvinsEnabled = GetCurrentPlaylistVarBool( "story_marvins_enabled", false )

	if ( ent.HasKey( "is_story_marvin" ) && ent.kv.is_story_marvin == "1" )
	{
		if ( storyMarvinsEnabled )
			ProcessLevelEdMarvinNode( ent, true )

		ent.Destroy()
	}
	else
	{
		file.marvinNodes.append( ent )
	}
}
#endif // SERVER


#if SERVER
void function ProcessLevelEdMarvinNode( entity node, bool isStoryMarvin, bool hasDetachableArm = false )
{
	vector origin       = node.GetOrigin()
	vector angles       = node.GetAngles()
	entity entityParent = node.GetParent()

	CreateMarvin( origin, angles, entityParent, isStoryMarvin, hasDetachableArm )
}
#endif //SERVER


// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
//
//  ##     ## ######## #### ##
//  ##     ##    ##     ##  ##
//  ##     ##    ##     ##  ##
//  ##     ##    ##     ##  ##
//  ##     ##    ##     ##  ##
//  ##     ##    ##     ##  ##
//   #######     ##    #### ########
//
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================


#if SERVER && DEVELOPER
void function CreateMarvin_Loot( bool hasDetachableArm = false )
{
	entity player             = gp()[0]
	TraceResults traceResults = PlayerViewTrace( player, 90000 )
	if ( traceResults.fraction >= 1.0 )
		return

	CreateMarvin( traceResults.endPos, <0, 0, 0>, null, false, hasDetachableArm )
}
#endif // SERVER && DEV


#if SERVER && DEVELOPER
void function CreateMarvin_Story()
{
	entity player             = gp()[0]
	TraceResults traceResults = PlayerViewTrace( player, 90000 )
	if ( traceResults.fraction >= 1.0 )
		return

	CreateMarvin( traceResults.endPos, <0, RandomFloat( 360.0 ), 0>, null, true, false )
}
#endif // SERVER && DEV


#if SERVER && DEVELOPER
void function SeeMarvinSpawnLocations()
{
	bool storyMarvinExists = false
	foreach ( entity marvin, MarvinData data in file.spawnedMarvinData )
	{
		if ( IsAlive( marvin ) )
		{
			if ( data.hasDetachableArm )
			{
				DebugDrawSphere( marvin.GetOrigin(), 256, 0, 0, 255 , true, 45.0 )
			}
			else if ( data.isStoryMarvin )
			{
				DebugDrawSphere( marvin.GetOrigin(), 256, 0, 255, 0, true, 45.0 )
				storyMarvinExists = true
			}
			else
			{
				DebugDrawSphere( marvin.GetOrigin(), 256, 255, 255, 0, true, 45.0 )
			}
		}
	}

	int numAliveMarvins = storyMarvinExists ? file.spawnedMarvinData.len() - 1 : file.spawnedMarvinData.len()

	printf( "Number of alive loot marvins: %i", numAliveMarvins )
}

void function TeleportToRandomMarvinLocations()
{
	bool storyMarvinExists = false
	array<entity> allMarvins = GetEntArrayByScriptName( LOOT_MARVIN_SCRIPTNAME )
	entity marvin = allMarvins.getrandom()
	{
		gp()[0].SetOrigin(marvin.GetOrigin())
	}
	printf( "Teleporting" + gp()[0] + "to Random Marvin Location" )
}
#endif // SERVER && DEVELOPER


#if SERVER
void function PlayAnimLootMarvin( entity marvin, Point startPoint, string animation )
{
	EndSignal( marvin, "OnDeath" )

	Assert( IsAlive( marvin ), "Marvin tried to play an anim, but it is not alive." )

	// TODO: support playing anims when the marvin is parented, which doesn't occur in olympus...for now at least.
	marvin.SetNextThinkNow()
	marvin.Anim_ScriptedPlayWithRefPoint( animation, startPoint.origin, startPoint.angles, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME )

	WaittillAnimDone( marvin )
}
#endif

// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
//
//   ######  ########     ###    ##      ## ##    ## #### ##    ##  ######
//  ##    ## ##     ##   ## ##   ##  ##  ## ###   ##  ##  ###   ## ##    ##
//  ##       ##     ##  ##   ##  ##  ##  ## ####  ##  ##  ####  ## ##
//   ######  ########  ##     ## ##  ##  ## ## ## ##  ##  ## ## ## ##   ####
//        ## ##        ######### ##  ##  ## ##  ####  ##  ##  #### ##    ##
//  ##    ## ##        ##     ## ##  ##  ## ##   ###  ##  ##   ### ##    ##
//   ######  ##        ##     ##  ###  ###  ##    ## #### ##    ##  ######
//
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================


#if SERVER
void function CreateMarvin( vector origin, vector angles, entity lootMarvinParent, bool isStoryMarvin, bool hasDetachableArm )
{
	if ( isStoryMarvin )
	{
		origin += (AnglesToRight( angles ) * -48.0) + (AnglesToForward( angles ) * 4.0)
	}

	string marvinScriptName = isStoryMarvin ? STORY_MARVIN_SCRIPTNAME : LOOT_MARVIN_SCRIPTNAME
	entity marvin           = CreateNPCFromAISettings( "npc_marvin_olympus", TEAM_UNASSIGNED, origin, angles )
	marvin.SetScriptName( marvinScriptName )
	DispatchSpawn( marvin )

	//marvin.SetIgnorePredictedTriggerTypes( TT_JUMP_PAD | TT_GRAVITY_LIFT | TT_BLACKHOLE  )

	//marvin.SetNetworkDistanceCullEnabled( false )

	//	link it all to greater parent if there is one
	if ( IsValid( lootMarvinParent ) )
		marvin.SetParent( lootMarvinParent )

	//	state data
	MarvinData data
	data.startPoint.origin = origin
	data.startPoint.angles = angles
	file.spawnedMarvinData[ marvin ] <- data

	// callbacks
	AddEntityCallback_OnDamaged( marvin, LootAndStoryMarvin_OnDamaged )
	AddEntityCallback_OnKilled( marvin, LootAndStoryMarvin_OnKilled )

	// setup
	if ( isStoryMarvin )
	{
		data.isStoryMarvin = true

		thread PlayAnim( marvin, ANIM_STORY_MARVIN_IDLE )

		marvin.SetUsable()
		marvin.SetUsePrompts( "#STORY_MARVIN_PROMPT_USE", "#STORY_MARVIN_PROMPT_USE" )
		marvin.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER | USABLE_BY_PILOTS | USABLE_BY_ENEMIES )
		marvin.SetUsablePriority( USABLE_PRIORITY_LOW )
		AddCallback_OnUseEntity_ServerOnly( marvin, OnUseStoryMarvin )
	}
	else
	{
		marvin.SetBodygroupModelByIndex( marvin.FindBodygroup( BODYGROUP_RIGHT_ARM ), BODYGROUP_RIGHT_ARM_INDEX_DETACHED )

		if ( hasDetachableArm )
		{
			marvin.SetSkin( 1 )
			data.hasDetachableArm = true
		}

		marvin.SetUsable()
		marvin.SetUsePrompts( "#LOOT_MARVIN_PROMPT_USE", "#LOOT_MARVIN_PROMPT_USE" )
		marvin.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER | USABLE_BY_PILOTS | USABLE_BY_ENEMIES )
		marvin.SetUsablePriority( USABLE_PRIORITY_LOW )
		AddCallback_OnUseEntity_ServerOnly( marvin, CreateOnUseLootMarvinFunc( data ) )

		data.marvinState = eMarvinState.READY_FOR_POWERUP

		//marvin.SetThinkDuringAnimation( false )

		thread PlayAnimLootMarvin( marvin, data.startPoint, ANIM_LOOT_MARVIN_POWERDOWN_IDLE )

		marvin.SetActivityModifier( ACT_MODIFIER_STAGGER, true )

		data.trigger = CreateEntity( "trigger_cylinder" )//
		data.trigger.SetRadius( LOOT_MARVIN_TRIGGER_RADIUS )//CreateTriggerCylinder( marvin.GetOrigin(), LOOT_MARVIN_TRIGGER_RADIUS, 72, 16 )
		data.trigger.SetOrigin( marvin.GetOrigin() )
		data.trigger.SetAboveHeight( 72 )
		data.trigger.SetBelowHeight( 16 )
		DispatchSpawn( data.trigger )
		data.trigger.SetEnterCallback( CreateOnEnterLootMarvinTriggerFunc( marvin, data ) )
		data.trigger.SetLeaveCallback( CreateOnLeaveLootMarvinTriggerFunc( marvin, data ) )
	}
}
#endif //SERVER


#if CLIENT
void function ClOnMarvinSpawned( entity marvin )
{
	if ( marvin.GetScriptName() != LOOT_MARVIN_SCRIPTNAME )
		return

	AddEntityCallback_GetUseEntOverrideText( marvin, LootMarvinHintTextFunc )
}
#endif


#if CLIENT
string function LootMarvinHintTextFunc( entity marvin )
{
	entity player = GetLocalViewPlayer()

	if ( GradeFlagsHas( marvin, eGradeFlags.IS_OPEN ) )
	{
		return "#LOOT_MARVIN_PROMPT_COOLDOWN"
	}
	else if ( GradeFlagsHas( marvin, eGradeFlags.IS_BUSY ) )
	{
		return "#LOOT_MARVIN_PROMPT_BUSY"
	}
	else if ( GradeFlagsHas( marvin, eGradeFlags.IS_LOCKED ) )
	{
		return "#LOOT_MARVIN_PROMPT_DISABLED"
	}
	else if ( DoesPlayerHaveMarvinArmInInventory( player ) )
	{
		return "#LOOT_MARVIN_PROMPT_USE_HAS_ARM"
	}

	return "#LOOT_MARVIN_PROMPT_USE"
}
#endif // CLIENT


// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
//
//   ######  ########  #######  ########  ##    ##       ##     ##    ###    ########  ##     ## #### ##    ##
//  ##    ##    ##    ##     ## ##     ##  ##  ##        ###   ###   ## ##   ##     ## ##     ##  ##  ###   ##
//  ##          ##    ##     ## ##     ##   ####         #### ####  ##   ##  ##     ## ##     ##  ##  ####  ##
//   ######     ##    ##     ## ########     ##          ## ### ## ##     ## ########  ##     ##  ##  ## ## ##
//        ##    ##    ##     ## ##   ##      ##          ##     ## ######### ##   ##    ##   ##   ##  ##  ####
//  ##    ##    ##    ##     ## ##    ##     ##          ##     ## ##     ## ##    ##    ## ##    ##  ##   ###
//   ######     ##     #######  ##     ##    ##          ##     ## ##     ## ##     ##    ###    #### ##    ##
//
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================


#if SERVER
void function OnUseStoryMarvin( entity marvin, entity playerUser, int useFlags )
{
	thread OnUseStoryMarvin_Thread( marvin, playerUser )
}
#endif //SERVER


#if SERVER
void function OnUseStoryMarvin_Thread( entity marvin, entity playerUser )
{
	const float AUDIO_LOG_LENGTH = 34.0
	const float PATH_DIST_FOR_REACTION_LINE = 1080.0

	EndSignal( marvin, "OnDeath" )

	marvin.UnsetUsable()

	EmitSoundOnEntity( marvin, SFX_STORY_MARVIN_LOG )

	wait AUDIO_LOG_LENGTH + 2.0

	marvin.SetUsable()

	if ( IsAlive( playerUser ) && IsPlayerPathfinder( playerUser ) )
	{
		/*if ( PlayerDeliveryShouldBeUrgent( playerUser, playerUser.GetOrigin() ) )
			return*/

		if ( Distance( playerUser.GetOrigin(), marvin.GetOrigin() ) <= PATH_DIST_FOR_REACTION_LINE )

			PlayBattleChatterLineToSpeakerAndTeam( playerUser, "path_story_marvin_reaction" )
	}
}
#endif


#if SERVER || CLIENT
bool function IsPlayerPathfinder( entity player )
{
	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_CharacterClass() )
	string characterRef  = ItemFlavor_GetHumanReadableRef( character ).tolower()

	if ( characterRef != "character_pathfinder" )
		return false

	return true
}
#endif


// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
//
//  ######## ########  ####  ######    ######   ######## ########   ######
//     ##    ##     ##  ##  ##    ##  ##    ##  ##       ##     ## ##    ##
//     ##    ##     ##  ##  ##        ##        ##       ##     ## ##
//     ##    ########   ##  ##   #### ##   #### ######   ########   ######
//     ##    ##   ##    ##  ##    ##  ##    ##  ##       ##   ##         ##
//     ##    ##    ##   ##  ##    ##  ##    ##  ##       ##    ##  ##    ##
//     ##    ##     ## ####  ######    ######   ######## ##     ##  ######
//
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================


#if SERVER
void functionref( entity trigger, entity ent ) function CreateOnEnterLootMarvinTriggerFunc( entity marvin, MarvinData data )
{
	return void function( entity trigger, entity ent ) : ( marvin, data )
	{
		OnEnterLootMarvinTrigger( trigger, ent, marvin, data )
	}
}
#endif //SERVER


#if SERVER
void functionref( entity trigger, entity ent ) function CreateOnLeaveLootMarvinTriggerFunc( entity marvin, MarvinData data )
{
	return void function( entity trigger, entity ent ) : ( marvin, data )
	{
		thread OnLeaveLootMarvinTrigger( trigger, ent, marvin, data )
	}
}
#endif //SERVER


#if SERVER
void function OnEnterLootMarvinTrigger( entity trigger, entity ent, entity marvin, MarvinData data )
{
	if ( !IsValid( ent ) || !ent.IsPlayer() )
		return

	if ( !IsAlive( marvin ) )
		return

	//marvin.SetThinkDuringAnimation( true )

	Signal( marvin, SIGNAL_PLAYER_ENTERED_MARVIN_TRIGGER )

	//if ( data.marvinState != eMarvinState.READY_FOR_POWERUP )
		//return

	PIN_Interact ( ent, "loot_marvin_power_up" ) //have checked that ent is a player above

	thread TryMarvinPowerUp( marvin, data )
}
#endif //SERVER


#if SERVER
void function OnLeaveLootMarvinTrigger( entity trigger, entity ent, entity marvin, MarvinData data )
{
	if ( !IsValid( ent ) || !ent.IsPlayer() )
		return

	if ( !IsAlive( marvin ) )
		return

	array<entity> touchingPlayers
	foreach ( entity touchEnt in trigger.GetTouchingEntities() )
	{
		if ( touchEnt.IsPlayer() )
			touchingPlayers.append( touchEnt )
	}

	if ( touchingPlayers.len() > 0 )
		return

	EndSignal( marvin, "OnDeath" )
	EndSignal( marvin, SIGNAL_MARVIN_ON_POWERDOWN )
	EndSignal( marvin, SIGNAL_PLAYER_ENTERED_MARVIN_TRIGGER )

	//marvin.SetThinkDuringAnimation( false )

	if ( data.marvinState != eMarvinState.ACTIVE )
	{
		if ( data.marvinState == eMarvinState.POWERING_UP )
		{
			WaitSignal( marvin, SIGNAL_MARVIN_ON_ACTIVATED )
		}
		else
		{
			return
		}
	}

	wait GetCurrentPlaylistVarFloat( "loot_marvin_wait_nearby_players_duration", DURATION_WAIT_FOR_PLAYERS_NEARBY )

	PIN_Interact ( ent, "loot_marvin_power_down" ) //have checked that ent is a player above

	thread TryPowerDownMarvin( marvin, data, false )
}
#endif //SERVER


// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
//
//  ##     ##    ###    #### ##    ##
//  ###   ###   ## ##    ##  ###   ##
//  #### ####  ##   ##   ##  ####  ##
//  ## ### ## ##     ##  ##  ## ## ##
//  ##     ## #########  ##  ##  ####
//  ##     ## ##     ##  ##  ##   ###
//  ##     ## ##     ## #### ##    ##
//
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================


#if SERVER
void function TryMarvinPowerUp( entity marvin, MarvinData data )
{
	if ( !IsAlive( marvin ) )
		return

	EndSignal( marvin, "OnDeath" )

	//if ( data.marvinState == eMarvinState.POWERING_UP )
		//return

	data.marvinState = eMarvinState.POWERING_UP

	GradeFlagsClear( marvin, eGradeFlags.IS_OPEN ) // clear the recharging use prompt
	GradeFlagsSet( marvin, eGradeFlags.IS_BUSY ) // busy use prompt

	if ( data.hasDetachableArm )
	{
		int particleIdx  = GetParticleSystemIndex( VFX_LOT_MARVIN_SPARK_ARM )
		int vfxAttachIdx = marvin.LookupAttachment( "FX_L_FOREARM" )
		data.armSparkFx = StartParticleEffectOnEntity_ReturnEntity( marvin, particleIdx, FX_PATTACH_POINT_FOLLOW, vfxAttachIdx )
		EmitSoundOnEntity( marvin, SFX_MARVIN_SPARKS )
	}

	waitthread PlayAnimLootMarvin( marvin, data.startPoint, ANIM_LOOT_MARVIN_POWERUP )

	data.marvinState = eMarvinState.ACTIVE
	Signal( marvin, SIGNAL_MARVIN_ON_ACTIVATED )

	thread PlayAnimLootMarvin( marvin, data.startPoint, ANIM_LOOT_MARVIN_ACTIVE_LOOP )
	thread SlotMachineCycleThink( marvin, data )

	marvin.SetActivityModifier( ACT_MODIFIER_STAGGER, false )
	GradeFlagsClear( marvin, eGradeFlags.IS_BUSY )
}
#endif //SERVER


#if SERVER
void function TryPowerDownMarvin( entity marvin, MarvinData data, bool shouldCooldown, bool playTransitionAnimToIdle = true )
{
	if ( !IsAlive( marvin ) )
		return

	EndSignal( marvin, "OnDeath" )

	if ( data.marvinState == eMarvinState.POWERING_DOWN )
		return

	data.marvinState = eMarvinState.POWERING_DOWN
	Signal( marvin, SIGNAL_MARVIN_ON_POWERDOWN )

	GradeFlagsSet( marvin, eGradeFlags.IS_BUSY ) // busy use prompt

	if ( playTransitionAnimToIdle )
		waitthread PlayAnimLootMarvin( marvin, data.startPoint, ANIM_LOOT_MARVIN_POWERDOWN )

	thread PlayAnimLootMarvin( marvin, data.startPoint, ANIM_LOOT_MARVIN_POWERDOWN_IDLE )

	if ( data.hasDetachableArm )
	{
		if ( IsValid( data.armSparkFx ) )
			data.armSparkFx.Destroy()

		StopSoundOnEntity( marvin, SFX_MARVIN_SPARKS )
	}

	if ( shouldCooldown )
	{
		data.marvinState = eMarvinState.DISABLED
		GradeFlagsSet( marvin, eGradeFlags.IS_OPEN ) // cooldown use prompt

		float cooldownDuration = GetCurrentPlaylistVarFloat( "loot_marvin_cooldown_duration", DURATION_COOLDOWN )
		entity wp              = CreateWaypoint_Custom( WAYPOINTTYPE_COOLDOWN )
		wp.SetWaypointEntity( 0, marvin )
		wp.SetOrigin( marvin.GetOrigin() + <0, 0, 66> )
		wp.SetAngles( marvin.GetAngles() )
		wp.SetWaypointGametime( 0, Time() )
		wp.SetWaypointGametime( 1, Time() + cooldownDuration )

		OnThreadEnd(
			function() : ( wp )
			{
				if ( IsValid( wp ) )
					wp.Destroy()
			}
		)

		wait cooldownDuration

		wp.Destroy()
	}
	else if ( data.hasMissingArmBeenAttached )
	{
		if ( IsValid( data.trigger ) )
			data.trigger.Destroy()

		data.marvinState = eMarvinState.PERMANENTLY_DISABLED
		GradeFlagsSet( marvin, eGradeFlags.IS_LOCKED ) // permanently disabled
		GradeFlagsClear( marvin, eGradeFlags.IS_BUSY ) // clear busy use prompt

		return
	}

	data.marvinState = eMarvinState.READY_FOR_POWERUP

	foreach ( entity touchEnt in data.trigger.GetTouchingEntities() )
	{
		if ( touchEnt.IsPlayer() )
			thread TryMarvinPowerUp( marvin, data )
	}
}
#endif


#if CLIENT
void function InstanceMarvinCooldownCreatedWP( entity wp )
{
	entity marvin = wp.GetWaypointEntity( 0 )
	marvin.ai.secondaryWaypoint = wp
}
#endif


#if SERVER
void function LootAndStoryMarvin_OnDamaged( entity marvin, var damageInfo )
{
	//marvin.SetThinkDuringAnimation( true )

	// prevent an arc star impact from killing a MRVN
	int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	float damageAmount = DamageInfo_GetDamage( damageInfo )
	int damageType     = DamageInfo_GetDamageType( damageInfo )

	if ( damageSourceId == eDamageSourceId.mp_weapon_grenade_emp && damageType != DMG_BLAST )
	{
		if ( marvin.GetHealth() - damageAmount <= 0.0 )
			DamageInfo_ScaleDamage( damageInfo, 0.1 )
	}
}
#endif //SERVER

#if SERVER
void function LootAndStoryMarvin_OnKilled( entity marvin, var damageInfo )
{
	if ( marvin in file.spawnedMarvinData )
	{
		MarvinData data = file.spawnedMarvinData[marvin]

		if ( data.hasDetachableArm )
		{
			int attachId     = marvin.LookupAttachment( "FX_L_FOREARM" )
			vector armOrigin = marvin.GetAttachmentOrigin( attachId )
			vector armAngles = marvin.GetAttachmentAngles( attachId )
			vector direction = AnglesToForward( armAngles )

			if ( IsValid( data.armSparkFx ) )
				data.armSparkFx.Destroy()

			StopSoundOnEntity( marvin, SFX_MARVIN_SPARKS )

			marvin.SetBodygroupModelByIndex( marvin.FindBodygroup( BODYGROUP_LEFT_ARM ), BODYGROUP_LEFT_ARM_INDEX_DETACHED )

			ThrowLootParams params
			params.dropOrg               = armOrigin
			params.fwd                   = direction
			params.ref                   = ITEM_MARVIN_ARM_REF
			params.count                 = 1
			params.player                = null
			params.deathBox              = null
			params.throwVelocityRange[0] = 25.0
			params.throwVelocityRange[1] = 50.0

			entity loot = SURVIVAL_ThrowLootFromPointEx( params )
		}

		if ( IsValid( data.trigger ) )
			data.trigger.Destroy()

		if ( IsValid( data.chestWaypoint ) )
			data.chestWaypoint.Destroy()
		
		//PIN_PlayerItemDestruction( DamageInfo_GetAttacker( damageInfo ), ITEM_DESTRUCTION_TYPES.LOOT_MARVIN, { dropped_arm = data.hasDetachableArm } )

		delete file.spawnedMarvinData[marvin]
	}
}
#endif //SERVER

#if SERVER
bool function LootMarvinArm_OnPickup( entity marvinArm, entity playerUser, int pickupFlags, entity deathBox, int ornull desiredCount )
{
	bool result = PickupBackpackItem( marvinArm, playerUser, pickupFlags, deathBox, desiredCount )

	//Remote_CallFunction_NonReplay(playerUser, "ServerCallback_PromptPingLootMarvin", playerUser)
	AttemptPingNearestValidMarvinForPlayer(playerUser)
	return result
}
#endif //SERVER


#if CLIENT
void function ServerCallback_PromptPingLootMarvin ( entity player )
{
	/*AddPingBlockingFunction( "quickchat", void function( entity player ) {
		Remote_CallFunction_NonReplay("ClientCallback_PromptPingLootMarvin")
	}, 6.0, "#PING_LOOT_MARVIN")*/
}
#endif

#if SERVER
void function ClientCallback_PromptPingLootMarvin ( entity player )
{
		AttemptPingNearestValidMarvinForPlayer(player)
}
#endif

#if SERVER
void function AttemptPingNearestValidMarvinForPlayer( entity player )
{

	// get all valid marvins who are available to have an arm attached
	array<entity> validMarvins
	foreach ( entity marvin, MarvinData data in file.spawnedMarvinData )
	{
		if ( !IsAlive( marvin ) || data.hasMissingArmBeenAttached || data.isStoryMarvin )
			continue

		validMarvins.append( marvin )
	}

	if ( validMarvins.len() == 0 )
		return

	array<ArrayDistanceEntry> allResults = ArrayDistanceResults( validMarvins, player.GetOrigin() )
	allResults.sort( DistanceCompareClosest )

	// get the nearest valid marvin in a safe area to ping
	entity nearestMarvin
	for ( int i = 0; i < allResults.len(); i++ )
	{
		entity marvin = allResults[i].ent

		if ( !SURVIVAL_DeathFieldIsValid() )
		{
			nearestMarvin = marvin
			break
		}

		if ( SURVIVAL_PosInSafeZone( marvin.GetOrigin() ) )
		{
			nearestMarvin = marvin
			break
		}
	}

	if ( !IsValid( nearestMarvin ) )
		return


	// ping the nearest valid marvin, only visible to the player who picked up the arm
	entity wp = CreateWaypoint_Ping_Location( player, ePingType.LOOT_MARVIN, nearestMarvin, nearestMarvin.GetOrigin(), -1, false )
	if ( IsValid( wp ) )
		wp.SetAbsOrigin( nearestMarvin.GetOrigin() + <0, 0, 138> )
}
#endif

// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
//
//   ######  ##        #######  ########       ##     ##    ###     ######  ##     ## #### ##    ## ########
//  ##    ## ##       ##     ##    ##          ###   ###   ## ##   ##    ## ##     ##  ##  ###   ## ##
//  ##       ##       ##     ##    ##          #### ####  ##   ##  ##       ##     ##  ##  ####  ## ##
//   ######  ##       ##     ##    ##          ## ### ## ##     ## ##       #########  ##  ## ## ## ######
//        ## ##       ##     ##    ##          ##     ## ######### ##       ##     ##  ##  ##  #### ##
//  ##    ## ##       ##     ##    ##          ##     ## ##     ## ##    ## ##     ##  ##  ##   ### ##
//   ######  ########  #######     ##          ##     ## ##     ##  ######  ##     ## #### ##    ## ########
//
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================

const int WAYPOINT_IDX_STARTTIME = 0
const int WAYPOINT_IDX_EMOTICON = 0
const int WAYPOINT_IDX_HAS_SETTLED = 1


#if SERVER || CLIENT
bool function DoesPlayerHaveMarvinArmInInventory( entity player )
{
	array<ConsumableInventoryItem> playerInventory = SURVIVAL_GetPlayerInventory( player )
	foreach ( invItem in playerInventory )
	{
		LootData lootData = SURVIVAL_Loot_GetLootDataByIndex( invItem.type )

		if ( lootData.ref == ITEM_MARVIN_ARM_REF )
			return true
	}

	return false
}
#endif


#if SERVER
void functionref( entity marvin, entity player, int useFlags ) function CreateOnUseLootMarvinFunc( MarvinData data )
{
	return void function( entity marvin, entity player, int useFlags ) : ( data )
	{
		thread DispenseLootFromMarvin( marvin, player, data )
	}
}
#endif //SERVER


#if SERVER
void function DispenseLootFromMarvin( entity marvin, entity player, MarvinData data )
{
	EndSignal( marvin, "OnDeath" )

	if ( GradeFlagsHas( marvin, eGradeFlags.IS_OPEN ) || GradeFlagsHas( marvin, eGradeFlags.IS_BUSY ) || GradeFlagsHas( marvin, eGradeFlags.IS_LOCKED ) )
	{
		EmitSoundOnEntityOnlyToPlayer( marvin, player, SFX_MARVIN_DENY )
		return
	}

	GradeFlagsSet( marvin, eGradeFlags.IS_BUSY ) // busy use prompt

	// check if player has marvin arm
	bool shouldAttachArm = false

	if ( !data.hasMissingArmBeenAttached ) // defensive, technically should never get this far if arm has been attached.
		shouldAttachArm = DoesPlayerHaveMarvinArmInInventory( player )

	if ( shouldAttachArm )
	{
		marvin.SetBodygroupModelByIndex( marvin.FindBodygroup( BODYGROUP_RIGHT_ARM ), BODYGROUP_RIGHT_ARM_INDEX_ATTACHED_SPECIAL )
		data.hasMissingArmBeenAttached = true
		SURVIVAL_RemoveFromPlayerInventory( player, ITEM_MARVIN_ARM_REF, 1 )
	}

	data.marvinState = eMarvinState.DISPENSING

	// play appropriate loot emoticon sound
	int lootEmoticonIdx = GetDesiredEmoticonIndex( data )
	switch ( lootEmoticonIdx )
	{
		case eMarvinEmoticon.SAD:
			EmitSoundOnEntity( marvin, SFX_LOOT_MARVIN_SLOT_INTERACT_SAD )
			break

		case eMarvinEmoticon.NEUTRAL:
			EmitSoundOnEntity( marvin, SFX_LOOT_MARVIN_SLOT_INTERACT_NEUTRAL )
			break

		case eMarvinEmoticon.PLEASED:
			EmitSoundOnEntity( marvin, SFX_LOOT_MARVIN_SLOT_INTERACT_PLEASED )
			break

		case eMarvinEmoticon.VERY_HAPPY:
			EmitSoundOnEntity( marvin, SFX_LOOT_MARVIN_SLOT_INTERACT_VERY_HAPPY )
			break
	}

	// show marvin/slot machine hand crank
	if ( !shouldAttachArm )
	{
		waitthread PlayAnimLootMarvin( marvin, data.startPoint, ANIM_LOOT_MARVIN_SLOT_CRANK )
		thread PlayAnimLootMarvin( marvin, data.startPoint, ANIM_LOOT_MARVIN_ACTIVE_LOOP )
		marvin.SetActivityModifier( ACT_MODIFIER_STAGGER, false )
	}

	while( !data.hasSlotMachineSettled )
		WaitFrame()

	data.hasSlotMachineSettled = false

	string dispenseAnim
	switch ( data.currentEmoticonIdx )
	{
		case eMarvinEmoticon.NEUTRAL:
			dispenseAnim = ANIM_LOOT_MARVIN_DISPENSE_NEUTRAL
			break

		case eMarvinEmoticon.PLEASED:
			dispenseAnim = ANIM_LOOT_MARVIN_DISPENSE_PLEASED
			break

		case eMarvinEmoticon.VERY_HAPPY:
			dispenseAnim = ANIM_LOOT_MARVIN_DISPENSE_VERY_HAPPY
			break

		default:
			dispenseAnim = ANIM_LOOT_MARVIN_DISPENSE_SAD
			break
	}

	marvin.SetActivityModifier( ACT_MODIFIER_STAGGER, true )
	waitthread PlayAnimLootMarvin( marvin, data.startPoint, dispenseAnim )

	string pinActionName = data.hasMissingArmBeenAttached ? "loot_marvin_dispense_arm" : "loot_marvin_dispense"
	PIN_Interact (player, pinActionName)

	bool shouldPowerDown = !data.hasMissingArmBeenAttached
	thread TryPowerDownMarvin( marvin, data, shouldPowerDown, false )
}
#endif //SERVER


#if SERVER
void function LootMarvin_OnDispenseLootAnimEvent( entity marvin )
{
	if ( !IsAlive( marvin ) )
		return

	if ( !(marvin in file.spawnedMarvinData) )
		return

	MarvinData data = file.spawnedMarvinData[ marvin ]

	string lootGroup
	switch ( data.currentEmoticonIdx )
	{
		case eMarvinEmoticon.NEUTRAL:
			lootGroup = "loot_roller_contents_rare"
			break

		case eMarvinEmoticon.PLEASED:
			lootGroup = "marvin_contents_epic"
			break

		case eMarvinEmoticon.VERY_HAPPY:
			lootGroup = "loot_roller_contents_legendary"
			break

		default:
			lootGroup = "loot_roller_contents_common"
			break
	}

	EmitSoundOnEntity( marvin, SFX_LOOT_MARVIN_DISPERSE )
	thread PlayLootDisperseFx_Thread ( marvin, data.currentEmoticonIdx )

	vector chestOrigin  = marvin.GetAttachmentOrigin( marvin.LookupAttachment( "SCREEN_CENTER" ) )
	int lootThrowVecIdx = 0
	array<vector> lootThrowVectors
	lootThrowVectors.append( FlattenVec( RotateVector( marvin.GetForwardVector(), <0, -45, 0> ) ) )
	lootThrowVectors.append( marvin.GetForwardVector() )
	lootThrowVectors.append( FlattenVec( RotateVector( marvin.GetForwardVector(), <0, 45, 0> ) ) )

	array<string> marvinLootRefs = SURVIVAL_GetMultipleWeightedItemsFromGroup( lootGroup, MAX_LOOT_ITEMS_FROM_MARVIN )

	if ( lootGroup == "loot_roller_contents_legendary" )
	{
		marvinLootRefs.pop()
		marvinLootRefs.append( SURVIVAL_GetWeightedItemFromGroup( "gold_any" ) )
	}

	foreach ( int lootIdx, string itemRef in marvinLootRefs )
	{
		vector direction = lootThrowVectors[ lootThrowVecIdx ]

		ThrowLootParams params
		params.dropOrg               = chestOrigin
		params.fwd                   = direction
		params.ref                   = itemRef
		params.count                 = 1
		params.player                = null
		params.deathBox              = null
		params.throwVelocityRange[0] = 25.0
		params.throwVelocityRange[1] = 150.0

		entity loot = SURVIVAL_ThrowLootFromPointEx( params )

		lootThrowVecIdx++
		if ( lootThrowVecIdx > lootThrowVectors.len() - 1 )
			lootThrowVecIdx = 0
	}
}
#endif


#if SERVER
void function PlayLootDisperseFx_Thread ( entity marvin, int currentEmoticonIdx )
{
	int lootRarity = currentEmoticonIdx + 1

	int particleIdx    = GetParticleSystemIndex( VFX_LOT_MARVIN_DISPERSE )
	int vfxAttachIdx   = marvin.LookupAttachment( "SCREEN_CENTER" )

	//Given ( entity, particleSystemIndex, FX_PATTACH_ attachType, attachmentIndex ),
	entity fxHandle    = StartParticleEffectOnEntity_ReturnEntity( marvin, particleIdx, FX_PATTACH_POINT_FOLLOW, vfxAttachIdx )

	vector rarityColor = GetFXRarityColorForTier( lootRarity )
	EffectSetControlPointVector( fxHandle, 1, rarityColor )

	wait 1

	if ( IsValid (fxHandle) )
		fxHandle.Destroy()
}

void function SlotMachineCycleThink( entity marvin, MarvinData data )
{
	EndSignal( marvin, "OnDeath" )
	EndSignal( marvin, SIGNAL_MARVIN_ON_POWERDOWN )

	EmitSoundOnEntity( marvin, SFX_LOOT_MARVIN_SLOT_LOOP )

	OnThreadEnd(
		function() : ( marvin, data )
		{
			if ( IsValid( data.chestWaypoint ) )
				data.chestWaypoint.Destroy()

			StopSoundOnEntity( marvin, SFX_LOOT_MARVIN_SLOT_LOOP )
		}
	)

	Assert( !IsValid( data.chestWaypoint ), "Marvin already has a valid waypoint entity for his chest screen at: " + marvin.GetOrigin() )

	// this number should be divisible by 0.1 so it plays nice between server and client
	float cycleLength           = GetCurrentPlaylistVarFloat( "marvin_slot_cycle_length", SLOT_MACHINE_CYCLE_LENGTH )
	float cycleLengthServerSafe = cycleLength - 0.01 //extra safe way to keep server aligned with client. Sometimes waiting in clean tenths gets rounded up.

	data.currentEmoticonIdx = eMarvinEmoticon.SAD
	data.chestWaypoint      = CreateWaypoint_Custom( WAYPOINTTYPE_SCREEN )
	data.chestWaypoint.SetOrigin( marvin.GetOrigin() )
	data.chestWaypoint.SetWaypointEntity( 0, marvin )

	data.chestWaypoint.SetWaypointInt( WAYPOINT_IDX_EMOTICON, data.currentEmoticonIdx )
	data.chestWaypoint.SetWaypointInt( WAYPOINT_IDX_HAS_SETTLED, 0 )

	while( true )
	{
		data.chestWaypoint.SetWaypointGametime( WAYPOINT_IDX_STARTTIME, Time() )

		wait cycleLengthServerSafe

		int desiredEmoticonIdx = GetDesiredEmoticonIndex( data )

		data.chestWaypoint.SetWaypointInt( WAYPOINT_IDX_EMOTICON, desiredEmoticonIdx )
		data.currentEmoticonIdx = desiredEmoticonIdx

		if ( data.marvinState == eMarvinState.DISPENSING )
			break
	}

	data.chestWaypoint.SetWaypointInt( WAYPOINT_IDX_HAS_SETTLED, 1 )
	data.hasSlotMachineSettled = true
	StopSoundOnEntity( marvin, SFX_LOOT_MARVIN_SLOT_LOOP )

	WaitForever()
}
#endif // SERVER


#if CLIENT
void function InstanceMarvinScreenCreatedWP( entity wp )
{
	/*entity marvin = wp.GetWaypointEntity( 0 )

	/*if( !IsValid( marvin ) )
	{
		thread Thread_HandleMarvinInvalid ( wp )
		return
	}

	marvin.ai.primaryWaypoint = wp*/
}

/*void function Thread_HandleMarvinInvalid( entity wp )
{
	entity marvin = wp.GetWaypointEntity( 0 )
	while( !IsValid( marvin ) )
	{
		#if DEV
			printf( "Loot Marvin has not yet replicated" )
		#endif
		marvin = wp.GetWaypointEntity( 0 )
		WaitFrame()
	}
	marvin.ai.primaryWaypoint = wp
}*/

#endif


#if SERVER
int function GetDesiredEmoticonIndex( MarvinData data )
{
	int desiredEmoticonIdx = 0

	if ( data.hasMissingArmBeenAttached )
		return eMarvinEmoticon.VERY_HAPPY

	switch ( data.currentEmoticonIdx )
	{
		case eMarvinEmoticon.SAD:
			desiredEmoticonIdx = eMarvinEmoticon.NEUTRAL
			break

		case eMarvinEmoticon.NEUTRAL:
			desiredEmoticonIdx = eMarvinEmoticon.PLEASED
			break

		case eMarvinEmoticon.PLEASED:
			desiredEmoticonIdx = eMarvinEmoticon.SAD
			break
	}

	return desiredEmoticonIdx
}
#endif //SERVER

// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
//
//  ########  ##     ## ####
//  ##     ## ##     ##  ##
//  ##     ## ##     ##  ##
//  ########  ##     ##  ##
//  ##   ##   ##     ##  ##
//  ##    ##  ##     ##  ##
//  ##     ##  #######  ####
//
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================


#if CLIENT
void function OnPlayerLifeStateChanged( entity player, int oldState, int newState )
{
	if ( player == GetLocalViewPlayer() )
	{
		if ( newState != LIFE_ALIVE )
		{

		}
		else if ( IsValid( player ) )
		{
			thread SetTopPriorityLootMarvin( player )
			thread TrackNearestChestScreen( player )
			thread TrackNearestCooldownIndicator( player )
		}
	}
}
#endif


#if CLIENT
void function TrackNearestChestScreen( entity player )
{
	const float MAYA_SCREEN_WIDTH = 5.686
	const float MAYA_SCREEN_HEIGHT = 4.512
	const asset SCREEN_RUI_ASSET = $"ui/ready_up_box.rpak"

	EndSignal( player, "OnDeath" )

	if ( file.chestScreenTopo == null )
		file.chestScreenTopo = CreateRUITopology_Worldspace( <0, 0, 0>, <0, 0, 0>, MAYA_SCREEN_WIDTH, MAYA_SCREEN_HEIGHT )

	if ( file.chestScreenRui == null )
		file.chestScreenRui = RuiCreate( SCREEN_RUI_ASSET, file.chestScreenTopo, RUI_DRAW_WORLD, 0 )

	float cycleLength = GetCurrentPlaylistVarFloat( "marvin_slot_cycle_length", SLOT_MACHINE_CYCLE_LENGTH )
	//RuiSetFloat( file.chestScreenRui, "cycleLength", cycleLength )
	//RuiSetBool( file.chestScreenRui, "isVisible", false )

	OnThreadEnd(
		function () : ()
		{
			//RuiSetBool( file.chestScreenRui, "isVisible", false )
		}
	)

	while( true )
	{
		/*if ( IsValid( file.topPriorityLootMarvin ) && IsValid( file.topPriorityLootMarvin.ai.primaryWaypoint ) )
		{
			entity wp = file.topPriorityLootMarvin.ai.primaryWaypoint
			RuiTopology_SetParent( file.chestScreenTopo, file.topPriorityLootMarvin, "SCREEN_CENTER" )

			RuiSetGameTime( file.chestScreenRui, "startCycleTime", wp.GetWaypointGametime( WAYPOINT_IDX_STARTTIME ) )
			RuiSetBool( file.chestScreenRui, "isVisible", true )
			RuiSetInt( file.chestScreenRui, "emotionIdx", wp.GetWaypointInt( WAYPOINT_IDX_EMOTICON ) )

			if ( wp.GetWaypointInt( WAYPOINT_IDX_HAS_SETTLED ) > 0 )
			{
				RuiSetBool( file.chestScreenRui, "shouldStop", true )
			}
			else
			{
				RuiSetBool( file.chestScreenRui, "shouldStop", false )
			}

			RuiSetGameTime( file.chestScreenRui, "startCycleTime", wp.GetWaypointGametime( WAYPOINT_IDX_STARTTIME ) )
		}
		else*/
		{
			//RuiSetBool( file.chestScreenRui, "isVisible", false )
		}

		WaitFrame()
	}
}
#endif


#if CLIENT
void function TrackNearestCooldownIndicator( entity player )
{
	EndSignal( player, "OnDeath" )

	/*if ( file.cooldownRui == null )
	{
		file.cooldownRui = CreateCockpitRui( $"ui/death_protection_status.rpak", 1 )
		RuiSetFloat3( file.cooldownRui, "worldPosOffset", <0, 0, 0> )
		RuiSetBool( file.cooldownRui, "shouldDesaturate", true )
	}

	OnThreadEnd(
		function () : ()
		{
			RuiSetBool( file.cooldownRui, "isVisible", false )
		}
	)

	while( true )
	{
		if ( IsValid( file.topPriorityLootMarvin ) && IsValid( file.topPriorityLootMarvin.ai.secondaryWaypoint ) )
		{
			entity wp = file.topPriorityLootMarvin.ai.secondaryWaypoint
			RuiTrackFloat3( file.cooldownRui, "worldPos", wp, RUI_TRACK_ABSORIGIN_FOLLOW )
			RuiSetGameTime( file.cooldownRui, "startTime", wp.GetWaypointGametime( 0 ) )
			RuiSetGameTime( file.cooldownRui, "endTime", wp.GetWaypointGametime( 1 ) )

			bool canTrace = false
			bool isFar    = Distance( player.EyePosition(), wp.GetOrigin() ) > 700.0
			if ( !isFar )
			{
				TraceResults results = TraceLine( player.EyePosition(), wp.GetOrigin(), [player], TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )
				canTrace = results.fraction > 0.95
			}

			if ( isFar || !canTrace )
			{
				RuiSetBool( file.cooldownRui, "isVisible", false )
			}
			else
			{
				RuiSetBool( file.cooldownRui, "isVisible", true )
			}
		}
		else
		{
			RuiSetBool( file.cooldownRui, "isVisible", false )
		}

		WaitFrame()
	}*/
}
#endif


#if CLIENT
void function SetTopPriorityLootMarvin( entity player )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )

	while( true )
	{
		array<entity> allMarvins = GetEntArrayByScriptName( LOOT_MARVIN_SCRIPTNAME )
		array<entity> validMarvins

		foreach ( entity marvin in allMarvins )
		{
			if ( !IsAlive( marvin ) )
				continue

			// is the marvin within the view player's viewcone
			float dot    = DotProduct( AnglesToForward( player.CameraAngles() ), Normalize( marvin.GetOrigin() - player.CameraPosition() ) )
			/*float scalar = GetFovScalar( player )

			float minDot  = cos( DEG_TO_RAD * DEFAULT_FOV * 1.3 * scalar )
			bool isInView = dot > minDot

			if ( isInView )
				validMarvins.append( marvin )*/
		}

		array<ArrayDistanceEntry> allResults = ArrayDistanceResults( validMarvins, player.GetOrigin() )
		allResults.sort( DistanceCompareClosest )

		if ( allResults.len() > 0 )
			file.topPriorityLootMarvin = allResults[ 0 ].ent

		wait 0.2
	}
}
#endif 