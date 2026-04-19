const string MUNITIONS_BOX_SCRIPT_NAME = "assault_perk_loot_bin"
global const string MUNITIONS_BOX_LOOT_BIN_SKIN_NAME = "MunitionsBox"

const int HOP_UP_DROP_CHANCE = 20
const int MAG_DROP_CHANCE = 65
const int PURPLE_DROP_CHANCE = 20
const int BLUE_DROP_CHANCE = 100

const int HOP_UP_TIER = 6
const int PURPLE_TIER = 3
const int BLUE_TIER = 2
const int WHITE_TIER = 1

global function Perk_MunitionsBox_Init
global function Perk_SwapMunitionsBoxAndSkirmisherPerks

#if SERVER || CLIENT
global function Perk_MunitionsBox_IsEntMunitionsBox
#endif


#if SERVER
global function MunitionsBox_SpawnMunitionsBoxProp
global function MunitionsBox_SpawnMunitionsBoxPropFromExistingBin
global function MunitionsBox_ClientToServer_MarkMunitionsBoxLoot

struct TeamMunitionAssistData
{
	float teamMunitionAssistCurrentCooldown

	int teamMunitionAssistCount

	float teamMunitionsGoldCooldown
}

struct
{
	array<entity> openedLootBoxes
	array<entity> lootBoxes
	table<entity, string> respawnGrantTable
	table< entity, entity> playerToOpened
	table< int, TeamMunitionAssistData > teamMunitionBinRegistry
}file

const array<int> ATTACHMENT_SLOTS_TO_DROP_MAG = [eWeaponAttachmentType.BARREL, eWeaponAttachmentType.MAG, eWeaponAttachmentType.STOCK]
const array<int> ATTACHMENT_SLOTS_TO_DROP_NOMAG = [eWeaponAttachmentType.BARREL, eWeaponAttachmentType.STOCK]
#endif

#if CLIENT
global function MunitionsBox_ServerToClient_DisplayOpenedMunitionsBoxPrompt
#endif

void function Perk_MunitionsBox_Init()
{
	if ( GetCurrentPlaylistVarBool( "disable_perk_munitions_box", false ) )
		return

	PerkInfo munitionsBox
	munitionsBox.perkId          = ePerkIndex.MUNITIONS_BOX
	#if SERVER || CLIENT
		munitionsBox.minimapStateIndex = eMinimapObject_prop_script.MUNITIONS_BOX
		munitionsBox.minimapPingType = ePingType.MUNITIONS_BOX
		munitionsBox.mapFeatureTitle = "#PERK_FEATURE_MUNITIONS_BOX"
		munitionsBox.mapFeatureDescription = "#PERK_FEATURE_MUNITIONS_BOX_DESC"
		munitionsBox.trackEntityPosition = true
		#if CLIENT
			munitionsBox.worldspaceIconUpOffset = 20
			munitionsBox.ruiThinkThread = Perk_MunitionsBin_RuiThinkThread
			munitionsBox.staticPingDistance = 1500
		#endif
	#endif

	Perks_RegisterClassPerk( munitionsBox )

	#if SERVER
	if ( !GetCurrentPlaylistVarBool( "disable_perk_respawn_with_primary", true ) && GameMode_IsActive( eGameModes.SURVIVAL ) )
	{
		AddCallback_OnPlayerRespawned( OnPlayerRespawned )
		AddCallback_OnPlayerKilled( OnPlayerKilled )
	}
	#endif


	#if SERVER
	AddCallback_GameStateEnter( eGameState.Playing, SpawnLootContainers )
	AddCallback_OnLootBinOpening( MunitionsBox_UpdateBinAfterOpening )
	#endif

	#if CLIENT
	AddCreateCallback( "prop_dynamic", OnMunitionsBoxSpawned )
	AddCreateCallback( "prop_script", OnMunitionsBoxSpawned )
	#endif

	#if SERVER || CLIENT
		Remote_RegisterClientFunction( "MunitionsBox_ServerToClient_DisplayOpenedMunitionsBoxPrompt" )
		Remote_RegisterServerFunction( "MunitionsBox_ClientToServer_MarkMunitionsBoxLoot" )
	#endif
}

#if SERVER
int function Perk_MunitionsBox_NumSmartLootAttachments()
{
	return GetCurrentPlaylistVarInt( "munitions_box_num_smart_loot_attachments", 3 )
}

int function Perk_MunitionsBox_MaxSmartLoot()
{
	return GetCurrentPlaylistVarInt( "munitions_box_max_smart_loot", 4 )
}

int function Perk_MunitionsBox_NumSmartLootAttachmentsOpener()
{
	return GetCurrentPlaylistVarInt( "munitions_box_num_smart_loot_attachments_opener", 2 )
}

int function Perk_MunitionsBox_NumSmartLootAttachmentsOther()
{
	return GetCurrentPlaylistVarInt( "munitions_box_num_smart_loot_attachments_other", 1 )
}

int function Perk_MunitionsBox_LowAmmoStackCount()
{
	return GetCurrentPlaylistVarInt( "munitions_box_num_smart_loot_low_ammo_stack_count", 2 )
}

float function Perk_MunitionsBox_GoldAwardCooldownTime()
{
	return GetCurrentPlaylistVarFloat( "munitions_box_num_gold_drop_cooldown", 15.0 )
}

float function Perk_MunitionsBox_MunitionsAssistanceCooldownTime()
{
	return GetCurrentPlaylistVarFloat( "munitions_box_num_assistance_cooldown_time", 90.0 )
}

int function Perk_MunitionsBox_MaxAssistanceCount()
{
	return GetCurrentPlaylistVarInt( "munitions_box_max_assistance_count", 4 )
}

int function Perk_MunitionsBox_GetGoldOpticDropPercentage()
{
	return GetCurrentPlaylistVarInt( "munitions_box_gold_optic_drop_percentage", 5 )
}
#endif

bool function Perk_SwapMunitionsBoxAndSkirmisherPerks()
{
	return GetCurrentPlaylistVarBool( "swap_munitions_box_and_skirmisher_perks", false )
}

bool function MunitionsBoxSpawnsSmartLoot()
{
	return GetCurrentPlaylistVarBool( "munitions_box_spawns_smart_loot", true )
}

bool function AllPlayersCanOpenMunitionsBin()
{
	return GetCurrentPlaylistVarBool( "munitions_box_all_players_can_open", true )
}

bool function MunitionsBoxSpawnsSmartOptic()
{
	return GetCurrentPlaylistVarBool( "munitions_box_spawns_smart_optic", true )
}

bool function MunitionsBoxDropsWeaponIfOpeningPlayerIsUnarmed()
{
	return GetCurrentPlaylistVarBool( "munitions_box_drops_weapon_if_opening_player_is_unarmed", true )
}

bool function MunitionsBoxLimitsMagsAndHopUps()
{
	return GetCurrentPlaylistVarBool( "munitions_box_limits_mags_and_hopups", true )
}

bool function MunitionsBoxLimitGoldDrops()
{
	return GetCurrentPlaylistVarBool( "munitions_box_limits_gold_drops", true )
}

bool function MunitionsBox_UseNewLootLogic()
{
	return GetCurrentPlaylistVarBool( "munitions_box_use_new_loot_logic", true )
}

bool function MunitionsBox_BoostOpenerLoot()
{
	return GetCurrentPlaylistVarBool( "munitions_box_boost_opener_loot", false )
}

#if SERVER || CLIENT
bool function CanPlayerUseMunitionsBoxCallback( entity player, entity lootBin )
{
	bool result =  CanPlayerUseMunitionsBox( player )
	#if CLIENT
	if( !result )
	{
		AddPlayerHint( 0.1, 0, Perks_GetIconForPerk( ePerkIndex.MUNITIONS_BOX ), "Munitions Bins can be used by Assault Legends" )
	}
	#endif

	return result
}

bool function CanPlayerUseMunitionsBox( entity player )
{
	if( !IsValid( player ) || !player.IsPlayer() || !Perks_DoesPlayerHavePerk( player, ePerkIndex.MUNITIONS_BOX ) || Bleedout_IsBleedingOut( player ) )
		return false

	return true
}

