                               
global function Valentines_S15_Mode_Init

global function Valentines_S15_ILoveYouEasterEggEnabled
global function Valentines_S15_SpawnTicks

global function ValentinesIsPlayerInRangeForProximityBuff
global function ValentinesGetPartner

#if SERVER
global function Valentines_IsPairInRange
global function ValentinesHandleSharedHealingTells_Thread
global function Valentines_ShowRangeFX
#if DEVELOPER
global function DEV_SpawnValentinesTick
global function DEV_GetValentinesTickSpawnLocation
#endif
#endif
#if CLIENT
global function ClValentines_Init
global function ServerToClient_Valentines_Add1pVFX
global function ServerToClient_Valentines_Stop1pVFX
#endif

const string VALENTINES_DISABLE_MAPS_PLAYLIST_VAR = "valentines_disable_maps"
const string VALENTINES_TOGETHER_DISTANCE_PLAYLIST_VAR = "valentines_together_dist"
const string VALENTINES_TOGETHER_DISTANCE_IS_2D_PLAYLIST_VAR = "valentines_together_2d"
const string VALENTINES_TOGETHER_DISTANCE_Z_CLAMP_PLAYLIST_VAR = "valentines_together_z_height"
const string VALENTINES_HEALING_FX_ONLY_ON_HEAL_PLAYLIST_VAR = "valentines_fx_only_heal"
const string VALENTINES_I_LOVE_YOU_PLAYLIST_VAR = "valentines_s16_luv_u"
const string VALENTINES_BOW_RESKIN_PLAYLIST_VAR = "valentines_bow_reskin"
const string VALENTINES_SPAWN_ALL_TICKS_PLAYLIST_VAR = "valentines_spawn_all_ticks"
const string VALENTINES_SPAWN_TICKS_PLAYLIST_VAR = "valentines_spawn_ticks"
const string VALENTINES_TICKS_PER_CLUSTER_PLAYLIST_VAR = "valentines_ticks_per_cluster"

global const string VALENTINES_S15_HEAL_SUCCESS_SIGNAL = "ValentinesHealSuccess"
global const string VALENTINES_S15_HEAL_CANCELED_SIGNAL = "ValentinesHealCancel"
global const string VALENTINES_S15_STOP_1P_FX_SIGNAL = "ValentinesStop1P"
const float VALENTINES_TOGETHER_DISTANCE_DEFAULT = 12 * METERS_TO_INCHES

const VFX_COCKPIT_HEAL = $"P_heal_loop_screen"
const FX_SHIELD_CHARGING = $"P_armor_FP_charging_CP"
const asset VFX_ULT_ACCEL_CONT = $"P_UltAcc_screenSpace_cont"

const asset RANGE_RADIUS_REMINDER_FX = $"P_ar_edge_ring_mid"
const float TROPHY_AR_EFFECT_SIZE = 768.0 // coresponds with the size of the sphere model used for the AR effect


const int VALENTINES_TICKS_PER_CLUSTER = 4
global const int VALENTINES_SPECIAL_EVENT_LOOT_TIER = 6

const string VALENTINES_BOW_WEAPON_REF = "mp_weapon_bow_cupid"

#if SERVER
const asset VALENTINES_BOW_CHARM = $"settings/itemflav/weapon_charm/charm_apex_event_v20_valentines_nessie_love01.rpak"
const asset VALENTINES_BOW_SKIN = $"settings/itemflav/weapon_skin/compound_bow/epicp_v23_valentines.rpak"
#endif

enum ValentinesConsumableType
{
	Phoenix,
	Health,
	Shields,
	Ult
}

struct TeamData
{
	bool currentlyInRange
}

struct StatusEffectHandles
{
	int shieldHealHandle
	int healthHealHandle
	int ultChargeHandle
}

struct
{
	table<int, TeamData> teamData

	float togetherSquareDist
	float togetherDist

	#if SERVER
		int ticksPerCluster = VALENTINES_TICKS_PER_CLUSTER
	#endif
} file

bool function Valentines_S15_ILoveYouEasterEggEnabled()
{
	return GetCurrentPlaylistVarBool( VALENTINES_I_LOVE_YOU_PLAYLIST_VAR, true )
}

bool function Valentines_S15_BowReskinEnabled()
{
	return GetCurrentPlaylistVarBool( VALENTINES_BOW_RESKIN_PLAYLIST_VAR, true )
}

bool function IsValidGameMode()
{
	return !GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_RANKED )
}

bool function IsValidMap( string map )
{
	array<string> disabledMaps = split( GetCurrentPlaylistVarString( VALENTINES_DISABLE_MAPS_PLAYLIST_VAR, "" ), "," )
	return !disabledMaps.contains( map )
}

bool function Valentines_S15_SpawnTicks()
{
	return GetCurrentPlaylistVarBool( VALENTINES_SPAWN_TICKS_PLAYLIST_VAR, true )
}

bool function DebugAllValentinesTicks()
{
	return GetCurrentPlaylistVarBool( VALENTINES_SPAWN_ALL_TICKS_PLAYLIST_VAR, false )
}

