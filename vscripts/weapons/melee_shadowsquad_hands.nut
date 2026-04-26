global function MeleeShadowsquadHands_Init

global function OnWeaponActivate_melee_shadowsquad_hands
global function OnWeaponDeactivate_melee_shadowsquad_hands

const SHADOWHANDS_FX_ATTACK_SWIPE_FP = $"P_wpn_bhaxe_swipe_FP"
const SHADOWHANDS_FX_ATTACK_SWIPE_3P = $"P_wpn_bhaxe_swipe_3P"

void function MeleeShadowsquadHands_Init()
{
	PrecacheParticleSystem( SHADOWHANDS_FX_ATTACK_SWIPE_FP )
	PrecacheParticleSystem( SHADOWHANDS_FX_ATTACK_SWIPE_3P )
}

// this weapon is only used for attacks (not "primary weapon" idling onscreen)
// - activate = attack start; deactivate = attack finished
void function OnWeaponActivate_melee_shadowsquad_hands( entity weapon )
{
	//printt( "melee_shadowsquad_hands activated" )
	//weapon.PlayWeaponEffect( SHADOWHANDS_FX_ATTACK_SWIPE_FP, SHADOWHANDS_FX_ATTACK_SWIPE_3P, "FX_CROW_MOUTH" )
}

void function OnWeaponDeactivate_melee_shadowsquad_hands( entity weapon )
{
	//printt( "melee_shadowsquad_hands deactivated" )
	//weapon.StopWeaponEffect( SHADOWHANDS_FX_ATTACK_SWIPE_FP, SHADOWHANDS_FX_ATTACK_SWIPE_3P )

}