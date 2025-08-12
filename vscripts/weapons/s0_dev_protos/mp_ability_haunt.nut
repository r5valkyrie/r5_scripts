global function Haunt_Init

//global function OnWeaponPrimaryAttack_Haunt
//global function OnWeaponActivate_Haunt
//global function OnWeaponDeactivate_Haunt

global function OnWeaponAttemptOffhandSwitch_Haunt
global function OnWeaponTossPrep_Haunt
global function OnWeaponTossReleaseAnimEvent_Haunt

#if SERVER && DEV
global function Haunt
global function DEV_GiveHauntUltimate
#endif

const int HAUNT_DEBUG_LEVEL = 0

#if SERVER
struct {
	table<entity, int> playerHauntCountMap
} file
#endif

void function Haunt_Init()
{
	PrecacheWeapon( "mp_ability_haunt" )
}


bool function OnWeaponAttemptOffhandSwitch_Haunt( entity weapon )
{
	int ammoReq  = weapon.GetAmmoPerShot()
	int currAmmo = weapon.GetWeaponPrimaryClipCount()
	if ( currAmmo < ammoReq )
		return false

	entity player = weapon.GetWeaponOwner()
	if ( player.IsPhaseShifted() )
		return false

	return true
}


void function OnWeaponTossPrep_Haunt( entity weapon, WeaponTossPrepParams prepParams )
{
	weapon.EmitWeaponSound_1p3p( GetGrenadeDeploySound_1p( weapon ), GetGrenadeDeploySound_3p( weapon ) )

	#if SERVER
		entity weaponOwner = weapon.GetWeaponOwner()
		PlayBattleChatterLineToSpeakerAndTeam( weaponOwner, "bc_tactical" )
	#endif
}


var function OnWeaponTossReleaseAnimEvent_Haunt( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	int ammoReq = weapon.GetAmmoPerShot()
	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )

	entity deployable = ThrowDeployable( weapon, attackParams, DEPLOYABLE_THROW_POWER, OnHauntTrapPlantedThread )
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


void function OnHauntTrapPlantedThread( entity projectile )
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

		vector endOrigin     = origin - <0, 0, 32>
		vector surfaceAngles = projectile.proj.savedAngles
		vector oldUpDir      = AnglesToUp( surfaceAngles )

		TraceResults traceResult = TraceLine( origin, endOrigin, [ projectile ], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_BLOCK_WEAPONS_AND_PHYSICS )
		if ( traceResult.fraction < 1.0 )
		{
			vector forward = AnglesToForward( projectile.proj.savedAngles )
			surfaceAngles = AnglesOnSurface( traceResult.surfaceNormal, forward )

			vector newUpDir = AnglesToUp( surfaceAngles )
			if ( DotProduct( newUpDir, oldUpDir ) < 0.55 )
				surfaceAngles = projectile.proj.savedAngles
		}

		entity oldParent = projectile.GetParent()
		projectile.ClearParent()

		origin = projectile.GetOrigin()
		float duration = projectile.GetProjectileWeaponSettingFloat( eWeaponVar.fire_duration )

		projectile.Destroy()

		asset model = $"mdl/props/gibraltar_bubbleshield/gibraltar_bubbleshield.rmdl"
		entity trap = CreatePropDynamic( model, origin, surfaceAngles )
		trap.SetOwner( owner )
		SetTeam( trap, owner.GetTeam() )
		//trap.SetCloakDuration( 2.0, -1, 1.0 )

		// thread TrapDestroyOnRoundEnd( owner, trap )

		if ( IsValid( traceResult.hitEnt ) )
		{
			trap.SetParent( traceResult.hitEnt )
		}
		else if ( IsValid( oldParent ) )
		{
			trap.SetParent( oldParent )
		}

		entity trigger = CreateEntity( "trigger_cylinder" )
		trigger.SetOwner( trap )
		trigger.SetRadius( 160.0 )
		trigger.SetAboveHeight( 128 )
		trigger.SetBelowHeight( 128 )
		trigger.SetOrigin( origin )
		SetTeam( trigger, trap.GetTeam() )
		trigger.kv.triggerFilterNonCharacter = "0"
		trigger.RemoveFromAllRealms()
		trigger.AddToOtherEntitysRealms( trap )
		trigger.SetEnterCallback( OnHauntTrapTriggerEnter )
		trigger.SetOrigin( origin )
		trigger.SetParent( trap, "", true, 0.0 )
		DispatchSpawn( trigger )
		trigger.SearchForNewTouchingEntity()

		OnThreadEnd( void function() : ( trigger ) {
			if ( IsValid( trigger ) )
				trigger.Destroy()
		} )

		EndSignal( trap, "OnDestroy" )
		EndSignal( owner, "OnDestroy" ) // todo(dw)

		WaitForever()
	#endif
}


