
global function MpAbilityMaelstromJavelin_Init
global function OnWeaponToss_ability_maelstrom_javelin
global function OnWeaponAttemptOffhandSwitch_ability_maelstrom_javelin
global function OnProjectileCollision_ability_maelstrom_javelin

global const string MAELSTROM_JAVELIN_SCRIPTNAME = "maelstrom_javelin"

const asset FX_SMOKESCREEN_MAELSTROM_JAVELIN = $"P_smokescreen_FD"
const asset FX_SMOKEGRENADE_TRAIL = $"P_wpn_dumbfire_burst_trail"
const asset MAELSTROM_JAVELIN_MODEL = $"mdl/props/pathfinder_zipline/pathfinder_zipline.rmdl"
const asset MAELSTROM_JAVELIN_ARC_FX = $"P_wpn_arcTrap"

const float MAELSTROM_JAVELIN_SMOKE_DURATION = 15.0
const float MAELSTROM_JAVELIN_SMOKE_MIN_EXPLODE_DIST_SQR = 512 * 512

const float MAELSTROM_JAVELIN_ARC_BALL_COUNT = 15
const float MAELSTROM_JAVELIN_RISE_HEIGHT = 8.0
const float MAELSTROM_JAVELIN_RISE_DURATION = 6.0
const float MAELSTROM_JAVELIN_ARC_BALL_OFFSET = 48.0
const int	MAELSTROM_JAVELIN_DAMAGE_SHIELD = 10
const int 	MAELSTROM_JAVELIN_DAMAGE_HEALTH = 1
const float MAELSTROM_JAVELIN_DAMAGE_INTERVAL = 1.0
const float MAELSTROM_JAVELIN_ARC_EFFECT_INNER_DIST_SQR = 98.0 * 98.0
const float MAELSTROM_JAVELIN_ARC_EFFECT_OUTER_DIST_SQR = 198.0 * 198.0

const bool MAELSTROM_JAVELIN_SMOKE_EXPLOSIONS = true

void function MpAbilityMaelstromJavelin_Init()
{
	PrecacheModel( MAELSTROM_JAVELIN_MODEL )
	PrecacheParticleSystem( FX_SMOKESCREEN_MAELSTROM_JAVELIN )
	PrecacheParticleSystem( FX_SMOKEGRENADE_TRAIL )
	PrecacheParticleSystem( MAELSTROM_JAVELIN_ARC_FX )

	RegisterSignal( "MaelstromJavelin_TriggerEnter" )

	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.damagedef_bangalore_smoke_explosion, MaelstromJavelin_DamagedTarget )
	#endif //SERVER
}

bool function OnWeaponAttemptOffhandSwitch_ability_maelstrom_javelin( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if SERVER
		thread MaelstromJavelin_TrackAbilityUsage( ownerPlayer, weapon )
	#endif //SERVER

	return true
}

var function OnWeaponToss_ability_maelstrom_javelin( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()

	if ( weapon.HasMod( "second_shot" ) )
	{
		weapon.RemoveMod( "second_shot" )
	}
	else
	{
		weapon.AddMod( "second_shot" )
	}


	return 1
}

void function OnProjectileCollision_ability_maelstrom_javelin( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	entity player = projectile.GetOwner()

	if ( !IsValid( player ) )
		return

	if ( hitEnt == player )
		return

	if ( !EntityShouldStick( projectile, hitEnt ) )
	{
		//printt( "SHOULD NOT STICK TO ENT: " + hitEnt )
		return
	}

	if ( hitEnt.IsProjectile() )
	{
		//printt( "ENT IS PROJECTILE!" )
		return
	}


	if ( !LegalOrigin( pos ) )
	{
		//printt( "ORIGIN IS NOT LEGAL!" )
		return
	}


	#if SERVER
		//if ( IsValid( hitEnt ) && hitEnt.IsWorld() )
		if ( IsValid( hitEnt ) )
		{
			thread MaelstromJavelin_Plant( pos, projectile.GetAngles(), normal, hitEnt, player )
		}

		projectile.Destroy()
	#endif
}

