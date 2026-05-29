global function LootTicks_Init
global function Debug_TestAllStaticLootTickSpawns
global function Debug_SpawnStaticLootTicksAroundMe

#if DEVELOPER
global function DEV_SpawnLootTickAtCrosshair
#endif // DEV

global function LootTicks_GetAllLootTicks
global function LootTicks_SpawnLootTickAtOrigin
global function LootTicks_SpawnLootTickLoot_NoEnt
global function LootTicks_SpawnLootTickLoot
global function LootTicks_GetStaticLootTicksCount

const int DEBUG_DRAW = 1			// Instead of asserting, visually show designers where the issues are happening without crashing.
const int PLAYLIST_STATIC_TICK_ALWAYSHIDE = 1

//---------------------
// Loot tick - Generic
//---------------------
const asset LOOT_TICK_MODEL						= $"mdl/robots/drone_frag/drone_frag_loot.rmdl"
global const asset LOOT_TICK_EYE_FX				 	= $"P_lt_eye_ON_flash_CP"

//---------------------
// Static tick - Generic
//---------------------
const string STATIC_TICK_SCRIPT_NAME 				= "static_loot_tick_spawn"//_test"
const int STATIC_TICK_HEALTH						= 30
const int NUM_STATIC_TICK_LOOT_ITEMS_TO_SPAWN		= 3
const array<string> STATIC_LOOT_TICK_LOOT_TABLES	= [	"loottick_static_01",
														"loottick_static_02",
														"loottick_static_03" ]
                    
                                             
      

const string STATIC_LOOT_TICK_AUDIO_LONG_RANGE_ALERT 	= "LootTick_Vocal_Cheerful"//"wpn_arctrap_beep"
const string STATIC_LOOT_TICK_AUDIO_CQB_ALERT 			= "LootTick_Vocal_Concerned"//"weapon_proximitymine_armedbeep"
const string STATIC_LOOT_TICK_AUDIO_SUPER_CQB_ALERT		= "LootTick_Vocal_Fleeing"//"weapon_proximitymine_armedbeep"
const string STATIC_LOOT_TICK_AUDIO_LOOP	 			= "LootTick_IdleShiver"

                    
const string STATIC_LOOT_TICK_AUDIO_LONG_RANGE_ALERT_GH 	= "Goldenhorse_LootTick_Cactuar_Cheerful"
const string STATIC_LOOT_TICK_AUDIO_CQB_ALERT_GH 			= "Goldenhorse_LootTick_Cactuar_Concerned"
const string STATIC_LOOT_TICK_AUDIO_SUPER_CQB_ALERT_GH		= "Goldenhorse_LootTick_Cactuar_Fleeing"
const string STATIC_LOOT_TICK_AUDIO_LOOP_GH	 				= "Goldenhorse_LootTick_Cactuar_IdleShiver"
      

const float STATIC_LOOT_TICK_LONG_RANGE_ALERT_INTERVAL	= 9.0
const float STATIC_LOOT_TICK_LONG_RANGE_ALERT_VARIANCE	= 2.0
const float STATIC_LOOT_TICK_CQB_ALERT_INTERVAL			= 2.0
const float STATIC_LOOT_TICK_CQB_ALERT_VARIANCE			= 5.0
const float STATIC_LOOT_TICK_SUPER_CQB_ALERT_INTERVAL	= 1.0
const float STATIC_LOOT_TICK_SUPER_CQB_ALERT_VARIANCE	= 5.0

const int TICK_AUDIO_STATE_NOALERT						= 0
const int TICK_AUDIO_STATE_LONG_RANGE_ALERT				= 1
const int TICK_AUDIO_STATE_CQB_ALERT					= 2
const int TICK_AUDIO_STATE_SUPER_CQB_ALERT				= 3


const float STATIC_TICK_HIDE_AND_SEEK_MIN_OPEN_TIME 		= 1.0
const float STATIC_TICK_HIDE_AND_SEEK_DIST_SUPER_CQB_SQ 	= 176.0 * 176.0
const float STATIC_TICK_HIDE_AND_SEEK_DIST_CQB_SQ 			= 768.0 * 768.0

const float STATIC_TICK_HIDE_AND_SEEK_TRIGGER_RADIUS = 1024.0

