                          
global function MpWeaponTitanSword_Slam_Init
global function TitanSword_Slam_OnWeaponActivate
global function TitanSword_Slam_OnWeaponDectivate
global function TitanSword_Slam_ClearMods
global function TitanSword_Slam_TrySlam
global function TitanSword_Slam_VictimHitOverride
global function TitanSword_Slam_TrySlamAnimEvent

#if SERVER
global function TitanSword_Slam_OnDamageDealt
global function TitanSword_SlamHit_OnDamageDealt
global function TitanSword_Slam_DeathboxOverride
#endif

//Names
const string TITAN_SWORD_SLAM_READY_MOD = "slam_ready"
const string TITAN_SWORD_SLAM_MOD = "slam"

const string TITAN_SWORD_LOOT_MOVER_SCRIPTNAME = "titan_sword_loot_mover"

//Playlist Vars

//Signals
global const string SIG_TITAN_SWORD_SLAM_ACTIVATED = "TitanSword_SlamActivated"
global const string SIG_TITAN_SWORD_SLAM_LANDED = "TitanSword_SlamLanded"


//DEBUG
const bool TITAN_SWORD_LOS_DEBUG = false

//Vars
const int TITAN_SWORD_SLAM_DISABLED_WEAPON_TYPES = WPT_ULTIMATE | WPT_TACTICAL | WPT_CONSUMABLE

//VFX
const asset VFX_TITAN_SWORD_SLAM = $"P_pilot_swd_slam_shockwave" //P_armored_leap_shockwave
const string VFX_TITAN_SWORD_SLAM_IMPACT = "pilot_sword_slam"
const TITAN_SWORD_FX_SLAM_ATK_FP = $"P_pilot_sword_swipe_slam_FP"
const TITAN_SWORD_FX_SLAM_ATK_3P = $"P_pilot_sword_swipe_slam_3P"
const asset VFX_TITAN_SWORD_SLAM_JETS = $"P_pilot_slam_thrusters"


//SFX
const string SFX_TITAN_SWORD_SLAM_ACTIVATED_1P = "titansword_special_slam_activate_1p"
const string SFX_TITAN_SWORD_SLAM_AIR_1P = "titansword_special_slam_air_1p"
const string SFX_TITAN_SWORD_SLAM_AIR_3P = "titansword_special_slam_air_3p"


struct
{
	#if SERVER
		table<entity, array<entity> > slamVictims
	#endif

	#if CLIENT
		bool slamHintActive = false
	#endif
}file

void function MpWeaponTitanSword_Slam_Init()
{
	RegisterImpactTable( VFX_TITAN_SWORD_SLAM_IMPACT )

	PrecacheParticleSystem( VFX_TITAN_SWORD_SLAM )
	PrecacheParticleSystem( VFX_TITAN_SWORD_SLAM_JETS )


	PrecacheParticleSystem( TITAN_SWORD_FX_SLAM_ATK_FP )
	PrecacheParticleSystem( TITAN_SWORD_FX_SLAM_ATK_3P )

	RegisterSignal( SIG_TITAN_SWORD_SLAM_ACTIVATED )

	RegisterSignal( SIG_TITAN_SWORD_SLAM_LANDED )
}

void function TitanSword_Slam_StartVFX( entity weapon )
{
	//FX that need to play for the duration of the slam go here
	weapon.PlayWeaponEffect( TITAN_SWORD_FX_SLAM_ATK_FP, TITAN_SWORD_FX_SLAM_ATK_3P, "muzzle_flash" )
}

void function TitanSword_Slam_OnWeaponActivate( entity player, entity weapon )
{
	//if ( !HasCallback_PlayerLanded( player, OnPlayerSlamLand ) )
	//	AddCallback_PlayerLanded( player, OnPlayerSlamLand )

	#if SERVER
		TitanSword_RemoveModOnDrop( weapon, TITAN_SWORD_SLAM_READY_MOD )
		TitanSword_RemoveModOnDrop( weapon, TITAN_SWORD_SLAM_MOD )
		thread TitanSword_SlamDetection_Thread( player, weapon )
	#endif

	#if CLIENT
		thread TitanSword_SlamHint_Thread( player, weapon )
	#endif
}

