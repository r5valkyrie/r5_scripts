global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	AddCallback_EntitiesDidLoad( PartyCrasherOnEntitiesDidLoad )

	#if SERVER
	PrecacheModel( $"mdl/props/ash_hologram/holo_ash_bust.rmdl" )
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