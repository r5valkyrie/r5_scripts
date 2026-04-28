global function CodeCallback_MapInit

const asset ARENA_LEVIATHAN_MODEL = $"mdl/creatures/leviathan/leviathan_kingscanyon_preview_animated.rmdl"

void function CodeCallback_MapInit()
{
	#if SERVER
	PrecacheModel( ARENA_LEVIATHAN_MODEL )
	thread InitARBarriers()
	//thread SpawnAshHolo()
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

void function SpawnAshHolo()
{

}