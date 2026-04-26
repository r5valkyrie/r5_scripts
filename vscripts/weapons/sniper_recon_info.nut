global function SniperRecon_Init
global function SniperRecon_BeginThread
global function SniperRecon_EndThread
global function SniperReconUI_EndThread
global function SniperRecon_GetBestTarget
global function SniperRecon_IsTracking
#if SERVER
//global function SniperRecon_IsPlayerAPotentialTarget
#endif

#if CLIENT
global function CL_SniperRecon_UI_Thread
#endif
const float SNIPER_RECON_MAX_DISTANCE = 400 * METERS_TO_INCHES
const float SNIPER_RECON_MAX_DISTANCE_SQR = SNIPER_RECON_MAX_DISTANCE * SNIPER_RECON_MAX_DISTANCE
const float SNIPER_RECON_TRACKING_FOV = 3.5 //degrees
const float SNIPER_RECON_MAX_DISTANCE_FROM_TRACE_END = 7.5


const bool SNIPER_RECON_DEBUG = false
const bool SNIPER_RECON_PERF = false
const string SNIPER_RECON_TARGET_NETVAR = "sniperReconBestTarget"

const int SNIPER_RECON_TRACE_MASK = TRACE_MASK_VISIBLE//TRACE_MASK_BLOCKLOS //CONTENTS_BLOCKLOS
const int SNIPER_RECON_TRACE_GROUP = TRACE_COLLISION_GROUP_NONE

//Sound
const string SNIPER_RECON_TARGET_ACQUIRED_SOUND = "Vantage_Passive_TargetAquire_1p"
global const string SNIPER_RECON_UI_START_SOUND = "Vantage_Passive_UI_1p"


#if DEVELOPER
int dbg_TraceCount = 0
#endif

enum ePlayerLiveState
{
	None = -1,
	Alive,
	Bleedout,
	CanBeRespawned
}

struct
{
	#if CLIENT
		var scopeRui
	#endif //CLIENT

#if SERVER
	table < entity, array <PotentialTargetData> > ownerTargetPotentialList
	table < entity , entity > ownerBestTarget
#endif //SERVER

} file

void function SniperRecon_Init()
{
	RegisterSignal( "EndSniperRecon" )
	RegisterSignal( "EndSniperRecon_UI" )

	RegisterNetworkedVariableSafe( SNIPER_RECON_TARGET_NETVAR, SNDC_PLAYER_EXCLUSIVE, SNVT_ENTITY )
}

//#if SERVER
//bool function SniperRecon_IsPlayerAPotentialTarget( entity owner , entity player )
//{
//	if ( file.ownerTargetPotentialList[owner].len() > 0 )
//	{
//		foreach( targetData in file.ownerTargetPotentialList[owner])
//		{
//			if ( player == targetData.target )
//			{
//				return true
//			}
//		}
//	}
//	return false
//}
//#endif

entity function SniperRecon_GetBestTarget( entity owner )
{
	if ( IsValid(owner) )
	{
		return owner.GetPlayerNetEnt( SNIPER_RECON_TARGET_NETVAR )
	}
	return null
}

void function SniperRecon_BeginThread( entity player, entity weapon, array <entity> targetExcludeList )
{
	#if SERVER
		thread SniperRecon_Thread( player, weapon, targetExcludeList )
	#endif
}

void function SniperRecon_EndThread( entity player )
{
	player.Signal( "EndSniperRecon" )
}

void function SniperReconUI_EndThread( entity player )
{
	player.Signal( "EndSniperRecon_UI" )
}

bool function SniperRecon_IsTracking( entity owner )
{
	#if CLIENT
	if ( owner == GetLocalViewPlayer() )
	{
		if ( file.scopeRui != null )
			return true
	}
	#endif

	#if SERVER
	if ( owner in file.ownerBestTarget )
		return true
	#endif

	return false
}


