global function MpWeaponAshDataknife_Init

global function OnWeaponActivate_ability_ash_dataknife
global function OnWeaponDeactivate_ability_ash_dataknife
global function OnWeaponPrimaryAttack_ability_ash_dataknife
global function OnWeaponAttemptOffhandSwitch_ability_ash_dataknife

global function DeathboxNetwork_CanPlayerUse
global function DeathboxNetwork_GetDeathboxAge

#if SERVER
global function DeathboxNetwork_ClientToServer_TryActivate
global function DeathboxNetwork_ClientToServer_PingDeathboxFromMap

global function DEV_TestAshDeathbox                            // Should only be used in dev, but you can't call remote functions in DEV blocks
                        
                                             
      
#endif

#if CLIENT
global function DeathboxNetwork_TrackBoxTargets
global function DeathboxNetwork_UntrackBoxTargets
global function DeathboxNetwork_UntrackIfTracking

                    
global function DeathboxNetwork_ServerToClient_TrackTargetOverTime
      

global function DeathboxNetwork_ServerToClient_ForceUsable  // Should only be used in Dev
#endif

#if DEV
bool devForceDeathboxUsable = false
#endif

global const string  ASH_DATAKNIFE_WEAPON_NAME = "mp_weapon_ash_dataknife"
const string FUNCNAME_TryActivate = "DeathboxNetwork_ClientToServer_TryActivate"
const string FUNCNAME_DevForceUsable = "DeathboxNetwork_ServerToClient_ForceUsable"
const string FUNCNAME_PingDeathboxFromMap = "DeathboxNetwork_ClientToServer_PingDeathboxFromMap"

const string ABILITY_USED_MOD = "ability_used_mod"

const asset DEATHBOX_USED_FX = $"P_ash_passive_onBox"
const asset DEATHBOX_KNIFE_FX = $"P_ash_passive_impact"

const float ASH_DATAKNIFE_MAP_WAYPOINT_DURATION = 180.0
const float ASH_DATAKNIFE_ENEMY_KILL_PING_RANGE_SQR_DEFAULT = 2000.0 * 2000.0
const float ASH_DATAKNIFE_ALLY_DEATH_PING_RANGE_SQR_DEFAULT = 2000.0 * 2000.0
const float ASH_DATAKNIFE_MAP_ICON_DELAY_DEFAULT = 0.0

const int INDEX_WaypointEntity_Deathbox = 0
const int INDEX_WaypointEntity_Attacker = 1
const int INDEX_WaypointInt_AttackerCount = 0
const int INDEX_WaypointInt_UNUSED = 1
const int INDEX_WaypointInt_DeathboxSquadID = 2
const int INDEX_WaypointFloat_CreatedTime = 0

const bool DEBUG_USE_NEW_ANIMS = true


struct deathboxInfo
{
	entity waypoint
	int    attackerTeam
	int    boxOwnerTeam        // Need to save this off, deathbox.GetTeam() gets set to 0 once the player can no longer be revived
	float  createdTime
	#if CLIENT
		bool hasIconExpired
	#endif
}

struct
{
	table< entity, deathboxInfo >                    deathboxInfoTable
	#if SERVER
		table< entity, float >  VO_AllyDiedDebounceTime
		table< entity, entity > ashDeathboxToUse

		float ping_EnemyKill_RangeSqr
		float ping_AllyDeath_RangeSqr
	#elseif CLIENT
		entity deathboxBeingUsed

		entity trackedDeathbox
		var    trackedDeathboxRui
		bool   isRefreshingMapIcons
		entity fullMapHighlightedDeathbox
		var    fullMapHightlightTooltipRui

		float  mapIconAppearanceDelay

                          
                                    
        
	#endif
} file