bool function Perk_MunitionsBox_IsEntMunitionsBox( entity ent )
{
	return ent.GetScriptName() == LOOT_BIN_SCRIPTNAME && ent.GetSkin() == ent.GetSkinIndexByName( MUNITIONS_BOX_LOOT_BIN_SKIN_NAME )
}

void function OnMunitionsBoxSpawned( entity ent )
{
	if( !Perk_MunitionsBox_IsEntMunitionsBox( ent ) )
		return

	if( !AllPlayersCanOpenMunitionsBin() )
	{
		AddCallback_CanOpenLootBin( ent, CanPlayerUseMunitionsBoxCallback )
	}

	if( GradeFlagsHas( ent, eGradeFlags.IS_OPEN_SECRET ) )
		return

	Perks_AddMinimapEntityForPerk( ePerkIndex.MUNITIONS_BOX, ent )
}

#if SERVER
void function MunitionsBox_ClientToServer_MarkMunitionsBoxLoot( entity player )
{
	if( !( player in file.playerToOpened ) )
		return

	entity box = file.playerToOpened[player]
	CreateWaypoint_Ping_Location( player, ePingType.MUNITIONS_BOX_LOOT, box, box.GetOrigin(), -1, false )
}

void function MunitionsBox_UpdateBinAfterOpening( entity player, entity lootbin, array<entity> regularLootEnts, array<entity> secretLootEnts, void functionref( bool, bool ) preventLootRevealFunc )
{
	if( !Perk_MunitionsBox_IsEntMunitionsBox( lootbin ) )
		return

	if( !GradeFlagsHas( lootbin, eGradeFlags.IS_OPEN_SECRET ) )
		return

	Perks_HideMinimapVisibility( lootbin, ePerkIndex.MUNITIONS_BOX )

	if( IsValid( player) )
	{
		StatsHook_WeaponsSupplyBinLooted( player )
		array<LootRef> loot = LootBin_GetLootRefs( lootbin, false, true )
		//PIN_Perks_WeaponSupplyBinLooted( player, loot, lootbin.GetOrigin() ) // S3: can't pass typed array to var

		if ( player in file.playerToOpened )
		{
			Remote_CallFunction_NonReplay( player, "MunitionsBox_ServerToClient_DisplayOpenedMunitionsBoxPrompt" )
		}
	}
}

array<string> function GetMainCompartmentLoot()
{
	array<string> loot

	if( AllPlayersCanOpenMunitionsBin() )
	{
		loot = SURVIVAL_GetMultipleWeightedItemsFromGroup( "Zone_Medium", 4 )
	}
	else
	{
		string groupRef   = "munitions_drop"
		string weaponDrop = SURVIVAL_GetWeightedItemFromGroup( groupRef )
		loot.append( weaponDrop )
		LootData weaponData   = SURVIVAL_Loot_GetLootDataByRef( weaponDrop )
		string weaponAmmoType = weaponData.ammoType
		if ( weaponAmmoType != "" )
			loot.append( weaponAmmoType )

		if ( MunitionsBoxSpawnsSmartLoot() )
		{
			array<string> attachmentsDropsForDroppedWeapon = GetAttachmentUpgradesForWeaponRef( weaponDrop )
			array<string> hopupDropsForDroppedWeapon       = GetHopupsForWeaponRef( weaponDrop )
			AwardTieredLoot( loot, attachmentsDropsForDroppedWeapon, hopupDropsForDroppedWeapon )
		}

		array<string> validAttachments = LootHelper_GetCompatibleScopesForWeapon( null, weaponData, [1, 2, 3] )
		string optic                   = validAttachments[ RandomIntRange( 0, validAttachments.len() ) ]
		loot.append( optic )
	}
	return loot
}

array<string> function GetHopupsForWeaponRef( string ref )
{
	return LootHelper_GetLootForWeaponRef( ref, [eWeaponAttachmentType.HOPUP] )
}

array<string> function GetAttachmentUpgradesForWeaponRef( string ref )
{
	return LootHelper_GetLootForWeaponRef( ref, ATTACHMENT_SLOTS_TO_DROP_MAG )
}

int function GetRandomTier()
{
	int roll = RandomInt(100)
	if( roll < HOP_UP_DROP_CHANCE )
	{
		return HOP_UP_TIER
	}
	if( roll < PURPLE_DROP_CHANCE )
	{
		return PURPLE_TIER
	}
	if( roll < BLUE_DROP_CHANCE )
	{
		return BLUE_TIER
	}
	return WHITE_TIER
}

bool function RollShouldDropGoldOptic( entity player )
{
	if( MunitionsBox_IsPlayerOnGoldCooldown( player ) )
		return false
	int roll = RandomInt( 100 )
	return roll < Perk_MunitionsBox_GetGoldOpticDropPercentage()
}

void function AwardTieredLoot( array<string> awardedLoot, array<string> potentialAttachments, array<string> potentialHopups )
{
	int attachmentTier = GetRandomTier()
	if( attachmentTier == HOP_UP_TIER && potentialHopups.len() > 0 )
	{
		int dropIndex = RandomInt( potentialHopups.len() )
		string ref = potentialHopups[dropIndex]
		awardedLoot.append( ref )
		potentialHopups.remove(dropIndex)
	}
	else if( potentialAttachments.len() > 0 )
	{
		attachmentTier = minint( attachmentTier, 3 )
		int dropIndex = RandomInt( potentialAttachments.len() )
		string ref = potentialAttachments[dropIndex]
		LootData lootItem = SURVIVAL_Loot_GetLootDataByRef( ref )
		if( lootItem.attachmentType == eWeaponAttachmentType.MAG )
		{
			attachmentTier = BLUE_TIER
		}
		if( attachmentTier > 1 )
		{
			ref = LootHelper_UpgradeLootRefToTier( ref, attachmentTier )
		}
		awardedLoot.append( ref )
		potentialAttachments.remove(dropIndex)
	}
}

void function MunitionsBoxWeapons_SmartLoot_RegisterAssist( entity player )
{
	int team = player.GetTeam()

	if( team in file.teamMunitionBinRegistry )
	{
		TeamMunitionAssistData teamData = file.teamMunitionBinRegistry[team]

		//If receiving assistance, add themn to the assistance registry.
		teamData.teamMunitionAssistCurrentCooldown = Time()

		if( teamData.teamMunitionAssistCount > 0 )
		{
			teamData.teamMunitionAssistCount++
			printt( "Munitions Assistance Count: " + teamData.teamMunitionAssistCount )
		}
	}
	else
	{
		TeamMunitionAssistData teamData

		teamData.teamMunitionAssistCount = 1

		teamData.teamMunitionAssistCurrentCooldown = Time()

		file.teamMunitionBinRegistry[team] <- teamData
	}
}

bool function MunitionsBoxWeapons_SmartLoot_IsAssistAllowed( entity player )
{
	int team = player.GetTeam()

	if( team in file.teamMunitionBinRegistry )
	{
		TeamMunitionAssistData teamData = file.teamMunitionBinRegistry[team]

		// check if the team is in the assistance cooldown registry. If so, check the time delta agains the cooldown. If greater, allow assistance, if not. Return false.
		if( !( Time() - teamData.teamMunitionAssistCurrentCooldown > Perk_MunitionsBox_MunitionsAssistanceCooldownTime() ) )
		{
			return false
		}


		// Check the amount of assistance. If lesser than 3, allow assistance, if not. Return false.
		if( teamData.teamMunitionAssistCount >= Perk_MunitionsBox_MaxAssistanceCount()  )
		{
			return false
		}
	}

	return true
}

