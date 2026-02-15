
global function MpAbilityRiotShield_Init

global function OnWeaponActivate_ability_riot_shield
global function OnWeaponDeactivate_ability_riot_shield
global function OnWeaponAttemptOffhandSwitch_ability_riot_shield
global function OnWeaponPrimaryAttack_ability_riot_shield
global function OnWeaponChargeBegin_ability_riot_shield
global function OnWeaponChargeEnd_ability_riot_shield
global function OnWeaponOwnerChanged_ability_riot_shield

global function RiotShield_RegisterNetworkFunctions

const vector RIOT_SHIELD_ANGLE_OFFSET = <90,-90,0>
const asset RIOT_SHIELD_WALL_FP_FX = $"P_gun_shield_gibraltar_FP"
const asset RIOT_SHIELD_WALL_FX = $"P_gun_shield_gibraltar_3P"
const asset RIOT_SHIELD_BREAK_FX = $"P_gun_shield_gibraltar_break_3P"
const asset RIOT_SHIELD_COL_FX = $"mdl/fx/jericho_gun_shield.rmdl"

const string RIOT_SHIELD_3P_SOUND = "Gibraltar_GunShield_Sustain_3P"
const string RIOT_SHIELD_1P_SOUND = "Gibraltar_GunShield_Sustain_1P"
const string RIOT_SHIELD_BREAK_1P_SOUND = "Gibraltar_GunShield_Destroyed_1P"
const string RIOT_SHIELD_BREAK_3P_SOUND = "Gibraltar_GunShield_Destroyed_3P"

const bool RIOT_SHIELD_DRAIN_AMMO = false
const float RIOT_SHIELD_DRAIN_AMMO_RATE = 1.0

const RIOT_SHIELD_REGEN_WAIT_TIME = 10.0
const RIOT_SHIELD_RADIUS = 18
const RIOT_SHIELD_HEIGHT = 32
const RIOT_SHIELD_FOV = 85

const int RIOT_SHIELD_OFFHAND_INDEX = OFFHAND_ANTIRODEO

void function MpAbilityRiotShield_Init()
{
	PrecacheModel( RIOT_SHIELD_COL_FX )

	PrecacheParticleSystem( RIOT_SHIELD_WALL_FP_FX )
	PrecacheParticleSystem( RIOT_SHIELD_WALL_FX )
	PrecacheParticleSystem( RIOT_SHIELD_BREAK_FX )

	#if SERVER
	AddDamageCallback( "player", RiotShield_OnPlayerDamaged )
	#endif

	RegisterSignal( "ShieldWeaponThink" )
	RegisterSignal( "DestroyPlayerShield" )
	RegisterSignal( "GunShieldDeactivate" )

}

bool function OnWeaponChargeBegin_ability_riot_shield( entity weapon )
{

	//printt( "RIOT SHIELD CHARGE BEGIN" )

	entity player = weapon.GetWeaponOwner()
	if ( player.IsPlayer() )
	{
		#if SERVER
			RiotShield_CreateShield( player, weapon )
			PlayerUsedOffhand( player, weapon )
		#elseif CLIENT
			TrackFirstPersonGunShield( weapon, RIOT_SHIELD_WALL_FP_FX, "muzzle_flash" )
		#endif

	}
	return true
}

void function RiotShield_RegisterNetworkFunctions()
{

}

void function OnWeaponOwnerChanged_ability_riot_shield( entity weapon, WeaponOwnerChangedParams changeParams )
{

}

void function OnWeaponChargeEnd_ability_riot_shield( entity weapon )
{
	weapon.Signal( "OnChargeEnd" )
}

void function OnWeaponActivate_ability_riot_shield( entity weapon )
{
	//printt( "RIOT SHIELD ACTIVATE" )
}

void function OnWeaponDeactivate_ability_riot_shield( entity weapon )
{
	//printt( "RIOT SHIELD DEACTIVATE" )
	weapon.Signal( "GunShieldDeactivate" )
}

bool function OnWeaponAttemptOffhandSwitch_ability_riot_shield( entity weapon )
{
	//printt( "RIOT SHIELD ATTEMPTING OFFHAND SWITCH" )
	entity player = weapon.GetWeaponOwner()

	if ( !IsValid( player ) )
		return false

	if ( !player.IsPlayer() )
		return false

	entity mainWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( !RiotShield_WeaponAllowsShield( mainWeapon ) )
		return false

	//printt( "RIOT SHIELD OFFHAND SWITCH SUCESSFUL" )

	return true
}

var function OnWeaponPrimaryAttack_ability_riot_shield( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return 0
}

#if SERVER
void function RiotShield_CreateShield( entity player, entity weapon )
{
	thread RiotShield_WeaponThink( player, weapon )
}


