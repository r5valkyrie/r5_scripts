global function OnWeaponPrimaryAttack_cloak

const float CLOAK_DURATION = 7.0

var function OnWeaponPrimaryAttack_cloak( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetWeaponOwner()

	Assert( IsValid( ownerPlayer ) && ownerPlayer.IsPlayer() )
	
	PlayerUsedOffhand( ownerPlayer, weapon )

	#if SERVER
		thread function () : ( ownerPlayer )
		{
			EndSignal( ownerPlayer, "OnDestroy" )
			EndSignal( ownerPlayer, "OnDeath" )
			
			float fadeout = 0.0
			
			OnThreadEnd(
				function() : ( ownerPlayer, fadeout )
				{
					if ( !IsValid( ownerPlayer ) )
						return
					
					// ownerPlayer.SetCloakDuration( 0, 0, fadeout )
					StopSoundOnEntity( ownerPlayer, "cloak_sustain_loop_1P" )
					StopSoundOnEntity( ownerPlayer, "cloak_sustain_loop_3P" )
					
					ownerPlayer.p.isPlayerInCloakAbility = false
				}
			)
			
			ownerPlayer.p.isPlayerInCloakAbility = true
			
			WaitFrame()
			
			if( Gamemode() == eGamemodes.fs_spieslegends )
				EndSignal( ownerPlayer, "Signal_OnWeaponAttack" )
			
			ownerPlayer.SetCloakDuration( 0.0, CLOAK_DURATION, fadeout )
		
			EmitSoundOnEntityOnlyToPlayer( ownerPlayer, ownerPlayer, "cloak_on_1P" )
			EmitSoundOnEntityExceptToPlayer( ownerPlayer, ownerPlayer, "cloak_on_3P" )
			EmitSoundOnEntityOnlyToPlayer( ownerPlayer, ownerPlayer, "cloak_sustain_loop_1P" )
			EmitSoundOnEntityExceptToPlayer( ownerPlayer, ownerPlayer, "cloak_sustain_loop_3P" )
			
			wait CLOAK_DURATION
		}()
		
		TryPlayWeaponBattleChatterLine( ownerPlayer, weapon )
		// ownerPlayer.Signal( "PlayerUsedAbility" )
	#endif

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
}
