                             
global function ShAbilityShadowZombie_Init
global function IsPlayerShadowZombie
global function Ability_Shadow_Zombie_RegisterNetworking
global function AreTeammatesShadowZombiesOrRespawning

#if SERVER
	global function GiveShadowZombieAbilities
	global function RemoveShadowZombieAbilities
	global function ShadowZombieOnDeath
	global function ShadowFormStopFxAndSound
	global function AreTeammatesShadowZombies
	global function ShadowZombie_TryDamagingTrapAfterTakingDamage
	global function ShadowZombie_SetCallback_GetMaxHealthValueToSetForShadows

	global function ResetCharacterSkin

	global function DEV_GiveShadowZombieAbilities
	bool Dev_Shadow_Squad_Initialized = false
#endif


#if CLIENT
	global function ServerCallback_ShadowAbilitiesClientEffectsEnable
	asset SHADOW_SCREEN_FX = $"P_Bshadow_screen"
#endif

const string STRING_SHADOW_SOUNDS = "ShadowSounds"
const string STRING_SHADOW_FX = "ShadowFX"
asset FX_SHADOW_TRAIL = $"P_Bshadow_body"
asset FX_SHADOW_FORM_EYEGLOW = $"P_BShadow_eye"

#if SERVER
global asset DEATH_FX_SHADOW_SQUAD = $"P_Bshadow_death"
const array < string > DEFAULT_SHADOW_MODS_ARRAY = [ "shadow_squad" ]
#endif

struct
{
	#if SERVER
		float functionref() GetMaxShadowHealth_Callback
		array < string > shadowModsArray
	#endif //SERVER
	#if CLIENT
		table< int, array< int > > playerShadowZombieClientFxHandles
	#endif //CLIENT

} file

void function ShAbilityShadowZombie_Init()
{
	#if SERVER
		AddSpawnCallback_ScriptName( "survival_door_model", OnUsableObjectSpawned )
		AddSpawnCallback_ScriptName( "survival_door_plain", OnUsableObjectSpawned )
		AddSpawnCallback_ScriptName( "survival_door_sliding", OnUsableObjectSpawned )
		AddSpawnCallback_ScriptName( LOOT_BIN_MARKER_SCRIPTNAME, OnUsableObjectSpawned )
		AddSpawnCallback( "zipline", OnUsableObjectSpawned )
		AddSpawnCallback( "ziprail", OnUsableObjectSpawned )
		AddCallback_OnPlayerKilled( OnPlayerKilled )

		PrecacheParticleSystem( DEATH_FX_SHADOW_SQUAD )

		file.shadowModsArray = DEFAULT_SHADOW_MODS_ARRAY

		                            
			/*if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) )
			{
				PrecacheWeapon( $"mp_ability_rise_from_the_ashes" )
				file.shadowModsArray = [ "shadow_squad", "revarmy_shadow_audio" ]
			}*/
        
	#endif

	ShPrecacheShadowSquadAssets()
	PrecacheWeapon( $"melee_shadowsquad_hands" )
	PrecacheWeapon( $"melee_shadowroyale_hands" )
	PrecacheWeapon( $"mp_weapon_shadow_squad_hands_primary" )
	PrecacheParticleSystem( FX_SHADOW_TRAIL )
	PrecacheParticleSystem( FX_SHADOW_FORM_EYEGLOW )

	#if CLIENT
		PrecacheParticleSystem( SHADOW_SCREEN_FX )
	#endif
}

bool function ShadowZombie_IsEnabled()
{
	                            
		/*if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ARMY ) )
			return true
       

                  
                                                                            
              
       

	                              
		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SHADOW_ROYALE ) )
			return true*/
       

	return true
}

//SHARED
bool function IsPlayerShadowZombie( entity player )
{
	if ( !ShadowZombie_IsEnabled() )
		return false

	if ( !IsValid( player ) )
		return false

	if ( !player.IsPlayer() )
		return false

	return player.GetPlayerNetBool( "isPlayerShadowZombie" )
}
//END SHARED

