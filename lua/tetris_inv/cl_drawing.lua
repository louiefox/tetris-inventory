local blur = Material("pp/blurscreen")
function TETRIS_INV.FUNC.DrawBlur( p, a, d )
	local x, y = p:LocalToScreen(0, 0)
	surface.SetDrawColor( 255, 255, 255 )
    surface.SetMaterial( blur )
    
	for i = 1, d do
		blur:SetFloat( "$blur", (i / d ) * ( a ) )
		blur:Recompute()
		if( render ) then render.UpdateScreenEffectTexture() end
		surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
	end
end

function TETRIS_INV.FUNC.ScreenScale( number )
    return math.Round( number*(ScrW()/2560) )
end

local function createFonts()
	surface.CreateFont( "MontserratMedium12", {
		font = "Montserrat Medium",
		extended = false,
		size = TETRIS_INV.FUNC.ScreenScale( 12 ),
		weight = 500,
		outline = false,
	} )

	surface.CreateFont( "MontserratMedium25", {
		font = "Montserrat Medium",
		extended = false,
		size = TETRIS_INV.FUNC.ScreenScale( 25 ),
		weight = 500,
		outline = false,
	} )
end
createFonts()

hook.Add( "OnScreenSizeChanged", "TetrisInv.OnScreenSizeChanged.Fonts", createFonts )

TETRIS_INV.COLOR = {
    White = Color( 255, 255, 255 ),
    Black = Color( 0, 0, 0 )
}