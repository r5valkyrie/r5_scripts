global function MpAbilitySpikeStrip_Init
global function OnWeaponActivate_ability_spike_strip
global function OnWeaponDeactivate_ability_spike_strip
global function OnProjectileCollision_ability_spike_strip
global function OnWeaponTossReleaseAnimEvent_ability_spike_strip
global function OnWeaponPrimaryAttack_ability_spike_strip

#if SERVER
global function ClientCallback_TryPickupSpikeStrip
global function SpikeStrip_Start3PIdleFXAnimEvent
global function GetAllSpikeCores
#endif

#if CLIENT
global function OnClientAnimEvent_ability_spike_strip
#endif

//Assets
const asset SPIKE_STRIP_MUZZLE_FLASH_FP = $"P_wpn_mflash_bang_rocket_FP"
const asset SPIKE_STRIP_MUZZLE_FLASH_3P = $"P_wpn_mflash_bang_rocket"
const asset SPIKE_STRIP_ARM_FP = $"P_EMPTY_ferro"
const asset SPIKE_STRIP_CREATE_FX = $"P_EMPTY_ferro"
const asset SPIKE_STRIP_DESTROY_FX = $"P_ferro_tac_death_exp_SM"
const asset SPIKE_STRIP_SPIKE_DORMANT = $"mdl/fx/ferrofluid_tac_calm_side_01.rmdl"
const asset SPIKE_STRIP_SPIKE_L_CORNER_DORMANT = $"mdl/fx/ferrofluid_tac_calm_side_L.rmdl"
const asset SPIKE_STRIP_SPIKE_R_CORNER_DORMANT = $"mdl/fx/ferrofluid_tac_calm_side_R.rmdl"
const asset SPIKE_STRIP_SPIKE_L_CORNER_ACTIVE = $"mdl/fx/ferrofluid_tac_spike_side_L.rmdl"
const asset SPIKE_STRIP_SPIKE_R_CORNER_ACTIVE = $"mdl/fx/ferrofluid_tac_spike_side_R.rmdl"
const asset SPIKE_STRIP_SPIKE_ACTIVE = $"mdl/fx/ferrofluid_tac_spike_side_01.rmdl"
const asset SPIKE_STRIP_SPIKE_CORE_DORMANT = $"mdl/fx/ferrofluid_tac_calm_core_01.rmdl"
const asset SPIKE_STRIP_SPIKE_CORE_ACTIVE = $"mdl/fx/ferrofluid_tac_spike_core_01.rmdl"
const asset SPIKE_STRIP_CORE_DORMANT_FX = $"P_ferro_spike_main"
const asset SPIKE_STRIP_CORE_ACTIVE_FX = $"P_ferro_spike_main_active"
const asset SPIKE_STRIP_SPIKE_FX = $"P_EMPTY_ferro"
const asset SPIKE_STRIP_ORB_IDLE_3P_FX = $"P_ferro_tac_orb_idle_3p"

//Sounds
const string SPIKE_STRIP_GO_ACTIVE_SFX = "Catalyst_Tactical_Activate_FerroSpikes_3p"
const string SPIKE_STRIP_GO_DORMANT_SFX = "Catalyst_Tactical_Activate_BackToCalm_3p"
const string SPIKE_STRIP_ACTIVE_IDLE_SFX = "Catalyst_Tactical_Idle_HarmfulStage_3p"
const string SPIKE_STRIP_DORMANT_IDLE_SFX = "Catalyst_Tactical_Idle_CalmStage_3p"
const string SPIKE_STRIP_EXPLOSION_SFX = "Catalyst_Tactical_Land_Explo_3p"
const string SPIKE_STRIP_PLAYER_DAMAGE_1P = "flesh_catalyst_Tac_ferrospikes_damage_1p"
const string SPIKE_STRIP_PLAYER_DAMAGE_3P = "flesh_catalyst_Tac_ferrospikes_damage_3p"
const string SPIKE_STRIP_DISSOLVE_3P = "Catalyst_Tactical_Dissolve_3p"
const string SPIKE_STRIP_DESTROY_3P = "Catalyst_Tactical_Destroy_3p"
const float SPIKE_STRIP_SFX_Z_OFFSET = 20.0

const float SPIKE_STRIP_IDLE_SFX_SEEK_SHIFT = 0.5
const float SPIKE_STRIP_IDLE_SFX_SEEK_VARIANCE = 0.15
const float SPIKE_STRIP_ACTIVE_IDLE_SFX_REPEAT_TIME = 18.0   // used when calculating seek value
const float SPIKE_STRIP_DORMANT_IDLE_SFX_REPEAT_TIME = 18.0  // ditto

//String consts
global const string SPIKE_STRIP_CORE_SPIKE_NAME = "core_spike_target_name"
const string SPIKE_STRIP_USE_ENTITY_NAME = "core_spike_use_entity"
const string KILL_CLIENT_THREAD_SIGNAL = "spike_strip_kill_client_thread"
global const string SPIKE_STRIP_WEAPON_NAME = "mp_ability_spike_strip"
const string SPIKE_STRIP_EXPLOSION_IMPACT_TABLE = "exp_ferro_tac_SM"

//Tunables
const int SPIKE_STRIP_MAX_TRAPS = 2
                    
const int UPGRADE_SPIKE_STRIP_MAX_TRAPS = 3
      
const float SPIKE_STRIP_SPIKE_HEALTH = 300
const float SPIKE_STRIP_SPIKE_DURATION = -1
const bool SPIKE_STRIP_DEBUG = false
const float SPIKE_STRIP_PRE_SPIKE_FX_OPACITY = 0.0
const float SPIKE_STRIP_PRE_SPIKE_RADIUS = 75
const vector SPIKE_STRIP_PRE_SPIKE_FX_COLOR = < 0, 0, 0>
const float SPIKE_STRIP_SPIKE_DAMAGE_DEBOUNCE_TIME = 1.0
const float SPIKE_STRIP_SPIKE_DAMAGE = 15
const float SPIKE_STRIP_SPIKE_SLOW_SCALER = 0.5
const float SPIKE_STRIP_SPIKE_SLOW_NPC_SCALER = 0.8
const int SPIKE_STRIP_NUM_SPIKES_IN_SPIKE_STRIP_LINE = 4
const int SPIKE_STRIP_NUM_SPIKES_IN_SPIKE_STRIP_EXTRA_WIDTH = 1
const int SPIKE_STRIP_DISTANCE_BETWEEN_SPIKES = 47
const int SPIKE_STRIP_DISTANCE_BETWEEN_ROWS = 30
const float SPIKE_STRIP_MAIN_SPIKE_HEALTH = 300
const float SPIKE_STRIP_SPIKE_CORE_DORMANT_RADIUS = 440
                    
const float UPGRADE_SPIKE_STRIP_SPIKE_CORE_DORMANT_RADIUS = 330
      
const float SPIKE_STRIP_SPIKE_DELAY = 2.0
const float SPIKE_STRIP_SPIKE_SCALE_DORMANT = 1.0
const float SPIKE_STRIP_SPIKE_SCALE_ACTIVE = 1.0
const float SPIKE_STRIP_SPIKE_SCALE_STABBING = 1.0
const float SPIKE_STRIP_DELAY_BEFORE_EXPANDING = 0.3
const float SPIKE_STRIP_DISTANCE_FROM_CORE_THRESHOLD = 250
const float SPIKE_STRIP_DISTANCE_FROM_CORE_THRESHOLD_SQR = SPIKE_STRIP_DISTANCE_FROM_CORE_THRESHOLD * SPIKE_STRIP_DISTANCE_FROM_CORE_THRESHOLD
const vector SPIKE_STRIP_USE_BOUNDING_MINS = < -15, -15, 0 >
const vector SPIKE_STRIP_USE_BOUNDING_MAXS = < 15, 15, 40 >
const float SPIKE_STRIP_VO_DEBOUNCE_TIME = 10.0

const vector FRIENDLY_SPIKE_COLOR = <80, 150, 255>
const vector ENEMY_SPIKE_COLOR = <255, 32, 10>
const float FRIENDLY_OUTLINE_COLOR = 0.1
const float ENEMY_OUTLINE_COLOR = 1.0

const int SPIKE_STRIP_PIECE_RADIUS = 32
const int SPIKE_STRIP_PIECE_HEIGHT = 50

const int SPIKE_STRIP_TRIGGER_HEIGHT = 150

const array< vector > SPIKE_STRIP_TEST_OFFSETS = [ < 0, 0, 25 >, < 60, 60 , 25 >, < -60, 60 , 25 >, < 60, -60 , 25 >, < -60, -60 , 25 > , < 60, 0 , 25 >, < -60, 0 , 25 >, < 0, -60 , 25 >, < 0, 60 , 25 > ]

struct SpikeData
{
	vector startPos
	entity moveParent
	vector angles
	asset model = SPIKE_STRIP_SPIKE_DORMANT
	bool valid
}

struct MoveSlowData
{
	int handle
	int refCount
}

struct
{
#if CLIENT
	var hud
#endif
	#if SERVER
		table<entity, float> lastSpikeDamageTime
		table<entity, MoveSlowData > moveSlowTable
		table< asset, asset > altModelTable
		int spikeCoreScriptManagedArray
	#endif

	int 		maxTraps
	float 		maxHealth
	int			numPiecesLength
	int 		numPiecesExtraWidth
	float		activationDelay
	float		detectionRadius
	float		detectionHeight
	float		pieceRadius
	float		pieceHeight

} file

