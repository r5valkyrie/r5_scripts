global function PhaseDriver_Init
global function PhaseDriver_IsPhaseDriverEnabled
#if DEVELOPER && SERVER
global function DEV_ToggleDriverVFX
global function DEV_ToggleDriverCooldown
//global function ActiveSparks
//global function AmbientSparks
#endif // DEV && SERVER

global const asset PHASEDRIVER_VFX_LOOTSPAWN = $"P_phase_tower_loot_spawn"
global const asset PHASEDRIVER_VFX_AMBIENT = $"P_phase_tower_ambient"
global const asset PHASEDRIVER_VFX_ACTIVE = $"P_phase_tower_active"
global const asset PHASEDRIVER_VFX_SPARKS_BATTERY_1 = $"P_phase_twr_batt_exp_01"
global const asset PHASEDRIVER_VFX_SPARKS_BATTERY_2 = $"P_phase_twr_batt_exp_02"
global const asset PHASEDRIVER_VFX_SPARKS_PORTAL_1 = $"P_phase_twr_batt_exp_03"
global const asset PHASEDRIVER_VFX_SPARKS_PORTAL_2 = $"P_env_sparks_dir_LG_02"

const float LOOT_ROLLER_SPAWN_DELAY = 0.0 // 0.5

table< asset, float > vfxLifetime = {}

struct PhaseDriverStruct
{
	float lastUsedTime = -100.0
	float cooldown = 45.0
	bool isUsable = true
	array<entity> panels
	array<entity> spawnPoints
	array<entity> activeProps
	int propBudget = 40
	int nodesPerUse = 5
	array<entity> cargoBins
	vector emitSFX_origin
	vector vfx_origin
	vector vfx_angles
	entity vfx_ambient
	entity vfx_active

	float spark_stutter_battery_ambient_min = 2.5
	float spark_stutter_battery_ambient_max = 4.0
	float spark_stutter_battery_active_min = 1.0
	float spark_stutter_battery_active_max = 1.5

	float spark_stutter_portal_ambient_min = 0.2
	float spark_stutter_portal_ambient_max = 0.6
	float spark_stutter_portal_active_min = 0.05
	float spark_stutter_portal_active_max = 0.2

	array< vector > sparks_battery_origins =
	[
		< -17819.5, -23259.5, -2811.5 >,
	 	< -17651.5, -23261.4, -2811.32 >,
		< -17135.5, -22745.4, -2811.32 >,
		< -17127.7, -22565.6, -2811.13 >,
		< -17647.2, -22058.1, -2809.29 >,
		< -17820.3, -22027.1, -2818.74 >,
		< -18333.9, -22576.6, -2808.5 >,
		< -18354.0, -22751.4, -2807.92 >,
	]
	array< vector > sparks_battery_angles =
	[
		< 0.0612351, 89.3366, 32.1913 >,
		< 0.0612351, 89.3366, 32.1913 >,
		< 0.0612356, 177.506, 32.1913 >,
		< 0.0612356, 177.506, 32.1913 >,
		< -4.39719, -94.1236, 27.3742 >,
		< -4.39719, -94.1236, 27.3742 >,
		< 0.187968, -6.56482, 25.2541 >,
		< 0.187968, -6.56482, 25.2541 >,
	]

	array< vector > sparks_portal_origins =
	[
		< -17733.9, -21784.3, -3244.4 >, //(DIRECTLY ABOVE CONSOLE 1)
		< -17416.3, -21845.6, -3246.4 >,
		< -17121.2, -22041.9, -3246.4 >, //(CLOCKWISE AFTER CONSOLE 1)
		< -16926.8, -22337.6, -3248.4 >,
		< -16866.1, -22657.2, -3248.4 >,
		< -16928.1, -22974.5, -3248.4 >,
		< -17122.6, -23270.2, -3248.4 >, //(DIRECTLY ABOVE CONSOLE 3)
		< -17416.5, -23464.9, -3248.4 >,
		< -17735.9, -23526.3, -3244.4 >,
		< -18054.3, -23464.4, -3244.4 >,
		< -18351.3, -23270.9, -3244.4 >, //(DIRECTLY ABOVE CONSOLE 2)
		< -18543.9, -22975.9, -3244.4 >,
		< -18603.2, -22656.1, -3244.4 >,
		< -18541.1, -22338.1, -3244.4 >,
		< -18350.1, -22041.3, -3244.4 >,
		< -18054.8, -21846.7, -3244.4 >,
	]