void function Valentines_S15_Mode_Init()
{
	Assert( IsValidGameMode() )

	PrecacheParticleSystem( RANGE_RADIUS_REMINDER_FX )
	PrecacheParticleSystem( VFX_ULT_ACCEL_CONT )

	float togetherDist = GetCurrentPlaylistVarFloat( VALENTINES_TOGETHER_DISTANCE_PLAYLIST_VAR, VALENTINES_TOGETHER_DISTANCE_DEFAULT )
	file.togetherDist       = togetherDist
	file.togetherSquareDist = togetherDist * togetherDist

	RegisterSignal( VALENTINES_S15_HEAL_SUCCESS_SIGNAL )
	RegisterSignal( VALENTINES_S15_HEAL_CANCELED_SIGNAL )
	RegisterSignal( VALENTINES_S15_STOP_1P_FX_SIGNAL )

	#if SERVER
		thread SetupServerTeamMonitoring_Thread()

		if ( Valentines_S15_BowReskinEnabled() )
			Loot_AddCallback_OnLootSpawn( OnLootSpawn )

		if ( Valentines_S15_SpawnTicks() )
		{
			file.ticksPerCluster = GetCurrentPlaylistVarInt( VALENTINES_TICKS_PER_CLUSTER_PLAYLIST_VAR, VALENTINES_TICKS_PER_CLUSTER )
			AddCallback_EntitiesDidLoad( OnEntitiesDidLoad )
		}
	#endif

	ShGameMode_Valentines_S15_RegisterNetworking()
}


void function ShGameMode_Valentines_S15_RegisterNetworking()
{
	Remote_RegisterClientFunction( "ServerToClient_Valentines_Add1pVFX", "float", 0.0, 99.0, 8, "int", 0, 126, "int", 0, 101 )
	Remote_RegisterClientFunction( "ServerToClient_Valentines_Stop1pVFX" )
}

#if CLIENT
void function ClValentines_Init()
{
	// Change Commentary Strings for Valentines
	SurvivalCommentary_SetStringCallback( Valentines_S15_GetString )

	thread SetupClientTeamMonitoring_Thread()
}
#endif

bool function ValentinesIsPlayerInRangeForProximityBuff( entity player )
{
	if ( !IsValid( player ) || !player.IsPlayer() )
		return false

	if ( player.IsShadowForm() )
		return false

	if ( player.IsPhaseShifted() )
		return false

	int team = player.GetTeam()

	if ( team in file.teamData )
	{
		return file.teamData[team].currentlyInRange
	}

	return false
}

entity function ValentinesGetPartner( entity self )
{
	if ( !IsValid( self ) || !self.IsPlayer() )
		return null

	int team = self.GetTeam()

	array<entity> teammates = GetPlayerArrayOfTeam_Alive( team )

	if ( teammates.len() != 2 )
		return null

	if ( teammates[0] == self )
		return teammates[1]

	return teammates[0]
}

#if SERVER
void function SetupServerTeamMonitoring_Thread()
{
	//wait until match is started
	//wait until skydive done?
	foreach ( int team in GetAllTeams() )
	{
		TeamData newData
		file.teamData[team] <- newData
		thread MonitorTeamProximity_Thread( team )
	}
}
#endif

#if CLIENT
void function SetupClientTeamMonitoring_Thread()
{
	entity player
	while( true )
	{
		player = GetLocalClientPlayer()
		if ( IsValid( player ) && player.IsPlayer() && player.GetTeam() >= TEAM_IMC )
			break

		WaitFrame()
	}

	int playerTeam = player.GetTeam()

	TeamData newData
	file.teamData[playerTeam] <- newData
	MonitorTeamProximity_Thread( playerTeam )
}

void function UpdateClientHUD( int team )
{

}
#endif //CLIENT

void function MonitorTeamProximity_Thread( int team )
{
	file.teamData[team].currentlyInRange = false

	//TODO This is just a semi lazy way to wait until the match is going proper...
	//works really good in debug though!
	while ( true )
	{
		array<entity> teammates = GetPlayerArrayOfTeam( team )

		if ( teammates.len() == 2 )
			break

		WaitFrame()
	}

	while( true )
	{
		//wait is at the start just to simplify the flow logic in this loop.
		//logic before the wait is actually run at the end of the tick
		#if CLIENT
			UpdateClientHUD( team )
		#endif //CLIENT
		WaitFrame()

		bool previouslyInRange               = file.teamData[team].currentlyInRange
		//resetting it here since to make sure we don't miss setting it to false if we early out in this loop
		file.teamData[team].currentlyInRange = false

		array<entity> teammates = GetPlayerArrayOfTeam( team )
		int numberOfTeammates   = teammates.len()

		//everyone is dead, lets bail
		if ( numberOfTeammates == 0 )
			break

		if ( teammates.len() != 2 )
			continue

		int numInvalidPlayers = 0
		bool allPlayersValid  = true
		foreach ( entity player in teammates )
		{
			if ( !IsValid( player ) )
			{
				numInvalidPlayers++
				allPlayersValid = false
			}

			if ( numInvalidPlayers > 0 )
				continue

			if ( !IsValidPlayerForProximityBuff( player ) )
			{
				allPlayersValid = false
				break
			}
		}

		if ( numInvalidPlayers == teammates.len() )
			break

		if ( !allPlayersValid )
			continue

		bool isPairInRange = IsPairInRangeForProximityBuff( teammates[0], teammates[1] )

		file.teamData[team].currentlyInRange = isPairInRange
		if ( isPairInRange )
		{
			#if CLIENT
				//DebugDrawSphere( teammates[0].GetOrigin(), 5, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), false, .1 )
				//DebugDrawSphere( teammates[1].GetOrigin(), 5, int(COLOR_GREEN.x), int(COLOR_GREEN.y), int(COLOR_GREEN.z), false, .1 )
			#endif
		}
	}

	//printf("Valentines Day Thread end" + team)
	file.teamData[team].currentlyInRange = false
}

