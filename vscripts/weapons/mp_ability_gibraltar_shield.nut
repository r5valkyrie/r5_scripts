global function MpAbilityGibraltarShield_Init

global function OnWeaponAttemptOffhandSwitch_ability_gibraltar_shield
global function OnWeaponPrimaryAttack_ability_gibraltar_shield
global function OnWeaponChargeBegin_ability_gibraltar_shield
global function OnWeaponChargeEnd_ability_gibraltar_shield
global function OnWeaponOwnerChanged_ability_gibraltar_shield

global function GibraltarShield_RegisterNetworkFunctions

#if SERVER
global function ClientCallback_ToggleGibraltarShield
#endif

global string GIBRALTAR_GUN_SHIELD_NAME = "gibraltar_gun_shield"

const vector SHIELD_ANGLE_OFFSET = <0, -90, 0>
const asset FX_GUN_SHIELD_WALL = $"P_gun_shield_gibraltar_3P"
const asset FX_GUN_SHIELD_BREAK = $"P_gun_shield_gibraltar_break_CP_3P"
const asset FX_GUN_SHIELD_BREAK_FP = $"P_gun_shield_gibraltar_break_CP_FP"
const asset FX_GUN_SHIELD_SHIELD_COL = $"mdl/fx/gibralter_gun_shield.rmdl"

const string SOUND_PILOT_GUN_SHIELD_3P = "Gibraltar_GunShield_Sustain_3P"
const string SOUND_PILOT_GUN_SHIELD_1P = "Gibraltar_GunShield_Sustain_1P"
const string SOUND_PILOT_GUN_SHIELD_BREAK_1P = "Gibraltar_GunShield_Destroyed_1P"
const string SOUND_PILOT_GUN_SHIELD_BREAK_3P = "Gibraltar_GunShield_Destroyed_3P"

const bool PILOT_GUN_SHIELD_DRAIN_AMMO = false
const float PILOT_GUN_SHIELD_DRAIN_AMMO_RATE = 1.0

const PLAYER_GUN_SHIELD_WALL_RADIUS = 18
const PLAYER_GUN_SHIELD_WALL_HEIGHT = 32
const PLAYER_GUN_SHIELD_WALL_FOV = 85

const int PILOT_SHIELD_OFFHAND_INDEX = OFFHAND_EQUIPMENT

struct
{
	var shieldRegenRui
	#if SERVER
		bool allowCarryoverDamage
	#endif
} file

void function MpAbilityGibraltarShield_Init()
{
	PrecacheWeapon( $"mp_ability_gibraltar_shield" )
	PrecacheScriptString( GIBRALTAR_GUN_SHIELD_NAME )

	PrecacheModel( FX_GUN_SHIELD_SHIELD_COL )

	PrecacheParticleSystem( FX_GUN_SHIELD_WALL )
	PrecacheParticleSystem( FX_GUN_SHIELD_BREAK_FP )
	PrecacheParticleSystem( FX_GUN_SHIELD_BREAK )

	RegisterSignal( "GibraltarShieldDeactivate" )

	#if CLIENT
		RegisterConCommandTriggeredCallback( "+scriptCommand5", GunShieldTogglePressed )
	#endif

	#if SERVER
		AddCallback_OnPassiveChanged( ePassives.PAS_ADS_SHIELD, PilotShield_OnPassiveChanged )

		file.allowCarryoverDamage = GetCurrentPlaylistVarBool( "enable_arm_shield_carryover_damage", true )
	#endif
}

void function GibraltarShield_RegisterNetworkFunctions()
{
	Remote_RegisterServerFunction( "ClientCallback_ToggleGibraltarShield" )
}

#if CLIENT
void function GunShieldTogglePressed( entity player )
{
	if ( player != GetLocalViewPlayer() || player != GetLocalClientPlayer() )
		return

	entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( !IsValid( activeWeapon ) )
		return

               
                                         
         
       

	if ( activeWeapon.IsWeaponAdsButtonPressed() || activeWeapon.IsWeaponInAds() )
		Remote_ServerCallFunction( "ClientCallback_ToggleGibraltarShield" )
}
#endif // #if CLIENT

#if SERVER
void function ClientCallback_ToggleGibraltarShield( entity player )
{
	if ( !IsAlive( player ) )
		return

	entity weapon = player.GetOffhandWeapon( PILOT_SHIELD_OFFHAND_INDEX )

	if ( !IsValid( weapon ) )
		return

	if ( weapon.GetWeaponClassName() != "mp_ability_gibraltar_shield" )
		return

	array<string> mods = weapon.GetMods()

	if ( mods.contains( "disabled" ) )
		mods.fastremovebyvalue( "disabled" )
	else
		mods.append( "disabled" )

	weapon.SetMods( mods )
}

