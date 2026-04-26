

global function MpAbilityRedeployBalloon_Init

global function OnWeaponPrimaryAttack_redeploy_balloon
global function OnWeaponActivate_redeploy_balloon
global function OnWeaponDeactivate_redeploy_balloon
global function OnWeaponPrimaryAttackAnimEvent_redeploy_balloon
global function OnObjectPlacementCanPlace_redeploy_balloon
#if CLIENT
global function OnCreateClientOnlyModel_redeploy_balloon
#endif

global function IsRedeployBalloonEnt
global function GetRedeployBalloonForHitEnt

#if SERVER
global function RedeployBalloon_GetSkydiveVelOverride
global function RedeployBalloon_GetHeight
#endif

#if DEV && SERVER
global function DEV_DeployRedeployBalloon
#endif

#if CLIENT
global function ServerToClient_OnZiplineMount
global function ServerToClient_OnZiplineStop
#endif

//Playlist
const string REDEPLOY_BALLOON_PLAYLIST_HEIGHT = "redeploy_balloon_height"
const string REDEPLOY_BALLOON_PLAYLIST_HEALTH = "redeploy_balloon_health"
const string REDEPLOY_BALLOON_PLAYLIST_DAMAGE_FX_ENABLED = "redeploy_balloon_damage_fx"
const string REDEPLOY_BALLOON_PLAYLIST_LIFETIME = "redeploy_balloon_lifetime_sec"
const string REDEPLOY_BALLOON_PLAYLIST_ZIPLINE_SCALE = "redeploy_balloon_zipline_scale"
const string REDEPLOY_BALLOON_PLAYLIST_SKYDIVE_VEL = "redeploy_balloon_skydive_vel"
const string REDEPLOY_BALLOON_PLAYLIST_WEIGHT_BURY_DIST = "redeploy_balloon_weight_bury"
const string REDEPLOY_BALLOON_PLAYLIST_DEPLOY_VEL = "redeploy_balloon_deploy_vel"
const string REDEPLOY_BALLOON_PLAYLIST_DEPLOY_TRACE_TIME = "redeploy_balloon_deploy_trace_time"
const string REDEPLOY_BALLOON_PLAYLIST_SKYDIVE_TRIGGER_HEIGHT = "redeploy_balloon_skydive_height"

//Signals
const string SIG_REDEPLOY_BALLOON_STOP_PLACEMENT = "RedeployBalloon_StopPlacement"
const string SIG_REDEPLOY_BALLOON_STOP_ZIPLINE = "RedeployBalloon_StopZipline"

//Script names
global const string REDEPLOY_BALLOON_WEAPON_REF = "mp_ability_redeploy_balloon"
const string REDEPLOY_BALLOON_BASE_SCRIPT_NAME = "redeploy_balloon_base"
const string REDEPLOY_BALLOON_MOVER_SCRIPTNAME = "redeploy_balloon_mover"
global const string REDEPLOY_BALLOON_INFLATABLE_SCRIPT_NAME = "redeploy_balloon_inflatable"
const string REDEPLOY_BALLOON_WEIGHT_SCRIPT_NAME = "redeploy_balloon_weight"
const string REDEPLOY_BALLOON_ZIPLINE_SCRIPT_NAME = "redeploy_balloon_zipline"
const string REDEPLOY_BALLOON_WAYPOINT_SCRIPT_NAME = "redeploy_balloon_waypoint"
const string REDEPLOY_BALLOON_PUSH_TRIGGER_SCRIPT_NAME = "redeploy_balloon_slip_trigger"
const string REDEPLOY_BALLOON_WEIGHT_PUSH_SCRIPT_NAME = "redeploy_balloon_weight_push"
const string REDEPLOY_BALLOON_AIR_PUSH_SCRIPT_NAME = "redeploy_balloon_air_push"
global const string REDEPLOY_BALLOON_SKYDIVE_TRIGGER_SCRIPT_NAME = "redeploy_balloon_skydive_trigger"

//Vars
const int REDEPLOY_BALLOON_HEIGHT = 3700
const int REDEPLOY_BALLOON_HEALTH = 1800
const int REDEPLOY_BALLOON_NO_AIRDROP_RADIUS = 500

const float REDEPLOY_BALLOON_DEPLOY_VEL = 1280
const float REDEPLOY_BALLOON_DEPLOY_TRACE_TIME = 1.6

const float REDEPLOY_BALLOON_LIFETIME_SEC = 25
const int REDEPLOY_BALLOON_LIFETIME_MIN_HEALTH = 1

const int REDEPLOY_BALLOON_ZIPLINE_FADE_DISTANCE = 24000
const int _PROTO_REDEPLOY_BALLOON_BANNER_FADE_DISTANCE = 40000

//-18 = Roughly the height of a heat shield/octane's jump pad
const float REDEPLOY_BALLOON_WEIGHT_BURY_DIST = -21
const vector REDEPLOY_BALLOON_WEIGHT_BURY_DIST_VEC = <0, 0, REDEPLOY_BALLOON_WEIGHT_BURY_DIST>//<0, 0, -23>//<0, 0, -32>

const bool USE_OBJECT_PLACER = false

//WAYPOINT
const int REDEPLOY_BALLOON_WAYPOINT_MIN_DISTANCE = 120
const int REDEPLOY_BALLOON_WAYPOINT_MAX_DISTANCE = 4000
const int REDEPLOY_BALLOON_WAYPOINT_LONG_MAX_DISTANCE = 25000 //Approximately 2 POI's over on KC
const int REDEPLOY_BALLOON_WAYPOINT_MIN_DISTANCE_SQR = REDEPLOY_BALLOON_WAYPOINT_MIN_DISTANCE * REDEPLOY_BALLOON_WAYPOINT_MIN_DISTANCE
const int REDEPLOY_BALLOON_WAYPOINT_MAX_DISTANCE_SQR = REDEPLOY_BALLOON_WAYPOINT_MAX_DISTANCE * REDEPLOY_BALLOON_WAYPOINT_MAX_DISTANCE
const int REDEPLOY_BALLOON_WAYPOINT_LONG_MAX_DISTANCE_SQR = REDEPLOY_BALLOON_WAYPOINT_LONG_MAX_DISTANCE * REDEPLOY_BALLOON_WAYPOINT_LONG_MAX_DISTANCE

const vector REDEPLOY_BALLOON_INVALID_PLACEMENT_MIN_AREA = <-25, -25, 0>
const vector REDEPLOY_BALLOON_INVALID_PLACEMENT_MAX_AREA = <25, 25, 50>

//RUI
const asset RUI_REDEPLOY_BALLOON_WAYPOINT = $"ui/redeploy_balloon_hp_meter_cockpit.rpak"
const asset RUI_REDEPLOY_BALLOON_HUD = $"ui/redeploy_balloon_hp_status.rpak"

//SKYDIVE TRIGGER
const float REDEPLOY_BALLOON_SKYDIVE_TRIGGER_RADIUS = 32
const float REDEPLOY_BALLOON_SKYDIVE_TRIGGER_HALF_HEIGHT = 80

const float REDEPLOY_BALLOON_PUSH_TRIGGER_RADIUS = 300
const float REDEPLOY_BALLOON_PUSH_TRIGGER_HALF_HEIGHT = 100
const float REDEPLOY_BALLOON_PUSH_TRIGGER_STRENGTH = 350.0
const vector REDEPLOY_BALLOON_PUSH_TRIGGER_OFFSET = <0, 0, 400>

const float REDEPLOY_BALLOON_WEIGHT_PUSH_RADIUS = 20
const float REDEPLOY_BALLOON_WEIGHT_PUSH_HALF_HEIGHT = 80
const float REDEPLOY_BALLOON_WEIGHT_PUSH_STRENGTH = 180.0
const vector REDEPLOY_BALLOON_WEIGHT_PUSH_OFFSET = <0, 0, 80>

const float REDEPLOY_BALLOON_AIR_PUSH_RADIUS = 320
const float REDEPLOY_BALLOON_AIR_PUSH_HALF_HEIGHT = 420
const float REDEPLOY_BALLOON_AIR_PUSH_STRENGTH = 300.0
const vector REDEPLOY_BALLOON_AIR_PUSH_OFFSET = <0, 0, 180>

//Timing
//5 second zipline, 1.0 is 6 seconds
const float REDEPLOY_BALLOON_ZIPLINE_SCALE = 1.4

//5 seconds to deploy
const float REDEPLOY_BALLOON_ZIPLINE_DEPLOY_SEC = 1.15
const float REDEPLOY_BALLOON_BASE_DEPLOY_SEC = 3.85
const float REDEPLOY_BALLOON_BASE_DEPLOY_ACCEL = 0.75
const float REDEPLOY_BALLOON_BASE_DEPLOY_DECEL = 2.25

const float REDEPLOY_BALLOON_SKYDIVE_VEL = 1315 //0 to disable

const float REDEPLOY_BALLOON_DAMAGE_BLINK_SEC = 0.5
const float REDEPLOY_BALLOON_TAKING_DAMAGE_SEC = 0.5

