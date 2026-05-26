global function MpWeaponCoverWall_Init

global function OnWeaponPrimaryAttack_weapon_cover_wall
global function OnWeaponActivate_weapon_cover_wall
global function OnWeaponDeactivate_weapon_cover_wall
global function OnWeaponAttemptOffhandSwitch_weapon_cover_wall

#if CLIENT
global function OnCreateClientOnlyModel_weapon_cover_wall
#endif

#if SERVER
global function DestroyWallFX
#endif

global function IsAmpedWallEnt

//$"mdl/barriers/sandbags_large_01.rmdl"
//$"mdl/barriers/sandbags_curved_01.rmdl"


#if CLIENT
global function ServerToClient_CoverWallUpgrade_StartFastReload
global function ServerToClient_CoverWallUpgrade_EndFastReload

int COCKPIT_FAST_RELOAD_SCREEN_FX
const asset FAST_RELOAD_UPGRADE_1P_SCREEN_FX = $"P_clbr_ulti_screen"
#endif

global const string COVER_WALL_WEAPON_NAME = "mp_weapon_cover_wall"
const asset COVER_WALL_MODEL = $"mdl/props/rampart_cover_wall/rampart_cover_wall.rmdl"

const int COVER_WALL_MAX_WALLS = 4

const float COVER_WALL_NO_SPAWN_RADIUS = 256.0
const float COVER_WALL_ICON_HEIGHT = 48.0
const float COVER_WALL_MAX_HEALTH = 400
const int COVER_WALL_STARTING_HEALTH = 45
global const string BASE_WALL_SCRIPT_NAME = "cover_wall"
const float AMPED_WALL_HEIGHT_OFFSET = 39.0
const float TIME_BEFORE_SWITCHING_FROM_MOBILE_HMG = 0.6

const float COVER_WALL_PLACEMENT_RANGE_MAX = 256.0
const float COVER_WALL_PLACEMENT_RANGE_MIN = 64.0
const vector COVER_WALL_PLACEMENT_TRACE_OFFSET = <0, 0, 128>
const float COVER_WALL_ANGLE_LIMIT = 0.7
const float COVER_WALL_PLACEMENT_MAX_HEIGHT_DELTA = 64.0
const vector COVER_WALL_BOUND_MINS = <-30, -30, 0>
const vector COVER_WALL_BOUND_MAXS = <30, 30, 80>

const float TIME_ELAPSED_BEFORE_ARM_EXTEND_BEGIN = 0.25
const float ARMOR_DEPLOY_DURATION = 0.5

const float COVER_WALL_PLACEMENT_DELAY = 0.5

const float TIME_ELAPSED_BEFORE_ARM_EXTEND_BEGIN_MODIFIED = 0.1
const float ARMOR_DEPLOY_DURATION_MODIFIED = 0.3
const float COVER_WALL_PLACEMENT_DELAY_MODIFIED = 0.3
const int COVER_WALL_HIGHER_HEALTH = 120

const float COVER_WALL_MAX_USE_DIST2_MOD = 64 * 64
const float COVER_WALL_PICKUP_TIME = 0.5
const bool COVER_WALL_USE_QUICK = true
const bool COVER_WALL_USE_ALT = true

const bool COVER_WALL_DEBUG_DRAW_PLACEMENT = false

global const string AMPED_WALL_SCRIPT_NAME = "amped_wall"
global const string AMPED_WALL_MOVER_SCRIPTNAME = "amped_wall_mover"
const string HEALTH_TICKS_SCRIPT_NAME = "health_ticks"

const float AMPED_WALL_BUILD_DELAY = 3.0

	const float AMPED_WALL_BUILD_DELAY_IMPROVED = 2.0

// animation was authored for 3 second deploy time, set FPS of prop_rampart_wall_extend_arms in bakery to ( 3 / rampart_wall_build_time ) * 30

// FX
// base wall
const BASE_WALL_DESTROYED_FX = $"P_rampart_wall_destroy"
const BASE_WALL_DAMAGE_STATE_TRANSITION_FX = $"P_rampart_wall_damaged"
const BASE_WALL_DAMAGE_STATE_PERSISTENT_FX = $"P_rampart_wall_damaged_idle"
const BASE_WALL_TAKE_DAMAGE_WHILE_HEALTH_LOW_FX = $"P_rampart_wall_damaged_hit"

//amped wall
const float FX_IMPACT_DURATION = 0.05
const DEPLOYABLE_SHIELD_FX_AMPED = $"P_rampart_shield_top"
const AMPED_WALL_DESTROYED_FX = $"P_rampart_amp_destroy"
const AMPED_WALL_PACKED_UP_FX = $"P_rampart_amp_end"

// AUDIO
const WALL_PLACED_SFX_1P = "Wall_Place_1p"
const WALL_PLACED_SFX_3P = "Wall_Place_3p"
const WALL_LANDS_ON_GROUND = "Wall_Land_Default"

const BASE_WALL_DAMAGE_STATE_TRANSITION_SFX = "Wall_Damage_ArmorBreak"
const BASE_WALL_DAMAGE_STATE_LOOP_SFX = "Wall_Rise_LowPulse_Damaged"
const BASE_WALL_DESTROYED_SFX = "Wall_Explode_Large"

const ARM_EXTEND_SERVO_SFX = "Wall_Rise_Start"
const AMPED_WALL_CHARGING_SEQUENCE_SFX = "Wall_Rise_LowPulse"
const AMPED_WALL_CHARGING_FINISHED_SFX = "Wall_ShieldAppear"
const AMPED_WALL_SHIELD_LOOP_SFX = "Wall_Shield_Sustain"
const AMPED_WALL_POWER_DOWN_SFX = "Wall_ShieldPowerDown"
const AMPED_WALL_BREAK_SFX_1P = "Wall_Shield_Break_1p"
const AMPED_WALL_BREAK_SFX_3P = "Wall_Shield_Break_3p"

// DIALOGUE
const float WALL_DESTROYED_CALLOUT_MIN_DIST = 1024.0

// ART
const asset DEPLOYABLE_SHIELD_MODEL = $"mdl/fx/rampart_shield_cell.rmdl"
const asset HEALTH_TICKS_MODEL = $"mdl/fx/rampart_health_ticks.rmdl"

struct CoverWallPlacementInfo
{
	bool   success = false
	vector origin
	vector angles
	entity parentEnt = null
}

struct
{
	#if SERVER
	table< entity, int > triggerStackCount
	table< entity, entity > baseWallToPersistentDamageFX
	#endif

	float ampedWallMaxHealth

	int shieldFxIndex
	int persistentDamageFxIndex

	table< entity, entity > ampedWallEntToShieldFX
} file

void function MpWeaponCoverWall_Init()
{
	Remote_RegisterServerFunction( "ClientCallback_TryPickupCoverWall", "typed_entity", "prop_script" )

	#if SERVER
		AddCallback_OnPassThrough( AmpedWallPassThroughFX )

		RegisterDynamicEntCleanupItem_Parented_Scriptname( BASE_WALL_SCRIPT_NAME )
		RegisterDynamicEntCleanupItem_Area_Scriptname( BASE_WALL_SCRIPT_NAME )
	#endif

	#if CLIENT
		RegisterConCommandTriggeredCallback( "+scriptCommand5", OnCharacterButtonPressed )

		AddCallback_UseEntGainFocus( CoverWall_OnGainFocus )
		AddCallback_UseEntLoseFocus( CoverWall_OnLoseFocus )


		RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.RAMPART_WALL, MINIMAP_OBJECT_RUI, MinimapPackage_RampartWall, FULLMAP_OBJECT_RUI, MinimapPackage_RampartWall )
	#endif

	                    
		#if SERVER || CLIENT
		RegisterSignal( "FastReloadsUpgradeEnd" )
		Remote_RegisterClientFunction( "ServerToClient_CoverWallUpgrade_StartFastReload" )
		Remote_RegisterClientFunction( "ServerToClient_CoverWallUpgrade_EndFastReload" )
		#endif

		#if SERVER
			AddCallback_OnPassiveChanged( ePassives.PAS_PAS_UPGRADE_TWO, CoverWallUpgrade_FastReloads_OnUpgradeChanged )
		#endif

		#if CLIENT
			COCKPIT_FAST_RELOAD_SCREEN_FX = PrecacheParticleSystem( FAST_RELOAD_UPGRADE_1P_SCREEN_FX )
		#endif

	file.ampedWallMaxHealth = GetRampartAmpedShieldHealth()

	CoverWall_Precache()
}

float function GetRampartAmpedShieldHealth()
{
	return GetCurrentPlaylistVarFloat( "rampart_amped_shield_health", 175.0 )
}

float function GetRampartUpgradedShieldHealth()
{
	return GetCurrentPlaylistVarFloat( "upgrade_core_shield_health_multiplier", 1.25 )
}

float function GetRampartUpgradedBaseHealth()
{
	return GetCurrentPlaylistVarFloat( "upgrade_core_shield_health_multiplier", 1.25 )
}

