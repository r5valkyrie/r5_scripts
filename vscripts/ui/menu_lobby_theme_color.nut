global function InitLobbyThemeOptionsMenu
global function InitLobbyThemeOptionsColorPanel
global function LobbyTheme_LoadSavedColor
global function LobbyTheme_ApplyToSeasonStyle

void function InitLobbyThemeOptionsMenu( var newMenuArg )
{
	// no-op, panel does the work
}

struct
{
	var					panel

	var                	defaultColorBtn
	table<var, vector>  paletteColorBtns
	var                	previousColorBtn
	var                	applyMannualColorBtn
	var                	applyMannualColorBtnBG

	var                	RTextArea
	var                	GTextArea
	var                	BTextArea

	var 				H_Slider
	var 				SV_Slider

	var                	previousCurrentColorPane

	vector				defaultColor = <199, 21, 11>
	vector				currentColor = <199, 21, 11>
	vector				previousColor = <199, 21, 11>
	array<vector> 		palettes = [
		<199, 21, 11>,     // Meltdown Red
		<30, 144, 255>,    // Blue
		<0, 200, 120>,     // Teal/Green
		<180, 50, 220>,    // Purple
	]

	bool 	isManuallyEnteringColor = false
	vector	manualColor

	bool registeredBindCallbacks = false

	float H_Progress = 0.0
	float SV_Progress = 0.0

	bool isOpen = false
	bool changingColorNotUsingSliders = false
} file

const float LOBBY_VALUE_MIN = 0.3
const float LOBBY_SATURATION_MAX = 1.0

void function InitLobbyThemeOptionsColorPanel( var panel )
{
	file.panel = panel

	SetPanelTabTitle( panel, "#LOBBY_THEME_COLOR" )

	AddPanelEventHandler( file.panel, eUIEvent.PANEL_SHOW, LobbyTheme_OnShowPanel )
	AddPanelEventHandler( file.panel, eUIEvent.PANEL_HIDE, LobbyTheme_OnHidePanel )

	file.defaultColorBtn = Hud_GetChild( file.panel, "BtnDefaultColor" )
	file.previousColorBtn = Hud_GetChild( file.panel, "PreviousColorButton" )
	file.applyMannualColorBtn = Hud_GetChild( file.panel, "ApplyRGBButton" )
	file.applyMannualColorBtnBG = Hud_GetChild( file.panel, "ApplyRGBButtonBG" )

	for( int i = 0; i < file.palettes.len(); i++ )
	{
		file.paletteColorBtns[Hud_GetChild( file.panel, format( "BtnPaletteColor%i", i ))] <- file.palettes[i]
	}

	file.H_Slider =  Hud_GetChild( Hud_GetChild( file.panel, "H_Slider" ), "PrgValue")
	file.SV_Slider =  Hud_GetChild( Hud_GetChild( file.panel, "SV_Slider" ), "PrgValue")

	file.RTextArea = Hud_GetChild( panel, "ColorRTextEntry" )
	AddButtonEventHandler( file.RTextArea, UIE_CHANGE, LobbyTheme_RGB_OnChanged )
	file.GTextArea = Hud_GetChild( panel, "ColorGTextEntry" )
	AddButtonEventHandler( file.GTextArea, UIE_CHANGE, LobbyTheme_RGB_OnChanged )
	file.BTextArea = Hud_GetChild( panel, "ColorBTextEntry" )
	AddButtonEventHandler( file.BTextArea, UIE_CHANGE, LobbyTheme_RGB_OnChanged )

	file.previousCurrentColorPane = Hud_GetChild( file.panel, "CurrentPreviousColor" )

	AddButtonEventHandler( file.defaultColorBtn, UIE_CLICK, LobbyTheme_OnDefaultColorButtonClicked )
	AddButtonEventHandler( file.previousColorBtn, UIE_CLICK, LobbyTheme_OnResetColorButtonClicked )
	AddButtonEventHandler( file.applyMannualColorBtn, UIE_CLICK, LobbyTheme_OnApplyManualColorButtonClicked )

	foreach( paletteBtn, color in file.paletteColorBtns )
	{
		AddButtonEventHandler( paletteBtn, UIE_CLICK, LobbyTheme_OnPaletteColorButtonClicked )
	}

	AddPanelFooterOption( panel, LEFT, BUTTON_B, true, "#B_BUTTON_BACK", "#B_BUTTON_BACK" )

	// Load saved color on init
	LobbyTheme_LoadSavedColor()
}

