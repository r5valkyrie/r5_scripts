global function MpWeaponNemesis_Init
global function OnWeaponActivate_weapon_nemesis
global function OnWeaponDeactivate_weapon_nemesis



// CLIENTSIDED VISUAL FUNCTIONS

#if CLIENT
// THESE FUNCTIONS ONLY CONTROL VISUALS!!
//global function Nemesis_DecayWatcher_Client 
global function Nemesis_GetEmissiveRenderColorKVString
global function UpdateChargeDecay
global function GetNemesisDataChargeLevel
global function UpdateFX_Client
#endif



// CONTROLS SERVER-SIDE DECAY LOGIC
global function Nemesis_DecayWatcher


// this code is fucking dogshit but I give up for now



// #if SERVER
global function OnWeaponPrimaryAttack_weapon_nemesis
// #endif
// (cafe): For visuals, not implemented atm
// Can be used to play heated fx and anim, prob add a networked var and a callback to execute on client
// #if SERVER || CLIENT
// global function OnWeaponHeatStateChanged_weapon_nemesis
// #endif

//Nemesis charge constants
//Retail values - Update each season, calculate how many mods we need based on heat_per_bullet
const float NEMESIS_CHARGE_PER_SHOT = 0.0417	//16.68% charge per burst
const float NEMESIS_DECAY_DELAY = 8.0			// 8 seconds before decay starts
const float NEMESIS_DECAY_RATE = 0.15			//15% per second decay rate
const float NEMESIS_DECAY_EPSILON = 0.0015     // Charge decays by this amount every NEMESIS_DECAY_LERP_TIME - Not retail
const float NEMESIS_DECAY_LERP_TIME = 0.005     // Controls the frequency that the charge level is decreased by NEMESIS_DECAY_EPSILON - Not retail
const float NEMESIS_FULL_CHARGE = 1.0			//100% charge
const float NEMESIS_CHARGE_EPSILON = 0.01		//Small value for float comparison
const float NEMESIS_MAX_CHARGE = 1.0
const float NEMESIS_TIME_TO_FULL_DISCHARGE = 7.0



//Charge level thresholds and corresponding mods


const NUMBER_OF_MODS = 10
const float MIN_CHARGE_THRESHOLD = 0.1668 
const float MAX_CHARGE_THRESHOLD = 1.0 
const float CHARGE_ADDED_PER_MOD = (MAX_CHARGE_THRESHOLD - MIN_CHARGE_THRESHOLD) / (NUMBER_OF_MODS - 1) // 0.09258



const array<float> NEMESIS_CHARGE_THRESHOLDS = [0.1668, 0.25938, 0.35196, 0.44454, 0.53712, 0.6297, 0.72228, 0.81486, 0.90744, 1.0] //  0.3336, 0.5004, 0.6672, 0.8340, 1.0]


const array<string> NEMESIS_CHARGE_MODS = ["nemesis_charge_1", "nemesis_charge_2", "nemesis_charge_3", "nemesis_charge_4", "nemesis_charge_5", "nemesis_charge_6", "nemesis_charge_7", "nemesis_charge_8", "nemesis_charge_9", "nemesis_charge_10", "fully_heated"]



const asset NEMESIS_FX_IDLE_MAGNET_FP = $"nrg_ice_shot_charge_ramp_1P_linger" // $"P_wpn_nem_idle_magnet_FP"
const asset NEMESIS_FX_IDLE_MAGNET_02_FP = $"nrg_ice_mflash_base_FP" // $"P_wpn_nem_idle_magnet_02_FP"
const asset NEMESIS_FX_IDLE_PANEL_FP =$"nrg_ice_shot_charge_ramp_1P_linger"  // $"P_wpn_nem_idle_panel_FP"
const asset NEMESIS_FX_IDLE_CENTER_FP = $"nrg_ice_shot_charge_ramp_1P_linger" // $"P_wpn_nem_idle_Center_FP"
const asset NEMESIS_FX_IDLE_LATCH_L_FP = $"nrg_ice_mflash_core_FP" // $"P_wpn_nem_idle_latch_L_FP"
const asset NEMESIS_FX_IDLE_LATCH_R_FP = $"nrg_ice_mflash_core_FP" // $"P_wpn_nem_idle_latch_R_FP"
const asset NEMESIS_FX_IDLE_3P = $"P_nrg_ice_idle_3P" // $"P_wpn_nem_idle_3P"
const asset NEMESIS_FX_IDLE_EMPTY = $"nrg_ice_lvlup_snow_B" // $"P_wpn_nem_empty_FP"