void function MpWeaponAshDataknife_Init()
{
	PrecacheWeapon( ASH_DATAKNIFE_WEAPON_NAME )
	PrecacheParticleSystem( DEATHBOX_USED_FX )
	PrecacheParticleSystem( DEATHBOX_KNIFE_FX )

                         
                                                                  
       

	if ( UseAlternatePassiveActivation() )
	{
		#if SERVER
			file.ping_EnemyKill_RangeSqr = GetCurrentPlaylistVarFloat( "ash_passive_ping_enemy_kill_range_sqr", ASH_DATAKNIFE_ENEMY_KILL_PING_RANGE_SQR_DEFAULT )
			file.ping_AllyDeath_RangeSqr = GetCurrentPlaylistVarFloat( "ash_passive_ping_ally_death_range_sqr", ASH_DATAKNIFE_ALLY_DEATH_PING_RANGE_SQR_DEFAULT )
			AddCallback_OnPlayerKilled( OnPlayerKilled )
		#endif
	}
	else
	{
		Remote_RegisterServerFunction( FUNCNAME_TryActivate, "typed_entity", "prop_death_box" )
		Remote_RegisterServerFunction( FUNCNAME_PingDeathboxFromMap, "typed_entity", "prop_death_box" )
		Remote_RegisterClientFunction( FUNCNAME_DevForceUsable )
		                    
		Remote_RegisterClientFunction( "DeathboxNetwork_ServerToClient_TrackTargetOverTime", "entity", "int", 0, ABSOLUTE_MAX_TEAMS )
        

		#if SERVER
			AddCallback_OnDeathBoxSpawned( OnDeathboxSpawned )
			AddCallback_OnPassiveChanged( ePassives.PAS_ASH, OnPassiveChanged )
			AddCallback_OnGiveOffhandEquipment( ASH_DATAKNIFE_WEAPON_NAME, OnGiveDataKnife )
			AddCallback_OnTakeOffhandEquipment( ASH_DATAKNIFE_WEAPON_NAME, OnTakeDataKnife )
		#elseif CLIENT
			RegisterConCommandTriggeredCallback( "+scriptCommand5", OnCharacterButtonPressed )
			AddCallback_OnPassiveChanged( ePassives.PAS_ASH, OnPassiveChanged )
			AddCreateCallback( PLAYER_WAYPOINT_CLASSNAME, OnWaypointCreated )

                           
                                                                    
                                                            
         

			file.mapIconAppearanceDelay = GetCurrentPlaylistVarFloat( "ash_passive_map_icon_delay", ASH_DATAKNIFE_MAP_ICON_DELAY_DEFAULT )
		#endif
	}
}

void function OnPassiveChanged( entity player, int passive, bool didHave, bool nowHas )
{
	#if CLIENT
		if ( !IsValid( GetLocalClientPlayer() ) || player != GetLocalClientPlayer() )
			return
	#endif

	if ( didHave && !nowHas )
	{
		#if SERVER
			TakePlayerOffhandEquipment( player, ASH_DATAKNIFE_WEAPON_NAME )

                           
                                                                    
     
                                                             
                                                              
     
         
		#elseif CLIENT
			// OnPassiveChanged can be called multiple times without actually changing, need to check if the callback is actually there
			if ( HasCallback_OnFindFullMapAimEntity( GetDeathboxUnderAim ) )
				RemoveCallback_OnFindFullMapAimEntity( GetDeathboxUnderAim )
		#endif
	}
	else if ( nowHas && !didHave )
	{
		#if SERVER
			GivePlayerOffhandEquipment( player, ASH_DATAKNIFE_WEAPON_NAME, false )

                           
                                                                    
                                                             
         
		#elseif CLIENT
			// OnPassiveChanged can be called multiple times without actually changing, need to check if the callback is actually there
			if ( !HasCallback_OnFindFullMapAimEntity( GetDeathboxUnderAim ) )
				AddCallback_OnFindFullMapAimEntity( GetDeathboxUnderAim, PingDeathboxUnderAim )
		#endif
	}
}

#if SERVER
void function OnGiveDataKnife( entity player, entity weapon )
{
	Assert( weapon.GetWeaponClassName() == ASH_DATAKNIFE_WEAPON_NAME, "Being given wrong weapon for callback!" )
	AddAnimEvent( weapon, "dataknife_throw", OnDataKnifeThrow )
	AddAnimEvent( weapon, "dataknife_trigger", OnDataKnifeTriggered )
}
#endif
#if SERVER
void function OnTakeDataKnife( entity player, entity weapon )
{
	Assert( weapon.GetWeaponClassName() == ASH_DATAKNIFE_WEAPON_NAME, "Taking wrong weapon for callback!" )
	DeleteAnimEvent( weapon, "dataknife_throw" )
	DeleteAnimEvent( weapon, "dataknife_trigger" )
}
#endif

