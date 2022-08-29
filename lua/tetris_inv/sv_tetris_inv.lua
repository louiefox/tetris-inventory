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

util.AddNetworkString( "TetrisInv.SendInventoryItems" )
function TETRIS_INV.PLAYERMETA:NetworkItem( ... )
    local keys = { ... }
    local inventoryTable = self.InventoryTable
    net.Start( "TetrisInv.SendInventoryItems" )
        net.WriteUInt( #keys, 8 )

        for i = 1, #keys do
            local key = keys[i]
            net.WriteUInt( key, 10 )

            local item = inventoryTable[key]
            net.WriteString( item[1] )
            net.WriteUInt( item[2][1], 5 )
            net.WriteUInt( item[2][2], 5 )
            net.WriteUInt( item[2][3], 5 )
            net.WriteUInt( item[2][4], 5 )
            net.WriteTable( item[3] )
        end
    net.Send( self.Player )
end

function TETRIS_INV.PLAYERMETA:SetInventory( inventoryTable )
    self.InventoryTable = inventoryTable
end

function TETRIS_INV.PLAYERMETA:PickupEnt( ent )
    if( not IsValid( ent ) ) then return end

    local entClass = ent:GetClass()
    if( not TETRIS_INV.CONFIG.ListedEntities[entClass] ) then return end
    
    local itemTypeInfo = TETRIS_INV.ITEM_TYPES[entClass] or TETRIS_INV.ITEM_TYPE_DEFAULT

    local itemData = itemTypeInfo.GetData( ent )
    local itemSize = itemTypeInfo.GetSize and itemTypeInfo.GetSize( itemData ) or TETRIS_INV.CONFIG.DefaultSize

    local success = self:AddItem( entClass, itemData, itemSize )
    if( not success ) then return end

    ent:Remove()
end

function TETRIS_INV.PLAYERMETA:AddItem( class, itemData, itemSize )
    local inventoryTable = self:GetInventory()

    local itemTransforms = {}
    for k, v in pairs( inventoryTable ) do
        table.insert( itemTransforms, v[2] )
    end
    
    local itemX, itemY
    local itemW, itemH = itemSize[1], itemSize[2]
    for row = 1, TETRIS_INV.CONFIG.GridY-(itemH-1) do
        for col = 1, TETRIS_INV.CONFIG.GridX-(itemW-1) do
            if( not TETRIS_INV.FUNC.CanMoveItem( col, row, itemW, itemH, itemTransforms ) ) then continue end

            itemX, itemY = col, row
            break
        end

        if( itemX ) then break end
    end

    if( not itemX ) then
        TETRIS_INV.FUNC.SendNotification( self.Player, "Your inventory is full!", 1, 5 )
        return false
    end

    local key = table.insert( inventoryTable, { class, { itemX, itemY, itemW, itemH }, itemData } )
    self:SetInventory( inventoryTable )

    self:NetworkItem( key )

    return true
end

util.AddNetworkString( "TetrisInv.RequestMoveItem" )
net.Receive( "TetrisInv.RequestMoveItem", function( len, ply )
    local itemKey = net.ReadUInt( 10 )
    if( not itemKey ) then return end

    local inventoryTable = ply:TetrisInv():GetInventory()
    if( not inventoryTable[itemKey] ) then return end

    local newX, newY = net.ReadUInt( 5 ), net.ReadUInt( 5 )
    if( not newX or not newY or newX == 0 or newY == 0 or newX > TETRIS_INV.CONFIG.GridX or newY > TETRIS_INV.CONFIG.GridY ) then return end

	inventoryTable[itemKey][2][1] = newX
	inventoryTable[itemKey][2][2] = newY

    ply:TetrisInv():SetInventory( inventoryTable )
end )