void function TitanSword_Slam_OnWeaponDectivate( entity player, entity weapon )
{
	//if ( HasCallback_PlayerLanded( player, OnPlayerSlamLand ) )
	//	RemoveCallback_PlayerLanded( player, OnPlayerSlamLand )

	ClearSlamState( player, weapon, false )
}

void function TitanSword_Slam_ClearMods( entity weapon )
{
	//We do not clear this so the slam ready state can persist in between attacks
	//weapon.RemoveMod( TITAN_SWORD_SLAM_READY_MOD )
	if ( weapon.HasMod( TITAN_SWORD_SLAM_MOD ) )
	{
		weapon.RemoveMod( TITAN_SWORD_SLAM_MOD )
	}
}

//SLAM

/* SLAM NOTES

- Might incorporate some sort of directional aiming
- Try to make the top down more weighty

*/
bool function TitanSword_Slam_TrySlam( entity player, entity weapon )
{
	#if CLIENT
		if ( !InPrediction() )
			return false
	#endif

	if ( player.IsOnGround() )
		return false

	if ( !weapon.HasMod( TITAN_SWORD_SLAM_READY_MOD ) )
		return false

	if ( weapon.HasMod( TITAN_SWORD_SLAM_MOD ) )
		return true

	weapon.RemoveMod( TITAN_SWORD_SLAM_READY_MOD )

	TitanSword_Slam_StartVFX( weapon )

	thread Slam_Thread( player, weapon )

	return true
}

void function TitanSword_Slam_TrySlamAnimEvent( entity weapon )
{
	#if CLIENT
		if ( !InPrediction() )
			return
	#endif

	if ( !weapon.HasMod( TITAN_SWORD_SLAM_MOD ) )
		return

	printt( "SLAMMING" )

	entity player = weapon.GetWeaponOwner()

	if ( !IsValid( player ) )
		return

	float velZ = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "slam_vel_z" )
	//player.PlayerLaunch( <0, 0, velZ>, false )
}

#if SERVER
//Should also run client so we can change the 1P easier
void function TitanSword_SlamDetection_Thread( entity player, entity weapon )
{
	//This is currently its own thread so we can potentially have an indicator on the ground...
	//If not, we can just do this detection when player activates melee

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( SIG_TITAN_SWORD_DEACTIVATE )

	float heightRequired = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "slam_height_required" )

	OnThreadEnd(
		function() : ( weapon )
		{
			if ( IsValid( weapon ) )
			{
				if ( weapon.HasMod( TITAN_SWORD_SLAM_READY_MOD ) )
					weapon.RemoveMod( TITAN_SWORD_SLAM_READY_MOD )
			}
		}
	)

	while( true )
	{
		while( !CanSlam( player ) )
		{
			if ( weapon.HasMod( TITAN_SWORD_SLAM_READY_MOD ) )
				weapon.RemoveMod( TITAN_SWORD_SLAM_READY_MOD )
			WaitFrame()
		}

		while( CanSlam( player ) )
		{
			vector start = player.GetOrigin()
			vector end   = start + <0, 0, -10000>

			TraceResults result = TraceLine( start, end, [player], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE, player )

			float height = start.z - result.endPos.z

			//printt( "HEIGHT: " + height )

			if ( height >= heightRequired )
			{
				if ( !weapon.HasMod( TITAN_SWORD_SLAM_READY_MOD ) )
				{
					weapon.AddMod( TITAN_SWORD_SLAM_READY_MOD )
				}
			}
			else
			{
				//We can't remove this while we're not in prediction
				if ( weapon.HasMod( TITAN_SWORD_SLAM_READY_MOD ) )
				{
					weapon.RemoveMod( TITAN_SWORD_SLAM_READY_MOD )
				}
			}

			WaitFrame()
		}
	}
}
#endif

