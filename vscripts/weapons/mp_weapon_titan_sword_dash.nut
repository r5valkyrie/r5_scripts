                          
global function MpWeaponTitanSword_Dash_Init
global function TitanSword_Dash_OnWeaponActivate
global function TitanSword_Dash_OnWeaponDeactivate
global function TitanSword_Dash_ClearMods
global function TitanSword_Dash_TryDash
global function PlayRotatedImpactFXTable

#if CLIENT
global function ServerToClient_PlayRotatedImpactFxTable
global function ServerToClient_StopDash
#endif

//Names

//Playlist Vars

//Signals
const string SIG_TITAN_SWORD_DASH_ACTIVATED = "TitanSword_DashActivated"
const string SIG_TITAN_SWORD_DASH_STOPPED = "TitanSword_DashStopped"

const float TITAN_SWORD_CHARGE_DASH_SEC = 0.0
const float TITAN_SWORD_DASH_SPEED = 1400//1600
const float TITAN_SWORD_DASH_SPEED_AIR = 950//1250

const float TITAN_SWORD_DASH_NOT_READY_DEBOUNCE_TIME_SEC = 1
const float TITAN_SWORD_MAIN_INSTRUCTIONS_DEBOUNCE_TIME = 30 //Maybe we make this first draw???
const float TITAN_SWORD_INSTRUCTIONS_DEBOUNCE_TIME = 10

//DEBUG
const bool TITAN_SWORD_LOS_DEBUG = false

//VFX
const asset VFX_TITAN_SWORD_DASH_1P = $"P_pilot_dash_FP"
const asset VFX_TITAN_SWORD_DASH_3P = $"P_pilot_dash_3P"
const asset VFX_TITAN_SWORD_DASH_JETS = $"P_pilot_dash_launch_thruster"

const string VFX_TITAN_SWORD_DASH_START_IMPACT = "pilot_dash_start" //pilot_start
const string VFX_TITAN_SWORD_DASH_SKID_IMPACT = "pilot_dash" //pilot_slide

//SFX
const string SFX_TITAN_SWORD_DASH_1P = "titansword_special_dash_1p"
const string SFX_TITAN_SWORD_DASH_3P = "titansword_special_dash_3p"
const string SFX_TITAN_SWORD_DASH_IMPACT = "titansword_special_dash_obstacle_1p"


struct
{
	#if SERVER
		table<entity, array <entity> >    fakeHitboxes
	#endif
}file

void function MpWeaponTitanSword_Dash_Init()
{
	RegisterImpactTable( VFX_TITAN_SWORD_DASH_START_IMPACT )
	RegisterImpactTable( VFX_TITAN_SWORD_DASH_SKID_IMPACT )

	PrecacheParticleSystem( VFX_TITAN_SWORD_DASH_1P )
	PrecacheParticleSystem( VFX_TITAN_SWORD_DASH_3P )
	PrecacheParticleSystem( VFX_TITAN_SWORD_DASH_JETS )

	RegisterSignal( SIG_TITAN_SWORD_DASH_ACTIVATED )
	RegisterSignal( SIG_TITAN_SWORD_DASH_STOPPED )


	Remote_RegisterClientFunction( "ServerToClient_PlayRotatedImpactFxTable", "entity", "vector", -MAX_MAP_BOUNDS, MAX_MAP_BOUNDS, 32, "vector", -MAX_MAP_BOUNDS, MAX_MAP_BOUNDS, 32, "int", INT_MIN, INT_MAX )
	Remote_RegisterClientFunction( "ServerToClient_StopDash" )
}

void function TitanSword_Dash_OnWeaponActivate( entity player, entity weapon )
{
	#if SERVER
		//TitanSword_RemoveModOnDrop( weapon, TITAN_SWORD_DASH_MOD )

		if ( !HasPlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, TitanSword_Dash_OnPlayerTouchGround ) )
			AddPlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, TitanSword_Dash_OnPlayerTouchGround )
	#endif
}