const asset NEMESIS_FX_IDLE_CHARGED_FP = $"nrg_ice_lvlup_snow_B" // $"P_wpn_nem_charged_ribbon_FP"

// const float BARREL_CLOSE_SOUND_HEAT_VALUE = 0.05



/////////////////////////////



global struct NemesisData
{
	float chargeLevel = 0.0
	float lastFireTime = 0.0
	int currentChargeMod = -1
	bool firstTime = true
	bool chargeIsDecaying = false
}

struct{
	table<entity, NemesisData> nemesisDataTable
} file

//Table to store nemesis data per weapon


void function MpWeaponNemesis_Init()
{

RegisterSignal("EndDecayWatcherThread")

	PrecacheParticleSystem( NEMESIS_FX_IDLE_MAGNET_FP )
	PrecacheParticleSystem( NEMESIS_FX_IDLE_MAGNET_02_FP )
	PrecacheParticleSystem( NEMESIS_FX_IDLE_PANEL_FP )
	PrecacheParticleSystem( NEMESIS_FX_IDLE_CENTER_FP )
	PrecacheParticleSystem( NEMESIS_FX_IDLE_3P )
	PrecacheParticleSystem( NEMESIS_FX_IDLE_LATCH_L_FP )
	PrecacheParticleSystem( NEMESIS_FX_IDLE_LATCH_R_FP )
	PrecacheParticleSystem( NEMESIS_FX_IDLE_EMPTY )

	PrecacheParticleSystem( NEMESIS_FX_IDLE_CHARGED_FP )

//	PrecacheParticleSystem( $"P_wpn_nem_reload_cyl_glow" )
//	PrecacheParticleSystem( $"P_wpn_nem_reload_cyl_glow_late" )
//	PrecacheParticleSystem( $"P_wpn_nem_cyl_elec" )
//	PrecacheParticleSystem( $"P_wpn_nem_reload_elec_ring" )

//	PrecacheParticleSystem( $"P_wpn_nem_reload_cyl_elec_01" )
//	PrecacheParticleSystem( $"P_wpn_nem_reload_cyl_elec_02" )
//	PrecacheParticleSystem( $"P_wpn_nem_reload_cyl_elec_03" )


/*
	for(int chargeIndex = 0, chargeIndex < NUMBER_OF_MODS, chargeIndex++)
// chargeIndex already exists at this scope error??? WTF, it's a local variable...

{
NEMESIS_CHARGE_THRESHOLDS[chargeIndex] = MIN_CHARGE_THRESHOLD + (CHARGE_ADDED_PER_MOD * chargeIndex)
}
*/
}

///////// SERVER //////////////////////////////////////////////////////////////////////////////////


void function Nemesis_DecayWatcher( entity weapon )