void function SpawnMunitionsBoxWeapons_SmartLoot_AddSmartLootForPlayer( entity player, array<string> awardedAttachments, bool pruneGold, bool soloPlayerLootBoost, bool overrideMagLimiter, bool isOpenerLootBoost, int desiredAttachmentCount )
{
	bool openerLootBoosted = false
	bool hopUpAwarded = false

	for( int weaponIndex = WEAPON_INVENTORY_SLOT_PRIMARY_0; weaponIndex <= WEAPON_INVENTORY_SLOT_PRIMARY_1; weaponIndex++ )
	{
		int roll = RandomInt(100)
		if( roll < HOP_UP_DROP_CHANCE )
		{
			array<string> allHopUps = SmartLoot_GetLoot( player, true, true, [], [eWeaponAttachmentType.HOPUP], [weaponIndex] )
			if( allHopUps.len() > 0 )
			{
				if( MunitionsBoxLimitsMagsAndHopUps() )
				{
					if ( MunitionsBoxWeapons_SmartLoot_IsAssistAllowed( player ) && !hopUpAwarded)
					{
						hopUpAwarded = true
						awardedAttachments.append( allHopUps[RandomInt(allHopUps.len())] )
						MunitionsBoxWeapons_SmartLoot_RegisterAssist( player )
					}
				}
			}
		}

		array<string> potentialLoot = SmartLoot_GetLoot( player, true, true, [], ATTACHMENT_SLOTS_TO_DROP_MAG , [weaponIndex] )

		if( MunitionsBoxLimitsMagsAndHopUps() && !soloPlayerLootBoost && !overrideMagLimiter)
		{
			int roll_two = RandomInt(100)
			if( roll_two < MAG_DROP_CHANCE )
			{
				potentialLoot = SmartLoot_GetLoot( player, true, true, [], ATTACHMENT_SLOTS_TO_DROP_NOMAG , [weaponIndex] )
			}
		}

		if( potentialLoot.len() == 0 )
			continue

		for( int i = 0; i < desiredAttachmentCount; i++ )
		{
			if( potentialLoot.len() <= 0 )
				break

			int lootIndex = RandomInt( potentialLoot.len() )
			string chosenLoot = potentialLoot[lootIndex]

			LootData lootItem = SURVIVAL_Loot_GetLootDataByRef( chosenLoot )

			if( lootItem.tier == 1 )
			{
				chosenLoot = LootHelper_UpgradeLootRefToTier( chosenLoot, 2 )
				lootItem = SURVIVAL_Loot_GetLootDataByRef( chosenLoot )
			}

			//if the player is the legend opening the smart loot drawer, give them one item that is double upgraded
			if( isOpenerLootBoost && !openerLootBoosted )
			{
				//limit to tier 3 if we've already dropped gold
				int lootTier = lootItem.tier + 2

				if( lootTier > 4 )
				{
					//if we're not pruning gold or if the player is solo, allow for gold drop
					if( !pruneGold || soloPlayerLootBoost )
					{
						lootTier = 4
					}

					//limit to tier 3 if we've already dropped gold
					if( pruneGold  &&  MunitionsBox_IsPlayerOnGoldCooldown( player ) )
					{
						lootTier = 3
					}
				}

				if( lootTier > 3 )
				{
					if( lootItem.attachmentType == eWeaponAttachmentType.STOCK || lootItem.attachmentType == eWeaponAttachmentType.BARREL )
					{
						lootTier = 3
					}
				}

				chosenLoot = LootHelper_UpgradeLootRefToTier( chosenLoot, lootTier )
				lootItem = SURVIVAL_Loot_GetLootDataByRef( chosenLoot )


				openerLootBoosted = true
			}

			if( pruneGold && MunitionsBox_IsPlayerOnGoldCooldown( player ) && !soloPlayerLootBoost || hopUpAwarded )
			{
				if( lootItem.tier >= 4 )
				{
					chosenLoot = LootHelper_UpgradeLootRefToTier( chosenLoot, 3 )
					lootItem = SURVIVAL_Loot_GetLootDataByRef( chosenLoot )
				}
			}

			lootItem = SURVIVAL_Loot_GetLootDataByRef( chosenLoot )
			awardedAttachments.append( chosenLoot )
			potentialLoot.fastremove( lootIndex )
		}
	}
}