void function LobbyTheme_LoadSavedColor()
{
	string savedColor = GetConVarString( "lobby_theme_color" )
	if ( savedColor != "" )
	{
		array<string> parts = split( savedColor, " " )
		if ( parts.len() == 3 )
		{
			file.currentColor = < float(parts[0]), float(parts[1]), float(parts[2]) >
			file.previousColor = file.currentColor
			LobbyTheme_ApplyToSeasonStyle( file.currentColor )
		}
	}
	else
	{
		file.currentColor = file.defaultColor
		file.previousColor = file.defaultColor
	}
}

void function LobbyTheme_OnShowPanel( var panel )
{
	LobbyTheme_RegisterBindCallbacks()

	file.H_Progress = OptionsColor_RGBToHSV( file.currentColor ).hue / 360
	file.SV_Progress = OptionsColor_RGBToHSV( file.currentColor ).value / 360

	Hud_SliderControl_SetCurrentValue( Hud_GetChild( file.panel, "H_Slider" ), file.H_Progress )
	Hud_SliderControl_SetCurrentValue( Hud_GetChild( file.panel, "SV_Slider" ),  file.SV_Progress )

	file.changingColorNotUsingSliders = true
	{
		LobbyTheme_UpdateSaturationValueProgress()
		LobbyTheme_UpdateColorDisplay( file.currentColor )
		OptionsColor_UpdateColorSliders( file.panel, file.H_Slider, file.SV_Slider, file.currentColor, file.H_Progress, file.SV_Progress )
		LobbyTheme_UpdatePreviousColorBtn()
		LobbyTheme_UpdateRGBTextAreas( file.currentColor )

		Hud_SetColor( file.RTextArea, 255, 54, 54 )
		Hud_SetColor( file.GTextArea, 31, 255, 68 )
		Hud_SetColor( file.BTextArea, 57, 129, 255 )
	}
	file.changingColorNotUsingSliders = false

	file.isOpen = true
}

void function LobbyTheme_OnHidePanel( var panel )
{
	LobbyTheme_UpdateThemeColor( file.currentColor, false, false )
	LobbyTheme_SaveToConVar()
	file.isOpen = false
	LobbyTheme_DeregisterBindCallbacks()
}

void function LobbyTheme_RegisterBindCallbacks()
{
	if( !file.registeredBindCallbacks )
	{
		file.registeredBindCallbacks = true
		Hud_AddEventHandler( Hud_GetChild( file.panel, "H_Slider" ), UIE_CHANGE, LobbyTheme_HueSliderSelector_OnChanged )
		Hud_AddEventHandler( Hud_GetChild( file.panel, "SV_Slider" ), UIE_CHANGE, LobbyTheme_ValueSliderSelector_OnChanged )
		RegisterButtonPressedCallback( BUTTON_Y, LobbyTheme_RestoreDefaultsButtonClicked )
		RegisterButtonPressedCallback( BUTTON_X, LobbyTheme_OnResetColorButtonClicked )
	}
}

void function LobbyTheme_DeregisterBindCallbacks()
{
	if( file.registeredBindCallbacks )
	{
		Hud_RemoveEventHandler( Hud_GetChild( file.panel, "H_Slider" ), UIE_CHANGE, LobbyTheme_HueSliderSelector_OnChanged )
		Hud_RemoveEventHandler( Hud_GetChild( file.panel, "SV_Slider" ), UIE_CHANGE, LobbyTheme_ValueSliderSelector_OnChanged )
		DeregisterButtonPressedCallback( BUTTON_Y, LobbyTheme_RestoreDefaultsButtonClicked )
		DeregisterButtonPressedCallback( BUTTON_X, LobbyTheme_OnResetColorButtonClicked )
		file.registeredBindCallbacks = false
	}
}

void function LobbyTheme_OnDefaultColorButtonClicked( var btn )
{
	LobbyTheme_RestoreDefaultsButtonClicked( btn )
}

