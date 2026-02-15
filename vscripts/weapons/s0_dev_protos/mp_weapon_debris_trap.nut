global function MpWeaponDebrisTrap_Init

global function OnWeaponTossReleaseAnimEvent_weapon_debris_trap
global function OnWeaponAttemptOffhandSwitch_weapon_debris_trap
global function OnWeaponTossPrep_weapon_debris_trap

const float DEBRIS_TRAP_DEPLOY_DELAY = 1.0
const float DEBRIS_TRAP_DURATION_WARNING = 5.0

const bool DEBRIS_TRAP_DAMAGE_ENEMIES = false

const float DEBRIS_TRAP_ANGLE_LIMIT = 0.55

const asset DEBRIS_TRAP_SHIELD_PROJECTILE = $"mdl/props/gibraltar_bubbleshield/gibraltar_bubbleshield.rmdl"

const asset DEBRIS_TRAP_MODEL = $"mdl/props/debris_trap/debris_trap.rmdl"

//TRAP TRIGGER VARS
const float DEBRIS_TRAP_TRIGGER_RADIUS = 48.0
const string DEBRIS_TRAP_DISTURB_SOUND = "Canyonlands_Generic_Emit_Rustle_MetalBarrel"//"Canyonlands_Generic_Emit_Rustle_RazorWire"

//TRAP DAMAGE VARS
const float DEBRIS_TRAP_DAMAGE_INTERVAL = 1.0
const int DEBRIS_TRAP_DAMAGE_NORMAL = 1
const int DEBRIS_TRAP_DAMAGE_BLEEDOUT = 5

//SLOWING EFFECT VARS
const float DEBRIS_TRAP_MOVE_SLOW_SCALAR = 0.5

//PLACEMENT VARS
const int DEBRIS_TRAP_MAX_DEPLOYED = 12

const string DEBRIS_TRAP_SOUND_ENDING = "Gibraltar_BubbleShield_Ending"
const string DEBRIS_TRAP_SOUND_FINISH = "Gibraltar_BubbleShield_Deactivate"

void function MpWeaponDebrisTrap_Init()
{
	PrecacheModel( DEBRIS_TRAP_SHIELD_PROJECTILE )
	PrecacheModel( DEBRIS_TRAP_MODEL )

	#if SERVER
	RegisterSignal( "DebrisTrap_Deploy" )
	#endif
}

bool function OnWeaponAttemptOffhandSwitch_weapon_debris_trap( entity weapon )
{
	int ammoReq = weapon.GetAmmoPerShot()
	int currAmmo = weapon.GetWeaponPrimaryClipCount()
	if ( currAmmo < ammoReq )
		return false

	entity player = weapon.GetWeaponOwner()
	if ( player.IsPhaseShifted() )
		return false

	return true
}

var function OnWeaponTossReleaseAnimEvent_weapon_debris_trap( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	int ammoReq = weapon.GetAmmoPerShot()
	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )

	entity deployable = ThrowDeployable( weapon, attackParams, DEPLOYABLE_THROW_POWER, DebrisTrap_OnPlanted )
	if ( deployable )
	{
		entity player = weapon.GetWeaponOwner()
		PlayerUsedOffhand( player, weapon, true, deployable )

		#if SERVER
		deployable.e.isDoorBlocker = true
		deployable.e.burnmeter_wasPreviouslyDeployed = weapon.e.burnmeter_wasPreviouslyDeployed

		string projectileSound = GetGrenadeProjectileSound( weapon )
		if ( projectileSound != "" )
			EmitSoundOnEntity( deployable, projectileSound )

		weapon.w.lastProjectileFired = deployable
		deployable.e.burnReward = weapon.e.burnReward
		#endif

		#if BATTLECHATTER_ENABLED && SERVER
			TryPlayWeaponBattleChatterLine( player, weapon )
		#endif

	}

	return ammoReq
}

void function OnWeaponTossPrep_weapon_debris_trap( entity weapon, WeaponTossPrepParams prepParams )
{
	weapon.EmitWeaponSound_1p3p( GetGrenadeDeploySound_1p( weapon ), GetGrenadeDeploySound_3p( weapon ) )

	#if SERVER
	entity weaponOwner = weapon.GetWeaponOwner()
	//PlayBattleChatterLineToSpeakerAndTeam( weaponOwner, "bc_tactical" )
	#endif
}

