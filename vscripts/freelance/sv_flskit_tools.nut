//Other
global const string FLARE_MOVER_SCRIPTNAME = "flare_mover"
//**********************************************************

//Creature bait
global function GetPlayersWithBaitLauncher
global function GetPlayersWithoutBaitLauncher
global function PlayerHasBaitLauncherEquipped
global function PlayerHasBaitLauncherUnequipped

//NPC utility
global function NPCInvulnerableTillFlagOrPlayerDamage
global function GetRandomCreatureType

//Player utility
global function ObjectivePlayersCanSeePos
global function AnyObjectivePlayerInRange
global function GetNearbyPlayers

//waypoints
global function AddWaypointToObjectiveEntityGroup

global function CreateSkitID
global function CreateMegaTurretRocket
global function CreateTurretShield
global function SpawnRadiusTrigger
global function FlagSetTriggerTouchingPlayer
global function FlagSetTriggerLeavePlayer
global function ShipLandThink
global function ShipTakeoffThink
global function CreatePVEButton
global function CreateWaypoint_UseObject
global function DeactivateButton
global function ReactivateButton
global function BuildCatwalk_StyleOverlook_WithButton
global function SpawnSimpleSidequestRewards
global function PVE_CreateLootBin
global function PVE_CreateLootBox
global function PVE_CreateTeamLootBox
global function PVE_DestroyLootBox
global function PVE_ThrowLootBox
global function DisableResource
global function DisableAllResourcesByScriptName
global function DisableAllResourcesByScriptNameWithLinkedEnts
global function DisableAllLinkedResources
global function EnableResource
global function EnableAllResourcesByScriptName
global function EnableAllResourcesByScriptNameWithLinkedEnts
global function EnableAllLinkedResources
global function GetAllResourcesByScriptName





global function SpawnSkitNPC_DropPod
global function LaunchFlare
global function CreateVictoryAirdrop
global function CreateVictoryAirdropsFromResourceKeyword
global function RollRandomLootForTieredChest
global function IsProtectedPveEntity

//PROTO
global function PROTO_SpawnObjectiveReward

global enum eVictoryAirdropRewardLevel
{
	LOW,
	MEDIUM,
	HIGH,

	_count
}

const asset MODEL_WALLBUTTON 	= $"mdl/props/global_access_panel_button/global_access_panel_button_wall.rmdl"
const asset MODEL_CONSOLEBUTTON = $"mdl/props/global_access_panel_button/global_access_panel_button_console.rmdl"
const asset MODEL_GRATEFLOOR	= $"mdl/ola/sewer_grate_01.rmdl"
const asset MODEL_RAILING 		= $"mdl/ola/sewer_railing_01_128.rmdl"
const asset MODEL_STAIR			= $"mdl/ola/sewer_staircase_quad.rmdl"
const asset MODEL_STAIR_RAILING	= $"mdl/s2s/s2s_stair_railing_quad_01.rmdl"
const asset MODEL_LOOT_BIN 		= $"mdl/props/loot_bin/loot_bin_01_animated.rmdl"

struct
{
	table<entity,string> touchFlags
	table<int,array<void functionref(entity)> > skitCallback_NpcSPawn
	int skitIDTracker = 0
	int txtPanelID = 0
} file


void function DisableResource( entity ent )
{
	ent.MakeInvisible()
	ent.NotSolid()
	//ent.EnableHibernation()
	ent.RemoveFromAllRealms()
}

void function EnableResource( entity ent )
{
	ent.MakeVisible()
	ent.Solid()
	//ent.DisableHibernation()
	ent.AddToAllRealms()
}

array<entity> function GetPlayersWithBaitLauncher( ObjectiveInstance objInstance, bool mustBeEquipped = false )
{
	array<entity> playersNearObjective = Objectives_GetPlayersInOrNearObjective( objInstance )
	array<entity> playersWithBaitLauncher
	array<entity> playersWithBaitLauncherEquipped
	foreach( player in playersNearObjective )
	{
		if ( !IsAlive( player ) )
			continue

		if ( PlayerHasBaitLauncherEquipped( player ) )
		{
			playersWithBaitLauncherEquipped.append( player )
			playersWithBaitLauncher.append( player )
			continue
		}
		else if ( PlayerHasBaitLauncherUnequipped( player ) )
		{
			playersWithBaitLauncher.append( player )
			continue
		}
		else
		{
			continue
		}
	}

	if ( mustBeEquipped )
		return playersWithBaitLauncherEquipped
	else
		return playersWithBaitLauncher

	unreachable
}

bool function PlayerHasBaitLauncherUnequipped( entity player )
{
	if ( !IsAlive( player ) )
		return false

	if ( PlayerHasBaitLauncherEquipped( player ) )
		return false

	if ( !PlayerHasWeapon( player, "mp_weapon_creaturebait" ) )
		return false

	return true
}

bool function PlayerHasBaitLauncherEquipped( entity player )
{
	if ( !IsAlive( player ) )
		return false

	entity currentWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( !IsValid( currentWeapon ) )
		return false

	if ( currentWeapon.GetWeaponClassName() != "mp_weapon_creaturebait" )
		return false

	return true
}

array<entity> function GetPlayersWithoutBaitLauncher( ObjectiveInstance objInstance )
{
	array<entity> playersNearObjective = Objectives_GetPlayersInOrNearObjective( objInstance )
	array<entity> playersWithoutBaitLauncher
	foreach( player in playersNearObjective )
	{
		if ( !IsAlive( player ) )
			continue

		if ( PlayerHasBaitLauncherEquipped( player ) )
			continue

		if ( PlayerHasWeapon( player, "mp_weapon_creaturebait" ) )
			continue

		playersWithoutBaitLauncher.append( player )
	}

	return playersWithoutBaitLauncher

}


void function DisableAllResourcesByScriptName( string scriptName, string scriptGroup = ""  )
{
	array <entity> ents = GetEntArrayByScriptName( scriptName )
	foreach( ent in ents )
	{
		if ( !IsValid( ent ) )
			continue


		if ( scriptGroup != "" )
		{
			if ( ent.HasKey( "script_group" ) && ent.GetValueForKey( "script_group" ) == scriptGroup )
				DisableResource( ent )
		}
		else
		{
			DisableResource( ent )
			continue
		}
	}
}

array<entity> function GetNearbyPlayers( vector pos, float maxDist )
{
	array<entity> players = GetPlayerArray_AliveConnected()
	array<entity> nearbyPlayers
	foreach ( player in players )
	{
		if ( !IsAlive( player ) )
			continue
		if ( Distance( pos, player.GetOrigin() ) > maxDist )
			continue
		nearbyPlayers.append( player )
	}

	return nearbyPlayers
}