void function LobbyTheme_OnPaletteColorButtonClicked( var btn )
{
	if( btn in file.paletteColorBtns )
	{
		file.changingColorNotUsingSliders = true
		LobbyTheme_UpdateThemeColor( file.paletteColorBtns[btn], false, true )
	}
}

void function LobbyTheme_UpdateThemeColor( vector color, bool validate = false, bool calculateSliderProgress = false )
{
	file.isManuallyEnteringColor = false
	if( file.isOpen )
	{
		if( validate )
			color = ColorPalette_ClampAndValidateColor( color )

		file.currentColor = color
		LobbyTheme_ApplyToSeasonStyle( color )

		if( calculateSliderProgress )
		{
			file.H_Progress = OptionsColor_RGBToHSV( color ).hue / 360
			LobbyTheme_UpdateSaturationValueProgress()
		}

		LobbyTheme_UpdateColorDisplay( file.currentColor )
		OptionsColor_UpdateColorSliders( file.panel, file.H_Slider, file.SV_Slider, file.currentColor, file.H_Progress, file.SV_Progress )
		LobbyTheme_UpdateRGBTextAreas( file.currentColor )
		LobbyTheme_UpdatePreviousColorBtn()
	}
	file.changingColorNotUsingSliders = false
}

void function LobbyTheme_SaveToConVar()
{
	SetConVarString( "lobby_theme_color", format( "%i %i %i", int(file.currentColor.x), int(file.currentColor.y), int(file.currentColor.z) ) )
}

// Derive all SeasonStyleData colors from a single RGB (0-255) color
void function LobbyTheme_ApplyToSeasonStyle( vector rgb255 )
{
	vector base = rgb255 / 255.0  // convert to 0-1 sRGB

	// Compute a darker and brighter variant
	vector dark = base * 0.7
	vector bright = < min(base.x * 1.15, 1.0), min(base.y * 1.15, 1.0), min(base.z * 1.15, 1.0) >
	vector glow = < min(base.x * 1.3, 1.0), min(base.y * 1.3, 1.0), min(base.z * 1.3, 1.0) >

	SeasonStyleData style = GetSeasonStyle()

	style.seasonColor = base
	style.seasonNewColor = bright

	// Tab colors
	style.tabFocusedBGCol = dark
	style.tabSelectedBGCol = base
	style.tabFocusedBarCol = bright
	style.tabSelectedBarCol = bright
	style.tabGlowFocusedCol = glow

	style.tabDefaultTextCol = <0.75, 0.75, 0.75>
	style.tabFocusedTextCol = <1.0, 1.0, 1.0>
	style.tabSelectedTextCol = <1.0, 1.0, 1.0>

	// Subtab colors
	style.subtabFocusedBGCol = dark * 0.85
	style.subtabSelectedBGCol = dark
	style.subtabFocusedBarCol = bright
	style.subtabSelectedBarCol = bright
	style.subtabGlowFocusedCol = glow

	style.subtabDefaultTextCol = <0.65, 0.65, 0.65>
	style.subtabFocusedTextCol = <1.0, 1.0, 1.0>
	style.subtabSelectedTextCol = <1.0, 1.0, 1.0>

	style.hasRefreshedOnce = true
}

void function LobbyTheme_UpdateRGBTextAreas( vector currentColor )
{
	Hud_SetVisible( file.applyMannualColorBtn, file.isManuallyEnteringColor )
	Hud_SetVisible( file.applyMannualColorBtnBG, file.isManuallyEnteringColor )

	string RText = Hud_GetUTF8Text( file.RTextArea )
	if( RText != string( currentColor.x ) || RText == "" )
		Hud_SetUTF8Text( file.RTextArea, ""  + currentColor.x )

	string GText = Hud_GetUTF8Text( file.GTextArea )
	if( GText != string( currentColor.y ) || GText == "" )
		Hud_SetUTF8Text( file.GTextArea, ""  + currentColor.y )

	string BText = Hud_GetUTF8Text( file.BTextArea )
	if( BText != string( currentColor.z ) || BText == "" )
		Hud_SetUTF8Text( file.BTextArea, ""  + currentColor.z )
}