float function GetRampartUpgradedWallDamageResilienceMultiplier()
{
	return GetCurrentPlaylistVarFloat( "upgrade_core_explosive_damage_multiplier", .5 )
}

#if SERVER
void function CoverWallUpgrade_FastReloads_OnUpgradeChanged( entity player, int passive, bool didHave, bool nowHas )
{
	if( !PlayerHasPassive( player, ePassives.PAS_GUNNER ) || didHave )
	{
		player.Signal( "FastReloadsUpgradeEnd" )
		return
	}

	if ( nowHas )
	{
		thread CoverWallUpgrade_FastReloads_Thread( player )
	}
}

void function CoverWallUpgrade_FastReloads_Thread( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "FastReloadsUpgradeEnd" )

	float fastReloadProximitySqr = 100 * 100
	bool hasFastReload = false
	while( IsValid( player ) )
	{
		vector playerOrigin = player.GetOrigin()

		bool fastReloadActive = false
		foreach ( wall, fx in file.ampedWallEntToShieldFX )
		{
			if( !IsValid( wall ) )
				continue
			vector wallToPlayer = playerOrigin - wall.GetOrigin()
			if ( LengthSqr( wallToPlayer ) > fastReloadProximitySqr )
				continue
			vector wallForward = wall.GetForwardVector()
			float dot = DotProduct( wallForward, wallToPlayer )
			if( dot < 0 )
				continue
			fastReloadActive = true
			break
		}

		if( fastReloadActive )
		{
			entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
			if ( IsValid( weapon ) )
			{
				bool isMountedTurret = weapon.GetWeaponClassName() == "mp_weapon_mounted_turret"

				int weaponFlags = weapon.GetWeaponTypeFlags()
				if ( !weapon.IsWeaponOffhand() && weaponFlags == WPT_PRIMARY && !isMountedTurret )
				{
					if ( !weapon.HasMod( "auto_loader" ) )
						weapon.AddMod( "auto_loader" )

					if( !hasFastReload )
					{
						Remote_CallFunction_NonReplay( player, "ServerToClient_CoverWallUpgrade_StartFastReload" )
						hasFastReload = true
					}
				}
			}
		}

		WaitFrame()
	}
}
#endif

#if CLIENT
void function ServerToClient_CoverWallUpgrade_StartFastReload()
{
	entity viewPlayer = GetLocalViewPlayer()
	if( viewPlayer != GetLocalClientPlayer() )
		return

	thread FastReload_1PFX_Thread( viewPlayer )
}

void function ServerToClient_CoverWallUpgrade_EndFastReload()
{
	entity viewPlayer = GetLocalViewPlayer()
	if( viewPlayer != GetLocalClientPlayer() )
		return

	viewPlayer.Signal( "FastReloadsUpgradeEnd" )
}

void function FastReload_1PFX_Thread( entity player )
{
	player.EndSignal( "OnDeath", "OnDestroy", "BleedOut_OnStartDying", "FastReloadsUpgradeEnd" )

	int fxHandle
	fxHandle = StartParticleEffectOnEntityWithPos( player, COCKPIT_FAST_RELOAD_SCREEN_FX, FX_PATTACH_ABSORIGIN_FOLLOW, -1, player.EyePosition(), <0, 0, 0> )
	EffectSetIsWithCockpit( fxHandle, true )
	EffectSetControlPointVector( fxHandle, 1, <255, 255, 255> )
	EffectSetControlPointVector( fxHandle, 3, <0.8,0.8,0.8> )

	OnThreadEnd(
		function() : ( fxHandle )
		{
			if ( EffectDoesExist( fxHandle ) )
				EffectStop( fxHandle, false, true )
		}
	)

	for ( ;; )
	{
		if ( !EffectDoesExist( fxHandle ) )
			break

		EffectSetControlPointVector( fxHandle, 1, <1.0, 999, 0> )

		WaitFrame()
	}
}
#endif
void function CoverWall_Precache()
{
	RegisterSignal( "CoverWall_PickedUp" )
	RegisterSignal( "CoverWall_OnContinousUseStopped" )
	RegisterSignal( "CoverWall_ServerPickup" )

	PrecacheModel( COVER_WALL_MODEL )
	PrecacheModel( COLLISION_CYLINDER_MODEL )

	file.shieldFxIndex = PrecacheParticleSystem( DEPLOYABLE_SHIELD_FX_AMPED )
	PrecacheParticleSystem( AMPED_WALL_DESTROYED_FX )
	PrecacheParticleSystem( AMPED_WALL_PACKED_UP_FX )

	PrecacheParticleSystem( BASE_WALL_DESTROYED_FX )
	PrecacheParticleSystem( BASE_WALL_DAMAGE_STATE_TRANSITION_FX )
	file.persistentDamageFxIndex = PrecacheParticleSystem( BASE_WALL_DAMAGE_STATE_PERSISTENT_FX )
	PrecacheParticleSystem( BASE_WALL_TAKE_DAMAGE_WHILE_HEALTH_LOW_FX )

	PrecacheModel( DEPLOYABLE_SHIELD_MODEL )
	PrecacheModel( HEALTH_TICKS_MODEL )

	#if CLIENT
		RegisterSignal( "CoverWall_StopPlacementProxy" )
		StatusEffect_RegisterEnabledCallback( eStatusEffect.placing_cover_wall, CoverWall_OnBeginPlacement )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.placing_cover_wall, CoverWall_OnEndPlacement )

		AddCreateCallback( "prop_script", CoverWall_OnPropScriptCreated )
		AddDestroyCallback( "prop_script", CoverWall_OnPropScriptDestroyed )

		AddCallback_ModifyDamageFlyoutForScriptName( BASE_WALL_SCRIPT_NAME, CoverWall_OffsetDamageNumbersLower )
	#endif
}

bool function IsAmpedWallEnt( entity ent )
{
	return ent.GetScriptName() == AMPED_WALL_SCRIPT_NAME
}

entity function GetAmpedWallForBase( entity baseWall )
{
	foreach( entity ent in baseWall.GetLinkEntArray() )
	{
		if ( IsAmpedWallEnt( ent ) )
			return ent
	}

	return null
}

bool function CanReclaimWall( entity baseWall )
{
	entity ampedWall = GetAmpedWallForBase( baseWall )

	if ( !IsValid( baseWall ) )
		return false

	if ( IsValid( baseWall.GetOwner() ) )
		return true

	if ( !IsValid( ampedWall) )
	{
		if ( GetCurrentPlaylistVarBool( "rampart_higher_health", true ) )
			 {
				 if ( baseWall.GetMaxHealth() != COVER_WALL_HIGHER_HEALTH )
					 return false
			 }
		else
			 {
				 if ( baseWall.GetMaxHealth() != COVER_WALL_STARTING_HEALTH )
					 return false
			 }
	}

	if ( baseWall.GetHealth() <= 0 )
		return false

	if ( IsValid( ampedWall ) && ampedWall.GetHealth() <= 0 )
		return false

	if ( baseWall.GetHealth() < baseWall.GetMaxHealth() )
		return false

	if ( IsValid( ampedWall ) && ampedWall.GetHealth() < ampedWall.GetMaxHealth() )
		return false

	return true
}

void function OnWeaponActivate_weapon_cover_wall( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	weapon.w.startChargeTime = Time()

	Assert( ownerPlayer.IsPlayer() )
	#if CLIENT
		if ( !InPrediction() )
			return
	#endif

	int statusEffect = eStatusEffect.placing_cover_wall
	StatusEffect_AddEndless( ownerPlayer, statusEffect, 1.0 )

	#if SERVER
		AddButtonPressedPlayerInputCallback( ownerPlayer, IN_OFFHAND1, CoverWall_CancelPlacement )
	#endif
}


void function OnWeaponDeactivate_weapon_cover_wall( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )
	#if CLIENT
		if ( !InPrediction() )
			return
	#endif
	StatusEffect_StopAllOfType( ownerPlayer, eStatusEffect.placing_cover_wall )

	#if SERVER
		RemoveButtonPressedPlayerInputCallback( ownerPlayer, IN_OFFHAND1, CoverWall_CancelPlacement )
	#endif
}

bool function OnWeaponAttemptOffhandSwitch_weapon_cover_wall( entity weapon )
{
	entity player = weapon.GetWeaponOwner()

	entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	entity ultWeapon = player.GetOffhandWeapon( OFFHAND_ULTIMATE )
	entity placementWeapon = player.GetOffhandWeapon( OFFHAND_ORDNANCE )

	if( IsValid( ultWeapon ) && IsValid( placementWeapon ) && placementWeapon.GetWeaponClassName() == "mp_weapon_mounted_turret_placeable"
			&& ( activeWeapon == ultWeapon || activeWeapon == placementWeapon ) )
	{
		float timeSinceStart = Time() - ultWeapon.w.startChargeTime
		if( timeSinceStart < GetCurrentPlaylistVarFloat( "cover_wall_switch_from_ult_delay", TIME_BEFORE_SWITCHING_FROM_MOBILE_HMG ) )
			return false
	}

	return true
}

