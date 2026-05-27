global function BreakableCrystals_Init

enum CrystalSectionState
{
	Intact,
    Cracked,
    Broken
}

struct SectionData
{
    float health
    float crackedHealth
    float maxHealth
    int state
    vector effectsOrigin
    vector effectsAngles
    vector effectsScale
}

struct CrystalData
{
    SectionData topSection
    SectionData bottomSection
    float topSectionHeight
}

struct
{
    table< entity, CrystalData > crystalsData
} file

const bool DEBUG_CRYSTALS = false

const float CRYSTAL_TOP_CRACKED_HEALTH = 100.0
const float CRYSTAL_TOP_HEALTH = 200.0
const float CRYSTAL_BOTTOM_CRACKED_HEALTH = 100.0
const float CRYSTAL_BOTTOM_HEALTH = 200.0

const asset CRYSTAL_BOTTOM_INTACT_TOP_INTACT = $"mdl/props/crystal_shard_01/crystal_shard_intact_01.rmdl"
const asset CRYSTAL_BOTTOM_INTACT_TOP_CRACKED = $"mdl/props/crystal_shard_01/crystal_shard_intact_damaged_01.rmdl"
const asset CRYSTAL_BOTTOM_INTACT_TOP_BROKEN = $"mdl/props/crystal_shard_01/crystal_shard_broken_01.rmdl"

const asset CRYSTAL_BOTTOM_CRACKED_TOP_INTACT = $"mdl/props/crystal_shard_01/crystal_shard_intact_bottom_damaged_01.rmdl"
const asset CRYSTAL_BOTTOM_CRACKED_TOP_CRACKED = $"mdl/props/crystal_shard_01/crystal_shard_intact_full_damaged_01.rmdl"
const asset CRYSTAL_BOTTOM_CRACKED_TOP_BROKEN = $"mdl/props/crystal_shard_01/crystal_shard_broken_damaged_01.rmdl"

const asset CRYSTAL_BOTTOM_BROKEN_TOP_BROKEN = $""

const asset CRYSTAL_BREAK_FX = $"P_env_TD2_smkScreen_init"

const float SECTION_DIVISION_THRESHOLD = 0.5 //50% top of the crystal will be considered the top section, bottom 50% the bottom

void function BreakableCrystals_Init()
{
#if DEBUG_CRYSTALS
    printt("BC: Crystal Init")
#endif

    PrecacheBreakableCrystals()

    AddSpawnCallback_ScriptName( "script_breakable_crystal", BreakableCrystals_Spawn )
}

void function PrecacheBreakableCrystals()
{
    PrecacheModel( CRYSTAL_BOTTOM_INTACT_TOP_INTACT )
    PrecacheModel( CRYSTAL_BOTTOM_INTACT_TOP_CRACKED )
    PrecacheModel( CRYSTAL_BOTTOM_INTACT_TOP_BROKEN )

    PrecacheModel( CRYSTAL_BOTTOM_CRACKED_TOP_INTACT )
    PrecacheModel( CRYSTAL_BOTTOM_CRACKED_TOP_CRACKED )
    PrecacheModel( CRYSTAL_BOTTOM_CRACKED_TOP_BROKEN )

    if ( CRYSTAL_BOTTOM_BROKEN_TOP_BROKEN != $"" )
        PrecacheModel( CRYSTAL_BOTTOM_BROKEN_TOP_BROKEN )

    PrecacheParticleSystem( CRYSTAL_BREAK_FX )
}