array<string> function SpawnMunitionsBoxWeapons_SmartLoot( entity ent, entity player, array<string> potentialFillerAttachments, array<string> potentialFillerHopups )
{
	array<string> potentialAttachments
	array<string> potentialOptics
	array<string> potentialGoldOptics
	array<string> smartLoot

	bool hasRecievedOpticsDrop = false
	bool hasRecievedGoldDrop = false
	bool teamBoostAllowed = false

	if( player in file.playerToOpened )
	{
		delete file.playerToOpened[player]
	}

	bool shouldPruneGoldLoot = MunitionsBoxLimitGoldDrops()

	// if the player opening doesn't have weapons, drop a weapon for them instead of giving smart loot for their teammates
	array<entity> primaryWeapons = SURVIVAL_GetPrimaryWeapons( player )
	bool shouldGrantSmartLoot =  primaryWeapons.len() != 0 || !MunitionsBoxDropsWeaponIfOpeningPlayerIsUnarmed()


		if ( GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_SOLOS ) || GameModeVariant_IsActive( eGameModeVariants.SURVIVAL_BATTLE_RUSH ) )



		{
			string weaponDrop

			if( CoinFlip() )
			{
				weaponDrop = SURVIVAL_GetWeightedItemFromGroup( "blue_kitted_weapons_qm" )
			}
			else
			{
				weaponDrop = SURVIVAL_GetWeightedItemFromGroup( "purple_kitted_weapons_qm" )
			}

			smartLoot.append( weaponDrop )

			LootData dropItem = SURVIVAL_Loot_GetLootDataByRef( weaponDrop )

			if( dropItem.lootType == eLootType.MAINWEAPON )
			{
				string ammoTypeRef = GetWeaponAmmoType( weaponDrop )
				LootData data = SURVIVAL_Loot_GetLootDataByRef( ammoTypeRef )
				smartLoot.append( ammoTypeRef )
			}

			if( smartLoot.len() < ( Perk_MunitionsBox_MaxSmartLoot() - 1 ) ) //if less than max smart loot items, give grenades
			{
				string ordnanceDrop = SURVIVAL_GetWeightedItemFromGroup( "ordnance_drops" )
				smartLoot.append( ordnanceDrop )
			}

			return smartLoot
		}


	if( shouldGrantSmartLoot )
	{
		// grab attachments we might give for every player on the team, give one for each player
		int team = player.GetTeam()
		array<entity> teamPlayers = GetPlayerArrayOfTeam_Alive( team )

		//Table of arrays for smart loot needs of alive teammates.
		table< entity, array<string> > teamSmartLootNeeds

		foreach( teamMember in teamPlayers )
		{
			array<string> potentialSmartLootForTeammember
			bool boostOpenerLoot = ( teamMember == player && MunitionsBox_BoostOpenerLoot() )
			SpawnMunitionsBoxWeapons_SmartLoot_AddSmartLootForPlayer( teamMember, potentialSmartLootForTeammember, shouldPruneGoldLoot, MunitionsBoxWeapons_ShouldPlayerGetSoloBoost( teamMember ), false , boostOpenerLoot, Perk_MunitionsBox_MaxSmartLoot() )

			teamSmartLootNeeds[teamMember] <- potentialSmartLootForTeammember
		}

		if( MunitionsBox_UseNewLootLogic() )
		{
			//Start - Loot Consideration for Opening Player
			int numberOfAttachmentsForOpener = Perk_MunitionsBox_NumSmartLootAttachmentsOpener()

			if( MunitionsBoxWeapons_ShouldPlayerGetSoloBoost( player ) || !MunitionsBoxWeapons_DoTeammatesHaveWeapons( player ) || !MunitionsBox_DoTeammatesNeedSmartLoot( player, teamSmartLootNeeds ) ) //if player is the only team member expand possible smart loot items up to 4
			{
				if( MunitionsBoxSpawnsSmartOptic() )
				{
					numberOfAttachmentsForOpener = 3
				}
				else
				{
					numberOfAttachmentsForOpener = 4
				}
			}

			array<string> potentialAttachmentsForPlayer

			potentialAttachmentsForPlayer = teamSmartLootNeeds[player]

			//SpawnMunitionsBoxWeapons_SmartLoot_AddSmartLootForPlayer( player, potentialAttachmentsForPlayer, shouldPruneGoldLoot, MunitionsBoxWeapons_ShouldPlayerGetSoloBoost( player ), false , true, numberOfAttachmentsForOpener )

			if( potentialAttachmentsForPlayer.len() > 0 )
			{
				for( int i = 0; i < numberOfAttachmentsForOpener; i++ )
				{
					//If you've reaching for an attachment to drop, and there are none, but we've not hit the desired attachments, allow teammates to get more loot
					if( potentialAttachmentsForPlayer.len() <= 0 )
					{
						teamBoostAllowed = true
						break
					}

					int indexToDrop = RandomInt( potentialAttachmentsForPlayer.len() )

					smartLoot.append( potentialAttachmentsForPlayer[indexToDrop] )
					potentialAttachmentsForPlayer.fastremove(indexToDrop)
				}
			}
			else
			{
				//If there are no possible smart loot attachments for opneing player, allow teammates to get more loot
				teamBoostAllowed = true
			}

			array<string> leftOverSmartLootToTopUp

			//if there is left over smart loot, save it for later in the event we fail to maximize smart loot for other reasons
			if( potentialAttachmentsForPlayer.len() > 0 )
				leftOverSmartLootToTopUp.extend( potentialAttachmentsForPlayer )

			//empty out the Player smart loot needs
			teamSmartLootNeeds[player].clear()

			//Roll optics for opening player
			array<int> acceptableOpticsTiers = [2,3]
			array<string> scopes = LootHelper_GetCompatibleScopes( player, acceptableOpticsTiers )
			if( scopes.len() > 0 )
			{
				potentialOptics.append( scopes[RandomInt( scopes.len() )] )
				hasRecievedOpticsDrop = true
			}
			array<string> goldScopes = LootHelper_GetCompatibleScopes( player, [4] )
			if( goldScopes.len() > 0 )
			{
				potentialGoldOptics.append( goldScopes[RandomInt( goldScopes.len() )] )
			}
			//End - Loot Consideration for Opening Player

			//Start - Loot Consideration for Teammates
			entity boostedPlayer = null
			array<entity> playersEligibleForBoost
			foreach( teamMate in teamPlayers )
			{
				if( teamMate == player )
					continue
				if ( teamSmartLootNeeds[ teamMate ].len() < 2 )
					continue
				playersEligibleForBoost.append( teamMate )
			}

			if( playersEligibleForBoost.len() == 1 )
			{
				boostedPlayer = playersEligibleForBoost[0]
			}

			else if( playersEligibleForBoost.len() > 1 )
			{
				boostedPlayer = playersEligibleForBoost[RandomIntRange( 0, playersEligibleForBoost.len() )]
			}

			int openSmartLootSlotsInBin

			foreach( entity teamMate in teamPlayers )
			{
				if( teamMate == player )
					continue

				openSmartLootSlotsInBin = Perk_MunitionsBox_MaxSmartLoot() - smartLoot.len()

				int numberOfSmartLootRollsForTeammate
				bool remainingTeammateNeedsSmartLoot = false

				array<string> potentialAttachmentsForTeammate = teamSmartLootNeeds[teamMate]

				if( potentialAttachmentsForTeammate.len() <= 0 )
					continue

				//Figure out if teammates need loot
				if( MunitionsBox_DoTeammatesNeedSmartLoot( teamMate, teamSmartLootNeeds ) )
				{
					//if the remaining teammate needs smart loot, see how many slots we have left, divide the remaining slots evenly (where possible) between the teammates
					if( openSmartLootSlotsInBin > Perk_MunitionsBox_NumSmartLootAttachmentsOther()  && teamBoostAllowed )
					{
						//check to see how to split the remaining loot slots
						int numOfNonOpeningTeammates = teamPlayers.len() - 1
						int splitLootAmount = openSmartLootSlotsInBin / numOfNonOpeningTeammates
						int splitLootRemainder = openSmartLootSlotsInBin % numOfNonOpeningTeammates

						if( splitLootRemainder != 0 )
						{
							if( teamMate == boostedPlayer )
							{
								numberOfSmartLootRollsForTeammate = splitLootAmount + splitLootRemainder
							}
							else
							{
								numberOfSmartLootRollsForTeammate = splitLootAmount
							}
						}
						else
						{
							numberOfSmartLootRollsForTeammate = splitLootAmount
						}
					}
					else
					{
						numberOfSmartLootRollsForTeammate = Perk_MunitionsBox_NumSmartLootAttachmentsOther()
					}
				}
				else //if other teammates don't need loot, give all slots to current teammate
				{
					numberOfSmartLootRollsForTeammate = openSmartLootSlotsInBin
				}

				//With the correct number of rolls assessed, roll that many smart loot attachments.
				for( int i = 0; i < numberOfSmartLootRollsForTeammate; i++ )
				{
					if( potentialAttachmentsForTeammate.len() > 0 )
					{
						int indexToDrop = RandomInt( potentialAttachmentsForTeammate.len() )

						smartLoot.append( potentialAttachmentsForTeammate[indexToDrop] )

						potentialAttachmentsForTeammate.fastremove(indexToDrop)
					}
				}

				if( potentialAttachmentsForTeammate.len() > 0 )
					leftOverSmartLootToTopUp.extend( potentialAttachmentsForTeammate )

				//empty out the Player smart loot needs
				teamSmartLootNeeds[teamMate].clear()

				//Roll potential optics for this teammate.
				acceptableOpticsTiers = [2,3]
				scopes = LootHelper_GetCompatibleScopes( teamMate, acceptableOpticsTiers )
				if( scopes.len() > 0 )
					potentialOptics.append( scopes[RandomInt( scopes.len() )] )
				goldScopes = LootHelper_GetCompatibleScopes( teamMate, [4] )
				if( goldScopes.len() > 0 )
					potentialGoldOptics.append( goldScopes[RandomInt( goldScopes.len() )] )

			}
			//End - Loot Consideration for Teammates

			//Start - Optics Selection for ALL
			if( MunitionsBoxSpawnsSmartOptic() )
			{
				while( smartLoot.len () > Perk_MunitionsBox_NumSmartLootAttachments() )
				{
					if( RandomInt( 10 ) >= 5 )
					{
						smartLoot.fastremove( smartLoot.len () - 1 )
					}
					else
					{
						smartLoot.fastremove( smartLoot.len () - 2 )
					}
				}

				if( potentialGoldOptics.len() > 0 && RollShouldDropGoldOptic( player ) )
				{
					smartLoot.append( potentialGoldOptics[RandomInt( potentialGoldOptics.len() )] )
					hasRecievedOpticsDrop = true
				}
				else if( potentialOptics.len() > 0 )
				{
					smartLoot.append( potentialOptics[RandomInt( potentialOptics.len() )] )
					hasRecievedOpticsDrop = true
				}
			}
			//End - Optics Selection for ALL

			//Start - Fill Out Smart Loot with Top Up Attachments, Grenades, Ammo
			int maxSmartLootAttachments = Perk_MunitionsBox_MaxSmartLoot()
			//if giving less than 4 smart loot items, back fill with ammo and/or grenades
			if( smartLoot.len() < maxSmartLootAttachments )
			{
				int openSmartLootSlots = maxSmartLootAttachments - smartLoot.len()

				if( leftOverSmartLootToTopUp.len() > 0 )
				{
					foreach( leftOverLootItem in leftOverSmartLootToTopUp )
					{
						if( smartLoot.len() < maxSmartLootAttachments )
						{
							int indexToDrop = RandomInt( leftOverSmartLootToTopUp.len() )

							smartLoot.append( leftOverSmartLootToTopUp[indexToDrop] )
							leftOverSmartLootToTopUp.fastremove(indexToDrop)

							openSmartLootSlots--
						}
					}
				}

				//add an optic to the drop if there are several unfilled slots
				if( openSmartLootSlots > 2 && potentialOptics.len() > 0 && !hasRecievedOpticsDrop)
				{
					smartLoot.append( potentialOptics[RandomInt(potentialOptics.len())] )
					hasRecievedOpticsDrop = true

					openSmartLootSlots = maxSmartLootAttachments - smartLoot.len()
				}

				if( openSmartLootSlots > 0 )
					MunitionsBoxWeapons_AddFillerLoot( player, teamPlayers, smartLoot, openSmartLootSlots )
			}
			//End - Fill Out Smart Loot with Top Up Attachments, Grenades, Ammo
		}
		else //TODO: Remove old alternate logic (and associated playlist vars / calls) once final refactor of loot logic is complete and submitted
		{
			foreach ( entity teamMate in teamPlayers )
			{
				array<string> potentialAttachmentsForPlayer
				SpawnMunitionsBoxWeapons_SmartLoot_AddSmartLootForPlayer( teamMate, potentialAttachmentsForPlayer, shouldPruneGoldLoot, MunitionsBoxWeapons_ShouldPlayerGetSoloBoost( teamMate ), false, false, Perk_MunitionsBox_NumSmartLootAttachmentsOther() )
				if( potentialAttachmentsForPlayer.len() > 0 )
				{
					int indexToDrop = RandomInt( potentialAttachmentsForPlayer.len() )

					smartLoot.append( potentialAttachmentsForPlayer[indexToDrop] )
					potentialAttachmentsForPlayer.fastremove(indexToDrop)
					potentialAttachments.extend( potentialAttachmentsForPlayer )
				}
				array<string> scopes = LootHelper_GetCompatibleScopes( teamMate, [2,3,4] )
				if( scopes.len() > 0 )
				{
					potentialOptics.append( scopes[RandomInt( scopes.len() )] )
				}
			}

			int numSmartLootAttachments = Perk_MunitionsBox_NumSmartLootAttachments()
			// fill up the rest of the loot slots with remaining attachments we could grant
			while( smartLoot.len() < numSmartLootAttachments && potentialAttachments.len() > 0 )
			{
				int indexToDrop = RandomInt(potentialAttachments.len())

				smartLoot.append( potentialAttachments[indexToDrop] )
				potentialAttachments.fastremove( indexToDrop )
			}

			// fill up the rest of the smart loot slots with attachments for the weapon we spawned
			while( smartLoot.len() < numSmartLootAttachments && potentialFillerAttachments.len() > 0 )
			{
				AwardTieredLoot( smartLoot, potentialFillerAttachments, potentialFillerHopups )
			}

			if( potentialOptics.len() > 0 && MunitionsBoxSpawnsSmartOptic() )
			{
				smartLoot.append( potentialOptics[RandomInt(potentialOptics.len())] )
			}
		}


		file.playerToOpened[player] <- ent
	}

	// spawn a starter weapon if they didn't have any weapons to grant awards for
	if( smartLoot.len() == 0 )
	{
		string groupRef   = "munitions_drop"
		string weaponDrop = SURVIVAL_GetWeightedItemFromGroup( groupRef )
		LootData dropItem = SURVIVAL_Loot_GetLootDataByRef( weaponDrop )
		smartLoot.append( weaponDrop )
		potentialFillerAttachments = GetAttachmentUpgradesForWeaponRef( weaponDrop )

		if( MunitionsBoxWeapons_SmartLoot_IsAssistAllowed( player ) || !MunitionsBoxLimitsMagsAndHopUps() || MunitionsBoxWeapons_ShouldPlayerGetSoloBoost( player ) ) // solo assist
			potentialFillerHopups = GetHopupsForWeaponRef( weaponDrop )
		else
			potentialFillerHopups.clear()

		AwardTieredLoot( smartLoot, potentialFillerAttachments, potentialFillerHopups )
		AwardTieredLoot( smartLoot, potentialFillerAttachments, potentialFillerHopups )

		//if a hop up was given register it for limiting
		if( MunitionsBoxLimitsMagsAndHopUps() )
		{
			for( int i; i < smartLoot.len(); i++ )
			{
				LootData lootItem = SURVIVAL_Loot_GetLootDataByRef( smartLoot[i] )

				if( lootItem.attachmentType == eWeaponAttachmentType.HOPUP )
					MunitionsBoxWeapons_SmartLoot_RegisterAssist( player )
			}
		}

		if( smartLoot.len() < ( Perk_MunitionsBox_MaxSmartLoot() - 1 ) ) //if less than max smart loot items, round up with optics.
		{
			if( MunitionsBoxSpawnsSmartOptic() )
			{
				array<int> acceptableOpticsTiers = [2,3,4]
				array<string> scopes = LootHelper_GetCompatibleScopesForWeapon( player, dropItem, acceptableOpticsTiers )
				if( scopes.len() > 0 )
				{
					smartLoot.append( scopes[RandomInt( scopes.len() )] )
					hasRecievedOpticsDrop = true
				}
			}
		}
	}

	foreach( string awardedLoot in smartLoot )
	{
		LootData refData = SURVIVAL_Loot_GetLootDataByRef( awardedLoot )
		if( refData.attachmentType ==  eWeaponAttachmentType.HOPUP || refData.tier >= 4 )
		{
			MunitionsBox_SetPlayerOnGoldCooldown( player )
			break
		}
	}


	return smartLoot
}

