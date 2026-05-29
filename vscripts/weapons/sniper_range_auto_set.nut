global function SniperRangeAutoSet_Init

#if CLIENT
global function SniperRangeAutoSet_Start
global function SniperRangeAutoSet_Stop
#endif

const bool SNIPER_RANGE_DEBUG_DRAW = false


//void function AttemptHawkZeroDistanceSet( entity player )
//{
//	if ( player != GetLocalViewPlayer() || player != GetLocalClientPlayer() )
//		return
//
//	entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
//	if ( !IsValid( activeWeapon ) )
//		return
//
//	if ( activeWeapon.IsWeaponInAds() )
//	{
//		TraceResults viewTrace = GetViewTrace( player )
//		TraceResults tr = TraceLine( player.EyePosition(), player.EyePosition() + 20000.0 * player.GetViewForward(), [ player ], TRACE_MASK_BLOCKLOS )
//
//		float distance = Distance( player.EyePosition(), viewTrace.endPos )
//
//		Remote_ServerCallFunction( "ClientCallback_HawkZeroDistanceSet" , distance)
//
//	}
//}

void function SniperRangeAutoSet_Init( )
{
	//Remote_RegisterServerFunction( "ClientCallback_SniperRangeSet", "float", 0.0, FLT_MAX, 32 )

	#if CLIENT
	//RegisterConCommandTriggeredCallback( "+scriptCommand5", AttemptHawkZeroDistanceSet )

	RegisterSignal( "EndHawkAutoSetThread" ) //Stops the AutoSet thread
	#endif //CLIENT
}

#if CLIENT

void function SniperRangeAutoSet_Start( entity player )
{
	if ( IsValid(player) )
		thread SniperRangeAutoSet_Thread( player )
}

void function SniperRangeAutoSet_Stop( entity player )
{
	if ( IsValid(player) )
		player.Signal( "EndHawkAutoSetThread" )
}

void function SniperRangeAutoSet_Thread( entity player )
{
	if ( player != GetLocalViewPlayer() || player != GetLocalClientPlayer() )
		return

	player.EndSignal( "OnDeath" )
	player.EndSignal( "EndHawkAutoSetThread" )

	if ( IsValid( player ) )
		SetSniperRange( player, 1.0 )

	OnThreadEnd(
		function() : ( player)
		{
			if ( IsValid( player ) )
			{
				SetSniperRange( player, 0.0 )
			}
			#if DEVELOPER
				if ( SNIPER_RANGE_DEBUG_DRAW )
				{
					printt( "HawkAutoSetThread ENDED" )
				}
			#endif //DEV
		}
	)


	float currentViewPlayerTime = 0.0
	entity currentViewPlayer    = null
	while( true )
	{
		entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
		if ( !IsValid( activeWeapon ) )
			break

		entity traceHit    = null // GetTargetUnderCrosshair not in S3
		vector traceEndPos = player.CameraPosition() // GetCrosshairTraceEndPos not in S3
		entity scopeTrackingTarget = SniperRecon_GetBestTarget( player )
		if ( SniperRecon_IsTracking( player ) )
		{
			scopeTrackingTarget = SniperRecon_GetBestTarget( player )
		}

		if ( IsValid( scopeTrackingTarget ) )
		{
			float distance = Distance( player.EyePosition(), scopeTrackingTarget.GetWorldSpaceCenter() )
			//Remote_ServerCallFunction( "ClientCallback_SniperRangeSet", distance )
			SetSniperRange( player, distance )
		}
		else if ( IsValid( traceHit ) &&  traceHit.IsPlayer() )
		{
			float distance = Distance( player.EyePosition(), traceEndPos )
			SetSniperRange( player, distance )

		}
		else
		{
			#if DEVELOPER
				if ( SNIPER_RANGE_DEBUG_DRAW )
				{
					float distance = Distance( player.EyePosition(), traceEndPos )

					DebugDrawLine( player.EyePosition(), traceEndPos, int(COLOR_YELLOW.x), int(COLOR_YELLOW.y), int(COLOR_YELLOW.z), false, 0.3 )
					DebugDrawSphere( traceEndPos, 3, int(COLOR_YELLOW.x), int(COLOR_YELLOW.y), int(COLOR_YELLOW.z), false, 0.3 )

					entity aaTarget = GetAimAssistCurrentTarget()
					if ( IsValid(aaTarget) )
					{
						DebugDrawSphere( aaTarget.GetOrigin(), 3, int(COLOR_MAGENTA.x), int(COLOR_MAGENTA.y), int(COLOR_MAGENTA.z), false, 0.3 )
					}


				}
			#endif
		}
		wait 0.1
	}
}

void function SetSniperRange( entity player, float distance )
{
	if ( !IsValid( player ) )
		return

	entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
	if ( !IsValid( activeWeapon ) )
		return

	float distanceMeters = distance * INCHES_TO_METERS

	#if DEVELOPER
		if ( SNIPER_RANGE_DEBUG_DRAW )
		{
			printt( "Hawk Zero Distance Set " + distanceMeters )
		}
	#endif

	Warning( "SetSniperRangeDotDistance not available in S3\n" )
}

#endif // #if CLIENT

#if SERVER
//void function ClientCallback_SniperRangeSet( entity player, float distance )
//{
//	if ( !IsValid( player ) )
//		return
//
//	entity activeWeapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand )
//	if ( !IsValid( activeWeapon ) )
//		return
//
//	//Remote_ServerCallFunction( "ClientCallback_ToggleHeartbeatSensor" )
//	//TraceResults viewTrace = GetViewTrace( player )
//	//float distance = Distance( player.EyePosition(), viewTrace.endPos )
//	float distanceMeters = distance * INCHES_TO_METERS
//
//	#if DEVELOPER
//		if ( DEBUG_DRAW )
//		{
//			printt( "Hawk Zero Distance Set " + distanceMeters )
//		}
//	#endif
//
//	activeWeapon.SetSniperRangeDotDistance( distanceMeters )
//}
#endif