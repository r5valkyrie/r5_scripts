                          
global function MpWeaponTitanSword_Block_Init
global function TitanSword_Block_OnWeaponActivate
global function TitanSword_Block_ClearMods

global function TitanSword_Block_PlayerIsBlocking
global function TitanSword_Block_IsBlocking

//Names
const string TITAN_SWORD_BLOCK_MOD = "blocking"

//Signals
const string SIG_TITAN_SWORD_BLOCK_DEACTIVATE = "TitanSword_DeactivateBlock"

//VFX
const asset VFX_TITAN_SWORD_BLOCK_HIT_1P = $"P_xo_sword_block_hit"
const asset VFX_TITAN_SWORD_BLOCK_HIT_3P = $"P_xo_sword_block_hit_3P"
const asset VFX_TITAN_SWORD_BLOCK_BULLET_HIT = $"P_pilot_sword_block_bullet"
const asset VFX_TITAN_SWORD_BLOCK_SWORD_HIT = $"P_pilot_sword_block_sword"

//SFX
const string SFX_TITAN_SWORD_BLOCK_DAMAGE = "titansword_block_bullet_impacts_1p"

struct
{
}file

void function MpWeaponTitanSword_Block_Init()
{
	PrecacheParticleSystem( VFX_TITAN_SWORD_BLOCK_HIT_1P )
	PrecacheParticleSystem( VFX_TITAN_SWORD_BLOCK_HIT_3P )
	PrecacheParticleSystem( VFX_TITAN_SWORD_BLOCK_BULLET_HIT )
	PrecacheParticleSystem( VFX_TITAN_SWORD_BLOCK_SWORD_HIT )

	#if SERVER
		RegisterSignal( SIG_TITAN_SWORD_BLOCK_DEACTIVATE )

		AddDamageCallback( "player", TitanSword_OnDamaged )
	#endif
}


void function TitanSword_Block_OnWeaponActivate( entity player, entity weapon )
{
	#if SERVER
		TitanSword_RemoveModOnDrop( weapon, TITAN_SWORD_BLOCK_MOD )

		thread TitanSword_BlockADS_Thread( player, weapon )
	#endif
}

void function TitanSword_Block_ClearMods( entity weapon )
{
	weapon.RemoveMod( TITAN_SWORD_BLOCK_MOD )
}

bool function TitanSword_Block_PlayerIsBlocking( entity player )
{
	if ( !player.IsPlayer() )
		return false

	entity weapon = TitanSword_GetMainWeapon( player )
	if ( IsValid( weapon ) )
		return TitanSword_Block_IsBlocking( weapon )

	return false
}

bool function TitanSword_Block_IsBlocking( entity weapon )
{
	return weapon.IsWeaponInAds()
}

//BLOCK

/* BLOCK NOTES

- Would like the sword to "jiggle" when it's getting hammered with bullets

*/
#if SERVER
void function TitanSword_BlockADS_Thread( entity player, entity weapon )
{
	AssertIsNewThread()

	if ( !IsValid( weapon ) )
		return

	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	weapon.EndSignal( "OnDestroy" )
	weapon.EndSignal( SIG_TITAN_SWORD_DEACTIVATE )

	bool gestureOn = false
	OnThreadEnd(
		function() : ( player, weapon )
		{
			if ( IsValid( weapon ) )
			{
				weapon.RemoveMod( TITAN_SWORD_BLOCK_MOD )
				weapon.Signal( SIG_TITAN_SWORD_BLOCK_DEACTIVATE )
				player.Anim_StopGesture( 0.0 )
			}
		}
	)

	while ( IsValid( weapon ) && IsValid( player ) )
	{
		if ( weapon.IsWeaponInAds() )
		{
			if ( !weapon.HasMod( TITAN_SWORD_BLOCK_MOD ) )
			{
				weapon.AddMod( TITAN_SWORD_BLOCK_MOD )
				//We'd want to display some instructions here...
				//TitanSword_DisplayHint(player, "#WPN_TITAN_SWORD_DASH_HINT", 4.0, TITAN_SWORD_INSTRUCTIONS_DEBOUNCE_TIME)
			}

			if ( player.IsZiplining() ) //Don't play the gesture if we're ziplining
			{
				player.Anim_StopGesture( 0.0 )
				gestureOn = false
			}
			else if ( !gestureOn )
			{
				player.Anim_PlayGesture( "ACT_GESTURE_BLOCK", 0.0, 0.0, 0.0 )
				gestureOn = true
			}
		}
		else
		{
			if ( weapon.HasMod( TITAN_SWORD_BLOCK_MOD ) )
			{
				weapon.RemoveMod( TITAN_SWORD_BLOCK_MOD )
				weapon.Signal( SIG_TITAN_SWORD_BLOCK_DEACTIVATE )
				player.Anim_StopGesture( 0.2 )
				gestureOn = false
				//Hack to get the activity to reset out of ads block dash
				//weapon.StartCustomActivity( "ACT_VM_SPRINT", WCAF_DISABLEWEAPON )
				//if ( weapon.IsInCustomActivity() && weapon.GetCurrentCustomActivity() == ACT_VM_SPRINT )
				//	weapon.StopCustomActivity()
			}
		}

		WaitFrame()
	}
}

