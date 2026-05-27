global function MpAbilityTransportPortalDatapad_Init

global function OnWeaponActivate_ability_transport_portal_datapad
global function OnWeaponDeactivate_ability_transport_portal_datapad
global function OnWeaponPrimaryAttack_ability_transport_portal_datapad

#if SERVER
global function TakeDataPadIfInterrupted_Thread
#endif
#if CLIENT
global function TransportPortal_CancelUse
#endif

global const string  TRANSPORT_PORTAL_DATAPAD_WEAPON_NAME = "mp_ability_transport_portal_datapad"

//RPCs

//Signals
const string TRANSPORT_PORTAL_CANCEL_CHANNEL_SIGNAL = "alter_ult_cancel_channel"
const string TRANSPORT_PORTAL_INTERRUPT_CHANNEL_SIGNAL = "alter_ult_interrupt_channel"
global const string TRANSPORT_PORTAL_FINISHED_CHANNEL_SIGNAL = "alter_ult_finish_channel"
#if CLIENT
const string TRANSPORT_PORTAL_SPECTATOR_TARGET_CHANGED = "alter_ult_spectator_changed"
#endif

//FX
const asset TRANSPORT_PORTAL_PRE_TRAVEL_FX = $"P_alter_ulti_portal_channeling"
const asset TRANSPORT_PORTAL_WARP_1P = $"P_alter_ulti_portal_warp_FP"
const asset TRANSPORT_PORTAL_ROPE_FRIENDLY = $"P_alter_ulti_portal_dir_friendly"
const asset TRANSPORT_PORTAL_ROPE_ENEMY = $"P_alter_ulti_portal_dir_enemy"

//Sounds
const string TRANSPORT_PORTAL_TELEPORT_CONFIRM_1P = "Alter_Ult_UI_Teleport_Confirm_1p"
const string TRANSPORT_PORTAL_START_CHANNEL_SOUND_1P = "Alter_Ult_Teleport_Buildup_1p"
const string TRANSPORT_PORTAL_START_CHANNEL_SOUND_3P = "Alter_Ult_Teleport_Buildup_3p"
const string TRANSPORT_PORTAL_START_CHANNEL_KNOCKED_SOUND_1P = "Alter_Ult_Teleport_Buildup_Downed_1p"
const string TRANSPORT_PORTAL_START_CHANNEL_KNOCKED_SOUND_3P = "Alter_Ult_Teleport_Buildup_Downed_3p"
const string TRANSPORT_PORTAL_START_CHANNEL_TRANSLOCATOR_SOUND_3P = "Alter_Ult_Base_Alert_RemotelyUsed_3p"

const bool TRANSPORT_PORTAL_DATAPAD_DEBUG = true

struct{
	float warpDelayAfterUse = 2.0
	float warpDelayAfterUseAdditionalWhenKnocked = 1.0

	bool canCancel = true
	bool cancelOnDamage = false
	bool cancelOnNonBulletDamage = false
}tuning

struct
{
	table < entity, bool > userToChannelCompletedMap
	#if SERVER
	table <entity, bool> entityToClearContextBusy
	#endif
}file

void function MpAbilityTransportPortalDatapad_Init()
{
	SetupTuning()

	PrecacheWeapon( TRANSPORT_PORTAL_DATAPAD_WEAPON_NAME )

	PrecacheParticleSystem( TRANSPORT_PORTAL_PRE_TRAVEL_FX )
	PrecacheParticleSystem( TRANSPORT_PORTAL_WARP_1P )
	PrecacheParticleSystem( TRANSPORT_PORTAL_ROPE_FRIENDLY )
	PrecacheParticleSystem( TRANSPORT_PORTAL_ROPE_ENEMY )

	RegisterSignal( TRANSPORT_PORTAL_CANCEL_CHANNEL_SIGNAL )
	RegisterSignal( TRANSPORT_PORTAL_INTERRUPT_CHANNEL_SIGNAL )
	RegisterSignal( TRANSPORT_PORTAL_FINISHED_CHANNEL_SIGNAL )

	#if CLIENT
	RegisterSignal( TRANSPORT_PORTAL_SPECTATOR_TARGET_CHANGED )

	AddOnSpectatorTargetChangedCallback( OnSpectatorTargetChanged )
	#endif
}


