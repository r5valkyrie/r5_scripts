global function Lifesteal_Init

#if CLIENT
global function ServerToClient_ShowLifesteal
#endif

#if SERVER
global function Lifesteal_PlayerDealtDamage
#endif

//Names
const string LIFESTEAL_WEAPON_VAR = "lifesteal_heal_percent"
const int LIFESTEAL_HEAL_PERCENT_WEAPON_VAR = eWeaponVar.custom_float_0

//Variables
const float VALENTINES_HEAL_DEBOUNCE_SEC = 10

//VFX  - valentines
 const VFX_COCKPIT_HEALTH = $"P_heal_loop_screen"
 const VFX_COCKPIT_SHIELDS = $"P_armor_FP_charging_CP"
 const VFX_PLAYER_HEALED_3P = $"P_armor_3P_loop_CP"//$"P_heal_3p_loop"

//VFX
//const VFX_COCKPIT_HEALTH = $"P_bMat_heal_loop_FP" // Health Heal
//const VFX_COCKPIT_SHIELDS = $"P_bmat_armor_charging_FP" //  Armor Heal
//const VFX_PLAYER_HEALED_3P = $"P_bmat_armor_charging_3P"// 3P Healing

//SFX
const SFX_RECEIVING_HEAL_1P = "DateNight_AOE_Bow_Healing_Success_1P"
const SFX_GAVE_HEAL_1P = "DateNight_AOE_Success_Stinger_1P"
const SFX_RECEIVING_HEAL_3P = "DateNight_AOE_Success_Stinger_3P"

struct
{
	#if CLIENT
		bool  isHealing = false
		float healedEndTime
		int healAmountTotal
		var healRui
	#endif
} file

void function Lifesteal_Init()
{
	PrecacheParticleSystem( VFX_COCKPIT_HEALTH )
	PrecacheParticleSystem( VFX_COCKPIT_SHIELDS )
	PrecacheParticleSystem( VFX_PLAYER_HEALED_3P )

	Remote_RegisterClientFunction( "ServerToClient_ShowLifesteal", "bool", "int", INT_MIN, INT_MAX )

	#if CLIENT
	AddCallback_GameStateEnter( eGameState.Postmatch, Lifesteal_OnGameState_Ending )
	#endif
}

#if SERVER
int function TryHealPlayer( entity player, int healAmount )
{
	int healPool      = healAmount
	int healthDiff    = player.GetMaxHealth() - player.GetHealth()
	bool healedHealth = false
	bool healedArmor  = false

	vector healColor = < 0, 128, 128> //teal

	if ( healthDiff > 0 )
	{
		if ( healthDiff >= healPool )
		{
			player.SetHealth( player.GetHealth() + healPool )
			healPool = 0
		}
		else
		{
			player.SetHealth( player.GetMaxHealth() )
			healPool -= healthDiff
		}
		healedHealth = true
	}

	int armorDiff = player.GetShieldHealthMax() - player.GetShieldHealth()

	if ( armorDiff > 0 && healPool > 0 )
	{
		int armorTier = EquipmentSlot_GetEquipmentTier( player, "armor" )
		healColor = GetFXRarityColorForTier( armorTier )
		printt("LIFESTEAL: " + armorTier + " :: " + healColor)
		if ( armorDiff >= healPool )
		{
			player.SetShieldHealth( player.GetShieldHealth() + healPool )
			healPool = 0
		}
		else
		{
			player.SetShieldHealth( player.GetShieldHealthMax() )
			healPool -= armorDiff
		}
		healedArmor = true
	}

	if ( healedHealth || healedArmor )
	{
		thread PlayHealFX3P_Thread( player, healColor )
		Remote_CallFunction_Replay( player, "ServerToClient_ShowLifesteal", !healedHealth && healedArmor, healAmount - healPool )
		EmitSoundOnEntityOnlyToPlayer( player, player, SFX_RECEIVING_HEAL_1P )
	}

	return healPool
}

void function PlayHealFX3P_Thread( entity player, vector color )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	entity BodyFX3p = StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( VFX_PLAYER_HEALED_3P ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "CHESTFOCUS" ) )
	BodyFX3p.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)
	BodyFX3p.SetOwner( player )
	SetTeam( BodyFX3p, player.GetTeam() )
	EffectSetControlPointVector( BodyFX3p, 2, color )

	OnThreadEnd(
		function() : ( BodyFX3p )
		{
			if ( IsValid( BodyFX3p ) )
				EffectStop( BodyFX3p )
		}
	)

	wait 1
}
#endif

