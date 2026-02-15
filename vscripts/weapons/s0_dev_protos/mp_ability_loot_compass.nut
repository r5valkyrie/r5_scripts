
//TODO: Still need to support directing the player to Loot Bins, Death Boxes, and Ticks

global function MpAbilityLootCompass_Init

global function OnWeaponChargeBegin_ability_loot_compass
global function OnWeaponChargeEnd_ability_loot_compass
global function OnWeaponPrimaryAttack_ability_loot_compass

void function MpAbilityLootCompass_Init()
{
	#if CLIENT
		RegisterSignal( "LootCompassStop" )
	#endif
}

bool function OnWeaponChargeBegin_ability_loot_compass( entity weapon )
{
	#if CLIENT
	if ( IsFirstTimePredicted() )
	{
		thread LootCompassThink( weapon )
	}
	#endif

	#if SERVER
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( weaponOwner.IsPlayer() )
		PlayerUsedOffhand( weaponOwner, weapon )
	#endif

	return true
}

void function OnWeaponChargeEnd_ability_loot_compass( entity weapon )
{
	#if CLIENT
	if ( IsFirstTimePredicted() )
	{
		weapon.Signal( "LootCompassStop" )
	}
	#endif
}

var function OnWeaponPrimaryAttack_ability_loot_compass( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return 0
}

#if CLIENT
void function LootCompassThink( entity weapon )
{
	weapon.EndSignal( "LootCompassStop" )
	weapon.EndSignal( "OnDestroy" )

	entity localViewPlayer = GetLocalViewPlayer()

	float startTime = Time()
	var rui = RuiCreate( $"ui/loot_compass.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 0 )
	RuiSetResolutionToScreenSize( rui )
	RuiSetGameTime( rui, "startTime", startTime )

	OnThreadEnd(
	function() : ( rui )
		{
			RuiDestroy( rui )
		}
	)

	int count = 20
	bool lootFound = true
	int itemSurvivalint
	vector lootPos
	while( true )
	{
		++count
		vector cameraPos = GetLocalViewPlayer().CameraPosition()
		if ( count > 20 )
		{
			// array<entity> nearbyLoot = GetSurvivalLootNearbyPos( cameraPos, 3000, false, true )
			array<entity> nearbyLoot = GetSurvivalLootNearbyPlayer( localViewPlayer, 3000, false, true ) //Cafe was here
			lootFound = nearbyLoot.len() > 0
			if ( lootFound )
			{
				nearbyLoot.sort( SortByLootTierFromEntity )
				array<entity> topTierLoot
				int maxTier = SURVIVAL_Loot_GetLootDataByIndex( nearbyLoot[0].GetSurvivalInt() ).tier
				for( int i = 0; i < nearbyLoot.len(); i++ )
				{
					if ( SURVIVAL_Loot_GetLootDataByIndex( nearbyLoot[i].GetSurvivalInt() ).tier == maxTier )
					{
						topTierLoot.append( nearbyLoot[i] )
					}
					else
					{
						break
					}
				}
				topTierLoot = ArrayClosest( topTierLoot, cameraPos )
				entity item = topTierLoot[ 0 ]
				lootPos = item.GetOrigin()
				itemSurvivalint = item.GetSurvivalInt()
			}
			else
			{
				float elapsedTime = Time() - startTime
				lootPos = cameraPos + < sin( elapsedTime ), cos( elapsedTime ), 0 >
			}
			count = 0
		}

		vector vecToDamage = lootPos - cameraPos
		vecToDamage.z = 0
		vecToDamage = Normalize( vecToDamage )
		RuiSetFloat( rui, "distance", Distance2D( lootPos, cameraPos ) )
		RuiSetFloat3( rui, "vecToDamage2D", vecToDamage )
		RuiSetFloat3( rui, "camVec2D", Normalize( AnglesToForward( <0, GetLocalViewPlayer().CameraAngles().y, 0> ) ) )
		RuiSetFloat( rui, "sideDot", vecToDamage.Dot( CrossProduct( <0,0,1>, Normalize( AnglesToForward( <0, GetLocalViewPlayer().CameraAngles().y, 0> ) ) ) ) )
		RuiSetBool( rui, "lootFound", lootFound )

		if ( lootFound )
		{
			LootData itemData = SURVIVAL_Loot_GetLootDataByIndex( itemSurvivalint )
			RuiSetAsset( rui, "lootImage", itemData.hudIcon )//GetItemImage( itemData.ref ) )
			vector color = GetFXRarityColorForTier( itemData.tier )
			RuiSetFloat3( rui, "lootColor", color / 255 ) //-1 is since the client part of this function isn't using the same enum as the server.
			RuiSetBool( rui, "isWeapon", itemData.lootType == eLootType.MAINWEAPON )
		}
		else
		{
			RuiSetAsset( rui, "lootImage", $"" )
			RuiSetFloat3( rui, "lootColor", GetFXRarityColorForTier( eLootTier.COMMON ) / 255 )//-1 is since the client part of this function isn't using the same enum as the server.
			RuiSetBool( rui, "isWeapon", false )
		}

		WaitFrame()
	}
}

int function SortByLootTierFromEntity( entity a, entity b )
{
	LootData aData = SURVIVAL_Loot_GetLootDataByIndex( a.GetSurvivalInt() )
	LootData bData = SURVIVAL_Loot_GetLootDataByIndex( b.GetSurvivalInt() )

	if ( aData.tier == bData.tier )
		return 0

	if ( aData.tier > bData.tier )
		return -1

	else if ( aData.tier < bData.tier )
		return 1

	unreachable
}
#endif