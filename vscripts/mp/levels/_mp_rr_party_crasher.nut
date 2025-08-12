global function CodeCallback_MapInit

struct {
	entity button1
    entity button2
    entity button3
    bool button1pressed = false
    bool button2pressed = false
    bool button3pressed = false
} file

void function CodeCallback_MapInit()
{
	//printt("PARTY CRASHER LOADED!")
	//PrecacheModel($"mdl/levels_terrain/mp_rr_canyonlands/waterfall_canyonlands_04.rmdl")
	AddCallback_EntitiesDidLoad( PartyCrasherOnEntitiesDidLoad )

	#if SERVER
	thread InitARBarriers()
	#endif
}

#if SERVER
void function InitARBarriers()
{
	AddSpawnCallback( "func_brush", void function ( entity brush )
	{
		brush.Destroy()//TODO: Recover this function once we get correct shaders and arenas -LorryLeKral
	} )
}
#endif

void function PartyCrasherOnEntitiesDidLoad()
{
    SpawnMovingLights()

	//Patch_mp_rr_party_crasher() //(mk): spawn LOS flagged props
}

array<entity> function PerfectZipline(vector startPos,vector endPos,bool pathfinder_model)
{
	vector pathfinder_offset = <0,0,120>
	asset PATHFINDER_ZIP_MODEL = $"mdl/props/pathfinder_zipline/pathfinder_zipline.rmdl"

	entity zipline_start = CreateEntity( "zipline" )
	entity ent_model_start
	zipline_start.kv.Material = "cable/zipline.vmt"
	zipline_start.kv.ZiplineAutoDetachDistance = "160"
	array<entity> ziplineEnts

	ent_model_start = CreatePropDynamic( PATHFINDER_ZIP_MODEL, startPos, <0,0,0>, 6, -1 )
	zipline_start.SetOrigin( startPos + pathfinder_offset)

	entity zipline_end = CreateEntity( "zipline_end" )
	zipline_end.kv.ZiplineAutoDetachDistance = "160"
	entity ent_model_end
	
	ent_model_end = CreatePropDynamic( PATHFINDER_ZIP_MODEL, endPos, <0,0,0>, 6, -1 )
	zipline_end.SetOrigin( endPos + pathfinder_offset)

	zipline_start.LinkToEnt( zipline_end )
	DispatchSpawn( zipline_start )
	DispatchSpawn( zipline_end )

	ziplineEnts = [ zipline_start, zipline_end ,ent_model_start,ent_model_end]
		
	return ziplineEnts
}

void function InitSpecialButtons()
{
    file.button1 = CreateFRButton(<1353,4808,1860>, <0,40,0>, "Secret Button (1/3)")
    file.button2 = CreateFRButton(<3337,892,1870>, <0,30,0>, "Secret Button (2/3)")
    file.button3 = CreateFRButton(<-4034,2586,1990>, <0,-100,0>, "Secret Button (3/3)")
	AddCallback_OnUseEntity( file.button1, void function(entity panel, entity user, int input)
	{
        if(file.button1pressed)
            return
        
        file.button1pressed = true
		ButtonCheck(panel)
	})
    AddCallback_OnUseEntity( file.button2, void function(entity panel, entity user, int input)
	{
        if(file.button2pressed)
            return

        file.button2pressed = true
		ButtonCheck(panel)
	})
    AddCallback_OnUseEntity( file.button3, void function(entity panel, entity user, int input)
	{
        if(file.button3pressed)
            return

        file.button3pressed = true
		ButtonCheck(panel)
	})
}

void function ButtonCheck(entity button)
{
    EmitSoundOnEntity( button, "ui_ingame_markedfordeath_countdowntomarked" )
    button.SetUsePrompts("ACTIVATED", "ACTIVATED")

    button.Dissolve( ENTITY_DISSOLVE_CORE, <0,0,0>, 1000 )

    if(file.button1pressed && file.button2pressed && file.button3pressed)
        thread ActivacteSecret()
}

