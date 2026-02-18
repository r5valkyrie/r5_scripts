global function MpWeaponNemesis_Init
global function OnWeaponActivate_weapon_nemesis
global function OnWeaponDeactivate_weapon_nemesis






// CLIENTSIDED VISUAL FUNCTIONS

#if CLIENT
global function Nemesis_VisualsWatcher
global function Nemesis_DecayWatcher
global function Nemesis_GetEmissiveRenderColorKVString
//global function Nemesis_GetDeltaAnimations
//global function Nemesis_AnimationHandler
global function Nemesis_DEBUGPLAYANIM
#endif

#if SERVER
// DEBUG & TESTING

global function Nemesis_DEBUGPLAYACTIVITY
#endif


//



// global function CalculateChargeThresholds

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
const float NEMESIS_TIME_TO_FULL_DISCHARGE = 7.0



//Charge level thresholds and corresponding mods


const NUMBER_OF_MODS = 10
const float MIN_CHARGE_THRESHOLD = 0.1668 
const float MAX_CHARGE_THRESHOLD = 1.0 
const float CHARGE_ADDED_PER_MOD = (MAX_CHARGE_THRESHOLD - MIN_CHARGE_THRESHOLD) / (NUMBER_OF_MODS - 1) // 0.09258



const array<float> NEMESIS_CHARGE_THRESHOLDS = [0.1668, 0.25938, 0.35196, 0.44454, 0.53712, 0.6297, 0.72228, 0.81486, 0.90744, 1.0] //  0.3336, 0.5004, 0.6672, 0.8340, 1.0]


const array<string> NEMESIS_CHARGE_MODS = ["nemesis_charge_1", "nemesis_charge_2", "nemesis_charge_3", "nemesis_charge_4", "nemesis_charge_5", "nemesis_charge_6", "nemesis_charge_7", "nemesis_charge_8", "nemesis_charge_9", "nemesis_charge_10", "fully_heated"]


////////// NEMESIS ANIMATIONS


const string NEMESIS_IDLE_ANIMATION_STRING = "animseq/weapons/nemesis/ptpov_nemesis/idle_nemesis_layer.rseq"
const string NEMESIS_FIRE_FULLYCHARGED_ANIMATION_STRING = ""
const string NEMESIS_FIRE_FULLYCHARGED_ONEHANDED_ANIMATION_STRING = "anmimseq/weapons/nemesis/ptpov_nemesis/fire_fullyCharged_onehanded.rseq"

const string NEMESIS_Idle_Anim_LVL1 = "ptpov_nemesis_idle_lv1_dmx__loop_sub_ptpov_nemesis_idle_precharge_dmx_CE0ECADD" // lvl1 charge
const string NEMESIS_Idle_Anim_LVL2 = "ptpov_nemesis_idle_lv2_dmx__loop_sub_ptpov_nemesis_idle_precharge_dmx_C33C1E0D" // lvl2 charge
const string NEMESIS_Idle_Anim_LVL3 = "ptpov_nemesis_idle_lv3_dmx__loop_sub_ptpov_nemesis_idle_precharge_dmx_47AEAF98" // lvl3 charge
const string NEMESIS_Idle_Anim_LVL4 =  "ptpov_nemesis_idle_lv4_dmx__loop_sub_ptpov_nemesis_idle_precharge_dmx_53769C4" // lvl4 charge
const string NEMESIS_Idle_Anim_LVL5 = "ptpov_nemesis_idle_lv5_dmx__loop_sub_ptpov_nemesis_idle_precharge_dmx_BCA3061F" // lvl5 charge
const string NEMESIS_Idle_FULLYCHARGED = "ptpov_nemesis_idle_fullycharged_dmx__loop_sub_ptpov_nemesis_idle_precharge_dmx_12E669FD" // fully charged

const string NEMESIS_Idle_RSEQ_Name = "idle_nemesis_layer" 
const string NEMESIS_Fire_FullyCharged_RSEQ_Name = "fire_fullyCharged"
const string NEMESIS_Fire_FullyCharged_OneHanded_RSEQ_Name = "fire_fullyCharged_onehanded"


const string NEMESIS_IDLE_PRECHARGE_LOOP = "ptpov_nemesis_idle_precharge_dmx__loop_sub_BE91F7B4"