#if SERVER
void function MaelstromJavelin_Plant( vector origin, vector angles, vector normal, entity hitEnt, entity owner )
{
	owner.EndSignal( "OnDestroy" )

	vector anglesOnSurface = AnglesOnSurface( normal, AnglesToForward( angles ) )

	entity javelinModel = CreatePropDynamic( MAELSTROM_JAVELIN_MODEL, origin, anglesOnSurface, 0, 4096 )
	SetTeam( javelinModel, owner.GetTeam() )
	javelinModel.SetOwner( owner )

	//printt( "CREATING JAVELIN MODEL" )

	vector originOnSurface = origin - ( javelinModel.GetUpVector() * 18 )
	//vector originOnSurface = origin - ( javelinModel.GetUpVector() * 64 )
	javelinModel.SetOrigin( originOnSurface )

	//javelinModel.SetForwardVector( -normal )

	if ( !hitEnt.IsWorld() )
		javelinModel.SetParent( hitEnt, "", true )

	OnThreadEnd(
		function() : ( javelinModel )
		{
			if ( IsValid( javelinModel ) )
				javelinModel.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 500 )
		}
	)

	if ( hitEnt.GetClassName() == "prop_door" )
	{
		vector originToDoor = Normalize( hitEnt.GetCenter() - origin )

		float doorDot = DotProduct( -normal, originToDoor )

		if ( doorDot > 0 )
			hitEnt.OpenDoor( javelinModel )

	}

	waitthread MaelstromJavelin_CreateArcBalls( owner, javelinModel )

}

void function MaelstromJavelin_CreateArcBalls( entity owner, entity javelinModel )
{
	vector up = javelinModel.GetUpVector()
	vector forward = javelinModel.GetForwardVector()
	owner.EndSignal( "OnDestroy" )
	javelinModel.EndSignal( "OnDestroy" )

	//Create mover around which all arc balls will rotate.
	entity mover = CreateScriptMover( javelinModel.GetOrigin() )
	mover.SetForwardVectorWithUp( forward, up )
	//SetTeam( mover, owner.GetTeam() )
	mover.SetParent( javelinModel, "", false )
	mover.EndSignal( "OnDestroy" )

	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetOwner( javelinModel )
	trigger.SetRadius( 198.0 )
	trigger.SetAboveHeight( 198 )
	trigger.SetBelowHeight( 198 )
	trigger.SetOrigin( javelinModel.GetOrigin() )
	trigger.SetAngles( javelinModel.GetAngles() )
	SetTeam( trigger, javelinModel.GetTeam() )
	trigger.kv.triggerFilterNonCharacter = "0"
	trigger.RemoveFromAllRealms()
	trigger.AddToOtherEntitysRealms( javelinModel )
	DispatchSpawn( trigger )

	trigger.SetEnterCallback( MaelstromJavelin_OnTriggerEnter )

	trigger.SetOrigin( javelinModel.GetOrigin() )
	trigger.SetAngles( javelinModel.GetAngles() )

	trigger.SetParent( javelinModel, "", true, 0.0 )

	OnThreadEnd(
		function() : ( mover, trigger )
		{
			if ( IsValid( mover ) )
			{
				// DestroyBallLightningOnEnt( mover )
				mover.Destroy()
			}

			if ( IsValid( trigger ) )
			{
				trigger.Destroy()
			}
		}
	)

	mover.NonPhysicsSetRotateModeLocal( true )
	mover.NonPhysicsRotate( <0,0,1>, 180.0 )
	//mover.NonPhysicsRotate( up, 180.0 )

	for ( int i = 1; i <= MAELSTROM_JAVELIN_ARC_BALL_COUNT; i++ )
	{
		wait 0.25
		thread MaelstromJavelin_CreateArcBall( owner, javelinModel, mover, i )
	}

	//TO DO: MAKE REAL VARS FOR THIS
	wait MAELSTROM_JAVELIN_RISE_DURATION

}

