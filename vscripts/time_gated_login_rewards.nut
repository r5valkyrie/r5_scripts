#if SERVER || CLIENT || UI
global function TimeGatedLoginRewards_Init
global function LoginEvent_GetLoginRewards
#endif


#if SERVER || CLIENT || UI
struct FileStruct_LifetimeLevel
{
	#if SERVER
		EntitySet loginRewardsChecked
	#endif
}
#endif


#if SERVER || CLIENT
FileStruct_LifetimeLevel fileLevel // resets every level change
#elseif UI
FileStruct_LifetimeLevel& fileLevel // resets every level change

struct {
	//
} fileVM // resets every UI VM reset
#endif


#if SERVER || CLIENT || UI
void function TimeGatedLoginRewards_Init()
{
	#if UI
		FileStruct_LifetimeLevel newFileLevel
		fileLevel = newFileLevel
	#endif

	#if SERVER
		AddCallback_QueueServersideScriptGRXOperations( GiveTimeGatedLoginRewards )
		AddCallback_OnClientDisconnected( LoginEvent_OnPlayerDisconnected )
	#endif
}
#endif


#if SERVER || CLIENT || UI
array<ItemFlavor> function GetActiveLoginEvents( int t )
{
	Assert( IsItemFlavorRegistrationFinished() )
	array<ItemFlavor> activeEvents
	foreach ( ItemFlavor ev in GetAllItemFlavorsOfType( eItemType.calevent_login ) )
	{
		if ( !CalEvent_IsActive( ev, t ) )
			continue

		activeEvents.append( ev )

	}

	return activeEvents
}
#endif


#if SERVER
// TODO: *if* you need to add a temporary check for a given calevent in here, please remove it when the event is over
void function GiveTimeGatedLoginRewards( entity player )
{
	if ( IsLowCostBot( player ) )
		return

	// return early if inventory isn't ready since something else hijacked our ready state (otherwise we'll error trying to grant rewards to non-ready inventory)
	if ( !GRX_IsInventoryReady( player ) )
		return

	array<ItemFlavor> activeLoginEvents = GetActiveLoginEvents( GetUnixTimestamp() )

	// DEFINE SPECIAL LOGIN REWARDS
	// if there are no rewards that should be active then delete the assignments (leave the table empty)
	// technically tables are slow; but since this is tiny, it won't impact perf noticably - refactor if we have more simultaneous events in the future
	table < asset, string > activeLoginRewards = {}
	activeLoginRewards[$"settings/itemflav/calevent/login_s16_anniversary_bonus_week_1.rpak"] <- "rewardseq_login_s16_anniversary_bonus_week_1"
	activeLoginRewards[$"settings/itemflav/calevent/login_s16_anniversary_bonus_week_2.rpak"] <- "rewardseq_login_s16_anniversary_bonus_week_2"

	if ( player in fileLevel.loginRewardsChecked )
		return

	fileLevel.loginRewardsChecked[ player ] <- IN_SET

	foreach ( ItemFlavor event in activeLoginEvents )
	{
		array<ItemFlavor> rewards = LoginEvent_GetLoginRewards( event )
		asset eventAsset = ItemFlavor_GetAsset( event )

		if( eventAsset == $"settings/itemflav/calevent/login_steam_launch.rpak" )
		{
			//if( !player.IsUsingSteam() )
			//	continue
		}

		if ( eventAsset == $"settings/itemflav/calevent/login_switch_launch.rpak" )
		{
			//if ( GetHardwareFromName( player.GetHardwareName() ) != HARDWARE_SWITCH )
				continue
		}

		// BEGIN SPECIAL TREATMENT LOGIN REWARDS
		// we could make this generic with 1) a rewardseq to use (if required) and 2) a gating-stat for make-good (if required)
		// only process special login rewards if they are defined in the table at the top of this function
		if ( activeLoginRewards.len() > 0 )
		{
			// if the activeLoginRewards table is empty (no reward events) then we can just default to blank string
			string seqName = eventAsset in activeLoginRewards ? activeLoginRewards[ eventAsset ] : ""

			int seqIdx = 1
			if ( seqName != "" )
				seqIdx = GRX_GetSequenceNumber( player, seqName )
			if ( seqIdx < 1 && seqName != "" )
			{
				ItemFlavorBag loginRewards
				foreach ( ItemFlavor reward in rewards )
				{
					if ( ItemFlavor_GetGRXMode( reward ) == eItemFlavorGRXMode.NONE )
						continue

					if ( ItemFlavor_GetGRXMode( reward ) == GRX_ITEMFLAVORMODE_REGULAR )
					{
						if ( GRX_IsItemOwnedByPlayer( reward, player ) )
							continue
					}

					if ( loginRewards.flavors.contains( reward ) )
					{
						// this is because we use parallel arrays rather than a table for an ItemFlavorBag
						for ( int i = 0; i < loginRewards.quantities.len(); i++ )
						{
							if ( loginRewards.flavors[i] == reward )
							{
								int qty = loginRewards.quantities[i]
								loginRewards.quantities[i] = qty + 1
								break
							}
						}
					}
					else
					{
						loginRewards.flavors.append( reward )
						loginRewards.quantities.append( 1 )
					}
				}

				GrantRewardsConfig grc
				grc.what = loginRewards
				grc.rewardSequenceName = seqName
				grc.rewardSequenceDesiredIdx = 1
				grc.rewardSequenceExpectedIdx = 0

				grc.sourceFlav = event
				grc.showCeremony = true
				int result = GRX_GrantRewards( player, grc )
				Assert( result == eGrantRewardsResult.ASYNC )

				continue
			}
			else if ( seqIdx >= 1 && seqName != "" )
			{
				continue
			}
		}
		// END SPECIAL TREATMENT LOGIN REWARDS

		// default reward flow
		foreach ( ItemFlavor reward in rewards )
		{
			if ( GRX_HasItem( player, ItemFlavor_GetGRXIndex( reward ) ) )
				continue

			GrantRewardsConfig grc
			grc.what = MakeItemFlavorBag( { [reward] = 1, } )
			grc.sourceFlav = event
			grc.showCeremony = true
			int result = GRX_GrantRewards( player, grc )
			Assert( result == eGrantRewardsResult.DONE )
		}
	}
}
#endif


#if SERVER || CLIENT || UI
array<ItemFlavor> function LoginEvent_GetLoginRewards( ItemFlavor event )
{
	Assert( ItemFlavor_GetType( event ) == eItemType.calevent_login )

	array<ItemFlavor> rewards = []
	foreach ( var rewardBlock in IterateSettingsAssetArray( ItemFlavor_GetAsset( event ), "loginRewards" ) )
	{
		asset rewardAsset = GetSettingsBlockAsset( rewardBlock, "flavor" )
		if ( IsValidItemFlavorSettingsAsset( rewardAsset ) )
			rewards.append( GetItemFlavorByAsset( rewardAsset ) )
	}
	return rewards
}
#endif


#if SERVER
void function LoginEvent_OnPlayerDisconnected( entity player )
{
	if ( IsLobby() )
	{
		if ( player in fileLevel.loginRewardsChecked )
			delete fileLevel.loginRewardsChecked[ player ]
	}
}
#endif