#if SERVER
void function Lifesteal_PlayerDealtDamage( entity attacker, entity victim, entity weapon, int healthDamage, int shieldDamage, int absorbedDamage, int damageType = -1 )
{
	//Don't think this would ever be the case... but why leave it to chance
	if ( damageType == DMG_MELEE_EXECUTION )
		return

	if ( !IsValid( weapon ) )
		return

	//Only weapons with the field defined can lifesteal
	//if ( !IsWeaponKeyFieldDefined( weapon.GetWeaponClassName(), LIFESTEAL_WEAPON_VAR ) )
	//	return

	float healSteal = weapon.GetWeaponSettingFloat( LIFESTEAL_HEAL_PERCENT_WEAPON_VAR )
	if ( healSteal <= 0.0 )
		return

	//Only lifesteal valid players
	if ( !IsValid( victim ) )
		return

	if ( !IsValid( attacker ) )
		return

	if ( attacker == victim ) //Hmmmmm
		return

	//Non-combat npc's should be ignored for life steal
	if ( victim.IsNPC() && victim.IsNonCombatAI() )
		return

	if ( IsFriendlyTeam( attacker.GetTeam(), victim.GetTeam() ) )
		return

	//Make sure no one is bleeding out
	if ( Bleedout_IsBleedingOut( victim ) || Bleedout_IsBleedingOut( attacker ) )
		return

	int damage     = healthDamage + shieldDamage + absorbedDamage
	int healAmount = int(healSteal * damage)

	if ( healAmount <= 0 )
		return

	int selfHealRemaining    = TryHealPlayer ( attacker, healAmount )

	//If we've triggered a heal, play the heal stinger
	if ( selfHealRemaining != healAmount ) //Did we heal at all?
	{
		EmitSoundOnEntityToEnemies( attacker, SFX_RECEIVING_HEAL_3P, attacker.GetTeam() )
	}

	                               
	if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_VALENTINES_S15 ) )
	{
		//TODO - we may want to rip this out at some point too, or turn healing teammates into a lifesteal var - pmcd
		entity partner = ValentinesGetPartner( attacker )

		if ( !IsValid( partner ) )
			return

		int partnerHealRemaining = 0

		if ( ValentinesIsPlayerInRangeForProximityBuff( partner ) )
		{
			partnerHealRemaining = TryHealPlayer( partner, healAmount )
		}

		if ( partnerHealRemaining != healAmount )
		{
			EmitSoundOnEntityToEnemies( partner, SFX_RECEIVING_HEAL_3P, attacker.GetTeam() )
			EmitSoundOnEntityOnlyToPlayer( attacker, attacker, SFX_GAVE_HEAL_1P )
		}
	}
       
}
#endif


#if CLIENT
const float HEAL_VFX_DURATION = 1
const float HEAL_HUD_LINGER = 1.5
void function ServerToClient_ShowLifesteal( bool onlyShields, int amount )
{
	if ( Time() > file.healedEndTime )
		file.healAmountTotal = amount
	else
		file.healAmountTotal += amount

	file.healedEndTime = (Time() + HEAL_VFX_DURATION )
	entity player = GetLocalViewPlayer()
	int armorTier = EquipmentSlot_GetEquipmentTier( player, "armor" )
	armorTier = armorTier <= 0 ? 1 : armorTier

	if ( !file.isHealing )
		thread HealVFX_Thread( onlyShields, armorTier )

	ShowHealHUD( file.healedEndTime + HEAL_HUD_LINGER, onlyShields, file.healAmountTotal, armorTier )
}

void function ShowHealHUD( float endTime, bool onlyShields, int amount, int armorTier )
{
	if ( file.healRui == null )
		file.healRui = CreateCockpitPostFXRui( $"ui/lifesteal_hud.rpak" , MINIMAP_Z_BASE )

	RuiSetGameTime( file.healRui, "endTime", endTime )
	RuiSetBool( file.healRui, "onlyShields", onlyShields )
	RuiSetInt( file.healRui, "healAmount", amount )
	RuiSetInt( file.healRui, "shieldTier", armorTier )
}

void function HealVFX_Thread( bool onlyShields, int armorTier )
{
	entity player = GetLocalViewPlayer()

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )

	file.isHealing = true

	int fxID = onlyShields ? GetParticleSystemIndex( VFX_COCKPIT_SHIELDS ) : GetParticleSystemIndex( VFX_COCKPIT_HEALTH )

	int fxHandle = StartParticleEffectOnEntity( player, fxID, FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	EffectSetIsWithCockpit( fxHandle, true )
	if ( onlyShields )
	{
		vector shieldColor = GetFXRarityColorForTier( armorTier )
		EffectSetControlPointVector( fxHandle, 1, shieldColor )
	}
	OnThreadEnd(
		function() : (fxHandle)
		{
			file.isHealing = false
			if ( EffectDoesExist( fxHandle ) )
				EffectStop( fxHandle, false, true )
		}
	)

	while( (file.healedEndTime > Time()) )
		WaitFrame()
}

void function Lifesteal_OnGameState_Ending()
{
	if ( file.healRui == null )
		return

	RuiDestroyIfAlive( file.healRui )
	file.healRui = null
}
#endif