	array< vector > sparks_portal_angles =
	[
		< 85.5456, -1.181, 91.4244 >,
		< 85.9973, 159.013, -83.2925 >,
		< 84.1598, -84.9124, 54.1261 >,
		< 77.5916, 109.961, -89.4222 >,
		< 81.7195, 79.8108, -99.7312 >,
		< 85.2865, -12.46, -180 >,
		< 84.1767, 43.8258, -88.4144 >,
		< 80.7317, 21.7975, -90.4662 >,
		< 86.502, 93.191, 3.18506 >,
		< 84.3374, -22.4576, -88.0305 >,
		< 87.9906, -47.2809, -93.363 >,
		< 85.6525, -68.4407, -89.3891 >,
		< 88.9014, -91.0186, -89.338 >,
		< 85.2598, -113.474, -86.3478 >,
		< 87.1546, -134.874, -92.6642 >,
		< 87.6447, -158.202, -84.224 >,
	]
#if DEVELOPER
	bool bypassCooldown = false
	bool flipVFX = false
#endif // DEV
}
PhaseDriverStruct phaseDriverStruct

void function PhaseDriver_Init()
{
#if SERVER
	//printf( "PhaseDriver_Init()" )
	AddSpawnCallback( "info_target", PhaseDriverSpawnPointInit )
	AddSpawnCallback( "prop_dynamic", PhaseDriverPanelInit )
	AddCallback_EntitiesDidLoad( PhaseDriverBootstrap )

	PrecacheScriptString( "panel_phasedriver" )
	PrecacheScriptString( PHASEDRIVER_PANEL_COOLDOWN_SCRIPTNAME )
	PrecacheScriptString( PHASEDRIVER_PANEL_SCRIPTNAME )

	PrecacheParticleSystem( PHASEDRIVER_VFX_LOOTSPAWN )
	PrecacheParticleSystem( PHASEDRIVER_VFX_AMBIENT )
	PrecacheParticleSystem( PHASEDRIVER_VFX_ACTIVE )
	PrecacheParticleSystem( PHASEDRIVER_VFX_SPARKS_BATTERY_1 )
	PrecacheParticleSystem( PHASEDRIVER_VFX_SPARKS_BATTERY_2 )
	PrecacheParticleSystem( PHASEDRIVER_VFX_SPARKS_PORTAL_1 )
	PrecacheParticleSystem( PHASEDRIVER_VFX_SPARKS_PORTAL_2 )

	RegisterSignal( "PhaseDriver_CancelCooldown" )
	RegisterSignal( "PhaseDriver_Ambient" )
	RegisterSignal( "PhaseDriver_Active" )

	vfxLifetime[PHASEDRIVER_VFX_LOOTSPAWN] <- 2.0
	vfxLifetime[PHASEDRIVER_VFX_SPARKS_BATTERY_1] <- 6.0
	vfxLifetime[PHASEDRIVER_VFX_SPARKS_BATTERY_2] <- 2.0
	vfxLifetime[PHASEDRIVER_VFX_SPARKS_PORTAL_1] <- 5.0
	vfxLifetime[PHASEDRIVER_VFX_SPARKS_PORTAL_2] <- 1.0
#endif
}

void function PhaseDriverBootstrap()
{
#if SERVER
	EnableVFX_Ambient()
	EnabledSparks_Ambient()
#endif
}