#if SERVER
void function OnHauntTrapTriggerEnter( entity trigger, entity ent )
{
	if ( trigger.e.isDisabled )
		return

	array<entity> targets
	foreach ( entity touching in trigger.GetTouchingEntities() )
	{
		if ( !touching.IsPlayer() )
			continue
		// if ( touching.GetTeam() == trigger.GetTeam() )
			// continue
		if ( !IsAlive( touching ) )
			continue
		targets.append( touching )
	}
	if ( targets.len() == 0 )
		return

	trigger.e.isDisabled = true

	entity trap = trigger.GetParent()
	thread PROTO_HauntTargetsNearTrapWithChaining( trap, targets )

	trigger.Destroy()
}
#endif


#if SERVER
void function PROTO_HauntTargetsNearTrapWithChaining( entity trap, array<entity> targetsInTrigger )
{
	entity owner = trap.GetOwner()

	EndSignal( trap, "OnDestroy" )
	EndSignal( owner, "OnDestroy" )

	EmitSoundOnEntity( trap, "EMP_Titan_Electrical_Field" )

	table<entity, entity> enemiesToZapSourceSet = {}
	foreach ( entity ent in targetsInTrigger )
		enemiesToZapSourceSet[ent] <- trap

	array<entity> sourcesToProcess = clone targetsInTrigger
	sourcesToProcess.insert( 0, trap )

	const float ZAP_CHAIN_DIST = 250.0
	while ( sourcesToProcess.len() > 0 )
	{
		entity source = sourcesToProcess.remove( 0 )

		foreach( entity enemy in GetPlayerArrayOfEnemies_Alive( trap.GetTeam() ) )
		{
			if ( enemy in enemiesToZapSourceSet )
				continue

			if ( Distance( enemy.GetOrigin(), source.GetOrigin() ) > ZAP_CHAIN_DIST )
				continue

			enemiesToZapSourceSet[enemy] <- source
			sourcesToProcess.append( enemy )
		}
	}

	array<entity> fxEntsToCleanup
	array<entity> enemiesToHaunt

	foreach ( entity enemy, entity source in enemiesToZapSourceSet )
	{
		enemiesToHaunt.append( enemy )
		// fx stuff stolen from DroneRepairFX
		entity cpEnd = CreateEntity( "info_placement_helper" )
		SetTargetName( cpEnd, UniqueString( "arc_cannon_beam_cpEnd" ) )
		cpEnd.SetParent( enemy, "CHESTFOCUS", false, 0.0 )
		DispatchSpawn( cpEnd )
		entity zapBeam = CreateEntity( "info_particle_system" )
		zapBeam.kv.cpoint1 = cpEnd.GetTargetName()
		zapBeam.SetValueForEffectNameKey( ARC_CANNON_BEAM_EFFECT )
		zapBeam.kv.start_active = 0
		zapBeam.SetOwner( trap )
		//zapBeam.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)
		zapBeam.SetParent( source, "ORIGIN", false, 0.0 )
		DispatchSpawn( zapBeam )
		EntFireByHandle( zapBeam, "Start", "", 0, null, null )
		EntFireByHandle( zapBeam, "StopPlayEndCap", "", 2.0, null, null )

		fxEntsToCleanup.append( cpEnd )
		fxEntsToCleanup.append( zapBeam )

		wait 0.08
	}

	thread Haunt( owner, null, enemiesToHaunt )

	wait 2.0

	OnThreadEnd( void function() : (trap, fxEntsToCleanup) {
		foreach ( entity ent in fxEntsToCleanup )
		{
			if ( IsValid( ent ) )
				ent.Destroy()
		}

		if ( IsValid( trap ) )
		{
			StopSoundOnEntity( trap, "EMP_Titan_Electrical_Field" )
			trap.Dissolve( ENTITY_DISSOLVE_NORMAL, <0, 0, 0>, 100 )
		}
	} )
}
#endif



//void function OnWeaponActivate_Haunt( entity weapon )
//{
//	// todo(dw): targetting
//}


//void function OnWeaponDeactivate_Haunt( entity weapon )
//{
//	//
//}