//---------------------
// Static tick - Peek a boo behavior
//---------------------
const string STATIC_TICK_ANIM_OPEN_IDLE 		= "sd_search_idle"

const int TICK_STATE_OPEN 		= 1
const int TICK_STATE_CLOSE		= 2
const float STATIC_TICK_MAX_DIST_TO_SCARE			= 256.0
const float STATIC_TICK_MAX_DIST_TO_SCARE_SQ		= STATIC_TICK_MAX_DIST_TO_SCARE * STATIC_TICK_MAX_DIST_TO_SCARE
const float STATIC_TICK_MAX_CROUCH_DIST_TO_SCARE_SQ	= 64.0 * 64.0 //128.0 * 128.0
const float STATIC_TICK_AWAKEN_DIST					= STATIC_TICK_MAX_DIST_TO_SCARE + 128.0
const float STATIC_TICK_AWAKEN_DIST_SQ				= STATIC_TICK_AWAKEN_DIST * STATIC_TICK_AWAKEN_DIST
const float STATIC_TICK_PEEK_INTERVAL				= 2.5
const float STATIC_TICK_PEEK_DURATION				= 0.7		// Period of time the script checks if the area is safe
const float STATIC_TICK_MIN_AWAKEN_PLAYER_HIDE_TIME	= 1.0

struct StaticLootTickData
{
                     
              
       
	vector launchDir

	int tickState 					= TICK_STATE_OPEN
	bool tickInOpenIdle				= true
	float peekIntervalTime     		= 0.0
	bool tickHasPeeked         		= false
	float lastPeekIntervalTime 		= 0.0
	float peekStartTime        		= 0.0
	bool tickCouldSeePlayer			= false
	float lastSeenPlayerTime		= 0.0

	int tickAudioState				= TICK_AUDIO_STATE_NOALERT

	array<string> lootRefs
}

struct
{
	table<entity, StaticLootTickData> spawnedStaticLootTicks
	int allLootTicksScriptManagedEntArrayID
	int staticTickState = -1

	bool registeredFields = false
} file

void function LootTicks_Init()
{
	AddCallback_EntitiesDidLoad( OnEntitiesDidLoad, eEntitiesDidLoadPriority.HIGH )
}

void function OnEntitiesDidLoad()
{
	bool hasStaticTickLocations = HasEntWithScriptName( STATIC_TICK_SCRIPT_NAME )
	if ( ( hasStaticTickLocations && LootTicks_GetStaticLootTicksCount() > 0 ) || HasDynamicLootTicks() )
	{
		RegisterLootTickFields_Internal()

		bool useStaticLootTicks = GetCurrentPlaylistVarBool( "enable_static_loot_ticks", true ) && hasStaticTickLocations

		                    
			if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_GOLDEN_HORSE ) )
				useStaticLootTicks = false
        

		if ( useStaticLootTicks )
		{
			file.staticTickState = PLAYLIST_STATIC_TICK_ALWAYSHIDE
		}

		if ( useStaticLootTicks )
		{
			SpawnStaticLootTicks()
		}
		else
		{
			CleanUpStaticLootTickSpawns()
		}
	}
	else if ( hasStaticTickLocations )
	{
		CleanUpStaticLootTickSpawns()
	}
}

void function RegisterLootTickFields_Internal()
{
	PrecacheParticleSystem( LOOT_TICK_EYE_FX )
	PrecacheEntity( "npc_frag_drone" )
	PrecacheModel( LOOT_TICK_MODEL )

	file.allLootTicksScriptManagedEntArrayID = CreateScriptManagedEntArray()

	file.registeredFields = true
}

bool function HasDynamicLootTicks()
{
	#if DEVELOPER
		if ( DEV_ForceLoadAllEntityTypes() )
			return true
	#endif
                    
                                                             
              
       
	                               
		//if ( Valentines_S15_SpawnTicks() )
		//	return true
       
	                    
		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_GOLDEN_HORSE ) && GoldenHorse_TicksEnabled() )
			return true
       
	                  
		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_THE_HUNT ) )
			return true
       

	if( POIPlayerSpawning_Exists() )
		return true

	return false
}