#if CLIENT
void function OnCreateClientOnlyModel_weapon_cover_wall( entity weapon, entity model, bool validHighlight )
{

}

vector function CoverWall_OffsetDamageNumbersLower( entity wall, vector damageFlyoutPosition )
{
	return ( damageFlyoutPosition - < 0, 0, wall.GetBoundingMaxs().z/2.0 > )
}
#endif

var function OnWeaponPrimaryAttack_weapon_cover_wall( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	entity proxy = CoverWall_CreateProxyModel( COVER_WALL_MODEL )
	CoverWallPlacementInfo placementInfo = CoverWall_GetPlacementInfo( ownerPlayer, proxy )
	proxy.Destroy()

	if ( !placementInfo.success )
	{
		#if CLIENT
		EmitSoundOnEntity( ownerPlayer, "Wpn_ArcTrap_Beep" )
		#endif
		return 0
	}

	#if SERVER
		thread CoverWall_Deploy( ownerPlayer, placementInfo )
	#endif

	PlayerUsedOffhand( ownerPlayer, weapon )
	return weapon.GetAmmoPerShot()
}

#if SERVER
void function CoverWall_CancelPlacement( entity player )
{
	if ( player.IsUsingOffhandWeapon( eActiveInventorySlot.mainHand ) )
	{
		entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

		if ( !IsValid( activeWeapon ) )
			return

		if ( activeWeapon.GetWeaponClassName() != COVER_WALL_WEAPON_NAME )
			return

		if ( activeWeapon.w.startChargeTime + 0.1 > Time() )
			return
	}
	else
	{
		return
	}

	SwapToLastEquippedPrimary( player )
}

void function CoverWall_DestoryMoverAfterProxy( entity mover, entity wallProxy )
{
	EndSignal( mover, "OnDestroy" )

	OnThreadEnd(
		function() : ( mover )
		{
			if( IsValid( mover ) )
				mover.Destroy()
		}
	)

	while( IsValid( wallProxy ) )
		WaitFrame()
}

void function CoverWall_Deploy( entity owner, CoverWallPlacementInfo placementInfo )
{
	if ( !IsValid( owner ) )
		return

	vector origin = placementInfo.origin
	vector angles = placementInfo.angles
	entity parentTo = placementInfo.parentEnt

	entity mover = CreateScriptMover_NEW( AMPED_WALL_MOVER_SCRIPTNAME, origin, angles )

	if ( IsValid( parentTo ) )
	{
		mover.SetParent( parentTo )
	}

	entity wallProxy = CreatePropScript( COVER_WALL_MODEL, origin, angles, SOLID_VPHYSICS )

	EndSignal( mover, "OnDestroy" )
	EndSignal( wallProxy, "OnDestroy" )
	EndSignal( wallProxy, "CoverWall_PickedUp" )

	wallProxy.SetParent( mover )
	thread CoverWall_DestoryMoverAfterProxy( mover, wallProxy )

	wallProxy.DisableHibernation()

	if ( GetCurrentPlaylistVarBool( "rampart_higher_health", true ) )
	{
		wallProxy.SetMaxHealth( COVER_WALL_HIGHER_HEALTH )
		wallProxy.SetHealth( COVER_WALL_HIGHER_HEALTH )
	}
	else
	{
		wallProxy.SetMaxHealth( COVER_WALL_STARTING_HEALTH )
		wallProxy.SetHealth( COVER_WALL_STARTING_HEALTH )
	}

	wallProxy.SetDamageNotifications( false )
	wallProxy.SetDeathNotifications( false )
	wallProxy.SetArmorType( ARMOR_TYPE_HEAVY )
	wallProxy.SetTakeDamageType( DAMAGE_YES )

	wallProxy.SetScriptName( BASE_WALL_SCRIPT_NAME )
	//wallProxy.SetTitle( "#WPN_COVER_WALL" )
	SetTargetName( wallProxy, BASE_WALL_SCRIPT_NAME )

	wallProxy.SetOwner( owner )
	SetTeam( wallProxy, owner.GetTeam() )
	wallProxy.e.noOwnerFriendlyFire = false
	wallProxy.e.canBeDamagedFromGas = false
	wallProxy.e.canBurn = true
	wallProxy.RemoveFromAllRealms()
	wallProxy.AddToOtherEntitysRealms( owner )

	wallProxy.SetScriptPropFlags( SPF_BLOCKS_AI_NAVIGATION )
	wallProxy.EnableAttackableByAI( 5, 0, AI_AP_FLAG_NONE )

	wallProxy.SetTouchTriggers( true ) //Make it destroyable by triggers e.g. Leviathan stomp, thermite

	int team = owner.GetTeam()
	wallProxy.Minimap_SetAlignUpright( true )
	wallProxy.Minimap_SetClampToEdge( false )
	wallProxy.Minimap_AlwaysShow( team, null )
	wallProxy.Minimap_SetZOrder( MINIMAP_Z_OBJECT-1 )

	wallProxy.Solid()
	wallProxy.AllowMantle()

	Highlight_SetOwnedHighlight( wallProxy, "sp_friendly_hero" )
	Highlight_SetFriendlyHighlight( wallProxy, "sp_friendly_hero" )

	string noSpawnIdx = CreateNoSpawnArea( TEAM_INVALID, team, origin, -1.0, COVER_WALL_NO_SPAWN_RADIUS )
	wallProxy.SetCanBeMeleed( true )
	SetVisibleEntitiesInConeQueriableEnabled( wallProxy, false )
	thread TrapDestroyOnRoundEnd( owner, wallProxy )

	AddEntityCallback_OnDamaged( wallProxy, CoverWall_OnDamaged )
	AddEntityCallback_OnPostDamaged( wallProxy, CoverWall_OnPostDamaged )

	wallProxy.SetUsable()
	wallProxy.SetUsablePriority( USABLE_PRIORITY_LOW )
	wallProxy.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER ) //Update hint text every server frame so that we can keep unique client texts up to date.
	SetCallback_CanUseEntityCallback( wallProxy, CoverWall_CanUse )

	entity cylinder = CreatePropScript( COLLISION_CYLINDER_MODEL, origin - ( wallProxy.GetRightVector() * 62 ) + ( wallProxy.GetUpVector() * 20 ), RotateAnglesAboutAxis( angles, wallProxy.GetForwardVector(), 90 ), SOLID_CAPSULE )
	InitCollisionCylinder( cylinder, owner, wallProxy )

	PIN_Interact( owner, "rampart_wall_deployed", origin )

	// Manage existing walls
	owner.e.coverWalls.insert( 0, wallProxy )
	while ( owner.e.coverWalls.len() > GetCurrentPlaylistVarInt( "rampart_max_walls_deployed", COVER_WALL_MAX_WALLS ) )
	{
		entity entToDelete = owner.e.coverWalls.pop()
		if ( IsValid( entToDelete ) )
		{
			Signal( entToDelete, "OnDestroy" )
		}
	}





	// Sounds
	EmitSoundOnEntityOnlyToPlayer( wallProxy, owner, WALL_PLACED_SFX_1P )
	EmitSoundOnEntityExceptToPlayer( wallProxy, owner, WALL_PLACED_SFX_3P )
	EmitSoundOnEntity( wallProxy, WALL_LANDS_ON_GROUND )

	// Animation
	wallProxy.SetBodygroupModelByIndex( wallProxy.FindBodygroup( "rampart_cover_wall_arms" ), 1 )
	thread PlayAnim( wallProxy, "prop_rampart_wall_folded_idle", mover )

	// FX
	file.baseWallToPersistentDamageFX[ wallProxy ] <- null

	OnThreadEnd(
	function() : ( owner, wallProxy, noSpawnIdx, cylinder )
		{
			DeleteNoSpawnArea( noSpawnIdx )

			if ( IsValid( cylinder ) )
				cylinder.Destroy()

			bool wasWallDestroyedDueToExceededLimit = true
			if ( IsValid( owner ) )
			{
				for ( int i=owner.e.coverWalls.len()-1; i>=0 ; i-- )
				{
					if ( owner.e.coverWalls[i] == wallProxy )
					{
						owner.e.coverWalls.remove( i )
						wasWallDestroyedDueToExceededLimit = false
					}
				}
			}

			if ( wallProxy in file.baseWallToPersistentDamageFX )
			{
				if ( IsValid( file.baseWallToPersistentDamageFX[ wallProxy ] ) )
					EffectStop( file.baseWallToPersistentDamageFX[ wallProxy ] )

				delete file.baseWallToPersistentDamageFX[ wallProxy ]
			}

			if ( wallProxy != null )
				StopSoundOnEntity( wallProxy, BASE_WALL_DAMAGE_STATE_LOOP_SFX )

			if ( IsValid( wallProxy ) )
			{
				if ( wallProxy.GetHealth() > 0 )
				{
					wallProxy.NotSolid()

					thread PlayPickupAnimAndDissolveAfter( wallProxy )

					PIN_Interact( owner, "rampart_wall_picked_up", wallProxy.GetOrigin() )

					if ( IsValid( owner ) && GetPlayerVoice( owner ) == "rampart" && !wasWallDestroyedDueToExceededLimit )
						PlayBattleChatterLineToSpeakerAndTeamWithDebounceTime( owner, "bc_rampart_coverPackedUp", 5.0, 5.0 )

					Signal( wallProxy, "OnDestroy" )
				}
				else
				{
					wallProxy.Destroy()
				}
			}
		}
	)

	int passThroughThickness = GetCurrentPlaylistVarInt( "rampart_wall_thickness", 1 )
	wallProxy.SetPassThroughThickness( passThroughThickness )
	wallProxy.SetPassThroughFlags( PTF_NO_DMG_ON_PASS_THROUGH )

	thread Wall_CheckForGeoIntersection( wallProxy )

	PlayBattleChatterLineToSpeakerAndTeamWithDebounceTime( owner, "bc_tactical", 10, 10 )

	if ( GetCurrentPlaylistVarBool( "rampart_improved_deployment", true ) )
	{
		wait COVER_WALL_PLACEMENT_DELAY
	}
	else
	{
		wait COVER_WALL_PLACEMENT_DELAY_MODIFIED
	}

	thread PlayAnim( wallProxy, "prop_rampart_wall_unfold", mover )

	thread DeployAmpedWallAfterDelay( wallProxy, mover )

	WaitForever()
}

