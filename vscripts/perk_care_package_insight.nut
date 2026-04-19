global function Perk_CarePackageInsight_Init

const string HIDDEN_CARE_PACKAGE_ENT_NAME = "care_package_hidden"
const string REVEALED_CARE_PACKAGE_ENT_NAME = "care_package_revealed"

const float CAREPACKAGE_WAYPOINT_UP_OFFSET = 90
const float CAREPACKAGE_HINT_NOTIFICATION_DIST = 20000
const float FORWARD_CAST_RAY_LENGTH = 40000
const float LOOKAT_HINT_COOLDOWN = 120

#if DEV
const bool CARE_PACKAGE_INSIGHT_PERF_TESTING = false
#endif


#if SERVER
const float SERVER_REVEAL_TIME_LENIENCY = .75
const float SERVER_REVEAL_DEGREES_LENIENCY = 1.25

global function Perks_CarePackageInsight_ClientToServer_RevealPackage
global function Perks_CarePackageInsight_ClientToServer_StartRevealPackage
global function Perks_CarePackageInsight_ClientToServer_MinimapIconPinged
global function Perks_CarePackageInsight_CreateCarePackageInsightPing

#if DEV
global function DeleteCarepackagePerkLinks
#endif

struct CarePackageData
{
	entity carePackage			//Care Package Entity itself
	string highestLootItem		//The Loot Item  we care about - likely need to store its icon reference here too
	entity highestLootEnt
	entity revealedEnt
	entity revealEnt
	table< entity, float > startRevealTimes
}
#endif

#if CLIENT
global function ClientCodeCallback_OnCarePackageInsightDataChanged
global function ServerToClient_NotifyPathfinderCooldownReduction

struct RevealEntData
{
	float revealProgress
	bool hasLos
	bool revealed
}

#endif

struct
{
	#if SERVER
		table<entity, CarePackageData  > carePackageArray

		#if DEV
			array < entity > carePackageExtraEnts
		#endif
	#endif

	#if CLIENT
		table<entity, RevealEntData> revealEntitiesToData
		array<entity>		 recentlyRevealedEntities
		table<entity, var> 	 revealEntityToRui
		entity                       soundController
		float                        lastRevealPackageHintTime
		entity 				prevHoverEntity
	#endif

} file

void function Perk_CarePackageInsight_Init()
{
	if ( GetCurrentPlaylistVarBool( "disable_perk_care_package_insight", false ) )
		return

	PerkInfo carePackageInsight
	carePackageInsight.perkId          = ePerkIndex.CARE_PACKAGE_INSIGHT
	#if SERVER || CLIENT
		carePackageInsight.minimapPingType = ePingType.CAREPACKAGE_INSIGHT
		carePackageInsight.activateCallback = OnActivate_CarePackageInsight
		carePackageInsight.deactivateCallback = OnDeactivate_CarePackageInsight
		carePackageInsight.mapFeatureTitle = "#PERK_FEATURE_CARE_PACKAGE_INSIGHT"
		carePackageInsight.mapFeatureDescription = "#PERK_FEATURE_CARE_PACKAGE_INSIGHT_DESC"
		RegisterSignal( "Perk_CarePackageInsight_ContentsTaken" )
	#endif

	#if CLIENT
		carePackageInsight.worldspaceIconUpOffset = CAREPACKAGE_WAYPOINT_UP_OFFSET
		carePackageInsight.hideFromTeammates = true
		carePackageInsight.trackEntityPosition = true
		carePackageInsight.ruiThinkThread = Perk_CarePackageInsight_UpdateLookatRevealProgressRui
		carePackageInsight.canPingEnt = Perk_CarePackageInsight_CanPingEnt
		carePackageInsight.getPingPosition = Perk_CarePackageInsight_GetPingPositionForEnt
		carePackageInsight.getDynamicPingMaxDistance = Perk_CarePackageInsight_GetPingDistanceForEnt
	#endif

	Perks_RegisterClassPerk( carePackageInsight )

	#if SERVER || CLIENT
	Remote_RegisterServerFunction( "Perks_CarePackageInsight_ClientToServer_RevealPackage", "typed_entity", "prop_care_package_insight" )
	Remote_RegisterServerFunction( "Perks_CarePackageInsight_ClientToServer_StartRevealPackage", "typed_entity", "prop_care_package_insight" )
	Remote_RegisterServerFunction( "Perks_CarePackageInsight_ClientToServer_MinimapIconPinged", "typed_entity", "prop_care_package_insight" )
	Remote_RegisterClientFunction( "ServerToClient_NotifyPathfinderCooldownReduction" )


		AddCallback_OnPassiveChanged( ePassives.PAS_UPGRADE_CAREPACKAGE_INSIGHT, OnPassiveChangedCarePackageInsightUpgrade )


	PrecacheScriptString( HIDDEN_CARE_PACKAGE_ENT_NAME )
	PrecacheScriptString( REVEALED_CARE_PACKAGE_ENT_NAME )
	#endif

	#if SERVER
		Survival_AddCallback_OnAirdropLaunched( CarePackageInsight_OnAirdropLaunched )
		Survival_AddCallback_OnAirdropOpened( CarePackageInsight_OnAirdropOpened )

		AddCallback_GameStateEnter( eGameState.WinnerDetermined, CarePackageInsight_ClearVisibilityOnGameEnd )
	#endif

	#if CLIENT
		RegisterSignal( "CarePackage_PerkDisabled" )
		RegisterSignal( "CarePackage_PerkEnabled" )
		AddCreateCallback( "prop_care_package_insight", OnCarePackageDataCreated )

		PrecacheParticleSystem( $"P_ar_loot_drop_point_CP_noZ" )

		AddCallback_OnFindFullMapAimEntity( GetCarePackageUnderAim, PingCarePackageUnderAim )

		file.lastRevealPackageHintTime = -9999
	#endif
}

