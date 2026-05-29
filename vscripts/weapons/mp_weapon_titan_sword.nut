                          
/* TITAN SWORD NOTES

Welcome to the titan sword
Because this file got huge I split up the sword into several .nut files
They are separated based on the abilities

mp_weapon_titan_sword_block
mp_weapon_titan_sword_dash
mp_weapon_titan_sword_heavy
mp_weapon_titan_sword_launcher
mp_weapon_titan_sword_slam
mp_weapon_titan_sword_super

What remains here are shared functions, accessors, etc

-Pat McD
*/

global function MpWeaponTitanSword_Init
global function OnWeaponActivate_weapon_titan_sword
global function OnWeaponDeactivate_weapon_titan_sword
global function OnMeleeWeaponPrimaryAttack_weapon_titan_sword
global function OnMeleeWeaponSecondaryAttack_weapon_titan_sword
global function OnWeaponCustomActivityEnd_weapon_titan_sword
global function OnWeaponPrimaryAttackAnimEvent_weapon_titan_sword


global function TitanSword_GetMainWeapon
global function TitanSword_ActiveWeaponIsTitanSword
global function TitanSword_WeaponIsTitanSword
global function TitanSword_WeaponRefIsTitanSword
global function TitanSword_DamageSourceIsTitanSword

global function TitanSword_PostCopySanityCheck

global function TitanSword_TryUseFuel
global function TitanSword_HasFuel
global function TitanSword_FillFuel

global function TitanSword_VictimHitOverride
global function TitanSword_LaunchEntity

global function TitanSword_SafelyAddAttackMod
global function TitanSword_CanGoThroughBlockingEntity

#if SERVER
global function TitanSword_ForceStopLootAnim
global function TitanSword_CreateMovementEffects
global function TitanSword_CreateJetDriveJetEffects
global function TitanSword_RemoveModOnDrop
#endif

#if CLIENT
global function TitanSword_DisplayHint
global function TitanSword_GetFuelRui
global function TitanSword_ClientPredictCheck
#endif

#if DEVELOPER
#if SERVER
global function DEV_TitanSword_GiveFuel
global function DEV_TitanSword_InfiniteFuel
global function Dev_TitanSword_ToggleFuel
#endif
#endif

//Names
global const string TITAN_SWORD_WEAPON_REF = "mp_weapon_titan_sword"
const string TITAN_SWORD_LIGHT_SUPER_MOD = "super_melee"

const string TITAN_SWORD_LOOT_MOVER_SCRIPTNAME = "titan_sword_loot_mover"

//Playlist Vars
const string PVAR_TITAN_SWORD_NITRO_TEST = "titan_sword_nitro_test"

//Signals
const string SIG_TITAN_SWORD_STOP_LOOT_ANIM = "TitanSword_StopLootAnim"
global const string SIG_TITAN_SWORD_DEACTIVATE = "TitanSword_Deactivate"
const string SIG_TITAN_SWORD_DESTROY_FUEL_RUI = "TitanSword_DestroyFuelRui"

//Vars
const int TITAN_SWORD_OFFHAND_SLOT = OFFHAND_GENERIC

const float TITAN_SWORD_DASH_NOT_READY_DEBOUNCE_TIME_SEC = 1
const float TITAN_SWORD_MAIN_INSTRUCTIONS_DEBOUNCE_TIME = 45 //Maybe we make this first draw???
const float TITAN_SWORD_INSTRUCTIONS_DEBOUNCE_TIME = 10

//VFX
const asset VFX_TITAN_SWORD_SPEED_TRAIL_BODY = $"P_pilot_dash_trail"
const string VFX_TITAN_SWORD_IMPACT = "pilot_sword_solo"    // solo sword item impact

const asset FX_TITAN_SWORD_LIGHT_SWIPE_FP = $"P_pilot_sword_swipe_light_FP"
const asset FX_TITAN_SWORD_LIGHT_SWIPE_3P = $"P_pilot_sword_swipe_light_3P"

//SFX
const string SFX_TITAN_SWORD_FUEL_READY = "titansword_special_ready_1p"
const string SFX_TITAN_SWORD_FUEL_NOT_READY = "titansword_special_notready_1p"
const string SFX_TITAN_SWORD_LOOT_AIR_LOOP = "titansword_drop_air_spin_LP_3P"

//RUI
const asset RUI_TITAN_SWORD_FUEL_HUD = $"ui/titan_sword_dash_meter.rpak"

// Sword going through
const int GOING_THROUGH_FALSE = 0
const int GOING_THROUGH_TRUE = 1
const int GOING_THROUGH_FORCE_HIT = 2

