#if SERVER || CLIENT
global function ShFRC_G7Scout_Init
#endif

const asset TARGET_SPINNING_BASE = $"mdl/barriers/shooting_range_target_02_stand.rmdl"
const asset TARGET_SPINNING_MODEL = $"mdl/barriers/shooting_range_target_02.rmdl"
const vector STARTING_TARGET_ORIGIN = <32126, -6696, -29018>

const string G7_CHALLENGE_TARGET_MOVER_SCRIPTNAME = "g7_challenge_target_mover"

struct ChallengeData
{
	array< entity > activeTargets
	array< entity > targets

	int targetsHit = 0
	int damageDone = 0
	int critShots = 0
}

struct
{
	table< int, ChallengeData > challengeDataByRealm
} file

#if SERVER || CLIENT
void function ShFRC_G7Scout_Init()
{
	if ( GetMapName() != "mp_rr_canyonlands_staging" ) //keeping it broad for testing with dev playlists
		return

	if ( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		return

	if ( !FRC_IsEnabled() )
		return

	FiringRangeChallengeRegistrationData data
	data.challengeKey = "mp_weapon_g2_challenge"
	data.gunRackOrigin = <30712.15, -6688.12, -29163.97>
	data.gunRackAngles = <0, 180, 0>
	data.gunRackScriptName = "gunrack_model1"
	data.weaponRef = "mp_weapon_g2"
	data.weaponMods = [ "optic_cq_hcog_bruiser", "bullets_mag_l3", "barrel_stabilizer_l3", "stock_sniper_l3" ]
	data.weaponMdl = $"mdl/techart/mshop/weapons/class/assault/g7/g7_base_w.rmdl"
	data.challengeTime = 60.0
	data.challengeType = eFiringRangeChallengeType.FR_CHALLENGE_TYPE_TARGETS_HIT
	data.statTemplate = CAREER_STATS.s12e04_challenge_1
	data.challengeName = "#FRC_CHALLENGE_1_NAME"
	data.challengeInteractStr = "#FRC_CHALLENGE_1_INTERACT"
	data.challengeStartHint = "#FR_CHALLENGE_TARGET_HINT"
	data.rewardTracker = $"settings/itemflav/gcard_tracker/frc_challenge1_score.rpak"

	data.playerTeleportPosition = <30885.4, -6689.3, -29164>
	data.squadSafePosition = [<30564.6, -6463.7, -29152.87>, <30550.2, -6972.4, -29160.6>]

	data.borderName = "frc_challenge1_border"
	data.borderType = 0
	data.outOfBoundsTriggerScriptName = "frc_challenge1_trigger"

	#if SERVER
	data.challengeSetupFunc = SetupChallenge
	data.challengeStartFunc = StartChallenge
	data.challengeCleanUpFunc = ClearChallenge
	#endif

	FRC_RegisterChallenge( "mp_weapon_g2_challenge", data )

	RegisterSignal("ChallengeTargetDamaged")
	PrecacheScriptString( "mp_weapon_g2_challenge" )
}
#endif

#if SERVER
void function SetupChallenge( entity player )
{
	if ( !IsValid( player ) )
		return

	int realm = player.GetRealms()[0]
	if ( !(realm in file.challengeDataByRealm) )
	{
		ChallengeData data
		file.challengeDataByRealm[realm] <- data
	}

	foreach ( ent in GetEntArrayByScriptName( "frc_challenge1_target" ) )
	{
		CreateChallengeTarget( ent, realm, player )
	}


}

void function ClearChallenge( int realm )
{
	if ( !(realm in file.challengeDataByRealm) )
		return

	delete file.challengeDataByRealm[realm]
}

void function CreateChallengeTarget( entity ent, int realm, entity player )
{
	if ( !IsValid ( ent ) )
		return

	entity targetMover
	entity targetGeo
	vector anglesReady  = < 0, 0, 0 >
	vector anglesShot   = < 0, 0, 0 >
	float rotateDuration = 0.0
	vector origin = ent.GetOrigin()

	entity targetBase = CreateScriptMoverModel( TARGET_SPINNING_BASE, origin, ent.GetAngles(), SOLID_VPHYSICS, 50000 )
	targetBase.RemoveFromAllRealms()
	targetBase.AddToRealm( realm )

	FRC_AddCleanupEnt( targetBase, realm )

	origin = OffsetPointRelativeToVector( origin, < 0, 0, 128 >, ent.GetForwardVector() )

	targetMover = CreateScriptMover_NEW( G7_CHALLENGE_TARGET_MOVER_SCRIPTNAME, origin, ent.GetAngles() )
	targetMover.NonPhysicsSetRotateModeLocal( true )
	targetMover.SetParent( targetBase, "", true )

	targetGeo = CreatePropDynamic( TARGET_SPINNING_MODEL, origin, ent.GetAngles(), SOLID_OBB, 50000 )
	targetGeo.SetScriptName( "mp_weapon_g2_challenge" )

	entity collision = CreatePropDynamic( TARGET_SPINNING_MODEL, origin, ent.GetAngles(), SOLID_VPHYSICS, 50000, false )
	collision.kv.collisionGroup = TRACE_COLLISION_GROUP_PLAYER
	DispatchSpawn( collision )

	collision.SetParent( targetGeo )
	collision.Hide()
	collision.RemoveFromAllRealms()
	collision.AddToRealm( realm )

	anglesReady = targetMover.GetLocalAngles()
	anglesShot = AnglesCompose( targetMover.GetLocalAngles(), < 180, 0, 0 > )

	Assert( IsValid( targetGeo ) )
	Assert( IsValid( targetMover ) )

	targetGeo.SetParent( targetMover, "", true )
	targetMover.SetPusher( true )

	targetGeo.RemoveFromAllRealms()
	targetGeo.AddToRealm( realm )
	targetMover.RemoveFromAllRealms()
	targetMover.AddToRealm( realm )

	AddEntityCallback_OnPostDamaged( targetGeo, ChallengeTargetEntity_OnDamaged )

	targetGeo.e.preventStickyEnts = true
	targetMover.SetLocalAngles( anglesShot )
	targetGeo.e.isDisabled = true

	FRC_AddCleanupEnt( targetGeo, realm  )
	FRC_AddCleanupEnt( targetMover, realm  )

	file.challengeDataByRealm[ realm ].targets.append( targetGeo )

	if ( DistanceSqr( origin, STARTING_TARGET_ORIGIN ) < 0.1 )
		thread StartChallengeThink( targetGeo,  player,  realm, false )

	printt("[CreateChallengeTarget] DistanceSqr( origin, STARTING_TARGET_ORIGIN ): " + DistanceSqr( origin, STARTING_TARGET_ORIGIN ) + " origin: " + origin)
}

void function ChallengeTargetEntity_OnDamaged( entity ent, var damageInfo )
{
	if ( !IsValid( ent ) )
		return

	if ( DamageInfo_GetDamage( damageInfo ) <= 0 )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	table data
	data["attacker"] <- attacker

	ent.Signal( "ChallengeTargetDamaged", data )

	HandleLocationBasedDamage( ent, damageInfo )

	if ( attacker.IsPlayer() && !ent.e.isDisabled && DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.mp_weapon_g2 )
	{
		attacker.NotifyDidDamage(
			ent, DamageInfo_GetHitBox( damageInfo ),
			DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ),
			DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ),
			DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ),
			DamageInfo_GetDistFromAttackOrigin( damageInfo )
		)

		FRC_UpdateScore( attacker, int(DamageInfo_GetDamage( damageInfo )), DamageInfo_GetHitGroup( damageInfo ) )
	}
}