// This is pretty hacky since it's polling every frame
void function RiotShield_WeaponThink( entity player, entity vortexWeapon )
{
	vortexWeapon.EndSignal( "OnDestroy" )
	vortexWeapon.EndSignal( "OnChargeEnd" )

	while ( true )
	{
		entity vortexSphere = vortexWeapon.GetWeaponUtilityEntity()

		vortexWeapon.w.savedShieldHealth = 100//player.GetSharedEnergyCount()

		if ( !IsValid( vortexSphere ) )
		{
			thread RiotShield_ShieldThread( player, vortexWeapon )
		}

		WaitFrame()
	}
}

void function RiotShield_ShieldThread( entity player, entity weapon )
{
	player.EndSignal( "OnDeath" )
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( "OnChargeEnd" )

	entity vortexSphere = CreatePlayerShield( player, weapon )
	vortexSphere.SetHealth( 100 )
	vortexSphere.EndSignal( "OnDestroy" )
	weapon.SetWeaponUtilityEntity( vortexSphere )
	UpdateShieldWallFX( vortexSphere, 1.0 )
	//UpdateShieldWallFX( vortexSphere, float( player.GetSharedEnergyCount() ) / float( player.GetSharedEnergyTotal() ) )

	EmitSoundOnEntityExceptToPlayer( player, player, RIOT_SHIELD_3P_SOUND )
	EmitSoundOnEntityOnlyToPlayer( player, player, RIOT_SHIELD_1P_SOUND )

	OnThreadEnd(
		function () : ( vortexSphere, weapon, player )
		{
			if ( IsValid( player ) )
			{
				StopSoundOnEntity( player, RIOT_SHIELD_3P_SOUND )
				StopSoundOnEntity( player, RIOT_SHIELD_1P_SOUND )
			}

			if ( IsValid( vortexSphere ) )
			{
				if ( IsValid( vortexSphere.e.shieldWallFX ) )
					EffectStop( vortexSphere.e.shieldWallFX )
				foreach ( fx in vortexSphere.e.fxControlPoints )
					EffectStop( fx )
				vortexSphere.Destroy()
			}
			else
			{

			}

			if ( IsValid( weapon ) && IsValid( player ) )
			{
				weapon.w.savedShieldHealth = player.GetSharedEnergyCount()
			}
			player.TakeSharedEnergy( player.GetSharedEnergyCount() )
			weapon.SetWeaponUtilityEntity( null )
		}
	)

	AddEntityCallback_OnPostDamaged( vortexSphere, RiotShield_OnDamaged )

	WaitForever()
}