void function PilotShield_OnPassiveChanged( entity player, int passive, bool didHave, bool nowHas )
{
	if ( didHave )
	{
		entity weapon = player.GetOffhandWeapon( PILOT_SHIELD_OFFHAND_INDEX )
		player.TakeOffhandWeapon( PILOT_SHIELD_OFFHAND_INDEX )
	}

	if ( nowHas )
	{
		player.GiveOffhandWeapon( "mp_ability_gibraltar_shield", PILOT_SHIELD_OFFHAND_INDEX, [] )
	}
}
#endif // #if SERVER

bool function WeaponAllowsShield( entity weapon )
{
	if ( !IsValid( weapon ) )
		return false

	// default allow, need to add k/v to exempt
	var allowShield = weapon.GetWeaponInfoFileKeyField( "allow_gibraltar_shield" )
	if ( allowShield != null && allowShield == 0 )
		return false

               
                                                                 
               
       

	return true
}

#if CLIENT
void function TrackPrimaryWeapon()
{
	entity oldPrimary

	while ( file.shieldRegenRui != null )
	{
		entity player = GetLocalViewPlayer()

		if ( IsAlive( player ) )
		{
			entity newPrimary = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

			if ( newPrimary != oldPrimary )
			{
				oldPrimary = newPrimary
				RuiSetBool( file.shieldRegenRui, "weaponAllowedToUseShield", WeaponAllowsShield( newPrimary ) )
			}

			bool playerUsePrompts = GetConVarBool( "player_use_prompt_enabled" )
			RuiSetBool( file.shieldRegenRui, "showPlayerHints", playerUsePrompts )
		}

		WaitFrame()
	}
}

void function CreateShieldRegenRui( entity weapon )
{
	file.shieldRegenRui = CreateCockpitRui( $"ui/gibraltar_shield_regen.rpak" )
	RuiTrackBool( file.shieldRegenRui, "weaponIsDisabled", weapon, RUI_TRACK_WEAPON_IS_DISABLED )

	thread TrackPrimaryWeapon()
}
#endif // #if CLIENT

void function OnWeaponOwnerChanged_ability_gibraltar_shield( entity weapon, WeaponOwnerChangedParams changeParams )
{
#if SERVER

	GibraltarShield_DestroyShieldEnt( weapon )
	if ( IsValid( changeParams.newOwner ) && changeParams.newOwner.IsPlayer() )
		GibraltarShield_CreateShieldEnt( changeParams.newOwner, weapon )

#elseif CLIENT
	if ( file.shieldRegenRui == null && changeParams.newOwner == GetLocalViewPlayer() )
	{
		CreateShieldRegenRui( weapon )
	}
	else if ( changeParams.newOwner != GetLocalViewPlayer() )
	{
		if ( file.shieldRegenRui != null )
		{
			RuiDestroy( file.shieldRegenRui )
			file.shieldRegenRui = null
		}
	}
#endif
}

bool function OnWeaponChargeBegin_ability_gibraltar_shield( entity weapon )
{
	entity player = weapon.GetWeaponOwner()
	if ( !player.IsPlayer() )
		return true

#if SERVER

	thread GibraltarShield_ChargeThread( player, weapon )

#elseif CLIENT
	if ( file.shieldRegenRui == null )
	{
		CreateShieldRegenRui( weapon )
	}
	if ( InPrediction() && IsFirstTimePredicted() )
	{
		if ( player.GetSharedEnergyCount() > 0 )
		{
			weapon.EmitWeaponSound_1p3p( SOUND_PILOT_GUN_SHIELD_1P, SOUND_PILOT_GUN_SHIELD_3P )
		}
	}
#endif

	return true
}

void function OnWeaponChargeEnd_ability_gibraltar_shield( entity weapon )
{
	weapon.Signal( "OnChargeEnd" )

	weapon.StopWeaponSound( SOUND_PILOT_GUN_SHIELD_1P )
	weapon.StopWeaponSound( SOUND_PILOT_GUN_SHIELD_3P )
}