#if SERVER
void function SniperRecon_Thread( entity player, entity weapon, array <entity> targetExcludeList )
{
	weapon.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "EndSniperRecon" )

	table<entity, float> enemiesTrackTime
	table<entity, float> enemiesLastTrackedTime

	if ( !( player in file.ownerTargetPotentialList) )
	{
		array<PotentialTargetData> targetDatas
		file.ownerTargetPotentialList[player] <- targetDatas
	}

	OnThreadEnd(
		function() : ( player )
		{
			if(player in file.ownerBestTarget)
				delete file.ownerBestTarget[player]

			player.SetPlayerNetEnt( SNIPER_RECON_TARGET_NETVAR, null )
		}
	)

	while( true )
	{
		#if DEVELOPER
		dbg_TraceCount = 0
		if ( SNIPER_RECON_PERF )
		{
			PerfStart( PerfIndexServer.SniperReconInfo )
		}
		#endif

		file.ownerTargetPotentialList[player].clear()

		array<entity> enemies = GetPlayerArrayOfEnemies( player.GetTeam() )


		float weaponFOV = weapon.GetWeaponZoomFOV()
		int zoomMag = CalcZoomMag( DEFAULT_FOV, weaponFOV )
		float maxRange = GetMaxRange( zoomMag )
		float maxFOV = GetReconInfoFOV( weapon )
		float fovMult = weaponFOV/weapon.GetWeaponSettingFloat(eWeaponVar.zoom_fov)
		maxFOV *= fovMult
		//printt( "SniperInfo Max Range: "+ maxRange * INCHES_TO_METERS )

		array<PotentialTargetData > functionPotentialList
		entity bestTarget  = SelectBestTargetFromArray( player, maxRange, maxFOV,enemies, targetExcludeList, file.ownerTargetPotentialList[player] )

		if ( bestTarget == null )
		{
			//No real gameplay targets
			//Other stuff?
			array<entity> otherObjects

			//Echos
			array<entity> vantageCompanionArray = GetEntArrayByScriptName( VANTAGE_COMPANION_SCRIPTNAME )
			foreach( echo in vantageCompanionArray )
			{
				entity echoOwner = echo.GetBossPlayer()
				if ( IsValid( echoOwner ) )
				{
					bool isEchoPerched = echoOwner.GetPlayerNetInt( VANTAGE_COMPANION_STATE_NETINT ) == eCompanionState.PERCHED
					if ( !isEchoPerched )
						otherObjects.append( echo )
				}
			}

			//Drones
			array<entity> cameras = GetEntArrayByScriptName( CRYPTO_DRONE_SCRIPTNAME )
			otherObjects.extend( cameras )

			//Health drones
			array<entity> healDrones = GetAllHealDrones()
			otherObjects.extend( healDrones )

			//AI Flyers, Prowlers, Spiders?
			array<entity> npcArray = GetNPCArray()
			otherObjects.extend( npcArray )

			array<entity> flyers = GetEntArrayByScriptName( DEATHBOX_FLYER_SCRIPT_NAME )
			otherObjects.extend( flyers )

			//Decoys?
			array<entity> decoyArray = GetPlayerDecoyArray()
			decoyArray.extend( GetEntArrayByScriptName( MIRAGE_DECOY_DROP_SCRIPTNAME ) )
			otherObjects.extend( decoyArray )

			bestTarget  = SelectBestTargetFromArray( player, maxRange, maxFOV, otherObjects, targetExcludeList, functionPotentialList )

		}

		file.ownerBestTarget[player] <- bestTarget
		player.SetPlayerNetEnt( SNIPER_RECON_TARGET_NETVAR, bestTarget )

		#if DEVELOPER
		if ( SNIPER_RECON_PERF )
		{
			DebugDrawScreenText( 0.8, 0.6, "num Traces: " + dbg_TraceCount )
			PerfEnd( PerfIndexServer.SniperReconInfo )
			PerfDump()
		}
		#endif
		WaitFrame()
	}
}

float function GetMaxRange( int zoomMag )
{
	float range = 0
	switch( zoomMag )
	{
		case 1:
			range = 100 * METERS_TO_INCHES
			break
		case 2:
			range = 175 * METERS_TO_INCHES
			break
		case 3:
			range = 200 * METERS_TO_INCHES
			break
		case 4:
			range = 250 * METERS_TO_INCHES
			break
		case 5:
		case 6:
			range = 350 * METERS_TO_INCHES
			break
		case 7:
		case 8:
			range = 450 * METERS_TO_INCHES
			break
		case 9:
		case 10:
			range = 500 * METERS_TO_INCHES
			break
		default:
		{
			#if DEVELOPER
				Assert( false, "SniperReconInfo: No max range specified for zoomMagnitude of " + zoomMag )
			#endif
			range = 200 * METERS_TO_INCHES
			break
		}
	}
	return range
}

