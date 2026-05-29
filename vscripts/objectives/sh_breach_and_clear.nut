#if SERVER

global function BreachableRoomInitNew
global function BreachableRoomCleanupNew
global function RoomGetsBreachedNew
global function DoorMakeBreachable
global function DoorClearBreachable
global function IsValidBreachDamage
global function IsDoorBreachable
global function DoorRestoreNavAndDeleteHints

const float BREACH_DELAY_BEFORE_NPCS_WAKE_UP = 0.5

enum eBreachableRoomSize
{
	XSMALL,
	SMALL,
	MEDIUM,
	LARGE,
	EXTRA_LARGE
}

enum eBreachMethod
{
	DAMAGED_ENEMIES_PRE_BREACH,
	DESTROYED_DOOR,
	TIMEOUT,
	PLAYER_GOT_INSIDE_ALT_ROUTE
}

enum eBreachedEnemyCategory
{
	FREED_FROM_ROOM,
	FREED_FROM_CAGE,
	AMBIENT_HORDE
}

global struct BreachableRoomData
{
	bool isBreached
	entity proximityTrigger
	bool playersNearby
	array <InfantrySpawn> infantrySpawns
	array <entity> doors
	array <entity> enemies
	int numberOfEnemiesToSpawn
	int roomSize
	array <entity> breachEarlyOutTriggers
	array<int> npcTypes
}

/*
=======================================================================================================================
=======================================================================================================================
=======================================================================================================================

########  ########  ########    ###     ######  ##     ##    ###    ########  ##       ########       ########   #######   #######  ##     ##  ######
##     ## ##     ## ##         ## ##   ##    ## ##     ##   ## ##   ##     ## ##       ##             ##     ## ##     ## ##     ## ###   ### ##    ##
##     ## ##     ## ##        ##   ##  ##       ##     ##  ##   ##  ##     ## ##       ##             ##     ## ##     ## ##     ## #### #### ##
########  ########  ######   ##     ## ##       ######### ##     ## ########  ##       ######         ########  ##     ## ##     ## ## ### ##  ######
##     ## ##   ##   ##       ######### ##       ##     ## ######### ##     ## ##       ##             ##   ##   ##     ## ##     ## ##     ##       ##
##     ## ##    ##  ##       ##     ## ##    ## ##     ## ##     ## ##     ## ##       ##             ##    ##  ##     ## ##     ## ##     ## ##    ##
########  ##     ## ######## ##     ##  ######  ##     ## ##     ## ########  ######## ########       ##     ##  #######   #######  ##     ##  ######

=======================================================================================================================
=======================================================================================================================
=======================================================================================================================
*/