void function MpAbilitySpikeStrip_Init()
{
	PrecacheScriptString( SPIKE_STRIP_CORE_SPIKE_NAME )
	PrecacheScriptString( SPIKE_STRIP_USE_ENTITY_NAME )
	PrecacheModel( SPIKE_STRIP_SPIKE_CORE_DORMANT )
	PrecacheModel( SPIKE_STRIP_SPIKE_CORE_ACTIVE )
	PrecacheModel( SPIKE_STRIP_SPIKE_DORMANT )
	PrecacheModel( SPIKE_STRIP_SPIKE_L_CORNER_DORMANT )
	PrecacheModel( SPIKE_STRIP_SPIKE_R_CORNER_DORMANT )
	PrecacheModel( SPIKE_STRIP_SPIKE_L_CORNER_ACTIVE )
	PrecacheModel( SPIKE_STRIP_SPIKE_R_CORNER_ACTIVE )
	PrecacheModel( SPIKE_STRIP_SPIKE_ACTIVE )
	PrecacheParticleSystem( SPIKE_STRIP_CREATE_FX )
	PrecacheParticleSystem( SPIKE_STRIP_DESTROY_FX )
	PrecacheParticleSystem( SPIKE_STRIP_ARM_FP )
	PrecacheParticleSystem( SPIKE_STRIP_CORE_DORMANT_FX )
	PrecacheParticleSystem( SPIKE_STRIP_CORE_ACTIVE_FX )
	PrecacheParticleSystem( SPIKE_STRIP_SPIKE_FX )
	PrecacheParticleSystem( SPIKE_STRIP_ORB_IDLE_3P_FX )
	PrecacheImpactEffectTable( SPIKE_STRIP_EXPLOSION_IMPACT_TABLE )
	RegisterSignal( KILL_CLIENT_THREAD_SIGNAL )

	Remote_RegisterServerFunction( "ClientCallback_TryPickupSpikeStrip", "typed_entity", "prop_ferro_prop" )

	#if SERVER
		file.altModelTable[ SPIKE_STRIP_SPIKE_CORE_DORMANT ]     <- SPIKE_STRIP_SPIKE_CORE_ACTIVE
		file.altModelTable[ SPIKE_STRIP_SPIKE_DORMANT ]          <- SPIKE_STRIP_SPIKE_ACTIVE
		file.altModelTable[ SPIKE_STRIP_SPIKE_L_CORNER_DORMANT ] <- SPIKE_STRIP_SPIKE_L_CORNER_ACTIVE
		file.altModelTable[ SPIKE_STRIP_SPIKE_R_CORNER_DORMANT ] <- SPIKE_STRIP_SPIKE_R_CORNER_ACTIVE

		file.spikeCoreScriptManagedArray = CreateScriptManagedEntArray()
	#endif

	#if CLIENT
		AddTargetNameCreateCallback( SPIKE_STRIP_CORE_SPIKE_NAME, MainSpikeCreated )
		AddTargetNameCreateCallback( SPIKE_STRIP_USE_ENTITY_NAME, UseEntityCreated )
		RegisterConCommandTriggeredCallback( "+scriptCommand5", OnCharacterButtonPressed )
		AddCallback_UseEntGainFocus( SpikeStrip_OnGainFocus )
		AddCallback_UseEntLoseFocus( SpikeStrip_OnLoseFocus )
		AddCallback_MinimapEntShouldCreateCheck_Targetname( SPIKE_STRIP_CORE_SPIKE_NAME, Minimap_DontCreateRuisForEnemies )
		RegisterDefaultMinimapPackage( "prop_ferro_prop", $"", void function( entity ent, var rui ) {} )
		RegisterMinimapPackage( "prop_ferro_prop", eMinimapObject_prop_script.SPIKE_STRIP, MINIMAP_OBJECT_RUI, MinimapPackage_SpikeStrip, FULLMAP_OBJECT_RUI, MinimapPackage_SpikeStrip )
	#endif

	file.maxTraps 					= GetCurrentPlaylistVarInt( "catalyst_spikes_maxTraps", SPIKE_STRIP_MAX_TRAPS )
	file.maxHealth 					= GetCurrentPlaylistVarFloat( "catalyst_spikes_maxHealth", SPIKE_STRIP_MAIN_SPIKE_HEALTH )
	file.numPiecesLength 			= GetCurrentPlaylistVarInt( "catalyst_spikes_numPiecesLength", SPIKE_STRIP_NUM_SPIKES_IN_SPIKE_STRIP_LINE )
	file.numPiecesExtraWidth		= GetCurrentPlaylistVarInt( "catalyst_spikes_numPiecesExtraWidth", SPIKE_STRIP_NUM_SPIKES_IN_SPIKE_STRIP_EXTRA_WIDTH )
	file.activationDelay			= GetCurrentPlaylistVarFloat( "catalyst_spikes_activationDelay", SPIKE_STRIP_SPIKE_DELAY )
	file.detectionRadius			= GetCurrentPlaylistVarFloat( "catalyst_spikes_detectionRadius", SPIKE_STRIP_SPIKE_CORE_DORMANT_RADIUS )
	file.detectionHeight			= GetCurrentPlaylistVarFloat( "catalyst_spikes_detectionHeight", SPIKE_STRIP_TRIGGER_HEIGHT )
	file.pieceRadius				= GetCurrentPlaylistVarFloat( "catalyst_spikes_pieceRadius", SPIKE_STRIP_PIECE_RADIUS )
	file.pieceHeight				= GetCurrentPlaylistVarFloat( "catalyst_spikes_pieceHeight", SPIKE_STRIP_PIECE_HEIGHT )
}

                    
float function GetUpgradedTriggerRadius()
{
	return GetCurrentPlaylistVarFloat( "catalyst_spikes_upgraded_detectionRadius", UPGRADE_SPIKE_STRIP_SPIKE_CORE_DORMANT_RADIUS )
}
      

int function GetMaxTraps( entity player )
{
	int result = file.maxTraps
	                    
		if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_TWO ) ) // upgrade_catalyst_tac_charge
		{
			result = UPGRADE_SPIKE_STRIP_MAX_TRAPS
		}
       
	return result
}

float function GetTriggerRadius( entity player )
{
	float result = file.detectionRadius
	                    
		if( PlayerHasPassive( player, ePassives.PAS_TAC_UPGRADE_THREE ) ) // upgrade_catalyst_tac_trigger_range
		{
			result = GetUpgradedTriggerRadius()
		}
       
	return result
}

void function OnWeaponActivate_ability_spike_strip( entity weapon )
{
}

void function OnWeaponDeactivate_ability_spike_strip( entity weapon )
{
	#if CLIENT
		if( weapon.GetOwner() == GetLocalViewPlayer() )
			weapon.Signal( KILL_CLIENT_THREAD_SIGNAL )
	#endif
	#if SERVER
	{
		CleanupFXArray( weapon.e.fxArray, false, true )
	}
	#endif

}


var function OnWeaponPrimaryAttack_ability_spike_strip( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if SERVER
		entity owner = weapon.GetOwner()
		PlayBattleChatterLineToSpeakerAndTeamWithDebounceTime( owner, "bc_tactical", SPIKE_STRIP_VO_DEBOUNCE_TIME, SPIKE_STRIP_VO_DEBOUNCE_TIME )
		weapon.w.lastFireTime = Time()
	#endif // SERVER

	#if CLIENT
		if( weapon.GetOwner() == GetLocalViewPlayer() )
			weapon.Signal( KILL_CLIENT_THREAD_SIGNAL )
	#endif
	return Grenade_OnWeaponTossReleaseAnimEvent( weapon, attackParams )
}


var function OnWeaponTossReleaseAnimEvent_ability_spike_strip( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if SERVER
		entity owner = weapon.GetOwner()
		PlayBattleChatterLineToSpeakerAndTeamWithDebounceTime( owner, "bc_tactical", SPIKE_STRIP_VO_DEBOUNCE_TIME, SPIKE_STRIP_VO_DEBOUNCE_TIME )
		weapon.w.lastFireTime = Time()
		CleanupFXArray( weapon.e.fxArray, false, true )
	#endif // SERVER

	#if CLIENT
		if( weapon.GetOwner() == GetLocalViewPlayer() )
			weapon.Signal( KILL_CLIENT_THREAD_SIGNAL )
	#endif

	return Grenade_OnWeaponTossReleaseAnimEvent( weapon, attackParams )
}


void function OnProjectileCollision_ability_spike_strip( entity projectile, vector pos, vector normal, entity hitEnt, int hitBox, bool isCritical, bool isPassthrough )
{
	entity owner = projectile.GetOwner()

	if( !IsValid( owner ) || !IsAlive( owner ) )
	{
#if SERVER
		projectile.Destroy()
#endif
		return
	}

	if ( projectile.GrenadeHasIgnited() )
		return

	vector targetPos = pos
	vector targetNormal = normal
	vector upVector = hitEnt.GetUpVector()

	projectile.proj.projectileBounceCount++
	int maxBounceCount = projectile.GetProjectileWeaponSettingInt( eWeaponVar.projectile_ricochet_max_count )
	bool destroyIfNotPlanted = ( projectile.proj.projectileBounceCount > maxBounceCount )



	bool projectileIsOnGround = normal.Dot( <0,0,1> ) > 0.75
	if ( !projectileIsOnGround )
	{
#if SERVER
		projectile.proj.savedDir = FlattenNormalizeVec( -normal )
		if( destroyIfNotPlanted )
			DestroyProjectileAndRefund( owner, projectile )
#endif
		return
	}

	if( !CanDeployOnEnt( hitEnt, pos ) )
	{
		#if SERVER
			if( destroyIfNotPlanted )
				DestroyProjectileAndRefund( owner, projectile )
		#endif
		return
	}

	DeployableCollisionParams collisionParams
	collisionParams.pos = targetPos
	collisionParams.normal = targetNormal
	collisionParams.hitEnt = hitEnt
	collisionParams.hitBox = hitBox
	collisionParams.isCritical = isCritical

	bool result = PlantStickyEntity( projectile, collisionParams, <90, 0, 0> )
	if( !result )
	{
		#if SERVER
			if( destroyIfNotPlanted )
				DestroyProjectileAndRefund( owner, projectile )
		#endif
		return
	}

	#if SERVER
		Explosion(
			pos,
			owner,
			owner,
			0	,
			0,
			0,
			1,
			0,
			pos,
			0,
			damageTypes.explosive,
			eDamageSourceId.mp_ability_spike_strip,
			"exp_ferro_tac_SM" )
		EmitSoundAtPosition( TEAM_ANY, pos, SPIKE_STRIP_EXPLOSION_SFX, projectile )

		StartParticleEffectInWorld( GetParticleSystemIndex( SPIKE_STRIP_CREATE_FX ), pos, ZERO_VECTOR )
		vector projectileOrigin = projectile.GetOrigin()
		vector flattenedDir = FlattenNormalizeVec( projectile.proj.savedDir )
		float dot = DotProduct( projectile.GetUpVector(), < 0, 0, 1 > )
		vector angles = VectorToAngles( flattenedDir )
		entity newParent = projectile.GetParent()
		int team = projectile.GetTeam()
		projectile.Hide()
		projectile.StopPhysics()
		thread SpawnSpikeArea( projectile, owner, newParent, projectileOrigin, angles, targetNormal, team )
	#endif
}

bool function CanDeployOnEnt( entity ent, vector pos )
{
	if ( IsValid( ent ) )
	{
		if ( ent.IsPlayer() || ent.IsNPC() || IsDeathboxFlyer( ent ) )
			return false

		if ( ent.GetScriptName() == CRYPTO_DRONE_SCRIPTNAME  )
			return false

		if( ent.GetScriptName() == BUBBLE_SHIELD_SCRIPTNAME )
			return false

		if ( ent.IsProjectile() )
			return false

		entity lootBin = GetLootBinForHitEnt( ent )
		if( IsValid( lootBin ) && !LootBin_IsBusy( lootBin ) )
			return true

		if( ent.GetNetworkedClassName() == "phys_bone_follower" )
			return false
	}

	return true
}

#if SERVER
array<entity> function GetAllSpikeCores()
{
		return GetScriptManagedEntArray( file.spikeCoreScriptManagedArray )
}