void function CoverWall_WaitForPickup( entity wallProxy )
{
	Assert( IsNewThread(), "Must be threaded off." )
	wallProxy.EndSignal( "OnDestroy" )
	wallProxy.EndSignal( "CoverWall_PickedUp" )

	wallProxy.SetUsable()
	wallProxy.AddUsableValue( USABLE_BY_OWNER )
 	wallProxy.SetUsePrompts( "#WPN_COVER_WALL_DYNAMIC_RECLAIM", "#WPN_COVER_WALL_DYNAMIC_DESTROY" )
	SetCallback_CanUseEntityCallback( wallProxy, CoverWall_CanUse )

	OnThreadEnd(
	function() : ( wallProxy )
		{
			if ( IsValid( wallProxy ) )
			{
				wallProxy.UnsetUsable()
			}
		}
	)

 	while( true )
 	{
 		table signalData = wallProxy.WaitSignal( "OnPlayerUseLong", "CoverWall_ServerPickup" )
 		entity player = expect entity( signalData.player )

 		if ( player.IsTitan() )
 			continue

		entity owner = wallProxy.GetOwner()

 		if ( player == owner )
 		{
 			waitthread CoverWall_PlayerAttemptPickup( player, wallProxy )
 		}
 	}
}

void function CoverWall_PlayerAttemptPickup( entity player, entity wallProxy )
{
	player.EndSignal( "OnDeath" )
	wallProxy.EndSignal( "OnDestroy" )
	player.EndSignal( "CoverWall_OnContinousUseStopped" )
	player.EndSignal( "StartPhaseShift" )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{
				DeployAndEnableWeapons( player )
			}
		}
	)

	HolsterAndDisableWeapons( player )

	waitthread CoverWall_TrackContinuousUse( player, wallProxy, COVER_WALL_PICKUP_TIME, true )

	if ( CoverWall_PickUp( player, wallProxy ) )
	{
		wallProxy.Signal( "CoverWall_PickedUp" )
	}
}

void function Wall_CheckForGeoIntersection( entity wallProxy )
{
	Assert ( IsNewThread(), "Must be threaded off." )
	wallProxy.EndSignal( "OnDestroy" )

	float hullDepth = 5
	float hullWidth = hullDepth
	float wallFullWidth = 62
	float hullHeight = 10
	float heightOffGround = 10 // Matches object_placement_ground_penetration_max

	while ( true )
	{
		array<entity> ignoreEnts = GetPlayerArray_Alive()
		ignoreEnts.append( wallProxy )

		vector right = wallProxy.GetRightVector()
		vector up = wallProxy.GetUpVector()

		vector startPos = wallProxy.GetOrigin() + up * heightOffGround + right * -wallFullWidth * 0.8
		vector endPos   = wallProxy.GetOrigin() + up * heightOffGround + right * wallFullWidth * 0.8

		TraceResults results = TraceHull( startPos, endPos, <-hullWidth, -hullDepth, 0>, <hullWidth, hullDepth, hullHeight>, ignoreEnts, TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER )
		//DebugDrawBox( startPos, <-hullWidth,-hullDepth,0>, <hullWidth,hullDepth,hullHeight>, <0, 255, 0>, 1, 1.0 )
		//DebugDrawBox( endPos, <-hullWidth,-hullDepth,0>, <hullWidth,hullDepth,hullHeight>, <0, 128, 0>, 1, 1.0 )
		//PrintTraceResults( results )
		if ( results.startSolid || results.fraction != 1 )
		{
			entity hitEnt = results.hitEnt
			if ( IsValid( hitEnt ) )
			{
				string hitEntClassname = hitEnt.GetClassName()

				if ( hitEntClassname == "worldspawn" || hitEntClassname == "phys_bone_follower" || hitEntClassname == "func_brush" || hitEntClassname == "script_mover" || hitEntClassname == "func_brush_lightweight" || hitEntClassname == "prop_dynamic" )
				{
					DestroyWallFX( wallProxy, null )
					wallProxy.Destroy()
				}
			}
		}
		wait 0.2
	}
}

void function InitCollisionCylinder( entity cylinder, entity owner, entity wall )
{
	cylinder.kv.collisionGroup = TRACE_COLLISION_GROUP_PROJECTILE
	cylinder.DisableHibernation()
	cylinder.RemoveFromAllRealms()
	cylinder.AddToOtherEntitysRealms( owner )
	cylinder.SetTakeDamageType( DAMAGE_NO )
	cylinder.Solid()
	cylinder.SetParent( wall )
}

void function DeployAmpedWallAfterDelay( entity baseWall, entity animReference )
{
	EndSignal( baseWall, "OnDestroy" )
	EndSignal( baseWall, "CoverWall_PickedUp" )

	float delayTime = GetCurrentPlaylistVarFloat( "rampart_wall_build_time", AMPED_WALL_BUILD_DELAY )

	if ( GetCurrentPlaylistVarBool( "rampart_improved_deployment", true ) )
		delayTime = GetCurrentPlaylistVarFloat( "rampart_wall_build_time", AMPED_WALL_BUILD_DELAY_IMPROVED )

	OnThreadEnd(
		function() : ( baseWall )
		{
			if ( IsValid( baseWall ) )
			{
				StopSoundOnEntity( baseWall, ARM_EXTEND_SERVO_SFX )
			}

		}
	)

	if ( GetCurrentPlaylistVarBool( "rampart_higher_health", true ) )
	{
		wait TIME_ELAPSED_BEFORE_ARM_EXTEND_BEGIN_MODIFIED
	}
	else
	{
		wait TIME_ELAPSED_BEFORE_ARM_EXTEND_BEGIN
	}

	thread PlayAnim( baseWall, "prop_rampart_wall_charging_idle", animReference )
	thread PlayAnim( baseWall, "prop_rampart_wall_extend_arms", animReference )
	EmitSoundOnEntity( baseWall, ARM_EXTEND_SERVO_SFX )

	if ( GetCurrentPlaylistVarBool( "rampart_higher_health", true ) )
	{
		wait delayTime - TIME_ELAPSED_BEFORE_ARM_EXTEND_BEGIN_MODIFIED - ARMOR_DEPLOY_DURATION_MODIFIED
	}
	else
	{
		wait delayTime - TIME_ELAPSED_BEFORE_ARM_EXTEND_BEGIN - ARMOR_DEPLOY_DURATION
	}

	thread PlayAnim( baseWall, "prop_rampart_wall_extend_armor", animReference )

	if ( GetCurrentPlaylistVarBool( "rampart_higher_health", true ) )
	{
		wait ARMOR_DEPLOY_DURATION_MODIFIED
	}
	else
	{
		wait ARMOR_DEPLOY_DURATION
	}

	thread PlayAnim( baseWall, "ref", animReference )
	baseWall.SetPassThroughThickness( -1 )

	if ( baseWall.GetHealth() > 0 )
	{
		thread DeployAmpedWall( baseWall, animReference.GetOrigin(), animReference.GetAngles(), animReference )
	}
}

float function GetAmpedWallHealth( entity owner )
{
	float health = GetRampartAmpedShieldHealth()
	return health
}

float function GetBaseWallHealth( entity owner )
{
	float baseHealth = COVER_WALL_MAX_HEALTH
	return baseHealth
}