BreachableRoomData function BreachableRoomInitNew( ObjectiveInstance objInstance, SkitInstance skitInstance, ResourceGroup resourceGroup, array<int> npcTypes )
{
	//----------------
	// init room struct
	//----------------
	BreachableRoomData room
	room.isBreached = false
	room.npcTypes = npcTypes

	//spawns just inside the rooms
	room.infantrySpawns = ORS_GetInfantrySpawnsFromGroups( [ resourceGroup ], [ RES_KEYWORD_INDOORS ], [] )
	Assert( room.infantrySpawns.len() > 0, "No infantry spawns found for resource group at " + resourceGroup.core.spawnOrigin + ", check indoor/outdoor keywords"  )

	//-------------------
	// Doors to the room
	//--------------------
	array<ResourceDoor> doorResources = ORS_GetDoorResourcesFromGroups( [ resourceGroup ], [], [ RES_KEYWORD_INDOORS ] )
	Assert( doorResources.len() > 0, "No door resources found for resource group at " + resourceGroup.core.spawnOrigin  )
	room.roomSize = GetRoomSize( resourceGroup )
	room.numberOfEnemiesToSpawn = GetNpcNumberEnemiesToSpawnForRoomSize( room.roomSize )

	//----------------------------------------------------------------------------------
	// Trigger POIs where player can get in without breaching (skylights, holes, windows
	//----------------------------------------------------------------------------------
	array<PointOfInterest> triggerPOIResources = ORS_GetPOIResourcesFromGroups( [ resourceGroup ], [ "trigger_breach_early_out" ], [] )
	if ( triggerPOIResources.len() > 0 )
	{
		float triggerBelowHeight = 0
		foreach( poi in triggerPOIResources )
		{
			entity trigger =  SpawnRadiusTrigger( poi.core.spawnOrigin, poi.scriptRadius, poi.scriptHeight, triggerBelowHeight )
			trigger.ConnectOutput( "OnStartTouch", void function ( entity trigger, entity activator, entity caller, var value ) : ( room, objInstance, skitInstance )
			{
				if ( !IsValid( trigger ) )
					return

				if ( !IsValid( room ) )
					return

				if ( room.isBreached )
					return

				if ( !IsValid( activator ) )
					return

				if ( !activator.IsPlayer() )
					return

				RoomGetsBreachedNew( room, eBreachMethod.PLAYER_GOT_INSIDE_ALT_ROUTE, objInstance, skitInstance )
			})

			room.breachEarlyOutTriggers.append( trigger )
		}
	}

	//-------------------------
	// Make doors breachable
	//-------------------------
	foreach( doorResource in doorResources )
	{
		foreach( door in doorResource.doorEnts )
		{
			Assert( IsValid( door ), format( "Linked door is unexpectedly invalid, near: %s", string( doorResource.core.spawnOrigin ) ) )
			if ( !IsValid( door ) )
			{
				Warning( "Linked door is unexpectedly invalid, near: %s", string( doorResource.core.spawnOrigin ) )
				continue
			}

			DoorMakeBreachable( door, doorResource.core.spawnOrigin, doorResource.core.spawnAngles )
			room.doors.append( door )

			AddEntityDestroyedCallback( door, void function ( entity door ) : ( room, objInstance, skitInstance )
			{
				DoorRestoreNavAndDeleteHints( door )
				thread BreachRoomIfDoorDestroyed( room, door, objInstance, skitInstance )
			} )
		}
	}

	//////////////////////////////////////////////
	// random loot always inside breachable rooms
	//////////////////////////////////////////////
	/*
	foreach( InfantrySpawn spawn in room.infantrySpawns )
	{
		string lootRef = SURVIVAL_GetWeightedItemFromGroup( "Weapon_High" )
		if ( CoinFlip() )
			lootRef = SURVIVAL_GetWeightedItemFromGroup( "gold_any" )

		SpawnLoot( lootRef, spawn.core.spawnOrigin, false )
	}
	*/

	//-----------------------------
	// spawn enemies inside rooms
	//-----------------------------
	int numberToSpawn = minint( room.numberOfEnemiesToSpawn, room.infantrySpawns.len() )
	room.infantrySpawns.randomize()
	for( int idx = 0; idx < numberToSpawn; ++idx )
	{
		int spawnerIndex      = (idx % room.infantrySpawns.len())
		InfantrySpawn spawner = room.infantrySpawns[spawnerIndex]

		int npcType =  room.npcTypes.getrandom()
		entity npc = SkNPC_SpawnNPC( skitInstance, npcType, spawner.core.spawnOrigin, spawner.core.spawnAngles + <0, RandomIntRange( 0, 10 ), 0> )
		npc.EnableNPCFlag( NPC_IGNORE_ALL )
		npc.SetNoTarget( true )
		npc.kv.alwaysalert = 1
		room.enemies.append( npc )
		thread PlayAnim( npc, GetRandomIdleAnimForNpcType( npc.ai.npcType ) )
		//----------------------------------
		// enemy damaged by player before breach?
		//----------------------------------
		AddEntityCallback_OnDamaged( npc,
			void function ( entity npc, var damageInfo ) : ( room, objInstance, skitInstance )
			{
				entity attacker = DamageInfo_GetAttacker( damageInfo )
				if ( !IsValid( attacker ) )
					return

				if ( !attacker.IsPlayer() )
					return

				if ( room.isBreached )
					return

				RoomGetsBreachedNew( room, eBreachMethod.DAMAGED_ENEMIES_PRE_BREACH, objInstance, skitInstance )
			} )
	}

	return room
}

void function BreachRoomIfDoorDestroyed( BreachableRoomData room, entity door, ObjectiveInstance oi, SkitInstance si )
{
	wait 0.1
	if ( room.isBreached )
		return

	RoomGetsBreachedNew( room, eBreachMethod.DESTROYED_DOOR, oi, si )
}


void function BreachableRoomCleanupNew( BreachableRoomData room )
{
	foreach( trigger in room.breachEarlyOutTriggers )
	{
		if ( IsValid( trigger ) )
			trigger.Destroy()
	}
}


void function RoomGetsBreachedNew( BreachableRoomData room, int breachType, ObjectiveInstance objInstance, SkitInstance skitInstance )
{
	if ( room.isBreached )
	{
		printf( "%s() - Trying to set a room to breached that is already breached", FUNC_NAME() )
		return
	}

	room.isBreached = true

	switch ( breachType )
	{
		case eBreachMethod.DESTROYED_DOOR:
			break
		case eBreachMethod.TIMEOUT:
		case eBreachMethod.DAMAGED_ENEMIES_PRE_BREACH:
		case eBreachMethod.PLAYER_GOT_INSIDE_ALT_ROUTE:
			BreachRandomDoor( room )
			break
		default:
			Assert( false, "Unhandled breach type" )

	}
	//----------
	// NPCs
	//----------
	foreach( npc in room.enemies )
		thread WakeUpBreachedNpc( npc )

	//----------
	// Cleanup
	//----------
	foreach( trigger in room.breachEarlyOutTriggers )
	{
		if ( IsValid( trigger ) )
			trigger.Destroy()
	}

	foreach( door in room.doors )
	{
		if ( !IsValid( door) )
			continue

		DoorClearBreachable( door )
	}
}

