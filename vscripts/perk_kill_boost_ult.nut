global function Perk_KillBoostUlt_Init
#if CLIENT
global function AlertUltGain
#endif

const float ULT_PERCENT_TO_ADD = 0.20
const float BONUS_DEBOUNCE_TIME = 30


struct
{
	#if SERVER || CLIENT
		table<entity, float> lastKnockedBonusTime
		array<entity>		 skirmisherArray
	#endif
} file

void function Perk_KillBoostUlt_Init()
{
	if ( GetCurrentPlaylistVarBool( "disable_perk_kill_boost_ult", true ) )
		return

	PerkInfo killBoostUlt
	killBoostUlt.perkId          = ePerkIndex.KILL_BOOST_ULT
	#if SERVER || CLIENT
		killBoostUlt.activateCallback = OnActivate_KillBoostUlt
		killBoostUlt.deactivateCallback = OnDeactivate_KillBoostUlt

		Remote_RegisterClientFunction( "AlertUltGain", "float", 0.0, 100.0, 16 )
	#endif
	Perks_RegisterClassPerk( killBoostUlt )

	#if SERVER
		Bleedout_AddCallback_OnPlayerStartBleedout( KillBoostUlt_OnPlayerKnocked )
		AddCallback_OnPlayerKilled( KillBoostUlt_OnPlayerKilled )
	#endif
}

#if SERVER || CLIENT
void function OnActivate_KillBoostUlt( entity player, string characterName )
{
	file.skirmisherArray.append( player )
}

void function OnDeactivate_KillBoostUlt( entity player )
{
	file.skirmisherArray.fastremovebyvalue( player )
}
#endif

#if SERVER
void function KillBoostUlt_OnPlayerKnocked( entity victim, entity attacker, var damageInfo )
{
	GiveUltBoostByDamageDealt( victim )
}

void function KillBoostUlt_OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( ShouldDoBleedout( victim ) )	// Already dealt with elsewhere
		return

	GiveUltBoostByDamageDealt( victim )
}

void function GiveUltBoostToTeam( int team, entity victim, float multiplier = 1.0 )
{
	float curTime = Time()
	if ( victim in file.lastKnockedBonusTime && file.lastKnockedBonusTime[ victim ] + BONUS_DEBOUNCE_TIME > curTime )
		return

	file.lastKnockedBonusTime[ victim ] <- curTime

	foreach( squadPlayer in GetPlayerArrayOfTeam( team ) )
	{
		entity ultWeapon = squadPlayer.GetOffhandWeapon( OFFHAND_ULTIMATE )
		if ( IsValid( ultWeapon ) && ultWeapon.GetWeaponPrimaryClipCountMax() > 0 )
		{
			float newFraction = ultWeapon.GetWeaponPrimaryClipCount() + ULT_PERCENT_TO_ADD * multiplier * ultWeapon.GetWeaponPrimaryClipCountMax()
			int newAmount = minint( int( newFraction + 0.5 ), ultWeapon.GetWeaponPrimaryClipCountMax() )
			ultWeapon.SetWeaponPrimaryClipCount( newAmount )

			Remote_CallFunction_NonReplay( squadPlayer, "AlertUltGain", 100.0 * ULT_PERCENT_TO_ADD * multiplier )
		}
	}
}

void function GiveUltBoostByDamageDealt( entity victim )
{
	table< entity, float >	damageDealtByPlayer
	foreach ( history in victim.e.recentDamageHistory )
	{
		if ( (history.damageType & DF_SHIELD_DAMAGE) != 0 || history.wasBleedingOut )
			continue

		entity damager = history.attacker
		if ( !IsValid( damager ) || !damager.IsPlayer() || !Perks_DoesPlayerHavePerk( damager, ePerkIndex.KILL_BOOST_ULT ) )
			continue

		if ( damager in damageDealtByPlayer )
		{
			damageDealtByPlayer[ damager ] = damageDealtByPlayer[ damager ] + history.damage
		}
		else
		{
			damageDealtByPlayer[ damager ] <- history.damage
		}
	}

	table<int, entity> teamMaxDamager
	foreach ( damager, damageDealt in damageDealtByPlayer )
	{
		int team = damager.GetTeam()
		if ( team in teamMaxDamager )
		{
			entity curMaxDamager = teamMaxDamager[ team ]
			if( damageDealt > damageDealtByPlayer[ curMaxDamager ] )
				teamMaxDamager[ team ] = damager
		}
		else
		{
			teamMaxDamager[ team ] <- damager
		}
	}

	int victimMaxHealth = victim.GetMaxHealth()
	foreach( team, maxDamager in teamMaxDamager)
	{
		GiveUltBoostToTeam( team, victim, damageDealtByPlayer[ maxDamager ] / victimMaxHealth )
	}
}
#endif

#if CLIENT
void function AlertUltGain( float amount )
{
	thread AlertUltGain_Thread( amount )
}

void function AlertUltGain_Thread( float amount )
{
	wait 0.3

	AnnouncementMessageRight( GetLocalClientPlayer(), "Gained Ult Charge: " + string( int( amount ) ) + "%", "", <1,1,1>, $"rui/hud/tactical_icons/tactical_mirage_in_world", 2.5, "ctrl_capturebonus_claimed_1p" )
}
#endif