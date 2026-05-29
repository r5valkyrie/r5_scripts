
global function Smokescreen_Init
global function Smokescreen
global function IsOriginTouchingSmokescreen
global function IsRayTouchingSmokescreen
global function GetFXCenterFromSmokescreen
                                    
global function SmokeBlockThreatVision_IsEnabled
      

#if DEVELOPER
const bool SMOKESCREEN_DEBUG = false
#endif

global struct SmokescreenStruct
{
	vector origin
	vector angles
	bool fxUseWeaponOrProjectileAngles = false
	bool fxPointCP1toCenter = false

	float lifetime = 5.0
	int ownerTeam = TEAM_ANY

	asset smokescreenFX = FX_ELECTRIC_SMOKESCREEN
	float fxXYRadius = 230.0 // single fx xy radius used to create nospawn area and block traces
	float fxZRadius = 170.0 // single fx z radius used to create nospawn area and block traces
	string deploySound1p = SFX_SMOKE_DEPLOY_1P
	string deploySound3p = SFX_SMOKE_DEPLOY_3P
	string stopSound1p = ""
	string stopSound3p = ""
	int damageSource = eDamageSourceId.damagedef_grenade_gas
	int damageFlags = DF_ELECTRICAL | DF_NO_HITBEEP
	float damageTickRate = 0.1

	bool blockLOS = true
	bool shouldHibernate = true

	bool isElectric = true
	entity attacker
	entity inflictor
	entity weaponOrProjectile
	entity smokeSource
	float damageDelay = 2.0
	float damageInnerRadius = 320.0
	float damageOuterRadius = 350.0
	float dangerousAreaRadius = -1.0
	int dpsPilot = 30
	int dpsTitan = 2200

	int traceBlockerTeam = TEAM_ANY
	string traceBlockerScriptName

	entity smokeTrigger

	array<vector> fxOffsets
}

struct SmokescreenFXStruct
{
	vector center	// center of all fx positions
	vector mins 	// approx mins of all fx relative to center
	vector maxs 	// approx maxs of all fx relative to center
	float radius	// approx radius of all fx relative to center
	array<vector> fxWorldPositions
	int ownerTeam = TEAM_ANY
}

struct
{
	array<SmokescreenFXStruct> allSmokescreenFX
	table<entity, float> nextSmokeSoundTime
} file

void function Smokescreen_Init()
{
    PrecacheParticleSystem( FX_ELECTRIC_SMOKESCREEN )
    PrecacheParticleSystem( FX_ELECTRIC_SMOKESCREEN_BURN )
	PrecacheParticleSystem( FX_ELECTRIC_SMOKESCREEN_HEAL )
	PrecacheParticleSystem( FX_GRENADE_SMOKESCREEN )
}

void function Smokescreen( SmokescreenStruct smokescreen, entity ownerEnt )
{
	SmokescreenFXStruct fxInfo = Smokescreen_CalculateFXStruct( smokescreen )
	file.allSmokescreenFX.append( fxInfo )

	entity traceBlocker

	if ( smokescreen.blockLOS )
		traceBlocker = Smokescreen_CreateTraceBlockerVol( smokescreen, fxInfo, ownerEnt )

#if DEVELOPER
	if ( SMOKESCREEN_DEBUG )
		DebugDrawCircle( fxInfo.center, <0,0,0>, fxInfo.radius + 240.0, int( COLOR_YELLOW.x ), int( COLOR_YELLOW.y ), int( COLOR_YELLOW.z ), true, smokescreen.lifetime )
#endif
	CreateNoSpawnArea( TEAM_ANY, TEAM_ANY, fxInfo.center, smokescreen.lifetime, fxInfo.radius + 240.0 )

	if ( IsValid( smokescreen.attacker ) && smokescreen.attacker.IsPlayer() )
	{
		if ( smokescreen.deploySound3p != "" )
			EmitSoundAtPositionExceptToPlayer( TEAM_ANY, fxInfo.center, smokescreen.attacker, smokescreen.deploySound3p )

		if ( smokescreen.deploySound1p != "" )
			EmitSoundAtPositionOnlyToPlayer( TEAM_ANY, fxInfo.center, smokescreen.attacker, smokescreen.deploySound1p)
	}
	else
	{
		if ( smokescreen.deploySound3p != "" )
			EmitSoundAtPosition( TEAM_ANY, fxInfo.center, smokescreen.deploySound3p, ownerEnt )
	}

	array<entity> fxEntities = SmokescreenFX( smokescreen, fxInfo )
	if ( smokescreen.isElectric )
		thread SmokescreenAffectsEntitiesInArea( smokescreen, fxInfo )
	//thread CreateSmokeSightTrigger( fxInfo.center, smokescreen.ownerTeam, smokescreen.lifetime ) // disabling for now, this should use the calculated radius if reenabled

	thread DestroySmokescreen( smokescreen, smokescreen.lifetime, fxInfo, traceBlocker, fxEntities )
}

