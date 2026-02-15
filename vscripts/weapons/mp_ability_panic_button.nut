global function OnWeaponAttemptOffhandSwitch_ability_panic_button
global function OnWeaponPrimaryAttack_ability_panic_button

global function PanicButton_Init

#if CLIENT
global function SCB_BroadcastPanicButtonCast
global function SCB_DoPanicHealFeedback
global function SCB_DoPanicSkydiveFeedback
#endif // CLIENT

enum ePanicButton
{
	NOTHING,

	HEALING,
	SKYDIVE,
	LOOTFOUNTAIN,
	DANCEPARTY,

	_count
}

const asset FX_HEAL_HEALED3P = $"P_heal_3p"
const asset FX_HEAL_RADIUS = $"P_ar_heal_radius_CP"

const string FUNCNAME_BroadcastPanicButtonCast = "SCB_BroadcastPanicButtonCast"
const string FUNCNAME_DoPanicHealFeedback = "SCB_DoPanicHealFeedback"
const string FUNCNAME_DoPanicSkydiveFeedback = "SCB_DoPanicSkydiveFeedback"
void function PanicButton_Init()
{
	ScriptRemote_RegisterClientFunction( FUNCNAME_BroadcastPanicButtonCast, "entity", "int", 0, ePanicButton._count, "int", 0, 128 )
	ScriptRemote_RegisterClientFunction( FUNCNAME_DoPanicHealFeedback )
	ScriptRemote_RegisterClientFunction( FUNCNAME_DoPanicSkydiveFeedback )

	PrecacheParticleSystem( FX_HEAL_HEALED3P )
	PrecacheParticleSystem( FX_HEAL_RADIUS )
}

bool function OnWeaponAttemptOffhandSwitch_ability_panic_button( entity weapon )
{
	return true
}

//

#if SERVER

array<int> s_randomPanics
void function SetUpPanicRandoms()
{
	if ( s_randomPanics.len() > 0 )
		return

	if ( GetCurrentPlaylistVarBool( "dummie_ult_healing_enable", true ) )
		s_randomPanics.append( ePanicButton.HEALING )
	if ( GetCurrentPlaylistVarBool( "dummie_ult_skydive_enable", false ) )
		s_randomPanics.append( ePanicButton.SKYDIVE )
	if ( GetCurrentPlaylistVarBool( "dummie_ult_lootfountain_enable", true ) )
		s_randomPanics.append( ePanicButton.LOOTFOUNTAIN )
	if ( GetCurrentPlaylistVarBool( "dummie_ult_danceparty_enable", true ) )
		s_randomPanics.append( ePanicButton.DANCEPARTY )
}

int function RollForPanicType()
{
	#if DEV
	{
		int reproNum = GetBugReproNum()
		switch( reproNum )
		{
			case -1:	return ePanicButton.HEALING
			case -2:	return ePanicButton.SKYDIVE
			case -3:	return ePanicButton.LOOTFOUNTAIN
			case -4:	return ePanicButton.DANCEPARTY
		}
	}
	#endif // DEV

	SetUpPanicRandoms()
	if ( s_randomPanics.len() == 0 )
		return ePanicButton.NOTHING

	return s_randomPanics.getrandom()
}
#endif // SERVER

#if SERVER

void function BroadcastPanicNotifyToTarget( entity target, entity castingPlayer, int panicType, int targetCount )
{
	Remote_CallFunction_Replay( target, FUNCNAME_BroadcastPanicButtonCast, castingPlayer, panicType, targetCount )
}

float function GetPanicRange()
{
	return GetCurrentPlaylistVarFloat( "dummie_ult_range", 1500.0 )
}

array<entity> function GetArrayOfTargetsInRangeOfPanicAbility( entity castingPlayer )
{
	array<entity> results = GetPlayerArrayEx( "any", TEAM_ANY, TEAM_ANY, castingPlayer.GetOrigin(), GetPanicRange() )

	// Filter:
	{
		array<int> badList
		foreach( int index, entity ent in results )
		{
			if ( !ent.DoesShareRealms( castingPlayer ) )
				badList.append( index )
		}

		int badListLen = badList.len()
		for( int idx = 0; idx < badListLen; ++idx )
		{
			int badIndex = badList[badListLen - 1 - idx]
			results.remove( badIndex )
		}
	}

	return results
}

