global function Tropics_MapInit_Common
global function CodeCallback_PreMapInit

const asset STORMCATCHER_GEOFIX_MODEL = $"mdl/tropics/stormcatcher_towerblock_02.rmdl"

void function CodeCallback_PreMapInit()
{
	if ( IsTropicsWildlifeEnabled() )
	{
		TropicsWildlife_PreMapInit()
	}
}

void function Tropics_MapInit_Common()
{
	printf( "%s()", FUNC_NAME() )

	//ShPrecacheSkydiveLauncherAssets()

	////////////////////////
	// Wildlife spawning
	////////////////////////

		TropicsWildlife_Init()
		if ( !IsTropicsWildlifeEnabled() )
		{
			FreelanceNPCs_Init() // needed for the Goliath if the rest of the map Wildlife AI is turned off
		}

#if SERVER
	//AddSpawnCallback_ScriptName( "ss_crush_prevention", HideArmoryTrigger )
	//RegisterGeoFixAsset( STORMCATCHER_GEOFIX_MODEL )

	thread KillPlayersUnderMap_Thread( MAP_KILL_VOLUME_OFFSET_TROPIC_ISLAND ) //-2048
#endif // SERVER


	#if SERVER
		//CommonStoryEvents_Init()
	#elseif CLIENT
		//ClCommonStoryEvents_Init()
	#endif
		//TropicsStoryEvents_Init()
}

#if SERVER
void function HideArmoryTrigger( entity ent )
{
	if( !IsValid( ent ) )
		return

	ent.Destroy()
}
#endif // SERVER