void function ActivacteSecret()
{
    wait 5

    entity nessy = CreateMapEditorProp( $"mdl/domestic/nessy_doll.rmdl", < -8266.8550, -2482.3440, 6157.1870 >, < -1.3469, -61.0443, -42.0124 >, true, 50000, -1, 100);

    foreach( entity player in GetPlayerArray() )
    {
		Remote_CallFunction_NonReplay( player, "ServerCallback_NessyMessage", 1 )
        EmitSoundOnEntity( nessy, "Canyonlands_Generic_Emit_Leviathan_Vocal_Generic_A" )
    }

    entity nessymover = CreateScriptMover( < -8266.8550, -2482.3440, 6157.1870 >, < -1.3469, -61.0443, -42.0124 > )
    nessy.SetParent( nessymover )

	nessymover.NonPhysicsMoveTo( < -5726.2830, -2482.3440, 7216.6340 >, 30.0, 4.0, 4.0 )
	nessymover.NonPhysicsRotateTo( < -1.3469, -61.0443, -42.0124 >, 15, 5, 5 )
}

void function MovingLights(entity ent, bool rightside)
{
	vector result
	float newAngle = 1.5
	float speed = 1.4
	while(IsValid(ent))
	{
		if(!rightside)
		   result =  ent.GetAngles() + <-speed,0,0>
		else
		   result = ent.GetAngles()  + <speed,0,0>

		if(result.x <= 70)
			rightside = true
		else if(result.x > 130)
			rightside = false
		
		ent.NonPhysicsRotateTo(result, 0.1, 0, 0)
		wait 0.01
	}	
}

void function SpawnMovingLights()
{
	entity beam =  StartParticleEffectInWorld_ReturnEntity(GetParticleSystemIndex( $"P_ar_hot_zone_far" ), <-4672.74414, 11260.5811, 2969.22217>, <70,0,0> )
	entity beam2 = StartParticleEffectInWorld_ReturnEntity(GetParticleSystemIndex( $"P_ar_hot_zone_far" ), <-6948.34473, 8222.79492, 3005.85596>, <130,0,0> )
	entity beam_2 =  StartParticleEffectInWorld_ReturnEntity(GetParticleSystemIndex( $"P_ar_hot_zone_far" ), <-4672.74414, 11260.5811, 2969.22217>, <70,0,0> )
	entity beam2_2 = StartParticleEffectInWorld_ReturnEntity(GetParticleSystemIndex( $"P_ar_hot_zone_far" ), <-6948.34473, 8222.79492, 3005.85596>, <130,0,0> )
	beam_2.SetParent(beam)
	beam2_2.SetParent(beam2)
	
	entity beam3 = StartParticleEffectInWorld_ReturnEntity(GetParticleSystemIndex( $"P_ar_hot_zone_far" ), <6654.4209, -6538.19385, 2883.62305>, <70,0,0> )
	entity beam4 = StartParticleEffectInWorld_ReturnEntity(GetParticleSystemIndex( $"P_ar_hot_zone_far" ), <3891.19507, -7936.33301, 2170.66748>, <130,0,0> )
	entity beam3_2 = StartParticleEffectInWorld_ReturnEntity(GetParticleSystemIndex( $"P_ar_hot_zone_far" ), <6654.4209, -6538.19385, 2883.62305>, <70,0,0> )
	entity beam4_2 = StartParticleEffectInWorld_ReturnEntity(GetParticleSystemIndex( $"P_ar_hot_zone_far" ), <3891.19507, -7936.33301, 2170.66748>, <130,0,0> )
	beam3_2.SetParent(beam3)
	beam4_2.SetParent(beam4)
	
	entity mover1 = CreateScriptMover( beam.GetOrigin() )
	mover1.SetAngles(beam.GetAngles())
	beam.SetParent(mover1)
	
	entity mover2 = CreateScriptMover( beam2.GetOrigin() )
	mover2.SetAngles(beam2.GetAngles())
	beam2.SetParent(mover2)

	entity mover3 = CreateScriptMover( beam3.GetOrigin() )
	mover3.SetAngles(beam3.GetAngles())
	beam3.SetParent(mover3)

	entity mover4 = CreateScriptMover( beam4.GetOrigin() )
	mover4.SetAngles(beam4.GetAngles())
	beam4.SetParent(mover4)
	
	thread MovingLights(mover1, true)
	thread MovingLights(mover2, false)
	thread MovingLights(mover3, true)
	thread MovingLights(mover4, false)		
}