#if CLIENT
void function TitanSword_SlamHint_Thread( entity player, entity weapon )
{
	if ( !IsValid( player ) )
		return

	if ( !IsLocalViewPlayer( player ) )
		return

	if ( file.slamHintActive )
		return

	if ( !IsValid( weapon ) )
		return

	EndSignal( player, "BleedOut_OnStartDying" )
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )

	EndSignal( weapon, "OnDestroy" )
	EndSignal( weapon, SIG_TITAN_SWORD_DEACTIVATE )

	file.slamHintActive = true

	string[1] displayedHint = [""]

	float buildUp = -1

	OnThreadEnd(
		function() : (displayedHint)
		{
			if ( displayedHint[0] != "" )
				HidePlayerHint( displayedHint[0] )
			file.slamHintActive = false
		}
	)

	while( true )
	{
		string hint

		if ( CanSlam( player ) && weapon.HasMod( TITAN_SWORD_SLAM_READY_MOD ) && !weapon.HasMod( TITAN_SWORD_SLAM_MOD ) && !TitanSword_Block_IsBlocking( weapon ) )
		{
			if ( buildUp == -1 )
			{
				buildUp = Time() + 0.25
			}
			else if ( Time() > buildUp )
			{
				hint = "#WPN_TITAN_SWORD_SLAM_HINT_ALT"
			}
		}

		if ( hint != displayedHint[0] )
		{
			if ( displayedHint[0] != "" )
			{
				buildUp = -1
				HidePlayerHint( displayedHint[0] )
			}
			if ( hint != "" )
			{
				AddPlayerHint( 60.0, 0.0, $"", hint )
			}
			displayedHint[0] = hint
		}
		WaitFrame()
	}
}
#endif // #if CLIENT


bool function CanSlam( entity player )
{
	if ( player.IsOnGround() )
		return false

	if ( player.IsZiplining() )
		return false

	if ( StatusEffect_HasSeverity( player, eStatusEffect.in_space_elevator ) )
		return false

	return true
}