array<entity> function LootTicks_GetAllLootTicks()
{
	Assert( file.registeredFields, " Warning! Must register fields from _LootTicks_OnEntitiesDidLoad before getting all loot ticks. If this is after EntitiesDidLoad you may need to add a case to HasDynamicLootTicks()" )

	int arrayID = file.allLootTicksScriptManagedEntArrayID
	array<entity> lootTicks = GetScriptManagedEntArray( arrayID )
	return lootTicks
}

entity function LootTicks_SpawnLootTickAtOrigin( vector origin, vector angles, array<string>lootRefs, int lootTier = 4 )
{
	entity tick = SpawnStaticLootTick( origin, angles )

	tick.SetHealth( 1 )

	StaticLootTickData data
                     
                                           
       
	data.launchDir = <0, 0, 1>

	data.lootRefs = lootRefs
	tick.ai.lootTickHighestLootLevel = lootTier

	file.spawnedStaticLootTicks[ tick ] <- data

	thread StaticLootTickBehavior( tick )

	return tick
}

void function LootTicks_SpawnLootTickLoot( entity tick, vector origin, vector launchDir, array<string> lootRefs )
{
	LootTicks_SpawnLootTickLoot_NoEnt( origin, tick.GetUpVector(), launchDir, lootRefs )
}

void function LootTicks_SpawnLootTickLoot_NoEnt( vector origin, vector upDir, vector launchDir, array<string> lootRefs )
{
	array<string> itemRefs = lootRefs// = SURVIVAL_SampleLootGroup( LOOT_TICK_TABLE_MEDIUM, NUM_LOOT_ITEMS_TO_SPAWN )
	bool debugLootTicks = GetCurrentPlaylistVarInt( "debug_loot_ticks", 0 ) == 1

	if ( debugLootTicks )
		printt( "---" )

	int numToSpawn = lootRefs.len()

	for( int i; i < numToSpawn; i++ )
	{
		string itemRef = itemRefs[ i ]

		if ( itemRef == "blank" )
			continue

		LootData data = SURVIVAL_Loot_GetLootDataByRef( itemRef )

		vector randFwd = RandomVecInDomeWithFOV( launchDir, 45 ) * 1.2
		randFwd = Normalize( randFwd + (upDir * 0.35) )

		SURVIVAL_ThrowLootFromPoint( origin, randFwd , itemRef, data.countPerDrop )
	}

	if ( debugLootTicks )
		printt( "---" )
}

int function LootTicks_GetStaticLootTicksCount()
{
	return GetCurrentPlaylistVarInt( "num_static_loot_ticks_to_spawn", 12 )
}

// ----------------------------------------------------------------------------------------------------------
//
// ███████╗████████╗ █████╗ ████████╗██╗ ██████╗    ████████╗██╗ ██████╗██╗  ██╗███████╗
// ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝██║██╔════╝    ╚══██╔══╝██║██╔════╝██║ ██╔╝██╔════╝
// ███████╗   ██║   ███████║   ██║   ██║██║            ██║   ██║██║     █████╔╝ ███████╗
// ╚════██║   ██║   ██╔══██║   ██║   ██║██║            ██║   ██║██║     ██╔═██╗ ╚════██║
// ███████║   ██║   ██║  ██║   ██║   ██║╚██████╗       ██║   ██║╚██████╗██║  ██╗███████║
// ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝       ╚═╝   ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝
//
// ----------------------------------------------------------------------------------------------------------