void function DeployAmpedWall( entity baseWall, vector origin, vector angles, entity mover )
{
	Assert( baseWall )
	EndSignal( baseWall, "OnDestroy" )

	EmitSoundOnEntity( baseWall, AMPED_WALL_CHARGING_FINISHED_SFX )

	vector up = AnglesToUp( angles )
	origin = origin + (up * AMPED_WALL_HEIGHT_OFFSET )

	entity ampedWall = CreatePropScript( DEPLOYABLE_SHIELD_MODEL, origin, RotateAnglesAboutAxis( angles, up, 180 ), SOLID_VPHYSICS )
	EmitSoundOnEntity( ampedWall, AMPED_WALL_SHIELD_LOOP_SFX )

	EndSignal( ampedWall, "OnDestroy" )

	ampedWall.kv.contents = (CONTENTS_WINDOW | CONTENTS_BLOCK_PING)
	ampedWall.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS_AND_PHYSICS
    //ampedWall.e.noFriendlyFireProtection = true
	ampedWall.e.canBeDamagedFromGas = false
	//ampedWall.e.preventStickyEnts = true
	//ampedWall.e.blocksThermite = true
	ampedWall.e.canBeDamagedFromGas = false
	ampedWall.SetPassThroughFlags( PTF_ADDS_MODS ) //PTF_NO_DMG_ON_PASS_THROUGH
	ampedWall.SetBlocksRadiusDamage( true )
	ampedWall.Hide()
	ampedWall.SetTakeDamageType( DAMAGE_YES )
	ampedWall.SetDamageNotifications( true )
	ampedWall.SetMaxHealth( GetAmpedWallHealth( baseWall.GetOwner() ) )
	ampedWall.SetHealth( GetAmpedWallHealth( baseWall.GetOwner() ) )
	ampedWall.SetOwner( baseWall.GetOwner() )

	ampedWall.RemoveFromAllRealms()
	ampedWall.AddToOtherEntitysRealms( baseWall )

	ampedWall.SetParent( baseWall ) //Make amped wall work with moving geo
	baseWall.LinkToEnt( ampedWall ) //Make amped wall easier to find later
	ampedWall.SetScriptName( AMPED_WALL_SCRIPT_NAME )

	SetTeam( ampedWall, baseWall.GetTeam() )

	AddEMPDamageDevice( ampedWall )
    //AddWreckingBallEMPDamageDevice( ampedWall )

	SetVisibleEntitiesInConeQueriableEnabled( ampedWall, true )

	AddEntityCallback_OnDamaged( ampedWall, AmpedWall_OnDamaged )
	AddEntityCallback_OnPostDamaged( ampedWall, AmpedWall_OnPostDamaged )

	ampedWall.SetPassThroughThickness( 0 )
	ampedWall.SetPassThroughDirection( -0.55 )
	StatusEffect_AddEndless( ampedWall, eStatusEffect.pass_through_amps_weapon, 1.0 )

	entity healthTicks = CreatePropDynamic( HEALTH_TICKS_MODEL, origin, angles, 0 )

	healthTicks.RemoveFromAllRealms()
	healthTicks.AddToOtherEntitysRealms( baseWall )

	healthTicks.SetParent( ampedWall )
	healthTicks.SetScriptName( HEALTH_TICKS_SCRIPT_NAME )

	int bodyGroupIndexHigh = healthTicks.FindBodygroup( "shield_health_high" )
	int bodyGroupIndexMid = healthTicks.FindBodygroup( "shield_health_mid" )
	int bodyGroupIndexLow = healthTicks.FindBodygroup( "shield_health_low" )

	healthTicks.SetBodygroupModelByIndex( bodyGroupIndexHigh, 1 )
	healthTicks.SetBodygroupModelByIndex( bodyGroupIndexMid, 0 )
	healthTicks.SetBodygroupModelByIndex( bodyGroupIndexLow, 0 )

	entity shieldFX = StartParticleEffectInWorld_ReturnEntity( file.shieldFxIndex, origin, angles )

	shieldFX.RemoveFromAllRealms()
	shieldFX.AddToOtherEntitysRealms( baseWall )

	shieldFX.SetParent( baseWall ) //Make amped wall work with moving geo

	file.ampedWallEntToShieldFX[ ampedWall ] <- shieldFX

	CreateAirShakeRumbleOnly( origin, 16, 150, 0.6, 150 )

	float baseHealth = GetBaseWallHealth( baseWall.GetOwner() )
	baseWall.SetMaxHealth( baseHealth )

	if ( GetCurrentPlaylistVarBool( "rampart_higher_health", true ) )
	{
		baseWall.SetHealth( baseWall.GetHealth() + ( baseHealth - COVER_WALL_HIGHER_HEALTH ) )
	}
	else
	{
		baseWall.SetHealth( baseWall.GetHealth() + ( baseHealth - COVER_WALL_STARTING_HEALTH ) )
	}

	OnThreadEnd(
		function() : ( ampedWall, baseWall, shieldFX, healthTicks )
		{
			StopSoundOnEntity( ampedWall, AMPED_WALL_SHIELD_LOOP_SFX )

			if ( ampedWall in file.ampedWallEntToShieldFX )
				delete file.ampedWallEntToShieldFX[ ampedWall ]

			if ( IsValid( baseWall ) )
			{
				if ( IsValid( ampedWall ) )
				{
					int fxID = GetParticleSystemIndex( AMPED_WALL_PACKED_UP_FX )
					StartParticleEffectInWorld( fxID, ampedWall.GetOrigin(), ampedWall.GetAngles() )
					EmitSoundAtPosition( TEAM_UNASSIGNED, ampedWall.GetOrigin(), AMPED_WALL_POWER_DOWN_SFX, ampedWall )
					ampedWall.Destroy()
				}
			}

			if ( IsValid( shieldFX ) )
			{
				EffectStop( shieldFX )
			}

			if ( IsValid( healthTicks ) )
				healthTicks.Destroy()
		}
	)

	WaitForever()
}

void function AmpedWallPassThroughFX( entity hitOwner, entity ampedWall, vector hitPos )
{
	if( IsValid( ampedWall ) && ampedWall.GetScriptName() == AMPED_WALL_SCRIPT_NAME )
		thread AmpedWallPassThroughFX_Thread( ampedWall )
}

void function AmpedWallPassThroughFX_Thread( entity ampedWall )
{
	if ( !IsValid( ampedWall ) )
		return

	if ( ! ( ampedWall in file.ampedWallEntToShieldFX ) )
		return

	#if SERVER
		entity owner = ampedWall.GetOwner()
	#endif

	entity shieldFX = file.ampedWallEntToShieldFX[ ampedWall ]
	EffectSetControlPointVector( shieldFX, 2, <1,0,0> )

	EndSignal( shieldFX, "OnDestroy" )

	wait FX_IMPACT_DURATION

	EffectSetControlPointVector( shieldFX, 2, <0,0,0> )
}

void function PlayIncomingDamageFX_Thread( entity shieldFX )
{
	EndSignal( shieldFX, "OnDestroy" )
	EffectSetControlPointVector( shieldFX, 3, <1,0,0> )

	wait FX_IMPACT_DURATION

	EffectSetControlPointVector( shieldFX, 3, <0,0,0> )
}

#if SERVER
void function ClientCallback_TryPickupCoverWall( entity player, entity device )
{
	if ( !SURVIVAL_PlayerAllowedToPickup( player ) )
		return

	if ( !IsValid( device ) || device.GetScriptName() != BASE_WALL_SCRIPT_NAME )
		return

	if ( device != player.GetUseEntity() )
		return

	PickupCoverWall( player, device )
}

void function PickupCoverWall( entity player, entity device )
{
	if ( GradeFlagsHas( device, eGradeFlags.IS_BUSY ) )
		return

	GradeFlagsSet( device, eGradeFlags.IS_BUSY )
	if ( CoverWall_PickUp( player, device ) )
	{
		device.Signal( "CoverWall_PickedUp" )
	}
}
#endif

void function CoverWall_TrackContinuousUse( entity player, entity useTarget, float useTime, bool doRequireUseButtonHeld )
{
	player.EndSignal( "OnDeath" )
	useTarget.EndSignal( "OnDeath" )
	useTarget.EndSignal( "OnDestroy" )
	player.EndSignal( "StartPhaseShift" )
	useTarget.EndSignal( "StartPhaseShift" )

	table result = {}
	result.success <- false

	float maxDist2 = DistanceSqr( player.GetOrigin(), useTarget.GetOrigin() ) + COVER_WALL_MAX_USE_DIST2_MOD

	OnThreadEnd
	(
		function() : ( player, result )
		{
			if ( !result.success )
			{
				player.Signal( "CoverWall_OnContinousUseStopped" )
			}
		}
	)

	float startTime = Time()
	while ( Time() < startTime + useTime && (!doRequireUseButtonHeld || CoverWall_IsReviveButtonDown( player )) && DistanceSqr( player.GetOrigin(), useTarget.GetOrigin() ) <= maxDist2 )
		WaitFrame()

	if ( (!doRequireUseButtonHeld || CoverWall_IsReviveButtonDown( player )) && DistanceSqr( player.GetOrigin(), useTarget.GetOrigin() ) <= maxDist2 )
		result.success = true
}