void function Slam_Thread( entity player, entity weapon )
{
	player.Signal( SIG_TITAN_SWORD_SLAM_ACTIVATED )

	player.EndSignal( SIG_TITAN_SWORD_SLAM_ACTIVATED )
	player.EndSignal( "JumpPadStart" )
	player.EndSignal( "JumpPadStart" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	//player.EndSignal( "PhaseTunnel_PhaseTunnelEntered" )
	//player.EndSignal( "OnSkywardAllyUse" )

	weapon.EndSignal( "OnDestroy" )
	//We shouldn't be allowed to deactivate the sword in the slam, but this is needed for the situations we do
	weapon.EndSignal( SIG_TITAN_SWORD_DEACTIVATE )

	TitanSword_SafelyAddAttackMod( weapon, TITAN_SWORD_SLAM_MOD )

	//player.PlayerLaunch( <0, 0, 200>, false )

	//Removes the double jump if we slam
	player.Signal( "JumpPad_GiveDoubleJump" )
	#if CLIENT
		if ( TitanSword_ClientPredictCheck( "slam" ) )
		{
			EmitSoundOnEntity( player, SFX_TITAN_SWORD_SLAM_ACTIVATED_1P )
		}
	#endif
	#if SERVER
		player.DisableWeaponTypes( TITAN_SWORD_SLAM_DISABLED_WEAPON_TYPES )

		//New slam, make sure victims are cleared
		if ( player in file.slamVictims )
			delete file.slamVictims[player]

		array<entity> movementEffects
		TitanSword_CreateJetDriveJetEffects( player, VFX_TITAN_SWORD_SLAM_JETS, movementEffects )

		EmitSoundOnEntityOnlyToPlayer( player, player, SFX_TITAN_SWORD_SLAM_AIR_1P )
		EmitSoundOnEntityExceptToPlayer( player, player, SFX_TITAN_SWORD_SLAM_AIR_3P )

		OnThreadEnd(
			function() : ( player, weapon, movementEffects )
			{
				if ( IsValid( player ) )
				{
					StopSoundOnEntity( player, SFX_TITAN_SWORD_SLAM_AIR_1P )
					StopSoundOnEntity( player, SFX_TITAN_SWORD_SLAM_AIR_3P )


					#if SERVER
						//Fix for R5DEV-554333
						//Clearing the slam state is not re-enabling weapon types if it's cleared in a way the player is no longer in melee
						if ( TitanSword_PostCopySanityCheck( "slam_enable_weapons" ) )
						{
							player.EnableWeaponTypes( TITAN_SWORD_SLAM_DISABLED_WEAPON_TYPES )
						}
					#endif
				}

				foreach ( entity effect in movementEffects )
				{
					if ( IsValid( effect ) )
						EffectStop( effect )
				}
				ClearSlamState( player, weapon, false )
			}
		)
	#endif

	wait 0.4 //0.5

	#if SERVER
		//Cut Jets at top
		foreach ( entity effect in movementEffects )
		{
			if ( IsValid( effect ) )
				EffectStop( effect )
		}
	#endif

	printt( "SHOULD SLAM NOW" )
	player.EndSignal( SIG_TITAN_SWORD_SLAM_LANDED )

	while( !player.IsOnGround() )
	{
		WaitFrame()
	}

	printt( "SLAM TOUCH GROUND" )
	OnPlayerSlamLand( player )
}

void function ClearSlamState( entity player, entity weapon, bool doLandAnim )
{
	if ( !IsValid( player ) )
		return

	if ( player.PlayerMelee_GetState() != PLAYER_MELEE_STATE_SLAM_ATTACK )
		return

	player.PlayerMelee_EndAttack()

	#if SERVER
		if ( !TitanSword_PostCopySanityCheck("slam_enable_weapons") )
		{
			player.EnableWeaponTypes( TITAN_SWORD_SLAM_DISABLED_WEAPON_TYPES )
		}
	#endif

	#if CLIENT
		if ( !InPrediction() )
			return
	#endif

	if ( !IsValid( weapon ) )
		return

	if ( weapon.IsInCustomActivity() )
		weapon.StopCustomActivity()

	if ( doLandAnim )
		weapon.StartCustomActivity( "ACT_VM_LAND_CUSTOM", WCAF_NONE )

	if ( IsValid( weapon ) )
		weapon.RemoveMod( TITAN_SWORD_SLAM_MOD )
}

void function OnPlayerSlamLand( entity player )
{
	printt( "SLAM LANDED!" )

	if ( player.PlayerMelee_GetState() != PLAYER_MELEE_STATE_SLAM_ATTACK )
		return

	entity weapon = TitanSword_GetMainWeapon( player )

	if ( !IsValid( weapon ) ) //How did this happen
	{
		player.PlayerMelee_EndAttack()
		player.Signal( SIG_TITAN_SWORD_SLAM_LANDED ) //Going through the signal exits prediction
		PlayRotatedImpactFXTable( player, player.GetOrigin(), AnglesToForward( player.GetAngles() ), VFX_TITAN_SWORD_SLAM_IMPACT )
		return
	}

	ClearSlamState( player, weapon, true )

	#if SERVER
		//TitanSword_CreateSlam( player, player.GetOrigin() )
		float upOffset = GetCurrentPlaylistVarFloat( "titan_sword_slam_offset", 10 )
		TitanSword_Slam_CreateSlam( player, weapon, player.GetOrigin() + <0, 0, upOffset> )
	#endif

	vector origin = player.GetOrigin()
	vector fwd    = AnglesToForward( player.GetAngles() )
	const float fwdImpactOffset = 50
	origin += Normalize( fwd ) * fwdImpactOffset
	PlayRotatedImpactFXTable( player, origin, AnglesToForward( player.GetAngles() ), VFX_TITAN_SWORD_SLAM_IMPACT, 0 )

	#if CLIENT
		StartParticleEffectInWorld( GetParticleSystemIndex( VFX_TITAN_SWORD_SLAM ), player.GetOrigin(), <0, 0, 0> )
	#endif

	player.Signal( SIG_TITAN_SWORD_SLAM_LANDED ) //Going through the signal exits prediction
}

#if SERVER
bool function TitanSword_SlamHasPlayerLOS( entity attacker, entity victim )
{
	//Ignore other players and the ward
	array<entity> ignoreEnts = GetPlayerArray_AliveConnected()
	ignoreEnts.append( victim )
	ignoreEnts.append( attacker )

	vector traceStart = attacker.GetWorldSpaceCenter()
	vector traceEnd   = victim.GetWorldSpaceCenter()

	TraceResults traceResults = TraceLine( traceStart, traceEnd, ignoreEnts, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )

	#if TITAN_SWORD_LOS_DEBUG
		DebugDrawLine( traceStart, traceEnd, <255, 1, 1>, true, 0.1 )
	#endif

	//We don't need the eye LOS I don't think
	/*if ( traceResults.fraction < 1.0 )
	{
		traceEnd     = victim.EyePosition()
		traceResults = TraceLine( traceStart, traceEnd, ignoreEnts, TRACE_MASK_SOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )
		#if TITAN_SWORD_LOS_DEBUG
			DebugDrawLine( traceStart, traceEnd, <255, 1, 1>, true, 0.1 )
		#endif
	}*/

	if ( traceResults.fraction == 1.0 )
	{
		#if TITAN_SWORD_LOS_DEBUG
			DebugDrawLine( traceStart, traceEnd, <1, 255, 1>, true, 10.0 )
		#endif
		return true
	}
	return false
}
#endif

#if SERVER
void function TitanSword_Slam_CreateSlam( entity owner, entity weapon, vector origin )
{
	float radiusInner = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "slam_radius_inner" )
	float radiusOuter = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "slam_radius_outer" )
	float forceMin    = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "slam_force_min" )
	float forceMax    = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "slam_force_max" )
	float damageMin   = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "slam_damage_min" )
	float damageMax   = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "slam_damage_max" )

	//View punch players and allies
	array<entity> players = GetPlayerArray_Alive()
	foreach ( entity player in players )
	{
		if ( !IsValid( player ) )
			continue

		if ( !(player.DoesShareRealms( owner )) )
			continue

		if ( player.IsPhaseShifted() )
			continue

		if ( !IsFriendlyTeam( owner.GetTeam(), player.GetTeam() ) )
			continue

		if ( owner == player )
		{
			player.ViewPunch( origin, 5, -5, 2 )
			continue
		}

		float distSqr = DistanceSqr( origin, player.GetOrigin() )
		if ( distSqr > (radiusOuter * radiusOuter) )
			continue

		if ( !TitanSword_SlamHasPlayerLOS( owner, player ) )
			continue

		player.ViewPunch( origin, 15, -15, 5 )
	}

	RadiusDamage(
		origin,
		owner,
		owner,
		damageMax,
		damageMax,
		radiusInner,
		radiusOuter,
		SF_ENVEXPLOSION_NO_DAMAGEOWNER,
		0,
		0,
		DF_RAGDOLL | DF_EXPLOSION,
		eDamageSourceId.mp_weapon_titan_sword_slam )

	entity fx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( VFX_TITAN_SWORD_SLAM ), origin, <0, 0, 0> )
	fx.SetOwner( owner )
	SetTeam( fx, owner.GetTeam() )
	fx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
	CopyRealmsFromTo( owner, fx )

	if ( owner in file.slamVictims )
		delete file.slamVictims[owner]
}