void function StaticLootTickBehavior( entity tick )
{
	Assert( file.registeredFields, " Warning! Must register fields from _LootTicks_OnEntitiesDidLoad before handling loot tick behavior. If this is after EntitiesDidLoad you may need to add a case to HasDynamicLootTicks()" )

	EndSignal( tick, "OnDeath" )
	EndSignal( tick, "OnDestroy" )

	StaticLootTickData data = file.spawnedStaticLootTicks[ tick ]
	thread PlayAnim( tick, STATIC_TICK_ANIM_OPEN_IDLE )

	array<entity> eyeFx
	int fxIdx = GetParticleSystemIndex( LOOT_TICK_EYE_FX )
	array< string > fxAttachPoints = [ "FX_L_EYE", "FX_R_EYE", "FX_C_EYE" ]
	foreach( string attachPoint in fxAttachPoints )
	{
		int attachIdx = tick.LookupAttachment( attachPoint )
		entity newFx = StartParticleEffectOnEntity_ReturnEntity( tick, fxIdx, FX_PATTACH_POINT_FOLLOW, attachIdx )
		eyeFx.append( newFx )
		EffectSetControlPointColorById( newFx, 1, GetLootTickEyeColor( tick.ai.lootTickHighestLootLevel ) )
	}

	entity trig = CreateStaticTickTrigger( tick )
	thread StaticLootTickAudioController( tick, data )

	SetLootTickSkin( tick )

	OnThreadEnd(
		function() : ( trig, eyeFx )
		{
			trig.Destroy()
			foreach( entity fx in eyeFx )
				fx.Destroy()
		}
	)

	int prevNumTouchingEntities
	bool tickWasAwake
	float lastStateChangeTime = 0.0
	while ( true )
	{
		int numTouchingEntities = trig.GetTouchingEntities().len()
		if ( numTouchingEntities == 0 )
		{
			if ( prevNumTouchingEntities != 0 )
			{
				data.tickAudioState = TICK_AUDIO_STATE_NOALERT
			}

			tick.LagCompensate( false )
			tickWasAwake = false
			trig.WaitSignal( "OnStartTouch", "OnEndTouch" )
		}
		else
			wait 0.1

		if ( !tickWasAwake )
		{
			tickWasAwake = true
			tick.LagCompensate( true )
		}

		entity ornull closestPlayerRaw = GetClosestEnemyToLootTick( tick )
		if ( IsValid( closestPlayerRaw ) )
		{
			entity closestPlayer = expect entity ( closestPlayerRaw )
			float distSQ = DistanceSqr( closestPlayer.GetOrigin(), tick.GetOrigin() )

			if ( ( distSQ > STATIC_TICK_HIDE_AND_SEEK_DIST_CQB_SQ ) )
			{
				if ( data.tickAudioState != TICK_AUDIO_STATE_LONG_RANGE_ALERT )
					data.tickAudioState = TICK_AUDIO_STATE_LONG_RANGE_ALERT
			}
			else if ( ( distSQ > STATIC_TICK_HIDE_AND_SEEK_DIST_SUPER_CQB_SQ ) )
			{
				if ( data.tickAudioState != TICK_AUDIO_STATE_CQB_ALERT )
					data.tickAudioState = TICK_AUDIO_STATE_CQB_ALERT
			}
			else if ( ( distSQ < STATIC_TICK_HIDE_AND_SEEK_DIST_SUPER_CQB_SQ ) )
			{
				if ( data.tickAudioState != TICK_AUDIO_STATE_SUPER_CQB_ALERT )
					data.tickAudioState = TICK_AUDIO_STATE_SUPER_CQB_ALERT
			}
		}

		prevNumTouchingEntities = numTouchingEntities
	}
}


int function GetLootTickEyeColor( int lootTier )
{
	switch( lootTier )
	{
                               
		//case VALENTINES_SPECIAL_EVENT_LOOT_TIER:
		//	return COLORID_HUD_LOOT_TIER_SPECIAL
      
                    
			//TODO: This is stub for golden horse - replace eye color to match
		//case GOLDEN_HORSE_SPECIAL_EVENT_LOOT_TIER:
		//	return COLORID_HUD_LOOT_TIER_GH
      
		default:
			return    COLORID_FX_LOOT_TIER0 + lootTier
	}

	return COLORID_FX_LOOT_TIER0 + lootTier
}


void function SetLootTickSkin( entity tick )
{
	int skindex = -1
	switch( tick.ai.lootTickHighestLootLevel )
	{
                    
		case GOLDEN_HORSE_SPECIAL_EVENT_LOOT_TIER:
			skindex = tick.GetSkinIndexByName( "epic_ragold" )
			break
      
	}
	if ( skindex != -1 )
		tick.SetSkin( skindex )
}