void function SetupTuning()
{
	tuning.warpDelayAfterUse = 						GetCurrentPlaylistVarFloat	( "alter_ult_warpDelayAfterUse", tuning.warpDelayAfterUse )
	tuning.warpDelayAfterUseAdditionalWhenKnocked = GetCurrentPlaylistVarFloat	( "alter_ult_warpDelayAfterUseKnocked", tuning.warpDelayAfterUseAdditionalWhenKnocked )

	tuning.cancelOnDamage =							GetCurrentPlaylistVarBool	( "alter_ult_cancelOnDamage", tuning.cancelOnDamage )
	tuning.cancelOnNonBulletDamage =				GetCurrentPlaylistVarBool	( "alter_ult_cancelOnNonBulletDamage", tuning.cancelOnNonBulletDamage )
}

#if CLIENT
void function OnSpectatorTargetChanged( entity player, entity prevTarget, entity newTarget )
{
	if ( IsValid( prevTarget ) && prevTarget.IsPlayer() )
	{
		entity weapon = prevTarget.GetOffhandWeapon( OFFHAND_EQUIPMENT )
		if ( IsValid( weapon ) && weapon.GetWeaponClassName() == TRANSPORT_PORTAL_DATAPAD_WEAPON_NAME )
		{
			if ( prevTarget in file.userToChannelCompletedMap )
			{
				delete file.userToChannelCompletedMap[prevTarget]
			}

			prevTarget.Signal( TRANSPORT_PORTAL_SPECTATOR_TARGET_CHANGED )
		}
	}

	if ( IsValid( newTarget ) && newTarget.IsPlayer() )
	{
		entity weapon = newTarget.GetOffhandWeapon( OFFHAND_EQUIPMENT )
		if ( IsValid( weapon ) && weapon.GetWeaponClassName() == TRANSPORT_PORTAL_DATAPAD_WEAPON_NAME )
		{
			file.userToChannelCompletedMap[newTarget] <- false

			bool playerIsKnocked = Bleedout_IsBleedingOut( newTarget )
			//TODO the charge frac doesn't seem to be right when changing spectators...
			SetupFxAndSound( newTarget, weapon.GetWeaponChargeFraction(), false, playerIsKnocked )
		}
	}
}
#endif

void function OnWeaponActivate_ability_transport_portal_datapad( entity weapon )
{
	#if CLIENT
		if ( weapon.GetOwner() != GetLocalViewPlayer() )
			return
	#endif

	#if TRANSPORT_PORTAL_DATAPAD_DEBUG
	printf( "Alter - " + weapon.GetOwner() + ": ACTIVATE portal datapad" )
	#endif

	entity player = weapon.GetWeaponOwner()
	if ( !IsValid(player) )
		return

	file.userToChannelCompletedMap[player] <- false

	bool playerIsKnocked = Bleedout_IsBleedingOut( player )
	#if SERVER
	#if TRANSPORT_PORTAL_DATAPAD_DEBUG
	printf( "Alter - " + weapon.GetOwner() + ": Ult" + weapon.w.transportPortalRootEnt )
	#endif
	entity rootEnt = weapon.w.transportPortalRootEnt

	thread OnHoldUseSuccessDatapad_Thread( rootEnt, player )
	#endif

	#if CLIENT
	EmitSoundOnEntity( player, TRANSPORT_PORTAL_TELEPORT_CONFIRM_1P )
	SetupFxAndSound( player, weapon.GetWeaponChargeFraction(), true, playerIsKnocked )
	#endif
}

void function OnWeaponDeactivate_ability_transport_portal_datapad( entity weapon )
{
	#if CLIENT
	if ( weapon.GetOwner() != GetLocalViewPlayer() )
		return
	#endif

	#if TRANSPORT_PORTAL_DATAPAD_DEBUG
	printf( "Alter - " + weapon.GetOwner() + ": Data pad DEACTIVATE" )
	#endif

	entity player = weapon.GetWeaponOwner()
	if ( !IsValid(player) )
		return

	if ( !( player in file.userToChannelCompletedMap ) || !file.userToChannelCompletedMap[player]  )
	{
		player.Signal( TRANSPORT_PORTAL_CANCEL_CHANNEL_SIGNAL )
		#if TRANSPORT_PORTAL_DATAPAD_DEBUG
		printf("Alter - " + weapon.GetOwner() + ": datapad WAS CANCELLED " + weapon.GetWeaponChargeFraction() )
		#endif
	}
	else
	{
		player.Signal( TRANSPORT_PORTAL_FINISHED_CHANNEL_SIGNAL )
	}

	if ( player in file.userToChannelCompletedMap  )
	{
		delete file.userToChannelCompletedMap[player]
	}

	#if SERVER
	//if it finished normally, the data pad should already be taken, but I'm leaving this here for safety
	thread TakeDataPadAtEndOfFrame_Thread( player )
	#endif
}