void function TitanSword_Dash_OnWeaponDeactivate( entity player, entity weapon )
{
	#if SERVER
		if ( HasPlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, TitanSword_Dash_OnPlayerTouchGround ) )
			RemovePlayerMovementEventCallback( player, ePlayerMovementEvents.TOUCH_GROUND, TitanSword_Dash_OnPlayerTouchGround )
	#endif
}

void function TitanSword_Dash_ClearMods( entity weapon )
{
	//weapon.RemoveMod( TITAN_SWORD_DASH_MOD )
}

void function TitanSword_Dash_StartDashing( entity player, float duration )
{
	#if CLIENT
		if ( InPrediction() )
			StatusEffect_AddTimed( player, eStatusEffect.titan_sword_dash, 1.0, duration, 0.0 )
	#elseif SERVER
		StatusEffect_AddTimed( player, eStatusEffect.titan_sword_dash, 1.0, duration, 0.0 )
	#endif
}

void function TitanSword_Dash_StopDashing( entity player )
{
	#if CLIENT
		if ( InPrediction() )
			StatusEffect_StopAllOfType( player, eStatusEffect.titan_sword_dash )
	#elseif SERVER
		StatusEffect_StopAllOfType( player, eStatusEffect.titan_sword_dash )
		Remote_CallFunction_Replay( player, "ServerToClient_StopDash" )
	#endif
	player.Signal( SIG_TITAN_SWORD_DASH_STOPPED )
}

bool function TitanSword_Dash_IsDashing( entity player )
{
	return StatusEffect_HasSeverity( player, eStatusEffect.titan_sword_dash )
}

bool function TitanSword_Dash_TryDash( entity player, entity weapon )
{
	if ( TitanSword_Block_IsBlocking( weapon ) )
	{
		if ( TitanSword_Dash_TryDashCancel( player, weapon ) && TitanSword_Heavy_TryHeavyAttack( player, weapon ) )
			return true

		//Switched to a status effect over weapon mod - more prediction friendly
		if ( TitanSword_Dash_IsDashing( player ) )
			return true

		if ( !TitanSword_TryUseFuel( player, true ) )
			return true

		thread TitanSword_Dash_Thread( player )

		#if CLIENT
			HidePlayerHint( "#WPN_TITAN_SWORD_DASH_NOT_READY" )
		#endif
		return true //blocking overrides all
	}

	return false
}

bool function TitanSword_Dash_TryDashCancel( entity player, entity weapon )
{
	if ( TitanSword_Dash_IsDashing( player ) && !weapon.IsWeaponInAds() )
	{
		return true
	}
	return false
}