void function EnableAllResourcesByScriptName( string scriptName, string scriptGroup = ""  )
{
	array <entity> ents = GetEntArrayByScriptName( scriptName )
	foreach( ent in ents )
	{
		if ( !IsValid( ent ) )
			continue


		if ( scriptGroup != "" )
		{
			if ( ent.HasKey( "script_group" ) && ent.GetValueForKey( "script_group" ) == scriptGroup )
				EnableResource( ent )
		}
		else
		{
			EnableResource( ent )
			continue
		}
	}
}

array <entity> function GetAllResourcesByScriptName( string scriptName, string scriptGroup = ""  )
{
	array <entity> ents = GetEntArrayByScriptName( scriptName )
	array <entity> entsToReturn
	foreach( ent in ents )
	{
		if ( !IsValid( ent ) )
			continue

		if ( scriptGroup != "" )
		{
			if ( ent.HasKey( "script_group" ) && ent.GetValueForKey( "script_group" ) == scriptGroup )
				entsToReturn.append( ent )
		}
		else
		{
			entsToReturn.append( ent )
			continue
		}
	}

	return entsToReturn
}

void function DisableAllResourcesByScriptNameWithLinkedEnts( string scriptName  )
{
	//disable anything the entity is linked to as well as the entity itself
	array <entity> ents = GetEntArrayByScriptName( scriptName )
	foreach( ent in ents )
	{
		DisableAllLinkedResources( ent )
		if ( IsValid( ent ) )
			DisableResource( ent )
	}
}

void function EnableAllResourcesByScriptNameWithLinkedEnts( string scriptName  )
{
	//disable anything the entity is linked to as well as the entity itself
	array <entity> ents = GetEntArrayByScriptName( scriptName )
	foreach( ent in ents )
	{
		EnableAllLinkedResources( ent )
		if ( IsValid( ent ) )
			EnableResource( ent )
	}
}

void function DisableAllLinkedResources( entity ent )
{
	array <entity> linkedEnts = ent.GetLinkEntArray()
	foreach( linkedEnt in linkedEnts )
	{
		if ( IsValid( linkedEnt ) )
			DisableResource( linkedEnt )
	}
}

void function EnableAllLinkedResources( entity ent )
{
	array <entity> linkedEnts = ent.GetLinkEntArray()
	foreach( linkedEnt in linkedEnts )
	{
		if ( IsValid( linkedEnt ) )
			EnableResource( linkedEnt )
	}
}


int function CreateSkitID()
{
	file.skitIDTracker++
	return file.skitIDTracker - 1
}

/************************************************************************************************\

███████╗██████╗  █████╗ ██╗    ██╗███╗   ██╗    ███╗   ██╗██████╗  ██████╗
██╔════╝██╔══██╗██╔══██╗██║    ██║████╗  ██║    ████╗  ██║██╔══██╗██╔════╝
███████╗██████╔╝███████║██║ █╗ ██║██╔██╗ ██║    ██╔██╗ ██║██████╔╝██║
╚════██║██╔═══╝ ██╔══██║██║███╗██║██║╚██╗██║    ██║╚██╗██║██╔═══╝ ██║
███████║██║     ██║  ██║╚███╔███╔╝██║ ╚████║    ██║ ╚████║██║     ╚██████╗
╚══════╝╚═╝     ╚═╝  ╚═╝ ╚══╝╚══╝ ╚═╝  ╚═══╝    ╚═╝  ╚═══╝╚═╝      ╚═════╝

\************************************************************************************************/



























































void function SpawnSkitNPC_DropPod( SkitInstance si, vector origin, vector angles, array<int> npcTypes, int criticalCount = -1, bool dissolveAfterDisembark = true, array<entity> returnedNpcsArray = [] )
{
	AssertIsNewThread()

	entity dropPod = CreateDropPod()
	if ( dissolveAfterDisembark )
		InitFireteamDropPod( dropPod, eDropPodFlag.DISSOLVE_AFTER_DISEMBARKS )
	else
		InitFireteamDropPod( dropPod, eDropPodFlag.NONE )

	waitthread LaunchAnimDropPod( dropPod, origin, angles )

	returnedNpcsArray.clear()
	for ( int i=0; i<npcTypes.len(); i++ )
	{
		int type = npcTypes[i]
		entity npc

		if ( criticalCount < 0 || i < criticalCount )
			npc = SkNPC_SpawnNPC( si, type, origin, angles )
		else
		{
			entity ornull npcRaw = SkNPC_SpawnNonCriticalNPC( si, type, origin, angles )
			if ( npcRaw == null )
				continue
			npc = expect entity( npcRaw )
		}

		if ( !IsAlive( npc ) )
			continue

		returnedNpcsArray.append( npc )
	}

	NPCsDeployFromDroppod( dropPod, returnedNpcsArray )
}

// --------------------------------------------------------------------------------------
//
//	Flare
//
// --------------------------------------------------------------------------------------
const float FLARE_TRAVEL_DISTANCE = 4000
const float FLARE_TRAVEL_TIME = 2.5
const float FLARE_ACCELERATION_TIME = 0.5
const float FLARE_DECELERATION_TIME = 0.5

const asset FLARE_FX = $"P_bFlare_trail"
const string FLARE_FIRE_SOUND = "weapon_titan_rocket_launcher_fire_3p_enemy"
const string FLARE_SOUND = "bangalore_ultimate_flare_hiss"

void function LaunchFlare( SkitInstance si, vector origin )
{
	AssertIsNewThread()

	vector endPoint = origin + <0, 0, FLARE_TRAVEL_DISTANCE>
	entity flareProp = CreateScriptMover( FLARE_MOVER_SCRIPTNAME, origin, <90, 0, 0> )
	entity flareFX = StartParticleEffectOnEntity_ReturnEntity( flareProp, GetParticleSystemIndex( FLARE_FX ), FX_PATTACH_ABSORIGIN_FOLLOW_NOROTATE, ATTACHMENTID_INVALID )

	EmitSoundAtPosition( -1, origin, FLARE_FIRE_SOUND, flareProp )
	EmitSoundOnEntity( flareProp, FLARE_SOUND )

	flareProp.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( flareProp, flareFX )
		{
			if ( IsValid( flareFX ) )
				flareFX.Destroy()

			if ( IsValid( flareProp ) )
				flareProp.Destroy()
		}
	)

	flareProp.NonPhysicsMoveTo( endPoint, FLARE_TRAVEL_TIME, FLARE_ACCELERATION_TIME, FLARE_DECELERATION_TIME )

	wait FLARE_TRAVEL_TIME
	flareProp.Destroy()
}