//SHARED
void function Ability_Shadow_Zombie_RegisterNetworking()
{
	if ( !ShadowZombie_IsEnabled() )
		return

	ScriptRegisterNetworkedVariable( "isPlayerShadowZombie", SNDC_PLAYER_GLOBAL, SNVT_BOOL, false )
	ScriptRemote_RegisterClientFunction( "ServerCallback_ShadowAbilitiesClientEffectsEnable", "entity", "bool" )

	#if CLIENT
	//	RegisterNetworkedVariableChangeCallback_bool( "isPlayerShadowZombie", OnServerVarChanged_IsPlayerShadowZombie )
	#endif
}
//END SHARED

#if CLIENT
void function ServerCallback_ShadowAbilitiesClientEffectsEnable( entity player, bool enableFx )
{
	thread ShadowAbilitiesClientEffectsEnable( player, enableFx )
	
	ClearCustomPlayerInfoColor(player)
	ClearCustomPlayerInfoTreatment(player)
	ClearCustomPlayerInfoCharacterIcon(player)
}
#endif //CLIENT

#if CLIENT
void function OnServerVarChanged_IsPlayerShadowZombie( entity player, bool new )
{
	                                       

	// Using whatever was made for Revenants shadow form. This was all after we did the shadowfall mode.
	// It's more subtle, but it works for temamate unitframes as well
	entity localViewPlayer = GetLocalViewPlayer()
	
//	player.Anim_SetSuppressDialogSounds( new )

	if ( player == localViewPlayer )
	{
		//SetCustomPlayerInfoShadowFormState( localViewPlayer, new )
		//SetCustomPlayerInfoColor( localViewPlayer, <245, 81, 35 > ) // doesn't seem to do anything visually.
	}
	else
	{
	//	SetUnitFrameShadowFormState( player, new )
		//SetUnitFrameCustomColor( player, <245, 81, 35 > ) // doesn't seem to do anything visually.
	}

}
#endif //CLIENT


