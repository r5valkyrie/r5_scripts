/*
Spectre Shack
██████╗  ██████╗ ██████╗  ██████╗     ███╗   ██╗██╗ ██████╗ ██╗  ██╗████████╗███╗   ███╗ █████╗ ██████╗ ███████╗
██╔══██╗██╔═══██╗██╔══██╗██╔═══██╗    ████╗  ██║██║██╔════╝ ██║  ██║╚══██╔══╝████╗ ████║██╔══██╗██╔══██╗██╔════╝
██████╔╝██║   ██║██████╔╝██║   ██║    ██╔██╗ ██║██║██║  ███╗███████║   ██║   ██╔████╔██║███████║██████╔╝█████╗
██╔══██╗██║   ██║██╔══██╗██║   ██║    ██║╚██╗██║██║██║   ██║██╔══██║   ██║   ██║╚██╔╝██║██╔══██║██╔══██╗██╔══╝
██║  ██║╚██████╔╝██████╔╝╚██████╔╝    ██║ ╚████║██║╚██████╔╝██║  ██║   ██║   ██║ ╚═╝ ██║██║  ██║██║  ██║███████╗
╚═╝  ╚═╝ ╚═════╝ ╚═════╝  ╚═════╝     ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝
*/

#if SERVER || CLIENT
global const float ARMORY_ENCOUNTER_DURATION = 60.0
const float DOOR_DESTRUCTION_FX_LIFETIME = 10.0
const float DUST_FX_LIFETIME = 5.0
const string ARMORY_MUSIC_TRACK = "Music_SpectreShack_Gameplay"
const float ARMORY_FORCE_OPEN_TIMER = 60.0

global function IsSpectreShackSmartLootLocked
global function GetSpectreShackSmartLootBinForLoot
#endif // SERVER || CLIENT

#if CLIENT
global function SpectreShackControl_V4_ClientInit
#endif

#if SERVER
const string ON_EXIT_AFTER_COMPLETION_SIGNAL_KEYWORD = "OnExitAfterCompletion"
const float ARMORY_ELECTRIC_VFX_FADE_DISTANCE = 5000.0

global function SpectreShack_Init
global function InitSkit_SpectreShack_V4_Server
global function LaunchSkit_SpectreShack_V4
global function AddCallback_SpectreShack_V4_OnSkitStarted
global function AddCallback_SpectreShack_V4_OnSkitEnded
global function ControlPanel_SpectreShack_OnUse_Server
global function IMC_Armory_EntitiesDidLoad
global function SpectreShackLootDefense

#if DEVELOPER
global function DEV_SpectreShack_IsPlayerInSpectreShack
global function DEV_SpectreShack_PauseEncounterTimer
global function DEV_SpectreShack_UnpauseEncounter
global function DEV_SpectreShack_EndEncounter
global function DEV_SpectreShack_ForceSpawnNewWave
global function DEV_SpectreShack_SetWaveSize
global function DEV_SpectreShack_OpenAllHatches
global function DEV_SpectreShack_CloseAllHatches
global function DEV_TestDoorExplodeVfx
global function DEV_TestSpectresFall
global function DEV_TestSpectreSpawn
global function DEV_Armory_DestroyDeployablesOnRamps
#endif // DEV
#endif // SERVER


#if SERVER
const int EXIT_TELEPORTER_HEIGHT = 5000
const int PROXIMITY_TRIGGER_RADIUS = 2200

const string SPECTRE_SHACK_SKIT_MOVER_SCRIPTNAME = "spectre_shack_skit_mover"

bool triggerTeleportFixEnabled

enum eSpectreShackState
{
	Dormant,
	Activated,
	Completed,
	Deactivated,
	Aborted,
}

enum UIeSpectreShackState
{
	Dormant,
	ScanningPlayersStart,
	ShackHackStart,
	ScanningPlayersEnd,
	ShackHackInterference,
	Arming,
	Activated,
	Completed,
	ExitPrompt,
	Deactivated,
	Aborted,
}

struct SpectreSpawnPoint
{
	string attachmentName = ""
	int attachmentIndex = -1
	vector attachmentOrigin = < 0, 0, 0 >
	vector attachmentAngles = < 0, 0, 0 >
	bool shortFall = false
	int spawnGroup = -1
}

array<string> waveStartSounds =
[
	"SpectreShack_Scr_SpectreWave1_Start",
	"SpectreShack_Scr_SpectreWave2_Start",
	"SpectreShack_Scr_SpectreWave3_Start",
	"SpectreShack_Scr_SpectreWave4_Start",
	"SpectreShack_Scr_SpectreWave5_Start",
	"SpectreShack_Scr_SpectreWave6_Start",
	"SpectreShack_Scr_SpectreWave7_8_Start",
	"SpectreShack_Scr_SpectreWave7_8_Start",
]

array<string> waveEndSounds =
[
	"SpectreShack_Scr_SpectreWave1_End",
	"SpectreShack_Scr_SpectreWave2_End",
	"SpectreShack_Scr_SpectreWave3_End",
	"SpectreShack_Scr_SpectreWave4_End",
	"SpectreShack_Scr_SpectreWave5_End",
	"SpectreShack_Scr_SpectreWave6_End",
	"SpectreShack_Scr_SpectreWave7_8_End",
	"SpectreShack_Scr_SpectreWave7_8_End",
]

array<string> armoryOpeningWarningDialogues =
[
	"diag_ap_aiNotify_armoryOpening_01_01",
	"diag_ap_aiNotify_armoryOpening_02_01",
	"diag_ap_aiNotify_armoryOpening_03_01",
	"diag_ap_aiNotify_armoryOpening_04_01",
]

#endif // SERVER

struct MyVars
{
#if SERVER
	#if DEVELOPER
		//Debugging Vars
		float devTimeRemainingOnEncounter // this is -1 if the encounter is running normally
	#endif //DEV

	int skitID

		bool forceShutdown = false
		entity controlPanel
		int spectreShackState
		array< entity > spawnGroups // in practice this seems to be used only by spawn group 0
		array< entity > spawnGroupOne
		array< entity > spawnGroupTwo
		int kills
		array<entity> activeSpectres
		int currentWave
		int waveSpawnCount
		float waveTimeBuffer
		float encounterDuration
		bool spawnWave
		float encounterEndTime
		array< void functionref() > callbacks_OnSkitStarted
		array< void functionref() > callbacks_OnSkitEnded
		array< entity > ruiOrigins
		entity entryTeleportEntryPoint
		entity teleporter
		entity skydiveLauncherSpawnPoint
		entity proximityTrigger
		array< entity > playersInsideProximity
		bool isSealed
		array< vector > entryTeleportExitPositions
		array< vector > entryTeleportExitAngles
		array< entity > ruiWaypoints
		entity interiorTriggerVolume
		array< entity > playersInsideShack
		float lastTimePlayerInteriorListUpdated = 0
		float lastTimePlayerProximityListUpdated = 0
		bool fullTeamIsInside
		bool fullTeamHasEscaped
		array< entity > lootbinLocations
		array< entity > lootbinProxies
		array< entity > lootbinMovers
		int teamIndex
		entity skydiveLauncher
		entity skydiveLauncherMover
		bool skydiveLauncherThreadCalled = false
		float kickoffStagger
		entity minimapEnt
		entity dustVfxSpawnPoint
		entity entryHatch_Rig
		array< entity > roof_Rig
		entity ceiling_Rig_Left
		entity ceiling_Rig_Right
		entity topPrizeSpawnPoint
		entity sfx_powerUp
		entity sfx_powerDown
		entity sfx_alarm
		array< SpectreSpawnPoint > spectreSpawnPoints
		array< entity > sfx_ceilingEmitPoints
		float encounterMusicStartTime
		entity scanVfxInfoTarget
		float scanVfx_LastTriggerTime
		int currentRuiState
		int cumulativeKills
		int cumulativeDamageToSpectres
		int cumulativeDamageToPlayers
		array< string > lootAwarded
		array< entity > playersTeleporting
		float forceOpenTime
		vector roofElectricOrigin
		vector roofElectricAngles
		bool roofRepelEnabled
		array< entity > roofElectricTriggerOrigins
		array< entity > roofElectricTriggerOrigins_Center
		array< entity > roofElectricTriggers_Sides
		array< entity > roofElectricTriggers_Center
		entity roofElectricVFX_Center
		float electricBoopInterval
		table< entity, float > playerLastBoopTime

	#if DEVELOPER
		bool ceilingIsOpen = false
	#endif // DEV
#endif // SERVER
}

#if SERVER
array< string > spectreAttachments_left =
[
	"ATT_L_HANGER_A_02",
	"ATT_L_HANGER_A_03",
	"ATT_L_HANGER_A_04",
	"ATT_L_HANGER_A_05",
	"ATT_L_HANGER_A_06",
	"ATT_L_HANGER_A_07",

	"ATT_L_HANGER_B_01",
	"ATT_L_HANGER_B_02",
	"ATT_L_HANGER_B_03",
	"ATT_L_HANGER_B_04",
	"ATT_L_HANGER_B_05",
	"ATT_L_HANGER_B_06",
	"ATT_L_HANGER_B_07",
	"ATT_L_HANGER_B_08",

	"ATT_L_HANGER_C_02",
	"ATT_L_HANGER_C_03",
	"ATT_L_HANGER_C_04",
	"ATT_L_HANGER_C_05",
	"ATT_L_HANGER_C_06",
	"ATT_L_HANGER_C_07",

	"ATT_L_HANGER_D_01",
	"ATT_L_HANGER_D_02",
	"ATT_L_HANGER_D_03",
	"ATT_L_HANGER_D_06",
	"ATT_L_HANGER_D_07",
	"ATT_L_HANGER_D_08"
]

array< string > spectreAttachments_right =
[
	"ATT_R_HANGER_A_02",
	"ATT_R_HANGER_A_03",
	"ATT_R_HANGER_A_04",
	"ATT_R_HANGER_A_05",
	"ATT_R_HANGER_A_06",
	"ATT_R_HANGER_A_07",

	"ATT_R_HANGER_B_01",
	"ATT_R_HANGER_B_02",
	"ATT_R_HANGER_B_03",
	"ATT_R_HANGER_B_04",
	"ATT_R_HANGER_B_05",
	"ATT_R_HANGER_B_06",
	"ATT_R_HANGER_B_07",
	"ATT_R_HANGER_B_08",

	"ATT_R_HANGER_C_02",
	"ATT_R_HANGER_C_03",
	"ATT_R_HANGER_C_04",
	"ATT_R_HANGER_C_05",
	"ATT_R_HANGER_C_06",
	"ATT_R_HANGER_C_07",

	"ATT_R_HANGER_D_01",
	"ATT_R_HANGER_D_02",
	"ATT_R_HANGER_D_03",
	"ATT_R_HANGER_D_06",
	"ATT_R_HANGER_D_07",
	"ATT_R_HANGER_D_08",
]

array< bool > spectreMap_shortFall_left =
[
	false,	//"ATT_L_HANGER_A_02",
	false,	//"ATT_L_HANGER_A_03",
	false,	//"ATT_L_HANGER_A_04",
	false,	//"ATT_L_HANGER_A_05",
	false,	//"ATT_L_HANGER_A_06",
	false,	//"ATT_L_HANGER_A_07",
			//
	false, 	//"ATT_L_HANGER_B_01",
	false, 	//"ATT_L_HANGER_B_02",
	true,	//"ATT_L_HANGER_B_03",
	false, 	//"ATT_L_HANGER_B_04",
	false, 	//"ATT_L_HANGER_B_05",
	true,	//"ATT_L_HANGER_B_06",
	false, 	//"ATT_L_HANGER_B_07",
	false, 	//"ATT_L_HANGER_B_08",
			//
	false, 	//"ATT_L_HANGER_C_02",
	false, 	//"ATT_L_HANGER_C_03",
	false, 	//"ATT_L_HANGER_C_04",
	false,	//"ATT_L_HANGER_C_05",
	false, 	//"ATT_L_HANGER_C_06",
	false, 	//"ATT_L_HANGER_C_07",
			//
	false, 	//"ATT_L_HANGER_D_01",
	false, 	//"ATT_L_HANGER_D_02",
	false, 	//"ATT_L_HANGER_D_03",
	false, 	//"ATT_L_HANGER_D_06",
	false, 	//"ATT_L_HANGER_D_07",
	false 	//"ATT_L_HANGER_D_08"
]

array< bool > spectreMap_shortFall_right =
[
	false, 	//"ATT_R_HANGER_A_02",
	false, 	//"ATT_R_HANGER_A_03",
	false, 	//"ATT_R_HANGER_A_04",
	false, 	//"ATT_R_HANGER_A_05",
	false, 	//"ATT_R_HANGER_A_06",
	false, 	//"ATT_R_HANGER_A_07",
		 	//
	false, 	//"ATT_R_HANGER_B_01",
	false, 	//"ATT_R_HANGER_B_02",
	true, 	//"ATT_R_HANGER_B_03",
	false, 	//"ATT_R_HANGER_B_04",
	false, 	//"ATT_R_HANGER_B_05",
	true, 	//"ATT_R_HANGER_B_06",
	false, 	//"ATT_R_HANGER_B_07",
	false, 	//"ATT_R_HANGER_B_08",
		 	//
	false, 	//"ATT_R_HANGER_C_02",
	false, 	//"ATT_R_HANGER_C_03",
	false, 	//"ATT_R_HANGER_C_04",
	false, 	//"ATT_R_HANGER_C_05",
	false, 	//"ATT_R_HANGER_C_06",
	false, 	//"ATT_R_HANGER_C_07",
		 	//
	false, 	//"ATT_R_HANGER_D_01",
	false, 	//"ATT_R_HANGER_D_02",
	false, 	//"ATT_R_HANGER_D_03",
	false, 	//"ATT_R_HANGER_D_06",
	false, 	//"ATT_R_HANGER_D_07",
	false 	//"ATT_R_HANGER_D_08",
]

array< int > spectreMap_spawnGroup_left =
[
	1,	//"ATT_L_HANGER_A_02",
	1,	//"ATT_L_HANGER_A_03",
	1,	//"ATT_L_HANGER_A_04",
	1,	//"ATT_L_HANGER_A_05",
	1,	//"ATT_L_HANGER_A_06",
	1,	//"ATT_L_HANGER_A_07",
	//
	1, 	//"ATT_L_HANGER_B_01",
	1, 	//"ATT_L_HANGER_B_02",
	2,	//"ATT_L_HANGER_B_03",
	1, 	//"ATT_L_HANGER_B_04",
	1, 	//"ATT_L_HANGER_B_05",
	2,	//"ATT_L_HANGER_B_06",
	1, 	//"ATT_L_HANGER_B_07",
	1, 	//"ATT_L_HANGER_B_08",
	//
	1, 	//"ATT_L_HANGER_C_02",
	1, 	//"ATT_L_HANGER_C_03",
	1, 	//"ATT_L_HANGER_C_04",
	1,	//"ATT_L_HANGER_C_05",
	1, 	//"ATT_L_HANGER_C_06",
	1, 	//"ATT_L_HANGER_C_07",
	//
	1, 	//"ATT_L_HANGER_D_01",
	1, 	//"ATT_L_HANGER_D_02",
	1, 	//"ATT_L_HANGER_D_03",
	1, 	//"ATT_L_HANGER_D_06",
	1, 	//"ATT_L_HANGER_D_07",
	1 	//"ATT_L_HANGER_D_08",
]
array< int > spectreMap_spawnGroup_right =
[
	1, 	//"ATT_R_HANGER_A_02",
	1, 	//"ATT_R_HANGER_A_03",
	1, 	//"ATT_R_HANGER_A_04",
	1, 	//"ATT_R_HANGER_A_05",
	1, 	//"ATT_R_HANGER_A_06",
	1, 	//"ATT_R_HANGER_A_07",
	//
	1, 	//"ATT_R_HANGER_B_01",
	1, 	//"ATT_R_HANGER_B_02",
	2, 	//"ATT_R_HANGER_B_03",
	1, 	//"ATT_R_HANGER_B_04",
	1, 	//"ATT_R_HANGER_B_05",
	2, 	//"ATT_R_HANGER_B_06",
	1, 	//"ATT_R_HANGER_B_07",
	1, 	//"ATT_R_HANGER_B_08",
	//
	1, 	//"ATT_R_HANGER_C_02",
	1, 	//"ATT_R_HANGER_C_03",
	1, 	//"ATT_R_HANGER_C_04",
	1, 	//"ATT_R_HANGER_C_05",
	1, 	//"ATT_R_HANGER_C_06",
	1, 	//"ATT_R_HANGER_C_07",
	//
	1, 	//"ATT_R_HANGER_D_01",
	1, 	//"ATT_R_HANGER_D_02",
	1, 	//"ATT_R_HANGER_D_03",
	1, 	//"ATT_R_HANGER_D_06",
	1, 	//"ATT_R_HANGER_D_07",
	1 	//"ATT_R_HANGER_D_08",
]
#endif //SERVER

table<entity, MyVars> sh_cpToVars

#if SERVER
table<SkitInstance, MyVars> s_siToVars
table<entity, SkitInstance> teleportTriggerToSkitLookup
table<entity, SkitInstance> proximityTriggerToSkitLookup
table<entity, SkitInstance> interiorTriggerToSkitLookup
table<entity, SkitInstance> playerToSkitLookup
array< SkitInstance > allSkits
float forceOpenTimer
#endif // SERVER

#if SERVER
array<entity> function GetPlayersInsideShack( MyVars vars )
{
	if ( vars.lastTimePlayerInteriorListUpdated != Time() )
	{
		vars.lastTimePlayerInteriorListUpdated = Time()
		for(int i = vars.playersInsideShack.len() - 1; i >= 0; i--)
		{
			entity player = vars.playersInsideShack[i]
			if ( (!IsValid(player) && !IsInvalidButMemberVarsStillValid(player) ) || ( IsValid(player) && !player.IsPlayer() ) )
			{
				#if DEVELOPER
					ArmoryPrint( vars, "We're in trouble, there's an invaid entity in the shack!" )
					foreach( entity ent in vars.playersInsideShack )
					{
						ArmoryPrint( vars, "Ent in list: " + ent )
					}

					foreach( entity ent in vars.interiorTriggerVolume.GetTouchingEntities() )
					{
						ArmoryPrint( vars, "ent inside trigger: " + ent )
					}
				#endif
				vars.playersInsideShack.fastremove(i)
			}
		}
	}
	return vars.playersInsideShack
}

array<entity> function GetPlayersInsideShackProximity( MyVars vars )
{
	if ( vars.lastTimePlayerProximityListUpdated != Time() )
	{
		vars.lastTimePlayerProximityListUpdated = Time()
		for(int i = vars.playersInsideProximity.len() - 1; i >= 0; i--)
		{
			entity player = vars.playersInsideProximity[i]
			if ( (!IsValid(player) && !IsInvalidButMemberVarsStillValid(player) ) || ( IsValid(player) && !player.IsPlayer() ) )
			{
				#if DEVELOPER
					ArmoryPrint( vars, "We're in trouble, there's an invaid entity in proximity of the shack!" )
					foreach( entity ent in vars.playersInsideProximity )
					{
						ArmoryPrint( vars, "Ent in proximity list: " + ent )
					}
					foreach( entity ent in vars.proximityTrigger.GetTouchingEntities() )
					{
						ArmoryPrint( vars, "ent inside proximity trigger: " + ent )
					}
				#endif
				vars.playersInsideProximity.fastremove(i)
			}
		}
	}
	return vars.playersInsideProximity
}
#endif // SERVER

