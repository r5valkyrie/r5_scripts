global function MpAbilityExectioner_Init
global function PassiveRevenantRework_OnPassiveChanged
global function PassiveAssassinsInstinct_EntityShouldBeHighlighted

const float EXECUTIONER_WATCH_RANGE = 30 * METERS_TO_INCHES
const int EXECUTIONER_HEALTH_THRESHOLD = 40

const vector EXECUTIONER_WAYPOINT_OFFSET = <0, 0, 96>
const float EXECUTIONER_WAYPOINT_DURATION = 2.75

const float EXECUTIONER_WAYPOINT_AFTER_DAMAGE_WINDOW = 30.0
const float EXECUTIONER_WAYPOINT_DAMAGE_DELAY = 0.3
const float EXECUTIONER_DELTA_DAMAGE_TIME = 30.0

const asset FX_EXECUTIONER_WAYPOINT_TARGET = $"P_rev2_ar_target"

const string EXECUTIONER_MARKED_SOUND = "Revenant_Passive_WaypointAppear"

const asset EXECUTIONER_ICON = $"rui/hud/character_abilities/revenant_rework_marked"

#if SERVER
struct DamageLogInfo
{
	float totalDamage
	float lastDamageTime
	bool waypointSpawned
}

struct TrackingVisionData
{
	entity owner
	int statusID
}
#endif

struct
{
	#if SERVER
		table<entity, table< entity, DamageLogInfo > > damageLog
		table < entity, TrackingVisionData > trackingVisionData
		table < entity, int > currentTargets
	#endif
	#if CLIENT
		array< entity > currentHighlightTargets
	#endif

	// Live Tuning
	float highlightRange
	int highlightHealthThreshold
	float markDuration
	float markDamageWindow
	float markDamageDelay
	float markDeltaDamageTime
}file

void function MpAbilityExectioner_Init()
{
	PrecacheParticleSystem( FX_EXECUTIONER_WAYPOINT_TARGET )

	RegisterSignal( "EndExecutionerPassive" )
	RegisterSignal( "StopWatchingExecutionerVictim" )
	AddCallback_OnPassiveChanged( ePassives.PAS_REVENANT_REWORK, PassiveRevenantRework_OnPassiveChanged )

	// Live Tuning
	file.highlightRange = GetCurrentPlaylistVarFloat( "assassins_instinct_highlight_range", EXECUTIONER_WATCH_RANGE )
	file.highlightHealthThreshold = GetCurrentPlaylistVarInt( "assassins_instinct_highlight_health_threshold", EXECUTIONER_HEALTH_THRESHOLD )
	file.markDuration = GetCurrentPlaylistVarFloat( "assassins_instinct_mark_duration", EXECUTIONER_WAYPOINT_DURATION )
	file.markDamageWindow = GetCurrentPlaylistVarFloat( "assassins_instinct_mark_damage_window", EXECUTIONER_WAYPOINT_AFTER_DAMAGE_WINDOW )
	file.markDamageDelay = GetCurrentPlaylistVarFloat( "assassins_instinct_mark_damage_delay", EXECUTIONER_WAYPOINT_DAMAGE_DELAY )
	file.markDeltaDamageTime = GetCurrentPlaylistVarFloat( "assassins_instinct_mark_delta_damage_time", EXECUTIONER_DELTA_DAMAGE_TIME )

	#if SERVER
		AddDamageCallback( "player", OnPlayerTookDamage )
		Bleedout_AddCallback_OnPlayerStartBleedout( Executioner_BleedoutBegin )
		Bleedout_AddCallback_OnPlayerStopBleedout( Executioner_BleedoutEnd )
	#endif

	#if CLIENT
		StatusEffect_RegisterEnabledCallback( eStatusEffect.assassins_instinct, AssassinsInstinct_OnBeginHighlight )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.assassins_instinct, AssassinsInstinct_OnEndHighlight )
	#endif
}

void function PassiveRevenantRework_OnPassiveChanged( entity player, int passive, bool didHave, bool nowHas )
{
	if ( !IsAlive( player ) )
		return

	if ( nowHas )
	{
		#if SERVER
			if( Bleedout_IsBleedingOut( player ) )
			{
				                    
				if( !PlayerHasPassive( player, ePassives.PAS_PAS_UPGRADE_ONE ) )
          
					GivePlayerSettingsMods( player, [ "revenant_bleedout" ] )
			}

			thread ExecutionMonitor_Thread( player )
		#endif
	}

	else if ( didHave )
	{
		player.Signal( "EndExecutionerPassive" )
		#if SERVER
			if( Bleedout_IsBleedingOut( player ) && player.GetPlayerSettingsMods().contains( "revenant_bleedout" ) )
				TakePlayerSettingsMods( player, [ "revenant_bleedout" ] )
			if ( player in file.damageLog )
				delete file.damageLog[player]
		#endif
	}
}

