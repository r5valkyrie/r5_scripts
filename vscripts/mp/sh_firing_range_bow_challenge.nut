#if SERVER || CLIENT
global function ShFRC_Bow_Init
#endif

const asset TARGET_SPINNING_BASE = $"mdl/barriers/shooting_range_target_02_stand.rmdl"
const asset TARGET_SPINNING_MODEL = $"mdl/barriers/shooting_range_target_02.rmdl"
const vector TARGET_ORIGIN = <32390, -5678, -28953>
const vector TARGET_END = <TARGET_ORIGIN.x, -4654, TARGET_ORIGIN.z>

const float TRAVEL_LENGTH_1Q = ( TARGET_END.y - TARGET_ORIGIN.y ) / 4.0
const vector TRAVEL_1Q_POINT = <TARGET_ORIGIN.x, TARGET_ORIGIN.y + ( TRAVEL_LENGTH_1Q ), TARGET_ORIGIN.z>
const vector TRAVEL_MID_POINT = <TARGET_ORIGIN.x, TARGET_ORIGIN.y + ( 2 * TRAVEL_LENGTH_1Q ), TARGET_ORIGIN.z>
const vector TRAVEL_3Q_POINT = <TARGET_ORIGIN.x, TARGET_ORIGIN.y + ( 3 * TRAVEL_LENGTH_1Q ), TARGET_ORIGIN.z>

const array< vector > MOVE_TARGETS =[ TARGET_ORIGIN , TRAVEL_1Q_POINT, TRAVEL_MID_POINT , TRAVEL_3Q_POINT, TARGET_END]

const string BOW_CHALLENGE_TARGET_MOVER_SCRIPTNAME = "bow_challenge_target_mover"

struct NextMoveIndexData
{
	int nextIndex = -1
	bool changedDirections = false
}


struct ChallengeData
{
	entity target = null
}

struct
{
	table< int, ChallengeData > challengeDataByRealm
} file