SmokescreenFXStruct function Smokescreen_CalculateFXStruct( SmokescreenStruct smokescreen )
{
	SmokescreenFXStruct fxInfo

	foreach ( i, position in smokescreen.fxOffsets )
	{
		//mins
		if ( i == 0 || position.x < fxInfo.mins.x )
			fxInfo.mins = <position.x, fxInfo.mins.y, fxInfo.mins.z>

		if ( i == 0 || position.y < fxInfo.mins.y )
			fxInfo.mins = <fxInfo.mins.x, position.y, fxInfo.mins.z>

		if ( i == 0 || position.z < fxInfo.mins.z )
			fxInfo.mins = <fxInfo.mins.x, fxInfo.mins.y, position.z>

		// maxs
		if ( i == 0 || position.x > fxInfo.maxs.x )
			fxInfo.maxs = <position.x, fxInfo.maxs.y, fxInfo.maxs.z>

		if ( i == 0 || position.y > fxInfo.maxs.y )
			fxInfo.maxs = <fxInfo.maxs.x, position.y, fxInfo.maxs.z>

		if ( i == 0 || position.z > fxInfo.maxs.z )
			fxInfo.maxs = <fxInfo.maxs.x, fxInfo.maxs.y, position.z>
	}

	vector offsetCenter = fxInfo.mins + ( fxInfo.maxs - fxInfo.mins ) * 0.5

	float xyRadius = smokescreen.fxXYRadius * 0.7071
	float zRadius = smokescreen.fxZRadius * 0.7071

	fxInfo.mins = <fxInfo.mins.x - xyRadius, fxInfo.mins.y - xyRadius, fxInfo.mins.z - zRadius> - offsetCenter
	fxInfo.maxs = <fxInfo.maxs.x + xyRadius, fxInfo.maxs.y + xyRadius, fxInfo.maxs.z + zRadius> - offsetCenter

	float radiusSqr
	float singleFXRadius = max( smokescreen.fxXYRadius, smokescreen.fxZRadius )

	vector forward = AnglesToForward( smokescreen.angles )
	vector right = AnglesToRight( smokescreen.angles )
	vector up = AnglesToUp( smokescreen.angles )

	vector originToUse = smokescreen.origin

	if ( IsValid( smokescreen.smokeSource ) )
	{
		originToUse = smokescreen.smokeSource.GetOrigin()
		forward = AnglesToForward( smokescreen.smokeSource.GetAngles() )
		right = AnglesToRight( smokescreen.smokeSource.GetAngles() )
	}

	foreach ( i, position in smokescreen.fxOffsets )
	{
		float distanceSqr = DistanceSqr( position, offsetCenter )

		if ( radiusSqr < distanceSqr )
			radiusSqr = distanceSqr

		fxInfo.fxWorldPositions.append( originToUse + ( position.x * forward ) + ( position.y * right ) + ( position.z * up ) )
	}

	fxInfo.center = originToUse + ( offsetCenter.x * forward ) + ( offsetCenter.y * right ) + ( offsetCenter.z * up )
	fxInfo.radius = sqrt( radiusSqr ) + singleFXRadius
	fxInfo.ownerTeam = smokescreen.ownerTeam

	return fxInfo
}

vector function GetFXCenterFromSmokescreen( SmokescreenStruct smokescreen )
{
	SmokescreenFXStruct fxInfo = Smokescreen_CalculateFXStruct( smokescreen )
	return fxInfo.center
}

