function TETRIS_INV.FUNC.CanMoveItem( itemX, itemY, itemW, itemH, items )
    local canMove = true

    local takenSlots = {}
    for y = itemY, itemY+itemH-1 do
        takenSlots[y] = {}
        for x = itemX, itemX+itemW-1 do
            takenSlots[y][x] = true
        end
    end

    -- each item table is { x, y, w, h }
    for k, v in ipairs( items ) do
        if( not canMove ) then break end

        for y = v[2], v[2]+v[4]-1 do
            if( not canMove ) then break end
            if( not takenSlots[y] ) then continue end

            for x = v[1], v[1]+v[3]-1 do
                if( not takenSlots[y][x] ) then continue end

                canMove = false
                break
            end
        end
    end

    return canMove
end