{
	EndSignal(weapon, "OnDestroy")
	EndSignal(weapon, "EndDecayWatcherThread")
	NemesisData nemesisData = file.nemesisDataTable[weapon]
	printt("Nemesis_DecayWatcher block 1")

		OnThreadEnd(
				function() : ( weapon, nemesisData )
			{
			//	if ( IsValid( weapon ) && "VisualsThreadActive" in weapon.s )
			//	{
			//		delete weapon.s.VisualsThreadActive
			//	}
				//#if SERVER
				if (nemesisData.chargeIsDecaying)
					nemesisData.chargeIsDecaying = false
				//#endif
				}
			)

	entity player = weapon.GetWeaponOwner()

	if (!IsValid(player))
	return

	while (IsValid(weapon))
		{
		float timeSinceLastFire = Time() - nemesisData.lastFireTime

		// printt("[NEMESIS] Time since last fire = " + timeSinceLastFire.tostring())	
		// nemesisData.lastFireTime = Time()
		float paramValueFromChargeLerpDecay

		if (timeSinceLastFire > NEMESIS_DECAY_DELAY )
			{
			while (nemesisData.chargeLevel > 0)
				{
				nemesisData = file.nemesisDataTable[weapon] 			
				//#if SERVER
				// SERVER-SIDE CHARGE DECAY LOGIC!
				nemesisData.chargeIsDecaying = true	

					if (nemesisData.chargeLevel - 0.01 <= 0)
						{
							nemesisData.chargeIsDecaying = false
							nemesisData.chargeLevel = 0.0 // charge reset contingency
							break
						}
					/*
					nemesisData.chargeLevel-= NEMESIS_DECAY_EPSILON // 0.00008 // NEMESIS_CHARGE_PER_SHOT
					printt("[NEMESIS] Charge level decayed to " + nemesisData.chargeLevel
					file.nemesisDataTable[weapon].chargeLevel = nemesisData.chargeLevel
					printt("[NEMESIS] Updated global charge level to " + nemesisData.chargeLevel)
					// wait NEMESIS_DECAY_LERP_TIME 
					*/				
					//#endif
	

					// These are tied to time instead of the charge level, but they can easily be switched to be tied to charge level
					float f_RedValue_d = GraphCapped(timeSinceLastFire, NEMESIS_DECAY_DELAY, NEMESIS_DECAY_DELAY + NEMESIS_TIME_TO_FULL_DISCHARGE, 255.0, 0.0) 
					// GraphCapped(nemesisData.chargeLevel, 0.0, 1.01, 255.0, 0.0) 
					// set charge max clamp to 1.01 to make sure it surpasses the 1.0 threshold the NEMESIS_CHARGE_THRESHOLDS array
					float f_GreenValue_d = GraphCapped(timeSinceLastFire, NEMESIS_DECAY_DELAY, NEMESIS_DECAY_DELAY + NEMESIS_TIME_TO_FULL_DISCHARGE, 255.0, 0.0)
					// GraphCapped(V, A, B, C, D), where V = current charge level, A = color clamp min, B = color clamp max, C = charge level min, D = charge level max
					float f_BlueValue_d = GraphCapped(timeSinceLastFire, NEMESIS_DECAY_DELAY, NEMESIS_DECAY_DELAY + NEMESIS_TIME_TO_FULL_DISCHARGE, 255.0, 0.0) 
					// GraphCapped(V, A, B, C, D), where V = current charge level, A = color clamp min, B = color clamp max, C = charge level min, D = charge level max

					#if CLIENT
					string NewKVString_d = Nemesis_GetEmissiveRenderColorKVString(f_RedValue_d, f_GreenValue_d, f_BlueValue_d) // , weapon)
					//if (NewKVString != OldKVString.tostring())
					//{
					// printt("[NEMESIS]: New KV String is: " + NewKVString)
					//}
					// printt("[NEMESIS] Time since last fire = " + timeSinceLastFire.tostring())	
					// printt("[NEMESIS] NEW DECAY RGB VALUES ARE: " + NewKVString_d)
					weapon.kv.rendercolor = NewKVString_d
					////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

					paramValueFromChargeLerpDecay = GraphCapped(nemesisData.chargeLevel, 0.0, 1.0, 0.0, 1.0)
					printt("[NEMESIS] Magnet Latch LERP Value (Script Pose Param 0) for charge DECAY is " + paramValueFromChargeLerpDecay)
					printt("[NEMESIS] [CLIENT DECAY WATCHER] nemesisData.chargeLevel = " + nemesisData.chargeLevel)
					weapon.SetScriptPoseParam0(paramValueFromChargeLerpDecay)
					#endif

					// newCharge = UpdateChargeDecay(weapon)  // need to update the charge level ever code block execution
					// clientCharge -= NEMESIS_DECAY_EPSILON

					nemesisData.chargeLevel-= NEMESIS_DECAY_EPSILON // 0.00008 // NEMESIS_CHARGE_PER_SHOT					

					printt("[NEMESIS] Charge level decayed to " + nemesisData.chargeLevel)
					file.nemesisDataTable[weapon].chargeLevel = nemesisData.chargeLevel
					printt("[NEMESIS] Updated global charge level to " + nemesisData.chargeLevel)

			wait NEMESIS_DECAY_LERP_TIME // 0.005
				}
			}
	WaitFrame()
		}
}