bool function IsValidPlayerForProximityBuff( entity player )
{
	Assert( IsValid( player ) && player.IsPlayer() )

	if ( !IsAlive( player ) )
		return false

	if ( Bleedout_IsBleedingOut( player ) )
		return false

	return true
}

#if SERVER
bool function Valentines_IsPairInRange( entity player1, entity player2 )
{
	if ( !IsValid( player1 ) || !IsValid( player2 ) )
		return false

	return IsPairInRangeForProximityBuff( player1, player2 )
}
#endif //SERVER

bool function IsPairInRangeForProximityBuff( entity player1, entity player2 )
{
	Assert( IsValid( player1 ) && IsValid( player2 ) )

	vector from1To2 = player2.GetOrigin() - player1.GetOrigin()

	float maxZHeight = 0.0
	float zHeight    = 0.0
	if ( GetCurrentPlaylistVarBool( VALENTINES_TOGETHER_DISTANCE_IS_2D_PLAYLIST_VAR, true ) )
	{
		maxZHeight = GetCurrentPlaylistVarFloat( VALENTINES_TOGETHER_DISTANCE_Z_CLAMP_PLAYLIST_VAR, file.togetherDist )
		if ( maxZHeight != 0.0 )
		{
			zHeight = fabs( from1To2.z )
		}
		from1To2 = FlattenVec( from1To2 )
	}

	if ( LengthSqr( from1To2 ) < file.togetherSquareDist )
	{
		if ( zHeight <= maxZHeight )
		{
			return true
		}
	}

	return false
}

bool function WillBenefitFromUltAccel( entity ent )
{
	entity ultimateAbility = ent.GetOffhandWeapon( OFFHAND_INVENTORY )
	if ( IsValid( ultimateAbility ) )
	{
		int ammo    = ultimateAbility.GetWeaponPrimaryClipCount()
		int maxAmmo = ultimateAbility.GetWeaponPrimaryClipCountMax()
		if ( ammo < maxAmmo && ultimateAbility.IsReadyToFire() && !ultimateAbility.HasMod( MOBILE_HMG_ACTIVE_MOD ) && !ultimateAbility.HasMod( ULTIMATE_ACTIVE_MOD_STRING ) )
			return true
	}
	return false
}

#if CLIENT
void function ServerToClient_Valentines_Add1pVFX( float duration, int shieldHealAmount, int healthHealAmount )
{
	thread Valentines_Add1pVFX_Thread( duration, shieldHealAmount, healthHealAmount )
}

void function ServerToClient_Valentines_Stop1pVFX()
{
	entity self = GetLocalClientPlayer()
	if ( !self )
		return

	Signal( self, VALENTINES_S15_STOP_1P_FX_SIGNAL )
}