void function TitanSword_SlamHit_OnDamageDealt( entity attacker, entity victim, var damageInfo )
{
	entity weapon = DamageInfo_GetWeapon( damageInfo )

	if ( !IsValid( weapon ) )
		return

	if ( !weapon.HasMod( TITAN_SWORD_SLAM_MOD ) )
		return

	if ( !(attacker in file.slamVictims) )
		file.slamVictims[attacker] <- []

	if ( !file.slamVictims[attacker].contains( victim ) )
		file.slamVictims[attacker].append( victim )
}

void function TitanSword_Slam_OnDamageDealt( entity attacker, entity victim, var damageInfo )
{
	//Special condition for rev
	if ( victim.GetScriptName() == FORGED_SHADOWS_SHIELD_NAME && IsFriendlyTeam( attacker.GetTeam(), victim.GetTeam() ) )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	float dist = DamageInfo_GetDistFromExplosionCenter( damageInfo )

	float dmgScale = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "slam_damage_scale" )

	if ( attacker in file.slamVictims )
	{
		if ( file.slamVictims[attacker].contains( victim ) )
		{
			DamageInfo_SetDamage( damageInfo, floor( DamageInfo_GetDamage( damageInfo ) * dmgScale ) )
		}
	}

	TitanSword_Slam_ApplyKnockback( victim, attacker.GetOrigin(), dist )
}

