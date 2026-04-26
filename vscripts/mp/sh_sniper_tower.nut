global function ShSniperTowers_Init

const string SNIPER_TOWER_PANEL = "sniper_tower_panel"

#if SERVER
const string SNIPER_TOWER_MOVER = "sniper_tower_mover"
const string ZIPLINE_ATTACHMENT_TOP = "zipline_top"
const float ZIPLINE_FALL_SPEED = 2.0
const float SNIPER_TOWER_MOVE_TO_DURATION = 15

// SFX
const string ZIPLINE_DEPLOY_SFX = "Canyonlands_Scr_Bunker_Hatch_Zipline_Drop"
const string SNIPER_TOWER_START_SFX = "Canyonlands_MU3_ObservationTower_Start"
const string SNIPER_TOWER_ASCEND_SFX = "Canyonlands_MU3_ObservationTower_Ascend"
const string SNIPER_TOWER_END_SFX = "Canyonlands_MU3_ObservationTower_End"
#endif //SERVER

struct SniperTowerData
{
	entity panel

	#if SERVER
		entity mover
		entity platform
		vector moverStartOrigin
		vector zipStartPos
		vector zipStartAngles
		vector zipEndPos
	#endif //SERVER
}

struct
{
	table< entity, SniperTowerData >		sniperTowerDataMap
} file

void function ShSniperTowers_Init()
{
	#if SERVER
		AddSpawnCallback_ScriptName( SNIPER_TOWER_MOVER, SniperTower_OnSpawn )
		AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	#endif //SERVER

	#if CLIENT
		AddCreateCallback( "prop_dynamic", OnPanelCreated )
	#endif //CLIENT
}

#if SERVER
void function SniperTower_OnSpawn(entity tower)
{
	tower.AllowZiplines()
}

void function EntitiesDidLoad()
{
	foreach ( entity panel in GetEntArrayByScriptName( SNIPER_TOWER_PANEL ) )
	{
		SniperTowerData data

		data.panel = panel
		data.panel.SetUsable()
		data.panel.SetUsablePriority( USABLE_PRIORITY_MEDIUM )
		data.panel.AddUsableValue( USABLE_CUSTOM_HINTS | USABLE_BY_OWNER | USABLE_BY_PILOTS | USABLE_BY_ENEMIES )
		data.panel.SetSkin( 0 )

		AddCallback_OnUseEntity_ClientServer( data.panel, SniperTower_OnUse )
		SetCallback_CanUseEntityCallback( data.panel, SniperTower_CanUse )

		foreach ( entity linkEnt in panel.GetLinkEntArray() )
		{
			string scriptName = linkEnt.GetScriptName()

			if ( scriptName == SNIPER_TOWER_MOVER )
			{
				data.mover = linkEnt
				data.moverStartOrigin = data.mover.GetOrigin()
				data.panel.SetParent( data.mover )
				data.mover.SetPusher( true )
				//data.mover.SetPusherMovesNearbyVehicles( true )
				data.mover.EnableNonPhysicsMoveInterpolation( false )

				foreach ( entity moverLinkEnt in data.mover.GetLinkEntArray() )
				{
					if ( moverLinkEnt.GetClassName() == "func_brush" )
					{
						data.platform = moverLinkEnt
						data.platform.SetParent( data.mover )
					}
				}
			}
			else if ( scriptName == ZIPLINE_ATTACHMENT_TOP )
			{
				entity zipStart = linkEnt
				data.zipStartPos = zipStart.GetOrigin()
				data.zipStartAngles = zipStart.GetAngles()
				data.zipEndPos = data.zipStartPos + <0, 0, -780>
				zipStart.Destroy()
			}
		}

		file.sniperTowerDataMap[ panel ] <- data
	}
}
#endif //SERVER

#if CLIENT
void function OnPanelCreated( entity panel )
{
	if ( panel.GetScriptName() != SNIPER_TOWER_PANEL )
		return

	AddCallback_OnUseEntity_ClientServer( panel, SniperTower_OnUse )
	SetCallback_CanUseEntityCallback( panel, SniperTower_CanUse )
	AddEntityCallback_GetUseEntOverrideText( panel, SniperTowerUseTextOverride )
}

string function SniperTowerUseTextOverride( entity panel )
{
	return "#SNIPERTOWER_HINT"
}
#endif // CLIENT

bool function SniperTower_CanUse( entity player, entity panel, int useFlags )
{
	if ( !SURVIVAL_PlayerCanUse_AnimatedInteraction( player, panel ) )
		return false

	return true
}

void function SniperTower_OnUse( entity panel, entity player, int useInputFlags )
{
	if ( IsBitFlagSet( useInputFlags, USE_INPUT_LONG ) )
		thread SniperTower_UseThink_Thread( panel, player )
}

void function SniperTower_UseThink_Thread( entity ent, entity playerUser )
{
	ent.EndSignal( "OnDestroy" )
	playerUser.EndSignal( "OnDeath" )

	ExtendedUseSettings settings
	settings.duration = 0.3

	#if SERVER
		settings.successFunc = SniperTower_ExtendedUseSuccess
	#endif //SERVER

	#if CLIENT || UI
		settings.loopSound = "survival_titan_linking_loop"
		settings.successSound = "ui_menu_store_purchase_success"
		settings.icon = $""
		settings.hint = Localize( "#SNIPERTOWER_ACTIVATE" )
		settings.displayRui = $"ui/extended_use_hint.rpak"
		settings.displayRuiFunc = SniperTower_DisplayRui
	#endif //CLIENT || UI

	waitthread ExtendedUse( ent, playerUser, settings )
}

#if CLIENT || UI
void function SniperTower_DisplayRui( entity ent, entity player, var rui, ExtendedUseSettings settings )
{
	RuiSetString( rui, "holdButtonHint", settings.holdHint )
	RuiSetString( rui, "hintText", settings.hint )
	RuiSetGameTime( rui, "startTime", Time() )
	RuiSetGameTime( rui, "endTime", Time() + settings.duration )
}
#endif //CLIENT || UI

#if SERVER
void function SniperTower_ExtendedUseSuccess( entity panel, entity player, ExtendedUseSettings settings )
{
	if ( !IsValid( player ) )
		return

	SniperTowerData data = file.sniperTowerDataMap[panel]
	data.mover.DisallowZiplines()

	EmitSoundAtPosition( TEAM_ANY, data.moverStartOrigin, SNIPER_TOWER_START_SFX, panel )
	EmitSoundAtPosition( TEAM_ANY, data.moverStartOrigin, SNIPER_TOWER_ASCEND_SFX, panel  )

	data.mover.NonPhysicsMoveTo( data.moverStartOrigin + <0, 0, 600>, SNIPER_TOWER_MOVE_TO_DURATION, SNIPER_TOWER_MOVE_TO_DURATION * 0.125, SNIPER_TOWER_MOVE_TO_DURATION * 0.25 )
	panel.SetSkin( 1 )
	panel.UnsetUsable()

	wait SNIPER_TOWER_MOVE_TO_DURATION

	data.mover.AllowZiplines()
	EmitSoundAtPosition( TEAM_ANY, data.mover.GetLocalOrigin(), SNIPER_TOWER_END_SFX, data.mover )
	EmitSoundAtPosition( TEAM_ANY, data.zipStartPos, ZIPLINE_DEPLOY_SFX, data.mover )

	thread BunkerDoor_CreateZipline( data.zipStartPos, data.zipEndPos, true, data.zipStartAngles )
}
#endif //SERVER