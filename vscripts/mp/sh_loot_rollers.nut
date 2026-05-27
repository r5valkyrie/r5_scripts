global function ShLootRollers_Init
global function IsLootRoller

#if SERVER
global function ShLootRoller_Spawned
#endif

#if CLIENT
global function ClientCodeCallback_OnLootRollerTierChanged
global function ServerCallback_StopLootRollerFX
#endif //CLIENT

//global function SetLootRollerUsable
//global function SetLootRollerUnUsable

global const asset LOOT_ROLLER_MODEL = $"mdl/props/loot_sphere/loot_sphere.rmdl" //  mdl/weapons_r5/loot/w_loot_msc_iso_sphere_v1.rmdl"
global const asset LOOT_ROLLER_EYE_FX				 	= $"P_loot_ball_flash_CP"
global const int NUM_LOOT_ROLLER_FX_ATTACH_POINTS 		= 12
global const string FX_ATTACH_ROOT_NAME 				= "fx_glow_"
global const asset FX_LOOT_ROLLER_EXPLOSION			= $"P_ball_tick_exp_CP"

global const string LOOT_ROLLER_SCRIPTNAME = "LootRoller"
global const string PARTY_BALL_SCRIPTNAME = "partyball_rotator"

#if CLIENT
struct LootRollerClientData
{
	entity rollerModel
	array<int> eyeFXEnts
	int lootTier = 1
	bool hasVaultKey
}
#endif

struct
{
	array< entity > allLootRollers
	//array< entity > usableLootRollers

	table< entity, array< void functionref( entity, var ) > > Callbacks_OnLootRollerDamaged
	table< entity, array< void functionref( entity, var ) > > Callbacks_OnLootRollerKilled

	#if CLIENT
		table<entity, LootRollerClientData> rollerToClientData
	#endif
} file

void function ShLootRollers_Init()
{
	PrecacheParticleSystem( LOOT_ROLLER_EYE_FX )

	#if SERVER
		AddSpawnCallback( "prop_lootroller", ShLootRoller_Spawned )
	#endif

	#if CLIENT
		AddCreateCallback( "prop_lootroller", ShLootRoller_Spawned )
	#endif
}

void function ShLootRoller_Spawned( entity ent )
{
	if ( ent.GetModelName().tolower() != LOOT_ROLLER_MODEL.tolower() )
		return

	file.allLootRollers.append( ent )

	#if SERVER
	ent.DisallowZiplines()
	#endif

	#if CLIENT
	LootRollerClientData data
	data.rollerModel = ent
	if ( ent.GetTier() > 1 )
		data.lootTier = ent.GetTier()
	data.hasVaultKey = ent.GetHasVaultKey()

	int fxIdx = GetParticleSystemIndex( LOOT_ROLLER_EYE_FX )
	for( int i; i < NUM_LOOT_ROLLER_FX_ATTACH_POINTS; i++ )
	{
		int suffixIdx = i + 1
		string attachSuffix = string( suffixIdx )
		//if ( suffixIdx < 10 )
		//	attachSuffix = "0" + attachSuffix

		int attachIdx = ent.LookupAttachment( FX_ATTACH_ROOT_NAME + attachSuffix )
		int newFx = StartParticleEffectOnEntity( ent, fxIdx, FX_PATTACH_POINT_FOLLOW, attachIdx )
		data.eyeFXEnts.append( newFx )
		EffectSetControlPointColorById( newFx, 1, COLORID_FX_LOOT_TIER0 + data.lootTier )
	}

	if ( data.hasVaultKey && data.eyeFXEnts.len() > 0 )
	{
		int randEye = data.eyeFXEnts[ RandomInt( data.eyeFXEnts.len() - 1 ) ]
		EffectSetControlPointColorById( randEye, 1, COLORID_FX_LOOT_TIER0 + 5 )
	}

	SetLootRollerClientData( data )

	//AddEntityCallback_OnDamaged( ent, OnLootRollerDamaged )
	#endif
}

void function OnLootRollerDamaged( entity roller, var damageInfo )
{
	int health = roller.GetHealth()
	float damage = DamageInfo_GetDamage( damageInfo )
	int remainingHealth = (health - int(damage))
	if( remainingHealth <= 0 )
	{
		#if CLIENT
		LootRollerClientData clientData = GetLootRollerClientDataFromEnt( roller )

		foreach( eye in clientData.eyeFXEnts )
		{
			EffectStop( eye, false, true )
		}
		#endif //CLIENT
	}
}

bool function IsLootRoller( entity ent )
{
	return file.allLootRollers.contains( ent )
}

#if CLIENT
void function SetLootRollerClientData( LootRollerClientData data )
{
	entity roller = data.rollerModel

	if ( roller in file.rollerToClientData )
		return

	file.rollerToClientData[ roller ] <- data
}

LootRollerClientData function GetLootRollerClientDataFromEnt( entity ent )
{
	Assert( ent in file.rollerToClientData, "Attempted to get Loot Roller Client data from a roller that's not in the table!" )

	return file.rollerToClientData[ ent ]
}

