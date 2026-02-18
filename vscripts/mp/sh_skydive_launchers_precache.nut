global function ShPrecacheSkydiveLauncherAssets

void function ShPrecacheSkydiveLauncherAssets()
{
	FX_SKYDIVE_LAUNCHER_LOOP_DEFAULT = $"P_launchpad_winter" //$"P_item_loot_LG" //$"P_ar_titan_droppoint"  //P_ar_loot_drop_point
	FX_SKYDIVE_LAUNCHER_LOOP_NO_SNOW = $"P_launchpad_winter_AR"
	PrecacheParticleSystem( FX_SKYDIVE_LAUNCHER_LOOP_DEFAULT )
	PrecacheParticleSystem( FX_SKYDIVE_LAUNCHER_LOOP_NO_SNOW )

	#if SERVER
		FX_SKYDIVE_LAUNCHER_LAUNCH = $"P_launchpad_winter_engage"
		MODEL_SKYDIVE_LAUNCHER_DEFAULT = $"mdl/s2s/s2s_hullhatch_tube_lift.rmdl"
		PrecacheModel( MODEL_SKYDIVE_LAUNCHER_DEFAULT )
		PrecacheParticleSystem( FX_SKYDIVE_LAUNCHER_LAUNCH )
	#endif
}