// --------------------------------------------------------------------------------------
//
//	Airdrops
//
// --------------------------------------------------------------------------------------
Assert( eVictoryAirdropRewardLevel._count == 3 )
const float AIRDROP_REWARDS_DISTANCE = 7000
void function CreateVictoryAirdrop( vector origin, vector angles, int rewardLevel )
{
	Assert( IsNewThread(), "Must be threaded off" )
	Assert( rewardLevel >= 0 && rewardLevel <= 2, "CreateVictoryAirdrop reward level must be between 0 and 2" )
	array<array<string> > airdropContents
	int airdropMoney = 0
	switch ( rewardLevel )
	{
		case eVictoryAirdropRewardLevel.LOW:
			airdropContents = DetermineAirdropContents ( [["care_package_1_L"], ["care_package_1_R"], ["care_package_1_C"]] )
			airdropMoney = 4000
			break
		case eVictoryAirdropRewardLevel.MEDIUM:
			airdropContents = DetermineAirdropContents ( [["care_package_2_L"], ["care_package_2_R"], ["care_package_2_C"]] )
			airdropMoney = 6000
			break
		case eVictoryAirdropRewardLevel.HIGH:
			airdropContents = DetermineAirdropContents ( [["care_package_3_L"], ["care_package_3_R"], ["care_package_3_C"]] )
			airdropMoney = 8000
			break
	}

	int rewardDivisions = 11		//weird number to get a non even number -- gets a better mix of big and small candies
	int airdropMoneyDivided = int( ceil( airdropMoney / rewardDivisions ) )
	AirdropItemsOptionalInfo optionInfo
	optionInfo.animationName = "droppod_loot_drop_lifeline"

	waitthread AirdropItems( origin, angles, airdropContents, optionInfo )














}


void function CreateVictoryAirdropsFromResourceKeyword( string resouceKeyword, int numberOfAirdrops, ObjectiveInstance objInstance )
{
	//keyword = the LD-placed resource_group which points to a number of POIs used for droppods
	//globalizing this for now since it's used in all 25 locations for the current slate of objectives
	AssertIsNewThread()

	ResourceGroup groupScope 			= ORS_GetGlobalGroup()
	int searchFlags 					= 0
	array<int> typesToInclude 			= [eORType.GROUP]
	array<string> keywordsToInclude 	= [ resouceKeyword ]
	array<string> keywordsToExclude 	= []

	ResourceCollection droppodGroup = ORS_Find_( groupScope, searchFlags, typesToInclude, keywordsToInclude, keywordsToExclude )
	Assert( droppodGroup.groups.len() == 1, "Expected to find single resource_group: " + resouceKeyword + " but found " + droppodGroup.groups.len() )

	array<PointOfInterest> droppodSpawns = ORS_Find_( droppodGroup.groups[ 0 ], searchFlags, [eORType.POI], [], [] ).pois
	//Requiring 3 possible locations in case we decide to spawn more than one later and want to avoid a recompile
	Assert( droppodSpawns.len() >= 3, "Currently require a minimum of 3 airdrop spawn locations. Found " + droppodSpawns.len() )

	droppodSpawns.randomize()
	int rewardLevel
	for ( int i = 0; i < numberOfAirdrops; i++ )
	{
		//TODO: reward level is Temp until we figure out reward structure per objective, match time, etc
		if ( CoinFlip() )
			rewardLevel = eVictoryAirdropRewardLevel.MEDIUM
		else
			rewardLevel = eVictoryAirdropRewardLevel.HIGH
		thread CreateVictoryAirdrop( droppodSpawns[i].core.spawnOrigin, droppodSpawns[i].core.spawnAngles, rewardLevel )
		wait RandomFloatRange( 0.25, 0.75 )
	}

	wait 3.5

	ObjectiveSplashMessage( objInstance, "Rewards Incoming", "Victory airdrop and cash are on the way" )
}


/************************************************************************************************\

██████╗  ██████╗  ██████╗██╗  ██╗███████╗████████╗    ████████╗██╗   ██╗██████╗ ██████╗ ███████╗████████╗███████╗
██╔══██╗██╔═══██╗██╔════╝██║ ██╔╝██╔════╝╚══██╔══╝    ╚══██╔══╝██║   ██║██╔══██╗██╔══██╗██╔════╝╚══██╔══╝██╔════╝
██████╔╝██║   ██║██║     █████╔╝ █████╗     ██║          ██║   ██║   ██║██████╔╝██████╔╝█████╗     ██║   ███████╗
██╔══██╗██║   ██║██║     ██╔═██╗ ██╔══╝     ██║          ██║   ██║   ██║██╔══██╗██╔══██╗██╔══╝     ██║   ╚════██║
██║  ██║╚██████╔╝╚██████╗██║  ██╗███████╗   ██║          ██║   ╚██████╔╝██║  ██║██║  ██║███████╗   ██║   ███████║
╚═╝  ╚═╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝   ╚═╝          ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝

\************************************************************************************************/
entity function CreateMegaTurretRocket( vector origin = <0,0,0>, vector angles = <0,0,0>, bool hasShield = false )
{
	entity turret = CreateNPCFromAISettings( "npc_turret_mega_rocket", eNpcTeam.LEGION, origin, angles )
	DispatchSpawn( turret )
	turret.DisableHibernation()
	turret.EnableNPCFlag( NPC_ANIM_FOV )

	if ( hasShield )
		thread MegaTurretShield( turret )

	return turret
}

void function MegaTurretShield( entity turret )
{
	EmitSoundOnEntity( turret, "MegaTurret_Laser_ShieldDeploy" )
	entity shield = CreateTurretShield( turret )

	// Wait for deactivation
	waitthread DestroyShieldOnTurretDeathOrShieldDeactivation( turret, shield )
}

void function DestroyShieldOnTurretDeathOrShieldDeactivation( entity turret, entity shield )
{
	EndSignal( turret, "OnDeath" )
	EndSignal( turret, "OnDestroy" )

	OnThreadEnd(
		function() : ( shield )
		{
			if ( IsValid( shield ) )
				shield.Destroy()
		}
	)

	WaitSignal( turret, "DisableShields" )
}