struct
{
	#if CLIENT
		float debounceMainMsg
		float debounceInstructionMsg
		float debounceDashMsg = -1
		var   fuelRui
	#endif

	#if DEVELOPER && SERVER
		bool infiniteFuel = false
	#endif
}file

bool function TestNitro()
{
	return GetCurrentPlaylistVarBool( PVAR_TITAN_SWORD_NITRO_TEST, false )
}

bool function TitanSword_PostCopySanityCheck( string id )
{
	return GetCurrentPlaylistVarBool( "titan_sword_post_copy_" + id, true )
}

#if SERVER
void function TitanSword_GameStateEnterPlaying()
{
	thread TitanSword_SpawnNitroSwords_Thread()
}

void function TitanSword_SpawnNitroSwords_Thread()
{
	wait 5
	foreach ( team in GetAllTeams() )
	{
		array< entity > players = GetPlayerArrayOfTeam( team )
		if ( players.len() == 0 )
			continue

		entity target = players[0]

		SpawnGenericLoot( TITAN_SWORD_WEAPON_REF, target.GetOrigin(), target.GetAngles() )
	}
}
#endif

#if SERVER
void function TitanSword_RemoveModOnDrop( entity weapon, string mod )
{
	if ( !weapon.w.modsToRemoveOnDrop.contains( mod ) )
		weapon.w.modsToRemoveOnDrop.append( mod )
}
#endif

void function MpWeaponTitanSword_Init()
{
	PrecacheWeapon( TITAN_SWORD_WEAPON_REF )

	PrecacheImpactEffectTable( VFX_TITAN_SWORD_IMPACT )

	PrecacheParticleSystem( VFX_TITAN_SWORD_SPEED_TRAIL_BODY )

	PrecacheParticleSystem( FX_TITAN_SWORD_LIGHT_SWIPE_FP )
	PrecacheParticleSystem( FX_TITAN_SWORD_LIGHT_SWIPE_3P )

	RegisterSignal( SIG_TITAN_SWORD_DEACTIVATE )

	//Inits all the attacks - titan sword is modular so we can swap in and out what we want it to do
	MpWeaponTitanSword_Block_Init()
	MpWeaponTitanSword_Dash_Init()
	MpWeaponTitanSword_Heavy_Init()
	MpWeaponTitanSword_Launcher_Init()
	MpWeaponTitanSword_Slam_Init()
	MpWeaponTitanSword_Super_Init()
	MpWeaponTitanSword_Light_Init()

	#if CLIENT
		StatusEffect_RegisterDisabledCallback( eStatusEffect.titan_sword_fuel, TitanSword_OnFuelFull )
		AddCallback_OnPrimaryWeaponStatusUpdate( OnPrimaryWeaponStatusUpdate_TitanSword )
	#endif

	#if SERVER
		RegisterSignal( SIG_TITAN_SWORD_STOP_LOOT_ANIM )

		Loot_AddCallback_OnLootSpawn( TitanSword_OnLootSpawned )
		AddCallback_OnPlayerKilled( TitanSword_OnPlayerKilled )

		if ( TestNitro() )
			AddCallback_GameStateEnter( eGameState.Playing, TitanSword_GameStateEnterPlaying )
	#endif

	RegisterSignal( SIG_TITAN_SWORD_DESTROY_FUEL_RUI )
}

void function MpWeaponTitanSword_Light_Init( )
{
	//Init any light attack FX here
}

void function TitanSword_Light_StartVFX( entity weapon )
{
	//FX that need to play for light attacks only start here

	entity player = weapon.GetWeaponOwner()
	{
	weapon.PlayWeaponEffect( FX_TITAN_SWORD_LIGHT_SWIPE_FP, FX_TITAN_SWORD_LIGHT_SWIPE_3P, "blade_tip" )
	}
}

void function TitanSword_Light_StopVFX( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	//Stop light attack specific FX here
	{
	weapon.StopWeaponEffect( FX_TITAN_SWORD_LIGHT_SWIPE_FP, FX_TITAN_SWORD_LIGHT_SWIPE_3P )
	}
}

void function OnWeaponActivate_weapon_titan_sword( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return

	TitanSword_Block_OnWeaponActivate( player, weapon )
	TitanSword_Dash_OnWeaponActivate ( player, weapon )
	TitanSword_Heavy_OnWeaponActivate ( player, weapon )
	TitanSword_Launcher_OnWeaponActivate ( player, weapon )
	TitanSword_Slam_OnWeaponActivate( player, weapon )
	TitanSword_Super_OnWeaponActivate( player, weapon )

	TitanSword_UpdateFuelCrosshair( player, weapon )

	#if SERVER
		TitanSword_RemoveModOnDrop( weapon, TITAN_SWORD_LIGHT_SUPER_MOD )
	#endif

	#if CLIENT
		TitanSword_DisplayHint( player, "#WPN_TITAN_SWORD_HINT", 5.0, TITAN_SWORD_MAIN_INSTRUCTIONS_DEBOUNCE_TIME )
		thread TitanSword_FuelMeterRui_Thread( weapon, player )
	#endif
}