#if SERVER
void function SpectreShack_Init()
{
	AddCallback_OnSurvivalDeathFieldStageChanged( SpectreShack_OnSurvivalDeathFieldStageChanged )
	forceOpenTimer = GetPlaylistVarFloat( GetCurrentPlaylistName(), "armory_force_open_timer", ARMORY_FORCE_OPEN_TIMER )
	triggerTeleportFixEnabled = GetCurrentPlaylistVarBool( "armory_trigger_teleport_fix_enabled", true )
	PrecacheScriptString( "ArmorySkydiveLauncherMover" )
}

SkitInstance ornull function InitThisSkit_Server( entity rootEnt, int skitID )
{
	if( !IsValid( rootEnt ) )
	{
		return null
	}

	SkitInstance si = Skit_AllocInstance( Runtime, Cleanup )
	allSkits.append( si )

	MyVars vars
	sh_cpToVars[rootEnt] <- vars
	s_siToVars[si] <- vars

	vars.skitID = skitID
	vars.spectreShackState = eSpectreShackState.Dormant
	vars.controlPanel = rootEnt
	vars.currentWave = 1
	vars.waveSpawnCount = 4 // formerly sont int SPAWN_COUNT
	vars.encounterDuration = ARMORY_ENCOUNTER_DURATION
	vars.waveTimeBuffer = 3.0 // formerly const float WAVE_TIME_BUFFER
	vars.spawnWave = false
	vars.kickoffStagger = 0.0
	vars.isSealed = true
	vars.encounterMusicStartTime = -1.0
	vars.cumulativeKills = 0
	vars.cumulativeDamageToSpectres = 0
	vars.cumulativeDamageToPlayers = 0
	vars.currentRuiState = UIeSpectreShackState.Dormant
	vars.scanVfx_LastTriggerTime = 0.0
	vars.roofRepelEnabled = GetPlaylistVarBool( GetCurrentPlaylistName(), "armory_roof_repel_enabled", false )
	vars.electricBoopInterval = GetPlaylistVarFloat( GetCurrentPlaylistName(), "armory_roof_repel_cooldown", 0.5 )

	// minimap icon setup pt.1
	vars.minimapEnt = CreatePropScript( $"mdl/dev/empty_model.rmdl", rootEnt.GetOrigin(), <0,0,0>, SOLID_NONE )
	SetTargetName( vars.minimapEnt, "SpectreShack" )
	vars.minimapEnt.Minimap_SetCustomState( eMinimapObject_prop_script.SPECTRE_SHACK )
	vars.minimapEnt.Minimap_SetAlignUpright( true )
	vars.minimapEnt.Minimap_SetClampToEdge( false )
	vars.minimapEnt.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
	vars.minimapEnt.DisableHibernation()

	RegisterSignal( ON_EXIT_AFTER_COMPLETION_SIGNAL_KEYWORD )

	#if DEVELOPER
		vars.devTimeRemainingOnEncounter = -1
	#endif

	return si
}

void function IMC_Armory_EntitiesDidLoad()
{
	foreach( SkitInstance si in allSkits )
	{
		InitArmoryVariables_Server( si )
	}
}

void function InitArmoryVariables_Server( SkitInstance si )
{
	MyVars vars = s_siToVars[ si ]

	array<entity> spawnGroups
	array<entity> routerEnts = vars.controlPanel.GetLinkEntArray()

	foreach( entity ent in routerEnts )
	{
		string entName = ent.GetScriptName()

		// spawn groups
		if( entName == "spectre_spawn" )
		{
			spawnGroups = ent.GetLinkEntArray()
			spawnGroups.sort( int function( entity groupA, entity groupB ) {
				return SortStringAlphabetize( groupA.GetScriptName(), groupB.GetScriptName() )
			} )

			if( spawnGroups.len() < 1 )
			{
				return null
			}
			vars.spawnGroups = spawnGroups

			foreach( entity e in vars.spawnGroups[0].GetLinkEntArray() )
			{
				//create the standing spectres
				SpectreShackSpawnPoint_Init( e, true )
			}

			ent.Destroy()
		}

		// rui origins
		else if( entName == "shack_rui_group" )
		{
			foreach( e in ent.GetLinkEntArray() )
			{
				// force the front screen to index 0
				if( e.GetScriptName().find( "_front" ) > -1 )
				{
					vars.ruiOrigins.insert( 0, e )
				}
				else
				{
					vars.ruiOrigins.append( e )
				}
			}
			ent.Destroy()

			// setup one common waypoint
			if( vars.ruiOrigins.len() > 0 )
			{
				entity wp = SpectreShack_CreateRuiWaypoint( vars.ruiOrigins[0].GetOrigin(), vars.ruiOrigins[0].GetAngles() )
				vars.ruiWaypoints.append( wp )
				wp.SetWaypointInt( CONTROLSCREEN_MASTER_STATE_INDEX, vars.currentRuiState )

				wp.SetWaypointEntity( ARMORY_SCREEN_MAIN_ENT, vars.ruiOrigins[0] )
				wp.SetWaypointEntity( ARMORY_SCREEN_SIDE1_ENT, vars.ruiOrigins[1] )
				wp.SetWaypointEntity( ARMORY_SCREEN_SIDE2_ENT, vars.ruiOrigins[2] )
			}
		}

		else if( entName == "shack_teleport_entrypoint" )
		{
			vars.entryTeleportEntryPoint = ent
		}

		else if( entName == "shack_teleport_interior" )
		{
			array< entity > candidates = ent.GetLinkEntArray()
			for( int i = 0; i < candidates.len(); i++ )
			{
				vars.entryTeleportExitPositions.append( candidates[i].GetOrigin() )
				vars.entryTeleportExitAngles.append( candidates[i].GetAngles() )
				candidates[i].Destroy()
			}
			ent.Destroy()
		}
		else if( entName == "exit_skydive_launcher_spawnpoint" )
		{
			vars.skydiveLauncherSpawnPoint = ent
		}

		else if( entName == "shack_interior_triggerVol" )
		{
			vars.interiorTriggerVolume = ent
			//0x01800 = TF_ALLOW_TEAM_MILITIA | TF_ALLOW_TEAM_IMC
			//vars.interiorTriggerVolume.AddTriggerFilter( 0x01800 )

			interiorTriggerToSkitLookup[vars.interiorTriggerVolume] <- si

			vars.interiorTriggerVolume.SetEnterCallback( SpectreShack_OnInteriorTriggerEnter )
			vars.interiorTriggerVolume.SetLeaveCallback( SpectreShack_OnInteriorTriggerLeave )

			ArmoryPrint( vars, "set interior trigger callback" )
		}

		else if( entName == "shack_lootbin_movers" )
		{
			foreach( entity e in ent.GetLinkEntArray() )
			{
				vars.lootbinMovers.append( e )
			}
			ent.Destroy()

			// sort by name
			vars.lootbinMovers.sort( int function( entity groupA, entity groupB ) {
				return SortStringAlphabetize( groupA.GetScriptName(), groupB.GetScriptName() )
			} )

			foreach( entity e in vars.lootbinMovers )
			{
				entity spawnPoint = e.GetLinkEnt()
				if( IsValid( spawnPoint ) )
				{
					vars.lootbinLocations.append( spawnPoint )

					entity binProxy = CreatePropDynamicLightweight ( LOOT_BIN_MODEL, spawnPoint.GetOrigin(), spawnPoint.GetAngles(), SOLID_VPHYSICS )
					if( IsValid( binProxy ) )
					{
						binProxy.SetSkin( binProxy.GetSkinIndexByName( "SmartLoot" ) )
						vars.lootbinProxies.append( binProxy )
					}
				}
			}
		}

		//seems to be an unused ent
		else if( entName == "shack_lootbin_locations" )
		{
			ent.Destroy()
		}
		//These for to open the shack before it was changed to use animations
		else if( entName == "shack_doors_exit" )
		{
			array< entity > candidates = ent.GetLinkEntArray()
			for( int i = 0; i < candidates.len(); i++ )
			{
				candidates[i].Destroy()
			}
			ent.Destroy()
		}

		else if( entName == "ss_door_vfx" )
		{
			vars.dustVfxSpawnPoint = ent
		}

		else if( entName == "ss_vfx_smartscanner" )
		{
			vars.scanVfxInfoTarget = ent
		}

		else if( entName == "armory_entry_hatch_rig" )
		{
			vars.entryHatch_Rig = ent
		}

		else if( entName == "armory_roof_rig" )
		{
			vars.roof_Rig.append( ent )
		}

		else if( entName == "armory_ceiling_rig_left" )
		{
			vars.ceiling_Rig_Left = ent

			for( int i = 0; i < spectreAttachments_left.len(); i++ )
			{
				SpectreSpawnPoint sp
				sp.attachmentName = spectreAttachments_left[i]
				sp.attachmentIndex = vars.ceiling_Rig_Left.LookupAttachment( sp.attachmentName )
				if( sp.attachmentIndex <= 0 )
				{
					#if DEVELOPER
						ArmoryPrint( vars, "could not find a valid attachment index for " + sp.attachmentName )
					#endif
					continue
				}
				sp.attachmentOrigin = vars.ceiling_Rig_Left.GetAttachmentOrigin( sp.attachmentIndex )
				vector correctionAngles = sp.attachmentName.find( "ATT_R_" ) > -1 ? < 0, 90, 0 > : < 0, -90, 0 >
				sp.attachmentAngles = ( vars.ceiling_Rig_Left.GetAngles() + correctionAngles )

				sp.shortFall = spectreMap_shortFall_left[i]
				sp.spawnGroup = spectreMap_spawnGroup_left[i]

				vars.spectreSpawnPoints.append( sp )
			}
		}

		else if( entName == "armory_ceiling_rig_right" )
		{
			vars.ceiling_Rig_Right = ent

			for( int i = 0; i < spectreAttachments_right.len(); i++ )
			{
				SpectreSpawnPoint sp
				sp.attachmentName = spectreAttachments_right[i]
				sp.attachmentIndex = vars.ceiling_Rig_Right.LookupAttachment( sp.attachmentName )
				if( sp.attachmentIndex <= 0 )
				{
					#if DEVELOPER
						ArmoryPrint( vars, "could not find a valid attachment index for " + sp.attachmentName )
					#endif
					continue
				}
				sp.attachmentOrigin = vars.ceiling_Rig_Right.GetAttachmentOrigin( sp.attachmentIndex )
				vector correctionAngles = sp.attachmentName.find( "ATT_R_" ) > -1 ? < 0, 90, 0 > : < 0, -90, 0 >
				sp.attachmentAngles = ( vars.ceiling_Rig_Right.GetAngles() + correctionAngles )

				sp.shortFall = spectreMap_shortFall_right[i]
				sp.spawnGroup = spectreMap_spawnGroup_right[i]

				vars.spectreSpawnPoints.append( sp )
			}
		}

		else if( entName == "ss_top_prize_spawnpoint" )
		{
			vars.topPrizeSpawnPoint = ent
		}

		else if( entName == "SpectreShack_Scr_Room_PowerUp" )
		{
			vars.sfx_powerUp = ent
		}

		else if( entName == "SpectreShack_Scr_EmergencyShutdown_PowerDown" )
		{
			vars.sfx_powerDown = ent
		}

		else if( entName == "SpectreShack_Scr_Breach_Alarm" )
		{
			vars.sfx_alarm = ent
		}

		else if( entName == "armory_ceiling_rig_sfx_origin" )
		{
			vars.sfx_ceilingEmitPoints.append( ent )
		}

		else if( entName == "armory_roof_trigger_origin" )
		{
			if ( vars.roofRepelEnabled )
			{
				vars.roofElectricTriggerOrigins.append( ent )
			}
			else
			{
				ent.Destroy()
			}
		}

		else if( entName == "armory_roof_trigger_origin_center" )
		{
			if ( vars.roofRepelEnabled )
			{
				vars.roofElectricTriggerOrigins_Center.append( ent )
			}
			else
			{
				ent.Destroy()
			}
		}

		else if( entName == "armory_roof_electric_origin" )
		{
			if ( vars.roofRepelEnabled )
			{
				vars.roofElectricOrigin = ent.GetOrigin()
				vars.roofElectricAngles = ent.GetAngles()
			}
			ent.Destroy()
		}

		else
		{
			printf( "ARMORY | WARNING | destroying unknown ent - " + ent )
			ent.Destroy()
		}
	}

	if( !IsValid( vars.interiorTriggerVolume ))
	{
		printf( "ARMORY | WARNING | Interior Trigger Volume was not found in entity links" )
	}

	if( IsValid( vars.entryTeleportEntryPoint ) )
	{
		// create a global wake-up skit trigger
		vars.proximityTrigger = CreateEntity( "trigger_cylinder" )
		proximityTriggerToSkitLookup[vars.proximityTrigger] <- si
		vars.proximityTrigger.SetCylinderRadius( PROXIMITY_TRIGGER_RADIUS )
		vars.proximityTrigger.SetAboveHeight( 1800.0 )
		vars.proximityTrigger.SetBelowHeight( 0.0 )
		vars.proximityTrigger.SetOrigin( vars.entryTeleportEntryPoint.GetOrigin() - < 0, 0, 600 > )
		vars.proximityTrigger.SetAngles( <0, 0, 0> )

		vars.proximityTrigger.SetEnterCallback( SpectreShack_OnProximityTriggerEnter )
		vars.proximityTrigger.SetLeaveCallback( SpectreShack_OnProximityTriggerLeave )

		vars.proximityTrigger.kv.triggerFilterNpc = "none"
		vars.proximityTrigger.kv.triggerFilterPlayer = "all"
		vars.proximityTrigger.kv.triggerFilterNonCharacter = 0

		DispatchSpawn( vars.proximityTrigger )
		vars.proximityTrigger.SearchForNewTouchingEntity()
	}

	thread SpaceOutInitialSpectreSpawns_Thread( vars )
}

void function SpaceOutInitialSpectreSpawns_Thread( MyVars vars )
{
	wait 0.25
	foreach( SpectreSpawnPoint spawnPoint in vars.spectreSpawnPoints )
	{
		entity attachParent = ( spawnPoint.attachmentName.find( "ATT_L_" ) > -1 ) ? vars.ceiling_Rig_Left : vars.ceiling_Rig_Right
		entity spectreProp = SpectreSpawnPoint_Rig_Proxy_Init( spawnPoint, attachParent )
		switch( spawnPoint.spawnGroup )
		{
			case 1:
				vars.spawnGroupOne.append( spectreProp )
				break
			case 2:
				vars.spawnGroupTwo.append( spectreProp )
				break
		}

		WaitFrame()
	}
}

void function SpectreShack_OnInteriorTriggerEnter( entity trigger, entity player )
{
	if ( triggerTeleportFixEnabled )
	{

		// Threading this off and doing two waitframes is gross, but required because of R5DEV-363475
		thread function () : ( trigger, player )
		{
			WaitFrame()
			WaitFrame()

			SpectreShack_OnInteriorTriggerEnter_Internal ( trigger, player )
		}()
	}
	else
	{
		SpectreShack_OnInteriorTriggerEnter_Internal ( trigger, player )
	}
}

void function SpectreShack_OnInteriorTriggerEnter_Internal ( entity trigger, entity player )
{
	if ( !IsValid(player) )
	{
		ArmoryPrint( null, "TRIGGER ENTER | entity invalid" )
		return
	}

	if ( !player.IsPlayer() )
	{
		ArmoryPrint( null, "TRIGGER ENTER | entity is not a player" )
		return
	}

	SkitInstance si = interiorTriggerToSkitLookup[trigger]
	MyVars vars = s_siToVars[ si ]
	if( vars.forceShutdown )
	{
		ArmoryPrint( vars, "TRIGGER ENTER | force shutdown!!!", false )
		return
	}

	if ( triggerTeleportFixEnabled )
	{
		if ( GetPlayersInsideShack( vars ).contains( player ) )
		{
			ArmoryPrint( vars, "TRIGGER ENTER | ignoring enter, player already inside shack", false )
			return
		}
		AddEntityDestroyedCallback ( player, SpectreShack_OnPlayerInsideInteriorDestroyed )
	}

	AddEntityCallback_OnDamaged( player, OnPlayerDamaged_Armory )
	playerToSkitLookup[player] <- si

	if( GetPlayersInsideShack(vars).len() == 0 &&
			vars.spectreShackState == eSpectreShackState.Dormant &&
			vars.scanVfx_LastTriggerTime + 3.0 < Time() )
	{
		if( IsValid( vars.scanVfxInfoTarget ))
		{
			vars.scanVfx_LastTriggerTime = Time()
			thread SmartScannerVFX_Thread( si )
		}
	}

	vars.playersInsideShack.append( player )
	if( vars.spectreShackState == eSpectreShackState.Activated )
	{
		float seekTime = Time() - vars.encounterMusicStartTime
		#if DEVELOPER
			ArmoryPrint( vars, "music seekTime: " + string( seekTime ))
		#endif
		if ( seekTime > 0 && seekTime < ARMORY_ENCOUNTER_DURATION )
		{
			EmitSoundOnEntityOnlyToPlayerWithSeek( player, player, ARMORY_MUSIC_TRACK, seekTime )
		}
	}

	ArmoryPrint( vars, "TRIGGER ENTER | a player entered the shack: " + player.GetPlayerName(), false )
	ArmoryPrint( vars, "TRIGGER ENTER | num players now in the shack: " + string( vars.playersInsideShack.len() ), false )

	if( vars.spectreShackState == eSpectreShackState.Activated && vars.fullTeamIsInside == false)
	{
		vars.fullTeamIsInside = TestTeamIsInsideTrigger( player.GetTeam(),  GetPlayersInsideShack (vars) )
	}
}

void function SpectreShack_OnInteriorTriggerLeave( entity trigger, entity player )
{
	if (triggerTeleportFixEnabled)
	{
		// Threading this off and doing two waitframes is gross, but required because of R5DEV-363475
		thread function () : ( trigger, player )
		{
			WaitFrame()
			WaitFrame()

			Spectreshack_OnInteriorTriggerLeave_Internal ( trigger, player )
		}()
	}
	else
	{
		Spectreshack_OnInteriorTriggerLeave_Internal ( trigger, player )
	}
}

