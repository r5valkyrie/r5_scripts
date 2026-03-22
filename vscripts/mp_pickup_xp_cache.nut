                    
global function Pickup_XP_Cache_Init

// XPCACHE constants moved to sh_consts.gnut for shared access

global enum eEvoCacheType
{
	EVO_CACHE_SMALL,
	EVO_CACHE_LARGE,
	EVO_CACHE_DYNAMIC,
	Count
}

// Pickup Audio is controlled through the survival_loot.csv
void function Pickup_XP_Cache_Init()
{
	#if SERVER || CLIENT
		RegisterCustomItemPickupAction( XPCACHE_BASIC_NAME, XPCache_ItemPickup )
		RegisterCustomItemPickupAction( XPCACHE_LARGE_NAME, XPCache_ItemPickup )
		RegisterCustomItemPickupAction( XPCACHE_ENHANCED_NAME, XPCache_ItemPickup )
	#endif
}


bool function XPCache_ItemPickup( entity pickup, entity player, int pickupFlags, entity deathBox, int ornull desiredCount, LootData data )
{
	#if SERVER
		//Give XP Points
		if( UpgradeCore_IsEnabled() )
		{
			switch( pickup.e.lootRef )
			{
				case XPCACHE_BASIC_NAME:
					UpgradeCore_Redeem_XP_Cache( player, pickup, eEvoCacheType.EVO_CACHE_SMALL )
					break
				case XPCACHE_LARGE_NAME:
					UpgradeCore_Redeem_XP_Cache( player, pickup, eEvoCacheType.EVO_CACHE_LARGE )
					break
				case XPCACHE_ENHANCED_NAME:
					UpgradeCore_Redeem_XP_Cache( player, pickup, eEvoCacheType.EVO_CACHE_DYNAMIC )
					break
			}
		}
	#endif

	return true
}

                          