entity function CreateTurretShield( entity turret )
{
	vector origin		= turret.GetOrigin() + <0,0,-64>
	vector angles		= turret.GetAngles()
	int radius			= 190
	int height			= 330
	int FOV				= 290
	float duration		= 99999999
	int health			= 3000
	asset shieldWallFx	= $"P_turret_shield_wall_missile"

	entity shieldWall = CreateTurretShieldWithSettings( origin, angles, radius, height, FOV, duration, health, shieldWallFx )
	thread DrainHealthOverTime( shieldWall, shieldWall.e.shieldWallFX, duration )

//	SetVortexSphereBulletHitRules( shieldWall, MegaTurret_Shield_BulletHitRules )
//	SetVortexSphereProjectileHitRules( shieldWall, MegaTurret_Shield_ProjectileHitRules )
	shieldWall.SetOwner( turret )
	SetTeam( shieldWall, turret.GetTeam() )
	shieldWall.DisableHibernation()

	return shieldWall
}
/*
void function MegaTurret_Shield_BulletHitRules( entity vortexSphere, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !MegaTurret_Shield_ShouldTakeDamage( vortexSphere, attacker ) )
		DamageInfo_SetDamage( damageInfo, 0 )
}

bool function MegaTurret_Shield_ProjectileHitRules( entity vortexSphere, entity attacker, bool takesDamageByDefault )
{
	return MegaTurret_Shield_ShouldTakeDamage( vortexSphere, attacker )
}

bool function MegaTurret_Shield_ShouldTakeDamage( entity vortexSphere, entity attacker )
{
	if ( !IsValid( vortexSphere ) )
	{
		printt( "Shield not taking damage - shield invalid" )
		return false
	}

	if ( !IsValid( attacker ) )
	{
		printt( "Shield not taking damage - attacker invalid" )
		return false
	}

	entity turret

	Assert( IsValid( turret ), "Turret shield took damage but is not being tracked by mega turret script" )

	int attackerTeam = attacker.GetTeam()

	// Don't take damage from neutral teams, or friendly fire
	if ( attackerTeam == TEAM_NPC_FRIENDLY_TO_PLAYERS || IsFriendlyTeam( attackerTeam, vortexSphere.GetTeam() ) )
	{
		printt( "Shield not taking damage - friendly fire" )
		return false
	}

	bool pilotDamage = ( turret.HasKey( "shield_damaged_by_pilots" ) && turret.GetValueForKey( "shield_damaged_by_pilots" ) == "1" )
	if ( IsPilot( attacker ) && !pilotDamage )
	{
		printt( "Shield not taking damage - pilots can't damage" )
		return false
	}

	bool titanDamage = ( turret.HasKey( "shield_damaged_by_titans" ) && turret.GetValueForKey( "shield_damaged_by_titans" ) == "1" )
	if ( attacker.IsTitan() && !titanDamage )
	{
		printt( "Shield not taking damage - titans can't damage" )
		return false
	}

	printt( "Shield taking damage!" )
	return true
}*/

/************************************************************************************************\

████████╗██████╗ ██╗ ██████╗  ██████╗ ███████╗██████╗ ███████╗
╚══██╔══╝██╔══██╗██║██╔════╝ ██╔════╝ ██╔════╝██╔══██╗██╔════╝
   ██║   ██████╔╝██║██║  ███╗██║  ███╗█████╗  ██████╔╝███████╗
   ██║   ██╔══██╗██║██║   ██║██║   ██║██╔══╝  ██╔══██╗╚════██║
   ██║   ██║  ██║██║╚██████╔╝╚██████╔╝███████╗██║  ██║███████║
   ╚═╝   ╚═╝  ╚═╝╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝

\************************************************************************************************/
entity function SpawnRadiusTrigger( vector origin, float radius, float aboveHight = 256, float belowHeight = 0 )
{
	entity trig = CreateEntity( "trigger_cylinder" )
	trig.SetCylinderRadius( radius )
	trig.SetAboveHeight( aboveHight )
	trig.SetBelowHeight( belowHeight )
	trig.SetOrigin( origin )
	trig.kv.triggerFilterNpc = "none"
	trig.kv.triggerFilterPlayer = "all"
	trig.kv.triggerFilterNonCharacter = "0"

	DispatchSpawn( trig )

	return trig
}

void function FlagSetTriggerTouchingPlayer( entity trigger, string flag )
{
	file.touchFlags[ trigger ] <- flag
	trigger.ConnectOutput( "OnStartTouch", TriggerStartTouchPlayerSetFlag )
	trigger.ConnectOutput( "OnEndTouch", TriggerEndTouchPlayerClearFlag )

	thread TriggerResetFlagOnDestroy( trigger, flag )
}

void function TriggerResetFlagOnDestroy( entity trigger, string flag )
{
	trigger.WaitSignal( "OnDestroy" )

	if ( Flag( flag ) )
		FlagClear( flag )
}

void function TriggerStartTouchPlayerSetFlag( entity trigger, entity activator, entity caller, var value )
{
	if ( !IsValid( trigger ) )
		return

	if ( !IsValid( activator ) )
		return

	if ( !activator.IsPlayer() )
		return

	Assert( trigger.GetTouchingEntities().contains( activator ) )

	FlagSet( file.touchFlags[ trigger ] )
}

void function TriggerEndTouchPlayerClearFlag( entity trigger, entity activator, entity caller, var value )
{
	if ( !IsValid( trigger ) )
		return

	if ( !IsValid( activator ) )
		return

	if ( !activator.IsPlayer() )
		return

	array<entity> ents = trigger.GetTouchingEntities()
	array<entity> players = GetPlayerArray()
	foreach ( player in players )
	{
		if( ents.contains( player ) )
			return
	}

	FlagClear( file.touchFlags[ trigger ] )
}

void function FlagSetTriggerLeavePlayer( entity trigger, string flag )
{
	file.touchFlags[ trigger ] <- flag
	trigger.ConnectOutput( "OnEndTouch", TriggerEndTouchPlayerSetFlag )

	thread TriggerResetFlagOnDestroy( trigger, flag )
}

void function TriggerEndTouchPlayerSetFlag( entity trigger, entity activator, entity caller, var value )
{
	if ( !IsValid( trigger ) )
		return

	if ( !IsValid( activator ) )
		return

	if ( !activator.IsPlayer() )
		return

	array<entity> ents = trigger.GetTouchingEntities()
	if( ents.contains( activator ) )
		return

	FlagSet( file.touchFlags[ trigger ] )
}