void function Spectreshack_OnInteriorTriggerLeave_Internal ( entity trigger, entity player )
{
	if ( triggerTeleportFixEnabled )
	{
		if ( !IsValid(player) && !IsInvalidButMemberVarsStillValid(player) )
		{
			ArmoryPrint( null, "TRIGGER LEAVE | called with invalid player" )
			return
		}

		trigger.SearchForNewTouchingEntity()
		if ( trigger.GetTouchingEntities().contains(player) )
		{
			ArmoryPrint( null, "TRIGGER LEAVE | called with player still inside trigger bounds (likely due to teleport)" )
			return
		}
	}
	else
	{
		if ( !IsValid(player) )
		{
			ArmoryPrint( null, "TRIGGER LEAVE | called with invalid player" )
			return
		}
	}

	if ( !player.IsPlayer() )
	{
		ArmoryPrint( null, "TRIGGER LEAVE | called with non-player entity" )
		return
	}


	if( (player in playerToSkitLookup) == false )
	{
		ArmoryPrint( null, "TRIGGER LEAVE | called with player not in skit" )
		return
	}

	SkitInstance si = playerToSkitLookup[player]
	MyVars vars = s_siToVars[ si ]
	delete playerToSkitLookup[player]

	vars.playersInsideShack.fastremovebyvalue( player )
	RemoveEntityCallback_OnDamaged( player, OnPlayerDamaged_Armory )
	if ( triggerTeleportFixEnabled )
		RemoveEntityDestroyedCallback ( player, SpectreShack_OnPlayerInsideInteriorDestroyed )

	ArmoryPrint( vars, "TRIGGER LEAVE | a player left the shack: " + player.GetPlayerName(), false )
	ArmoryPrint( vars, "TRIGGER LEAVE | num players still in the shack: " + string( vars.playersInsideShack.len() ), false )
	#if DEVELOPER
		foreach ( entity p in vars.playersInsideShack )
		{
			ArmoryPrint( vars, "TRIGGER LEAVE | " + p.GetPlayerName() + " is in the shack")
		}
	#endif

	if( ( vars.spectreShackState == eSpectreShackState.Deactivated ||
	vars.spectreShackState == eSpectreShackState.Aborted ) &&
			IsPlayerOnTeamInArmory( player, si ) )
	{
		// set the flag to remove the skydive launcher
		vars.fullTeamHasEscaped = TestEntireTeamIsOutsideTrigger( player, si )

		if ( GetPlayersInsideShack(vars).len() == 0 )
		{
			ArmoryPrint( vars, "TRIGGER LEAVE | All players have left the shack and the encounter is over, disabling the triggers", false )
			vars.proximityTrigger.Disable()
			vars.interiorTriggerVolume.Disable()

			if ( GetCurrentPlaylistVarBool( "armory_loot_entity_cleanup", true ) )
			{
				if ( IsValid( vars.sfx_alarm ) )
				{
					vars.sfx_alarm.Destroy()
				}
				foreach( entity ent in vars.sfx_ceilingEmitPoints )
				{
					if ( IsValid( ent ) )
					{
						ent.Destroy()
					}
				}
				if ( IsValid( vars.sfx_powerDown ) )
				{
					vars.sfx_powerDown.Destroy()
				}
				if ( IsValid( vars.sfx_powerUp ) )
				{
					vars.sfx_powerUp.Destroy()
				}
				if ( IsValid( vars.scanVfxInfoTarget ) )
				{
					vars.scanVfxInfoTarget.Destroy()
				}
				if ( IsValid( vars.topPrizeSpawnPoint ) )
				{
					vars.topPrizeSpawnPoint.Destroy()
				}
				if ( IsValid( vars.entryTeleportEntryPoint ) )
				{
					vars.entryTeleportEntryPoint.Destroy()
				}
				foreach( entity ent in vars.lootbinLocations )
				{
					if ( IsValid( ent ) )
					{
						ent.Destroy()
					}
				}
				foreach( entity ent in vars.spawnGroups)
				{
					if ( IsValid( ent ) )
					{
						ent.Destroy()
					}
				}

				SpectreShack_RemoveRuiWaypoints( vars )
			}

		}
	}
	else if ( vars.spectreShackState == eSpectreShackState.Activated )
	{
		FadeOutSoundOnEntity( player, ARMORY_MUSIC_TRACK, 6.0 )

		if( GetPlayersInsideShack(vars).len() < 1 || ( vars.playersInsideShack.len() == 1 && vars.playersInsideShack[0] == player ) )
		{
			AbortEncounter( si )
			OpenLoadingHatch( si )
			OpenRoof( si )
			//PIN_Interact_Armory_Complete( player, "spectre_shack_complete", "eliminated", CreateArmoryInts( vars ), [], vars.controlPanel.GetInstanceName(), player.GetOrigin() )
		}

		if ( player.GetTeam() == vars.teamIndex )
		{
			ArmoryPrint( vars, "OWNERSHIP TRANSITION - Shack Encounter owner has died. Checking to see if team index needs to change.")
			ArmoryPrint( vars, "OWNERSHIP TRANSITION - Current team index is: " + string( vars.teamIndex ) )

			int teamIndex = -1

			array<int> teamsStillInside
			foreach ( entity e in vars.playersInsideShack )
			{
				if ( e == player )
					continue
				if ( !teamsStillInside.contains( e.GetTeam() ) )
					teamsStillInside.append( e.GetTeam() )
			}

			if ( !teamsStillInside.contains( player.GetTeam() ) && teamsStillInside.len() > 0 )
			{
				ArmoryPrint( vars, ("OWNERSHIP TRANSITION - Changed team index to: " + string( vars.teamIndex )) )
				vars.teamIndex = teamsStillInside.getrandom()

				if ( IsValid(vars.teleporter) )
				{
					vars.teleporter.SetOwner( vars.playersInsideShack[0] )
					SetTeam( vars.teleporter, vars.teamIndex )
				}
				else
				{
					ManageEntryTeleporter( si, vars.teamIndex )
				}
			}
			else
			{
				ArmoryPrint( vars, "OWNERSHIP TRANSITION - Didn't change team index" )
			}
		}
	}
}

void function SpectreShack_OnPlayerInsideInteriorDestroyed ( entity player )
{
	Assert( !IsValid(player) && IsInvalidButMemberVarsStillValid(player), "ERROR: ON DESTROY PLAYER | called ondestroy with an entity with invalid members" )

	if ( !( player in playerToSkitLookup ) )
		return

	SkitInstance si = playerToSkitLookup[player]
	MyVars vars = s_siToVars[ si ]

	if ( IsValid(vars.interiorTriggerVolume) )
	{
		Spectreshack_OnInteriorTriggerLeave_Internal ( vars.interiorTriggerVolume, player )
	}
}

void function OnPlayerDamaged_Armory( entity player, var damageInfo )
{
	if( !IsValid( player ) )
	{
		return
	}

	if( DamageInfo_GetAttacker( damageInfo ).GetClassName() == "npc_spectre" )
	{
		SkitInstance si = playerToSkitLookup[ player ]
		MyVars vars = s_siToVars[ si ]
		vars.cumulativeDamageToPlayers += int( DamageInfo_GetDamage( damageInfo ))
	}
}

void function SmartScannerVFX_Thread( SkitInstance si )
{
	MyVars vars = s_siToVars[ si ]
	entity smartScan_vfx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( ARMORY_SMART_SCAN_FX ), vars.scanVfxInfoTarget.GetOrigin(), vars.scanVfxInfoTarget.GetAngles() )

	if( IsValid( smartScan_vfx ) )
	{
		EmitSoundAtPosition( TEAM_ANY, smartScan_vfx.GetOrigin(), "SpectreShack_Scr_EntryScanner", smartScan_vfx )
	}

	wait 3.0
	EffectStop( smartScan_vfx )
	wait 3.0
	if( IsValid( smartScan_vfx ) )
	{
		smartScan_vfx.Destroy()
	}
}

void function SpectreShack_OnSurvivalDeathFieldStageChanged( int stage, float nextCircleStartTime )
{
	if ( stage == 0 )
	{
		return
	}

	vector nextCircleCenter = SURVIVAL_GetDeathFieldCenter( Survival_Loot_GetDefaultRealm() )
	float roundRadius = SURVIVAL_GetDeathFieldCurrentRadius( Survival_Loot_GetDefaultRealm() )
	const float SPECTRE_SHACK_RADIUS = 1000 // need a radius to ensure we'll entirely outside of the ring and not just the root entity
	foreach ( SkitInstance si in allSkits )
	{
		if ( si in s_siToVars )
		{
			MyVars vars = s_siToVars[si]
			if ( vars.spectreShackState == eSpectreShackState.Dormant ) // we want to make sure we don't stop Shacks in progress?
			{
				float distance = Distance2D( vars.controlPanel.GetOrigin(), nextCircleCenter )
				float maxDistance = SPECTRE_SHACK_RADIUS + roundRadius
				if ( distance > maxDistance )
				{
					vars.forceShutdown = true
					AbortEncounter( si )
				}
			}
		}
	}
}

void function Cleanup( SkitInstance si )
{
	MyVars vars = s_siToVars[si]
	vars.callbacks_OnSkitStarted.clear()
	vars.callbacks_OnSkitEnded.clear()

	delete s_siToVars[si]
}

entity function SpectreSpawnPoint_Rig_Proxy_Init( SpectreSpawnPoint spawnPoint, entity attachParent )
{
	entity spectreProp = CreatePropDynamicLightweight( HANGING_SPECTRE_STATIC, spawnPoint.attachmentOrigin, spawnPoint.attachmentAngles, 0, -1, true )
	spectreProp.SetParent( attachParent, spawnPoint.attachmentName )
	spectreProp.SetLocalOrigin( < 0, 0, 0 > )
	spectreProp.SetAbsAngles( spawnPoint.attachmentAngles )
	return spectreProp
}


// ██████╗ ██╗   ██╗███╗   ██╗████████╗██╗███╗   ███╗███████╗
// ██╔══██╗██║   ██║████╗  ██║╚══██╔══╝██║████╗ ████║██╔════╝
// ██████╔╝██║   ██║██╔██╗ ██║   ██║   ██║██╔████╔██║█████╗
// ██╔══██╗██║   ██║██║╚██╗██║   ██║   ██║██║╚██╔╝██║██╔══╝
// ██║  ██║╚██████╔╝██║ ╚████║   ██║   ██║██║ ╚═╝ ██║███████╗
// ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝

void function Runtime( SkitInstance si )
{
	MyVars vars = s_siToVars[si]

	// idle until the skit has been triggered by players
	while (vars.spectreShackState == eSpectreShackState.Dormant)
	{
		if ( vars.forceShutdown == true )
		{
			return
		}
		WaitFrame()
	}

	#if DEVELOPER
		ArmoryPrint( vars, "AUDIO TRIGGER | 'SpectreShack_Scr_UI_Activate'" )
		ArmoryPrint( vars, "AUDIO TRIGGER | broadcasting audio to num players: " + string(vars.playersInsideShack.len()) )
	#endif
	foreach( entity p in GetPlayersInsideShack(vars) )
	{
		EmitSoundOnEntityOnlyToPlayer( p, p, "SpectreShack_Scr_UI_Activate" )
	}

	// skit has been activated
	foreach ( void functionref() fr in vars.callbacks_OnSkitStarted )
	{
		if ( IsValid( fr ) )
		{
			fr();
		}
	}



	ArmoryPrint( vars, "Kicking off spectreshack. Number of people inside: " + vars.playersInsideShack.len(), false )
	Assert( GetPlayersInsideShack(vars).len() >= 1, "kicking off a spectreshack, but no one is inside it!" )

	if( vars.roofRepelEnabled )
	{
		thread RoofForcePush_Thread( si )
	}

	int lastKills = 0

	vars.currentRuiState = UIeSpectreShackState.ScanningPlayersStart
	foreach( entity wp in vars.ruiWaypoints)
	{
		wp.SetWaypointInt( CONTROLSCREEN_MASTER_STATE_INDEX, vars.currentRuiState )
	}

	wait 2.5

	vars.currentRuiState = UIeSpectreShackState.ShackHackStart
	foreach( entity wp in vars.ruiWaypoints)
	{
		wp.SetWaypointInt( CONTROLSCREEN_MASTER_STATE_INDEX, vars.currentRuiState )
	}

	wait 0.6

	vars.currentRuiState = UIeSpectreShackState.ScanningPlayersEnd
	foreach( entity wp in vars.ruiWaypoints)
	{
		wp.SetWaypointInt( CONTROLSCREEN_MASTER_STATE_INDEX, vars.currentRuiState )
	}

	wait 0.5

	vars.currentRuiState = UIeSpectreShackState.ShackHackInterference
	foreach( entity wp in vars.ruiWaypoints)
	{
		wp.SetWaypointInt( CONTROLSCREEN_MASTER_STATE_INDEX, vars.currentRuiState )
	}
	wait 0.2

	if( IsValid( vars.sfx_alarm ) )
	{
		EmitSoundAtPosition( TEAM_ANY, vars.sfx_alarm.GetOrigin(), vars.sfx_alarm.GetScriptName(), vars.sfx_alarm )
	}

	{ // ALERT / THREAT DETECTED
		array< string > voLines = [ "diag_ap_aiNotify_armoryWave1st_01_01", "diag_ap_aiNotify_armoryWave1st_02_01" ]
		#if DEVELOPER
			ArmoryPrint( vars, "AUDIO TRIGGER | 'diag_ap_aiNotify_armoryWave1st_01_01'" )
			ArmoryPrint( vars, "AUDIO TRIGGER | broadcasting audio to num players: " + string(vars.playersInsideShack.len()) )
		#endif
		string line = voLines.getrandom()
		foreach( entity p in GetPlayersInsideShack(vars) )
		{
			EmitSoundOnEntityOnlyToPlayer( p, p, line )
		}
	}

	wait 0.25

	thread PlayAnimOnly( vars.ceiling_Rig_Left,  "spectre_shack_hatchL_lower" )
	thread PlayAnimOnly( vars.ceiling_Rig_Right, "spectre_shack_hatchR_lower" )

	foreach( entity e in vars.sfx_ceilingEmitPoints )
	{
		EmitSoundAtPosition( TEAM_ANY, e.GetOrigin(), "SpectreShack_Emit_SpectreRackHatch_Lowering", e )
	}

	wait 1.0

	if( IsValid( vars.sfx_alarm ) )
	{
		EmitSoundAtPosition( TEAM_ANY, vars.sfx_alarm.GetOrigin(), "SpectreShack_Scr_Interference_Stinger", vars.sfx_alarm )
	}

	vars.currentRuiState = UIeSpectreShackState.Arming
	foreach( entity wp in vars.ruiWaypoints)
	{
		wp.SetWaypointInt( CONTROLSCREEN_MASTER_STATE_INDEX, vars.currentRuiState )
		wp.SetWaypointInt( CONTROLSCREEN_WAVES_CLEARED, vars.currentWave )
	}

	wait 1.5

	// cue the music
	vars.encounterMusicStartTime = Time()
	#if DEVELOPER
		ArmoryPrint( vars, "AUDIO TRIGGER | 'ARMORY_MUSIC_TRACK'" )
		ArmoryPrint( vars, "AUDIO TRIGGER | broadcasting audio to num players: " + string(vars.playersInsideShack.len()) )
	#endif
	foreach( entity p in GetPlayersInsideShack(vars) )
	{
		EmitSoundOnEntityOnlyToPlayer( p, p, ARMORY_MUSIC_TRACK )
	}

	foreach ( entity wp in vars.ruiWaypoints )
	{
		wp.SetWaypointGametime( 0, Time() )
		wp.SetWaypointGametime( 1, vars.encounterEndTime )
	}

	//wait 1.0
	vars.currentRuiState = UIeSpectreShackState.Activated
	foreach( entity wp in vars.ruiWaypoints)
	{
		wp.SetWaypointInt( CONTROLSCREEN_MASTER_STATE_INDEX, vars.currentRuiState )
	}

	foreach( entity wp in vars.ruiWaypoints)
	{
		wp.SetWaypointInt( CONTROLSCREEN_WAVES_CLEARED, vars.currentWave )
		wp.SetWaypointInt ( CONTROLSCREEN_COMBATSTATE_INDEX, 1 )
	}

	float waitTime = GetPlaylistVarFloat( GetCurrentPlaylistName(), "armory_wave_start_delay_time", 2.0 )
	for( ;; )
	{
		if( vars.spectreShackState == eSpectreShackState.Aborted )
			break

		if( vars.spawnWave )
		{
			thread SpawnCurrentWave_Thread( si, vars )
			vars.spawnWave = false
		}

		if ( vars.kills != lastKills ) {} // this is a lil event structure for when a kill has occurred

		if ( vars.kills >= vars.waveSpawnCount )
		{
			string waveEndSound = waveEndSounds[vars.currentWave - 1]

			#if DEVELOPER
				ArmoryPrint( vars, "AUDIO TRIGGER | " + waveEndSound )
				ArmoryPrint( vars, "AUDIO TRIGGER | broadcasting audio to num players: " + string(vars.playersInsideShack.len()) )
			#endif
			foreach( entity p in GetPlayersInsideShack(vars) )
			{
				EmitSoundOnEntityOnlyToPlayer( p, p, waveEndSound )
			}

			if ( Time() > vars.encounterEndTime || vars.currentWave == 8 || vars.spectreShackState != eSpectreShackState.Activated )
			{
				// end the encounter
				vars.encounterEndTime = Time() - 5.0
			}
			else
			{
				if( Time() + (waitTime * 0.5) < vars.encounterEndTime )
				{
					// encounter continues, trigger another wave
					vars.currentWave++
					array< string > voLines = [ "diag_ap_aiNotify_armoryWaveNext_01_01", "diag_ap_aiNotify_armoryWaveNext_02_01" ]
					#if DEVELOPER
						ArmoryPrint( vars, "AUDIO TRIGGER | 'diag_ap_aiNotify_armoryWaveNext_01_01'" )
						ArmoryPrint( vars, "AUDIO TRIGGER | broadcasting audio to num players: " + string(vars.playersInsideShack.len()) )
					#endif
					string line = voLines.getrandom()
					foreach( entity p in GetPlayersInsideShack( vars ) )
					{
						EmitSoundOnEntityOnlyToPlayer( p, p, line )
					}
					foreach ( entity wp in vars.ruiWaypoints )
					{
						wp.SetWaypointInt( CONTROLSCREEN_WAVES_CLEARED, vars.currentWave )
					}
					vars.spawnWave = true
				}
				vars.kills = 0
			}
		}

		lastKills = vars.kills

		if ( Time() > vars.encounterEndTime && vars.spectreShackState == eSpectreShackState.Activated )
		{
			// end the encounter
			if( vars.spectreShackState != eSpectreShackState.Aborted )
			{
				foreach( entity p in vars.playersInsideShack )
				{
					EmitSoundOnEntityOnlyToPlayer( p, p, "SpectreShack_Scr_60Sec_TimeEnd_Stinger" )
				}

				wait (waitTime * 0.5)
				vars.spectreShackState = eSpectreShackState.Completed
				Thread_ControlPanel_OnStateChange( si, vars.spectreShackState )
				vars.currentRuiState = UIeSpectreShackState.Completed

				thread LootbinAnimation_SFX_Thread( si )

				foreach ( entity wp in vars.ruiWaypoints )
				{
					wp.SetWaypointInt( CONTROLSCREEN_MASTER_STATE_INDEX, vars.currentRuiState )
				}
				thread ForceOpenTimer_Thread( si )
			}
			break
		}

		WaitFrame()
	}

	thread PlayAnimOnly( vars.ceiling_Rig_Left,  "spectre_shack_hatchL_raise" )
	thread PlayAnimOnly( vars.ceiling_Rig_Right, "spectre_shack_hatchR_raise" )

	foreach( entity e in vars.sfx_ceilingEmitPoints )
	{
		EmitSoundAtPosition( TEAM_ANY, e.GetOrigin(), "SpectreShack_Emit_SpectreRackHatch_Rising", e )
	}



	if( vars.spectreShackState == eSpectreShackState.Completed )
	{
		array< string > voLines = [ "diag_ap_aiNotify_armoryVictory_01_01", "diag_ap_aiNotify_armoryVictory_02_01" ]
		#if DEVELOPER
			ArmoryPrint( vars, "AUDIO TRIGGER | 'diag_ap_aiNotify_armoryVictory_01_01'" )
			ArmoryPrint( vars, "AUDIO TRIGGER | broadcasting audio to num players: " + string(vars.playersInsideShack.len()) )
		#endif
		string line = voLines.getrandom()

		foreach( entity p in GetPlayersInsideShack(vars) )
		{
			EmitSoundOnEntityOnlyToPlayer( p, p, line )
		}

		foreach( entity wp in vars.ruiWaypoints)
		{
			wp.SetWaypointInt ( CONTROLSCREEN_COMBATSTATE_INDEX, 0 )
		}

		wait 2.0

//	██╗      ██████╗  ██████╗ ████████╗
//	██║     ██╔═══██╗██╔═══██╗╚══██╔══╝
//	██║     ██║   ██║██║   ██║   ██║
//	██║     ██║   ██║██║   ██║   ██║
//	███████╗╚██████╔╝╚██████╔╝   ██║
//	╚══════╝ ╚═════╝  ╚═════╝    ╚═╝


		int shackSuccessTier = int( floor (vars.currentWave / 2) )
		shackSuccessTier = int ( max( shackSuccessTier, 1 ) )

		// awww yeah smartloot

		array<entity> teammates = GetPlayerArrayOfTeam_Alive( vars.teamIndex )

		if ( GetCurrentPlaylistVarBool( "armory_loot_only_for_players_inside", true ) )
		{
			for ( int i = teammates.len() - 1; i >= 0; --i )
			{
				if ( !vars.playersInsideShack.contains( teammates[i] ) )
				{
					teammates.fastremove( i )
				}
			}
		}

		//shuffle the order of the players here since the order matters for gold tie breakers
		teammates.randomize()
		int numberOfTeammates   = teammates.len()
		array< array< string > > possibleRewardsPerPlayer
		array<string> possibleRewards

		int cargoBinsToSpawn = vars.currentWave
		#if DEVELOPER
			int cargoBinCountOverride = GetCurrentPlaylistVarInt( "spectreshack_cargobin_count", 0 )
			if( cargoBinCountOverride > 0)
			{
				cargoBinsToSpawn = cargoBinCountOverride
			}
		#endif

		int numberOfBinsPerPlayer = 0
		int numberOfExtraSharedBins = 0
		if ( numberOfTeammates > 0 )
		{
			numberOfBinsPerPlayer = int( floor( cargoBinsToSpawn / numberOfTeammates ) )
			numberOfExtraSharedBins = cargoBinsToSpawn % numberOfTeammates
		}

		array< int > equipmentTypes = [ eLootType.HELMET, eLootType.INCAPSHIELD, eLootType.BACKPACK ]
		for( int i = 0; i < numberOfTeammates; i++ )
		{
			possibleRewardsPerPlayer.append(SmartLoot_GetLoot( teammates[i], true, true, equipmentTypes ))
		}

		if ( numberOfTeammates > 0 )
		{
			//post process the list to upgrade the tiers and remove extra golds
			array< array < string > > whiteLoot
			array< array < string > > goldLoot
			table< string, int > goldLootItemCounts
			array< string > goldLootOptions
			int numberOfTeammatesWhoCanGetGold = 0
			bool redistributeGolds = GetCurrentPlaylistVarBool( "armory_distribute_golds", true )
			int hopupBaseChance = GetCurrentPlaylistVarInt( "armory_hopup_base_chance", 50 )
			int hopupGoldChance = GetCurrentPlaylistVarInt( "armory_hopup_gold_chance", 20 )

			//Step 1: create dictionary of golds and whites
			LootData lootItem
			for( int i = 0; i < numberOfTeammates; i++ )
			{
				whiteLoot.append( [] )
				goldLoot.append( [] )
				for(int j = 0; j < possibleRewardsPerPlayer[i].len(); j++ )
				{
					lootItem = SURVIVAL_Loot_GetLootDataByRef( possibleRewardsPerPlayer[i][j] )

					//scopes are doing their own thing, people sometimes like white scopes
					if ( lootItem.attachmentType == eWeaponAttachmentType.SCOPE )
						continue

					if ( lootItem.attachmentType == eWeaponAttachmentType.HOPUP )
					{
						if ( lootItem.tier == 4 )
						{
							if ( RandomInt(100) < hopupGoldChance )
								continue
						}
						else
						{
							if ( RandomInt(100) < hopupBaseChance )
								continue
						}

						possibleRewardsPerPlayer[i].fastremove(j)
						j--
						continue
					}

					if (lootItem.tier == 1)
					{
						whiteLoot[i].append( possibleRewardsPerPlayer[i][j] )
						possibleRewardsPerPlayer[i].fastremove(j)
						j--
					}
					else if ( redistributeGolds && lootItem.tier == 4 )
					{
						int itemType = lootItem.lootType

						//we dont care about gold attachements, people can have however many of them
						if ( !equipmentTypes.contains(itemType) )
							continue

						if ( !(possibleRewardsPerPlayer[i][j] in goldLootItemCounts) )
						{
							goldLootOptions.append( possibleRewardsPerPlayer[i][j] )
							goldLootItemCounts[possibleRewardsPerPlayer[i][j]] <- 1
						}
						else
						{
							goldLootItemCounts[possibleRewardsPerPlayer[i][j]]++
						}
						if( goldLoot[i].len() == 0 )
						{
							numberOfTeammatesWhoCanGetGold++
						}

						goldLoot[i].append( possibleRewardsPerPlayer[i][j] )
						possibleRewardsPerPlayer[i].fastremove(j)
						j--
					}
				}

				//shuffle the list here to make sure we don't always award the same loot to the same players
				goldLoot[i].randomize()
			}

			//Step 2: upgrade some white loot
			int upgradeChance = 100
			array< LootData > returnedUpgrades
			for( int i = 0; i < numberOfTeammates; i++ )
			{
				int lootSizeAtEnd = possibleRewardsPerPlayer[i].len() + whiteLoot[i].len()
				for ( int j = 0; j < whiteLoot[i].len(); j++ )
				{
					if ( RandomInt( 100 ) < upgradeChance )
					{
						returnedUpgrades.clear()
						lootItem = SURVIVAL_Loot_GetLootDataByRef( whiteLoot[i][j] )
						if ( lootItem.lootType == eLootType.ATTACHMENT )
						{
							returnedUpgrades = LootHelper_GetAttachmentData_OfType_OfTier( lootItem.attachmentType, 2 )
							LootData lootItemToKeep

							foreach( LootData item in returnedUpgrades )
							{
								if( item.attachmentStyle == lootItem.attachmentStyle )
								{
									lootItemToKeep = item
									break
								}
							}

							returnedUpgrades.clear()
							returnedUpgrades.append( lootItemToKeep )
						}
						else
						{
							returnedUpgrades = LootHelper_GetLootData_OfType_OfTier( lootItem.lootType, 2 )
						}

						if (  returnedUpgrades.len() == 1 )
						{
							possibleRewardsPerPlayer[i].append( returnedUpgrades[0].ref )
						}
						else
						{
							Warning( "Spectre Shacks - Tried to upgrade %s but got %d upgrades back!", whiteLoot[i][j], returnedUpgrades.len() )
							possibleRewardsPerPlayer[i].append( whiteLoot[i][j] )
						}
					}
					else
					{
						possibleRewardsPerPlayer[i].append( whiteLoot[i][j] )
					}
				}

				Assert( possibleRewardsPerPlayer[i].len() == lootSizeAtEnd, "Spectre Shacks - changed number of items while trying to upgrate whites! Original: " + string(lootSizeAtEnd) + ", Current: " + string (possibleRewardsPerPlayer[i].len()) )

				//once we re-add all the whites and upgrades, shuffle the list since we'll be pulling in order after this
				possibleRewardsPerPlayer[i].randomize()
			}

			//Step 3: redistribute the gold loot so only one of each is spawned and players get at most 1 each
			int numberOfPlayersWithGold = 0
			int currentPass             = 1
			while ( goldLootOptions.len() != 0 && numberOfPlayersWithGold != numberOfTeammatesWhoCanGetGold)
			{
				//Pass 1, hand out uniques to anyone who has them, remove all other golds they have from the pool and try again
				//until all uniques are handed out
				if ( currentPass == 1 )
				{
					bool foundGoldForAnyone = false
					for( int i = 0; i < numberOfTeammates; i++ )
					{
						for ( int j = 0; j < goldLoot[i].len(); j++ )
						{
							if ( goldLootItemCounts[goldLoot[i][j]] == 1 )
							{
								possibleRewardsPerPlayer[i].append(goldLoot[i][j])
								goldLootOptions.fastremovebyvalue( goldLoot[i][j] )
								numberOfPlayersWithGold++

								while (goldLoot[i].len() != 0)
								{
									goldLootItemCounts[goldLoot[i].top()]--
									goldLoot[i].pop()
								}

								foundGoldForAnyone = true
								break
							}
						}
					}

					if ( !foundGoldForAnyone )
					{
						currentPass = 2
						//continue is just so we don't run the next step if all loot is already handed out
						continue
					}
				}

				//Pass 2, if anyone only has has one option, lets give them that
				//we don't go back to pass 1 from this, since it doesn't effect the gold count for items other than what's picked
				if ( currentPass == 2 )
				{
					bool foundGoldForAnyone = false
					for( int i = 0; i < numberOfTeammates; i++ )
					{
						if ( goldLoot[i].len() == 1 )
						{
							possibleRewardsPerPlayer[i].append(goldLoot[i].top())
							goldLootItemCounts[goldLoot[i].top()] = 0
							goldLootOptions.fastremovebyvalue( goldLoot[i].top() )
							numberOfPlayersWithGold++

							//remove this option from everyone elses pool
							for( int j = 0; j < numberOfTeammates; j++ )
							{
								if ( i == j )
									continue

								for ( int k = 0; k < goldLoot[j].len(); k++ )
								{
									if( goldLoot[j][k] == goldLoot[i].top() )
									{
										goldLoot[j].fastremove( k )
									}
								}
							}

							goldLoot[i].pop()
							foundGoldForAnyone = true
						}
					}

					if ( !foundGoldForAnyone )
					{
						currentPass = 3
						//continue is just so we don't run the next step if all loot is already handed out
						continue
					}
				}

				//Pass 3: players all share multiple options, give someone random loot and try pass 1 again
				if ( currentPass == 3 )
				{
					for( int i = 0; i < numberOfTeammates; i++ )
					{
						if ( goldLoot[i].len() >= 1 )
						{
							possibleRewardsPerPlayer[i].append(goldLoot[i].top())
							goldLootItemCounts[goldLoot[i].top()] = 1 //since it'll get deincremented below
							goldLootOptions.fastremovebyvalue( goldLoot[i].top() )
							numberOfPlayersWithGold++

							//remove this option from everyone elses pool
							for( int j = 0; j < numberOfTeammates; j++ )
							{
								if ( i == j )
									continue

								for( int k = 0; k < goldLoot[j].len(); k++ )
								{
									if( goldLoot[j][k] == goldLoot[i].top() )
									{
										goldLoot[j].fastremove( k )
										break
									}
								}
							}

							while( goldLoot[i].len() != 0 )
							{
								goldLootItemCounts[goldLoot[i].top()]--
								goldLoot[i].pop()
							}

							currentPass = 1
							break
						}
					}
					Assert( currentPass != 3, "Spectre Shacks - Trying to distribute gold loot but got stuck in an infinte loop!" )
					if ( currentPass == 3 )
						break
				}
			}
		}

		// ammo types
		int totalSmartLootOptions = 0
		foreach ( array< string > perPlayerLoot in possibleRewardsPerPlayer )
		{
			totalSmartLootOptions += perPlayerLoot.len()
		}

		int ammoToAdd = (cargoBinsToSpawn * 4) - totalSmartLootOptions

		if ( ammoToAdd > 0 )
		{
			table< int, string > weightedAmmoList = LootHelper_GetTeamAmmoTypes_Weighted( vars.teamIndex )

			var seed = CreateRandomSeed( 420 )
			for( int i = 0; i < ammoToAdd; i++ )
			{
				if( i % 2 == 0 )
				{
					int roll = RandomIntSeeded( seed, 100 )
					if( roll < 33 )
					{
						possibleRewards.append( "mp_weapon_thermite_grenade" )
					}
					else if( roll < 66 )
					{
						possibleRewards.append( GRENADE_EMP_WEAPON_NAME )
					}
					else
					{
						possibleRewards.append( "mp_weapon_frag_grenade" )
					}
				}
				else
				{
					if( weightedAmmoList.len() < 1 )
					{
						continue
					}
					int selectedAmmoIndex = RandomInt( weightedAmmoList.len() )
					possibleRewards.append( weightedAmmoList[selectedAmmoIndex] )
				}
			}
		}

		// Push cargo bins into the interior space
		//
		if( IsValid( vars.lootbinMovers ) )
		{
			if( IsValid( vars.lootbinLocations ) )
			{
				// pick n random numbers
				array< int > lootbinIndices

				if( GetPlaylistVarBool( GetCurrentPlaylistName(), "armory_grouped_bin_locations", true ) )
				{
					for( int i = 0; i < cargoBinsToSpawn; i++ )
					{
						if ( !lootbinIndices.contains( i ) )
						{
							lootbinIndices.append( i )
						}
					}
				}
				else
				{
					while( lootbinIndices.len() < cargoBinsToSpawn )
					{
						int r = RandomInt( vars.lootbinLocations.len() )

						if( !lootbinIndices.contains( r ) )
						{
							lootbinIndices.append( r )
						}
					}
				}

				array< int > lootBinHighestRarities
				lootBinHighestRarities.resize( 8, 0 )
				int numberOfLootBinsFilled = 0
				string lootRef_internal
				array< string > lootStringArray
				bool giveHealthItems = GetPlaylistVarBool( GetCurrentPlaylistName(), "armory_include_smart_health", true )
				for( int playerIndex = 0; playerIndex < numberOfTeammates; playerIndex++ )
				{
					for( int currentPlayerBinNumber = 0; currentPlayerBinNumber < numberOfBinsPerPlayer; currentPlayerBinNumber++ )
					{
						lootStringArray.clear()

						//if we're completely out of rewards for a player, don't make a fresh bin for them,
						if (possibleRewardsPerPlayer[playerIndex].len() == 0)
						{
							numberOfExtraSharedBins += ( numberOfBinsPerPlayer - currentPlayerBinNumber )
							break
						}

						for (int j = 0; j < 4; j++)
						{
							//this is a bit hacky, it'll just fill the extra space with random ammo, but it works
							if (possibleRewardsPerPlayer[playerIndex].len() > 0)
							{
								//we've suffled the order of the array, but put the gold at the end if there is one, so this ensures that you always get it
								lootRef_internal = possibleRewardsPerPlayer[playerIndex].pop()
								lootStringArray.append( lootRef_internal )
								vars.lootAwarded.append( lootRef_internal )
							}
							else
							{
								lootRef_internal = LootHelper_GetRandomLootRefFromGroupAndRemove( possibleRewards )
								lootStringArray.append( lootRef_internal )
								vars.lootAwarded.append( lootRef_internal )
							}
						}

						if( currentPlayerBinNumber == 0 )
						{
							if( giveHealthItems )
							{
								float currentHealth = float( teammates[playerIndex].GetHealth() )
								float maxHealth = float( teammates[playerIndex].GetMaxHealth() )
								float healthPct = 1.0
								if( maxHealth > 0 )
								{
									healthPct = currentHealth / maxHealth
								}
								bool needsMedKit = healthPct < 1.0

								float currentShields = float( teammates[playerIndex].GetShieldHealth() )
								float maxShields = float( teammates[playerIndex].GetShieldHealthMax() )
								float shieldPct = 1.0
								if ( maxShields > 0 )
								{
									shieldPct = currentShields / maxShields
								}
								bool needsBattery = shieldPct < 1.0

								#if DEVELOPER
									ArmoryPrint( vars, "processing health for teammate "  + playerIndex + " | HEALTH : "  + healthPct )
									ArmoryPrint( vars, "processing battery for teammate " + playerIndex + " | SHIELDS : " + shieldPct  )
									ArmoryPrint( vars, "processing health items | needs med kit: " + string(needsMedKit) + "| needs battery: " + string(needsBattery) )
								#endif

								if( needsMedKit && needsBattery )
								{
									lootStringArray.append( "health_pickup_combo_full" )
								}
								else if ( needsMedKit || needsBattery )
								{
									if( needsMedKit )
									{
										lootStringArray.append( "health_pickup_health_large" )
									}
									else
									{
										lootStringArray.append( "health_pickup_combo_large" )
									}
								}
							}
						}

						//suffle the array so we don't have the gold in the same spot all the time
						lootStringArray.randomize()

						lootBinHighestRarities[numberOfLootBinsFilled] = CreateFillAndMoveCargoBin( lootStringArray, teammates[playerIndex], lootbinIndices[numberOfLootBinsFilled], vars )

						numberOfLootBinsFilled++
					}
				}

				if ( numberOfExtraSharedBins > 0 )
				{
					foreach ( array< string > perPlayerLoot in possibleRewardsPerPlayer )
					{
						possibleRewards.extend( perPlayerLoot )
					}
				}

				for( int i = numberOfLootBinsFilled; i < (numberOfLootBinsFilled + numberOfExtraSharedBins); i++ )
				{
					lootStringArray.clear()
					for (int j = 0; j < 4; j++)
					{
						lootRef_internal = LootHelper_GetRandomLootRefFromGroupAndRemove( possibleRewards )
						lootStringArray.append( lootRef_internal )
						vars.lootAwarded.append( lootRef_internal )
					}

					lootBinHighestRarities[i] = CreateFillAndMoveCargoBin( lootStringArray, null,  lootbinIndices[i], vars )
				}
				foreach( entity p in GetPlayersInsideShack( vars ) )
				{
					foreach ( entity wp in vars.ruiWaypoints )
					{
						Remote_CallFunction_Replay( p, "ServerCallback_SpectreShacksUpdateLootBinRarity", wp,
						lootBinHighestRarities[0], lootBinHighestRarities[1], lootBinHighestRarities[2], lootBinHighestRarities[3],
						lootBinHighestRarities[4], lootBinHighestRarities[5], lootBinHighestRarities[6], lootBinHighestRarities[7] )
					}
				}

				if( cargoBinsToSpawn == 8 && GetPlaylistVarBool( GetCurrentPlaylistName(), "armory_spawn_loot_roller", false ) )
				{
					EmitSoundAtPosition( TEAM_UNASSIGNED, vars.topPrizeSpawnPoint.GetOrigin(), "SpectreShack_Scr_LootAppear", vars.topPrizeSpawnPoint )
					entity lootVFX = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( ARMORY_TOP_PRIZE_VFX ), vars.topPrizeSpawnPoint.GetOrigin(), vars.topPrizeSpawnPoint.GetAngles() )
					lootVFX.kv.kill_for_replay = true

					wait 1.5
					//LootRollerData launchData = LootRollers_CreateLootRoller_Armory( vars.topPrizeSpawnPoint.GetOrigin(), vars.topPrizeSpawnPoint.GetAngles() )
					//LaunchLootRoller( launchData, <0,0,1>, 200 )
					thread DestroyFXAfterDelay_Thread( lootVFX, 2.0 )
				}
			}
		}

		wait 1.0
	}

	foreach ( void functionref() fr in vars.callbacks_OnSkitEnded )
	{
		if (IsValid( fr ))
		{
			fr();
		}
	}

	wait 3.0
	foreach( entity group in vars.spawnGroups )
	{
		if( !IsValid( group ) )
		{
			continue
		}
		foreach( entity prop in group.GetLinkEntArray() )
		{
			if( !IsValid( prop ) )
			{
				continue
			}
			prop.Destroy()
		}
	}

	foreach( entity e in vars.spawnGroupOne )
	{
		if( IsValid( e ) )
		{
			e.Destroy()
		}
	}

	foreach( entity e in vars.spawnGroupTwo )
	{
		if( IsValid( e ) )
		{
			e.Destroy()
		}
	}

	foreach( e in vars.lootbinMovers )
	{
		foreach( bin in e.GetChildren() )
		{
			bin.ClearParent()
		}
		e.Destroy()
	}
	vars.lootbinMovers.clear()

	if( vars.spectreShackState != eSpectreShackState.Aborted )
		vars.currentRuiState = UIeSpectreShackState.ExitPrompt
	else
		vars.currentRuiState = UIeSpectreShackState.Aborted

	foreach( entity wp in vars.ruiWaypoints)
	{
		wp.SetWaypointInt( CONTROLSCREEN_MASTER_STATE_INDEX, vars.currentRuiState )
	}

	//previously, due to a logic bug, runtime never ended. There's not a lot of cleanup that actually happens when it finishes
	//and the script sorta expects it to never end, so lets just maintain that behavior
	WaitForever()
}