#if SERVER
void function TakeDataPadAtEndOfFrame_Thread( entity player )
{
	WaitEndFrame()

	if ( IsValid( player ) )
	{
		TransportPortal_EndUseOfDatapad( player )
	}
}

void function TakeDataPadIfInterrupted_Thread( entity player )
{
	EndThreadOn_PlayerChangedClass( player )
	player.EndSignal( "BleedOut_OnStartDying", "StartPhaseShift", "BleedOut_OnReviveStart", "OnSyncedMeleeVictim", TRANSPORT_PORTAL_INTERRUPT_CHANNEL_SIGNAL )

	PassByReferenceBool takeWeapon
	takeWeapon.value = true
	OnThreadEnd(
		function() : ( player, takeWeapon )
		{
			if ( takeWeapon.value && IsValid( player ) )
			{
				TransportPortal_EndUseOfDatapad( player )
			}
		}
	)

	player.WaitSignal( TRANSPORT_PORTAL_CANCEL_CHANNEL_SIGNAL, TRANSPORT_PORTAL_FINISHED_CHANNEL_SIGNAL )
	takeWeapon.value = false
}
#endif

var function OnWeaponPrimaryAttack_ability_transport_portal_datapad( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) )
		return 0

	if ( weapon.GetWeaponChargeFraction() < 1.0 )
		return 0

	file.userToChannelCompletedMap[player] <- true

	#if SERVER
	entity rootEnt = weapon.w.transportPortalRootEnt

	if ( !IsValid( rootEnt ) )
		return 0

	//need this here or we don't teleport because we're busy, as the thread ends right after
	if ( player in file.entityToClearContextBusy )
	{
		player.ContextAction_ClearBusy()
		delete file.entityToClearContextBusy[player]
	}

	#if TRANSPORT_PORTAL_DATAPAD_DEBUG
	printf("ALTER - " + player + ": ChasePortal now")
	#endif

	thread CreateChasePortal_Thread( rootEnt, player )
	#endif

	return 1
}

#if SERVER
void function OnHoldUseSuccessDatapad_Thread( entity rootEnt, entity player )
{
	Assert ( IsNewThread(), "Must be started as new thread" )

	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDeath", "OnDestroy", TRANSPORT_PORTAL_CANCEL_CHANNEL_SIGNAL )

	Assert( IsValid( rootEnt ), "Root ent isn't valid when on hold succeeded" )
	rootEnt.EndSignal( "OnDestroy" )
	player.EndSignal( "OnSyncedMelee" )
	EndThreadOn_PlayerChangedClass( player )

	if (tuning.cancelOnDamage)
	{
		AddEntityCallback_OnPostDamaged( player, OnPostTakeDamage )
	}

	bool isKnocked = Bleedout_IsBleedingOut( player )

	EmitSoundOnEntityExceptToPlayer( player, player, isKnocked ? TRANSPORT_PORTAL_START_CHANNEL_KNOCKED_SOUND_3P : TRANSPORT_PORTAL_START_CHANNEL_SOUND_3P )
	PlayBattleChatterLineToSpeakerAndTeamWithDebounceTime( player, "bc_portalUsing", 15, 15 )

	thread ManageRopeFX_Thread( rootEnt, player )

	float warpDelay = tuning.warpDelayAfterUse

	if ( isKnocked )
	{
		warpDelay += tuning.warpDelayAfterUseAdditionalWhenKnocked
	}

	PassByReferenceBool wasCancelled
	wasCancelled.value = true

	int attachId = player.LookupAttachment( "CHESTFOCUS" )
	int fxid = GetParticleSystemIndex( TRANSPORT_PORTAL_PRE_TRAVEL_FX )
	entity travelFX = StartParticleEffectOnEntity_ReturnEntity( player, fxid, FX_PATTACH_POINT_FOLLOW, attachId )
	travelFX.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)	// everyone but owner
	travelFX.SetOwner( player )

	if ( !isKnocked )
	{
		file.entityToClearContextBusy[player] <- true
		player.ContextAction_SetBusy()
	}

	int slowHandle = StatusEffect_AddTimed( player, eStatusEffect.move_slow, 0.35, warpDelay, 0.0 )

	OnThreadEnd(
		function() : ( player, slowHandle, travelFX, rootEnt, wasCancelled, isKnocked )
		{
			#if TRANSPORT_PORTAL_DATAPAD_DEBUG
				printf( "Alter - " + player + ": Data pad end thread" )
			#endif

			bool clearContextAction = false
			if ( player in file.entityToClearContextBusy )
			{
				clearContextAction = true
				delete file.entityToClearContextBusy[player]
			}

			if ( IsValid( player ) )
			{
				StatusEffect_Stop( player, slowHandle )

				if ( clearContextAction )
				{
					player.ContextAction_ClearBusy()
				}

				if ( wasCancelled.value )
				{
					#if TRANSPORT_PORTAL_DATAPAD_DEBUG
						printf( "Alter - " + player + ": Data pad end thread - was CANCELED" )
					#endif

					StopSoundOnEntity( player, (isKnocked ? TRANSPORT_PORTAL_START_CHANNEL_KNOCKED_SOUND_3P : TRANSPORT_PORTAL_START_CHANNEL_SOUND_3P) )

					PIN_PlayerAbility( player, "mp_ability_transport_portal_datapad", ABILITY_TYPE.ULTIMATE, null, { cancelled = true } )
				}
			}

			if ( tuning.cancelOnDamage )
			{
				RemoveEntityCallback_OnPostDamaged( player, OnPostTakeDamage )
			}

			if ( IsValid( travelFX ) )
			{
				EffectStop( travelFX )
			}
		}
	)

	wait warpDelay

	wasCancelled.value = false
}
	#endif

