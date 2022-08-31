hook.Add( "KeyPress", "TetrisInv.KeyPress.Pickup", function( ply, key )
    if( key == IN_WALK ) then
        ply.TETRISINV_PICKUP_STARTED = true
        return
    elseif( key == IN_USE and ply.TETRISINV_PICKUP_STARTED ) then
        ply.TETRISINV_PICKUP_STARTED = false
        ply:TetrisInv():PickupEnt( ply:GetEyeTrace().Entity )
    elseif( ply.TETRISINV_PICKUP_STARTED ) then
        ply.TETRISINV_PICKUP_STARTED = false
    end
end )

util.AddNetworkString( "TetrisInv.SendNotification" )
function TETRIS_INV.FUNC.SendNotification( ply, text, notifyType, length )
	net.Start( "TetrisInv.SendNotification" )
		net.WriteString( text )
		net.WriteUInt( notifyType, 4 )
		net.WriteUInt( length, 6 )
	net.Send( ply )
end

util.AddNetworkString( "TetrisInv.RequestMoveItem" )
net.Receive( "TetrisInv.RequestMoveItem", function( len, ply )
    local itemKey = net.ReadUInt( 10 )
    if( not itemKey ) then return end

    local inventoryTable = ply:TetrisInv():GetInventory()
    if( not inventoryTable[itemKey] ) then return end

    local newX, newY = net.ReadUInt( 5 ), net.ReadUInt( 5 )
    if( not newX or not newY or newX == 0 or newY == 0 or newX > TETRIS_INV.CONFIG.GridX or newY > TETRIS_INV.CONFIG.GridY ) then return end

    local oldX, oldY = inventoryTable[itemKey][2][1], inventoryTable[itemKey][2][2]

	inventoryTable[itemKey][2][1] = newX
	inventoryTable[itemKey][2][2] = newY

    ply:TetrisInv():SetInventory( inventoryTable )

    TETRIS_INV.FUNC.SQLQuery( string.format( "UPDATE tetrisinv_inventory SET transformX=%d, transformY=%d WHERE userID=%d AND transformX=%d AND transformY=%d", 
    newX, newY, ply:TetrisInv():GetUserID(), oldX, oldY ) )
end )

util.AddNetworkString( "TetrisInv.RequestUseItem" )
net.Receive( "TetrisInv.RequestUseItem", function( len, ply )
    local itemKey = net.ReadUInt( 10 )
    if( not itemKey ) then return end

    local itemTable = ply:TetrisInv():GetInventory()[itemKey]
    if( not itemTable ) then return end

    local itemTypeInfo = TETRIS_INV.ITEM_TYPES[itemTable[1]] or TETRIS_INV.ITEM_TYPE_DEFAULT
    if( not itemTypeInfo.DoUse ) then return end

    itemTypeInfo.DoUse( ply, itemTable[1], itemTable[3] )

    ply:TetrisInv():RemoveItem( itemKey )
end )

util.AddNetworkString( "TetrisInv.RequestDropItem" )
net.Receive( "TetrisInv.RequestDropItem", function( len, ply )
    local itemKey = net.ReadUInt( 10 )
    if( not itemKey ) then return end

    local itemTable = ply:TetrisInv():GetInventory()[itemKey]
    if( not itemTable ) then return end

    local itemTypeInfo = TETRIS_INV.ITEM_TYPES[itemTable[1]] or TETRIS_INV.ITEM_TYPE_DEFAULT
    if( not itemTypeInfo.DoDrop ) then return end

    itemTypeInfo.DoDrop( ply, itemTable[1], itemTable[3] )

    ply:TetrisInv():RemoveItem( itemKey )
end )