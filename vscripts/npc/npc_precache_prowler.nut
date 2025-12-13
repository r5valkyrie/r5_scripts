global function NPCPrecache_Prowler

const asset MODEL_NPC_PROWLER = $"mdl/Creatures/prowler/prowler_apex.rmdl"

void function NPCPrecache_Prowler()
{
	PrecacheModel( MODEL_NPC_PROWLER )
	SetNPCAsset( eNPC.PROWLER, eNPCAsset.BODY, MODEL_NPC_PROWLER )
	//PrecacheObjectiveAsset_FX( "PROWLER_EYEGLOW_FX", $"P_infected_prowler_head" )
	//PrecacheObjectiveAsset_FX( "PROWLER_EYEGLOW_SHADOW_FX", $"P_BShadow_prowler_head" )
}