bool function DeathboxNetwork_CanPlayerUse( entity player, entity deathbox, bool checkDistance = false )
{
	if ( !IsValid( player ) || !IsValid( deathbox ) || !player.HasPassive( ePassives.PAS_ASH ) )
		return false

	#if DEV
		if ( devForceDeathboxUsable )
			return true
	#endif

	if ( PlayerIsLinkedToDeathbox( player, deathbox ) )
		return false

	if ( !(deathbox in file.deathboxInfoTable) )
		return false

	deathboxInfo info = file.deathboxInfoTable[deathbox]

	if ( info.attackerTeam == player.GetTeam() )
		return false

	if ( checkDistance && DistanceSqr( player.GetOrigin(), deathbox.GetOrigin() ) > (500*500) ) // Actual use distance is smaller but this accounts for movement during client-to-server message travel time
		return false

	return true
}

array<entity> function GetLivingAttackerCount( entity player, entity deathbox )
{
	array<entity> attackerArray

	deathboxInfo info = file.deathboxInfoTable[ deathbox ]

	if ( info.attackerTeam == player.GetTeam() )
		return attackerArray

	return GetPlayerArrayOfTeam_Alive( info.attackerTeam )
}

#if SERVER
void function OnDeathboxSpawned( entity deathbox, entity attacker, int damageSourceID )
{
	if ( IsValid( attacker ) && attacker.IsPlayer() && IsValid( deathbox ) && IsValid( deathbox.GetOwner() ) )
	{
		deathboxInfo boxInfo
		boxInfo.attackerTeam = attacker.GetTeam()
		boxInfo.boxOwnerTeam = deathbox.GetOwner().GetTeam()
		boxInfo.createdTime  = Time()
		boxInfo.waypoint     = CreateWaypoint_DeathboxNetwork( deathbox, attacker, boxInfo.createdTime )

		file.deathboxInfoTable[ deathbox ] <- boxInfo
		thread Waypoint_DestroyAfterDuration_THREAD( boxInfo.waypoint, ASH_DATAKNIFE_MAP_WAYPOINT_DURATION )
	}
}

entity function CreateWaypoint_DeathboxNetwork( entity deathbox, entity attacker, float createdTime )
{
	entity wp = CreatePlayerWaypoint_Wrapper( eWaypoint.DEATHBOX_NETWORK )
	wp.SetWaypointEntity( INDEX_WaypointEntity_Deathbox, deathbox )
	wp.SetWaypointEntity( INDEX_WaypointEntity_Attacker, attacker )
	wp.SetWaypointInt( INDEX_WaypointInt_DeathboxSquadID, deathbox.GetOwner().GetTeam() )
	wp.SetWaypointFloat( INDEX_WaypointFloat_CreatedTime, createdTime )
	wp.SetParent( deathbox )
	return wp
}

void function OnPlayerKilled( entity victim, entity attacker, var attackerDamageInfo )
{
	if ( !IsValid( attacker ) && ! IsValid( victim ) )
		return

	foreach ( player in GetAllAshPlayers() )
	{
		if ( attacker.IsPlayer() && ArePlayersAllies( victim, player ) )
		{
			if ( Distance2DSqr( player.GetOrigin(), victim.GetOrigin() ) < file.ping_AllyDeath_RangeSqr
					|| Distance2DSqr( player.GetOrigin(), attacker.GetOrigin() ) < file.ping_EnemyKill_RangeSqr )
			{
				CreateWaypoint_Ping_Location( player, ePingType.ASH_PASSIVE_ID_ATTACKER, attacker, attacker.GetOrigin() + <0, 0, 50>, -1, true )

				if ( player in file.VO_AllyDiedDebounceTime && Time() < file.VO_AllyDiedDebounceTime[ player ] )
					continue

				file.VO_AllyDiedDebounceTime[ player ] <- Time() + 15.0
				PlayBattleChatterLineToSpeakerAndTeam( player, "bc_ash_passive_ally_died" )
			}
		}
	}
}
                        
                                                            
 
                                             

               

                                                                  
                                                   
     
                                         

                                     
 
      
#endif