#if SERVER || CLIENT
void function OnActivate_CarePackageInsight( entity player, string characterName )
{
	#if CLIENT
		if( player != GetLocalViewPlayer() )
			return

		thread UpdateCarePackageLootAtReveal( player )
		thread UpdateCarePackageLos( player )

		entity soundController = CreatePropDynamic( EMPTY_MODEL )
		soundController.SetParent( player )
		file.soundController = soundController
		player.Signal( "CarePackage_PerkEnabled" )
	#endif
}

void function OnDeactivate_CarePackageInsight( entity player )
{
	#if CLIENT
		player.Signal( "CarePackage_PerkDisabled" )
		if( player == GetLocalViewPlayer() && file.soundController != null )
		{
			file.soundController.Destroy()
			file.soundController = null
		}
	#endif
}


void function OnPassiveChangedCarePackageInsightUpgrade( entity player, int passive, bool didHave, bool nowHas )
{
	if( nowHas )
	{
		Perks_AddPerk( player, ePerkIndex.CARE_PACKAGE_INSIGHT )
	}
}

#endif

// Playlist Var Tuning values
float function Perk_CarePackageInsight_LookatRevealTime()
{
	return GetCurrentPlaylistVarFloat( "care_package_insight_reveal_time", 1.0 )
}

float function Perk_CarePackageInsight_LookAtWideRevealDegrees()
{
	return GetCurrentPlaylistVarFloat( "care_package_insight_wide_reveal_degrees", 30.0 )
}

float function Perk_CarePackageInsight_LookAtDirectRevealDegrees()
{
	return GetCurrentPlaylistVarFloat( "care_package_insight_direct_reveal_degrees", 3.0 )
}

float function Perk_CarePackageInsight_IgnoreLosRevealDistance()
{
	return GetCurrentPlaylistVarFloat( "care_package_insight_ignore_los_distance", 6000.0 )
}

#if SERVER
bool function Perk_CarePackageInsight_ValidateRevealOnServer()
{
	return GetCurrentPlaylistVarBool( "care_package_insight_validate_reveal_on_server", true )
}

void function Perks_CarePackageInsight_ClientToServer_MinimapIconPinged( entity player, entity minimapEnt )
{
	if ( Perks_CarePackageInsight_IsClientDataValid( player, minimapEnt, false ) )
	{
		string lootItem = Perk_CarePackageInsight_GetLootItemStringForPing( player, minimapEnt )
		vector dropPos = minimapEnt.GetOrigin()
		if( lootItem == "" )
		{
			entity locationWp = CreateWaypoint_Ping_Location( player, ePingType.CAREPACKAGE, null, dropPos, -1, false )
			return
		}
		int pingType = false ?  ePingType.CAREPACKAGE_INSIGHT_LOOTED : ePingType.CAREPACKAGE_INSIGHT
		entity wp = CreateWaypoint_Ping_Location( player,  pingType, minimapEnt, minimapEnt.GetOrigin(), -1, false )
		wp.SetWaypointString( 0, lootItem )
	}
}

bool function Perks_CarePackageInsight_IsClientDataValid( entity player, entity revealEnt, bool isActualRevealEnt )
{
	if( !IsValid( player ) || !player.IsPlayer() )
		return false

	if ( !IsValid( revealEnt ) )
		return false

	if( revealEnt.GetScriptName() != HIDDEN_CARE_PACKAGE_ENT_NAME && revealEnt.GetScriptName() != REVEALED_CARE_PACKAGE_ENT_NAME )
		return false

	// the following two checks don't apply to the minimapEnt, but it's simpler to have a single validation function
	if ( isActualRevealEnt )
	{
		entity carePackage = revealEnt.GetLinkEnt()
		if( !IsValid( carePackage ) )
			return false

		if( !(carePackage in file.carePackageArray) )
			return false
	}

	return true
}

bool function Perks_CarePackageInsight_ValidateLookAtDegrees( entity player, entity revealEnt, bool validateLos )
{
	// validate that the player was looking at the care package to start the reveal, but use a wider lookat degree to account for potential lag
	entity carePackage = revealEnt.GetLinkEnt()
	vector viewVector = player.GetViewVector()
	vector eyePosition = player.EyePosition()
	float lookatThreshold = deg_cos( Perk_CarePackageInsight_LookAtWideRevealDegrees() * SERVER_REVEAL_DEGREES_LENIENCY )

	vector carePackageLookatPos = carePackage.GetOrigin() + <0,0,CAREPACKAGE_WAYPOINT_UP_OFFSET>
	vector carePackageDir = Normalize( carePackageLookatPos - eyePosition )
	float dotProduct = DotProduct( viewVector, carePackageDir )

	if( dotProduct < lookatThreshold )
		return false

	if( !validateLos )
		return true

	TraceResults trace = TraceLine( eyePosition, carePackageLookatPos, null, TRACE_MASK_BLOCKLOS, TRACE_COLLISION_GROUP_NONE )

	// for some reason the pathfinder tt collision only seems to exist on the server ( or the collision maks for it are different on the server)
	// which results in the server validation failing even though it looks correct on the client
	// fix this by ignoring the pathfinder tt collision if we detect it
	if( IsValid( trace.hitEnt ) && trace.hitEnt.GetScriptName() == "pathfinder_tt_ring_shield" )
	{
		trace = TraceLine( eyePosition, carePackageLookatPos, trace.hitEnt, TRACE_MASK_BLOCKLOS, TRACE_COLLISION_GROUP_NONE )
	}
	bool canSee = trace.hitEnt == carePackage || trace.fraction >= 0.99 || trace.hitSky
	return canSee
}