void function ForceOpenTimer_Thread ( SkitInstance si )
{
	MyVars vars = s_siToVars[ si ]

	int livingSpectreGracePeriod = 0
	while ( vars.activeSpectres.len() > 0 && livingSpectreGracePeriod < 40 )
	{
		livingSpectreGracePeriod++
		wait 0.5
	}

	vars.forceOpenTime = Time() + forceOpenTimer

	// we gotta set the start and end point of force open thread, so we can actually show / hide and control the timer of the auto open
	foreach ( entity wp in vars.ruiWaypoints )
	{
		wp.SetWaypointGametime( CONTROLSCREEN_EXIT_PROMPT_START, Time() )
		wp.SetWaypointGametime( CONTROLSCREEN_EXIT_PROMPT_END, Time() + ARMORY_FORCE_OPEN_TIMER )
	}

	string commentaryRef = armoryOpeningWarningDialogues.getrandom()
	while ( Time() < vars.forceOpenTime )
	{
		if ( vars.forceOpenTime - Time() < 30 && commentaryRef != "" )
		{
			foreach ( entity player in  GetPlayersInsideShack ( vars) )
			{
				EmitSoundOnEntityOnlyToPlayer ( player , player, commentaryRef)
			}
			commentaryRef = ""
		}
		wait 0.5
	}

	if( vars.spectreShackState == eSpectreShackState.Completed )
	{
		TransitionCompletedToDeactivated( si )
		array< entity > teammatesAlive = GetPlayerArrayOfTeam_Alive( vars.teamIndex )
		if( teammatesAlive.len() < 1 )
		{
			return
		}
		entity randomTeammate = teammatesAlive.getrandom()
		if( IsValid( randomTeammate ) )
		{
			//PIN_Interact_Armory_Complete( randomTeammate, "spectre_shack_complete", "completed", CreateArmoryInts( vars ), vars.lootAwarded, vars.controlPanel.GetInstanceName(), randomTeammate.GetOrigin() )
		}
	}
}

void function UnlockCargoBin_Thread( entity cargoBin, entity player, entity controlPanel )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "OnDestroy" )
	EndSignal( controlPanel, ON_EXIT_AFTER_COMPLETION_SIGNAL_KEYWORD )

	OnThreadEnd(
		function() : ( cargoBin )
		{
			if ( IsValid( cargoBin ) )
			{
				GradeFlagsClear( cargoBin, eGradeFlags.IS_LOCKED )
			}
		}
	)

	WaitForever()
}

int function CreateFillAndMoveCargoBin( array< string > loot, entity player, int cargoBinIndex, MyVars vars )
{
	// open the cargo storage hatch
	int highestRarity = 1

	entity cargoHatch = vars.lootbinLocations[cargoBinIndex].GetLinkEnt()
	if( IsValid( cargoHatch ) )
	{
		entity hatchMover = CreateScriptMover( SPECTRE_SHACK_SKIT_MOVER_SCRIPTNAME + "__hatchMover", cargoHatch.GetOrigin(), cargoHatch.GetAngles() )
		cargoHatch.SetParent( hatchMover )
		hatchMover.NonPhysicsSetMoveModeLocal( true )
		//vector destination = CalcLocalToWorldOrigin_Entity( hatchMover, <0, 0, -68> )
		//hatchMover.NonPhysicsMoveTo( destination, 2.0, 0.5, 1.5 )
	}

	entity lootBin = CreateLootBin( vars.lootbinLocations[cargoBinIndex].GetOrigin(), vars.lootbinLocations[cargoBinIndex].GetAngles() )
	if( IsValid( lootBin ) )
	{
		InitLootBin( lootBin )
		vars.lootbinProxies.append( lootBin )
		lootBin.SetSkin( lootBin.GetSkinIndexByName( "SmartLoot" ) )
		FillSpectreShackLootBin( lootBin, loot, vars )

		LootData lootItem
		foreach ( string lootItemString in loot )
		{
			lootItem = SURVIVAL_Loot_GetLootDataByRef( lootItemString )
			if ( lootItem.tier > highestRarity )
			{
				highestRarity = lootItem.tier
			}
		}

		if ( player != null )
		{
			GradeFlagsSet( lootBin, eGradeFlags.IS_LOCKED )
			lootBin.SetOwner( player )

			thread UnlockCargoBin_Thread( lootBin, player, vars.controlPanel )
		}

		vars.lootbinProxies[cargoBinIndex].Destroy()
	}

	if( IsValid( vars.lootbinMovers[cargoBinIndex] ) )
	{
		entity mover = CreateScriptMover( SPECTRE_SHACK_SKIT_MOVER_SCRIPTNAME + "__lootbinMover", lootBin.GetOrigin(), lootBin.GetAngles(), 0 )
		if( IsValid( mover ) )
		{
			mover.SetPusher( true )
			vars.lootbinMovers[cargoBinIndex].Destroy()
			vars.lootbinMovers[cargoBinIndex] = mover
			lootBin.SetParent( vars.lootbinMovers[cargoBinIndex] )
			//vector v = CalcLocalToWorldOrigin_Entity( vars.lootbinMovers[cargoBinIndex],  <72, 0, 0>)
			//vars.lootbinMovers[cargoBinIndex].NonPhysicsMoveTo( v, 4.0, 3.5, 0.5 )
			EmitSoundOnEntity( lootBin, "SpectreShack_Scr_LootBin_Slide_Open" )
			if ( IsValid( player ) )
				thread HighlightSmartLootBinForOwner_Thread( lootBin, player, vars )
		}
	}

	return highestRarity
}

// this function executes when loba steals something from the shack's smartloot via black market
void function SpectreShackLootDefense( entity pickup, entity device, entity player ) {}

void function HighlightSmartLootBinForOwner_Thread ( entity lootBin, entity player, MyVars vars )
{
	lootBin.EndSignal("OnDestroy")

	wait 2.0

	if ( !IsValid( lootBin ) || !IsValid( player ) )
		return

	ArmoryPrint( vars, "Highlighting lootbin for " + player.GetPlayerName() )

	entity wp = CreateWaypoint_Custom( "highlighter" )

	wp.SetWaypointEntity( 0, lootBin )
	wp.SetOnlyTransmitToOnePlayer( player )

	OnThreadEnd ( function ():(wp, player, vars) {
		if ( IsValid( wp ) )
			wp.Destroy()
		#if DEVELOPER
		if ( IsValid( player ) )
			ArmoryPrint( vars, "Removing lootbin highlighting for " + player.GetPlayerName() )
		#endif
	} )

	while ( IsSpectreShackSmartLootLocked(lootBin) )
	{
		WaitFrame()
	}

}

// ██╗    ██╗ █████╗ ██╗   ██╗███████╗███████╗
// ██║    ██║██╔══██╗██║   ██║██╔════╝██╔════╝
// ██║ █╗ ██║███████║██║   ██║█████╗  ███████╗
// ██║███╗██║██╔══██║╚██╗ ██╔╝██╔══╝  ╚════██║
// ╚███╔███╔╝██║  ██║ ╚████╔╝ ███████╗███████║
//  ╚══╝╚══╝ ╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚══════╝


void function SpawnCurrentWave_Thread( SkitInstance si, MyVars vars )
{



	string waveStartSound = waveStartSounds[vars.currentWave - 1]

	switch( vars.currentWave )
	{
		case 1:
			#if DEVELOPER
				ArmoryPrint( vars, "AUDIO TRIGGER | " + waveStartSound )
				ArmoryPrint( vars, "AUDIO TRIGGER | broadcasting audio to num players: " + string(vars.playersInsideShack.len()) )
			#endif
			foreach( entity p in GetPlayersInsideShack( vars ) )
			{
				EmitSoundOnEntityOnlyToPlayer( p, p, waveStartSound )
			}
			break
		default:
			vars.currentRuiState = UIeSpectreShackState.Arming
			foreach ( entity wp in vars.ruiWaypoints )
			{
				wp.SetWaypointInt( CONTROLSCREEN_MASTER_STATE_INDEX, vars.currentRuiState )
			}
			float waitTime = GetPlaylistVarFloat( GetCurrentPlaylistName(), "armory_wave_start_delay_time", 2.0 )
			wait waitTime
			#if DEVELOPER
				ArmoryPrint( vars, "AUDIO TRIGGER | " + waveStartSound )
				ArmoryPrint( vars, "AUDIO TRIGGER | broadcasting audio to num players: " + string(vars.playersInsideShack.len()) )
			#endif
			foreach( entity p in GetPlayersInsideShack( vars ) )
			{
				EmitSoundOnEntityOnlyToPlayer( p, p, waveStartSound )
			}
			vars.currentRuiState = UIeSpectreShackState.Activated
			foreach ( entity wp in vars.ruiWaypoints )
			{
				wp.SetWaypointInt( CONTROLSCREEN_MASTER_STATE_INDEX, vars.currentRuiState )
			}
			break
	}

	bool spawnedGroupTwo = false
	for (int i = 0; i < vars.waveSpawnCount; i++)
	{
		int selectedSpawnGroup = -1
		switch( vars.currentWave )
		{
			case 1:
				// spawn all the spectres in group 0
				selectedSpawnGroup = 0
				break
			case 6:
			case 7:
			case 8:
				// starting with wave 6 there are no more spectres in group 2
				selectedSpawnGroup = 1
				break
			default:
				// spawn one spectre that falls on the cubby
				if( spawnedGroupTwo == false )
				{
					selectedSpawnGroup = 2
					spawnedGroupTwo = true
				}
				else
				{
					selectedSpawnGroup = 1
				}
				break
		}

		switch ( selectedSpawnGroup )
		{
			case 0:
				array<entity> spawnPoints = vars.spawnGroups[selectedSpawnGroup].GetLinkEntArray()
				int spawnIndex = RandomIntRange(0, spawnPoints.len())
				entity spawnEnt = spawnPoints[spawnIndex]
				vars.spawnGroups[selectedSpawnGroup].UnlinkFromEnt( spawnEnt )
				vector pos = spawnEnt.GetOrigin()
				vector rot = spawnEnt.GetAngles()

				array<entity> doors = clone spawnEnt.GetLinkEntArray()
				float stagger = vars.kickoffStagger
				vars.kickoffStagger += 0.2
				// spectre npcs get created in combatkickoff_thread()
				thread CombatKickoff_Thread( si, pos, rot, spawnEnt, selectedSpawnGroup, doors, stagger )
				break
			case 1:
				int spawnIndex = 0
				if( vars.spawnGroupOne.len() > 0 )
				{
					spawnIndex = RandomInt( vars.spawnGroupOne.len() )
				}
				entity spawnEnt = vars.spawnGroupOne[spawnIndex]
				ArmoryPrint( vars, "Spawn Group 1 / Spawn Index: " + string( spawnIndex ) + " | Spawn Group Length: " + vars.spawnGroupOne.len() )
				vars.spawnGroupOne.fastremove( spawnIndex )
				vector pos = spawnEnt.GetOrigin()
				vector rot = spawnEnt.GetAngles()
				entity npc = SkNPC_SpawnNPC( si, eNPC.SPECTRE, pos, rot )
				Armory_InitSpectre( npc, si, spawnEnt, selectedSpawnGroup )
				break
			case 2:
				int spawnIndex = 0
				if( vars.spawnGroupTwo.len() > 0 )
				{
					spawnIndex = RandomInt( vars.spawnGroupTwo.len() )
				}
 				entity spawnEnt = vars.spawnGroupTwo[spawnIndex]
				ArmoryPrint( vars, ("Spawn Group 2 / Spawn Index: " + string( spawnIndex ) + " | Spawn Group Length: " + vars.spawnGroupTwo.len()) )
				vars.spawnGroupTwo.fastremove( spawnIndex )
				vector pos = spawnEnt.GetOrigin()
				vector rot = spawnEnt.GetAngles()
				entity npc = SkNPC_SpawnNPC( si, eNPC.SPECTRE, pos, rot )
				Armory_InitSpectre( npc, si, spawnEnt, selectedSpawnGroup )
				break
		}
	}


}

void function Armory_InitSpectre( entity npc, SkitInstance si, entity spawnEnt, int selectedSpawnGroup )
{
	MyVars vars = s_siToVars[si]
	float ammoMultiplier = GetPlaylistVarFloat( GetCurrentPlaylistName(), "armory_ammo_count_multiplier", 2.0 )
	int ammoDropPct = GetPlaylistVarInt( GetCurrentPlaylistName(), "armory_spectre_extra_ammo_drop_percent", 40 )

	if( vars.currentWave > 1 )
	{
		if ( selectedSpawnGroup == 2 )
		{
			thread PlayAnim( npc, "spectre_shack_ceiling_dropB" )
		}
		else
		{
			thread PlayAnim( npc, "spectre_shack_ceiling_dropA" )
		}
	}

	if ( (RandomInt( 100 )) < 65 )
	{
		npc.kv.defenseActive = false
		npc.DisableNPCFlag( NPC_USE_SHOOTING_COVER )
	}
	spawnEnt.Destroy()

	vars.activeSpectres.append( npc )
	AddEntityCallback_OnPostDamaged( npc, void function ( entity npc, var damageInfo ) : ( vars, ammoMultiplier )
	{
		entity attacker = DamageInfo_GetAttacker( damageInfo )

		if ( IsValid( attacker ) &&  attacker.IsPlayer() )
		{
			vars.cumulativeDamageToSpectres += int( DamageInfo_GetDamage( damageInfo ))
		}
	} )

	AddEntityCallback_OnKilled( npc, void function ( entity npc, var damageInfo ) : ( vars, ammoMultiplier, ammoDropPct )
	{
		entity attacker = DamageInfo_GetAttacker( damageInfo )

		++vars.kills
		++vars.cumulativeKills

		if ( IsValid( attacker ) && attacker.IsPlayer() )
		{
			SpawnAmmoForCurrentWeapon( npc, damageInfo, ammoMultiplier )
			if ( (RandomInt( 100 )) < ammoDropPct )
			{
				SpawnAmmoForRandomWeapon( npc, damageInfo, ammoMultiplier )
			}

			if( vars.cumulativeKills % vars.waveSpawnCount == 0 )
			{
				string itemRef
				if( vars.currentWave % 2 == 0 )
				{
					itemRef = SURVIVAL_GetWeightedItemFromGroup( "ai_loot_drop_shield_small" )
				}
				else
				{
					itemRef = SURVIVAL_GetWeightedItemFromGroup( "ai_loot_drop_health_small" )
				}
				LootThrowData throwData
				throwData.throwAngle = RandomFloat( 360 )
				throwData.throwScale = 1
				vector throwOrigin = npc.GetOrigin()

				int countPerDrop = int( floor( SURVIVAL_Loot_GetLootDataByRef( itemRef ).countPerDrop ) )
				entity itemEnt = SpawnGenericLoot( itemRef, throwOrigin, < -1, -1, -1 >, countPerDrop )

				vector throwDir = <sin( throwData.throwAngle ), cos( throwData.throwAngle ), 0>
				float speed     = throwData.throwScale * sqrt( RandomFloatRange( 0.75, 1.0 ) ) * 150
				vector vel      = throwDir * speed
				thread FakePhysicsThrow( npc, itemEnt, <vel.x, vel.y, 200>, true )
				throwData = SURVIVAL_DropLoot_IncrementThrowAngle( throwData )
			}
		}

		if ( Time() > vars.encounterEndTime && vars.kills >= vars.waveSpawnCount)
		{
			string encounterEndSound = "SpectreShack_Scr_SpectreWaveTimeOut_Success_End"
			#if DEVELOPER
				ArmoryPrint( vars, "AUDIO TRIGGER | 'SpectreShack_Scr_SpectreWaveTimeOut_Success_End'" )
				ArmoryPrint( vars, "AUDIO TRIGGER | broadcasting audio to num players: " + string(vars.playersInsideShack.len()) )
			#endif
			foreach( entity p in GetPlayersInsideShack( vars ) )
			{
				EmitSoundOnEntityOnlyToPlayer( p, p, encounterEndSound )
			}
		}

		vars.activeSpectres.fastremovebyvalue( npc )
	} )
}

void function CombatKickoff_Thread( SkitInstance si, vector pos, vector rot, entity spawnEnt, int selectedSpawnGroup, array< entity > doors, float stagger )
{
	MyVars vars = s_siToVars[si]
	wait stagger
	entity npc = SkNPC_SpawnNPC( si, eNPC.SPECTRE, pos, rot )
	Armory_InitSpectre( npc, si, spawnEnt, selectedSpawnGroup )
	thread PlayAnim(npc, "spectre_shack_closet_kick", null, null, 0)
	thread SpectreKickDoor_Thread( npc, doors )
}

void function SpectreKickDoor_Thread( entity npc, array< entity > doors )
{
	wait 1.65

	if( !IsValid( npc ) )
		return

	if( doors.len() > 0 )
	{
		foreach ( entity e in doors )
		{
			if( IsValid( e ) )
			{
				e.Destroy()
			}
		}
	}
	//vector doorPoint = CalcLocalToWorldOrigin_Entity( npc, <20, 0, 40> )
	//entity doorBreakVfx_end = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( ARMORY_DOOR_DESTRUCTION_FX ), doorPoint, npc.GetAngles() - <0,0,180> )
	//thread DestroyFXAfterDelay_Thread( doorBreakVfx_end, DOOR_DESTRUCTION_FX_LIFETIME )
	EmitSoundOnEntity( npc, "Door_Impact_Break_SpectreClosets" )
}

// ████████╗██████╗ ██╗ ██████╗  ██████╗ ███████╗██████╗
// ╚══██╔══╝██╔══██╗██║██╔════╝ ██╔════╝ ██╔════╝██╔══██╗
//    ██║   ██████╔╝██║██║  ███╗██║  ███╗█████╗  ██████╔╝
//    ██║   ██╔══██╗██║██║   ██║██║   ██║██╔══╝  ██╔══██╗
//    ██║   ██║  ██║██║╚██████╔╝╚██████╔╝███████╗██║  ██║
//    ╚═╝   ╚═╝  ╚═╝╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝

bool function IsPlayerOnTeamInArmory ( entity player, SkitInstance si )
{
	if( !IsValid( player ) )
	{
		return false
	}

	MyVars vars = s_siToVars[si]

	int teamInt = player.GetTeam()
	if( teamInt == vars.teamIndex )
	{
		return true
	}
	return false
}

bool function TestTeamIsInsideTrigger( int teamIndex, array< entity > playersInsideTrigger )
{
	array< entity > squadMates = GetPlayerArrayOfTeam_Alive( teamIndex )

	foreach( entity e in squadMates)
	{
		if( playersInsideTrigger.contains( e ) == false )
		{
			return false
		}
	}
	return true
}