/************************************************************************************************\

███████╗██╗  ██╗██╗██████╗     ███████╗██╗  ██╗██╗████████╗███████╗
██╔════╝██║  ██║██║██╔══██╗    ██╔════╝██║ ██╔╝██║╚══██╔══╝██╔════╝
███████╗███████║██║██████╔╝    ███████╗█████╔╝ ██║   ██║   ███████╗
╚════██║██╔══██║██║██╔═══╝     ╚════██║██╔═██╗ ██║   ██║   ╚════██║
███████║██║  ██║██║██║         ███████║██║  ██╗██║   ██║   ███████║
╚══════╝╚═╝  ╚═╝╚═╝╚═╝         ╚══════╝╚═╝  ╚═╝╚═╝   ╚═╝   ╚══════╝

\************************************************************************************************/
const string SHIP_LAND_MOVER_SCRIPTNAME1 = "ship_skit_node_mover"
const string SHIP_LAND_MOVER_SCRIPTNAME2 = "ship_skit_node2_mover"
const string SHIP_TAKEOFF_MOVER_SCRIPTNAME = "ship_skit_takeoff_mover"
void function ShipLandThink( array<entity> cleanup, entity ship, array<entity> guys = [], float delay = 0, float y = 0 )
{
	ship.EndSignal( "OnDeath" )
	ship.EndSignal( "OnDestroy" )

	vector entryAng = AnglesCompose( ship.GetAngles(), <0,-80,0> )
	if ( y != 0 )
		entryAng = < 0, y, 0 >

	entity node = CreateScriptMover( SHIP_LAND_MOVER_SCRIPTNAME1, ship.GetOrigin() + <0,0,350>, entryAng )
	entity node2 = CreateScriptMover( SHIP_LAND_MOVER_SCRIPTNAME2, ship.GetOrigin(), ship.GetAngles() )

	OnThreadEnd(
   		function () : ( node )
   		{
   			if ( IsValid( node ) )
   				node.Destroy()
   		}
   	)

	cleanup.append( node )
	cleanup.append( node2 )

	string anim = "cd_dropship_rescue_side_start"
	ship.SetOrigin( node.GetOrigin() )
	ship.SetAngles( node.GetAngles() )
	Attachment result = ship.Anim_GetAttachmentAtTime( anim, "ORIGIN", 0 )
	vector origin = result.position
	vector angles = result.angle

	ship.Hide()
	ship.SetOrigin( origin )
	ship.SetAngles( angles )

	foreach( idx, guy in guys )
	{
		guy.Hide()
		thread ShipLandGuys( guy, ship, idx )
	}

	wait delay

	waitthread __WarpInEffectShared( origin, angles, "", ship )
	ship.Show()

	ship.SetParent( node, "REF", false, 0 )
	thread PlayAnimTeleport( ship, anim, node, "REF" )
	wait 3.3

	float blendTime = 5.0

	foreach( idx, guy in guys )
		guy.Show()

	ship.SetParent( node2, "REF", false, blendTime )
	thread PlayAnim( ship, "test_land", node2, "REF", blendTime )
	wait 6.2

	ship.Signal( "udpateGuys" )
}

void function ShipLandGuys( entity guy, entity ship, int idx )
{
	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "OnDestroy" )

	int attach_id = ship.LookupAttachment( "RAMPDOORLIP" )

	array<string> anims = [ "Classic_MP_flyin_exit_playerA_idle", "Classic_MP_flyin_exit_playerB_idle", "Classic_MP_flyin_exit_playerC_idle", "Classic_MP_flyin_exit_playerD_idle" ]

	guy.SetParent( ship, "ORIGIN" )
	thread PlayAnim( guy, anims[ idx ], ship, "ORIGIN" )

	ship.WaitSignal( "udpateGuys" )

	array<float> ends = [ 3.2, 4.7, 3.7, 4.1 ]

	array<string> jumps = [ "Classic_MP_flyin_exit_playerA_jump", "Classic_MP_flyin_exit_playerB_jump", "Classic_MP_flyin_exit_playerC_jump", "Classic_MP_flyin_exit_playerD_jump" ]
	thread PlayAnim( guy, jumps[ idx ], ship, "ORIGIN", DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME )
	wait ends[ idx ]

	guy.ClearParent()
	guy.Anim_Stop()

}

void function ShipTakeoffThink( entity ship, array<entity> guys = [], float delay = 0, float y = 0 )
{
	ship.EndSignal( "OnDeath" )
	ship.EndSignal( "OnDestroy" )

	wait delay

	ArrayRemoveDead( guys )

	array<entity> ready
	foreach( idx, guy in guys )
		thread ShipTakeoffGuys( guy, ship, idx, ready )

	while( guys.len() > 0 )
	{
		WaitSignal( ship, "udpateGuys", "OnDeath", "OnDestroy" )
		if ( ready.len() >= guys.len() )
			break
	}

	float duration = ship.GetSequenceDuration( "test_takeoff" )
	float blendTime = 0.75
	float takeoffTime = 4.5
	float nextAnimTime = duration - takeoffTime

	entity node = ship.GetParent()
	thread PlayAnim( ship, "test_takeoff", node, "REF" )

	wait takeoffTime

	foreach ( guy in guys )
	{
		if ( IsValid( guy ) )
			guy.Destroy()
	}

	vector ang = node.GetAngles()
	if ( y != 0 )
	 	ang = < 0, y, 0 >
	node.NonPhysicsRotateTo( ang, nextAnimTime, 1.0, 1.0 )

	wait nextAnimTime - blendTime

	entity node2 = CreateScriptMover( SHIP_TAKEOFF_MOVER_SCRIPTNAME, node.GetOrigin() + <0,0,500>, ang )

	ship.SetParent( node2, "REF", false, blendTime )
	thread PlayAnim( ship, "cd_dropship_rescue_end", node2, "REF", blendTime, 1.0 )

	duration = ship.GetSequenceDuration( "cd_dropship_rescue_end" )
	wait duration - 1.3

	thread __WarpOutEffectShared( ship )
	ship.Destroy()
	node.Destroy()
	node2.Destroy()
}

void function ShipTakeoffGuys( entity guy, entity ship, int idx, array<entity> ready )
{
	guy.EndSignal( "OnDeath" )
	guy.EndSignal( "OnDestroy" )

	int attach_id = ship.LookupAttachment( "RAMPDOORLIP" )
  	vector goal = ship.GetAttachmentOrigin( attach_id )

  	guy.AssaultPointClamped( goal )
	guy.AssaultSetGoalRadius( 175 )

	WaitSignal( guy, "OnFinishedAssault", "OnEnterGoalRadius", "OnFailedToPath" )

	array<string> anims = [ "Classic_MP_flyin_exit_playerA_idle", "Classic_MP_flyin_exit_playerB_idle", "Classic_MP_flyin_exit_playerC_idle", "Classic_MP_flyin_exit_playerD_idle" ]
	float blendTime = 0.5
	guy.SetParent( ship, "ORIGIN", false, blendTime )
	thread PlayAnim( guy, anims[ idx ], ship, "ORIGIN" )

	ready.append( guy )
	ship.Signal( "udpateGuys" )
}