void function WaitForDestructiveAction( entity coreSpike )
{
	EndSignal( coreSpike, "OnDestroy" )

	OnThreadEnd(
		function () : ( coreSpike )
		{
			if( IsValid( coreSpike ) )
				coreSpike.Destroy()
		}
	)

	WaitFrame()

	while( true )
	{
		entity parentEnt = coreSpike.GetParent()
		if( IsValid( parentEnt ) )
		{
			entity lootBin = GetLootBinForHitEnt( parentEnt )
			if( lootBin && LootBin_IsBusy( lootBin ) )
			{
				return
			}
		}
		WaitFrame()
	}
}

void function DestroyProjectileAndRefund( entity owner, entity projectile )
{
	entity tacWeapon = owner.GetOffhandWeapon( OFFHAND_TACTICAL )
	if( IsValid( tacWeapon ) )
		Weapon_AddSingleCharge( tacWeapon )
	projectile.Destroy()
}
void function SpikeStrip_Start3PIdleFXAnimEvent( entity weaponOwner )
{
	entity weapon = weaponOwner.GetOffhandWeapon( OFFHAND_TACTICAL )
	if( !IsValid( weapon ) )
		return

	CleanupFXArray( weapon.e.fxArray, false, true )
	int attachIndex = weaponOwner.LookupAttachment( "L_FOREARM" )
	entity fx = StartParticleEffectOnEntity_ReturnEntity( weaponOwner, GetParticleSystemIndex( SPIKE_STRIP_ORB_IDLE_3P_FX ), FX_PATTACH_POINT_FOLLOW, attachIndex  )
	fx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
	fx.SetOwner( weaponOwner )
	weapon.e.fxArray.append( fx )
}

void function ClientCallback_TryPickupSpikeStrip( entity player, entity totem )
{
	if ( !SURVIVAL_PlayerAllowedToPickup( player ) )
		return

	entity useEnt = player.GetUseEntity()
	if ( !IsValid( useEnt ) || totem != useEnt.GetParent() )
		return
	TryPickupSpikeStrip( player, totem )
}

void function TryPickupSpikeStrip( entity player, entity totem )
{
	entity weapon = player.GetOffhandWeapon( OFFHAND_TACTICAL )
	if( !IsValid( weapon ) || weapon.GetWeaponClassName() != SPIKE_STRIP_WEAPON_NAME )
		return

	if ( !IsValid( totem ) || totem.GetTargetName() != SPIKE_STRIP_CORE_SPIKE_NAME )
		return


	if ( GradeFlagsHas( totem, eGradeFlags.IS_BUSY ) )
		return

	GradeFlagsSet( totem, eGradeFlags.IS_BUSY )

	if( !totem.e.isBusy )
		Weapon_AddSingleCharge( weapon )
	EmitSoundAtPosition( TEAM_ANY, totem.GetOrigin() + < 0, 0, SPIKE_STRIP_SFX_Z_OFFSET>, SPIKE_STRIP_DISSOLVE_3P, totem )
	totem.Destroy()
}

void function SpawnSpikeArea( entity projectile, entity owner, entity newParent, vector pos, vector angles, vector normal, int team  )
{
	vector newAngles = AnglesOnSurface( normal, AnglesToForward( angles ) )
	entity totem = CreateSpike( owner, newParent, pos + < 0, 0, -8 >, newAngles, team, SPIKE_STRIP_SPIKE_DURATION, file.maxHealth , SPIKE_STRIP_SPIKE_CORE_DORMANT  )
                         
                                                                             
       

	totem.RemoveFromAllRealms()
	totem.AddToOtherEntitysRealms( projectile )
	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_CATALYST_SPIKES, owner, pos, team, projectile )
	if( IsValid( projectile ) )
		projectile.Destroy()
	thread CreateSpikeStrip2(owner, totem, pos, angles, team  )
	thread SpikeTotemThread( totem, owner )
}

void function SpikeTotemThread( entity totem, entity owner  )
{
	EndSignal( totem, "OnDestroy" )
	EndSignal( totem, "EMP_Destroy" )
	EndSignal( owner, "SquadEliminated" )
	EndSignal( owner, "OnDestroy" )
	EndSignal( owner, "PlayerChangedClass" )

	int teamId = owner.GetTeam()
	int particleIndex = GetParticleSystemIndex( SPIKE_STRIP_CREATE_FX )

	//entity friendlyFx = StartParticleEffectOnEntityWithPos_ReturnEntity( totem, particleIndex, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0>)
	//EffectSetControlPointVector( friendlyFx, 2, FRIENDLY_SPIKE_COLOR )
	//friendlyFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
	//SetTeam( friendlyFx, teamId )

	//entity enemyFx = StartParticleEffectOnEntity_ReturnEntity( totem, particleIndex, FX_PATTACH_ABSORIGIN, ATTACHMENTID_INVALID )
	//EffectSetControlPointVector( enemyFx, 2, ENEMY_SPIKE_COLOR )
	//enemyFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
	//SetTeam( enemyFx, teamId )

	entity useEntity = CreateResinShard(  $"mdl/dev/empty_model.rmdl", totem.GetOrigin() , totem.GetAngles(), teamId, 1, 0, true, -1, owner )
	useEntity.SetOwner( owner )
	useEntity.NotSolid()
	//useEntity.SetCollisionBounds( SPIKE_STRIP_USE_BOUNDING_MINS, SPIKE_STRIP_USE_BOUNDING_MAXS )
	SetTargetName( useEntity, SPIKE_STRIP_USE_ENTITY_NAME )
	useEntity.SetParent( totem )
	useEntity.SetUsable()
	useEntity.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER )
	useEntity.SetUsablePriority( USABLE_PRIORITY_LOW )

	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.RemoveFromAllRealms()
	trigger.AddToOtherEntitysRealms( totem )
	trigger.SetCylinderRadius( GetTriggerRadius( owner ) )
	trigger.SetAboveHeight( file.detectionHeight )
	trigger.SetBelowHeight( file.detectionHeight)
	trigger.SetOrigin( totem.GetOrigin() )
	trigger.SetAngles( totem.GetAngles() )
	trigger.SetOwner( owner )
	SetTeam( trigger, totem.GetTeam() )
	trigger.kv.triggerFilterNpc = "all"
	trigger.kv.triggerFilterPlayer = "all"
	trigger.kv.triggerFilterNonCharacter = 0
	DispatchSpawn( trigger )
	trigger.SetParent( totem )

	thread SpikeTotemTriggerThread( totem, trigger, teamId )

	SetTargetName( totem, SPIKE_STRIP_CORE_SPIKE_NAME )
	AddToScriptManagedEntArray( file.spikeCoreScriptManagedArray, totem )
	totem.Minimap_SetCustomState( eMinimapObject_prop_script.SPIKE_STRIP )
	totem.Minimap_AlwaysShow( teamId, null )
	AllianceProximity_SetMinimapAlwaysShow_ForAlliance( teamId, totem, owner )
	totem.Minimap_SetAlignUpright( true )
	totem.Minimap_SetZOrder( MINIMAP_Z_OBJECT - 1 )
	MarkEntForCleanupOnRoundEnd( totem )

	EndSignal( totem, "OnDestroy" )

	vector pingOrigin = totem.GetOrigin() + <0,0, 32>
	entity traceBlocker = CreateTraceBlockerVolume( pingOrigin, 64.0, false, CONTENTS_BLOCK_PING, teamId, SPIKE_STRIP_CORE_SPIKE_NAME )
	traceBlocker.RemoveFromAllRealms()
	traceBlocker.AddToOtherEntitysRealms( totem )
	traceBlocker.SetParent( totem )
	SetTargetName( traceBlocker, SPIKE_STRIP_CORE_SPIKE_NAME )

	if( IsValid( owner ) && owner.IsPlayer() )
	{
		if( GetResinStructureRoot( totem ) == totem )
			owner.e.activeTraps.insert( 0, totem )

		for ( int i = owner.e.activeTraps.len() - 1; i >= 0 ; i-- )
		{
			if ( !IsValid( owner.e.activeTraps[i] ) )
			{
				owner.e.activeTraps.remove( i )
			}
		}

		while ( owner.e.activeTraps.len() > GetMaxTraps( owner ) )
		{
			entity entToDelete = owner.e.activeTraps.top()
			if ( IsValid( entToDelete ) )
			{
				StartParticleEffectInWorld( GetParticleSystemIndex( SPIKE_STRIP_CREATE_FX ), entToDelete.GetOrigin(), ZERO_VECTOR )
				EmitSoundAtPosition( TEAM_ANY, entToDelete.GetOrigin() + <0, 0, SPIKE_STRIP_SFX_Z_OFFSET>, SPIKE_STRIP_DISSOLVE_3P, entToDelete )
				entToDelete.Destroy()
			}
		}
	}

	OnThreadEnd(
		//function () : ( totem, owner, friendlyFx, enemyFx )
		function () : ( totem, owner )
		{
			//if( IsValid( friendlyFx ) )
				//EffectStop( friendlyFx )

			//if( IsValid( enemyFx ) )
				//EffectStop( enemyFx )

			bool isValid = IsValid( totem )
			if( isValid || IsInvalidButMemberVarsStillValid( totem ) )
			{
				array< entity > linkedSpikes = totem.GetLinkEntArray()
				foreach( s in linkedSpikes )
				{
					if( IsValid( s ) )
						s.Destroy()
				}
				if( isValid )
					totem.Destroy()
			}

			if ( IsValid( owner ) )
			{
				if ( owner.e.activeTraps.contains( totem ) )
				{
					for ( int i = owner.e.activeTraps.len() - 1; i >= 0 ; i-- )
					{
						if ( owner.e.activeTraps[i] == totem )
						{
							owner.e.activeTraps.remove( i )
						}
					}
				}
			}
		}
	)

                         
                                               
                                                    
       

	WaitForever()
}

                        
                                                             
 
                                                
        

                                     

  
                                       
                         
                                          
  

                        
                                                                                                                                                                                    
                                                                        

             
                              
   
                                
    
                             
    
   
  

              
  
                                                                                 

                           
           

                                           
                         
           

                                       

                        
   
                                                                        
   
  
 
      

void function GetAdjustedTestOffsets( entity mainSpike, array< vector > testOffsets )
{
	testOffsets.clear()
	vector pos = mainSpike.GetOrigin() + ( mainSpike.GetUpVector() * 30 )
	foreach( offset in SPIKE_STRIP_TEST_OFFSETS )
	{
		TraceResults testTrace = TraceLine( pos , mainSpike.GetOrigin() + offset, mainSpike, TRACE_MASK_SHOT & ~CONTENTS_WATER, TRACE_COLLISION_GROUP_DEBRIS )
		testOffsets.append( testTrace.endPos )
		#if DEVELOPER && SPIKE_STRIP_DEBUG
			DebugDrawSphere( testTrace.endPos, 5.0, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 5.0 )
		#endif
	}
}