#if SERVER
                    
float function Execution_UpgradeBleedoutRegenRate()
{
 	return GetCurrentPlaylistVarFloat( "execution_upgrade_bleedout_regen_rate", 3.0 )
}
      

void function Executioner_BleedoutBegin( entity player, entity attacker, var damageInfo )
{
	if ( !PlayerHasPassive( player, ePassives.PAS_REVENANT_REWORK ) )
		return

	                    
	if( PlayerHasPassive( player, ePassives.PAS_PAS_UPGRADE_ONE ) )
	{
		int regenSource = eRegenSource.STIM_PASSIVE
		float regenHealthPerSec = Execution_UpgradeBleedoutRegenRate()
		float regenStartDelay = GetPlaylistVar_HealthRegenDelay()

		thread HealthRegen_Thread( player, regenSource, regenHealthPerSec, 0.0, regenStartDelay, false )
		return
	}
       

	GivePlayerSettingsMods( player, [ "revenant_bleedout" ] )
}

void function Executioner_BleedoutEnd( entity player )
{
	if ( !PlayerHasPassive( player, ePassives.PAS_REVENANT_REWORK ) )
		return
	if( player.GetPlayerSettingsMods().contains( "revenant_bleedout" ) )
		TakePlayerSettingsMods( player, [ "revenant_bleedout" ] )

	                    
		HealthRegen_End( player )
       
}

void function ExecutionMonitor_Thread( entity player )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if( !IsValid( player ) )
		return

	EndSignal( player, "OnDeath", "OnDestroy", "EndExecutionerPassive" )

	OnThreadEnd(
		function() : ()
		{
			foreach ( entity enemy, int effectHandle in file.currentTargets )
			{
				if( IsValid( enemy ) )
					StatusEffect_Stop( enemy, effectHandle )
			}
			file.currentTargets.clear()
		}
	)

	while( true )
	{
		// Check if we should mark damaged enemies
		if( player in file.damageLog )
		{
			foreach( entity enemy, DamageLogInfo damageInfo in file.damageLog[player] )
			{
				if( DoesPlayerPassExecutionerChecks( player, enemy ) )
				{
					float damageDeltaTime = Time() - file.damageLog[player][enemy].lastDamageTime
					if ( damageDeltaTime <= file.markDamageWindow )
					{
						if( damageDeltaTime > file.markDamageDelay )
						{
							if ( !file.damageLog[player][enemy].waypointSpawned )
							{
								file.damageLog[player][enemy].waypointSpawned = true
								MarkExecutionerTarget( player, enemy )
								EmitSoundOnEntityToTeam( enemy, EXECUTIONER_MARKED_SOUND, player.GetTeam() )
							}
						}
					}
					else
					{
						file.damageLog[player][enemy].waypointSpawned = false
					}
				}
			}
		}

		// Check if targets are in range for us to highlight
		array<entity> enemiesInRange = GetAllEnemiesInRange( player )

		table< entity, int > lastFrameTargets = clone file.currentTargets

		foreach( enemy in enemiesInRange )
		{
			if( !IsValid( enemy ) )
				continue

			if( !StatusEffect_HasSeverity( enemy, eStatusEffect.assassins_instinct ) )
			{
				if( DoesPlayerPassExecutionerChecks( player, enemy ) )
				{
					file.currentTargets[ enemy ] <- StatusEffect_AddEndless( enemy, eStatusEffect.assassins_instinct, 1.0 )
				}
			}
			else
			{
				if( !DoesPlayerPassExecutionerChecks( player, enemy ) )
				{
					if( enemy in file.currentTargets )
					{
						if ( IsValid( enemy ) )
							StatusEffect_Stop( enemy, file.currentTargets[ enemy ] )

						delete file.currentTargets[ enemy ]
					}
				}
			}
		}

		foreach( entity enemy, int effectHandle in lastFrameTargets)
		{
			if( !IsValid( enemy ) )
			{
				delete file.currentTargets[ enemy ]
				continue
			}

			if ( enemy == player )
				continue

			bool inRange = enemiesInRange.contains( enemy )
			bool inCurrentTargetList = ( enemy in file.currentTargets )

			if( !inRange && inCurrentTargetList && StatusEffect_HasSeverity( enemy, eStatusEffect.assassins_instinct ))
			{
				StatusEffect_Stop( enemy, file.currentTargets[ enemy ] )
				delete file.currentTargets[ enemy ]
			}
		}

		WaitFrame()
	}
}