#if CLIENT
void function OnCharacterButtonPressed( entity player )
{
	file.deathboxBeingUsed = null

	entity useEnt = player.GetUsePromptEntity()

	if ( !DeathboxNetwork_CanPlayerUse( player, useEnt ) )
		return

	Remote_ServerCallFunction( FUNCNAME_TryActivate, useEnt )

	entity weapon = player.GetOffhandWeapon( OFFHAND_EQUIPMENT )

	if ( IsValid( weapon ) && weapon.GetWeaponClassName() == ASH_DATAKNIFE_WEAPON_NAME )
	{
		ActivateOffhandWeaponByIndex( OFFHAND_EQUIPMENT )
		file.deathboxBeingUsed = useEnt
	}
}
#endif

#if SERVER
void function DeathboxNetwork_ClientToServer_TryActivate( entity player, entity deathbox )
{
	if ( !DeathboxNetwork_CanPlayerUse( player, deathbox, true ) )
	{
		Warning( "ASH DATAKNIFE: Try activate failed" )
		return
	}

	file.ashDeathboxToUse[ player ] <- deathbox
}

void function OnDataKnifeThrow( entity knife )
{
	entity player = knife.GetOwner()

	if ( !(player in file.ashDeathboxToUse) )
	{
		Warning( "ASH DATAKNIFE: Throw triggered but player is not in the table" )
		return
	}

	entity deathbox = file.ashDeathboxToUse[ player ]

	if ( IsValid( deathbox ) )
		PlayOnBoxVFX( deathbox, player )
}

void function PlayOnBoxVFX( entity deathbox, entity player )
{
	vector attachPoint = FindBestDeathboxEdgeForVFX_LocalSpace( deathbox, player )

	StartParticleEffectOnEntityWithPos( deathbox, GetParticleSystemIndex( DEATHBOX_KNIFE_FX ), FX_PATTACH_CUSTOMORIGIN_FOLLOW, ATTACHMENTID_INVALID, attachPoint, VectorToAngles( -attachPoint ) )
	StartParticleEffectOnEntity( deathbox, GetParticleSystemIndex( DEATHBOX_USED_FX ), FX_PATTACH_POINT_FOLLOW, deathbox.LookupAttachment( "fx_center" ) )
}

void function OnDataKnifeTriggered( entity knife )
{
	entity player = knife.GetOwner()

	if ( !(player in file.ashDeathboxToUse) )
	{
		Warning( "ASH DATAKNIFE: Use triggered but player is not in the table" )
		return
	}

	entity deathbox = file.ashDeathboxToUse[ player ]

	if ( IsValid( deathbox ) )
	{
		OnDeathboxUsed( file.ashDeathboxToUse[ player ], player )
		TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_ASH_DATAKNIFE_USED, player, deathbox.GetOrigin(), player.GetTeam(), player )
	}
}

