--[[
local otherWindowModule = require("uiWindow")
local function sort(a,b) return a.Z < b.Z end

function _G.ReadLevelCode(code,antiSave,isStart)
    if not antiSave then
        AutoSave("Load")
    end
    for _,v in pairs(items) do v:Destroy() end items = {}
    levelSizeX = 25
    levelSizeY = 17
    tiles = cleanLevel
    local mod = {}
    local currentParam = "size"
    local lastKey = "x"
    local lastValue = ""
    local setAmount = false
    local writeMod = false
    local cX, cY = 0, 0
    local params = {}
    local layer = "r"
    local i = 0
    for c in string.gmatch(code,".") do
        i = i + 1
        if currentParam == "size" then --X AND Y SIZE
            if lastKey == "x" then
                if c ~= "x" then
                    lastValue = lastValue..c
                else
                    if tonumber(lastValue) == nil then
                        error("x or y invalid")
                        return
                    end
                    levelSizeX = tonumber(lastValue)
                    lastKey = "y"
                    lastValue = ""
                end
            else
                if c ~= "~" then
                    lastValue = lastValue..c
                else
                    if tonumber(lastValue) == nil then
                        error("x or y invalid")
                        return
                    end
                    currentParam = "tiles"
                    levelSizeY = tonumber(lastValue)
                    lastKey = ""
                    lastValue = ""
                end
            end
        elseif currentParam == "tiles" then --TILES
            if c ~= "~" then
                if c == "*" then
                    if setAmount then
                        if #lastKey ~= 0 then
                            if tileImages[lastKey] == nil then
                                error("Tile doesn't exist")
                                return
                            end
                            for _ = 1,tonumber(lastValue) do
                                cY = cY+1 > levelSizeY and 1 or cY+1
                                cX = cY == 1 and cX+1 or cX
                                if tiles[cX] ~= nil then
                                    tiles[cX][cY] = lastKey
                                else
                                    tiles[cX] = {[cY] = lastKey}
                                end
                            end
                        end
                        setAmount = false
                        lastValue = ""
                        lastKey = ""
                    else
                        setAmount = true
                        lastValue = ""
                    end
                else
                    if setAmount then
                        lastValue = lastValue..c
                    else
                        if #lastKey == 2 or c == "0" then
                            if setAmount then
                                if tileImages[lastKey] == nil then
                                    error("Tile doesn't exist")
                                    return
                                end
                                for _ = 1,tonumber(lastValue) do
                                    cY = cY+1 > levelSizeY and 1 or cY+1
                                    cX = cY == 1 and cX+1 or cX
                                    if tiles[cX] ~= nil then
                                        tiles[cX][cY] = lastKey
                                    else
                                        tiles[cX] = {[cY] = lastKey}
                                    end
                                end
                                setAmount = false
                                lastValue = ""
                                lastKey = ""
                            elseif #lastKey ~= 0 then
                                cY = cY+1 > levelSizeY and 1 or cY+1
                                cX = cY == 1 and cX+1 or cX
                                if tileImages[lastKey] == nil then
                                    error("Tile doesn't exist")
                                    return
                                end
                                if tiles[cX] ~= nil then
                                    tiles[cX][cY] = lastKey
                                else
                                    tiles[cX] = {[cY] = lastKey}
                                end
                                lastValue = ""
                                lastKey = c
                            else
                                lastKey = c
                            end
                        elseif lastKey == "0" then
                            cY = cY+1 > levelSizeY and 1 or cY+1
                            cX = cY == 1 and cX+1 or cX
                            if tileImages[lastKey] == nil then
                                error("Tile doesn't exist")
                                return
                            end
                            if tiles[cX] ~= nil then
                                tiles[cX][cY] = lastKey
                            else
                                tiles[cX] = {[cY] = lastKey}
                            end
                            setAmount = false
                            lastValue = ""
                            lastKey = c
                        else
                            lastValue = ""
                            lastKey = lastKey..c
                        end
                    end
                end
            else
                setAmount = false
                currentParam = "items"
                lastValue = ""
                lastKey = ""
            end
        elseif currentParam == "items" then --ITEMS
            if c == "|" or c == "~" then
                if lastValue ~= "NO" then
                    table.insert(params,lastValue)
                    lastValue = ""
                    table.insert(params,1)
                    table.insert(params,layer)
                    if string.sub(params[1],1,1) == "0" then
                        params[1] = string.sub(params[1],2)
                        params[#params+1] = 1
                    else
                        params[#params+1] = 0
                    end
                    if itemImages[params[1]]--[[ == nil then
                        error("Item does not exist.")
                        return
                    end
                    for k,v in pairs(params) do
                        if k ~= 1 then
                            params[k] = tostring(tonumber(v)) == v and tonumber(v) or v == "." and 0 or v --if string is number, make it a number
                        end
                    end
                    if params[1] == "76" or params[1] == "75" then
                        params[3] = params[3] + 8
                    elseif params[1] == "40" or params[1] == "42" then
                        params[3] = params[3] + 18
                    elseif params[1] == "39" then
                        params[3] = params[3] - 16
                    elseif params[1] == "112" then
                        params[3] = params[3] - 10
                        params[2] = params[2] - 16
                    elseif params[1] == "38" then
                        params[2] = (params[2]+params[5]/2)
                        params[3] = (params[3]-16+params[6]/2)
                    elseif params[1] == "73" then
                        params[3] = params[3] - 28
                        local char
                        local param = ""
                        for cc in params[4]:gmatch(".") do
                            if cc == "%" then
                                char = ""
                            elseif char then
                                char = char..cc
                                if #char == 2 then
                                    param = param..string.char(tonumber("0x"..char))
                                    char = nil
                                end
                            else
                                param = param..cc
                            end
                        end
                        params[4] = param
                    end
                    local it = item:new(params[2]+64,params[3]+64,params[1],true)
                    it.SaveParams = params
                    it:PropChanged()
                    params = {}
                else
                    lastValue = ""
                end
                if c == "~" then
                    currentParam = "musicid"
                    lastKey = ""
                    lastValue = ""
                end
            else
                local lastc = code:sub(i-1,i-1)
                local nextc = code:sub(i+1,i+1)
                if c == "," then
                    table.insert(params,lastValue)
                    lastValue = ""
                elseif (lastc == "|" or lastc == "~") and (nextc == "|" or nextc == "~") and (c == "r" or c == "b" or c == "f") then
                    layer = c
                    lastValue = "NO"
                else
                    lastValue = lastValue..c
                end
            end
        elseif currentParam == "musicid" then --MUSIC
            if c == "~" then
                otherWindowModule.LevelConfig.SongId = tonumber(lastValue)
                lastValue = ""
                currentParam = "bgid"
            else
                lastValue = lastValue..c
            end
        elseif currentParam == "bgid" then --BACKGROUND
            if c == "~" then
                otherWindowModule.LevelConfig.BackgroundId = tonumber(lastValue)
                lastValue = ""
                currentParam = "name"
            else
                lastValue = lastValue..c
            end
        elseif currentParam == "name" then --BACKGROUND
            if string.sub(lastValue,-10) == '<img src="' then
                otherWindowModule.LevelConfig.Name = string.sub(lastValue,1,-11)
                lastValue = ""
                currentParam = "mod"
                table.insert(mod,c)
                writeMod = true
            elseif c == "%" then
                setAmount = 0
            else
                if setAmount then
                    if setAmount == 1 then
                        lastKey = lastKey..c
                        lastValue = lastValue..string.char(tonumber("0x"..lastKey))
                        setAmount = false
                        lastKey = ""
                    else
                        setAmount = setAmount + 1
                        lastKey = lastKey..c
                    end
                else
                    lastValue = lastValue..c
                end
            end
        elseif currentParam == "mod" then
            if c == "%" then
                setAmount = 0
            else
                if setAmount then
                    if setAmount == 1 then
                        lastKey = lastKey..c
                        if string.char(tonumber("0x"..lastKey)) == '"' then
                            if writeMod then
                                table.insert(mod,"")
                            end
                            writeMod = not writeMod
                            setAmount = false
                            lastKey = ""
                        else
                            if writeMod then
                                mod[#mod] = mod[#mod]..string.char(tonumber("0x"..lastKey))
                            end
                            setAmount = false
                            lastKey = ""
                        end
                    else
                        setAmount = setAmount + 1
                        lastKey = lastKey..c
                    end
                elseif writeMod then
                    mod[#mod] = mod[#mod]..c
                end
            end
        end
    end
    if currentParam == "name" and lastValue ~= "" then
        otherWindowModule.LevelConfig.Name = lastValue
    end
    ModsFromCode = mod
    if isStart then
    else
        otherWindowModule:OpenWindow(10)
    end
    camX, camY = -50,levelSizeY*32+50-windowY
    undoModule:Initialize()
end

function _G.GenerateLevelCode() --generate the save code
    local changeList = {["0D"] = true,["20"] = true,["2C"] = true,["2E"] = true,["21"] = true,["3F"] = true,["27"] = true,["22"] = true,["2F"] = true,["5C"] = true,["3A"] = true,["3B"] = true,["3C"] = true,["3D"] = true,["3E"] = true,["40"] = true,["5F"] = true,["7E"] = true,["23"] = true,["24"] = true,["25"] = true,["26"] = true,["28"] = true,["29"] = true,["2A"] = true,["2B"] = true,["2D"] = true}
    local code = levelSizeX.."x"..levelSizeY.."~"
    local tempTileAmount = 0
    local tempTileId = ""
    --tiles
    for x,yList in pairs(tiles) do
        for y,id in pairs(yList) do
            if tempTileAmount == 0 then
                tempTileId = id
            end
            if tiles[x][y] == tempTileId then
                tempTileAmount = tempTileAmount + 1
            else
                code = tempTileAmount == 1 and code..tempTileId or code..tempTileId.."*"..tempTileAmount.."*"
                tempTileId = id
                tempTileAmount = 1
            end
        end
    end
    code = tempTileAmount == 1 and code..tempTileId or code..tempTileId.."*"..tempTileAmount.."*"
    code = code.."~"
    --items
    local function checkItem(item)
        if item.iID == "38" then
            if item.SaveParams[#item.SaveParams] == 1 then
                code = code.."0"
            end
            code = code.."38,"
            code = code..(item.X-64-item.SaveParams[5]/2)..","
            code = code..(item.Y-48-item.SaveParams[6]/2)..","
            code = code..item.SaveParams[4]..","
            code = code..(item.SaveParams[5]+10)..","
            code = code..item.SaveParams[6].."|"
        else
            if item.SaveParams[#item.SaveParams] == 1 then
                code = code.."0"
            end
            for i,value in pairs(item.SaveParams) do
                if i < #item.SaveParams-2 then
                    if type(value) == "number" then
                        value = math.floor(value*100)/100
                    end
                    if i == 3 then
                        if item.iID == "76" or item.iID == "75" then
                            value = value - 8
                        elseif item.iID == "40" or item.iID == "42" then
                            value = value - 18
                        elseif item.iID == "39" then
                            value = value + 16
                        elseif item.iID == "112" then
                            value = value + 10
                        elseif item.iID == "73" then
                            value = value + 28
                        end
                    elseif i == 2 then
                        if  item.iID == "112" then
                            value = value - 16
                        end
                    elseif i == 4 then
                        if item.iID == "73" then
                            local name = ""
                            for c in string.gmatch(value,".") do
                                if changeList[string.format("%x",string.byte(c)):upper()] ~= nil then
                                    name = name.."%"..string.format("%x",string.byte(c)):upper()
                                else
                                    name = name..c
                                end
                            end
                            value = name
                        end
                    end
                    code = code..value..","
                end
            end
            code = code:sub(1,-2).."|"
        end
    end
    if Mods[1][3] then
        code = code.."r|"
        for _,item in ipairs(itemsOnZ.r) do
            checkItem(item)
        end
        code = code.."b|"
        for _,item in ipairs(itemsOnZ.b) do
            checkItem(item)
        end
        code = code.."f|"
        for _,item in ipairs(itemsOnZ.f) do
            checkItem(item)
        end
    else
        local saveItems = {}
        for _,item in ipairs(itemsOnZ.b) do
            table.insert(saveItems,item)
        end
        for _,item in ipairs(itemsOnZ.r) do
            table.insert(saveItems,item)
        end
        for _,item in ipairs(itemsOnZ.f) do
            table.insert(saveItems,item)
        end
        table.sort(saveItems,sort)
        for _,item in ipairs(saveItems) do
            checkItem(item)
        end
    end
    code = code:sub(1,-2)
    local name = ""
    for c in string.gmatch(otherWindowModule.LevelConfig.Name,".") do
        if changeList[string.format("%x",string.byte(c)):upper()] ~= nil then
            name = name.."%"..string.format("%x",string.byte(c)):upper()
        else
            name = name..c
        end
    end
    code = code.."~"..otherWindowModule.LevelConfig.SongId.."~"..otherWindowModule.LevelConfig.BackgroundId.."~"..name
    for _,v in pairs(Mods) do
        if v[3] then
            local mc = ""
            for c in v[2]:gmatch(".") do
                if changeList[string.format("%x",string.byte(c)):upper()] ~= nil then
                    mc = mc.."%"..string.format("%x",string.byte(c)):upper()
                else
                    mc = mc..c
                end
            end
            code = code.."%3Cimg%20src%3D%22"..mc.."%22%3E"
        end
    end
    return code
end

return true
--]]