//string function Nemesis_GetDeltaAnimations(entity weapon)





// script gp()[0].GetActiveWeapon(eActiveInventorySlot.mainHand).GetWeaponViewmodel().Anim_NonScriptedPlay("animseq/weapons/nemesis/ptpov_nemesis/idle_nemesis_layer.rseq")


//{


// entity vm = weapon.GetWeaponViewmodel()



//}

//
//GetAnimFromRef
//GetAnimFromString?
//PlayAnimFromRef?


////// ANIMATION METHODS FOR REFERENCE



// ent.Anim_GetAttachmentAtTime(anim, attachName, 0.0)
// ent.Anim_GetStartForRefPoint(anim, origin, angles)
// ent.Anim_GetStartTime()
// Attachment result = dropship.Anim_GetAttachmentAtTime(anim, attach, time) (sh_flightpath.gnut)
// Attachment result = pete.Anim_GetAttachmentAtTime(anim, attachName, 0.0) (sh_flightpath.gnut)
// vector startPos = target.Anim_GetStartForRefEntity( anim, target, "" ).origin (_bleedout.gnut)
// vector animMotionDelta = target.GetAnimDeltas( animID, 0, 1) (_bleedout.gnut)
// ent.GetAnimDeltas(sequenceIdx, 0, 1)
// GetAnimFromAlias(settings, expect string(e.animSet.firstPersonStandingAlias)) (sh_titan_embark.gnut)
// rodeoPanel.Anim_Play( GetAnimFromAlias(titanType, "hatch_rodeo_up_idle") ) (sh_titan.gnut)
// batteryContainer.Anim_Play( GetAnimFromAlias(titanType, "hatch_rodeo_up_idle") ) (sh_titan.gnut)
// marvin.targetAnimation3pStart = "mv_leech_start" <- the engine uses the RSEQ names to play animations, not individual SMD / DMX animation names



// from sh_hover_vehicle.gnut:

/*
        [...]

	if( trident.GetModelName() != $"mdl/vehicle/olympus_hovercraft/olympus_hovercraft_v2.rmdl" )
		return
	
	if( !ENABLE_TRIDENT_ANIMS )
		return
	
	string animtoplay
	
	switch(index)
	{
		case 1:
			animtoplay = "animseq/vehicle/olympus_hovercraft/olympus_hovercraft/hovercraft_activate_chase.rseq"
		break
				
		case 2:
			animtoplay = "animseq/vehicle/olympus_hovercraft/olympus_hovercraft/hovercraft_activate_hover.rseq"
		break
		
		case 3:
			animtoplay = "animseq/vehicle/olympus_hovercraft/olympus_hovercraft/hovercraft_breaking_idle.rseq"
		break


		[...]


	trident.Anim_NonScriptedPlay(animtoplay)
	trident.e.LastTridentAnim = animtoplay
	float maxTime = Time() + trident.GetSequenceDuration(animtoplay)



*/





// UNUSED

///////////////////////
// if (ASSET_ID != $"")
//{
//thread function(): (vm, ASSET_ID)
//{
//}()
//}
//////////////////////





/////////////////////////////



struct NemesisData
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

/*
	for(int chargeIndex = 0, chargeIndex < NUMBER_OF_MODS, chargeIndex++)


// chargeIndex already exists at this scope error??? WTF, it's a local variable...

{

NEMESIS_CHARGE_THRESHOLDS[chargeIndex] = MIN_CHARGE_THRESHOLD + (CHARGE_ADDED_PER_MOD * chargeIndex)


}
*/

}