/************************************************************************************************\

██████╗ ██╗   ██╗████████╗████████╗ ██████╗ ███╗   ██╗███████╗
██╔══██╗██║   ██║╚══██╔══╝╚══██╔══╝██╔═══██╗████╗  ██║██╔════╝
██████╔╝██║   ██║   ██║      ██║   ██║   ██║██╔██╗ ██║███████╗
██╔══██╗██║   ██║   ██║      ██║   ██║   ██║██║╚██╗██║╚════██║
██████╔╝╚██████╔╝   ██║      ██║   ╚██████╔╝██║ ╚████║███████║
╚═════╝  ╚═════╝    ╚═╝      ╚═╝    ╚═════╝ ╚═╝  ╚═══╝╚══════╝

\************************************************************************************************/
entity function CreatePVEButton( asset model, vector origin, vector angles, string usePrompt1 = "", string usePrompt2 = "" )
{
	entity button = CreatePropDynamic( model, origin, angles )
	button.SetTouchTriggers( false )

	if ( usePrompt2 == "" )
		usePrompt2 = usePrompt1

	button.SetUsable()
	button.SetUsePrompts( usePrompt1, usePrompt2 )
	button.AddUsableValue( USABLE_BY_OWNER | USABLE_BY_PILOTS | USABLE_BY_ENEMIES )

	vector offset = <0,0,0>
	switch( model )
	{
		case MODEL_CONSOLEBUTTON:
			offset = <0,0,12>
			break
		case MODEL_WALLBUTTON:
			offset = <0,0,5>
			break
	}

	thread CreateWaypoint_UseObject( button, "#PVE_WAYPOINT_BUTTON", $"rui/hud/common/overhead_icon_pilot_arrow", offset )

	return button
}

void function CreateWaypoint_UseObject( entity object, string prompText, asset iconImage, vector offset = <0,0,0> )
{
	Assert( IsNewThread(), "Must be threaded off" )

	object.EndSignal( "OnDestroy" )

	string radiusFlag = "PVEUseObjectWaypointFlag" + UniqueString()
	string enableFlag = "PVEUseObjectEnableFlag" + UniqueString()
	FlagInit( radiusFlag )
	FlagInit( enableFlag )
	FlagSet( enableFlag )

	object.e.waypointObjectEnableFlag = enableFlag // hijacking this... it's hacky, but this whole concept is hacky

	entity trigger = SpawnRadiusTrigger( object.GetOrigin(), 1600, 800, 800 )
	trigger.SetParent( object )
	FlagSetTriggerTouchingPlayer( trigger, radiusFlag )

	array<entity> deleteMe
	deleteMe.append( trigger )

	OnThreadEnd(
   		function () : ( deleteMe )
   		{
   			foreach ( ent in deleteMe )
			if ( IsValid( ent ) )
				ent.Destroy()
		}
	)

	while ( true )
	{
		FlagWaitAll( enableFlag, radiusFlag )
		entity wp = CreateWaypoint_Button( object, prompText, iconImage, offset )
		deleteMe.append( wp )

		FlagWaitClearAny( enableFlag, radiusFlag )
		deleteMe.fastremovebyvalue( wp )
		wp.Destroy()
	}
}

void function DeactivateButton( entity button )
{
	FlagClear( button.e.waypointObjectEnableFlag )
	button.Signal( "OnDeactivate" )

	button.UnsetUsable()
	button.SetSkin( 1 )
}

void function ReactivateButton( entity button )
{
	FlagSet( button.e.waypointObjectEnableFlag )
	button.Signal( "OnActivate" )

	button.SetUsable()
	button.SetSkin( 0 )
}

/************************************************************************************************\

 ██████╗ █████╗ ████████╗██╗    ██╗ █████╗ ██╗     ██╗  ██╗
██╔════╝██╔══██╗╚══██╔══╝██║    ██║██╔══██╗██║     ██║ ██╔╝
██║     ███████║   ██║   ██║ █╗ ██║███████║██║     █████╔╝
██║     ██╔══██║   ██║   ██║███╗██║██╔══██║██║     ██╔═██╗
╚██████╗██║  ██║   ██║   ╚███╔███╔╝██║  ██║███████╗██║  ██╗
 ╚═════╝╚═╝  ╚═╝   ╚═╝    ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝

\************************************************************************************************/
void function BuildCatwalk_StyleOverlook( vector origin, vector angles, int numCatwalks, int numStairs, array<entity> cleanup = [] )
{
	vector forward = AnglesToForward( angles )
	vector right = AnglesToRight( angles )

	int solidType = 6 // use vPhysics
	float fadeDist = -1

	entity model = CreatePropDynamicLightweight( MODEL_GRATEFLOOR, origin, angles, solidType, fadeDist )
	model.SetTouchTriggers( false )
	cleanup.append( model )

	vector endRailOrigin = CalcEndRailOrigin( origin, angles, numCatwalks )
	model = CreatePropDynamicLightweight( MODEL_RAILING, endRailOrigin, angles, solidType, fadeDist )
	model.SetTouchTriggers( false )
	cleanup.append( model )

	model = CreatePropDynamicLightweight( MODEL_RAILING, origin + ( forward * -64 ), AnglesCompose( angles, <0,180,0> ), solidType, fadeDist )
	model.SetTouchTriggers( false )
	cleanup.append( model )

	BuildCatwalkSection( origin + ( forward * 128 ), AnglesCompose( angles, <0,90,0> ), numCatwalks, cleanup )
	BuildCatwalkStairs( origin, angles, numStairs, cleanup )
	BuildCatwalkStairs( origin, AnglesCompose( angles, <0,180,0> ), numStairs, cleanup )
}

entity function BuildCatwalk_StyleOverlook_WithButton( vector origin, vector angles, int numCatwalks, int numStairs, string usePrompt1 = "", string usePrompt2 = "", array<entity> cleanup = [] )
{
	vector forward = AnglesToForward( angles )
	vector right = AnglesToRight( angles )

	BuildCatwalk_StyleOverlook( origin, angles, numCatwalks, numStairs, cleanup )

	vector endRailOrigin = CalcEndRailOrigin( origin, angles, numCatwalks )
	entity button = CreatePVEButton( MODEL_CONSOLEBUTTON, endRailOrigin + <0,0,48>, AnglesCompose( angles, <0,-90,20> ), usePrompt1, usePrompt2 )
	cleanup.append( button )

	return button
}

vector function CalcEndRailOrigin( vector origin, vector angles, int num )
{
	vector forward = AnglesToForward( angles )

	return origin + ( forward * 64 ) + ( forward * ( 128 * num ) )
}

void function BuildCatwalkSection( vector origin, vector angles, int num, array<entity> cleanup = [] )
{
	vector forward = AnglesToForward( angles )
	vector right = AnglesToRight( angles )

	int solidType = 6 // use vPhysics
	float fadeDist = -1

	for( int i = 0; i < num; i++ )
	{
		vector deltaR = right * ( 128 * i )

		entity model = CreatePropDynamicLightweight( MODEL_GRATEFLOOR, origin + deltaR, angles, solidType, fadeDist )
		model.SetTouchTriggers( false )
		cleanup.append( model )

		model = CreatePropDynamicLightweight( MODEL_RAILING, origin + deltaR + ( forward * 64 ), angles, solidType, fadeDist )
		model.SetTouchTriggers( false )
		cleanup.append( model )

		model = CreatePropDynamicLightweight( MODEL_RAILING, origin + deltaR + ( forward * -64 ), AnglesCompose( angles, <0,180,0> ), solidType, fadeDist )
		model.SetTouchTriggers( false )
		cleanup.append( model )
	}
}

