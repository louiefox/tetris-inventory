local PANEL = {}

function PANEL:Init()
    local slotSize = TETRIS_INV.FUNC.ScreenScale( 50 )
    local outerMargin = TETRIS_INV.FUNC.ScreenScale( 25 )
    local slotSpacing = 1--TETRIS_INV.FUNC.ScreenScale( 25 )

    self.slotSize, self.slotSpacing = slotSize, slotSpacing

    self.gridPanel = vgui.Create( "Panel", self )
    self.gridPanel:SetSize( TETRIS_INV.CONFIG.GridX*(slotSize+slotSpacing)-slotSpacing, TETRIS_INV.CONFIG.GridY*(slotSize+slotSpacing)-slotSpacing )
    self.gridPanel:SetPos( outerMargin, outerMargin )

    self:SetSize( self.gridPanel:GetWide()+2*outerMargin, self.gridPanel:GetTall()+2*outerMargin )
    self:SetPos( ScrW()*0.9-self:GetWide(), ScrH()/2-self:GetTall()/2 )

    gui.EnableScreenClicker( true )

    self.slotPanels = {}
    self.itemPanels = {}

    local color_green = Color( 50, 100, 50, 255 )
    local color_red = Color( 125, 50, 50, 255 )

    local row = 1
    timer.Create( "tetris_inv_createslots", 0.01, 0, function()
        if( not IsValid( self ) or row > TETRIS_INV.CONFIG.GridY ) then
            timer.Remove( "tetris_inv_createslots" )

            if( not IsValid( self ) ) then return end
            self:CreateItems()

            return
        end

        for col = 1, TETRIS_INV.CONFIG.GridX do
            local slotX, slotY = col, row
            
            local uniqueID = "tetris_inv_slot_" .. row .. "_" .. col
            local slotPanel = vgui.Create( "Panel", self.gridPanel )
            slotPanel:SetPos( (col-1)*(slotSize+slotSpacing), (row-1)*(slotSize+slotSpacing) )
            slotPanel:SetSize( slotSize, slotSize )
            slotPanel.Paint = function( self2, w, h )
                TETRIS_INV.FUNC.BeginShadow( uniqueID )
                local x, y = self2:LocalToScreen( 0, 0 )
                surface.SetDrawColor( 0, 0, 0 )
                surface.DrawRect( x, y, w, h )
                TETRIS_INV.FUNC.EndShadow( uniqueID, x, y, 1, 1, 1, 150, 0, 0, true )

                surface.SetDrawColor( 175, 175, 175, 25 )
                surface.DrawRect( 0, 0, w, h )

                local dragging = self.draggingItem
                if( dragging and slotX >= dragging.x and slotX < dragging.x+dragging.w and slotY >= dragging.y and slotY < dragging.y+dragging.h ) then
                    surface.SetDrawColor( dragging.blocked and color_red or color_green )
                    surface.DrawRect( 0, 0, w, h )
                end

                surface.SetDrawColor( 175, 175, 175, 50 )
                surface.DrawOutlinedRect( 0, 0, w, h )
            end
        end

        row = row+1
    end )

    hook.Add( "TetrisInv.Hooks.UpdateInventory", self, function()
        self:CreateItems()
    end )

    hook.Add( "KeyPress", self, function( self, ply, key )
        if( not self.draggingItem or key != IN_RELOAD ) then return end
        self.draggingItem.rotated = not self.draggingItem.rotated
        self.draggingItem.w, self.draggingItem.h = self.draggingItem.h, self.draggingItem.w
    end )
end

