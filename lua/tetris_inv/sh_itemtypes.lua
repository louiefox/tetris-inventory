TETRIS_INV.ITEM_TYPE_DEFAULT = {
    GetData = function( ent )
        return { ent:GetModel() }
    end,
    GetDisplayInfo = function( itemData )
        return {
            Name = "Prop",
            Model = itemData[1]
        }
    end
}

TETRIS_INV.ITEM_TYPES = {}

local function getWeaponName( weaponClass )
	if( weapons.GetStored( weaponClass ) and weapons.GetStored( weaponClass ).PrintName ) then
		return weapons.GetStored( weaponClass ).PrintName or weaponClass
	end

    return weaponClass
end

TETRIS_INV.ITEM_TYPES["spawned_weapon"] = {
    GetData = function( ent )
        return { ent:GetModel(), (ent.GetWeaponClass and ent:GetWeaponClass()) or "", ent:Getamount() }
    end,
    GetSize = function( itemData )
        return { 4, 2 }
    end,
    GetDisplayInfo = function( itemData )
        return {
            Name = getWeaponName( itemData[2] ),
            Model = itemData[1]
        }
    end
}