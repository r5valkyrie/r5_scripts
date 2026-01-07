
#if SERVER || CLIENT || UI
global function VendingMachine_LevelInit
#endif // SERVER || CLIENT || UI

#if SERVER
global function DoVendingMachinePostPickupLogic
global function ClientCommand_OpenVendingMachine
global function ClientCommand_CloseVendingMachine
global function GetVendingMachineInUseByPlayer
global function VendingMachine_CreateSimple

const string SUPPLYBOX_SOUND_OPEN 	= "UI_Survival_SupplyBoxOpen"
const string SUPPLYBOX_SOUND_CLOSE 	= "UI_Survival_SupplyBoxClose"

#if DEVELOPER
global function DEV_VendingMachine_Create
#endif // DEVELOPER
#endif // SERVER

#if SERVER || CLIENT
global function IsVendingMachine
global function IsVendingMachineUnsafe
#endif // SERVER || CLIENT

#if SERVER || CLIENT
const string VENDING_MACHINE_DISABLED_PLAYLIST_VAR = "vending_machine_disabled"

global const string VENDING_MACHINE_SCRIPTNAME = "vending_machine"
global const string VENDING_MACHINE_MOVER_SCRIPTNAME = "vending_machine_mover"
global const string VENDING_MACHINE_CLOSE_CMD = "ClientCallback_CloseVendingMachine"
const string VENDING_MACHINE_OPEN_CMD = "ClientCallback_OpenVendingMachine"

// Use the Death Box as placeholder
const asset SUPPLY_BOX = DEATH_BOX

const asset BLACK_MARKET_WARP_BEAM_FX = $"P_item_warp_travel"

const bool VENDING_MACHINE_DEBUG = false
#endif // SERVER || CLIENT

#if CLIENT
const string FAKEBOX_SCRIPTNAME = "fakebox"
#endif // CLIENT

struct {
	#if SERVER
		table< entity, entity > playersToVendingMachineMap
	#endif // SERVER

	#if CLIENT
		array< entity > vendingMachinesFake
	#endif // CLIENT
} file


#if SERVER || CLIENT || UI
void function VendingMachine_LevelInit()
{
	#if SERVER
		AddClientCommandCallback( VENDING_MACHINE_OPEN_CMD, ClientCommand_OpenVendingMachine )
		AddClientCommandCallback( VENDING_MACHINE_CLOSE_CMD, ClientCommand_CloseVendingMachine )
		Loot_AddCallback_OnPlayerLootPickupRetail( OnPlayerLootPickup )

	#endif // SERVER

	#if CLIENT
		AddCreateCallback( "prop_death_box", OnPropScriptCreated )
	#endif //CLIENT

	//Remote_RegisterClientFunction( "CL_VendingMachineHighlight_Init" )

	RegisterSignal( "highlightSupplyBox" )
}
#endif // SERVER || CLIENT || UI