void function BreakableCrystals_Spawn( entity crystal )
{
#if DEBUG_CRYSTALS
    printt("BC: Crystal spawned")
#endif

    crystal.SetCanBeMeleed( true )
	crystal.SetTakeDamageType( DAMAGE_YES )
	crystal.SetDamageNotifications( true )
	crystal.SetDeathNotifications( true )
	crystal.SetTouchTriggers( true )
	crystal.SetMaxHealth( 100000 ) //Fake health numbers so the entity doesn't die before its sections
	crystal.SetHealth( 100000 )
	crystal.DisableHibernation()

    crystal.e.noOwnerFriendlyFire       = false
	crystal.e.noFriendlyFireProtection  = false
	crystal.e.canBurn                   = true
	crystal.e.canBeDamagedFromGas       = false
    crystal.e.canStickArrows            = false
    crystal.e.preventStickyEnts         = false

    AddEntityCallback_OnPostDamaged( crystal, BreakableCrystals_OnDamaged )
	AddEntityCallback_OnKilled( crystal, BreakableCrystals_OnKilled )

    CrystalData crystalData

    float crystalHeight = (crystal.GetBoundingMaxs().z - crystal.GetBoundingMins().z)

    crystalData.topSectionHeight = crystalHeight * SECTION_DIVISION_THRESHOLD

    crystalData.topSection.health = CRYSTAL_TOP_HEALTH
    crystalData.topSection.crackedHealth = CRYSTAL_TOP_CRACKED_HEALTH
    crystalData.topSection.maxHealth = CRYSTAL_TOP_HEALTH
    crystalData.topSection.state = CrystalSectionState.Intact
    crystalData.topSection.effectsOrigin = crystal.GetOrigin() + (crystal.GetUpVector() * crystalData.topSectionHeight)
    crystalData.topSection.effectsAngles = crystal.GetAngles()

    #if DEBUG_CRYSTALS
        DebugDrawCube( crystalData.topSection.effectsOrigin, 10, COLOR_GREEN, true, 300.0 )
    #endif

    crystalData.bottomSection.health = CRYSTAL_BOTTOM_HEALTH
    crystalData.bottomSection.crackedHealth = CRYSTAL_BOTTOM_CRACKED_HEALTH
    crystalData.bottomSection.maxHealth = CRYSTAL_BOTTOM_HEALTH
    crystalData.bottomSection.state = CrystalSectionState.Intact
    crystalData.bottomSection.effectsOrigin = crystal.GetOrigin()
    crystalData.bottomSection.effectsAngles = crystal.GetAngles()

    file.crystalsData[crystal] <- crystalData
}

bool function BreakableCrystals_UpdateSection( entity crystal, SectionData section )
{
    if ( section.health <= 0.0 && section.state != CrystalSectionState.Broken )
    {
        EmitSoundAtPosition( TEAM_ANY, section.effectsOrigin, "corporate_spectre_death_explode", crystal )
        StartParticleEffectInWorld( GetParticleSystemIndex( CRYSTAL_BREAK_FX ), section.effectsOrigin, section.effectsAngles )

        section.health = 0.0
        section.state = CrystalSectionState.Broken
        return true
    }
    else if ( section.health > 0.0 && section.health <= section.crackedHealth && section.state != CrystalSectionState.Cracked )
    {
        //Play VFX/SFX
        section.state = CrystalSectionState.Cracked
        return true
    }
    else if ( section.health > section.crackedHealth && section.state != CrystalSectionState.Intact )
    {
        //Let's support healing for completeness sake, but it's not used in the game at this time
        section.state = CrystalSectionState.Intact
        return true
    }

    return false
}

void function BreakableCrystals_UpdateModel( entity crystal, CrystalData crystalData )
{
    //Bottom intact
    if ( crystalData.bottomSection.state == CrystalSectionState.Intact && crystalData.topSection.state == CrystalSectionState.Intact )
    {
        crystal.SetModel( CRYSTAL_BOTTOM_INTACT_TOP_INTACT )
    }
    else if ( crystalData.bottomSection.state == CrystalSectionState.Intact && crystalData.topSection.state == CrystalSectionState.Cracked )
    {
        crystal.SetModel( CRYSTAL_BOTTOM_INTACT_TOP_CRACKED )
    }
    else if ( crystalData.bottomSection.state == CrystalSectionState.Intact && crystalData.topSection.state == CrystalSectionState.Broken )
    {
        crystal.SetModel( CRYSTAL_BOTTOM_INTACT_TOP_BROKEN )
    }
    //Bottom cracked
    else if ( crystalData.bottomSection.state == CrystalSectionState.Cracked && crystalData.topSection.state == CrystalSectionState.Intact )
    {
        crystal.SetModel( CRYSTAL_BOTTOM_CRACKED_TOP_INTACT )
    }
    else if ( crystalData.bottomSection.state == CrystalSectionState.Cracked && crystalData.topSection.state == CrystalSectionState.Cracked )
    {
        crystal.SetModel( CRYSTAL_BOTTOM_CRACKED_TOP_CRACKED )
    }
    else if ( crystalData.bottomSection.state == CrystalSectionState.Cracked && crystalData.topSection.state == CrystalSectionState.Broken )
    {
        crystal.SetModel( CRYSTAL_BOTTOM_CRACKED_TOP_BROKEN )
    }
    //Bottom broken
    else if ( crystalData.bottomSection.state == CrystalSectionState.Broken )
    {
        crystal.SetHealth( 0 )
    }
}