bool function CoverWall_IsReviveButtonDown( entity player )
{
	bool inUse      = player.IsInputCommandHeld( IN_USE )
	bool inUseAlt   = COVER_WALL_USE_ALT && player.IsInputCommandHeld( IN_USE_ALT )
	bool inUseQuick = COVER_WALL_USE_QUICK && player.IsInputCommandHeld( IN_USE_LONG )

	return inUse || inUseAlt || inUseQuick
}

bool function CoverWall_PickUp( entity player, entity baseWall )
{
	entity weapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )

	string className = weapon.GetWeaponClassName()
	if ( className != COVER_WALL_WEAPON_NAME )
		return false

	if ( Bleedout_IsBleedingOut( player ) )
		return false

	//Don't allow the player to pick up walls if they are using a mounted turret.
	if ( MountedTurretPlaceable_IsUsingMountedTurret( player ) )
		return false

	if ( CanReclaimWall( baseWall ) )
	{
		Weapon_AddSingleCharge( weapon )
	}

	return true
}
void function PlayPickupAnimAndDissolveAfter( entity wall )
{
	waitthread PlayAnim( wall, "prop_rampart_wall_destroy" )

	if ( IsValid( wall ) )
		wall.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 1000  )
}

void function CoverWall_OnDamaged( entity wallProxy, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( wallProxy ) )
		return

	if ( !IsValid( attacker ) )
		return

	if ( IsWorldSpawn( attacker ) )
		return

	int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )

	//Two melees will destroy the wall
	if ( IsBitFlagSet( damageFlags, DF_EXPLOSION ) || IsBitFlagSet( damageFlags, DF_MELEE ) )
	{
		if ( IsBitFlagSet( damageFlags, DF_EXPLOSION ) )
		{
			int damageSourceIdentifier = DamageInfo_GetDamageSourceIdentifier( damageInfo )

			switch ( damageSourceIdentifier )
			{
				case eDamageSourceId.melee_shadowroyale_hands:
				case eDamageSourceId.melee_shadowsquad_hands:
				case eDamageSourceId.mp_weapon_shadow_squad_hands_primary:
					DamageInfo_SetDamage( damageInfo, wallProxy.GetMaxHealth() / 2 )
					DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
					break

				default:
					if ( IsProwler( attacker ) )
						DamageInfo_SetDamage( damageInfo, wallProxy.GetMaxHealth() / 2 )
			}
		}

		if ( IsBitFlagSet( damageFlags, DF_MELEE ) )
		{
			DamageInfo_SetDamage( damageInfo, wallProxy.GetMaxHealth() / 2 )
			DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
		}
	}
}

void function CoverWall_OnPostDamaged( entity wallProxy, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	entity weapon = DamageInfo_GetWeapon( damageInfo )

	if ( !IsValid( wallProxy ) )
		return

	if ( !IsValid( attacker ) )
		return

	if ( IsWorldSpawn( attacker ) )
		return

	int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )

	if ( wallProxy.GetMaxHealth() >= COVER_WALL_MAX_HEALTH && wallProxy.GetHealth() - DamageInfo_GetDamage( damageInfo ) <= wallProxy.GetMaxHealth()/2 )
	{
		if ( wallProxy.GetHealth() > wallProxy.GetMaxHealth()/2 )
		{
			thread PlayAnim( wallProxy, "prop_rampart_wall_extended_damage_alt_idle", wallProxy.GetParent() )
			StartParticleEffectInWorld( GetParticleSystemIndex( BASE_WALL_DAMAGE_STATE_TRANSITION_FX ), wallProxy.GetOrigin(), wallProxy.GetAngles() )
			EmitSoundOnEntity( wallProxy, BASE_WALL_DAMAGE_STATE_TRANSITION_SFX )

			if ( ( wallProxy in file.baseWallToPersistentDamageFX ) && !IsValid( file.baseWallToPersistentDamageFX[ wallProxy ] ) )
			{
				entity persistentFX = StartParticleEffectInWorld_ReturnEntity( file.persistentDamageFxIndex, wallProxy.GetOrigin(), wallProxy.GetAngles() )

				persistentFX.RemoveFromAllRealms()
				persistentFX.AddToOtherEntitysRealms( wallProxy )

				file.baseWallToPersistentDamageFX[ wallProxy ] <- persistentFX
			}

			EmitSoundOnEntity( wallProxy, BASE_WALL_DAMAGE_STATE_LOOP_SFX )
		}
		else
		{
			StartParticleEffectInWorld( GetParticleSystemIndex( BASE_WALL_TAKE_DAMAGE_WHILE_HEALTH_LOW_FX ), wallProxy.GetOrigin(), wallProxy.GetAngles() )
		}
	}

	#if SERVER
		if ( !IsBitFlagSet( damageFlags, DF_MELEE ) )
		{
			entity owner = wallProxy.GetOwner()
		}
	#endif

	bool wallDestroyed = false
	if ( wallProxy.GetHealth() - DamageInfo_GetDamage( damageInfo ) <= 0 )
	{
		wallDestroyed = true
		DestroyWallFX( wallProxy, attacker )

		if ( IsValid( wallProxy.GetOwner() ) )
			PIN_Interact( wallProxy.GetOwner(), "rampart_base_wall_destroyed", wallProxy.GetOrigin() )

		array<entity> children = GetChildren(wallProxy)
		foreach ( child in children )
		{
			if( !IsValid(child) )
				continue

			entity deathBox = FindTargetNameInChildren( child, "_DEATH_BOX_" )
			if ( IsValid ( deathBox ) )
			{
				child.ClearParent()
				FakePhysicsThrow( null, child, <0,0,50>, true )
			}
		}
	}

	if ( wallDestroyed || wallProxy.GetMaxHealth() < COVER_WALL_MAX_HEALTH )
		DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
	else
		DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )

	if ( attacker.IsPlayer() && !IsBitFlagSet( damageFlags, DF_MELEE ) )
	{
		attacker.NotifyDidDamage( wallProxy, 0, DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ),
			DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ) | DF_NO_HITBEEP,
			DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
	}
}

void function DestroyWallFX( entity wallProxy, entity attacker )
{
	StartParticleEffectInWorld( GetParticleSystemIndex( BASE_WALL_DESTROYED_FX ), wallProxy.GetOrigin(), wallProxy.GetAngles() )
	EmitSoundAtPosition( TEAM_UNASSIGNED, wallProxy.GetOrigin(), BASE_WALL_DESTROYED_SFX, wallProxy )

	entity owner = wallProxy.GetOwner()
	if ( IsValid( owner )
		&& attacker != owner
		&& Distance( owner.GetOrigin(), wallProxy.GetOrigin() ) < WALL_DESTROYED_CALLOUT_MIN_DIST
		&& wallProxy.GetMaxHealth() >= COVER_WALL_MAX_HEALTH
		&& ( GetPlayerVoice( owner ) == "rampart" ) )
	{
		PlayBattleChatterLineToSpeakerAndTeamWithDebounceTime( owner, "bc_rampart_coverDestroyed", 5.0, 5.0 )
	}
}

void function AmpedWall_OnDamaged( entity ampedWall, var damageInfo )
{
	// Damage Math
	int damageSourceIdentifier = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	float damageScale = 1.0
	float damage = DamageInfo_GetDamage( damageInfo )

	if ( damage <= 0 )
		return

	if ( IsBitFlagSet( DamageInfo_GetCustomDamageType( damageInfo ), DF_ELECTRICAL ) )
	{
		if ( damageSourceIdentifier == eDamageSourceId.mp_weapon_grenade_emp )
			damageScale *= 1.5
	}

	if ( damageSourceIdentifier == eDamageSourceId.mp_ability_crypto_drone_emp_trap )
		damageScale *= ampedWall.GetMaxHealth() / damage

	if ( damageScale > 1.0 )
		DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )

	DamageInfo_SetDamage( damageInfo, damage * damageScale )
}

