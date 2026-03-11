#if SERVER || CLIENT
global function ShFRC_p2020_Init
#endif

const vector CHALLENGE_ORIGIN = < 31914.67, -5707.44, -29218.94 >
const float CHALLENGE_SPAWN_RADIUS = 225.0
const array<vector> SMOKE_COORDINATES = [ <31899.125, -5695.9375, -29216.0938>, <31900.7813, -5902, -29224.2188>, <31897.1875, -5492.5625, -29214.375> ]

struct ChallengeData
{
	entity npc = null
}

struct
{
	table< int, ChallengeData > challengeDataByRealm
} file

#if SERVER || CLIENT
void function ShFRC_p2020_Init()
{
	if ( GetMapName() != "mp_rr_canyonlands_staging" ) //keeping it broad for testing with dev playlists
		return

	if ( !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		return

	if ( !FRC_IsEnabled() )
		return

	FiringRangeChallengeRegistrationData data
	data.challengeKey = "mp_weapon_semipistol_challenge"
	data.gunRackOrigin = <31218.45, -5631.31, -29235.98>
	data.gunRackAngles = <0, 180, 0>
	data.gunRackScriptName = "gunrack_model3"
	data.weaponRef = "mp_weapon_semipistol"
	data.weaponMods = [ "optic_cq_threat", "bullets_mag_l4", "hopup_unshielded_dmg" ]
	data.weaponMdl = $"mdl/weapons/p2011/w_p2011.rmdl"
	data.challengeTime = 60.0
	data.challengeType = eFiringRangeChallengeType.FR_CHALLENGE_TYPE_BEST_DAMAGE
	data.statTemplate = CAREER_STATS.s12e04_challenge_3
	data.challengeName = "#FRC_CHALLENGE_3_NAME"
	data.challengeInteractStr = "#FRC_CHALLENGE_3_INTERACT"
	data.challengeStartHint = "#FR_CHALLENGE_DUMMIE_HINT"
	data.rewardTracker = $"settings/itemflav/gcard_tracker/frc_challenge3_score.rpak"

	data.borderName = "frc_challenge3_border"
	data.borderType = 1
	data.outOfBoundsTriggerScriptName = "frc_challenge3_trigger"

	data.playerTeleportPosition = < 31338,  -5733.5, -29224 >
	data.squadSafePosition = [<31240.2, -6096.4, -29235.9>, <31226.7, -5358.7, -29235.8>]

	#if SERVER
		data.challengeSetupFunc = SetupChallenge
		data.challengeStartFunc = StartChallenge
		data.challengeCleanUpFunc = ClearChallenge
	#endif

	FRC_RegisterChallenge( "mp_weapon_semipistol_challenge", data )

	RegisterSignal("ChallengeTargetDamaged")
	PrecacheScriptString( "mp_weapon_semipistol_challenge" )
	PrecacheScriptString( BANGALORE_SMOKESCREEN_SCRIPTNAME )
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

	thread StartChallengeThink( player, realm )
}

void function ClearChallenge( int realm )
{
	if ( !(realm in file.challengeDataByRealm) )
		return

	if ( IsValid ( file.challengeDataByRealm[realm].npc ) )
		file.challengeDataByRealm[realm].npc.Destroy()

	delete file.challengeDataByRealm[realm]
}

void function StartChallengeThink( entity player, int realm )
{
	if ( !IsValid ( player ) )
		return

	EndSignal( player, "OnDestroy" )
	EndSignal( player, "FRChallengeEnded" )
	#if DEVELOPER
		EndSignal( player, "DEV_EndChallenge" )
	#endif

	entity npc = SpawnNPCTrainingDummy( CHALLENGE_ORIGIN, <0, 180, 0>, 0 )
	npc.RemoveFromAllRealms()
	npc.AddToRealm( realm )
	npc.SetHealth( 1 )
	npc.SetShieldHealth( 0 )
	AddEntityCallback_OnPostDamaged ( npc, ChallengeDummie_OnPostDamaged )

	OnThreadEnd(
		function() : ( npc )
		{
				if ( IsValid(npc) )
					npc.Destroy()
		} )

	WaitSignal( npc, "OnDeath", "OnDestroy"  )

	FRC_UpdateState ( player,  eFiringRangeChallengeState.FR_CHALLENGE_ACTIVE )
}

void function CreateChallengeCombatDummie( entity player, int realm )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "FRChallengeEnded" )

	float movingTargetTime = 30.0 + Time()

	while ( true )
	{
		vector origin = GetRandomPointInCircle( CHALLENGE_ORIGIN, CHALLENGE_SPAWN_RADIUS )

		if ( !(realm in file.challengeDataByRealm) )
		{
			break
		}

		if ( Time() <= movingTargetTime )
		{
			file.challengeDataByRealm[realm].npc = SpawnNPCTrainingDummy( origin, <0, 180, 0>, 1 )
		}
		else
		{
			file.challengeDataByRealm[realm].npc = SpawnNPCCombatDummie( origin, <0, 180, 0>, 0 )
			file.challengeDataByRealm[realm].npc.EnableBehavior( "Assault" )
			file.challengeDataByRealm[realm].npc.AssaultPointClampedExtents( CHALLENGE_ORIGIN, <64, 64, 64> )
			file.challengeDataByRealm[realm].npc.AssaultSetGoalRadius( 320 )
			file.challengeDataByRealm[realm].npc.AssaultSetArrivalTolerance( 320 )
			file.challengeDataByRealm[realm].npc.AssaultSetGoalHeight(10000)
			file.challengeDataByRealm[realm].npc.EnableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING | NPC_MUTE_TEAMMATE )
			file.challengeDataByRealm[realm].npc.SetAlert()
		}

		file.challengeDataByRealm[realm].npc.SetScriptName( "mp_weapon_semipistol_challenge" )
		file.challengeDataByRealm[realm].npc.RemoveFromAllRealms()
		file.challengeDataByRealm[realm].npc.AddToRealm( realm )

		AddEntityCallback_OnPostDamaged ( file.challengeDataByRealm[realm].npc, ChallengeDummie_OnPostDamaged )
		AddEntityCallback_OnPostShieldDamage ( file.challengeDataByRealm[realm].npc, ChallengeDummie_OnPostShieldDamage )
		WaitSignal( file.challengeDataByRealm[realm].npc, "OnDeath", "OnDestroy"  )
	}
}


