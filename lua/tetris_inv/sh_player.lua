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

function TETRIS_INV.PLAYERMETA:GetUserID()
	return self.UserID or 0
end