local radialGradient = Material( "tetris_inv/gradient_radial.png" )
function PANEL:CreateItem( itemKey, itemInfo )
    local itemTypeInfo = TETRIS_INV.ITEM_TYPES[itemInfo[1]] or TETRIS_INV.ITEM_TYPE_DEFAULT
    local displayInfo = itemTypeInfo.GetDisplayInfo( itemInfo[1], itemInfo[3] )

    local transformData = itemInfo[2]
    local itemX, itemY, itemW, itemH = transformData[1], transformData[2], transformData[3], transformData[4]

    local isRotated = transformData[5]
    local actualW, actualH = isRotated and itemH or itemW, isRotated and itemW or itemH

    local rarityConfig = TETRIS_INV.CONFIG.Rarities[displayInfo.Rarity] or TETRIS_INV.CONFIG.Rarities[TETRIS_INV.CONFIG.DefaultRarity]
    if( not rarityConfig ) then
        error( "[TETRISINV] ERROR: Invalid default rarity!" )
    end

    local itemPanel = vgui.Create( "DButton", self.gridPanel )
    itemPanel:SetPos( (itemX-1)*(self.slotSize+self.slotSpacing), (itemY-1)*(self.slotSize+self.slotSpacing) )
    itemPanel:SetSize( actualW*(self.slotSize+self.slotSpacing)-self.slotSpacing, actualH*(self.slotSize+self.slotSpacing)-self.slotSpacing )
    itemPanel:SetText( "" )
    itemPanel.itemX, itemPanel.itemY = transformData[1], transformData[2]
    itemPanel.itemW, itemPanel.itemH = transformData[3], transformData[4]
    itemPanel.isRotated = isRotated
    itemPanel.Paint = function( self2, w, h )
        if( self2.isDragging ) then 
            surface.SetDrawColor( 0, 0, 0, 100 )
            surface.DrawRect( 0, 0, w, h )
            return 
        end

        surface.SetDrawColor( rarityConfig.BackgroundColor.r, rarityConfig.BackgroundColor.g, rarityConfig.BackgroundColor.b, 200 )
        surface.DrawRect( 0, 0, w, h )

        surface.SetDrawColor( 255, 255, 255, 15 )
        surface.SetMaterial( radialGradient )
        local gradientSize = math.max( w, h )
        surface.DrawTexturedRect( w/2-gradientSize/2, h/2-gradientSize/2, gradientSize, gradientSize )

        surface.SetDrawColor( rarityConfig.BorderColor )
        surface.DrawOutlinedRect( 0, 0, w, h )

        draw.SimpleTextOutlined( string.upper( displayInfo.Name ), "MontserratMedium12", w-5, 3, TETRIS_INV.COLOR.White, TEXT_ALIGN_RIGHT, 0, 1, TETRIS_INV.COLOR.Black )

        -- if( itemInfo.durability ) then
        --     draw.SimpleTextOutlined( itemInfo.durability .. "/" .. itemInfo.maxDurability, "MontserratMedium12", w-5, h-3, TETRIS_INV.COLOR.White, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 1, TETRIS_INV.COLOR.Black )
        -- end
    end
    itemPanel.OnMousePressed = function( self2, keyCode )
        if( keyCode == MOUSE_LEFT ) then
            self2.dragStartX, self2.dragStartY = gui.MousePos()
            self2.isDragging = true
    
            self.draggingItem = {
                x = self2.itemX,
                y = self2.itemY,
                w = isRotated and self2.itemH or self2.itemW,
                h = isRotated and self2.itemW or self2.itemH,
                rotated = isRotated
            }
        elseif( keyCode == MOUSE_RIGHT ) then
            local itemTypeInfo = TETRIS_INV.ITEM_TYPES[itemInfo[1]] or TETRIS_INV.ITEM_TYPE_DEFAULT

            local menu = DermaMenu()

            if( itemTypeInfo.DoUse ) then 
                menu:AddOption( "Use", function()
                    net.Start( "TetrisInv.RequestUseItem" )
                        net.WriteUInt( itemKey, 10 )
                    net.SendToServer()
                end )
            end

            if( itemTypeInfo.DoDrop ) then 
                menu:AddOption( "Drop", function()
                    net.Start( "TetrisInv.RequestDropItem" )
                        net.WriteUInt( itemKey, 10 )
                    net.SendToServer()
                end )
            end

            menu:Open()
        end
    end
    itemPanel.CancelDragging = function( self2 )
        self2.isDragging = false

        if( self.draggingItem and not self.draggingItem.blocked ) then 
            self2.itemX, self2.itemY = self2.hoverItemX or itemX, self2.hoverItemY or itemY
            self2:SetPos( (self2.itemX-1)*(self.slotSize+self.slotSpacing), (self2.itemY-1)*(self.slotSize+self.slotSpacing) )
            TETRIS_INV.FUNC.RequestMoveItem( itemKey, self2.itemX, self2.itemY, self.draggingItem.rotated )
        end

        self2.hoverItemX, self2.hoverItemY = nil, nil
        self.draggingItem = nil
    end
    itemPanel.OnMouseReleased = function( self2 )
        self2:CancelDragging()
    end
    itemPanel.Think = function( self2 )
        if( not self2.isDragging ) then return end

        if( not input.IsMouseDown( MOUSE_LEFT ) ) then
            self2:CancelDragging()
            return
        end

        local mouseX, mouseY = gui.MousePos()
        local newX = math.Clamp( self2.itemX+math.Round( (mouseX-self2.dragStartX)/self.slotSize, 0 ), 1, TETRIS_INV.CONFIG.GridX-self.draggingItem.w+1 )
        local newY = math.Clamp( self2.itemY+math.Round( (mouseY-self2.dragStartY)/self.slotSize, 0 ), 1, TETRIS_INV.CONFIG.GridY-self.draggingItem.h+1 )

        if( newX == self2.hoverItemX and newY == self2.hoverItemY and self.draggingItem.rotated == self2.isRotated ) then return end
        self2.hoverItemX, self2.hoverItemY = newX, newY
        self2.isRotated = self.draggingItem.rotated

        self.draggingItem = {
            blocked = (newX == self2.itemX and newY == self2.itemY and self.draggingItem.rotated == isRotated) or not TETRIS_INV.FUNC.CanMoveItem( newX, newY, self2.itemW, self2.itemH, self.draggingItem.rotated, TETRIS_INV.FUNC.GetItemTransforms( LocalPlayer():TetrisInv():GetInventory(), itemKey ) ),
            x = newX,
            y = newY,
            w = self.draggingItem.w,
            h = self.draggingItem.h,
            rotated = self.draggingItem.rotated
        }
    end

    table.insert( self.itemPanels, itemPanel )

    local itemPanelW, itemPanelH = itemPanel:GetSize()
    local maxPanelSize = math.max( itemPanelW, itemPanelH )

    local modelPanel = vgui.Create( "DModelPanel", itemPanel )
    modelPanel:SetSize( maxPanelSize, maxPanelSize )
    modelPanel:SetPos( itemPanelW/2-modelPanel:GetWide()/2, itemPanelH/2-modelPanel:GetTall()/2 )
    modelPanel:SetModel( displayInfo.Model )
    modelPanel.LayoutEntity = function() end
    modelPanel.OnMousePressed = function( self2, keyCode ) itemPanel:OnMousePressed( keyCode ) end
    modelPanel.OnMouseReleased = function( self2, keyCode ) itemPanel:OnMouseReleased( keyCode ) end

    if( IsValid( modelPanel.Entity ) ) then 
        local min, max = modelPanel.Entity:GetRenderBounds()

        local function getOffset( val )
            return math.abs( min[val] )-(max[val]-min[val])/2
        end
        
        -- If the x width of the model is larger rotate it 90 degrees
        local xDiff, yDiff = max[1]-min[1], max[2]-min[2]

        if( xDiff > yDiff ) then
            modelPanel.Entity:SetPos( Vector( getOffset( 2 ), getOffset( 1 ), getOffset( 3 ) ) )
            modelPanel.Entity:SetAngles( Angle( 0, 90, 0 ) )
        else
            modelPanel.Entity:SetPos( Vector( getOffset( 1 ), getOffset( 2 ), getOffset( 3 ) ) )
        end

        local modelWidth = math.max( xDiff, yDiff )
        modelPanel:SetCamPos( Vector( -modelWidth*4/itemW, 0, 0 ) )
        modelPanel:SetLookAt( Vector( 0, 0, 0 ) )
        modelPanel:SetLookAng( Angle( 0, 0, isRotated and -90 or 0 ) )
    end
