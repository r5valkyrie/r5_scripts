global function ClSnake_Init
global function Snake_Start
global function Snake_Stop

const asset SQUARE = $"mdl/thunderdome/thunderdome_cage_floor_128x128_01.rmdl"

struct
{
	array<vector> snake = []
	array<entity> snakeSquares = []
	array<entity> borderSquares = []

	int gridWidth = 20
	int gridHeight = 15

	float baseTickRate = 0.2
	float tickRate = 0.2

	vector snakeDir = <0, 1, 0>

	vector apple = <0, 0, 0>
	entity appleSquare = null

	vector boardOrigin = <0, 0, 0>

	bool isPlaying = false
	bool bordersCreated = false

	int appleCount = 0

} file


void function ClSnake_Init()
{
	PrecacheModel( SQUARE )
	RegisterSignal( "snakeGameOver" )
}


void function Snake_Start()
{
	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) )
		return

	if ( file.isPlaying )
	{
		Signal( player, "snakeGameOver" )
		wait 0.1
	}

	file.boardOrigin = player.GetOrigin() //+ <1500, 1250, -900>
	thread PlaySnake( player )
}


void function Snake_Stop()
{
	entity player = GetLocalClientPlayer()
	if ( !IsValid( player ) )
		return

	if ( file.isPlaying )
		Signal( player, "snakeGameOver" )
}


void function PlaySnake( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "snakeGameOver" )

	file.isPlaying = true

	OnThreadEnd(
		function() : ()
		{
			CleanupAllSnakeEntities()
			file.isPlaying = false
		}
	)

	if ( file.bordersCreated )
	{
		DestroyBorders()
	}

	ClearSnake()
	file.snake = []
	file.snakeSquares = []
	file.snakeDir = <0, 1, 0>
	file.appleCount = 0
	file.tickRate = file.baseTickRate

	if ( IsValid( file.appleSquare ) )
	{
		file.appleSquare.Destroy()
		file.appleSquare = null
	}

	CreateBorders()

	wait 0.2

	CreateSnake()
	CreateApple()

	wait 3.0

	thread GetPlayerInput( player )

	while ( true )
	{
		MoveSnakeTo( file.snake[file.snake.len() - 1] + file.snakeDir )
		wait file.tickRate
	}
}


void function CleanupAllSnakeEntities()
{
	ClearSnake()
	file.snake = []
	file.snakeSquares = []

	if ( IsValid( file.appleSquare ) )
	{
		file.appleSquare.Destroy()
		file.appleSquare = null
	}

	DestroyBorders()
}


void function ClearSnake()
{
	for ( int i = 0; i < file.snakeSquares.len(); ++i )
	{
		if ( IsValid( file.snakeSquares[i] ) )
			file.snakeSquares[i].Destroy()
	}
}


void function DestroyBorders()
{
	for ( int i = 0; i < file.borderSquares.len(); ++i )
	{
		if ( IsValid( file.borderSquares[i] ) )
			file.borderSquares[i].Destroy()
	}
	file.borderSquares = []
	file.bordersCreated = false
}


void function GetPlayerInput( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "snakeGameOver" )

	while ( true )
	{
		if ( player.IsInputCommandHeld( IN_FORWARD ) )
		{
			if ( !VectorsEqual( file.snakeDir, <0, 0, -1> ) )
				file.snakeDir = <0, 0, 1>
		}
		else if ( player.IsInputCommandHeld( IN_BACK ) )
		{
			if ( !VectorsEqual( file.snakeDir, <0, 0, 1> ) )
				file.snakeDir = <0, 0, -1>
		}
		else if ( player.IsInputCommandHeld( IN_MOVELEFT ) )
		{
			if ( !VectorsEqual( file.snakeDir, <0, 1, 0> ) )
				file.snakeDir = <0, -1, 0>
		}
		else if ( player.IsInputCommandHeld( IN_MOVERIGHT ) )
		{
			if ( !VectorsEqual( file.snakeDir, <0, -1, 0> ) )
				file.snakeDir = <0, 1, 0>
		}

		WaitFrame()
	}
}


bool function VectorsEqual( vector a, vector b )
{
	return a.x == b.x && a.y == b.y && a.z == b.z
}