#if CLIENT
void function ShadowAbilitiesClientEffectsEnable( entity player, bool enableFx, bool isVictorySequence = false )
{
	AssertIsNewThread()
	wait 0.25

	if ( !IsValid( player ) )
		return

	bool isLocalPlayer = ( player == GetLocalViewPlayer() )
	vector playerOrigin = player.GetOrigin()
	int playerTeam = player.GetTeam()

	//////////////////////////
	// ENABLE all FX, Sound, etc
	//////////////////////////
	if ( enableFx )
	{
		/////////////////////
		// Local player only
		/////////////////////
		if ( isLocalPlayer )
		{
			HealthHUD_StopUpdate( player )

			///////////////////////
			// Sound and cockpit fx
			///////////////////////
			EmitSoundOnEntity( player, "ShadowLegend_Shadow_Loop_1P" )

			entity cockpit = player.GetCockpit()
			if ( !IsValid( cockpit ) )
				return

			int fxHandle = StartParticleEffectOnEntity( cockpit, PrecacheParticleSystem( SHADOW_SCREEN_FX ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
			player.p.shadowFxHandles.append(fxHandle)
			EffectSetIsWithCockpit( fxHandle, true )
			vector controlPoint = <1,1,1>
			EffectSetControlPointVector( fxHandle, 1, controlPoint )

			//store off in a client table (by player team...each shadow has own team number)
			if ( !( playerTeam in file.playerShadowZombieClientFxHandles) )
				file.playerShadowZombieClientFxHandles[ playerTeam ] <- []
			file.playerShadowZombieClientFxHandles[playerTeam].append( fxHandle )

		}
	

		/////////////////////
		// Non-players only
		/////////////////////
		else
		{
			//Shadow loop sound
			entity clientAG = CreateClientSideAmbientGeneric( player.GetOrigin() + <0,0,16>, "ShadowLegend_Shadow_Loop_3P", 0 )
			SetTeam( clientAG, player.GetTeam() )
			clientAG.SetSegmentEndpoints( player.GetOrigin() + <0,0,16>, playerOrigin + <0, 0, 72> )
			clientAG.SetEnabled( true )
			clientAG.RemoveFromAllRealms()
			clientAG.AddToOtherEntitysRealms( player )
			clientAG.SetParent( player, "", true, 0.0 )
			clientAG.SetScriptName( STRING_SHADOW_SOUNDS )
		}
		
		SetCustomPlayerInfoCharacterIcon( player, $"rui/gamemodes/shadow_squad/generic_shadow_character_sdk" )
		SetCustomPlayerInfoTreatment( player, $"rui/gamemodes/shadow_squad/player_info_custom_treatment_sdk" )
		SetCustomPlayerInfoColor( player, <245, 81, 35 > )


		///////////////
		// All players
		///////////////


		//fx regardless of whether local player or not
		/*
		//store off in a client table by player team
		if ( !( playerTeam in file.playerShadowZombieClientFxHandles) )
			file.playerShadowZombieClientFxHandles[ playerTeam ] <- []

		//shadow form
		string smokeAttachment = "CHESTFOCUS"
		int fxHandleShadow = StartParticleEffectOnEntity( player, GetParticleSystemIndex( FX_SHADOW_TRAIL ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( smokeAttachment ) )

		//stick handles in a table to be deleted later
		file.playerShadowZombieClientFxHandles[playerTeam].append( fxHandleShadow )

		*/

	}

	//////////////////////////
	// DELETE all FX, sound, etc
	//////////////////////////
	else
	{
		/////////////////////
		// Local player only
		/////////////////////
		if ( isLocalPlayer )
		{
			StopSoundOnEntity( player, "ShadowLegend_Shadow_Loop_1P" )

			if ( !( playerTeam in file.playerShadowZombieClientFxHandles) )
			{
				Warning( "%s() - Unable to find client-side effect table for player: '%s'", FUNC_NAME(), string( player ) )
			}
			else
			{
				foreach( int fxHandle in file.playerShadowZombieClientFxHandles[ playerTeam ] )
				{
					if ( EffectDoesExist( fxHandle ) )
						EffectStop( fxHandle, false, true )
				}
				delete file.playerShadowZombieClientFxHandles[ playerTeam ]
			}
		}

		////////////////
		// All players
		////////////////


		//////////////////////////////////////////////
		// SFX ambient generics parented to the player
		//////////////////////////////////////////////
		array<entity> children = player.GetChildren()
		foreach( childEnt in children )
		{
			if ( !IsValid( childEnt ) )
				continue

			if ( childEnt.GetScriptName() == STRING_SHADOW_SOUNDS )
			{
				childEnt.Destroy()
				continue
			}
		}


	}
}
#endif //CLIENT

#if SERVER
void function ShadowSquadApplyCharacterSkin( entity player )
{
	                               
	//////////////////////////////////////////////
	// Switch to base character model for Legend
	/////////////////////////////////////////////
	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_CharacterClass() )
	ItemFlavor skin = GetDefaultItemFlavorForLoadoutSlot( ToEHI( player ), Loadout_CharacterSkin( character ) )
	CharacterSkin_Apply( player, skin )

	//////////////////////////////////////
	// Apply the shadow skin material if we have it
	//////////////////////////////////////

	SetShadowAbilitiesSkin( player )
}
#endif //SERVER


#if SERVER
void function SetShadowAbilitiesSkin( entity player )
{
	int skinIdx = player.GetSkinIndexByName( "ShadowSqaud" )
	if ( skinIdx > 0 )
	{
		player.SetSkin( skinIdx )
		player.SetCamo( 0 )
	}
	else //otherwise just tint the player full black till we get the skin
	{
		player.kv.rendercolor = <0, 0, 0>
	}
}
#endif //SERVER

#if SERVER
void function DEV_GiveShadowZombieAbilities( entity player )
{
	if ( !Dev_Shadow_Squad_Initialized )
	{
		/*array<entity> nonCodeDoors = GetAllNonCodeDoorEnts()
		foreach ( door in nonCodeDoors )
		{
			door.AddUsableValue( USABLE_CAN_USE_OVERRIDE )
		}*/

		/*array<entity> ziplines = GetEntArrayByClass_Expensive( "zipline" )
		foreach ( zipline in ziplines )
		{
			zipline.AddUsableValue( USABLE_CAN_USE_OVERRIDE )
		}
		array<entity> lootBins = GetAllLootBins()
		foreach ( bin in lootBins )
		{
			bin.AddUsableValue( USABLE_CAN_USE_OVERRIDE )
		}*/
		Dev_Shadow_Squad_Initialized = true
	}

	player.SetHealth( 30 )

	GiveShadowZombieAbilities( player )
	ShadowSquadApplyCharacterSkin( player )
}
#endif //SERVER


#if SERVER
void function OnUsableObjectSpawned( entity usableObject )
{
	usableObject.AddUsableValue( USABLE_CAN_USE_OVERRIDE )
}
#endif // SERVER

#if SERVER
int function GetDamageDealtToDeployablesAfterBeingDamagedByThem()
{
	return GetCurrentPlaylistVarInt( "shadow_damage_dealt_on_damage_from_deployable", 10 )
}
#endif // SERVER

#if SERVER
// Allow other modes to set different functions to grab the max health value to set Shadows to
void function ShadowZombie_SetCallback_GetMaxHealthValueToSetForShadows( float functionref() func )
{
	Assert( file.GetMaxShadowHealth_Callback == null )
	file.GetMaxShadowHealth_Callback = func
}
#endif //SERVER

#if SERVER
float function GetMaxHealthValueToSetForShadows()
{
	return GetCurrentPlaylistVarFloat( "shadow_health", 30 )
}
#endif // SERVER

#if SERVER
void function ShadowZombie_TryDamagingTrapAfterTakingDamage( entity victim, entity attacker, entity attackerProp )
{
	int damageAmountToDeployables = GetDamageDealtToDeployablesAfterBeingDamagedByThem()

	// Break out if we don't do any damage to the deployables
	if ( damageAmountToDeployables <= 0 )
		return

	// Validity checks
	if ( !IsValid( victim ) || !IsValid( attacker ) || !IsValid( attackerProp ) )
		return

	// Only do anything if the affected player is a shadow
	if ( !IsPlayerShadowZombie( victim ) )
		return

	// If the trap is friendly, no need to do anything
	if ( IsFriendlyTeam( attacker.GetTeam(), victim.GetTeam() ) )
		return

	// Damage the deployable
	if ( attackerProp.GetHealth() > 0 )
		attackerProp.TakeDamage( damageAmountToDeployables, victim, victim, {} )
}
#endif // SERVER

#if SERVER
void function GiveShadowZombieAbilities( entity player )
{
	if ( !IsAlive( player ) ) //Defensive fix, shouldn't need to be done in theory? R5DEV-187597
		return

	if ( !player.GetPlayerNetBool( "isPlayerShadowZombie" ) )
	{
			player.SetPlayerNetBool( "isPlayerShadowZombie", true )
	}

	if ( Bleedout_IsBleedingOut( player ) )
	{
		//if squadmate is bleeding out, just allow them back in the fight
		//too many unresolved issues doing player state change, particularly with heirlooms
		Bleedout_ForceStop( player )
		Bleedout_ReviveForceStop( player )
	}

	player.AddUsableValue( USABLE_CAN_USE_OVERRIDE ) //allow shadow zombies to revive eachother if bleedout is enabled

	////////////////////////////////
	// Cleanup old traps, ults, etc
	////////////////////////////////
	foreach ( trap in player.e.activeTraps )
	{
		if ( IsValid( trap ) )
			trap.Destroy()
	}
	foreach ( trap in player.e.activeUltimateTraps )
	{
		if ( IsValid( trap ) )
			trap.Destroy()
	}

	/*CancelPlayerStatesData states
	states.cancelZipline = true
	states.cancelGrapple = true
	states.cancelPhaseTunnel = true
	states.cancelPhaseWalk = true
	states.cancelRevive = true
	states.cancelCryptoDrone = true
	states.cancelTotem = true
	states.cancelMainOrAltHandAbility = true

	CancelPlayerStates( player, states )*/


	//////////////////////////////////////
	// Deal with character specific cases
	//////////////////////////////////////
	//delete any deployed mirage tactical decoys (ults will fade by the time he respawns
	//if ( !player.IsBot() && IsValid( player.p.decoy ) )
		//player.p.decoy.Destroy()

	CryptoDroneHideCamera( player )

	/////////////////////
	// Melee and mods
	/////////////////////
	TakeAllWeapons( player )
	player.TakeOffhandWeapon( OFFHAND_TACTICAL )
	player.TakeOffhandWeapon( OFFHAND_ULTIMATE )

	TakeAllPassives( player )
	array<string> mods = player.GetPlayerSettingsMods()
	TakePlayerSettingsMods( player, mods )

	player.TakeOffhandWeapon( OFFHAND_MELEE )
	player.GiveWeapon( "mp_weapon_shadow_squad_hands_primary", WEAPON_INVENTORY_SLOT_PRIMARY_2 )
	string melee_hands_weapon = "melee_shadowsquad_hands"

	                             
       


	player.GiveOffhandWeapon( melee_hands_weapon, OFFHAND_MELEE )
	GivePlayerSettingsMods( player, [ "enable_wallrun", "shadow_squad" ] )
	/*if ( player.GetTeam() != TEAM_SPECTATOR )
	{
		GivePlayerSettingsMods( player, [ "disable_targetinfo" ] )
	}*/
	player.EnterShadowForm()
	bool playerAlreadyHasHealthCallback = false
	/*foreach ( func in player.e.entOnShadowHealthExhaustedCallbacks )
	{
		if ( func == Outlands_OnShadowHealthExhausted )
		{
			playerAlreadyHasHealthCallback = true
			break
		}
	}*/
	//if ( !playerAlreadyHasHealthCallback )
		//AddEntityCallback_OnShadowHealthExhausted( player, Outlands_OnShadowHealthExhausted )
	float shadowHealth = GetMaxHealthValueToSetForShadows()
	player.SetMaxHealth( shadowHealth )
	player.SetHealth( shadowHealth )
	//AddCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )
	ForceAutoSprintOn( player )

	/*
	//don't really want this for quests, can re-enable if we do shadowfall again
                  
                                                          
                       
	*/

	//////////////////////////////
	// FX Eye Glows, Smoke, sound
	//////////////////////////////
	bool shouldApplyShadowFX = true
	                            

	
	if ( shouldApplyShadowFX )
	{
		ShadowAbilitiesStartFxAndSound( player )
		EmitSoundOnEntityOnlyToPlayer( player, player, "ShadownLegend_Shadow_Spawn" )
		ShadowAbilitiesApplyCharacterSkin( player )
	}

	if ( GetCurrentPlaylistVarBool( "shadow_health_regen", true ) )
	{
		//health regen
		/*int regenSource = eRegenSource.MODE
		float regenHealthPerSec = GetPlaylistVar_ShadowHealthRegenPerSec()
		float regenShieldPerSec = GetPlaylistVar_ShadowHealthRegenPerSec()
		float regenStartDelay = GetPlaylistVar_ShadowHealthRegenDelay()

		thread HealthRegen_Thread( player, regenSource, regenHealthPerSec, regenShieldPerSec, regenStartDelay, false )*/
	}
	else
	{
		//Disable regen health for octane
		//HealthRegen_End( player )
	}
}
#endif


#if SERVER
void function RemoveShadowZombieAbilities( entity player )
{
	if ( !IsValid( player ) )
		return

/*	if ( !IsPlayerShadowZombie( player ) )
	{
		Warning( "%s() - Trying to call RemoveShadowZombieAbilities on a non-shadow player: '%s'", FUNC_NAME(), string( player ) )
		return
	}

	if ( Bleedout_IsBleedingOut( player ) )
	{
		//if squadmate is bleeding out, just allow them back in the fight
		//too many unresolved issues doing player state change, particularly with heirlooms
		Bleedout_ForceStop( player )
		Bleedout_ReviveForceStop( player )
	}*/

	EmitSoundOnEntity( player, "ShadowLegend_Shadow_Regen" )
	RemoveCinematicFlag( player, CE_FLAG_HIDE_MAIN_HUD )
	TakePlayerSettingsMods( player,[ "enable_wallrun", "shadow_squad" ] )
	//player.TargetInfoDisableOn()
	ForceAutoSprintOff( player )
	player.LeaveShadowForm()
	player.kv.rendercolor = <255, 255, 255>
	ShadowFormStopFxAndSound( player )
	//SurvivalPlayerRespawnedInit( player ) //reset everything
	player.TakeOffhandWeapon( OFFHAND_MELEE )
	player.p.respawnPodLanded = true
	//SurvivalPlayerRespawnedInit( player )
	ResetCharacterSkin( player )
	player.p.respawnPodLanded = false
	if ( player.GetPlayerNetBool( "isPlayerShadowZombie" ) )
		player.SetPlayerNetBool( "isPlayerShadowZombie", false )

	if ( IsAlive( player ) )
		player.SetHealth( player.GetMaxHealth() )
		
	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_CharacterClass() )
		
	player.TakeOffhandWeapon( OFFHAND_MELEE )
	player.TakeNormalWeaponByIndexNow( WEAPON_INVENTORY_SLOT_PRIMARY_2 )
	player.GiveWeapon( "mp_weapon_melee_survival", WEAPON_INVENTORY_SLOT_PRIMARY_2 )
	string melee_hands_weapon = "melee_pilot_emptyhanded"
	
	ItemFlavor ultimateAbility = CharacterClass_GetUltimateAbility( character )
	ItemFlavor tacticalAbility = CharacterClass_GetTacticalAbility( character )
	
	player.GiveOffhandWeapon(CharacterAbility_GetWeaponClassname(tacticalAbility), OFFHAND_TACTICAL )	
	player.GiveOffhandWeapon( CharacterAbility_GetWeaponClassname( ultimateAbility ), OFFHAND_ULTIMATE )


	player.GiveOffhandWeapon( melee_hands_weapon, OFFHAND_MELEE )
}
#endif //#if SERVER

