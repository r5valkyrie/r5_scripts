#if DEVELOPER
untyped
#endif


global function ModelViewer_Init

global function ToggleModelViewer

#if DEVELOPER
struct
{
	array<asset> modelViewerModels

	bool initialized
	bool active
	entity gameUIFreezeControls
	array<string> playerWeapons
	array<string> playerOffhands
	bool dpadUpPressed = true
	bool dpadDownPressed = true
	//var lastTitanAvailability
} file
#endif // DEVELOPER

void function ModelViewer_Init()
{
	#if DEVELOPER
		if ( reloadingScripts )
			return
		AddClientCommandCallback( "ModelViewer", ClientCommand_ModelViewer ) // dev
	#endif // DEVELOPER
}

void function ToggleModelViewer()
{
	#if DEVELOPER
		WaitFrame()
		entity player = GetPlayerArray()[ 0 ]
		if ( !file.active )
		{
			file.active = true

			player.SetPlayerNetBool( "pingEnabled", false )

			DisablePrecacheErrors()
			wait 0.5

			ModelViewerDisableConflicts()

			ReloadShared()

			if ( !file.initialized )
			{
				file.initialized = true
				ControlsInit()
			}

			Remote_CallFunction_NonReplay( player, "ServerCallback_MVEnable" )

			//file.lastTitanAvailability = level.nv.titanAvailability
			//Riff_ForceTitanAvailability( eTitanAvailability.Never )

			WeaponsRemove()
			thread UpdateModelBounds()
			PilotAbilitySelectMenu_SetEnabled( false )
		}
		else
		{
			file.active = false
			PilotAbilitySelectMenu_SetEnabled( true )

			player.SetPlayerNetBool( "pingEnabled", true )

			Remote_CallFunction_NonReplay( player, "ServerCallback_MVDisable" )
			RestorePrecacheErrors()

			//Riff_ForceTitanAvailability( file.lastTitanAvailability )

			WeaponsRestore()
		}
	#endif // DEVELOPER
}

#if DEVELOPER
void function ModelViewerDisableConflicts()
{
	disable_npcs() //Just disable_npcs() for now, will probably add things later
}

void function ReloadShared()
{
	file.modelViewerModels = GetModelViewerList()
}

void function ControlsInit()
{
	file.gameUIFreezeControls = CreateEntity( "game_ui" )
	file.gameUIFreezeControls.kv.spawnflags = 32
	file.gameUIFreezeControls.kv.FieldOfView = -1.0

	DispatchSpawn( file.gameUIFreezeControls )
}

bool function ClientCommand_ModelViewer( entity player, array<string> args )
{
	//string command = args.remove( 0 )
	//switch ( command )
	{
		//case "freeze_player":
			file.gameUIFreezeControls.Fire( "Activate", "!player", 0 )
			//break

		//case "unfreeze_player":
			file.gameUIFreezeControls.Fire( "Deactivate", "!player", 0 )
			//break
	}

	return true
}

void function UpdateModelBounds()
{
	wait( 0.3 )

	foreach ( index, modelName in file.modelViewerModels )
	{
		entity model = CreatePropDynamic( modelName )
		vector mins = model.GetBoundingMins()
		vector maxs = model.GetBoundingMaxs()

		mins.x = min( -8.0, mins.x )
		mins.y = min( -8.0, mins.y )
		mins.z = min( -8.0, mins.z )

		maxs.x = max( 8.0, maxs.x )
		maxs.y = max( 8.0, maxs.y )
		maxs.z = max( 8.0, maxs.z )

		Remote_CallFunction_NonReplay( GetPlayerArray()[ 0 ], "ServerCallback_MVUpdateModelBounds", index, mins.x, mins.y, mins.z, maxs.x, maxs.y, maxs.z )
		model.Destroy()
	}
}

void function WeaponsRemove()
{
	entity player = GetPlayerArray()[0]
	if ( !IsValid( player ) )
		return

	file.playerWeapons.clear()
	file.playerOffhands.clear()

	array<entity> weapons = player.GetMainWeapons()
	foreach ( weaponEnt in weapons )
	{
		string weapon = weaponEnt.GetWeaponClassName()
		file.playerWeapons.append( weapon )
		player.TakeWeapon( weapon )
	}

	array<entity> offhands = player.GetOffhandWeapons()
	foreach ( index, offhandEnt in offhands )
	{
		string offhand = offhandEnt.GetWeaponClassName()
		file.playerOffhands.append( offhand )
		player.TakeOffhandWeapon( index )
	}
}

void function WeaponsRestore()
{
	entity player = GetPlayerArray()[0]
	if ( !IsValid( player ) )
		return
	foreach ( weapon in file.playerWeapons )
	{
		player.GiveWeapon( weapon, WEAPON_INVENTORY_SLOT_ANY )
	}

	foreach ( index, offhand in file.playerOffhands )
	{
		if ( offhand != "" )
			player.GiveOffhandWeapon( offhand, index )
	}
}

#endif // DEVELOPER