void function StaticLootTickAudioController( entity tick, StaticLootTickData data )
{
	EndSignal( tick, "OnDeath" )
	EndSignal( tick, "OnDestroy" )

	// Hack. Wait until tick is non-null.
	while( !IsValid( tick ) )
		WaitFrame()

	int curTickAudioState                = TICK_AUDIO_STATE_NOALERT
	float lastAlertTime
	float nextLongRangeAlertWaitTime     = GetStaticLootTickNextLongRangeAlertWaitTime()
	float nextCQBAlertWaitTime           = GetStaticLootTickNextCQBAlertWaitTime()
	float nextSuperCQBAlertWaitTime      = GetStaticLootTickNextSuperCQBAlertWaitTime()
	float lastCQBLoopStartTime           = Time()
	float CQB_LOOP_SOUND_DURATION_HACK   = 15.0

	// Hack to ensure there are players when the idle loop sound tries to start
	wait 10

	                    
		if(tick.ai.lootTickHighestLootLevel == GOLDEN_HORSE_SPECIAL_EVENT_LOOT_TIER)
			EmitSoundOnEntity( tick, STATIC_LOOT_TICK_AUDIO_LOOP_GH )
		else
       
	EmitSoundOnEntity( tick, STATIC_LOOT_TICK_AUDIO_LOOP )

	while ( true )
	{
		float timeSinceLastAlert = Time() - lastAlertTime
		curTickAudioState = data.tickAudioState
		switch( curTickAudioState )
		{
			case TICK_AUDIO_STATE_NOALERT:
				break

			case TICK_AUDIO_STATE_LONG_RANGE_ALERT:
				if ( ( timeSinceLastAlert - nextLongRangeAlertWaitTime ) > 0 )
				{
					                    
						if(tick.ai.lootTickHighestLootLevel == GOLDEN_HORSE_SPECIAL_EVENT_LOOT_TIER)
							EmitSoundOnEntity( tick, STATIC_LOOT_TICK_AUDIO_LONG_RANGE_ALERT_GH )
						else
           
					EmitSoundOnEntity( tick, STATIC_LOOT_TICK_AUDIO_LONG_RANGE_ALERT )
					nextLongRangeAlertWaitTime = GetStaticLootTickNextLongRangeAlertWaitTime()
					lastAlertTime = Time()
				}
				break

			case TICK_AUDIO_STATE_CQB_ALERT:
				if ( ( timeSinceLastAlert - nextCQBAlertWaitTime ) > 0 )
				{
					                    
						if(tick.ai.lootTickHighestLootLevel == GOLDEN_HORSE_SPECIAL_EVENT_LOOT_TIER)
							EmitSoundOnEntity( tick, STATIC_LOOT_TICK_AUDIO_CQB_ALERT_GH )
						else
           
					EmitSoundOnEntity( tick, STATIC_LOOT_TICK_AUDIO_CQB_ALERT )
					nextCQBAlertWaitTime = GetStaticLootTickNextCQBAlertWaitTime()
					lastAlertTime = Time()
				}
				break

			case TICK_AUDIO_STATE_SUPER_CQB_ALERT:
				if ( ( timeSinceLastAlert - nextCQBAlertWaitTime ) > 0 )
				{
					                    
						if(tick.ai.lootTickHighestLootLevel == GOLDEN_HORSE_SPECIAL_EVENT_LOOT_TIER)
							EmitSoundOnEntity( tick, STATIC_LOOT_TICK_AUDIO_SUPER_CQB_ALERT_GH )
						else
           
					EmitSoundOnEntity( tick, STATIC_LOOT_TICK_AUDIO_SUPER_CQB_ALERT )
					nextSuperCQBAlertWaitTime = GetStaticLootTickNextSuperCQBAlertWaitTime()
					lastAlertTime = Time()
				}
				break
		}

		wait 0.099
	}
}

float function GetStaticLootTickNextLongRangeAlertWaitTime()
{
	return STATIC_LOOT_TICK_LONG_RANGE_ALERT_INTERVAL + ( RandomFloatRange( -STATIC_LOOT_TICK_LONG_RANGE_ALERT_VARIANCE, STATIC_LOOT_TICK_LONG_RANGE_ALERT_VARIANCE ) * 0.5 )
}

float function GetStaticLootTickNextCQBAlertWaitTime()
{
	return STATIC_LOOT_TICK_CQB_ALERT_INTERVAL + ( RandomFloatRange( -STATIC_LOOT_TICK_CQB_ALERT_VARIANCE, STATIC_LOOT_TICK_CQB_ALERT_VARIANCE ) * 0.5 )
}
float function GetStaticLootTickNextSuperCQBAlertWaitTime()
{
	return STATIC_LOOT_TICK_SUPER_CQB_ALERT_INTERVAL + ( RandomFloatRange( -STATIC_LOOT_TICK_SUPER_CQB_ALERT_VARIANCE, STATIC_LOOT_TICK_SUPER_CQB_ALERT_VARIANCE ) * 0.5 )
}

