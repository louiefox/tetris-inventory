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
        return TETRIS_INV.CONFIG.CustomSizes[itemData[2]] or { 4, 2 }
    end,
    GetDisplayInfo = function( itemData )
        return {
            Name = getWeaponName( itemData[2] ),
            Model = itemData[1]
        }
    end
}

function TETRIS_INV.FUNC.GetEntData( ent )
    return (TETRIS_INV.ITEM_TYPES[ent:GetClass()] or TETRIS_INV.ITEM_TYPE_DEFAULT).GetData( ent )
end

function TETRIS_INV.FUNC.GetDisplayInfo( class, itemData )
    return (TETRIS_INV.ITEM_TYPES[class] or TETRIS_INV.ITEM_TYPE_DEFAULT).GetDisplayInfo( itemData )
end