bool function MunitionsBoxWeapons_ShouldPlayerGetSoloBoost ( entity player )
{
	array<entity> teamPlayers = GetPlayerArrayOfTeam( player.GetTeam() )

	if( teamPlayers.len() == 1 && Perks_DoesPlayerHavePerk( player, ePerkIndex.MUNITIONS_BOX ) )
	{
		return true
	}

	return false
}

void function MunitionsBoxWeapons_AddFillerLoot( entity player, array<entity> teamPlayers, array<string> currentLootOffering, int fillerLootCount )
{
	bool teamNeedsAmmo = false
	int ammoInOffering = 0
	int ordnanceInOffering = 0

	//count how much ammo is already in the smart loot offering
	foreach ( ref in currentLootOffering)
	{
		LootData refData = SURVIVAL_Loot_GetLootDataByRef( ref )

		switch( refData.ammoType )
		{
			case BULLET_AMMO:
			case HIGHCAL_AMMO:
			case SHOTGUN_AMMO:
			case SPECIAL_AMMO:
			case ARROWS_AMMO:
			case SNIPER_AMMO:
				ammoInOffering++
				break
		}

		if( SURVIVAL_Weapon_IsOrdnance( ref ) )
		{
			ordnanceInOffering++
		}
	}

	//Assess ammo needs (look in team inventories and check if their ammo is at 1 stack or less)
	table< string, int > ammoNeeded = LootHelper_GetAmmoNeededByTeam( player.GetTeam(), Perk_MunitionsBox_LowAmmoStackCount() )
	if ( ammoNeeded.len() > 0 )
	{
		teamNeedsAmmo = true
	}

	for( int i = 0; i < fillerLootCount; i++ )
	{
		//check if team needs ammo and if 2 ammo stacks have not already been added to the smart loot
		//OR if already giving lots of ordnance give more ammo
		if( ( teamNeedsAmmo && ammoInOffering < 2 ) || ordnanceInOffering >= 2)
		{
			int mostNeededCount = 0
			string typeNeededMost

			//check the ammo need table to see which ammo is most needed by the squad
			foreach( string ammoRef, int refNeed in ammoNeeded )
			{
				if( refNeed > mostNeededCount )
				{
					mostNeededCount = refNeed
					typeNeededMost = ammoRef
				}
			}

			if( typeNeededMost != "" )
			{
				currentLootOffering.append( typeNeededMost )
				ammoInOffering++
				continue
			}
		}

		//if ammo is not needed or already covered, give grenades
		if( !teamNeedsAmmo || ammoInOffering >= 2 )
		{
			string groupRef   = "ordnance_drops"
			string ordnanceDrop = SURVIVAL_GetWeightedItemFromGroup( groupRef )

			currentLootOffering.append( ordnanceDrop )
			continue
		}
	}
}

bool function MunitionsBox_DoTeammatesNeedSmartLoot( entity player, table< entity, array <string> > teanSmartLootNeeds )
{
	foreach( entity teamMember, teamMemberLootNeeds in teanSmartLootNeeds )
	{
		if( teamMember == player )
			continue

		if( teamMemberLootNeeds.len() > 0 )
		{
			return true
		}
	}

	return false
}