void function PhaseDriverPanelInit( entity panel )
{
#if SERVER
	//printf( "PhaseDriver: %s", panel.GetScriptName()  )
	if( panel.GetScriptName().find( "oly_tele_toy" ) >= 0 )
	{
		panel.SetScriptName( "panel_phasedriver" )
		phaseDriverStruct.panels.append( panel )
		SetupPhaseDriverPanel( panel )
	}
#endif // SERVER
}

void function PhaseDriverSpawnPointInit( entity spawnPoint )
{
	#if SERVER
		//printf( "PhaseDriverSpawnPointInit(): %s", spawnPoint.GetScriptName() )

		if( spawnPoint.GetScriptName().find( "telephaser_spawn") >= 0 )
		{
			//printf( "PhaseDriver Assigned SpawnPoint!" )
			phaseDriverStruct.spawnPoints.append( spawnPoint )
		}

		if( spawnPoint.GetScriptName().find( "telephaser_emit_sfx") >= 0 )
		{
			//printf( "PhaseDriver Assigned Emit SFX entity" )
			phaseDriverStruct.emitSFX_origin = spawnPoint.GetOrigin()
		}

		if( spawnPoint.GetScriptName().find( "phasedriver_vfx_ambient_active") >= 0 )
		{
			//printf( "PhaseDriver Assigned Emit SFX entity" )
			phaseDriverStruct.vfx_origin = spawnPoint.GetOrigin()
			phaseDriverStruct.vfx_angles = spawnPoint.GetAngles()
			phaseDriverStruct.vfx_ambient = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( PHASEDRIVER_VFX_AMBIENT ), phaseDriverStruct.vfx_origin, phaseDriverStruct.vfx_angles )
			phaseDriverStruct.vfx_active = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( PHASEDRIVER_VFX_ACTIVE ), phaseDriverStruct.vfx_origin, phaseDriverStruct.vfx_angles )
		}

	#endif // SERVER
}

void function PhaseDriverLootbinInit( entity bin )
{
	//---THIS ISN'T WORKING---ggcv
#if CLIENT
	printf( "client | bin instance name: %s", bin.GetInstanceName() )
#endif // CLIENT
#if SERVER
	printf( "server | bin instance name: %s", bin.GetInstanceName() )
	//if( bin.GetInstanceName() == "oly_tele_toy_bin" )
	//{
	//	phaseDriverStruct.cargoBins.append( bin )
	//	printf( "Registered a PhaseDriver Lootbin" )
	//}
#endif // SERVER
}

void function SetupPhaseDriverPanel( entity panel )
{
#if SERVER
	AddCallback_OnUseEntity_ServerOnly( panel, OnUse_PhaseDriverPanel )
	panel.SetUsePrompts( "#PHASEDRIVER_ACTIVATE", "#PHASEDRIVER_ACTIVATE" )
	panel.SetUsableByGroup ( "pilot" )
	panel.SetUsablePriority( USABLE_PRIORITY_LOW )
	panel.AddUsableValue( USABLE_CUSTOM_HINTS )
	panel.SetUsable()
#endif // SERVER
}

void function OnUse_PhaseDriverPanel( entity panel, entity player, int useInputFlags )
{
#if SERVER
	if( !CanUse_PhaseDriverPanel() )
	{
		return
	}

#if DEVELOPER
	printf( "Used a PhaseDriver Panel %s", panel.GetScriptName() )
#endif
	PlayBattleChatterLineToSpeakerAndTeam( player, "bc_usingPhaseDriver" )
	EmitSoundOnEntity( panel, "Olympus_Mu2_Teleporter_Switch_Activate" )
	
	PIN_Interact( player, "phase_driver", panel.GetOrigin() )
#endif // SERVER

	thread PhaseDriverSequence_Thread( )
}