void function Perks_CarePackageInsight_ClientToServer_RevealPackage( entity player, entity revealEnt )
{
	if( !(Perks_CarePackageInsight_IsClientDataValid( player, revealEnt, true )) )
		return

	entity carePackage = revealEnt.GetLinkEnt()
	CarePackageData info = file.carePackageArray[carePackage]
	if( Perk_CarePackageInsight_ValidateRevealOnServer() )
	{
		if( !Perks_DoesPlayerHavePerk( player, ePerkIndex.CARE_PACKAGE_INSIGHT ) )
			return

		if( !( player in info.startRevealTimes ) )
			return

		if( Time() - info.startRevealTimes[player] < ( Perk_CarePackageInsight_LookatRevealTime() * SERVER_REVEAL_TIME_LENIENCY ) )
			return

		if( !Perks_CarePackageInsight_ValidateLookAtDegrees( player, revealEnt, false ) )
			return
	}

	// validation succeeded reveal the care package
	entity revealedEnt = file.carePackageArray[carePackage].revealedEnt
	int team = player.GetTeam()

	array<entity> teamPlayers = GetPlayerArrayOfTeam( team )
	bool shouldStopTransmittingReveal = player.HasPassive( ePassives.PAS_PATHFINDER )
	if( !shouldStopTransmittingReveal )
	{
		shouldStopTransmittingReveal = true
		foreach ( teammate in teamPlayers )
		{
			if ( teammate.HasPassive( ePassives.PAS_PATHFINDER ) )
			{
				shouldStopTransmittingReveal = false
				break
			}
		}
	}

	//if( shouldStopTransmittingReveal )
	//	revealEnt.SetTransmitToTeam( team, false )
	bool alreadyRevealed = false//revealedEnt.IsTransmittingToTeam( team )
	//revealedEnt.SetTransmitToTeam( team, true )

	if( !alreadyRevealed )
	{
		Perks_CarePackageInsight_CreateCarePackageInsightPing( player, revealedEnt, carePackage.GetOrigin(), 0 )
		LootData data               = SURVIVAL_Loot_GetLootDataByIndex( 0 )
		vector carePackageLookatPos = carePackage.GetOrigin() + <0, 0, CAREPACKAGE_WAYPOINT_UP_OFFSET>
		//PIN_Perks_CarePackageRevealed( player, carePackageLookatPos, data.ref )
		StatsHook_CarePackageRevealed( player )


			UpgradeCore_GrantCarePackageScanXp( player )

	}

	delete info.startRevealTimes[player]

	if ( PlayerHasPassive( player, ePassives.PAS_PATHFINDER ) )
	{
		GrantPathfinderCooldownReduction( player )
	}
}

void function Perks_CarePackageInsight_ClientToServer_StartRevealPackage( entity player, entity revealEnt )
{
	if( !(Perks_CarePackageInsight_IsClientDataValid( player, revealEnt, true )) )
		return

	if( Perk_CarePackageInsight_ValidateRevealOnServer() )
	{
		if( !Perks_DoesPlayerHavePerk( player, ePerkIndex.CARE_PACKAGE_INSIGHT ) )
			return

		// line of sight is only required if we are far away from the care package's landing location
		float ignoreLosDistance = Perk_CarePackageInsight_IgnoreLosRevealDistance()
		bool validateLos = DistanceSqr( revealEnt.GetOrigin(), player.EyePosition() ) > ignoreLosDistance * ignoreLosDistance
		if( !Perks_CarePackageInsight_ValidateLookAtDegrees( player, revealEnt, validateLos ) )
			return
	}
	entity carePackage = revealEnt.GetLinkEnt()
	file.carePackageArray[carePackage].startRevealTimes[player] <- Time()
}

string function Perk_CarePackageInsight_GetLootItemStringForPing( entity player, entity carePackage )
{
	int team = player.GetTeam()
	if( false )
	{
		int lootIndex = 0//carePackage.GetLootIndex()
		LootData data = SURVIVAL_Loot_GetLootDataByIndex( lootIndex )
		return data.ref
	}
	else
	{
		return ""
	}
	return ""
}

void function Perks_CarePackageInsight_CreateCarePackageInsightPing( entity player, entity revealEnt, vector pingOrigin, int userTicketId )
{
	if( revealEnt.GetClassName() != "prop_care_package_insight" )
		return
	string lootItem = Perk_CarePackageInsight_GetLootItemStringForPing( player, revealEnt )
	if( lootItem == "" )
		return

	entity carePackage = revealEnt.GetLinkEnt()
	vector pingPosition = carePackage.GetOrigin()
	vector offsetPosition = pingPosition + <0,0,CAREPACKAGE_WAYPOINT_UP_OFFSET - 72>


	int pingType = false ? ePingType.CAREPACKAGE_INSIGHT_LOOTED : ePingType.CAREPACKAGE_INSIGHT
	entity wp = CreateWaypoint_Ping_Location( player, pingType, revealEnt, offsetPosition, userTicketId, false )
	wp.SetWaypointString( 0, lootItem )
	wp.SetWaypointGroupFlags( WPGF_NO_CREATE_MINIMAP_ICONS )
	wp.SetParent( carePackage )
}

bool function CarePackageInsight_ShouldTeamSeeInsight( int team )
{
	array<entity> teamPlayers = GetPlayerArrayOfTeam( team )
	foreach ( entity player in teamPlayers )
	{
		if( Perks_DoesPlayerHavePerk( player, ePerkIndex.CARE_PACKAGE_INSIGHT ) )
		{
			return true
		}
	}
	return false
}