#if SERVER
void function ResetCharacterSkin( entity player )
{
	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_CharacterClass() )
	LoadoutEntry skinSlot = Loadout_CharacterSkin( character )
	ItemFlavor skin = LoadoutSlot_GetItemFlavor( ToEHI( player ), skinSlot )

	player.kv.rendercolor = "255 255 255 255"
	CharacterSkin_Apply( player, skin )
}
#endif //SERVER

#if SERVER
void function ShadowAbilitiesStartFxAndSound( entity player )
{
	foreach ( entity otherPlayer in GetPlayerArray_AliveConnected() )
		Remote_CallFunction_Replay( otherPlayer, "ServerCallback_ShadowAbilitiesClientEffectsEnable", player, true )

	array <entity> shadowFx

	//shadow form
	string smokeAttachment = "CHESTFOCUS"
	entity fxHandleShadow = StartParticleEffectOnEntity_ReturnEntity( player, PrecacheParticleSystem( FX_SHADOW_TRAIL ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( smokeAttachment ) )
	fxHandleShadow.SetOwner( player )
	fxHandleShadow.SetParent( player, smokeAttachment )
	fxHandleShadow.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)
	shadowFx.append( fxHandleShadow )

	// Eye glows
	array <entity> fxEyeGlows
	if ( player.LookupAttachment( "EYE_L" ) > 0 )
	{
		fxEyeGlows.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( FX_SHADOW_FORM_EYEGLOW ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "EYE_L" ) ) )
		fxEyeGlows.append( StartParticleEffectOnEntity_ReturnEntity( player, GetParticleSystemIndex( FX_SHADOW_FORM_EYEGLOW ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "EYE_R" ) ) )
		foreach ( fx in fxEyeGlows )
		{
			fx.SetOwner( player )
			fx.kv.VisibilityFlags = ( ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY ) //render to everyone except player
		}
		shadowFx.extend( fxEyeGlows )

		player.e.fxArray.extend( shadowFx )
	}

	//vision fx

	                              
	/*
	if ( IsShadowRoyaleMode() )
		StatusEffect_AddEndless( player, eStatusEffect.enemy_only_threat_vision, 5.0 )
	*/
       

}
#endif //#if SERVER