void function PhaseDriverSequence_Thread()
{
#if SERVER
	phaseDriverStruct.panels[0].EndSignal( "PhaseDriver_CancelCooldown" )

	phaseDriverStruct.isUsable = false
	foreach( entity panel in phaseDriverStruct.panels)
	{
		panel.UnsetUsable()
		panel.SetScriptName( PHASEDRIVER_PANEL_COOLDOWN_SCRIPTNAME )
		panel.SetSkin( 2 )
	}

	EmitSoundAtPosition( TEAM_UNASSIGNED, phaseDriverStruct.emitSFX_origin, "Olympus_MU2_Emit_Teleporter_ChargeUp", phaseDriverStruct.panels[0] )
	EnableVFX_Active()
	EnableSparks_Active()

	//thread ActiveSparks ()

	wait( 3.0 )

	foreach( entity panel in phaseDriverStruct.panels)
	{
		panel.SetUsable()
		panel.SetUsePrompts( "#PHASEDRIVER_RECHARGING", "#PHASEDRIVER_RECHARGING" )
	}

	EmitSoundAtPosition( TEAM_UNASSIGNED, phaseDriverStruct.emitSFX_origin, "Olympus_MU2_Emit_Teleporter_Activate", phaseDriverStruct.panels[0] )

	array<int> lootTiers

	for( int i = 0; i < 3; i++ )
	{
		lootTiers.append( RandomIntRangeInclusive( 2, 3 ) )
	}

	int highTierIndex = RandomInt( 3 )
	lootTiers[ highTierIndex ] = 4

	bool useInitialVelocity = true
	// spawn some loot rollers
	array< int > indices = [ 0, 1, 2 ]
	for (int i = 0; i < phaseDriverStruct.spawnPoints.len(); i++)
	{
		int randIndex = RandomInt( indices.len() )
		int index = indices[ randIndex ]
		indices.remove( randIndex )
		vector launchDir = <0, 0, 0>
		if( useInitialVelocity )
			launchDir = < RandomFloat( 0.1 ), RandomFloat( 0.1 ), -8 >
		float launchSpeed = 500.0
		vector spinDir = <0, 100, 0>
		float spinSpeed = 1000
		float noiseRadius = 50.0
		vector originNoise = <RandomFloatRange( -noiseRadius, noiseRadius ), RandomFloatRange( -noiseRadius, noiseRadius ), 0>
		vector spawnPos = phaseDriverStruct.spawnPoints[index].GetOrigin() + originNoise

		thread SpawnLootRollerOnDelay_Thread( spawnPos, phaseDriverStruct.spawnPoints[index].GetAngles(), lootTiers[i], Normalize( launchDir ), launchSpeed, spinDir, spinSpeed )

		EmitSoundAtPosition( TEAM_UNASSIGNED, spawnPos, "Olympus_Mu2_Emit_Teleporter_LootAppear", phaseDriverStruct.spawnPoints[index] )
		entity lootVFX = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( PHASEDRIVER_VFX_LOOTSPAWN ), spawnPos, <0, 0, 0> )
		lootVFX.kv.kill_for_replay = true
		thread DestroyFXAfterDelay_Thread( lootVFX, vfxLifetime[PHASEDRIVER_VFX_LOOTSPAWN] )
		wait 0.12
	}

	thread PhaseDriverCooldown()

	EnableVFX_Ambient()
	wait 1.0
	EnabledSparks_Ambient()

#endif // SERVER
}

void function SpawnLootRollerOnDelay_Thread( vector spawnPos, vector angles, int lootTier, vector launchDir, float launchSpeed, vector spinDir, float spinSpeed )
{
#if SERVER
	wait LOOT_ROLLER_SPAWN_DELAY
	LootRollerData launchRoller = LootRollers_CreatePhaseDriverLootRoller( spawnPos, angles, lootTier )
	LaunchLootRoller_SpinControl( launchRoller, launchDir, launchSpeed, spinDir, spinSpeed )
#endif // SERVER
}

void function ResetLootBins()
{
#if SERVER
	foreach( entity bin in phaseDriverStruct.cargoBins )
	{
		if( IsValid( bin ) )
		{
			thread LootBin_ForceClose_Thread( bin, true, true, true )
		}
	}
	wait 0.5
	foreach( entity bin in phaseDriverStruct.cargoBins )
	{
		// refresh the loot
		array<string> newRefs = SURVIVAL_GetMultipleWeightedItemsFromGroup( "Tick_Epic_Items", 3 )
		LootBin_PutMultipleLootItemsInside( bin, eLootBinCompartment.REGULAR, newRefs )
	}
#endif // SERVER
}

