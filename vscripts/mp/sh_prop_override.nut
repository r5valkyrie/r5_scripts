global function PropOverride_Init

// The purpose of this file is to allow for easy managment of dynamic prop reskining and basic interaction via csv file.

#if SERVER
struct PropReskinData
{
	string skinName
	int priority


	string className // Only use for EditorClassName
	string scriptName
	string targetName
}

enum PropReskinMethod
{
	AddSpawnCallbackEditorClass,
	AddSpawnCallback
}
#endif

struct
{
#if SERVER
	table< string, PropReskinData > propReskinDataByScriptNameTable
	table< string, PropReskinData > propReskinDataByEditorClassNameTable
#endif
} file


void function PropOverride_Init()
{
#if SERVER
	RegisterPropReskinDatable()
#endif

	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
}

#if DEV
const bool PRINT_DEBUG = true
#endif


#if SERVER
void function RegisterPropReskinDatable()
{
	var dataTable = GetDataTable( $"datatable/prop_reskin.rpak" )
	int numRows   = GetDataTableRowCount( dataTable )

	int scriptNameColumn                = GetDataTableColumnByName( dataTable, "scriptName" )
	int classNameColumn      			= GetDataTableColumnByName( dataTable, "className" )
	int editorClassNameColumn			= GetDataTableColumnByName( dataTable, "editorClassName" )
	int targetNameColumn				= GetDataTableColumnByName( dataTable, "targetName" )
	int skinNameColumn           		= GetDataTableColumnByName( dataTable, "skinName" )
	int priorityColumn  				= GetDataTableColumnByName( dataTable, "priority" )
	int checkTypeColumn					= GetDataTableColumnByName( dataTable, "checkType" )
	int variableNameColumn     			= GetDataTableColumnByName( dataTable, "variableName" )
	int caleventColumn          		= GetDataTableColumnByName( dataTable, "calevent" )
	int negativeCheckColumn     		= GetDataTableColumnByName( dataTable, "negativeCheck" )

	#if DEV
		if ( PRINT_DEBUG )
			printf( "[RegisterPropReskinDatable] Starting Process - Total Number of Rows: %i", numRows )
	#endif

	int unixTimeNow = GetUnixTimestamp()

	for ( int i = 0; i < numRows; i++ )
	{
		#if DEV
			if ( PRINT_DEBUG )
				printf( "[RegisterPropReskinDatable] Row: %i", i )
		#endif

		string scriptName     		 		= GetDataTableString( dataTable, i, scriptNameColumn )
		string targetName					= GetDataTableString( dataTable, i, targetNameColumn )
		string className           			= GetDataTableString( dataTable, i, classNameColumn )
		string editorClassName           	= GetDataTableString( dataTable, i, editorClassNameColumn )
		string skinName           			= GetDataTableString( dataTable, i, skinNameColumn )
		int checkType        				= GetDataTableInt( dataTable, i, checkTypeColumn )
		string variableName      		    = GetDataTableString( dataTable, i, variableNameColumn )
		asset calevent 		 			    = GetDataTableAsset( dataTable, i, caleventColumn )
		bool negativeCheck					= GetDataTableBool( dataTable, i, negativeCheckColumn )
		int priority        				= GetDataTableInt( dataTable, i, priorityColumn )

		//Assert( ( ((scriptName == "") && ( className != "" )  && ( editorClassName != "" )) || ((scriptName != "") && ( className == "" )  && ( editorClassName == "" )) ), "[RegisterPropReskinDatable] Incorrect configuration. ."  )
		Assert( skinName != "", "[RegisterPropReskinDatable] skin name field cannot be empty"  )

		int method

		if ( editorClassName != ""  )
		{
			method = PropReskinMethod.AddSpawnCallbackEditorClass
		}
		else if ( scriptName != "" )
		{
			method = PropReskinMethod.AddSpawnCallback
		}
		else
		{
			Assert( false, "[RegisterPropReskinDatable] incorrect configuration for script name / editor class name / class name." )
		}

		switch ( checkType )
		{
			case 0: // Always override
			break
			case 1: // gamemode
			{
				Assert( variableName != "", "[RegisterPropReskinDatable] variableName field can't be empty for check type gamemode." )
				#if DEV
					if ( PRINT_DEBUG )
						printf( "[RegisterPropReskinDatable] Row: %i - Gamemode(%s) - current Gamemode(%s) - isNegativeCheck(%s)", i, variableName, GameRules_GetGameMode(), ( negativeCheck ) ? "true" : "false" )
				#endif

				bool isVariableActiveGameMode = GameRules_GetGameMode() == variableName

				if ( (negativeCheck && isVariableActiveGameMode) || (!negativeCheck && !isVariableActiveGameMode) )
					continue
			}
			break
			case 2: // bakery calevent
			{
				Assert( calevent != $"", "[RegisterPropReskinDatable] bakery calevent field can't be empty for check type bakery calevent" )
				ItemFlavor eventFlav = GetItemFlavorByAsset( calevent )
				Assert( IsCalEvent( ItemFlavor_GetType(eventFlav) ), "[SetupMapCleanUpFromDatatable] Specified event is not of type calevent." )
				bool isCalEventActive = CalEvent_IsActive( eventFlav, unixTimeNow )
				#if DEV
					if ( PRINT_DEBUG )
						printf( "[RegisterPropReskinDatable] Row: %i - IsCalEventActive(%s) - isNegativeCheck(%s)", i, ( isCalEventActive ) ? "true" : "false", ( negativeCheck ) ? "true" : "false" )
				#endif
				if ( (negativeCheck && isCalEventActive) || (!negativeCheck && !isCalEventActive) )
					continue
			}
			break
			case 3: // bool playlist var
			{
				Assert( variableName != "", "[RegisterPropReskinDatable] variableName field can't be empty for check type bool playlist var." )
				bool boolVar = GetCurrentPlaylistVarBool( variableName, false )
				#if DEV
					if ( PRINT_DEBUG )
						printf( "[RegisterPropReskinDatable] Row: %i - Boolean Playlist Var(%s) - value(%s) - isNegativeCheck(%s) ", i, variableName,( boolVar ) ? "true" : "false", ( negativeCheck ) ? "true" : "false" )
				#endif

				if ( (negativeCheck && boolVar) || (!negativeCheck && !boolVar) )
					continue

			}
			break
			case 4: // timestamp playlist var
			{
				Assert( variableName != "", "[RegisterPropReskinDatable] variableName field can't be empty for check type timestamp playlist var." )
				bool isVariableActive =  ( unixTimeNow >= expect int(GetCurrentPlaylistVarTimestamp( variableName, UNIX_TIME_FALLBACK_2038 ) ) )
				#if DEV
					if ( PRINT_DEBUG )
						printf( "[RegisterPropReskinDatable] Row: %i - timestamp Playlist Var(%s) - value(%i) - currentUnixTimestamp(%s) - isNegativeCheck(%s) ", i, variableName, ( expect int(GetCurrentPlaylistVarTimestamp( variableName, UNIX_TIME_FALLBACK_2038 ) ) ), unixTimeNow, ( negativeCheck ) ? "true" : "false" )
				#endif

				if ( (negativeCheck && isVariableActive) || (!negativeCheck && !isVariableActive) )
					continue
			}
			break
			case 5: // map name
			{
				Assert( variableName != "", "[RegisterPropReskinDatable] variableName field can't be empty for check type map name." )
				bool isMapActive = ( variableName == GetMapName() ) || ( GetMapName().find( variableName ) != -1 )
				#if DEV
					if ( PRINT_DEBUG )
						printf( "[RegisterPropReskinDatable] Row: %i - map(%s) - current map(%s) - isNegativeCheck(%s)", i, variableName, GetMapName(), ( negativeCheck ) ? "true" : "false" )
				#endif

				if ( (negativeCheck && isMapActive) || (!negativeCheck && !isMapActive) )
					continue
			}
			break
			default:
				Assert( false, "[RegisterPropReskinDatable] Invalid value of checkType " + checkType + " specified. "   )
				break

		}


		if ( method == PropReskinMethod.AddSpawnCallbackEditorClass )
		{
			if ( editorClassName in file.propReskinDataByEditorClassNameTable )
			{
				if ( priority > file.propReskinDataByEditorClassNameTable[ editorClassName ].priority )
					file.propReskinDataByEditorClassNameTable[ editorClassName ].skinName = skinName
			}
			else
			{
				PropReskinData prd
				prd.priority = priority
				prd.skinName = skinName
				prd.className = className
				prd.scriptName = scriptName
				prd.targetName = targetName
				file.propReskinDataByEditorClassNameTable[editorClassName] <- prd

				AddSpawnCallbackEditorClass( className, editorClassName, PropReskin_PropSpawned_EditorClass )
			}
		}
		else if ( method == PropReskinMethod.AddSpawnCallback )
		{
			if ( scriptName in file.propReskinDataByScriptNameTable )
			{
				if ( priority > file.propReskinDataByScriptNameTable[ scriptName ].priority )
					file.propReskinDataByScriptNameTable[ scriptName ].skinName = skinName
			}
			else
			{
				PropReskinData prd
				prd.priority = priority
				prd.skinName = skinName
				prd.className = className
				prd.targetName = targetName
				file.propReskinDataByScriptNameTable[scriptName] <- prd

				AddSpawnCallback( className, PropReskin_PropSpawned )
			}
		}
	}
}