// When an Airdrop first gets launched, store it's loot tier so we can change the look of the icon when it lands based on tier
void function CarePackageInsight_OnAirdropLaunched( entity airdrop, vector airdropPos )
{
	if ( airdrop.GetTargetName() != CARE_PACKAGE_TARGETNAME ) // Lifeline care package, no scans
		return

	if ( GetGameState() >= eGameState.WinnerDetermined )
		return

	array< array<string> > contents = airdrop.e.airDropContents
	if( contents.len() <= 0 )
		return

	int highestTier = 0
	int highestTierLootId = -1
	string highestTierLoot = ""

	array<string> highestTierPanel = contents[contents.len()-1]
	foreach ( loot in highestTierPanel )
	{
		LootData ld = SURVIVAL_Loot_GetLootDataByRef( loot )
		if ( ( ld.tier > highestTier ) )
		{
			highestTier = ld.tier
			highestTierLoot = loot
			highestTierLootId = ld.index
		}
	}

	array<entity> allPlayers = GetPlayerArray_Alive()

	entity carePackageHiddenEntity = CreateEntity( "prop_care_package_insight" )
	carePackageHiddenEntity.RemoveFromAllRealms()
	carePackageHiddenEntity.AddToOtherEntitysRealms( airdrop )
	carePackageHiddenEntity.SetValueForModelKey( $"mdl/dev/empty_model.rmdl" )
	carePackageHiddenEntity.SetOrigin( airdropPos )
	carePackageHiddenEntity.MakeInvisible()
	carePackageHiddenEntity.SetScriptName( HIDDEN_CARE_PACKAGE_ENT_NAME )
	DispatchSpawn( carePackageHiddenEntity )

	entity carePackageVisibleEntity = CreateEntity( "prop_care_package_insight" )
	carePackageVisibleEntity.RemoveFromAllRealms()
	carePackageVisibleEntity.AddToOtherEntitysRealms( airdrop )
	carePackageVisibleEntity.SetValueForModelKey( $"mdl/dev/empty_model.rmdl" )
	carePackageVisibleEntity.SetOrigin( airdropPos )
	carePackageVisibleEntity.MakeInvisible()
	carePackageVisibleEntity.SetScriptName( REVEALED_CARE_PACKAGE_ENT_NAME )
	//carePackageVisibleEntity.SetLootIndex( highestTierLootId )
	DispatchSpawn( carePackageVisibleEntity )

	carePackageHiddenEntity.LinkToEnt( airdrop )
	carePackageVisibleEntity.LinkToEnt( airdrop )


	//Create the Droppod Data on the Server
	CarePackageData droppod
	droppod.carePackage 	= airdrop
	droppod.highestLootItem	= highestTierLoot
	droppod.revealedEnt = carePackageVisibleEntity
	droppod.revealEnt = carePackageHiddenEntity

	file.carePackageArray[airdrop] <- droppod

	foreach( team in GetAllValidPlayerTeams() )
	{
		//carePackageHiddenEntity.SetTransmitToTeam( team, true )
	}

	Perks_AddMinimapEntityForPerk( ePerkIndex.CARE_PACKAGE_INSIGHT, airdrop )
}

void function CarePackageInsight_OnAirdropOpened( entity airdrop, entity player )
{
	if( !(airdrop in file.carePackageArray) )
		return

	//The AirDrop creates its Loot Children when opened - at which point we add a Callback to the loot item to track when it gets taken.
	CarePackageData carePackageData = file.carePackageArray[airdrop]
	string highestTierLoot = carePackageData.highestLootItem

	array<entity> childArray = airdrop.GetChildren()
	foreach ( child in childArray )
	{
		if ( !IsValid( child ) || !(child.GetNetworkedClassName() == "prop_survival") )
			continue

		LootData data = SURVIVAL_Loot_GetLootDataByIndex( child.GetSurvivalInt() )
		if( data.ref == highestTierLoot )
		{
			carePackageData.highestLootEnt = child
			AddEntityDestroyedCallback( child, OnRemovedAirdropLootItem )
		}
	}

	if( IsValid( player ) )
	{
		int team = player.GetTeam()
		if ( false )
		{
			array<entity> teamPlayers = GetPlayerArrayOfTeam( team )
			foreach( teammate in teamPlayers )
			{
				if( !IsAlive( teammate ) )
					continue
				if( !Perks_DoesPlayerHavePerk( teammate, ePerkIndex.CARE_PACKAGE_INSIGHT ) )
					continue
				StatsHook_RevealedCarePackageLooted( teammate )



			}
		}
	}
}

void function CarePackageInsight_ClearVisibilityOnGameEnd()
{
	// hide all the reveal ents on game end so that they don't show up in the winners podium
	foreach( ent, carePackageData in file.carePackageArray )
	{
		array< int > allTeams = GetAllValidPlayerTeams()
		foreach( int team in allTeams )
		{
			//carePackageData.revealEnt.SetTransmitToTeam( team, false )
			//carePackageData.revealedEnt.SetTransmitToTeam( team, false )
		}
	}
}

void function OnRemovedAirdropLootItem( entity lootItem )
{
	foreach( ent, carePackageData in file.carePackageArray )
	{
		entity carePackage = carePackageData.carePackage
		entity bestItem = carePackageData.highestLootEnt

		//If the Pod's Best Item is removed, we kill the WP and update the Map Icon
		if( bestItem == lootItem )
		{
			carePackageData.highestLootEnt = null
			//carePackageData.revealedEnt.SetAreContentsTaken( true )
		}
	}
}
#endif // SERVER

#if CLIENT
void function ClientCodeCallback_OnCarePackageInsightDataChanged( entity carePackageInsightEnt )
{
	if( false )
	{
		carePackageInsightEnt.Signal( "Perk_CarePackageInsight_ContentsTaken" )
	}
}