void function OnWeaponDeactivate_weapon_titan_sword( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return

	TitanSword_Dash_OnWeaponDeactivate( player, weapon )
	TitanSword_Slam_OnWeaponDectivate( player, weapon )
	TitanSword_Super_OnWeaponDeactivate( player, weapon )
	TitanSword_ClearMods( weapon )
	weapon.Signal( SIG_TITAN_SWORD_DEACTIVATE )
}

int function OnMeleeWeaponPrimaryAttack_weapon_titan_sword( entity weapon, entity player )
{
	// --  TODO TRY HIGHLIGHT ON PLAYER WHILE THEY HAVE SUPER

	//Try to dash first
	if ( TitanSword_Dash_TryDash( player, weapon ) )
		return PLAYER_MELEE_STATE_NONE

	//Check for slam next
	if ( TitanSword_Slam_TrySlam( player, weapon ) )
		return PLAYER_MELEE_STATE_SLAM_ATTACK

	//We always heavy attack if we have nothing else to fall back on
	TitanSword_Heavy_TryHeavyAttack( player, weapon )
	return PLAYER_MELEE_STATE_KICK_ATTACK
}

int function OnMeleeWeaponSecondaryAttack_weapon_titan_sword( entity weapon, entity player )
{
	if ( !weapon.IsReadyToFire() )
		return PLAYER_MELEE_STATE_NONE

	//Try to launch the player
	if ( TitanSword_Launcher_TryLauncher( player, weapon ) )
		return PLAYER_MELEE_STATE_KICK_ATTACK

	//Do a super light if we have super activated
	if ( TitanSword_Super_IsActive( player ) )
		weapon.AddMod( TITAN_SWORD_LIGHT_SUPER_MOD )

	//Always light attack if we can't do this otherwise
	TitanSword_Light_StartVFX ( weapon )
	return PLAYER_MELEE_STATE_KICK_ATTACK
}

void function OnWeaponCustomActivityEnd_weapon_titan_sword( entity weapon, int activity )
{
	//FIXME: activity is sometimes ending early on special for some reason
	switch( activity )
	{
		case ACT_VM_MELEE_ATTACK1:
		case ACT_VM_MELEE_ATTACK2:
		case ACT_VM_MELEE_ATTACK3:
		//case ACT_VM_MELEE_LIGHT:
		//case ACT_VM_MELEE_HEAVY:
		//case ACT_VM_MELEE_SPECIAL:
		//case ACT_VM_MELEE_SLAM:
			TitanSword_ClearMods( weapon )
			break
	}

	//if ( activity == ACT_VM_MELEE_SLAM )
	//{

	//	float velZ = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "slam_vel_z" )
	//	weapon.GetWeaponOwner().PlayerLaunch( <0, 0, velZ>, false )
	//}
}

var function OnWeaponPrimaryAttackAnimEvent_weapon_titan_sword( entity weapon, WeaponPrimaryAttackParams params )
{
	TitanSword_Launcher_TryLauncherAnimEvent(weapon)
	TitanSword_Slam_TrySlamAnimEvent(weapon)

	return 0
}

void function TitanSword_SafelyAddAttackMod( entity weapon, string mod )
{
	#if CLIENT
		if ( !InPrediction() )
			return
	#endif

	//Clear all the mods
	TitanSword_ClearMods(weapon)

	//Add the new one
	weapon.AddMod( mod )
}

void function TitanSword_ClearMods( entity weapon )
{
	#if CLIENT
		if ( !InPrediction() )
			return
	#endif
	TitanSword_Block_ClearMods( weapon )
	TitanSword_Dash_ClearMods( weapon )
	TitanSword_Slam_ClearMods( weapon )
	TitanSword_Heavy_ClearMods( weapon )
	TitanSword_Launcher_ClearMods( weapon )
	TitanSword_Super_ClearMods( weapon )

	TitanSword_Light_StopVFX( weapon )
	weapon.RemoveMod( TITAN_SWORD_LIGHT_SUPER_MOD )
}

entity function TitanSword_GetMainWeapon( entity player )
{
	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( !IsValid( weapon ) )
		return null

	if ( !TitanSword_WeaponIsTitanSword( weapon ) )
		return null

	return weapon
}