//Models
const asset MDL_REDEPLOY_BALLOON_INFLATABLE = $"mdl/props/evac_tower_balloon/evac_tower_balloon.rmdl"//$"mdl/props/zipline_balloon/zipline_balloon_night.rmdl"
const asset MDL_REDEPLOY_BALLOON_BASE = $"mdl/props/evac_tower_rocket/evac_tower_rocket.rmdl"//$"mdl/Robots/drone_ticky/drone_ticky.rmdl"
const asset MDL_REDEPLOY_BALLOON_WEIGHT = $"mdl/props/evac_tower_weight/evac_tower_weight.rmdl"//$"mdl/containers/barrel_explosive.rmdl"
//const asset MDL_REDEPLOY_BALLOON_WEIGHT_OLD = $"mdl/containers/barrel_explosive.rmdl"

//VFX
const asset VFX_REDEPLOY_BALLOON_LAUNCH_TRAIL = $"P_evacB_launch"
const asset VFX_REDEPLOY_BALLOON_LAUNCH = $"P_evacB_launch_engage"
//const asset VFX_REDEPLOY_BALLOON_PRELAUNCH = $"P_evacB_jet_propulsion"
const asset VFX_REDEPLOY_BALLOON_INFLATE = $"P_evacB_airburst"
const asset VFX_REDEPLOY_BALLOON_DESTROYED = $"P_evacB_destroy"
const asset VFX_REDEPLOY_BALLOON_WEIGHT_DESTROYED = $"P_evacB_sys_exp"
const asset VFX_REDEPLOY_BALLOON_AR_DROP = $"P_ar_evacB_point"//$"P_ar_titan_droppoint"//$"P_mrb_ar_drop_point"

const asset VFX_REDEPLOY_BALLOON_DAMAGED = $"P_rmp_smoke_pink_diag"
//const asset _PROTO_VFX_REDEPLOY_BALLOON_DAMAGED = $"P_xo_dam_exhaust_doom"//$"P_exp_blowout_md"
//const asset VFX_REDEPLOY_BALLOON_LIGHTS = $"test_flood_light_white"

const string VFX_REDPLOY_BALLOON_WEIGHT_IMPACT_TABLE = "evac_tower_anchor_impact"

//Sound
const string SFX_REDEPLOY_BALLOON_LAUNCH = "Survival_EvacTower_BlastOff"//"valk_ultimate_blastoff_3p"
const string SFX_REDEPLOY_BALLOON_INFLATE = "Survival_EvacTower_Balloon_Inflate"//"gasgrenade_explo"
const string SFX_REDEPLOY_BALLOON_ZIPLINE_EXTEND = "Survival_EvacTower_Anchor_Incoming"
const string SFX_REDEPLOY_BALLOON_DEATH = "Survival_EvacTower_Balloon_Explode"//"titan_death_explode"
const string SFX_REDEPLOY_BALLOON_WEIGHT_DEATH = "Survival_EvacTower_Zipline_Snap"//"turret_explode"
const string SFX_REDEPLOY_BALLOON_AR = "Survival_EvacTower_AR_Landing_Marker" //New sound needed

//MATERIALS - Proto Materials for Zipline
const asset MAT_ASSET_REDEPLOY_BALLOON_ZIPLINE = $"cable/zipline" //cable/evac_rope
const string MAT_REDEPLOY_BALLOON_ZIPLINE = "cable/zipline" //cable/evac_rope

//Anims
const string ANIM_REDEPLOY_BALLOON_DEPLOY = "evac_balloon_deploy"

struct RedeployBalloonPlacementInfo
{
	vector origin
	vector angles
	vector surfaceNormal
	bool   failed
	bool   hide
	string failReason
}

struct {
	#if SERVER
		table <entity, int> playersOnZipline
	#endif

	#if CLIENT
		var waypointRui
	#endif

	int   height = REDEPLOY_BALLOON_HEIGHT
	float deployVel = REDEPLOY_BALLOON_DEPLOY_VEL
	float deployTraceTime = REDEPLOY_BALLOON_DEPLOY_TRACE_TIME

	#if SERVER
		int    health = REDEPLOY_BALLOON_HEALTH
		float  lifetimeSec = REDEPLOY_BALLOON_LIFETIME_SEC
		float  ziplineScale = REDEPLOY_BALLOON_ZIPLINE_SCALE
		float  skydiveVel = REDEPLOY_BALLOON_SKYDIVE_VEL
		vector buryDist = REDEPLOY_BALLOON_WEIGHT_BURY_DIST_VEC
		float  skydiveTriggerHalfHeight = REDEPLOY_BALLOON_SKYDIVE_TRIGGER_HALF_HEIGHT
	#endif
}
file

void function MpAbilityRedeployBalloon_Init()
{
	PrecacheModel( MDL_REDEPLOY_BALLOON_INFLATABLE )
	PrecacheModel( MDL_REDEPLOY_BALLOON_BASE )
	PrecacheModel( MDL_REDEPLOY_BALLOON_WEIGHT )
	//PrecacheModel( MDL_REDEPLOY_BALLOON_WEIGHT_OLD )

	PrecacheScriptString( REDEPLOY_BALLOON_INFLATABLE_SCRIPT_NAME )
	PrecacheScriptString( REDEPLOY_BALLOON_PUSH_TRIGGER_SCRIPT_NAME )
	PrecacheScriptString( REDEPLOY_BALLOON_SKYDIVE_TRIGGER_SCRIPT_NAME )
	PrecacheScriptString( REDEPLOY_BALLOON_WAYPOINT_SCRIPT_NAME )
	PrecacheScriptString( REDEPLOY_BALLOON_WEIGHT_PUSH_SCRIPT_NAME )
	PrecacheScriptString( REDEPLOY_BALLOON_AIR_PUSH_SCRIPT_NAME )
	PrecacheScriptString( REDEPLOY_BALLOON_WEIGHT_SCRIPT_NAME )
	PrecacheScriptString( REDEPLOY_BALLOON_ZIPLINE_SCRIPT_NAME )

	PrecacheImpactEffectTable( VFX_REDPLOY_BALLOON_WEIGHT_IMPACT_TABLE )

	PrecacheParticleSystem( VFX_REDEPLOY_BALLOON_LAUNCH_TRAIL )
	PrecacheParticleSystem( VFX_REDEPLOY_BALLOON_LAUNCH )
	//	PrecacheParticleSystem( VFX_REDEPLOY_BALLOON_PRELAUNCH )
	PrecacheParticleSystem( VFX_REDEPLOY_BALLOON_INFLATE )
	PrecacheParticleSystem( VFX_REDEPLOY_BALLOON_DESTROYED )
	PrecacheParticleSystem( VFX_REDEPLOY_BALLOON_WEIGHT_DESTROYED )
	PrecacheParticleSystem( VFX_REDEPLOY_BALLOON_AR_DROP )
	//PrecacheParticleSystem( VFX_REDEPLOY_BALLOON_LIGHTS )

	PrecacheParticleSystem( VFX_REDEPLOY_BALLOON_DAMAGED )

	PrecacheMaterial( MAT_ASSET_REDEPLOY_BALLOON_ZIPLINE )

	Remote_RegisterClientFunction( "ServerToClient_OnZiplineMount", "entity" )
	Remote_RegisterClientFunction( "ServerToClient_OnZiplineStop" )

	#if CLIENT
		RegisterSignal( SIG_REDEPLOY_BALLOON_STOP_PLACEMENT )
		RegisterSignal( SIG_REDEPLOY_BALLOON_STOP_ZIPLINE )
		AddCreateCallback( PLAYER_WAYPOINT_CLASSNAME, OnWaypointCreated )
		AddCreateCallback( "prop_dynamic", OnPropDynamicCreate )

		RegisterMinimapPackage( "prop_script", eMinimapObject_prop_script.REDEPLOY_BALLOON, MINIMAP_OBJECT_RUI, MinimapPackage_RedeplyBalloon, FULLMAP_OBJECT_RUI, MinimapPackage_RedeplyBalloon )
	#endif

	#if SERVER
		AddCallback_ZiplineMount( RedeployBalloon_OnZiplineMount )
		AddCallback_ZiplineStop( RedeployBalloon_OnZiplineStop )
	#endif

	file.height          = GetCurrentPlaylistVarInt( REDEPLOY_BALLOON_PLAYLIST_HEIGHT, REDEPLOY_BALLOON_HEIGHT )
	file.deployVel       = GetCurrentPlaylistVarFloat( REDEPLOY_BALLOON_PLAYLIST_DEPLOY_VEL, REDEPLOY_BALLOON_DEPLOY_VEL )
	file.deployTraceTime = GetCurrentPlaylistVarFloat( REDEPLOY_BALLOON_PLAYLIST_DEPLOY_TRACE_TIME, REDEPLOY_BALLOON_DEPLOY_TRACE_TIME )

	#if SERVER
		file.health = GetCurrentPlaylistVarInt( REDEPLOY_BALLOON_PLAYLIST_HEALTH, REDEPLOY_BALLOON_HEALTH )
		file.lifetimeSec = GetCurrentPlaylistVarFloat( REDEPLOY_BALLOON_PLAYLIST_LIFETIME, REDEPLOY_BALLOON_LIFETIME_SEC )
		file.ziplineScale = GetCurrentPlaylistVarFloat( REDEPLOY_BALLOON_PLAYLIST_ZIPLINE_SCALE, REDEPLOY_BALLOON_ZIPLINE_SCALE )
		file.skydiveVel = GetCurrentPlaylistVarFloat( REDEPLOY_BALLOON_PLAYLIST_SKYDIVE_VEL, REDEPLOY_BALLOON_SKYDIVE_VEL )
		file.buryDist = <0, 0, GetCurrentPlaylistVarFloat( REDEPLOY_BALLOON_PLAYLIST_WEIGHT_BURY_DIST, REDEPLOY_BALLOON_WEIGHT_BURY_DIST )>
		file.skydiveTriggerHalfHeight = GetCurrentPlaylistVarFloat( REDEPLOY_BALLOON_PLAYLIST_SKYDIVE_TRIGGER_HEIGHT, REDEPLOY_BALLOON_SKYDIVE_TRIGGER_HALF_HEIGHT )
	#endif
}