bool function MunitionsBoxWeapons_DoTeammatesHaveWeapons( entity player )
{
	array<entity> teamPlayers = GetPlayerArrayOfTeam( player.GetTeam() )
	bool teamHasGuns = false

	//check to see if Opener teammates have no weapons, return true (give solo boost)
	foreach( teamMember in teamPlayers)
	{
		if( teamMember == player )
			continue

		array<entity> primaryWeapons = SURVIVAL_GetPrimaryWeapons( teamMember )

		if(primaryWeapons.len() > 0)
			teamHasGuns = true
	}

	if( teamHasGuns )
	{
		return true
	}

	return false
}

bool function MunitionsBox_IsPlayerOnGoldCooldown( entity player )
{
	int teamID = player.GetTeam()

	if( teamID in file.teamMunitionBinRegistry )
	{
		if (  ( Time() - file.teamMunitionBinRegistry[teamID].teamMunitionsGoldCooldown ) < Perk_MunitionsBox_GoldAwardCooldownTime() )
		{
			return true
		}
	}

	return false
}

void function MunitionsBox_SetPlayerOnGoldCooldown( entity player )
{
	int teamID = player.GetTeam()

	if( teamID in file.teamMunitionBinRegistry )
	{
		file.teamMunitionBinRegistry[teamID].teamMunitionsGoldCooldown = Time()
	}
	else
	{
		TeamMunitionAssistData teamData

		teamData.teamMunitionsGoldCooldown = Time()

		file.teamMunitionBinRegistry[teamID] <- teamData
	}
}

void function SpawnMunitionsBoxWeapons_LockedSetWeapon( array<string> awardedLoot )
{
	int currentRound = SURVIVAL_GetCurrentDeathFieldStage()
	string weaponDrop
	if( currentRound < 4 )
	{
		string groupRef = "munitions_drop"
		weaponDrop = SURVIVAL_GetWeightedItemFromGroup( groupRef )
		if( currentRound <= 0 )
		{
			float randChance = RandomFloatRange( 0.0, 1.0 )
			if( randChance < .5 )
			{
				weaponDrop += WEAPON_LOCKEDSET_SUFFIX_WHITESET
			}
			else
			{
				weaponDrop += WEAPON_LOCKEDSET_SUFFIX_BLUESET
			}
		}
		else if( currentRound == 1 )
		{
			weaponDrop += WEAPON_LOCKEDSET_SUFFIX_BLUESET
		}
		else if( currentRound == 2 )
		{
			weaponDrop += WEAPON_LOCKEDSET_SUFFIX_PURPLESET
		}
		else if( currentRound == 3 )
		{
			weaponDrop += WEAPON_LOCKEDSET_SUFFIX_GOLD
		}
		LootData weaponData   = SURVIVAL_Loot_GetLootDataByRef( weaponDrop )
		string weaponAmmoType = weaponData.ammoType
		if ( weaponAmmoType != "" )
			awardedLoot.append( weaponAmmoType )
	}
	else
	{
		string groupRef = "crate_weapons_lategame"
		weaponDrop = SURVIVAL_GetWeightedItemFromGroup( groupRef )
		if ( weaponDrop == "mp_weapon_dragon_lmg" )
		{
			awardedLoot.append( "mp_weapon_thermite_grenade" )

		}
	}
	awardedLoot.append( weaponDrop )
}

void function AddSecretCompartmentLoot( entity bin, entity player )
{
	if( !CanAccessSecretCompartments( bin, player ) )
		return

	array<LootRef> existingSecretLoot = LootBin_GetLootRefs( bin, false, true )
	if( existingSecretLoot.len() > 0 )
		return

	if( file.openedLootBoxes.contains( bin ) )
		return


	array<string> potentialFillerAttachments
	array<string> potentialFillerHopups

	// if the top bin is catered loot there will be a weapon in there. if it isn't we'll spawn a weapon in the bottom bin
	if( !AllPlayersCanOpenMunitionsBin() )
	{
		LootRef weapon
		LootRef attachment
		array<LootRef> lootInside = LootBin_GetLootRefs( bin, true, false )
		foreach ( LootRef loot in lootInside )
		{
			if ( loot.lootData.lootType == eLootType.MAINWEAPON )
				weapon = loot
			else if ( loot.lootData.lootType == eLootType.ATTACHMENT && loot.lootData.attachmentType != eWeaponAttachmentType.SCOPE )
				attachment = loot
		}
		// build the potential drops from the weapon
		potentialFillerAttachments = GetAttachmentUpgradesForWeaponRef( weapon.lootData.ref )
		potentialFillerHopups = GetHopupsForWeaponRef( weapon.lootData.ref )

		// make sure we don't consider attachment types that have already been dropped
		for( int i=potentialFillerAttachments.len() -1; i >=0; i-- )
		{
			LootData potentialAttachmentData = SURVIVAL_Loot_GetLootDataByRef( potentialFillerAttachments[i] )
			if( attachment.lootData.attachmentStyle == potentialAttachmentData.attachmentStyle )
			{
				potentialFillerAttachments.fastremove( i )
			}
		}
		for( int i=potentialFillerHopups.len() -1; i >=0; i-- )
		{
			LootData potentialHopupData = SURVIVAL_Loot_GetLootDataByRef( potentialFillerHopups[i] )
			if( attachment.lootData.attachmentStyle == potentialHopupData.attachmentStyle )
			{
				potentialFillerHopups.fastremove( i )
			}
		}
	}

	array<string> smartLoot = SpawnMunitionsBoxWeapons_SmartLoot( bin, player, potentialFillerAttachments, potentialFillerHopups )

	int epicAndAboveCount = 0
	foreach( string loot in smartLoot )
	{
		LootData lootData = SURVIVAL_Loot_GetLootDataByRef( loot )
		if( lootData.tier >= 3 )
			epicAndAboveCount += 1
	}
	StatsHook_WeaponSupplyBinHighTierLootAwarded( player, epicAndAboveCount )

	file.openedLootBoxes.append( bin )

	LootBin_PutMultipleLootItemsInside( bin, eLootBinCompartment.SECRET, smartLoot )
}

#endif
#endif