//var function OnWeaponPrimaryAttack_Haunt( entity weapon, WeaponPrimaryAttackParams attackParams )
//{
//	entity owner = weapon.GetWeaponOwner()
//	Assert( owner.IsPlayer() )
//
//	const float HAUNT_MAX_DISTANCE = 300.0
//
//	entity closestEnemy = GetClosest( GetPlayerArrayOfEnemies_Alive( owner.GetTeam() ), owner.EyePosition(), HAUNT_MAX_DISTANCE )
//	if ( !IsValid( closestEnemy ) )
//	{
//		weapon.DoDryfire()
//		return 0
//	}
//
//	#if SERVER
//		thread Haunt( owner, weapon, closestEnemy )
//	#endif
//
//	PlayerUsedOffhand( owner, weapon )
//
//	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
//}


#if SERVER
void function Haunt( entity owner, entity weapon, array<entity> victimList )
{
	EndSignal( owner, "OnDeath" )
	//EndSignal( victim, "OnDeath" )

	if ( IsValid( weapon ) )
	{
		EndSignal( weapon, "OnDestroy" )
		weapon.AddMod( "ultimate_active_no_regen" )
	}

	array<entity> decoyList     = []
	array<entity> fxList        = []
	array<entity> ownerAllyList = GetPlayerArrayOfTeam( owner.GetTeam() )
	//array<entity> victimAllyList = GetPlayerArrayOfTeam( victim.GetTeam() )

	table<var, var> threadState = {}
	threadState.cleanupDone <- false

	void functionref() cleanupTargetBits_FXAndSoundsAndDecoys = void function() : (victimList, decoyList, fxList, threadState) {
		if ( threadState.cleanupDone )
			return
		threadState.cleanupDone <- true

		foreach( entity victim in victimList)
		{
			if ( IsValid( victim ) )
			{
				StopSoundOnEntity( victim, "cloak_sustain_loop_3p_enemy" )
				StopSoundOnEntity( victim, "cloak_sustain_loop_1p" )
			}
		}

		foreach ( entity fx in fxList )
		{
			if ( IsValid( fx ) )
				fx.Destroy()
		}

		foreach ( entity decoy in decoyList )
		{
			if ( IsValid( decoy ) )
				decoy.Decoy_Die()
		}
	}

	OnThreadEnd( void function() : ( weapon, decoyList, ownerAllyList, victimList, cleanupTargetBits_FXAndSoundsAndDecoys ) {
		if ( IsValid( weapon ) )
			weapon.RemoveMod( "ultimate_active_no_regen" )

		foreach ( entity ownerAlly in ownerAllyList )
		{
			if ( IsValid( ownerAlly ) )
			{
				file.playerHauntCountMap[ownerAlly] -= 1
				if ( file.playerHauntCountMap[ownerAlly] == 0 )
					ownerAlly.RemoveFromRealm( eRealms.PROTO_ABILITY_HAUNT )
			}
		}

		foreach ( entity victim in victimList )
		{
			if ( IsValid( victim ) )
			{
				file.playerHauntCountMap[victim] -= 1
				if ( file.playerHauntCountMap[victim] == 0 )
					victim.RemoveFromRealm( eRealms.PROTO_ABILITY_HAUNT )
			}
		}

		cleanupTargetBits_FXAndSoundsAndDecoys()
	} )

	// todo(dw): this will make the players involved see ALL hauntings, even if not victimted at them
	foreach ( entity ownerAlly in ownerAllyList )
	{
		ownerAlly.AddToRealm( eRealms.PROTO_ABILITY_HAUNT )
		if ( !(ownerAlly in file.playerHauntCountMap) )
			file.playerHauntCountMap[ownerAlly] <- 0
		file.playerHauntCountMap[ownerAlly] += 1
	}

	foreach ( entity victim in victimList )
	{
		victim.AddToRealm( eRealms.PROTO_ABILITY_HAUNT )
		if ( !(victim in file.playerHauntCountMap) )
			file.playerHauntCountMap[victim] <- 0
		file.playerHauntCountMap[victim] += 1

		EmitSoundOnEntityExceptToPlayer( victim, victim, "cloak_sustain_loop_3p_enemy" )
		EmitSoundOnEntityOnlyToPlayer( victim, victim, "cloak_sustain_loop_1p" )

		int attachID  = victim.LookupAttachment( "CHESTFOCUS" )
		entity glowFX = StartParticleEffectOnEntity_ReturnEntity( victim, PrecacheParticleSystem( $"interior_Dlight_red_MED" ), FX_PATTACH_POINT_FOLLOW, attachID )
		fxList.append( glowFX )
	}

	//entity holoPilotTrailFXFriendly = StartParticleEffectOnEntity_ReturnEntity( victim, MARK_RECALL_TRAIL_FX_FRIENDLY, FX_PATTACH_POINT_FOLLOW, attachID )
	//SetTeam( holoPilotTrailFXFriendly, owner.GetTeam() )
	//holoPilotTrailFXFriendly.SetOwner( owner )
	//holoPilotTrailFXFriendly.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_OWNER
	//fxList.append( holoPilotTrailFXFriendly )
	//
	//entity holoPilotTrailFXEnemy = StartParticleEffectOnEntity_ReturnEntity( victim, MARK_RECALL_TRAIL_FX_ENEMY, FX_PATTACH_POINT_FOLLOW, attachID )
	//SetTeam( holoPilotTrailFXEnemy, owner.GetTeam() )
	//holoPilotTrailFXEnemy.SetOwner( owner )
	//holoPilotTrailFXEnemy.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
	//fxList.append( holoPilotTrailFXEnemy )

	// todo(dw): a special Mirage decoy that teleports around and taunts you
	//entity tauntDecoy = owner.CreatePlayerDecoy( modelName, skinIdx, camoIdx, 1.0, true )
	//mp_pt_medium_holo_taunt_05
	//mp_pt_medium_holo_taunt_04
	//mp_pt_medium_holo_taunt_03
	//mp_pt_medium_holo_taunt_02
	//mp_pt_medium_holo_taunt_01
	//mp_pt_medium_mirage_taunt
	//diag_mp_mirage_glad_taunt_12_3p
	//
	//tauntDecoy.Highlight_SetCurrentContext( HIGHLIGHT_CONTEXT_ENEMY )
	//int highlightId = tauntDecoy.Highlight_GetState( HIGHLIGHT_CONTEXT_ENEMY )
	//tauntDecoy.Highlight_SetFunctions( HIGHLIGHT_CONTEXT_ENEMY, HIGHLIGHT_FILL_MENU_MODEL_REVEAL, true, HIGHLIGHT_OUTLINE_MENU_MODEL_REVEAL, 1.0, highlightId, false )
	//tauntDecoy.Highlight_SetParam( HIGHLIGHT_CONTEXT_ENEMY, 0, HIGHLIGHT_COLOR_ENEMY )
	//tauntDecoy.Highlight_SetParam( HIGHLIGHT_CONTEXT_ENEMY, 1, <5000, 0, 0> )

	array<vector> previousSpotList = []

	const float HAUNT_DURATION = 22.2
	const int HAUNT_MAX_VICTIM_CAP = 3
	const float HAUNT_DECOY_INTERVAL_MIN_LEAST = 1.2 // fastest the decoys can appear with 1 victim
	const float HAUNT_DECOY_INTERVAL_MIN_MOST = 0.7 // fastest the decoys can appear with 3+ victims
	const float HAUNT_DECOY_INTERVAL_MAX_LEAST = 2.5 // slowest the decoys can appear with 1 victim
	const float HAUNT_DECOY_INTERVAL_MAX_MOST = 1.8 // slowest the decoys can appear with 3+ victims

	float startTime     = Time()
	float nextDecoyTime = startTime
	while ( Time() < startTime + HAUNT_DURATION )
	{
		if ( Time() < nextDecoyTime )
		{
			WaitFrame()
			continue
		}

		ArrayRemoveDead( victimList )
		if ( victimList.len() == 0 )
			return

		float hauntDecoyIntervalMin = GraphCapped( victimList.len(), 1, HAUNT_MAX_VICTIM_CAP, HAUNT_DECOY_INTERVAL_MIN_LEAST, HAUNT_DECOY_INTERVAL_MIN_MOST )
		float hauntDecoyIntervalMax = GraphCapped( victimList.len(), 1, HAUNT_MAX_VICTIM_CAP, HAUNT_DECOY_INTERVAL_MAX_LEAST, HAUNT_DECOY_INTERVAL_MAX_MOST )
		nextDecoyTime = Time() + RandomFloatRange( hauntDecoyIntervalMin, hauntDecoyIntervalMax )

		entity victim = victimList.getrandom() // only check one victim's perspective (otherwise we may never find a spot that they can't all see)

		vector victimOrg         = victim.GetOrigin()
		vector victimEyePos      = victim.EyePosition()
		vector victimEyeAng      = victim.EyeAngles()
		vector victimViewForward = AnglesToForward( <0, victimEyeAng.y, 0> )//victim.GetViewForward()

		//TraceResults victimEyeTrace = TraceLine( victimEyePos, victimEyePos + <0, 0, 120> + 290.0 * victimViewForward )
		//victimOrg = victimEyeTrace.endPos + 2.0 * victim.GetVelocity()

		victimOrg = victimOrg + 290.0 * victimViewForward + 2.0 * victim.GetVelocity() + <0, 0, 32>

		//victimOrg = OriginToGround( victimOrg )

		if ( HAUNT_DEBUG_LEVEL >= 1 ) DebugDrawAxis( victimOrg, victimEyeAng, 5.0, 20, <0, 0, 0> )

		//vector victimFutureOrg   = victimOrg + 5.0 * victim.GetVelocity()
		//victimFutureOrg = OriginToGround( victimFutureOrg )
		//vector victimDir = Normalize( victimPos - owner.GetOrigin() )

		vector ornull decoyPos = null

		//
		// NavMesh_RandomPositions
		//
		//array<vector> candidatePosList = NavMesh_RandomPositions( victimFutureOrg, HULL_HUMAN, 20, 30, 800 )
		//
		//array<vector> preferredPosList
		//array<vector> fallbackPosList
		//
		//foreach ( vector candidatePos in candidatePosList )
		//{
		//	const float EYE_HEIGHT = 60.0
		//	if ( DotProduct( Normalize( candidatePos - victimEyePos ), victimViewForward ) > 0 )
		//	{
		//		TraceResults tr = TraceLine( victimEyePos, candidatePos + <0, 0, EYE_HEIGHT>, victim )
		//		if ( tr.fraction < 0.95 )
		//		{
		//			preferredPosList.append( candidatePos )
		//			DebugDrawAxis( candidatePos, <0, 0, 0>, 5.0, 20, <0, 255, 0> )
		//		}
		//		else
		//		{
		//			DebugDrawAxis( candidatePos, <0, 0, 0>, 5.0, 20, <255, 0, 0> )
		//		}
		//	}
		//	else
		//	{
		//		fallbackPosList.append( candidatePos )
		//		DebugDrawAxis( candidatePos, <0, 0, 0>, 5.0, 20, <255, 255, 0> )
		//	}
		//}
		//vector decoyPos = <0, 0, 0>
		//if ( preferredPosList.len() > 0 )
		//{
		//	decoyPos = preferredPosList[0]
		//}
		//else if ( fallbackPosList.len() > 0 )
		//{
		//	decoyPos = fallbackPosList[0]
		//}


		//
		// random points in wedge clamped to navmesh
		//
		//const float WEDGE_RADIUS_MIN = 500.0
		//const float WEDGE_RADIUS_MAX = 900.0
		//const int MAX_ATTEMPTS = 20
		//for ( int attempts = 0; attempts < MAX_ATTEMPTS; attempts++ )
		//{
		//	float wedgeAngSize = Graph( attempts, 0, MAX_ATTEMPTS - 1, 0, 360 )
		//	float wedgeRadius  = Graph( attempts, 0, MAX_ATTEMPTS - 1, WEDGE_RADIUS_MIN, WEDGE_RADIUS_MAX )
		//	vector randomPos   = GetRandomPointInWedge( victimOrg, wedgeRadius, victimEyeAng, wedgeAngSize )
		//	randomPos = OriginToGround( randomPos + <0, 0, 60> )
		//	vector ornull candidatePosOrNull = NavMesh_ClampPointForHull( randomPos, HULL_HUMAN )
		//
		//	if ( candidatePosOrNull == null )
		//	{
		//		DebugDrawAxis( randomPos, <0, 0, 0>, 5.0, 20, <255, 0, 0> )
		//		continue
		//	}
		//	vector candidatePos = expect vector( candidatePosOrNull )
		//	candidatePos = OriginToGround( candidatePos + <0, 0, 16> )
		//
		//	if ( DotProduct( Normalize( candidatePos - victimEyePos ), victimViewForward ) < 0 )
		//	{
		//		DebugDrawAxis( randomPos, <0, 0, 0>, 5.0, 20, <255, 0, 255> )
		//		decoyPos = candidatePos
		//		break
		//	}
		//	else
		//	{
		//		const float EYE_HEIGHT = 60.0
		//		TraceResults tr = TraceLine( victimEyePos, candidatePos + <0, 0, EYE_HEIGHT>, victim )
		//		if ( tr.fraction < 0.95 )
		//		{
		//			DebugDrawAxis( randomPos, <0, 0, 0>, 5.0, 20, <0, 255, 0> )
		//			decoyPos = candidatePos
		//			break
		//		}
		//		else
		//		{
		//			DebugDrawAxis( randomPos, <0, 0, 0>, 5.0, 20, <255, 255, 0> )
		//		}
		//	}
		//}
		//
		//if ( decoyPos == null )
		//	break
		//expect vector(decoyPos)
		//DebugDrawAxis( decoyPos, <0, 0, 0>, 5.0, 20, <0, 0, 255> )

		//
		// path from victim to random point in wedge, pick a good point along path
		//
		const float WEDGE_ANG_SIZE_MIN = 100.0
		const float WEDGE_ANG_SIZE_MAX = 330//360.0
		const float WEDGE_RADIUS_MIN = 1300.0
		const float WEDGE_RADIUS_MAX = 1900.0
		const float TARGET_ORG_RANDOMNESS_MIN = 0.0
		const float TARGET_ORG_RANDOMNESS_MAX = 180.0
		const float EXCLUSION_RADIUS_MAX = 90.0
		const float EXCLUSION_RADIUS_MIN = 0.0
		const int NO_EXCLUSION_AT_ATTEMPT = 7 // prefer locations in front of the player, even if they've been used before
		const int MAX_ATTEMPTS = 22
		for ( int attempts = 0; attempts < MAX_ATTEMPTS; attempts++ )
		{
			if ( attempts % 5 == 4 )
				WaitFrame()

			float wedgeAngSize        = Graph( attempts, 0, MAX_ATTEMPTS - 1, WEDGE_ANG_SIZE_MIN, WEDGE_ANG_SIZE_MAX )
			float wedgeRadius         = Graph( attempts, 0, MAX_ATTEMPTS - 1, WEDGE_RADIUS_MIN, WEDGE_RADIUS_MAX )
			vector victimRandomOffset = RandomVec( Graph( attempts, 0, MAX_ATTEMPTS - 1, TARGET_ORG_RANDOMNESS_MIN, TARGET_ORG_RANDOMNESS_MAX ) )
			vector randomPos          = GetRandomPointInWedge( victimOrg, wedgeRadius, victimEyeAng, wedgeAngSize )

			NavMesh_FindMeshPath_Result fmpr = NavMesh_FindMeshPath( victimOrg, HULL_HUMAN, randomPos )
			if ( !fmpr.pathFound )
			{
				if ( HAUNT_DEBUG_LEVEL >= 2 ) DebugDrawAxis( randomPos, <0, 0, 0>, 5.0, 20, <255, 0, 0> )
				continue
			}

			vector prevPoint = victimOrg
			for ( int pointIndex = 2; pointIndex < fmpr.points.len(); pointIndex++ )
			{
				vector point = fmpr.points[pointIndex]
				if ( HAUNT_DEBUG_LEVEL >= 2 ) DebugDrawLine( prevPoint, point, 0, 255, 0, true, 16.0 )
				prevPoint = point

				if ( DotProduct( Normalize( point - victimEyePos ), victimViewForward ) < 0 )
				{
					if ( HAUNT_DEBUG_LEVEL >= 2 ) DebugDrawAxis( randomPos, <0, 0, 0>, 5.0, 20, <255, 0, 255> )
					decoyPos = point
					printt( "HAUNT -- ATTEMPTS (FoV): ", attempts )
					break
				}

				const float EYE_HEIGHT = 60.0
				TraceResults tr = TraceLine( victimEyePos, point + <0, 0, EYE_HEIGHT>, victim, TRACE_MASK_BLOCKLOS )
				if ( tr.fraction < 0.95 )
				{
					if ( HAUNT_DEBUG_LEVEL >= 2 ) DebugDrawAxis( randomPos, <0, 0, 0>, 5.0, 20, <0, 255, 0> )
					decoyPos = point
					printt( "HAUNT -- ATTEMPTS (Vis): ", attempts )
					break
				}
				else
				{
					if ( HAUNT_DEBUG_LEVEL >= 2 ) DebugDrawAxis( randomPos, <0, 0, 0>, 5.0, 20, <255, 255, 0> )
				}
			}

			if ( decoyPos != null )
			{
				float exclusionRadius = GraphCapped( attempts, 0, NO_EXCLUSION_AT_ATTEMPT, EXCLUSION_RADIUS_MAX, EXCLUSION_RADIUS_MIN )
				bool exclude          = false
				foreach ( vector previousSpot in previousSpotList )
				{
					if ( Distance( expect vector(decoyPos), previousSpot ) < exclusionRadius )
					{
						exclude = true
						break
					}
				}
				if ( exclude )
				{
					decoyPos = null
					continue
				}

				break
			}
		}

		if ( decoyPos == null )
		{
			WaitFrame()
			continue
		}
		expect vector(decoyPos)
		if ( HAUNT_DEBUG_LEVEL >= 1 ) DebugDrawAxis( decoyPos, <0, 0, 0>, 5.0, 20, <0, 0, 255> )

		previousSpotList.append( decoyPos )

		vector moveToPos = victimOrg

		NavMesh_FindMeshPath_Result fmpr = NavMesh_FindMeshPath( decoyPos, HULL_HUMAN, victimOrg )
		if ( fmpr.pathFound )
		{
			fmpr.points.append( moveToPos )
			vector prevPoint = decoyPos
			for ( int pointIndex = 0; pointIndex < fmpr.points.len(); pointIndex++ )
			{
				vector point = fmpr.points[pointIndex]
				if ( HAUNT_DEBUG_LEVEL >= 2 ) DebugDrawLine( prevPoint, point, 0, 0, 255, true, 16.0 )
				prevPoint = point

				if ( pointIndex == 0 )
					continue

				const float HULL_SHRINK = 0.11
				const float FLOOR_GAP = 22.0 // step height

				vector boundsMin = GetBoundsMin( HULL_HUMAN )
				vector boundsMax = GetBoundsMax( HULL_HUMAN )
				boundsMin.x *= (1 - HULL_SHRINK)
				boundsMin.y *= (1 - HULL_SHRINK)
				boundsMax.x *= (1 - HULL_SHRINK)
				boundsMax.y *= (1 - HULL_SHRINK)
				boundsMax.z -= FLOOR_GAP
				TraceResults tr = TraceHull( decoyPos + <0, 0, FLOOR_GAP>, point + <0, 0, FLOOR_GAP>, boundsMin, boundsMax )
				if ( tr.fraction > 0.99 )
					moveToPos = point
			}
			//moveToPos = nmfmpr.points[0]
		}

		vector moveToDir = Normalize( moveToPos - decoyPos )
		moveToPos = decoyPos + 5000.0 * moveToDir

		ItemFlavor character = GetUnlockedItemFlavorsForLoadoutSlot( EHI_null, Loadout_CharacterClass() ).getrandom()
		ItemFlavor skin      = GetUnlockedItemFlavorsForLoadoutSlot( ToEHI( owner ), Loadout_CharacterSkin( character ) ).getrandom()

		asset modelName = CharacterSkin_GetBodyModel( skin )
		entity decoy    = owner.CreateTargetedPlayerDecoy( moveToPos + <10, 10, 10>, $"", modelName, 0, 0 )
		//entity decoy    = owner.CreatePlayerDecoy( modelName, skinIdx, camoIdx, 1.0, true )
		// todo(dw): need a way for the decoy not to copy the owner's crouch/sliding/weapon states

		CharacterSkin_Apply( decoy, skin )
		decoy.SetOrigin( decoyPos + <0, 0, 8> )
		decoy.SetAngles( VectorToAngles( moveToDir ) )
		decoy.SetVelocity( moveToDir * Length( decoy.GetVelocity() ) )

		SetupDecoy_Common( owner, decoy )
		decoy.SetMaxHealth( 50 )
		decoy.SetHealth( 50 )
		decoy.EnableAttackableByAI( 50, 0, AI_AP_FLAG_NONE )
		SetObjectCanBeMeleed( decoy, true )
		decoy.SetTimeout( 0.6 * DECOY_DURATION )
		decoy.SetPlayerOneHits( true )
		//decoy.SetFlickerRate( 0.0 )
		//decoy.SetKillOnCollision( true )

		decoy.RemoveFromAllRealms()
		decoy.AddToRealm( eRealms.PROTO_ABILITY_HAUNT )

		//entity decoyTrailFX = StartParticleEffectOnEntity_ReturnEntity( decoy, MARK_RECALL_TRAIL_FX_ENEMY, FX_PATTACH_POINT_FOLLOW, attachID )
		//decoyTrailFX.SetOwner( victim )
		//decoyTrailFX.kv.VisibilityFlags = ENTITY_VISIBLE_EXCLUDE_PARENT_PLAYER
		//decoyTrailFX.RemoveFromAllRealms()
		//decoyTrailFX.AddToRealm( eRealms.PROTO_ABILITY_HAUNT )
		//fxList.append( decoyTrailFX )

		thread HauntDecoyBehaviourThread( decoy, victim, victimList )

		decoyList.append( decoy )

		//wait RandomFloatRange( HAUNT_DECOY_INTERVAL_MIN, HAUNT_DECOY_INTERVAL_MAX )
	}

	wait 1.0

	foreach ( entity victim in victimList )
	{
		EmitSoundOnEntityExceptToPlayer( victim, victim, "Mirage_PsycheOut_Decoy_End_3P" )
		EmitSoundOnEntityOnlyToPlayer( victim, victim, "Mirage_PsycheOut_Decoy_End_1P" )
	}

	cleanupTargetBits_FXAndSoundsAndDecoys()

	while ( decoyList.len() > 0 )
	{
		ArrayRemoveInvalid( decoyList )
		wait 0.2 - 0.001
	}
}
#endif


