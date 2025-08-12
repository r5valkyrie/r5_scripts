untyped
global function CodeCallback_RegisterClass_C_Player

var function CodeCallback_RegisterClass_C_Player()
{
	C_Player.ClassName <- "C_Player"

	C_Player.classChanged <- true
	C_Player.cv <- null
	
	C_Player.canUseZipline <- true
	
	function C_Player::SetCanUseZipline( setting ) //todo: move to code 
	{
		entity player = expect entity ( this )
		
		player.canUseZipline = expect bool( setting )
		
		if( player.canUseZipline )
		{
			player.p.ziplineUsages = 0
			player.canUseZipline = true
		}
		else
		{
			player.canUseZipline = false
		}
	}
}