void function AmpedWall_OnPostDamaged( entity ampedWall, var damageInfo )
{
	int damageSourceIdentifier = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	float damageScale = 1.0
	float damage = DamageInfo_GetDamage( damageInfo )
	if ( damage <= 0 )
		return

	//	Rampart unique tracker
	#if SERVER
		if ( !IsBitFlagSet( DamageInfo_GetCustomDamageType( damageInfo ), DF_MELEE ) )
		{
			entity owner = ampedWall.GetOwner()
		}
	#endif

	bool ampedWallDestroyed = ( ampedWall.GetHealth() - DamageInfo_GetDamage( damageInfo ) ) <= 0

	// Damage Feedback

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !IsValid( attacker ) )
		return

	entity baseWall = ampedWall.GetParent()

	if ( IsBitFlagSet( DamageInfo_GetCustomDamageType( damageInfo ), DF_MELEE ) )
	{
		if ( baseWall != null && baseWall.GetScriptName() == BASE_WALL_SCRIPT_NAME )
			baseWall.TakeDamage( DamageInfo_GetDamage( damageInfo ), attacker, attacker, { scriptType = DamageInfo_GetCustomDamageType( damageInfo ), damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo ) } )

	}
	else if ( attacker.IsPlayer() )
	{
		DamageInfo_AddCustomDamageType( damageInfo, DF_NO_HITBEEP )
		DamageInfo_AddCustomDamageType( damageInfo, DAMAGEFLAG_VICTIM_HAS_VORTEX )

		if ( ampedWallDestroyed )
			DamageInfo_AddCustomDamageType( damageInfo, DF_KILLSHOT )

		attacker.NotifyDidDamage( ampedWall, 0, DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ),
			DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ) | DF_NO_HITBEEP | DAMAGEFLAG_VICTIM_HAS_VORTEX,
			DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
	}

	if ( IsValid( ampedWall ) && ampedWall in file.ampedWallEntToShieldFX )
	{
		entity shieldFX = file.ampedWallEntToShieldFX[ ampedWall ]
		thread PlayIncomingDamageFX_Thread( shieldFX )
	}

	if ( ampedWallDestroyed )
	{
		StartParticleEffectInWorld( GetParticleSystemIndex( AMPED_WALL_DESTROYED_FX ), ampedWall.GetOrigin(), ampedWall.GetAngles())

		if ( baseWall != null && baseWall.GetScriptName() == BASE_WALL_SCRIPT_NAME )
		{
			baseWall.SetBodygroupModelByIndex( baseWall.FindBodygroup( "rampart_cover_wall_arms" ), 0 )
		}

		if ( attacker.IsPlayer() )
		{
			EmitSoundOnEntityOnlyToPlayer( attacker, attacker, AMPED_WALL_BREAK_SFX_1P )
			EmitSoundAtPositionExceptToPlayer( TEAM_UNASSIGNED, ampedWall.GetOrigin(), attacker, AMPED_WALL_BREAK_SFX_3P )
		}
		else
		{
			EmitSoundAtPosition( TEAM_UNASSIGNED, ampedWall.GetOrigin(), AMPED_WALL_BREAK_SFX_3P, ampedWall)
		}

		if ( IsValid( baseWall) && IsValid( baseWall.GetOwner() ) )
			PIN_Interact( baseWall.GetOwner(), "rampart_amped_wall_destroyed", baseWall.GetOrigin() )
	}

	HealthTick_OnDamaged( ampedWall, DamageInfo_GetDamage( damageInfo ) )
}

void function HealthTick_OnDamaged( entity ampedWall, float damage )
{
	entity healthTicks

	foreach ( entity child in GetChildren(ampedWall) )
	{
		if ( child.GetScriptName() == HEALTH_TICKS_SCRIPT_NAME )
		{
			healthTicks = child
		}
	}

	if ( !IsValid( healthTicks ) )
		return

	string bodyGroupIndexOn = "shield_health_high"
	array<string> bodyGroups = [ "shield_health_high", "shield_health_low" ]

	if ( ampedWall.GetHealth() - damage > ampedWall.GetMaxHealth() * ( 1.0 / 2.0 ) )
	{
		bodyGroupIndexOn = "shield_health_high"
	}
	else
	{
		bodyGroupIndexOn = "shield_health_low"
	}

	foreach ( string bodyGroup in bodyGroups )
	{
		if ( bodyGroup == bodyGroupIndexOn )
			healthTicks.SetBodygroupModelByIndex( healthTicks.FindBodygroup( bodyGroup ), 1 )
		else
			healthTicks.SetBodygroupModelByIndex( healthTicks.FindBodygroup( bodyGroup ), 0 )
	}
}
#endif

bool function CoverWall_CanUse( entity player, entity ent, int useFlags )
{
	if ( !IsValid( player ) || !IsValid( ent ) )
		return false

	if ( player != ent.GetOwner() )
		return false

	if ( player.IsTitan() )
		return false

	return SURVIVAL_PlayerAllowedToPickup( player ) && !GradeFlagsHas( ent, eGradeFlags.IS_BUSY )
}

#if CLIENT
void function CoverWall_OnPropScriptCreated( entity ent )
{
	if ( ent.GetScriptName() == BASE_WALL_SCRIPT_NAME )
	{
		SetCallback_CanUseEntityCallback( ent, CoverWall_CanUse )
	}
}

void function CoverWall_OnPropScriptDestroyed( entity ent )
{
	if ( !IsValid( ent ) )
		return

	if ( ent.GetScriptName() == BASE_WALL_SCRIPT_NAME )
	{
		CustomUsePrompt_ClearForEntity( ent )
	}
}

void function OnCharacterButtonPressed( entity player )
{
	entity useEnt = player.GetUsePromptEntity()
	if ( !IsValid( useEnt ) || useEnt.GetScriptName() != BASE_WALL_SCRIPT_NAME )
		return

	if ( useEnt.GetOwner() != player )
		return

	//CustomUsePrompt_SetLastUsedTime( Time() )

	// Send client command to server
	// Get ent index to pass to server
	int entIndex = useEnt.GetEncodedEHandle()
	player.ClientCommand( "ClientCallback_TryPickupCoverWall " + entIndex )
}

void function CoverWall_CreateHUDMarker( entity wall )
{
	entity localClientPlayer = GetLocalClientPlayer()
	wall.EndSignal( "OnDestroy" )

	if ( !CoverWall_ShouldShowIcon( localClientPlayer, wall ) )
		return

	vector pos = wall.GetOrigin() + <0,0,COVER_WALL_ICON_HEIGHT>
	var rui = CreateCockpitRui( $"ui/cover_wall_marker_icons.rpak", RuiCalculateDistanceSortKey( localClientPlayer.EyePosition(), pos ) )
	RuiTrackFloat( rui, "healthFrac", wall, RUI_TRACK_HEALTH )
	RuiTrackFloat3( rui, "pos", wall, RUI_TRACK_OVERHEAD_FOLLOW )
	RuiKeepSortKeyUpdated( rui, true, "pos" )

	OnThreadEnd(
	function() : ( rui )
	{
		RuiDestroy( rui )
	}
	)

	WaitForever()
}

bool function CoverWall_ShouldShowIcon( entity localPlayer, entity wall )
{
	if ( !GamePlayingOrSuddenDeath() )
		return false

	entity owner = wall.GetOwner()
	if ( !IsValid( owner ) )
		return false

	if ( localPlayer.GetTeam() != owner.GetTeam() )
		return false

	return true
}

void function CoverWall_OnGainFocus( entity ent )
{
	if ( !IsValid( ent ) )
		return

	if ( ent.GetScriptName() == BASE_WALL_SCRIPT_NAME )
	{
	//	CustomUsePrompt_Show( ent )
	}
}

void function CoverWall_OnLoseFocus( entity ent )
{
	//CustomUsePrompt_ClearForAny()
}

void function CoverWall_OnBeginPlacement( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return

	thread CoverWall_Placement( player )
}

void function CoverWall_OnEndPlacement( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return

	player.Signal( "CoverWall_StopPlacementProxy" )
}

void function CoverWall_Placement( entity player )
{
	player.EndSignal( "CoverWall_StopPlacementProxy" )

	entity wall = CoverWall_CreateProxyModel( COVER_WALL_MODEL )
	wall.EnableRenderAlways()
	wall.Show()
	DeployableModelHighlight( wall )

	var placementRui = CreateCockpitRui( $"ui/generic_trap_placement.rpak", RuiCalculateDistanceSortKey( player.EyePosition(), wall.GetOrigin() ) )
	int placementAttachment = wall.LookupAttachment( "fx_top" )
	RuiSetBool( placementRui, "staticPosition", true )
	RuiSetInt( placementRui, "trapLimit", COVER_WALL_MAX_WALLS )
	RuiTrackFloat3( placementRui, "mainTrapPos", wall, RUI_TRACK_POINT_FOLLOW, placementAttachment )
	RuiKeepSortKeyUpdated( placementRui, true, "mainTrapPos" )

	OnThreadEnd(
		function() : ( wall, placementRui )
		{
			if ( IsValid( wall ) )
				wall.Destroy()

			if ( IsValid( placementRui ) )
				RuiDestroy( placementRui )
		}
	)

	while ( true )
	{
		CoverWallPlacementInfo placementInfo = CoverWall_GetPlacementInfo( player, wall )

		if ( !placementInfo.success )
			DeployableModelInvalidHighlight( wall )
		else
			DeployableModelHighlight( wall )

		RuiSetBool( placementRui, "success", placementInfo.success )
		RuiSetInt( placementRui, "trapCount", CoverWall_GetOwnedTrapCountOnClient( player ) )

		wall.SetOrigin( placementInfo.origin )
		wall.SetAngles( placementInfo.angles )

		WaitFrame()
	}
}

int function CoverWall_GetOwnedTrapCountOnClient( entity player )
{
	int count = 0
	array<entity> walls = GetEntArrayByScriptName( BASE_WALL_SCRIPT_NAME )
	foreach ( entity wall in walls )
	{
		if ( wall.GetOwner() == player )
			count++
	}

	return count
}
#endif