bool function CanBeBlocked( var damageInfo )
{
	vector dir = DamageInfo_GetDamageForceDirection( damageInfo )

	//entity attacker    = DamageInfo_GetAttacker( damageInfo )
	int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	int flags          = DamageInfo_GetCustomDamageType( damageInfo )

	//printt( "BLOCKING BIT FLAG: " + !IsBitFlagSet( flags, DF_BULLET | DF_SNIPER | DF_SHOTGUN | DF_EXPLOSION | DF_MELEE ) )
	//We only want to block bullets and explosions
	// && !IsBitFlagSet( flags, DF_SHOTGUN ) && !IsBitFlagSet( flags, DF_EXPLOSION ) && !IsBitFlagSet( flags, DF_MELEE )

	//if ( !IsBitFlagSet( flags, DF_BULLET | DF_SNIPER | DF_SHOTGUN | DF_EXPLOSION | DF_MELEE ) )
	//	return false

	//printt( "BLOCKING DIR: " + dir )
	//Can't block something that doesn't have a direction
	if ( dir == <0, 0, 0> )
		return false

	switch( damageSourceId )
	{
		//Specific abilities
		case eDamageSourceId.mp_ability_crypto_drone_emp:
		case eDamageSourceId.damagedef_grenade_gas:
		case eDamageSourceId.damagedef_gas_exposure:
		case eDamageSourceId.mp_weapon_thermite_grenade:
		case eDamageSourceId.mp_ability_spike_strip:
		case eDamageSourceId.mp_ability_conduit_shield_mines:
		case eDamageSourceId.mp_ability_sonic_blast:
		case eDamageSourceId.mp_weapon_mortar_ring:
		case eDamageSourceId.mp_weapon_tesla_trap:
		case eDamageSourceId.mp_weapon_arc_bolt:

		case eDamageSourceId.burn:
		case eDamageSourceId.crushed:
		case eDamageSourceId.fall:
		case eDamageSourceId.outOfBounds:
		case eDamageSourceId.splat:
		case eDamageSourceId.submerged:
		case eDamageSourceId.turbine:
		case eDamageSourceId.floor_is_lava:
		case eDamageSourceId.deadly_fog:
		case eDamageSourceId.human_execution:
		case eDamageSourceId.titan_execution:
		case eDamageSourceId.lasergrid:
		case eDamageSourceId.indoor_inferno:
		case eDamageSourceId.damagedef_suicide:
			return false
	}

	return true
}