#if SERVER
float function RedeployBalloon_GetSkydiveVelOverride()
{
	return file.skydiveVel
}

float function RedeployBalloon_GetHeight()
{
	return float(file.height)
}
#endif

void function OnWeaponActivate_redeploy_balloon( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if CLIENT

		#if !USE_OBJECT_PLACER
			RedployBalloon_BeginPlacement( ownerPlayer )
		#endif

		if ( ownerPlayer == GetLocalViewPlayer() )
		{
			RunUIScript( "CloseSurvivalInventoryMenu" )
		}

		if ( !InPrediction() )
			return
	#endif

	int skinIndex = weapon.GetSkinIndexByName( "evac_tower_clacker" )
	if ( skinIndex != -1 )
		weapon.SetSkin( skinIndex )
}

void function OnWeaponDeactivate_redeploy_balloon( entity weapon )
{
	entity ownerPlayer = weapon.GetWeaponOwner()
	Assert( ownerPlayer.IsPlayer() )

	#if CLIENT
		RedeployBalloon_EndPlacement( ownerPlayer )
		if ( !InPrediction() ) //Stopgap fix for Bug 146443
			return
	#endif
}

bool function IsRedeployBalloonEnt( entity ent )
{
	return ent.GetScriptName() == REDEPLOY_BALLOON_INFLATABLE_SCRIPT_NAME
}

entity function GetRedeployBalloonForHitEnt( entity hitEnt )
{
	if ( !IsValid( hitEnt ) )
		return null

	//Return balloon if pinging the weight or zipline
	if ( hitEnt.GetScriptName() == REDEPLOY_BALLOON_WEIGHT_SCRIPT_NAME || hitEnt.GetScriptName() == REDEPLOY_BALLOON_ZIPLINE_SCRIPT_NAME )
		return hitEnt.GetOwner()

	if ( hitEnt.GetScriptName() == REDEPLOY_BALLOON_INFLATABLE_SCRIPT_NAME )
		return hitEnt

	return null
}

//PLACEMENT
#if CLIENT
void function OnCreateClientOnlyModel_redeploy_balloon( entity weapon, entity model, bool validHighlight )
{
	if ( validHighlight )
		DeployableModelHighlight( model )
	else
		DeployableModelInvalidHighlight( model )
}

void function RedployBalloon_BeginPlacement( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	thread RedeployBalloon_Placement_Thread( player )
}

void function RedeployBalloon_EndPlacement( entity player )
{
	if ( player != GetLocalViewPlayer() )
		return

	player.Signal( SIG_REDEPLOY_BALLOON_STOP_PLACEMENT )
}

void function RedeployBalloon_Placement_Thread( entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( SIG_REDEPLOY_BALLOON_STOP_PLACEMENT )

	entity proxy = CreateProxy( MDL_REDEPLOY_BALLOON_BASE )
	proxy.EnableRenderAlways()
	proxy.Show()
	DeployableModelHighlight( proxy )
	proxy.SetFadeDistance( 320000 ) //Prevent it from fading out

	string[1] displayedHint = [""]

	OnThreadEnd(
		function() : ( proxy, displayedHint )
		{
			if ( IsValid( proxy ) )
				thread DestroyProxy_Thread( proxy )

			if ( displayedHint[0] != "" )
				HidePlayerHint( displayedHint[0] )
		}
	)

	//AddPlayerHint( 3.0, 0.25, $"", "#SURVIVAL_PICKUP_REDEPLOY_BALLOON_HINT" )

	while ( true )
	{
		RedeployBalloonPlacementInfo placementInfo = RedeployBalloon_GetPlacementInfo ( player )

		proxy.SetOrigin( placementInfo.origin )
		proxy.SetAngles( placementInfo.angles )

		string hint = "#REDEPLOY_BALLOON_USE_PROMPT"

		if ( !placementInfo.failed )
			DeployableModelHighlight( proxy )
		else
		{
			DeployableModelInvalidHighlight( proxy )
			hint = "#REDEPLOY_BALLOON_INVALID_PLACEMENT"
		}

		if ( placementInfo.hide )
		{
			hint = "#REDEPLOY_BALLOON_INVALID_PLACEMENT"
			proxy.Hide()
		}
		else
			proxy.Show()

		if ( hint != displayedHint[0] )
		{
			if ( displayedHint[0] != "" )
				HidePlayerHint( displayedHint[0] )
			if ( hint != "" )
				AddPlayerHint( 60.0, 0, $"", hint )
			displayedHint[0] = hint
		}

		WaitFrame()
	}
}

entity function CreateProxy( asset modelName )
{
	entity modelEnt = CreateClientSidePropDynamic( <0, 0, 0>, <0, 0, 0>, modelName )
	modelEnt.kv.renderamt   = 255
	modelEnt.kv.rendermode  = 3
	modelEnt.kv.rendercolor = "255 255 255 255"

	modelEnt.Anim_Play( "ref" )
	modelEnt.Hide()

	return modelEnt
}

void function DestroyProxy_Thread( entity proxy )
{
	Assert( IsNewThread(), "Must be threaded off" )
	proxy.EndSignal( "OnDestroy" )

	//Do I even need to thread this anymore? probs not
	//wait 1
	//if ( file.mobileRespawnDeployed )
	//	wait 0.225

	proxy.Destroy()
}
#endif

bool function OnObjectPlacementCanPlace_redeploy_balloon( entity weapon, vector origin, vector angles, entity parentTo )
{
	entity player = weapon.GetOwner()
	return VerifyAirdropPoint( origin, angles.y, true, player )
}


//DEPLOYMENT
var function OnWeaponPrimaryAttack_redeploy_balloon( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return RedeployBallon_PlaceBalloon( weapon, attackParams )
}

int function RedeployBallon_PlaceBalloon( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity player = weapon.GetWeaponOwner()
	Assert( player.IsPlayer() )

	#if USE_OBJECT_PLACER
		RedeployBalloonPlacementInfo placementInfo
		placementInfo.origin = weapon.GetObjectPlacementOrigin()
		placementInfo.angles = weapon.GetObjectPlacementAngles()
	#else
		RedeployBalloonPlacementInfo placementInfo = RedeployBalloon_GetPlacementInfo( player )
	#endif


	if ( placementInfo.failed )
		return 0

	#if SERVER
		LootData lootData = EquipmentSlot_GetEquippedLootDataForSlot( player, "gadgetslot" )
		if ( lootData.ref != REDEPLOY_BALLOON_WEAPON_REF )
		{
			SwapToLastEquippedPrimary( player )
			return 0
		}

		RedeployBalloon_StartSequence( player, placementInfo.origin, placementInfo.angles )

		PlayerUsedOffhand( player, weapon, true, null, {pos = placementInfo.origin} )
	#else
		PlayerUsedOffhand( player, weapon )
		RedeployBalloon_EndPlacement( weapon )
	#endif

	#if SERVER
		TryPlayWeaponBattleChatterLine( player, weapon )

		//LiveAPI_SendInventoryActionWeapon( eLiveAPI_EventTypes.inventoryUse, player, weapon )
	#endif

	int ammoReq = weapon.GetAmmoPerShot()
	return ammoReq
}

#if SERVER

entity function CreateSkyDiveTrigger( vector origin, vector angles )
{
	entity trigger = CreateEntity( "trigger_cylinder" )
	trigger.SetCylinderRadius( REDEPLOY_BALLOON_SKYDIVE_TRIGGER_RADIUS )
	trigger.SetAboveHeight( file.skydiveTriggerHalfHeight )
	trigger.SetBelowHeight( file.skydiveTriggerHalfHeight )
	trigger.kv.triggerFilterNpc          = "none"
	trigger.kv.triggerFilterPlayer       = "all"
	trigger.kv.triggerFilterNonCharacter = 0
	trigger.SetOrigin( origin + <0, 0, -file.skydiveTriggerHalfHeight> )

	trigger.SetScriptName( REDEPLOY_BALLOON_SKYDIVE_TRIGGER_SCRIPT_NAME )

	//Bruh
	//trigger.SetPhaseShiftCanTouch( false )

	DispatchSpawn( trigger )

	return trigger
}