void function DoPanicButtonHealing( entity player )
{
	EmitSoundOnEntityOnlyToPlayer( player, player, "Dummie_Ultimate_Heal_Trigger_1P" )
	EmitSoundOnEntityExceptToPlayer( player, player, "Dummie_Ultimate_Heal_Trigger_3P" )

	// World effect:
	{
		// AOE Heal Ring FX- Needs CP1 for radius. Model is 512 units, 256 radius, so using 5.86 for scale is about 1500, Can adjust as needed. CP1: 5.86 1 1
		// (Radius is actually 256.)
		entity newFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( FX_HEAL_RADIUS ), player.GetOrigin(), <0,0,0> )
		const float MODEL_BASE_RADIUS = 256.0
		float modelRadius = GetPanicRange()
		float modelScale = (modelRadius / MODEL_BASE_RADIUS)
		EffectSetControlPointVector( newFx, 1, <modelScale, 1.0, 1.0> )
	}


	array<entity> targets
	array<entity> rawTargets = GetArrayOfTargetsInRangeOfPanicAbility( player )
	foreach( target in rawTargets )
	{
		if ( !IsAlive( target ) )
			continue
		if ( Bleedout_IsBleedingOut( target ) )
			continue
		if ( target.IsPhaseShifted() )
			continue

		targets.append( target )
	}

	int healCount = 0
	foreach( target in targets )
	{
		int gave = GiveHealthAndShieldToPlayer( target, 200 )
		
		#if DEVELOPER
			printf( "  Gave %d health & shield to: %s", gave, string( target ) )
		#endif

		++healCount
		EmitSoundOnEntityOnlyToPlayer( target, target, "Dummie_Ultimate_Heal_GotHealed_1P" )
		EmitSoundOnEntityExceptToPlayer( target, target, "Dummie_Ultimate_Heal_GotHealed_3P" )
		Remote_CallFunction_Replay( target, FUNCNAME_DoPanicHealFeedback )

		// 3p Effect:
		{
			entity newFx = StartParticleEffectOnEntity_ReturnEntity( target, GetParticleSystemIndex( FX_HEAL_HEALED3P ), FX_PATTACH_POINT_FOLLOW, target.LookupAttachment( "ref" ) )
			newFx.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_EVERYONE | ENTITY_VISIBLE_EXCLUDE_PARENT_PLAYER)
		}
	}

	foreach( target in targets )
		BroadcastPanicNotifyToTarget( target, player, ePanicButton.HEALING, healCount )
}

void function DoPanicButtonSkydive( entity player )
{
	array<entity> targets
	array<entity> rawTargets = GetArrayOfTargetsInRangeOfPanicAbility( player )
	foreach( target in rawTargets )
	{
		if ( !IsAlive( target ) )
			continue
		if ( Bleedout_IsBleedingOut( target ) )
			continue
		if ( target.IsPhaseShifted() )
			continue
		if ( target.ContextAction_IsActive() )
			continue
		if ( Bleedout_IsBleedingOut( target ) )
			continue
		if ( IsValid( target.GetParent() ) )
			continue

		targets.append( target )
	}

	int skydiveCount = 0
	float planeHeight = SURVIVAL_GetPlaneHeight()
	foreach( target in targets )
	{
		vector oldPos = target.GetOrigin()
		vector newPos = <oldPos.x, oldPos.y, planeHeight>
		target.SetOrigin( newPos )
		                        
			Control_PrintSkydiveDebug(player, " DoPanicButtonSkydive going to trigger PlayerSkydiveFromCurrentPosition" )
                                
		thread PlayerSkydiveFromCurrentPosition( target )

		#if DEVELOPER
			printf( "  Teleported player into skydive: %s", string( target ) )
		#endif 
		
		Remote_CallFunction_Replay( target, FUNCNAME_DoPanicSkydiveFeedback )
		++skydiveCount
	}

	foreach( target in targets )
		BroadcastPanicNotifyToTarget( target, player, ePanicButton.SKYDIVE, skydiveCount )
}