bool function OnWeaponAttemptOffhandSwitch_ability_gibraltar_shield( entity weapon )
{
	entity player = weapon.GetWeaponOwner()

	if ( !IsValid( player ) )
		return false

	entity mainWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( !WeaponAllowsShield( mainWeapon ) )
	{
                
             
                                                                        
         
        
		return false
	}

	return PlayerHasPassive( player, ePassives.PAS_ADS_SHIELD )
}

var function OnWeaponPrimaryAttack_ability_gibraltar_shield( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return 0
}

#if SERVER
void function GibraltarShield_ChargeThread( entity player, entity weapon )
{
	// Poll player shared energy and activate the shield if we have any energy available

	player.EndSignal( "OnDeath" )
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( "OnChargeEnd" )

	// Important WaitFrame, see R5DEV-201218
	WaitFrame()

	while ( true )
	{
		entity shieldEnt = weapon.GetWeaponUtilityEntity()
		if ( !IsValid( shieldEnt ) )
			return

		int amountOfMissingEnergy = player.GetSharedEnergyTotal() - player.GetSharedEnergyCount()
		if ( amountOfMissingEnergy != 0 && Time() > weapon.GetScriptTime0() )
		{
			player.AddSharedEnergy( amountOfMissingEnergy )
			GibraltarShield_UpdateShieldHealth( player, shieldEnt )
		}

		if ( player.GetSharedEnergyCount() > 0 )
		{
			//if ( !shieldEnt.GetCollisionAllowed() )
			{
				thread GibraltarShield_ShieldActiveThread( player, weapon )
			}
		}

		WaitFrame()
	}
}

void function GibraltarShield_ShieldActiveThread( entity player, entity weapon )
{
	entity shieldEnt = weapon.GetWeaponUtilityEntity()

	shieldEnt.Signal( "GibraltarShieldDeactivate" )
	shieldEnt.EndSignal( "GibraltarShieldDeactivate" )

	player.EndSignal( "OnDeath" )
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( "OnChargeEnd" )
	shieldEnt.EndSignal( "OnDestroy" )

	GunShieldSettings gs = GibraltarShield_GetGunShieldSettings( player, weapon )
	StartGunAttachedShieldFX( gs, shieldEnt )

	//shieldEnt.SetCollisionAllowed( true )
	shieldEnt.SetTakeDamageType( DAMAGE_EVENTS_ONLY )

	GibraltarShield_UpdateShieldHealth( player, shieldEnt )

	EmitSoundOnEntityExceptToPlayer( player, player, SOUND_PILOT_GUN_SHIELD_3P )
	EmitSoundOnEntityOnlyToPlayer( player, player, SOUND_PILOT_GUN_SHIELD_1P )

	OnThreadEnd(
		function () : ( player, weapon, shieldEnt )
		{
			if ( IsValid( shieldEnt ) )
			{
				if ( IsValid( shieldEnt.e.shieldWallFX ) )
					EffectStop( shieldEnt.e.shieldWallFX )

				foreach ( fx in shieldEnt.e.fxControlPoints )
					EffectStop( fx )

				shieldEnt.e.fxControlPoints.clear()
				//shieldEnt.SetCollisionAllowed( false )
				shieldEnt.SetTakeDamageType( DAMAGE_NO )
			}

			if ( IsValid( player ) )
			{
				StopSoundOnEntity( player, SOUND_PILOT_GUN_SHIELD_3P )
				StopSoundOnEntity( player, SOUND_PILOT_GUN_SHIELD_1P )
			}
		}
	)

	WaitForever()
}