void function BuildCatwalkStairs( vector origin, vector angles, int num, array<entity> cleanup = [] )
{
	vector forward = AnglesToForward( angles )
	vector right = AnglesToRight( angles )

	int solidType = 6 // use vPhysics
	float fadeDist = -1

	for( int i = 0; i < num; i++ )
	{
		vector deltaR = right * ( 48 * i ) + ( <0,0,-32> * i )

		entity model = CreatePropDynamicLightweight( MODEL_STAIR, origin + deltaR + ( right * 64 ) + <0,0,8>, AnglesCompose( angles, <0,-90,0> ), solidType, fadeDist )
		model.SetTouchTriggers( false )
		cleanup.append( model )

		model = CreatePropDynamicLightweight( MODEL_STAIR_RAILING, origin + deltaR + ( forward * 64 ) + ( right * 64 ) + <0,0,8>, angles, solidType, fadeDist )
		model.SetTouchTriggers( false )
		cleanup.append( model )

		model = CreatePropDynamicLightweight( MODEL_STAIR_RAILING, origin + deltaR + ( forward * -72 ) + ( right * 64 ) + <0,0,8>, angles, solidType, fadeDist )
		model.SetTouchTriggers( false )
		cleanup.append( model )
	}
}

/************************************************************************************************\

████████╗ ██████╗  ██████╗ ██╗     ███████╗
╚══██╔══╝██╔═══██╗██╔═══██╗██║     ██╔════╝
   ██║   ██║   ██║██║   ██║██║     ███████╗
   ██║   ██║   ██║██║   ██║██║     ╚════██║
   ██║   ╚██████╔╝╚██████╔╝███████╗███████║
   ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝╚══════╝

\************************************************************************************************/

entity function AddWaypointToObjectiveEntityGroup( SkitInstance skitInstance, ObjectiveInstance objInstance, entity objectiveEnt, string waypointGroupName, vector offset = <0, 0, 0> )
{
	//only draws the closest one in the group
	//only draws when inside the objective
	entity wp = CreateWaypoint_ObjectiveEnt( objectiveEnt, "" )
	wp.SetLocalOrigin( offset )
	Waypoint_Objectives_BindToObjective( wp, objInstance )
	Waypoint_Objectives_SetHideWhenOutside( wp )
	//wp.SetParent( objectiveEnt, "", true )
	wp.SetWaypointGroupName( waypointGroupName )
	wp.SetWaypointGroupFlags( WPGF_ONLY_DRAW_CLOSEST_ON_HUD )
	return wp
}

bool function ObjectivePlayersCanSeePos( ObjectiveInstance objInstance, vector pos )
{
	array <entity> players = Objectives_GetPlayersInOrNearObjective( objInstance )
	if ( players.len() == 0 )
		return false

	foreach( player in players )
	{
		if ( PlayerCanSeePos( player, pos, true, 50 ) )
			return true
	}

	return false

}

bool function AnyObjectivePlayerInRange( ObjectiveInstance objInstance, vector origin, float dist )
{
	array<entity> players = Objectives_GetPlayersInOrNearObjective( objInstance )
	if ( players.len() == 0 )
		return false

	foreach( player in players )
	{
		if ( Distance( player.GetOrigin(), origin ) < dist )
			return true
	}

	return false
}





/////////////////////////////////////////////////////////

////

array<string> function RollRandomLootForTieredChest( int maxTier, int resultCount )
{
	array<int> whiteListedLoot =
	[
		eLootType.MAINWEAPON,
		eLootType.ATTACHMENT,
		eLootType.ARMOR,
		eLootType.HELMET,
		//eLootType.HEALTH,
		//eLootType.AMMO,
		eLootType.ORDNANCE,
		eLootType.BACKPACK,
	]

	return SURVIVAL_Loot_GetRandomLootRefsOfType( maxTier, resultCount, whiteListedLoot )
}

void function SpawnSimpleSidequestRewards( vector origin, vector angles )
{








	entity box = PVE_CreateLootBox( origin, angles, RollRandomLootForTieredChest( 4, 2 ) )
	PVE_ThrowLootBox( box )
}

entity function PVE_CreateLootBin( vector origin, vector angles )
{
	entity lootbin = CreateEntity( "prop_dynamic" )
	lootbin.SetScriptName( LOOT_BIN_SCRIPTNAME )
	lootbin.SetValueForModelKey( MODEL_LOOT_BIN )
	lootbin.SetOrigin( origin )
	lootbin.SetAngles( angles )
	lootbin.kv.solid = SOLID_VPHYSICS
	DispatchSpawn( lootbin )

	lootbin.SetTouchTriggers( false )

	return lootbin
}

entity function PVE_CreateLootBox( vector origin, vector angles, array<string> lootRefs )
{
	table<entity,array<LootData> > loot
	foreach( player in GetPlayerArray() )
	{
		array<LootData> addLoot
		foreach ( ref in lootRefs )
		{
			LootData data
			data.ref = ref
			data.countPerDrop = SURVIVAL_Loot_GetLootDataByRef( ref ).countPerDrop
			addLoot.append( data )
		}

		loot[ player ] <- addLoot
	}

	entity base = PVE_CreateTeamLootBox( origin, angles, loot )

	return base
}

entity function PVE_CreateTeamLootBox( vector origin, vector angles, table<entity,array<LootData> > loot )
{
	Assert( loot.len() > 0 )

	entity base = __CreateLootBoxBase( origin, angles )

	array<entity> boxes
	foreach ( player, playerLoot in loot )
	{
		array<entity> items = []
		foreach ( data in playerLoot )
		{
			entity ent = SpawnGenericLoot( data.ref, origin,  < -1, -1, -1 >, data.countPerDrop )
			items.append( ent )
		}

		entity box = PVE_CreatePersonalLootBox( player, origin, angles, items )
		box.SetParent( base )
		boxes.append( box )
	}

	foreach( box in boxes )
		thread PVE_DestroyLootCrateThink( box, boxes )

	return base
}

entity function __CreateLootBoxBase( vector origin, vector angles )
{
	entity base = CreatePropDynamic( DEATH_BOX, origin, angles, 6 )
	base.EnableRenderAlways()
	base.AllowMantle()
	base.kv.fadedist = 6000
	base.SetForceVisibleInPhaseShift( true )

	return base
}

