if( not TETRIS_INV.LOCALPLYMETA ) then
	TETRIS_INV.LOCALPLYMETA = {
		Player = self
	}

	setmetatable( TETRIS_INV.LOCALPLYMETA, TETRIS_INV.PLAYERMETA )
end

hook.Add( "PlayerButtonDown", "TetrisInv.PlayerButtonDown.Open", function( ply, button )
	if( button != KEY_I or IsValid( TETRIS_INV.TEMP.Menu ) ) then return end
    TETRIS_INV.TEMP.Menu = vgui.Create( "tetris_inv_main" )
    TETRIS_INV.TEMP.KeyStillDown = true
end )

hook.Add( "PlayerButtonUp", "TetrisInv.PlayerButtonUp.Close", function( ply, button )
    if( button != KEY_I or not IsValid( TETRIS_INV.TEMP.Menu ) ) then return end

    if( TETRIS_INV.TEMP.KeyStillDown ) then
        TETRIS_INV.TEMP.KeyStillDown = false
        return
    end

    TETRIS_INV.TEMP.Menu:Remove()
end )

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
end
createFonts()

hook.Add( "OnScreenSizeChanged", "TetrisInv.OnScreenSizeChanged.Fonts", createFonts )

TETRIS_INV.COLOR = {
    White = Color( 255, 255, 255 ),
    Black = Color( 0, 0, 0 )
}

net.Receive( "TetrisInv.SendNotification", function()
	notification.AddLegacy( net.ReadString(), net.ReadUInt( 3 ), net.ReadUInt( 6 ) )
end )

net.Receive( "TetrisInv.SendInventoryItems", function()
	local inventoryTable = TETRIS_INV.LOCALPLYMETA:GetInventory()
	for i = 1, net.ReadUInt( 8 ) do
		inventoryTable[net.ReadUInt( 10 )] = {
			net.ReadString(),
			{ net.ReadUInt( 5 ), net.ReadUInt( 5 ), net.ReadUInt( 5 ), net.ReadUInt( 5 ) },
			net.ReadTable()
		}
	end

	TETRIS_INV.LOCALPLYMETA.InventoryTable = inventoryTable
end )

function TETRIS_INV.FUNC.RequestMoveItem( key, newX, newY )
	local inventoryTable = TETRIS_INV.LOCALPLYMETA:GetInventory()

	local itemTransforms = {}
    for k, v in pairs( inventoryTable ) do
		if( k == key ) then continue end
        table.insert( itemTransforms, v[2] )
    end

	if( not TETRIS_INV.FUNC.CanMoveItem( newX, newY, inventoryTable[key][2][3], inventoryTable[key][2][4], itemTransforms ) ) then 
		hook.Run( "TetrisInv.Hooks.UpdateInventory" )
		return
	end

	inventoryTable[key][2][1] = newX
	inventoryTable[key][2][2] = newY

	TETRIS_INV.LOCALPLYMETA.InventoryTable = inventoryTable

    net.Start( "TetrisInv.RequestMoveItem" )
		net.WriteUInt( key, 10 )
		net.WriteUInt( newX, 5 )
		net.WriteUInt( newY, 5 )
	net.SendToServer()
end