void function BreakableCrystals_UpdateState( entity crystal, CrystalData crystalData )
{
    #if DEBUG_CRYSTALS
        printt( "BC: Current state" )
        printt( "BC: Top health -", crystalData.topSection.health )
        printt( "BC: Top state -", crystalData.topSection.state )
        printt( "BC: Bottom health -", crystalData.bottomSection.health )
        printt( "BC: Bottom state -", crystalData.bottomSection.state )
    #endif

    bool needsUpdate = BreakableCrystals_UpdateSection( crystal, crystalData.topSection ) || BreakableCrystals_UpdateSection( crystal, crystalData.bottomSection )

    if ( !needsUpdate )
        return

    #if DEBUG_CRYSTALS
        printt( "BC: Needs update!" )
        printt( "BC: Top health -", crystalData.topSection.health )
        printt( "BC: Top state -", crystalData.topSection.state )
        printt( "BC: Bottom health -", crystalData.bottomSection.health )
        printt( "BC: Bottom state -", crystalData.bottomSection.state )
    #endif

    BreakableCrystals_UpdateModel( crystal, crystalData )
}

bool function BreakableCrystals_ShouldDamageTop( entity crystal, vector damagePosition, CrystalData crystalData )
{
    vector localDamagePosition = CalcWorldToLocalOrigin_Entity( crystal, damagePosition )

    return localDamagePosition.z > crystalData.topSectionHeight
}

void function BreakableCrystals_OnDamaged( entity crystal, var damageInfo )
{
#if DEBUG_CRYSTALS
    printt("BC: Crystal damaged")
#endif
    if ( !(crystal in file.crystalsData) )
        return

    vector damagePosition = DamageInfo_GetDamagePosition( damageInfo )

    CrystalData crystalData = file.crystalsData[crystal]

    float damage = DamageInfo_GetDamage( damageInfo )


    //Top is broken, just damage the bottom
    if ( crystalData.topSection.state == CrystalSectionState.Broken )
    {
        #if DEBUG_CRYSTALS
            printt( "BC: Top is broken, damaging bottom" )
            printt( "BC: Damage -", damage )
            printt( "BC: Bottom health -", crystalData.bottomSection.health )
        #endif

        crystalData.bottomSection.health -= damage

        #if DEBUG_CRYSTALS
            printt( "BC: Bottom new health -", crystalData.bottomSection.health )
            DebugDrawSphere( damagePosition, 25.0, COLOR_MAGENTA, true, 30.0 )
        #endif
    }
    else
    {
        if ( BreakableCrystals_ShouldDamageTop( crystal, damagePosition, crystalData ) )
        {
            #if DEBUG_CRYSTALS
                printt( "BC: Hit top section" )
                printt( "BC: Damage -", damage )
                printt( "BC: Top health -", crystalData.topSection.health )
            #endif

            crystalData.topSection.health -= damage

            #if DEBUG_CRYSTALS
                printt( "BC: Top new health -", crystalData.topSection.health )
                DebugDrawSphere( damagePosition, 25.0, COLOR_GREEN, true, 30.0 )
            #endif
        }
        else
        {
            #if DEBUG_CRYSTALS
                printt( "BC: Hit bottom section" )
                printt( "BC: Damage -", damage )
                printt( "BC: Bottom health -", crystalData.bottomSection.health )
            #endif

            crystalData.bottomSection.health -= damage

             #if DEBUG_CRYSTALS
                 printt( "BC: Bottom new health -", crystalData.bottomSection.health )
                 DebugDrawSphere( damagePosition, 25.0, COLOR_RED, true, 30.0 )
             #endif
        }
    }

    BreakableCrystals_UpdateState( crystal, crystalData )

    entity attacker = DamageInfo_GetAttacker( damageInfo )
    if ( IsValidPlayer( attacker ) )
	{
		attacker.NotifyDidDamage(
			crystal, 0,
			DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ),
			DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ),
			DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ),
			DamageInfo_GetDistFromAttackOrigin( damageInfo )
		)
	}
}

void function BreakableCrystals_OnKilled( entity crystal, var damageInfo )
{
#if DEBUG_CRYSTALS
    printt("BC: Crystal Killed")
#endif

    if ( crystal in file.crystalsData )
    {
        delete file.crystalsData[crystal]
    }
}
 