bool function CanUse_PhaseDriverPanel()
{
	return phaseDriverStruct.isUsable
}

void function PhaseDriverCooldown()
{
#if SERVER
	//phaseDriverStruct.panels[0].EndSignal( "PhaseDriver_CancelCooldown" )
	phaseDriverStruct.cooldown = GetCurrentPlaylistVarFloat("oly_phaser_cooldown_time", phaseDriverStruct.cooldown)

#if DEVELOPER
	if( !phaseDriverStruct.bypassCooldown )
	{
		wait phaseDriverStruct.cooldown
	}
#else
	wait phaseDriverStruct.cooldown
#endif
	phaseDriverStruct.isUsable = true
	foreach( entity panel in phaseDriverStruct.panels)
	{
		panel.SetUsePrompts( "#PHASEDRIVER_ACTIVATE", "#PHASEDRIVER_ACTIVATE" )
		panel.SetScriptName( PHASEDRIVER_PANEL_SCRIPTNAME )
		panel.SetSkin(0)
	}
#endif // SERVER
}

#if SERVER
void function BatterySparks_Ambient_Thread()
{
	svGlobal.levelEnt.EndSignal( "PhaseDriver_Active" )

	for( ;; )
	{
		int idx = RandomInt( phaseDriverStruct.sparks_battery_origins.len() )
		asset vfx = ( RandomInt( 100 ) % 2 ) == 0 ? PHASEDRIVER_VFX_SPARKS_BATTERY_1 : PHASEDRIVER_VFX_SPARKS_BATTERY_2
		entity vfx_ent = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( vfx ), phaseDriverStruct.sparks_battery_origins[idx], phaseDriverStruct.sparks_battery_angles[idx] )
		vfx_ent.kv.kill_for_replay = true
		thread DestroyFXAfterDelay_Thread( vfx_ent, vfxLifetime[vfx] )
		float waitTime = RandomFloatRange( phaseDriverStruct.spark_stutter_battery_ambient_min, phaseDriverStruct.spark_stutter_battery_ambient_max )
		wait waitTime
	}
}

void function PortalSparks_Ambient_Thread()
{
	svGlobal.levelEnt.EndSignal( "PhaseDriver_Active" )
	for( ;; )
	{
		int idx = RandomInt( phaseDriverStruct.sparks_portal_origins.len() )
		int seed = RandomInt( 100 ) % 2
		asset vfx = ( seed == 0 ) ? PHASEDRIVER_VFX_SPARKS_PORTAL_1 : PHASEDRIVER_VFX_SPARKS_PORTAL_2
		entity vfx_ent = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( vfx ), phaseDriverStruct.sparks_portal_origins[idx], phaseDriverStruct.sparks_portal_angles[idx] )
		vfx_ent.kv.kill_for_replay = true
		if( seed == 0 )
		{
			EmitSoundAtPosition( TEAM_UNASSIGNED, phaseDriverStruct.sparks_portal_origins[idx], "Olympus_Mu2_Emit_Teleporter_PortalSparks", vfx_ent )
		}
		thread DestroyFXAfterDelay_Thread( vfx_ent, vfxLifetime[vfx] )
		float waitTime = RandomFloatRange( phaseDriverStruct.spark_stutter_portal_ambient_min, phaseDriverStruct.spark_stutter_portal_ambient_max )
		wait waitTime
	}
}

