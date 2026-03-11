#if SERVER || CLIENT
global function ShFiringRangeStoryEvents_Init
#endif

struct RealmStoryData
{
	entity door
}

struct
{
	table< int,  RealmStoryData > realmStoryDataByRealmTable
} file

const array<string> BTS_DIALOGUE_ARRAY = [ ]

const asset BTS_DOOR_MDL = $"mdl/door/metal_swinging_door_01.rmdl"
const string BTS_DOOR_SCRIPT_NAME = "FR_BTS_DOOR_SCRIPTNAME"

// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
//
//  #### ##    ## #### ########
//   ##  ###   ##  ##     ##
//   ##  ####  ##  ##     ##
//   ##  ## ## ##  ##     ##
//   ##  ##  ####  ##     ##
//   ##  ##   ###  ##     ##
//  #### ##    ## ####    ##
//
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================

#if SERVER || CLIENT
void function ShFiringRangeStoryEvents_Init()
{
	if ( GetMapName() != "mp_rr_canyonlands_staging_mu1" ) //keeping it broad for testing with dev playlists
		return

	if ( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		return

	PrecacheScriptString( BTS_DOOR_SCRIPT_NAME )

	AddCallback_EntitiesDidLoad( EntitiesDidLoad )

	#if SERVER
		AddSpawnCallback( "prop_dynamic", BTSDoorSpawned )
		// Survival_AddCallback_OnPlayerSetupComplete( OnPlayerSetupComplete ) // S3: callback system not available
	#endif

	RegisterSignal( "EndBTSConvo" )
}
#endif

#if SERVER || CLIENT
void function EntitiesDidLoad()
{

}
#endif // SERVER || CLIENT


#if SERVER
void function BTSDoorSpawned( entity ent )
{
	if ( IsValid( ent ) && ent.GetScriptName() == BTS_DOOR_SCRIPT_NAME)
	{
		thread SetupBTSDoors( ent.GetOrigin(), ent.GetAngles() )
		ent.Destroy()
	}

}


void function SetupBTSDoors( vector origin, vector angles )
{
	array<int> allCommonPlayerRealms = GetAllPlayerCommonRealms()
	foreach( int realm in allCommonPlayerRealms )
	{
		CreateBTSDoor( realm, origin, angles )
		WaitFrame() // Can only create range one realm per frame or we run out of physics jobs on the movers
	}

}

void function CreateBTSDoor( int realm, vector origin, vector angles )
{
	entity ent = CreatePropScript( BTS_DOOR_MDL, origin, angles )
	ent.RemoveFromAllRealms()
	ent.AddToRealm( realm )

	SetDoorSkin( ent )
	ent.SetUsable()
	ent.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER | USABLE_BY_PILOTS | USABLE_BY_ENEMIES | USABLE_USE_VERTICAL_LINE )
	ent.SetUsablePriority( USABLE_PRIORITY_HIGH )
	ent.SetUsePrompts( "#S17CR_INTERACT", "#S17CR_INTERACT" )
	AddCallback_OnUseEntity_ServerOnly( ent, BTSDoor_OnUse )
	SetCallback_CanUseEntityCallback( ent, BTSDoor_CanUse )

	RealmStoryData rsd
	rsd.door = ent

	file.realmStoryDataByRealmTable[ realm ] <- rsd
}

void function BTSDoor_OnUse( entity door, entity player, int useInputFlags )
{
	door.UnsetUsable()

	if ( !IsConvoActive()  )
	{
		PlayBattleChatterLineToPlayer( "bc_firingrange_btsdoor", player, player )
		thread BTS_DoorCooldownThread( door )
		return
	}

	/*array< entity > teamPlayers = GetPlayerArrayOfTeam( player.GetTeam() )
	foreach ( teamPlayer in teamPlayers)
	{
		if ( IsPlayerOneOfCharacters( teamPlayer, ["character_lifeline", "character_octane"] ) )
		{
			PlayBattleChatterLineToPlayer( "bc_firingrange_btsdoor", player, player )
			thread BTS_DoorCooldownThread( door )
			return
		}
	}
	
	thread BTSDoorConvoThread( door )*/
}

void function BTS_DoorCooldownThread( entity door )
{
	door.EndSignal( "OnDestroy" )

	wait 10.0
	door.SetUsable()
}

/*void function BTSDoorConvoThread( entity door )
{
	if ( !IsValid( door ) )
		return

	door.EndSignal( "OnDestroy" )
	RealmInfoEntity_EndSignal( door.GetRealms()[0],"EndBTSConvo")

	OnThreadEnd(
		function() : ( door )
		{
			if ( IsValid ( door ) )
			{
				thread BTS_DoorCooldownThread( door )
				foreach ( convo in BTS_DIALOGUE_ARRAY)
				{
					StopSoundOnEntity( door, convo )
				}
			}

		}
	)
	
	foreach ( convo in BTS_DIALOGUE_ARRAY)
	{
		wait EmitSoundOnEntity( door, convo )
	}
}*/

bool function BTSDoor_CanUse( entity player, entity door ) // S3: no useFlags param
{
	if ( !IsValid ( player ) )
		return false
	if ( !IsAlive( player ) )
		return false
	if( Bleedout_IsBleedingOut( player ) )
		return false

	return true
}

void function OnPlayerSetupComplete( entity player )
{
	if ( !IsValid ( player ) )
		return

	int realm = player.GetRealms()[0]
	if ( !(realm in file.realmStoryDataByRealmTable)  )
		return

	if ( !IsValid( file.realmStoryDataByRealmTable[ realm ].door ) )
		return


	SetDoorSkin( file.realmStoryDataByRealmTable[ realm ].door )
}

void function SetDoorSkin( entity door )
{
	if ( IsConvoActive() )
	{
		door.SetSkin( 0 )
	}
	else
	{
		door.SetSkin( 1 )
		return
	}

/*	int realm = door.GetRealms()[0]
	array<entity> players = GetAllPlayersInRealm( realm )
	foreach ( player in players )
	{
		if ( IsPlayerOneOfCharacters( player, ["character_lifeline", "character_octane"] ) )
		{
			RealmInfoEntity_Signal( realm, "EndBTSConvo" )
			door.SetSkin( 1 )
			return
		}
	}
*/
}

bool function IsConvoActive()
{
	return false
}
#endif

