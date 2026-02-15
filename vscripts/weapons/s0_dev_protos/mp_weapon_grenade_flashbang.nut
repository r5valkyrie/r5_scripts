
global function MpWeaponGrenadeFlashbang_Init
global function OnWeaponTossReleaseAnimEvent_weapon_flashbang
global function OnProjectileExplode_weapon_flashbang

#if SERVER
global function FlashBang_Flash
#endif

const float FLASHBANG_BLIND_DURATION = 2.0
const float FLASHBANG_BLIND_FADE_DURATION = 2.0

const float FLASHBANG_BLIND_FADE_DISTANCE_MIN = 1024.0
const float FLASHBANG_BLIND_FADE_DISTANCE_MAX = 1536.0//1280.0

const int FLASH_BANG_DAMAGE = 5

const asset FLASH_BANG_BLIND_TEMP_FX = $"P_emp_body_human"
global bool FLASHBANG_AFFECTS_SPIES = false

void function MpWeaponGrenadeFlashbang_Init()
{
	PrecacheParticleSystem( FLASH_BANG_BLIND_TEMP_FX )
}

var function OnWeaponTossReleaseAnimEvent_weapon_flashbang( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	Grenade_OnWeaponTossReleaseAnimEvent( weapon, attackParams )

	entity weaponOwner = weapon.GetWeaponOwner()
	Assert( weaponOwner.IsPlayer() )

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

void function OnProjectileExplode_weapon_flashbang( entity projectile )
{
	//printt ( "FLASH BANG IS EXPLODING!!!" )
	#if SERVER
	entity owner = projectile.GetOwner()

	if ( !IsValid( owner ) )
		return

	vector flashOrigin = projectile.GetOrigin() + <0,0,32>
	array<entity> livingPlayers = GetPlayerArray_Alive()
	foreach ( entity player in livingPlayers  )
	{
		if( Gamemode() == eGamemodes.fs_spieslegends && !FLASHBANG_AFFECTS_SPIES && player.GetTeam() == gCurrentSpyTeam )
			continue
		
		vector viewOrigin = player.EyePosition()
		float distSqr = DistanceSqr( viewOrigin, flashOrigin )
		if ( distSqr > ( FLASHBANG_BLIND_FADE_DISTANCE_MAX * FLASHBANG_BLIND_FADE_DISTANCE_MAX ) )
			continue

		array<entity> ignoreEnts = [ player, projectile ]
		TraceResults results = TraceLineHighDetail( flashOrigin, viewOrigin, ignoreEnts, TRACE_MASK_BLOCKLOS, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
	//	DebugDrawLine( flashOrigin, results.endPos, 0, 255, 0, true, 30 )
	//	DebugDrawLine( results.endPos, viewOrigin, 255, 0, 0, true, 30 )

	//	PrintTraceResults( results )

		if ( results.fraction == 1.0 )
		{
			//printt( "PLAYER HIT BY FLASH" )
			vector posToVictim = Normalize ( flashOrigin - viewOrigin )
			vector viewDir = player.GetViewForward()

			//DebugDrawLine( player.EyePosition(), player.EyePosition() + ( posToVictim * 64 ), 255, 0, 0, true, 15 )
			//DebugDrawLine( player.EyePosition(), player.EyePosition() + ( viewDir * 64 ), 0, 255, 0, true, 15 )

			float dot = DotProduct( posToVictim, viewDir )
			//printt( "DOT: " + dot )

			float dist = Distance( viewOrigin, flashOrigin )
			
			thread FlashBang_Flash( player, dot, dist )
		}
	}
	#endif //SERVER
}

#if SERVER
void function FlashBang_Flash( entity victim, float dot, float dist )
{
	victim.EndSignal( "OnDeath" )
	victim.EndSignal( "OnDestroy" )

	float flashScalar = GraphCapped( dot, 0.75, 0.5, 1.0, 0.0 ) * GraphCapped( dist, FLASHBANG_BLIND_FADE_DISTANCE_MIN, FLASHBANG_BLIND_FADE_DISTANCE_MAX, 1.0, 0.0 )
	int flashAlpha = int ( 255 * flashScalar )
	ScreenFade( victim, 255, 255, 255, flashAlpha, FLASHBANG_BLIND_FADE_DURATION, FLASHBANG_BLIND_DURATION, FFADE_IN | FFADE_PURGE )

	//printt( "FLASH SCALAR: " + flashScalar )

	if ( flashScalar >= 0.5 )
	{

		//printt( "CREATING BLINDING FX" )

		int attachmentID = victim.LookupAttachment( "CHESTFOCUS" )
		int fxID = GetParticleSystemIndex( FLASH_BANG_BLIND_TEMP_FX )
		entity fx = StartParticleEffectOnEntity_ReturnEntity ( victim, fxID, FX_PATTACH_POINT_FOLLOW, attachmentID )

		OnThreadEnd(
			function() : ( fx )
			{
				if ( IsValid( fx ) )
					EffectStop( fx )
			}
		)
	}

	wait FLASHBANG_BLIND_DURATION

}
#endif