void function TitanSword_OnDamaged( entity player, var damageInfo )
{
	if ( !player.IsPlayer() )
		return

	if ( !TitanSword_ActiveWeaponIsTitanSword( player ) )
		return

	entity weapon = TitanSword_GetMainWeapon( player )

	float damage = DamageInfo_GetDamage( damageInfo )

	vector dir = DamageInfo_GetDamageForceDirection( damageInfo )
	float dot  = player.GetViewForward().Dot( dir )

	bool damageBlocked = IsValid( weapon ) &&
	weapon.HasMod( TITAN_SWORD_BLOCK_MOD ) &&
	CanBeBlocked( damageInfo ) &&
	dot <= weapon.GetWeaponSettingFloat( eWeaponVar.deflect_missile_impacts_dot )

	int damageSourceId      = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	bool isTitanSwordAttack = TitanSword_DamageSourceIsTitanSword( damageSourceId )

	if ( damageBlocked )
	{
		//printt( "BLOCKING DAMAGE: " + GetObitFromDamageSourceID( damageSourceId ) + " :: " + attacker + " :: " + dir )
		EmitSoundOnEntity( player, SFX_TITAN_SWORD_BLOCK_DAMAGE )

		vector damageOrigin = DamageInfo_GetDamagePosition( damageInfo )
		vector damageAngles = VectorToAngles( dir )
		entity damageSparks = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( VFX_TITAN_SWORD_BLOCK_BULLET_HIT ), damageOrigin, damageAngles )
		damageSparks.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
		damageSparks.SetOwner( player )
		CopyRealmsFromTo( player, damageSparks )

		//if ( GetCurrentPlaylistVarBool( "titansword_block_use_additive_anims", true ) )
		//	player.DoAnimationEvent( PLAYERANIMEVENT_WEAPON_DEFLECT, 0 )
		//else
			weapon.StartCustomActivity( "ACT_VM_SECONDARYATTACK", WCAF_NONE )

		//TODO (pmcd) - effects aren't playing, need to make this directional (get damage vector and use dot)
		//Pretty good start - the 1P and 3P blocking needs to be visualized
		//Sword should shoot some stuff
		//Needs super break
		//Sword should drop on death
		//DamageInfo_GetDamageForceDirection ???

		string blockVar  = TitanSword_Super_IsActive( player ) ? "melee_block_scale_super" : "melee_block_scale"
		float blockScale = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, blockVar )
		int blockMin     = GetWeaponInfoFileKeyField_GlobalInt( TITAN_SWORD_WEAPON_REF, "melee_block_min_damage" )
		int blockMax     = GetWeaponInfoFileKeyField_GlobalInt( TITAN_SWORD_WEAPON_REF, "melee_block_max_damage" )

		float scaledDamage = floor( damage * blockScale )
		scaledDamage = clamp( scaledDamage, blockMin, blockMax )
		DamageInfo_AddCustomDamageType( damageInfo, DF_SOUR )
		//DamageInfo_RemoveCustomDamageType( damageInfo, DF_HEADSHOT )

		DamageInfo_SetDamage( damageInfo, scaledDamage )

		int damageDiff = int(ceil( damage - scaledDamage ))

		if ( isTitanSwordAttack )
		{
			//DamageInfo_SetDamage( damageInfo, 0.0 ) //Take no damage from another sword
			entity attacker = DamageInfo_GetAttacker( damageInfo )

			if ( IsValid( attacker ) )
			{
				//Slam should be immune
				float enemySwordKnockback = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "melee_block_sword_knockback" )
				KnockbackPlayer( attacker, attacker.GetViewForward(), enemySwordKnockback )
			}
		}
		else
		{
			//May want to extend this to all melee attacks since a punch probably shouldn't slow you down when melee'd, only bullets and bombs and stuff
			//We'll want to track and clear this I think
			float swordSlow = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "melee_block_sword_slow" )
			StatusEffect_AddTimed( player, eStatusEffect.move_slow, swordSlow, 1, 0.5 )

			bool kraberKnockbackEnabled = GetCurrentPlaylistVarBool( "titan_sword_kraber_knockback_enabled", true )
			if ( kraberKnockbackEnabled && damageSourceId == eDamageSourceId.mp_weapon_sniper )
			{
				float kraberKnockback = GetCurrentPlaylistVarFloat( "titan_sword_kraber_knockback", 1150.0 )
				KnockbackPlayer( player, player.GetViewForward(), kraberKnockback )
			}
		}
	}
	else
	{
		float damageScale          = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "owner_damage_scale" )
		float damageScaleSuper     = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "owner_damage_scale_super" )
		float damageScaleFort      = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "owner_damage_scale_fort" )
		float damageScaleSuperFort = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "owner_damage_scale_super_fort" )

		float finalScale = TitanSword_Super_IsActive( player ) ? damageScaleSuper : damageScale

		ItemFlavor victimCharacter = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_Character() )
		float characterScale       = CharacterClass_GetDamageScale( victimCharacter )

		//character is fortified
		if ( characterScale < 1.0 )
		{
			finalScale = TitanSword_Super_IsActive( player ) ? damageScaleSuperFort : damageScaleFort
		}

		//Wait this won't work bakaaaa
		//float characterDamageScale = CharacterClass_GetDamageScale( player )


		//if ( characterDamageScale < finalScale )
		DamageInfo_ScaleDamage( damageInfo, finalScale )
	}

	if ( !TitanSword_Super_IsActive( player ) )
	{
		entity attacker = DamageInfo_GetAttacker( damageInfo )
		if ( IsValid( attacker ) && attacker != player && !IsFriendlyTeam( attacker.GetTeam(), player.GetTeam() ) )
		{
			float blockingChargeScale = GetWeaponInfoFileKeyField_GlobalFloat( TITAN_SWORD_WEAPON_REF, "melee_block_charge_scale" )
			TitanSword_Super_AddCharge( player, int(ceil( damage * blockingChargeScale )) )
		}
	}
}

void function KnockbackPlayer( entity victim, vector dir, float mag )
{
	if ( IsValid( victim ) )
	{
		vector knockback = -mag * dir
		knockback.z = 0.0
		knockback *= 0.5
		float currentVelDotInKnockbackDir = -1.0
		if ( LengthSqr( knockback ) > 0.0 )
		{
			vector currentVel = victim.GetVelocity()
			currentVelDotInKnockbackDir = DotProduct( Normalize( knockback ), Normalize( currentVel ) )
			if ( currentVelDotInKnockbackDir <= 0.0 ) //melee knockback shouldnt speed us up.
			{
				victim.KnockBack( knockback, 0.25 )
			}
		}
	}
}
#endif
                               