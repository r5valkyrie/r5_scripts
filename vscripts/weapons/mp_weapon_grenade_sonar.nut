global function SonarGrenade_Init

#if CLIENT
global function ClSonarGrenade_Init
#endif

#if SERVER
global function AddSonarStartGrenadeCallback
#endif

global function OnProjectileCollision_weapon_grenade_sonar
global function OnProjectileIgnite_weapon_grenade_sonar

global float SONAR_GRENADE_RADIUS 			= 1250.0 //(mk): max in ServerCallback_SonarPulseFromPosition set to 3000.0 with 8 bits.
global float SONAR_GRENADE_PULSE_DURATION 	= 4.5 //(cafe): total max time is grenade_ignition_time

const asset FLASHEFFECT    = $"wpn_grenade_sonar_impact"

void function SonarGrenade_Init()
{
	PrecacheParticleSystem( $"wpn_grenade_sonar_impact" )
	
	if( Gamemode() == eGamemodes.fs_spieslegends )
	{
		SONAR_GRENADE_RADIUS = 500
		SONAR_GRENADE_PULSE_DURATION = 2.0
	}
}

#if CLIENT
void function ClSonarGrenade_Init()
{
	PrecacheParticleSystem( $"wpn_grenade_sonar_impact" )
	StatusEffect_RegisterEnabledCallback( eStatusEffect.sonar_detected, EntitySonarDetectedEnabled )
	StatusEffect_RegisterDisabledCallback( eStatusEffect.sonar_detected, EntitySonarDetectedDisabled )

	StatusEffect_RegisterEnabledCallback( eStatusEffect.lockon_detected, EntitySonarDetectedEnabled )
	StatusEffect_RegisterDisabledCallback( eStatusEffect.lockon_detected, EntitySonarDetectedDisabled )

	RegisterSignal( "EntitySonarDetectedDisabled" )
}
#endif

void function OnProjectileCollision_weapon_grenade_sonar( entity projectile, vector pos, vector normal, entity hitEnt, int hitbox, bool isCritical )
{
	#if SERVER
	
	if( !IsValid( projectile ) )
		return
	
	table collisionParams =
	{
		pos = pos,
		normal = normal,
		hitEnt = hitEnt,
		hitbox = hitbox
	}
	
	projectile.SetScriptName( "grenadeSonarProjectile" )
	AddToTrackedEnts_Level( projectile )

	bool result = PlantStickyEntity( projectile, collisionParams )
	projectile.SetAngles(projectile.GetAngles() + <90,0,0>)

	if ( IsHumanSized( hitEnt ) )//Don't stick on Pilots/Grunts/Spectres. Causes pulse blade to fall into ground
		return

	if ( !result )
		return

	if ( projectile.GrenadeHasIgnited() )
		return

	projectile.GrenadeIgnite()
	#endif
	
}