#if SERVER || CLIENT
void function ShFRC_Bow_Init()
{
	if ( GetMapName() != "mp_rr_canyonlands_staging" ) //keeping it broad for testing with dev playlists
		return

	if ( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		return

	if ( !FRC_IsEnabled() )
		return

	FiringRangeChallengeRegistrationData data
	data.challengeKey = "mp_weapon_bow_challenge"
	data.gunRackOrigin = <30712.15, -5278.97, -29163.97>
	data.gunRackAngles = <0, 180, 0>
	data.gunRackScriptName = "gunrack_model2"
	data.weaponRef = "mp_weapon_bow"
	data.weaponMods = [ "optic_cq_holosight_variable", "hopup_shatter_rounds", "hopup_marksmans_tempo" ]
	data.weaponMdl = $"mdl/weapons/compound_bow/w_compound_bow.rmdl"
	data.challengeTime = 60.0
	data.challengeType = eFiringRangeChallengeType.FR_CHALLENGE_TYPE_BEST_DAMAGE
	data.statTemplate = CAREER_STATS.s12e04_challenge_2
	data.challengeName = "#FRC_CHALLENGE_2_NAME"
	data.challengeInteractStr = "#FRC_CHALLENGE_2_INTERACT"
	data.challengeStartHint = "#FR_CHALLENGE_TARGET_HINT"
	data.rewardTracker = $"settings/itemflav/gcard_tracker/frc_challenge2_score.rpak"

	data.borderName = "frc_challenge2_border"
	data.borderType = 0
	data.outOfBoundsTriggerScriptName = "frc_challenge2_trigger"

	data.playerTeleportPosition = <30840.5, -5287.0, -29164>
	data.squadSafePosition = [<30595.6, -5535.3, -29162.3>, <30593.2, -5073.2, -29138.2>]

	#if SERVER
		data.challengeSetupFunc = SetupChallenge
		data.challengeStartFunc = StartChallenge
		data.challengeCleanUpFunc = ClearChallenge
	#endif

	FRC_RegisterChallenge( "mp_weapon_bow_challenge", data )

	RegisterSignal("ChallengeTargetDamaged")
	PrecacheScriptString( "mp_weapon_bow_challenge" )
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

	CreateChallengeTarget( realm, player )
}

void function ClearChallenge( int realm )
{
	if ( !(realm in file.challengeDataByRealm) )
		return

	delete file.challengeDataByRealm[realm]
}

void function CreateChallengeTarget( int realm, entity player )
{
	if ( !IsValid( player ) )
		return

	entity targetMover
	entity targetGeo
	vector anglesReady  = < 0, 0, 0 >
	vector anglesShot   = < 0, 0, 0 >
	float rotateDuration = 0.0
	vector origin = TRAVEL_MID_POINT

	entity targetBase = CreateScriptMoverModel( TARGET_SPINNING_BASE, origin, <0, -180, 0 >, SOLID_VPHYSICS, 50000 ) // ent.GetAngles()
	targetBase.RemoveFromAllRealms()
	targetBase.AddToRealm( realm )

	FRC_AddCleanupEnt( targetBase, realm )

	origin = OffsetPointRelativeToVector( origin, < 0, 0, 128 >, <-1,0,0> ) // ent.GetForwardVector()

	targetMover = CreateScriptMover_NEW( BOW_CHALLENGE_TARGET_MOVER_SCRIPTNAME, origin, <0, -180, 0 > )
	targetMover.NonPhysicsSetRotateModeLocal( true )
	targetMover.SetParent( targetBase, "", true )

	targetGeo = CreatePropDynamic( TARGET_SPINNING_MODEL, origin, <0, -180, 0 >, SOLID_OBB, 50000 )
	targetGeo.SetScriptName( "mp_weapon_bow_challenge" )

	entity collision = CreatePropDynamic( TARGET_SPINNING_MODEL, origin, <0, -180, 0 >, SOLID_VPHYSICS, 50000, false )
	collision.kv.collisionGroup = TRACE_COLLISION_GROUP_PLAYER
	DispatchSpawn( collision )

	collision.SetParent( targetGeo )
	collision.Hide()
	collision.RemoveFromAllRealms()
	collision.AddToRealm( realm )

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
	targetMover.SetLocalAngles( anglesReady )
	targetGeo.e.isDisabled = false

	FRC_AddCleanupEnt( targetGeo, realm  )
	FRC_AddCleanupEnt( targetMover, realm  )

	file.challengeDataByRealm[ realm ].target = targetGeo

	thread StartChallengeThink( targetGeo,  player,  realm, false )
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

	if ( attacker.IsPlayer() && !ent.e.isDisabled && DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.mp_weapon_bow)
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

	EndSignal( player, "OnDestroy" )
	EndSignal( target, "OnDestroy" )
	#if DEVELOPER
		EndSignal( player, "DEV_EndChallenge" )
	#endif

	WaitSignal( target, "ChallengeTargetDamaged" )
	FRC_UpdateState ( player,  eFiringRangeChallengeState.FR_CHALLENGE_ACTIVE )
}

void function StartChallenge( entity player )
{
	thread ChallengeThink( player, player.GetRealms()[0] )
}

void function ChallengeThink( entity player, int realm )
{
	if ( !IsValid(player) )
		return

	EndSignal( player, "OnDestroy" )
	EndSignal( player, "FRChallengeEnded" )
	#if DEVELOPER
		EndSignal( player, "DEV_EndChallenge" )
	#endif

	if ( !IsValid(file.challengeDataByRealm[ realm ].target) )
		return

	EndSignal( file.challengeDataByRealm[ realm ].target, "OnDestroy" )

	table<string, bool> e
	e[ "challengeCompleted" ] <- false

	OnThreadEnd(
		function() : ( player, realm, e )
		{
			if ( e[ "challengeCompleted" ] )
				FRC_UpdateState ( player,  eFiringRangeChallengeState.FR_CHALLENGE_POST )
		} )


	thread MovingGunRangeTargetThink( file.challengeDataByRealm[ realm ].target, realm )

	wait 60.0
	e[ "challengeCompleted" ] = true
}

void function MovingGunRangeTargetThink( entity target, int realm )
{
	EndSignal( target, "OnDestroy" )

	entity targetMover = target.GetParent()
	if ( !IsValid ( targetMover ) )
		return

	EndSignal( targetMover, "OnDestroy" )

	entity targetBase = targetMover.GetParent()
	if ( !IsValid ( targetBase ) )
		return

	EndSignal( targetBase, "OnDestroy" )

	float moveDuration = Distance( TARGET_ORIGIN, TARGET_END ) / 100.0 //--> larger divisor makes targets faster
	float accelDecel = moveDuration * 0.25

	bool toEnd = false

	WaitFrame()
	if ( CoinFlip() )
		toEnd = true

	wait RandomFloat( 0.5 )

	targetBase.NonPhysicsMoveTo( toEnd ? TARGET_END : TARGET_ORIGIN, moveDuration / 2, accelDecel, accelDecel )
	toEnd = !toEnd
	wait (moveDuration / 2)
	moveDuration = moveDuration / 2
	accelDecel = accelDecel / 2
	targetBase.NonPhysicsMoveTo( toEnd ? TARGET_END : TARGET_ORIGIN, moveDuration, accelDecel, accelDecel )
	toEnd = !toEnd
	wait moveDuration
	moveDuration = moveDuration / 1.5
	accelDecel = accelDecel / 1.5
	targetBase.NonPhysicsMoveTo( toEnd ? TARGET_END : TARGET_ORIGIN, moveDuration, accelDecel, accelDecel )
	toEnd = !toEnd
	wait moveDuration
	thread MovingGunRangeRotatingThread( target, targetMover )
	float endingLoop = Time() + 10
	while ( Time() <= endingLoop )
	{
		targetBase.NonPhysicsMoveTo( toEnd ? TARGET_END : TARGET_ORIGIN, moveDuration, accelDecel, accelDecel )
		toEnd = !toEnd
		wait moveDuration
	}

	int currentMoveTargetIndex = toEnd ? 0 : (MOVE_TARGETS.len() - 1)
	int previousMoveTargetInex = toEnd ? (MOVE_TARGETS.len() - 1) : 0
	float changeDirectionProbability = 0.3
	float minDirectionChangeProbability = 0.3
	float deltaChangeProbability = 0.05
	float increaseProbability = Time() + 7.0

	while ( true )
	{
		NextMoveIndexData nextMoveIndexData = GetNextMoveTargetIndex( currentMoveTargetIndex, previousMoveTargetInex, changeDirectionProbability )
		targetBase.NonPhysicsMoveTo( MOVE_TARGETS[nextMoveIndexData.nextIndex], moveDuration/4, 0, 0)
		wait ( moveDuration / 4 )

		if ( Time() >= increaseProbability )
		{
			minDirectionChangeProbability += 0.1
			deltaChangeProbability += 0.05
			increaseProbability = Time() + 7.0
		}

		if ( nextMoveIndexData.changedDirections || nextMoveIndexData.nextIndex == 0 || nextMoveIndexData.nextIndex == 4 )
			changeDirectionProbability = deltaChangeProbability
		else
			changeDirectionProbability = min( changeDirectionProbability + deltaChangeProbability, minDirectionChangeProbability )
		
		previousMoveTargetInex = currentMoveTargetIndex
		currentMoveTargetIndex = nextMoveIndexData.nextIndex
	}
}

NextMoveIndexData function GetNextMoveTargetIndex( int currentIndex, int previousIndex, float probablityToChange )
{
	NextMoveIndexData data
	switch ( currentIndex )
	{
		case 0:
			data.nextIndex = 1
			break
		case 4:
			data.nextIndex = 3
			break
		case 1:
		case 2:
		case 3:
		{
			data.changedDirections = ( RandomFloat( 1.0 ) <= probablityToChange )
			data.nextIndex = currentIndex + (( !data.changedDirections ) ? currentIndex - previousIndex : previousIndex - currentIndex)
			break
		}
		default:
			break
	}

	return data
}

void function MovingGunRangeRotatingThread( entity target, entity targetMover )
{
	EndSignal( target, "OnDestroy" )
	EndSignal( targetMover, "OnDestroy" )

	while ( true )
	{
		wait RandomFloatRange( 2.0, 5.0 )
		vector anglesShot = AnglesCompose( targetMover.GetLocalAngles(), < 180, 0, 0 > )
		targetMover.SetLocalAngles( anglesShot )
		target.e.isDisabled = true

		wait 1.0

		vector anglesReady = AnglesCompose( targetMover.GetLocalAngles(), < 180, 0, 0 > )
		targetMover.SetLocalAngles( anglesReady )
		target.e.isDisabled = false
	}
}
#endif