void function OnWeaponActivate_weapon_nemesis( entity weapon )
{
	#if DEVELOPER
		printt("[NEMESIS] Weapon activated")
	#endif
	
	//Initialize nemesis data if not already present (preserves charge on re-equip)
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

		nemesisData.chargeLevel += NEMESIS_CHARGE_PER_SHOT

//////////////////////////
	#if CLIENT
	thread Nemesis_VisualsWatcher(weapon)
	thread Nemesis_DecayWatcher(weapon)
	//thread Nemesis_AnimationHandler(weapon)
    #endif

//////////////////////////

		printt("NEMESIS CHARGE CHANGED")
		
		#if DEVELOPER
			// if ( oldCharge != nemesisData.chargeLevel )
				printt("[NEMESIS] Charge changed:", oldCharge, "->", nemesisData.chargeLevel)
			// printt("[NEMESIS] Charge added: ",  nemesisData.chargeLevel - oldCharge)
		#endif
		
		//Update charge mod if charge level changed significantly
		#if SERVER
		if ( fabs(oldCharge - nemesisData.chargeLevel) > NEMESIS_CHARGE_EPSILON )

			UpdateChargeMod( weapon )
        #endif  
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

// #endif






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



#if SERVER

// ACTIVITIES REFERENCE

// ACT_VM_DRAW 
// ACT_VM_ONEHANDED_DRAW
// ACT_VM_DRAWFIRST
// ACT_VM_ONEHANDED_DRAWFIRST
// ACT_VM_DRAW_TO_SPRINT
// ACT_VM_PRIMARYATTACK
// ACT_VM_ONEHANDED_PRIMARYATTACK
// ACT_VM_HOLSTER
// ACT_VM_ONEHANDED_HOLSTER
// ACT_VM_WEAPON_INSPECT
// ACT_VM_LOWER
// ACT_VM_ONEHANDED_LOWER
// ACT_VM_RAISE_FROM_MELEE
// ACT_VM_ONEHANDED_RAISE_FROM_MELEE
// ACT_VM_RAISE
// ACT_VM_ONEHANDED_RAISE
// ACT_VM_RELOAD
// ACT_VM_RELOAD_LATE1
// ACT_VM_ONEHANDED_RELOAD_LATE1 
// ACT_VM_ONEHANDED_RELOAD
// ACT_VM_RELOADEMPTY
// ACT_VM_RELOADEMPTY_LATE1
// ACT_VM_ONEHANDED_RELOADEMPTY_LATE1
// ACT_VM_RELOADEMPTY_LATE2
// ACT_VM_IDLE


// ACT_VM_CHARGE_VER4


// ANIM TESTING AND DEBUGGING HELPER FUNCTION


void function Nemesis_DEBUGPLAYACTIVITY(string ACTIVITY_NAME_STRING, bool STARTORSTOP) // bool THREADOFF)

{


entity player = GetPlayerArray()[0]


entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand)

entity vm = weapon.GetWeaponViewmodel()

if (IsAlive(player))

{
 
if (STARTORSTOP)

{

// float duration = vm.GetSequenceDuration(ACTIVITY_NAME_STRING)

// float finishTime = Time() + duration


weapon.StartCustomActivity(ACTIVITY_NAME_STRING, 0)
 
printt("Playing activity " + ACTIVITY_NAME_STRING)


}



}


else

{


weapon.StopCustomActivity()

printt("Stopped activity " + ACTIVITY_NAME_STRING)


}


}

#endif



#if CLIENT 


