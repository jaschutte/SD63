
local threads = require("loaders.threading")
local graphics = require("loaders.graphics")
local json = require("loaders.dkjson")
local mod = {}
mod.IsBusy = false

local function sign(x,f) --get the sign of an number. Option to replace 0 with f
    return x == 0 and (f or 0) or x < 0 and -1 or 1
end

function mod:ArrayToString(a) --only give arrays to this and NOT DIRECTIONARIES. Ignores functions.
    local s = "{"
    for _,v in ipairs(a) do
        if type(v) == "table" then
            coroutine.yield()
            if #v == 0 then --if length is 0 it means it's an dictionary and not an array
                s = s..mod:TableToString(v)..","
            else
                s = s..mod:ArrayToString(v)..","
            end
        elseif type(v) ~= "function" then
            local val = type(v) == "number" and v or "'"..v.."'"
            s = s..val..","
        end
    end
    return s.."}"
end

function mod:TableToString(t) --Ignores functions.
    local s = "{"
    for k,v in pairs(t) do
        if type(v) == "table" then
            local key = type(k) == "number" and "["..k.."]=" or "['"..k.."']="
            coroutine.yield()
            if #v == 0 then
                s = s..key..mod:TableToString(v)..","
            else
                s = s..key..mod:ArrayToString(v)..","
            end
        elseif type(v) ~= "function" then
            local key = type(k) == "number" and "["..k.."]=" or "['"..k.."']="
            local val = type(v) == "number" and v or "'"..v.."'"
            s = s..key..val..","
        end
    end
    return s.."}"
end

function mod:StringToTable(s)
    local suc, func = pcall(loadstring,"local TABLE = "..s.."; return TABLE")
    if suc and func then
        local env = setfenv(func,{}) --don't give it acces to anything.
        return env()
    else
        return nil
    end
end

function mod:SaveTiles() --save tiles in selected range
    if mod.IsBusy then
        local msg = graphics:AddMessage("Error; please wait for the previous request to complete before saving again.",3)
        msg:SetColours(1,0,0)
        return
    end
    threads:StartThread(threads:NewThread(function() --put this in a new thread so it won't stop the entire program
        mod.IsBusy = true
        local msg = graphics:AddMessage("Collecting tiles please wait",math.huge)
        local maxTiles = 0
        local signX, signY = sign(ToolSettings.TileRange.EndX-ToolSettings.TileRange.StartX,1), sign(ToolSettings.TileRange.EndY-ToolSettings.TileRange.StartY,1)
        local sx = signX == 1 and ToolSettings.TileRange.StartX or ToolSettings.TileRange.EndX
        local sy = signY == 1 and ToolSettings.TileRange.StartY or ToolSettings.TileRange.EndY
        local struct = {}
        for x = ToolSettings.TileRange.StartX,ToolSettings.TileRange.EndX, signX do
            if LD.Level.Tiles[x] then --check if x is valid
                struct[x-sx+1] = {}
                for y = ToolSettings.TileRange.StartY,ToolSettings.TileRange.EndY, signY do
                    local tile = graphics:IsTilePositionValid(x,y)
                    if tile then
                        maxTiles = maxTiles + 1
                        struct[x-sx+1][y-sy+1] = tile
                    else
                        msg:SetColours(1,0,0)
                        msg:Update("Something went wrong. Tiles did NOT save.", 3)
                        mod.IsBusy = false
                        print("SavingTiles/Whoops/1")
                        return
                    end
                end
            else
                msg:SetColours(1,0,0)
                msg:Update("Something went wrong. Tiles did NOT save.", 3)
                mod.IsBusy = false
                print("SavingTiles/Whoops/2")
                return
            end
        end
        if love.filesystem.getInfo("SavedTiles1.luat") == nil then
            print("Generating new file; SavedTiles1.luat")
            love.filesystem.write("SavedTiles1.luat","{}")
        end
        msg:Update("Reading file...")
        local savedTiles = mod:StringToTable(love.filesystem.read("SavedTiles1.luat"))
        if not savedTiles then
            msg:SetColours(1,0,0)
            print(savedTiles)
            msg:Update("Failed saving tiles. SavedTiles1.luat is corrupted. Please delete the file and try again.",3)
            mod.IsBusy = false
            print("SavingTiles/Whoops/3")
            return
        end
        msg:Update("Generating ID please wait 0%",math.huge)
        local p = 0
        local tileId = ""
        for x,yList in ipairs(struct) do
            for y,id in ipairs(yList) do
                p = p + 1
                msg:Update("Generating ID please wait "..(math.floor(p/maxTiles*1000)/10).."%")
                tileId = tileId..id
                if p%100 == 0 then
                    coroutine.yield() --yield the function every 100 loops
                end
            end
        end
        if savedTiles[tileId] then
            msg:SetColours(1,0,0)
            msg:Update("Failed to save due to a close already existing.",3)
            mod.IsBusy = false
            return
        end
        savedTiles[tileId] = struct
        msg:Update("Saving tiles...")
        local str = mod:TableToString(savedTiles)
        love.filesystem.write("SavedTiles1.luat",str)
        msg:Update("Succesfully saved tiles! Check Saved1 to view the saved tiles!",3)
        mod.IsBusy = false
    end))
end

return mod