void function DebrisTrap_OnPlanted( entity projectile )
{
	#if SERVER
		Assert( IsValid( projectile ) )

		entity owner = projectile.GetOwner()

		if ( !IsValid( owner ) )
		{
			projectile.Destroy()
			return
		}

		vector origin = projectile.GetOrigin()

		vector endOrigin = origin - <0,0,32>
		vector surfaceAngles = projectile.proj.savedAngles
		vector oldUpDir = AnglesToUp( surfaceAngles )

		TraceResults traceResult = TraceLine( origin, endOrigin, [ projectile ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
		if ( traceResult.fraction < 1.0 )
		{
			vector forward = AnglesToForward( projectile.proj.savedAngles )
			surfaceAngles = AnglesOnSurface( traceResult.surfaceNormal, forward )

			vector newUpDir = AnglesToUp( surfaceAngles )
			if ( DotProduct( newUpDir, oldUpDir ) < DEBRIS_TRAP_ANGLE_LIMIT )
				surfaceAngles = projectile.proj.savedAngles
		}

		entity oldParent = projectile.GetParent()
		projectile.ClearParent()

		origin = projectile.GetOrigin()
		asset model = DEBRIS_TRAP_MODEL
		float duration = projectile.GetProjectileWeaponSettingFloat( eWeaponVar.fire_duration )

		projectile.Destroy()
		projectile = CreatePropScript( model, origin, surfaceAngles, SOLID_VPHYSICS )
		projectile.SetOwner( owner )
		SetTeam( projectile, owner.GetTeam() )
		projectile.SetScriptName( "debris_trap" )
		projectile.e.isDoorBlocker = false //Don't block doors.
		projectile.SetPhysics( MOVETYPE_FLY ) // doesn't actually make it move, but allows pushers to interact with it

		projectile.Highlight_Enable()
		projectile.HighlightEnableForTeam( owner.GetTeam() )
		Highlight_SetFriendlyHighlight( projectile, "friendly_player_decoy" )
		Highlight_SetOwnedHighlight( projectile, "friendly_player_decoy" )

		AddSonarDetectionForPropScript( projectile )

		// thread TrapDestroyOnRoundEnd( owner, projectile )

		if ( IsValid( traceResult.hitEnt ) )
		{
			if ( EntityShouldStick( projectile, traceResult.hitEnt ) && !traceResult.hitEnt.IsWorld() )
				projectile.SetParent( traceResult.hitEnt )
		}
		else if ( IsValid( oldParent ) )
		{
			if ( EntityShouldStick( projectile, oldParent ) && !oldParent.IsWorld() )
				projectile.SetParent( oldParent )
		}

		thread DebrisTrap_Deploy( projectile, duration )

		projectile.SetMaxHealth( 150 )
		projectile.SetHealth( 150 )
		projectile.SetTakeDamageType( DAMAGE_YES )
		SetObjectCanBeMeleed( projectile, true )

		AddEntityCallback_OnDamaged( projectile, DebrisTrap_OnDamaged )

	#endif
}

#if SERVER
void function DebrisTrap_Deploy( entity projectile, float duration )
{
	projectile.EndSignal( "OnDestroy" )

	entity owner = projectile.GetOwner()

	if ( !IsValid( owner ) )
	{
		projectile.Destroy()
		return
	}
	int team = owner.GetTeam()

	/*
	entity wp = CreateWaypoint_Ping_Location( owner, ePingType.ABILITY_DOMESHIELD, projectile, projectile.GetOrigin(), -1, false )
	wp.SetAbsOrigin( projectile.GetOrigin() + <0, 0, 35> )
	wp.SetParent( projectile )
	*/

	entity mover = CreateScriptMover( projectile.GetOrigin(), projectile.GetAngles() )

	entity oldParent = projectile.GetParent()

	if ( IsValid( oldParent ) && !oldParent.IsWorld() )
		mover.SetParent( oldParent )

	projectile.SetParent( mover )

	owner.Signal( "DebrisTrap_Deploy" )
	//owner.EndSignal( "OnDestroy" )
	mover.EndSignal( "OnDestroy" )

	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetOwner( projectile )
	trigger.SetRadius( DEBRIS_TRAP_TRIGGER_RADIUS )
	trigger.SetAboveHeight( 16 )
	trigger.SetBelowHeight( 0 )
	trigger.SetOrigin( projectile.GetOrigin() )
	trigger.SetAngles( projectile.GetAngles() )
	SetTeam( trigger, team )
	trigger.kv.triggerFilterNonCharacter = "0"
	trigger.RemoveFromAllRealms()
	trigger.AddToOtherEntitysRealms( projectile )
	DispatchSpawn( trigger )

	trigger.SetEnterCallback( DebrisTrap_OnTriggerEnter )

	trigger.SetOrigin( projectile.GetOrigin() )
	trigger.SetAngles( projectile.GetAngles() )

	trigger.SetParent( projectile, "", true, 0.0 )

	//Create a threat zone for the passive voices and store the ID so we can clean it up later.
	int threatZoneID = -1 //ThreatDetection_CreateThreatZoneForTrap( owner, projectile.GetOrigin(), team )

	OnThreadEnd(
		function() : ( owner, mover, projectile, trigger, threatZoneID, oldParent )
		{

			//Remove the threat zone for this trap.
			ThreatDetection_DestroyThreatZone( threatZoneID )

			if ( IsValid( owner ) )
			{
				for ( int i=owner.e.activeTraps.len()-1; i>=0 ; i-- )
				{
					if ( owner.e.activeTraps[i] == projectile )
					{
						owner.e.activeTraps.remove( i )
					}
				}
			}

			if ( IsValid( trigger ) )
				trigger.Destroy()

			if ( IsValid( projectile ) )
			{
				//if ( IsValid( oldParent ) )
				//	projectile.SetParent( oldParent )
				//else
				projectile.ClearParent()

				thread DebrisTrap_ProjectileShutdown( projectile )
			}

			if ( IsValid( mover ) )
			{
				mover.Destroy()
			}
		}
	)

	owner.e.activeTraps.insert( 0, projectile )

	while ( owner.e.activeTraps.len() > DEBRIS_TRAP_MAX_DEPLOYED )
	{
		entity entToDelete = owner.e.activeTraps.pop()
		if ( IsValid( entToDelete ) )
		{
			entToDelete.Destroy()
		}
	}

	WaitForever()
}

void function DebrisTrap_OnTriggerEnter( entity trigger, entity player )
{
	if ( !player.IsPlayer() )
		return

	thread DebrisTrap_TriggerUpdate( trigger, player )
}

void function DebrisTrap_TriggerUpdate( entity trigger, entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	trigger.EndSignal( "OnDestroy" )

	entity projectile = trigger.GetOwner()

	if ( !IsValid( projectile ) )
		return

	entity owner = projectile.GetOwner()
	entity damageOwner = IsValid( owner ) ? owner : svGlobal.worldspawn

	if ( !player.IsPlayer() )
		return

	//Slow player while they are in the trigger, if they don't have the "light step" passive.
	if ( !player.HasPassive( ePassives.PAS_LIGHT_STEP ) )
	{
		int statusEffectHandle = StatusEffect_AddEndless( player, eStatusEffect.move_slow, DEBRIS_TRAP_MOVE_SLOW_SCALAR )

		OnThreadEnd(
			function() : ( player, statusEffectHandle )
			{
				if ( IsValid( player ) )
					StatusEffect_Stop( player, statusEffectHandle )
			}
		)
	}

	while ( trigger.IsTouching( player ) )
	{
		//if the player is moving and does not have the "light step" passive
		if ( player.GetVelocity() != <0,0,0> && !player.HasPassive( ePassives.PAS_LIGHT_STEP ) )
		{
			if ( player.GetTeam() != trigger.GetTeam() )
			{
				if ( player.IsSliding() || Bleedout_IsBleedingOut( player ) )
					player.TakeDamage( DEBRIS_TRAP_DAMAGE_BLEEDOUT, damageOwner, damageOwner, { damageSourceId = eDamageSourceId.mp_weapon_debris_trap } )
				else
					player.TakeDamage( DEBRIS_TRAP_DAMAGE_NORMAL, damageOwner, damageOwner, { damageSourceId = eDamageSourceId.mp_weapon_debris_trap } )
			}


			EmitSoundOnEntity( player, DEBRIS_TRAP_DISTURB_SOUND )
		}

		wait DEBRIS_TRAP_DAMAGE_INTERVAL
	}
}

void function DebrisTrap_ProjectileShutdown( entity projectile )
{
	entity mover = CreateScriptMover( projectile.GetOrigin(), projectile.GetAngles() )

	entity oldParent = projectile.GetParent()

	if ( IsValid( oldParent ) )
		mover.SetParent( oldParent )

	projectile.SetParent( mover )

	projectile.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( mover )
		{
			if ( IsValid( mover ) )
				mover.Destroy()
		}
	)

	EmitSoundOnEntity( projectile, DEBRIS_TRAP_SOUND_FINISH )
	//waitthread PlayAnim( projectile, "prop_bubbleshield_shutdown", mover )
	projectile.Dissolve( ENTITY_DISSOLVE_CORE, <0, 0, 0>, 500 )
	WaitSignal( projectile, "OnDestroy" )
}

void function DebrisTrap_OnDamaged( entity projectile, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( projectile ) )
		return

	if ( !IsValid( attacker ) )
		return

	if ( IsWorldSpawn( attacker ) )
		return

	int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )

	//Only explosions and melee can damage this.
	//if ( damageFlags & DF_EXPLOSION )
	//	return
	//if ( damageFlags & DF_MELEE )
	//	return

	//DamageInfo_SetDamage( damageInfo, 0 )

}

#endif