array<entity> function GetAllEnemiesInRange( entity player )
{
	array<entity> enemyPlayers

	array< entity > enemies = GetPlayerArray_Alive()
	// Get all enemy players and check if they are in range
	foreach( entity enemy in enemies )
	{
		if( enemy == player )
			continue
		if( IsFriendlyTeam( player.GetTeam(), enemy.GetTeam() ) )
			continue

		if( IsEnemyInRange( player, enemy ) )
			enemyPlayers.append( enemy )
	}

	//For firing range, we manually get the dummies and add them to our results.
	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
	{
		array<entity> dummies = GetEntArrayByScriptName( FIRING_RANGE_DUMMIE_SCRIPT_NAME )

		foreach ( entity dummy in dummies )
		{
			if ( !IsAlive( dummy ) )
				continue

			if( IsEnemyInRange( player, dummy ) )
				enemyPlayers.append( dummy )
		}
	}

	// Then we get any decoys
	array<entity> decoys = GetEntArrayByScriptName( DECOY_SCRIPTNAME )
	decoys.extend( GetEntArrayByScriptName( CONTROLLED_DECOY_SCRIPTNAME ) )
	foreach ( entity decoy in decoys )
	{
		if ( !IsValid( decoy ) )
			continue
		if ( IsFriendlyTeam( decoy.GetTeam(), player.GetTeam() ) )
			continue

		if( IsEnemyInRange( player, decoy ) )
			enemyPlayers.append( decoy )
	}

	return enemyPlayers
}

bool function IsEnemyInRange( entity player, entity target )
{
	if( !IsValid( player ) || !IsValid( target ) )
		return false

	float distanceSqr = DistanceSqr( player.EyePosition(), target.GetWorldSpaceCenter() )
	if ( distanceSqr <= pow( file.highlightRange, 2 ) )
		return true

	return false
}

void function MarkExecutionerTarget( entity player, entity target )
{
	if ( !IsAlive( player ) || !IsAlive( target ) )
		return

	if ( PlayerHasPassive( player, ePassives.PAS_REVENANT_REWORK ) )
	{
		thread ExecutionerWaypoint_Thread( player, target )
		StatsHook_RevenantPassiveMarkedEnemies( player )
	}
}

void function ExecutionerWaypoint_Thread( entity player, entity target )
{
	Assert ( IsNewThread(), "Must be threaded off" )

	EndSignal( target, "OnDeath", "OnDestroy", "BleedOut_OnStartDying" )

	// VFX for Rev
	entity markFX = StartParticleEffectOnEntity_ReturnEntity( target, GetParticleSystemIndex( FX_EXECUTIONER_WAYPOINT_TARGET ), FX_PATTACH_POINT_FOLLOW_NOROTATE, target.LookupAttachment( "CHESTFOCUS" ) )
	SetTeam( markFX, player.GetTeam() )
	markFX.SetOwner( player )
	markFX.SetVisibilityFlags( ENTITY_VISIBLE_TO_OWNER )

	// Waypoint for Team
	array< entity > wpTargets
	array< entity > revTeam = GetPlayerArrayOfTeam_Alive( player.GetTeam() )
	foreach( entity teammate in revTeam )
	{
		if( teammate == player )
			continue
		entity wpTarget = CreateWaypoint_BasicPos( target.GetOrigin() + EXECUTIONER_WAYPOINT_OFFSET, "", EXECUTIONER_ICON )
		wpTarget.SetOnlyTransmitToOnePlayer( teammate )
		wpTargets.append( wpTarget )
	}

	OnThreadEnd(
		function() : ( markFX, wpTargets )
		{
			if ( IsValid( markFX ) )
			{
				EffectStop( markFX )
				markFX.Destroy()
			}
			foreach( target in wpTargets)
			{
				if( IsValid( target ) )
					target.Destroy()
			}
		}
	)

	float startTime = Time()
	while( ( Time() - startTime ) < file.markDuration )
	{
		if( target.IsPhaseShifted() || target.IsCloaked( true ) )
		{
			markFX.SetVisibilityFlags( ENTITY_VISIBLE_TO_NOBODY )
		}
		else
		{
			markFX.SetVisibilityFlags( ENTITY_VISIBLE_TO_OWNER )
		}

		WaitFrame()
	}
}