#if SERVER
void function ManageRopeFX_Thread( entity rootEnt, entity player )
{
	player.EndSignal( "OnDeath", "OnDestroy", "BleedOut_OnStartDying", TRANSPORT_PORTAL_CANCEL_CHANNEL_SIGNAL )

	entity translocator = GetAlterRootEntData(rootEnt).translocator

	vector origin = rootEnt.GetOrigin() + <0,0,TRANSPORT_PORTAL_TRANSLOCATOR_PORTAL_OFFSET>
	vector dirFromRootEntToPlayer = Normalize(player.GetOrigin() - rootEnt.GetOrigin())
	float ropeLength = 5 * METERS_TO_INCHES

	EmitSoundOnEntity( translocator, TRANSPORT_PORTAL_START_CHANNEL_TRANSLOCATOR_SOUND_3P )

	int beamFXID
	if ( IsFriendlyTeam( player.GetTeam(), translocator.GetTeam() ) )
	{
		beamFXID = GetParticleSystemIndex( TRANSPORT_PORTAL_ROPE_FRIENDLY )
	}
	else
	{
		beamFXID = GetParticleSystemIndex( TRANSPORT_PORTAL_ROPE_ENEMY )
	}

	entity beamFXEnt = StartParticleEffectOnEntityWithPos_ReturnEntity( translocator, beamFXID, FX_PATTACH_ABSORIGIN_FOLLOW_NOROTATE, ATTACHMENTID_INVALID, <0,0,0>, <0,0,0> )

	EffectSetControlPointVector( beamFXEnt, 1, origin + (dirFromRootEntToPlayer * ropeLength) )

	OnThreadEnd(
		function() : ( beamFXEnt )
		{
			if ( IsValid( beamFXEnt ) )
				beamFXEnt.Destroy()
		}
	)

	table results = WaitSignal( player, TRANSPORT_PORTAL_EXTRA_WAIT_TIME_SIGNAL )

	float travelTime = expect float( results.extraTime )

	wait travelTime
}

void function OnPostTakeDamage( entity player, var damageInfo )
{
	if ( DamageInfo_GetDamage( damageInfo ) <= 0 )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( attacker ) )
		return

	//don't get cancelled by stuff like ring damage
	if (  attacker.IsPlayer() || (attacker.IsNPC() && !attacker.IsNonCombatAI()) )
	{
		int damageType = DamageInfo_GetCustomDamageType( damageInfo )
		if ( tuning.cancelOnNonBulletDamage || IsBitFlagSet( damageType, DF_BULLET ) )
		{
			player.Signal( TRANSPORT_PORTAL_INTERRUPT_CHANNEL_SIGNAL )
		}
	}
}
#endif

#if CLIENT
void function SetupFxAndSound( entity player, float chargeFrac, bool forceSoundFromStart, bool playerIsKnocked )
{
	float channelTime = tuning.warpDelayAfterUse + (playerIsKnocked ? tuning.warpDelayAfterUseAdditionalWhenKnocked : 0.0)
	float channelTimeElapsed = chargeFrac * channelTime
	float soundTotalTime = channelTime
	string sound = playerIsKnocked ? TRANSPORT_PORTAL_START_CHANNEL_KNOCKED_SOUND_1P : TRANSPORT_PORTAL_START_CHANNEL_SOUND_1P

	if ( forceSoundFromStart )
	{
		EmitSoundOnEntity( player, sound )
	}
	else
	{
		soundTotalTime -= channelTimeElapsed
		EmitSoundOnEntityWithSeek( player, sound, channelTimeElapsed )
	}

	thread CleanupChannelSound_Thread( player, soundTotalTime, sound )
	thread PlayScreenFXWarpJumpTransportPortal( player )
	TransportPortal_SetChannelUseTime( channelTime, channelTimeElapsed )
}
#endif