void function OnProjectileIgnite_weapon_grenade_sonar( entity projectile )
{
	#if SERVER
		thread SonarGrenadeThink( projectile )
	#endif

	SetObjectCanBeMeleed( projectile, true )

	StartParticleEffectOnEntity( projectile, GetParticleSystemIndex( FLASHEFFECT ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
	projectile.SetDoesExplode( false )
}


#if SERVER
struct
{
	table< entity, array<int> > entitySonarHandles
	table< int, int > teamSonarCount
	array< void functionref( entity, vector, int, entity ) > SonarStartGrenadeCallbacks = []
} file

void function AddSonarStartGrenadeCallback( void functionref( entity, vector, int, entity ) callback )
{
	file.SonarStartGrenadeCallbacks.append( callback )
}

void function SonarGrenadeThink( entity projectile )
{
	projectile.EndSignal( "OnDestroy" )

	entity weaponOwner = projectile.GetOwner()

	int team = projectile.GetTeam()
	vector pulseOrigin = projectile.GetOrigin()
	array<entity> ents = []

	entity trigger = CreateTriggerRadiusMultiple_Deprecated( pulseOrigin, SONAR_GRENADE_RADIUS, ents, TRIG_FLAG_START_DISABLED | TRIG_FLAG_NO_PHASE_SHIFT )
	SetTeam( trigger, team )
	trigger.SetOwner( projectile.GetOwner() )

	entity owner = projectile.GetThrower()
	if ( IsValid( owner ) && owner.IsPlayer() )
	{
		array<entity> offhandWeapons = owner.GetOffhandWeapons()
		foreach ( weapon in offhandWeapons )
		{
			//if ( weapon.GetWeaponClassName() == grenade.GetWeaponClassName() ) // function doesn't exist for grenade entities
			if ( weapon.GetWeaponClassName() == "mp_weapon_grenade_sonar" )
			{
				float duration = weapon.GetWeaponSettingFloat( eWeaponVar.grenade_ignition_time ) + 0.75 // buffer cause these don't line up
				StatusEffect_AddTimed( weapon, eStatusEffect.simple_timer, 1.0, duration, duration )
				break
			}
		}
	}


	OnThreadEnd(
		function() : ( projectile, trigger, team )
		{
			trigger.Destroy()
			if ( IsValid( projectile ) )
				projectile.Destroy()
		}
	)

	AddCallback_ScriptTriggerEnter_Deprecated( trigger, OnSonarTriggerEnter )
	AddCallback_ScriptTriggerLeave_Deprecated( trigger, OnSonarTriggerLeave )

	ScriptTriggerSetEnabled_Deprecated( trigger, true )

	if ( IsValid( weaponOwner ) && weaponOwner.IsPlayer() )
	{
		EmitSoundOnEntityExceptToPlayer( projectile, weaponOwner, "Pilot_PulseBlade_Activated_3P" )
		EmitSoundOnEntityOnlyToPlayer( projectile, weaponOwner, "Pilot_PulseBlade_Activated_1P" )
	}
	else
	{
		EmitSoundOnEntity( projectile, "Pilot_PulseBlade_Activated_3P" )
	}

	float endTime = Time() + SONAR_GRENADE_PULSE_DURATION
	
	while ( IsValid( projectile ) && Time() < endTime )
	{
		pulseOrigin = projectile.GetOrigin()
		trigger.SetOrigin( pulseOrigin )

		array<entity> players = GetPlayerArrayOfTeam( team )

		foreach ( player in players )
			Remote_CallFunction_Replay( player, "ServerCallback_SonarPulseFromPosition", pulseOrigin, SONAR_GRENADE_RADIUS, 1.0, false )//Audit 2-22-2025 (mk): switched to typed.

		wait 1.0
		if ( IsValid( projectile ) )
		{
			if ( IsValid( weaponOwner ) && weaponOwner.IsPlayer() )
			{
				EmitSoundOnEntityExceptToPlayer( projectile, weaponOwner, "Pilot_PulseBlade_Sonar_Pulse_3P" )
				EmitSoundOnEntityOnlyToPlayer( projectile, weaponOwner, "Pilot_PulseBlade_Sonar_Pulse_1P" )
			}
			else
			{
				EmitSoundOnEntity( projectile, "Pilot_PulseBlade_Sonar_Pulse_3P" )
			}
		}
	}
}

void function OnSonarTriggerEnter( entity trigger, entity ent )
{
	if ( !IsEnemyTeam( trigger.GetTeam(), ent.GetTeam() ) )
		return

	if ( ent.e.sonarTriggers.contains( trigger ) )
		return
		
	if ( trigger.e.sonarConeDetections == 0 )
	{
		// play targer acquisition "start" sound here
		EmitSoundOnEntityOnlyToPlayer( trigger.GetOwner(), trigger.GetOwner(), "SonarScan_AcquireTarget_1p" )
	}

	if ( IsHostileSonarTarget( trigger.GetOwner(), ent ) && ent.GetTeam() != TEAM_TICK ) //Hardcoded check, we don't want ticks to show up as hostile but we do want them to be highlighted
		trigger.GetOwner().e.sonarConeDetections++
	
	ent.e.sonarTriggers.append( trigger )
	SonarStart( ent, trigger.GetOrigin(), trigger.GetTeam(), trigger.GetOwner() )
}

void function OnSonarTriggerLeave( entity trigger, entity ent )
{
	int triggerTeam = trigger.GetTeam()
	if ( !IsEnemyTeam( triggerTeam, ent.GetTeam() ) )
		return

	if ( ent.e.sonarTriggers.contains( trigger ) )
	{
		SonarEnd( ent, triggerTeam, trigger.GetOwner() )
		ent.e.sonarTriggers.fastremovebyvalue( trigger )
	}
}
#endif

#if CLIENT


void function EntitySonarDetectedEnabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( ent == GetLocalViewPlayer() )
	{
		// player is already lockon highlighted
		if ( statusEffect == eStatusEffect.sonar_detected && StatusEffect_GetSeverity( ent, eStatusEffect.lockon_detected ) )
			return

		entity viewModelEntity = ent.GetViewModelEntity()
		entity firstPersonProxy = ent.GetFirstPersonProxy()
		entity predictedFirstPersonProxy = ent.GetPredictedFirstPersonProxy()

		vector highlightColor = statusEffect == eStatusEffect.sonar_detected ? HIGHLIGHT_COLOR_ENEMY : <1, 0, 0>

		if ( IsValid( viewModelEntity ) )
			SonarViewModelHighlight( viewModelEntity, highlightColor )

		if ( IsValid( firstPersonProxy ) )
			SonarViewModelHighlight( firstPersonProxy, highlightColor )

		if ( IsValid( predictedFirstPersonProxy ) )
			SonarViewModelHighlight( predictedFirstPersonProxy, highlightColor )

		thread PlayLoopingSonarSound( ent )
	}
	else
	{
		ClInitHighlight( ent )
	}
}

void function EntitySonarDetectedDisabled( entity ent, int statusEffect, bool actuallyChanged )
{
	if ( ent == GetLocalViewPlayer() )
	{
		// player should have lockon highlighted
		if ( statusEffect == eStatusEffect.sonar_detected && StatusEffect_GetSeverity( ent, eStatusEffect.lockon_detected ) )
		{
			return
		}
		else if ( statusEffect == eStatusEffect.lockon_detected && StatusEffect_GetSeverity( ent, eStatusEffect.sonar_detected ) )
		{
			// restore sonar after lockon wears off
			EntitySonarDetectedEnabled( ent, eStatusEffect.sonar_detected, true )
			return
		}

		entity viewModelEntity = ent.GetViewModelEntity()
		entity firstPersonProxy = ent.GetFirstPersonProxy()
		entity predictedFirstPersonProxy = ent.GetPredictedFirstPersonProxy()

		if ( IsValid( viewModelEntity ) )
			SonarViewModelClearHighlight( viewModelEntity )

		if ( IsValid( firstPersonProxy ) )
			SonarViewModelClearHighlight( firstPersonProxy )

		if ( IsValid( predictedFirstPersonProxy ) )
			SonarViewModelClearHighlight( predictedFirstPersonProxy )

		ent.Signal( "EntitySonarDetectedDisabled" )
	}
	else
	{
		ClInitHighlight( ent )
	}
}

void function PlayLoopingSonarSound( entity ent )
{
	EmitSoundOnEntity( ent, "HUD_MP_EnemySonarTag_Activated_1P" )

	ent.EndSignal( "EntitySonarDetectedDisabled" )
	ent.EndSignal( "OnDeath" )

	while( true )
	{
		wait 1.5
		EmitSoundOnEntity( ent, "HUD_MP_EnemySonarTag_Flashed_1P" )
	}

}
#endif