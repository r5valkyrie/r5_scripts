global function Gamemodes_Map_Cleanup

// This function is to remove any map objects placed into maps that are gamemode specific
// when that gamemode isn't running
// as such it needs to be run when gamemodes are NOT run inculding if the entire script is featureflag'd out

struct
{
	array<entity> cleanupEntityList
	array<string> cleanupEntScriptNameList
} file

void function Gamemodes_Map_Cleanup()
{
	if ( GetCurrentPlaylistVarBool( "map_cleanup_datatable", true ) )
	{
		SetupMapCleanUpFromDataTable()
	}
	else
	{

		if ( !GameMode_IsActive( eGameModes.FREEDM ) && !IsEventFinale() )

		{
			BlockMapEntityParseCreationOf( "zipline", "freedm_zipline", "" )
			BlockMapEntityParseCreationOf( "script_ref", "", "info_freedm_intro_camera" )
			BlockMapEntityParseCreationOf( "script_ref", "", "info_freedm_airdrop_location" )
			BlockMapEntityParseCreationOf( "func_brush", "", "func_brush_freedm_wall" )
			AddSpawnCallback( "func_brush", Editor_EntityCleanup_FreeDMGeo )
		}




		{
			BlockMapEntityParseCreationOf( "script_ref", "", "info_arenas_defensive_end_location" )
			BlockMapEntityParseCreationOf( "script_ref", "", "info_arenas_airdrop_location" )
			BlockMapEntityParseCreationOf( "script_ref", "", "info_arenas_spawn_location" )
			BlockMapEntityParseCreationOf( "script_ref", "", "info_arenas_end_location" )
		}


		// Cleanup Control Geo if Control is not enabled or feature flagged out
		if ( !GameMode_IsActive( eGameModes.CONTROL ) )

		{
			BlockMapEntityParseCreationOf( "zipline", "control_zipline", "" )
			BlockMapEntityParseCreationOf( "func_brush", "func_brush_control_border", "" )
			BlockMapEntityParseCreationOf( "prop_script", "Control_SetUsableVehicleBase", "control_vehicle_summon_platform" )
			BlockMapEntityParseCreationOf( "prop_dynamic", "Control_FlagProp", "control_flag_prop" )
			BlockMapEntityParseCreationOf( "prop_dynamic", "", "control_gun_rack" )
			BlockMapEntityParseCreationOf( "prop_dynamic", "", "control_gun_rack_panel" )
			BlockMapEntityParseCreationOf( "func_brush", "", "func_brush_control_wall" )
			BlockMapEntityParseCreationOf( "script_ref", "control_skydive_launcher", "script_skydive_launcher" )
			BlockMapEntityParseCreationOf( "script_ref", "", "info_control_team_spawn_area" )
			BlockMapEntityParseCreationOf( "trigger_multiple", "control_trigger_homebase", "" )

			AddSpawnCallbackEditorClass( "prop_script", "control_vehicle_summon_platform", Editor_EntityCleanup )
			//AddSpawnCallbackEditorClass( "prop_script", "control_static_prop", Editor_EntityCleanup ) //TODO SHAWBS DISABLED
			AddSpawnCallbackEditorClass( "prop_dynamic", "control_flag_prop", Editor_EntityCleanup )
			AddSpawnCallbackEditorClass( "prop_dynamic", "control_gun_rack", Editor_EntityCleanup )
			AddSpawnCallbackEditorClass( "prop_dynamic", "control_gun_rack_panel", Editor_EntityCleanup )
			AddSpawnCallbackEditorClass( "script_ref", "script_skydive_launcher", Editor_EntityCleanup_ControlSkyDiveLauncher )
			AddSpawnCallbackEditorClass( "func_brush", "func_brush_control_wall", Editor_EntityCleanup )
			AddSpawnCallback( "func_brush", Editor_EntityCleanup_ControlGeo )
		}


		if( !Perks_Enabled() )

		{
			BlockMapEntityParseCreationOf( "prop_script", "", "script_survival_next_zone_survey_beacon" )
		}


		if ( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) )

		{
			BlockMapEntityParseCreationOf( "script_ref", "info_shadowarmy_map_data", "" )
			AddSpawnCallback( "info_target", Editor_EntityCleanup_EvacNodes )
		}

		/*else if ( IsShadowArmyGamemodeCineVersion() )
		{
			BlockMapEntityParseCreationOf( "func_brush", "func_brush_end_cine", "" )
			BlockMapEntityParseCreationOf( "zipline", "end_cine_zip", "" )
		}*/
		Warning("map cleaning disabled for IsShadowArmyGamemodeCineVersion because shadow army gamemode isnt implemented")


		if ( !GameModeVariant_IsActive( eGameModeVariants.FREEDM_LOCKDOWN ) )

		{
			BlockMapEntityParseCreationOf( "func_brush", "func_brush_lockdown_border", "" )
			BlockMapEntityParseCreationOf( "trigger_multiple", "", "trigger_lockdown_objective" )

		}



		{
			BlockMapEntityParseCreationOf( "prop_script", "ObjectiveBR_SetUsableVehicleBase", "objectivebr_vehicle_summon_platform" )
			AddSpawnCallbackEditorClass( "prop_script", "objectivebr_vehicle_summon_platform", Editor_EntityCleanup )
		}




		{
			BlockMapEntityParseCreationOf( "script_ref", "", "info_bomb_center" )
			BlockMapEntityParseCreationOf( "script_ref", "", "info_bomb_spawn_attacker" )
			BlockMapEntityParseCreationOf( "script_ref", "", "info_bomb_spawn_defender" )
			BlockMapEntityParseCreationOf( "prop_dynamic", "", "info_bomb_site" )
		}




		{
			BlockMapEntityParseCreationOf( "script_ref", "", "info_treasurehunt_spawnpos" )
			BlockMapEntityParseCreationOf( "script_ref", "", "treasurehunt_spawnpos_squad" )
			BlockMapEntityParseCreationOf( "info_move_target", "", "treasurehunt_endpos" )
			BlockMapEntityParseCreationOf( "info_move_target", "", "treasurehunt_trigger_flag" )
		}
	}

	AddCallback_EntitiesDidLoad( OnEntitiesDidLoad_MapEntityCleanup )
}