void function ClientCodeCallback_OnLootRollerTierChanged( entity roller, int tier, bool hasVaultKey )
{
	vector tierColor = GetFXRarityColorForTier( tier )
	string tierColorString = format("%f %f %f", tierColor.x, tierColor.y, tierColor.z )
	roller.kv.rendercolor = tierColorString

	LootRollerClientData rollerData = GetLootRollerClientDataFromEnt( roller )
	rollerData.lootTier = tier
	rollerData.hasVaultKey = hasVaultKey

	foreach (fx in rollerData.eyeFXEnts )
	{
		EffectSetControlPointColorById( fx, 1, COLORID_FX_LOOT_TIER0 + rollerData.lootTier )
	}

	int fxCount = GetCurrentPlaylistVarInt( "loot_rollers_vault_key_fx_hints", 3 )

	if ( fxCount > 0 && rollerData.hasVaultKey && rollerData.eyeFXEnts.len() > 0 )
	{
		array<int> randomEyes
		int eyeCount = rollerData.eyeFXEnts.len()
		fxCount = minint( fxCount, eyeCount )
		for ( int i = 0; i < fxCount; i++ )
		{
			int randomIdx = RandomInt( rollerData.eyeFXEnts.len() - 1 )
			randomEyes.append( randomIdx )
		}

		foreach ( idx in randomEyes )
		{
			int randEye = rollerData.eyeFXEnts[ idx ]
			EffectSetControlPointColorById( randEye, 1, COLORID_FX_LOOT_TIER0 + 5 )
		}
	}
}

void function ServerCallback_StopLootRollerFX( int rollerHandle )
{
	entity roller = GetEntityFromEncodedEHandle( rollerHandle )

	if ( !IsValid( roller ) )
		return

	LootRollerClientData rollerData = GetLootRollerClientDataFromEnt( roller )
	foreach ( fx in rollerData.eyeFXEnts )
		EffectStop( fx, false, true )
}
#endif //CLIENT

//void function SetLootRollerUsable( entity lootRollerEnt )
//{
//	if ( file.usableLootRollers.contains( lootRollerEnt ) )
//		return
//
//	#if SERVER
//	printf( "LootRollerDebug: Loot Roller Set to Usable (entity: %s)", string( lootRollerEnt ) )
//	lootRollerEnt.SetUsable()
//	lootRollerEnt.SetUsableByGroup( "pilot" )
//	//lootRollerEnt.SetUsePrompts( "#LOOT_ROLLER_HINT", "#LOOT_ROLLER_HINT" )
//	lootRollerEnt.AddUsableValue( USABLE_CUSTOM_HINTS )
//	AddCallback_OnUseEntity( lootRollerEnt, OnLootRollerUse )
//	#endif //SERVER
//
//	#if CLIENT
//	AddCallback_OnUseEntity( lootRollerEnt, OnLootRollerUse )
//	#endif //CLIENT
//
//	file.usableLootRollers.append( lootRollerEnt )
//}
//
//void function OnLootRollerUse( entity lootRollerEnt, entity playerUser, int useInputFlags )
//{
//	if ( useInputFlags & USE_INPUT_LONG )
//	{
//		printf( "LootRollerDebug: OnLootRollerUse" )
//		thread LootRollerUseThink( lootRollerEnt, playerUser )
//	}
//}
//
//const float LOOT_ROLLER_USE_TIME = 5.0
//void function LootRollerUseThink( entity lootRollerEnt, entity playerUser )
//{
//	ExtendedUseSettings settings
//
//	settings.duration = LOOT_ROLLER_USE_TIME
//	settings.requireMatchingUseEnt = true
//	#if SERVER
//	settings.successFunc = LootRollerUseSuccess
//	#endif
//	#if CLIENT
//	settings.loopSound = "survival_titan_linking_loop"
//	settings.successSound = "ui_menu_store_purchase_success"
//	settings.displayRuiFunc = DisplayRuiForLootRoller
//	settings.displayRui = $"ui/health_use_progress.rpak"
//	settings.hint = "#LOOT_ROLLER_HINT"
//	#endif
//
//	lootRollerEnt.EndSignal( "OnDestroy" )
//
//	waitthread ExtendedUse( lootRollerEnt, playerUser, settings )
//}
//
//void function SetLootRollerUnUsable( entity lootRollerEnt )
//{
//	if ( !file.usableLootRollers.contains( lootRollerEnt ) )
//		return
//
//	#if SERVER
//	printf( "LootRollerDebug: Loot Roller Set to Unusable (entity: %s)", string( lootRollerEnt ) )
//	lootRollerEnt.UnsetUsable()
//	#endif //SERVER
//
//	RemoveCallback_OnUseEntity( lootRollerEnt, OnLootRollerUse )
//	file.usableLootRollers.removebyvalue( lootRollerEnt )
//}
//
//#if SERVER
//void function LootRollerUseSuccess( entity lootRollerEnt, entity player, ExtendedUseSettings settings )
//{
//	LootRollerData data = GetLootRollerDataFromRollerModel( lootRollerEnt )
//	data.canExplode = false
//
//	DestroyLootRoller( data )
//}
//#endif //SERVER
//
//#if CLIENT
//void function DisplayRuiForLootRoller( entity ent, entity player, var rui, ExtendedUseSettings settings )
//{
//	DisplayRuiForLootRoller_Internal( rui, settings.icon, Time(), Time() + settings.duration, settings.hint )
//}
//
//void function DisplayRuiForLootRoller_Internal( var rui, asset icon, float startTime, float endTime, string hint )
//{
//	RuiSetBool( rui, "isVisible", true )
//	RuiSetImage( rui, "icon", icon )
//	RuiSetGameTime( rui, "startTime", startTime )
//	RuiSetGameTime( rui, "endTime", endTime )
//	RuiSetString( rui, "hintKeyboardMouse", hint )
//	RuiSetString( rui, "hintController", hint )
//}
//#endif //CLIENT
 