void function WakeUpBreachedNpc( entity npc )
{
	if ( !IsAlive ( npc ) )
		return

	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )
	npc.Anim_Stop()

	wait BREACH_DELAY_BEFORE_NPCS_WAKE_UP
	npc.DisableNPCFlag( NPC_IGNORE_ALL )

	UpdateEnemyMemoryWithinRadius( npc, 3000 )
	entity closestEnemy = npc.GetClosestEnemy()
	if ( IsValid( closestEnemy ) )
		npc.SetEnemy( closestEnemy )

	npc.SetNoTarget( false )
}

void function BreachRandomDoor( BreachableRoomData room )
{
	entity doorToBreach
	ArrayRemoveInvalid( room.doors )
	if ( room.doors.len() == 0 )
		return

	room.doors.randomize()
	doorToBreach = room.doors[ 0 ]
	vector doorCenter = doorToBreach.GetCenter()
	DoorClearBreachable( doorToBreach, doorCenter )
	//doorToBreach.TakeDamage( doorToBreach.GetMaxHealth(), null, attacker, { damageSourceId=damagedef_suicide } )
}

int function GetRoomSize( ResourceGroup resourceGroup )
{
	foreach( keyword in resourceGroup.core.keywords )
	{
		if ( keyword.find( "_xs" ) != -1 )
			return eBreachableRoomSize.XSMALL
		if ( keyword.find( "_sm" ) != -1 )
			return eBreachableRoomSize.SMALL
		if ( keyword.find( "_med" ) != -1 )
			return eBreachableRoomSize.MEDIUM
		if ( keyword.find( "_lg" ) != -1 )
			return eBreachableRoomSize.LARGE
		if ( keyword.find( "_xl" ) != -1 )
			return eBreachableRoomSize.EXTRA_LARGE
	}

	//Assert( false, "Unable to find keyword (xs, sm, med, lg, xl) for breachable room at " + resourceGroup.core.spawnOrigin )
	return eBreachableRoomSize.LARGE
}


int function GetNpcNumberEnemiesToSpawnForRoomSize( int RoomSize )
{
	int numberToSpawn
	switch( RoomSize )
	{
		case eBreachableRoomSize.XSMALL:
			numberToSpawn = 1
			break
		case eBreachableRoomSize.SMALL:
			numberToSpawn = 2
			break
		case eBreachableRoomSize.MEDIUM:
			numberToSpawn = 4
			break
		case eBreachableRoomSize.LARGE:
			numberToSpawn = 4
			break
		case eBreachableRoomSize.EXTRA_LARGE:
			numberToSpawn = 8
			break
		default:
			Assert( false, "Unhandled eBreachableRoomSize" )
	}

	//TODO - handle playercounts a bit better
	//if ( GetPlayerArray_AliveConnected().len() > 1 )
		//numberToSpawn++

	return numberToSpawn
}




/*
===========================================================
===========================================================
===========================================================

     ########   #######   #######  ########   ######
     ##     ## ##     ## ##     ## ##     ## ##    ##
     ##     ## ##     ## ##     ## ##     ## ##
     ##     ## ##     ## ##     ## ########   ######
     ##     ## ##     ## ##     ## ##   ##         ##
     ##     ## ##     ## ##     ## ##    ##  ##    ##
     ########   #######   #######  ##     ##  ######

===========================================================
===========================================================
===========================================================
*/