void function BatterySparks_Active_Thread()
{
	svGlobal.levelEnt.EndSignal( "PhaseDriver_Ambient" )

	for( ;; )
	{
		int idx = RandomInt( phaseDriverStruct.sparks_battery_origins.len() )
		asset vfx = ( RandomInt( 100 ) % 2 ) == 0 ? PHASEDRIVER_VFX_SPARKS_BATTERY_1 : PHASEDRIVER_VFX_SPARKS_BATTERY_2
		entity vfx_ent = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( vfx ), phaseDriverStruct.sparks_battery_origins[idx], phaseDriverStruct.sparks_battery_angles[idx] )
		vfx_ent.kv.kill_for_replay = true
		thread DestroyFXAfterDelay_Thread( vfx_ent, vfxLifetime[vfx] )
		float waitTime = RandomFloatRange( phaseDriverStruct.spark_stutter_battery_active_min, phaseDriverStruct.spark_stutter_battery_active_max )
		wait waitTime
	}
}

void function PortalSparks_Active_Thread()
{
	svGlobal.levelEnt.EndSignal( "PhaseDriver_Ambient" )
	for( ;; )
	{
		int idx = RandomInt( phaseDriverStruct.sparks_portal_origins.len() )
		int seed = RandomInt( 100 ) % 2
		asset vfx = ( seed == 0 ) ? PHASEDRIVER_VFX_SPARKS_PORTAL_1 : PHASEDRIVER_VFX_SPARKS_PORTAL_2
		entity vfx_ent = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( vfx ), phaseDriverStruct.sparks_portal_origins[idx], phaseDriverStruct.sparks_portal_angles[idx] )
		vfx_ent.kv.kill_for_replay = true
		if( seed == 0 )
		{
			EmitSoundAtPosition( TEAM_UNASSIGNED, phaseDriverStruct.sparks_portal_origins[idx], "Olympus_Mu2_Emit_Teleporter_PortalSparks", vfx_ent )
		}
		thread DestroyFXAfterDelay_Thread( vfx_ent, vfxLifetime[vfx] )
		float waitTime = RandomFloatRange( phaseDriverStruct.spark_stutter_portal_active_min, phaseDriverStruct.spark_stutter_portal_active_max )
		wait waitTime
	}
}

void function EnableVFX_Active()
{
	svGlobal.levelEnt.Signal( "PhaseDriver_Active" )

	if( IsValid( phaseDriverStruct.vfx_ambient ) )
	{
		EffectWake( phaseDriverStruct.vfx_active )
	}
	if( IsValid( phaseDriverStruct.vfx_active ) )
	{
		EffectSleep( phaseDriverStruct.vfx_ambient )
	}

	#if DEVELOPER
	phaseDriverStruct.flipVFX = true
#endif
}

void function EnableSparks_Active()
{
	thread BatterySparks_Active_Thread()
	thread PortalSparks_Active_Thread()
}

void function EnableVFX_Ambient()
{
	svGlobal.levelEnt.Signal( "PhaseDriver_Ambient" )

	if( IsValid( phaseDriverStruct.vfx_ambient ) )
	{
		EffectWake( phaseDriverStruct.vfx_ambient )
	}
	if( IsValid( phaseDriverStruct.vfx_active ) )
	{
		EffectSleep( phaseDriverStruct.vfx_active )
	}

	#if DEVELOPER
	phaseDriverStruct.flipVFX = false
#endif
}

void function EnabledSparks_Ambient()
{
	thread BatterySparks_Ambient_Thread()
	thread PortalSparks_Ambient_Thread()
}

#endif // SERVER

#if DEVELOPER && SERVER
void function DEV_ToggleDriverVFX()
{
	phaseDriverStruct.panels[0].Signal( "PhaseDriver_CancelCooldown" )
	if( phaseDriverStruct.flipVFX == false )
	{
		EnableVFX_Active()
		EnableSparks_Active()
	}
	else
	{
		EnableVFX_Ambient()
		EnabledSparks_Ambient()
	}
}

void function DEV_ToggleDriverCooldown()
{
	phaseDriverStruct.bypassCooldown = !phaseDriverStruct.bypassCooldown
	printf( "Bypass Phase Driver Cooldown: " + string( phaseDriverStruct.bypassCooldown ) )
}
#endif // DEV && SERVER

bool function PhaseDriver_IsPhaseDriverEnabled()
{
	return HasEntWithScriptName( PHASEDRIVER_PANEL_SCRIPTNAME )
} 