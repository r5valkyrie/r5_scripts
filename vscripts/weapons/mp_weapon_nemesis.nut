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
const float NEMESIS_DECAY_EPSILON = 0.00007     // Charge decays by this amount every NEMESIS_DECAY_LERP_TIME - Not retail
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


   //      #if SERVER

	     if (nemesisData.chargeIsDecaying)
            nemesisData.chargeIsDecaying = false

//		#endif

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
				

				printt("[NEMESIS] Charge level decayed to " + nemesisData.chargeLevel)

				file.nemesisDataTable[weapon].chargeLevel = nemesisData.chargeLevel

				printt("[NEMESIS] Updated global charge level to " + nemesisData.chargeLevel)

				// wait NEMESIS_DECAY_LERP_TIME 
*/				

//#endif
 

 // These are tied to time instead of the charge level, but they can easily be switched to be tied to charge level

float f_RedValue_d = GraphCapped(timeSinceLastFire, NEMESIS_DECAY_DELAY, NEMESIS_DECAY_DELAY + NEMESIS_TIME_TO_FULL_DISCHARGE, 255.0, 0.0) // GraphCapped(nemesisData.chargeLevel, 0.0, 1.01, 255.0, 0.0) 

// set charge max clamp to 1.01 to make sure it surpasses the 1.0 threshold the NEMESIS_CHARGE_THRESHOLDS array

float f_GreenValue_d = GraphCapped(timeSinceLastFire, NEMESIS_DECAY_DELAY, NEMESIS_DECAY_DELAY + NEMESIS_TIME_TO_FULL_DISCHARGE, 255.0, 0.0)// GraphCapped(V, A, B, C, D), where V = current charge level, A = color clamp min, B = color clamp max, C = charge level min, D = charge level max

float f_BlueValue_d = GraphCapped(timeSinceLastFire, NEMESIS_DECAY_DELAY, NEMESIS_DECAY_DELAY + NEMESIS_TIME_TO_FULL_DISCHARGE, 255.0, 0.0) // GraphCapped(V, A, B, C, D), where V = current charge level, A = color clamp min, B = color clamp max, C = charge level min, D = charge level max

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

float f_RedValue = GraphCapped(nemesisData.chargeLevel, 0.0, 1.0, 0.0, 255.0)// 0.0, 255.0, 0.0, 1.01) // GraphCapped(V, A, B, C, D), where V = current charge level, A = color clamp min, B = color clamp max, C = charge level min, D = charge level max

// set charge max clamp to 1.01 to make sure it surpasses the 1.0 threshold the NEMESIS_CHARGE_THRESHOLDS array

float f_GreenValue = GraphCapped(nemesisData.chargeLevel, 0.0, 1.0, 0.0, 255.0) // GraphCapped(V, A, B, C, D), where V = current charge level, A = color clamp min, B = color clamp max, C = charge level min, D = charge level max

float f_BlueValue = GraphCapped(nemesisData.chargeLevel, 0.0, 1.0, 0.0, 255.0) // GraphCapped(V, A, B, C, D), where V = current charge level, A = color clamp min, B = color clamp max, C = charge level min, D = charge level max

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




/*
void function Nemesis_DecayWatcher_Client( entity weapon, NemesisData nemesisData )

{

EndSignal(weapon, "OnDestroy")
EndSignal(weapon, "EndClientDecayThread")



printt("Nemesis_DecayWatcher_Client block 1")

OnThreadEnd(
		function() : ( weapon )
				{

				}
	)


entity player = weapon.GetWeaponOwner()

if (!IsValid(player))
return

while (IsValid(weapon))
	{

//nemesisData = file.nemesisDataTable[weapon] 


float timeSinceLastFire = Time() - nemesisData.lastFireTime


float paramValueFromChargeLerpDecay

while (timeSinceLastFire > NEMESIS_DECAY_DELAY )

		{

while ( file.nemesisDataTable[weapon].chargeLevel > 0.0) 
			{

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// nemesisData = file.nemesisDataTable[weapon] 

// These are tied to time instead of the charge level, but they can easily be switched to be tied to charge level

float f_RedValue_d = GraphCapped(timeSinceLastFire, NEMESIS_DECAY_DELAY, NEMESIS_DECAY_DELAY + NEMESIS_TIME_TO_FULL_DISCHARGE, 255.0, 0.0) // GraphCapped(nemesisData.chargeLevel, 0.0, 1.01, 255.0, 0.0) 

// set charge max clamp to 1.01 to make sure it surpasses the 1.0 threshold the NEMESIS_CHARGE_THRESHOLDS array

float f_GreenValue_d = GraphCapped(timeSinceLastFire, NEMESIS_DECAY_DELAY, NEMESIS_DECAY_DELAY + NEMESIS_TIME_TO_FULL_DISCHARGE, 255.0, 0.0)// GraphCapped(V, A, B, C, D), where V = current charge level, A = color clamp min, B = color clamp max, C = charge level min, D = charge level max

float f_BlueValue_d = GraphCapped(timeSinceLastFire, NEMESIS_DECAY_DELAY, NEMESIS_DECAY_DELAY + NEMESIS_TIME_TO_FULL_DISCHARGE, 255.0, 0.0) // GraphCapped(V, A, B, C, D), where V = current charge level, A = color clamp min, B = color clamp max, C = charge level min, D = charge level max

string NewKVString_d = Nemesis_GetEmissiveRenderColorKVString(f_RedValue_d, f_GreenValue_d, f_BlueValue_d) // , weapon)

//if (NewKVString != OldKVString.tostring())

//{
// printt("[NEMESIS]: New KV String is: " + NewKVString)
//}

// printt("[NEMESIS] Time since last fire = " + timeSinceLastFire.tostring())	


// printt("[NEMESIS] NEW DECAY RGB VALUES ARE: " + NewKVString_d)

weapon.kv.rendercolor = NewKVString_d

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

paramValueFromChargeLerpDecay = GraphCapped(GetNemesisDataChargeLevel(weapon), 0.0, 1.0, 0.0, 1.0)

// printt("[NEMESIS] Magnet Latch LERP Value (Script Pose Param 0) for charge DECAY is " + paramValueFromChargeLerpDecay)

printt("[NEMESIS] [CLIENT DECAY WATCHER] nemesisData.chargeLevel = " + GetNemesisDataChargeLevel(weapon))

weapon.SetScriptPoseParam0(paramValueFromChargeLerpDecay)

// newCharge = UpdateChargeDecay(weapon)  // need to update the charge level ever code block execution

// clientCharge -= NEMESIS_DECAY_EPSILON

wait NEMESIS_DECAY_LERP_TIME // 0.005

			}

		}

WaitFrame()

	}


}

*/



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