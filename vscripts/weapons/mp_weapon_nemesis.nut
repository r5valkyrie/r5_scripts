global function MpWeaponNemesis_Init
global function OnWeaponActivate_weapon_nemesis
global function OnWeaponDeactivate_weapon_nemesis
global function OnWeaponPrimaryAttack_weapon_nemesis

// (cafe): For visuals, not implemented atm
// Can be used to play heated fx and anim, prob add a networked var and a callback to execute on client
// #if SERVER || CLIENT
// global function OnWeaponHeatStateChanged_weapon_nemesis
// #endif

//Nemesis charge constants
//Retail values - Update each season, calculate how many mods we need based on heat_per_bullet
const float NEMESIS_CHARGE_PER_BURST = 0.1668	//16.68% charge per burst
const float NEMESIS_DECAY_DELAY = 8.0			//8 seconds before decay starts
const float NEMESIS_DECAY_RATE = 0.15			//15% per second decay rate
const float NEMESIS_FULL_CHARGE = 1.0			//100% charge
const float NEMESIS_CHARGE_EPSILON = 0.01		//Small value for float comparison

//Charge level thresholds and corresponding mods
const array<float> NEMESIS_CHARGE_THRESHOLDS = [0.1668, 0.3336, 0.5004, 0.6672, 0.8340, 1.0]
const array<string> NEMESIS_CHARGE_MODS = ["nemesis_charge_1", "nemesis_charge_2", "nemesis_charge_3", "nemesis_charge_4", "nemesis_charge_5", "fully_heated"]

struct NemesisData
{
	float chargeLevel = 0.0
	float lastFireTime = 0.0
	int currentChargeMod = -1
	int shotsInCurrentBurst = 0
	bool decayThreadRunning = false
}

struct{
	table<entity, NemesisData> nemesisDataTable
} file

//Table to store nemesis data per weapon
void function MpWeaponNemesis_Init()
{
	
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
	}
	
	//Start charge decay monitoring (SERVER ONLY, once per weapon)
	#if SERVER
	NemesisData nemesisData = file.nemesisDataTable[weapon]
	if ( !nemesisData.decayThreadRunning )
	{
		RemoveAllChargeMods( weapon ) //Required to avoid crash if charge mods were transferred to a dropped weapon
		
		nemesisData.decayThreadRunning = true
		thread NemesisChargeDecayThink( weapon )
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

var function OnWeaponPrimaryAttack_weapon_nemesis( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetOwner()
	if ( !IsValid(owner) )
		return 0
	
	//Get nemesis data from table
	if ( !(weapon in file.nemesisDataTable) )
		return 0
	
	NemesisData nemesisData = file.nemesisDataTable[weapon]
	
	//Increment shot counter
	nemesisData.shotsInCurrentBurst++
	nemesisData.lastFireTime = Time()
	
	//Get burst fire count from weapon (should be 4 for Nemesis)
	int burstFireCount = weapon.GetWeaponSettingInt( eWeaponVar.burst_fire_count )
	
	weapon.FireWeapon_Default( attackParams.pos, attackParams.dir, 1.0, 1.0, false )
	
	//Check if burst is complete (SERVER ONLY for charge calculation)
	if ( nemesisData.shotsInCurrentBurst >= burstFireCount )
	{
		#if DEVELOPER
			printt("[NEMESIS] Burst completed after", nemesisData.shotsInCurrentBurst, "shots, charge level:", nemesisData.chargeLevel)
		#endif
		
		#if SERVER
		//Add charge (SERVER ONLY)
		float oldCharge = nemesisData.chargeLevel
		nemesisData.chargeLevel += NEMESIS_CHARGE_PER_BURST
		
		//Cap at maximum charge
		if ( nemesisData.chargeLevel > NEMESIS_FULL_CHARGE )
			nemesisData.chargeLevel = NEMESIS_FULL_CHARGE
		
		#if DEVELOPER
			printt("[NEMESIS] Charge added:", oldCharge, "->", nemesisData.chargeLevel)
		#endif
		
		//Update charge mod
		UpdateChargeMod( weapon )
		#endif // SERVER
		
		//Reset shot counter for next burst
		nemesisData.shotsInCurrentBurst = 0
	}
	
	//Use default attack behavior
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}


#if SERVER
void function NemesisChargeDecayThink( entity weapon )
{
	weapon.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( weapon )
		{
			// printw("weapon is not valid anymore" )
			if ( weapon in file.nemesisDataTable )
				delete file.nemesisDataTable[weapon]
		}
	)

	while ( IsValid(weapon) )
	{
		//Check if weapon is still in the table
		if ( !(weapon in file.nemesisDataTable) )
		{
			WaitFrame()
			continue
		}
		
		NemesisData nemesisData = file.nemesisDataTable[weapon]
		
		//Check if enough time has passed since last fire for decay to start
		float timeSinceLastFire = Time() - nemesisData.lastFireTime
		
		if ( timeSinceLastFire >= NEMESIS_DECAY_DELAY && nemesisData.chargeLevel > 0.0 )
		{
			float oldCharge = nemesisData.chargeLevel
			
			//Decay charge at 15% per second
			float decayAmount = NEMESIS_DECAY_RATE * 1.0	//1 second frame
			nemesisData.chargeLevel -= decayAmount
			
			//Don't go below 0
			if ( nemesisData.chargeLevel < 0.0 )
				nemesisData.chargeLevel = 0.0
			
			#if DEVELOPER
				if ( oldCharge != nemesisData.chargeLevel )
					printt("[NEMESIS] Charge decayed:", oldCharge, "->", nemesisData.chargeLevel)
			#endif
			
			//Update charge mod if charge level changed significantly
			if ( fabs(oldCharge - nemesisData.chargeLevel) > NEMESIS_CHARGE_EPSILON )
				UpdateChargeMod( weapon )
		}
		
		wait 1.0	//Check every second for decay
	}
}

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
			
			#if DEVELOPER
				printt("[NEMESIS] Applied charge mod:", newMod, "at charge level:", nemesisData.chargeLevel)
			#endif
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