// Destroy entities on Entities Did Load ( used to destroy entities for disabled modes)
void function OnEntitiesDidLoad_MapEntityCleanup()
{
	foreach( ent in file.cleanupEntityList )
		ent.Destroy()
}

// Add Control Geo for cleanup
void function Editor_EntityCleanup_ControlGeo( entity ent )
{
	if( ent.GetScriptName() != "func_control_geo" )
		return

	file.cleanupEntityList.append( ent )
}

// Add FreeDM Geo for cleanup
void function Editor_EntityCleanup_FreeDMGeo( entity ent )
{
	if( ent.GetScriptName() != "func_brush_freedm_geo" )
		return

	file.cleanupEntityList.append( ent )
}

// Add Control Skydive Launchers to cleanup list
void function Editor_EntityCleanup_ControlSkyDiveLauncher( entity ent )
{
	if ( ent.GetScriptName() != "control_skydive_launcher" )
		return

	file.cleanupEntityList.append( ent )
}

// Add Shadow Army Evac and Evac Ship nodes to cleanup list
void function Editor_EntityCleanup_EvacNodes( entity ent )
{
	if ( ent.GetScriptName() != "script_rev_army_evacpos" && ent.GetScriptName() != "script_rev_army_evacship_pos")
		return

	file.cleanupEntityList.append( ent )
}


#if DEVELOPER
const bool PRINT_DEBUG = true
#endif