void function Nemesis_DEBUGPLAYANIM(string ANIM_NAME_STRING, bool STARTORSTOP, bool THREADOFF)
{

entity player = GetPlayerArray()[0]


entity weapon = player.GetActiveWeapon( eActiveInventorySlot.mainHand)

entity vm = weapon.GetWeaponViewmodel()

if (IsAlive(player))

{
 
if (STARTORSTOP && THREADOFF) 

{
thread function():( player, weapon, vm, ANIM_NAME_STRING ) {


float duration = vm.GetSequenceDuration(ANIM_NAME_STRING)

float finishTime = Time() + duration

while (Time() <= finishTime) 


{

vm.Anim_NonScriptedPlay(ANIM_NAME_STRING)

printt("Playing animation " + ANIM_NAME_STRING + " in thread")

WaitFrame()

}

}()

}

else if(STARTORSTOP && !THREADOFF)

{


vm.Anim_NonScriptedPlay(ANIM_NAME_STRING)

printt("Playing animation " + ANIM_NAME_STRING + " non-threaded")


}

else if(!STARTORSTOP)

{


vm.Anim_Stop()

printt("Stopped animation " + ANIM_NAME_STRING)


}


}



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

/////////////// NEMESIS DECAY 





void function Nemesis_DecayWatcher( entity weapon )

{

EndSignal(weapon, "OnDestroy")

//if (!"VisualsThreadActive"in weapon.s) 

//{

//weapon.s.VisualsThreadActive <- true


NemesisData nemesisData = file.nemesisDataTable[weapon]


//}
printt("Nemesis_DecayWatcher block 1")

OnThreadEnd(
		function() : ( weapon, nemesisData )
	{
	//	if ( IsValid( weapon ) && "VisualsThreadActive" in weapon.s )
	//	{
	//		delete weapon.s.VisualsThreadActive
	//	}
	     if (nemesisData.chargeIsDecaying)
            nemesisData.chargeIsDecaying = false
		}
	)


while (IsValid(weapon))
	{

// NemesisData nemesisData = file.nemesisDataTable[weapon] 

//var OldKVString = weapon.kv.rendercolor


float timeSinceLastFire = Time() - nemesisData.lastFireTime

// nemesisData.lastFireTime = Time()

float paramValueFromChargeLerpDecay

if (timeSinceLastFire > NEMESIS_DECAY_DELAY )

{

while (nemesisData.chargeLevel > 0)

	{

nemesisData.chargeIsDecaying = true	

if (nemesisData.chargeLevel - 0.01 <= 0)

		{


nemesisData.chargeIsDecaying = false

break

		}

nemesisData.chargeLevel-= NEMESIS_DECAY_EPSILON // 0.00008 // NEMESIS_CHARGE_PER_SHOT



float f_RedValue_d = GraphCapped(timeSinceLastFire, NEMESIS_DECAY_DELAY, NEMESIS_DECAY_DELAY + NEMESIS_TIME_TO_FULL_DISCHARGE, 255.0, 0.0) // GraphCapped(nemesisData.chargeLevel, 0.0, 1.01, 255.0, 0.0) 

// set charge max clamp to 1.01 to make sure it surpasses the 1.0 threshold the NEMESIS_CHARGE_THRESHOLDS array

float f_GreenValue_d = GraphCapped(timeSinceLastFire, NEMESIS_DECAY_DELAY, NEMESIS_DECAY_DELAY + NEMESIS_TIME_TO_FULL_DISCHARGE, 255.0, 0.0)// GraphCapped(V, A, B, C, D), where V = current charge level, A = color clamp min, B = color clamp max, C = charge level min, D = charge level max

float f_BlueValue_d = GraphCapped(timeSinceLastFire, NEMESIS_DECAY_DELAY, NEMESIS_DECAY_DELAY + NEMESIS_TIME_TO_FULL_DISCHARGE, 255.0, 0.0) // GraphCapped(V, A, B, C, D), where V = current charge level, A = color clamp min, B = color clamp max, C = charge level min, D = charge level max

string NewKVString_d = Nemesis_GetEmissiveRenderColorKVString(f_RedValue_d, f_GreenValue_d, f_BlueValue_d) // , weapon)


paramValueFromChargeLerpDecay = GraphCapped(nemesisData.chargeLevel, 0.0, 1.0, 0.0, 1.0)



// printt("[NEMESIS] NEW DECAY RGB VALUES ARE: " + NewKVString_d)

weapon.kv.rendercolor = NewKVString_d

entity player = weapon.GetWeaponOwner()

if (!IsValid(player))
return

// printt("[NEMESIS] Magnet Latch LERP Value (Script Pose Param 0) for charge DECAY is " + paramValueFromChargeLerpDecay)

weapon.SetScriptPoseParam0(paramValueFromChargeLerpDecay)

wait NEMESIS_DECAY_LERP_TIME // 0.005


	}


}

//if (NewKVString != OldKVString.tostring())

//{
// printt("[NEMESIS]: New KV String is: " + NewKVString)
//}


// printt("[NEMESIS] Time since last fire = " + timeSinceLastFire.tostring())	


WaitFrame()

	}


}




/////////////////////////




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




/*
void function CalculateChargeThresholds(int modsNumber, float minCharge, float maxCharge, float chargePerMod)


{

for(int chargeIndex = 0, chargeIndex < NUMBER_OF_MODS, chargeIndex++)

{

NEMESIS_CHARGE_THRESHOLDS[chargeIndex] = MIN_CHARGE_THRESHOLD + (CHARGE_ADDED_PER_MOD * chargeIndex)


}



}
*/