bool function TitanSword_ActiveWeaponIsTitanSword( entity player )
{
	entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( !IsValid( weapon ) )
		return false

	return TitanSword_WeaponIsTitanSword( weapon )
}

bool function TitanSword_WeaponIsTitanSword( entity weapon )
{
	return TitanSword_WeaponRefIsTitanSword( weapon.GetWeaponClassName() )
}

bool function TitanSword_WeaponRefIsTitanSword( string ref )
{
	return ref == TITAN_SWORD_WEAPON_REF
}

bool function TitanSword_DamageSourceIsTitanSword( int damageSourceId )
{
	return damageSourceId == eDamageSourceId.mp_weapon_titan_sword || damageSourceId == eDamageSourceId.melee_titan_sword || damageSourceId == eDamageSourceId.mp_weapon_titan_sword_slam
}

#if CLIENT
bool function TitanSword_ClientPredictCheck( string power )
{
	//If we dont want to do this check, return true
	if ( !GetCurrentPlaylistVarBool( "titan_sword_predict_" + power, true ) )
		return true

	//check if first time predicted
	if ( !InPrediction() || (InPrediction() && IsFirstTimePredicted()) )
		return true

	return false
}
#endif

#if SERVER
void function TitanSword_OnLootSpawned( entity ent, LootData data, int count )
{
	if ( !TitanSword_WeaponRefIsTitanSword( data.ref ) )
		return

	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		return

	thread LootSpin_Thread( ent )
}

void function LootSpin_Thread( entity ent )
{
	if ( !IsValid( ent ) )
		return

	ent.EndSignal( "OnDestroy" )
	ent.EndSignal( SIG_TITAN_SWORD_STOP_LOOT_ANIM )

	wait 0.1 //wait a frame for spawning and whatnot to happen

	if ( ent.e.spawnSource == eSpawnSource.DROPPOD )
		return

	//Angle check
	vector angles = ent.GetAngles()
	angles = <0, angles.y, 0>
	ent.SetAngles( angles )

	entity mover = CreateScriptMover( TITAN_SWORD_LOOT_MOVER_SCRIPTNAME, ent.GetOrigin() + <0, 0, 26>, ent.GetAngles() )
	mover.EndSignal( "OnDestroy" )

	ent.SetVelocity( <0, 0, 0> )
	ent.StopPhysics()
	ent.ClearParent()
	ent.SetParent( mover )

	const float UP = 400

	vector start = ent.GetOrigin()
	vector endUp = start + <0, 0, UP>

	vector finalPosition = start + <0, 0, 20>

	//Check Up to make sure we dont bust through the ceiling
	float upOffset = GetCurrentPlaylistVarFloat( "titan_sword_spin_up_offset", 3.0 )
	TraceResults upTrace = TraceLine( start + <0, 0, upOffset>, start + <0, 0, 400>, [], TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_DEBRIS )

	EmitSoundOnEntity( mover, SFX_TITAN_SWORD_LOOT_AIR_LOOP )

	if ( IsValid( upTrace.hitEnt ) )
	{
		endUp = upTrace.endPos
	}

	mover.NonPhysicsMoveTo( endUp, 0.5, 0.0, 0.1 )
	mover.NonPhysicsRotate( ent.GetRightVector() * -1, 1630 )

	//Check down
	TraceResults groundTrace = TraceLine( start + <0, 0, 5>, start + <0, 0, -20000>, [], TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_DEBRIS  )

	if ( groundTrace.fraction < 1.0 )
		finalPosition = groundTrace.endPos + <0, 0, 20>

	OnThreadEnd(
		function() : ( ent, mover, angles, finalPosition )
		{
			if ( IsValid( ent ) )
			{
				if ( ent.GetParent() == mover )
					ent.ClearParent()
			}

			if ( IsValid( mover ) )
			{
				StopSoundOnEntity( mover, SFX_TITAN_SWORD_LOOT_AIR_LOOP )
				mover.NonPhysicsStop()
				mover.Destroy()
			}
		}
	)

	wait 0.67

	float distTimer = mover.GetOrigin().z - finalPosition.z
	distTimer = distTimer / 700 //1 second for every 700 units

	if ( distTimer > 1.2 )
		distTimer = 1.2

	if ( distTimer < 0.3 )
		distTimer = 0.3

	mover.NonPhysicsMoveTo( finalPosition + <0, 0, 20>, distTimer, 0.2, 0.0 )

	/*float endTime = Time() + distTimer

	vector prevPosition = finalPosition
	while( Time() < endTime )
	{
		groundTrace = TraceLine( start + <0, 0, 5>, start + <0, 0, -10000>, [], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

		if ( groundTrace.fraction < 1.0 )
			finalPosition = groundTrace.endPos + <0, 0, 20>

		if ( prevPosition != finalPosition )
		{
			printt( "NEW POSITION CALCULATED!" )
			float timeRemaining = endTime - Time()
			if ( timeRemaining > 0.0 )
				mover.NonPhysicsMoveTo( finalPosition, timeRemaining, 0.0, 0.0 )
		}
		WaitFrame()
	}*/

	wait distTimer

	groundTrace = TraceLine( finalPosition + <0, 0, 32>, finalPosition + <0, 0, -20000>, [], TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_DEBRIS  )


	//Change the final position, move the ent to the final pose, parent to hit ent

	bool validHitEnt = IsValid( groundTrace.hitEnt )
	if ( validHitEnt )
	{
		finalPosition = groundTrace.endPos
	}
	ent.ClearParent()
	ent.SetOrigin( finalPosition + <0, 0, 40> )
	ent.SetAngles( AnglesCompose( angles, <158, 0, 0> ) )
	if ( validHitEnt && !groundTrace.hitEnt.IsWorld() )
	{
		ent.SetParent( groundTrace.hitEnt )
	}

	vector effectsOrigin = finalPosition + VectorRotate( <14, 0, 0>, angles )
	vector beamOrigin = finalPosition + VectorRotate( <8, 0, 0>, angles )

	PlayImpactFXTable( effectsOrigin, ent, VFX_TITAN_SWORD_IMPACT )
	entity shake         = CreateAirShake( effectsOrigin, 8, 50, 0.5, 500 )
	CopyRealmsFromTo( ent, shake )

	thread CreateLootBeam( ent, beamOrigin, COLORID_HUD_LOOT_TIER5 )
}