enum eHauntDecoyBehaviour
{
	TURN_TOWARD,
	//JUMP_AND_STOP,
	_COUNT
}

#if SERVER
void function HauntDecoyBehaviourThread( entity decoy, entity target, array<entity> victimList )
{
	EndSignal( decoy, "OnDestroy" )
	EndSignal( target, "OnDeath" )

	int behaviour = RandomInt( eHauntDecoyBehaviour._COUNT )

	bool hasSeenBefore = false

	float startTime    = Time()
	vector startOrigin = decoy.GetOrigin()
	vector startVel    = decoy.GetVelocity()
	const float HESITATE_DURATION = 0.19 // hestiate the decoys for a short time to avoid the player seeing the flicker
	while ( Time() < startTime + HESITATE_DURATION )
	{
		decoy.SetModelScale( Graph( Time(), startTime, startTime + HESITATE_DURATION, 0.25, 1.0 ) )
		decoy.SetOrigin( startOrigin )
		decoy.SetVelocity( <0, 0, 0> )
		WaitFrame()
	}
	decoy.SetModelScale( 1.0 )
	decoy.SetVelocity( startVel )

	//vector lastPos             = decoy.GetOrigin()
	//float lastTimeWithMovement = Time()
	float prevTime = Time()
	while( true )
	{
		float time = Time()
		float dt   = time - prevTime

		vector pos = decoy.GetOrigin()
		//if ( Length( lastPos - pos ) > 5.0 )
		//{
		//	lastTimeWithMovement = time
		//	lastPos = pos
		//}
		//if ( time > lastTimeWithMovement + 0.2 )
		//{
		//	decoy.Decoy_Die()
		//	break
		//}

		foreach ( entity victim in victimList )
		{
			if ( Distance( pos, victim.GetOrigin() ) < 105.0 )
			{
				decoy.Decoy_Die()
				break
			}
		}

		TraceResults doorCheckResult = TraceLine( decoy.EyePosition(), decoy.EyePosition() + 60.0 * AnglesToForward( decoy.EyeAngles() ), decoy )
		if ( IsValid( doorCheckResult.hitEnt ) && doorCheckResult.hitEnt.GetNetworkedClassName() == "prop_door" )
			doorCheckResult.hitEnt.OpenDoor( decoy )

		TraceResults visibilityResult = TraceLine( decoy.EyePosition(), target.EyePosition(), target )
		bool canSee                   = (visibilityResult.fraction > 0.99)

		switch ( behaviour )
		{
			case eHauntDecoyBehaviour.TURN_TOWARD:
			{
				if ( canSee )
				{
					//decoy.SetVelocity( <0, 0, 0> )
					vector targetDir       = Normalize( target.EyePosition() - decoy.EyePosition() )
					vector targetAng       = VectorToAngles( targetDir )
					//const float TURN_TO_TARGET_FRAC = 0.009
					float turnToTargetFrac = RandomFloatRange( 0.007, 0.024 )
					vector goalAngles      = AnglesLerp( decoy.GetAngles(), targetAng, turnToTargetFrac * dt )
					decoy.SetAbsAnglesSmooth( <0, goalAngles.y, 0> )
					//wait 0.2 - 0.001
					WaitFrame()
					continue
				}
				break
			}

				//case eHauntDecoyBehaviour.JUMP_AND_STOP:
				//{
				//	if ( canSee )
				//	{
				//		if ( !hasSeenBefore )
				//			decoy.SetJumpDelay( 1.0 )
				//		decoy.SetVelocity( <0, 0, 0> )
				//	}
				//	break
				//}
		}

		if ( canSee )
			hasSeenBefore = true

		prevTime = time
		wait 1.2
	}
}
#endif


#if SERVER && DEV
void function DEV_GiveHauntUltimate( entity player )
{
	player.TakeOffhandWeapon( OFFHAND_ULTIMATE )
	player.GiveOffhandWeapon( "mp_ability_haunt", OFFHAND_ULTIMATE, [] )
}
#endif


// CodeCallback_PlayerDecoyStateChange



vector function GetRandomPointInWedge( vector origin, float radius, vector wedgeForwardAng, float wedgeAngSize )
{
	// Get a single random uniform point within a circle
	float t  = wedgeAngSize * DEG_TO_RAD * (RandomFloat( 1.0 ) - 0.5)
	float r  = sqrt( RandomFloat( 1.0 ) ) * radius
	float x  = r * cos( t )
	float y  = r * sin( t )
	vector p = RotateVector( <x, y, 0>, wedgeForwardAng ) + origin
	return p
}



