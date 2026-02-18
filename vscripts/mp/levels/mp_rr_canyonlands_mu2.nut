global function CodeCallback_MapInit
global function CryptoTTButton

const array <string> dialogue_ash = [
	"diag_mp_questTBG_assembleRelic_relicAi_02_3p"
	"diag_mp_questTBG_assembleRelic_relicAi_03_3p"
	"diag_mp_questTBG_assembleRelic_relicAi_04_3p"
	"diag_mp_questTBG_assembleRelic_relicAi_05_3p"
	"diag_mp_questTBG_assembleRelic_relicAi_06_3p"
	"diag_mp_questTBG_assembleRelic_relicAi_07_3p"
	"diag_mp_questTBG_assembleRelic_relicAi_08_3p"
	"diag_mp_questTBG_assembleRelic_relicAi_09_3p"
	"diag_mp_questTBG_assembleRelic_relicAi_10_3p"
	"diag_mp_questTBG_assembleRelic_relicAi_11_3p"
	"diag_mp_questTBG_assembleRelic_relicAi_12_3p"
	"diag_mp_questTBG_assembleRelic_relicAi_13_3p"
	"diag_mp_questTBG_assembleRelic_relicAi_14_3p"
	"diag_mp_questTBG_assembleRelic_relicAi_15_3p"
	"diag_mp_questTBG_assembleRelic_relicAi_16_3p"
	"diag_mp_questTBG_assembleRelic_relicAi_17_3p"
]

void function CodeCallback_MapInit()
{
	thread InitLootRollers()

	if (GetMapName() == "mp_rr_canyonlands_mu2_mv" )
		MapZones_RegisterDataTable( $"datatable/map_zones/zones_mp_rr_canyonlands_mu2_mv.rpak" )
	else if (GetMapName() == "mp_rr_canyonlands_mu2_tt" )
	{
		MapZones_RegisterDataTable( $"datatable/map_zones/zones_mp_rr_canyonlands_mu2_tt.rpak" )
	}
	else
		MapZones_RegisterDataTable( $"datatable/map_zones/zones_mp_rr_canyonlands_mu2.rpak" )
}