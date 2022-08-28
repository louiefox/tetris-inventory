--[[
    Credit: <CODE BLUE>
    Link: https://gist.github.com/MysteryPancake/a31637af9fd531079236a2577145a754
]]--

local function createShadows()
    --The original drawing layer
    TETRIS_INV.TEMP.ShadowRenderTarget = GetRenderTarget( "tetrisinv_shadows_original_" .. ScrW(), ScrW(), ScrH() )
    
    --The matarial to draw the render targets on
    TETRIS_INV.TEMP.ShadowMaterial = CreateMaterial( "tetrisinv_shadows_" .. ScrW(), "UnlitGeneric", {
        ["$translucent"] = 1,
        ["$vertexalpha"] = 1,
        ["alpha"] = 1
    } )

    TETRIS_INV.TEMP.CreatedShadows = {}
end
createShadows()

hook.Add( "OnScreenSizeChanged", "TetrisInv.OnScreenSizeChanged.BShadows", createShadows )

TETRIS_INV.TEMP.RTMaterials = TETRIS_INV.TEMP.RTMaterials or {}
local function createRTMaterial( uniqueID )
    local materialID
    for k, v in ipairs( TETRIS_INV.TEMP.RTMaterials or {} ) do
        if( v != true ) then continue end

        materialID = k
        break
    end

    if( not materialID ) then
        TETRIS_INV.TEMP.RTMaterials = TETRIS_INV.TEMP.RTMaterials or {}
        materialID = #TETRIS_INV.TEMP.RTMaterials+1
    end

    TETRIS_INV.TEMP.RTMaterials[materialID] = uniqueID

    return CreateMaterial( "tetrisinv_shadows_grayscale_" .. ScrW() .. "_id_" .. materialID, "UnlitGeneric", {
        ["$translucent"] = 1,
        ["$vertexalpha"] = 1,
        ["$alpha"] = 1,
        ["$color"] = "0 0 0",
        ["$color2"] = "0 0 0"
    } )
end

TETRIS_INV.TEMP.ShadowRenderTargets = TETRIS_INV.TEMP.ShadowRenderTargets or {}
local function getShadowRenderTarget( uniqueID )
    local targetID
    for k, v in ipairs( TETRIS_INV.TEMP.ShadowRenderTargets or {} ) do
        if( v == uniqueID ) then 
            targetID = k
            break
        end
    end

    if( not targetID ) then
        for k, v in ipairs( TETRIS_INV.TEMP.ShadowRenderTargets or {} ) do
            if( v == true ) then 
                targetID = k
                break
            end
        end

        if( not targetID ) then
            TETRIS_INV.TEMP.ShadowRenderTargets = TETRIS_INV.TEMP.ShadowRenderTargets or {}
            targetID = #TETRIS_INV.TEMP.ShadowRenderTargets+1
        end
    
        TETRIS_INV.TEMP.ShadowRenderTargets[targetID] = uniqueID
    end

    return GetRenderTarget( "tetrisinv_shadows_rt_" .. ScrW() .. "_id_" .. targetID, ScrW(), ScrH() )
end

--Call this to begin drawing a shadow
function TETRIS_INV.FUNC.BeginShadow( uniqueID, areaX, areaY, areaEndX, areaEndY )
    if( not TETRIS_INV.TEMP.CreatedShadows[uniqueID] ) then
        TETRIS_INV.TEMP.CreatedShadows[uniqueID] = {}
        TETRIS_INV.TEMP.CreatedShadows[uniqueID].Started = true
    end

    if( not TETRIS_INV.TEMP.CreatedShadows[uniqueID].Started ) then return end
    
    --Set the render target so all draw calls draw onto the render target instead of the screen
    render.PushRenderTarget(TETRIS_INV.TEMP.ShadowRenderTarget)

    --Clear is so that theres no color or alpha
    render.OverrideAlphaWriteEnable(true, true)
    render.Clear(0,0,0,0)
    render.OverrideAlphaWriteEnable(false, false)

    local shadowTable = TETRIS_INV.TEMP.CreatedShadows[uniqueID]
    if( areaX and (not shadowTable[4] or shadowTable[4] != areaX or shadowTable[5] != areaY or shadowTable[6] != areaEndX or shadowTable[7] != areaEndY) ) then
        shadowTable[4] = areaX
        shadowTable[5] = areaY
        shadowTable[6] = areaEndX
        shadowTable[7] = areaEndY
    end

    --Start Cam2D as where drawing on a flat surface 
    cam.Start2D()

    --Now leave the rest to the user to draw onto the surface