entity function CreateBase( entity owner, vector origin, vector angles )
{
	entity base = CreatePropDynamic( MDL_REDEPLOY_BALLOON_BASE, origin, angles, SOLID_VPHYSICS, 10000 )
	//May need to add stuff like no ziplines
	base.DisallowZiplines()
	base.DisableGrappleAttachment()

	CopyRealmsFromTo( owner, base )

	return base
}

entity function CreateWeight( vector origin, vector angles )
{
	entity weight = CreatePropDynamic( MDL_REDEPLOY_BALLOON_WEIGHT, origin, angles, SOLID_VPHYSICS, 10000 )
	weight.SetScriptName( REDEPLOY_BALLOON_WEIGHT_SCRIPT_NAME )

	weight.DisallowZiplines()
	//weight.DisallowObjectPlacement()

	//May need to add stuff like no ziplines
	weight.kv.contents = int(weight.kv.contents) | CONTENTS_NOGRAPPLE | CONTENTS_BLOCK_PING

	return weight
}

entity function CreateInflatable( entity owner, vector origin, vector angles )
{
	entity inflatable = CreatePropScript( MDL_REDEPLOY_BALLOON_INFLATABLE, origin, angles, SOLID_VPHYSICS, -1, false )

	inflatable.SetOrigin( origin )
	inflatable.SetAngles( angles )
	inflatable.SetScriptName( REDEPLOY_BALLOON_INFLATABLE_SCRIPT_NAME )

	inflatable.SetOwner( owner )
	//SetTeam( inflatable, owner.GetTeam() )

	inflatable.DisableHibernation()
	inflatable.Solid()
	//inflatable.AllowMantle()
	inflatable.DisallowZiplines()
	//inflatable.DisallowObjectPlacement()

	DispatchSpawn( inflatable )

	//DisableSkydiveEndOnEntity( inflatable, true )
	//DisableSkydiveAnticipateOnEntity( inflatable, true )

	CopyRealmsFromTo( owner, inflatable )

	inflatable.SetMaxHealth( file.health )
	inflatable.SetHealth( file.health )
	inflatable.SetDamageNotifications( true )
	inflatable.SetDeathNotifications( true )
	inflatable.SetArmorType( ARMOR_TYPE_HEAVY )

	inflatable.SetTakeDamageType( DAMAGE_YES )
	inflatable.SetCanBeMeleed( true )
	inflatable.e.noOwnerFriendlyFire      = false
	inflatable.e.noFriendlyFireProtection = true
	inflatable.e.canBeDamagedFromGas      = false
	inflatable.e.canBurn                  = false

	SetVisibleEntitiesInConeQueriableEnabled( inflatable, false )
	inflatable.Highlight_Enable()
	AddSonarDetectionForPropScript( inflatable )

	AddEntityCallback_OnPostDamaged( inflatable, RedeployBalloon_OnPostDamaged )

	return inflatable
}

entity function CreatePushTrigger( vector origin, string scriptName, float radius, float aboveHeight, float belowHeight, float strength )
{
	entity push = CreateEntity( "trigger_cylinder" )
	push.SetCylinderRadius( radius )
	push.SetAboveHeight( aboveHeight )
	push.SetBelowHeight( belowHeight )
	push.kv.triggerFilterNpc          = "all"
	push.kv.triggerFilterPlayer       = "all"
	push.kv.triggerFilterNonCharacter = 0
	push.SetOrigin( origin )
	push.SetScriptName( scriptName )
	push.SetPhaseShiftCanTouch( true )
	push.SetEnterCallback( PushOutOfTrigger( strength ) )

	DispatchSpawn( push )

	return push
}

entity function CreateSlipTrigger( vector origin, string scriptName, float radius )
{
	entity slip = CreateEntity( "trigger_slip_sphere" )
	slip.kv.triggerFilterNpc          = "all"
	slip.kv.triggerFilterPlayer       = "all"
	slip.kv.triggerFilterNonCharacter = 0
	slip.kv.radiusOverride            = radius
	slip.SetOrigin( origin )
	slip.SetScriptName( scriptName )
	slip.SetPhaseShiftCanTouch( true )

	DispatchSpawn( slip )

	return slip
}

entity function CreateWaypoint( entity inflatable )
{
	entity waypoint = CreatePlayerWaypoint( eWaypoint.REDEPLOY_BALLOON_LIFE )
	waypoint.SetScriptName( REDEPLOY_BALLOON_WAYPOINT_SCRIPT_NAME )
	waypoint.SetOrigin( inflatable.GetOrigin() + (inflatable.GetUpVector() * 30) + <0, 0, 5> )
	waypoint.SetAngles( inflatable.GetAngles() )
	waypoint.SetWaypointFloat( 0, float(file.health) )
	waypoint.SetWaypointFloat( 1, float(file.health) )
	waypoint.SetWaypointInt( 0, 0 )
	//waypoint.SetWaypointInt( 1, inflatable.GetMaxHealth() )
	waypoint.wp.waypointCreatedTime = Time()
	waypoint.SetOwner( inflatable.GetOwner() )
	waypoint.SetParent( inflatable )
	CopyRealmsFromTo( inflatable, waypoint )
	SetTeam( waypoint, waypoint.GetOwner().GetTeam() )

	return waypoint
}
#endif

#if SERVER
void function RedeployBalloon_StartSequence( entity owner, vector origin, vector angles )
{
	thread RedeployBalloon_Sequence_Thread( owner, origin, angles )
}

void function RedeployBalloon_Sequence_Thread( entity owner, vector origin, vector angles )
{
	if ( !IsValid( owner ) )
		return

	Assert( IsNewThread(), "Must be threaded off." )

	vector startPos = origin
	vector endPos   = origin + <0, 0, file.height>

	entity traceBlocker = CreateTraceBlockerVolume( origin, REDEPLOY_BALLOON_NO_AIRDROP_RADIUS, false, CONTENTS_NOAIRDROP, TEAM_MILITIA, "redeploy_balloon_trace_blocker" )
	CopyRealmsFromTo( owner, traceBlocker )

	OnThreadEnd(
		function() : ( traceBlocker )
		{
			if ( IsValid( traceBlocker ) )
				traceBlocker.Destroy()
		}
	)

	thread RedeployBalloon_AR_Thread( owner, startPos, angles )

	//Base deployed
	waitthread RedeployBalloon_BaseSequence_Thread ( owner, startPos, endPos, angles )

	//Inflatable deployed
	waitthread RedeployBalloon_InflatableSequence_Thread( owner, startPos, endPos, angles )
}

void function RedeployBalloon_AR_Thread( entity owner, vector startPos, vector angles )
{
	// Setup all FX that exist for the lifetime of the respawnBeacon
	entity threatIndicator = CreateThreatIndicator( startPos + <0, 0, 48>, eThreatIndicatorID.GRENADE_INDICATOR_GENERIC, 160.0 )
	int markerIndex        = GetParticleSystemIndex( VFX_REDEPLOY_BALLOON_AR_DROP ) // AR Marker
	entity markerFx        = StartParticleEffectInWorld_ReturnEntity( markerIndex, startPos, angles )

	EmitSoundAtPosition( TEAM_UNASSIGNED, startPos, SFX_REDEPLOY_BALLOON_AR, owner )

	CopyRealmsFromTo( owner, threatIndicator )
	CopyRealmsFromTo( owner, markerFx )

	OnThreadEnd(
		function() : ( threatIndicator, markerFx, startPos )
		{
			if ( IsValid( threatIndicator ) )
				threatIndicator.Destroy()
			if ( IsValid( markerFx ) )
				markerFx.Destroy()

			StopSoundAtPosition( startPos, SFX_REDEPLOY_BALLOON_AR )
		}
	)

	wait REDEPLOY_BALLOON_BASE_DEPLOY_SEC + REDEPLOY_BALLOON_ZIPLINE_DEPLOY_SEC
}