//Make a global func for this - it's becoming a common thing
void function CreateLootBeam( entity ent, vector origin, int color )
{
	ent.EndSignal( "OnDeath" )
	ent.EndSignal( "OnDestroy" )

	int beamIndex = GetParticleSystemIndex( FX_AIRDROP_BEAM_CP )
	entity beamFx = StartParticleEffectInWorld_ReturnEntity( beamIndex, origin, <0, 180, 0> )
	EffectSetControlPointColorById( beamFx, 1, color )

	//Set the beam parent to the ent parent
	if ( IsValid( ent.GetParent() ) )
		beamFx.SetParent( ent.GetParent() )

	OnThreadEnd(
		function() : ( beamFx )
		{
			if ( IsValid( beamFx ) )
				EffectStop( beamFx )
		}
	)

	WaitForever()
}

void function TitanSword_ForceStopLootAnim( entity ent )
{
	ent.Signal( SIG_TITAN_SWORD_STOP_LOOT_ANIM )
}

//Do it before it shows up in a death box
void function TitanSword_OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	//Don't do this if in the firing range
	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		return

	array<int> primarySlots = [WEAPON_INVENTORY_SLOT_PRIMARY_0, WEAPON_INVENTORY_SLOT_PRIMARY_1]

	foreach ( int slot in primarySlots )
	{
		entity meleeWeapon = victim.GetNormalWeapon( slot )

		if ( (meleeWeapon!= null && TitanSword_WeaponIsTitanSword( meleeWeapon )) )
		{
			victim.TakeWeaponNow( meleeWeapon.GetWeaponClassName() )
			entity sword = SpawnGenericLoot( TITAN_SWORD_WEAPON_REF, victim.GetOrigin(), victim.GetAngles() )

			PutEntityInSafeSpot( sword, null, null, victim.GetOrigin(), victim.GetOrigin() )
		}
	}
}

#endif

#if SERVER
void function TitanSword_CreateMovementEffects( entity player, array<entity> movementEffects )
{
	entity trailFxBody = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( VFX_TITAN_SWORD_SPEED_TRAIL_BODY ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "ORIGIN" ) )
	trailFxBody.SetOwner( player )
	trailFxBody.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY) // not owner only
	movementEffects.append( trailFxBody )
}

//TODO: We keep copying and pasting this around - maybe just make a global func
void function TitanSword_CreateJetDriveJetEffects( entity player, asset jetFXAsset, array<entity> jumpJetFXs )
{
	array<string> attachments = [ "vent_left", "vent_right" ]
	foreach ( attachment in attachments )
	{
		int friendlyID = GetParticleSystemIndex( jetFXAsset )
		entity jetFX   = StartParticleEffectOnEntity_ReturnEntity( player, friendlyID, FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( attachment ) )
		jetFX.SetOwner( player )
		SetTeam( jetFX, player.GetTeam() )
		jetFX.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY) // not owner only
		jumpJetFXs.append( jetFX )
	}
}
#endif