void function SmokescreenAffectsEntitiesInArea( SmokescreenStruct smokescreen, SmokescreenFXStruct fxInfo )
{
	float startTime = Time()
	float tickRate 	= smokescreen.damageTickRate

	float dpsPilot = smokescreen.dpsPilot * tickRate
	float dpsTitan = smokescreen.dpsTitan * tickRate
	Assert( dpsPilot > 0 || dpsTitan > 0, "Electric smokescreen with 0 damage created" )

	entity aiDangerTarget = CreateEntity( "info_target" )
	DispatchSpawn( aiDangerTarget )
	aiDangerTarget.SetOrigin( fxInfo.center )
	SetTeam( aiDangerTarget, smokescreen.ownerTeam )

	float dangerousAreaRadius = smokescreen.damageOuterRadius
	if ( smokescreen.dangerousAreaRadius != -1.0 )
		dangerousAreaRadius = smokescreen.dangerousAreaRadius

	AI_CreateDangerousArea_Static( aiDangerTarget, smokescreen.weaponOrProjectile, dangerousAreaRadius, TEAM_INVALID, true, true, fxInfo.center )

	OnThreadEnd(
		function () : ( aiDangerTarget )
		{
			aiDangerTarget.Destroy()
		}
	)

	wait smokescreen.damageDelay

	while ( Time() - startTime <= smokescreen.lifetime )
	{
#if DEVELOPER
		if ( SMOKESCREEN_DEBUG )
		{
			DebugDrawCircle( fxInfo.center, <0,0,0>, smokescreen.damageInnerRadius, int( COLOR_RED.x ), int( COLOR_RED.y ), int( COLOR_RED.z ), true, tickRate )
			DebugDrawCircle( fxInfo.center, <0,0,0>, smokescreen.damageOuterRadius, int( COLOR_RED.x ), int( COLOR_RED.y ), int( COLOR_RED.z ), true, tickRate )
			DebugDrawLine( fxInfo.center, smokescreen.origin, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, tickRate )
		}
#endif

		RadiusDamage(
			fxInfo.center,															// center
			smokescreen.attacker,													// attacker
			smokescreen.inflictor,													// inflictor
			dpsPilot,																// damage
			dpsTitan,																// damageHeavyArmor
			smokescreen.damageInnerRadius,											// innerRadius
			smokescreen.damageOuterRadius,											// outerRadius
			SF_ENVEXPLOSION_MASK_BRUSHONLY,	// flags
			0.0,																	// distanceFromAttacker
			0.0,																	// explosionForce
			smokescreen.damageFlags,												// scriptDamageFlags
			smokescreen.damageSource )												// scriptDamageSourceIdentifier

			wait tickRate
	}
}

                                    
bool function SmokeBlockThreatVision_IsEnabled()
{
	return GetCurrentPlaylistVarBool( "smoke_blocks_threat_vision", true )
}
      

entity function Smokescreen_CreateTraceBlockerVol( SmokescreenStruct smokescreen, SmokescreenFXStruct fxInfo, entity ownerEnt )
{
	entity tbl = CreateEntity( "trace_volume" )
	tbl.kv.targetname = UniqueString( "smokescreen_traceblocker_vol" )
	tbl.kv.origin = fxInfo.center + <0,0,( fabs( fxInfo.maxs.z ) * 0.5 )>
	tbl.kv.angles = smokescreen.angles
	DispatchSpawn( tbl )
	tbl.SetBox( fxInfo.mins * 0.9, fxInfo.maxs * 1.1 )
	tbl.kv.contents = int( tbl.kv.contents ) | CONTENTS_OPAQUE
	                                    
	if( SmokeBlockThreatVision_IsEnabled() )
	{
		tbl.kv.contents = int( tbl.kv.contents )
	}
       

	if ( smokescreen.traceBlockerTeam >= 0 )
		SetTeam( tbl, smokescreen.traceBlockerTeam )
	tbl.SetScriptName( smokescreen.traceBlockerScriptName )
	tbl.SetIgnorePredictedTriggerTypes( TT_JUMP_PAD | TT_GRAVITY_LIFT | TT_BLACKHOLE  )

	if ( IsValid( ownerEnt ) )
	{
		tbl.RemoveFromAllRealms()
		tbl.AddToOtherEntitysRealms( ownerEnt )
	}

	AI_CreateDangerousArea_Static(tbl, null, fxInfo.radius, TEAM_INVALID, true, true, fxInfo.center);

	#if DEVELOPER
	if ( SMOKESCREEN_DEBUG )
		DrawAngledBox( tbl.GetOrigin(), smokescreen.angles, tbl.GetBoundingMins(), tbl.GetBoundingMaxs(), int( COLOR_RED.x ), int( COLOR_RED.y ), int( COLOR_RED.z ), true, smokescreen.lifetime - 0.6 )
#endif

	return tbl
}

