global function OnWeaponPrimaryAttack_care_package_medic
#if SERVER
global function AbilityCarePackage_SetContentOverrideCallback
#endif
                   
	#if SERVER
	global function GenerateSmartCarePackageContents
	global function AbilityCarePackage_SetNextUltIsCarePackage
	#endif
      

struct AirdropContents
{
	array<string> left
	array<string> right
	array<string> center
}

struct LootPool
{
	// tables will hold the lowest-tier pieces of loot among equippable things
	table< string, int > equipmentTable
	table< string, int > attachmentTable

	array<string> armorLootGroup
	array<string> equipmentLootGroup
	array<string> attachmentsLootGroup
}

enum eLootPoolType
{
	ARMOR
	OTHER_EQUIPMENT
	ATTACHMENTS
	SMALL_CONSUMABLE
	LARGE_CONSUMABLE
	DEAD

	_count
}

struct
{
	array<string> validSlots = [
		"armor",
		"helmet",
		"incapshield",
		"backpack",
	]
#if SERVER
	array< array<string> >  functionref( entity player ) CarePackageContentsOverrideCallback = null
	                    
		table<entity, bool> shouldDropCarePackage
       
#endif
} file

var function OnWeaponPrimaryAttack_care_package_medic( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	CarePackagePlacementInfo placementInfo = GetCarePackagePlacementInfo( ownerPlayer )

	if ( placementInfo.failed )
		return 0

	#if SERVER
		vector origin = placementInfo.origin
		vector angles = placementInfo.angles

		AirdropItemsOptionalInfo optionInfo
		                            
			if ( GetCurrentPlaylistVarBool( "lifeline_res_slow_disabled", true ) )
			{
				optionInfo.animationName = "droppod_loot_drop_lifeline_fast"
			}
			else
        
			{
				optionInfo.animationName = "droppod_loot_drop_lifeline"
			}
		optionInfo.owner = ownerPlayer
		optionInfo.team = ownerPlayer.GetTeam()
		optionInfo.skin = GetSkinForCarePackageModel( optionInfo.owner )
		optionInfo.targetName = CARE_PACKAGE_LIFELINE_TARGETNAME
		optionInfo.sourceWeaponClassname = weapon.GetWeaponClassName()

		array< array<string> > contents
		if ( file.CarePackageContentsOverrideCallback != null)
			contents = file.CarePackageContentsOverrideCallback(ownerPlayer)
		else
			optionInfo.delayedContentFunc = GenerateSmartCarePackageContents

		if( PlayerHasPassive( ownerPlayer, ePassives.PAS_ULT_UPGRADE_ONE ) && ownerPlayer in file.shouldDropCarePackage )
		{
                                      
			contents = GenerateGoldLootPackageContents(weapon.GetWeaponOwner())
			delete file.shouldDropCarePackage[ownerPlayer]
       
                                      
                                                 
                                                                                                                       
                                                                                                                  
                          
                                                                                
                      
                                                          
                                                  
        
		}
		{
			thread CreateCarePackageAirdrop( origin, angles, contents, optionInfo )
		}


		PlayBattleChatterLineToSpeakerAndTeam( ownerPlayer, "bc_super" )

		PlayerUsedOffhand( ownerPlayer, weapon, true, null, {pos = origin} )
	#else
		PlayerUsedOffhand( ownerPlayer, weapon )
		SetCarePackageDeployed( true )
		ownerPlayer.Signal( "DeployableCarePackagePlacement" )
	#endif

	int ammoReq = weapon.GetAmmoPerShot()
	return ammoReq
}

#if SERVER
void function AbilityCarePackage_SetNextUltIsCarePackage( entity player )
{
	file.shouldDropCarePackage[player] <- true
}