#if CLIENT
void function TitanSword_ClearHints()
{
	HidePlayerHint( "#WPN_TITAN_SWORD_SUPER_READY_HINT" )
	HidePlayerHint( "#WPN_TITAN_SWORD_HINT" )
	HidePlayerHint( "#WPN_TITAN_SWORD_DASH_HINT" )
	HidePlayerHint( "#WPN_TITAN_SWORD_SLAM_HINT" )
	HidePlayerHint( "#WPN_TITAN_SWORD_DASH_NOT_READY" )
}

void function TitanSword_DisplayHint( entity player, string message, float time = 6.0, float debounce = 0.0 )
{
	if ( !IsLocalViewPlayer( player ) )
		return

	switch( message )
	{
		case "#WPN_TITAN_SWORD_SLAM_HINT":
		case "#WPN_TITAN_SWORD_DASH_HINT":
			if ( Time() < file.debounceInstructionMsg )
				return
			file.debounceInstructionMsg = Time() + debounce
			break

		case "#WPN_TITAN_SWORD_HINT":
			if ( Time() < file.debounceMainMsg )
				return
			file.debounceMainMsg = Time() + debounce
			break

		default:
			break
	}

	TitanSword_ClearHints()
	AddPlayerHint( time, 0.5, $"", message )
}

#endif

#if CLIENT
void function OnPrimaryWeaponStatusUpdate_TitanSword( entity selectedWeapon, var weaponRui )
{
	if ( !IsValid( selectedWeapon ) )
		return

	// send signal here to make sure it happens right after we switch to another weapon
	entity activeWeapon = GetLocalViewPlayer().GetActiveWeapon( eActiveInventorySlot.mainHand  )
	bool switchToMeleeOrGrenade = IsBitFlagSet( selectedWeapon.GetWeaponTypeFlags(), ( WPT_VIEWHANDS | WPT_GRENADE ) )
	if ( IsValid( activeWeapon ) && activeWeapon != selectedWeapon )
	{
		if ( !( TitanSword_WeaponIsTitanSword( activeWeapon ) && switchToMeleeOrGrenade ) )
			activeWeapon.Signal( SIG_TITAN_SWORD_DESTROY_FUEL_RUI )
	}

	if ( TitanSword_WeaponIsTitanSword( selectedWeapon ) )
	{
		entity player = selectedWeapon.GetWeaponOwner()
		thread TitanSword_FuelMeterRui_Thread( selectedWeapon, player )
	}
}
#endif

void function TitanSword_UpdateFuelCrosshair( entity player, entity weapon )
{
	#if CLIENT
		if ( !InPrediction() || !IsFirstTimePredicted() )
			return
	#endif
	float scale = TitanSword_GetFuelScale( player )
	weapon.SetWeaponPrimaryClipCountNoRegenReset( weapon.GetWeaponSettingInt( eWeaponVar.ammo_clip_size ) * scale )
	//weapon.SetScriptTime0( Time() )
	//weapon.SetScriptTime1( Time() + duration )
}

bool function TitanSword_TryUseFuel( entity player, bool playMessage = false )
{
	if ( !TitanSword_HasFuel( player ) )
	{
		#if CLIENT
			if ( Time() > file.debounceDashMsg )
			{
				//Play message and sound
				if ( playMessage )
				{
					EmitSoundOnEntity( player, SFX_TITAN_SWORD_FUEL_NOT_READY )
					TitanSword_DisplayHint( player, "#WPN_TITAN_SWORD_DASH_NOT_READY", TITAN_SWORD_DASH_NOT_READY_DEBOUNCE_TIME_SEC + 0.5 )
				}
				file.debounceDashMsg = Time() + TITAN_SWORD_DASH_NOT_READY_DEBOUNCE_TIME_SEC
			}
		#endif
		return false
	}
	if ( !TitanSword_Super_IsActive( player ) )
	{
		#if CLIENT
			file.debounceDashMsg = Time() + TITAN_SWORD_DASH_NOT_READY_DEBOUNCE_TIME_SEC
		#endif

		float fuelCooldown = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "fuel_cooldown_sec" )
		StatusEffect_AddTimed( player, eStatusEffect.titan_sword_fuel, 1.0, fuelCooldown, 0.0 )

		entity weapon = TitanSword_GetMainWeapon( player )
		if ( IsValid( weapon ) )
			TitanSword_UpdateFuelCrosshair( player, weapon )

		#if DEVELOPER && SERVER
			if ( file.infiniteFuel )
			{
				TitanSword_FillFuel( player )
			}
		#endif
	}
	return true
}