void function GibraltarShield_OnDamaged( entity ent, var damageInfo )
{
	float damage        = DamageInfo_GetDamage( damageInfo )
	entity attacker     = DamageInfo_GetAttacker( damageInfo )
	entity inflictor    = DamageInfo_GetInflictor( damageInfo )
	int damageSourceId  = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	vector damageOrigin = DamageInfo_GetDamagePosition( damageInfo )
	entity owner        = ent.GetOwner()

	if ( damage > 0 )
	{
		if ( IsFriendlyTeam( attacker.GetTeam(), owner.GetTeam() ) )
			return

		if ( IsValid( owner ) && IsValid( attacker ) && attacker.IsPlayer() )
		{
			//SniperUlt_OnDamagedByPlayer_DiamondScan( owner, damageInfo )
			damage = DamageInfo_GetDamage( damageInfo ) //Reget damage as it may have been scaled.
		}

		float carryoverDamage = 0
		if ( file.allowCarryoverDamage && damage > owner.GetSharedEnergyCount() )
		{
			carryoverDamage = damage - owner.GetSharedEnergyCount()
			damage -= carryoverDamage
			DamageInfo_SetDamage( damageInfo, damage )

			if ( IsBitFlagSet( DamageInfo_GetCustomDamageType( damageInfo ), DF_EXPLOSION ) )
			{
				carryoverDamage = 0
			}
		}

		if ( IsValid( attacker ) && attacker.IsPlayer() )
		{
			attacker.NotifyDidDamage( ent, 0, damageOrigin, 0, damage, DF_NO_HITBEEP | DAMAGEFLAG_VICTIM_HAS_VORTEX, 0, null, 0 )
			StatsHook_GibraltarGunShield_OnDamageAbsorbed( owner, attacker, int(damage) ) // todo(dw): should damage be treated as a float or int?

			LiveAPI_SendCombatInstanceEvent( eLiveAPI_EventTypes.gibraltarShieldAbsorbed, attacker, owner, 0, int( floor( damage ) ) )

			if ( IsValid( owner ) )
			{
				entity weapon = DamageInfo_GetWeapon( damageInfo )
				Survival_PlayerDealtDamage( attacker, owner, weapon, 0, 0, int( damage ), damageSourceId )
				Remote_CallFunction_Replay( attacker, "ServerCallback_WarlordsIre_HighlightTargetRemote", attacker, owner, DamageInfo_GetDamageType( damageInfo ) )
				AddAssistingPlayerToVictim( attacker, owner ) //assists for damaging gibby arm shield
			}
		}

		if ( IsValid( owner ) )
		{
			int energyDamage = minint( int( damage ), owner.GetSharedEnergyCount() )
			owner.TakeSharedEnergy( energyDamage )
			entity weapon = owner.GetOffhandWeapon( PILOT_SHIELD_OFFHAND_INDEX )
			if ( IsValid( weapon ) && weapon.GetWeaponClassName() == "mp_ability_gibraltar_shield" )
			{
				float delay = weapon.GetWeaponSettingFloat( eWeaponVar.fire_duration )
				weapon.SetScriptTime0( Time() + delay )
				float frac = float( owner.GetSharedEnergyCount() ) / float( owner.GetSharedEnergyTotal() )
				UpdateShieldWallColorFX( ent, frac )
			}
		}

		int newHealth = maxint( 1, ent.GetHealth() - int( damage ) )
		ent.SetHealth( newHealth )

		if ( IsValid( owner ) )
		{
			if ( owner.GetSharedEnergyCount() <= 0 )
			{
				int attachmentIndex = owner.LookupAttachment( "L_FOREARM_SHIELD" )
				if ( attachmentIndex > 0 )
				{
					vector attachmentOrigin = owner.GetAttachmentOrigin( attachmentIndex )
					vector attachmentAngles = owner.GetAttachmentAngles( attachmentIndex )

					entity foeFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( FX_GUN_SHIELD_BREAK ), attachmentOrigin, attachmentAngles )
					SetTeam( foeFx, owner.GetTeam() )
					foeFx.SetOwner( owner )
					foeFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
					EffectSetControlPointVector( foeFx, 2, ENEMY_COLOR_FX )
					thread DestroyAfterDelay( foeFx, 3.0 );

					entity friendlyFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( FX_GUN_SHIELD_BREAK ), attachmentOrigin, attachmentAngles )
					SetTeam( friendlyFx, owner.GetTeam() )
					friendlyFx.SetOwner( owner )
					friendlyFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
					EffectSetControlPointVector( friendlyFx, 2, FRIENDLY_COLOR_FX )
					thread DestroyAfterDelay( friendlyFx, 3.0 );

					vector fwd = owner.GetViewVector()
					entity ownFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( FX_GUN_SHIELD_BREAK_FP ), owner.CameraPosition() + fwd * 50, owner.CameraAngles() )
					SetTeam( ownFx, owner.GetTeam() )
					ownFx.SetOwner( owner )
					ownFx.SetParent( owner )
					ownFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER | ENTITY_VISIBLE_ONLY_PARENT_PLAYER
					EffectSetControlPointVector( ownFx, 2, FRIENDLY_COLOR_FX )
					ownFx.RenderWithViewModels( true )
					SetForceDrawWhileParented( ownFx, true )
					thread DestroyAfterDelay( ownFx, 3.0 );

					EmitSoundOnEntityExceptToPlayer( owner, owner, SOUND_PILOT_GUN_SHIELD_BREAK_3P )
					EmitSoundOnEntityOnlyToPlayer( owner, owner, SOUND_PILOT_GUN_SHIELD_BREAK_1P )
				}

				PassiveConsumed( owner, ePassives.PAS_ADS_SHIELD )

				ent.Signal( "GibraltarShieldDeactivate" )

				if ( carryoverDamage > 0 && IsValid( inflictor ) )
				{
				//	owner.TakeDamage( carryoverDamage, attacker, inflictor, { origin = damageOrigin, damageSourceId = damageSourceId, scriptType = DF_OVERFLOW } )
				}
			}
		}
	}
}