#if CLIENT
void function CleanupChannelSound_Thread( entity player, float delay, string sound )
{
	player.EndSignal( "OnDeath", "OnDestroy", "BleedOut_OnStartDying", TRANSPORT_PORTAL_CANCEL_CHANNEL_SIGNAL, TRANSPORT_PORTAL_SPECTATOR_TARGET_CHANGED )

	OnThreadEnd(
		function() : ( player, sound )
		{
			StopSoundOnEntity( player, sound )
		}
	)

	wait delay
}
#endif

#if CLIENT
void function Channel_DisplayProgressBar( entity player, float channelTime, float channelTimeElapsed )
{
	player.EndSignal( "OnDeath", "OnDestroy", "BleedOut_OnStartDying", TRANSPORT_PORTAL_CANCEL_CHANNEL_SIGNAL, TRANSPORT_PORTAL_SPECTATOR_TARGET_CHANGED )

	string consumableName = "#ABL_ULT_TRANSPORT_PORTAL_SHORT"
	asset hudIcon         = $"rui/hud/ultimate_icons/ultimate_alter"
	float raiseTime       = 0
	float chargeTime      = channelTime

	var rui = CreateFullscreenRui( $"ui/consumable_progress.rpak" )

	RuiSetGameTime( rui, "healStartTime", ( Time() - channelTimeElapsed ) )
	RuiSetString( rui, "consumableName", consumableName )
	RuiSetFloat( rui, "raiseTime", raiseTime )
	RuiSetFloat( rui, "chargeTime", chargeTime )
	RuiSetImage( rui, "hudIcon", hudIcon )

	OnThreadEnd(
		function() : ( rui, player )
		{
			RuiDestroy( rui )
		}
	)

	RuiSetString( rui, "hintController", "#SURVIVAL_CANCEL_HEAL_GAMEPAD" )
	RuiSetString( rui, "hintKeyboardMouse", "#SURVIVAL_CANCEL_HEAL_PC" )

	wait ( channelTime - channelTimeElapsed )
}
#endif

#if CLIENT
void function PlayScreenFXWarpJumpTransportPortal( entity player )
{
	Assert ( IsNewThread(), "Must be started as new thread" )

	player.EndSignal( "OnDeath", "OnDestroy", "BleedOut_OnStartDying", TRANSPORT_PORTAL_CANCEL_CHANNEL_SIGNAL, TRANSPORT_PORTAL_SPECTATOR_TARGET_CHANGED )

	int fxHandle = -1
	if ( IsValid( player.GetCockpit() ) )
	{
		fxHandle = StartParticleEffectOnEntity( player, GetParticleSystemIndex( TRANSPORT_PORTAL_WARP_1P ), FX_PATTACH_POINT_FOLLOW, player.GetCockpit().LookupAttachment( "CAMERA" ) )
		EffectSetIsWithCockpit( fxHandle, true )
	}
	else
	{
		return
	}

	OnThreadEnd(
		function() : ( player, fxHandle )
		{
			printf("ALTER - FX Done Portal " + Time())
			if ( fxHandle > -1 )
				EffectStop( fxHandle, true, false )
		}
	)

	//bit overkill, but better safe than sorry when having FX stuck on your screen
	float maxTime = tuning.warpDelayAfterUse + tuning.warpDelayAfterUseAdditionalWhenKnocked + 2.0
	float endTime = Time() + maxTime

	//printf("ALTER - FX WAIT " + Time())
	while( Time() < endTime )
	{
		WaitFrame()
		if ( Bleedout_IsBleedingOut( player ) && player.ContextAction_IsActive() )
			break

		if ( player.IsPhaseShifted() )
			break
	}
	
	#if TRANSPORT_PORTAL_DATAPAD_DEBUG
	printf("ALTER - " + player + " - wait done " + Time())
	#endif
}
#endif


#if CLIENT
void function TransportPortal_CancelUse( )
{
	entity player = GetLocalViewPlayer()
	if ( !IsValid( player ) )
		return

	entity datapadWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( IsValid( datapadWeapon ) && datapadWeapon.GetWeaponClassName() == TRANSPORT_PORTAL_DATAPAD_WEAPON_NAME )
	{
		#if TRANSPORT_PORTAL_DATAPAD_DEBUG
		printf("Alter - " + player + ": TransportPortal_CancelUse - doing cancel")
		#endif
		player.ClientCommand( "invnext" )
	}
}
#endif 