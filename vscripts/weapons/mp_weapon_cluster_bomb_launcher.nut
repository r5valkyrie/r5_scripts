global function MpWeaponClusterBombLauncher_Init
global function OnProjectileCollision_weapon_cluster_bomb_launcher
global function OnWeaponOwnerChanged_weapon_cluster_bomb_launcher

//Models, fx, impact tables
const asset CLUSTER_BOMB_MODEL = $"mdl/weapons_r5/misc_fuse_tactical_grenade/w_fuse_tactical_grenade_projectile.rmdl"
const asset CLUSTER_BOMB_FIRST_EXPLOSION_FX = $"P_grapple_sparks"
const asset CLUSTER_BOMB_SECONDARY_EXPLOSION_FX = $"P_grapple_sparks"
const asset CLUSTER_BOMB_LAUNCHER_IMPACT_FX = $"P_fuse_tac_impact"
const asset CLUSTER_BOMB_LAUNCHER_LIGHT_FX = $"P_fuse_tac_light"
const string CLUSTER_BOMB_INITIAL_IMPACT_TABLE = "exp_fuse_tac_bomb"
const string CLUSTER_BOMB_FIRST_EXPLOSION_IMPACT_TABLE = "exp_fuse_tac_bomb_first_explo"
const string CLUSTER_BOMB_SECONDARY_EXPLOSION_IMPACT_TABLE = "exp_fuse_tac_bomb_secondary_explo"
const string CLUSTER_BOMB_TIMER_SFX = "Fuse_Tactical_Timer_3p"

//Tunables
const vector CLUSTER_BOMB_EXPLOSION_POS_OFFSET = < 0, 0, 5>
const float CLUSTER_BOMB_LAUNCHER_FIRST_EXPLOSION_DELAY = 1.7
const float CLUSTER_BOMB_LAUNCHER_DAMAGE_INFLICTOR_LIFETIME = 20.0
const float CLUSTER_BOMB_SUBSEQUENT_DAMAGE_PERCENTAGE = 0.5
const float CLUSTER_BOMB_EXPLOSION_DURATION = 1.0
const float CLUSTER_BOMB_BURST_ROUGH_DURATION = 2.0
const int CLUSTER_BOMB_MAX_HITS = 6
const float CLUSTER_BOMB_EXPLOSION_RADIUS = 150.0
const float CLUSTER_BOMB_DEFAULT_DAMAGE = 10.0
const string CLUSTER_BOMB_WEAPON = "mp_weapon_cluster_bomb"
const int CLUSTER_BOMB_WEAPON_SLOT = OFFHAND_EQUIPMENT
const float CLUSTER_BOMB_FIRST_LAUNCH_OFFSET = 3.0

const float CLUST_BOMB_FOLLOW_UP_SPEED_BOOST_DURATION = 1.0


//Debug
const bool CLUSTER_BOMB_LAUNCHER_DEBUG = false

struct ClusterBurstData
{
	array<float> yawOffset = [ 0.0 ]
	float zVelMin = 0.0
	float zVelMax = 0.0
	float xyVel = 0.0
	float explodeDelayMin = 0.5
	float explodeDelayMax = 0.5
	float nextSpawnDelayMin = 0.1
	float nextSpawnDelayMax = 0.1
}


struct FollowUpStatusEffectIndexes
{
	int speedBoostID
	int followUpVisualsID
}

const vector UP_VECTOR = < 0, 0, 1 >

struct
{
#if SERVER
	table <entity, table<entity, int> > clusterBombHitTable
	array< entity > activeClusterBombs

		table<entity, FollowUpStatusEffectIndexes> playerStatusEffects

#endif
} file

void function MpWeaponClusterBombLauncher_Init()
{
	PrecacheModel( CLUSTER_BOMB_MODEL )
	PrecacheWeapon( CLUSTER_BOMB_WEAPON )
	PrecacheParticleSystem( CLUSTER_BOMB_LAUNCHER_IMPACT_FX )
	PrecacheParticleSystem( CLUSTER_BOMB_LAUNCHER_LIGHT_FX )
	PrecacheParticleSystem( CLUSTER_BOMB_FIRST_EXPLOSION_FX )
	PrecacheParticleSystem( CLUSTER_BOMB_SECONDARY_EXPLOSION_FX )
	PrecacheImpactEffectTable( CLUSTER_BOMB_INITIAL_IMPACT_TABLE )
	PrecacheImpactEffectTable( CLUSTER_BOMB_FIRST_EXPLOSION_IMPACT_TABLE )
	PrecacheImpactEffectTable( CLUSTER_BOMB_SECONDARY_EXPLOSION_IMPACT_TABLE )

#if SERVER
	AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_cluster_bomb_launcher, ClusterBombDamageCallback )