void function OnDeathboxUsed( entity deathbox, entity player )
{
	if ( !IsValid( player ) || !IsValid( deathbox ) || !player.HasPassive( ePassives.PAS_ASH ) )
		return

	if ( PlayerIsLinkedToDeathbox( player, deathbox ) )
		return

	if ( deathbox in file.deathboxInfoTable )
	{
		int attackerSquadId = file.deathboxInfoTable[ deathbox ].attackerTeam

		player.LinkToEnt( deathbox )
		array<entity> targetArray = GetPlayerArrayOfTeam_Alive( attackerSquadId )

		int count = 0
		foreach ( target in targetArray )
		{
			if ( target.GetTeam() == player.GetTeam() )
				continue

                        
                                                   
             
         

			CreateWaypoint_Ping_Location( player, ePingType.ASH_PASSIVE_ID_ATTACKER, target, target.GetOrigin() + <0, 0, 50>, count, true )
			StatusEffect_AddTimed( target, eStatusEffect.revealed_by_ash, 1.0, 4.0, 0.0 )
			count++
		}
		StatsHook_AshEnemiesMarked( player, count )
		StatusEffect_AddTimed( player, eStatusEffect.revealing_enemies, (count.tofloat() / 10.0) + 0.1, 4.0, 0.0 )

		if ( count > 0 )
			PlayBattleChatterLineToSpeakerAndTeam( player, "bc_ash_passive_onUse" )

		                    
			if( count > 0 && PlayerHasPassive( player, ePassives.PAS_PAS_UPGRADE_ONE ) ) // upgrade_ash_deathbox_enemy_tracking
			{
				array<entity> teammates = GetPlayerArrayOfTeam_Alive( player.GetTeam() )
				foreach( teammate in teammates )
				{
					Remote_CallFunction_NonReplay( teammate, "DeathboxNetwork_ServerToClient_TrackTargetOverTime", deathbox, attackerSquadId )
				}
			}
        

		count = 0
		foreach ( box, boxInfo in file.deathboxInfoTable )
		{
			if ( !IsValid( box ) )
				continue

			if ( boxInfo.boxOwnerTeam == attackerSquadId && attackerSquadId != player.GetTeam() )
			{
				CreateWaypoint_Ping_Location( player, ePingType.ASH_PASSIVE_ID_DEATHBOX, box, box.GetOrigin() + <0, 0, 50>, count, true )
			}
		}
	}
}
#endif

bool function OnWeaponAttemptOffhandSwitch_ability_ash_dataknife( entity weapon )
{
	#if SERVER
		entity owner = weapon.GetOwner()
		if ( !IsValid( owner ) || !( owner in file.ashDeathboxToUse ) )
			return false

		bool canUse = DeathboxNetwork_CanPlayerUse( owner, file.ashDeathboxToUse[ owner ] )
		if( !canUse )
			Warning( "ASH DATAKNIFE: Offhand switch failed, player cannot use" )

		return canUse
	#endif
	return true
}

var function OnWeaponPrimaryAttack_ability_ash_dataknife( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.RemoveMod( ABILITY_USED_MOD )

	bool serverOrPredicted = IsServer() || (InPrediction() && IsFirstTimePredicted())
	if ( serverOrPredicted )
	{
		entity owner = weapon.GetOwner()
		if ( !IsValid( owner ) )
			return 0

		entity deathboxToUse
		#if SERVER
			if ( !( owner in file.ashDeathboxToUse ) || !IsValid( file.ashDeathboxToUse[ owner ] ) )
				return 0

			deathboxToUse = file.ashDeathboxToUse[ owner ]
		#elseif CLIENT
			deathboxToUse = file.deathboxBeingUsed
		#endif

		if ( !IsValid( deathboxToUse ) || !(deathboxToUse in file.deathboxInfoTable) )
			return 0

		array<entity> livingPlayers = GetLivingAttackerCount( owner, deathboxToUse )
		if ( livingPlayers.len() > 0 )
			weapon.AddMod( ABILITY_USED_MOD )
	}
	return 0
}

void function OnWeaponActivate_ability_ash_dataknife( entity weapon )
{
}

void function OnWeaponDeactivate_ability_ash_dataknife( entity weapon )
{
	#if SERVER
	entity owner = weapon.GetOwner()
	Assert( owner in file.ashDeathboxToUse, "ASH DATAKNIFE: Owner not found in table during deactive" )

	if ( IsValid( owner ) && owner in file.ashDeathboxToUse )
		delete file.ashDeathboxToUse[ owner ]
	#endif
}