void function StartChallenge( entity player )
{
	thread ChallengeThink( player, player.GetRealms()[0] )
}

void function ChallengeThink( entity player, int realm )
{
	if ( !IsValid (player) )
		return

	EndSignal( player, "OnDestroy" )
	EndSignal( player, "FRChallengeEnded" )
	#if DEVELOPER
		EndSignal( player, "DEV_EndChallenge" )
	#endif

	table<string, bool> e
	e[ "challengeCompleted" ] <- false

	OnThreadEnd(
		function() : ( player, realm, e )
		{
			if ( e[ "challengeCompleted" ] )
				FRC_UpdateState ( player,  eFiringRangeChallengeState.FR_CHALLENGE_POST )
		} )

	thread CreateChallengeSmoke( player, realm )
	thread CreateChallengeCombatDummie( player, realm )
	wait 60.0
	e[ "challengeCompleted" ] = true
}

void function CreateChallengeSmoke( entity player, int realm )
{
	if ( !IsValid( player ) )
		return

	EndSignal( player, "OnDestroy" )
	EndSignal( player, "FRChallengeEnded" )

	for( int i = 0; i < SMOKE_COORDINATES.len(); i++ )
	{
		SmokescreenStruct smokescreen
		smokescreen.smokescreenFX = $"P_smokescreen_FD"
		smokescreen.origin = SMOKE_COORDINATES[i]
		smokescreen.angles = <0, 0, 0>
		smokescreen.fxOffsets = [ <0.0, 0.0, 0.0> ]
		smokescreen.traceBlockerTeam = player.GetTeam()
		smokescreen.traceBlockerScriptName = BANGALORE_SMOKESCREEN_SCRIPTNAME

		smokescreen.isElectric = false
		smokescreen.shouldHibernate = false
		smokescreen.lifetime = 60.0
		smokescreen.ownerTeam = TEAM_UNASSIGNED
		smokescreen.attacker = player
		smokescreen.inflictor = player
		smokescreen.blockLOS = true
		smokescreen.weaponOrProjectile = null
		smokescreen.damageInnerRadius = 320.0
		smokescreen.damageOuterRadius = 350.0
		smokescreen.damageDelay = 1.5
		smokescreen.dpsPilot = 0
		smokescreen.dpsTitan = 0
		smokescreen.deploySound1p = "bangalore_smoke_screen_3p"
		smokescreen.deploySound3p = "bangalore_smoke_screen_3p"
		smokescreen.stopSound1p = "bangalore_smoke_screen_stop_3p"
		smokescreen.stopSound3p = "bangalore_smoke_screen_stop_3p"
		Smokescreen( smokescreen, player )

		thread CreateSmokeTrigger ( player, smokescreen, realm )
	}
}