void function StaticLootTick_SetToOpenIdle( entity tick, StaticLootTickData data )
{
	data.tickInOpenIdle = true
	data.tickState = TICK_STATE_OPEN
	thread PlayAnimGravity( tick, STATIC_TICK_ANIM_OPEN_IDLE )
}

array<entity> function GetLivingNonPhasedNonCloakedPlayers()
{
	array<entity> allPlayers = GetPlayerArray()
	array<entity> results
	foreach( player in allPlayers )
	{
		if ( !IsAlive( player ) )
			continue
		if ( player.IsCloaked( true ) )
			continue
		if ( player.GetNoTarget() )
			continue
		if ( player.IsPlayer() && player.IsPhaseShifted() )
			continue

		results.append( player )
	}

	return results
}

const float LOOT_TICK_MAX_RELEVANT_PLAYER_DIST_SQ = 1024.0 * 1024.0
entity ornull function GetClosestEnemyToLootTick( entity tick )
{
	array<entity> validPlayers = GetLivingNonPhasedNonCloakedPlayers()
	entity closestPlayer
	float closestDistSq        = LOOT_TICK_MAX_RELEVANT_PLAYER_DIST_SQ
	vector tickOrigin          = tick.GetOrigin()

	foreach( player in validPlayers )
	{
		float distSq = DistanceSqr( tickOrigin, player.GetOrigin() )
		if ( distSq < closestDistSq )
		{
			closestPlayer = player
			closestDistSq = distSq
		}
	}

	return closestPlayer
}

bool function StaticLootTicksDoAlwaysHidingBehavior()
{
	return file.staticTickState == PLAYLIST_STATIC_TICK_ALWAYSHIDE
}

int function GetStatickTickBehavior()
{
	return GetCurrentPlaylistVarInt( "static_loot_tick_behavior", 1 )
}

entity function CreateStaticTickTrigger( entity tick )
{
	entity trig = CreateEntity( "trigger_cylinder" )
	trig.SetCylinderRadius( STATIC_TICK_HIDE_AND_SEEK_TRIGGER_RADIUS )
	trig.SetAboveHeight( STATIC_TICK_AWAKEN_DIST )
	trig.SetBelowHeight( STATIC_TICK_AWAKEN_DIST )
	trig.SetOrigin( tick.GetOrigin() )
	trig.kv.triggerFilterNpc = "none"
	trig.kv.triggerFilterPlayer = "all"
	trig.kv.triggerFilterNonCharacter = "0"
	trig.SetOwner( tick )
	DispatchSpawn( trig )

	return trig
}

// ----------------------------------------------------------------------------------------------------------
//
// ███████╗██████╗  █████╗ ██╗    ██╗███╗   ██╗    ████████╗██╗ ██████╗██╗  ██╗███████╗
// ██╔════╝██╔══██╗██╔══██╗██║    ██║████╗  ██║    ╚══██╔══╝██║██╔════╝██║ ██╔╝██╔════╝
// ███████╗██████╔╝███████║██║ █╗ ██║██╔██╗ ██║       ██║   ██║██║     █████╔╝ ███████╗
// ╚════██║██╔═══╝ ██╔══██║██║███╗██║██║╚██╗██║       ██║   ██║██║     ██╔═██╗ ╚════██║
// ███████║██║     ██║  ██║╚███╔███╔╝██║ ╚████║       ██║   ██║╚██████╗██║  ██╗███████║
// ╚══════╝╚═╝     ╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═══╝       ╚═╝   ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝
//
// ----------------------------------------------------------------------------------------------------------