bool function TestEntireTeamIsOutsideTrigger( entity player, SkitInstance si )
{
	if( !IsValid( player ) )
	{
		return false
	}

	MyVars vars = s_siToVars[si]
	int teamInt = player.GetTeam()

	array< entity > squadMates = GetPlayerArrayOfTeam_Alive( teamInt )

	foreach( entity e in squadMates)
	{
		if( GetPlayersInsideShack( vars ).contains( e ) )
		{
			return false
		}
	}
	return true
}

// ████████╗███████╗██╗     ███████╗██████╗  ██████╗ ██████╗ ████████╗███████╗██████╗
// ╚══██╔══╝██╔════╝██║     ██╔════╝██╔══██╗██╔═══██╗██╔══██╗╚══██╔══╝██╔════╝██╔══██╗
//    ██║   █████╗  ██║     █████╗  ██████╔╝██║   ██║██████╔╝   ██║   █████╗  ██████╔╝
//    ██║   ██╔══╝  ██║     ██╔══╝  ██╔═══╝ ██║   ██║██╔══██╗   ██║   ██╔══╝  ██╔══██╗
//    ██║   ███████╗███████╗███████╗██║     ╚██████╔╝██║  ██║   ██║   ███████╗██║  ██║
//    ╚═╝   ╚══════╝╚══════╝╚══════╝╚═╝      ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═╝


void function Thread_ManageEntryTeleporter_Delayed( SkitInstance si, int teamIndex )
{
	// wait for the entry ramp to close
	wait( 5.0 )
	ManageEntryTeleporter( si, teamIndex )
}

void function ManageEntryTeleporter( SkitInstance si, int teamIndex )
{
	MyVars vars = s_siToVars[si]
	vars.fullTeamIsInside = TestTeamIsInsideTrigger( teamIndex, vars.playersInsideShack )

	if( vars.fullTeamIsInside )
	{
		return
	}

	if ( GetCurrentPlaylistVarBool( "armory_disable_teleporter", false ) )
	{
		return
	}

	if( IsValid( vars.entryTeleportEntryPoint ) )
	{
		array< entity > squadmatesAlive = GetPlayerArrayOfTeam_Alive( teamIndex )
		// create teammate teleport point
		vars.teleporter = CreateEntity( "trigger_cylinder" )
		if( squadmatesAlive.len() > 0 )
		{
			vars.teleporter.SetOwner( squadmatesAlive[0] )
		}
		vars.teleporter.SetCylinderRadius( 32.0 )
		vars.teleporter.SetAboveHeight( 72.0 )
		vars.teleporter.SetBelowHeight( 32.0 )
		vars.teleporter.SetOrigin( vars.entryTeleportEntryPoint.GetOrigin() )
		vars.teleporter.SetAngles( <0, 0, 0> )

		vars.teleporter.SetEnterCallback( EntryTeleporter_OnTriggerEnter )

		vars.teleporter.kv.triggerFilterNpc = "none"
		vars.teleporter.kv.triggerFilterPlayer = "all"
		vars.teleporter.kv.triggerFilterNonCharacter = 0
		vars.teleporter.kv.triggerFilterTeamOther = 1 // this is key for survival
		SetTeam( vars.teleporter, teamIndex )

		DispatchSpawn( vars.teleporter )
		entity teleporterFX = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( SPECTRE_SHACK_TELEPORTER_FX ), vars.entryTeleportEntryPoint.GetOrigin(), vars.entryTeleportEntryPoint.GetAngles() )
		EmitSoundOnEntity(teleporterFX, "SpectreShack_Scr_TelporterBeam_Idle_Loop")
		EffectSetControlPointVector( teleporterFX, 1, vars.entryTeleportEntryPoint.GetOrigin() + <0, 0, 84> )
		EffectSetControlPointVector( teleporterFX, 0, vars.entryTeleportEntryPoint.GetOrigin() + <0, 0, -56> )

		teleportTriggerToSkitLookup[vars.teleporter] <- si

		thread Thread_Remove_Entry_Teleporter( si, teleporterFX )
	}
}

void function Manage_Skydive_Launcher_Thread( SkitInstance si )
{
	if ( GetCurrentPlaylistVarBool( "armory_disable_skydive_launcher", false ) )
	{
		return
	}

	MyVars vars = s_siToVars[si]

	ArmoryPrint( vars, "Calling Manage_Skydive_Launcher_Thread", false )

	if( vars.skydiveLauncherThreadCalled )
	{
		Assert( false, "IMC Armory - Skydive launcher thread called twice!!" )
		return
	}
	vars.skydiveLauncherThreadCalled = true

	if( vars.fullTeamHasEscaped )
	{
		return
	}

	if( IsValid( vars.skydiveLauncherSpawnPoint ) )
	{
		vars.skydiveLauncherMover = CreateScriptMoverModel( MODEL_SKYDIVE_LAUNCHER_GRAVITY_MINI, vars.skydiveLauncherSpawnPoint.GetOrigin() - <0,0,14>, vars.skydiveLauncherSpawnPoint.GetAngles(), SOLID_VPHYSICS, 2000 )
		vars.skydiveLauncherMover.SetScriptName( "ArmorySkydiveLauncherMover" )

		Assert( IsValid(vars.skydiveLauncherMover), "IMC Armory - Skydive launch invalid after spawn!" )

		entity floorHatch = vars.skydiveLauncherSpawnPoint.GetLinkEnt()
		entity floorHatchMover

		if( IsValid( floorHatch ) )
		{
			floorHatchMover = CreateScriptMover( SPECTRE_SHACK_SKIT_MOVER_SCRIPTNAME + "__floorHatchMover", floorHatch.GetOrigin(), floorHatch.GetAngles() )
			floorHatch.SetParent( floorHatchMover )
			//vector destination = CalcLocalToWorldOrigin_Entity( floorHatchMover, < 96, 0, 0 > )
			//floorHatchMover.NonPhysicsMoveTo( destination, 2.0, 0.25, 1.5 )
			EmitSoundOnEntity( floorHatch, "SpectreShack_Scr_MiniGravityLauncher_Open" )
			wait 1.8
			floorHatch.ClearParent()
			floorHatchMover.Destroy()
		}

		if ( IsValid(vars.skydiveLauncherMover) )
		{
			vars.skydiveLauncherMover.NonPhysicsMoveTo( vars.skydiveLauncherSpawnPoint.GetOrigin(), 1.25, 0.25, 1.0 )
		}

		wait 1.25

		if ( IsValid(vars.skydiveLauncherMover) )
		{
			vars.skydiveLauncherMover.Destroy()
		}

		vars.skydiveLauncher = CreateSkydiveLauncher( vars.skydiveLauncherSpawnPoint.GetOrigin(), vars.skydiveLauncherSpawnPoint.GetAngles(), eSkydiveLauncherType.IMC_ARMORY, 2500, 20 )
		vars.skydiveLauncher.SetFadeDistance( 7000 )

		if( IsValid( vars.skydiveLauncher ) )
		{
			while( vars.fullTeamHasEscaped == false )
			{
				WaitFrame()
			}
			vars.skydiveLauncher.Destroy()
			vars.skydiveLauncherMover = CreateScriptMoverModel( MODEL_SKYDIVE_LAUNCHER_GRAVITY_MINI, vars.skydiveLauncherSpawnPoint.GetOrigin() - <0,0,0>, vars.skydiveLauncherSpawnPoint.GetAngles(), SOLID_VPHYSICS, 2000 )
			if ( IsValid(vars.skydiveLauncherMover) )
			{
				EmitSoundOnEntity( vars.skydiveLauncherMover, "SpectreShack_Scr_MiniGravityLauncher_Close" )
				vars.skydiveLauncherMover.SetFadeDistance( 7000 )
				vars.skydiveLauncherMover.NonPhysicsMoveTo( vars.skydiveLauncherSpawnPoint.GetOrigin() - <0, 0, 14>, 1.25, 0.25, 1.0 )
			}
			else
			{
				Assert( IsValid(vars.skydiveLauncherMover), "IMC Armory - Skydive launch invalid after spawn 2!" )
			}

			wait 1.25

			if( IsValid( floorHatch ) )
			{
				floorHatchMover = CreateScriptMover( SPECTRE_SHACK_SKIT_MOVER_SCRIPTNAME + "__floorHatchMover", floorHatch.GetOrigin(), floorHatch.GetAngles() )
				floorHatch.SetParent( floorHatchMover )
				//vector destination = CalcLocalToWorldOrigin_Entity( floorHatchMover, < -96, 0, 0 > )
				//floorHatchMover.NonPhysicsMoveTo( destination, 2.0, 0.25, 1.5 )
				wait 1.8
				floorHatch.ClearParent()
				floorHatchMover.Destroy()
				if( IsValid( vars.skydiveLauncherMover ) )
				{
					vars.skydiveLauncherMover.Destroy()
				}
			}

			if ( IsValid( vars.skydiveLauncherSpawnPoint ) )
			{
				vars.skydiveLauncherSpawnPoint.Destroy()
			}
		}
	}
}

void function AbortEncounter( SkitInstance si )
{
	MyVars vars = s_siToVars[si]
	vars.spectreShackState = eSpectreShackState.Aborted
	vars.encounterEndTime = Time()
	vars.kills = vars.waveSpawnCount

	vars.controlPanel.UnsetUsable()

	DisableActiveSpectres( si )
	// stop the music
	#if DEVELOPER
		ArmoryPrint( vars, "AUDIO TRIGGER | Stopping music to num players: " + string(vars.playersInsideShack.len()) )
	#endif

	foreach( entity p in GetPlayersInsideShack( vars ) )
	{
		if( IsValid ( p ) )
		{
			FadeOutSoundOnEntity( p, ARMORY_MUSIC_TRACK, 3.0 )
		}
	}

	// Remove minimap icon
	foreach ( player in GetPlayerArray() )
	{
		vars.minimapEnt.Minimap_Hide ( 0, player )
	}
}

void function DisableActiveSpectres( SkitInstance si )
{
	MyVars vars = s_siToVars[ si ]
	array< entity > killSpectres = clone vars.activeSpectres

	ArmoryPrint( vars, "found " + killSpectres.len() + " spectres in the array" )
	foreach( entity spectre in killSpectres )
	{
		if( IsValid( spectre ) )
		{
			spectre.Die()
		}
	}
}
#endif // SERVER

// SkitInstance is Server only
#if SERVER
void function ControlPanel_SpectreShack_OnUse_Server( SkitInstance si, entity player )
{
	if ( player.GetParent() != null )
	{
		//If the player is parented to something, do nothing, you can't interact
		return
	}

	MyVars vars = s_siToVars[si]
	if( IsValid( vars.controlPanel ) )
	{
		switch ( vars.spectreShackState )
		{
			case eSpectreShackState.Dormant:
				vars.controlPanel.UnsetUsable()
				PlayBattleChatterLineToSpeakerAndTeam( player, "bc_hackingArmory" )
				vars.currentRuiState = UIeSpectreShackState.ScanningPlayersStart
				foreach( entity wp in vars.ruiWaypoints)
				{
					wp.SetWaypointInt( CONTROLSCREEN_MASTER_STATE_INDEX, vars.currentRuiState )
					wp.SetWaypointInt( CONTROLSCREEN_TEAM_INDEX, vars.teamIndex )
				}
				thread ArmoryHackAnim_Thread( si, player )

				break
			case eSpectreShackState.Activated:
				vars.controlPanel.UnsetUsable()
				vars.spectreShackState = eSpectreShackState.Aborted

				AbortEncounter( si )

				OpenLoadingHatch( si, 1.0 )
				OpenRoof( si, 0.1 )

				thread Manage_Skydive_Launcher_Thread( si )

				foreach( entity wp in vars.ruiWaypoints)
				{
					wp.SetWaypointInt ( CONTROLSCREEN_COMBATSTATE_INDEX, 0 )
				}

				EmitSoundAtPosition( TEAM_ANY, vars.sfx_powerDown.GetOrigin(), "SpectreShack_Scr_UI_EmergencyShutdown", vars.sfx_powerDown )
				EmitSoundAtPosition( TEAM_ANY, vars.sfx_powerDown.GetOrigin(), "SpectreShack_Scr_EmergencyShutdown_PowerDown", vars.sfx_powerDown )

				array< string > voLines = [ "diag_ap_aiNotify_armoryWaveEscape_01_01", "diag_ap_aiNotify_armoryWaveEscape_02_01" ]
				#if DEVELOPER
					ArmoryPrint( vars, "ARMORY AUDIO TRIGGER | 'diag_ap_aiNotify_armoryWaveEscape_01_01'" )
					ArmoryPrint( vars, "ARMORY AUDIO TRIGGER | broadcasting audio to num players: " + string(vars.playersInsideShack.len()) )
				#endif
				string line = voLines.getrandom()

				foreach( entity p in GetPlayersInsideShack( vars ) )
				{
					EmitSoundOnEntityOnlyToPlayer( p, p, line )
					EmitSoundOnEntityOnlyToPlayer( p, p, "SpectreShack_Scr_SpectreWaveEmergencyExit_End" )
				}

				//PIN_Interact_Armory_Complete( player, "spectre_shack_complete", "aborted", CreateArmoryInts( vars ), [], vars.controlPanel.GetInstanceName(), player.GetOrigin() )

				break
			case eSpectreShackState.Completed:
				TransitionCompletedToDeactivated( si )
				//PIN_Interact_Armory_Complete( player, "spectre_shack_complete", "completed", CreateArmoryInts( vars ), vars.lootAwarded, vars.controlPanel.GetInstanceName(), player.GetOrigin() )
				break
			case eSpectreShackState.Deactivated:
			case eSpectreShackState.Aborted:
				break
		}
	}
}

void function TransitionCompletedToDeactivated( SkitInstance si )
{
	MyVars vars = s_siToVars[si]

	vars.controlPanel.UnsetUsable()
	vars.spectreShackState = eSpectreShackState.Deactivated
	vars.currentRuiState = UIeSpectreShackState.Deactivated
	Signal( vars.controlPanel, ON_EXIT_AFTER_COMPLETION_SIGNAL_KEYWORD )

	foreach ( entity wp in vars.ruiWaypoints )
	{
		wp.SetWaypointInt( CONTROLSCREEN_MASTER_STATE_INDEX, vars.currentRuiState )
	}

	EmitSoundAtPosition( TEAM_ANY, vars.sfx_powerDown.GetOrigin(), "SpectreShack_Scr_UI_Exit", vars.sfx_powerDown )
	EmitSoundAtPosition( TEAM_ANY, vars.sfx_powerDown.GetOrigin(), "SpectreShack_Scr_Exit_PowerDown", vars.sfx_powerDown )

	DisableActiveSpectres( si )

	OpenLoadingHatch( si, 1.0 )
	OpenRoof( si, 0.1 )

	thread Manage_Skydive_Launcher_Thread( si )

	array< string > voLines = [ "diag_ap_aiNotify_armoryExit_01_01", "diag_ap_aiNotify_armoryExit_02_01" ]
	#if DEVELOPER
		ArmoryPrint( vars, "ARMORY AUDIO TRIGGER | 'diag_ap_aiNotify_armoryExit_01_01'" )
		ArmoryPrint( vars, "ARMORY AUDIO TRIGGER | broadcasting audio to num players: " + string(vars.playersInsideShack.len()) )
	#endif
	string line = voLines.getrandom()

	foreach ( entity p in GetPlayersInsideShack( vars ) )
	{
		EmitSoundOnEntityOnlyToPlayer( p, p, line )
	}
}

void function LootbinAnimation_SFX_Thread( SkitInstance si )
{
	float staggerTime = 40.0 / 60.0
	MyVars vars = s_siToVars[si]
	wait 1.5
	for( int i = 0; i < vars.currentWave; i++ )
	{
		#if DEVELOPER
			ArmoryPrint( vars, "ARMORY AUDIO TRIGGER | 'SpectreShack_Scr_UIUX_CargoCount_Won'" )
			ArmoryPrint( vars, "ARMORY AUDIO TRIGGER | broadcasting audio to num players: " + string(vars.playersInsideShack.len()) )
		#endif
		foreach ( entity p in GetPlayersInsideShack( vars ) )
		{
			foreach (entity e in vars.ruiOrigins)
			{
				EmitSoundAtPositionOnlyToPlayer( TEAM_ANY, e.GetOrigin(), p, "SpectreShack_Scr_UIUX_CargoCount_Won" )
			}
		}
		wait ( staggerTime )
	}
}

table< string, int > function CreateArmoryInts( MyVars vars )
{
	table<string, int> armoryInts
	armoryInts["wave"] <- vars.currentWave
	armoryInts["spectresKilled"] <- vars.cumulativeKills
	armoryInts["damageToSpectres"] <- vars.cumulativeDamageToSpectres
	armoryInts["damageTaken"] <- vars.cumulativeDamageToPlayers
	return armoryInts
}

void function ArmoryHackAnim_Thread( SkitInstance si, entity player )
{
	int teamIndex = player.GetTeam()

	MyVars vars = s_siToVars[si]
	ArmoryPrint( vars, "hacking started by player " + player.GetPlayerName(), false )

	Assert( vars.playersInsideShack.contains(player), "Spectre Shacks, player hacking the armory isn't inside the shack!")

	HackPanelAnims animData = GetPanelHackingAnims( vars.controlPanel )
	FirstPersonSequenceStruct playerSequence
	playerSequence.attachment = "ref"
	playerSequence.thirdPersonAnim = animData.playerAnimation3pStart
	playerSequence.firstPersonAnim = animData.playerAnimation1pStart
	playerSequence.prediction = true

	player.SetAnimNearZ( 1 )

	if ( player.GetParent() != null )
	{
		entity parentEntity = player.GetParent()

		//if ( IsValid(parentEntity) && parentEntity.IsHoverVehicle() )
		{
			//Vehicle_KickPlayer_ForOtherReason( player )
		}
		//else
		{
			player.ClearParent()
		}
	}

	PlayParentedFirstAndThirdPersonAnimation( player, vars.controlPanel, playerSequence.attachment, playerSequence.firstPersonAnim, playerSequence.thirdPersonAnim )

	wait 2.15
	if( IsValid( vars.sfx_powerUp ) )
	{
		EmitSoundAtPosition( TEAM_ANY, vars.sfx_powerUp.GetOrigin(), vars.sfx_powerUp.GetScriptName(), vars.sfx_powerUp )
	}
	thread CloseLoadingHatch( si )

	thread Armory_CryptoFlash_Thread( si )

	if( IsValid( player ) )
	{
		//PIN_Interact_Armory_Activate( player, "spectre_shack_activate", vars.controlPanel.GetInstanceName(), player.GetOrigin() )
		if ( IsAlive( player ) )
		{
			waitthread WaittillAnimDone( player )
		}
	}
	else
	{
		ArmoryPrint( vars, "Kicking off spectreshack with the hacking player being invalid", false )
	}

	if ( GetPlayersInsideShack( vars ).len() == 0)
	{
		#if DEVELOPER
			ArmoryPrint(vars, "Players died during startup, aborting skit", false)
		#endif
		OpenLoadingHatch( si )
		vars.currentRuiState = UIeSpectreShackState.Dormant
		Assert( vars.spectreShackState == eSpectreShackState.Dormant, "Spectreshack is already out of dormant state before hack success" )
		foreach( entity wp in vars.ruiWaypoints)
		{
			wp.SetWaypointInt( CONTROLSCREEN_MASTER_STATE_INDEX, vars.currentRuiState )
		}
		vars.controlPanel.SetUsable()
	}
	else
	{
		ArmoryHack_Success( si, teamIndex )
	}
}