#if SERVER
void function ShadowZombieOnDeath( entity player )
{
	if ( !IsValid( player ) )
		return

	//////////////////
	// Death FX
	//////////////////

	bool shouldPlayDeathVFX = true
       

	if ( shouldPlayDeathVFX )
	{
		vector deathOrigin = player.GetOrigin()
		vector lootOrigin = deathOrigin + <0, 0, 64>

		thread CreateAirShake( deathOrigin, 2, 50, 1 )

		if (  player.LookupAttachment( "CHESTFOCUS" ) > 0 )
			StartParticleEffectOnEntity( player, GetParticleSystemIndex( DEATH_FX_SHADOW_SQUAD ), FX_PATTACH_POINT_FOLLOW, player.LookupAttachment( "CHESTFOCUS" ) )
		else
			PlayFX( DEATH_FX_SHADOW_SQUAD, deathOrigin )

		EmitSoundAtPosition( TEAM_ANY, lootOrigin, "ShadowLegend_Shadow_DeathVanish", player )
	}

	//////////////////////
	// Hide until respawn
	//////////////////////
	player.MakeInvisible()
	player.NotSolid()

	if ( shouldPlayDeathVFX )
		ShadowFormStopFxAndSound( player )

}
#endif //#if SERVER

#if SERVER
void function ShadowFormStopFxAndSound( entity player )
{
	StatusEffect_StopAll( player )

	foreach( fxHandle in player.e.fxArray )
	{
		if ( IsValid( fxHandle ) )
			EffectStop( fxHandle )
	}

	foreach ( entity otherPlayer in GetPlayerArray_AliveConnected() )
		Remote_CallFunction_Replay( otherPlayer, "ServerCallback_ShadowAbilitiesClientEffectsEnable", player, false )

}
#endif //#if SERVER