bool function TitanSword_HasFuel( entity player )
{
	return !StatusEffect_HasSeverity( player, eStatusEffect.titan_sword_fuel ) || TitanSword_Super_IsActive( player )
}

void function TitanSword_FillFuel( entity player )
{
	StatusEffect_StopAllOfType( player, eStatusEffect.titan_sword_fuel )
	entity weapon = TitanSword_GetMainWeapon( player )
	if ( IsValid( weapon ) )
		TitanSword_UpdateFuelCrosshair( player, weapon )
}

float function TitanSword_GetFuelScale( entity player )
{
	if ( TitanSword_HasFuel( player ) )
		return 1.0

	float fuel = StatusEffect_GetTimeRemaining( player, eStatusEffect.titan_sword_fuel )
	float diff = fuel / GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "fuel_cooldown_sec" )
	return 1.0 - diff
}


#if CLIENT
void function TitanSword_OnFuelFull( entity player, int statusEffect, bool actuallyChanged )
{
	if ( !actuallyChanged )
		return

	if ( !IsLocalViewPlayer( player ) )
		return

	EmitSoundOnEntity( player, SFX_TITAN_SWORD_FUEL_READY )
}
#endif

#if CLIENT
var function TitanSword_GetFuelRui()
{
	return file.fuelRui
}

void function TitanSword_FuelMeterRui_Thread( entity weapon, entity player )
{
	if ( !IsValid( weapon ) )
		return

	if ( weapon != player.GetActiveWeapon( eActiveInventorySlot.mainHand ) )
		return

	if ( !IsValid( player ) || !IsLocalViewPlayer( player ) )
		return

	if ( file.fuelRui != null )
		return

	weapon.Signal( SIG_TITAN_SWORD_DESTROY_FUEL_RUI )
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( SIG_TITAN_SWORD_DESTROY_FUEL_RUI )
	weapon.EndSignal ( SIG_TITAN_SWORD_DEACTIVATE )

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )


	file.fuelRui = CreateCockpitRui( RUI_TITAN_SWORD_FUEL_HUD )
	OnThreadEnd(
		function() : ()
		{
			if ( file.fuelRui != null )
			{
				RuiDestroyIfAlive( file.fuelRui )
				file.fuelRui = null
			}
		}
	)

	while( IsValid( player ) && IsValid( weapon ) )
	{
		if ( file.fuelRui == null )
			return

		float dashFrac = TitanSword_GetFuelScale( player )
		bool fuelFull = dashFrac >= 1.0
		bool hasUnlimitedDash = TitanSword_Super_IsActive( player )
		bool isBlocking = TitanSword_Block_IsBlocking( weapon )
		bool canLaunch = fuelFull && player.IsOnGround()
		string hintText = ""

		if ( isBlocking )
		{
			if ( fuelFull || hasUnlimitedDash )
			{
				hintText = "#WPN_TITAN_SWORD_PROMPT_DASH"
			}
			else
			{
				hintText = "#WPN_TITAN_SWORD_DASH_NOT_READY"
			}
		}
		else
		{
			if ( canLaunch )
			{
				hintText = "#WPN_TITAN_SWORD_PROMPT_LAUNCH"
			}
			else
			{
				hintText = "#WPN_TITAN_SWORD_PROMPT_LIGHT"
			}
		}

		RuiSetFloat( file.fuelRui, "dashFrac", dashFrac )
		RuiSetBool( file.fuelRui, "hasUnlimitedDash", hasUnlimitedDash )
		RuiSetString( file.fuelRui, "hintText", hintText )

		WaitFrame()
	}
}
#endif


bool function TitanSword_VictimHitOverride( entity weapon, entity attacker, entity victim, vector velocity )
{
	if ( !TitanSword_WeaponIsTitanSword( weapon ) )
		return false

	if ( TitanSword_Launcher_VictimHitOverride( weapon, attacker, victim, velocity ) )
		return true

	if ( TitanSword_Slam_VictimHitOverride( weapon, attacker, victim, velocity ) )
		return true

	if ( TitanSword_Light_VictimHitOverride( weapon, attacker, victim, velocity ) )
		return true

	return false
}

bool function TitanSword_Light_VictimHitOverride( entity weapon, entity attacker, entity victim, vector velocity )
{
	//Wtf why doesn't this work
	//Heavy attacks shouldnt bounce you
	//Neither should slam
	
	if ( !IsFriendlyTeam( attacker.GetTeam(), victim.GetTeam() ) )
	{
		if ( !victim.IsOnGround() && !attacker.IsOnGround() )
		{
			TitanSword_LaunchEntity( attacker, <0, 0, 150> )
			TitanSword_LaunchEntity( victim, <0, 0, 250> )
			return true
		}
	}
	return false
}