void function TitanSword_Dash_Thread( entity player )
{
	//This is kinda ass
	//The trigger volume approach is unreliable
	//Maybe do a cone check instead
	//Some client/server shenanigans happening here

	if ( !IsValid( player ) )
		return

	player.Signal( SIG_TITAN_SWORD_DASH_ACTIVATED )

	player.EndSignal( SIG_TITAN_SWORD_DASH_ACTIVATED )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "BleedOut_OnStartDying" )
	player.EndSignal( SIG_TITAN_SWORD_DASH_STOPPED )

	#if CLIENT
		if ( !InPrediction() || (InPrediction() && IsFirstTimePredicted()) )
			EmitSoundOnEntity( player, SFX_TITAN_SWORD_DASH_1P )
	#endif

	float duration = 0.4

	TitanSword_Dash_StartDashing( player, duration + 0.1 )

	#if SERVER
		player.Zipline_Stop()

		EmitSoundOnEntityExceptToPlayer( player, player, SFX_TITAN_SWORD_DASH_3P )

		array<entity> movementEffects

		entity dashFx = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( VFX_TITAN_SWORD_DASH_3P ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "CHESTFOCUS" ) )
		dashFx.SetOwner( player )
		dashFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY

		movementEffects.append( dashFx )

		TitanSword_CreateMovementEffects( player, movementEffects )
		TitanSword_CreateJetDriveJetEffects( player, VFX_TITAN_SWORD_DASH_JETS, movementEffects )
		//Do I need to declare realms if attaching to player?
		//Needs to be client for cockpit
		//int fxID = GetParticleSystemIndex( FX_DRONE_MEDIC_HEAL_COCKPIT_FX )
		//file.healFxHandle = StartParticleEffectOnEntity( cockpit, fxID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
		//EffectSetIsWithCockpit( file.healFxHandle, true )

		int forceStandHandle = player.PushForcedStance( FORCE_STANCE_STAND )

		OnThreadEnd(
			function() : ( player, forceStandHandle, movementEffects )
			{
				if ( IsValid( player ) )
				{
					player.RemoveForcedStance( forceStandHandle )
				}

				foreach ( entity effect in movementEffects )
				{
					if ( IsValid( effect ) )
						EffectStop( effect )
				}
			}
		)
	#endif

	//The actual launch
	vector fwdAdjusted = AnglesCompose( player.EyeAngles(), <90, 0, 0> )
	fwdAdjusted.x = 90

	vector eyeAngles = player.EyeAngles()
	eyeAngles.x = 0
	vector launchFwd = FlattenNormalizeVec( AnglesToForward( eyeAngles ) )

	vector normalVel = Normalize( player.GetVelocity() )

	float dashSpeed = player.IsOnGround() ? TITAN_SWORD_DASH_SPEED : TITAN_SWORD_DASH_SPEED_AIR
	//If we're dashing too quickly, make sure player falls back to earth or they can fly
	//if ( StatusEffect_HasSeverity( player, eStatusEffect.titan_sword_dash_sickness ) )
	//{
	//	launchFwd.z = normalVel.z// * 0.75
	//	launchFwd   = FlattenNormalizeVec( launchFwd )
	//}
	vector dashVec  = launchFwd * dashSpeed
	if ( StatusEffect_HasSeverity( player, eStatusEffect.titan_sword_dash_sickness ) )
	{
		dashVec.z = player.GetVelocity().z * 0.85
	}
	//player.PlayerLaunch( dashVec, false )

	//If the player isn't on the ground, start dash sickness
	if ( !player.IsOnGround() )
		StatusEffect_AddTimed( player, eStatusEffect.titan_sword_dash_sickness, 1.0, 5.0, 0.0 )

	thread TitanSword_Dash_PlaySkidVFX_Thread( player )

	//StatusEffect_AddTimed( player, eStatusEffect.turn_slow, 1.0, duration, 0 )

	//We might want Lunge_SetTargetPosition instead of Launch
	//player.PlayerCone_SetSpecific( eyeAngles )
	//player.PlayerCone_SetLerpTime( 0.2 )
	//player.PlayerCone_SetMinYaw( 0 )
	//player.PlayerCone_SetMaxYaw( 0 )
	//player.PlayerCone_SetMinPitch( 0 )
	//player.PlayerCone_SetMaxPitch( 0 )

	//ViewConeLockedForward(player)

	wait 0.1

	#if SERVER
		TitanSword_CreateHitbox( player, player.GetWorldSpaceCenter(), fwdAdjusted, 50, 80, duration, TitanSword_Dash_OnHit )
	#endif

	wait duration

	player.Signal( SIG_TITAN_SWORD_DASH_STOPPED )
}

#if SERVER
void function TitanSword_Dash_OnPlayerTouchGround( entity player )
{
	StatusEffect_StopAllOfType( player, eStatusEffect.titan_sword_dash_sickness )
}
#endif

#if SERVER
void function TitanSword_Dash_OnHit( entity trigger, entity victim )
{
	if ( !victim.IsPlayer() && !victim.IsNPC() && !IsDoor( victim ) )
		return

	entity attacker = trigger.GetOwner()

	if ( !IsValid( attacker ) )
		return

	TitanSword_Dash_StopDashing( attacker ) //this will upset prediction

	attacker.SetVelocity( ZERO_VECTOR )
	victim.TakeDamage( 0, attacker, attacker, { damageSourceId = eDamageSourceId.mp_weapon_titan_sword, scriptType = DF_MELEE | DF_KNOCK_BACK | DF_GIB | DF_EXPLOSION } )

	EmitSoundOnEntity( attacker, SFX_TITAN_SWORD_DASH_IMPACT )
}
#endif

#if CLIENT
void function ServerToClient_StopDash()
{
	entity player = GetLocalViewPlayer()
	if ( IsValid( player ) )
		TitanSword_Dash_StopDashing( player )
}
#endif

