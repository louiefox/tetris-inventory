TETRIS_INV = TETRIS_INV or {
    FUNC = {},
    TEMP = {},
    PLAYERMETA = {}
}

TETRIS_INV.PLAYERMETA.__index = TETRIS_INV.PLAYERMETA

AddCSLuaFile( "sh_tetrisinv_config.lua" )
include( "sh_tetrisinv_config.lua" )

for _, v in ipairs( file.Find( "tetris_inv/*.lua", "LUA" ) ) do
    local isShared = string.StartWith( v, "sh_" )

    if( SERVER and (string.StartWith( v, "cl_" ) or isShared) ) then
        AddCSLuaFile( "tetris_inv/" .. v )
    end

    if( isShared or (SERVER and string.StartWith( v, "sv_" )) or (CLIENT and string.StartWith( v, "cl_" )) ) then
        print( "[TETRISINV] " .. v .. " file loaded" )
        include( "tetris_inv/" .. v )
    end
end