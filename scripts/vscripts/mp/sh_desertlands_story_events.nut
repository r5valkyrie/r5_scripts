global function DesertlandsStoryEvents_Init

#if SERVER
const asset HARVEST_BEAM_FX 	= $"P_lava_harvest_beam_mu1"
const vector HARVEST_BEAM_ORIGIN = <-2564.53, -11268.6, -4000.03>
const asset HARVEST_BEAM_SKY_FX = $"P_lava_harvest_beam_mu1_sb"
#endif

struct
{
	entity beamFX

} file


// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
//
//  #### ##    ## #### ########
//   ##  ###   ##  ##     ##
//   ##  ####  ##  ##     ##
//   ##  ## ## ##  ##     ##
//   ##  ##  ####  ##     ##
//   ##  ##   ###  ##     ##
//  #### ##    ## ####    ##
//
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================
// =================================================================================================================================


void function DesertlandsStoryEvents_Init()
{
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )

	#if SERVER
		PrecacheParticleSystem( HARVEST_BEAM_FX )
		PrecacheParticleSystem( HARVEST_BEAM_SKY_FX )
	#endif
}

void function EntitiesDidLoad()
{
	#if SERVER
	if ( GetMapName() == "mp_rr_desertlands_mu1" || GetMapName() == "mp_rr_desertlands_mu2" )
		HarvesterFX_Init()
	#endif

}

#if SERVER
void function HarvesterFX_Init()
{
	printt( "HarvestorFX _Init()" )
	file.beamFX = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( HARVEST_BEAM_FX ), HARVEST_BEAM_ORIGIN, <0, 0, 0> )
	entity beamFX_skybox = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( HARVEST_BEAM_SKY_FX ), <-22202.556641, 700.704834,-26997.375000 >, <0, 0, 0> )
	beamFX_skybox.kv.in_skybox = true
}
#endif