#if SERVER
void function VendingMachineDeployThread( vector origin, vector angles, entity spawnTarget, int realm = -1 )
{
	if ( GetPlaylistVarBool( GetCurrentPlaylistName(), VENDING_MACHINE_DISABLED_PLAYLIST_VAR, false ) )
		return

	float lootGrabDist = 50000.0

	entity vendingMachine
	{
		vendingMachine = CreateEntity( "prop_death_box" )
		//vendingMachine.SetIsVendingMachine()
		vendingMachine.SetScriptName( VENDING_MACHINE_SCRIPTNAME )
		SetTargetName( vendingMachine, VENDING_MACHINE_SCRIPTNAME )

		vendingMachine.SetValueForModelKey( SUPPLY_BOX )
		vendingMachine.kv.fadedist = 320000
		vendingMachine.kv.solid = SOLID_VPHYSICS
		vendingMachine.kv.contents = CONTENTS_SOLID

		vendingMachine.DisableHibernation()

		vendingMachine.SetOrigin( origin )
		vendingMachine.SetAngles( angles )

		//vendingMachine.SetLootGrabDist( lootGrabDist )
		#if VENDING_MACHINE_DEBUG
			DebugDrawCircle( origin, <0, 0, 0>, lootGrabDist, COLOR_RED, true, 20.0 )
		#endif // VENDING_MACHINE_DEBUG

		vendingMachine.SetAbsOrigin( origin )
		vendingMachine.SetAbsAngles( angles )

		SetVisibleEntitiesInConeQueriableEnabled( vendingMachine, true )

		DispatchSpawn( vendingMachine )

		vendingMachine.SetSkin( vendingMachine.GetSkinIndexByName( "firing_range_mu1" ))

		vendingMachine.kv.impacteffectcolorid = COLORID_FX_LOOT_TIER1
		vendingMachine.SetIgnorePredictedTriggerTypes( TT_JUMP_PAD  )
		vendingMachine.SetPhysics( MOVETYPE_FLY ) // doesn't actually make it move, but allows pushers to interact with it

		vendingMachine.RemoveFromAllRealms()
		if( realm > 0 )
		{
			vendingMachine.AddToRealm ( realm )
		}
		else if ( IsValid( spawnTarget ) )
		{
			CopyRealmsFromTo( spawnTarget, vendingMachine )
		}
		else
		{
			vendingMachine.AddToAllRealms()
		}

		if ( IsValid( spawnTarget ) )
		{
			if ( IsValid (spawnTarget.GetParent()) )
			{
				entity mover = CreateScriptMover( origin, angles )
				mover.SetScriptName( VENDING_MACHINE_MOVER_SCRIPTNAME )
				mover.SetParent( spawnTarget.GetParent() )
				vendingMachine.SetParent( mover )
			}
		}

		SetCallback_CanUseEntityCallback_Retail( vendingMachine, CanUseVendingMachine )
		AddCallback_OnUseEntity_ClientServer( vendingMachine, OnVendingMachineUsed )
		//SetCallback_ShouldUseBlockReloadCallback( vendingMachine, SimpleShouldNotBlockReloadCallback )
	}

	vendingMachine.SetUsable()
	vendingMachine.SetUsableByGroup( "pilot" )
	vendingMachine.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER | USABLE_BY_PILOTS | USABLE_BY_ENEMIES )
	vendingMachine.SetUsablePriority( USABLE_PRIORITY_LOW )

	EndSignal( vendingMachine, "OnDestroy" )

	while( true )
	{
		//eLootTier.NONE causes ALL the loot get spawned
		//TriggerLootSpawnForLootBinsInRadius( vendingMachine.GetOrigin(), lootGrabDist, eLootTier.NONE ) // Need to do this repeatedly as the vending machine may be on moving geo

		wait 0.5
	}
}
#endif // SERVER


#if CLIENT
void function OnPropScriptCreated( entity ent )
{
	if ( ent.GetScriptName() == VENDING_MACHINE_SCRIPTNAME )
	{
		AddEntityCallback_GetUseEntOverrideText( ent, GetVendingMachineUsePromptText )
		SetCallback_CanUseEntityCallback_Retail( ent, CanUseVendingMachine )
		AddCallback_OnUseEntity_ClientServer( ent, OnVendingMachineUsed )
		//SetCallback_ShouldUseBlockReloadCallback( ent, SimpleShouldNotBlockReloadCallback )

		CL_VendingMachineFake_Create( ent.GetOrigin(), ent.GetAngles() )
	}
}

void function CL_VendingMachineFake_Create( vector pos, vector angles )
{
	// Create a geo-only vending machine for use in highlighting.
	entity fakeBox = CreateClientSidePropDynamic( pos, angles, SUPPLY_BOX  )
	fakeBox.SetScriptName( FAKEBOX_SCRIPTNAME )
	fakeBox.SetSkin( fakeBox.GetSkinIndexByName( "firing_range_mu1" ))

	fakeBox.SetModelScale( 0.99 )

	file.vendingMachinesFake.append( fakeBox )

	// Start highlight thread immediately
	thread Do_Highlight_Thread( fakeBox )
}

void function CL_VendingMachineHighlight_Init( entity player )
{
	// Try just letting far-fade distance work.
	foreach( fakeBox in file.vendingMachinesFake )
	{
		thread Do_Highlight_Thread( fakeBox )
	}
}

void function Do_Highlight_Thread( entity fakeBox )
{
	if( !IsValid( fakeBox ) )
		return

	fakeBox.Signal( "highlightSupplyBox" )
	fakeBox.EndSignal( "highlightSupplyBox" )
	fakeBox.EndSignal( "OnDestroy" )

	const float HIGHLIGHT_PERIOD = 5

	SetSurvivalPropHighlight( fakeBox, "firingrange_supplybox", false )

	while( IsValid( fakeBox ) )
	{
		// NOTE: Far distance is dictated in sh_highlight.gnut by the "firingrange_supplybox" registered highlight type.
		FiringRangeSupplyBoxHighlight( fakeBox )
		wait( HIGHLIGHT_PERIOD )
	}
}
#endif // CLIENT


