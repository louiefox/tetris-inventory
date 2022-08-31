TETRIS_INV.CONFIG = {}

TETRIS_INV.CONFIG.GridX = 8
TETRIS_INV.CONFIG.GridY = 10
TETRIS_INV.CONFIG.PickupDistance = 7500

TETRIS_INV.CONFIG.IsWhitelist = true
TETRIS_INV.CONFIG.ListedEntities = {
    ["prop_physics"] = true,
    ["spawned_weapon"] = true
}

TETRIS_INV.CONFIG.DefaultSize = { 2, 2 }
TETRIS_INV.CONFIG.CustomSizes = {
    ["ent_class"] = { 2, 4 },
    ["weapon_class"] = { 4, 4 },
    ["weapon_glock2"] = { 2, 1 },
    ["weapon_deagle2"] = { 2, 1 }
}

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

local playerMeta = FindMetaTable( "Player" )

function playerMeta:TetrisInv()
	if( SERVER ) then
		if( not self ) then return false end

		if( not self.TETRISINV_PLAYERMETA ) then
			self.TETRISINV_PLAYERMETA = {
				Player = self
			}

			setmetatable( self.TETRISINV_PLAYERMETA, TETRIS_INV.PLAYERMETA )
		end

		return self.TETRISINV_PLAYERMETA
	else
		return TETRIS_INV.LOCALPLYMETA
	end
end

function TETRIS_INV.PLAYERMETA:GetInventory()
    return self.InventoryTable or {}
end