void function CreateSpikeStrip2( entity owner, entity mainSpike, vector pos, vector angles, int team )
{
	EndSignal( mainSpike, "OnDestroy" )

	wait SPIKE_STRIP_DELAY_BEFORE_EXPANDING

	pos = mainSpike.GetOrigin() + < 0, 0, 8 >
	array< vector > testOffsets
	GetAdjustedTestOffsets( mainSpike, testOffsets )

	int gridLength = ( file.numPiecesLength * 2 ) + 1
	int gridWidth = ( file.numPiecesExtraWidth * 2 ) + 1
	int coreX = file.numPiecesLength
	int coreY = file.numPiecesExtraWidth
	array< array< SpikeData > > spikeDataGrid
	for( int i = 0; i < gridLength; i++  )
	{
		array< SpikeData > spikeDataGridWidth
		for( int j = 0; j < gridWidth; j++  )
		{
			SpikeData data
			spikeDataGridWidth.append( data )
		}
		spikeDataGrid.append( spikeDataGridWidth )
	}

	vector spikeLineAngles = angles
	entity newParent = mainSpike.GetParent()
	vector newAngles = angles

	// Create Spike Segment above core
	array<SpikeData> spikeData = CreateSpikeLineData2( owner, mainSpike, newParent, pos, AnglesToForward( spikeLineAngles ), angles, file.numPiecesExtraWidth, SPIKE_STRIP_DISTANCE_BETWEEN_ROWS, false, testOffsets )
	for( int i = 0; i < spikeData.len(); i++  )
	{
		SpikeData dataTemp = spikeData[ i ]
		newAngles = < dataTemp.angles.x, angles.y, dataTemp.angles.z >
		if( dataTemp.valid )
		{
			SpikeData gridData = spikeDataGrid[ coreX ][ coreY - ( i + 1 ) ]
			gridData.valid = true
			gridData.startPos = dataTemp.startPos
			gridData.angles = RotateAnglesAboutAxis( newAngles, AnglesToUp( newAngles ), 270 )
			gridData.moveParent =  dataTemp.moveParent
		}
	}

	// Create spike segment below core
	spikeData = CreateSpikeLineData2( owner, mainSpike, newParent, pos, -AnglesToForward( spikeLineAngles ), angles, file.numPiecesExtraWidth, SPIKE_STRIP_DISTANCE_BETWEEN_SPIKES, false, testOffsets )
	for( int i = 0; i < spikeData.len(); i++  )
	{
		SpikeData dataTemp = spikeData[ i ]
		newAngles = < dataTemp.angles.x, angles.y, dataTemp.angles.z >
		if( dataTemp.valid )
		{
			SpikeData gridData = spikeDataGrid[ coreX ][ coreY + ( i + 1 ) ]
			gridData.valid = true
			gridData.startPos = dataTemp.startPos + ( AnglesToForward( newAngles ) * 21 )
			gridData.angles = RotateAnglesAboutAxis( newAngles, AnglesToUp( newAngles ), 90 )
			gridData.moveParent =  dataTemp.moveParent
		}
	}

	// Create spike segments outward from the core
	for( int i = 1; i <= file.numPiecesLength; i++ )
	{
		// Create next line segment to the right of the core
		spikeData = CreateSpikeLineData2( owner, mainSpike, newParent, pos, AnglesToRight( spikeLineAngles ), angles, i, SPIKE_STRIP_DISTANCE_BETWEEN_SPIKES, false, testOffsets )
		SpikeData data = spikeData[ i - 1 ]

		newAngles = < data.angles.x, angles.y, data.angles.z >
		if( data.valid )
		{
			SpikeData gridData = spikeDataGrid[ coreX + i ][ coreY ]
			gridData.valid = true
			gridData.startPos = data.startPos
			gridData.angles = RotateAnglesAboutAxis( newAngles, AnglesToUp( newAngles ), 180 )
			gridData.moveParent =  data.moveParent
		}

		array<SpikeData> spikeDataTemp = CreateSpikeLineData2( owner, mainSpike, newParent, data.startPos, AnglesToForward( spikeLineAngles ), angles, file.numPiecesExtraWidth, SPIKE_STRIP_DISTANCE_BETWEEN_ROWS, false, testOffsets )
		for( int j = 0; j < spikeDataTemp.len(); j++ )
		{
			asset model = ( i == file.numPiecesLength && j == ( spikeDataTemp.len() - 1 )  ) ? SPIKE_STRIP_SPIKE_L_CORNER_DORMANT : SPIKE_STRIP_SPIKE_DORMANT
			SpikeData dataTemp = spikeDataTemp[ j ]
			newAngles = < dataTemp.angles.x, angles.y, dataTemp.angles.z >
			if( dataTemp.valid )
			{
				SpikeData gridData = spikeDataGrid[ coreX + i ][ coreY - ( j + 1 ) ]
				gridData.valid = true
				gridData.startPos = dataTemp.startPos
				gridData.angles = RotateAnglesAboutAxis( newAngles, AnglesToUp( newAngles ), 180 )
				gridData.moveParent =  dataTemp.moveParent
				gridData.model = model
			}
		}
		spikeDataTemp = CreateSpikeLineData2( owner, mainSpike, newParent, data.startPos, -AnglesToForward( spikeLineAngles ), angles,  file.numPiecesExtraWidth, SPIKE_STRIP_DISTANCE_BETWEEN_ROWS, false, testOffsets )
		for( int j = 0; j < spikeDataTemp.len(); j++ )
		{
			asset model = ( i == file.numPiecesLength && j == ( spikeDataTemp.len() - 1 )  ) ? SPIKE_STRIP_SPIKE_R_CORNER_DORMANT : SPIKE_STRIP_SPIKE_DORMANT
			SpikeData dataTemp = spikeDataTemp[ j ]
			newAngles = < dataTemp.angles.x, angles.y, dataTemp.angles.z >
			if( dataTemp.valid )
			{
				SpikeData gridData = spikeDataGrid[ coreX + i ][ coreY + ( j + 1 ) ]
				gridData.valid = true
				gridData.startPos = dataTemp.startPos
				gridData.angles = RotateAnglesAboutAxis( newAngles, AnglesToUp( newAngles ), 180 )
				gridData.moveParent =  dataTemp.moveParent
				gridData.model = model
			}
		}

		// Create next line segment to the left of the core
		spikeData = CreateSpikeLineData2( owner, mainSpike, newParent, pos, -AnglesToRight( spikeLineAngles ), angles,  i , SPIKE_STRIP_DISTANCE_BETWEEN_SPIKES, false, testOffsets )
		data = spikeData[ i - 1 ]
		newAngles = < data.angles.x, angles.y, data.angles.z >
		if( data.valid )
		{
			SpikeData gridData = spikeDataGrid[ coreX - i ][ coreY ]
			gridData.valid = true
			gridData.startPos = data.startPos
			gridData.angles = RotateAnglesAboutAxis( newAngles, AnglesToUp( newAngles ), 0 )
			gridData.moveParent =  data.moveParent
		}

		spikeDataTemp = CreateSpikeLineData2( owner, mainSpike, newParent, data.startPos, AnglesToForward( spikeLineAngles ), angles, file.numPiecesExtraWidth, SPIKE_STRIP_DISTANCE_BETWEEN_ROWS, false, testOffsets )
		for( int j = 0; j < spikeDataTemp.len(); j++ )
		{
			asset model = ( i == file.numPiecesLength && j == ( spikeDataTemp.len() - 1 )  ) ? SPIKE_STRIP_SPIKE_R_CORNER_DORMANT : SPIKE_STRIP_SPIKE_DORMANT
			SpikeData dataTemp = spikeDataTemp[ j ]
			newAngles = < dataTemp.angles.x, angles.y, dataTemp.angles.z >
			if( dataTemp.valid )
			{
				SpikeData gridData = spikeDataGrid[ coreX - i ][ coreY - ( j + 1 ) ]
				gridData.valid = true
				gridData.startPos = dataTemp.startPos
				gridData.angles = RotateAnglesAboutAxis( newAngles, AnglesToUp( newAngles ), 0 )
				gridData.moveParent =  dataTemp.moveParent
				gridData.model = model
			}
		}
		spikeDataTemp = CreateSpikeLineData2( owner, mainSpike, newParent, data.startPos, -AnglesToForward( spikeLineAngles ), angles,  file.numPiecesExtraWidth, SPIKE_STRIP_DISTANCE_BETWEEN_ROWS, false, testOffsets )
		for( int j = 0; j < spikeDataTemp.len(); j++ )
		{
			asset model = ( i == file.numPiecesLength && j == ( spikeDataTemp.len() - 1 )  ) ? SPIKE_STRIP_SPIKE_L_CORNER_DORMANT : SPIKE_STRIP_SPIKE_DORMANT
			SpikeData dataTemp = spikeDataTemp[ j ]
			newAngles = < dataTemp.angles.x, angles.y, dataTemp.angles.z >
			if( dataTemp.valid )
			{
				SpikeData gridData = spikeDataGrid[ coreX - i ][ coreY + ( j + 1 ) ]
				gridData.valid = true
				gridData.startPos = dataTemp.startPos
				gridData.angles = RotateAnglesAboutAxis( newAngles, AnglesToUp( newAngles ), 0 )
				gridData.moveParent =  dataTemp.moveParent
				gridData.model = model
			}
		}
	}

	//Eliminate pieces that cant connect back to the core
	//Assume pieces 1 out from the core are valid
	if( file.numPiecesLength > 1 )
	{
		for( int i = 2; i <= file.numPiecesLength; i++ )
		{
			array< int > leftBridges
			array< int > rightBridges
			for( int j = 0; j < gridWidth; j++ )
			{
				if( spikeDataGrid[ coreX + i ][ j ].valid && spikeDataGrid[ coreX + ( i - 1 ) ][ j ].valid )
				{
					rightBridges.append( j )
				}
				if( spikeDataGrid[ coreX - i ][ j ].valid && spikeDataGrid[ coreX - ( i - 1 ) ][ j ].valid )
				{
					leftBridges.append( j )
				}
			}

			for( int j = 0; j < gridWidth; j++ )
			{
				if( spikeDataGrid[ coreX + i ][ j ].valid && !rightBridges.contains( j ) )
				{
					bool pathFound = false

					foreach( int bridge in rightBridges )
					{
						int inc = ( bridge < j ) ? 1 : -1
						int k = bridge + inc
						for( ; k != j; k += inc )
						{
							if( !( spikeDataGrid[ coreX + i ][ k ].valid ) )
								break

						}
						if( k == j )
						{
							pathFound = true
							break
						}
					}
					if( !pathFound )
						spikeDataGrid[ coreX + i ][ j ].valid = false
				}

				if( spikeDataGrid[ coreX - i ][ j ].valid && !leftBridges.contains( j ) )
				{
					bool pathFound = false
					foreach( int bridge in leftBridges )
					{
						int inc = ( bridge < j ) ? 1 : -1
						int k = bridge + inc
						for( ; k != j; k += inc )
						{
							if( !( spikeDataGrid[ coreX - i ][ k ].valid ) )
								break

						}
						if( k == j )
						{
							pathFound = true
							break
						}
					}
					if( !pathFound )
						spikeDataGrid[ coreX - i ][ j ].valid = false
				}
			}
		}
	}


	for( int i = 0; i < gridLength; i++  )
	{
		for( int j = 0; j < gridWidth; j++  )
		{
			SpikeData data = spikeDataGrid[ i ][ j ]
			if( data.valid )
			{
				CreateSpikeSegment( owner, data.moveParent, mainSpike, data.startPos, data.angles, team, data.model )
			}
		}
	}
	WaitFrame()
}