#if SERVER
void function DoVendingMachinePostPickupLogic( entity player, entity vendingMachine, entity lootEnt, LootData lootFlav, int unitsPickedUp, int pickupFlags )
{
	entity lootEntParent = lootEnt.GetParent()
	if ( IsValid( lootEntParent ) )
	{
		if ( lootEntParent.GetScriptName() == LOOT_BIN_SCRIPTNAME )
		{
			bool shouldOpenRegularCompartment = true
			bool shouldOpenSecretCompartment  = lootEnt.e.isSecretLoot
			//thread LootBin_ForceOpen_Thread( lootEntParent, shouldOpenRegularCompartment, shouldOpenSecretCompartment )
		}
		else if ( lootEntParent.GetScriptName() == CARE_PACKAGE_SCRIPTNAME )
		{
			//if ( lootEntParent.DoesShareRealms( player ) ) // suspect fix for http://jiratf.respawn.net:8080/browse/R5DEV-230699
				//thread RemoteOpenAirdrop( lootEntParent, null )
		}
	}

	if ( lootFlav.lootType == eLootType.MAINWEAPON && GetWeaponInfoFileKeyField_GlobalBool( lootFlav.baseWeapon, "uses_ammo_pool" ) )
	{
		if ( GetCurrentPlaylistVarBool( "loba_ultimate_refill_weapon_clip", true ) )
		{
			entity newMainWeapon = player.p.justCreatedSurvivalMainWeapon
			Assert( IsValid( newMainWeapon ) && newMainWeapon.GetWeaponClassName() == lootFlav.baseWeapon )
			if ( newMainWeapon.UsesClipsForAmmo() )
				newMainWeapon.SetWeaponPrimaryClipCount( newMainWeapon.GetWeaponPrimaryClipCountMax() )
		}
	}
}
#endif // SERVER


#if SERVER
void function OnPlayerLootPickup( entity player, entity lootEnt, string ref, int unitsPickedUp, bool willDestroy, entity vendingMachine, int pickupFlags )
{
	LootData lootFlav = SURVIVAL_Loot_GetLootDataByRef( ref )

	if ( !IsValid( vendingMachine ) )
		return

	if ( !IsValid( lootEnt ) )
		return

	if ( vendingMachine.GetScriptName() != VENDING_MACHINE_SCRIPTNAME )
		return

	Assert( unitsPickedUp > 0, "In OnPlayerLootPickup with unitsPickedUp: " + unitsPickedUp + ". player: " + player + " lootRef: " + ref )

	DoVendingMachinePostPickupLogic( player, vendingMachine, lootEnt, lootFlav, unitsPickedUp, pickupFlags )
}
#endif // SERVER


#if SERVER
void function WarpBeamFXThread( entity player, vector startPos, vector endPos )
{
	entity controlPoint = CreateEntity( "info_placement_helper" )
	SetTargetName( controlPoint, UniqueString( "translocation_endPos" ) )
	controlPoint.SetOrigin( endPos )
	CopyRealmsFromTo( player, controlPoint )
	DispatchSpawn( controlPoint )

	entity beamFX = CreateEntity( "info_particle_system" )
	beamFX.SetValueForEffectNameKey( BLACK_MARKET_WARP_BEAM_FX )
	beamFX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	beamFX.kv.cpoint1 = controlPoint.GetTargetName()
	beamFX.kv.start_active = 1
	beamFX.SetOrigin( startPos )
	CopyRealmsFromTo( player, beamFX )
	DispatchSpawn( beamFX )

	OnThreadEnd( function () : ( beamFX, controlPoint ) {
		if ( IsValid( beamFX ) )
			beamFX.Destroy()

		if ( IsValid( controlPoint ) )
			controlPoint.Destroy()
	} )

	wait 2.0
}
#endif // SERVER

#if SERVER
bool function ClientCommand_OpenVendingMachine( entity player, array<string> args )
{
	if ( args.len() < 1 )
		return true

	entity grabber = GetEntByIndex( args[0].tointeger() )

	if ( !IsValid( grabber ) || grabber.GetNetworkedClassName() != "prop_death_box" || !IsValid( player ) || !player.IsPlayer() )
		return true

	//grabber.IncrementPlayersGrabbingLoot()
	EmitSoundOnEntityOnlyToPlayer( grabber, player, SUPPLYBOX_SOUND_OPEN )

	return true
}
#endif // SERVER