void function RiotShield_OnDamaged( entity ent, var damageInfo )
{
	float damage = DamageInfo_GetDamage( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	vector damageOrigin = DamageInfo_GetDamagePosition( damageInfo )
	if ( damage > 0 )
	{
		if ( IsFriendlyTeam( attacker.GetTeam(), ent.GetTeam() ) )
			DamageInfo_SetDamage( damageInfo, 0 )
	}

	damage = DamageInfo_GetDamage( damageInfo )

	if ( damage > 0 )
	{
		if ( IsValid( attacker ) && attacker.IsPlayer() )
			attacker.NotifyDidDamage( ent, 0, damageOrigin, 0, damage, DF_NO_HITBEEP | DAMAGEFLAG_VICTIM_HAS_VORTEX, 0, null, 0 )

		entity player = ent.GetOwner()

		if ( IsValid( player ) )
		{
			vector attackerOrigin = attacker.GetOrigin()
			player.ViewPunch( attackerOrigin, 2, 2, 1 )
		}
	}
}

void function RiotShield_OnPlayerDamaged( entity victim, var damageInfo )
{
	int flags = DamageInfo_GetCustomDamageType( damageInfo )

	//Only procceed with melee damage or explosive damage.
	if ( !(flags & DF_MELEE ) && !( flags & DF_EXPLOSION ) )
		return

	entity activeWeapon = victim.GetActiveWeapon( eActiveInventorySlot.mainHand )

	if ( !IsValid( activeWeapon ) )
		return

	printt( "ACTIVE WEAPON: " + activeWeapon )

	string weaponName = activeWeapon.GetWeaponClassName()

	if ( weaponName != "mp_ability_riot_shield" )
		return

	vector damagePos = DamageInfo_GetDamagePosition( damageInfo )

	vector damageToPlayer = Normalize( damagePos - victim.GetOrigin() )
	vector viewForward = victim.GetViewForward()

	float dot = DotProduct( damageToPlayer, viewForward )

	printt( "DOT: " + dot )

	if ( dot >= 0 )
		DamageInfo_ScaleDamage( damageInfo, 0.0 )

}

entity function CreatePlayerShield( entity player, entity vortexWeapon )
{
	/*
	GunShieldSettings gs
	gs.invulnerable = false
	gs.maxHealth = 100
	gs.spawnflags = SF_ABSORB_BULLETS
	gs.bulletFOV = RIOT_SHIELD_FOV
	gs.sphereRadius = RIOT_SHIELD_RADIUS
	gs.sphereHeight = RIOT_SHIELD_HEIGHT
	gs.ownerWeapon = vortexWeapon
	gs.owner = player
	gs.shieldFX = RIOT_SHIELD_WALL_FX
	gs.parentEnt = player
	gs.parentAttachment = "L_FOREARM_SHIELD"
	gs.gunVortexAttachment = "L_HAND"
	gs.localVortexAngles = AnglesCompose( forward, < 0, -25, 0> )
	gs.bulletHitRules = GunShield_VortexBulletHitRules
	gs.projectileHitRules = GunShield_VortexProjectileHitRules
	gs.useFriendlyEnemyFx = false
	gs.model = RIOT_SHIELD_COL_FX
	gs.modelOverrideAngles = RIOT_SHIELD_ANGLE_OFFSET
	gs.modelHide = false
	gs.modelBlockRadiusDamage = true

	int idx = gs.parentEnt.LookupAttachment( gs.parentAttachment )
	*/

	vector viewAngles = player.EyeAngles()
	vector shieldOffest = player.IsCrouched() ? player.GetOrigin() + <0,0,16> : player.GetOrigin() + <0,0,48>
	entity shield = CreatePropDynamic_NoDispatchSpawn( RIOT_SHIELD_COL_FX, shieldOffest + ( player.GetViewForward() * 32 ), AnglesCompose( viewAngles, < 0, 0, 0> ), 6, 320000 )
	shield.kv.CollisionGroup = TRACE_COLLISION_GROUP_BLOCK_WEAPONS
	shield.SetBlocksRadiusDamage( true )
	shield.RemoveFromAllRealms()
	shield.AddToOtherEntitysRealms( player )

	shield.SetMaxHealth( 100 )
	shield.SetHealth( 100 )
	SetTeam( shield, player.GetTeam() )

	shield.SetTakeDamageType( DAMAGE_EVENTS_ONLY )

	SetVortexSphereBulletHitRules( shield, GunShield_VortexBulletHitRules )
	SetVortexSphereProjectileHitRules( shield, GunShield_VortexProjectileHitRules )

	shield.SetOwner( player )
	shield.SetParent( player, "", true )

	DispatchSpawn( shield )

	vortexWeapon.SetWeaponUtilityEntity( shield )
	shield.e.ownerWeapon = vortexWeapon

	return shield
}

/*
entity function CreatePlayerShield( entity player, entity vortexWeapon )
{
	vector dir = player.EyeAngles()
	vector forward = AnglesToForward( dir )

	GunShieldSettings gs
	gs.invulnerable = false
	gs.maxHealth = 100
	gs.spawnflags = SF_ABSORB_BULLETS
	gs.bulletFOV = RIOT_SHIELD_FOV
	gs.sphereRadius = RIOT_SHIELD_RADIUS
	gs.sphereHeight = RIOT_SHIELD_HEIGHT
	gs.ownerWeapon = vortexWeapon
	gs.owner = player
	gs.shieldFX = RIOT_SHIELD_WALL_FX
	gs.parentEnt = player
	gs.parentAttachment = "L_FOREARM_SHIELD"
	gs.gunVortexAttachment = "L_HAND"
	gs.localVortexAngles = AnglesCompose( forward, < 0, -25, 0> )
	gs.bulletHitRules = GunShield_VortexBulletHitRules
	gs.projectileHitRules = GunShield_VortexProjectileHitRules
	gs.useFriendlyEnemyFx = false
	gs.model = RIOT_SHIELD_COL_FX
	gs.modelOverrideAngles = RIOT_SHIELD_ANGLE_OFFSET
	gs.modelHide = false
	gs.modelBlockRadiusDamage = true

	entity vortexSphere = CreateGunAttachedShield( gs )

	return vortexSphere
}
*/

void function GunShield_VortexBulletHitRules( entity vortexSphere, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( attacker ) )
		return

	ResolveVortexAttackForOwner( vortexSphere, attacker )
}

bool function GunShield_VortexProjectileHitRules( entity vortexSphere, entity attacker, bool takesDamageByDefault )
{
	if ( !IsValid( attacker ) )
		return false
	if ( !IsValid( vortexSphere ) )
		return false

	ResolveVortexAttackForOwner( vortexSphere, attacker )

	return takesDamageByDefault
}

void function ResolveVortexAttackForOwner( entity vortexSphere, entity attacker )
{
	entity vortexOwner = vortexSphere.GetOwner()
	if ( IsValid( vortexOwner ) )
	{
		vector attackerOrigin = attacker.GetOrigin()

		vortexOwner.ViewPunch( attackerOrigin, 1, 1, 3 )
	}
}
#endif

bool function RiotShield_WeaponAllowsShield( entity weapon )
{
	if ( !IsValid( weapon ) )
		return false

	// default allow, need to add k/v to exempt
	//var allowShield = weapon.GetWeaponInfoFileKeyField( "allow_gibraltar_shield" )
	//if ( allowShield != null && allowShield == 0 )
	//	return false

	return true
}