void function OnPlayerTookDamage( entity damagedEnt, var damageInfo )
{
	if ( !IsValid( damagedEnt ) )
		return

	if ( !damagedEnt.IsPlayer() )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !IsValid( attacker ) )
		return

	if ( !attacker.IsPlayer() )
		return

	if ( PlayerHasPassive( attacker, ePassives.PAS_REVENANT_REWORK ) )
	{
		// Update damage log
		if ( !( attacker in file.damageLog ) )
		{
			table<entity, DamageLogInfo> data
			file.damageLog[ attacker ] <- data
		}

		float damage = DamageInfo_GetDamage( damageInfo )

		if ( damagedEnt in file.damageLog[attacker] )
		{
			float deltaDamageTime = Time() - file.damageLog[attacker][damagedEnt].lastDamageTime

			//if we haven't damaged them in a while, reset the count.
			if ( deltaDamageTime <= file.markDeltaDamageTime )
				file.damageLog[attacker][damagedEnt].totalDamage += damage
			else
				file.damageLog[attacker][damagedEnt].totalDamage = damage

			file.damageLog[attacker][damagedEnt].lastDamageTime = Time()
		}
		else
		{
			DamageLogInfo data
			data.lastDamageTime = Time()
			data.totalDamage = damage
			data.waypointSpawned = false

			file.damageLog[attacker][damagedEnt] <- data
		}
	}
}
#endif

bool function DoesPlayerPassExecutionerChecks( entity player, entity target )
{
	if ( !IsAlive( target ) )
		return false

	if( target == player )
		return false

	if ( target.IsPhaseShifted() )
		return false

	if( Bleedout_IsBleedingOut( target ) )
		return false

	if ( DoesPlayerPassExecutionHealthCheck( target ) )
		return true

	return false
}

bool function DoesPlayerPassExecutionHealthCheck( entity player )
{
	int shieldValue = GetEntityShieldValue( player )
	int healthValue = GetEntityHealthValue( player )

	int totalHealth = shieldValue + healthValue

	if ( ( totalHealth > 0 ) && ( totalHealth <= file.highlightHealthThreshold ) )
		return true

	return false
}

int function GetEntityHealthValue( entity ent )
{
	if ( !IsValid( ent ) )
		return 0

	int victimHealth = 100

	if ( ent.IsPlayerDecoy() )
	{
		entity decoyOwner = ent.GetOwner()

		if ( IsValid( decoyOwner ) )
			victimHealth = decoyOwner.GetHealth()
	}
	else
		victimHealth = ent.GetHealth()

	return victimHealth
}

int function GetEntityShieldValue( entity ent )
{
	if ( !IsValid( ent ) )
		return 0

	int victimShields = 0

	if ( ent.IsPlayerDecoy() )
	{
		entity decoyOwner = ent.GetOwner()

		if ( IsValid( decoyOwner ) )
			victimShields = decoyOwner.GetShieldHealth()
	}
	else
		victimShields = ent.GetShieldHealth()

	return victimShields
}

#if CLIENT
void function AssassinsInstinct_OnBeginHighlight( entity highlightTarget, int statusEffect, bool actuallyChanged )
{
	if( !IsValid( highlightTarget ) )
		return

	if( file.currentHighlightTargets.contains( highlightTarget ) )
		return

	thread AssassinsInstinct_HighlightThink( highlightTarget )

	file.currentHighlightTargets.append( highlightTarget )
}

void function AssassinsInstinct_OnEndHighlight( entity highlightTarget, int statusEffect, bool actuallyChanged )
{
	if( !IsValid( highlightTarget ) )
		return

	highlightTarget.Signal( "StopWatchingExecutionerVictim" )
}

void function AssassinsInstinct_HighlightThink( entity targetPlayer )
{
	if ( !IsValid( targetPlayer ) )
		return

	targetPlayer.EndSignal( "EndExecutionerPassive" )
	EndSignal( targetPlayer, "OnDeath", "OnDestroy", "StopWatchingExecutionerVictim" )

	ManageHighlightEntity( targetPlayer )

	OnThreadEnd(
		function() : ( targetPlayer )
		{
			if ( IsValid( targetPlayer ) )
			{
				ManageHighlightEntity( targetPlayer )
				file.currentHighlightTargets.fastremovebyvalue( targetPlayer )
			}
		}
	)

	while( StatusEffect_HasSeverity( targetPlayer, eStatusEffect.assassins_instinct ) )
	{
		WaitFrame()
	}
}
#endif

bool function PassiveAssassinsInstinct_EntityShouldBeHighlighted( entity viewPlayer, entity target )
{
	#if CLIENT
		if ( StatusEffect_HasSeverity( target, eStatusEffect.assassins_instinct ) )
		{
			float distanceSqr = DistanceSqr( viewPlayer.EyePosition(), target.GetWorldSpaceCenter() )
			if( distanceSqr > pow( file.highlightRange, 2 ) )
				return false

			return true
		}
	#endif

	return false
} 