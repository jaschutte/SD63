
local multiTileStats = require("loaders.stats.multiTiles")
local graphics = require("loaders.graphics")
local menu = require("loaders.menu")
local mod = {}
mod.Recording = false
mod.REC = {}

local function sign(x,f) --get the sign of an number. Option to replace 0 with f
    return x == 0 and (f or 0) or x < 0 and -1 or 1
end

function mod:SetTileFinal(x,y,id,ignoreRecording) --does not check, if tile is invalid graphics module WILL error
    if not ignoreRecording then
        mod.REC[#mod.REC+1] = {x,y,id}
    end
    LD.Level.Tiles[x][y] = id
end

function _G:SetTile(x,y,id) --checks if id, x and y is valid & applies a multitile if needed
    if graphics:IsTilePositionValid(x,y) and Textures.TileTextures[id] then
        if string.sub(id,1,1) == "m" then
            local l, r = graphics:IsTilePositionValid(x-1,y,"0",true), graphics:IsTilePositionValid(x+1,y,"0",true)
            local t, b = graphics:IsTilePositionValid(x,y-1,"0",true), graphics:IsTilePositionValid(x,y+1,"0",true)
            print(l,r,t,b)
            mod:SetTileFinal(x,y,id)
        else
            mod:SetTileFinal(x,y,id)
        end
    end
end

function mod:FloodRecursive(x,y,id,changeToId)
    local tile = graphics:IsTilePositionValid(x,y,id)
    if tile then
        if tile == changeToId then
            return
        end
        _G:SetTile(x,y,changeToId)
        mod:FloodRecursive(x,y+1,id,changeToId)
        mod:FloodRecursive(x+1,y,id,changeToId)
        mod:FloodRecursive(x,y-1,id,changeToId)
        mod:FloodRecursive(x-1,y,id,changeToId)
    end
end

function mod:Update()
    if ToolSettings.CurrentDisplay == "Tiles" and not ToolSettings.UIBlockingMouse then
        if ToolSettings.MouseDown then
            local mx, my = graphics:ScreenToTile(ToolSettings.MouseX,ToolSettings.MouseY)
            if ToolSettings.TileTool == "normal" then
                _G:SetTile(mx,my,ToolSettings.EraserMode and "0" or ToolSettings.SelectedTile)
            end
        end
        if ToolSettings.TileTool == "area" then
            local mx, my = graphics:ScreenToTile(ToolSettings.MouseX,ToolSettings.MouseY)
            if ToolSettings.TileRange.Stage == 1 then
                ToolSettings.TileRange.StartX, ToolSettings.TileRange.StartY = mx, my
                ToolSettings.TileRange.EndX, ToolSettings.TileRange.EndY = mx, my
            elseif ToolSettings.TileRange.Stage == 2 then
                ToolSettings.TileRange.EndX, ToolSettings.TileRange.EndY = mx, my
            end
        end
        if ToolSettings.Translation.Enabled == true then
            local mx, my = graphics:ScreenToTile(ToolSettings.MouseX,ToolSettings.MouseY)
            local dx, dy = ToolSettings.Translation.X, ToolSettings.Translation.Y
            ToolSettings.Translation.X, ToolSettings.Translation.Y = mx-ToolSettings.Translation.BeginX, my-ToolSettings.Translation.BeginY
            dx, dy = dx-ToolSettings.Translation.X, dy-ToolSettings.Translation.Y
            for _,frame in pairs(menu.HUD) do
                frame:Move(frame.X-dx*32,frame.Y-dy*32)
            end
        end
    end
end

function mod:MouseDown(b)
    --!!MAKE SNAPSHOT
    if b == 2 then
        ToolSettings.EraserMode = true
        if ToolSettings.CurrentDisplay == "Tiles" then
            if ToolSettings.TileTool == "fill" then
                love.mouse.setCursor(Textures.RawTextures.Cursors.bucketRemove)
                local x, y = graphics:ScreenToTile(ToolSettings.MouseX, ToolSettings.MouseY)
                local tile = graphics:IsTilePositionValid(x,y)
                if tile then
                    mod:FloodRecursive(x,y, tile,"0")
                end
            end
        end
    end
    if b == 1 then
        if ToolSettings.CurrentDisplay == "Tiles" and not ToolSettings.UIBlockingMouse then
            if ToolSettings.TileTool == "area" then
                ToolSettings.TileRange.Stage = math.min(ToolSettings.TileRange.Stage+1,3)
                if ToolSettings.TileRange.Stage == 3 then
                    local x, y = graphics:TileToScreen(ToolSettings.TileRange.EndX, ToolSettings.TileRange.EndY)
                    menu:GenerateHUD(x+40-CameraPosition.X,y+40-CameraPosition.Y,true)
                end
            end
            if ToolSettings.TileTool == "fill" then
                local x, y = graphics:ScreenToTile(ToolSettings.MouseX, ToolSettings.MouseY)
                local tile = graphics:IsTilePositionValid(x,y)
                if tile then
                    mod:FloodRecursive(x,y, tile,ToolSettings.EraserMode and "0" or ToolSettings.SelectedTile)
                end
            end
        end
    end
    mod.REC = {}
    mod.Recording = true
end

function mod:MouseUp(b)
    --!!FINISH SNAPSHOT
    if b == 2 then
        ToolSettings.EraserMode = false
        if ToolSettings.CurrentDisplay == "Tiles" then
            if ToolSettings.TileTool == "fill" then
                love.mouse.setCursor(Textures.RawTextures.Cursors.bucket)
            end
        end
    end
    if ToolSettings.Translation.Enabled then
        local tx, ty = ToolSettings.Translation.X, ToolSettings.Translation.Y
        ToolSettings.Translation.Enabled = false
        local temp = {}
        for x = ToolSettings.TileRange.StartX,ToolSettings.TileRange.EndX, sign(ToolSettings.TileRange.EndX-ToolSettings.TileRange.StartX,1) do
            temp[x] = {}
            for y = ToolSettings.TileRange.StartY,ToolSettings.TileRange.EndY, sign(ToolSettings.TileRange.EndY-ToolSettings.TileRange.StartY,1) do
                local t = graphics:IsTilePositionValid(x,y)
                if t then
                    temp[x][y] = t
                    _G:SetTile(x,y,"0")
                end
            end
        end
        for x = ToolSettings.TileRange.StartX,ToolSettings.TileRange.EndX, sign(ToolSettings.TileRange.EndX-ToolSettings.TileRange.StartX,1) do
            for y = ToolSettings.TileRange.StartY,ToolSettings.TileRange.EndY, sign(ToolSettings.TileRange.EndY-ToolSettings.TileRange.StartY,1) do
                if temp[x] and temp[x][y] then
                    _G:SetTile(x+tx,y+ty,temp[x][y])
                end
            end
        end
        ToolSettings.TileRange.StartX = ToolSettings.TileRange.StartX+tx
        ToolSettings.TileRange.StartY = ToolSettings.TileRange.StartY+ty
        ToolSettings.TileRange.EndX = ToolSettings.TileRange.EndX+tx
        ToolSettings.TileRange.EndY = ToolSettings.TileRange.EndY+ty
        ToolSettings.Translation.X, ToolSettings.Translation.Y = 0, 0
    end
    mod.Recording = false
    --mod.REC
end

return mod
