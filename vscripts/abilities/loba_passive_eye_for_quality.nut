// eye for koalaty
#if SERVER || CLIENT || UI
global function ShLobaPassiveEyeForQuality_LevelInit

global function GetEyeForQualityRadius
global function GetEyeForQualityCanSee
#endif


#if SERVER || CLIENT || UI
void function ShLobaPassiveEyeForQuality_LevelInit()
{
	#if SERVER
		AddPingCallbackForType( ePingType.LOOT, OnLootPinged )
	#endif

	#if SERVER || CLIENT
		RegisterSignal( "LobaPassiveEyeForQuality_StopThink" )
		AddCallback_OnPassiveChanged( ePassives.PAS_LOBA_EYE_FOR_QUALITY, OnPassiveChanged )
	#endif

	#if CLIENT
		AddCreateCallback( "player", OnPlayerCreated )
		//AddCallback_OnLootBinOpening( OnLootBinOpening )
	#endif


	#if CLIENT || UI
		AddCallback_EditLootDesc( Loba_EditUALootDesc )
	#endif
}
#endif


#if SERVER || CLIENT
void function OnPassiveChanged( entity player, int passive, bool didHave, bool nowHas )
{
	if ( didHave )
	{
		Signal( player, "LobaPassiveEyeForQuality_StopThink" )
	}

	if ( nowHas )
	{
		#if SERVER
			thread ServerThinkThread( player )
		#elseif CLIENT
			thread ClientThinkThread( player )
		#endif
	}
}
#endif

#if CLIENT || UI
string function Loba_EditUALootDesc( string lootRef, entity player, string originalDesc )
{
	string finalDesc = originalDesc

	// (Also, we can't use PlayerHasPassive here because it's not available in the UI VM.)
	if ( lootRef == "health_pickup_ultimate"
			&& IsValid( player )
			&& LoadoutSlot_IsReady( ToEHI( player ), Loadout_CharacterClass() )
			&& ItemFlavor_GetAsset( LoadoutSlot_GetItemFlavor( ToEHI( player ), Loadout_CharacterClass() ) ) == $"settings/itemflav/character/loba.rpak" )
	{
		finalDesc = Localize( "#SURVIVAL_PICKUP_HEALTH_ULTIMATE_HINT_LOBA" )
	}
	return finalDesc
}
#endif


#if CLIENT
void function OnPlayerCreated( entity player )
{
	// For spectator and respawning (player entity is deleted and recreated). To fix R5DEV-139661 .
	if ( player == GetLocalClientPlayer() || player == GetLocalViewPlayer() )
	{
		bool hasPassive = PlayerHasPassive( player, ePassives.PAS_LOBA_EYE_FOR_QUALITY )
		OnPassiveChanged( player, ePassives.PAS_LOBA_EYE_FOR_QUALITY, hasPassive, hasPassive )
	}
}
#endif


#if SERVER
void function ServerThinkThread( entity player )
{
	EndSignal( player, "OnDestroy" )
	Signal( player, "LobaPassiveEyeForQuality_StopThink" )
	EndSignal( player, "LobaPassiveEyeForQuality_StopThink" )

	float range = GetEyeForQualityRadius()

	while ( true )
	{
		//if ( Survival_HasPlayerJumpedOutOfPlane( player ) )
			//TriggerLootSpawnForLootBinsInRadius( player.EyePosition(), range, eLootTier.EPIC )//TODO: FIX BINS
		wait 0.4
	}
}
#endif


