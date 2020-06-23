
local graphics = require("loaders.graphics")
local windows = require("loaders.window")

local mod = {}
mod.DisplayForStat = {}
mod.SpecialStats = {}
mod.NamesForId = {
    [1] = "Spawn"; [2] = "Coin"; [3] = "Red Coin"; [4] = "Blue Coin"; [5] = "Silver Star"; [6] = "Shrine"; [7] = "Green Platform"; [8] = "Rotating Green Platforms"; [9] = "Rotating Square";
    [10] = "Node"; [11] = "Falling Node";
}
mod.Appearance = {Mirror = true, Angle = true, Color = true, Frame = true, BlockType = true, Size = true, Depth = true, Length = true}

function mod:Init()
    --create the list for item initialization
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
            Stats = {math.random(1,4) == 1 and "H0i I'm temmie!" or math.random(1,3) == 1 and "How is your day sir?" or math.random(1,2) == 1 and "This is a sign. It's quite a boring one I would say." or "Hey don't paste mods in here! I'm a SIGN! Not a mod loader!"};
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
    --the drawing functions for those stats
    local function defLabel(key, x, y, w, h, window)
        local label = graphics:NewText(0, 0, w/2, h)
        label.Text = key:gsub("%u", function(c) return " "..c end)
        label:SetHint(true, label.Text)
        if #label.Text >= 14 then
            label.Text = label.Text:sub(1, 12)..".."
        end
        label:SetColours(unpack(Colours.WindowUI.ReadOnly))
        window:Attach(label, x, y, 2) --index is 2 so it doesn't collide with the textboxes which are 3
    end
    local function defaultNum(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        local label = graphics:NewEditableText(0, 0, w/2, h)
        label.Settings.NumberOnly = true
        label.Settings.RoundNumber = 2
        label.OnCompletion = function()
            item.Stats.Dict[key] = tonumber(label.Text)
        end
        label.Text = tostring(val)
        label:SetColours(unpack(Colours.WindowUI.NormalField))
        window:Attach(label, x + w/2, y, 3)
    end
    local function defaultDir(item, key, val, x, y, w, h, window, first, second, third) --default direction value function
        local button = graphics:NewText(0, 0, w/2, h)
        button.Text = val
        button.Collision.OnClick = function()
            button.Text = third and (button.Text == first and second or button.Text == second and third or first) or (button.Text == first and second or first) --cycle through the phases
            if third then
                if button.Text == first then --update the colours
                    button:SetColours(unpack(Colours.WindowUI.TrippleOptionField1))
                elseif button.Text == second then
                    button:SetColours(unpack(Colours.WindowUI.TrippleOptionField2))
                else
                    button:SetColours(unpack(Colours.WindowUI.TrippleOptionField3))
                end
            elseif button.Text == first then
                button:SetColours(unpack(Colours.WindowUI.DoubleOptionField1))
            else
                button:SetColours(unpack(Colours.WindowUI.DoubleOptionField2))
            end
        end
        if third then
            if button.Text == first then --update the colours
                button:SetColours(unpack(Colours.WindowUI.TrippleOptionField1))
            elseif button.Text == second then
                button:SetColours(unpack(Colours.WindowUI.TrippleOptionField2))
            else
                button:SetColours(unpack(Colours.WindowUI.TrippleOptionField3))
            end
        elseif button.Text == first then
            button:SetColours(unpack(Colours.WindowUI.DoubleOptionField1))
        else
            button:SetColours(unpack(Colours.WindowUI.DoubleOptionField2))
        end
        button.OnCompletion = function()
            item.Stats.Dict[key] = button.Text
        end
        window:Attach(button, x + w/2, y, 3)
    end

    self.DisplayForStat.ItemId = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window) --make itemid changeable? idkkkk
        local label = graphics:NewEditableText(0, 0, w/2, h)
        label.Settings.ReadOnly = true
        label.Text = tostring(val)
        label:SetColours(unpack(Colours.WindowUI.ReadOnly))
        window:Attach(label, x + w/2, y, 3)
    end
    
    self.DisplayForStat.Direction = function(item, key, val, x, y, w, h, window) --direction textboxes
        defLabel(key, x, y, w, h, window)
        defaultDir(item, key, val, x, y, w, h, window, "Both", "Left", "Right")
    end
    self.DisplayForStat.XDirection = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        defaultDir(item, key, val, x, y, w, h, window, "none", "Left", "Right")
    end
    self.DisplayForStat.YDirection = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        defaultDir(item, key, val, x, y, w, h, window, "none", "Up", "Down")
    end
    self.DisplayForStat.RotationDirection = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        defaultDir(item, key, val, x, y, w, h, window, "Left", "Right")
    end

    self.DisplayForStat.NoDecimals = function(item, key, val, x, y, w, h, window) --fallback for no decimal textboxes
        defLabel(key, x, y, w, h, window)
        local label = graphics:NewEditableText(0, 0, w/2, h)
        label.Settings.NumberOnly = true
        label.Settings.RoundNumber = 0
        label.Text = tostring(math.floor(val+.5))
        label.OnCompletion = function()
            item.Stats.Dict[key] = tonumber(label.Text)
        end
        label:SetColours(unpack(Colours.WindowUI.NormalField))
        window:Attach(label, x + w/2, y, 3)
    end

    self.DisplayForStat.Depth = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        local label = graphics:NewEditableText(0, 0, w/2, h)
        label.Settings.NumberOnly = true
        label.Settings.RoundNumber = 0
        label.Settings.Bounds.Enabled = true
        label.Settings.Bounds.Min = 0
        label.Settings.Bounds.Max = math.huge
        label.Text = tostring(math.floor(val+.5))
        label.OnCompletion = function()
            item.Stats.Dict[key] = tonumber(label.Text)
        end
        label:SetColours(unpack(Colours.WindowUI.NormalField))
        window:Attach(label, x + w/2, y, 3)
    end
    self.DisplayForStat.Length = self.DisplayForStat.Depth

    self.DisplayForStat.Mirror = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        local button = graphics:NewText(0, 0, w/2, h)
        button.Text = ""
        button.Collision.OnClick = function()
            item.Stats.Dict[key] = item.Stats.Dict[key] == 0 and 1 or 0
            if item.Stats.Dict[key] == 1 then
                button:SetColours(unpack(Colours.Standard.BoolYes))
            else
                button:SetColours(unpack(Colours.Standard.BoolNo))
            end
        end
        if val == 1 then
            button:SetColours(unpack(Colours.Standard.BoolYes))
        else
            button:SetColours(unpack(Colours.Standard.BoolNo))
        end
        window:Attach(button, x + w/2, y, 3)
    end
    self.DisplayForStat["Touch&Go"] = self.DisplayForStat.Mirror

    self.DisplayForStat.Unknown = self.DisplayForStat.ItemId
    self.DisplayForStat.Default = defaultNum
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
            stats.Desc[i] = key
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
                local window = windows:NewWindow(ToolSettings.MouseX, ToolSettings.MouseY)
                window:Resize(400, 300)
                --basic textboxes
                local basic = graphics:NewText(0, 0, window.W - 4, 59)
                basic.Text = "  Basic Attributes"
                basic:SetFont("InconsolataBold", 16)
                basic:SetColours(unpack(Colours.WindowUI.Tab))
                basic.AnchorX, basic.AnchorY = 0, 0
                window:Attach(basic, 2, 18)
                self.DisplayForStat.ItemId(item, "ItemId", item.Stats.Dict.ItemId, 0, 41, (window.W - 4)/2, 16, window)
                self.DisplayForStat.NoDecimals(item, "X", item.Stats.Dict.X, 0, 59, (window.W - 4)/2, 16, window)
                self.DisplayForStat.NoDecimals(item, "Y", item.Stats.Dict.Y, (window.W - 4)/2, 59, (window.W - 4)/2, 16, window)
                
                local offsetS, offsetA = 0, 0 --place "advanced" textboxes
                for i,key in ipairs(item.Stats.Desc) do
                    if i >= 4 then
                        if not self.Appearance[key] then
                            offsetS = offsetS + 1
                        else
                            offsetA = offsetA + 1
                        end
                    end
                end
                local _a, _s = 0, 0
                for i,key in ipairs(item.Stats.Desc) do
                    if i >= 4 then
                        local offset, yOff
                        if self.Appearance[key] then
                            offset = _a; _a = _a + 1
                            yOff = math.ceil(offsetS/2) * 18 + 104 + (offsetS ~= 0 and 23 or -2)
                        else
                            offset = _s; _s = _s + 1;
                            yOff = 102
                        end
                        if self.DisplayForStat[key] then
                            self.DisplayForStat[key](item, key, item.Stats.Dict[key], offset%2 * (window.W - 4)/2, math.floor(offset/2) * 18 + yOff, (window.W - 4)/2, 16, window)
                        else
                            self.DisplayForStat.Default(item, key, item.Stats.Dict[key], offset%2 * (window.W - 4)/2, math.floor(offset/2) * 18 + yOff, (window.W - 4)/2, 16, window)
                        end
                    end
                end
                local height = 79
                if offsetS ~= 0 then --if there are no advanced options, don't place
                    local specific = graphics:NewText(0, 0, window.W - 4, math.ceil(offsetS/2) * 18 + 23)
                    specific.Text = "  Advanced Settings"
                    specific:SetFont("InconsolataBold", 16)
                    specific:SetColours(unpack(Colours.WindowUI.Tab))
                    specific.AnchorX, basic.AnchorY = 0, 0
                    window:Attach(specific, 2, 79)
                    height = height + math.ceil(offsetS/2) * 18 + 25
                end
                if offsetA ~= 0 then --if there are no advanced options, don't place
                    local appear = graphics:NewText(0, 0, window.W - 4, math.ceil(offsetA/2) * 18 + 23)
                    appear.Text = "  Appearance"
                    appear:SetFont("InconsolataBold", 16)
                    appear:SetColours(unpack(Colours.WindowUI.Tab))
                    appear.AnchorX, basic.AnchorY = 0, 0
                    window:Attach(appear, 2, math.ceil(offsetS/2) * 18 + 81 + (offsetS ~= 0 and 23 or -2))
                    height = height + math.ceil(offsetA/2) * 18 + 25
                end

                window:Resize(window.W, height)
                window:SetTitle("Modifying Item: "..(self.NamesForId[item.ItemId] or "ERR: No Name Found").." (#"..item.Id..")")
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