array<SpikeData> function CreateSpikeLineData2( entity owner, entity mainSpike, entity projectileHitEnt, vector pos, vector dir, vector angles, int stepCount, float spacing, bool ignoreFirst, array< vector > testOffsets )
{
	int count = 0
	vector lastDownPos = pos
	array<SpikeData> segmentsArray

	dir.z = 0
	dir = Normalize( dir )
	vector anglesDir = AnglesToForward( angles )
	anglesDir.z = 0
	anglesDir = Normalize( anglesDir )

	bool useUpwardTraces = GetCurrentPlaylistVarBool( "thermite_grenade_use_new_traces", true )
	float downwardTraceOffset = GetCurrentPlaylistVarFloat( "thermite_grenade_downward_trace_offset", 5.0 ) // This used to be 2 but 2 was not enough to get out of high collision

	array<entity> ignoreArray = GetAllResinShards()
	ignoreArray.extend( GetAllCodeDoorEnts() )

	for ( int i = 0; i < stepCount; i++ )
	{
		bool firstTrace = false

		vector newPos = lastDownPos + < 0, 0, 40 >
		newPos += dir * spacing

		TraceResults downTrace = TraceLine( newPos, newPos + <0,0,-80>, ignoreArray, TRACE_MASK_SHOT & ~CONTENTS_WATER, TRACE_COLLISION_GROUP_DEBRIS )



		lastDownPos = downTrace.endPos
		SpikeData segment
		segment.startPos = downTrace.endPos
		segmentsArray.append( segment )


		bool lootBinCheck = true
		entity parentEnt = IsValid( mainSpike ) ? mainSpike.GetParent() : null
		if( IsValid( parentEnt ) )
		{
			entity lootBin = GetLootBinForHitEnt( parentEnt )
			if( lootBin && downTrace.hitEnt != lootBin )
			{
				lootBinCheck = false
			}
		}
		if ( downTrace.fraction == 1.0 || !lootBinCheck || ( IsValid( downTrace.hitEnt ) && downTrace.hitEnt.e.blocksThermite ) || downTrace.surfaceNormal.Dot( <0,0,1> ) < 0.75 || fabs( downTrace.endPos.z - pos.z ) > 100.0 ||  !CanDeployOnEnt( downTrace.hitEnt, downTrace.endPos ) )
		{
			#if DEVELOPER && SPIKE_STRIP_DEBUG
				DebugDrawSphere( downTrace.endPos, 5.0, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 5.0 )
			#endif
			continue
		}


		bool append = false
		foreach( test in testOffsets )
		{
			TraceResults testTrace = TraceLine( downTrace.endPos, test, ignoreArray, TRACE_MASK_SHOT & ~CONTENTS_WATER, TRACE_COLLISION_GROUP_DEBRIS )
			if( testTrace.fraction == 1.0 )
			{
				append = true
				break
			}
		}

		if( !append )
		{
			#if DEVELOPER && SPIKE_STRIP_DEBUG
				DebugDrawSphere( downTrace.endPos, 5.0, int(COLOR_BLUE.x), int(COLOR_BLUE.y), int(COLOR_BLUE.z), true, 5.0 )
			#endif
			continue
		}

		#if DEVELOPER && SPIKE_STRIP_DEBUG
			DebugDrawSphere( downTrace.endPos, 5.0, int(COLOR_YELLOW.x), int(COLOR_YELLOW.y), int(COLOR_YELLOW.z), true, 5.0 )
		#endif

		segment.valid = true
		segment.startPos = downTrace.endPos
		segment.angles = AnglesOnSurface( downTrace.surfaceNormal, anglesDir )

		segment.moveParent = null
		if ( IsValid( downTrace.hitEnt ) )
		{
			if ( !downTrace.hitEnt.IsWorld() )
			{
				segment.moveParent = downTrace.hitEnt
				//segment.angles = CalcWorldToLocalAngles_Entity( downTrace.hitEnt, segment.angles )
				//segment.startPos = CalcWorldToLocalOrigin_Entity( downTrace.hitEnt, segment.startPos )
			}
		}
		else if ( firstTrace && IsValid( projectileHitEnt ) )
		{
			if ( !projectileHitEnt.IsWorld() )
			{
				segment.moveParent = projectileHitEnt
				//segment.angles = CalcWorldToLocalAngles_Entity( projectileHitEnt, segment.angles )
				//segment.startPos = CalcWorldToLocalOrigin_Entity( projectileHitEnt, segment.startPos )
			}
		}
		//segmentsArray.append( segment )
	}

	if( ignoreFirst && segmentsArray.len() > 0 )
		segmentsArray.remove( 0 )

	return segmentsArray
}


void function CreateSpikeSegment( entity owner, entity moveParent, entity mainSpike, vector pos, vector angles, int team, asset model = SPIKE_STRIP_SPIKE_DORMANT )
{
	entity spike = CreateSpike( owner,moveParent, pos, angles, team, SPIKE_STRIP_SPIKE_DURATION, SPIKE_STRIP_SPIKE_HEALTH, model, mainSpike )
	AI_CreateDangerousArea_Static( spike, null, file.pieceRadius, TEAM_INVALID, true, true, pos)
}

