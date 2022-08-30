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

-- Probably laggy, however I wanted to use shadows and blur
local blur = Material( "pp/blurscreen" )
local currentInfo, currentEnt
local pickupAlpha = 0
hook.Add( "HUDPaint", "TetrisInv.HUDPaint.DrawPickup", function()
    local ply = LocalPlayer()
    local traceEnt = ply:GetEyeTrace().Entity
	if( IsValid( traceEnt ) and TETRIS_INV.CONFIG.ListedEntities[traceEnt:GetClass()] and ply:GetPos():DistToSqr( traceEnt:GetPos() ) <= TETRIS_INV.CONFIG.PickupDistance ) then 
		currentInfo = TETRIS_INV.FUNC.GetDisplayInfo( traceEnt:GetClass(), TETRIS_INV.FUNC.GetEntData( traceEnt ) )
		currentEnt = traceEnt
	end

	if( not currentInfo ) then return end
	pickupAlpha = math.Clamp( pickupAlpha+(currentEnt == traceEnt and 5 or -5), 0, 255 )

	surface.SetAlphaMultiplier( pickupAlpha/255 )

	local bindText = input.LookupBinding( "+walk" ) .. "+" .. input.LookupBinding( "+use" )
	local text = string.upper( bindText .. " PICKUP " .. currentInfo.Name )
	surface.SetFont( "MontserratMedium25" )
	local textW, textH = surface.GetTextSize( text )

	local w, h = textW+25, textH+20

	local x, y = ScrW()/2-w/2, ScrH()*0.8-h/2

	-- Draw shadow
	TETRIS_INV.FUNC.BeginShadow( "test" )
	surface.SetDrawColor( 0, 0, 0 )
	surface.DrawRect( x, y, w, h )
	TETRIS_INV.FUNC.EndShadow( "test", x, y, 1, 1, 1, 100, 0, 0, true )

	-- Draw blur
	surface.SetDrawColor( 255, 255, 255 )
    surface.SetMaterial( blur )
    
	local a, d = 8, 8
	render.SetScissorRect( x, y, x+w, y+h, true )
	for i = 1, d do
		blur:SetFloat( "$blur", (i / d ) * ( a ) )
		blur:Recompute()
		if( render ) then render.UpdateScreenEffectTexture() end
		surface.DrawTexturedRect( 0 * -1, 0 * -1, ScrW(), ScrH() )
	end
	render.SetScissorRect( 0, 0, 0, 0, false )

	-- Draw the rest
	surface.SetDrawColor( 0, 0, 0, 200 )
	surface.DrawOutlinedRect( x, y, w, h )

	local textX, textY = math.floor( x+w/2-textW/2 ), math.floor( y+h/2-textH/2 )

	local outlinewidth = 1
	local steps = ( outlinewidth * 2 ) / 3
	if( steps < 1 ) then steps = 1 end

	for _x = -outlinewidth, outlinewidth, steps do
		for _y = -outlinewidth, outlinewidth, steps do
			draw.SimpleText( text, "MontserratMedium25", textX + _x, textY + _y, TETRIS_INV.COLOR.Black )
		end
	end

	local rarityColor = Color( 50, 255, 50 )

	surface.SetFont( "MontserratMedium25" )
	surface.SetTextPos( textX, textY )

	surface.SetTextColor( TETRIS_INV.COLOR.White )
	surface.DrawText( string.upper( bindText ) .. " PICKUP " )

	surface.SetTextColor( rarityColor )
	surface.DrawText( string.upper( currentInfo.Name ) )

	surface.SetAlphaMultiplier( 1 )
end )