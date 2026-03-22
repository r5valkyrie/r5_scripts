global function ExtraShields_Init

#if SERVER || CLIENT
global function GetPlayerExtraShields
global function GetPlayerExtraShieldsTier
#endif
#if SERVER
global function SetPlayerExtraShields
global function SetPlayerExtraShieldsTier
#endif

global const string EXTRA_SHIELDS_DURATION_NETFLOAT = "extra_shields_duration"
global const float EXTRA_SHIELDS_TOTAL_DURATION = 28.0
global const int EXTRA_SHIELD_DECAY_RATE = 2


#if SERVER
const float SHIELD_DURATION_TICK_WAIT = .1
#endif


struct
{
	float totalShieldDuration
#if SERVER
	int shieldDecayRate
#endif
#if CLIENT
	var extraShieldDurationRui
#endif
}file


void function ExtraShields_Init()
{
	file.totalShieldDuration = GetCurrentPlaylistVarFloat( "extra_shield_total_shield_duration", EXTRA_SHIELDS_TOTAL_DURATION )

	RegisterNetworkedVariable( EXTRA_SHIELDS_DURATION_NETFLOAT, SNDC_PLAYER_EXCLUSIVE, SNVT_FLOAT_RANGE , file.totalShieldDuration, 0.0, file.totalShieldDuration )

#if CLIENT
	RegisterNetVarFloatChangeCallback( EXTRA_SHIELDS_DURATION_NETFLOAT, ExtraShields_OnExtraShieldDurationChanged )
#endif

	#if SERVER
		AddCallback_OnPlayerKilled( ExtraShields_OnPlayerRespawned ) //Move to FD game mode script

		RegisterSignal( "ExtraShieldsChanged" )

		file.shieldDecayRate = GetCurrentPlaylistVarInt( "extra_shield_decay_rate", EXTRA_SHIELD_DECAY_RATE )
	#endif
}

#if SERVER || CLIENT
int function GetPlayerExtraShields( entity player )
{
	return 0
}

int function GetPlayerExtraShieldsTier( entity player )
{
	return 0
}

float function GetPlayerExtraShieldsDuration( entity player )
{
	return 0.0
}
#endif

#if SERVER
void function ExtraShields_OnPlayerRespawned( entity victim, entity attacker, var damageInfo )
{
	// wait a frame so that we know what level to drop the players shields at before resetting
	thread ExtraShields_ResetExtraShieldsDelayed( victim )
}

void function ExtraShields_ResetExtraShieldsDelayed( entity victim )
{
	WaitFrame()
	if( !IsValid( victim ) )
		return
	
	SetPlayerExtraShields( victim, 0 )
	SetPlayerExtraShieldsTier( victim, 1 )
}

void function SetPlayerExtraShields( entity player, int val )
{
	//player.SetExtraShieldHealth( val )

	player.Signal( "ExtraShieldsChanged" )
	if( val <= 0 )
	{
		thread RegenExtraShieldDuration( player )
	}
	else
	{
                                    
                                                                                      
        
		{
			thread DecayExtraShields( player, val )
		}
	}
}

void function SetPlayerExtraShieldDuration( entity player, float val )
{
	player.SetPlayerNetFloat( EXTRA_SHIELDS_DURATION_NETFLOAT, val )
}

void function RegenExtraShieldDuration( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "ExtraShieldsChanged" )

	float curDuration= GetPlayerExtraShieldsDuration( player )
	while( curDuration < file.totalShieldDuration )
	{
		wait( SHIELD_DURATION_TICK_WAIT )
		curDuration = min( curDuration + SHIELD_DURATION_TICK_WAIT, file.totalShieldDuration )
		SetPlayerExtraShieldDuration( player, curDuration )
	}
}

void function DecayExtraShields( entity player, int extraShield )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "ExtraShieldsChanged" )

	float curDuration = GetPlayerExtraShieldsDuration( player )
	while( curDuration > 0 )
	{
		wait( SHIELD_DURATION_TICK_WAIT )
		curDuration = max( curDuration - SHIELD_DURATION_TICK_WAIT, 0.0 )
		SetPlayerExtraShieldDuration( player, curDuration )
	}

	// we can track this internally because changes to this netvar will reset the thread
	while ( extraShield > 0 )
	{
		wait SHIELD_DURATION_TICK_WAIT
		extraShield     = maxint(extraShield-file.shieldDecayRate, 0)
		//player.SetExtraShieldHealth( extraShield )
	}

	// downgrade the player's shield to the tier it should be in
	string newArmorRef = UpgradeCore_GetPlayerShieldCoreRef( player )
	thread SURVIVAL_GivePlayerEquipment( player, newArmorRef, player.GetShieldHealthMax() )

	thread RegenExtraShieldDuration( player )
}

void function SetPlayerExtraShieldsTier( entity player, int val )
{
	//player.SetExtraShieldTier( val )
}
#endif

#if CLIENT
void function ExtraShields_OnExtraShieldDurationChanged( entity player, float newDuration )
{
	if ( player != GetLocalViewPlayer() )
		return

	int extraShields = GetPlayerExtraShields( player )
	if( newDuration <= 0.0 || extraShields <= 0 )
	{
		if( file.extraShieldDurationRui != null )
		{
			if ( extraShields <= 0 )
			{
				RuiDestroyIfAlive( file.extraShieldDurationRui )
				file.extraShieldDurationRui = null
			}
			else
			{
				RuiSetInt( file.extraShieldDurationRui, "state", eArcFlashState.DECAY )
			}
		}
		return
	}

	if ( file.extraShieldDurationRui == null )
	{
		file.extraShieldDurationRui = CreateCockpitPostFXRui( $"ui/extra_shield_indicator.rpak", HUD_Z_BASE )
		RuiSetFloat( file.extraShieldDurationRui, "timeTotal", file.totalShieldDuration )
		RuiSetInt( file.extraShieldDurationRui, "state", eArcFlashState.ACTIVE )
		// RUI_TRACK_EXTRA_SHIELD_TIER_INT not available in S3
		//RuiTrackInt( file.extraShieldDurationRui, "tierColor", player, RUI_TRACK_EXTRA_SHIELD_TIER_INT )
	}

	RuiTrackFloat( file.extraShieldDurationRui, "timeRemaining", player, RUI_TRACK_SCRIPT_NETWORK_VAR, GetNetworkedVariableIndex( EXTRA_SHIELDS_DURATION_NETFLOAT ) )
}

void function ExtraShields_OnExtraShieldTierChanged( entity player, int newTier )
{
	if( file.extraShieldDurationRui != null && player == GetLocalViewPlayer())
	{
		vector tierColor = GetKeyColor( COLORID_TEXT_LOOT_TIER0, newTier ) / 255.0
		RuiSetFloat3( file.extraShieldDurationRui, "colorTint", tierColor )
	}
}
#endif