entity function PVE_CreatePersonalLootBox( entity player, vector origin, vector angles, array<entity> items )
{
	entity box = CreateUtilityDeathBox( origin, angles, items, "#PVE_DEATHBOX_HINT" )
	box.SetOwner( player  )
	box.SetNetInt( "ownerEHI", EHIToEncodedEHandle( player )  )
	box.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
	box.NotSolid()

	return box
}

void function PVE_DestroyLootCrateThink( entity box, array<entity> boxes )
{
	entity base = box.GetParent()
	Assert( IsValid( base ) )
	base.EndSignal( "OnDestroy" )

	entity owner = box.GetOwner()
	Assert( IsValid( owner ) )
	owner.EndSignal( "OnDestroy" )

	box.EndSignal( "OnDestroy" )

	OnThreadEnd(
   		function () : ( base, box, boxes, owner )
   		{
   			if ( !IsValid( base ) )
   				return

   			if ( IsValid( box ) && !IsValid( owner ) )
   				box.Destroy()

   			foreach ( box in boxes )
			{
				if ( IsValid( box ) )
					return
			}

			PVE_DestroyLootBox( base )
   		}
   	)

   	while ( true )
   	{
   		entity player = expect entity( WaitSignal( box, "OnPlayerUseLong" ).player )
   		Signal( base, "OnPlayerUseLong", { player = player } )
   	}
}

void function PVE_DestroyLootBox( entity base )
{
	vector o = base.GetOrigin()
	vector a = base.GetAngles()
	asset m = base.GetModelName()
	base.Destroy()

	entity newBox = CreatePropDynamic( m, o, a )
	//EmitSoundAtPosition( TEAM_UNASSIGNED, o, "Object_Dissolve" )
	newBox.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 500 )
}

void function PVE_ThrowLootBox( entity box, vector vel = <0,0,200> )
{
	box.NotSolid()
	thread FakePhysicsThrow( null, box, vel, false )
}

void function PROTO_SpawnObjectiveReward( ObjectiveInstance objInstance, int amount, vector origin )
{
	//Just need a placeholder till we figure out exact way to reward token task list items







}


/*
============================================================================================
============================================================================================
============================================================================================

##    ## ########   ######        ##     ## ######## #### ##       #### ######## ##    ##
###   ## ##     ## ##    ##       ##     ##    ##     ##  ##        ##     ##     ##  ##
####  ## ##     ## ##             ##     ##    ##     ##  ##        ##     ##      ####
## ## ## ########  ##             ##     ##    ##     ##  ##        ##     ##       ##
##  #### ##        ##             ##     ##    ##     ##  ##        ##     ##       ##
##   ### ##        ##    ##       ##     ##    ##     ##  ##        ##     ##       ##
##    ## ##         ######         #######     ##    #### ######## ####    ##       ##
============================================================================================
============================================================================================
============================================================================================
*/

void function NPCInvulnerableTillFlagOrPlayerDamage( entity npc, SkitInstance skitInstance, string flag )
{
	//Used before players arrive at a skit for cases where we want critical npcs to be fighting against other factions
	if ( !IsAlive( npc ) )
		return

	AddEntityCallback_OnDamaged( npc, void function ( entity npc, var damageInfo ) : ( skitInstance, flag )
	{
		entity attacker = DamageInfo_GetAttacker( damageInfo )
		if ( !IsValid( attacker) )
			return

		//Abort if player shot me, the objective has been discovered or the skit is over
		if ( SkFlag( skitInstance, flag ) || skitInstance.lifeState >= eSkitLifeState.SHUT_DOWN || attacker.IsPlayer() )
		{
			//RemoveEntityCallback_OnDamaged( npc, ThisFunc() )
			return
		}

		float damageAmount = DamageInfo_GetDamage( damageInfo )
		if ( !IsValid( damageAmount ) )
			return

		//do fractional damage till super low on health then do none
		int npcHealth = npc.GetHealth()
		if ( npcHealth - damageAmount < 10 )
			DamageInfo_SetDamage( damageInfo, 0 )
		else
			DamageInfo_SetDamage( damageInfo, ( damageAmount/10 ) )

		//do some damage to the attacking npc so he eventually dies if the invulnerable npc gets swarmed and can't attack
		attacker.TakeDamage( 10, svGlobal.worldspawn, null, { damageSourceId = eDamageSourceId.crushed, scriptType =  DF_BYPASS_SHIELD | DF_SKIPS_DOOMED_STATE }   )

	} )
}

int function GetRandomCreatureType()
{
	array <int> creatureTypes










	creatureTypes.append( eNPC.SPIDER_JUNGLE )






	creatureTypes.randomize()

	return creatureTypes[0]
}

void function StunNearbyEnemies( vector stunOrigin, float radius)
{
	array <entity> npcs = GetNPCArrayEx( "any", TEAM_ANY, TEAM_ANY, stunOrigin, radius )
	foreach( npc in npcs )
		thread NpcGetsStunned( npc )
}

void function NpcGetsStunned( entity npc )
{
	AssertIsNewThread()

	if ( !IsAlive( npc ) )
		return

	if ( !npc.IsInterruptable() )
		return

	if ( npc.ContextAction_IsBusy() )
		return

	array <string> stunAnims

	switch( npc.ai.npcType )
	{










		/*

		case eNPC.RIFLEMAN:
		case eNPC.SNIPER:
		case eNPC.SHOTGUNNER:
			stunAnims.append( "" )
			break
		case eNPC.SPECTRE:
			stunAnims.append( "" )
			break
		case eNPC.STALKER:
			stunAnims.append( "" )
			break
		case eNPC.LINEBACKER:
			stunAnims.append( "" )
			break
		case eNPC.PROWLER:
			stunAnims.append( "" )
			break
		case eNPC.SPIDER:
			stunAnims.append( "" )
			break
		case eNPC.TICK:
			stunAnims.append( "" )
			break
		case eNPC.VIP:
			stunAnims.append( "" )
			break
		case eNPC.DEATH_SPECTRE:
			stunAnims.append( "" )
			break
		*/
		default:
			printf( "%s() - Unhandled npc. Can't play stun animation: %s", FUNC_NAME(), npc )
			return
	}

	stunAnims.randomize()
	thread PlayAnim( npc, stunAnims[ 0 ] )

}


bool function IsProtectedPveEntity( entity ent )
{
	//tons of stuff in PvP (ultimates, etc) that may want to damage or mess with PvE entities that it has no idea about
	if ( !IsValid( ent ) )
		return true

	string className = ent.GetClassName()

	if ( className == "prop_door" && IsDoorBreachable( ent ) )
		return true

	return false
}
 