array< array<string> > function GenerateSmartCarePackageContents( AirdropItemsOptionalInfo optionInfo )
{
	LootPool pool

	array<entity> teammates = GetPlayerArrayOfTeam_Alive( optionInfo.team )
	table<string, EquipmentSlot> equipmentSlots = EquipmentSlot_GetAllEquipmentSlots()

	//get "tester" attachments to see if the weapon will take those attachments
	array<LootData> barrelAttachmentsData = LootHelper_GetAttachmentData_OfType_OfTier( eWeaponAttachmentType.BARREL, 1 )
	array<LootData> gripAttachmentsData = LootHelper_GetAttachmentData_OfType_OfTier( eWeaponAttachmentType.STOCK, 1 )
	array<LootData> magAttachmentsData =  LootHelper_GetAttachmentData_OfType_OfTier( eWeaponAttachmentType.MAG, 1 )

	if ( teammates.len() <= 0 )
		return DetermineAirdropContents( [ FillAirdropDoor( pool, eLootPoolType.DEAD ), FillAirdropDoor( pool, eLootPoolType.DEAD ), FillAirdropDoor( pool, eLootPoolType.DEAD ) ] )

	foreach (entity teammate in teammates )
	{
		// Populate Equipment table
		foreach ( slot, slotData in equipmentSlots )
		{
			if ( !file.validSlots.contains( slot ) )
				continue

			int equipmentTier = EquipmentSlot_GetEquipmentTier( teammate, slot )
			if ( !(slot in pool.equipmentTable) || equipmentTier < pool.equipmentTable[ slot ] )
				pool.equipmentTable[ slot ] <- equipmentTier

		}

		// Populate Attachment table
		foreach ( entity weapon in SURVIVAL_GetPrimaryWeapons( teammate ) )
		{
			LootData weaponData = SURVIVAL_GetLootDataFromWeapon( weapon )

			if ( SURVIVAL_Weapon_IsAttachmentLocked( weaponData.ref ) )
				continue

			array<string> attachments 	= weaponData.supportedAttachments

			foreach ( attachmentName in attachments )
			{
				// get the current tier of the attachment at that point
				int attachmentTier = 0
				string mod = GetInstalledWeaponAttachmentForPoint( weapon, attachmentName )
				if ( SURVIVAL_Loot_IsRefValid( mod ) )
				{
					LootData attachmentData = SURVIVAL_Loot_GetLootDataByRef( mod )
					attachmentTier = attachmentData.tier
				}

				// need to rename things here because the name of the attachment does not match the name of the loot like it does with equipment
				string attachmentLootRefPrefix = ""
				array<string> splitRef = []
				array<LootData> attachmentsDataOfType

				switch ( attachmentName )
				{
					case "barrel":
						attachmentsDataOfType = barrelAttachmentsData
						break
					case "mag":
						attachmentsDataOfType = magAttachmentsData
						break
					case "grip":
						attachmentsDataOfType = gripAttachmentsData
						break
					default:
						break
				}

				foreach ( attachment in attachmentsDataOfType )
				{
					AttachmentData attachmentData = GetAttachmentData( attachment.ref )
					if ( attachmentData.compatibleWeapons.contains( weaponData.ref ) )
					{
						splitRef = split( attachment.ref, "1" )

						if ( splitRef.len() <= 0 )
							continue

						attachmentLootRefPrefix = splitRef[ 0 ]

						if ( !(attachmentLootRefPrefix in pool.attachmentTable) || attachmentTier < pool.attachmentTable[ attachmentLootRefPrefix ] )
							pool.attachmentTable[ attachmentLootRefPrefix ] <- attachmentTier
					}
				}

			}

		}

	}

	string lootStr

	// Validate higher-tier loot possibility for Attachments
	foreach ( string attachmentRef, int attachmentTier in pool.attachmentTable )
	{
		if ( attachmentTier > eLootTier.LEGENDARY )
			continue

		lootStr = attachmentRef + maxint( ( attachmentTier + 1), eLootTier.RARE ) // want to grant a piece of loot that is Rare or +1 tier better than their current

		if ( SURVIVAL_Loot_IsRefValid( lootStr ) && !SURVIVAL_Loot_IsRefDisabled( lootStr ) )
			pool.attachmentsLootGroup.append( lootStr )
	}

	// Validate higher-tier loot possibility for Equipment
	foreach ( string equipmentRef, int equipmentTier in pool.equipmentTable )
	{
		string suffix 	= ""
		int targetTier 	= maxint( ( equipmentTier + 1), eLootTier.RARE ) // want to grant a piece of loot that is Rare or +1 tier better than their current

		// seperate armor into its own loot pool (we can modify this later if we like)
		if ( equipmentRef == "armor" )
		{
			// not allowing Red armor - should be earned through EVO
			if ( targetTier > eLootTier.LEGENDARY )
				continue

			if ( targetTier == eLootTier.LEGENDARY )
				suffix = "_all_fast"
			else if ( GetCurrentPlaylistVarBool( "lifeline_spawns_evolving_armor", false ) )
				suffix = "_evolving"

			lootStr = equipmentRef + "_pickup_lv" + targetTier + suffix

			if ( SURVIVAL_Loot_IsRefValid( lootStr ) && !SURVIVAL_Loot_IsRefDisabled( lootStr ) )
				pool.armorLootGroup.append( lootStr )
		}
		else
		{
			// no Heirloom-level equipment, skip
			if ( targetTier > eLootTier.LEGENDARY )
				continue

			if ( targetTier == eLootTier.LEGENDARY )
			{
				switch ( equipmentRef )
				{
					case "incapshield" :
						suffix = "_selfrevive"
						break
					case "helmet" :
						suffix = "_abilities"
						break
					case "backpack" :
						suffix = "_revive_boost"
						break
				}
			}

			lootStr = equipmentRef + "_pickup_lv" + targetTier + suffix

			if ( SURVIVAL_Loot_IsRefValid( lootStr ) && !SURVIVAL_Loot_IsRefDisabled( lootStr ) )
				pool.equipmentLootGroup.append( lootStr )
		}
	}

	AirdropContents contents
	                    
	if( UpgradeCore_ArmorTiedToUpgrades() )
	{
		// 50/50 roll, RandomInt is exclusive of the upper range, which is why we are using 2 instead of 1
		bool shouldSpawnEquipment = RandomInt( 2 ) > 0
		if( shouldSpawnEquipment )
		{
			contents.right = FillAirdropDoor( pool, eLootPoolType.OTHER_EQUIPMENT )
		}
		else
		{
			contents.right = FillAirdropDoor( pool, eLootPoolType.LARGE_CONSUMABLE )
		}
	}
	else
       
		contents.right = FillAirdropDoor( pool, eLootPoolType.ARMOR )
	contents.left = FillAirdropDoor( pool, eLootPoolType.OTHER_EQUIPMENT )
	contents.center = FillAirdropDoor( pool, eLootPoolType.ATTACHMENTS )
	return DetermineAirdropContents( [ contents.left, contents.center, contents.right ] )
}

                                    
const string LIFELINE_UPGRADE_LOOTGROUP_ITEM_1_DOOR_1 = "lifeline_upgrade_carepackage_item_1_door_1"
const string LIFELINE_UPGRADE_LOOTGROUP_ITEM_2_DOOR_1 = "lifeline_upgrade_carepackage_item_2_door_1"
const string LIFELINE_UPGRADE_LOOTGROUP_ITEM_2_ALT_DOOR_1 = "lifeline_upgrade_carepackage_item_2_alt_door_1"
const string LIFELINE_UPGRADE_LOOTGROUP_DOOR_2 = "lifeline_upgrade_carepackage_door_2"
const string LIFELINE_UPGRADE_LOOTGROUP_DOOR_3 = "lifeline_upgrade_carepackage_door_3"
#if DEVELOPER
const int EXPECTED_ITEM_COUNT_PER_DOOR = 2
#endif // DEV
array< array<string> > function GenerateGoldLootPackageContents( entity player )
{
	bool assureMobi = false
	if( IsValid( player) )
	{
		int alliesAlive = GetPlayerArrayOfTeam_Alive( player.GetTeam() ).len()
		assureMobi = alliesAlive < GetPlayerArrayOfTeam( player.GetTeam() ).len()
		printt("Allies alive? " + alliesAlive)
	}

	array < array<string> > contents
	for(int i = 0; i < 3; i++)
	{
		array <string> door
		if( i == 0 )
		{
			door.append( SURVIVAL_GetWeightedItemFromGroup( LIFELINE_UPGRADE_LOOTGROUP_ITEM_1_DOOR_1 ) )
			door.append( assureMobi ? SURVIVAL_GetWeightedItemFromGroup( LIFELINE_UPGRADE_LOOTGROUP_ITEM_2_DOOR_1 ) : SURVIVAL_GetWeightedItemFromGroup( LIFELINE_UPGRADE_LOOTGROUP_ITEM_2_ALT_DOOR_1 ) )
		}
		else if( i == 1 )
		{
			door = SURVIVAL_GetAllRefsInLootGroup( LIFELINE_UPGRADE_LOOTGROUP_DOOR_2, true )
		}
		else
		{
			door = SURVIVAL_GetAllRefsInLootGroup( LIFELINE_UPGRADE_LOOTGROUP_DOOR_3, true )
		}

		#if DEVELOPER
			Assert( door.len() == EXPECTED_ITEM_COUNT_PER_DOOR, "Expect " + EXPECTED_ITEM_COUNT_PER_DOOR + " per door in " + FUNC_NAME() + " but got " + door.len() + ", this is likely caused by loot group overrides or disabling an item that is normally included." )
		#endif // DEV

		contents.append(door)
	}
	return contents
}
      

                     
                                                                       
 
                                 
                           
  
                     
                            
   
                                                
   
                       
  
                
 
      

