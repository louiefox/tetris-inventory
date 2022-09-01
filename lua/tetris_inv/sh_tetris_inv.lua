function TETRIS_INV.FUNC.CanMoveItem( itemX, itemY, itemW, itemH, isRotated, items )
    local actualW, actualH = isRotated and itemH or itemW, isRotated and itemW or itemH
    if( itemX == 0 or itemY == 0 or itemX > TETRIS_INV.CONFIG.GridX-(actualW-1) or itemY > TETRIS_INV.CONFIG.GridY-(actualH-1) ) then return false end

    local canMove = true

    local takenSlots = {}
    for y = itemY, itemY+actualH-1 do
        takenSlots[y] = {}
        for x = itemX, itemX+actualW-1 do
            takenSlots[y][x] = true
        end
    end

    -- each item table is { x, y, w, h, rotated }
    for k, v in ipairs( items ) do
        if( not canMove ) then break end

        local w, h = v[5] and v[4] or v[3], v[5] and v[3] or v[4]
        for y = v[2], v[2]+h-1 do
            if( not canMove ) then break end
            if( not takenSlots[y] ) then continue end

            for x = v[1], v[1]+w-1 do
                if( not takenSlots[y][x] ) then continue end

                canMove = false
                break
            end
        end
    end

    return canMove
end

function TETRIS_INV.FUNC.GetItemTransforms( inventoryTable, excludedKey )
    local itemTransforms = {}
    for k, v in pairs( inventoryTable ) do
        if( k == excludedKey ) then continue end
        table.insert( itemTransforms, v[2] )
    end

    return itemTransforms
end