#if CLIENT
void function OnWaypointCreated( entity wp )
{
	if ( wp.GetWaypointType() != eWaypoint.DEATHBOX_NETWORK )
		return

	entity player = GetLocalViewPlayer()
	if ( !IsValid( player ) || !player.HasPassive( ePassives.PAS_ASH ) )
		return

	entity deathbox = wp.GetWaypointEntity( INDEX_WaypointEntity_Deathbox )
	if ( !IsValid( deathbox ) )
		return

	entity attacker = wp.GetWaypointEntity( INDEX_WaypointEntity_Attacker )
	if ( !IsValid( attacker ) )
		return

	float createdTime = wp.GetWaypointFloat( INDEX_WaypointFloat_CreatedTime )

	deathboxInfo boxInfo
	boxInfo.waypoint     = wp
	boxInfo.attackerTeam = attacker.GetTeam()
	boxInfo.boxOwnerTeam = wp.GetWaypointInt( INDEX_WaypointInt_DeathboxSquadID )
	boxInfo.createdTime  = createdTime
	file.deathboxInfoTable[ deathbox ] <- boxInfo

	DeathboxNetwork_AddDeathboxToMaps( deathbox, boxInfo, $"rui/rui_screens/icon_ash_passive_deathbox", 8, 24 )

	AddEntityDestroyedCallback( wp, OnWaypointDestroyed )
}

void function DeathboxNetwork_AddDeathboxToMaps( entity deathbox, deathboxInfo boxInfo, asset icon, float fullmapIconSize, float minimapIconSize )
{
	var fRui = FullMap_CommonAdd( $"ui/deathbox_fullmap_icon.rpak" )
	if ( fRui == null )
	{
		Warning( "Couldn't add ping icon to fullmap." )
		return
	}

	RuiSetFloat( fRui, "objectSize", fullmapIconSize )
	RuiSetImage( fRui, "iconImage", icon )
	RuiSetGameTime( fRui, "startTime", boxInfo.createdTime )
	RuiSetFloat( fRui, "appearanceDelay", file.mapIconAppearanceDelay )

	FullMap_CommonTrackEntOrigin( fRui, deathbox, false )
	Fullmap_AddRui( fRui )
	boxInfo.waypoint.wp.ruiFullmap = fRui

	var mRui = Minimap_CommonAdd( $"ui/deathbox_minimap_icon.rpak", MINIMAP_Z_PING )
	if ( mRui == null )
	{
		Warning( "Couldn't add ping icon to minimap." )
		return
	}

	RuiSetFloat( mRui, "objectSize", minimapIconSize )
	RuiSetImage( mRui, "iconImage", icon )
	RuiSetImage( mRui, "clampedIconImage", icon )
	RuiSetGameTime( mRui, "startTime", boxInfo.createdTime )
	RuiSetFloat( mRui, "appearanceDelay", file.mapIconAppearanceDelay )

	Minimap_CommonTrackEntOrigin( mRui, deathbox, false )
	boxInfo.waypoint.wp.ruiMinimap = mRui
}

void function DeathboxNetwork_TrackBoxTargets( entity deathbox )
{
	if ( !(deathbox in file.deathboxInfoTable) )
		return

	deathboxInfo boxInfo = file.deathboxInfoTable[ deathbox ]

	var rui = CreateTransientFullscreenRui( $"ui/deathbox_hint_far.rpak", -1 )
	RuiTrackFloat3( rui, "pos", deathbox, RUI_TRACK_OVERHEAD_FOLLOW )
	RuiSetInt( rui, "localPlayerSquadID", GetLocalViewPlayer().GetTeam() )
	RuiSetInt( rui, "attackerSquadID", boxInfo.attackerTeam )
	RuiSetInt( rui, "deathboxSquadID", boxInfo.boxOwnerTeam )

	file.trackedDeathboxRui = rui
	file.trackedDeathbox = deathbox

	array<entity> livingTargets = GetPlayerArrayOfTeam_Alive( boxInfo.attackerTeam )
	entity player               = GetLocalViewPlayer()
	if ( IsValid( player ) && livingTargets.len() > 0 )
	{
		entity closestTarget = GetClosest( livingTargets, player.GetOrigin() )
		float closestDist = Distance2D( closestTarget.GetOrigin(), player.GetOrigin() )
		RuiSetFloat( rui, "nearestTargetDist", closestDist )
	}
	else
	{
		RuiSetFloat( rui, "nearestTargetDist", 999999 )
	}

	RuiSetInt( rui, "attackerTargets", livingTargets.len() )
	RuiSetFloat( rui, "createdTime", boxInfo.createdTime )
	RuiSetBool( rui, "isFocused", true )

}