entity function CoverWall_CreateProxyModel( asset modelName )
{
	#if SERVER
		entity proxy = CreatePropDynamic( modelName, <0,0,0>, <0,0,0> )
	#else
		entity proxy = CreateClientSidePropDynamic( <0,0,0>, <0,0,0>, modelName )
	#endif
	proxy.kv.renderamt = 255
	proxy.kv.rendermode = 3
	proxy.kv.rendercolor = "255 255 255 255"
	proxy.Hide()

	return proxy
}

CoverWallPlacementInfo function CoverWall_GetPlacementInfo( entity player, entity wallModel )
{
	vector eyePos = player.EyePosition()
	vector viewVec = player.GetViewVector()
	vector angles = < 0, VectorToAngles( viewVec ).y, 0 >

	float maxRange = COVER_WALL_PLACEMENT_RANGE_MAX

	TraceResults viewTraceResults = TraceLine( eyePos, eyePos + player.GetViewVector() * (COVER_WALL_PLACEMENT_RANGE_MAX * 2), [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
	if ( viewTraceResults.fraction < 1.0 )
	{
		float slope = fabs( viewTraceResults.surfaceNormal.x ) + fabs( viewTraceResults.surfaceNormal.y )
		if ( slope < 0.707 )
			maxRange = min( Distance2D( eyePos, viewTraceResults.endPos ), COVER_WALL_PLACEMENT_RANGE_MAX )
	}

	vector idealPos =  player.GetOrigin() + ( AnglesToForward( angles ) * COVER_WALL_PLACEMENT_RANGE_MAX )

	vector fwdStart = eyePos + viewVec * min( COVER_WALL_PLACEMENT_RANGE_MIN, maxRange )
	TraceResults fwdResults = TraceHull( fwdStart, eyePos + viewVec * maxRange, COVER_WALL_BOUND_MINS, COVER_WALL_BOUND_MAXS, [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
	TraceResults downResults = TraceHull( fwdResults.endPos, fwdResults.endPos - COVER_WALL_PLACEMENT_TRACE_OFFSET, COVER_WALL_BOUND_MINS, COVER_WALL_BOUND_MAXS, [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

	if ( COVER_WALL_DEBUG_DRAW_PLACEMENT )
	{
		DebugDrawLine( fwdStart, fwdResults.endPos, 255,0,0, true, 0.05 )
		DebugDrawSphere( fwdResults.endPos, 16, 255,0,0, true, 0.05 )
		DebugDrawLine( fwdResults.endPos, fwdResults.endPos - COVER_WALL_PLACEMENT_TRACE_OFFSET, 255,0,0, true, 0.05 )
		DebugDrawBox( downResults.endPos, COVER_WALL_BOUND_MINS, COVER_WALL_BOUND_MAXS, 0, 255, 0, 1, 1.0 )
	}

	CoverWallPlacementInfo placementInfo = CoverWall_GetPlacementInfoFromTraceResults( player, wallModel, downResults, viewTraceResults, idealPos )

	int attempts = 0
	vector fallbackPos = fwdResults.endPos

	while ( !placementInfo.success && attempts < 3 )
	{
		fallbackPos = fallbackPos - ( viewVec * ( Length( COVER_WALL_BOUND_MINS ) / 4 ) )
		TraceResults downFallbackResults = TraceHull( fallbackPos, fallbackPos - COVER_WALL_PLACEMENT_TRACE_OFFSET, COVER_WALL_BOUND_MINS, COVER_WALL_BOUND_MAXS, [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

		if ( COVER_WALL_DEBUG_DRAW_PLACEMENT )
		{
			DebugDrawBox( downFallbackResults.endPos, COVER_WALL_BOUND_MINS, COVER_WALL_BOUND_MAXS, 255, 0, 0, 1, 1.0 )
		}

		placementInfo = CoverWall_GetPlacementInfoFromTraceResults( player, wallModel, downFallbackResults, viewTraceResults, idealPos )
		attempts++
	}

	return placementInfo
}

CoverWallPlacementInfo function CoverWall_GetPlacementInfoFromTraceResults( entity player, entity wallModel, TraceResults hullTraceResults, TraceResults viewTraceResults, vector idealPos )
{
	vector viewVec = player.GetViewVector()
	vector angles  = < 0, VectorToAngles( viewVec ).y + 90.0, 0 >

	bool success = !hullTraceResults.startSolid && hullTraceResults.fraction < 1.0

	entity hitEnt = hullTraceResults.hitEnt
	if ( IsValid( hitEnt ) )
	{
		if ( !hitEnt.IsWorld() && hitEnt.GetNetworkedClassName() != "func_brush" )
			success = false
	} else {
		success = false
	}


	if ( hullTraceResults.startSolid && hullTraceResults.fraction < 1.0 )
	{
		TraceResults upResults = TraceHull( hullTraceResults.endPos, hullTraceResults.endPos, COVER_WALL_BOUND_MINS, COVER_WALL_BOUND_MAXS, [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
		if ( !upResults.startSolid )
			success = true
	}

	vector surfaceAngles = AnglesToRight( angles )
	if ( hullTraceResults.fraction < 1.0 )
	{
		surfaceAngles 	= AnglesOnSurface( hullTraceResults.surfaceNormal, AnglesToRight( angles ) )
		vector newUpDir = AnglesToUp( surfaceAngles )
		vector oldUpDir = AnglesToUp( angles )

		if ( DotProduct( newUpDir, oldUpDir ) < COVER_WALL_ANGLE_LIMIT )
		{
			surfaceAngles = AnglesToRight( angles )
			success = false
		}
	}

	if ( success )
	{
		wallModel.SetOrigin( hullTraceResults.endPos )
		wallModel.SetAngles( surfaceAngles )
	}

	if ( !player.IsOnGround() )
	{
		success = false
	}

	if ( success && hullTraceResults.fraction < 1.0 )
	{
		vector right = wallModel.GetRightVector()
		vector forward = wallModel.GetForwardVector()
		vector up = wallModel.GetUpVector()

		array< vector > groundTestOffsetsForward = [
			( -right * 8 ),
			( -right * 8 ) + ( forward * 40 ),
			( -right * 8 ) + ( -forward * 40 ),
		]

		array<vector> groundTestOffsetsBack = [
			( right * 8 ),
			( right * 8 ) + ( forward * 40 ),
			( right * 8 ) +  ( -forward * 40 ),
		]

		vector tempSurfaceNormals = <0,0,0>
		foreach ( vector testOffset in groundTestOffsetsForward )
		{
			vector testPos = wallModel.GetOrigin() + testOffset
			TraceResults traceResult = TraceLine( testPos + ( up * COVER_WALL_PLACEMENT_MAX_HEIGHT_DELTA ), testPos + ( up * -COVER_WALL_PLACEMENT_MAX_HEIGHT_DELTA ), [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
			if ( traceResult.fraction == 1.0 )
			{
				success = false
				break
			}
		}

		foreach ( vector testOffset in groundTestOffsetsBack )
		{
			vector testPos = wallModel.GetOrigin() + testOffset
			TraceResults traceResult = TraceLine( testPos + ( up * COVER_WALL_PLACEMENT_MAX_HEIGHT_DELTA ), testPos + ( up * -COVER_WALL_PLACEMENT_MAX_HEIGHT_DELTA ), [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
			if ( traceResult.fraction == 1.0 )
			{
				success = false
				break
			}
			tempSurfaceNormals += traceResult.surfaceNormal
		}

		tempSurfaceNormals.x /= groundTestOffsetsForward.len()
		tempSurfaceNormals.y /= groundTestOffsetsForward.len()
		tempSurfaceNormals.z /= groundTestOffsetsForward.len()
		surfaceAngles = AnglesOnSurface( tempSurfaceNormals, AnglesToRight( angles ) )
	}

	if ( success )
	{
		vector right = wallModel.GetRightVector()
		vector forward = wallModel.GetForwardVector()

		array< vector > wallTestOffsets = [
			( right * 8 ) + ( forward * 40 ),
			( -right * 8 ) + ( forward * 40 ),
			( right * 8 ) +  ( -forward * 40 ),
			( -right * 8 ) + ( -forward * 40 )
		]

		foreach ( vector testOffset in wallTestOffsets )
		{
			vector testPos = wallModel.GetWorldSpaceCenter()
			TraceResults traceResult = TraceLine( testPos, testPos + testOffset, [player, wallModel], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
			if ( traceResult.fraction < 1.0 )
			{
				success = false
				break
			}
		}
	}

	if ( success && !PlayerCanSeePos( player, hullTraceResults.endPos, true, 90 ) )
	{
		success = false
	}

	vector org = success ? hullTraceResults.endPos : idealPos
	vector ang = success ? surfaceAngles : angles
	CoverWallPlacementInfo placementInfo
	placementInfo.success = success
	placementInfo.origin = org
	placementInfo.angles = ang
	if ( success && IsValid(hitEnt) && hitEnt.GetNetworkedClassName() == "func_brush" )
	{
		placementInfo.parentEnt = hitEnt
	}

	return placementInfo
}