void function Control_PrintSkydiveDebug( entity player, string message )
{
	if ( IsValid( player ) )
		printt( "R5DEV-429111: ", player, message )
	else
		printt( "R5DEV-429111: PlayerInvalid", message )
}

void function DoPanicButtonLootFountain( entity player )
{
	for( int idx = 0; idx < 20; ++idx )
	{
		string ref = SURVIVAL_GetWeightedItemFromGroup( "Zone_High" )
		if ( ref == "blank" )
			continue

		int countPerDrop = SURVIVAL_Loot_GetLootDataByRef( ref ).countPerDrop

		vector attackOrigin = player.GetCenter() - <0,0,16>
		vector attackVec = (player.GetForwardVector() * 2.0) + RandomVec( 0.75 ) + <0.0, 0.0, 2.0>
		entity lootEnt = SURVIVAL_ThrowLootFromPoint( attackOrigin, attackVec, ref, countPerDrop, null, null )
	}

	EmitSoundOnEntityOnlyToPlayer( player, player, "Dummie_Ultimate_Loot_Trigger_1P" )
	EmitSoundOnEntityExceptToPlayer( player, player, "Dummie_Ultimate_Loot_Trigger_3P" )

	array<entity> targets = GetArrayOfTargetsInRangeOfPanicAbility( player )
	foreach ( target in targets )
		BroadcastPanicNotifyToTarget( target, player, ePanicButton.LOOTFOUNTAIN, 0 )
}

void function DoKaleidoscopeUltimate( entity weapon )
{
	entity owner = weapon.GetWeaponOwner()

	int numDecoys      = GetCurrentPlaylistVarInt( "dummie_kaleidoscope_ulti_decoy_count", 5 )
	float baseDuration = GetCurrentPlaylistVarFloat( "dummie_kaleidoscope_ulti_decoy_duration", 15.0 )
	for ( int decoyIdx = 0; decoyIdx < numDecoys; decoyIdx++ )
	{
		// The decoys + the player will form a regular polygon. Good luck guessing which one's the player!
		float yawOffset = 360.0 / (numDecoys + 1) * (decoyIdx + 1)
		// Don't all dissolve all at once. Decoys on the opposite side will dissolve a bit sooner than decoys close to the player.
		float duration  = baseDuration + 1.8 * fabs( float(numDecoys - 1) / 2.0 - float(decoyIdx) ) / (float(numDecoys - 1) / 2.0)

		entity decoy = owner.CreateMimicPlayerDecoy( yawOffset )
		decoy.SetMaxHealth( 50 )
		decoy.SetHealth( 50 )
		decoy.EnableAttackableByAI( GetThreatPriorityForHolopilot( weapon.GetWeaponOwner() ), 0, AI_AP_FLAG_NONE )
		decoy.SetCanBeMeleed( true )
		decoy.SetTimeout( duration )
		decoy.SetPlayerOneHits( true )
		SetupDecoy_Common( owner, decoy, true )
		StatsHook_HoloPiliot_OnDecoyCreated( owner )
		AddEntityCallback_OnPostDamaged( decoy, void function( entity decoy, var damageInfo ) : ( owner ) {
			if ( IsValid( owner ) )
				HoloPilot_OnDecoyDamaged( decoy, owner, damageInfo )
		} )
	}
}

void function DoPanicButtonDanceparty( entity player, entity weapon )
{
	DoKaleidoscopeUltimate( weapon )

	EmitSoundOnEntityOnlyToPlayer( player, player, "Dummie_Ultimate_Clone_Trigger_1P" )
	EmitSoundOnEntityExceptToPlayer( player, player, "Dummie_Ultimate_Clone_Trigger_3P" )

	array<entity> targets = GetArrayOfTargetsInRangeOfPanicAbility( player )
	foreach ( target in targets )
		BroadcastPanicNotifyToTarget( target, player, ePanicButton.DANCEPARTY, 0 )
}
#endif // SERVER