void function StartChallengeThink( entity target, entity player, int realm, bool destroyOnHit )
{
	if ( !IsValid( target ) || !IsValid( player ) )
		return

	EndSignal( target, "OnDestroy" )
	EndSignal( player, "OnDestroy" )
	#if DEVELOPER
		EndSignal( player, "DEV_EndChallenge" )
	#endif

	file.challengeDataByRealm[realm].activeTargets.append( target )
	thread ChallengeTargetThink ( target )
	WaitSignal( target, "ChallengeTargetDamaged" )
	FRC_UpdateState ( player,  eFiringRangeChallengeState.FR_CHALLENGE_ACTIVE )
}

void function StartChallenge( entity player )
{
	thread ChallengeThink( player, player.GetRealms()[0] )
}

void function ChallengeThink( entity player, int realm )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "FRChallengeEnded" )
	#if DEVELOPER
		EndSignal( player, "DEV_EndChallenge" )
	#endif

	table<string, bool> e
	e[ "challengeCompleted" ] <- false

	OnThreadEnd(
		function() : ( player, e )
		{
			if ( e[ "challengeCompleted" ] )
				FRC_UpdateState ( player,  eFiringRangeChallengeState.FR_CHALLENGE_POST )
		} )


	float endTime = Time() + 60.0
	while ( endTime >= Time() )
	{
		if ( ( realm in file.challengeDataByRealm ) && file.challengeDataByRealm[realm].activeTargets.len() < 3 )
		{
			// pick a new target.
			printt( "ChallengeThink - Less than 3" )
			entity target = file.challengeDataByRealm[realm].targets.getrandom()
			bool targetFound = false
			foreach ( entity activeTarget in file.challengeDataByRealm[realm].activeTargets )
			{
				if ( activeTarget == target )
				{
					targetFound = true
					break
				}
			}

			if ( !targetFound )
			{
				printt( "ChallengeThink - New Target" )
				file.challengeDataByRealm[realm].activeTargets.append( target )
				thread ChallengeTargetThink ( target )
			}
		}
		WaitFrame()
	}
	e[ "challengeCompleted" ] = true
}

