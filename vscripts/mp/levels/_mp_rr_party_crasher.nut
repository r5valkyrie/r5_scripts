global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	//printt("PARTY CRASHER LOADED!")
	//PrecacheModel($"mdl/levels_terrain/mp_rr_canyonlands/waterfall_canyonlands_04.rmdl")
	AddCallback_EntitiesDidLoad( PartyCrasherOnEntitiesDidLoad )

	#if SERVER
	PrecacheModel( $"mdl/props/ash_hologram/holo_ash_bust.rmdl" )
	thread InitARBarriers()
	thread SpawnAshHolo()
	#endif
}

#if SERVER
void function InitARBarriers()
{
	AddSpawnCallback( "func_brush", void function ( entity brush )
	{
		//brush.Destroy()
		brush.NotSolid()
	} )
}
#endif

void function PartyCrasherOnEntitiesDidLoad()
{
    SpawnMovingLights()
}

void function SpawnAshHolo()
{
    entity head1 = CreatePropDynamic( $"mdl/props/ash_hologram/holo_ash_bust.rmdl", <-2685.55, 4041.76, 720>, <0,50,0> )
	head1.SetSkin(3)
	head1.SetModelScale(0.4)
	entity head2 = CreatePropDynamic( $"mdl/props/ash_hologram/holo_ash_bust.rmdl", <1724.13, -3584.71, 720>, <0,190,0> )
	head2.SetSkin(3)
	head2.SetModelScale(0.4)
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