void function TitanSword_Slam_ApplyKnockback( entity victim, vector origin, float distance )
{
	if ( !IsValid( victim ) )
		return

	if ( !victim.IsPlayer() && !IsTrainingDummie( victim ) && !IsCombatNPC( victim ) )
		return

	float radiusOuter = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "slam_radius_outer" )

	if ( distance > radiusOuter )
		return

	float radiusInner = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "slam_radius_inner" )
	float forceMin    = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "slam_force_min" )
	float forceMax    = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "slam_force_max" )

	vector originToPlayer = FlattenVec( Normalize( victim.GetCenter() - origin ) )

	float impulseForce = GraphCapped( distance, 0, radiusOuter, forceMax, forceMin )

	victim.SetVelocity( ZERO_VECTOR )
	vector currentVel = victim.GetVelocity()
	vector addedVel   = (originToPlayer + <0, 0, 0.5>) * impulseForce //1.05
	vector newVel     = currentVel + addedVel
	victim.SetVelocity( newVel )

	if ( victim.IsPlayer() )
		victim.ViewPunch( origin, 35, -35, 5 )
}
#endif

bool function TitanSword_Slam_VictimHitOverride( entity weapon, entity attacker, entity victim, vector velocity )
{
	if ( weapon.HasMod( TITAN_SWORD_SLAM_MOD ) )
	{
		if ( !IsFriendlyTeam( attacker.GetTeam(), victim.GetTeam() ) )
		{
			vector lookDirection = attacker.GetViewForward()
			lookDirection.z = 0
			lookDirection   = Normalize( lookDirection )

			vector knockback = lookDirection * 2000
			TitanSword_LaunchEntity( victim, <knockback.x, knockback.y, -2200> )
			return true
		}
	}

	return false
}

#if SERVER
//This is good for the DB but ragdoll should get knocked away too
bool function TitanSword_Slam_DeathboxOverride( entity box, entity attacker, entity owner )
{
	entity weapon = TitanSword_GetMainWeapon( attacker )
	if ( !IsValid( weapon ) )
		return false

	if ( weapon.HasMod( TITAN_SWORD_SLAM_MOD ) )
	{
		vector lookDirection = attacker.GetViewForward()
		lookDirection.z = 0
		lookDirection   = Normalize( lookDirection )

		vector knockback = lookDirection * 1600
		thread FakePhysicsThrow( owner, box, <knockback.x, knockback.y, -1800>, false )
		//TitanSword_Slam_VictimHitOverride( weapon, attacker, box, <0, 0, 0> )
		return true
	}

	//TitanSword_Slam_VictimHitOverride( weapon, attacker, deathBox, <0, 0, 0> )
	//

	return false
}
#endif

                                