#if CLIENT
void function ClientThinkThread( entity player )
{
	EndSignal( player, "OnDestroy" )
	Signal( player, "LobaPassiveEyeForQuality_StopThink" )
	EndSignal( player, "LobaPassiveEyeForQuality_StopThink" )

	if ( player != GetLocalViewPlayer() )
		return

	float range = GetEyeForQualityRadius()

	EntitySet currLootSet

	OnThreadEnd( void function() : ( currLootSet ) {
		foreach ( entity loot, void _ in currLootSet )
		{
			if ( !IsValid( loot ) )
				continue

			loot.e.eyeForQuality_isScanned = false
			SURVIVAL_Loot_UpdateHighlightForLoot( loot )
		}
	} )

	while ( true )
	{
		EntitySet noLongerExistingLootSet = clone currLootSet
		currLootSet.clear()

		array<entity> newLootList
		if ( IsAlive( player ) )
			newLootList = GetSurvivalLootNearbyPlayer( player, range, false, false )

		foreach ( entity loot in newLootList )
		{
			if ( loot in noLongerExistingLootSet )
				delete noLongerExistingLootSet[loot]

			currLootSet[loot] <- IN_SET

			if ( !loot.e.eyeForQuality_isScanned )
			{
				loot.e.eyeForQuality_isScanned = true
				SURVIVAL_Loot_UpdateHighlightForLoot( loot )
				loot.SetFadeDistance( range )
			}
		}

		foreach ( entity noLongerExistingLoot, void _ in noLongerExistingLootSet )
		{
			if ( !IsValid( noLongerExistingLoot ) )
				continue

			noLongerExistingLoot.e.eyeForQuality_isScanned = false
			SURVIVAL_Loot_UpdateHighlightForLoot( noLongerExistingLoot )

			float fadeDist = 2000.0
			if ( SURVIVAL_Loot_IsLootIndexValid( noLongerExistingLoot.GetSurvivalInt() ) )
				fadeDist = GetFadeDistForLoot( SURVIVAL_Loot_GetLootDataByIndex( noLongerExistingLoot.GetSurvivalInt() ) )
			noLongerExistingLoot.SetFadeDistance( fadeDist )
		}

		WaitFrame()
	}
}
#endif


#if CLIENT
void function OnLootBinOpening( entity lootBin )
{
	if ( !PlayerHasPassive( GetLocalViewPlayer(), ePassives.PAS_LOBA_EYE_FOR_QUALITY ) )
		return

	if ( !IsValid( lootBin ) )
		return

	if ( !lootBin.DoesShareRealms( GetLocalViewPlayer() ) )
		return

	//array<entity> loot = LootBin_GetSpawnedLoot( lootBin, true, true )
	//thread FadeLootBinLootHighlightsOutThenIn( loot )
}
#endif


#if CLIENT
void function FadeLootBinLootHighlightsOutThenIn( array<entity> loot )
{
	/*foreach ( entity lootEnt in loot )
	{
		if ( !IsValid( lootEnt ) )
			continue

		lootEnt.Highlight_SetVisibilityType( HIGHLIGHT_VIS_LOS )
		lootEnt.Highlight_SetFadeInTime( 0.1 )
		lootEnt.Highlight_SetFadeOutTime( 0.1 )
	}

	wait 0.5

	foreach ( entity lootEnt in loot )
	{
		if ( !IsValid( lootEnt ) )
			continue

		SURVIVAL_Loot_UpdateHighlightForLoot( lootEnt )
	}*/
}
#endif


#if SERVER
void function OnLootPinged( entity player, entity wp, entity pingEnt, int pingType )
{
	if ( !PlayerHasPassive( player, ePassives.PAS_LOBA_EYE_FOR_QUALITY ) )
		return

	//StatsHook_EyeForQuality_OnLootPinged( player, pingEnt )
}
#endif


#if SERVER || CLIENT || UI
float function GetEyeForQualityRadius()
{
	return GetCurrentPlaylistVarFloat( "loba_pas_eye_for_quality_range", 4500.0 )
}

bool function GetEyeForQualityCanSee( LootData data )
{
	if ( data.tier - 1 >= eQuality.EPIC )
		return true

	                    
		if ( data.ref.find( "hopup_golden_horse" ) != -1 )
			return true
       


	return false
}
#endif