void function SpawnStaticLootTicks()
{
	string staticTickScriptName = STATIC_TICK_SCRIPT_NAME

	int numToSpawn = LootTicks_GetStaticLootTicksCount()
	array<entity> allStaticTickSpawns = GetEntArrayByScriptName( staticTickScriptName )
	array<entity> staticTickSpawns = RandomOrientedGridDistribution( allStaticTickSpawns, numToSpawn )
	int numSpawns = staticTickSpawns.len()
	if ( numToSpawn > numSpawns && !IsTestMap() )
		Warning( "Not enough tick spawns for specified number of static tick spawns! [" + numSpawns + "/" + numToSpawn + "]" )

	int j
	for( int i = 0; i < numSpawns; i++ )
	{
		entity spawn = staticTickSpawns.pop()

		if ( !IsValid( spawn ) )
			continue

		vector origin = spawn.GetOrigin()
		vector angles = < 0, 0, 0 >
		entity tick = SpawnStaticLootTick( origin, angles )

		tick.SetHealth( 1 )

		StaticLootTickData data
                      
                                            
        
		data.launchDir = AnglesToForward( spawn.GetAngles() )

		for( int k; k < NUM_STATIC_TICK_LOOT_ITEMS_TO_SPAWN; k++ )
		{
			data.lootRefs.append( SURVIVAL_GetWeightedItemFromGroup( STATIC_LOOT_TICK_LOOT_TABLES[ k ] ) )

			int lootTier = SURVIVAL_Loot_GetLootDataByRef( data.lootRefs[ k ] ).tier
			if ( lootTier > tick.ai.lootTickHighestLootLevel )
				tick.ai.lootTickHighestLootLevel = lootTier
		}

		file.spawnedStaticLootTicks[ tick ] <- data

		thread StaticLootTickBehavior( tick )

		j++
		if ( ( j >= numToSpawn ) )
			break
	}

	CleanUpStaticLootTickSpawns()
}

void function CleanUpStaticLootTickSpawns()
{
	if ( GetBugReproNum() == 1007 )
		return

	array<entity> staticTickSpawns = GetEntArrayByScriptName( STATIC_TICK_SCRIPT_NAME )
	printt( FUNC_NAME(), "- deleting loot tick spawns:", staticTickSpawns.len() )

	foreach( entity spawn in staticTickSpawns )
	{
		spawn.Destroy()
	}
}

// HEADS UP: TO USE, MUST COMMENT OUT DELETING ALL SPAWNS ABOVE.
void function Debug_TestAllStaticLootTickSpawns()
{
	array<entity> staticTickSpawns = GetEntArrayByScriptName( STATIC_TICK_SCRIPT_NAME )
	array<entity> tempLootTicks
	int curTickCount
	int totalTickCount

	printt( "!!! TESTING ALL LOOT TICK POSITIONS !!!" )

	foreach( spawn in staticTickSpawns )
	{
		vector origin = spawn.GetOrigin()
		vector angles = spawn.GetAngles()
		entity tick = SpawnStaticLootTick( origin, angles )
		tempLootTicks.append( tick )
		curTickCount++
		totalTickCount++

		if ( curTickCount == 10 )
		{
			WaitFrame()
			for( int i = 9; i >= 0; i-- )
			{
				tempLootTicks[ i ].Destroy()
				tempLootTicks.fastremove( i )
			}
			curTickCount = 0
			printt( "Clearing set of 10 ticks! Tested:", totalTickCount, "so far." )
		}
	}
	printt( "All (", totalTickCount, ") tick spawns tested!" )
}

const float DEBUG_NEARBY_SPAWN_RADIUS = 1024.0
void function Debug_SpawnStaticLootTicksAroundMe( entity player )
{
	if ( !( GetBugReproNum() == 1007 ) )
	{
		Warning ( "Must set bug repro num to 1007!" )
		return
	}

	array< entity > staticTickSpawns = GetEntArrayByScriptName( STATIC_TICK_SCRIPT_NAME )

	if ( staticTickSpawns.len() == 0 )
		Warning ( "No tick spawns! Reload the map after setting bug repro num!" )

	array< entity > nearbySpawns
	vector playerOrigin = player.GetOrigin()
	foreach( entity spawn in staticTickSpawns )
	{
		vector origin = spawn.GetOrigin()
		float distToPlayer = Distance( playerOrigin, origin )

		if ( distToPlayer < DEBUG_NEARBY_SPAWN_RADIUS )
		{
			entity tick = SpawnStaticLootTick( origin, spawn.GetAngles() )
			StaticLootTickData data
			for( int k; k < NUM_STATIC_TICK_LOOT_ITEMS_TO_SPAWN; k++ )
			{
				data.lootRefs.append( SURVIVAL_GetWeightedItemFromGroup( STATIC_LOOT_TICK_LOOT_TABLES[ k ] ) )

				int lootTier = SURVIVAL_Loot_GetLootDataByRef( data.lootRefs[ k ] ).tier
				if ( lootTier > tick.ai.lootTickHighestLootLevel )
					tick.ai.lootTickHighestLootLevel = lootTier
			}

			data.launchDir = AnglesToForward( spawn.GetAngles() )
			file.spawnedStaticLootTicks[ tick ] <- data

			thread StaticLootTickBehavior( tick )
		}
	}
}