void function OnCarePackageDataCreated( entity ent )
{
	// delay this a frame so that perks can be assigned in the event of a cl_fullupdate causing race conditions
	thread OnCarePackageDataCreated_Delayed( ent )
}

void function OnCarePackageDataCreated_Delayed( entity ent )
{
	ent.EndSignal( "OnDestroy" )
	WaitFrame()
	entity player = GetLocalViewPlayer()
	if( !Perks_DoesPlayerHavePerk( player, ePerkIndex.CARE_PACKAGE_INSIGHT ) && !IsSpectator( player ) )
	{
		player.WaitSignal( "CarePackage_PerkEnabled" )
	}

	if ( !IsValid( ent ) )
		return

	if( ent.GetScriptName() == HIDDEN_CARE_PACKAGE_ENT_NAME )
	{
		thread AddCarePackageInsightRui( ent, false )
		AddDropLocationEffects( ent )
	}
	else if( ent.GetScriptName() == REVEALED_CARE_PACKAGE_ENT_NAME )
	{
		thread AddCarePackageInsightRui( ent, true )
	}
}

void function AddDropLocationEffects( entity ent )
{
	ent.EndSignal( "OnDestroy" )
	entity carePackage = ent.GetLinkEnt()
	if( !IsValid( carePackage ) )
		return

	carePackage.EndSignal( "OnDestroy" )

	int colorID = COLORID_AIRDROP_DEFAULT_COLOR
	asset markerParticleSystem = $"P_ar_loot_drop_point_CP_noZ"

	int markerIndex = GetParticleSystemIndex( markerParticleSystem )
	int markerHandle = StartParticleEffectInWorldWithHandle( markerIndex, ent.GetOrigin(), ent.GetAngles() )
	EffectSetControlPointColorById( markerHandle, 1, colorID )

	OnThreadEnd(
		function() : ( markerHandle )
		{
			EffectStop( markerHandle, true, false )
		}
	)


	vector landPosition = ent.GetOrigin()
	while( DistanceSqr( landPosition, carePackage.GetOrigin() ) > 50 * 50 )
	{
		float distToPlayer = Distance( landPosition, GetLocalViewPlayer().GetOrigin() )
		Wait( .5 )
	}
}


asset function GetHiddenCarePackageIcon()
{
	return Perks_GetSettingsInfoForPerk( ePerkIndex.CARE_PACKAGE_INSIGHT ).icon
}

void function AddCarePackageInsightRui( entity ent, bool revealed )
{
	vector pos 			= ent.GetOrigin()
	asset lootIcon = GetHiddenCarePackageIcon()
	int lootTier = 1
	bool isWeapon = false

	ent.EndSignal( "OnDestroy" )

	if( revealed )
	{
		int lootIndex = 0//ent.GetLootIndex()
		LootData ld = SURVIVAL_Loot_GetLootDataByIndex( lootIndex )
		lootIcon = ld.hudIcon
		lootTier = ld.tier
		isWeapon = ld.lootType == eLootType.MAINWEAPON
	}

	int iconColorID
	switch( lootTier )
	{
		case 0:
			iconColorID = COLORID_HUD_LOOT_TIER0
			break
		case 1:
			iconColorID = COLORID_HUD_LOOT_TIER1
			break
		case 2:
			iconColorID = COLORID_HUD_LOOT_TIER2
			break
		case 3:
			iconColorID = COLORID_HUD_LOOT_TIER3
			break
		case 4:
			iconColorID = COLORID_HUD_LOOT_TIER4
			break
		case 5:
			iconColorID = COLORID_HUD_LOOT_TIER5
			break
		default:
			iconColorID = COLORID_HUD_LOOT_TIER0
			break
	}

	vector iconColor = GetKeyColor( iconColorID ) * ( 1.0 / 255.0 )
	asset button = $"rui/menu/inventory/buttons/border_base_default"
	asset bg = $"rui/menu/inventory/buttons/bg_base"

	float miniMapScale	= 1.0
	float fullMapScale 	= 12

	var minimapRui = Minimap_AddCarePackageInsightIconAtPosition( pos, <0,90,0>, lootIcon, miniMapScale, iconColor ) //0.9
	var fullmapRui = FullMap_AddCarePackageInsightIconAtPos( pos, <0,0,0>, lootIcon, fullMapScale, iconColor ) //6.0

	if( isWeapon )
	{
		RuiSetFloat2( minimapRui, "iconScale", <2.0,1.0,0.0> )
		RuiSetFloat2( fullmapRui, "objectScale", <2.0,1.0,0.0> )
	}

	if( !revealed )
	{
		RevealEntData data
		file.revealEntitiesToData[ent] <- data
	}
	else
	{
		file.revealEntityToRui[ent] <- fullmapRui
		entity carePackage = ent.GetLinkEnt()
		foreach( revealEnt, data in file.revealEntitiesToData )
		{
			if( carePackage == revealEnt.GetLinkEnt() )
			{
				data.revealed = true
			}
		}
	}

	bool addMinimapEnt = true
	if( revealed )
	{
		if( false )
		{
			RuiSetBool( fullmapRui, "contentsTaken", true )
			RuiSetBool( minimapRui, "contentsTaken", true )
			addMinimapEnt = false
		}
		else
		{
			thread ListenToDroppodEmptied( ent, minimapRui, fullmapRui )
		}
	}

	if( addMinimapEnt )
		Perks_AddMinimapEntityForPerk( ePerkIndex.CARE_PACKAGE_INSIGHT, ent )


	OnThreadEnd(
		function() : ( ent, revealed, minimapRui, fullmapRui )
		{
			if( !revealed )
			{
				delete file.revealEntitiesToData[ent]
			}
			else
			{
				delete file.revealEntityToRui[ent]
			}

			RuiSetBool( fullmapRui, "destroy", true )
			Minimap_CommonCleanup( minimapRui )
			Fullmap_RemoveRui( fullmapRui )
		}
	)

	WaitForever()

}