entity function SelectBestTargetFromArray( entity player, float maxRange, float maxFOV,  array<entity> potentialTargets, array<entity> targetExcludeList, array<PotentialTargetData> arrayToPopulate )
{
	float MAX_RANGE_SQR = maxRange * maxRange
	foreach ( target in potentialTargets )
	{
		bool doesShare = target.DoesShareRealms( player )
		if ( !doesShare )
			continue

		if ( !IsAlive( target ) && target.GetScriptName() != MIRAGE_DECOY_DROP_SCRIPTNAME )
			continue

		if ( target.IsPhaseShifted() )
			continue

		if ( target.IsCloaked(false) )
			continue

		if ( targetExcludeList.contains(target) )
			continue

		bool skipEyeTest = false
		if ( IsPlayerInCryptoDroneCameraView(target) )
		{
			//If this is a Crypto and he is in his camera, the "eye" position is at the camera
			skipEyeTest = true
		}

		vector playerToTargetCenter = target.GetWorldSpaceCenter() - player.EyePosition()

		float dotToTargetCenter = DotProduct( Normalize(playerToTargetCenter), player.GetViewVector() )
		//Dot test

		float roughMinDot = DOT_45DEGREE //deg_cos( SNIPER_RECON_TRACKING_FOV*4.0 )

		if ( dotToTargetCenter < roughMinDot )
			continue

		float distanceToTargetSqr = LengthSqr( playerToTargetCenter )
		if ( distanceToTargetSqr > MAX_RANGE_SQR )
		{
			if ( SNIPER_RECON_DEBUG )
			{
				DebugDrawText(  target.GetWorldSpaceCenter(), "Out of Range", true, 0.1 )
				DebugDrawSphere( target.GetWorldSpaceCenter(), 3, COLOR_YELLOW, true, 0.1 )
			}
			continue
		}



		bool targetInCone           = false
		float bestDot               = dotToTargetCenter
		bool canSeeOrigin           = false
		bool canSeeWorldSpaceCenter = false
		bool canSeeEyes             = false
		float minDot                = deg_cos( maxFOV )
		if ( dotToTargetCenter >= minDot )
		{
			targetInCone           = true
			canSeeWorldSpaceCenter = true
		}

		if ( !targetInCone ) //If I cant see then check the origin
		{
			vector playerToTarget = Normalize( target.GetOrigin() - player.EyePosition() )
			float dotToTarget = DotProduct( playerToTarget, player.GetViewVector() )
			if ( dotToTarget >= minDot )
			{
				targetInCone = true
				canSeeOrigin = true
				bestDot      = dotToTarget
			}
		}
		//
		if ( !targetInCone && !skipEyeTest ) //If I cant see then check the eyes
		{
			vector playerToTargetEye = Normalize( target.EyePosition() - player.EyePosition() )
			float dotToTargetEye = DotProduct( playerToTargetEye, player.GetViewVector() )
			if ( dotToTargetEye >= minDot )
			{

				targetInCone = true
				canSeeEyes   = true
				bestDot      = dotToTargetEye
			}
		}

		if ( !targetInCone )
		{
			if ( SNIPER_RECON_DEBUG )
			{
				DebugDrawSphere( target.GetWorldSpaceCenter(), 3, COLOR_RED, true, 0.1 )
				//DebugDrawText( target.GetWorldSpaceCenter(), "center", true, 0.1 )
				DebugDrawSphere( target.EyePosition(), 3, COLOR_RED, true, 0.1 )
				//DebugDrawText( target.EyePosition(), "eye", true, 0.1 )
				DebugDrawSphere( target.GetOrigin(), 3, COLOR_RED, true, 0.1 )
				//DebugDrawText( target.GetOrigin(), "orig", true, 0.1 )
			}
			continue
		}


		if ( targetInCone )
		{
			if ( SNIPER_RECON_DEBUG )
			{
				vector posToDraw = target.GetWorldSpaceCenter()
				if ( canSeeWorldSpaceCenter )
				{
					posToDraw = target.GetWorldSpaceCenter()
				}
				else if ( canSeeEyes )
				{
					posToDraw = target.EyePosition()
				}
				else if ( canSeeOrigin )
				{
					posToDraw = target.GetOrigin()
				}

				DebugDrawSphere( posToDraw, 3, COLOR_YELLOW, true, 0.1 )

				DebugDrawText( target.GetWorldSpaceCenter(), ""+bestDot , true, 0.1 )
			}


			PotentialTargetData targetData
			targetData.score = bestDot
			targetData.target = target

			arrayToPopulate.append(targetData)

		}


	}

	entity bestTarget = null
	if ( arrayToPopulate.len() > 0 )
	{
		//Step 2 will be to sort this list and then only do raycasts until we find one we can see
		//file.ownerTargetPotentialList[player].sort( SortByScore )
		arrayToPopulate.sort( SortByScore )

		//We have a  potential target!
		float bestScore = 0
		foreach( targetData in arrayToPopulate )
		{
			if( IsValid( targetData.target ) && FerroWall_BlockScan( player.EyePosition(), targetData.target.EyePosition() ) &&FerroWall_BlockScan( player.EyePosition(), targetData.target.GetWorldSpaceCenter() ) )
				continue

			#if DEVELOPER
			dbg_TraceCount++
			#endif

			int traceMask = targetData.target.IsPlayer() && MountedTurretPlaceable_IsUsingMountedTurret( targetData.target ) ? TRACE_MASK_SHOT : SNIPER_RECON_TRACE_MASK
			array<entity> ignoreEnts = [ player ]

			TraceResults trace = TraceLine( player.EyePosition(), targetData.target.GetWorldSpaceCenter(), ignoreEnts, traceMask, SNIPER_RECON_TRACE_GROUP )
			if ( trace.fraction >= 1.0  )
			{
				bestScore = targetData.score
				bestTarget = targetData.target
				if ( SNIPER_RECON_DEBUG )
				{
					DebugDrawSphere( trace.endPos, 5, COLOR_GREEN, true, 0.1 )
				}
			}
			else if ( SNIPER_RECON_DEBUG )
			{
				DebugDrawSphere( targetData.target.GetWorldSpaceCenter(), 5, COLOR_RED, true, 0.1 )
				DebugDrawSphere( trace.endPos, 3, COLOR_PINK, true, 0.1 )
			}

			if ( bestTarget == null ) //If I cant see then check the origin
			{
				#if DEVELOPER
					dbg_TraceCount++
				#endif
				trace = TraceLine( player.EyePosition(), targetData.target.GetOrigin(), ignoreEnts, traceMask, SNIPER_RECON_TRACE_GROUP )
				if ( trace.fraction >= 1.0)
				{
					bestScore = targetData.score
					bestTarget = targetData.target
					if ( SNIPER_RECON_DEBUG )
					{
						DebugDrawSphere( trace.endPos, 5, COLOR_GREEN, true, 0.1 )
					}
				}
				else if ( SNIPER_RECON_DEBUG )
				{
					DebugDrawSphere( targetData.target.GetOrigin(), 5, COLOR_RED, true, 0.1 )
					DebugDrawSphere( trace.endPos, 3, COLOR_PINK, true, 0.1 )
				}
			}

			bool skipEyeTest = false
			if ( IsPlayerInCryptoDroneCameraView(targetData.target) )
			{
				//If this is a Crypto and he is in his camera, the "eye" position is at the camera
				skipEyeTest = true
			}
			if ( bestTarget == null && !skipEyeTest ) //If I cant see then check the eyes
			{
				#if DEVELOPER
					dbg_TraceCount++
				#endif
				trace = TraceLine( player.EyePosition(), targetData.target.EyePosition(), ignoreEnts, traceMask, SNIPER_RECON_TRACE_GROUP )
				if ( trace.fraction >= 1.0 )
				{
					bestScore = targetData.score
					bestTarget = targetData.target
					if ( SNIPER_RECON_DEBUG )
					{
						DebugDrawSphere( trace.endPos, 5, COLOR_GREEN, true, 0.1 )
					}
				}
				else if ( SNIPER_RECON_DEBUG )
				{
					DebugDrawSphere( targetData.target.EyePosition(), 5, COLOR_RED, true, 0.1 )
					DebugDrawSphere( trace.endPos, 3, COLOR_PINK, true, 0.1 )
				}
			}

			if ( bestTarget != null )
				break

			if ( SNIPER_RECON_DEBUG )
			{
				DebugDrawText(  targetData.target.GetOrigin(), "No Trace", false, 0.1   )
			}

		}
	}

	return bestTarget
}