entity function SpawnStaticLootTick( vector spawnPos, vector spawnAngles )
{
	Assert( file.registeredFields, " Warning! Must register fields from _LootTicks_OnEntitiesDidLoad before spawning loot ticks. If this is after EntitiesDidLoad you may need to add a case to HasDynamicLootTicks()" )

	entity newTick = CreateNPC( "npc_frag_drone", TEAM_TICK, spawnPos, < 0, 0, 0 > )
	SetSpawnOption_AISettings( newTick, "npc_frag_drone_treasure_tick" )
	DispatchSpawn( newTick )
	newTick.SetSkin( 1 )
	newTick.ai.lootTickExplode = true
	newTick.SetCanBeMeleed( true )
	newTick.e.canBeDamagedFromGas = false

	if ( GetCurrentPlaylistVarInt( "debug_loot_ticks", 0 ) == 1 )
	{
		printt( "Loot tick spawned @", spawnPos, newTick.GetEntIndex() )
		DebugDrawSphere( spawnPos, 128, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 600 )
	}

	int arrayID = file.allLootTicksScriptManagedEntArrayID
	AddToScriptManagedEntArray( arrayID, newTick )

	newTick.SetAngles( spawnAngles )
	newTick.EnableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING )
	newTick.DisableNPCFlag( NPC_ALLOW_PATROL )
	AddEntityCallback_OnKilled( newTick, OnStaticLootTickKilled )
	GrappleAutoAim_AddTarget( newTick )
	newTick.SetMaxHealth( STATIC_TICK_HEALTH )
	newTick.SetHealth( STATIC_TICK_HEALTH )
	AddSonarDetectionForPropScript( newTick )
	AddEMPDamageDevice( newTick )
	//newTick.SetThinkDuringAnimation( false )
	return newTick
}

#if DEVELOPER
entity function DEV_SpawnLootTickAtCrosshair( entity player, string skin = "" )
{
	vector origin = GetPlayerCrosshairOrigin( player )
	vector eyeAngles = player.EyeAngles()
	vector angles = <0.0, (eyeAngles.y + 180.0), 0.0>

	entity tick = SpawnStaticLootTick( origin, angles )

	tick.SetHealth( 1 )
	SetSkinByName_Safe( tick, skin )

	StaticLootTickData data
                     
                                           
       
	data.launchDir = AnglesToForward( eyeAngles )

	for( int k; k < NUM_STATIC_TICK_LOOT_ITEMS_TO_SPAWN; k++ )
	{
		data.lootRefs.append( SURVIVAL_GetWeightedItemFromGroup( STATIC_LOOT_TICK_LOOT_TABLES[ k ] ) )

		int lootTier = SURVIVAL_Loot_GetLootDataByRef( data.lootRefs[ k ] ).tier
		if ( lootTier > tick.ai.lootTickHighestLootLevel )
			tick.ai.lootTickHighestLootLevel = lootTier
	}

	file.spawnedStaticLootTicks[ tick ] <- data

	thread StaticLootTickBehavior( tick )

	AddToUltimateRealm( player, tick )
	return tick
}
#endif // DEV

void function OnStaticLootTickKilled( entity lootTick, var damageInfo )
{
	// Only handle static and pack roaming
	if ( lootTick in file.spawnedStaticLootTicks )
	{
		vector origin            	= lootTick.GetOrigin()
		StaticLootTickData data 	= file.spawnedStaticLootTicks[ lootTick ]

		LootTicks_SpawnLootTickLoot( lootTick, origin, data.launchDir, data.lootRefs )
                      
                                                   
        

		delete file.spawnedStaticLootTicks[ lootTick ]
	}
}