void function LobbyTheme_UpdateColorDisplay( vector currentColor )
{
	RuiSetFloat3( Hud_GetRui( file.defaultColorBtn ), "paletteColor", file.defaultColor )

	RuiSetColorAlpha( Hud_GetRui( file.previousCurrentColorPane ), "previousColor", file.previousColor, 1.0 )
	RuiSetColorAlpha( Hud_GetRui( file.previousCurrentColorPane ), "currentColor", currentColor, 1.0 )

	foreach( paletteBtn, color in file.paletteColorBtns )
	{
		RuiSetFloat3( Hud_GetRui( paletteBtn ), "paletteColor", color )
	}
}

void function LobbyTheme_UpdatePreviousColorBtn()
{
	Hud_SetVisible( file.previousColorBtn, OptionsColor_HasColorChanged( file.previousColor, file.currentColor ) )
}

void function LobbyTheme_UpdateSaturationValueProgress()
{
	HSV updateSaturationValueProgress = OptionsColor_RGBToHSV( file.currentColor )

	if( updateSaturationValueProgress.value > updateSaturationValueProgress.saturation )
	{
		file.SV_Progress = 1.0 - ( ( max( updateSaturationValueProgress.saturation - ( 1.0 - LOBBY_SATURATION_MAX ), 0.0 ) / LOBBY_SATURATION_MAX ) / 2.0 )
	}
	else
	{
		file.SV_Progress = ( max( ( updateSaturationValueProgress.value - LOBBY_VALUE_MIN ), 0 ) )
	}
}

void function LobbyTheme_HueSliderSelector_OnChanged( var button )
{
	float value = Hud_SliderControl_GetCurrentValue( button )

	HSV currentColor = OptionsColor_RGBToHSV( file.currentColor )
	HSV newColor
	{
		newColor.hue        = value * 360
		newColor.saturation = currentColor.saturation
		newColor.value      = currentColor.value
	}
	file.H_Progress = value
	if( !file.changingColorNotUsingSliders )
		LobbyTheme_UpdateThemeColor( OptionsColor_HSVToRGB( newColor ), false, false )
}

void function LobbyTheme_ValueSliderSelector_OnChanged( var button )
{
	float value = Hud_SliderControl_GetCurrentValue( button )

	float centerPoint = 0.5

	HSV newColor
	{
		newColor.hue        = file.H_Progress * 360
		newColor.saturation = ( value <= centerPoint ) ? 1.0 : 1 - ( ( ( value - 0.5 ) * 2 ) * LOBBY_SATURATION_MAX )
		newColor.value      = ( value > centerPoint ) ? 1.0 : LOBBY_VALUE_MIN + ( ( value * 2 ) * ( 1 - LOBBY_VALUE_MIN ) )
	}

	file.SV_Progress = Hud_SliderControl_GetCurrentValue( button )
	if( !file.changingColorNotUsingSliders )
		LobbyTheme_UpdateThemeColor( OptionsColor_HSVToRGB( newColor ), false, false )
}

void function LobbyTheme_RGB_OnChanged( var button )
{
	file.isManuallyEnteringColor = true

	float R = min( float( Hud_GetUTF8Text( file.RTextArea ) ), 255 )
	float G = min( float( Hud_GetUTF8Text( file.GTextArea ) ), 255 )
	float B = min( float( Hud_GetUTF8Text( file.BTextArea ) ), 255 )
	file.manualColor = < R, G, B >

	LobbyTheme_UpdateColorDisplay( file.manualColor )
	LobbyTheme_UpdateRGBTextAreas( file.manualColor )
}

void function LobbyTheme_OnResetColorButtonClicked( var btn )
{
	if( OptionsColor_HasColorChanged( file.previousColor, file.currentColor ) )
	{
		file.changingColorNotUsingSliders = true
		LobbyTheme_UpdateThemeColor( file.previousColor, false, true )
		LobbyTheme_SaveToConVar()
	}
}

void function LobbyTheme_RestoreDefaultsButtonClicked( var button )
{
	file.changingColorNotUsingSliders = true
	LobbyTheme_UpdateThemeColor( file.defaultColor, false, true )
	LobbyTheme_SaveToConVar()
}

void function LobbyTheme_OnApplyManualColorButtonClicked( var btn )
{
	vector validatedColor = ColorPalette_ClampAndValidateColor( file.manualColor )
	file.changingColorNotUsingSliders = true
	LobbyTheme_UpdateThemeColor( validatedColor, true, true )
	LobbyTheme_SaveToConVar()
}