#if SERVER
void function SpawnLootContainers()
{
	string mapName = GetMapName()
	if( mapName.find( "mp_rr_box" ) >= 0 )
	{
		MunitionsBox_SpawnMunitionsBoxProp( <-1021.446655, -1803.945679, 128.031250>, <1.367292, 90, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <-821.446655, -1803.945679, 128.031250>, <1.367292, 90, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <-621.446655, -1803.945679, 128.031250>, <1.367292, 90, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <-421.446655, -1803.945679, 128.031250>, <1.367292, 90, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <-221.446655, -1803.945679, 128.031250>, <1.367292, 90, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <-21.446655, -1803.945679, 128.031250>, <1.367292, 90, 0.000000> )

	}
	else if( mapName.find( "mp_rr_qv_map_test_gym" ) >= 0 )
	{
		MunitionsBox_SpawnMunitionsBoxProp( <-2992.000000, -15808.000000, 512.000000>, <4.887651, -90.259758, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <-2768.000007, -15808.000000, 512.000000>, <4.887651, -90.259758, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <-2544.000015, -15808.000000, 512.000000>, <4.887651, -90.259758, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <-2320.000023, -15808.000000, 512.000000>, <4.887651, -90.259758, 0.000000> )
	}

	if( LootBin_RandomizePerkBinsFromExistingBins() )
		return

	if( mapName.find( "mp_rr_divided_moon" ) >= 0 )
	{
		MunitionsBox_SpawnMunitionsBoxProp( <13244.017578, -12227.027344, 6227.672852>, <0, 110.143806, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <29880.166016, -24768.419922, 4819.145020>, <0, 104.706818, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <34314.742188, -2647.132080, 3409.562500>, <0, -168.935883, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <24338.324219, 12701.845703, 1180.983521>, <0, 128.566025, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <26954.921875, 30829.640625, 3544.031250>, <0, 32.592331, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <4820.759766, 28381.951172, 610.190247>, <0, 19.540972, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <7303.350586, 15350.131836, 1328.780396>, <0, -8.909310, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <4532.344238, 28563.441406, 604.026428>, <0, 118.126808, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <-12696.399414, 18674.564453, 2068.336914>, <0, 150.234222, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <-34179.464844, 29487.523438, -719.952637>, <0, 45.433327, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <-27697.683594, 9837.678711, 1024.403320>, <0, 146.380356, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <-31926.503906, -4949.711426, 1383.590698>, <0, -64.726372, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <-30029.320313, -32659.492188, 2081.341553>, <0, 38.576233, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <-11742.100586, -23299.083984, 2725.892578>, <0, -57.486496, 0.000000> )
		MunitionsBox_SpawnMunitionsBoxProp( <-10598.881836, -2440.176270, 1654.323242>, <0, 47.591625, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <-143.720459, 6593.060547, 2167.562256>, <0, -67.485725, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <11012.102539, -28290.384766, 7508.328613>, <0, -11.468691, 0 > )
	}
	else if( mapName.find( "mp_rr_desertlands" ) >= 0 )
	{
		MunitionsBox_SpawnMunitionsBoxProp( <7051.270508, -20977.933594, -3047.968750>, < 0, 135.772964, 0> )
		MunitionsBox_SpawnMunitionsBoxProp( <27152.400391, -21183.148438, -3167.202637>, < 0, -130.858368, 0> )
		MunitionsBox_SpawnMunitionsBoxProp( <19783.357422, -37974.476563, -2303.968750>, < 0, 144.369751, 0> )
		MunitionsBox_SpawnMunitionsBoxProp( <3184.508301, -38995.296875, -2772.917725>, < 0, 143.963516, 0> )
		MunitionsBox_SpawnMunitionsBoxProp( <-7475.288086, -29397.343750, -3563.787354>, < 0, 127.375259, 0> )
		MunitionsBox_SpawnMunitionsBoxProp( <-19247.687500, -20534.246094, -4320.118652>, < 0, -173.748245, 0> )
		MunitionsBox_SpawnMunitionsBoxProp( <-2922.646973, -11600.609375, -3679.937012>, < 0, -135.686646, 0> )
		MunitionsBox_SpawnMunitionsBoxProp( <20998.808594, -10431.543945, -4139.164063>, < 0, 153.126022, 0> )
		MunitionsBox_SpawnMunitionsBoxProp( <-17061.667969, -7355.215332, -3686.968750>, < 0, 47.443512, 0> )
		MunitionsBox_SpawnMunitionsBoxProp( <-12802.795898, 3476.284180, -3086.213135>, < 0, -65.296494, 0> )
		MunitionsBox_SpawnMunitionsBoxProp( <-19091.609375, 13686.468750, -3607.011719>, < 0, -84.678947, 0> )
		MunitionsBox_SpawnMunitionsBoxProp( <-9969.223633, 25954.375000, -3645.968750>, < 0, 128.228851, 0> )
		MunitionsBox_SpawnMunitionsBoxProp( <4968.516602, 27579.185547, -4561.959473>, < 0, -116.744194, 0> )
		MunitionsBox_SpawnMunitionsBoxProp( <18396.412109, 30176.363281, -4642.220703>, < 0, -37.575581, 0> )
		MunitionsBox_SpawnMunitionsBoxProp( <12081.490234, 15466.110352, -4425.539551>, < 0, 94.210670, 0> )
		MunitionsBox_SpawnMunitionsBoxProp( <8138.310059, 6933.407227, -4170.497070>, < 0, 145.944305, 0> )
		MunitionsBox_SpawnMunitionsBoxProp( <30692.914063, 9521.009766, -3463.968750>, < 0, -167.166382, 0> )
		MunitionsBox_SpawnMunitionsBoxProp( < -27224.345703, 8811.740234, -3168.968750> , <0, -35.188007, 0 > )
	}
	else if( mapName.find( "mp_rr_canyonlands" ) >= 0 )
	{
		MunitionsBox_SpawnMunitionsBoxProp( <-7092.843750, 37688.542969, 6403.635742>, <0,  -102.614441, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <9034.998047, 30638.275391, 5336.031250>, <0,  177.197205, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <27521.218750, 25632.458984, 4308.031250>, <0,  99.515610, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <36103.132813, 22305.863281, 4160.061523>, <0,  -139.208328, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <-20254.349609, 21990.312500, 2219.966309>, <0,  18.639416, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <-6579.455078, 16844.576172, 3008.031250>, <0,  86.385300, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <24239.775391, 9603.304688, 2626.391357>, <0,  -149.418427, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <-16531.990234, 14661.212891, 3719.696533>, <0,  56.170425, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <-23434.531250, 10234.173828, 3028.031250>, <0,  -106.413124, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <-11572.135742, 4624.170410, 2847.031250>, <0,  13.698462, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <-25679.890625, -3690.875977, 2717.093750>, <0,  -75.846512, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <-20111.236328, -13394.391602, 2840.031250>, <0,  101.286247, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <-9414.827148, -17630.410156, 2422.996094>, <0,  41.519188, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <3721.574707, -10598.234375, 2760.031250>, <0,  -174.828934, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <8024.411621, -28177.857422, 3179.075928>, <0,  -93.311874, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <23714.490234, -22699.140625, 4370.031250>, <0,  173.893753, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <22348.855469, -15469.926758, 4923.531250>, <0,  -6.640507, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <27069.205078, -4922.058594, 4328.031250>, <0,  -95.333275, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <15436.791016, -1440.817749, 5236.031250>, <0,  94.769272, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <27487.662109, 3010.136475, 3192.031250>, <0,  18.596706, 0 > )
		MunitionsBox_SpawnMunitionsBoxProp( <34943.925781, 1396.181152, 3469.078125>, <0,  -72.181503, 0 > )
	}
	else if( mapName.find( "mp_rr_olympus" ) >= 0 )
	{
		MunitionsBox_SpawnMunitionsBoxProp( < -17568.328125, 32218.265625, -6179.542480> ,<0,  79.001816 ,0 > )
		MunitionsBox_SpawnMunitionsBoxProp( < -25131.880859, 22003.732422, -6295.968750> ,<0,  -53.895424 ,0 > )
		MunitionsBox_SpawnMunitionsBoxProp( < -32754.185547, 12350.286133, -5618.968750> ,<0,  94.086243 ,0 > )
		MunitionsBox_SpawnMunitionsBoxProp( < -12320.904297, 11439.777344, -6143.650391> ,<0,  114.556824 ,0 > )
		MunitionsBox_SpawnMunitionsBoxProp( < -6142.036133, 22152.521484, -6139.968750> ,<0,  173.620575 ,0 > )
		MunitionsBox_SpawnMunitionsBoxProp( < 6288.772461, 22756.076172, -6750.911621> ,<0,  85.044746 ,0 > )
		MunitionsBox_SpawnMunitionsBoxProp( < 24841.947266, 6192.139648, -3455.941650> ,<0,  -0.824509 ,0 > )
		MunitionsBox_SpawnMunitionsBoxProp( < 16932.263672, -4215.321777, -4519.968750> ,<0,  -20.539833 ,0 > )
		MunitionsBox_SpawnMunitionsBoxProp( < 22898.675781, -18206.412109, -5215.968750>,< 0,  -161.459045 ,0 > )
		MunitionsBox_SpawnMunitionsBoxProp( < 2720.029053, -17965.804688, -5342.937988>,< 0,  -140.576035 ,0 > )
		MunitionsBox_SpawnMunitionsBoxProp( < 6967.930664, -24381.466797, -5333.019531>,< 0,  -90.162697 ,0 > )
		MunitionsBox_SpawnMunitionsBoxProp( < -2172.460938, -31811.656250, -4724.232422>,< 0,  159.058472 ,0 > )
		MunitionsBox_SpawnMunitionsBoxProp( < -17709.517578, -20948.197266, -4740.470215>,< 0,  -97.639221 ,0 > )
		MunitionsBox_SpawnMunitionsBoxProp( < -33789.492188, -15155.681641, -3807.968750>,< 0,  51.616116 ,0 > )
		MunitionsBox_SpawnMunitionsBoxProp( < -41223.160156, -9696.855469, -3341.412598>,< 0,  0.957459 ,0 > )
		MunitionsBox_SpawnMunitionsBoxProp( < -23330.314453, 934.135376, -5129.968750>,< 0,  -122.098785 ,0 > )

		MunitionsBox_SpawnMunitionsBoxProp(< -3763.263916, -73.628296, -6119.968750>, <0, 69.919426, 0 >)
		MunitionsBox_SpawnMunitionsBoxProp(<3550.017578, 9624.615234, -5129.609375>, <0, -113.303101, 0 >)
	}
	else if( mapName.find( "mp_rr_tropic_island" ) >= 0 )
	{
		MunitionsBox_SpawnMunitionsBoxProp(< -1098.894165, -40487.445313, -647.938904>, <0, -38.675213, 0 >)
		MunitionsBox_SpawnMunitionsBoxProp(< 14797.683594, -29291.697266, 869.257507>, <0, 141.407349, 0 >)
		MunitionsBox_SpawnMunitionsBoxProp(< 29939.796875, -30165.068359, 65.915489>, <0, -132.053284, 0 >)
		MunitionsBox_SpawnMunitionsBoxProp(< -17702.052734, -21369.074219, 822.658386>, < 0, 146.176987, 0 >)
		MunitionsBox_SpawnMunitionsBoxProp(< -36247.976563, -17899.390625, 173.579910>, < 0, 67.305817, 0 >)
		MunitionsBox_SpawnMunitionsBoxProp(< 8210.808594, -18060.873047, 632.062561>, < 0, 136.328400, 0 >)
		MunitionsBox_SpawnMunitionsBoxProp(< 32231.312500, -11393.885742, 148.638596>, <0, -95.415283, 0 >)
		MunitionsBox_SpawnMunitionsBoxProp(< -32561.880859, 2792.754883, 701.263000>, <0, 53.932713, 0 >)
		MunitionsBox_SpawnMunitionsBoxProp(< -18578.906250, 21173.152344, 2864.031250>, <0, -165.066055, 0 >)
		MunitionsBox_SpawnMunitionsBoxProp(< -23905.939453, 32907.843750, 192.627213>, <0, -49.500519, 0 >)
		MunitionsBox_SpawnMunitionsBoxProp(< 7652.769531, 37730.832031, 3703.412598>, <0, -177.891998, 0 >)
		MunitionsBox_SpawnMunitionsBoxProp(< 24914.992188, 38021.035156, 10144.062500>, <0, -176.209091, 0 >)
		MunitionsBox_SpawnMunitionsBoxProp(< 37543.011719, 36006.230469, 10969.444336>, <0, -137.699539, 0 >)
		MunitionsBox_SpawnMunitionsBoxProp(< 28721.417969, 25273.289063, 8984.031250>, <0, 76.829750, 0 >)
		MunitionsBox_SpawnMunitionsBoxProp(< 25478.740234, 11102.598633, 6561.884766>, < 0, -105.816376, 0 >)
		MunitionsBox_SpawnMunitionsBoxProp( < 17468.419922, 17565.082031, 5859.180664>, < 0, 173.922302, 0 > )
	}
}