array<string> function FillAirdropDoor( LootPool contentPool, int lootPoolType )
{
	// In modes with all healing items disabled, Health_1 ends up getting removed.  Use lifeline_carepackage_midloot_override as backup
	string fillerGroup = "top_tier_health"
	if( !SURVIVAL_IsValidLootGroup( fillerGroup ) )
		fillerGroup = GetCurrentPlaylistVarString( "lifeline_carepackage_midloot_override", fillerGroup )

	array<string> doorContents

	switch ( lootPoolType )
	{
		case eLootPoolType.ARMOR:
			if ( contentPool.armorLootGroup.len() > 0 )
			{
				if ( contentPool.armorLootGroup.contains( "armor_pickup_lv4_all_fast" ) )
					doorContents.append( "care_package_final_armor_or_health" )
				else
					doorContents.append( LootHelper_GetRandomLootRefFromGroupAndRemove( contentPool.armorLootGroup ) )
			}
			else
			{
				return FillAirdropDoor( contentPool, eLootPoolType.LARGE_CONSUMABLE )
			}
			break

		case eLootPoolType.OTHER_EQUIPMENT:
			if ( contentPool.equipmentLootGroup.len() > 0 )
			{
				doorContents.append( LootHelper_GetRandomLootRefFromGroupAndRemove( contentPool.equipmentLootGroup ) )
				doorContents.append( "top_tier_health" )
			}
			else
			{
				return FillAirdropDoor( contentPool, eLootPoolType.LARGE_CONSUMABLE )
			}
			break

		case eLootPoolType.ATTACHMENTS:
			if ( contentPool.attachmentsLootGroup.len() > 0 )
			{
				doorContents.append( LootHelper_GetRandomLootRefFromGroupAndRemove( contentPool.attachmentsLootGroup ) )
				doorContents.append( "shield_battery" )
			}
			else
			{
				return FillAirdropDoor( contentPool, eLootPoolType.LARGE_CONSUMABLE )
			}
			break

		case eLootPoolType.LARGE_CONSUMABLE:
			doorContents.append( "top_tier_health" )
			doorContents.append( "shield_battery" )
			break

		case eLootPoolType.SMALL_CONSUMABLE:
			doorContents.append( fillerGroup )
			doorContents.append( fillerGroup )
			doorContents.append( fillerGroup )
			break

		case eLootPoolType.DEAD:
			doorContents.append( "mp_ability_mobile_respawn_beacon" )
			break
	}

	return doorContents
}