#if SERVER

void function UpdateChargeMod( entity weapon )
{
	if ( !IsValid(weapon) )
		return
	
	//Get nemesis data from global table
	if ( !(weapon in file.nemesisDataTable) )
		return

	NemesisData nemesisData = file.nemesisDataTable[weapon]
	int newChargeMod = GetChargeModIndex( nemesisData.chargeLevel )
	
	//Only update if charge mod changed
	if ( newChargeMod != nemesisData.currentChargeMod )
	{
		//Remove old charge mod
		if ( nemesisData.currentChargeMod >= 0 && nemesisData.currentChargeMod < NEMESIS_CHARGE_MODS.len() )
		{
			string oldMod = NEMESIS_CHARGE_MODS[nemesisData.currentChargeMod]
			if ( weapon.HasMod(oldMod) )
			{
				weapon.RemoveMod( oldMod )
				#if DEVELOPER
				printt("[NEMESIS] Removed charge mod:", oldMod)
				#endif
			}
		}
		
		//Apply new charge mod
		if ( newChargeMod >= 0 && newChargeMod < NEMESIS_CHARGE_MODS.len() ) 
		{
			string newMod = NEMESIS_CHARGE_MODS[newChargeMod]
			weapon.AddMod( newMod )
			printt("weapon.Addmod()")
			
			#if DEVELOPER
			printt("[NEMESIS] Applied charge mod:", newMod, "at charge level:", nemesisData.chargeLevel)
			#endif
		}
		
		if ( nemesisData.chargeLevel <= 0.0 )
		{

			RemoveAllChargeMods(weapon)	
			printt("[NEMESIS] Removed all weapon mods")
			nemesisData.chargeLevel = 0.0 // reset charge to flat 0.0
		}

		nemesisData.currentChargeMod = newChargeMod
	}
}

int function GetChargeModIndex( float chargeLevel )
{
	//Return -1 for no mod (base state)
	if ( chargeLevel < NEMESIS_CHARGE_THRESHOLDS[0] )
		return -1
	
	//Find the appropriate charge mod based on charge level
	for ( int i = NEMESIS_CHARGE_THRESHOLDS.len() - 1; i >= 0; i-- )
	{
		if ( chargeLevel >= NEMESIS_CHARGE_THRESHOLDS[i] )
			return i
	}
	
	return -1
}

void function RemoveAllChargeMods( entity weapon )
{
	if ( !IsValid(weapon) )
		return
	
	foreach ( string mod in NEMESIS_CHARGE_MODS )
	{
		if ( weapon.HasMod(mod) )
		{
			weapon.RemoveMod( mod )
			#if DEVELOPER
			printt("[NEMESIS] Removed charge mod during cleanup:", mod)
			#endif
		}
	}
}


#endif

///////// SERVER //////////////////////////////////////////////////////////////////////////////////


void function OnWeaponActivate_weapon_nemesis( entity weapon )
{
	#if DEVELOPER
	printt("[NEMESIS] Weapon activated")
	#endif
	
	//Initialize nemesis data if not already present (preserves charge on re-equip)
	#if CLIENT || SERVER	
	if ( !(weapon in file.nemesisDataTable) )
	{
		NemesisData nemesisData
		file.nemesisDataTable[weapon] <- nemesisData
		if (nemesisData.firstTime)
		{
          printt("[NEMESIS]: First deploy, setting lights to OFF")
		  weapon.kv.rendercolor = "0 0 0"
		  nemesisData.firstTime = false

		}
		// does this block even execute?
		#if CLIENT
		thread UpdateFX_Client( weapon ) 
		#endif
	}

#endif

}

void function OnWeaponDeactivate_weapon_nemesis( entity weapon )
{
	#if DEVELOPER
	printt("[NEMESIS] Weapon deactivated")
	#endif
	
	//Shouldn't remove the charges on weapon deactivate, it should be only on decay
	//RemoveAllChargeMods( weapon )
	
	// if ( weapon in file.nemesisDataTable )
		// delete file.nemesisDataTable[weapon]
}