GunShieldSettings function GibraltarShield_GetGunShieldSettings( entity player, entity weapon )
{
	vector dir		= player.EyeAngles()
	vector forward	= AnglesToForward( dir )

	GunShieldSettings gs
	gs.invulnerable			= false
	gs.maxHealth			= float( player.GetSharedEnergyTotal() )
	gs.spawnflags			= SF_ABSORB_BULLETS
	gs.bulletFOV			= PLAYER_GUN_SHIELD_WALL_FOV
	gs.sphereRadius			= PLAYER_GUN_SHIELD_WALL_RADIUS
	gs.sphereHeight			= PLAYER_GUN_SHIELD_WALL_HEIGHT
	gs.ownerWeapon			= weapon
	gs.owner				= player
	gs.shieldFX				= FX_GUN_SHIELD_WALL
	gs.parentEnt			= player
	gs.parentAttachment		= "L_FOREARM_SHIELD"
	gs.gunVortexAttachment	= "L_HAND"
	gs.localVortexAngles	= AnglesCompose( forward, < 0, -25, 0> )
	gs.useFriendlyEnemyFx	= true
	gs.model				= FX_GUN_SHIELD_SHIELD_COL
	gs.modelHide			= true
	gs.modelOverrideAngles	= SHIELD_ANGLE_OFFSET

	return gs
}

entity function GibraltarShield_CreateShieldEnt( entity player, entity weapon )
{
	GunShieldSettings gs = GibraltarShield_GetGunShieldSettings( player, weapon )
	gs.shieldFX = $""

	entity shieldEnt = CreateGunAttachedShield_PropDynamic( gs )

	// dklein: Defensive fix for R5DEV-198772
	if ( !IsValid( shieldEnt ) )
		return null

	shieldEnt.SetBlocksLOS( false )
	shieldEnt.EnableAttackableByAI( AI_PRIORITY_NO_THREAT, 0, AI_AP_FLAG_NONE )
	shieldEnt.SetScriptName( GIBRALTAR_GUN_SHIELD_NAME )
	//shieldEnt.SetCollisionAllowed( false )
	shieldEnt.SetTakeDamageType( DAMAGE_NO )

	AddEntityCallback_OnPostDamaged( shieldEnt, GibraltarShield_OnDamaged )

	return shieldEnt
}

void function GibraltarShield_DestroyShieldEnt( entity weapon )
{
	entity shieldEnt = weapon.GetWeaponUtilityEntity()
	if ( IsValid( shieldEnt ) )
	{
		shieldEnt.Destroy()
	}
}

void function GibraltarShield_UpdateShieldHealth( entity player, entity shieldEnt )
{
	shieldEnt.SetHealth( player.GetSharedEnergyCount() )
	float frac = float( player.GetSharedEnergyCount() ) / float( player.GetSharedEnergyTotal() )
	UpdateShieldWallColorFX( shieldEnt, frac )
}

void function UpdateShieldWallColorFX( entity ent, float frac )
{
	UpdateShieldWallFX( ent, GraphCapped( frac, 0.0, 1.0, 0.3, 1.0 ) )

	if ( ent.e.fxControlPoints.len() >= 2 )
	{
		EffectSetControlPointVector( ent.e.fxControlPoints[0], 2, GetFriendlyEnemyTriLerpColor( frac, true ) )
		EffectSetControlPointVector( ent.e.fxControlPoints[1], 2, GetFriendlyEnemyTriLerpColor( frac, false ) )
	}
}

vector function GetFriendlyEnemyTriLerpColor( float frac, bool isFriendly )
{
	vector color3

	if ( isFriendly )
	{
		color3 = TEAM_COLOR_FRIENDLY
	}
	else
	{
		color3 = TEAM_COLOR_ENEMY
	}

	return GetTriLerpColor( frac, <255, 255, 255>, LerpVector( color3, <255, 255, 255>, 0.5 ), color3, 0.55, 0.10 )
}
#endif // #if SERVER
