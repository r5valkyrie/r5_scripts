untyped

global function IsCrawling
global function CodeCallback_RegisterClass_CAI_BaseNPC
global function SetSpawnOption_AISettings
global function SetSpawnOption_Alert
global function SetSpawnOption_NotAlert
global function SetSpawnOption_SquadName
global function SetSpawnOption_Titanfall
global function SetSpawnOption_Weapon

var function CodeCallback_RegisterClass_CAI_BaseNPC()
{
	#document( "SetSpawnOption_AISettings", "Specify AI Setting" )
	#document( "SetSpawnOption_Alert", "Enable spawn alerted" )
	#document( "SetSpawnOption_NotAlert", "Enable spawn alerted" )
	#document( "SetSpawnOption_SquadName", "Specify spawn squadname" )
	#document( "SetSpawnOption_Titanfall", "npc titan will spawn via titanfall" )
	#document( "SetSpawnOption_Weapon", "Specify spawn weapon and mods" )

	//printl( "Class Script: CAI_BaseNPC" )

	CAI_BaseNPC.ClassName <- "CAI_BaseNPC"

	CAI_BaseNPC.mySpawnOptions_aiSettings <- null
	CAI_BaseNPC.mySpawnOptions_alert <- null
	CAI_BaseNPC.mySpawnOptions_titanfallSpawn <- null
	CAI_BaseNPC.mySpawnOptions_warpfallSpawn <- null
	CAI_BaseNPC.executedSpawnOptions <- null

	function CAI_BaseNPC::ForceCombat()
	{
		this.FireNow( "UpdateEnemyMemory", "!player" )
	}
	//document( CAI_BaseNPC, "ForceCombat", "Force into combat state by updating NPC's memory of the player." )

	function CAI_BaseNPC::InCombat()
	{
		entity enemy = expect entity( this ).GetEnemy()
		if ( !IsValid( enemy ) )
			return false

		return this.CanSee( enemy )
	}
	//document( CAI_BaseNPC, "InCombat", "Returns true if NPC is in combat" )
}

void function SetSpawnOption_AISettings( entity npc, string setting )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.mySpawnOptions_aiSettings = setting
}

void function SetSpawnOption_Alert( entity npc )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.mySpawnOptions_alert = true
}

void function SetSpawnOption_NotAlert( entity npc )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.mySpawnOptions_alert = false
}

void function SetSpawnOption_Weapon( entity npc, string weapon, array<string> mods = [] )
{
	Assert( weapon != "", "Tried to assign no weapon as a spawn weapon" )
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )

	{
		NPCDefaultWeapon spawnoptionsweapon
		spawnoptionsweapon.wep = weapon
		spawnoptionsweapon.mods = mods

		npc.ai.mySpawnOptions_weapon = spawnoptionsweapon
	}
}

void function SetSpawnOption_SquadName( entity npc, string squadName )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	npc.kv.squadname = squadName
}

void function SetSpawnOption_Titanfall( entity npc )
{
	Assert( IsValid( npc ) && npc.IsNPC(), npc + " is not an npc!" )
	Assert( !npc.executedSpawnOptions, npc + " tried to set spawn options after npc was dispatchspawned." )
	Assert( npc.IsTitan(), "npc is for titans only" )
	npc.mySpawnOptions_titanfallSpawn = true
}

bool function IsCrawling( entity npc )
{
	return npc.ai.crawling
}