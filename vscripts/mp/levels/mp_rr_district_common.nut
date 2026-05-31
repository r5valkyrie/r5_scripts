global function District_MapInit_Common
global function CodeCallback_PreMapInit

void function CodeCallback_PreMapInit()
{
	#if SERVER
		LaserMesh_Init()
	#endif
}

void function District_MapInit_Common()
{
	printf( "%s()", FUNC_NAME() )

	//ShPrecacheSkydiveLauncherAssets()

#if SERVER
	//RegisterGeoFixAsset( STORMCATCHER_GEOFIX_MODEL )
	thread KillPlayersUnderMap_Thread( MAP_KILL_VOLUME_OFFSET_TROPIC_ISLAND ) //-2048
#endif // SERVER

	#if SERVER
		//CommonStoryEvents_Init()
	#endif
}