void function RedeployBalloon_BaseSequence_Thread( entity owner, vector startPos, vector endPos, vector angles )
{
	if ( !IsValid( owner ) )
		return

	entity base = CreateBase( owner, startPos, angles )

	base.EndSignal( "OnDeath" )
	base.EndSignal( "OnDestroy" )

	entity mover = CreateScriptMover( REDEPLOY_BALLOON_MOVER_SCRIPTNAME, base.GetOrigin(), base.GetAngles() )
	base.SetParent( mover )

	CopyRealmsFromTo( owner, mover )

	mover.EndSignal( "OnDeath" )
	mover.EndSignal( "OnDestroy" )

	//Push trigger to move stuff out of air space
	entity pushAir = CreatePushTrigger( endPos + REDEPLOY_BALLOON_AIR_PUSH_OFFSET,
		REDEPLOY_BALLOON_AIR_PUSH_SCRIPT_NAME,
		REDEPLOY_BALLOON_AIR_PUSH_RADIUS,
		REDEPLOY_BALLOON_AIR_PUSH_HALF_HEIGHT,
		REDEPLOY_BALLOON_AIR_PUSH_HALF_HEIGHT,
		REDEPLOY_BALLOON_AIR_PUSH_STRENGTH )

	CopyRealmsFromTo( owner, pushAir )

	OnThreadEnd(
		function() : ( base, mover, pushAir )
		{
			if ( IsValid( base ) )
			{
				StopSoundOnEntity( base, SFX_REDEPLOY_BALLOON_LAUNCH )
				base.Destroy()
			}
			if ( IsValid( mover ) )
				mover.Destroy()

			if ( IsValid( pushAir ) )
				pushAir.Destroy()
		}
	)

	thread TrapDestroyOnRoundEnd( owner, base )

	EmitSoundOnEntity( base, SFX_REDEPLOY_BALLOON_LAUNCH )
	entity shake = CreateAirShake( base.GetOrigin(), 12, 400, 0.75, 800 )
	CopyRealmsFromTo( base, shake )

	entity launchFX = StartParticleEffectOnEntity_ReturnEntity( base, GetParticleSystemIndex( VFX_REDEPLOY_BALLOON_LAUNCH_TRAIL ), FX_PATTACH_ABSORIGIN_FOLLOW, ATTACHMENTID_INVALID )
	launchFX.DisableHibernation()

	launchFX = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( VFX_REDEPLOY_BALLOON_LAUNCH ), base.GetOrigin(), base.GetAngles() )
	CopyRealmsFromTo( base, launchFX )
	launchFX.DisableHibernation()

	TrackingVision_CreatePOI( eTrackingVisionNetworkedPOITypes.PLAYER_ABILITY_REDEPLOY_BALLOON, owner, startPos, owner.GetTeam(), owner )

	mover.NonPhysicsMoveTo( endPos, REDEPLOY_BALLOON_BASE_DEPLOY_SEC, REDEPLOY_BALLOON_BASE_DEPLOY_ACCEL, REDEPLOY_BALLOON_BASE_DEPLOY_DECEL )

	wait REDEPLOY_BALLOON_BASE_DEPLOY_SEC
}

void function RedeployBalloon_InflatableSequence_Thread( entity owner, vector startPos, vector endPos, vector angles )
{
	if ( !IsValid( owner ) )
		return

	entity trigger    = CreateSkyDiveTrigger( endPos, angles )
	entity inflatable = CreateInflatable( owner, endPos, angles )
	entity slip       = CreateSlipTrigger( endPos + REDEPLOY_BALLOON_PUSH_TRIGGER_OFFSET,
		REDEPLOY_BALLOON_PUSH_TRIGGER_SCRIPT_NAME,
		REDEPLOY_BALLOON_PUSH_TRIGGER_RADIUS )

	CopyRealmsFromTo( owner, trigger )
	CopyRealmsFromTo( owner, slip )

	slip.SetParent( inflatable )
	slip.SearchForNewTouchingEntity()

	trigger.EndSignal( "OnDeath" )
	trigger.EndSignal( "OnDestroy" )
	inflatable.EndSignal( "OnDeath" )
	inflatable.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( trigger, inflatable, slip )
		{
			if ( IsValid( trigger ) )
				trigger.Destroy()
			if ( IsValid( inflatable ) )
				inflatable.Destroy()
			if ( IsValid( slip ) )
				slip.Destroy()
		}
	)

	thread TrapDestroyOnRoundEnd( owner, inflatable )

	entity inflateFX = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( VFX_REDEPLOY_BALLOON_INFLATE ), inflatable.GetOrigin(), inflatable.GetAngles() )
	CopyRealmsFromTo( owner, inflateFX )
	inflateFX.DisableHibernation()

	inflatable.Anim_Play( ANIM_REDEPLOY_BALLOON_DEPLOY )

	EmitSoundAtPosition( TEAM_ANY, inflatable.GetOrigin(), SFX_REDEPLOY_BALLOON_INFLATE, owner )

	entity shake = CreateAirShake( inflatable.GetOrigin(), 12, 400, 0.5, 800 )
	CopyRealmsFromTo( inflatable, shake )

	inflatable.Show()

	//Zipline deployed
	waitthread RedeployBalloon_DeployZipline_Thread( inflatable, REDEPLOY_BALLOON_ZIPLINE_DEPLOY_SEC, endPos, startPos, <0, 0, 0> )
}