void function Armory_CryptoFlash_Thread( SkitInstance si )
{
	wait 2.3

	MyVars vars = s_siToVars[si]

	if( IsValid( vars.scanVfxInfoTarget ) )
	{
		EmitSoundAtPosition( TEAM_ANY, vars.scanVfxInfoTarget.GetOrigin(), "SpectreShack_Scr_Hacking_FlashScreen", vars.scanVfxInfoTarget)
	}

	int loops = 7
	for( int i = 0; i < loops; i++ )
	{
		vars.controlPanel.SetSkin( vars.controlPanel.GetSkinIndexByName( "screen_crypto" ) )
		wait 0.24
		vars.controlPanel.SetSkin( 0 )
		wait 0.24
	}
}

void function ArmoryHack_Success( SkitInstance si, int teamIndex )
{
	MyVars vars = s_siToVars[si]

	vars.spectreShackState = eSpectreShackState.Activated
	vars.teamIndex = teamIndex
	foreach( entity wp in vars.ruiWaypoints)
	{
		wp.SetWaypointInt( CONTROLSCREEN_TEAM_INDEX, vars.teamIndex )
	}

	// try to workaround trigger inconsistency issue
	vars.interiorTriggerVolume.SearchForNewTouchingEntity()

	LaunchSkit_SpectreShack_V4( si )

	ArmoryPrint( vars, "hacking done" )

	thread Thread_ManageEntryTeleporter_Delayed( si, teamIndex )
	thread Thread_ControlPanel_OnStateChange( si, vars.spectreShackState )

	array< string > voLines = [ "diag_ap_aiNotify_armoryActivated_01_01", "diag_ap_aiNotify_armoryActivated_02_01" ]
	#if DEVELOPER
		ArmoryPrint( vars, "AUDIO TRIGGER | 'diag_ap_aiNotify_armoryActivated_01_01'" )
		ArmoryPrint( vars, "AUDIO TRIGGER | broadcasting audio to num players: " + string( vars.playersInsideShack.len()) )
	#endif
	string line = voLines.getrandom()
	foreach( entity p in GetPlayersInsideShack( vars ) )
	{
		EmitSoundOnEntityOnlyToPlayer( p, p, line )
	}
}

void function RoofForcePush_Thread( SkitInstance si )
{
	MyVars vars = s_siToVars[si]

	if ( vars.roofElectricTriggerOrigins.len() == 0 || vars.roofElectricTriggerOrigins_Center.len() == 0 )
		return

	if ( vars.roofElectricOrigin == <0,0,0> )
		return

	entity roofElectricVFX = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( ARMORY_ELECTRIC_ROOF_FX ), vars.roofElectricOrigin, vars.roofElectricAngles )
	roofElectricVFX.SetFadeDistance( ARMORY_ELECTRIC_VFX_FADE_DISTANCE )
	vars.roofElectricVFX_Center = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( ARMORY_ELECTRIC_ROOF_CENTER_FX ), vars.roofElectricOrigin, vars.roofElectricAngles )
	vars.roofElectricVFX_Center.SetFadeDistance( ARMORY_ELECTRIC_VFX_FADE_DISTANCE )

	foreach( e in vars.roofElectricTriggerOrigins )
	{
		entity ornull rt = CreateRoofTrigger( e, si )
		if( IsValid( rt ))
		{
			expect entity ( rt )
			vars.roofElectricTriggers_Sides.append( rt )
		}
	}
	foreach( e in vars.roofElectricTriggerOrigins_Center )
	{
		entity ornull rt = CreateRoofTrigger( e, si )
		if( IsValid( rt ))
		{
			expect entity ( rt )
			vars.roofElectricTriggers_Center.append( rt )
		}
	}

	if( IsValid( roofElectricVFX ) )
	{
		EmitSoundOnEntity( roofElectricVFX, "Spectreshack_ElectricRoof_Idle" )
	}

	OnThreadEnd(
		function() : ( roofElectricVFX, si )
		{
			MyVars vars = s_siToVars[si]
			EffectStop( roofElectricVFX )
			StopSoundOnEntity( roofElectricVFX, "Spectreshack_ElectricRoof_Idle" )
			foreach( e in vars.roofElectricTriggers_Sides )
			{
				if( IsValid( e ) )
				{
					e.Destroy()
				}
			}
		}
	)

	while( vars.fullTeamHasEscaped == false )
	{
		WaitFrame()
	}

	wait 3.0
}

entity ornull function CreateRoofTrigger( entity originEnt, SkitInstance si )
{
	entity roofTrigger = CreateEntity( "trigger_cylinder" )
	roofTrigger.SetCylinderRadius( 270.0 )
	roofTrigger.SetAboveHeight( 10.0 )
	roofTrigger.SetBelowHeight( 30.0 )
	roofTrigger.SetOrigin( originEnt.GetOrigin() )
	roofTrigger.SetAngles( originEnt.GetAngles() )

	roofTrigger.SetEnterCallback( void function ( entity trigger, entity ent ) : ( si )
	{
		#if DEVELOPER
			printf( "Armory_OnRoofTriggerEnter" )
		#endif
		if( !IsValid( ent ) )
			return

		if( !ent.IsPlayer() )
			return

		thread OnBoopTriggerEnter_Thread( trigger, ent, si )
	} )

	roofTrigger.kv.triggerFilterNpc = "none"
	roofTrigger.kv.triggerFilterPlayer = "all"
	roofTrigger.kv.triggerFilterNonCharacter = 0

	DispatchSpawn( roofTrigger )
	roofTrigger.SearchForNewTouchingEntity()

	return roofTrigger
}

void function OnBoopTriggerEnter_Thread( entity trigger, entity ent, SkitInstance si )
{
	MyVars vars = s_siToVars[si]

	if ( ent in vars.playerLastBoopTime )
	{
		float boopWindow = Time() - ( vars.electricBoopInterval * 0.9 )
		if ( vars.playerLastBoopTime[ent] > boopWindow )
		{
			thread ProcessBoopedPlayer_Thread( ent, trigger, si )
			return
		}

		vars.playerLastBoopTime[ent] = Time()
	}
	else
	{
		vars.playerLastBoopTime[ent] <- Time()
	}

	while ( ent.Player_IsSkydiving() )
	{
		WaitFrame()
	}

	if ( !IsValid( ent ) || !IsValid( trigger ) )
	{
		return
	}

	array<entity> touchingEnts = trigger.GetTouchingEntities()
	if ( !touchingEnts.contains( ent ) )
	{
		return
	}

	vector boopOrigin = vars.roofElectricOrigin
	vector boopDirection = ent.GetOrigin() - boopOrigin
	// flatten the push direction vector
	boopDirection.z = 0
	boopDirection = Normalize( boopDirection )
	// give the boop a constant upward velocity
	boopDirection.z = 1.0
	#if DEVELOPER
		bool drawDebugs = false
		if ( drawDebugs )
		{
			//DebugDrawMark( boopOrigin, 50, COLOR_BLUE, true, 30.0 )
			DebugDrawLine( boopOrigin, boopOrigin + (boopDirection * 100), int(COLOR_WHITE.x), int(COLOR_WHITE.y), int(COLOR_WHITE.z), true, 30.0 )
		}
	#endif // DEV
	float boopForce = 600.0
	ent.KnockBack( boopDirection * boopForce, 0.02 )

	EmitSoundOnEntityOnlyToPlayer( ent, ent, "Spectreshack_ElectricRoof_Damage_1p" )
	EmitSoundOnEntityExceptToPlayer( ent, ent, "Spectreshack_ElectricRoof_Damage_3p" )

	StatusEffect_AddTimed( ent, eStatusEffect.castle_wall_emp, 1.0, 2.5, 0.2 )
	StatusEffect_AddTimed( ent, eStatusEffect.emp, 1.0, 2.5, 0.2 )
	StatusEffect_AddTimed( ent, eStatusEffect.move_slow, 0.5, 2.5, 1 )

	thread ProcessBoopedPlayer_Thread( ent, trigger, si )
}

void function ProcessBoopedPlayer_Thread( entity player, entity trigger, SkitInstance si )
{
	MyVars vars = s_siToVars[si]

	wait vars.electricBoopInterval

	if ( IsValid(player) && IsValid( trigger ) )
	{
		array<entity> touchingEnts = trigger.GetTouchingEntities()
		if ( touchingEnts.contains( player ) )
		{
			thread OnBoopTriggerEnter_Thread( trigger, player, si )
		}
	}
}

void function OpenRoof( SkitInstance si, float delayTime = 0.0)
{
	thread OpenRoofInternal_Thread( si, delayTime )
}
void function OpenRoofInternal_Thread( SkitInstance si, float delayTime )
{
	MyVars vars = s_siToVars[si]
	wait delayTime

	foreach( entity roofPiece in vars.roof_Rig )
	{
		if( IsValid( roofPiece ) )
		{
			thread PlayAnimOnly( roofPiece, "spectre_shack_roof_open" )
		}
	}

	wait 0.8

	if( IsValid( vars.roofElectricVFX_Center ) )
	{
		EffectStop( vars.roofElectricVFX_Center )
	}

	foreach( e in vars.roofElectricTriggers_Center )
	{
		if( IsValid( e ) )
		{
			e.Destroy()
		}
	}

	wait 3.0

	if( IsValid( vars.roofElectricVFX_Center ) )
	{
		vars.roofElectricVFX_Center.Destroy()
	}
}

void function CloseLoadingHatch( SkitInstance si )
{
	MyVars vars = s_siToVars[si]

	EmitSoundOnEntity( vars.entryHatch_Rig, "SpectreShack_Scr_Ramp_Close" )
	thread PlayAnimOnly( vars.entryHatch_Rig, "spectre_shack_door_close" )

	// kick off checking for intersection on placeable props childed to ramp for duration of animation
	bool destroyImmediately = false
	entity target = null
	array<entity> bone_followers = vars.entryHatch_Rig.GetChildren()
	foreach ( string abilityName in DEPLOYABLE_ABILITY_NAMES)
	{
		foreach ( entity bone_follower in bone_followers )
		{
			array<entity> children = bone_follower.GetChildren()
			foreach ( entity child in children )
			{
				target = FindScriptNameInChildren( child, abilityName )
				if ( target != null )
				{
					if ( !destroyImmediately )
					{
						thread Thread_CheckForGeoIntersection( target, bone_follower )
					}

					else
						DeactivateDeployableAbility ( target )
				}
			}
		}
	}

	// stop checking for intersection on end of closing animation
	waitthread WaittillAnimDone( vars.entryHatch_Rig )
	vars.entryHatch_Rig.Signal( "StopCheckingForIntersectingGeo" )
}

void function OpenLoadingHatch( SkitInstance si, float delayTime = 0.0)
{
	thread OpenLoadingHatchInternal_Thread( si, delayTime )
}

void function OpenLoadingHatchInternal_Thread( SkitInstance si, float delayTime )
{
	MyVars vars = s_siToVars[si]

	wait delayTime

	EmitSoundOnEntity( vars.entryHatch_Rig , "SpectreShack_Scr_Ramp_Open" )
	thread PlayAnimOnly( vars.entryHatch_Rig, "spectre_shack_door_open" )

	entity dustVfx_ent = null
	if ( IsValid( vars.dustVfxSpawnPoint ) )
	{
		dustVfx_ent = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( HATCH_OPEN_DUST_FX ), vars.dustVfxSpawnPoint.GetOrigin(), vars.dustVfxSpawnPoint.GetAngles() )
		vars.dustVfxSpawnPoint.Destroy()
	}
	// open the ramp
	thread CrushPrevention_Thread( si )

	if( IsValid( dustVfx_ent ) )
	{
		thread DestroyFXAfterDelay_Thread( dustVfx_ent, DUST_FX_LIFETIME )
	}
}

#if DEVELOPER
void function DEV_Armory_DestroyDeployablesOnRamps ()
{
	// destroy the deployables on all ramps
	foreach ( si, vars in s_siToVars )
	{
		foreach ( entity mover in vars.entryHatch_Rig.GetChildren() )
		{
			entity target
			foreach ( string abilityName in DEPLOYABLE_ABILITY_NAMES)
			{
				target = FindScriptNameInChildren( mover, abilityName )
				if ( target != null )
				{
					printt ( "Armory - Debug destroying deployables on: " + mover.GetScriptName() )
					// Instead of destroying, here's where you'd spawn a thread to check for intersecting geo every 0.1 sec until the ramp anim end
					DeactivateDeployableAbility ( target )
					break
				}
			}
		}
	}
	printt ( "Armory - Didn't find any ramps with children" )
}
#endif // DEV

void function CrushPrevention_Thread ( SkitInstance si )
{
	MyVars vars = s_siToVars[si]

	//vars.entryHatch_Rig.SetNeverCrush( true )

	foreach( entity ent in vars.entryHatch_Rig.GetChildren() )
	{
	//	ent.SetNeverCrush( true )
	}

	wait 8.0

	foreach( entity ent in vars.entryHatch_Rig.GetChildren() )
	{
	//	ent.SetNeverCrush( false )
	}

	//vars.entryHatch_Rig.SetNeverCrush( false )
}

// move to trigger header
void function EntryTeleporter_OnTriggerEnter( entity trigger, entity ent )
{
	if( ent.IsPlayer() )
	{
		SkitInstance si = teleportTriggerToSkitLookup[trigger]
		if( IsPlayerOnTeamInArmory ( ent, si ) )
		{
			MyVars vars = s_siToVars[si]
			ArmoryPrint( vars, "a player entered the teleporter at " + string( Time() ) )
			if( !vars.playersTeleporting.contains( ent ) )
			{
				vars.playersTeleporting.append( ent )
				thread Thread_Entry_Teleport_Player( si, ent )
			}
		}
		else
		{
			ArmoryPrint( null, "a player entered the teleporter but the skit instance was not valid!", false )
		}
	}
}

void function Thread_Remove_Entry_Teleporter( SkitInstance si, entity fxEnt )
{
	MyVars vars = s_siToVars[si]

	while( vars.fullTeamIsInside == false && vars.spectreShackState == eSpectreShackState.Activated)
	{
		WaitFrame()
	}

	if( IsValid( vars.teleporter ) )
	{
		vars.teleporter.Destroy()
	}

	if( IsValid( fxEnt ) )
	{
		fxEnt.Destroy()
	}
}

void function Thread_Entry_Teleport_Player( SkitInstance si, entity player )
{
	MyVars vars = s_siToVars[si]

	// Start the teleport sound early, for build up
	EmitSoundOnEntityOnlyToPlayer( player, player, "SpectreShack_Scr_TeleporterBeam_WarpIn_1p" )
	EmitSoundAtPositionExceptToPlayer( TEAM_ANY, player.GetOrigin(), player, "SpectreShack_Scr_TeleporterBeam_WarpIn_3p" )

	// Wait a short time before teleporting the player.
	float plantTime = Time()
	float delay     = 0.1

	// Play some screen FX just before teleport
	StatusEffect_AddTimed( player, eStatusEffect.translocation_visual_effect, 1.0, GetCurrentPlaylistVarFloat( "loba_tactical_screen_fx_duration", 1.0 ), 0.0 )

	// Wait the rest of the time
	while ( Time() < plantTime + delay )
	{
		WaitFrame()
	}

	if ( !IsValid(player) )
	{
		return
	}

	// Store original position
	vector playerOrigPos = player.GetOrigin()
	vector playerOrigPos_VFX = player.GetAttachmentOrigin( player.LookupAttachment( "CHESTFOCUS" ))
	vector playerOrigAngle = player.GetAngles()
	vector playerOrigVelocity = player.GetVelocity()

	int teleportDestinationIndex = RandomInt( vars.entryTeleportExitPositions.len() )
	vector playerMaybePos = vars.entryTeleportExitPositions[ teleportDestinationIndex ]
	#if DEVELOPER
	// TODO: trace to validate this spot is ok // if they all fail, just pick one
	#endif
	vector ornull playerFinalPos = playerMaybePos

	playerFinalPos = playerMaybePos
	expect vector( playerFinalPos )


		//Vehicle_KickPlayer_ForAbility( player )


	if ( player.ContextAction_IsZipline() )
		player.Zipline_Stop()

	thread SetPlayerTeleportingFlagThread( player )

	player.SetAbsAngles( vars.entryTeleportExitAngles[ teleportDestinationIndex ] )
	player.SetVelocity( <0, 0, 0> )

	bool success = false
	success = TeleportPlayerNoInterp( player, playerFinalPos )

	if ( !success )
	{
		player.SetAbsAngles( playerOrigAngle )
		player.SetVelocity( playerOrigVelocity )
		return
	}

	vector playerFinalPos_VFX = player.GetAttachmentOrigin( player.LookupAttachment( "CHESTFOCUS" ))
	entity teleport_vfx_3p_a = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( ARMORY_TELEPORTER_3P_FX ), playerOrigPos_VFX, playerOrigAngle )
	entity teleport_vfx_3p_b = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( ARMORY_TELEPORTER_3P_FX ), playerFinalPos_VFX, vars.entryTeleportExitAngles[ teleportDestinationIndex ] )
	EmitSoundAtPositionExceptToPlayer( TEAM_ANY, playerFinalPos, player, "SpectreShack_Scr_TeleporterBeam_WarpOut_3p" )

	wait 1.5
	if( IsValid( teleport_vfx_3p_a ) )
	{
		teleport_vfx_3p_a.Destroy()
	}
	if( IsValid( teleport_vfx_3p_b ) )
	{
		teleport_vfx_3p_b.Destroy()
	}
}

void function SetPlayerTeleportingFlagThread( entity owner )
{
	OnThreadEnd( void function() : ( owner ) {
		if ( IsValid( owner ) )
		{
			//owner.EndTeleport()
		}
	} )

	//owner.StartTeleport()
	WaitFrame()
}

void function SpectreShack_RemoveRuiWaypoints( MyVars vars )
{
	ArmoryPrint( vars, "RemoveRuiWaypoints called" )

	entity parentEnt = null
	for( int i = 0; i < vars.ruiWaypoints.len(); i++ )
	{
		if ( !IsValid( vars.ruiWaypoints[i] ) )
			continue

		if ( !IsValid( parentEnt ) )
		{
			parentEnt = vars.ruiWaypoints[i].GetParent()
		}

		vars.ruiWaypoints[i].Destroy()
	}
	if ( IsValid( parentEnt ) )
	{
		parentEnt.Destroy()
		parentEnt = null
	}

	for( int i = 0; i < vars.ruiOrigins.len(); i++ )
	{
		if ( !IsValid( vars.ruiOrigins[i] ) )
			continue

		if ( !IsValid( parentEnt ) )
		{
			parentEnt = vars.ruiOrigins[i].GetParent()
		}

		vars.ruiOrigins[i].Destroy()
	}
	if ( IsValid( parentEnt ) )
	{
		parentEnt.Destroy()
	}

	vars.ruiWaypoints.clear()
	vars.ruiOrigins.clear()
}

void function SpectreShack_OnProximityTriggerEnter( entity trigger, entity ent )
{
	if ( triggerTeleportFixEnabled )
	{
		// Threading this off and doing two waitframes is gross, but required because of R5DEV-363475
		thread function () : ( trigger, ent )
		{
			WaitFrame()
			WaitFrame()

			SpectreShack_OnProximityTriggerEnter_Internal ( trigger, ent )
		}()
	}
	else
	{
		SpectreShack_OnProximityTriggerEnter_Internal ( trigger, ent )
	}
}