array<entity> function SmokescreenFX( SmokescreenStruct smokescreen, SmokescreenFXStruct fxInfo )
{
	array<entity> fxEntities

	foreach ( position in fxInfo.fxWorldPositions )
	{
#if DEVELOPER
		if ( SMOKESCREEN_DEBUG )
			DebugDrawCircle( position, <0,0,0>, smokescreen.fxXYRadius, int( COLOR_BLUE.x ), int( COLOR_BLUE.y ), int( COLOR_BLUE.z ), true, smokescreen.lifetime )
#endif
		int fxID = GetParticleSystemIndex( smokescreen.smokescreenFX )
		vector angles = smokescreen.fxUseWeaponOrProjectileAngles ? smokescreen.weaponOrProjectile.GetAngles() : <0,0,0>
		entity fxEnt = StartParticleEffectInWorld_ReturnEntity( fxID, position, angles )
		entity ownerEnt = smokescreen.attacker
		if ( ownerEnt != null )
		{
			fxEnt.RemoveFromAllRealms()
			fxEnt.AddToOtherEntitysRealms( ownerEnt )
		}

		float fxLife = smokescreen.lifetime

		EffectSetControlPointVector( fxEnt, 1, <fxLife,0,0> )

		if ( !smokescreen.shouldHibernate )
			fxEnt.DisableHibernation()

		fxEntities.append( fxEnt )
	}

	return fxEntities
}

void function DestroySmokescreen( SmokescreenStruct smokescreen, float lifetime, SmokescreenFXStruct fxInfo, entity traceBlocker, array<entity> fxEntities )
{
	if ( IsValid( smokescreen.attacker ) )
	{
		EndThreadOn_PlayerCleanupPermanents( smokescreen.attacker )
		EndThreadOn_PlayerChangedClass( smokescreen.attacker )
	}

               
                                       
      

	OnThreadEnd(
		function () : ( fxEntities, traceBlocker, fxInfo, smokescreen )
		{
			if ( IsValid( traceBlocker ) )
				traceBlocker.Destroy()

			// stop sound if it has not been stoped before
			if ( smokescreen.deploySound1p != "" )
				StopSoundAtPosition( fxInfo.center, smokescreen.deploySound1p )

			if ( smokescreen.deploySound3p != "" )
				StopSoundAtPosition( fxInfo.center, smokescreen.deploySound3p )

			foreach ( fxEnt in fxEntities )
			{
				if ( IsValid( fxEnt ) )
					EffectStop( fxEnt )
			}

			if ( IsValid( smokescreen.smokeTrigger ) )
				smokescreen.smokeTrigger.Destroy()
		}
	)

	float timeToWait = 0.0

	timeToWait = max( lifetime - 0.5, 0.0 )

	wait( timeToWait )

	if ( IsValid( traceBlocker ) )
		traceBlocker.Destroy()
	file.allSmokescreenFX.fastremovebyvalue( fxInfo )

	if ( smokescreen.deploySound1p != "" )
		StopSoundAtPosition( fxInfo.center, smokescreen.deploySound1p )

	if ( smokescreen.deploySound3p != "" )
		StopSoundAtPosition( fxInfo.center, smokescreen.deploySound3p )

	if ( IsValid( smokescreen.attacker ) && smokescreen.attacker.IsPlayer() )
	{
		if ( smokescreen.stopSound3p != "" )
			EmitSoundAtPositionExceptToPlayer( TEAM_ANY, fxInfo.center, smokescreen.attacker, smokescreen.stopSound3p )

		if ( smokescreen.stopSound1p != "" )
			EmitSoundAtPositionOnlyToPlayer( TEAM_ANY, fxInfo.center, smokescreen.attacker, smokescreen.stopSound1p )
	}
	else
	{
		if ( smokescreen.stopSound3p != "" )
			EmitSoundAtPosition( TEAM_ANY, fxInfo.center, smokescreen.stopSound3p, fxEntities[0] )
	}

	timeToWait = max( ( lifetime + 0.1 ) - timeToWait, 0.0 )

	wait( timeToWait )
}