void function UpdateCarePackageLos( entity player )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "CarePackage_PerkDisabled" )

	var soundHandle = null
	while( true )
	{
		if( !IsAlive( player ) )
		{
			Wait( 1 )
			continue
		}

		vector eyePosition = player.EyePosition()
		foreach( ent, data in file.revealEntitiesToData )
		{
			if( data.revealProgress > 0 )
				continue

			entity carePackage = ent.GetLinkEnt()

			if ( !IsValid( carePackage ) )
				continue

			vector wpPosition = carePackage.GetOrigin() +  <0,0,CAREPACKAGE_WAYPOINT_UP_OFFSET>
			TraceResults trace = TraceLine( player.EyePosition(), wpPosition, null, TRACE_MASK_BLOCKLOS, TRACE_COLLISION_GROUP_NONE )
			bool canSee = trace.hitEnt == carePackage || trace.fraction >= 0.99 || trace.hitSky
			file.revealEntitiesToData[ent].hasLos = canSee
		}

		Wait( 1.0 )
	}
}

void function UpdateCarePackageLootAtReveal( entity player )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( player, "CarePackage_PerkDisabled" )

	var soundHandle = null
	while( true )
	{
		if( !IsAlive( player ) || player.IsPhaseShifted() )
		{
			Wait( 1 )
			continue
		}
#if DEV
		if( CARE_PACKAGE_INSIGHT_PERF_TESTING )
		{
			PerfStart( PerfIndexClient.CarePackagePerkLookatUpdate )
		}
#endif

		entity centerEnt = null
		bool traceHitSky = false
		vector eyePosition = player.EyePosition()
		vector viewDir = player.GetViewVector()
		float minDot = deg_cos( Perk_CarePackageInsight_LookAtWideRevealDegrees() )
		float revealDegrees = deg_cos( Perk_CarePackageInsight_LookAtDirectRevealDegrees() )
		bool revealedCarePackage = false

		foreach( ent, data in file.revealEntitiesToData )
		{
			if( !IsValid( ent ) )
				continue

			if( data.revealed && !player.HasPassive( ePassives.PAS_PATHFINDER ) )
				continue

			int playerIndex = player.GetEntIndex()
			if( data.revealProgress >= 1.0 )
			{
				continue
			}

			entity carePackage = ent.GetLinkEnt()

			if ( !IsValid( carePackage ) )
				continue

			vector wpPosition = carePackage.GetOrigin() +  <0,0,CAREPACKAGE_WAYPOINT_UP_OFFSET>
			float dot = DotProduct( Normalize( wpPosition - eyePosition ), viewDir )
			if ( dot < minDot )
			{
				continue
			}

			vector landPos = ent.GetOrigin()
			// allow the player to scan through walls when they are close to the care package drop position or have already started scanning
			float ignoreLosDistance = Perk_CarePackageInsight_IgnoreLosRevealDistance()
			bool ignoreLosCheck = data.revealProgress > 0 || ( DistanceSqr( landPos, eyePosition ) < ignoreLosDistance * ignoreLosDistance && dot > revealDegrees )

			if( !ignoreLosCheck && !data.hasLos )
			{
				continue
			}

			if( centerEnt == null && !ignoreLosCheck )
			{
				vector viewVector = player.GetViewVector()
				TraceResults trace = TraceLine( eyePosition, eyePosition + viewVector * FORWARD_CAST_RAY_LENGTH, null, TRACE_MASK_BLOCKLOS, TRACE_COLLISION_GROUP_NONE )
				centerEnt = trace.hitEnt
				traceHitSky = trace.hitSky
			}

			bool lookingAt = ( traceHitSky && dot > revealDegrees ) || centerEnt == carePackage || ignoreLosCheck

			if( !lookingAt )
			{
				if( dot < revealDegrees )
				{
					continue
				}

				TraceResults trace = TraceLine( player.EyePosition(), wpPosition, null, TRACE_MASK_BLOCKLOS, TRACE_COLLISION_GROUP_NONE )
				bool canSee = trace.hitEnt == carePackage || trace.fraction >= 0.99 || trace.hitSky
				if( !canSee )
				{
					continue
				}
			}

			if( file.revealEntitiesToData[ent].revealProgress == 0.0 )
			{
				Remote_ServerCallFunction( "Perks_CarePackageInsight_ClientToServer_StartRevealPackage", ent )
			}

			file.revealEntitiesToData[ent].revealProgress += ( FrameTime() / Perk_CarePackageInsight_LookatRevealTime() )

			if( soundHandle == null )
				soundHandle = EmitSoundOnEntity( file.soundController, "Skirmisher_PackageScan_Progress_LP_1P" )
			file.soundController.SetSoundCodeControllerValue( file.revealEntitiesToData[ent].revealProgress * 100 )

			revealedCarePackage = true

			if( file.revealEntitiesToData[ent].revealProgress >= 1.0 )
			{
				EmitSoundOnEntity( GetLocalViewPlayer(), "Skirmisher_PackageScan_Complete_1P" )
				Remote_ServerCallFunction( "Perks_CarePackageInsight_ClientToServer_RevealPackage", ent )
				thread ResetRevealIfNotAcked( ent )
			}
			break
		}
		if( !revealedCarePackage && soundHandle != null )
		{
			StopSound( soundHandle )
			soundHandle = null
		}

#if DEV
		if( CARE_PACKAGE_INSIGHT_PERF_TESTING )
		{
			PerfEnd( PerfIndexClient.CarePackagePerkLookatUpdate )
		}
#endif
		WaitFrame()
	}
}