array< array<string> > function GenerateCarePackageContents( )
{
	array<string> firstSlot = [GetCurrentPlaylistVarString( "lifeline_carepackage_superslot_override", "medic_super" )]
	array<string> lastSlot
	array<string> midSlot
	array<string> lastLoots = SURVIVAL_GetMultipleWeightedItemsFromGroup( "top_tier_inventory", 2 )

	bool hasNonAttachment = false
	foreach ( loot in lastLoots )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByRef( loot )
		if ( data.lootType != eLootType.ATTACHMENT )
		{
			hasNonAttachment = true
			lastSlot = [ loot ]
			break
		}
	}

	if ( !hasNonAttachment )
		lastSlot = lastLoots

	string groupRef = "medic_super_side"
	if ( GetCurrentPlaylistVarString( "lifeline_carepackage_midloot_override", "" ) != "" )
		groupRef = GetCurrentPlaylistVarString( "lifeline_carepackage_midloot_override", "" )
	array<string> midLoots = SURVIVAL_GetMultipleWeightedItemsFromGroup( groupRef, 3 )

	bool hasNonMed = false
	foreach ( loot in midLoots )
	{
		LootData data = SURVIVAL_Loot_GetLootDataByRef( loot )
		if ( data.lootType != eLootType.HEALTH )
		{
			hasNonMed = true
			midSlot = [ loot ]
			break
		}
	}

	if ( !hasNonMed )
		midSlot = midLoots

	AirdropContents contents
	contents.left = firstSlot
	contents.right = midSlot
	contents.center = lastSlot
	return [ contents.left, contents.center, contents.right ]
}
#endif //SERVER

#if SERVER
void function AbilityCarePackage_SetContentOverrideCallback(array< array<string> > functionref( entity player ) func )
{
	file.CarePackageContentsOverrideCallback = func
}
#endif