void function CreateApple()
{
	vector pos

	while ( true )
	{
		int randZ = RandomInt( file.gridHeight )
		int randY = RandomInt( file.gridWidth )

		pos = <0, randY, randZ>

		if ( !file.snake.contains( pos ) )
			break
	}

	file.appleSquare = CreateSquare( pos, 2 )
	file.apple = pos
	file.appleCount += 1
}


void function CreateSnake()
{
	int posZ = int( floor( file.gridHeight / 2 ) )
	int posY = int( floor( file.gridWidth / 2 ) )

	vector s0 = <0, posY, posZ>
	vector s1 = <0, posY - 1, posZ>
	vector s2 = <0, posY - 2, posZ>

	entity ss0 = CreateSquare( s0, 1 )
	entity ss1 = CreateSquare( s1, 1 )
	entity ss2 = CreateSquare( s2, 1 )

	file.snake = [s2, s1, s0]
	file.snakeSquares = [ss2, ss1, ss0]
}


entity function CreateSquare( vector gridPos, int color )
{
	vector worldPos = file.boardOrigin + <128 * gridPos.x, -128 * gridPos.y, 128 * gridPos.z>

	entity square = CreateClientSidePropDynamic( worldPos, <90, 0, 0>, SQUARE )

	string highlightName
	switch ( color )
	{
		case 1:
			highlightName = "snake_green"
			break
		case 2:
			highlightName = "snake_apple"
			break
		case 3:
			highlightName = "snake_gameover"
			break
		default:
			highlightName = "snake_border"
			break
	}

	Highlight_SetNeutralHighlight( square, highlightName )

	return square
}


void function MoveSnakeTo( vector pos )
{
	entity player = GetLocalClientPlayer()

	if ( !IsOutOfBounds( pos ) )
	{
		if ( !IsApple( pos ) )
		{
			if ( IsValid( file.snakeSquares[0] ) )
				file.snakeSquares[0].Destroy()

			file.snakeSquares.remove( 0 )
			file.snake.remove( 0 )

			entity ss = CreateSquare( pos, 1 )
			file.snake.append( pos )
			file.snakeSquares.append( ss )
		}
		else
		{
			if ( IsValid( file.appleSquare ) )
			{
				file.appleSquare.Destroy()
				file.appleSquare = null
			}

			entity ss = CreateSquare( pos, 1 )
			file.snake.append( pos )
			file.snakeSquares.append( ss )

			CreateApple()

			if ( file.appleCount <= 10 )
				file.tickRate = file.baseTickRate - 0.01 * file.appleCount
		}
	}
	else
	{
		ClearSnake()
		file.snakeSquares = []

		for ( int i = 0; i < file.snake.len(); ++i )
		{
			entity ssyellow = CreateSquare( file.snake[i], 3 )
			file.snakeSquares.append( ssyellow )
		}

		if ( IsValid( player ) )
			Signal( player, "snakeGameOver" )
	}
}


bool function IsApple( vector pos )
{
	return file.apple == pos
}


bool function IsOutOfBounds( vector pos )
{
	if ( pos.y >= file.gridWidth || pos.y < 0 )
		return true

	if ( pos.z >= file.gridHeight || pos.z < 0 )
		return true

	if ( file.snake.contains( pos ) )
		return true

	return false
}


void function CreateBorders()
{
	// bottom
	for ( int i = 0; i < file.gridWidth + 2; ++i )
	{
		file.borderSquares.append( CreateSquare( <0, i - 1, -1>, 0 ) )
	}

	// left
	for ( int i = 0; i < file.gridHeight; ++i )
	{
		file.borderSquares.append( CreateSquare( <0, -1, i>, 0 ) )
	}

	// right
	for ( int i = 0; i < file.gridHeight; ++i )
	{
		file.borderSquares.append( CreateSquare( <0, file.gridWidth, i>, 0 ) )
	}

	// top
	for ( int i = 0; i < file.gridWidth + 2; ++i )
	{
		file.borderSquares.append( CreateSquare( <0, i - 1, file.gridHeight>, 0 ) )
	}

	file.bordersCreated = true
}