void function RedeployBalloon_DeployZipline_Thread( entity inflatable, float deployDuration, vector startPos, vector endPos, vector startAngles )
{
	Assert ( IsNewThread(), "DeployZipline must be threaded off" )

	inflatable.EndSignal( "OnDeath" )
	inflatable.EndSignal( "OnDestroy" )

	// have to create the zipline begin/end on top of each other,
	// otherwise you'll see the fully complete zipline a frame before it deploys
	string detachDist   = "0"
	entity ziplineStart = CreateEntity( "zipline" )

	ziplineStart.SetScriptName( REDEPLOY_BALLOON_ZIPLINE_SCRIPT_NAME )
	ziplineStart.kv.Material                   = MAT_REDEPLOY_BALLOON_ZIPLINE
	//ziplineStart.Zipline_SetRopeColorModulation( <0, 1, 0> )
	ziplineStart.SetOrigin( startPos )
	ziplineStart.SetAngles( startAngles )
	ziplineStart.kv.ZiplineAutoDetachDistance  = detachDist
	ziplineStart.kv._zipline_rest_point_0      = startPos.x + " " + startPos.y + " " + startPos.z
	ziplineStart.kv._zipline_rest_point_1      = endPos.x + " " + endPos.y + " " + endPos.z
	ziplineStart.kv.ZiplineVertical            = true
	ziplineStart.kv.ZiplinePreserveVelocity    = true
	ziplineStart.kv.ZiplinePushOffInDirectionX = false
	ziplineStart.kv.ZiplineSpeedScale          = file.ziplineScale //Faster to go up these zips

	ziplineStart.SetOwner( inflatable )

	ziplineStart.kv.ZiplineFadeDistance = REDEPLOY_BALLOON_ZIPLINE_FADE_DISTANCE

	// we're deploying, so we want this
	ziplineStart.Zipline_DisableResting()

	entity ziplineEnd = CreateEntity( "zipline_end" )
	ziplineEnd.kv.ZiplineAutoDetachDistance = detachDist
	ziplineEnd.SetOrigin( startPos )

	ziplineEnd.kv.ZiplineFadeDistance = REDEPLOY_BALLOON_ZIPLINE_FADE_DISTANCE

	inflatable.LinkToEnt( ziplineStart )
	ziplineStart.LinkToEnt( ziplineEnd )

	CopyRealmsFromTo( inflatable, ziplineStart )
	CopyRealmsFromTo( inflatable, ziplineEnd )

	DispatchSpawn( ziplineStart )
	DispatchSpawn( ziplineEnd )

	entity mover = CreateScriptMover( REDEPLOY_BALLOON_MOVER_SCRIPTNAME + "__ziplineMover", startPos )

	ziplineStart.Zipline_Disable()
	ziplineEnd.SetOrigin( startPos + <0, 0, 60> )
	ziplineEnd.SetParent( mover )

	CopyRealmsFromTo( inflatable, mover )

	entity weight = CreateWeight ( startPos, startAngles )
	weight.SetOwner( inflatable )
	inflatable.LinkToEnt( weight )
	weight.SetParent( mover )

	EmitSoundOnEntity( weight, SFX_REDEPLOY_BALLOON_ZIPLINE_EXTEND )

	CopyRealmsFromTo( inflatable, weight )

	weight.EndSignal( "OnDeath" )
	weight.EndSignal( "OnDestroy" )

	//Sets initial colors
	UpdateDamageColors( inflatable, weight )

	entity push = CreatePushTrigger( endPos + REDEPLOY_BALLOON_WEIGHT_PUSH_OFFSET,
		REDEPLOY_BALLOON_WEIGHT_PUSH_SCRIPT_NAME,
		REDEPLOY_BALLOON_WEIGHT_PUSH_RADIUS,
		REDEPLOY_BALLOON_WEIGHT_PUSH_HALF_HEIGHT,
		REDEPLOY_BALLOON_WEIGHT_PUSH_HALF_HEIGHT,
		REDEPLOY_BALLOON_WEIGHT_PUSH_STRENGTH )

	CopyRealmsFromTo( inflatable, push )
	push.Disable()

	entity waypoint = CreateWaypoint( inflatable )
	inflatable.LinkToEnt( waypoint )

	mover.NonPhysicsMoveTo( endPos + file.buryDist, deployDuration, 0.0, 0.0 )

	file.playersOnZipline[ziplineStart] <- 0

	int team          = waypoint.GetTeam()
	entity minimapObj = CreatePropScript( $"mdl/dev/empty_model.rmdl", waypoint.GetOrigin() )
	SetTargetName( minimapObj, "redeploy_balloon" )
	minimapObj.SetOwner( waypoint )
	minimapObj.Minimap_SetCustomState( eMinimapObject_prop_script.REDEPLOY_BALLOON )
	minimapObj.Minimap_SetAlignUpright( true )
	minimapObj.DisableHibernation()
	minimapObj.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
	array<entity> players = GetPlayerArray()
	foreach ( player in players )
	{
		minimapObj.Minimap_Hide( player.GetTeam(), null )
	}
	minimapObj.Minimap_AlwaysShow( team, null )

	OnThreadEnd(
		function () : ( ziplineStart, ziplineEnd, weight, mover, waypoint, push, endPos, minimapObj )
		{
			delete file.playersOnZipline[ziplineStart]
			if ( IsValid( ziplineStart ) )
				ziplineStart.Destroy()
			if ( IsValid( ziplineEnd ) )
				ziplineEnd.Destroy()
			if ( IsValid( weight ) )
			{
				EmitSoundAtPosition( TEAM_ANY, endPos, SFX_REDEPLOY_BALLOON_WEIGHT_DEATH, weight )
				entity deathFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( VFX_REDEPLOY_BALLOON_WEIGHT_DESTROYED ), weight.GetOrigin(), weight.GetAngles() )
				CopyRealmsFromTo( weight, deathFx )
				StopSoundOnEntity( weight, SFX_REDEPLOY_BALLOON_ZIPLINE_EXTEND )
				weight.Destroy()
			}
			if ( IsValid( mover ) )
				mover.Destroy()
			if ( IsValid( waypoint ) )
				waypoint.Destroy()
			if ( IsValid( push ) )
				push.Destroy()
			if ( IsValid( minimapObj ) )
				minimapObj.Destroy()
		}
	)

	wait deployDuration - 0.2

	push.Enable()
	push.SearchForNewTouchingEntity()

	wait 0.2

	PlayImpactFXTable( endPos, weight, VFX_REDPLOY_BALLOON_WEIGHT_IMPACT_TABLE )
	entity shake = CreateAirShake( endPos, 8, 50, 0.5, 800 )
	CopyRealmsFromTo( inflatable, shake )

	DropPod_ClearLandingZone( endPos, weight, 15, 15, false )

	push.Destroy()

	wait 0.1

	//Show bottom waypoint
	waypoint.SetWaypointInt( 0, 1 )
	ziplineStart.Zipline_Enable()

	ziplineEnd.ClearParent()
	weight.ClearParent()
	mover.Destroy()

	//Make sure it ends up in the right spot every time
	weight.SetOrigin( endPos + file.buryDist )

	AddEntToInvalidEntsForPlacingPermanentsOnto( weight )
	AddEntityDestroyedCallback( weight,
		void function( entity ent ) : ( weight )
		{
			RemoveEntFromInvalidEntsForPlacingPermanentsOnto( ent )
		}
	)
	AddRefEntAreaToInvalidOriginsForPlacingPermanentsOnto( weight, REDEPLOY_BALLOON_INVALID_PLACEMENT_MIN_AREA, REDEPLOY_BALLOON_INVALID_PLACEMENT_MAX_AREA )
	AddEntityDestroyedCallback( weight,
		void function( entity ent ) : ( weight )
		{
			RemoveRefEntAreaFromInvalidOriginsForPlacingPermanentsOnto( ent )
		}
	)
	//DEBUG
	//entity weightProxy = CreatePropDynamic( MDL_REDEPLOY_BALLOON_WEIGHT_OLD, endPos + file.buryDist + <0, 14, -5>, <0, 0, 0>, SOLID_VPHYSICS, 4500 )

	//TODO show balloon explosion in the kill feed
	if ( file.lifetimeSec <= 0 ) //we live forever
	{
		WaitForever()
	}
	else
	{
		const float damageTickSec = 1

		float totalTicks  = file.lifetimeSec / damageTickSec
		int damagePerTick = int(ceil( inflatable.GetMaxHealth() / totalTicks ) )

		while( inflatable.GetHealth() > 0 )
		{
			wait damageTickSec
			int targetHealth = inflatable.GetHealth() - damagePerTick
			if ( targetHealth <= 0 )
			{
				//We set the health to 1 and wait until there isn't anyone riding the balloon
				if ( file.playersOnZipline[ziplineStart] > 0 )
				{
					inflatable.SetHealth( REDEPLOY_BALLOON_LIFETIME_MIN_HEALTH )
					UpdateWaypointHealth( inflatable )
				}

				while( file.playersOnZipline[ziplineStart] > 0 )
					WaitFrame()

				UpdateDamageState( inflatable, float(damagePerTick), true )
				inflatable.SetHealth( 0 )
				UpdateWaypointHealth( inflatable )
				break
			}
			else
			{
				UpdateDamageState( inflatable, float(damagePerTick), false )
				inflatable.SetHealth( targetHealth )
				UpdateWaypointHealth( inflatable )
			}
		}
	}
}

void function RedeployBalloon_OnZiplineMount( entity player, entity zipline )
{
	if ( zipline in file.playersOnZipline )
	{
		file.playersOnZipline[zipline] += 1
		entity ornull waypointOrNull = GetWaypointFromInflatable( zipline.GetOwner() )
		if ( IsValid( waypointOrNull ) )
		{
			entity waypoint = expect entity(waypointOrNull)
			Remote_CallFunction_Replay( player, "ServerToClient_OnZiplineMount", waypoint )
		}
	}
}

void function RedeployBalloon_OnZiplineStop( entity player )
{
	entity zipline = player.Zipline_GetLastZipline()

	if ( !IsValid( zipline ) )
		return

	if ( zipline in file.playersOnZipline )
	{
		file.playersOnZipline[zipline] -= 1
		Remote_CallFunction_Replay( player, "ServerToClient_OnZiplineStop" )
	}
}
#endif


