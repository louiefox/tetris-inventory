if( not TETRIS_INV.LOCALPLYMETA ) then
	TETRIS_INV.LOCALPLYMETA = {
		Player = self
	}

	setmetatable( TETRIS_INV.LOCALPLYMETA, TETRIS_INV.PLAYERMETA )
end

net.Receive( "TetrisInv.SendUserID", function()
    TETRIS_INV.LOCALPLYMETA.UserID = net.ReadUInt( 16 )
end )

net.Receive( "TetrisInv.SendInventoryItems", function()
	local inventoryTable = TETRIS_INV.LOCALPLYMETA:GetInventory()
	for i = 1, net.ReadUInt( 8 ) do
		local itemKey = net.ReadUInt( 10 )
		if( not net.ReadBool() ) then
			inventoryTable[itemKey] = nil
			continue 
		end

		inventoryTable[itemKey] = {
			net.ReadString(),
			{ net.ReadUInt( 5 ), net.ReadUInt( 5 ), net.ReadUInt( 5 ), net.ReadUInt( 5 ), net.ReadBool() },
			net.ReadTable()
		}
	end

	TETRIS_INV.LOCALPLYMETA.InventoryTable = inventoryTable
	hook.Run( "TetrisInv.Hooks.UpdateInventory" )
end )