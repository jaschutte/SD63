
local graphics = require("loaders.graphics")
local windows = require("loaders.window")

local mod = {}

function mod:Init()
    local global = {
        ["1"] = {Stats = {0, 0, "Right"};Desc = {"X Speed", "Y Speed", "Direction"};};
        ["7"] = {Stats = {3, 0, 30, 0, 0, 0, "Right", "none", 0.5, 1, 0, 25}; Desc = {"X Speed", "Y Speed", "X Length", "Y Length", "X Offset", "Y Offset", "X Direction", "Y Direction", "Acceleration", "Size", "Touch & Go", "Count"};};
        ["8"] = {Stats = {2, 2, 50, 0, 1}; Desc = {"X Speed", "Y Speed", "Platform Count", "Radius", "Offset", "Size"};};
        ["9"] = {
            Stats = {0, 0, 0, 0, 0, 0, "Right", "none", 0.5, 80, 1, "Left", 3, 72, 1};
            Desc = {"X Speed", "Y Speed", "X Length", "Y Length", "X Offset", "Y Offset", "X Direction", "Y Direction", "Acceleration", "Size", "Block Type", "Rotation Direction", "Rotation Speed", "Wait Time", "Unknown"};
        };
        ["18"] = {Stats = {2, 0}; Desc = {"Speed", "Angle"};}; ["37"] = {Stats = {15, 0}; Desc = {"Speed", "Angle"};}; ["38"] = {Stats = {0, 128, 96}; Desc = {"Angle", "Length", "Depth"};};
        ["39"] = {Stats = {0, 0, 1}; Desc = {"Target X", "Target Y", "Frame"};}; ["40"] = {Stats = {0, 0}; Desc = {"Target X", "Target Y"};};
        ["44"] = {Stats = {0, 12, 16, 7, 1, 0.1, 3, 30, 1}; Desc = {"Offset", "Wait Time", "Ground Wait Time", "Fall Speed", "Fall Acceleration", "Rise Acceleration", "Rise Speed", "Range", "Chase"};};
        ["45"] = {Stats = {0, 100, 100, 64, 92, 0, 0, 0}; Desc = {"Angle", "X Scale", "Y Scale", "On Wait", "Off Wait", "Disabled", "Offset", "Start Off"};};
        ["71"] = {Stats = {"Both", 0, 3, 100, 0, 1, 0}; Desc = {"Direction", "Angle", "Speed", "Wait", "Offset", "Color", "Chase"};};
        ["73"] = {
            Stats = {math.random(1,4) == 1 and "H0i I'm temmie!", math.random(1,3) == 1 and "How is your day sir?", math.random(1,2) == 1 and "This is a sign. It's quite a boring one I would say." or "Hey don't paste mods in here! I'm a SIGN! Not a mod loader!"};
            Desc = {"Text"};
        };
        ["74"] = {Stats = {20}; Desc = {"Duration"};};
    }
    global["19"] = global["18"]
    global["41"] = {Stats = {1, 0}; Desc = {"Mirror", "Angle"};}
    global["42"] = global["41"]
    for i = 28, 36 do global[tostring(i)] = global["41"] end
    for i = 51, 70 do global[tostring(i)] = {Stats = {1}; Desc = {"Mirror"}} end
    for i = 78, 81 do global[tostring(i)] = {Stats = {30}; Desc = {"Duration"}} end
    for i = 100, 145 do global[tostring(i)] = global["41"] end
    self.SpecialStats = global
end

function mod:GetStats(item)
    --39 & 40 [4][5] = X, Y
    local stats = {
        Stats = {item.ItemId, item.Frame.X, item.Frame.Y};
        Desc = {"Item Id", "X", "Y"};
    }
    local special = self.SpecialStats[tostring(item.ItemId)]
    if special then --if there are special stats, add them here
        for i,val in ipairs(special.Stats) do
            stats.Stats[i+3] = val
            stats.Desc[i+3] = special.Desc[i]
        end
        if item.ItemId == 39 or item.ItemId == 40 then
            stats.Stats[4] = item.Frame.X
            stats.Stats[5] = item.Frame.Y
        end
    end
    stats.Dict = {}
    for i,val in ipairs(stats.Stats) do --create a dictionary instead of an array
        local key = stats.Desc[i]
        if key then
            key = key:gsub(" ","") --remove all spaces, to re-add them is simple, key:gsub("%u", function(c) return " "..c end)
            stats.Dict[key] = val
        end
    end
    stats.Stats = nil --remove the old stats table
    return stats