void function Valentines_Add1pVFX_Thread( float duration, int shieldHealAmount, int healthHealAmount )
{
	entity self = GetLocalClientPlayer()
	if ( !self )
		return

	entity cockpit = self.GetCockpit()
	if ( cockpit && !IsSpectating() )
	{
		EndSignal( self, "OnDeath", "OnDestroy", VALENTINES_S15_STOP_1P_FX_SIGNAL )

		StatusEffectHandles effectHandles
		effectHandles.healthHealHandle = 0
		effectHandles.shieldHealHandle = 0
		effectHandles.ultChargeHandle  = 0

		int healthFxID = GetParticleSystemIndex( VFX_COCKPIT_HEAL )
		int shieldFxID = GetParticleSystemIndex( FX_SHIELD_CHARGING )
		int ultFxID    = GetParticleSystemIndex( VFX_ULT_ACCEL_CONT )

		OnThreadEnd(
			function() : ( effectHandles )
			{
				if ( EffectDoesExist( effectHandles.healthHealHandle ) )
					EffectStop( effectHandles.healthHealHandle, false, true )
				if ( EffectDoesExist( effectHandles.shieldHealHandle ) )
					EffectStop( effectHandles.shieldHealHandle, false, true )
				if ( EffectDoesExist( effectHandles.ultChargeHandle ) )
					EffectStop( effectHandles.ultChargeHandle, false, true )
			}
		)

		bool wasInRange     = false
		float endTime       = Time() + duration
		float fxRestartTime = 0
		while ( Time() < endTime )
		{
			bool gettingHealth  = false
			bool gettingShields = false
			bool gettingUlt     = false
			bool inRange        = ValentinesIsPlayerInRangeForProximityBuff( self )
			if ( inRange )
			{
				wasInRange = true
				if ( shieldHealAmount > 0 )
				{
					int currentShields  = self.GetShieldHealth()
					int shieldHealthMax = self.GetShieldHealthMax()
					if ( shieldHealthMax > 0 && currentShields < shieldHealthMax )
					{
						gettingShields = true
					}
				}

				if ( healthHealAmount > 0 )
				{
					int currentHealth = self.GetHealth()
					int healthMax     = self.GetMaxHealth()
					if ( currentHealth < healthMax )
					{
						gettingHealth = true
					}
				}

				if ( healthHealAmount == 0 && shieldHealAmount == 0 )
				{
					gettingUlt = WillBenefitFromUltAccel( self )
				}
			}
			else if ( !inRange && wasInRange )
			{
				wasInRange = false
			}

			bool showHealthFX = inRange && gettingHealth && !gettingShields
			bool showShieldFX = inRange && gettingShields
			bool showUltFX    = inRange && gettingUlt

			if ( !showUltFX )
			{
				if ( EffectDoesExist( effectHandles.ultChargeHandle ) )
					EffectStop( effectHandles.ultChargeHandle, false, true )
			}
			else
			{
				if ( !EffectDoesExist( effectHandles.ultChargeHandle ) )
				{
					effectHandles.ultChargeHandle = StartParticleEffectOnEntity( cockpit, ultFxID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
					EffectSetIsWithCockpit( effectHandles.ultChargeHandle, true )
					EffectSetControlPointVector( effectHandles.ultChargeHandle, 1, <255, 208, 56> )
				}
			}

			if ( !showHealthFX )
			{
				if ( EffectDoesExist( effectHandles.healthHealHandle ) )
					EffectStop( effectHandles.healthHealHandle, false, true )
			}
			else
			{
				if ( !EffectDoesExist( effectHandles.healthHealHandle ) )
				{
					effectHandles.healthHealHandle = StartParticleEffectOnEntity( self, healthFxID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
					EffectSetIsWithCockpit( effectHandles.healthHealHandle, true )
				}
			}

			if ( !showShieldFX )
			{
				if ( EffectDoesExist( effectHandles.shieldHealHandle ) )
				{
					EffectStop( effectHandles.shieldHealHandle, false, true )
				}
				fxRestartTime = FLT_MAX
			}
			else
			{
				if ( fxRestartTime == FLT_MAX )
				{
					fxRestartTime = 0
				}
				if ( Time() >= fxRestartTime )
				{
					int armorTier      = EquipmentSlot_GetEquipmentTier( self, "armor" )
					vector shieldColor = GetFXRarityColorForTier( armorTier )

					if ( EffectDoesExist( effectHandles.shieldHealHandle ) )
					{
						EffectStop( effectHandles.shieldHealHandle, false, true )
					}
					effectHandles.shieldHealHandle = StartParticleEffectOnEntity( cockpit, shieldFxID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
					EffectSetIsWithCockpit( effectHandles.shieldHealHandle, true )
					EffectSetControlPointVector( effectHandles.shieldHealHandle, 1, shieldColor )

					fxRestartTime = Time() + .23
				}
			}

			WaitFrame()
		}
	}
}
#endif //CLIENT

#if SERVER
string function GetChargingSFX( int type )
{
	switch ( type )
	{
		case ValentinesConsumableType.Phoenix:
			return "DateNight_AOE_PhoenixKit_Charge_1P"

		case ValentinesConsumableType.Health:
			return "DateNight_AOE_Healing_Charge_1P"

		case ValentinesConsumableType.Shields:
			return "DateNight_AOE_Shield_Charge_1P"

		case ValentinesConsumableType.Ult:
			return "DateNight_AOE_Ult_Acc_Charge_1P"
	}
	Assert( false, "called GetChargingSFX with invalid type" )
	return ""
}

string function GetCancelSFX( int type )
{
	switch ( type )
	{
		case ValentinesConsumableType.Phoenix:
			return "DateNight_AOE_PhoenixKit_Failure_1P"

		case ValentinesConsumableType.Health:
			return "DateNight_AOE_Healing_Failure_1P"

		case ValentinesConsumableType.Shields:
			return "DateNight_AOE_Shield_Failure_1P"

		case ValentinesConsumableType.Ult:
			return "DateNight_AOE_Ult_Acc_Failure_1P"
	}
	Assert( false, "called GetCancelSFX with invalid type" )
	return ""
}

void function ValentinesHandleHealingCanceledSFX_Thread( entity healingEnt, entity partner, int consumableType, int shieldHealAmount, int healthHealAmount )
{
	EndSignal( healingEnt, VALENTINES_S15_HEAL_SUCCESS_SIGNAL, "OnDeath", "OnDestroy" )
	EndSignal( partner, "OnDeath", "OnDestroy" )

	WaitSignal( healingEnt, VALENTINES_S15_HEAL_CANCELED_SIGNAL )

	if ( ValentinesIsPlayerInRangeForProximityBuff( partner ) )
	{
		bool playCancelSound = false
		if ( shieldHealAmount > 0 )
		{
			int partnerCurrentShields  = partner.GetShieldHealth()
			int partnerShieldHealthMax = partner.GetShieldHealthMax()
			float partnerTargetShields = 0
			if ( partnerShieldHealthMax > 0 && partnerCurrentShields < partnerShieldHealthMax )
			{
				playCancelSound = true
			}
		}
		if ( !playCancelSound && healthHealAmount > 0 )
		{
			int partnerCurrentHealth  = partner.GetHealth()
			int partnerHealthMax      = partner.GetMaxHealth()
			float partnerTargetHealth = 0
			if ( partnerCurrentHealth < partnerHealthMax )
			{
				playCancelSound = true
			}
		}
		if ( !playCancelSound && consumableType == ValentinesConsumableType.Ult )
		{
			playCancelSound = WillBenefitFromUltAccel( partner )
		}

		if ( playCancelSound )
		{
			StopSoundOnEntity( partner, GetChargingSFX( consumableType ) )
			StopSoundOnEntity( partner, "DateNight_AOE_Generic_Consumable_Start_3P" )
			EmitSoundOnEntityOnlyToPlayer( partner, partner, GetCancelSFX( consumableType ) )
		}
	}
}

void function ValentinesHandleSharedHealingTells_Thread( entity healingEnt, ConsumableInfo info, float healTime )
{
	entity partner = ValentinesGetPartner( healingEnt )

	if ( !IsValid( partner ) )
		return

	EndSignal( healingEnt, VALENTINES_S15_HEAL_SUCCESS_SIGNAL, VALENTINES_S15_HEAL_CANCELED_SIGNAL, "OnDeath", "OnDestroy" )
	EndSignal( partner, "OnDeath", "OnDestroy" )
	StatusEffectHandles effectHandles
	effectHandles.shieldHealHandle = 0
	effectHandles.healthHealHandle = 0
	effectHandles.ultChargeHandle  = 0
	RecoveryHealingFXRequest healingRequest = Player3pHealFXAddRequest( partner, eHealingRequestType.Valentines )

	float healthHealAmount = Consumable_CalculateTotalHealFromItem( partner, info )
	float shieldHealAmount = Consumable_CalculateTotalShieldFromItem( partner, info )

	int consumableType = ValentinesConsumableType.Phoenix
	if ( healthHealAmount == 0 && shieldHealAmount == 0 )
	{
		consumableType = ValentinesConsumableType.Ult
	}
	else if ( healthHealAmount > 0 && shieldHealAmount > 0 )
	{
		consumableType = ValentinesConsumableType.Phoenix
	}
	else if ( healthHealAmount > 0 )
	{
		consumableType = ValentinesConsumableType.Health
	}
	else if ( shieldHealAmount > 0 )
	{
		consumableType = ValentinesConsumableType.Shields
	}
	else
	{
		Assert( false, "Invalid ValentinesConsumableType" )
	}

	OnThreadEnd(
		function() : ( partner, effectHandles, consumableType, healingRequest )
		{
			Assert( IsValid( partner ) )

			if ( !IsValid( partner ) )
				return

			if ( effectHandles.shieldHealHandle != 0 )
			{
				StatusEffect_Stop( partner, effectHandles.shieldHealHandle )
			}
			if ( effectHandles.healthHealHandle != 0 )
			{
				StatusEffect_Stop( partner, effectHandles.healthHealHandle )
			}

			StopSoundOnEntity( partner, GetChargingSFX( consumableType ) )
				StopSoundOnEntity( partner, "DateNight_AOE_Generic_Consumable_Start_3P" )

			Remote_CallFunction_Replay( partner, "ServerToClient_Valentines_Stop1pVFX" )

			Player3pHealFXRemoveRequest( partner, healingRequest )
		}
	)

	thread ValentinesRangeFXStart_Thread( healingEnt, healTime )

	thread ValentinesHandleHealingCanceledSFX_Thread( healingEnt, partner, consumableType, int(shieldHealAmount), int(healthHealAmount) )

	Remote_CallFunction_Replay( partner, "ServerToClient_Valentines_Add1pVFX", healTime, int(min( shieldHealAmount, 125 )), int(min( healthHealAmount, 100 )) )

	bool wasInRange           = false
	bool wasPartnerBenefiting = false
	while ( true )
	{
		bool receivingUlt      = false
		bool gettingHealed     = false
		bool onlyGettingHealth = true
		bool wouldGetHealingIfInRange = false
		bool wouldGetShieldsIfInRange = false

		bool inRange           = ValentinesIsPlayerInRangeForProximityBuff( partner )

		if ( shieldHealAmount > 0 )
		{
			int partnerCurrentShields  = partner.GetShieldHealth()
			int partnerShieldHealthMax = partner.GetShieldHealthMax()
			float partnerTargetShields = 0
			if ( partnerShieldHealthMax > 0 && partnerCurrentShields < partnerShieldHealthMax )
			{
				wouldGetShieldsIfInRange = true
				if ( inRange )
				{
					gettingHealed     = true
					onlyGettingHealth = false
					if ( effectHandles.shieldHealHandle == 0 )
					{
						partnerTargetShields           = shieldHealAmount / float( partnerShieldHealthMax )
						effectHandles.shieldHealHandle = StatusEffect_AddEndless( partner, eStatusEffect.target_shields, partnerTargetShields )
					}
				}
			}
		}

		if ( healthHealAmount > 0 )
		{
			int partnerCurrentHealth  = partner.GetHealth()
			int partnerHealthMax      = partner.GetMaxHealth()
			float partnerTargetHealth = 0
			if ( partnerCurrentHealth < partnerHealthMax )
			{
				wouldGetHealingIfInRange = true
				if ( inRange )
				{
					gettingHealed = true
					if ( effectHandles.healthHealHandle == 0 )
					{
						partnerTargetHealth            = minint( int(healthHealAmount), partnerHealthMax ) / float( partnerHealthMax )
						effectHandles.healthHealHandle = StatusEffect_AddEndless( partner, eStatusEffect.target_health, partnerTargetHealth )
					}
				}
			}
		}

		if ( inRange )
		{
			if ( consumableType == ValentinesConsumableType.Ult )
			{
				if ( WillBenefitFromUltAccel( partner ) )
				{
					receivingUlt = true
				}
			}

			if ( gettingHealed || receivingUlt )
			{
				if ( !wasInRange || !wasPartnerBenefiting )
				{
					EmitSoundOnEntityOnlyToPlayer( partner, partner, GetChargingSFX( consumableType ) )
						EmitSoundOnEntityExceptToPlayer( partner, partner, "DateNight_AOE_Generic_Consumable_Start_3P" )
				}
				wasPartnerBenefiting = true
			}
			else
			{
				wasPartnerBenefiting = false
			}

			wasInRange = true

			//printf("Valentines adding partnerFX amount: " + partnerTargetShields  + " handle: " + useData.partnerShieldStatusHandle + " ent: "+ partner)
		}
		else if ( !inRange && wasInRange )
		{
			wasInRange = false
			if ( effectHandles.shieldHealHandle != 0 )
			{
				StatusEffect_Stop( partner, effectHandles.shieldHealHandle )
				effectHandles.shieldHealHandle = 0
			}
			if ( effectHandles.healthHealHandle != 0 )
			{
				StatusEffect_Stop( partner, effectHandles.healthHealHandle )
				effectHandles.healthHealHandle = 0
			}
			if ( wasPartnerBenefiting )
			{
				StopSoundOnEntity( partner, GetChargingSFX( consumableType ) )
					StopSoundOnEntity( partner, "DateNight_AOE_Generic_Consumable_Start_3P" )
				EmitSoundOnEntityOnlyToPlayer( partner, partner, GetCancelSFX( consumableType ) )
			}
		}

		bool showHealFX = gettingHealed || GetCurrentPlaylistVarBool( VALENTINES_HEALING_FX_ONLY_ON_HEAL_PLAYLIST_VAR, false )

		healingRequest.requestHealthFX = false
		healingRequest.requestShieldFX = false
		if ( inRange && showHealFX )
		{
			if ( onlyGettingHealth )
			{
				healingRequest.requestHealthFX = true
			}
			else
			{
				healingRequest.requestShieldFX = true
			}
		}
		healingRequest.decoyHealthFXIfValidatorPasses = wouldGetHealingIfInRange
		healingRequest.decoyShieldFXIfValidatorPasses = wouldGetShieldsIfInRange

		WaitFrame()
	}
}

void function Valentines_ShowRangeFX( entity healingEnt )
{
	if ( !IsValid( healingEnt ) )
		return

	thread ValentinesRangeFXStart_Thread( healingEnt, 99999 )
}

void function ValentinesRangeFXStart_Thread( entity healingEnt, float healDuration )
{
	EndSignal( healingEnt, VALENTINES_S15_HEAL_SUCCESS_SIGNAL, VALENTINES_S15_HEAL_CANCELED_SIGNAL, "OnDeath", "OnDestroy" )

	int StartFxId = GetParticleSystemIndex( RANGE_RADIUS_REMINDER_FX )
	entity fx     = StartParticleEffectOnEntity_ReturnEntity( healingEnt, StartFxId, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	EffectSetControlPointVector( fx, 1, <10.0, file.togetherDist / TROPHY_AR_EFFECT_SIZE, 0> )
	EffectSetControlPointColorById( fx, 2, COLORID_HUD_LOOT_TIER_SPECIAL )
	fx.SetOwner( healingEnt )
	SetTeam( fx, healingEnt.GetTeam() )
	fx.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_OWNER)

	OnThreadEnd(
		function() : ( fx, healingEnt )
		{
			if ( IsValid( fx ) )
			{
				fx.Destroy()
			}
		}
	)

	wait healDuration
}
#endif


#if SERVER
void function OnLootSpawn( entity ent, LootData data, int count )
{
	if ( data.ref == VALENTINES_BOW_WEAPON_REF )
	{
		thread DelayedSkinChange_Thread( ent )
	}
}

void function DelayedSkinChange_Thread( entity ent )
{
	wait 0.1
	if ( IsValid( ent ) )
	{
		ItemFlavor skin  = GetItemFlavorByAsset( VALENTINES_BOW_SKIN )
		ItemFlavor charm = GetItemFlavorByAsset( VALENTINES_BOW_CHARM )
		WeaponCosmetics_Apply( ent, skin, charm )
	}
}
#endif

#if SERVER
void function OnEntitiesDidLoad()
{
	thread InitTicks_Thread()
}

void function InitTicks_Thread()
{
	switch ( GetMapName() )
	{
		case "mp_rr_desertlands_hu":
		case "mp_rr_desertlands_mu4":

		case "mp_rr_desertlands_mu3":
			SpawnTicks_WorldsEdge()
			break;

		case "mp_rr_olympus_mu2":
			SpawnTicks_Olympus()
			break;

		case "mp_rr_divided_moon":
			SpawnTicks_DividedMoon()
			break;
	}
}

void function SpawnTicks_WorldsEdge()
{
	//NE
	array <vector> clusterA = [
		<33715.2, 9417.22, -3524.94>,
		<9767.41, 5397.32, -3567.97>,
		<12416.6, 20024.3, -3955.5>,
		<17036.9, 30544.4, -3918.33>, //Doubles at climatize
		<22488.9, 25095, -3918.33>,
		<1737.25, 4196.93, -2999.88>,
	]

	//NW
	array <vector> clusterB = [
		<-13149.5, 26409, -2939.17>,
		<79.19, 20489, -2895.97>,
		<-18408.7, 13369.6, -3614.97>,
		<-29847.3, 9167.56, -2960.91>,
		<-12990.4, 4334.12, -2331.24>,
		<-9437.47, 11301.2, -2495.92>,
	]

	//S
	array <vector> clusterC = [
		<6307.99, -20224.6, -3635.97>,
		<29501.1, -8175.45, -3263.34>,
		<-7440.36, -10695.4, -3839.94>,
		<-17142.4, -7562.93, -3080.47>,
		<-28406.8, -27324.7, -4243.94>,
		<-5106.24, -33681.3, -3555.48>,
		<8741.15, -40875.1, -2340.82>,
		<27053.5, -29312.8, -2891.97>,
	]

	SpawnTicksFromClusters( clusterA, clusterB, clusterC )
}

void function SpawnTicks_Olympus()
{
	//SW
	array <vector> clusterA = [
		<-19895, -27528.2, -4415.94>,
		<-30937.5, -16808.9, -3723.94>,
		<-42677.4, -12577.2, -3021.56>,
		<-34815.3, -822.365, -4093.91>,
		<-28116.6, -6083.03, -4129.59>,
		<-22088.9, 2296.63, -5137.59>,
	]

	//SE
	array <vector> clusterB = [
		<30267.6, 6192.28, -3454.68>,
		<24103.1, -5992.61, -4727.97>,
		<18853.3, -20175.5, -4790.16>,
		<9360.59, -29673, -5424.56>,
		<-5512.9, -34676.2, -2338.86>, //Doubles at bonsai plaza
		<-5503.66, -30898.1, -2338.86>,
	]

	//N
	array <vector> clusterC = [
		<-16606.4, 20997.4, -6720.52>,
		<-17095, 38665.8, -6815.73>,
		<-30184.7, 20511.5, -6511.97>,
		<-32774.9, 12771.8, -6743.94>,
		<-4997.52, 28737, -5963.95>,
		<10155, 29249.9, -4641.76>,
	]

	SpawnTicksFromClusters( clusterA, clusterB, clusterC )
}

void function SpawnTicks_DividedMoon()
{
	//SE
	array <vector> clusterA = [
		<29986.8, -10845.8, 4641.47>,
		<33531.3, -1465.56, 3793.7>,
		<15092.7, -11868.4, 6186.73>,
		<1158.57, -24173.2, 5763.69>,
		<12784.9, -34129.8, 6987.33>,
		<-8802.64, -22111.2, 2928.15>,
	]

	//N
	array <vector> clusterB = [
		<22836.2, 7393.57, 1614.68>,
		<9612.44, 8892.96, 1836.4>,
		<892.897, 32374.7, 1156.26>,
		<26878.3, 36814.6, 3655.44>,
		<-21499.9, 23021.4, 2161.52>,
		<-3026.85, 12027.7, 2023.13>,
	]

	//SW
	array <vector> clusterC = [
		<-34922.1, 32730.8, 47.9316>, //Doubles in Breaker Wharf
		<-38196.4, 29458.4, 47.9321>,
		<-25742.6, 9436.57, 1648.65>,
		<-33839.6, -3588.93, 2759.81>,
		<-10829.3, -3210.59, 2035.6>,
		<-27445.8, -26690.2, 2615.99>,
	]

	SpawnTicksFromClusters( clusterA, clusterB, clusterC )
}

vector function GetTickSpawnFromCluster( array<vector> cluster )
{
	return cluster.getrandom()
}

void function SpawnTicks( array<vector> ticks )
{
	foreach ( vector tick in ticks )
	{
		thread SpawnTick_Thread( tick )
	}
}

void function SpawnTicksFromClusters( array<vector> clusterA, array<vector> clusterB, array<vector> clusterC )
{
	if ( DebugAllValentinesTicks() )
	{
		array<vector> allTicks = clusterA
		allTicks.extend( clusterB )
		allTicks.extend( clusterC )
		SpawnTicks( allTicks )
	}
	else
	{
		SpawnTicksFromCluster( clusterA )
		SpawnTicksFromCluster( clusterB )
		SpawnTicksFromCluster( clusterC )
	}
}

void function SpawnTicksFromCluster( array<vector> cluster )
{
	for ( int i = 0; i < file.ticksPerCluster; ++i )
	{
		vector spawn = GetTickSpawnFromCluster( cluster )
		thread SpawnTick_Thread( spawn )
		cluster.fastremovebyvalue( spawn )
	}
}

void function SpawnTick_Thread( vector origin )
{
	printt( "SPAWNING VALENTINES TICK AT: " + origin )
	entity tick = LootTicks_SpawnLootTickAtOrigin( origin, <0, 0, 0>, ["mp_weapon_bow_cupid"], VALENTINES_SPECIAL_EVENT_LOOT_TIER )
	thread CreateLootBeam( tick )
}

void function CreateLootBeam( entity tick )
{
	tick.EndSignal( "OnDeath" )
	tick.EndSignal( "OnDestroy" )

	int beamIndex = GetParticleSystemIndex( FX_AIRDROP_BEAM_CP )
	entity beamFx = StartParticleEffectInWorld_ReturnEntity( beamIndex, tick.GetOrigin(), tick.GetAngles() + <0, 180, 0> )
	EffectSetControlPointColorById( beamFx, 1, COLORID_HUD_LOOT_TIER_SPECIAL )
	OnThreadEnd(
		function() : ( beamFx )
		{
			beamFx.Destroy()
		}
	)

	WaitForever()
}

#if DEVELOPER
const vector CROSSHAIR_OFFSET = <0, 0, -32>
void function DEV_SpawnValentinesTick( entity player )
{
	vector origin = GetPlayerCrosshairOrigin( player )
	origin += CROSSHAIR_OFFSET
	thread SpawnTick_Thread( origin )
	printt( "<" + origin.x + ", " + origin.y + ", " + origin.z + ">" )
}

void function DEV_GetValentinesTickSpawnLocation( entity player )
{
	//EmitSoundOnEntityOnlyToPlayer( player, player, GetChargingSFX( ValentinesConsumableType.Ult ) )

	vector origin = GetPlayerCrosshairOrigin( player )
	origin += CROSSHAIR_OFFSET
	printt( "<" + origin.x + ", " + origin.y + ", " + origin.z + ">" )
}
#endif
#endif

#if CLIENT
string function Valentines_S15_GetString( int infoId )
{
	string retVal = ""
	switch ( infoId )
	{
		case eSurvivalCommentary_SringtoPrint.NEWKILLLEADER_OBIT:
			retVal = "#SURVIVAL_NEWKILLLEADER_OBIT_DATE_NIGHT"
			printt( "Passed Valentines String - NEWKILLLEADER_OBIT - Shicks" )

			break

		case eSurvivalCommentary_SringtoPrint.YOUAREKILLLEADER:
			retVal = "#SURVIVAL_YOUAREKILLLEADER_DATE_NIGHT"
			printt( "Passed Valentines String - YOUAREKILLLEADER - Shicks" )

			break

		case eSurvivalCommentary_SringtoPrint.CHAMPION_OBIT:
			retVal = "#SURVIVAL_CHAMPION_OBIT_DATE_NIGHT"
			printt( "Passed Valentines String - CHAMPION_OBIT - Shicks" )

			break

		case eSurvivalCommentary_SringtoPrint.YOUKILLED_CHAMPION:
			retVal = "#SURVIVAL_YOUKILLED_CHAMPION_DATE_NIGHT"
			printt( "Passed Valentines String - YOUKILLED_CHAMPION - Shicks" )

			break

		case eSurvivalCommentary_SringtoPrint.KILLLEADER_OBIT:
			retVal = "#SURVIVAL_KILLLEADER_OBIT_DATE_NIGHT"
			printt( "Passed Valentines String - KILLLEADER_OBIT - Shicks" )

			break

		case eSurvivalCommentary_SringtoPrint.KILLLEADER_KILLS:
			retVal = "#SURVIVAL_KILLLEADERKILLS_DATE_NIGHT"

			break

		case eSurvivalCommentary_SringtoPrint.YOUKILLED_KILLLEADER:
			retVal = "#SURVIVAL_YOUKILLED_KILLLEADER_DATE_NIGHT"
			printt( "Passed Valentines String -  YOUKILLED_KILLLEADER - Shicks" )

			break

		default:
			SurvivalCommentary_GetCommentaryString( infoId )
			printt( "Passed DEFAULT String" )

			break
	}
	return retVal
}
#endif

                                     