void function CreateSmokeTrigger( entity player, SmokescreenStruct smokescreen, int realm )
{
	if ( !IsValid( player ) )
		return

	EndSignal( player, "OnDestroy" )
	EndSignal( player, "FRChallengeEnded" )

	vector origin   = smokescreen.origin
	int radius      = int( smokescreen.damageOuterRadius / 1.5 )
	int aboveHeight = radius / 2
	int belowHeight = 0

	entity trigger = CreateTriggerCylinder( origin, radius, aboveHeight, belowHeight )
	trigger.RemoveFromAllRealms()
	trigger.AddToRealm( realm )

	trigger.SetEnterCallback( SmokeGrenadeTriggerEnter )
	trigger.SearchForNewTouchingEntity()  // set this to catch an entity in the trigger right away

	smokescreen.smokeTrigger = trigger
	EndSignal( trigger, "OnDestroy" )

	OnThreadEnd(
		function () : ( trigger )
		{
			if ( IsValid( trigger ) )
				trigger.Destroy()
		}
	)

	float timeToWait = smokescreen.lifetime + 3.0

	wait timeToWait
}

void function SmokeGrenadeTriggerEnter( entity trigger, entity ent )
{
	thread SmokeGrenadeTriggerTouchingThread( trigger, ent )
}

void function SmokeGrenadeTriggerTouchingThread( entity trigger, entity ent )
{
	EndSignal( trigger, "OnDestroy" )
	EndSignal( ent, "OnDestroy" )
	EndSignal( ent, "OnDeath" )

	if ( !ent.IsPlayer() )
		return

	if ( !ent.DoesShareRealms( trigger ) )
		return

	const TICK_RATE = 0.1

	OnThreadEnd(
		function() : ( ent )
		{
			float severity = StatusEffect_GetSeverity( ent, eStatusEffect.smokescreen )
			StatusEffect_StopAllOfType( ent, eStatusEffect.smokescreen )
			StatusEffect_AddTimed( ent, eStatusEffect.smokescreen, severity, 1.0, 1.0 )
		}
	)

	float radius           = 256.0 // S3: GetCylinderRadius() entity method not available at compile time
	float radiusSqr        = radius * radius
	int lastStatusEffectId = -1
	while( trigger.IsTouching( ent ) )
	{
		float distance = DistanceSqr( trigger.GetOrigin(), ent.GetOrigin() )
		float severity = GraphCapped( distance, 0, radiusSqr, 1, 0.25 )    // close to the center the more screen fx

		if ( lastStatusEffectId != -1 )
			StatusEffect_Stop( ent, lastStatusEffectId )
		lastStatusEffectId = StatusEffect_AddEndless( ent, eStatusEffect.smokescreen, severity )

		wait TICK_RATE
	}
}

void function ChallengeDummie_OnPostShieldDamage ( entity ent, var damageInfo, float actualShieldDamage )
{
	if ( !IsValid( ent ) )
		return

	if ( DamageInfo_GetDamage( damageInfo ) <= 0 )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	table data
	data["attacker"] <- attacker

	if ( DamageInfo_GetDamageSourceIdentifier( damageInfo ) != eDamageSourceId.mp_weapon_semipistol )
	{
		return
	}

	if ( attacker.IsPlayer() )
	{
		FRC_UpdateScore( attacker, int(actualShieldDamage), DamageInfo_GetHitGroup( damageInfo ) )
	}
}

void function ChallengeDummie_OnPostDamaged( entity ent, var damageInfo )
{
	if ( !IsValid( ent ) )
		return

	if ( DamageInfo_GetDamage( damageInfo ) <= 0 )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	table data
	data["attacker"] <- attacker

	if ( DamageInfo_GetDamageSourceIdentifier( damageInfo ) != eDamageSourceId.mp_weapon_semipistol )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	if ( attacker.IsPlayer() )
	{
		FRC_UpdateScore( attacker, int(DamageInfo_GetDamage( damageInfo )), DamageInfo_GetHitGroup( damageInfo ) )
	}
}
#endif