end

function mod:New(id, x, y) --create new
    if ToolSettings.ShiftDown then
        x = math.floor(x/ToolSettings.ItemGrid.X+0.5)*ToolSettings.ItemGrid.X
        y = math.floor(y/ToolSettings.ItemGrid.Y+0.5)*ToolSettings.ItemGrid.Y
    end
    local item = {}
    item.Id = GetId()
    item.ItemId = id
    item.Frame = graphics:NewFrame(x, y) --create the frame for the item (including img)
    item.Frame:SetImage(Textures.ItemTextures[id])
    item.Frame:Resize(item.Frame.ImageData.W, item.Frame.ImageData.H)
    item.Frame.IS_ITEM = item.ItemId
    item.Frame.Visible = true
    item.IsBeingDragged = false
    item.LastLocation = {X = 0, Y = 0}
    item._LastPressed = os.clock()
    item.Frame.Collision.OnClick = function(mx, my) --onclick behaviour (todo: add double click)
        if ToolSettings.CurrentDisplay == "Items" then
            item.IsBeingDragged = true
            mx, my = graphics:ScreenToWorld(mx, my)
            item.LastLocation.X, item.LastLocation.Y = item.Frame.X - mx, item.Frame.Y - my
            local now = os.clock()
            if now-item._LastPressed ~= 0 and now-item._LastPressed <= 0.3 then --0.3 is the max time between the double click
                --open tab
                --[[local window = windows:NewWindow(ToolSettings.MouseX, ToolSettings.MouseY)
                local frame = graphics:NewText(0, 0, 100, 50)
                frame:SetColours(1, 0, 0)
                frame.AnchorX, frame.AnchorY = 0, 0
                window:Attach(frame, 0, 16, 2)
                window:SetTitle("Modifying Item: "..item.Id)--]]
                item:Destroy()
            end
            item._LastPressed = now
        end
    end
    item.Frame.Collision.OnUp = function()
        item.IsBeingDragged = false
    end
    item.Stats = mod:GetStats(item)
    if not item.Stats then
        return
    end
    --update functionality
    function item:Move(x, y) --makes it easier to update the position
        x = x or self.Frame.X
        y = y or self.Frame.Y
        self:Update("X", x)
        self:Update("Y", y)
        self.Frame.X = x
        self.Frame.Y = y
    end
    function item:Update(key, val) --use this to update item.Stats, it will also invoke update methods for the item properties menu
        if item.Stats then
            item.Stats.Dict[key] = val
        end
    end
    function item:Destroy()
        LD.Level.Items[self.Id] = nil
        self.Frame:Destroy()
    end
    LD.Level.Items[item.Id] = item
    if not ToolSettings.CtrlDown then
        ToolSettings.ItemTool = "move"
    end
    return item
end

function mod:Update()
    local mx, my = ToolSettings.MouseX, ToolSettings.MouseY
    if ToolSettings.ItemTool == "move" and ToolSettings.CurrentDisplay == "Items" then
        for _,item in pairs(LD.Level.Items) do
            --print(item.Frame.OnScreen)
            if item.IsBeingDragged then
                local x, y = graphics:ScreenToWorld(mx, my)
                local dx, dy = item.LastLocation.X + x, item.LastLocation.Y + y
                local fx, fy = dx, dy
                if ToolSettings.ShiftDown then
                    fx = math.floor(dx/ToolSettings.ItemGrid.X+0.5)*ToolSettings.ItemGrid.X
                    fy = math.floor(dy/ToolSettings.ItemGrid.Y+0.5)*ToolSettings.ItemGrid.Y
                end
                item:Move(fx, fy)
            end
        end
    end
end

mod:Init()
return mod
