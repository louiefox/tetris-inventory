TETRIS_INV = TETRIS_INV or {
    FUNC = {},
    TEMP = {},
    PLAYERMETA = {}
}

TETRIS_INV.PLAYERMETA.__index = TETRIS_INV.PLAYERMETA

for _, v in ipairs( file.Find( "tetris_inv/*.lua", "LUA" ) ) do
    local isShared = string.StartWith( v, "sh_" )

    if( SERVER ) then
        if( isShared or string.StartWith( v, "sv_" ) ) then
            include( "tetris_inv/" .. v )
        end

        if( isShared or string.StartWith( v, "cl_" ) ) then
            AddCSLuaFile( "tetris_inv/" .. v )
        end
    elseif( CLIENT and (isShared or string.StartWith( v, "cl_" )) ) then
        include( "tetris_inv/" .. v )
    end
end