entity function MunitionsBox_SpawnMunitionsBoxPropFromExistingBin( entity bin )
{
	entity newBin = MunitionsBox_SpawnMunitionsBoxProp(bin.GetOrigin(), bin.GetAngles())
	if (IsValid(bin.GetParent()))
		newBin.SetParent( bin.GetParent() )
	LootBin_TransferLootBinServerData( bin, newBin, eLootBinCompartment.REGULAR )
	return newBin
}

entity function MunitionsBox_SpawnMunitionsBoxProp ( vector position, vector angles )
{
	entity box = CreateLootBin(position, angles, false, false, true)
	if( !IsValid( box ) )
		return box

	InitLootBin( box )
	box.SetSkin( box.GetSkinIndexByName( MUNITIONS_BOX_LOOT_BIN_SKIN_NAME ) )
	LootBin_SetAddItemsToBinOnOpenCallback( box, AddSecretCompartmentLoot )

	if( !LootBin_RandomizePerkBinsFromExistingBins() )
	{
		array<string> mainCompartmentLoot = GetMainCompartmentLoot()
		LootBin_PutMultipleLootItemsInside( box, eLootBinCompartment.REGULAR, mainCompartmentLoot )
	}

	file.lootBoxes.append( box )

	OnMunitionsBoxSpawned( box )

	return box
}

bool function IsCrateWeapon( entity weapon )
{
	string itemRef = weapon.GetWeaponClassName()
	LootData data = SURVIVAL_Loot_GetLootDataByRef( itemRef )
	return data.tier == 5
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	//printt( "OnPlayerKilled for " + victim.GetPlayerName() )

	if( !Perks_DoesPlayerHavePerk( victim, ePerkIndex.MUNITIONS_BOX ) )
		return

	entity previousPrimary = victim.GetLatestPrimaryWeaponForIndexZeroOrOne( eActiveInventorySlot.mainHand )
	if( previousPrimary == null )
		return
	if( IsCrateWeapon( previousPrimary ) )
	{
		previousPrimary = null
		for( int i=0; i <= WEAPON_INVENTORY_SLOT_PRIMARY_1; i++ )
		{
			entity weaponAtSlot = victim.GetNormalWeapon( i )
			if( !weaponAtSlot )
				continue
			if( !IsCrateWeapon( weaponAtSlot ) )
			{
				previousPrimary = weaponAtSlot
				break
			}
		}
		if( !previousPrimary )
			return
	}

	file.respawnGrantTable[victim] <- previousPrimary.GetWeaponClassName()

}

void function OnPlayerRespawned( entity player )
{
	if( GetGameState() < eGameState.Playing )
		return

	if( !Perks_DoesPlayerHavePerk( player, ePerkIndex.MUNITIONS_BOX ) )
		return

	// delay this by a frame so that we grant the weapon after normal respawn logic takes our inventory away
	thread Delayed_OnPlayerRespawn( player )
}

void function Delayed_OnPlayerRespawn( entity player )
{
	WaitFrame()

	if ( !IsValid( player ) )
		return

	// always grant the grenade regardless of them having a valid primary to get back
	//printt( "Delayed_OnPlayerRespawn for " + player.GetPlayerName() )
	//SURVIVAL_AddToPlayerInventory( player, LOOT_NAME_FRAG ) // Disabled as it's causing preflight to fail frequently, intermittently in SmokeTest_rr_deathbox

	if( !( player in file.respawnGrantTable ) )
		return

	string weaponToGrant = file.respawnGrantTable[player]
	delete file.respawnGrantTable[player]

	// give them the primary and some ammo
	entity weapon = player.GiveWeapon( weaponToGrant, WEAPON_INVENTORY_SLOT_PRIMARY_0 )
	player.SetActiveWeaponBySlot( eActiveInventorySlot.mainHand, WEAPON_INVENTORY_SLOT_PRIMARY_0 )
	if( weapon.UsesClipsForAmmo() )
		weapon.SetWeaponPrimaryClipCount( weapon.GetWeaponPrimaryClipCountMax() )
	int ammoType = weapon.GetWeaponAmmoPoolType()
	string ammoTypeRef = AmmoType_GetRefFromIndex( ammoType )
	LootData data = SURVIVAL_Loot_GetLootDataByRef( ammoTypeRef )
	player.AmmoPool_SetCount( ammoType, data.countPerDrop )
}
#endif


#if CLIENT
void function MunitionsBox_ServerToClient_DisplayOpenedMunitionsBoxPrompt()
{
	AddOnscreenPromptFunction( "quickchat", InvokePingOpenedMunitionsBox, 6.0, Localize( "#PING_OPEN_MUNITIONS_BOX" ) )
}

void function InvokePingOpenedMunitionsBox( entity player )
{
	Remote_ServerCallFunction( "MunitionsBox_ClientToServer_MarkMunitionsBoxLoot" )
}

void function Perk_MunitionsBin_RuiThinkThread( var rui, entity ent )
{
	RuiSetFloat( rui, "minAlphaDist", 1500 )
	RuiSetFloat( rui, "maxAlphaDist", 2000 )
}
#endif