#endif

float function GetReconInfoFOV( entity weapon )
{
	if ( !IsValid( weapon ) )
		return 0.0

	if ( (weapon.GetWeaponTypeFlags() & WPT_ULTIMATE) > 0 ||
					(weapon.GetWeaponTypeFlags() & WPT_VIEWHANDS ) > 0 )
		return 8.0

	if ( weapon.GetWeaponClassName() == KRABER_WEAPON_NAME )
		return 4.5

	string opticAttachment = GetInstalledWeaponAttachmentForPoint( weapon, "sight" )

	float reconInfoFOV = 0.0
	switch ( opticAttachment )
	{
		case "optic_cq_hcog_bruiser":
			reconInfoFOV = 6.0
			break
		case "optic_ranged_hcog":
			reconInfoFOV = 4.0
			break
		case "optic_ranged_aog_variable":
			reconInfoFOV = 7.5
			break
		case "optic_sniper":
			reconInfoFOV = 4.5
			break
		case "optic_sniper_variable":
		case "optic_sniper_threat":
			reconInfoFOV = 6.0
			break
		default:
			reconInfoFOV = 8.0
			break
	}

	return reconInfoFOV
}

#if CLIENT
void function CL_SniperRecon_UI_Thread( entity owner )
{
	if ( owner != GetLocalViewPlayer() )
		return

	owner.Signal( "EndSniperRecon_UI" ) // clean up any exisiting just in case
	owner.EndSignal( "OnDestroy" )
	owner.EndSignal( "OnDeath" )
	owner.EndSignal( "EndSniperRecon_UI" )

	file.scopeRui = CreateFullscreenRui( $"ui/vantage_sniper_info.rpak" )
	bool playedStartSound = false


	OnThreadEnd(
		function() : ( owner )
		{
			if ( file.scopeRui != null )
			{
				RuiSetGameTime( file.scopeRui, "endTime", Time() )
				file.scopeRui = null
			}
		}
	)

	entity previousTarget = null
	while( !GetPlayerIsEmoting( owner )
			&& !owner.Player_IsSkydiving()
			&& !owner.Player_IsSkywardLaunching()
	)
	{
		if ( !playedStartSound && owner.GetZoomFrac() > 0.8 )
		{
			EmitSoundOnEntity( owner, SNIPER_RECON_UI_START_SOUND )
			playedStartSound = true
		}
		//float cornerScale = SNIPER_RECON_TRACKING_FOV/owner.GetFOV()
		entity activeWeapon = owner.GetActiveWeapon( eActiveInventorySlot.mainHand )
		if ( !activeWeapon )
			continue

		float reconInfoFOV = GetReconInfoFOV( activeWeapon )

		float outerCornerScale = reconInfoFOV/activeWeapon.GetWeaponSettingFloat(eWeaponVar.zoom_fov)
		float innerCornerScale = 5.0/ owner.GetFOV()

		float fireRate = activeWeapon.GetWeaponSettingFloat( eWeaponVar.fire_rate )
		float weaponFireDelay = 1.0

		if ( fireRate > 0 )
		{
			weaponFireDelay = 1.0 / fireRate
		}
		//0.3 + rate of fire delay with the first 1/2 of that being turned off completely (in RUI) feels pretty good.
		weaponFireDelay += 0.3
		RuiSetFloat( file.scopeRui, "weaponFireDelay", weaponFireDelay )

		RuiTrackGameTime( file.scopeRui, "lastFireTime", activeWeapon, RUI_TRACK_WEAPON_LAST_PRIMARY_ATTACK_TIME )
		RuiSetFloat( file.scopeRui, "outerCornerScale", outerCornerScale )

		RuiSetFloat( file.scopeRui, "innerCornerScale", innerCornerScale )

		RuiSetFloat( file.scopeRui, "range", SNIPER_RECON_MAX_DISTANCE )

		float distanceToTarget = Distance( owner.EyePosition(), owner.GetCrosshairTraceEndPos() )
		RuiSetFloat( file.scopeRui, "crossDist", distanceToTarget )
		RuiSetBool( file.scopeRui, "outOfRange", false )

		if ( IsValid( activeWeapon ) )
			RuiSetBool( file.scopeRui, "isWeaponMelee", DoesWeaponTriggerMeleeAttack( activeWeapon ) )

		bool isSilenced = StatusEffect_HasSeverity( owner, eStatusEffect.silenced )
		bool isValidGameState = ( GetGameState() >= eGameState.Playing && GetGameState() < eGameState.Resolution ) || ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_FIRING_RANGE ) )
		bool isADS = owner.GetZoomFrac() > 0.99
		RuiSetBool( file.scopeRui, "visible", !isSilenced && isValidGameState && isADS )
		entity bestScopeTarget = owner.GetPlayerNetEnt( SNIPER_RECON_TARGET_NETVAR )

		//Validate that our best scope target is actually within the confines of the RUI square
		if ( IsValid( bestScopeTarget ) )
		{
			int attachID = bestScopeTarget.LookupAttachment( "CHESTFOCUS" )
			//validate our target has a "CHESTFOCUS" to lookup.
			vector bestScopeTargetLookupPosition = attachID != 0 ? bestScopeTarget.GetAttachmentOrigin( attachID ) : bestScopeTarget.GetWorldSpaceCenter()
			ScreenSpaceData screenSpaceData = GetScreenSpaceData( owner, bestScopeTargetLookupPosition )
			int screenWidth          = GetScreenSize().width

			int xScreenMid = screenWidth / 2
			int allowedDistFromCenter = int( xScreenMid * outerCornerScale )

			//Target screen space outside of the UI square so invalidate this target.
			if ( ( abs( screenSpaceData.deltaCenterX ) > allowedDistFromCenter ) || ( abs( screenSpaceData.deltaCenterY ) > allowedDistFromCenter ) )
			{
				bestScopeTarget = null
			}
		}

		if ( SNIPER_RECON_DEBUG )
		{
			if ( IsValid(bestScopeTarget) )
			{
				DebugDrawSphere( bestScopeTarget.GetWorldSpaceCenter(), 10, <0, 100, 255>, true, 0.1 )


				entity aaTarget = GetAimAssistCurrentTarget()
				if ( IsValid(aaTarget) && aaTarget != bestScopeTarget )
				{
					DebugDrawSphere( aaTarget.GetWorldSpaceCenter(), 15, COLOR_RED, true, 0.1 )
				}
			}
		}

		entity vantageTacWeapon = owner.GetOffhandWeapon( OFFHAND_TACTICAL )
		if ( IsValid( vantageTacWeapon) )
		{
			bool hasAmmo = vantageTacWeapon.GetWeaponPrimaryClipCount() >= vantageTacWeapon.GetAmmoPerShot()
			RuiSetBool( file.scopeRui, "hasAmmo", hasAmmo )
		}

		RuiSetBool( file.scopeRui, "hasTarget", IsValid(bestScopeTarget) )

		RuiSetString( file.scopeRui, "targetClass", "" )
		//printt( "hasAmmo " + hasAmmo )
		if ( IsValid(bestScopeTarget) )
		{
			if ( bestScopeTarget.IsPlayer() )
			{
				bool showTargetClass = GetCurrentPlaylistVarBool( "hawk_scope_show_targetClass", true )
				if ( showTargetClass )
				{
					ItemFlavor character = LoadoutSlot_GetItemFlavor( ToEHI( bestScopeTarget ), Loadout_Character() )
					string name = Localize( ItemFlavor_GetShortName( character ) )
					RuiSetString( file.scopeRui, "targetClass", name )
				}

				//For team info
				array<entity> teamPlayers = GetPlayerArrayOfTeam( bestScopeTarget.GetTeam() )
				array<int> playerStates = [ ePlayerLiveState.None,
											ePlayerLiveState.None,
											ePlayerLiveState.None,
											ePlayerLiveState.None ]

				array<int> playerArmorTierStates = [ 0, 0, 0, 0 ]

				int thisPlayerIndex = 1
				foreach (teammate in teamPlayers )
				{
					bool isAlive = IsAlive( teammate )
					bool isBleedingOut = Bleedout_IsBleedingOut( teammate )

					int playerArmorTier = EquipmentSlot_GetEquipmentTier( teammate, "armor" )
					int playerState = ePlayerLiveState.None
					if ( isAlive )
					{
						if ( isBleedingOut )
							playerState = ePlayerLiveState.Bleedout
						else
							playerState = ePlayerLiveState.Alive
					}
					else
					{
						if ( PlayerIsMarkedAsCanBeRespawned( teammate ) )
						{
							playerState = ePlayerLiveState.CanBeRespawned
						}
					}

					if ( teammate == bestScopeTarget )
					{
						playerStates[0] = playerState
						playerArmorTierStates[0] = playerArmorTier
					}
					else
					{
						if ( playerState != ePlayerLiveState.None )
						{
							if ( thisPlayerIndex <= 3 )
							{
								playerStates[thisPlayerIndex] = playerState
								playerArmorTierStates[thisPlayerIndex] = playerArmorTier
							}
							thisPlayerIndex++
						}
					}
				}

				for( int i = 0; i < 4; ++i )
				{
					bool showArmorTier = GetCurrentPlaylistVarBool( "hawk_scope_show_armorTier", true )
					if ( showArmorTier )
					{
						int playerArmorTierState = 0
						if( playerStates.len() > i )
							playerArmorTierState = playerArmorTierStates[i]

						RuiSetInt( file.scopeRui, "player" + i + "ArmorTier", playerArmorTierState )
					}
				}
			}
			else
			{
				bool showTargetClass = GetCurrentPlaylistVarBool( "hawk_scope_show_targetClass", true )
				if ( showTargetClass )
				{
					string displayName =  GetDisplayName( bestScopeTarget )
					RuiSetString( file.scopeRui, "targetClass", Localize( displayName ) )
				}
				RuiSetInt( file.scopeRui, "player0ArmorTier", 0 )
				RuiSetInt( file.scopeRui, "player1ArmorTier", 0 )
				RuiSetInt( file.scopeRui, "player2ArmorTier", 0 )
				RuiSetInt( file.scopeRui, "player3ArmorTier", 0 )
			}


			//For range info
			int attachment = bestScopeTarget.LookupAttachment( "CHESTFOCUS" )
			if ( attachment <= 0 )
				attachment = bestScopeTarget.LookupAttachment( "REF" )

			RuiTrackFloat3( file.scopeRui, "targetPos", bestScopeTarget, RUI_TRACK_POINT_FOLLOW, attachment )
			RuiSetBool( file.scopeRui, "targetChanged", bestScopeTarget != previousTarget )
		}

		if ( bestScopeTarget != previousTarget )
		{
			if ( IsValid(bestScopeTarget) )
				EmitSoundOnEntity( owner, SNIPER_RECON_TARGET_ACQUIRED_SOUND )

			previousTarget = bestScopeTarget
		}

		WaitFrame()
	}
}