void function SpectreShack_OnProximityTriggerEnter_Internal ( entity trigger, entity ent )
{
	if ( !IsValid(ent) || !ent.IsPlayer() )
	{
		return
	}

	SkitInstance si = proximityTriggerToSkitLookup[trigger]
	MyVars vars     = s_siToVars[si]
	if ( !GetPlayersInsideShackProximity( vars ).contains( ent ) )
	{
		ArmoryPrint( vars, "TRIGGER ENTER - A player entered the proximity trigger" )
		vars.playersInsideProximity.append( ent )
		if ( triggerTeleportFixEnabled )
			AddEntityDestroyedCallback ( ent, SpectreShack_OnPlayerInsideProximityDestroyed )
	}
	else
	{
		ArmoryPrint( vars, "TRIGGER ENTER - Ignoring player entering proximity trigger, they're already in proximity" )
		return
	}

	if ( vars.forceShutdown == true )
	{
		return
	}

	foreach ( entity wp in vars.ruiWaypoints )
	{
		if ( !IsValid( wp ) )
			continue

		Remote_CallFunction_NonReplay( ent, "Cl_SpectreShack_OnProximityTriggerEnter", wp )
	}

	if ( vars.isSealed )
	{
		vars.isSealed = false
		thread PlayAnimOnly( vars.ceiling_Rig_Left, "spectre_shack_hatchL_idle" )
		thread PlayAnimOnly( vars.ceiling_Rig_Right, "spectre_shack_hatchR_idle" )
		OpenLoadingHatch( si )
	}
}
void function SpectreShack_OnProximityTriggerLeave( entity trigger, entity ent )
{
	if ( triggerTeleportFixEnabled )
	{
		// Threading this off and doing two waitframes is gross, but required because of R5DEV-363475
		thread function () : ( trigger, ent )
		{
			WaitFrame()
			WaitFrame()

			SpectreShack_OnProximityTriggerLeave_Internal ( trigger, ent )
		}()
	}
	else
	{
		SpectreShack_OnProximityTriggerLeave_Internal ( trigger, ent )
	}
}

void function SpectreShack_OnProximityTriggerLeave_Internal ( entity trigger, entity ent )
{
	if ( triggerTeleportFixEnabled )
	{
		if ( !IsValid(ent) && !IsInvalidButMemberVarsStillValid(ent) )
			return
	}
	else
	{
		if ( !IsValid(ent) )
			return
	}

	if ( !ent.IsPlayer() )
		return

	SkitInstance si = proximityTriggerToSkitLookup[trigger]
	MyVars vars = s_siToVars[si]

	trigger.SearchForNewTouchingEntity()
	if ( triggerTeleportFixEnabled )
	{
		if ( trigger.GetTouchingEntities().contains( ent ) )
		{
			ArmoryPrint( vars, "TRIGGER LEAVE - proxmity trigger leave ignored, player didn't really leave" )
			return
		}
		else if ( !GetPlayersInsideShackProximity(vars).contains(ent) )
		{
			ArmoryPrint( vars, "TRIGGER LEAVE - proxmity trigger leave ignored, player wasn't considered to be in the shack already" )
			return
		}
	}

	ArmoryPrint( vars, "TRIGGER LEAVE - Player left proximity" )
	vars.playersInsideProximity.fastremovebyvalue( ent )
	if (triggerTeleportFixEnabled)
		RemoveEntityDestroyedCallback ( ent, SpectreShack_OnPlayerInsideProximityDestroyed )

	foreach ( entity wp in vars.ruiWaypoints )
	{
		if ( !IsValid( wp ) )
			continue

		Remote_CallFunction_NonReplay( ent, "Cl_SpectreShack_OnProximityTriggerLeave", wp )
	}
}

void function SpectreShack_OnPlayerInsideProximityDestroyed ( entity player )
{
	Assert( !IsValid(player) && IsInvalidButMemberVarsStillValid(player), "ERROR: ON DESTROY PLAYER | called ondestroy with an entity with invalid members" )

	if ( !( player in playerToSkitLookup ) )
		return

	SkitInstance si = playerToSkitLookup[player]
	MyVars vars = s_siToVars[ si ]

	if ( IsValid(vars.proximityTrigger) )
	{
		SpectreShack_OnProximityTriggerLeave_Internal ( vars.proximityTrigger, player )
	}
}

void function Thread_ControlPanel_OnStateChange( SkitInstance si, int newState )
{
	MyVars vars = s_siToVars[si]
	if ( IsValid( vars.controlPanel ) )
	{
		switch( newState )
		{
			case eSpectreShackState.Activated:
				wait 10.0

				vars.controlPanel.SetUsePrompts( "#PROMPT_CANCEL_SPECTRESHACK", "#PROMPT_CANCEL_SPECTRESHACK" )
				vars.controlPanel.SetUsable()
				break
			case eSpectreShackState.Completed:

				vars.controlPanel.SetUsePrompts( "#PROMPT_EXIT_SPECTRESHACK", "#PROMPT_EXIT_SPECTRESHACK" )
				vars.controlPanel.SetUsable()

				//// Remove minimap icon
				foreach ( player in GetPlayerArray() )
				{
					vars.minimapEnt.Minimap_Hide ( 0, player )
				}

				break
		}
	}
}
#endif // SERVER

//////////////////////
#if SERVER
SkitInstance function InitSkit_SpectreShack_V4_Server( entity rootEnt, int skitID )
{
	SkitInstance ornull siRaw = InitThisSkit_Server( rootEnt, skitID )
	if ( siRaw == null )
	{
		Warning( "%s() - Couldn't init skit.", FUNC_NAME() )
	}

	expect SkitInstance( siRaw )
	return siRaw
}
#endif // SERVER

#if SERVER
void function LaunchSkit_SpectreShack_V4( SkitInstance si )
{
	LaunchSkit( si )
	Skit_LaunchInstance( si )
}

// launch is on triggered
void function LaunchSkit( SkitInstance si )
{
	MyVars vars = s_siToVars[si]

	vars.encounterEndTime = Time() + (7) + vars.encounterDuration
	vars.spawnWave = true

	thread ManageTimerCallouts_Thread( si )
}

void function ManageTimerCallouts_Thread( SkitInstance si )
{
	MyVars vars = s_siToVars[ si ]

	// total 35 seconds
	wait 34.75
	if( vars.spectreShackState == eSpectreShackState.Activated )
	{
		#if DEVELOPER
			ArmoryPrint( vars, "AUDIO TRIGGER | 'SpectreShack_Scr_30sec_Warning'" )
			ArmoryPrint( vars, "AUDIO TRIGGER | broadcasting audio to num players: " + string(vars.playersInsideShack.len()) )
		#endif

		foreach( entity p in GetPlayersInsideShack ( vars ) )
		{
			EmitSoundOnEntityOnlyToPlayer( p, p, "SpectreShack_Scr_30sec_Warning" )
		}
	}

	wait 0.25

	if( vars.spectreShackState == eSpectreShackState.Activated )
	{
		array< string > voLines = [ "diag_ap_aiNotify_armoryWaveEscalate30sec_01_01", "diag_ap_aiNotify_armoryWaveEscalate30sec_02_01" ]
		#if DEVELOPER
			ArmoryPrint( vars, "AUDIO TRIGGER | 'diag_ap_aiNotify_armoryWaveEscalate30sec_01_01'" )
			ArmoryPrint( vars, "AUDIO TRIGGER | broadcasting audio to num players: " + string(vars.playersInsideShack.len()) )
		#endif
		string line = voLines.getrandom()
		foreach( entity p in GetPlayersInsideShack ( vars ) )
		{
			EmitSoundOnEntityOnlyToPlayer( p, p, line )
		}
	}

	// total 20 seconds
	wait 19.75
	if( vars.spectreShackState == eSpectreShackState.Activated )
	{
		#if DEVELOPER
			ArmoryPrint( vars, "AUDIO TRIGGER | 'SpectreShack_Scr_10sec_Warning'" )
			ArmoryPrint( vars, "AUDIO TRIGGER | broadcasting audio to num players: " + string(vars.playersInsideShack.len()) )
		#endif
		foreach( entity p in GetPlayersInsideShack ( vars ) )
		{
			EmitSoundOnEntityOnlyToPlayer( p, p, "SpectreShack_Scr_10sec_Warning" )
		}
	}

	wait 0.25
	if( vars.spectreShackState == eSpectreShackState.Activated )
	{
		array< string > voLines = [ "diag_ap_aiNotify_armoryWaveEscalate10sec_01_01", "diag_ap_aiNotify_armoryWaveEscalate10sec_02_01" ]
		#if DEVELOPER
			ArmoryPrint( vars, "AUDIO TRIGGER | 'diag_ap_aiNotify_armoryWaveEscalate10sec_01_01'" )
			ArmoryPrint( vars, "AUDIO TRIGGER | broadcasting audio to num players: " + string(vars.playersInsideShack.len()) )
		#endif
		string line = voLines.getrandom()
		foreach( entity p in GetPlayersInsideShack ( vars ) )
		{
			EmitSoundOnEntityOnlyToPlayer( p, p, line )
		}
	}
}

void function AddCallback_SpectreShack_V4_OnSkitStarted( SkitInstance si, void functionref() fr )
{
	MyVars vars = s_siToVars[si]
	vars.callbacks_OnSkitStarted.append( fr )
}

void function AddCallback_SpectreShack_V4_OnSkitEnded( SkitInstance si, void functionref() fr )
{
	MyVars vars = s_siToVars[si]
	vars.callbacks_OnSkitEnded.append( fr )
}

void function FillSpectreShackLootBin( entity lootBin, array<string> lootRefs, MyVars vars )
{
	#if DEVELOPER
		ArmoryPrint( vars, "Filling armory lootbin" )

		foreach( s in lootRefs )
		{
			printf( s )
		}
	#endif
	LootBin_PutMultipleLootItemsInside( lootBin, eLootBinCompartment.REGULAR, lootRefs )
}
#endif // SERVER

#if CLIENT
void function SpectreShackControl_V4_ClientInit( entity cp )
{
	if( !IsValid( cp ) )
		return
}
#endif // CLIENT


#if SERVER || CLIENT
bool function IsSpectreShackSmartLootLocked ( entity cargoBin )
{
	return GradeFlagsHas( cargoBin, eGradeFlags.IS_LOCKED )
}

entity function GetSpectreShackSmartLootBinForLoot( entity lootEnt )
{
	entity parentEnt = lootEnt.GetParent()
	if ( IsValid(parentEnt) && parentEnt.GetScriptName() == LOOT_BIN_SCRIPTNAME )
		return parentEnt

	return null
}
#endif // SERVER || CLIENT

void function ArmoryPrint( MyVars ornull varsOrNull, string message, bool devOnly = true )
{
	string armoryString = "IMC ARMORY - "
#if SERVER
	if ( IsValid(varsOrNull) )
	{
		MyVars vars = expect MyVars(varsOrNull)
		armoryString = ("IMC ARMORY #" + vars.skitID + " - ")
	}
#endif //SERVER

	if( devOnly )
	{
		#if DEVELOPER
			printf( armoryString + message )
		#endif //DEV
	}
	else
	{
		printf( armoryString + message )
	}
}

#if DEVELOPER && SERVER
bool function DEV_SpectreShack_IsPlayerInSpectreShack(SkitInstance si, int teamIndex)
{
	if (si in s_siToVars)
	{
		MyVars vars = s_siToVars[si]
		if (vars.teamIndex == teamIndex)
		{
			return true
		}
	}
	return false
}

MyVars ornull function DEV_GetSpectreShackDataFromPlayer( entity player )
{
	SkitInstance ornull siOrNull = DEV_GetSpectreShackSkitFromPlayer(player)
	if (siOrNull)
	{
		SkitInstance si = expect SkitInstance(siOrNull)
		return s_siToVars[si]
	}
	return null
}

void function DEV_SpectreShack_PauseEncounterTimer( entity player )
{
	MyVars ornull varsOrNull = DEV_GetSpectreShackDataFromPlayer( player )

	if (!varsOrNull)
		return

	MyVars vars = expect MyVars(varsOrNull)

	vars.devTimeRemainingOnEncounter = vars.encounterEndTime - Time()
	vars.encounterEndTime = Time() + 1000000
}

void function DEV_SpectreShack_UnpauseEncounter( entity player )
{
	MyVars ornull varsOrNull = DEV_GetSpectreShackDataFromPlayer( player )

	if (!varsOrNull)
		return

	MyVars vars = expect MyVars(varsOrNull)

	vars.encounterEndTime = Time() + vars.devTimeRemainingOnEncounter
	vars.devTimeRemainingOnEncounter = -1
}

void function DEV_SpectreShack_EndEncounter ( entity player, int waveReached = 6 )
{
	SkitInstance ornull siOrNull = DEV_GetSpectreShackSkitFromPlayer(player)
	if (siOrNull)
	{
		SkitInstance si = expect SkitInstance(siOrNull)
		s_siToVars[si].currentWave = waveReached
		s_siToVars[si].encounterEndTime = Time() - 5.0
		thread function ():(si)
		{
			wait 2.0
			DisableActiveSpectres( si )
		}()
	}
}

void function DEV_SpectreShack_ForceSpawnNewWave( entity player )
{
	MyVars ornull varsOrNull = DEV_GetSpectreShackDataFromPlayer( player )

	if (!varsOrNull)
		return

	MyVars vars = expect MyVars(varsOrNull)

	array< entity > killSpectres = clone vars.activeSpectres
	foreach( entity spectre in killSpectres )
	{
		if( IsValid( spectre ) )
		{
			spectre.Die()
		}
	}
}

void function DEV_SpectreShack_SetWaveSize( entity player, int size )
{
	MyVars ornull varsOrNull = DEV_GetSpectreShackDataFromPlayer( player )

	if (!varsOrNull)
		return

	MyVars vars = expect MyVars(varsOrNull)

	size = int(max(size, 1))
	vars.waveSpawnCount = size

	DEV_SpectreShack_ForceSpawnNewWave( player )
	vars.kills = size
}
void function DEV_SpectreShack_ResetShack( entity player )
{
}

void function DEV_SpectreShack_OpenAllHatches()
{
	foreach( SkitInstance si in allSkits )
	{
		if( IsValid( si ) )
		{
			MyVars vars = s_siToVars[si]
			OpenLoadingHatch( si )
			vars.isSealed = false
		}
	}
}

void function DEV_SpectreShack_CloseAllHatches()
{
	foreach( SkitInstance si in allSkits )
	{
		if( IsValid( si ) )
		{
			MyVars vars = s_siToVars[si]
			if ( !vars.isSealed )
			{
				thread CloseLoadingHatch( si )
				vars.isSealed = true
			}
		}
	}
}

void function DEV_TestDoorExplodeVfx()
{
	entity player = GetPlayerArray()[0]
	foreach( si, vars in s_siToVars )
	{
		foreach( entity e in GetPlayersInsideShack( vars ) )
		{
			if( e == player )
			{
				array<entity> spawnPoints = vars.spawnGroups[0].GetLinkEntArray()
				for( int spawnIndex = 0; spawnIndex < spawnPoints.len(); spawnIndex++ )
				{
					entity spawnEnt = spawnPoints[spawnIndex]
					array<entity> doors = clone spawnEnt.GetLinkEntArray()
					thread SpectreKickDoor_Thread( spawnEnt, doors )
				}
				return
			}
		}
	}
	printf( "You must be standing inside an Armory for this dev command to work" )
}

void function DEV_TestSpectresFall()
{
	entity player = GetPlayerArray()[0]
	foreach ( si, vars in s_siToVars )
	{
		foreach ( entity e in GetPlayersInsideShack( vars ) )
		{
			if ( e == player )
			{
				thread DEV_TestSpectresDropAnim_Thread( si, vars )
				return
			}
		}
	}
	printf( "You must be standing inside an Armory for this dev command to work" )
}

void function DEV_TestSpectresDropAnim_Thread( SkitInstance si, MyVars vars )
{
	if( !vars.ceilingIsOpen )
	{
		thread PlayAnimOnly( vars.ceiling_Rig_Left,  "spectre_shack_hatchL_lower" )
		thread PlayAnimOnly( vars.ceiling_Rig_Right, "spectre_shack_hatchR_lower" )
		vars.ceilingIsOpen = true
		wait 5.0
	}

	array< entity > testProps
	array< entity > testSpectres
	array< SpectreSpawnPoint > spawnPointSubset

	foreach( SpectreSpawnPoint sp in vars.spectreSpawnPoints )
	{
		if( sp.attachmentName.find( "_B_02" ) > -1 ||
			sp.attachmentName.find( "_B_03" ) > -1 ||
			sp.attachmentName.find( "_B_04" ) > -1 ||
			sp.attachmentName.find( "_B_05" ) > -1 ||
			sp.attachmentName.find( "_B_06" ) > -1 ||
			sp.attachmentName.find( "_B_07" ) > -1 )
		{
			spawnPointSubset.append( sp )
			entity spectreProp = SpectreSpawnPoint_Rig_Proxy_Init( sp, vars.ceiling_Rig_Left )
			testProps.append( spectreProp )
		}
	}

	wait 1.0

	foreach( entity e in testProps)
	{
		e.Destroy()
	}

	foreach( SpectreSpawnPoint sp in spawnPointSubset)
	{
		entity npc = SkNPC_SpawnNPC( si, eNPC.SPECTRE, sp.attachmentOrigin, sp.attachmentAngles )
		if( sp.shortFall == true )
		{
			thread PlayAnim( npc, "spectre_shack_ceiling_dropB" )
		}
		else
		{
			thread PlayAnim( npc, "spectre_shack_ceiling_dropA" )
		}
		testSpectres.append( npc )
	}

	wait 3.0
	foreach( entity e in testSpectres )
	{
		e.Destroy()
	}
}

void function DEV_TestSpectreSpawn()
{
	entity player = GetPlayerArray()[0]
	foreach ( si, vars in s_siToVars )
	{
		foreach ( entity e in GetPlayersInsideShack( vars ) )
		{
			if ( e == player )
			{
				thread DEV_TestSpectreSpawn_Thread( si, vars )
				return
			}
		}
	}
	printf( "You must be standing inside an Armory for this dev command to work" )
}

void function DEV_TestSpectreSpawn_Thread( SkitInstance si, MyVars vars )
{
	if( !vars.ceilingIsOpen )
	{
		thread PlayAnimOnly( vars.ceiling_Rig_Left,  "spectre_shack_hatchL_lower" )
		thread PlayAnimOnly( vars.ceiling_Rig_Right, "spectre_shack_hatchR_lower" )
		vars.ceilingIsOpen = true
		wait 5.0
	}

	array< entity > testProps
	array< entity > testSpectres
	array< SpectreSpawnPoint > spawnPointSubset

	foreach( SpectreSpawnPoint sp in vars.spectreSpawnPoints )
	{
		if( sp.attachmentName.find( "L_HANGER_A_02" ) > -1 )
		{
			spawnPointSubset.append( sp )
			entity spectreProp = SpectreSpawnPoint_Rig_Proxy_Init( sp, vars.ceiling_Rig_Left )
			testProps.append( spectreProp )
		}
	}

	wait 1.0

	foreach( entity e in testProps)
	{
		e.Destroy()
	}

	foreach( SpectreSpawnPoint sp in spawnPointSubset)
	{
		entity npc = SkNPC_SpawnNPC( si, eNPC.SPECTRE, sp.attachmentOrigin, sp.attachmentAngles )
		if( sp.shortFall == true )
		{
			thread PlayAnim( npc, "spectre_shack_ceiling_dropB" )
		}
		else
		{
			thread PlayAnim( npc, "spectre_shack_ceiling_dropA" )
		}
		testSpectres.append( npc )
	}
}

#endif //DEV && SERVER 