#if SERVER
void function ShadowAbilitiesApplyCharacterSkin( entity player )
{
	//Called from ApplyAppropriateCharacterSkin() on player spawn or on mod setting change

	ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_CharacterClass() )
	//Temporary set up until shadow form is applied via modifier - to delete with .p variables
	{
		LoadoutEntry skinSlot = Loadout_CharacterSkin( character )
		if ( LoadoutSlot_IsReady( ToEHI( player ), skinSlot ) )
		{
			ItemFlavor skin = LoadoutSlot_GetItemFlavor( ToEHI( player ), skinSlot )
			//player.p.skinIndex = player.GetSkin()
			//player.p.camoIndex = CharacterSkin_GetCamoIndex( skin )
			//player.p.loadoutSkin = skin
		}
	}

	//////////////////////////////////////////////
	// Switch to base character model for Legend
	/////////////////////////////////////////////
	ItemFlavor skin = GetDefaultItemFlavorForLoadoutSlot( ToEHI( player ), Loadout_CharacterSkin( character ) )
	CharacterSkin_Apply( player, skin )

	//////////////////////////////////////
	// Apply the shadow skin material if we have it
	//////////////////////////////////////

	//SetShadowAbilitiesSkin( player )
}
#endif //SERVER



#if SERVER
bool function Outlands_OnShadowHealthExhausted( entity player )
{
	if ( IsPlayerShadowZombie( player ) )
	{
		// Do something before the shadow dies in this frame
	}

	return false // Do not save the player from death
}
#endif //SERVER