void function TitanSword_Dash_PlaySkidVFX_Thread( entity player )
{
	Assert ( player )
	Assert ( IsNewThread(), "Must be threaded off" )

	player.EndSignal( SIG_TITAN_SWORD_DASH_ACTIVATED )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( SIG_TITAN_SWORD_DASH_STOPPED )
	player.EndSignal( "BleedOut_OnStartDying" )

	vector currentPos = player.GetOrigin()
	float trackDist   = 0
	vector prevPos    = currentPos
	const float SLIDE_IMPACT_FX_MIN_DIST = 20

	float startTime = Time()

	PlayRotatedImpactFXTable( player, currentPos, AnglesToForward( player.GetAngles() ), VFX_TITAN_SWORD_DASH_START_IMPACT )

	while ( TitanSword_Dash_IsDashing( player ) )
	{
		currentPos = player.GetOrigin()
		trackDist += Distance( currentPos, prevPos )

		if ( trackDist >= SLIDE_IMPACT_FX_MIN_DIST && player.IsOnGround() )
		{
			PlayRotatedImpactFXTable( player, currentPos, currentPos - prevPos, VFX_TITAN_SWORD_DASH_SKID_IMPACT )
			trackDist = 0
			prevPos   = currentPos
		}

		WaitFrame()
	}
}


void function PlayRotatedImpactFXTable( entity owner, vector origin, vector fwd, string impactFx, int flags = 0 )
{
	int impactTableIndex = GetImpactTableIndex( impactFx )
	#if CLIENT
		ServerToClient_PlayRotatedImpactFxTable( owner, origin, fwd, impactTableIndex )
	#endif
	#if SERVER
		array< entity > allPlayers = GetPlayerArray()
		foreach ( entity player in allPlayers )
		{
			if ( player == owner )
				continue

			//Firing range
			if ( !player.DoesShareRealms( owner ) )
				continue

			Remote_CallFunction_Replay( player, "ServerToClient_PlayRotatedImpactFxTable", owner, origin, fwd, impactTableIndex )
		}
	#endif
}

#if CLIENT
void function ServerToClient_PlayRotatedImpactFxTable( entity owner, vector origin, vector fwd, int impactTableIndex )
{
	entity localPlayer = GetLocalViewPlayer()

	if ( !IsValid( localPlayer ) )
		return

	if ( !IsValid( owner ) )
		return

	const float UP = 40
	const float DOWN = -80

	vector startPos = origin + <0, 0, UP>
	vector endPos   = origin + <0, 0, DOWN>

	TraceResults trace = TraceLineHighDetail( startPos, endPos, owner, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE, owner )

	//DebugDrawCube( startPos, 3, COLOR_RED, true, 5.0 )
	//DebugDrawSphere( endPos, 3, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 5.0 )

	vector finalEnd = trace.endPos

	if ( !IsValid( trace.hitEnt ) ) //We didn't hit anything
	{
		if ( origin != owner.GetOrigin() ) // Try again if it isn't where we're already standing
		{
			startPos = owner.GetOrigin() + <0, 0, UP>
			endPos   = owner.GetOrigin() + <0, 0, -200>
			finalEnd = origin
			trace    = TraceLineHighDetail( startPos, endPos, owner, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE, owner )
		}
	}

	//DebugDrawCube( startPos, 3, COLOR_GREEN, true, 5.0 )
	//DebugDrawSphere( endPos, 3, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 5.0 )

	if ( IsValid( trace.hitEnt ) )
	{
		vector normal = Normalize( startPos - (endPos + (fwd * .1)) )
		localPlayer.DispatchImpactEffects( trace.hitEnt, startPos, finalEnd, normal, trace.surfaceProp, trace.staticPropID, DMG_MELEE_ATTACK, impactTableIndex, owner, 0 )

		//DebugDrawLine( startPos, trace.endPos, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 5.0 )
		//printt( "PlayImpactFXTable event collided with surfaceProp " + trace.surfaceProp + " on " + trace.hitEnt )
	}
}
#endif