#endif


}

void function OnWeaponOwnerChanged_weapon_cluster_bomb_launcher( entity weapon, WeaponOwnerChangedParams changeParams )
{
	#if SERVER
		entity oldOwner = changeParams.oldOwner
		if( IsValid( oldOwner ) )
			TakeClusterBombWeapon( oldOwner )
	#endif
}

void function OnProjectileCollision_weapon_cluster_bomb_launcher( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	if ( !IsValid( hitEnt ) )
		return

	if ( IsValid( projectile.GetOwner() ) && hitEnt == projectile.GetOwner() )
		return

	if ( hitEnt.IsPlayer() && IsFriendlyTeam( hitEnt.GetTeam(), projectile.GetTeam() ) )
		return

	//if ( hitEnt.IsPlayerVehicle() && IsFriendlyTeam( hitEnt.GetTeam(), projectile.GetTeam() ) )
		//return

#if SERVER
	//entity zapTrophy = Trophy_GetTrophyInRangeOfEntity( projectile )
	//if ( IsValid( zapTrophy ) && Trophy_RemoteTryZapProjectile( zapTrophy, projectile ) )
		//return
#endif

	DeployableCollisionParams collisionParams
	collisionParams.pos = pos
	collisionParams.normal = ( LengthSqr( normal ) > FLT_EPSILON) ? normal : UP_VECTOR
	collisionParams.hitEnt = hitEnt
	collisionParams.hitBox = hitbox
	collisionParams.isCritical = isCritical
	collisionParams.highDetailTrace = true
	collisionParams.ignoreHullSize = true

	if ( hitEnt.IsPlayer() && StatusEffect_GetTimeRemaining(hitEnt, eStatusEffect.death_totem_recall) > 0.0 )
	{
		projectile.SetVelocity( <0,0,0> )
		projectile.ClearParent()
		projectile.SetPhysics( MOVETYPE_FLYGRAVITY )
	}
	else
	{
		PlantStickyEntity_Retail( projectile, collisionParams, ZERO_VECTOR, false, ( hitEnt.IsPlayer() || hitEnt.IsNPC() ) )
	}

#if SERVER
	if( !file.activeClusterBombs.contains( projectile ) )
		thread DeployClusterBombLauncher( projectile )
#endif //SERVER
}