#if SERVER
void function RedeployBalloon_OnPostDamaged( entity ent, var damageInfo )
{
	if ( !IsValid( ent ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )
	entity weapon   = DamageInfo_GetWeapon( damageInfo )

	if ( !IsValid( attacker ) )
		return

	bool destroyed = (ent.GetHealth() - DamageInfo_GetDamage( damageInfo )) <= 0

	if ( attacker.IsPlayer() )
	{
		DamageInfo_AddCustomDamageType( damageInfo, DF_NO_HITBEEP )
		DamageInfo_AddCustomDamageType( damageInfo, DAMAGEFLAG_VICTIM_HAS_VORTEX )
		//DamageInfo_AddCustomDamageType( damageInfo, DF_SOUR )

		if ( destroyed )
			DamageInfo_AddCustomDamageType( damageInfo, DF_KILLSHOT )

		attacker.NotifyDidDamage( ent, 0,
			DamageInfo_GetDamagePosition( damageInfo ),
			DamageInfo_GetCustomDamageType( damageInfo ),
			DamageInfo_GetDamage( damageInfo ),
			DamageInfo_GetDamageFlags( damageInfo ) | DF_NO_HITBEEP | DAMAGEFLAG_VICTIM_HAS_VORTEX,
			DamageInfo_GetHitGroup( damageInfo ),
			DamageInfo_GetWeapon( damageInfo ),
			DamageInfo_GetDistFromAttackOrigin( damageInfo ) )
	}

	UpdateDamageState( ent, DamageInfo_GetDamage( damageInfo ), destroyed )
	UpdateWaypointHealth( ent, true )
}

void function UpdateWaypointHealth( entity inflatable, bool playerDamaged = false )
{
	entity ornull waypointOrNull = GetWaypointFromInflatable( inflatable )
	if ( !IsValid( waypointOrNull ) )
		return

	//float percent = ceil( (float(inflatable.GetHealth()) / float(inflatable.GetMaxHealth())) * REDEPLOY_BALLOON_LIFETIME_SEC )

	entity waypoint = expect entity(waypointOrNull)
	waypoint.SetWaypointFloat( 0, float(inflatable.GetHealth()) )

	if ( playerDamaged )
		waypoint.SetWaypointGametime( 3, Time() )
}

entity ornull function GetWaypointFromInflatable( entity inflatable )
{
	Assert( inflatable.GetLinkEntArray().len() > 0, "Redeploy Balloon Inflatable has no linked ents!" )
	array<entity> linkedEnts = inflatable.GetLinkEntArray()
	foreach ( entity ent in linkedEnts )
	{
		if ( IsValid( ent ) && ent.GetScriptName() == REDEPLOY_BALLOON_WAYPOINT_SCRIPT_NAME )
			return ent
	}
	return null
}

entity ornull function GetWeightFromInflatable( entity inflatable )
{
	array<entity> linkedEnts = inflatable.GetLinkEntArray()
	foreach ( entity ent in linkedEnts )
	{
		if ( IsValid( ent ) && ent.GetScriptName() == REDEPLOY_BALLOON_WEIGHT_SCRIPT_NAME )
			return ent
	}
	return null
}

void function UpdateDamageState( entity inflatable, float damage, bool destroyed )
{
	if ( destroyed )
	{
		entity deathFx = StartParticleEffectInWorld_ReturnEntity( GetParticleSystemIndex( VFX_REDEPLOY_BALLOON_DESTROYED ), inflatable.GetOrigin(), inflatable.GetAngles() )
		CopyRealmsFromTo( inflatable, deathFx )
		EmitSoundAtPosition( TEAM_ANY, inflatable.GetOrigin(), SFX_REDEPLOY_BALLOON_DEATH, inflatable )
		return
	}

	int health          = inflatable.GetHealth()
	float healthChanged = inflatable.GetHealth() - damage
	int maxHealth       = inflatable.GetMaxHealth()
	float prevHealth    = float (health) / float(maxHealth)
	float currHealth    = healthChanged / float(maxHealth)

	const float DMG_NONE = .66//0.5//0.66//1.0
	const float DMG_SMALL = 0.33//0.66
	const float DMG_MED = 0.25//0.33

	if ( prevHealth > DMG_SMALL && currHealth <= DMG_SMALL )
	{
		SetDamageState( inflatable, 2 )
		entity ornull weight = GetWeightFromInflatable( inflatable )
		if ( weight == null )
			return
		expect entity(weight)
		UpdateDamageColors( inflatable, weight )
	}
	else    if ( prevHealth >= DMG_NONE && currHealth < DMG_NONE )
	{
		SetDamageState( inflatable, 1 )
		entity ornull weight = GetWeightFromInflatable( inflatable )
		if ( weight == null )
			return
		expect entity(weight)
		UpdateDamageColors( inflatable, weight )
	}
}

vector function GetColorForDamageState( int damageState )
{
	//TODO we should maybe have color blind options?
	switch( damageState )
	{
		case 0: //HEALTHY
		return <0.216, 0.77, 0.894>//<0, 1, 1>

		case 1: //INJURED
		return <1, 0.64, 0.12>//<1, 0.64, 0>

		case 2: //DYING
		return <0.98, 0.11, 0.12>//<1, 0, 0>
	}

	//We should never be here
	return <0, 0, 0>
}

void function SetDamageState( entity inflatable, int damageState )
{
	//Unused value in entitystruct - we could probably switch this over to the waypoint if need be
	inflatable.e.embarkCount = damageState
}

int function GetDamageState( entity inflatable )
{
	//Unused value in entitystruct
	return inflatable.e.embarkCount
}

void function UpdateDamageColors( entity inflatable, entity weight )
{
	vector targetColor = GetColorForDamageState( GetDamageState( inflatable ) )
	float intensity    = 1.0
	UpdateColors( inflatable, weight, targetColor, intensity )
}

void function UpdateColors( entity inflatable, entity weight, vector color, float intensity = 1.0 )
{
	//Update the color of each ent here
	vector colorRGB    = color * 255.0 * intensity
	string stringColor = colorRGB.x + " " + colorRGB.y + " " + colorRGB.z
	inflatable.kv.rendercolor = stringColor
	weight.kv.rendercolor     = stringColor
}
#endif

#if CLIENT

void function OnWaypointCreated( entity wp )
{
	int wpType = wp.GetWaypointType()

	if ( wpType == eWaypoint.REDEPLOY_BALLOON_LIFE )
	{
		thread RedeployBalloon_UpdateWaypoint_Thread( wp )
	}
}

void function OnPropDynamicCreate( entity prop )
{
	if ( prop.GetScriptName() == REDEPLOY_BALLOON_WEIGHT_SCRIPT_NAME )
	{
		AddRefEntAreaToInvalidOriginsForPlacingPermanentsOnto( prop, REDEPLOY_BALLOON_INVALID_PLACEMENT_MIN_AREA, REDEPLOY_BALLOON_INVALID_PLACEMENT_MAX_AREA )
		AddEntityDestroyedCallback( prop,
			void function( entity ent ) : ( prop )
			{
				RemoveRefEntAreaFromInvalidOriginsForPlacingPermanentsOnto( ent )
			}
		)
	}
}


void function RedeployBalloon_UpdateWaypoint_Thread( entity wp )
{
	entity player = GetLocalViewPlayer()

	if ( !IsValid( player ) || !IsValid( wp ) )
		return

	wp.SetDoDestroyCallback( true )
	wp.EndSignal( "OnDeath" )
	wp.EndSignal( "OnDestroy" )

	float width  = 220
	float height = 220
	vector right = <0, 1, 0> * height * 0.5
	vector fwd   = <1, 0, 0> * width * 0.5 * -1.0
	vector org   = <0, 0, 0>

	var topo = RuiTopology_CreatePlane( org - right * 0.5 - fwd * 0.5, fwd, right, true )
	RuiTopology_SetParent( topo, wp )

	array<var> ruis

	var rui = RuiCreate( RUI_REDEPLOY_BALLOON_WAYPOINT, topo, RUI_DRAW_WORLD, 1 )

	ruis.append( rui )

	bool isOwned = IsFriendlyTeam( wp.GetTeam(), player.GetTeam() )

	var bottomRui = CreateCockpitPostFXRui( RUI_REDEPLOY_BALLOON_WAYPOINT, 1 )
	RuiTrackFloat3( bottomRui, "playerAngles", player, RUI_TRACK_EYEANGLES_FOLLOW )
	RuiTrackFloat3( bottomRui, "worldPos", wp, RUI_TRACK_ABSORIGIN_FOLLOW )
	RuiSetFloat3( bottomRui, "offset", <0, 0, -file.height> ) //put this one at the bottom of the balloon
	RuiTrackFloat( bottomRui, "curHP", wp, RUI_TRACK_WAYPOINT_FLOAT, 0 )
	RuiTrackFloat( bottomRui, "maxHP", wp, RUI_TRACK_WAYPOINT_FLOAT, 1 )
	RuiTrackGameTime( bottomRui, "playerDamage", wp, RUI_TRACK_WAYPOINT_GAMETIME, 3 )
	//RuiTrackFloat( ownedRui, "damageTaken", wp, RUI_TRACK_WAYPOINT_FLOAT, 2 )
	ruis.append( bottomRui )

	var topRui = CreateCockpitPostFXRui( RUI_REDEPLOY_BALLOON_WAYPOINT, 1 )
	RuiTrackFloat3( topRui, "playerAngles", player, RUI_TRACK_EYEANGLES_FOLLOW )
	RuiTrackFloat3( topRui, "worldPos", wp, RUI_TRACK_ABSORIGIN_FOLLOW )
	RuiSetFloat3( topRui, "offset", <0, 0, 200> ) //put this one at the top of the balloon
	RuiTrackFloat( topRui, "curHP", wp, RUI_TRACK_WAYPOINT_FLOAT, 0 )
	RuiTrackFloat( topRui, "maxHP", wp, RUI_TRACK_WAYPOINT_FLOAT, 1 )
	RuiTrackGameTime( topRui, "playerDamage", wp, RUI_TRACK_WAYPOINT_GAMETIME, 3 )
	RuiSetBool( topRui, "hideIcon", true ) //put this one at the bottom of the balloon
	RuiSetBool( topRui, "useTight", true )
	//RuiTrackFloat( ownedRui, "damageTaken", wp, RUI_TRACK_WAYPOINT_FLOAT, 2 )
	ruis.append( topRui )

	OnThreadEnd(
		function() : ( topo, ruis )
		{
			foreach ( rui in ruis )
				RuiDestroy( rui )
			RuiTopology_Destroy( topo )
		}
	)

	while ( IsValid( wp ) )
	{
		//Bottom RUI logic
		bool displayBottomRui = wp.GetWaypointInt( 0 ) == 1
		bool displayTopRui    = false
		bool isInRange        = false

		if ( IsValid( player ) && IsValid( wp.GetParent() ) )
		{
			float dist = Distance2DSqr( player.EyePosition(), wp.GetOrigin() )
			isInRange = (dist > REDEPLOY_BALLOON_WAYPOINT_MIN_DISTANCE_SQR) && (dist < REDEPLOY_BALLOON_WAYPOINT_MAX_DISTANCE_SQR)

			displayBottomRui = displayBottomRui && isInRange
			if ( displayBottomRui && !isOwned ) //Additional LoS check for enemies (so you can still get a sneaky balloon)
			{
				TraceResults results = TraceLine( player.EyePosition(), wp.GetOrigin() - <0, 0, file.height>, [player, wp.GetParent()], TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )
				displayBottomRui = results.fraction > 0.95
			}

			//Top RUI logic
			if ( isInRange || (dist < REDEPLOY_BALLOON_WAYPOINT_LONG_MAX_DISTANCE_SQR && PlayerIsInADS( player )) )
			{
				TraceResults results = TraceLine( player.EyePosition(), wp.GetOrigin(), [player, wp.GetParent()], TRACE_MASK_VISIBLE, TRACE_COLLISION_GROUP_NONE )
				displayTopRui = results.fraction > 0.95
			}
		}

		RuiSetBool( bottomRui, "isVisible", displayBottomRui )
		RuiSetBool( topRui, "isVisible", displayTopRui )

		WaitFrame()

		player = GetLocalViewPlayer()
	}
}

void function RedeployBalloon_UpdateZiplineHUD_Thread( entity player, entity waypoint )
{
	if ( !IsValid( player ) || !IsValid( waypoint ) )
		return

	player.EndSignal( SIG_REDEPLOY_BALLOON_STOP_ZIPLINE )
	waypoint.EndSignal( "OnDeath" )
	waypoint.EndSignal( "OnDestroy" )

	if ( player != GetLocalViewPlayer() )
		return

	var rui = CreateCockpitPostFXRui( RUI_REDEPLOY_BALLOON_HUD, HUD_Z_BASE )

	RuiTrackFloat( rui, "curHP", waypoint, RUI_TRACK_WAYPOINT_FLOAT, 0 )
	RuiTrackFloat( rui, "maxHP", waypoint, RUI_TRACK_WAYPOINT_FLOAT, 1 )
	RuiTrackGameTime( rui, "playerDamage", waypoint, RUI_TRACK_WAYPOINT_GAMETIME, 3 )

	OnThreadEnd(
		function() : (rui)
		{
			RuiDestroyIfAlive( rui )
		}
	)

	WaitForever()
}

void function ServerToClient_OnZiplineMount( entity waypoint )
{
	if ( GetLocalViewPlayer() != GetLocalClientPlayer() )
		return

	thread RedeployBalloon_UpdateZiplineHUD_Thread( GetLocalViewPlayer(), waypoint )
}

void function ServerToClient_OnZiplineStop()
{
	if ( GetLocalViewPlayer() != GetLocalClientPlayer() )
		return

	Signal( GetLocalViewPlayer(), SIG_REDEPLOY_BALLOON_STOP_ZIPLINE )
}

void function MinimapPackage_RedeplyBalloon( entity ent, var rui )
{
	#if MINIMAP_DEBUG
		printt( "Adding 'rui/hud/evac_tower/evac_tower_minimap' icon to minimap" )
	#endif
	RuiSetImage( rui, "defaultIcon", $"rui/hud/evac_tower/evac_tower_minimap" )
	RuiSetImage( rui, "clampedDefaultIcon", $"rui/hud/evac_tower/evac_tower_minimap" )
	RuiSetBool( rui, "useTeamColor", false )
	RuiSetFloat( rui, "iconBlend", 1.0 )
}
#endif

#if SERVER
void function AutoEquipInventoryItem( entity takeWeapon, entity ownerPlayer )
{
	ownerPlayer.TakeWeaponByEnt( takeWeapon )

	// We need to call this so the mobile respawn beacon can be taken out of the slot (it stays linked to the hotkey otherwise)
	// It also re-populates the slot with an ordnance.
	waitthread SURVIVAL_AutoEquipOrdnanceFromInventory( ownerPlayer, false )
	Remote_CallFunction_Replay( ownerPlayer, "ServerCallback_RefreshInventoryAndWeaponInfo" )
}
#endif

#if SERVER && DEV
void function DEV_DeployRedeployBalloon( entity player, vector origin )
{
	RedeployBalloon_StartSequence ( player, origin, <0, 0, 0> )
}
#endif

var function OnWeaponPrimaryAttackAnimEvent_redeploy_balloon( entity ent, WeaponPrimaryAttackParams params )
{
	// Reminder note:
	// There is an AE_WPN_PRIMARYATTACK event in attack_mrb_seq.  Without this "empty function" we get an error:
	// Unhandled weapon primary attack callback OnWeaponPrimaryAttack AnimEvent for '' weapon 'mp_ability_mobile_respawn'
	//
	// Q: Why not remove that event?
	// A: B/c really we should be triggering on AE_WPN_PRIMARYATTACK rather than the standard PrimaryAttack callback,
	// but we run into an error if we enable the anim event and disable the standard PrimaryAttack.
	//
	// There is a devwarning in code:
	//	   if ( !this->IsOffhandWeapon() && !weapInfo->isTossWeapon ) // Toss weapons may use anim event CBs for attack, so it's normal for CBs to be missing
	//			DevWarning( "`Unhandled weapon primary attack callback %s for '%s' weapon '%s'\n", g_scriptCBInfo[scriptCB].name, this->GetWeaponClass(), this->GetWeaponName() );
	// ...that fires if you don't implement the standard PrimaryAttack callback.
	//
	// Setting the fire_mode to offhand to avoid the assert triggers a runtime fatal assert as there
	// are assumptions in the fire_mode for ordnances (of which the mrb is considered as one).
	// And mrb is part of the grenade/ordnance slot until a future spot for gadgets can be found.
	//
	// Q: Why not implement it here and leave PrimaryAttack empty?
	// A: 1) The standard PrimaryAttack has had alot more testing over PrimaryAttackAnimEvent.
	//	  2) PrimaryAttackAnimEvent will only work with the currently not-great override found in CL 482698 (only until a more permanent home is found).  If that change is undone then the anim won't play and the beacon will break.
	//	  3) Lifeline's care package also uses the standard PrimaryAttack.

	// Q: Why doesn't Lifeline's care package trigger the same assert?
	// A: The carepackage ability's fire_mode is set to offhand (which it can do, and mrb cannot until it is out of the ordnance slot).

	return 0 // Or we will decrement too many shots from our clip (i.e. one from PrimaryAttack and one from PrimaryAttackAnimEvent).
}

RedeployBalloonPlacementInfo function RedeployBalloon_GetPlacementInfo( entity player )
{
	const MAX_UP_ANGLE = -20
	const MAX_DOWN_ANGLE = 75
	const MIN_DIST_SQR = 72 * 72
	const PARENT_VELOCITY = <0, 0, 0>
	const SIGHT_TRACE_OFFSET = <0, 0, 48>
	const EYE_ANGLE_PITCH_OFFSET = 0

	bool failed = false
	bool hide   = false

	RedeployBalloonPlacementInfo placementInfo
	vector startPos        = player.EyePosition()
	vector flatForward     = FlattenVec( player.GetViewVector() )
	vector placementAngles = ClampAngles( VectorToAngles( flatForward ) + <0, 180, 0> )

	vector eyeAngles = player.EyeAngles()

	GravityLandData landData
	float pitch = GraphCapped( eyeAngles.x + EYE_ANGLE_PITCH_OFFSET, MAX_UP_ANGLE, MAX_DOWN_ANGLE, 0, 1 )
	pitch = PlacementEasing( pitch )

	float clampedPitch      = GraphCapped( pitch, 0, 1, MAX_UP_ANGLE, MAX_DOWN_ANGLE )
	vector clampedEyeAngles = < clampedPitch, eyeAngles.y, eyeAngles.z >
	vector objectVelocity   = AnglesToForward( clampedEyeAngles ) * file.deployVel

	landData = GetGravityLandData( startPos, PARENT_VELOCITY, objectVelocity, file.deployTraceTime, false )

	TraceResults traceResults = landData.traceResults

	vector origin = traceResults.endPos

	if ( !IsValid( traceResults.hitEnt ) )
	{
		origin = landData.points.top()
		failed = true
	}

	if ( DistanceSqr( player.GetOrigin(), origin ) < MIN_DIST_SQR )
	{
		failed = true
		hide   = true
	}

	//Additional check for balloon to prevent clipping
	if ( !failed )
	{
		const boundsMin = <-230, -230, 100>
		const boundsMax = <230, 230, 585>
		vector pos              = origin + <0, 0, file.height>
		TraceResults airResults = TraceHull( pos, pos, boundsMin, boundsMax, [ ], TRACE_MASK_PLAYERSOLID, TRACE_COLLISION_GROUP_PLAYER_MOVEMENT, <0, 0, 1>, player )

		failed = airResults.fraction < 1.0
		//DebugDrawBox( pos, boundsMin, boundsMax, failed ? COLOR_RED: COLOR_GREEN, 1, 0.1 )
	}

	if ( !failed && !VerifyAirdropPoint( origin, placementAngles.y, true, player ) )
	{
		failed = true
	}

	placementInfo.origin        = origin
	placementInfo.angles        = placementAngles
	placementInfo.surfaceNormal = traceResults.surfaceNormal
	placementInfo.failed        = failed
	placementInfo.hide          = hide
	return placementInfo
}

//Taken from care package
float function PlacementEasing( float frac )
{
	// used to manipulate the placement throw vector such that the destination is fairly stable infront of the player,
	// but still possible to deploy at a steep downwards angle from on top of a building.

	Assert( frac >= 0.0 && frac <= 1.0 )

	const float CUT_POINT = 1
	const float DIVISIONS = 2
	const float MID_VALUE = 0.35

	frac *= DIVISIONS
	if ( frac < CUT_POINT )
		return Tween_QuadEaseOut( frac / CUT_POINT ) * MID_VALUE
	return MID_VALUE + Tween_QuadEaseIn( (frac - CUT_POINT) / (DIVISIONS - CUT_POINT) ) * (1 - MID_VALUE)
}

                                   