void function ResetRevealIfNotAcked( entity ent )
{
	ent.EndSignal( "OnDestroy" )
	Wait( 2.0 )
	if( ent in file.revealEntitiesToData )
	{
		file.revealEntitiesToData[ent].revealProgress = 0.0
	}
}

bool function Perk_CarePackageInsight_CanPingEnt( entity ent )
{
	return ent.GetScriptName() == REVEALED_CARE_PACKAGE_ENT_NAME
}

entity function GetCarePackageUnderAim( vector worldPos, float worldRange )
{
	entity closestEnt = null
	float closestDistSqr = FLT_MAX
	float worldRangeSqr = worldRange * worldRange
	foreach( ent, rui in file.revealEntityToRui )
	{
		if( !IsValid( ent ) )
			continue
		float distSqr = Distance2DSqr( worldPos, ent.GetOrigin() )
		if( distSqr > worldRangeSqr )
			continue
		if( distSqr > closestDistSqr )
			continue
		closestDistSqr = distSqr
		closestEnt = ent
	}

	if( closestEnt != file.prevHoverEntity )
	{
		if( IsValid( file.prevHoverEntity ) )
		{
			RuiSetBool( file.revealEntityToRui[file.prevHoverEntity], "showContents", false )
		}
		if( closestEnt != null )
			RuiSetBool( file.revealEntityToRui[closestEnt], "showContents", true )
		file.prevHoverEntity = closestEnt
	}

	return closestEnt
}

bool function PingCarePackageUnderAim( entity ent )
{
	entity player = GetLocalClientPlayer()

	if ( !IsValid( player ) || !IsAlive( player ) )
		return false

	if ( !IsPingEnabledForPlayer( player ) )
		return false

	Remote_ServerCallFunction( "Perks_CarePackageInsight_ClientToServer_MinimapIconPinged", ent )

	EmitSoundOnEntity( GetLocalViewPlayer(), PING_SOUND_LOCAL_CONFIRM )

	return true
}

void function Perk_CarePackageInsight_UpdateLookAtRevealRuiVisibility( var rui, entity carePackage )
{
	EndSignal( carePackage, "OnDestroy" )
	EndSignal( carePackage,  "HidePerkMinimapVisibility" )
	clGlobal.levelEnt.EndSignal( "UpdatePerkMinimapVisibility" )

	bool prevWithinGroundRevealDist = false
	while( true )
	{
		entity player = GetLocalViewPlayer()
		float ignoreLosDist = Perk_CarePackageInsight_IgnoreLosRevealDistance()
		bool withinGroundRevealDist = DistanceSqr( player.GetOrigin(), carePackage.GetOrigin() ) < ignoreLosDist * ignoreLosDist
		if( prevWithinGroundRevealDist != withinGroundRevealDist && withinGroundRevealDist && Time() - file.lastRevealPackageHintTime > LOOKAT_HINT_COOLDOWN )
		{
			file.lastRevealPackageHintTime = Time()
			AddPlayerHint( 10, 0, Perks_GetIconForPerk( ePerkIndex.CARE_PACKAGE_INSIGHT ), "#CARE_PACKAGE_INSIGHT_REVEAL_HINT" )
		}
		prevWithinGroundRevealDist = withinGroundRevealDist

		bool shouldHideFromNotPathfinders = !player.HasPassive( ePassives.PAS_PATHFINDER ) && file.revealEntitiesToData[carePackage].revealed
		bool visible = !shouldHideFromNotPathfinders && ( file.revealEntitiesToData[carePackage].hasLos || file.revealEntitiesToData[carePackage].revealProgress > 0 || withinGroundRevealDist )
		if( visible )
		{
			RuiSetBool( rui, "doAdsFade", false )
			RuiSetBool( rui, "isVisibleOverride", true )
			RuiSetBool( rui, "hidePerkIcon", file.revealEntitiesToData[carePackage].hasLos )
		}
		else
		{
			RuiSetBool( rui, "doAdsFade", true )
			RuiSetBool( rui, "isVisibleOverride", false )
			RuiSetBool( rui, "hidePerkIcon", true )
		}

		Wait( 1.0 )
	}
}