void function DeathboxNetwork_UntrackBoxTargets( entity deathbox )
{
	if ( IsValid( file.trackedDeathboxRui ) )
		RuiDestroy( file.trackedDeathboxRui )

	file.trackedDeathboxRui = null
	file.trackedDeathbox = null
}

void function DeathboxNetwork_UntrackIfTracking()
{
	if ( file.trackedDeathbox != null )
	{
		DeathboxNetwork_UntrackBoxTargets( file.trackedDeathbox )
	}
}

void function OnWaypointDestroyed( entity wp )
{
	foreach ( box, boxInfo in file.deathboxInfoTable )
	{
		if ( wp != boxInfo.waypoint )
			continue
		
		boxInfo.hasIconExpired = true
		return
	}
}
#endif

bool function UseAlternatePassiveActivation()
{
	return GetCurrentPlaylistVarBool( "ash_use_alternate_passive_activation", false )
}

#if SERVER
array<entity> function GetAllAshPlayers()
{
	array<entity> ashArray

	foreach ( player in GetPlayerArray_Alive() )
	{
		if ( !IsValid( player ) )
			continue

		if ( player.HasPassive( ePassives.PAS_ASH ) )
		{
			ashArray.append( player )
		}
	}

	return ashArray
}
#endif

#if CLIENT
                    
void function DeathboxNetwork_ServerToClient_TrackTargetOverTime( entity deathbox, int targetTeam )
{
	thread DeathboxNetwork_ServerToClient_TrackTargetOverTime_Thread( deathbox, targetTeam )
}

void function DeathboxNetwork_ServerToClient_TrackTargetOverTime_Thread( entity deathbox, int targetTeam )
{
	entity player = GetLocalViewPlayer()
	array<entity> targetArray = GetPlayerArrayOfTeam_Alive( targetTeam )

	float scanDuration = 60.0
	float endTime = Time() + scanDuration
	float fadeStartTime = Time() + 2.0
	float fadeEndTime = Time() + 2.5

	array<var> fullMapRuis
	array<var> minimapRuis
	array<entity> entsForTracking

	OnThreadEnd(
		function() : ( fullMapRuis, minimapRuis )
		{
			foreach( var ruiToDestroy in fullMapRuis )
			{
				Fullmap_RemoveRui( ruiToDestroy )
				RuiDestroyIfAlive( ruiToDestroy )
			}

			foreach( var ruiToDestroy in minimapRuis)
			{
				Minimap_CommonCleanup( ruiToDestroy )
			}
		}
	)

	if( IsValid( deathbox ) )
	{
		vector pulseOrigin = deathbox.GetOrigin()
		FullMap_PlayCryptoPulseSequence( pulseOrigin, true, 60.0 )
	}

	while ( Time() < endTime ) //timeToWait > 0 )
	{
		foreach( var ruiToDestroy in fullMapRuis )
		{
			Fullmap_RemoveRui( ruiToDestroy )
			RuiDestroyIfAlive( ruiToDestroy )
		}

		foreach( var ruiToDestroy in minimapRuis)
		{
			Minimap_CommonCleanup( ruiToDestroy )
		}
		fullMapRuis.clear()
		minimapRuis.clear()

		foreach( entity enemy in targetArray )
		{
			if ( !IsValid( enemy ) )
				continue
                        
                                      
             
         

			// Full map
			var fRui = FullMap_AddEnemyLocation( enemy )
			fullMapRuis.append( fRui )

			// MiniMap
			var mRui = Minimap_AddEnemyToMinimap( enemy )
			minimapRuis.append( mRui )
		}

		Wait( 2.0 )

		float curTime = Time()

		foreach( var rui in fullMapRuis )
		{
			RuiSetGameTime( rui, "fadeOutEndTime", curTime + .5 )
		}

		foreach( var rui in minimapRuis)
		{
			RuiSetGameTime( rui, "fadeStartTime", curTime )
			RuiSetGameTime( rui, "fadeEndTime", curTime + .5 )
		}

		Wait( 1.0 )
	}
}
      

void function DeathboxNetwork_ServerToClient_ForceUsable()
{
	#if DEV
		devForceDeathboxUsable = true
	#endif
}