//Fake Melee
//This may be necessary if the normal melee doesn't cut it
#if SERVER
entity function TitanSword_CreateHitbox( entity player, vector origin, vector angles, int radius, int range, float duration, void functionref(entity, entity) OnHit )
{
	entity mover = CreateScriptMover( "BLAH BLAH TESTING" )
	mover.SetOrigin( origin )
	mover.SetAngles( <0, 0, 0> )

	mover.SetParent( player )

	entity hitbox = CreateEntity( "trigger_cylinder" )
	hitbox.SetCylinderRadius( radius )
	hitbox.SetAboveHeight( range )
	hitbox.SetBelowHeight( 0 )
	hitbox.SetOrigin( origin )

	hitbox.SetParent( mover )
	hitbox.SetOwner( player )
	SetTeam( hitbox, player.GetTeam() )
	hitbox.SetAbsAngles( angles )

	hitbox.kv.triggerFilterNpc    = "all"
	hitbox.kv.triggerFilterPlayer = "all"
	//hitbox.kv.triggerFilterNonCharacter = 1
	DispatchSpawn( hitbox )

	array<entity> playersHit
	file.fakeHitboxes[hitbox] <- playersHit

	//hitbox.SetEnterCallback( OnHit )
	hitbox.SearchForNewTouchingEntity()

	thread FakeMeleeTrigger_Thread( player, hitbox, mover, duration, OnHit )

	return hitbox
}

void function FakeMeleeTrigger_Thread( entity player, entity hitbox, entity mover, float duration, void functionref(entity, entity) OnHit )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "BleedOut_OnStartDying" )

	hitbox.EndSignal( "OnDestroy" )

	mover.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( hitbox, mover )
		{
			if ( hitbox in file.fakeHitboxes )
				delete file.fakeHitboxes[hitbox]

			if ( IsValid( hitbox ) )
				hitbox.Destroy()

			if ( IsValid( mover ) )
				mover.Destroy()
		}
	)

	float endTime = Time() + duration
	while( Time() < endTime )
	{
		hitbox.SearchForNewTouchingEntity()
		foreach ( entity ent in hitbox.GetTouchingEntities() )
		{
			if ( IsValidHitTarget( hitbox, ent ) )
			{
				OnHit( hitbox, ent )
			}
		}

		WaitFrame()
	}
}

bool function IsValidHitTarget( entity trigger, entity victim )
{
	if ( !IsValid( trigger ) )
		return false

	if ( !IsValid( victim ) )
		return false

	if ( !(trigger in file.fakeHitboxes) )
		return false

	if ( file.fakeHitboxes[trigger].contains( victim ) )
		return false

	if ( IsFriendlyTeam( trigger.GetTeam(), victim.GetTeam() ) )
		return false

	if ( !TitanSword_HasPlayerLOS( trigger, victim ) )
		return false

	file.fakeHitboxes[trigger].append( victim )

	return true
}

bool function TitanSword_HasPlayerLOS( entity trigger, entity player )
{
	//Ignore other players and the ward
	array<entity> ignoreEnts = GetPlayerArray_AliveConnected()
	ignoreEnts.append( player )
	ignoreEnts.append( trigger )

	vector traceStart = trigger.GetWorldSpaceCenter()
	vector traceEnd   = player.GetWorldSpaceCenter()

	TraceResults traceResults = TraceLine( traceStart, traceEnd, ignoreEnts, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )

	#if TITAN_SWORD_LOS_DEBUG
		DebugDrawLine( traceStart, traceEnd, 255, 1, 1, true, 0.1 )
	#endif

	if ( traceResults.fraction < 1.0 )
	{
		traceEnd     = player.EyePosition()
		traceResults = TraceLine( traceStart, traceEnd, ignoreEnts, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
		#if TITAN_SWORD_LOS_DEBUG
			DebugDrawLine( traceStart, traceEnd, 255, 1, 1, true, 0.1 )
		#endif
	}

	if ( traceResults.fraction == 1.0 )
	{
		#if TITAN_SWORD_LOS_DEBUG
			DebugDrawLine( traceStart, traceEnd, 1, 255, 1, true, 10.0 )
		#endif
		return true
	}
	return false
}
#endif

                               