// #if SERVER

var function OnWeaponPrimaryAttack_weapon_nemesis( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetOwner()
	if ( !IsValid(owner) )
		return 0
	
	//Get nemesis data from table
	if ( !(weapon in file.nemesisDataTable) )
		return 0
	
	NemesisData nemesisData = file.nemesisDataTable[weapon]

	
	//Get burst fire count from weapon (should be 4 for Nemesis)
	int burstFireCount = weapon.GetWeaponSettingInt( eWeaponVar.burst_fire_count )	
	weapon.FireWeapon_Default( attackParams.pos, attackParams.dir, 1.0, 1.0, false )	
	NemesisChargeDecayCalculate( weapon ) // renamed from NemesisChargeDecayThink to NemesisChargeDecayCalculate because it's not a thinker function executed at regular intervals; it's not threaded off
	
	 #if SERVER
	// SERVER-SIDE DECAY LOGIC
	// Signal(weapon, "EndServerDecayThread")
    // thread Nemesis_DecayWatcher_Server(weapon)
	#endif	

    #if CLIENT
    // CLIENT-SIDE VISUAL CHARGE DECAY
	//Signal(weapon, "EndClientDecayThread")
   // thread Nemesis_DecayWatcher_Client(weapon, nemesisData)
	#endif

    Signal(weapon, "EndDecayWatcherThread") // end then restart the thread
	thread Nemesis_DecayWatcher(weapon)
	
	//Use default attack behavior
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}



void function NemesisChargeDecayCalculate( entity weapon )
{		
	NemesisData nemesisData = file.nemesisDataTable[weapon] // TODO: delete on destroy!!! put it in weapon.w or something

	//Check if enough time has passed since last fire for decay to start
	float oldCharge = nemesisData.chargeLevel
	float timeSinceLastFire = Time() - nemesisData.lastFireTime
	nemesisData.lastFireTime = Time()	
	
	if ( nemesisData.chargeLevel >= 0.0 && !nemesisData.chargeIsDecaying )
	{
		nemesisData.chargeLevel = GraphCapped( Time() - nemesisData.lastFireTime, NEMESIS_DECAY_DELAY, NEMESIS_DECAY_DELAY + ( nemesisData.chargeLevel / NEMESIS_DECAY_RATE ), nemesisData.chargeLevel, 0) // (1.0 / NEMESIS_DECAY_RATE * nemesisData.chargeLevel), nemesisData.chargeLevel, 0 )
		//	NEMESIS_DECAY_DELAY, 
		//	NEMESIS_DECAY_DELAY + (1.0 / NEMESIS_DECAY_RATE * nemesisData.chargeLevel)
		//	nemesisData.chargeLevel, 0 )
		if (nemesisData.chargeLevel + NEMESIS_CHARGE_PER_SHOT > NEMESIS_MAX_CHARGE) // not optimal implementation, already uses GraphCapped above, should use Max(arg1,arg2)! Shouldn't exceed max charge in the first place...
			{
          	nemesisData.chargeLevel = NEMESIS_MAX_CHARGE
			}
			else
			{	
			nemesisData.chargeLevel += NEMESIS_CHARGE_PER_SHOT
			}
		printt("NEMESIS CHARGE CHANGED")
		
		#if DEVELOPER
		// if ( oldCharge != nemesisData.chargeLevel )
		printt("[NEMESIS] Charge changed:", oldCharge, "->", nemesisData.chargeLevel) // after reaching 1.0, it's always 1.0, it doesn't decay, wtf?
		// printt("[NEMESIS] Charge added: ",  nemesisData.chargeLevel - oldCharge)
		#endif
		
		//Update charge mod if charge level changed significantly
		#if SERVER
		if ( fabs(oldCharge - nemesisData.chargeLevel) > NEMESIS_CHARGE_EPSILON )
		UpdateChargeMod( weapon )
        #endif  


		#if CLIENT
		// CLIENT-SIDE VISUALS CHARGE UP
		thread Nemesis_VisualsWatcher(weapon)
		#endif
	}

/* 	
	if (nemesisData.chargeLevel >= 0 && nemesisData.chargeIsDecaying)  // Not possible to reach these conditions at this point of execution because you've just fired
	{
	
	 #if SERVER
	// SERVER-SIDE DECAY LOGIC
    thread Nemesis_DecayWatcher_Server(weapon)
	#endif	

    #if CLIENT
    // CLIENT-SIDE VISUAL CHARGE DECAY
    thread Nemesis_DecayWatcher_Client(weapon)
	#endif
	}
*/ 	
}
// #endif