end

--This will draw the shadow, and mirror any other draw calls the happened during drawing the shadow
function TETRIS_INV.FUNC.EndShadow( uniqueID, x, y, intensity, spread, blur, opacity, direction, distance, _shadowOnly )
    local shadowTable = TETRIS_INV.TEMP.CreatedShadows[uniqueID]
    if( not shadowTable.Started ) then return end
    
    -- Set default opcaity
    opacity = opacity or 255
    direction = direction or 0
    distance = distance or 0
    _shadowOnly = _shadowOnly or false

    if( not shadowTable[1] or (shadowTable[8] and (shadowTable[10] or 0) != shadowTable[8]) or (shadowTable[9] and (shadowTable[11] or 0) != shadowTable[9]) or (shadowTable[12] or 1) != surface.GetAlphaMultiplier() ) then
        local shadowRenderTarget = getShadowRenderTarget( uniqueID )
        -- Copy this render target to the other
        render.CopyRenderTargetToTexture(shadowRenderTarget)
    
        --Blur the second render target
        if blur > 0 then
            render.OverrideAlphaWriteEnable(true, true)
            render.BlurRenderTarget(shadowRenderTarget, spread, spread, blur)
            render.OverrideAlphaWriteEnable(false, false) 
        end

        if( not shadowTable[1] ) then
            shadowTable[1] = createRTMaterial( uniqueID )
        end
        
        shadowTable[2] = x
        shadowTable[3] = y

        if( shadowTable[8] ) then
            shadowTable[10] = shadowTable[8]
            shadowTable[11] = shadowTable[9]
        end

        shadowTable[12] = surface.GetAlphaMultiplier()

        shadowTable[1]:SetTexture("$basetexture", shadowRenderTarget)
        shadowTable[1]:SetFloat("$alpha", opacity/255)
    end

    --First remove the render target that the user drew
    render.PopRenderTarget()

    --Now update the material to what was drawn
    TETRIS_INV.TEMP.ShadowMaterial:SetTexture('$basetexture', TETRIS_INV.TEMP.ShadowRenderTarget)
    
    --Work out shadow offsets
    local xOffset = math.sin(math.rad(direction)) * distance 
    local yOffset = math.cos(math.rad(direction)) * distance

    if( shadowTable[4] ) then render.SetScissorRect( shadowTable[4], shadowTable[5], shadowTable[6], shadowTable[7], true ) end

    render.SetMaterial(shadowTable[1])
    for i = 1 , math.ceil(intensity) do
        render.DrawScreenQuadEx(xOffset+(x-shadowTable[2]), yOffset+(y-shadowTable[3]), ScrW(), ScrH())
    end

    if( not _shadowOnly ) then
        if( shadowTable[4] ) then 
            render.SetScissorRect( 0, 0, 0, 0, false )
            render.SetScissorRect( shadowTable[4], shadowTable[5], shadowTable[6], shadowTable[7], true ) 
        end

        TETRIS_INV.TEMP.ShadowMaterial:SetTexture('$basetexture', TETRIS_INV.TEMP.ShadowRenderTarget)
        render.SetMaterial(TETRIS_INV.TEMP.ShadowMaterial)
        render.DrawScreenQuad()
    end

    if( shadowTable[4] ) then render.SetScissorRect( 0, 0, 0, 0, false ) end

    cam.End2D()
end

function TETRIS_INV.FUNC.SetShadowSize( uniqueID, w, h )
    if( not TETRIS_INV.TEMP.CreatedShadows[uniqueID] ) then return end

    TETRIS_INV.TEMP.CreatedShadows[uniqueID][8] = w
    TETRIS_INV.TEMP.CreatedShadows[uniqueID][9] = h
end

function TETRIS_INV.FUNC.DeleteShadow( uniqueID )
    if( not TETRIS_INV.TEMP.CreatedShadows[uniqueID] ) then return end

    for k, v in ipairs( TETRIS_INV.TEMP.RTMaterials or {} ) do
        if( v != uniqueID ) then continue end

        TETRIS_INV.TEMP.RTMaterials[k] = true
        break
    end

    for k, v in ipairs( TETRIS_INV.TEMP.ShadowRenderTargets or {} ) do
        if( v != uniqueID ) then continue end

        TETRIS_INV.TEMP.ShadowRenderTargets[k] = true
        break
    end

    TETRIS_INV.TEMP.CreatedShadows[uniqueID][1] = nil
    TETRIS_INV.TEMP.CreatedShadows[uniqueID] = nil
end