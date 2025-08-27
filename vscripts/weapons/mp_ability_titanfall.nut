global function OnWeaponPrimaryAttack_call_for_titan
global function OnWeaponDeactivate_titanfall
global function OnWeaponActivate_titanfall
global function ShTitanfallAbility_Init

struct
{
#if CLIENT
	bool TitanDeployed
#endif
} file

struct TitanPlacementInfo
{
	vector origin
	vector angles
	vector surfaceNormal
	bool failed
	bool hide
}


void function ShTitanfallAbility_Init()
{
	#if CLIENT
		StatusEffect_RegisterEnabledCallback( eStatusEffect.placing_titan, OnBeginPlacingCarePackage )
		StatusEffect_RegisterDisabledCallback( eStatusEffect.placing_titan, OnEndPlacingCarePackage )
	#endif

	/*#if SERVER
		AddCallback_OnClientConnected( MpAbilityCarePackage_ClientConnected )
	#endif*/
}

var function OnWeaponPrimaryAttack_call_for_titan( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetWeaponOwner()

	if( !IsValid( ownerPlayer ) || !ownerPlayer.IsPlayer() )
		return 0

	if ( ownerPlayer.IsPhaseShifted() )
		return 0

	TitanPlacementInfo placementInfo = GetTitanPlacementInfo( ownerPlayer )

	if ( placementInfo.failed )
		return 0

	#if SERVER
		vector origin = placementInfo.origin
		vector angles = placementInfo.angles

        //Start the ground circle particle
		//entity fx = StartParticleEffectInWorld_ReturnEntity(GetParticleSystemIndex( DROPPOD_SPAWN_FX ), origin, angles)
		//fx.RemoveFromAllRealms()
		//fx.AddToOtherEntitysRealms( ownerPlayer )

		thread CallBT( origin, angles )

		//PlayBattleChatterLineToSpeakerAndTeam( ownerPlayer, "bc_super" )

		PlayerUsedOffhand( ownerPlayer, weapon, true, null, {pos = origin} )
	#else
		PlayerUsedOffhand( ownerPlayer, weapon )
	#endif

	int ammoReq = weapon.GetAmmoPerShot()
	return ammoReq
}

TitanPlacementInfo function GetTitanPlacementInfo( entity player )
{
	const MAX_UP_ANGLE = -20
	const MAX_DOWN_ANGLE = 75
	const VELOCITY_MULTIPLIER = 1800

		const MAX_UP_ANGLE_FAST = -10
		const MAX_DOWN_ANGLE_FAST = 70
		const VELOCITY_MULTIPLIER_FAST = 1600
		const TRACE_TIME_FAST = 1.6

	const TRACE_TIME = 2.25
	const MIN_DIST_SQR = 72 * 72
	const PARENT_VELOCITY = <0,0,0>
	const SIGHT_TRACE_OFFSET = <0,0,48>

	bool failed = false
	bool hide = false

	TitanPlacementInfo placementInfo
	vector startPos    = player.EyePosition()
	vector flatForward = FlattenVector( player.GetViewVector() )
	vector placementAngles = ClampAngles( VectorToAngles( flatForward ) + <0,180,0> )

	vector eyeAngles = player.EyeAngles()
	GravityLandData landData
			float pitch = GraphCapped( eyeAngles.x, MAX_UP_ANGLE, MAX_DOWN_ANGLE, 0, 1 )
			pitch = PlacementEasing( pitch )

			float clampedPitch = GraphCapped( pitch, 0, 1, MAX_UP_ANGLE, MAX_DOWN_ANGLE )
			vector clampedEyeAngles = < clampedPitch, eyeAngles.y, eyeAngles.z >
			vector objectVelocity = AnglesToForward( clampedEyeAngles ) * VELOCITY_MULTIPLIER

			landData = GetGravityLandData( startPos, PARENT_VELOCITY, objectVelocity, TRACE_TIME, false )

	TraceResults traceResults = landData.traceResults

	vector origin = traceResults.endPos

	if ( !IsValid( traceResults.hitEnt ) )
	{
		origin = landData.points.top()
		failed = true
	}

	if ( DistanceSqr( player.GetOrigin(), origin ) < MIN_DIST_SQR )
	{
		failed = true
		hide = true
	}

	const bool IsCarePackage = true
	if ( !failed && !VerifyAirdropPoint( origin, placementAngles.y, IsCarePackage, player ) )
	{
		failed = true
	}

	placementInfo.origin = origin
	placementInfo.angles = placementAngles
	placementInfo.surfaceNormal = traceResults.surfaceNormal
	placementInfo.failed = failed
	placementInfo.hide = hide
	return placementInfo
}


