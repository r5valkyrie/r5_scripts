global const string MOUNTED_TURRET_PLACEABLE_SCRIPT_NAME = "mounted_turret_placeable"
struct
{
	#if SERVER
		table< entity, bool > isTurretEnabled
		table< entity, int > turretToLastAmmoCount
		array < entity > placedTurrets
	#endif

	#if CLIENT
		bool isShowingPlacementFX
	#endif
	table< entity, bool > turretEligibleForRefund
	int maxNumTurretsDeployed
} file

#if SERVER
global function MountedTurretPlaceable_GetLastAmmoCount
global function MountedTurretPlaceable_SetLastAmmoCount


int function MountedTurretPlaceable_GetLastAmmoCount( entity turret )
{
	Assert ( turret in file.turretToLastAmmoCount, "Turret not in file table" )

	if ( turret in file.turretToLastAmmoCount )
		return file.turretToLastAmmoCount[ turret ]

	return 0
}

void function MountedTurretPlaceable_SetLastAmmoCount( entity turret, int ammoCount )
{
	file.turretToLastAmmoCount[ turret ] <- ammoCount
}
#endif