//////////// CLIENT //////////////////////////////////////////////////////////////////////////////


#if CLIENT
float function UpdateChargeDecay(entity weapon)
{
NemesisData nemesisData = file.nemesisDataTable[weapon]
float newCharge = nemesisData.chargeLevel
printt("[NEMESIS] Updated charge = " + newCharge)
return newCharge
}


// CLIENTSIDED VISUALS WATCHER

void function Nemesis_VisualsWatcher( entity weapon )
{
EndSignal(weapon, "OnDestroy")

//if (!"VisualsThreadActive"in weapon.s) 
//{
//weapon.s.VisualsThreadActive <- true
//}
printt("Nemesis_VisualsWatcher block 1")

OnThreadEnd(
		function() : ( weapon )
		{
	//	if ( IsValid( weapon ) && "VisualsThreadActive" in weapon.s )
	//	{
	//		delete weapon.s.VisualsThreadActive
	//	}

		}
	)


while (IsValid(weapon))
	{

	NemesisData nemesisData = file.nemesisDataTable[weapon] 
	//var OldKVString = weapon.kv.rendercolor
	float f_RedValue = GraphCapped(nemesisData.chargeLevel, 0.0, 1.0, 0.0, 255.0)
	// GraphCapped(V, A, B, C, D), where V = current charge level, A = color clamp min, B = color clamp max, C = charge level min, D = charge level max
	// set charge max clamp to 1.01 to make sure it surpasses the 1.0 threshold the NEMESIS_CHARGE_THRESHOLDS array
	float f_GreenValue = GraphCapped(nemesisData.chargeLevel, 0.0, 1.0, 0.0, 255.0) 
	// GraphCapped(V, A, B, C, D), where V = current charge level, A = color clamp min, B = color clamp max, C = charge level min, D = charge level max
	float f_BlueValue = GraphCapped(nemesisData.chargeLevel, 0.0, 1.0, 0.0, 255.0) 
	// GraphCapped(V, A, B, C, D), where V = current charge level, A = color clamp min, B = color clamp max, C = charge level min, D = charge level max
	string NewKVString = Nemesis_GetEmissiveRenderColorKVString(f_RedValue, f_GreenValue, f_BlueValue) // , weapon)

	weapon.kv.rendercolor = NewKVString
	float paramValueFromChargeLerp = GraphCapped(nemesisData.chargeLevel, 0.0, 1.0, 0.0, 1.0)
	entity vm = weapon.GetWeaponViewmodel()
	entity player = weapon.GetWeaponOwner()

	if (!IsValid(player))
	return

	weapon.SetScriptPoseParam0(paramValueFromChargeLerp)

	//if (NewKVString != OldKVString.tostring())
	//{
	// printt("[NEMESIS]: New KV String is: " + NewKVString)
	//}
WaitFrame()
	}
}








string function Nemesis_GetEmissiveRenderColorKVString(float RedValue = 0, float GreenValue = 0, float BlueValue = 0)
{
//OldKVString = weapon.kv.rendercolor
string KVString = RedValue.tostring() + " " + GreenValue.tostring() + " " + BlueValue.tostring()
//if (NewKVString != KVString)
//{
//printt("[NEMESIS]: KV String is: " + KVString)
//}
return KVString
}

#endif

//////////// CLIENT //////////////////////////////////////////////////////////////////////////////




//// SHARED /////////////////////////////////////////////////////////////////////////////

#if SERVER || CLIENT
void function OnWeaponHeatStateChanged_weapon_nemesis( entity weapon, int newHeatState )
{
	//This callback is called when the weapon's heat state changes
	//We could use this for additional effects or logic if needed	
	#if DEVELOPER
	printt("[NEMESIS] Heat state changed to:", newHeatState)
	#endif
}