void function TitanSword_AirCombo_Thread( entity ent )
{
	printt( "AIR COMBO THREAD: " + ent )

	#if SERVER
		ent.EndSignal( "OnDeath" )
		ent.EndSignal( "OnDestroy" )

		float time = Time() + 3
		while( Time() < time )
		{
			printt("SET PLAYER VEL AIR COMBO")
			ent.SetVelocity( <0, 0, 0> )
			WaitFrame()
		}
	#endif
}

void function TitanSword_LaunchEntity( entity victim, vector velocity )
{
	if ( victim.IsPlayer() )
	{
		//victim.PlayerLaunch( velocity, false )
	}
#if SERVER
	else
	{
		PushEnt( victim, velocity )
	}
#endif
}

#if DEVELOPER
#if SERVER
void function DEV_TitanSword_GiveFuel( entity player )
{
	TitanSword_FillFuel( player )
}

void function DEV_TitanSword_InfiniteFuel( entity player, bool fuel )
{
	TitanSword_FillFuel( player )
	file.infiniteFuel = fuel
}

void function Dev_TitanSword_ToggleFuel( entity player, bool fuel )
{
	if ( fuel )
	{
		TitanSword_FillFuel( player )
	}
	else
	{
		StatusEffect_AddEndless( player, eStatusEffect.titan_sword_fuel, 1.0 )
		entity weapon = TitanSword_GetMainWeapon( player )
		if ( IsValid( weapon ) )
			TitanSword_UpdateFuelCrosshair( player, weapon )
	}
}
#endif
#endif

#if SERVER || CLIENT
int function TitanSword_CanGoThroughBlockingEntity( entity blockingEntity )
{
	if ( !IsValid( blockingEntity ) )
		return GOING_THROUGH_TRUE

	//printt( "BLOCKING ENTITY: " + blockingEntity.GetScriptName() + " :: " + blockingEntity.GetModelName() )

	// Gibraltar dome
	if ( blockingEntity.GetScriptName() == BUBBLE_SHIELD_SCRIPTNAME )
	{
		return GOING_THROUGH_TRUE
	}

	// Newcastle tactical
	if ( blockingEntity.GetScriptName() == MOBILE_SHIELD_SCRIPTNAME )
	{
		return GOING_THROUGH_TRUE
	}

	// Rampart tactical upper part
	if ( blockingEntity.GetScriptName() == AMPED_WALL_SCRIPT_NAME )
	{
		return GOING_THROUGH_TRUE
	}

	// Rampart tactical lower part - needed for friendly fire
	if ( blockingEntity.GetScriptName() == BASE_WALL_SCRIPT_NAME )
	{
		return GOING_THROUGH_FORCE_HIT
	}

	//Wattson Ult - needed for friendly fire
	if ( blockingEntity.GetScriptName() == TROPHY_SYSTEM_NAME )
	{
		return GOING_THROUGH_FORCE_HIT
	}

	//Newt - needed for friendly fire
	if ( blockingEntity.GetScriptName() == BLACKHOLE_PROP_SCRIPTNAME )
	{
		return GOING_THROUGH_FORCE_HIT
	}

	//Care Package - needed for friendly fire
	if ( blockingEntity.GetScriptName() == CARE_PACKAGE_SCRIPTNAME )
	{
		return GOING_THROUGH_FORCE_HIT
	}

	//MRB - needed for friendly fire
	if ( blockingEntity.GetScriptName() == MOBILE_RESPAWN_BEACON_TARGETNAME )
	{
		return GOING_THROUGH_FORCE_HIT
	}

	// Rampart turret
	// Need to go through all parts and force the turret itself to be hit
	if ( blockingEntity.IsWeaponX() )
	{
		if ( blockingEntity.GetWeaponClassName() == MOUNTED_TURRET_WEAPON_NAME ||
				blockingEntity.GetWeaponClassName() == COVER_WALL_WEAPON_NAME )
		{
			return GOING_THROUGH_TRUE
		}
	}

	if ( blockingEntity.GetModelName() == COLLISION_CYLINDER_MODEL )
	{
		return GOING_THROUGH_TRUE
	}

	if ( blockingEntity.GetScriptName() == MOUNTED_TURRET_PLACEABLE_SCRIPT_NAME )
	{
		return GOING_THROUGH_FORCE_HIT
	}
	// End Rampart turret

	return GOING_THROUGH_FALSE
}
#endif
                               