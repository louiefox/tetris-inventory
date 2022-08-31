util.AddNetworkString( "TetrisInv.SendUserID" )
function TETRIS_INV.PLAYERMETA:SetUserID( userID )
    self.UserID = userID

    net.Start( "TetrisInv.SendUserID" )
        net.WriteUInt( userID, 16 )
    net.Send( self.Player )
end

hook.Add( "PlayerInitialSpawn", "TetrisInv.PlayerInitialSpawn.LoadData", function( ply )
	TETRIS_INV.FUNC.SQLQuery( "SELECT * FROM tetrisinv_players WHERE steamID64 = '" .. ply:SteamID64() .. "';", function( data )
        if( data ) then
            local userID = tonumber( data.userID or "" ) or 1 
            ply:Project0():SetUserID( userID )

			hook.Run( "TetrisInv.Hooks.PlayerLoadData", ply, userID )
        else
            TETRIS_INV.FUNC.SQLQuery( "INSERT INTO tetrisinv_players( steamID64 ) VALUES(" .. ply:SteamID64() .. ");", function()
                TETRIS_INV.FUNC.SQLQuery( "SELECT * FROM tetrisinv_players WHERE steamID64 = '" .. ply:SteamID64() .. "';", function( data )
                    if( data ) then
                        local userID = tonumber( data.userID or "" ) or 1 
                        ply:TetrisInv():SetUserID( userID )
                    else
                        ply:Kick( "ERROR: Could not create unique UserID, try rejoining!\n\nPlease contact support for TetrisInv on the workshop." )
                    end
                end, true )
            end )
        end
    end, true )
end )

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

            net.WriteBool( tobool( item ) )
            if( not item ) then continue end

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
    local itemSize = itemTypeInfo.GetSize and itemTypeInfo.GetSize( entClass, itemData ) or TETRIS_INV.CONFIG.DefaultSize

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

function TETRIS_INV.PLAYERMETA:RemoveItem( itemKey )
    local inventoryTable = self:GetInventory()
    if( not inventoryTable[itemKey] ) then return false end

    inventoryTable[itemKey] = nil
    self:NetworkItem( itemKey )
end