end

function PANEL:CreateItems()
    for i = 1, #self.itemPanels do
        self.itemPanels[i]:Remove()
    end

    self.itemPanels = {}

    -- local inventoryTable = {
    --     {
    --         x = 4,
    --         y = 5,
    --         w = 4,
    --         h = 2,
    --         name = "AK-47",
    --         durability = 20,
    --         maxDurability = 30,
    --         model = "models/weapons/w_rif_ak47.mdl"
    --     },
    --     {
    --         x = 2,
    --         y = 2,
    --         w = 2,
    --         h = 2,
    --         name = "Rifle Ammo",
    --         model = "models/Items/BoxMRounds.mdl"
    --     }
    -- }

    local inventoryTable = LocalPlayer():TetrisInv():GetInventory()
    for k, v in pairs( inventoryTable ) do
        self:CreateItem( k, v )
    end
end

function PANEL:OnRemove()
    gui.EnableScreenClicker( false )

    for row = 1, TETRIS_INV.CONFIG.GridY do
        for col = 1, TETRIS_INV.CONFIG.GridX do
            TETRIS_INV.FUNC.DeleteShadow( "tetris_inv_slot_" .. row .. "_" .. col )
        end
    end
end

function PANEL:Paint( w, h )
    surface.SetDrawColor( 0, 0, 0, 100 )
    surface.DrawRect( 0, 0, w, h )

    TETRIS_INV.FUNC.DrawBlur( self, 4, 4 )

    surface.SetDrawColor( 0, 0, 0, 150 )
    surface.DrawOutlinedRect( 0, 0, w, h )
end

vgui.Register( "tetris_inv_main", PANEL, "Panel" )