#if SERVER
bool function AreTeammatesShadowZombies( entity player )
{

	foreach ( entity guy in GetPlayerArrayOfTeam_Alive( player.GetTeam() ) )
	{
		if ( guy == player )
			continue


		if ( !IsPlayerShadowZombie( guy ) )
			return false
	}

	return true

}
#endif //SERVER

#if SERVER
void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !IsValid( victim ) || !IsPlayerShadowZombie( victim) )
	{
		return
	}

	TakePlayerSettingsMods( victim, [ "enable_wallrun", "shadow_squad" ] )
}
#endif //SERVER


#if CLIENT || SERVER
bool function AreTeammatesShadowZombiesOrRespawning( entity player )
{

	foreach ( entity guy in GetPlayerArrayOfTeam( player.GetTeam() ) )
	{
		if ( !IsValid( guy ) )
			continue

		if ( guy == player )
			continue

		if ( guy.GetPlayerNetInt( "respawnStatus" ) == eRespawnStatus.WAITING_FOR_DROPPOD )
			continue

		if ( !IsPlayerShadowZombie( guy ) )
			return false
	}

	return true

}
#endif //CLIENT || SERVER

float function GetPlaylistVar_ShadowHealthRegenPerSec()
{
	return GetCurrentPlaylistVarFloat( "shadow_health_regen_rate_multiplier", 2.0 )
}

float function GetPlaylistVar_ShadowHealthRegenDelay()
{
	return GetCurrentPlaylistVarFloat( "shadow_health_regen_delay", 6.0 )
}