#if SERVER
void function CallBT( vector origin, vector angles)
{
	DisablePrecacheErrors()
	wait 0.2
	entity player = GetPlayerArray()[ 0 ]

	entity pet_titan = player.GetPetTitan()
	if ( IsValid(pet_titan) )
		pet_titan.SetHealth(0)

	//TitanLoadoutDef loadout = GetTitanLoadoutForCurrentMap()
	entity npc = CreateNPCTitanFromSettings($"settings/player/mp/titan_survival_buddy.rpak",player.GetTeam(),origin, angles)//CreateAutoTitanForPlayer_FromTitanLoadout( player, loadout, origin, angles )

	SetSpawnOption_AISettings( npc, "npc_titan_buddy" )
	npc.SetCollisionAllowed( false )//TODO: Get rid of this when collision is fixed, it causes crash. - Kral

	//DispatchSpawn( npc )
	
	npc.kv.solid = 8

	npc.GiveWeapon("mp_titanweapon_xo16_shorty", WEAPON_INVENTORY_SLOT_ANY)

	//SetPlayerPetTitan( player, npc )
	SetupAutoTitan( npc, player )

	thread NPCTitanHotdrops( npc, false )
		
	//CodeCallback_EmbarkTitan( player, npc )
}
#endif

void function OnWeaponActivate_titanfall( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if CLIENT
		SetTitanDeployed( false )
		if ( !InPrediction() ) //Stopgap fix for Bug 146443
			return
	#endif


	#if SERVER
		StatusEffect_AddEndless( ownerPlayer, eStatusEffect.placing_titan, 1.0 )
		//ownerPlayer.Server_TurnOffhandWeaponsDisabledOn()
	#endif
}


void function OnWeaponDeactivate_titanfall( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if CLIENT
		if ( !InPrediction() ) //Stopgap fix for Bug 146443
			return
	#endif

	#if SERVER
		StatusEffect_StopAllOfType( ownerPlayer, eStatusEffect.placing_titan )
		//ownerPlayer.Server_TurnOffhandWeaponsDisabledOff()
	#endif
}

#if CLIENT
void function OnBeginPlacingCarePackage( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return

	thread DeployableCarePackagePlacement( player, $"mdl/titans/buddy/titan_buddy.rmdl" )
}

void function OnEndPlacingCarePackage( entity player, int statusEffect, bool actuallyChanged )
{
	if ( player != GetLocalViewPlayer() )
		return

	player.Signal( "DeployableCarePackagePlacement" )
}

void function DeployableCarePackagePlacement( entity player, asset carePackageModel )
{
	player.EndSignal( "DeployableCarePackagePlacement" )

	entity carePackage = CreateCarePackageProxy( $"mdl/titans/buddy/titan_buddy.rmdl"  )
	carePackage.EnableRenderAlways()
	carePackage.Show()

	DeployableModelHighlight( carePackage )

	OnThreadEnd(
		function() : ( carePackage )
		{
			if ( IsValid( carePackage ) )
				thread DestroyCarePackageProxy( carePackage )

			HidePlayerHint( "CALL IN TITAN" )
		}
	)

	AddPlayerHint( 3.0, 0.25, $"", "CALL IN TITAN" )

	while ( true )
	{
		TitanPlacementInfo placementInfo = GetTitanPlacementInfo( player )

		carePackage.SetOrigin( placementInfo.origin )
		carePackage.SetAngles( placementInfo.angles )

		if ( !placementInfo.failed )
			DeployableModelHighlight( carePackage )
		else
			DeployableModelInvalidHighlight( carePackage )

		if ( placementInfo.hide )
			carePackage.Hide()
		else
			carePackage.Show()

		WaitFrame()
	}
}

entity function CreateCarePackageProxy( asset modelName ) //TODO: Needs work if we do different turret models
{
	entity carePackage = CreateClientSidePropDynamic( <0,0,0>, <0,0,0>, modelName )
	carePackage.kv.renderamt = 255
	carePackage.kv.rendermode = 3
	carePackage.kv.rendercolor = "255 255 255 255"

	carePackage.Anim_Play( "at_MP_embark_idle" )
	carePackage.Hide()

	return carePackage
}

void function DestroyCarePackageProxy( entity ent )
{
	Assert( IsNewThread(), "Must be threaded off" )
	ent.EndSignal( "OnDestroy" )

	if ( file.TitanDeployed )
		wait 0.225

	ent.Destroy()
}

void function SetTitanDeployed( bool state )
{
	file.TitanDeployed = state
}
#endif