void function ChallengeTargetThink( entity targetGeo )
{
	if ( !IsValid( targetGeo ) )
		return

	targetGeo.SetTakeDamageType( DAMAGE_EVENTS_ONLY )
	targetGeo.SetDamageNotifications( true )
	targetGeo.SetMaxHealth( 10000 )
	targetGeo.SetHealth( 10000 )

	entity targetMover = targetGeo.GetParent()

	if ( !IsValid( targetMover ) )
		return

	EndSignal( targetGeo, "OnDestroy" )
	EndSignal( targetMover, "OnDestroy" )

	targetGeo.e.isDisabled = false
	vector anglesReady = AnglesCompose( targetMover.GetLocalAngles(), < 180, 0, 0 > )
	targetMover.SetLocalAngles( anglesReady )

	table data = WaitSignal( targetGeo, "ChallengeTargetDamaged" )
	entity attacker = expect entity( data.attacker )

	if ( IsValid( attacker ) && attacker.IsPlayer() )
	{
		EmitSoundOnEntityOnlyToPlayer( targetGeo, attacker, "Canyonlands_Scr_RangeTarget_Hit_1P" )
		EmitSoundOnEntityExceptToPlayer( targetGeo, attacker, "Canyonlands_Scr_RangeTarget_Hit_3P" )
	}
	else
	{
		EmitSoundOnEntity( targetGeo, "Canyonlands_Scr_RangeTarget_Hit_3P" )
	}

	targetGeo.e.isDisabled = true
	vector anglesShot = AnglesCompose( targetMover.GetLocalAngles(), < 180, 0, 0 > )
	targetMover.SetLocalAngles( anglesShot )
	WaitFrame()

	int realm = targetGeo.GetRealms()[0]
	if ( realm in file.challengeDataByRealm )
		file.challengeDataByRealm[ realm ].activeTargets.removebyvalue( targetGeo )

	EmitSoundOnEntity( targetGeo, "Canyonlands_Scr_RangeTarget_Spin" )
	return
}
#endif