#if SERVER
void function DeployClusterBombLauncher( entity clusterBombLauncherProxy )
{
	if( !IsValid( clusterBombLauncherProxy ) )
		return
	clusterBombLauncherProxy.EndSignal( "OnDestroy" )

	entity launcherWeapon = clusterBombLauncherProxy.GetWeaponSource()
	if( !IsValid( launcherWeapon ) )
		return
	launcherWeapon.EndSignal( "OnDestroy" )

	entity owner = clusterBombLauncherProxy.GetOwner()
	if( !IsValid( owner ) )
		return
	owner.EndSignal( "OnDestroy" )

	file.activeClusterBombs.append( clusterBombLauncherProxy )
	entity impactEffect = StartParticleEffectOnEntityWithPos_ReturnEntity( clusterBombLauncherProxy, GetParticleSystemIndex( CLUSTER_BOMB_LAUNCHER_IMPACT_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, ZERO_VECTOR, VectorToAngles( <0,0,-1> ) )
	PlayImpactFXTable( clusterBombLauncherProxy.GetOrigin(), owner, CLUSTER_BOMB_INITIAL_IMPACT_TABLE )
	entity lightEffect = StartParticleEffectOnEntityWithPos_ReturnEntity( clusterBombLauncherProxy, GetParticleSystemIndex( CLUSTER_BOMB_LAUNCHER_LIGHT_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, ZERO_VECTOR, VectorToAngles( <0,0,-1> ) )
	EmitSoundOnEntity( clusterBombLauncherProxy, CLUSTER_BOMB_TIMER_SFX )

	OnThreadEnd(
		function() : ( clusterBombLauncherProxy, impactEffect, lightEffect )
		{
			if ( IsValid( impactEffect ) )
				EffectStop( impactEffect )

			if ( IsValid( lightEffect ) )
				EffectStop( lightEffect )

			file.activeClusterBombs.fastremovebyvalue( clusterBombLauncherProxy )
			if ( IsValid( clusterBombLauncherProxy ) )
				clusterBombLauncherProxy.Destroy()
		}
	)

	thread SpawnDangerousAreaForAI( clusterBombLauncherProxy )

	wait CLUSTER_BOMB_LAUNCHER_FIRST_EXPLOSION_DELAY

	StopSoundOnEntity( clusterBombLauncherProxy, CLUSTER_BOMB_TIMER_SFX )
	//TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_KNUCKLE_CLUSTER, owner, clusterBombLauncherProxy.GetOrigin(), owner.GetTeam(), owner )
	// Create an inflictor that survives seprately from the proxy model and weapon for damage tracking purposes
	entity inflictor = CreateClusterBombDamageInflictor( owner )

	ClusterBurstData data
	array< ClusterBurstData > burstDataArray

//%if !HAS_FUSE_EXTENDED_TAC
	data.yawOffset = [ 90.0, 270.0 ]
	data.zVelMin = 300.0
	data.zVelMax = 300.0
	data.xyVel = 200.0
	data.explodeDelayMin = 0.3
	data.explodeDelayMax = 0.3
	data.nextSpawnDelayMax = 0.2
	burstDataArray.append( clone data )

	data.yawOffset = [ 90.0, 270.0 ]
	data.zVelMin = 200.0
	data.zVelMax = 275.0
	data.xyVel = 300.0
	data.explodeDelayMin = 0.5
	data.explodeDelayMax = 0.5
	burstDataArray.append( clone data )

	data.yawOffset = [ 45.0, 135.0, 225.0, 215.0 ]
	data.zVelMin = 50.0
	data.zVelMax = 200.0
	data.xyVel = 300.0
	data.explodeDelayMin = 0.4
	data.explodeDelayMax = 0.4
	data.nextSpawnDelayMax = 0.2
	burstDataArray.append( clone data )
//%endif


	/*
	data.yawOffset = [ 90.0, 270.0 ]
	data.zVelMin = 300.0
	data.zVelMax = 300.0
	data.xyVel = 200.0
	data.explodeDelayMin = 0.3
	data.explodeDelayMax = 0.3
	data.nextSpawnDelayMax = 0.2
	burstDataArray.append( clone data )

	data.yawOffset = [ 90.0, 270.0 ]
	data.zVelMin = 200.0
	data.zVelMax = 275.0
	data.xyVel = 300.0
	data.explodeDelayMin = 0.5
	data.explodeDelayMax = 0.5
	burstDataArray.append( clone data )

	data.yawOffset = [ 45.0, 135.0, 225.0, 215.0 ]
	data.zVelMin = 50.0
	data.zVelMax = 200.0
	data.xyVel = 300.0
	data.explodeDelayMin = 0.4
	data.explodeDelayMax = 0.4
	data.nextSpawnDelayMax = 0.2
	burstDataArray.append( clone data )
	*/

	ClusterBurstData data2
	array< ClusterBurstData > burstDataArray2

	data2.yawOffset = [ 90.0, 270.0 ]
	data2.zVelMin = 300.0
	data2.zVelMax = 300.0
	data2.xyVel = 200.0
	data2.explodeDelayMin = 0.3
	data2.explodeDelayMax = 0.3
	data2.nextSpawnDelayMax = 0.2
	burstDataArray2.append( clone data2 )

	data2.yawOffset = [ 90.0, 270.0 ]
	data2.zVelMin = 200.0
	data2.zVelMax = 275.0
	data2.xyVel = 300.0
	data2.explodeDelayMin = 0.4
	data2.explodeDelayMax = 0.4
	burstDataArray2.append( clone data2 )

	data2.yawOffset = [ 45.0, 135.0, 225.0, 215.0 ]
	data2.zVelMin = 50.0
	data2.zVelMax = 200.0
	data2.xyVel = 300.0
	data2.explodeDelayMin = 0.4
	data2.explodeDelayMax = 0.4
	data2.nextSpawnDelayMax = 0.2
	burstDataArray2.append( clone data2 )


	entity weapon = GiveClusterBombWeapon( owner )
	if( !IsValid( weapon ) )
		return

	vector clusterBombLauncherOrigin = clusterBombLauncherProxy.GetOrigin()
	vector clusterBombLauncherFwd = clusterBombLauncherProxy.GetForwardVector()
	Cluster_Bomb_Explosion( owner, inflictor, clusterBombLauncherOrigin, CLUSTER_BOMB_FIRST_EXPLOSION_FX, CLUSTER_BOMB_FIRST_EXPLOSION_IMPACT_TABLE )
	thread DoClusterBurst( burstDataArray, owner, inflictor, weapon,
		clusterBombLauncherOrigin + clusterBombLauncherFwd * CLUSTER_BOMB_FIRST_LAUNCH_OFFSET, FlattenNormalizeVec( clusterBombLauncherFwd ), 0 )


	wait CLUSTER_BOMB_BURST_ROUGH_DURATION

	thread DoClusterBurst( burstDataArray2, owner, inflictor, weapon,
		clusterBombLauncherOrigin + clusterBombLauncherFwd * CLUSTER_BOMB_FIRST_LAUNCH_OFFSET, FlattenNormalizeVec( clusterBombLauncherFwd ), 0 )

}

entity function CreateClusterBombDamageInflictor( entity owner )
{
	entity inflictor = CreateEntity( "info_target" )
	DispatchSpawn( inflictor )
	inflictor.RemoveFromAllRealms()
	inflictor.AddToOtherEntitysRealms( owner )
	thread ClusterBombDamageInflictorLifeTimeThread( inflictor )
	return inflictor
}

void function ClusterBombDamageInflictorLifeTimeThread( entity inflictor )
{
	inflictor.EndSignal( "OnDestroy" )
	table< entity, int > playerData
	file.clusterBombHitTable[ inflictor ] <- playerData
	wait CLUSTER_BOMB_LAUNCHER_DAMAGE_INFLICTOR_LIFETIME
	delete file.clusterBombHitTable[ inflictor ]
	inflictor.Destroy()
}

void function ClusterBombDamageCallback( entity victim, var damageInfo )
{
	// Seems like we need this since the invulnerability from phase shift has not kicked in at this point yet
	if ( victim.IsPhaseShifted() )
		return


	entity attacker = DamageInfo_GetAttacker( damageInfo )
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if( IsValid( inflictor ) )
	{
		if( victim.IsProjectile() && victim.ProjectileGetWeaponClassName() == CLUSTER_BOMB_WEAPON )
		{
			DamageInfo_ScaleDamage( damageInfo, 0.0 )
		}
		//Blow up doors!
		else if( IsDoor( victim ) )
		{
			DamageInfo_SetDamage( damageInfo, victim.GetHealth() )
		}
		else if( IsValid( victim ) && ( victim.IsPlayer() || victim.IsNPC() ) && inflictor in file.clusterBombHitTable )
		{
			//if( IsValidTacticalDamageStatTarget( attacker, victim ) )
				//StatsHook_ClusterBombHits( attacker )
			float damageScale = 1.0
			if( victim.IsPlayer() )
			{
				ItemFlavor victimCharacter = LoadoutSlot_GetItemFlavor( ToEHI( victim ), Loadout_CharacterClass() )
				damageScale = CharacterClass_GetDamageScale( victimCharacter )
			}
			table< entity, int > playerData = file.clusterBombHitTable[ inflictor ]
			if( victim in playerData )
			{
				playerData[ victim ]++
				if( playerData[ victim ] > CLUSTER_BOMB_MAX_HITS )
				{
					DamageInfo_SetDamage( damageInfo, 1 )
				}
				else
				{
					float damage = floor( CLUSTER_BOMB_DEFAULT_DAMAGE * CLUSTER_BOMB_SUBSEQUENT_DAMAGE_PERCENTAGE * damageScale )
					DamageInfo_SetDamage( damageInfo, damage )
				}
			}
			else
			{
				playerData[ victim ] <- 1
				float damage = floor( CLUSTER_BOMB_DEFAULT_DAMAGE * damageScale )
				DamageInfo_SetDamage( damageInfo, damage )
			}
		}





			if( IsValid( victim ) && ( victim.IsPlayer() || victim.IsNPC() ) && PlayerHasPassive( attacker, ePassives.PAS_TAC_UPGRADE_ONE ) ) // upgrade_fuse_knuckle_cluster_speed_boost
			{
				if( IsValid( attacker ) && victim != attacker && !Bleedout_IsBleedingOut( victim ) )
				{
					/*if( !( attacker in file.playerStatusEffects ) )
					{
						FollowUpStatusEffectIndexes statusEffectIndexes
						statusEffectIndexes.speedBoostID = SE_INVALID_HANDLE
						statusEffectIndexes.followUpVisualsID = SE_INVALID_HANDLE
						file.playerStatusEffects[ attacker ] <- statusEffectIndexes
					}*/

					FollowUp_Start( attacker, CLUST_BOMB_FOLLOW_UP_SPEED_BOOST_DURATION )
				}
			}


	}
}


void function FollowUp_Start( entity player, float duration )
{
	// no need to check both status effect, since he should never have one without the other.

	/*if ( file.playerStatusEffects[player].speedBoostID != SE_INVALID_HANDLE && StatusEffect_GetTimeRemaining_WithHandle( player, file.playerStatusEffects[ player ].speedBoostID ) > 0 )
	{
		StatusEffect_SetDuration( player, file.playerStatusEffects[ player ].followUpVisualsID, duration )
		StatusEffect_SetDuration( player, file.playerStatusEffects[ player ].speedBoostID, duration )
	}
	else*/
	{
		PlayBattleChatterLineToSpeakerWithDebounceTime( "bc_damageEnemyKCBoost", player, player, 4.0, 4.0 )
		file.playerStatusEffects[ player ].followUpVisualsID = StatusEffect_AddTimed( player, eStatusEffect.adrenaline_visuals, 1, duration, duration )
		file.playerStatusEffects[ player ].speedBoostID = StatusEffect_AddTimed( player, eStatusEffect.speed_boost, 0.15, duration, 0.25 )
		thread StatsHook_TrackAdrenalineDistance( player )
	}
}


void function SpawnDangerousAreaForAI( entity clusterBombLauncherProxy )
{
	entity launcherWeapon = clusterBombLauncherProxy.GetWeaponSource()
	launcherWeapon.EndSignal( "OnDestroy" )

	entity owner = clusterBombLauncherProxy.GetOwner()
	owner.EndSignal( "OnDestroy" )

	float aiDangerousAreaLifetime = CLUSTER_BOMB_BURST_ROUGH_DURATION + CLUSTER_BOMB_LAUNCHER_FIRST_EXPLOSION_DELAY

		aiDangerousAreaLifetime += CLUSTER_BOMB_BURST_ROUGH_DURATION


	entity aiDangerTarget = CreateEntity( "info_target" )
	DispatchSpawn( aiDangerTarget )
	aiDangerTarget.SetOrigin( clusterBombLauncherProxy.GetOrigin() )
	SetTeam( aiDangerTarget, owner.GetTeam() )
	AI_CreateDangerousArea_Static( aiDangerTarget, clusterBombLauncherProxy, CLUSTER_BOMB_EXPLOSION_RADIUS * 1.25, TEAM_INVALID, true, true, clusterBombLauncherProxy.GetOrigin() )

	OnThreadEnd(
		function() : ( aiDangerTarget )
		{
			if ( IsValid( aiDangerTarget ) )
				aiDangerTarget.Destroy()
		}
	)

	wait aiDangerousAreaLifetime
}

void function DoClusterBurst( array<ClusterBurstData> burstData, entity owner, entity inflictor, entity weapon, vector origin, vector fwd, int idx )
{
	if ( idx >= burstData.len() )
		return

	ClusterBurstData data = burstData[ idx ]
	foreach ( yaw in data.yawOffset )
	{
		vector vel = VectorRotate( fwd, <0, yaw, 0> )
		vector flatttenedVel = < vel.x, vel.y, 0 >
		vel = flatttenedVel*data.xyVel + <0,0, RandomFloatRange( data.zVelMin, data.zVelMax ) >
		entity projectile = CreateClusterBomb( weapon, origin, vel )
		if( !IsValid( projectile ) )
			return

		projectile.proj.savedVel = flatttenedVel
		projectile.SetDoesExplode( false )
		projectile.SetDamageNotifications( true )

		thread ClusterBombThink( burstData, projectile, owner, inflictor, idx )
		if ( data.nextSpawnDelayMin == data.nextSpawnDelayMax )
			wait data.nextSpawnDelayMin
		else
			wait RandomFloatRange( data.nextSpawnDelayMin, data.nextSpawnDelayMax )
	}
}

void function ClusterBombThink( array<ClusterBurstData> burstData, entity projectile, entity owner, entity inflictor, int idx )
{
	if ( idx >= burstData.len() )
		return

	ClusterBurstData data = burstData[ idx ]

	projectile.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( projectile )
		{
			if ( IsValid( projectile ) )
				projectile.Destroy()
		}
	)

	if ( data.explodeDelayMin > 0 )
	{
		if ( data.explodeDelayMin == data.explodeDelayMax )
			wait data.explodeDelayMin
		else
			wait RandomFloatRange( data.explodeDelayMin, data.explodeDelayMax )
	}

	vector origin = projectile.GetOrigin()
	vector dir = projectile.proj.savedVel
	projectile.StopPhysics()

	/*entity zapTrophy = Trophy_GetTrophyInRangeOfEntity( projectile )
	if ( IsValid( zapTrophy ) && Trophy_RemoteTryZapEntity( zapTrophy, projectile ) )
		return*/

	Cluster_Bomb_Explosion( owner, inflictor, origin + CLUSTER_BOMB_EXPLOSION_POS_OFFSET, CLUSTER_BOMB_SECONDARY_EXPLOSION_FX, CLUSTER_BOMB_SECONDARY_EXPLOSION_IMPACT_TABLE )
	thread DoClusterBurst( burstData, owner, inflictor, projectile.GetWeaponSource(), origin, dir, idx+1 )
}

void function Cluster_Bomb_Explosion( entity player, entity inflictor, vector pos, asset explosionFX, string impactTable )
{
	Explosion(
		pos,
		player,
		inflictor,
		CLUSTER_BOMB_DEFAULT_DAMAGE	,
		CLUSTER_BOMB_DEFAULT_DAMAGE,
		CLUSTER_BOMB_EXPLOSION_RADIUS,
		CLUSTER_BOMB_EXPLOSION_RADIUS,
		SF_ENVEXPLOSION_NOSOUND_FOR_ALLIES,
		pos,
		0,
		damageTypes.explosive,
		eDamageSourceId.mp_weapon_cluster_bomb_launcher,
		impactTable )

	StartParticleEffectInWorld( GetParticleSystemIndex( explosionFX ), pos, ZERO_VECTOR )
}

entity function CreateClusterBomb( entity weapon, vector origin, vector velocity )
{
	if ( !IsValid( weapon ) )
		return null

	WeaponFireGrenadeParams fireGrenadeParams
	fireGrenadeParams.pos                       = origin
	fireGrenadeParams.vel                       = velocity
	fireGrenadeParams.angVel                    = <0, 0, 0>
	fireGrenadeParams.scriptTouchDamageType     = damageTypes.projectileImpact
	fireGrenadeParams.scriptExplosionDamageType = damageTypes.explosive
	fireGrenadeParams.clientPredicted           = false
	fireGrenadeParams.lagCompensated            = true
	fireGrenadeParams.useScriptOnDamage         = true
	return weapon.FireWeaponGrenade( fireGrenadeParams )
}

entity function GiveClusterBombWeapon( entity player )
{
	entity weapon = player.GetOffhandWeapon( CLUSTER_BOMB_WEAPON_SLOT )
	if ( IsValid( weapon ) && weapon.GetWeaponClassName() != CLUSTER_BOMB_WEAPON )
		player.TakeOffhandWeapon( CLUSTER_BOMB_WEAPON_SLOT )

	if ( !IsValid( player.GetOffhandWeapon( CLUSTER_BOMB_WEAPON_SLOT ) ) )
	{
		player.GiveOffhandWeapon( CLUSTER_BOMB_WEAPON, CLUSTER_BOMB_WEAPON_SLOT )
	}

	return player.GetOffhandWeapon( CLUSTER_BOMB_WEAPON_SLOT )
}

void function TakeClusterBombWeapon( entity player )
{
	entity weapon = player.GetOffhandWeapon( CLUSTER_BOMB_WEAPON_SLOT )
	if ( IsValid( weapon ) && weapon.GetWeaponClassName() == CLUSTER_BOMB_WEAPON )
		player.TakeOffhandWeapon( CLUSTER_BOMB_WEAPON_SLOT )
}


#endif //SERVER 