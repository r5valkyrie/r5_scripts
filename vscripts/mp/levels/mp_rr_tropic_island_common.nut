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
	//RegisterGeoFixAsset( STORMCATCHER_GEOFIX_MODEL )

	thread KillPlayersUnderMap_Thread( MAP_KILL_VOLUME_OFFSET_TROPIC_ISLAND ) //-2048
#endif // SERVER


	#if SERVER
		//CommonStoryEvents_Init()
		AddCallback_OnPlayerRespawned( OnPlayerCreated )
	#elseif CLIENT
		//ClCommonStoryEvents_Init()
	#endif
		//TropicsStoryEvents_Init()
}

#if SERVER
void function OnPlayerCreated( entity player )
{
	thread warningprint( player )
}

void function warningprint( entity player )
{
	wait 1
	string wildlife = DEV_TropicsWildlife_GetCampDetailsAllString()
	Dev_PrintMessage(
    player,
    "THIS MAP IS WORK IN PROGRESS",
    "Detected map: " + GetMapName() +
	"\n\nKnown Bugs: Missing ocean water\nBroken wildlife\nSome flickery textures." + "\n\n" + wildlife + "\n\nPlease report any glitch you see outside of known bugs\nto our discord server!",
    25, "SQ_UI_InGame_10SecondTimeWarning" )
}
#endif // SERVER