void function Perk_CarePackageInsight_UpdateLookatRevealProgressRui( var rui, entity revealEnt )
{
	EndSignal( revealEnt, "OnDestroy" )
	clGlobal.levelEnt.EndSignal( "UpdatePerkMinimapVisibility" )

	if( revealEnt.GetScriptName() == HIDDEN_CARE_PACKAGE_ENT_NAME )
	{
		entity carePackage = revealEnt.GetLinkEnt()
		if( IsValid( carePackage ) )
		{
			RuiTrackFloat3( rui, "pos", carePackage, RUI_TRACK_ABSORIGIN_FOLLOW  )
			thread Perk_CarePackageInsight_UpdateLookAtRevealRuiVisibility( rui, revealEnt )

			float currentProgress = 0
			float targetProgress = 0

			RuiSetFloat( rui, "arcFill", 0.0 )
			RuiSetBool( rui, "clampToScreen", true )
			RuiSetBool( rui, "ignoreDistanceFade", true )
			RuiSetBool( rui, "isUnrevealedCarePackageInsight", true )

			while( currentProgress < 1.0 && revealEnt in file.revealEntitiesToData )
			{
				entity localPlayer = GetLocalViewPlayer()
				targetProgress = file.revealEntitiesToData[revealEnt].revealProgress
				RuiSetFloat( rui, "arcFill", targetProgress )
				WaitFrame()
			}

			revealEnt.WaitSignal( "OnDestroy" )
		}
	}
	else
	{
		entity carePackageEnt = revealEnt.GetLinkEnt()
		if( IsValid( carePackageEnt ) )
		{
			int lootIndex = 0//revealEnt.GetLootIndex()
			LootData ld = SURVIVAL_Loot_GetLootDataByIndex( lootIndex )
			if( ld.lootType == eLootType.MAINWEAPON )
			{
				RuiSetFloat2( rui, "sizeScale", <2.0,1.0,0.0> )
			}
			RuiSetString( rui, "descriptiveTextLocString", ld.pickupString )
			RuiSetImage( rui, "beaconImage", ld.hudIcon )
			RuiSetInt( rui, "lootTier", ld.tier )
			RuiSetFloat( rui, "arcFill", 0.0 )
			RuiSetBool( rui, "playConfirmAnim", true )
			RuiSetBool( rui, "clampToScreen", false )
			RuiSetBool( rui, "isVisibleOverride", true )
			RuiSetBool( rui, "isRevealedCarePackageInsight", true )

			// highlight the icon if we are already looking at it so that it doesn't pop for a single frame
			entity player = GetLocalViewPlayer()

			vector viewVector = player.GetViewVector()
			vector eyePosition = player.EyePosition()
			vector carePackagePos = carePackageEnt.GetOrigin()
			vector dirToCarePackage = Normalize( carePackagePos - eyePosition )
			if( DotProduct( dirToCarePackage, viewVector ) > deg_cos( PERK_HIGHLIGHT_DEGREES ) )
			{
				Perks_SetHighlightedPerkIcon( revealEnt, ePerkIndex.CARE_PACKAGE_INSIGHT )
			}

			thread Perk_CarePackageInsight_ResetRevealDistance( rui, revealEnt )
			RuiTrackFloat3( rui, "pos", carePackageEnt, RUI_TRACK_ABSORIGIN_FOLLOW  )
		}
	}
}

void function Perk_CarePackageInsight_ResetRevealDistance( var rui, entity revealEnt )
{
	revealEnt.EndSignal( "OnDestroy" )
	revealEnt.EndSignal( "Perk_CarePackageInsight_ContentsTaken" )
	revealEnt.EndSignal( "HidePerkMinimapVisibility" )
	clGlobal.levelEnt.EndSignal( "UpdatePerkMinimapVisibility" )

	RuiSetFloat( rui, "minAlphaDist", 999999 )
	RuiSetFloat( rui, "maxAlphaDist", 999999 )
	file.recentlyRevealedEntities.append( revealEnt )

	OnThreadEnd(
		function() : ( revealEnt )
		{
			file.recentlyRevealedEntities.fastremovebyvalue( revealEnt )
		}
	)

	wait( 10 )

	RuiSetFloat( rui, "minAlphaDist", 3000 )
	RuiSetFloat( rui, "maxAlphaDist", 4000 )
}

void function Perk_CarePackageInsight_WaitForContentsTaken( entity carePackage )
{
	if( !IsValid( carePackage ) )
		return

	carePackage.EndSignal( "OnDestroy" )

	carePackage.WaitSignal( "Perk_CarePackageInsight_ContentsTaken" )
	ServerToClient_HidePerkPropMinimapVisibility( carePackage, ePerkIndex.CARE_PACKAGE_INSIGHT )
}

float function Perk_CarePackageInsight_GetPingDistanceForEnt( entity ent )
{
	if( file.recentlyRevealedEntities.contains( ent ) )
		return 999999
	return PERK_ENT_MAX_PING_DISTANCE
}

vector function Perk_CarePackageInsight_GetPingPositionForEnt( entity ent )
{
	entity carePackageEnt = ent.GetLinkEnt()
	if ( !IsValid( carePackageEnt ) )
		return <0, 0, 0>

	return carePackageEnt.GetOrigin()
}

void function ListenToDroppodEmptied( entity droppod, var minimapRui, var fullmapRui )
{
	droppod.EndSignal( "OnDestroy" )
	droppod.WaitSignal( "Perk_CarePackageInsight_ContentsTaken" )

	RuiSetBool( fullmapRui, "contentsTaken", true )
	RuiSetBool( minimapRui, "contentsTaken", true )
	ServerToClient_HidePerkPropMinimapVisibility( droppod, ePerkIndex.CARE_PACKAGE_INSIGHT )
}

void function ServerToClient_NotifyPathfinderCooldownReduction()
{
	entity localViewPlayer = GetLocalViewPlayer()
	if ( IsValid( localViewPlayer ) && PlayerHasPassive( localViewPlayer, ePassives.PAS_PATHFINDER ) )
	{
		HidePlayerHint( "#CARE_PACKAGE_INSIGHT_REVEAL_HINT" )
		string hintStr = "#SURVEY_PATHFINDER_SUCCESS"


		if( UpgradeCore_IsEnabled() )
		{
			hintStr = "#SURVEY_PATHFINDER_SUCCESS_UPGRADED"
		}


		AddPlayerHint( 2.5, 0.25, $"rui/hud/ultimate_icons/ultimate_pathfinder", hintStr )
	}
}

#endif // CLIENT

#if SERVER
#if DEV
void function DeleteCarepackagePerkLinks()
{
	foreach( ent, carePackageData in file.carePackageArray )
	{
		if ( !IsValid( ent ) )
			continue

		array< entity > linkParents = ent.GetLinkParentArray()
		for ( int i = linkParents.len() - 1; i >= 0; i-- )
		{
			linkParents[ i ].Destroy()
		}


	}

	file.carePackageArray.clear()
}
#endif
#endif