var function OnWeaponPrimaryAttack_ability_panic_button( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( !IsValid( weaponOwner ) || !weaponOwner.IsPlayer() )
		return

	#if SERVER
		//
		int panicType = RollForPanicType()
		switch( panicType )
		{
			case ePanicButton.HEALING:
				DoPanicButtonHealing( weaponOwner )
				break
			case ePanicButton.SKYDIVE:
				DoPanicButtonSkydive( weaponOwner )
				break
			case ePanicButton.LOOTFOUNTAIN:
				DoPanicButtonLootFountain( weaponOwner )
				break
			case ePanicButton.DANCEPARTY:
				DoPanicButtonDanceparty( weaponOwner, weapon )
				break
		}

	#endif // SERVER

	#if CLIENT
		ScreenFlash( 3.0, 3.0, 5.0, 0.2, 0.4 )
	#endif // CLIENT

	PlayerUsedOffhand( weaponOwner, weapon )
	int ammoReq = weapon.GetAmmoPerShot()
	return ammoReq
}


#if CLIENT
string function GetAnnounceTextForPanicType( int panicType )
{
	switch ( panicType )
	{
		case ePanicButton.HEALING:
			return "EMERGENCY  AREA  HEAL"
		case ePanicButton.SKYDIVE:
			return "EMERGENCY  MASS  TELEPORT"
		case ePanicButton.LOOTFOUNTAIN:
			return "EMERGENCY  LOOT  Piñata"
		case ePanicButton.DANCEPARTY:
			return "EMERGENCY  DANCE  PARTY"
	}

	return format( "ERR - %s( %d )", FUNC_NAME(), panicType )
}

string function GetAnnounceSubTextForPanicType( entity player, int panicType, int targetCount, entity localPlayer )
{
	if ( !IsValid( player ) )
		return ""

	if ( player == localPlayer )
	{
		switch ( panicType )
		{
			case ePanicButton.HEALING:
				return format( "Targets Healed: %d", targetCount )
			case ePanicButton.SKYDIVE:
				return format( "Targets Teleported: %d", targetCount )
			case ePanicButton.LOOTFOUNTAIN:
				return ""
			case ePanicButton.DANCEPARTY:
				return ""
		}

		return ""
	}

	string playerName = GetDisplayablePlayerNameFromEHI( ToEHI( player ) )
	return format( "%s hit their Panic Button.", playerName )
}

void function SCB_BroadcastPanicButtonCast( entity player, int panicType, int targetCount )
{
	entity localPlayer = GetLocalClientPlayer()
	string mainText = GetAnnounceTextForPanicType( panicType )
	string subText = GetAnnounceSubTextForPanicType( player, panicType, targetCount, localPlayer )
	vector titleColor = <1.8, 0.4, 0.2>
	float duration = 3.0
	AnnouncementMessageSweep( localPlayer, mainText, subText, titleColor, $"", SFX_HUD_ANNOUNCE_QUICK, duration )
}

void function SCB_DoPanicHealFeedback()
{
	entity localPlayer = GetLocalClientPlayer()
	if ( !IsAlive( localPlayer ) )
		return

	ScreenFlash( 3.0, 16.0, 5.0, 0.2, 0.5 )
	Consumable_DoHealScreenFx( localPlayer )
}

void function SCB_DoPanicSkydiveFeedback()
{
	entity localPlayer = GetLocalClientPlayer()
	if ( !IsAlive( localPlayer ) )
		return

	ScreenFlash( 0.0, 0.0, 0.0, 0.2, 1.0 )
	EmitSoundOnEntity( GetLocalViewPlayer(), "dropship_mp_epilogue_warpout" )
}
#endif // CLIENT
 