bool function IsOriginTouchingSmokescreen( vector origin, int teamToIgnore = TEAM_UNASSIGNED )
{
	foreach ( fxInfo in file.allSmokescreenFX )
	{
		if ( teamToIgnore == fxInfo.ownerTeam )
			continue

		if ( DistanceSqr( origin, fxInfo.center ) < fxInfo.radius * fxInfo.radius )
			return true
	}

	return false
}

bool function IsRayTouchingSmokescreen( vector rayStart, vector rayEnd, int teamToIgnore = TEAM_UNASSIGNED )
{
	foreach ( fxInfo in file.allSmokescreenFX )
	{
		if ( teamToIgnore == fxInfo.ownerTeam )
			continue

		if ( IntersectRayWithSphere( rayStart, rayEnd, fxInfo.center, fxInfo.radius ).result )
			return true
	}

	return false
}

#if SERVER
void function TitanElectricSmoke_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	if ( !IsAlive( ent ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( IsFriendlyTeam( ent.GetTeam(), attacker.GetTeam() ) )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	PlayDamageSounds( ent, attacker, ELECTRIC_SMOKESCREEN_SFX_DAMAGE_TITAN_1P, ELECTRIC_SMOKESCREEN_SFX_DAMAGE_TITAN_3P, ELECTRIC_SMOKESCREEN_SFX_DAMAGE_PILOT_1P, ELECTRIC_SMOKESCREEN_SFX_DAMAGE_PILOT_3P )
}

void function GrenadeElectricSmoke_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	if ( !IsAlive( ent ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	PlayDamageSounds( ent, attacker, ELECTRIC_SMOKE_GRENADE_SFX_DAMAGE_TITAN_1P, ELECTRIC_SMOKE_GRENADE_SFX_DAMAGE_TITAN_3P, ELECTRIC_SMOKE_GRENADE_SFX_DAMAGE_PILOT_1P, ELECTRIC_SMOKE_GRENADE_SFX_DAMAGE_PILOT_3P )
}

void function PlayDamageSounds( entity ent, entity attacker, string titan1P_SFX, string titan3P_SFX, string pilot1P_SFX, string pilot3P_SFX )
{
	float currentTime = Time()

	if ( !( ent in file.nextSmokeSoundTime ) )
	{
		if ( ent.IsPlayer() )
			file.nextSmokeSoundTime[ ent ] <- currentTime
		else
			file.nextSmokeSoundTime[ ent ] <- currentTime + RandomFloat( 0.5 )
	}

	if ( file.nextSmokeSoundTime[ ent ] <= currentTime )
	{
		if ( ent.IsPlayer() )
		{
			if ( ent.IsTitan() )
			{
				EmitSoundOnEntityExceptToPlayer( ent, ent, titan3P_SFX )
				EmitSoundOnEntityOnlyToPlayer( ent, ent, titan1P_SFX )
				file.nextSmokeSoundTime[ ent ] = currentTime + RandomFloatRange( 0.75, 1.25 )
			}
			else
			{
				EmitSoundOnEntityExceptToPlayer( ent, ent, pilot3P_SFX )
				EmitSoundOnEntityOnlyToPlayer( ent, ent, pilot1P_SFX )
			}

			if ( IsValid( attacker ) && attacker.IsPlayer() )
				EmitSoundOnEntityOnlyToPlayer( attacker, attacker, "Player.Hitbeep" )
		}
		else
		{
			if ( ent.IsTitan() )
				EmitSoundOnEntity( ent, titan3P_SFX )
			else if ( IsHumanSized( ent ) )
				EmitSoundOnEntity( ent, pilot3P_SFX )
		}

		file.nextSmokeSoundTime[ ent ] = currentTime + RandomFloatRange( 0.75, 1.25 )
	}
}
#endif