void function PropReskin_PropSpawned_EditorClass( entity prop )
{
	string editorClassName = GetEditorClass( prop )
	if ( !( editorClassName in file.propReskinDataByEditorClassNameTable ) )
		return

	PropReskinData prd = file.propReskinDataByEditorClassNameTable[editorClassName]

	if ( prop.GetClassName() != prd.className )
		return

	if ( prd.scriptName != "" && prd.scriptName != prop.GetScriptName() )
		return

	int skinIndex = prop.GetSkinIndexByName( prd.skinName)

	if ( skinIndex == -1 )
	{
		printf("[PropReskin_PropSpawned_EditorClass] Could not find a valid skin index for skin name(%s), on prop editor class name(%s)", prd.skinName, editorClassName)
		return
	}

	prop.SetSkin( skinIndex )
}

void function PropReskin_PropSpawned( entity prop )
{
	if ( !( prop.GetScriptName() in file.propReskinDataByScriptNameTable ) )
		return

	PropReskinData prd = file.propReskinDataByScriptNameTable[prop.GetScriptName()]

	if ( prd.targetName != "" && prd.targetName != prop.GetTargetName() )
		return

	string skinName = prd.skinName
	int skinIndex = prop.GetSkinIndexByName( skinName )
	if ( skinIndex == -1 )
	{
		printf("[PropReskin_PropSpawned] Could not find a valid skin index for skin name(%s), on prop script name(%s)", skinName, prop.GetScriptName())
		return
	}

	prop.SetSkin( skinIndex )
}
#endif

void function EntitiesDidLoad()
{

} 