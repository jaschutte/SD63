
local multiTileStats = require("loaders.stats.multiTiles")
multiTileStats:Init()
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
            local TLS = multiTileStats.MultiTiles[ToolSettings.TileCatagory][tonumber(string.sub(id,2))]
            local DB = multiTileStats.Override
            local l, r = graphics:IsTilePositionValid(x-1,y,"0",true), graphics:IsTilePositionValid(x+1,y,"0",true)
            local t, b = graphics:IsTilePositionValid(x,y-1,"0",true), graphics:IsTilePositionValid(x,y+1,"0",true)
            local c = graphics:IsTilePositionValid(x,y)
            local sId = TLS.TopTile
            local notPlace = false
            if t and not b then
                if l and not r then
                    if DB[t]["SmoothCornersBottemLeftBig"] then
                        sId = TLS.SmoothCorners.BottemLeft.Small
                    else
                        sId = TLS.Corners.BottemLeftBase
                    end
                elseif r and not l then
                    if DB[t]["SmoothCornersBottemRightBig"] then
                        sId = TLS.SmoothCorners.BottemRight.Small
                    else
                        sId = TLS.Corners.BottemRightBase
                    end
                else
                    sId = TLS.BottemTile
                end
            elseif b and not t then
                if l and r then
                    if (DB[r]["SmoothCornersTopLeftBaseTR"] or DB[r]["SmoothCornersTopLeftRandomTR"]) and (DB[l]["SmoothCornersTopRightBaseTL"] or DB[l]["SmoothCornersTopRightRandomTL"]) then
                        sId = TLS.SlabTileTop
                    elseif DB[r]["SmoothCornersTopLeftBaseTR"] or DB[r]["SmoothCornersTopLeftRandomTR"] then
                        sId = TLS.SmoothCorners.TopLeft.Base.TL
                    elseif DB[l]["SmoothCornersTopRightBaseTL"] or DB[l]["SmoothCornersTopRightRandomTL"] then
                        sId = TLS.SmoothCorners.TopRight.Base.TR
                    elseif DB[c]["SlabTileTop"] then
                        notPlace = true
                    elseif DB[c]["TopTile"] and DB[r]["SlabTileTop"] then
                        sId = TLS.SmoothCorners.TopLeft.Random.TL
                    elseif DB[c]["TopTile"] and DB[l]["SlabTileTop"] then --ADD TopToSlab functionality
                        sId = TLS.SmoothCorners.TopRight.Random.TR

                    elseif DB[l]["SlabTileTop"] and DB[r]["SlabTileTop"] then
                        sId = TLS.SlabTileTop
                    end
                elseif l then
                    if not r then
                        local rb = graphics:IsTilePositionValid(x+1,y+1,"0",true)
                        local ll = graphics:IsTilePositionValid(x-2,y,"0",true)
                        local lt = graphics:IsTilePositionValid(x-1,y-1,"0")
                        if rb and ll and not DB[rb]["SlabTileTop"] and not DB[ll]["SlabTopTile"] and lt then
                            sId = TLS.SmoothCorners.TopLeft.Base.TR
                        elseif DB[l]["SlabTileTop"] then
                            if not DB[c]["CornersSlabTopRightBase"] and not DB[c]["CornersSlabTopRightRandom"] then
                                sId = math.random(2) == 1 and TLS.Corners.SlabTopRightBase or TLS.Corners.SlabTopRightRandom
                            else
                                notPlace = true
                            end
                        elseif not DB[c]["CornersTopRightBase"] and not DB[c]["CornersTopRightRandom"] then
                            sId = math.random(2) == 1 and TLS.Corners.TopRightBase or TLS.Corners.TopRightRandom
                        else
                            notPlace = true
                        end
                    end
                elseif r then
                    if not l then
                        local lb = graphics:IsTilePositionValid(x-1,y+1,"0",true)
                        local rr = graphics:IsTilePositionValid(x+2,y,"0",true)
                        local rt = graphics:IsTilePositionValid(x+1,y-1,"0")
                        if lb and rr and not DB[lb]["SlabTileTop"] and not DB[rr]["SlabTopTile"] and rt then
                            sId = TLS.SmoothCorners.TopRight.Base.TL
                        elseif DB[r]["SlabTileTop"] then
                            if not DB[c]["CornersSlabTopLeftBase"] and not DB[c]["CornersSlabTopLeftRandom"] then
                                sId = math.random(2) == 1 and TLS.Corners.SlabTopLeftBase or TLS.Corners.SlabTopLeftRandom
                            else
                                notPlace = true
                            end
                        elseif not DB[c]["CornersTopLeftBase"] and not DB[c]["CornersTopLeftRandom"] then
                            sId = math.random(2) == 1 and TLS.Corners.TopLeftBase or TLS.Corners.TopLeftRandom
                        else
                            notPlace = true
                        end
                    end
                end
            elseif t and b then
                if l and not r then
                    sId = TLS.RightEdge
                elseif r and not l then
                    sId = TLS.LeftEdge
                else
                    local lb = graphics:IsTilePositionValid(x-1,y+1,"0",true)
                    local rb = graphics:IsTilePositionValid(x+1,y+1,"0",true)
                    if lb and not rb then
                        local rr = graphics:IsTilePositionValid(x+2,y,"0",true)
                        if not rr then
                            sId = TLS.SmoothCorners.BottemLeft.Big;
                        else
                            sId = TLS.EdgeCorner.BottemLeft
                        end
                    elseif rb and not lb then
                        local ll = graphics:IsTilePositionValid(x-2,y,"0",true)
                        if not ll then
                            sId = TLS.SmoothCorners.BottemRight.Big;
                        else
                            sId = TLS.EdgeCorner.BottemRight
                        end
                    else
                        if DB[t]["SmoothCornersTopRightBaseTL"] or DB[t]["SmoothCornersTopRightRandomTL"] then
                            sId = DB[t]["SmoothCornersTopRightBaseTL"] and TLS.SmoothCorners.TopRight.Base.BL or TLS.SmoothCorners.TopRight.Random.BL
                        elseif DB[t]["SmoothCornersTopLeftBaseTR"] or DB[t]["SmoothCornersTopLeftRandomTR"] then
                            sId = DB[t]["SmoothCornersTopLeftBaseTR"] and TLS.SmoothCorners.TopLeft.Base.BR or TLS.SmoothCorners.TopLeft.Random.BR
                        else
                            local lt = graphics:IsTilePositionValid(x-1,y-1,"0",true)
                            local rt = graphics:IsTilePositionValid(x+1,y-1,"0",true)
                            if lt and not rt then
                                if DB[r]["SlabTileTop"] or DB[r]["SmoothCornersTopRightBaseTR"] or DB[r]["SmoothCornersTopRightRandomTR"] then
                                    sId = TLS.EdgeCorner.SlabLeftTop
                                else
                                    sId = TLS.EdgeCorner.Left
                                end
                            elseif rt and not lt then
                                if DB[l]["SlabTileTop"] or DB[l]["SmoothCornersTopLeftBaseTL"] or DB[l]["SmoothCornersTopLeftRandomTL"] then
                                    sId = TLS.EdgeCorner.SlabRightTop
                                else
                                    sId = TLS.EdgeCorner.Right
                                end
                            else
                                if DB[t]["SlabTileTop"] then
                                    sId = TLS.SlabTileBottem
                                elseif DB[t]["SmoothCornersTopRightBaseTR"] or DB[t]["SmoothCornersTopRightRandomTR"] then
                                    sId = TLS.SmoothCorners.TopRight.Base.BR
                                elseif DB[t]["SmoothCornersTopLeftBaseTL"] or DB[t]["SmoothCornersTopLeftRandomTL"] then
                                    sId = TLS.SmoothCorners.TopLeft.Base.BL
                                elseif DB[t]["EdgeCornerSlabRightTop"] then
                                    sId = TLS.EdgeCorner.SlabRightBottem
                                elseif DB[t]["EdgeCornerSlabLeftTop"] then
                                    sId = TLS.EdgeCorner.SlabLeftBottem
                                elseif not DB[c]["GroundTilesBase"] and not DB[c]["GroundTilesRandom1"] and not DB[c]["GroundTilesRandom2"] then
                                    sId = math.random(1,8) ~= 1 and TLS.GroundTiles.Base or math.random(1,2) == 1 and TLS.GroundTiles.Random1 or TLS.GroundTiles.Random2
                                else
                                    notPlace = true
                                end
                            end
                        end
                    end
                end
            end
            if not notPlace then
                mod:SetTileFinal(x,y,sId)
                if c ~= sId then
                    if r and DB[r] then
                        _G:SetTile(x+1,y,id)
                    end
                    if l and DB[l] then
                        _G:SetTile(x-1,y,id)
                    end
                    if t and DB[t] then
                        _G:SetTile(x,y-1,id)
                    end
                    if b and DB[b] then
                        _G:SetTile(x,y+1,id)
                    end
                end
            end
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