void function MaelstromJavelin_OnTriggerEnter( entity trigger, entity player )
{
	if ( !player.IsPlayer() )
		return

	thread MaelstromJavelin_TriggerUpdate( trigger, player )
}

void function MaelstromJavelin_TriggerUpdate( entity trigger, entity player )
{
	trigger.Signal( "MaelstromJavelin_TriggerEnter" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	trigger.EndSignal( "OnDestroy" )
	trigger.EndSignal( "MaelstromJavelin_TriggerEnter" )

	entity javelinModel = trigger.GetOwner()

	if ( !IsValid( javelinModel ) )
		return

	entity owner = javelinModel.GetOwner()
	entity damageOwner = IsValid( owner ) ? owner : svGlobal.worldspawn

	if ( !player.IsPlayer() )
		return

	//Apply emp status effect to player
	table<int, int> statusEffectHandles
	statusEffectHandles[eStatusEffect.emp] <- -1

	OnThreadEnd(
		function() : ( player, statusEffectHandles )
		{
			if ( IsValid( player ) )
			{
				if ( statusEffectHandles[eStatusEffect.emp] != -1 )
					StatusEffect_Stop( player, statusEffectHandles[eStatusEffect.emp] )
			}
		}
	)

	while ( trigger.IsTouching( player ) )
	{

		//Clear Status Effect
		if ( statusEffectHandles[eStatusEffect.emp] != -1 )
		{
			StatusEffect_Stop( player, statusEffectHandles[eStatusEffect.emp] )
			statusEffectHandles[eStatusEffect.emp] = -1
		}

		if ( MaelstromJavelin_CanDamagePlayer( player, javelinModel ) )
		{
			int team = javelinModel.GetTeam()
			if ( player.GetTeam() != team || player == owner )
			{
				if ( player.GetShieldHealth() )
				{
					int shieldHealth = player.GetShieldHealth()
					int shieldDamage = minint( MAELSTROM_JAVELIN_DAMAGE_SHIELD, shieldHealth )
					player.TakeDamage( shieldDamage, damageOwner, damageOwner, { damageSourceId = eDamageSourceId.mp_ability_maelstrom_javelin } )
				}
				else
				{
					player.TakeDamage( MAELSTROM_JAVELIN_DAMAGE_HEALTH, damageOwner, damageOwner, { damageSourceId = eDamageSourceId.mp_ability_maelstrom_javelin } )
				}
			}

			float distSqr = DistanceSqr( player.EyePosition(), trigger.GetOrigin() )
			float effectScalar = GraphCapped( distSqr, MAELSTROM_JAVELIN_ARC_EFFECT_OUTER_DIST_SQR, MAELSTROM_JAVELIN_ARC_EFFECT_INNER_DIST_SQR, 0.5, 1.0 )
			statusEffectHandles[eStatusEffect.emp] = StatusEffect_AddEndless( player, eStatusEffect.emp, effectScalar )
		}

		wait MAELSTROM_JAVELIN_DAMAGE_INTERVAL
	}
}

bool function MaelstromJavelin_CanDamagePlayer( entity player, entity javelinModel )
{
	vector origin = javelinModel.GetWorldSpaceCenter()
	vector eyePos = player.EyePosition()
	vector bodyPos = player.GetWorldSpaceCenter()
	vector footPos = player.GetOrigin()

	TraceResults eyeResults = TraceLineHighDetail( origin, eyePos, [ player, javelinModel ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
	TraceResults bodyResults = TraceLineHighDetail( origin, bodyPos, [ player, javelinModel ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
	TraceResults footResults = TraceLineHighDetail( origin, footPos, [ player, javelinModel ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )

	/*
	DebugDrawLine( origin, eyeResults.endPos, 0, 255, 0, true, 1.0 )
	DebugDrawLine( eyeResults.endPos, eyePos, 255, 0, 0, true, 1.0 )
	DebugDrawLine( origin, bodyResults.endPos, 0, 255, 0, true, 1.0 )
	DebugDrawLine( bodyResults.endPos, bodyPos, 255, 0, 0, true, 1.0 )
	DebugDrawLine( origin, footResults.endPos, 0, 255, 0, true, 1.0 )
	DebugDrawLine( footResults.endPos, footPos, 255, 0, 0, true, 1.0 )
	*/

	if ( eyeResults.fraction == 1.0 || bodyResults.fraction == 1.0 || footResults.fraction == 1.0 )
		return true

	return false
}

void function MaelstromJavelin_CreateArcBall( entity owner, entity javelinModel, entity baseMover, int index )
{
	vector up = javelinModel.GetUpVector()
	vector forward = javelinModel.GetForwardVector()
	owner.EndSignal( "OnDestroy" )
	javelinModel.EndSignal( "OnDestroy" )
	baseMover.EndSignal( "OnDestroy" )

	//Create mover
	entity mover = CreateScriptMover( javelinModel.GetOrigin() + up * ( MAELSTROM_JAVELIN_RISE_HEIGHT * index ) + ( forward * MAELSTROM_JAVELIN_ARC_BALL_OFFSET ) )
	SetTeam( mover, owner.GetTeam() )
	mover.SetParent( baseMover, "", true )
	mover.EndSignal( "OnDestroy" )

	int fxId  = GetParticleSystemIndex( MAELSTROM_JAVELIN_ARC_FX )
	entity fx = StartParticleEffectOnEntity_ReturnEntity( mover, fxId, FX_PATTACH_ABSORIGIN_FOLLOW, -1 )

	OnThreadEnd(
		function() : ( mover, fx )
		{
			if ( IsValid( mover ) )
			{
				// DestroyBallLightningOnEnt( mover )
				mover.Destroy()
			}
			if ( IsValid( fx ) )
				EffectStop( fx )
		}
	)

	EmitSoundOnEntity( javelinModel, "Wpn_ArcTrap_Activate" )

	wait MAELSTROM_JAVELIN_RISE_DURATION
}

void function MaelstromJavelin_TrackAbilityUsage( entity player, entity weapon )
{
	Assert( IsNewThread(), "Must be threaded off." )

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	weapon.EndSignal( "OnDestroy" )

	array mods = player.GetExtraWeaponMods()
	mods.append( "ult_active" )
	player.SetExtraWeaponMods( mods )
	//printt( "ADDING MODS" )

	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{
				array mods = player.GetExtraWeaponMods()
				mods.fastremovebyvalue( "ult_active" )
				player.SetExtraWeaponMods( mods )
				//printt( "REMOVING MODS" )

				entity altWeapon = player.GetActiveWeapon( eActiveInventorySlot.altHand )
				if ( IsValid( altWeapon ) )
					altWeapon.ForceChargeEndNoAttack()

				entity mainWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
				if ( IsValid( mainWeapon ) )
					mainWeapon.ForceChargeEndNoAttack()

			}
		}
	)

	//Hack: Wait for weapon swap to take place.
	wait 1.0

	while ( true )
	{
		entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )

		//if ( IsValid( activeWeapon ) )
		//	printt( activeWeapon.GetWeaponClassName() )

		if ( activeWeapon != weapon )
			return

		WaitFrame()
	}
}

void function MaelstromJavelin_DamagedTarget( entity victim, var damageInfo )
{
	//if the attacker is a valid friendly set damage do zero.
	//Note: We need the FF so we can trigger the shellshock effect.
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( IsValid( attacker ) )
	{
		if ( IsFriendlyTeam( attacker.GetTeam(), victim.GetTeam() ) && (attacker != victim) )
			DamageInfo_ScaleDamage( damageInfo, 0 )
	}
}

#endif //SERVER