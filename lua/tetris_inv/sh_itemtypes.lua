TETRIS_INV.ITEM_TYPE_DEFAULT = {
    GetData = function( ent )
        return { ent:GetModel() }
    end,
    GetDisplayInfo = function( entClass, itemData )
        return {
            Name = entClass,
            Model = itemData[1],
            Rarity = TETRIS_INV.CONFIG.RarityList[entClass] or TETRIS_INV.CONFIG.DefaultRarity
        }
    end,
    DoDrop = function( ply, entClass, itemData )
        local ent = ents.Create( entClass )
        ent:SetPos( ply:GetPos()+ply:GetForward()*20+Vector( 0, 0, 20 ) )
        ent:SetAngles( ply:GetAngles()+Angle( 180, 0, 0 ) )
        ent:SetModel( itemData[1] )
        ent:Spawn()
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
        return { ent:GetModel(), (ent.GetWeaponClass and ent:GetWeaponClass()) or "", ent:Getamount(), ent.clip1 or 0 }
    end,
    GetSize = function( entClass, itemData )
        return TETRIS_INV.CONFIG.CustomSizes[itemData[2]] or { 4, 2 }
    end,
    GetDisplayInfo = function( entClass, itemData )
        return {
            Name = getWeaponName( itemData[2] ),
            Model = itemData[1],
            Rarity = TETRIS_INV.CONFIG.RarityList[itemData[2]] or TETRIS_INV.CONFIG.DefaultRarity
        }
    end,
    DoDrop = function( ply, entClass, itemData )
        local ent = ents.Create( "spawned_weapon" )
        ent:SetPos( ply:GetPos()+ply:GetForward()*20+Vector( 0, 0, 20 ) )
        ent:SetAngles( ply:GetAngles()+Angle( 180, 0, 0 ) )
        ent:SetModel( itemData[1] )
        ent:SetWeaponClass( itemData[2] )
        ent:Spawn()
        ent.clip1 = itemData[4] or 0
    end,
    DoUse = function( ply, entClass, itemData )
        local weapon = ply:Give( itemData[2], true )
        if( not itemData[4] or not IsValid( weapon ) ) then return end

        weapon:SetClip1( itemData[4] )
    end
}

function TETRIS_INV.FUNC.GetEntData( ent )
    return (TETRIS_INV.ITEM_TYPES[ent:GetClass()] or TETRIS_INV.ITEM_TYPE_DEFAULT).GetData( ent )
end

function TETRIS_INV.FUNC.GetDisplayInfo( class, itemData )
    return (TETRIS_INV.ITEM_TYPES[class] or TETRIS_INV.ITEM_TYPE_DEFAULT).GetDisplayInfo( class, itemData )
end