void function DoorMakeBreachable( entity door, vector lockOrigin, vector lockAngles )
{
	LockDoor( door )
	CloseDoor( door, null )
	door.e.isDoorBreachable = true //proto - using as temp property to mark as breachable
	ToggleNPCPathsForEntity( door, false )
	vector doorCenter = door.GetCenter()
	//Door lock
	entity doorLock = CreatePropDynamic( GetObjectiveAsset_Model( "BREACH_AND_CLEAR_MODEL_LOCK" ), PositionOffsetFromOriginAngles( doorCenter, lockAngles, 0, 26, -6 ), AnglesCompose( lockAngles, <0, 0, 0> ), 6 )
	doorLock.SetUsable()
	//doorLock.Hide()
	doorLock.NotSolid()
	//doorLock.AddUsableValue( USABLE_USE_DISTANCE_OVERRIDE | USABLE_NO_FOV_REQUIREMENTS )
	//doorLock.SetUsableDistanceOverride( 64 )
	doorLock.SetUsePrompts( "#SURVIVAL_BREACHABLE_DOOR", "#SURVIVAL_BREACHABLE_DOOR" )
	doorLock.SetUsablePriority( USABLE_PRIORITY_HIGH )
	doorLock.SetScriptName( "doorLock" )
	doorLock.LinkToEnt( door )
	bool addToParentRealms = true
	doorLock.SetParent( door, "", true, 0 )
	entity fxLight = StartParticleEffectOnEntity_ReturnEntity( doorLock, GetParticleSystemIndex( GetObjectiveAsset_FX( "FX_BREACH_DOOR_LOCK_RED" ) ), FX_PATTACH_POINT_FOLLOW, doorLock.LookupAttachment( "light0" ) )
	//fxLight.SetParent( doorLock )
	doorLock.SetSkin( 1 ) //red

	//Door hint dummy
	entity doorHintDummy = CreatePropDynamic( $"mdl/dev/editor_ref.rmdl", doorCenter, AnglesCompose( door.GetAngles(), <0, 0, 0> ), 6 )
	doorHintDummy.SetUsable()
	doorHintDummy.Hide()
	doorHintDummy.NotSolid()
	doorHintDummy.SetUsePrompts( "#SURVIVAL_BREACHABLE_DOOR", "#SURVIVAL_BREACHABLE_DOOR" )
	doorHintDummy.SetUsablePriority( USABLE_PRIORITY_HIGH )
	doorHintDummy.SetScriptName( "doorHintDummy" )
	doorHintDummy.LinkToEnt( door )
	doorHintDummy.SetParent( door, "", true, 0 )

	AddEntityCallback_OnDamaged( door, void function ( entity door, var damageInfo )
	{
		if ( !IsDoorBreachable( door ) )
			return

		entity attacker = DamageInfo_GetAttacker( damageInfo )
		if ( !IsValid( attacker ) )
			return

		if ( !attacker.IsPlayer() )
		{
			//If an npc damages a breachable door, do nothing
			DamageInfo_SetDamage( damageInfo, 0 )
			return
		}

	} )

}


void function DoorClearBreachable( entity door, vector doorCenter = <0,0,0> )
{
	//Door is either breached or reverted to default behavior
	if ( IsValid( door ) )
	{
		UnlockDoor( door )
		door.e.isDoorBreachable = false //proto - using as temp property to mark as breachable
		ToggleNPCPathsForEntity( door, true )
	}

	array <entity> parentEnts = door.GetLinkParentArray()
	entity doorLock
	entity doorHintDummy
	foreach( ent in parentEnts )
	{
		if ( ent.GetScriptName() == "doorLock" )
			doorLock = ent
		if ( ent.GetScriptName() == "doorHintDummy" )
			doorHintDummy = ent

	}
	if ( IsValid( doorLock ) )
		DoorLockExplodes( doorLock )

	if ( IsValid( doorHintDummy ) )
		doorHintDummy.Destroy()


}

void function DoorLockExplodes( entity doorLock )
{
	if ( !IsValid( doorLock ) )
		return

	int attachID  = doorLock.LookupAttachment( "FX_CENTER" )
	vector origin = doorLock.GetAttachmentOrigin( attachID )
	vector angles = doorLock.GetAttachmentAngles( attachID )

	StartParticleEffectInWorld( GetParticleSystemIndex( GetObjectiveAsset_FX( "BREACH_AND_CLEAR_FX_LOCK_EXPLODE" ) ), origin, angles )
	EmitSoundAtPosition( TEAM_ANY, origin, "SQ_Lock_Explode", doorLock )
	doorLock.Destroy()
}

void function DoorRestoreNavAndDeleteHints( entity door )
{
	//Door is either breached or reverted to default behavior
	if ( IsValid( door ) )
	{
		UnlockDoor( door )
	}
	ToggleNPCPathsForEntity( door, true )
	array <entity> parentEnts = door.GetLinkParentArray()
	entity doorLock
	entity doorHintDummy

	foreach( ent in parentEnts )
	{
		if ( ent.GetScriptName() == "doorLock" )
			doorLock = ent

		if ( ent.GetScriptName() == "doorHintDummy" )
			doorHintDummy = ent


	}
	if ( IsValid( doorLock ) )
		DoorLockExplodes( doorLock )

	if ( IsValid( doorHintDummy ) )
		doorHintDummy.Destroy()
}


bool function IsValidBreachDamage( var damageInfo )
{
	int damageType = DamageInfo_GetCustomDamageType( damageInfo )
	int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )


	if ( bool(damageType & DF_MELEE ) )
		return true

	if ( damageSourceId == eDamageSourceId.mp_weapon_frag_grenade )
		return true

	return false
}

bool function IsDoorBreachable( entity door )
{
	return door.e.isDoorBreachable //proto - using as temp property to mark as breachable
}
#endif //SERVER