#if SERVER
bool function ClientCommand_CloseVendingMachine( entity player, array<string> args )
{
	if ( args.len() < 1 )
		return true

	entity grabber = GetEntByIndex( args[0].tointeger() )

	if ( !IsValid( grabber ) || grabber.GetNetworkedClassName() != "prop_death_box" || !IsValid( player ) || !player.IsPlayer() )
		return true

	//grabber.DecrementPlayersGrabbingLoot()
	EmitSoundOnEntityOnlyToPlayer( grabber, player, SUPPLYBOX_SOUND_CLOSE )

	// do not trust the integrity of tables-as-maps; too many errors so checking for existence based on live game issues
	if ( player in file.playersToVendingMachineMap )
		delete file.playersToVendingMachineMap[ player ]

	return true
}
#endif // SERVER

#if SERVER
entity function GetVendingMachineInUseByPlayer( entity player )
{
	entity grabber = null

	if ( !IsValid( player ) )
		return grabber

	if ( player in file.playersToVendingMachineMap )
		grabber = file.playersToVendingMachineMap[ player ]

	return grabber
}
#endif // SERVER


#if CLIENT
string function GetVendingMachineUsePromptText( entity device )
{
	return "#VENDING_MACHINE_USE_HINT"
}
#endif // CLIENT


#if SERVER || CLIENT
bool function CanUseVendingMachine( entity player, entity ent, int useFlags )
{
	return SURVIVAL_PlayerAllowedToPickup( player )
}
#endif // SERVER || CLIENT

#if SERVER || CLIENT
bool function IsVendingMachine( entity ent )
{
	if ( IsValid(ent) && ent.GetNetworkedClassName() == "prop_death_box" )
	{
		return true//ent.IsVendingMachine()
	}

	return false
}

//faster if you already know that the ent is valid and is a prop_loot_grabber
bool function IsVendingMachineUnsafe( entity ent )
{
	return false//ent.IsVendingMachine()
}
#endif // SERVER || CLIENT


#if SERVER || CLIENT
void function OnVendingMachineUsed( entity vendingMachine, entity player, int useInputFlags )
{
	if ( !IsBitFlagSet( useInputFlags, USE_INPUT_LONG ) )
		return

	if ( IsBitFlagSet( useInputFlags, USE_INPUT_ALT ) )
		return

	#if CLIENT
		if ( Survival_IsGroundlistOpen() )
			return
	#endif

	thread (void function() : ( vendingMachine, player ) {
		ExtendedUseSettings settings
		settings.duration = 0.3
		settings.disableWeaponTypes = WPT_TACTICAL | WPT_ULTIMATE | WPT_CONSUMABLE
		settings.loopSound = "UI_Survival_PickupTicker"
		settings.successSound = ""
		#if CLIENT
			settings.displayRui = $"ui/extended_use_hint.rpak"
			settings.displayRuiFunc = void function( entity vendingMachine, entity player, var rui, ExtendedUseSettings settings )
			{
				RuiSetString( rui, "holdButtonHint", settings.holdHint )
				RuiSetString( rui, "hintText", settings.hint )
				RuiSetGameTime( rui, "startTime", Time() )
				RuiSetGameTime( rui, "endTime", Time() + settings.duration )
			}
			settings.icon = $""
			settings.hint = "#PROMPT_OPEN"
			settings.successFunc = void function( entity vendingMachine, entity player, ExtendedUseSettings settings )
			{
				OpenSurvivalGroundListRetail( player, vendingMachine, eGroundListBehavior.NEARBY, eGroundListType.VENDINGMACHINE )
				player.ClientCommand( VENDING_MACHINE_OPEN_CMD + " " + vendingMachine.GetEntIndex() )
			}
		#endif

		#if CLIENT
			EndSignal( clGlobal.levelEnt, "ClearSwapOnUseThread" )
		#endif
		EndSignal( vendingMachine, "OnDestroy" )
		waitthread ExtendedUse( vendingMachine, player, settings )
	})()
}
#endif // SERVER || CLIENT

#if SERVER
void function VendingMachine_CreateSimple( vector location, vector angles = < 0,0,0>, int realm = -1 )
{
	thread VendingMachineDeployThread( location, angles, null, realm )
}

void function DEV_VendingMachine_Create( entity player )
{
	if ( IsValid(player) )
	{
		thread VendingMachineDeployThread( player.GetOrigin(), player.GetAngles(), player )
	}
}
#endif // SERVER