string function GetDisplayName( entity displayObject )
{
	string displayName = displayObject.GetTitleForUI()
	string scriptName = displayObject.GetScriptName()
	if ( displayName == "" )
	{
		bool notFound     = false
		switch( scriptName )
		{
			case CRYPTO_DRONE_SCRIPTNAME:
				displayName = "#PROMPT_PING_CRYPTO_DRONE_SHORT"
				break

			case DEATHBOX_FLYER_SCRIPT_NAME:
				displayName = "#PROMPT_PING_FLYER_SHORT"
				break
			case FIRING_RANGE_DUMMIE_SCRIPT_NAME:
			case FIRING_RANGE_COMBAT_DUMMIE_SCRIPT_NAME:
				displayName = "#SURVIVAL_TRAINING_DUMMIE_NAME"
				break

			case DECOY_SCRIPTNAME:
			case CONTROLLED_DECOY_SCRIPTNAME:
			case MIRAGE_DECOY_DROP_SCRIPTNAME:
				displayName = "#DECOY"
				break

			default:
				notFound = true
				displayName = "#HUD_UNKNOWN"
				#if DEVELOPER
				printt( "Unknown display name for scriptname: " + scriptName + " for entity: " + displayObject )
				#endif
		}
	}

	#if DEVELOPER
	if ( displayName == "" )
	{
		printt( "Unknown display name for entity: " + displayObject + " ,scriptname: "  + scriptName )
	}
	#endif

	return displayName
}

#endif




