function TETRIS_INV.FUNC.SQLQuery( queryStr, func, singleRow )
    local query
    if( not singleRow ) then
        query = sql.Query( queryStr )
    else
        query = sql.QueryRow( queryStr, 1 )
    end
    
    if( query == false ) then
        print( "[TETRISINV SQLLite] ERROR", sql.LastError() )
    elseif( func ) then
        func( query )
    end
end    

function TETRIS_INV.FUNC.SQLCreateTable( tableName, query )
    if( not sql.TableExists( tableName ) ) then
        TETRIS_INV.FUNC.SQLQuery( "CREATE TABLE " .. tableName .. " ( " .. query .. " );" )
    end

    print( "[TETRISINV SQLLite] " .. tableName .. " table validated!" )
end

TETRIS_INV.FUNC.SQLCreateTable( "tetrisinv_players", [[
	userID INTEGER PRIMARY KEY AUTOINCREMENT,
	steamID64 varchar(20) NOT NULL UNIQUE
]] )

TETRIS_INV.FUNC.SQLCreateTable( "tetrisinv_inventory", [[
	userID int,
	entClass varchar(50),
	transformX int,
	transformY int,
	transformW int,
	transformH int,
    transformIsRotated int,
    entData TEXT
]] )