#endif

//// SHARED /////////////////////////////////////////////////////////////////////////////


#if CLIENT
float function GetNemesisDataChargeLevel(entity weapon)
{
NemesisData nemesisData = file.nemesisDataTable[weapon]
return nemesisData.chargeLevel
}

#endif

#if CLIENT
void function UpdateFX_Client ( entity weapon)
{
	//////THREAD
	AssertIsNewThread()
	if ( !IsValid( weapon ) )
		{
			return
		}
	else
		{

			if ( !(weapon in file.nemesisDataTable) )
			{
			NemesisData nemesisData
			file.nemesisDataTable[weapon] <- nemesisData
			}	
		NemesisData nemesisData = file.nemesisDataTable[weapon]
		}

	weapon.EndSignal( "OnDestroy" )
	// weapon.EndSignal( "WeaponDeactivate_Nemesis" )
	// weapon.EndSignal( "UpdateCosmetic" )

	entity player = weapon.GetWeaponOwner()
	if ( !IsValid( player ) || !IsLocalViewPlayer( player ) )
		return

	player.EndSignal( "OnDeath" )
	//player.EndSignal( "PlayerDisconnected" )
	//////THREAD

	//weapon.PlayWeaponEffect( NEMESIS_FX_IDLE_RIBBON_FP, $"", "fx_ribbon_charge_03", true )

	weapon.PlayWeaponEffect( NEMESIS_FX_IDLE_PANEL_FP, $"", "fx_panel_L", true )
	weapon.PlayWeaponEffect( NEMESIS_FX_IDLE_PANEL_FP, $"", "fx_panel_R", true )

	weapon.PlayWeaponEffect( NEMESIS_FX_IDLE_MAGNET_FP, $"", "fx_magnet_01", true )
	weapon.PlayWeaponEffect( NEMESIS_FX_IDLE_MAGNET_02_FP, $"", "fx_magnet_02", true )
	weapon.PlayWeaponEffect( NEMESIS_FX_IDLE_MAGNET_FP, $"", "fx_magnet_03", true )
	weapon.PlayWeaponEffect( NEMESIS_FX_IDLE_MAGNET_02_FP, $"", "fx_magnet_04", true )
	weapon.PlayWeaponEffect( NEMESIS_FX_IDLE_MAGNET_FP, $"", "fx_magnet_05", true )

	int fxHandle_Barrel
	int fxHandle_Ribbon

	if ( !EffectDoesExist(fxHandle_Barrel))
		fxHandle_Barrel = weapon.PlayWeaponEffectReturnViewEffectHandle( NEMESIS_FX_IDLE_CENTER_FP, NEMESIS_FX_IDLE_3P, "fx_barrel_back") //, true )
	if ( !EffectDoesExist(fxHandle_Ribbon))
		fxHandle_Ribbon = weapon.PlayWeaponEffectReturnViewEffectHandle( NEMESIS_FX_IDLE_CHARGED_FP, $"", "fx_ribbon_charge") //, true )

	//Left and right wing tendrils
	array<int> fxHandlesLeft =
	[
		weapon.PlayWeaponEffectReturnViewEffectHandle( NEMESIS_FX_IDLE_LATCH_L_FP, $"", "fx_mag_latch_L_01") //, true ),
		weapon.PlayWeaponEffectReturnViewEffectHandle( NEMESIS_FX_IDLE_LATCH_L_FP, $"", "fx_mag_latch_L_02") //, true ),
		weapon.PlayWeaponEffectReturnViewEffectHandle( NEMESIS_FX_IDLE_LATCH_L_FP, $"", "fx_mag_latch_L_03") //, true ),
		weapon.PlayWeaponEffectReturnViewEffectHandle( NEMESIS_FX_IDLE_LATCH_L_FP, $"", "fx_mag_latch_L_04") //, true ),
		weapon.PlayWeaponEffectReturnViewEffectHandle( NEMESIS_FX_IDLE_LATCH_L_FP, $"", "fx_mag_latch_L_05") //, true ),
		weapon.PlayWeaponEffectReturnViewEffectHandle( NEMESIS_FX_IDLE_LATCH_L_FP, $"", "fx_mag_latch_L_06") //, true ),
	]
	array<int> fxHandlesRight =
	[
		weapon.PlayWeaponEffectReturnViewEffectHandle( NEMESIS_FX_IDLE_LATCH_R_FP, $"", "fx_mag_latch_R_01") //, true ),
		weapon.PlayWeaponEffectReturnViewEffectHandle( NEMESIS_FX_IDLE_LATCH_R_FP, $"", "fx_mag_latch_R_02") //, true ),
		weapon.PlayWeaponEffectReturnViewEffectHandle( NEMESIS_FX_IDLE_LATCH_R_FP, $"", "fx_mag_latch_R_03") //, true ),
		weapon.PlayWeaponEffectReturnViewEffectHandle( NEMESIS_FX_IDLE_LATCH_R_FP, $"", "fx_mag_latch_R_04") //, true ),
		weapon.PlayWeaponEffectReturnViewEffectHandle( NEMESIS_FX_IDLE_LATCH_R_FP, $"", "fx_mag_latch_R_05") //, true ),
		weapon.PlayWeaponEffectReturnViewEffectHandle( NEMESIS_FX_IDLE_LATCH_R_FP, $"", "fx_mag_latch_R_06") //, true ),
	]

	//Sleep latch particles after being created
	for ( int i; i < fxHandlesLeft.len(); i++ )
	{
		if ( EffectDoesExist( fxHandlesLeft[i] ) )
		{
			EffectSleep( fxHandlesLeft[i])
		}
		if ( EffectDoesExist( fxHandlesRight[i]) )
		{
			EffectSleep( fxHandlesRight[i])
		}
	}

	OnThreadEnd(
		function() : ( weapon, fxHandlesLeft, fxHandlesRight, fxHandle_Barrel, fxHandle_Ribbon )
		{
			for ( int i; i < fxHandlesLeft.len(); i++ )
			{
				if ( EffectDoesExist( fxHandlesLeft[i] ) )
				{
					EffectStop( fxHandlesLeft[i], true, false )
				}

				if ( EffectDoesExist( fxHandlesRight[i]) )
				{
					EffectStop( fxHandlesRight[i], true, false )
				}
			}

			if ( EffectDoesExist( fxHandle_Barrel ) )
			{
				EffectStop( fxHandle_Barrel, true, false )
			}

			if ( EffectDoesExist( fxHandle_Ribbon ) )
			{
				EffectStop( fxHandle_Ribbon, true, false )
			}

			weapon.StopWeaponEffect( $"", NEMESIS_FX_IDLE_3P )
		}

	)

	float previousHeat = 0.0
	float length = float( fxHandlesLeft.len() )

	//Loop
	while( true && IsValid(weapon))
	{

		
		float heatValue 		= GetNemesisDataChargeLevel(weapon) // weapon.GetHeatValue()
		float interp 			= 0.0

		//Activate/Deactivate particles based on heatValue interpolation
		if (heatValue != previousHeat)
		{

			if ( EffectDoesExist( fxHandle_Barrel ) )
				EffectSetControlPointVector( fxHandle_Barrel, 15, <heatValue, heatValue, heatValue> )

			if ( EffectDoesExist( fxHandle_Ribbon ) )
				EffectSetControlPointVector( fxHandle_Ribbon, 15, <heatValue, heatValue, heatValue> )

			for ( int i; i < fxHandlesLeft.len(); i++ )
			{

				interp = ( i / length )

				if (heatValue > interp)
				{
					if ( EffectDoesExist( fxHandlesLeft[i] ) )
					{
						EffectWake( fxHandlesLeft[i] )
					}
					if ( EffectDoesExist( fxHandlesRight[i] ))
					{
						EffectWake( fxHandlesRight[i] )
					}
				}
				else
				{
					if ( EffectDoesExist( fxHandlesLeft[i] ))
					{
						EffectSleep( fxHandlesLeft[i] )
					}
					if ( EffectDoesExist( fxHandlesRight[i] ))
					{
						EffectSleep( fxHandlesRight[i] )
					}
				}
			}
		}
		previousHeat = heatValue
		WaitFrame()
	}
}
#endif