void function SetupMapCleanUpFromDataTable()
{
	var dataTable = GetDataTable( $"datatable/map_cleanup.rpak" )
	int numRows   = GetDataTableRowCount( dataTable )

	int mapCleanUpTypeColumn            = GetDataTableColumnByName( dataTable, "mapCleanUpType" )
	int classNameColumn                 = GetDataTableColumnByName( dataTable, "className" )
	int editorClassNameColumn           = GetDataTableColumnByName( dataTable, "editorClassName" )
	int scriptNameColumn                = GetDataTableColumnByName( dataTable, "scriptName" )
	int checkTypeColumn					= GetDataTableColumnByName( dataTable, "checkType" )
	int variableNameColumn     			= GetDataTableColumnByName( dataTable, "variableName" )
	int caleventColumn          		= GetDataTableColumnByName( dataTable, "calevent" )
	int negativeCheckColumn     		= GetDataTableColumnByName( dataTable, "negativeCheck" )

	#if DEVELOPER
		if ( PRINT_DEBUG )
			printf( "[SetupMapCleanUpFromDataTable] Starting Process - Total Number of Rows: %i", numRows )
	#endif

	int unixTimeNow = GetUnixTimestamp()

	for ( int i = 0; i < numRows; i++ )
	{
		#if DEVELOPER
			if ( PRINT_DEBUG )
				printf( "[SetupMapCleanUpFromDataTable] Row: %i", i )
		#endif

		int mapCleanUpType           		= GetDataTableInt( dataTable, i, mapCleanUpTypeColumn )
		string className           	 		= GetDataTableString( dataTable, i, classNameColumn )
		string editorClassName           	= GetDataTableString( dataTable, i, editorClassNameColumn )
		string scriptName     		 		= GetDataTableString( dataTable, i, scriptNameColumn )
		int checkType        				= GetDataTableInt( dataTable, i, checkTypeColumn )
		string variableName      		    = GetDataTableString( dataTable, i, variableNameColumn )
		asset calevent 		 			    = GetDataTableAsset( dataTable, i, caleventColumn )
		bool negativeCheck					= GetDataTableBool( dataTable, i, negativeCheckColumn )

		switch ( checkType )
		{
			case 0: // Always disable
				break
			case 1: // gamemode
				{
					Assert( variableName != "", "[SetupMapCleanUpFromDataTable] variableName field can't be empty for check type gamemode." )
					#if DEVELOPER
						if ( PRINT_DEBUG )
							printf( "[SetupMapCleanUpFromDataTable] Row: %i - Gamemode(%s) - current Gamemode(%s) - isNegativeCheck(%s)", i, variableName, GameRules_GetGameMode(), ( negativeCheck ) ? "true" : "false" )
					#endif

					bool isVariableActiveGameMode = GameRules_GetGameMode() == variableName

					if ( (negativeCheck && isVariableActiveGameMode) || (!negativeCheck && !isVariableActiveGameMode) )
						continue
				}
				break
			case 2: // bakery calevent
				{
					Assert( calevent != $"", "[SetupMapCleanUpFromDataTable] bakery calevent field can't be empty for check type bakery calevent" )
					ItemFlavor eventFlav = GetItemFlavorByAsset( calevent )
					Assert( IsCalEvent( ItemFlavor_GetType(eventFlav) ), "[SetupMapCleanUpFromDataTable] Specified event is not of type calevent." )
					bool isCalEventActive = CalEvent_IsActive( eventFlav, unixTimeNow )
					#if DEVELOPER
						if ( PRINT_DEBUG )
							printf( "[SetupMapCleanUpFromDataTable] Row: %i - IsCalEventActive(%s) - isNegativeCheck(%s)", i, ( isCalEventActive ) ? "true" : "false", ( negativeCheck ) ? "true" : "false" )
					#endif
					if ( (negativeCheck && isCalEventActive) || (!negativeCheck && !isCalEventActive) )
						continue
				}
				break
			case 3: // bool playlist var
				{
					Assert( variableName != "", "[SetupMapCleanUpFromDataTable] variableName field can't be empty for check type bool playlist var." )
					bool boolVar = GetCurrentPlaylistVarBool( variableName, false )
					#if DEVELOPER
						if ( PRINT_DEBUG )
							printf( "[SetupMapCleanUpFromDataTable] Row: %i - Boolean Playlist Var(%s) - value(%s) - isNegativeCheck(%s) ", i, variableName,( boolVar ) ? "true" : "false", ( negativeCheck ) ? "true" : "false" )
					#endif

					if ( (negativeCheck && boolVar) || (!negativeCheck && !boolVar) )
						continue

				}
				break
			case 4: // timestamp playlist var
				{
					Assert( variableName != "", "[SetupMapCleanUpFromDataTable] variableName field can't be empty for check type timestamp playlist var." )
					bool isVariableActive =  ( unixTimeNow >= expect int(GetCurrentPlaylistVarTimestamp( variableName, UNIX_TIME_FALLBACK_2038 ) ) )
					#if DEVELOPER
						if ( PRINT_DEBUG )
							printf( "[SetupMapCleanUpFromDataTable] Row: %i - timestamp Playlist Var(%s) - value(%i) - currentUnixTimestamp(%s) - isNegativeCheck(%s) ", i, variableName, ( expect int(GetCurrentPlaylistVarTimestamp( variableName, UNIX_TIME_FALLBACK_2038 ) ) ), unixTimeNow, ( negativeCheck ) ? "true" : "false" )
					#endif

					if ( (negativeCheck && isVariableActive) || (!negativeCheck && !isVariableActive) )
						continue
				}
				break
			default:
				Assert( false, "[SetupMapCleanUpFromDataTable] Invalid value of checkType " + checkType + " specified. "   )
				break

		}

		switch ( mapCleanUpType )
		{
			case 0:
				#if DEVELOPER
				if ( PRINT_DEBUG )
					printf( "[SetupMapCleanUpFromDataTable] Row: %i - BlockMapEntityParseCreationOf(%s, %s, %s)", i, className, scriptName, editorClassName)
				#endif
				BlockMapEntityParseCreationOf( className, scriptName, editorClassName )
				break
			case 1:
				Assert( (scriptName != ""), "SetupMapCleanUpFromDataTable scriptName is empty for AddSpawnCallback"   )
				file.cleanupEntScriptNameList.append( scriptName )
				AddSpawnCallback( className, Editor_EntityCleanup_ScriptName )
				#if DEVELOPER
				if ( PRINT_DEBUG )
					printf( "[SetupMapCleanUpFromDataTable] Row: %i - AddSpawnCallback(%s) - for scriptName(%s)", i, className, scriptName)
				#endif
				break
			case 2:
				if ( scriptName != "" )
					file.cleanupEntScriptNameList.append( scriptName )
				AddSpawnCallbackEditorClass( className, editorClassName, ( scriptName == "" ) ? Editor_EntityCleanup : Editor_EntityCleanup_ScriptName )
				#if DEVELOPER
				if ( PRINT_DEBUG )
					printf( "[SetupMapCleanUpFromDataTable] Row: %i - AddSpawnCallbackEditorClass(%s, %s) - for scriptName(%s)", i, className, editorClassName, scriptName)
				#endif
				break
			default:
				Assert( false, "SetupMapCleanUpFromDataTable invalid value of mapCleanUpType " + mapCleanUpType + " specified. "   )
				break
		}
	}
}

// Add entities to cleanup list, destroy them on Entities Did Load Callback
void function Editor_EntityCleanup( entity ent )
{
	file.cleanupEntityList.append( ent )
}


void function Editor_EntityCleanup_ScriptName( entity ent )
{
	if ( file.cleanupEntScriptNameList.contains( ent.GetScriptName()) )
		file.cleanupEntityList.append( ent )
}