array<SpikeData> function CreateSpikeLineData( entity owner, entity projectileHitEnt, vector pos, vector dir, vector angles, int stepCount, float spacing, bool ignoreFirst )
{
	int count = 0
	vector lastDownPos = pos
	array<SpikeData> segmentsArray

	dir.z = 0
	dir = Normalize( dir )
	vector anglesDir = AnglesToForward( angles )
	anglesDir.z = 0
	anglesDir = Normalize( anglesDir )

	bool useUpwardTraces = GetCurrentPlaylistVarBool( "thermite_grenade_use_new_traces", true )
	float downwardTraceOffset = GetCurrentPlaylistVarFloat( "thermite_grenade_downward_trace_offset", 5.0 ) // This used to be 2 but 2 was not enough to get out of high collision

	for ( int i = 0; i < stepCount; i++ )
	{
		bool firstTrace = false

		vector newPos = pos
		if ( !firstTrace )
			newPos += dir * spacing

		vector traceStart = pos
		vector traceEndUnder = newPos
		vector traceEndOver = newPos

		array<entity> ignoreArray = GetAllResinShards()
		ignoreArray.extend( GetAllCodeDoorEnts() )

		if ( !firstTrace )
		{
			traceStart = lastDownPos + <0,0,40>

			if ( useUpwardTraces )
			{
				TraceResults upwardTrace = TraceLine( lastDownPos, traceStart, ignoreArray, TRACE_MASK_NPCSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_NONE )

				#if DEVELOPER && SPIKE_STRIP_DEBUG
					DebugDrawLine( lastDownPos, upwardTrace.endPos, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 25.0 )
				#endif

				traceStart = upwardTrace.endPos
			}

			traceEndUnder = <newPos.x, newPos.y, traceStart.z - 40>
			traceEndOver = <newPos.x, newPos.y, traceStart.z + spacing * 0.57735056839> // The over height is to cover the case of a sheer surface that then continues gradually upwards (like mp_box)
		}

		#if DEVELOPER && SPIKE_STRIP_DEBUG
			DebugDrawLine( traceStart, traceEndUnder, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 25.0 )
		#endif

		TraceResults forwardTrace = TraceLine( traceStart, traceEndUnder, ignoreArray, TRACE_MASK_NPCSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
		if ( forwardTrace.fraction > 0.5 )
		{
			vector downTraceStartPos = forwardTrace.endPos
			if ( firstTrace )
				downTraceStartPos += <0, 0, downwardTraceOffset>

			TraceResults downTrace = TraceLine( downTraceStartPos, forwardTrace.endPos + <0,0,-100>, ignoreArray, TRACE_MASK_NPCSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

			#if DEVELOPER && SPIKE_STRIP_DEBUG
				DebugDrawLine( downTraceStartPos, downTrace.endPos, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 25.0 )
			#endif

			if ( downTrace.fraction == 1.0 )
				break

			SpikeData segment
			//segment.index = i
			//segment.startPos = lastDownPos
			segment.startPos = downTrace.endPos
			//vector surfaceAngles =
			//segment.angles = VectorToAngles( AnglesToUp( VectorToAngles( downTrace.surfaceNormal ) ) )
			segment.angles = AnglesOnSurface( downTrace.surfaceNormal, anglesDir )

			segment.moveParent = null
			if ( IsValid( downTrace.hitEnt ) )
			{
				if ( !downTrace.hitEnt.IsWorld() )
				{
					segment.moveParent = downTrace.hitEnt
					//segment.endPos = CalcWorldToLocalOrigin_Entity( downTrace.hitEnt, segment.endPos )
					//segment.angles = CalcWorldToLocalAngles_Entity( downTrace.hitEnt, segment.angles )
					segment.startPos = CalcWorldToLocalOrigin_Entity( downTrace.hitEnt, segment.startPos )
				}
			}
			else if ( firstTrace && IsValid( projectileHitEnt ) )
			{
				if ( !projectileHitEnt.IsWorld() )
				{
					segment.moveParent = projectileHitEnt
					//segment.endPos = CalcWorldToLocalOrigin_Entity( projectileHitEnt, segment.endPos )
					//segment.angles = CalcWorldToLocalAngles_Entity( projectileHitEnt, segment.angles )
					segment.startPos = CalcWorldToLocalOrigin_Entity( projectileHitEnt, segment.startPos )
				}
			}

			//printt( "i:", i, "stepCount:", stepCount, "segment.sound:", segment.sound )
			segmentsArray.append( segment )

			if( IsValid( downTrace.hitEnt ) && downTrace.hitEnt.e.blocksThermite )
				break

			lastDownPos = downTrace.endPos
			pos = forwardTrace.endPos

			continue
		}

		if(forwardTrace.hitEnt.e.blocksThermite)
		{
			break
		}

		if ( firstTrace && useUpwardTraces )
		{
			TraceResults upwardTrace = TraceLine( lastDownPos, traceStart, ignoreArray, TRACE_MASK_NPCSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

			#if DEVELOPER && SPIKE_STRIP_DEBUG
				DebugDrawLine( lastDownPos, upwardTrace.endPos, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), true, 25.0 )
			#endif

			if ( upwardTrace.fraction < 1.0 )
				continue
		}

		TraceResults upwardImpactTrace = TraceLine( traceStart, traceEndOver, ignoreArray, TRACE_MASK_NPCSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

		#if DEVELOPER && SPIKE_STRIP_DEBUG
			DebugDrawLine( traceStart, traceEndOver, int(COLOR_BLUE.x), int(COLOR_BLUE.y), int(COLOR_BLUE.z), true, 25.0 )
		#endif

		if ( upwardImpactTrace.fraction < 1.0 )
		{
			if( upwardImpactTrace.hitEnt.e.blocksThermite || ( IsValid( upwardImpactTrace.hitEnt ) && upwardImpactTrace.hitEnt.IsWorld() ) )
				break
		}
		else
		{
			vector upwardImpactDownTraceEndPos = upwardImpactTrace.endPos + <0,0,-1000>
			TraceResults downTrace = TraceLine( upwardImpactTrace.endPos, upwardImpactDownTraceEndPos, ignoreArray, TRACE_MASK_NPCSOLID_BRUSHONLY, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )

			#if DEVELOPER && SPIKE_STRIP_DEBUG
				DebugDrawLine( upwardImpactTrace.endPos, downTrace.endPos, int(COLOR_RED.x), int(COLOR_RED.y), int(COLOR_RED.z), true, 25.0 )
			#endif

			if ( downTrace.fraction == 1.0 )
				break

			SpikeData segment
			//segment.index = i
			//segment.startPos = lastDownPos
			segment.startPos = downTrace.endPos
			//vector surfaceAngles = AnglesOnSurface( downTrace.surfaceNormal, dir )
			//segment.angles = VectorToAngles( AnglesToUp( VectorToAngles( downTrace.surfaceNormal ) ) )
			segment.angles = AnglesOnSurface( downTrace.surfaceNormal, anglesDir )

			segment.moveParent = null
			if ( IsValid( downTrace.hitEnt ) )
			{
				if ( !downTrace.hitEnt.IsWorld() )
				{
					segment.moveParent = downTrace.hitEnt
					//Pos = CalcWorldToLocalOrigin_Entity( downTrace.hitEnt, segment.endPos )
					//segment.angles = CalcWorldToLocalAngles_Entity( downTrace.hitEnt, segment.angles )
					segment.startPos = CalcWorldToLocalOrigin_Entity( downTrace.hitEnt, segment.startPos )
				}
			}

			//printt( "i:", i, "stepCount:", stepCount, "segment.sound:", segment.sound )
			segmentsArray.append( segment )

			if ( IsValid(downTrace.hitEnt) && downTrace.hitEnt.e.blocksThermite )
				break

			lastDownPos = downTrace.endPos
			pos = forwardTrace.endPos
		}
	}

	if( ignoreFirst && segmentsArray.len() > 0 )
		segmentsArray.remove( 0 )

	return segmentsArray
}



entity function CreateSpike( entity owner, entity newParent, vector pos, vector angles, int team, float duration, float health, asset model = SPIKE_STRIP_SPIKE_DORMANT, entity mainSpike = null  )
{
	entity spike = CreateResinShard( model, pos , angles, team, health, CONTENTS_SOLID | CONTENTS_NOGRAPPLE, true, -1, owner )
	spike.kv.solid = SOLID_HITBOXES
	spike.e.destroyIfBubbleShieldParentDestroyed = true
	if( IsValid( mainSpike ) )
	{
		spike.RemoveFromAllRealms()
		spike.AddToOtherEntitysRealms( mainSpike )
		mainSpike.LinkToEnt( spike )
	}
	//spike.kv.CollisionGroup = TRACE_COLLISION_GROUP_PERMEABLE
	spike.SetPassThroughThickness( 0 )
	spike.SetPassThroughDirection( 0 )
	//spike.SetPassThroughFlags( PTF_ADDS_MODS | PTF_BLOCKS_PING )

	spike.e.baseModel = model
	if( model in file.altModelTable )
	{
		spike.e.altModel = file.altModelTable[ model ]
	}
	else
	{
		spike.e.altModel = SPIKE_STRIP_SPIKE_ACTIVE
	}

	EndSignal( spike, "OnDestroy" )
	if( IsValid( newParent ) )
	{
		spike.SetParent( newParent )
	}

	spike.Solid()
	spike.SetCollisionAllowed( true )
	spike.SetOwner( owner )

	thread SpikeLifeTimeThread( owner, spike, mainSpike, duration )
	thread WaitForDestructiveAction( spike )

	return spike
}

void function SpikeLifeTimeThread( entity owner, entity spike, entity mainSpike, float duration )
{
	Assert ( IsNewThread(), "Must be threaded off" )
	EndSignal( spike, "OnDestroy" )

	spike.SetModelScale( SPIKE_STRIP_SPIKE_SCALE_DORMANT )
	spike.NotSolid()

	OnThreadEnd(
		function () : ( spike, owner )
		{
			if ( IsValid( spike ) )
			{
				StartParticleEffectInWorld( GetParticleSystemIndex( SPIKE_STRIP_CREATE_FX ), spike.GetOrigin(), ZERO_VECTOR )
				EmitSoundOnEntity( spike, RESIN_CRUMBLE_3P_SOUND )
				spike.Destroy()
			}
		}
	)

	float activationTime = Time() + file.activationDelay
	while( Time() < activationTime )
	{
		if( IsValid( mainSpike ) && DistanceSqr( mainSpike.GetOrigin(), spike.GetOrigin() ) > SPIKE_STRIP_DISTANCE_FROM_CORE_THRESHOLD_SQR )
		{
			spike.Destroy()
			return
		}
		WaitFrame()
	}

	/*entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.RemoveFromAllRealms()
	trigger.AddToOtherEntitysRealms( spike )
	trigger.SetCylinderRadius( 18 )
	trigger.SetAboveHeight( 50 )
	trigger.SetBelowHeight( 0 )
	trigger.SetOrigin( spike.GetOrigin() )
	trigger.SetOwner( owner )
	SetTeam( trigger, spike.GetTeam() )
	trigger.kv.triggerFilterNpc = "all"
	trigger.kv.triggerFilterPlayer = "all"
	trigger.kv.triggerFilterNonCharacter = 0
	trigger.SetEnterCallback( SpikeTriggerEnter )
	DispatchSpawn( trigger )
	trigger.SearchForNewTouchingEntity()
	trigger.SetParent( spike )*/

	while( true )
	{
		if( IsValid( mainSpike ) && DistanceSqr( mainSpike.GetOrigin(), spike.GetOrigin() ) > SPIKE_STRIP_DISTANCE_FROM_CORE_THRESHOLD_SQR )
		{
			spike.Destroy()
			return
		}

		bool touchingEnemy = false
		/*array< entity > ents = trigger.GetTouchingEntities()
		foreach( ent in ents )
		{
			if( IsValid( ent ) && ent.IsPlayer() && IsEnemyTeam( ent.GetTeam(), trigger.GetTeam() ) )
			{
				touchingEnemy = true
				break
			}
		}*/


		if( ( IsValid( mainSpike ) && mainSpike.IsSolid() ) || ( mainSpike == null && spike.IsSolid() ) )
		{
			spike.SetModel( spike.e.altModel )
			if( touchingEnemy )
			{
				spike.SetModelScale( SPIKE_STRIP_SPIKE_SCALE_STABBING )
			}
			else
			{
				spike.SetModelScale( SPIKE_STRIP_SPIKE_SCALE_ACTIVE )
			}
		}
		else
		{
			spike.SetModel( spike.e.baseModel )
			spike.SetModelScale( SPIKE_STRIP_SPIKE_SCALE_DORMANT )
		}

		WaitFrame()
	}
}

void function SpikeTotemTriggerThread( entity totem, entity trigger, int teamId )
{
	EndSignal( trigger, "OnDestroy" )
	EndSignal( totem, "OnDestroy" )

	bool touchingEnemy = false
	bool lastTouchingEnemy = false
	                            
		PassByReferenceBool visibleEnemy
		visibleEnemy.value = false
       

	totem.NotSolid()
	trigger.SearchForNewTouchingEntity()
	AddEntityCallback_OnPostDamaged( totem, OnMainSpikeDamaged )
	totem.SetTakeDamageType( DAMAGE_NO )
	AddEMPDestroyDeviceNoDissolve( totem )

	//EmitSoundOnEntityWithSeek( totem, SPIKE_STRIP_DORMANT_IDLE_SFX, (Time() + SPIKE_STRIP_IDLE_SFX_SEEK_SHIFT + RandomFloat( SPIKE_STRIP_IDLE_SFX_SEEK_VARIANCE )) % SPIKE_STRIP_ACTIVE_IDLE_SFX_REPEAT_TIME )

	entity friendlyFx = StartParticleEffectOnEntityWithPos_ReturnEntity( totem, GetParticleSystemIndex( SPIKE_STRIP_CORE_DORMANT_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0>)
	EffectSetControlPointVector( friendlyFx, 2, FRIENDLY_SPIKE_COLOR )
	friendlyFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
	SetTeam( friendlyFx, teamId )

	entity enemyFx = StartParticleEffectOnEntityWithPos_ReturnEntity( totem, GetParticleSystemIndex( SPIKE_STRIP_CORE_DORMANT_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0>)
	EffectSetControlPointVector( enemyFx, 2, ENEMY_SPIKE_COLOR )
	enemyFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
	SetTeam( enemyFx, teamId )

	OnThreadEnd(
		function () : ( totem, friendlyFx, enemyFx )
		{
			if( IsValid( friendlyFx ) )
				EffectStop( friendlyFx )

			if( IsValid( enemyFx ) )
				EffectStop( enemyFx )
		}
	)

	wait file.activationDelay

	vector totemCenter = totem.GetWorldSpaceCenter()

	while( true )
	{
		touchingEnemy = false
		                            
			visibleEnemy.value = false
        
		array< entity > ents = trigger.GetTouchingEntities()
		foreach( ent in ents )
		{
			if( IsAlive( ent ) && ( ( ( ent.IsPlayer() || ent.IsPlayerDecoy() ) && IsEnemyTeam( ent.GetTeam(), trigger.GetTeam() ) ) || ( ( ent.IsNPC() && !ent.IsNonCombatAI() ) && !IsDropship( ent ) && !IsFriendlyTeam( ent.GetTeam(), trigger.GetTeam() ) ) ) && !ent.IsPhaseShifted() )
			{
                                
					touchingEnemy = true
					totem.e.isBusy = true

					array<entity> ignoreEnts = clone ents
					ignoreEnts.fastremovebyvalue(ent)

					// Trace to ent center
					array<entity> traceEntities
					TraceResults traceResultCenter = TraceLine( totemCenter, ent.GetWorldSpaceCenter(), ignoreEnts, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
					if( IsValid( traceResultCenter.hitEnt ) )
						traceEntities.append( traceResultCenter.hitEnt )

					// Trace to ent Head, if possible
					int index = ent.LookupAttachment( "HEADFOCUS" )
					TraceResults traceResultHead
					if( index != ATTACHMENTID_INVALID )
						traceResultHead = TraceLine( totemCenter, ent.GetAttachmentOrigin( index ), ignoreEnts, TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE )
					if( IsValid( traceResultHead.hitEnt ) )
						traceEntities.append( traceResultHead.hitEnt )

					foreach( hitEnt in traceEntities )
					{
                           
                                                                                                                                       
						     
						if( ( hitEnt == ent ) || hitEnt.GetScriptName() == GIBRALTAR_GUN_SHIELD_NAME )
            
						{
							visibleEnemy.value = true
							break
						}
					}
					if( visibleEnemy.value )
						break
         
                         
                          
          
          
			}
		}

                             
		if( visibleEnemy.value && !lastTouchingEnemy )
      
                                           
       
		{
			StopSoundOnEntity( totem, SPIKE_STRIP_DORMANT_IDLE_SFX)
			EmitSoundOnEntity( totem, SPIKE_STRIP_GO_ACTIVE_SFX )
			//EmitSoundOnEntityWithSeek( totem, SPIKE_STRIP_ACTIVE_IDLE_SFX, (Time() + SPIKE_STRIP_IDLE_SFX_SEEK_SHIFT + RandomFloat( SPIKE_STRIP_IDLE_SFX_SEEK_VARIANCE )) % SPIKE_STRIP_ACTIVE_IDLE_SFX_REPEAT_TIME )
			totem.Solid()
			totem.SetTakeDamageType( DAMAGE_YES )

			friendlyFx.Destroy()
			enemyFx.Destroy()

			friendlyFx = StartParticleEffectOnEntityWithPos_ReturnEntity( totem, GetParticleSystemIndex( SPIKE_STRIP_CORE_ACTIVE_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0>)
			EffectSetControlPointVector( friendlyFx, 2, FRIENDLY_SPIKE_COLOR )
			EffectSetControlPointVector( friendlyFx, 3, <FRIENDLY_OUTLINE_COLOR, 0, 0> )
			friendlyFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
			SetTeam( friendlyFx, teamId )

			enemyFx = StartParticleEffectOnEntityWithPos_ReturnEntity( totem, GetParticleSystemIndex( SPIKE_STRIP_CORE_ACTIVE_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0>)
			EffectSetControlPointVector( enemyFx, 2, ENEMY_SPIKE_COLOR )
			EffectSetControlPointVector( enemyFx, 3, <ENEMY_OUTLINE_COLOR, 0, 0> )
			enemyFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
			SetTeam( enemyFx, teamId )
		}
                             
		else if( !visibleEnemy.value && lastTouchingEnemy )
      
                                                
       
		{

			StopSoundOnEntity( totem, SPIKE_STRIP_ACTIVE_IDLE_SFX)
			EmitSoundOnEntity( totem, SPIKE_STRIP_GO_DORMANT_SFX )
			//EmitSoundOnEntityWithSeek( totem, SPIKE_STRIP_DORMANT_IDLE_SFX, (Time() + SPIKE_STRIP_IDLE_SFX_SEEK_SHIFT + RandomFloat( SPIKE_STRIP_IDLE_SFX_SEEK_VARIANCE )) % SPIKE_STRIP_ACTIVE_IDLE_SFX_REPEAT_TIME )
			totem.NotSolid()
			totem.SetTakeDamageType( DAMAGE_NO )

			friendlyFx.Destroy()
			enemyFx.Destroy()

			friendlyFx = StartParticleEffectOnEntityWithPos_ReturnEntity( totem, GetParticleSystemIndex( SPIKE_STRIP_CORE_DORMANT_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0>)
			EffectSetControlPointVector( friendlyFx, 2, FRIENDLY_SPIKE_COLOR )
			friendlyFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY
			SetTeam( friendlyFx, teamId )

			enemyFx = StartParticleEffectOnEntityWithPos_ReturnEntity( totem, GetParticleSystemIndex( SPIKE_STRIP_CORE_DORMANT_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0>)
			EffectSetControlPointVector( enemyFx, 2, ENEMY_SPIKE_COLOR )
			enemyFx.kv.VisibilityFlags = ENTITY_VISIBLE_TO_ENEMY
			SetTeam( enemyFx, teamId )
		}

		// In range of trap
		if( touchingEnemy )
		{
			entity damageOwner = IsValid( trigger.GetOwner() ) ? trigger.GetOwner()  : svGlobal.worldspawn
			foreach( ent in ents )
			{
				if( !IsValid( ent ) || ent.IsPhaseShifted() || IsFriendlyTeam( damageOwner.GetTeam(), ent.GetTeam() ) || ( ent.IsPlayer() && PlayerHasPassive( ent, ePassives.PAS_LOCKDOWN ) ) )
					continue

				if( SpikeStrip_InSpikes( totem, trigger, ent ) )
				{
					if( !ent.e.spikeCoreTriggers.contains( trigger ) )
					{
						ent.e.spikeCoreTriggers.append( trigger )
						if( ent.e.spikeCoreTriggers.len() == 1)
						{
                                   
								thread SpikeStripEnterThread( ent, visibleEnemy )
            
                                           
             
						}
					}
				}
			}
		}

		#if DEVELOPER && SPIKE_STRIP_DEBUG
		array< entity > linkedSpikes = totem.GetLinkEntArray()
		foreach( spike in linkedSpikes )
		{
			if( IsValid( spike ) )
			{
				vector cylinderBottom  = spike.GetOrigin()
				DebugDrawCylinder( cylinderBottom, RotateAnglesAboutAxis( spike.GetAngles(), spike.GetRightVector(), 90 ), file.pieceRadius, file.pieceHeight, COLOR_YELLOW, true, 0.1 )
			}
		}

		vector cylinderBottom  = totem.GetOrigin()
		DebugDrawCylinder( cylinderBottom, RotateAnglesAboutAxis( totem.GetAngles(), totem.GetRightVector(), 90 ), file.pieceRadius, file.pieceHeight, COLOR_YELLOW, true, 0.1 )
		#endif

                              
			lastTouchingEnemy = visibleEnemy.value
       
                                    
        
		WaitFrame()
	}
}

bool function SpikeStrip_InSpikes( entity spikeCore, entity trigger, entity ent )
{
	array< entity > linkedSpikes = spikeCore.GetLinkEntArray()

	bool inSpikes = false

	foreach( spike in linkedSpikes )
	{
		if( IsValid( spike ) )
		{
			vector cylinderBottom  = spike.GetOrigin()
			vector cylinderTop = cylinderBottom + ( spike.GetUpVector() * file.pieceHeight )
			float radius = file.pieceRadius

			if( PointInCylinder( cylinderBottom, cylinderTop, radius, ent.GetOrigin() ) )
			{
				inSpikes = true
				break
			}
		}
	}

	if( !inSpikes )
	{
		vector cylinderBottom  = spikeCore.GetOrigin()
		vector cylinderTop = cylinderBottom + ( spikeCore.GetUpVector() * file.pieceHeight )
		float radius = file.pieceRadius

		if( PointInCylinder( cylinderBottom, cylinderTop, radius, ent.GetOrigin() ) )
		{
			inSpikes = true
		}
	}

	return inSpikes
}

                            
void function SpikeStripEnterThread( entity player, PassByReferenceBool visibleEnemy )
     
                                                    
      
{
	EndSignal( player, "OnDestroy" )
	if( player.IsPlayer() )
	{
		EndSignal( player, "OnDeath" )
		EndSignal( player, "StartPhaseShift" )
	}

	int handle = StatusEffect_AddEndless( player, eStatusEffect.move_slow, player.IsPlayer() ? SPIKE_STRIP_SPIKE_SLOW_SCALER : SPIKE_STRIP_SPIKE_SLOW_NPC_SCALER )
	if( player.IsPlayer() && !player.IsOnGround() )
	{
		vector vel = player.GetVelocity()
		player.SetVelocity( < vel.x / 2.0, vel.y / 2.0, vel.z > )
	}
	else if( player.IsPlayer() && player.IsSliding() )
	{
		vector vel = player.GetVelocity()
		player.SetVelocity( < vel.x / 2.0, vel.y / 2.0, vel.z > )
	}

	OnThreadEnd( function() : ( player, handle )
	{
		if ( IsValid( player ) )
		{
			StatusEffect_Stop( player, handle )
			player.e.spikeCoreTriggers.clear()
		}
	} )

	while( true )
	{
		for ( int i = player.e.spikeCoreTriggers.len() - 1; i >= 0 ; i-- )
		{
			if( !IsAlive( player ) )
				continue

			bool remove = true
			entity trigger = player.e.spikeCoreTriggers[ i ]
			if ( IsValid( trigger ) )
			{
				entity damageOwner = IsValid( trigger.GetOwner() ) ? trigger.GetOwner() : svGlobal.worldspawn
				entity spikeCore = trigger.GetParent()
                                
				if( IsValid( spikeCore ) )
         
                                                     
          
				{
					if( SpikeStrip_InSpikes( spikeCore, trigger, player ) )
					{
						remove = false
						                            
						if( visibleEnemy.value && spikeCore.IsSolid() )
            
						{
							if ( (!(player in file.lastSpikeDamageTime)) || ((Time() - file.lastSpikeDamageTime[ player ]) > SPIKE_STRIP_SPIKE_DAMAGE_DEBOUNCE_TIME) )
							{
								player.TakeDamage( SPIKE_STRIP_SPIKE_DAMAGE, damageOwner, trigger.GetParent(), { damageSourceId = eDamageSourceId.mp_ability_spike_strip } )
								if ( player.IsPlayer() )
								{
									EmitSoundOnEntityExceptToPlayer( player, player, SPIKE_STRIP_PLAYER_DAMAGE_3P )
									EmitSoundOnEntityOnlyToPlayer( player, player, SPIKE_STRIP_PLAYER_DAMAGE_1P )

									                             
										ShadowZombie_TryDamagingTrapAfterTakingDamage( player, damageOwner, spikeCore )
               
								}
								else
								{
									EmitSoundOnEntity( player, SPIKE_STRIP_PLAYER_DAMAGE_3P )
								}

								file.lastSpikeDamageTime[ player ] <- Time()
							}
						}
					}
				}
			}
			if( remove )
				player.e.spikeCoreTriggers.remove( i )

			if( player.e.spikeCoreTriggers.len() == 0 )
				return
		}
		WaitFrame()
	}
}

void function SpikeTriggerEnter( entity trigger, entity ent )
{
	if ( IsAlive( ent ) && ( ent.IsPlayer() || ent.IsNPC() ) )
		thread SpikeTriggerEnterThread( trigger, ent )
}

void function SpikeTriggerEnterThread( entity trigger, entity player )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( trigger, "OnDestroy" )

	if(  player.IsPlayer() && PlayerHasPassive( player, ePassives.PAS_LOCKDOWN )  )
		 return

	entity damageOwner = IsValid( trigger.GetOwner() ) ? trigger.GetOwner()  : svGlobal.worldspawn
	if( IsFriendlyTeam( damageOwner.GetTeam(), player.GetTeam() ) )
		return

	if( !( player in file.moveSlowTable ) )
	{
		MoveSlowData data
		data.handle = StatusEffect_AddEndless( player, eStatusEffect.move_slow, player.IsPlayer() ? SPIKE_STRIP_SPIKE_SLOW_SCALER : SPIKE_STRIP_SPIKE_SLOW_NPC_SCALER )
		data.refCount = 1
		file.moveSlowTable[ player ] <- data
		if( player.IsPlayer() && !player.IsOnGround() )
		{
			vector vel = player.GetVelocity()
			player.SetVelocity( < vel.x / 2.0, vel.y / 2.0, vel.z > )
		}
	}
	else
	{
		file.moveSlowTable[ player ].refCount++
	}

	OnThreadEnd( function() : ( player )
	{
		if ( IsValid( player ) && player in file.moveSlowTable )
		{
			file.moveSlowTable[ player ].refCount--
			if( file.moveSlowTable[ player ].refCount == 0 )
			{
				StatusEffect_Stop( player, file.moveSlowTable[ player ].handle )
				delete file.moveSlowTable[ player ]
			}
		}
	} )

	bool firstLoop = true
	while( trigger.IsTouching( player ) )
	{
		if( firstLoop )
		{
			if( player.IsPlayer() && player.IsSliding() )
			{
				vector vel = player.GetVelocity()
				player.SetVelocity( < vel.x / 2.0, vel.y / 2.0, vel.z > )
			}
		}

		damageOwner = IsValid( trigger.GetOwner() ) ? trigger.GetOwner()  : svGlobal.worldspawn
		if( ( !( player in file.lastSpikeDamageTime ) ) || ( ( Time() - file.lastSpikeDamageTime[ player ] ) > SPIKE_STRIP_SPIKE_DAMAGE_DEBOUNCE_TIME ) )
		{
			player.TakeDamage( SPIKE_STRIP_SPIKE_DAMAGE, damageOwner, trigger.GetParent(), { damageSourceId = eDamageSourceId.mp_ability_spike_strip } )
			if( player.IsPlayer() )
			{
				EmitSoundOnEntityExceptToPlayer( player, player, SPIKE_STRIP_PLAYER_DAMAGE_3P )
				EmitSoundOnEntityOnlyToPlayer( player, player, SPIKE_STRIP_PLAYER_DAMAGE_1P )

				                             
					ShadowZombie_TryDamagingTrapAfterTakingDamage( player, damageOwner, damageOwner )
          
			}
			else
			{
				EmitSoundOnEntity( player, SPIKE_STRIP_PLAYER_DAMAGE_3P )
			}

			file.lastSpikeDamageTime[ player ] <- Time()
		}
		firstLoop = false
		WaitFrame()
	}
}
void function OnLittleSpikeDamaged( entity spike, var damageInfo )
{
	float damage = DamageInfo_GetDamage( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	vector pos = spike.GetOrigin()

	if ( damage > 0 )
	{
		entity mainSpike = spike.e.ownerWeapon
		if( IsValid( mainSpike ) )
			mainSpike.TakeDamage( damage, attacker, spike, { damageSourceId =  DamageInfo_GetDamageSourceIdentifier( damageInfo ), scriptType =  DamageInfo_GetDamageFlags( damageInfo )  }   )

		if ( IsValid( attacker ) && IsAlive( attacker ) && attacker.IsPlayer() )
		{
			int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )
			if ( IsBitFlagSet( damageFlags, DF_MELEE ) )
			{
				if( IsFriendlyTeam( spike.GetTeam(), attacker.GetTeam() ) )
				{
					DamageInfo_SetDamage( damageInfo, spike.GetMaxHealth() )
				}
				DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
			}

			DamageInfo_AddCustomDamageType( damageInfo, DAMAGEFLAG_VICTIM_HAS_VORTEX )
			attacker.NotifyDidDamage( spike, 0, DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ),
				DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ) | DF_NO_HITBEEP,
				DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
		}
		EmitSoundAtPosition( TEAM_ANY, spike.GetOrigin() + <0, 0, SPIKE_STRIP_SFX_Z_OFFSET>, RESIN_IMPACT_3P_SOUND, spike )
	}

	damage = DamageInfo_GetDamage( damageInfo )

	if( damage >= spike.GetHealth() )
	{
		StartParticleEffectInWorld( GetParticleSystemIndex( $"P_debris_blast_vert" ), pos, ZERO_VECTOR )
		EmitSoundOnEntity( spike, RESIN_CRUMBLE_3P_SOUND )
	}

	DamageInfo_ScaleDamage( damageInfo, 0 )
}

void function OnMainSpikeDamaged( entity spike, var damageInfo )
{
	float damage = DamageInfo_GetDamage( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	vector pos = spike.GetOrigin()

	if ( damage > 0 )
	{
		if ( IsValid( attacker ) && IsAlive( attacker ) && attacker.IsPlayer() )
		{
			int damageFlags = DamageInfo_GetCustomDamageType( damageInfo )
			if ( IsBitFlagSet( damageFlags, DF_MELEE ) )
			{
                              
					if ( TitanSword_PostCopySanityCheck( "catalyst" ) )
					{
						bool isTitanSword = TitanSword_DamageSourceIsTitanSword( DamageInfo_GetDamageSourceIdentifier( damageInfo ) )
						if ( IsFriendlyTeam( spike.GetTeam(), attacker.GetTeam() ) || isTitanSword )
						{
							DamageInfo_SetDamage( damageInfo, spike.GetMaxHealth() )
						}
					}
					else
					{
						if ( IsFriendlyTeam( spike.GetTeam(), attacker.GetTeam() ) )
						{
							DamageInfo_SetDamage( damageInfo, spike.GetMaxHealth() )
						}
					}
         
                                                                 
      
                                                              
      
          
				DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
			}
			else if( !IsValid( inflictor ) || !( inflictor.GetModelName() == SPIKE_STRIP_SPIKE_ACTIVE ) )
			{
				DamageInfo_ScaleDamage( damageInfo, 2.0 )
				DamageInfo_AddCustomDamageType( damageInfo, DF_CRITICAL )
			}

			DamageInfo_AddCustomDamageType( damageInfo, DAMAGEFLAG_VICTIM_HAS_VORTEX )
			attacker.NotifyDidDamage( spike, 0, DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ),
				DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ) | DF_NO_HITBEEP,
				DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
		}
		EmitSoundAtPosition( TEAM_ANY, spike.GetOrigin() + <0, 0, SPIKE_STRIP_SFX_Z_OFFSET>, RESIN_IMPACT_3P_SOUND, spike )
	}

	damage = DamageInfo_GetDamage( damageInfo )

	if( damage >= spike.GetHealth() )
	{
		EmitSoundAtPosition( TEAM_ANY, spike.GetOrigin() + <0, 0, SPIKE_STRIP_SFX_Z_OFFSET>, SPIKE_STRIP_DESTROY_3P, spike )
	}
}
#endif


#if CLIENT
void function OnClientAnimEvent_ability_spike_strip( entity weapon, string name )
{
	GlobalClientEventHandler( weapon, name )

	if ( name == "muzzle_flash" )
	{
		weapon.PlayWeaponEffect( SPIKE_STRIP_MUZZLE_FLASH_FP, SPIKE_STRIP_MUZZLE_FLASH_3P, "muzzle_flash" )
	}
}

void function WeaponActive_Client( entity owner, entity weapon )
{
	EndSignal( weapon, KILL_CLIENT_THREAD_SIGNAL )
	EndSignal( weapon, "OnDestroy" )
	EndSignal( owner, "OnDestroy" )

}

entity function SpikeStripCreatePlacementProxy( asset modelName )
{
	entity proxy = CreateClientSidePropDynamic( <0, 0, 0>, <0, 0, 0>, modelName )
	proxy.EnableRenderAlways()
	proxy.kv.rendermode = 3
	proxy.kv.renderamt = 1
	proxy.Hide()

	return proxy
}

void function MainSpikeCreated( entity spike )
{
	SetAllowForKillreplayProjectileCam( spike )
	SetCustomKillreplayChaseCamFromWeaponClass( spike, SPIKE_STRIP_WEAPON_NAME )

	entity player = GetLocalViewPlayer()
	ShowGrenadeArrow( player, spike, GetTriggerRadius( spike.GetOwner() ), 0.0, true, eThreatIndicatorVisibility.INDICATOR_SHOW_TO_ENEMIES )
}

void function UseEntityCreated( entity useEnt )
{
	AddCallback_OnUseEntity_ClientServer( useEnt, SpikeStrip_OnUseClient )
}

void function SpikeStrip_OnUseClient( entity spike, entity player, int useFlags )
{
	if ( IsControllerModeActive() )
	{
		if ( !IsBitFlagSet( useFlags, USE_INPUT_LONG ) )
		{
			thread IssueReloadCommand( player )
		}
	}
}

void function OnCharacterButtonPressed( entity player )
{
                         
                                               
        
       

	entity useEnt = player.GetUsePromptEntity()
	if ( !IsValid( useEnt ) || useEnt.GetTargetName() != SPIKE_STRIP_USE_ENTITY_NAME )
		return

	if ( useEnt.GetOwner() != player )
		return

	CustomUsePrompt_SetLastUsedTime( Time() )

	entity coreSpike = useEnt.GetParent()
	if( IsValid( coreSpike ) )
		Remote_ServerCallFunction( "ClientCallback_TryPickupSpikeStrip", coreSpike )
}

void function SpikeStrip_OnGainFocus( entity ent )
{
	if ( !IsValid( ent ) )
		return

	entity player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	if ( player == ent.GetOwner() && ent.GetTargetName() == SPIKE_STRIP_USE_ENTITY_NAME )
	{
                          
                                                
   
                                                                
   
      
        
		{
			CustomUsePrompt_SetText( Localize( "#WPN_SPIKES_PICKUP" ) )
		}
		CustomUsePrompt_Show( ent )
	}
}

void function SpikeStrip_OnLoseFocus( entity ent )
{
	CustomUsePrompt_ClearForAny()
}

void function MinimapPackage_SpikeStrip( entity ent, var rui )
{
	#if MINIMAP_DEBUG
		printt( "Adding 'rui/hud/gametype_icons/survival/catalyst_ult_map_icon' icon to minimap" )
	#endif
	RuiSetImage( rui, "defaultIcon", $"rui/hud/gametype_icons/survival/catalyst_ult_map_icon" )
	RuiSetImage( rui, "clampedDefaultIcon", $"rui/hud/gametype_icons/survival/catalyst_ult_map_icon" )
	RuiSetBool( rui, "useTeamColor", false )
	RuiSetFloat( rui, "iconBlend", 0.0 )
}
#endif // CLIENT
 