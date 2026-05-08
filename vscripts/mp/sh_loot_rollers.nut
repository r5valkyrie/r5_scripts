//=========================================================
//	sh_loot_rollers.nut
//=========================================================

global function ShLootRollers_Init
global function IsLootRoller
global function LootRollerSpawned

#if SERVER
global function Flowstate_StartRollerLootLoop
global function Flowstate_BuildLootForDrone
global function Pathtt_StartRollerLootLoop
#endif

#if CLIENT
global function ServerCallback_SetLootRollerLootTierFX
global function ServerCallback_StopLootRollerFX
#endif // CLIENT

//////////////////////
//////////////////////
//// Global Types ////
//////////////////////
//////////////////////
global const asset LOOT_ROLLER_MODEL              = $"mdl/props/loot_sphere/loot_sphere.rmdl"
global const asset LOOT_ROLLER_EYE_FX             = $"P_loot_ball_flash_CP"
global const int NUM_LOOT_ROLLER_FX_ATTACH_POINTS = 12
global const string FX_ATTACH_ROOT_NAME           = "fx_glow_"
global const asset FX_LOOT_ROLLER_EXPLOSION       = $"P_ball_tick_exp_CP"

///////////////////////
///////////////////////
//// Private Types ////
///////////////////////
///////////////////////
#if CLIENT
struct LootRollerClientData
{
	entity rollerModel
	array<int> eyeFXEnts
	int lootTier = 1
}
#endif

struct
{
	table< entity, table< int, array< string > > > allLootRollers
	#if CLIENT
		table<entity, LootRollerClientData> rollerToClientData
	#endif
} file


////////////////////////
////////////////////////
//// Initialization ////
////////////////////////
////////////////////////
void function ShLootRollers_Init()
{
	if( Gamemode() == eGamemodes.fs_aimtrainer )
		return

	#if SERVER
	AddSpawnCallback( "prop_physics", LootRollerSpawned )
	AddSpawnCallback( "prop_dynamic", LootRollerSpawned )
	#endif

	#if CLIENT
	AddCreateCallback( "prop_physics", LootRollerSpawned )
	AddCreateCallback( "prop_dynamic", LootRollerSpawned )
	#endif
}
/////////////////////////
/////////////////////////
//// Internals       ////
/////////////////////////
/////////////////////////
void function LootRollerSpawned( entity ent )
{
	if ( ent.GetModelName().tolower() != LOOT_ROLLER_MODEL.tolower() )
		return

	file.allLootRollers[ ent ] <- {}

	thread Flowstate_BuildLootForDrone( ent )

	#if CLIENT
	LootRollerClientData data
	data.rollerModel = ent

	int fxIdx = GetParticleSystemIndex( LOOT_ROLLER_EYE_FX )
	for( int i; i < NUM_LOOT_ROLLER_FX_ATTACH_POINTS; i++ )
	{
		int suffixIdx = i + 1
		string attachSuffix = string( suffixIdx )
		int attachIdx = ent.LookupAttachment( FX_ATTACH_ROOT_NAME + attachSuffix )
		int newFx = StartParticleEffectOnEntity( ent, fxIdx, FX_PATTACH_POINT_FOLLOW, attachIdx )
		data.eyeFXEnts.append( newFx )
		EffectSetControlPointColorById( newFx, 1, COLORID_FX_LOOT_TIER0 + data.lootTier )
	}

	data.lootTier = 0

	SetLootRollerClientData( data )
	#endif

	#if SERVER
	thread Flowstate_StartRollerLootLoop( ent )
	#endif
}

const int WHITE_LOOT_TO_SPAWN = 2
const int BLUE_LOOT_TO_SPAWN = 2
const int PURPLE_LOOT_TO_SPAWN = 1
const int YELLOW_LOOT_TO_SPAWN = 1

void function Flowstate_BuildLootForDrone( entity roller, bool isMirageRoller = false )
{
	file.allLootRollers[ roller ] <- {}
	int lootToSpawn

	for(int i = 1; i < 5; i++)
	{
		file.allLootRollers[ roller ][ i ] <- [ ]

		switch( i )
		{
			case 1:
				lootToSpawn = WHITE_LOOT_TO_SPAWN
			break
			case 2:
				lootToSpawn = BLUE_LOOT_TO_SPAWN
			break
			case 3:
				lootToSpawn = PURPLE_LOOT_TO_SPAWN
			break
			case 4:
				lootToSpawn = YELLOW_LOOT_TO_SPAWN
			break
		}

		for(int j = 0; j < lootToSpawn; j++)
		{
			file.allLootRollers[ roller ][ i ].append( SURVIVAL_Loot_GetByTier( i )[RandomIntRangeInclusive(0,SURVIVAL_Loot_GetByTier( i ).len()-1)].ref )
		}
	}

	#if SERVER
	#endif
}

#if SERVER
void function Flowstate_StartRollerLootLoop( entity roller, int tier = 2, int max_tier = 4, bool isMirageRoller = false )
{

}

void function Pathtt_StartRollerLootLoop( entity roller, int tier = 3, int max_tier = 5 )
{

}


#endif


bool function IsLootRoller( entity ent )
{
	return (ent in file.allLootRollers)
}

#if CLIENT
void function SetLootRollerClientData( LootRollerClientData data )
{
	entity roller = data.rollerModel

	if ( roller in file.rollerToClientData )
		return

	file.rollerToClientData[ roller ] <- data
}

LootRollerClientData function GetLootRollerClientDataFromEnt( entity ent )
{
	Assert( ent in file.rollerToClientData, "Attempted to get Loot Roller Client data from a roller that's not in the table!" )

	return file.rollerToClientData[ ent ]
}

//////////////////////////
//////////////////////////
//// Global functions ////
//////////////////////////
//////////////////////////
void function ServerCallback_SetLootRollerLootTierFX( int rollerHandle, int tier, bool hasVaultKey )
{

}

void function ServerCallback_StopLootRollerFX( int rollerHandle )
{

}
#endif // CLIENT