entity function GetDeathboxUnderAim( vector worldPos, float worldRange )
{
	float closestDistSqr        = FLT_MAX
	float worldRangeSqr = worldRange * worldRange
	float extendedRange = worldRange * 1.5	// Cast a wider net initially to use for the "nearby deathboxes" prompt
	entity closestEnt = null

	int count
	foreach ( box, boxInfo in file.deathboxInfoTable )
	{
		if ( !IsValid( box ) )
			continue

		if ( box.GetNetworkedClassName() != "prop_death_box" )
			continue

		if ( boxInfo.hasIconExpired || boxInfo.createdTime + file.mapIconAppearanceDelay > Time()  )
			continue

		vector boxOrigin = box.GetOrigin()

		if ( !IsPositionWithinRadius( extendedRange, boxOrigin, worldPos ) )
			continue

		count++

		float distSqr = Distance2DSqr( boxOrigin, worldPos )
		if ( distSqr < worldRangeSqr && distSqr < closestDistSqr  )
		{
			closestDistSqr = distSqr
			closestEnt     = box
		}
	}

	if ( !IsValid( closestEnt ) )
	{
		if ( IsValid( file.fullMapHighlightedDeathbox ) )
		{
				Fullmap_RemoveRui( file.fullMapHightlightTooltipRui )
				RuiDestroy( file.fullMapHightlightTooltipRui )
			file.fullMapHightlightTooltipRui = null
			file.fullMapHighlightedDeathbox = null
		}

		return null
	}

	if ( !IsValid( file.fullMapHightlightTooltipRui ) )
	{
		file.fullMapHightlightTooltipRui = FullMap_CommonAdd( $"ui/deathbox_fullmap_tooltip.rpak", 100 )
		Fullmap_AddRui( file.fullMapHightlightTooltipRui )
	}

	if ( closestEnt != file.fullMapHighlightedDeathbox )
	{
		RuiSetGameTime( file.fullMapHightlightTooltipRui, "startTime", file.deathboxInfoTable[ closestEnt ].createdTime )
		file.fullMapHighlightedDeathbox = closestEnt
	}

	RuiSetInt( file.fullMapHightlightTooltipRui, "nearbyDeathboxCount", count )
	RuiSetFloat3( file.fullMapHightlightTooltipRui, "highlightedObjectPos", closestEnt.GetOrigin() )

	return closestEnt
}

bool function PingDeathboxUnderAim( entity deathbox )
{
	entity player = GetLocalClientPlayer()

	if ( !IsValid( player ) || !IsAlive( player ) )
		return false

	if ( !IsPingEnabledForPlayer( player ) )
		return false

	Remote_ServerCallFunction( FUNCNAME_PingDeathboxFromMap, deathbox )

	EmitSoundOnEntity( GetLocalViewPlayer(), PING_SOUND_LOCAL_CONFIRM )

	return true
}

                        
                                      
 
                                                      
        

                                      
                                     

                                          
        

                               
  
                                                              
                                           
  
 
      
#endif

#if SERVER
void function DeathboxNetwork_ClientToServer_PingDeathboxFromMap( entity player, entity deathbox )
{
	if ( IsValid( player ) && player.HasPassive( ePassives.PAS_ASH ) && IsValid( deathbox ) )
	{
		entity wp = CreateWaypoint_Ping_Location( player, ePingType.ASH_PASSIVE_PING_DEATHBOX, deathbox, deathbox.GetOrigin() + <0, 0, 50>, -1, false )
		Waypoint_SetQuantityForWaypoint( wp, int( DeathboxNetwork_GetDeathboxAge( deathbox ) ) )
	}
}

void function DEV_TestAshDeathbox()
{
	#if DEV
		devForceDeathboxUsable = true
		Remote_CallFunction_NonReplay( GP(), "DeathboxNetwork_ServerToClient_ForceUsable" )
		DEV_SpawnDeathBoxWithRandomLoot( GP() )
	#endif
}
#endif

float function DeathboxNetwork_GetDeathboxAge( entity deathbox )
{
	if ( IsValid( deathbox ) && deathbox in file.deathboxInfoTable )
		return Time() - file.deathboxInfoTable[deathbox].createdTime

	return -1
} 