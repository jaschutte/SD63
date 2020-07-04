
--[[
    Because I'll need to look into the decompiler *alot*
    Here's a smol list of special stuffz
    EditorFrame = 5
    Lines 39 - 119; lists for special items
    Lines 391 - 437; item place hover logic
    Lines 438 - 659; item place logic
    
    Platforms: DefineSprite (7722)
    Rotating Square: DefineSprite(7734)
    Rotating Triangle: DefineSprite(7738)
    Frames inside of LDItem are the item (frame number = item id)
]]

local graphics = require("loaders.graphics")
local windows = require("loaders.window")

local mod = {}
mod.DisplayForStat = {}
mod.SpecialStats = {}
mod.NamesForId = {
    [1] = "Spawn"; [2] = "Coin"; [3] = "Red Coin"; [4] = "Blue Coin"; [5] = "Silver Star"; [6] = "Shrine"; [7] = "Green Platform"; [8] = "Rotating Green Platforms"; [9] = "Rotating Square";
    [10] = "Node"; [11] = "Falling Node";
}
mod.Appearance = {ZIndex = true, Layer = true, PlatformSize = true, Mirror = true, Angle = true, Color = true, Frame = true, BlockType = true, Size = true, Depth = true, Length = true}

function mod:Init()
    --create the list for item initialization
    local global = {
        ["1"] = {Stats = {0, 0, "Right"};Desc = {"X Speed", "Y Speed", "Direction"};};
        ["7"] = {Stats = {4, 0, 30, 0, 0, 0, "Right", "none", 0.5, 1, 0, 25}; Desc = {"X Speed", "Y Speed", "X Length", "Y Length", "X Offset", "Y Offset", "X Direction", "Y Direction", "Acceleration", "Platform Size", "Touch & Go", "Count"};};
        ["8"] = {Stats = {2, 2, 50, 0, 1}; Desc = {"Speed", "Platform Count", "Radius", "Offset", "Platform Size"};};
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
        label.FontColour = {
            R = Colours.WindowUI.SubTextColour[1] or 0,
            G = Colours.WindowUI.SubTextColour[2] or 0,
            B = Colours.WindowUI.SubTextColour[3] or 0,
            A = Colours.WindowUI.SubTextColour[4] or 1;
        }
        label:SetColours(unpack(Colours.WindowUI.ReadOnly))
        window:Attach(label, x, y, 2) --index is 2 so it doesn't collide with the textboxes which are 3
        return label
    end
    local function defaultNum(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        local label = graphics:NewEditableText(0, 0, w/2, h)
        label.Settings.NumberOnly = true
        label.Settings.RoundNumber = 0
        label.OnCompletion = function()
            item.Stats.Dict[key] = tonumber(label.Text)
        end
        label.Text = tostring(val)
        label.FontColour = {
            R = Colours.WindowUI.NormalTextColour[1] or 0,
            G = Colours.WindowUI.NormalTextColour[2] or 0,
            B = Colours.WindowUI.NormalTextColour[3] or 0,
            A = Colours.WindowUI.NormalTextColour[4] or 1;
        }
        label:SetColours(unpack(Colours.WindowUI.NormalField))
        window:Attach(label, x + w/2, y, 3)
        return label
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
        button.FontColour = {
            R = Colours.WindowUI.NormalTextColour[1] or 0,
            G = Colours.WindowUI.NormalTextColour[2] or 0,
            B = Colours.WindowUI.NormalTextColour[3] or 0,
            A = Colours.WindowUI.NormalTextColour[4] or 1;
        }
        window:Attach(button, x + w/2, y, 3)
        return button
    end
    local function addSub(item, key, x, y, w, h, valbox, window, inc, min, max) --a default for adding + / - button at the end of a textbox
        min, max = min or -math.huge, max or math.huge
        local add = graphics:NewFrame(0, 0, h, h/2)
        add.AnchorX, add.AnchorY = 0, 0
        add:SetImage(Textures.MenuTextures.Add)
        add.Collision.DetectHover = true
        add.Collision.OnClick = function()
            valbox.Text = tostring(math.min(max, tonumber(valbox.Text) + inc))
            item.Stats.Dict[key] = tonumber(valbox.Text)
        end
        add.FitImageInsideWH = true
        window:Attach(add, x + w - h, y, 3)
        local sub = graphics:NewFrame(0, 0, h, h/2)
        sub.AnchorX, sub.AnchorY = 0, 0
        sub:SetImage(Textures.MenuTextures.Subtract)
        sub.Collision.DetectHover = true
        sub.Collision.OnClick = function()
            valbox.Text = tostring(math.max(min, tonumber(valbox.Text) - inc))
            item.Stats.Dict[key] = tonumber(valbox.Text)
        end
        sub.FitImageInsideWH = true
        window:Attach(sub, x + w - h, y + h/2, 3)
        return add, sub
    end

    --some standard functions
    self.DisplayForStat.ItemId = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window) --make itemid changeable? idkkkk
        local label = graphics:NewEditableText(0, 0, w/2, h)
        label.Settings.ReadOnly = true
        label.Text = tostring(val)
        label:SetColours(unpack(Colours.WindowUI.ReadOnly))
        label.FontColour = {
            R = Colours.WindowUI.NormalTextColour[1] or 0,
            G = Colours.WindowUI.NormalTextColour[2] or 0,
            B = Colours.WindowUI.NormalTextColour[3] or 0,
            A = Colours.WindowUI.NormalTextColour[4] or 1;
        }
        window:Attach(label, x + w/2, y, 3)
    end
    self.DisplayForStat.NoDecimals = function(item, key, val, x, y, w, h, window) --fallback for no decimal textboxes
        defLabel(key, x, y, w, h, window)
        local label = graphics:NewEditableText(0, 0, w/2 - h, h)
        label.Settings.NumberOnly = true
        label.Settings.RoundNumber = 0
        label.Text = tostring(math.floor(val+.5))
        label.OnCompletion = function()
            item.Stats.Dict[key] = tonumber(label.Text)
        end
        label.FontColour = {
            R = Colours.WindowUI.NormalTextColour[1] or 0,
            G = Colours.WindowUI.NormalTextColour[2] or 0,
            B = Colours.WindowUI.NormalTextColour[3] or 0,
            A = Colours.WindowUI.NormalTextColour[4] or 1;
        }
        label:SetColours(unpack(Colours.WindowUI.NormalField))
        window:Attach(label, x + w/2, y, 3)
        addSub(item, key, x, y, w, h, label, window, 1)
    end
    
    --directions
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
    
    --layer & z index
    self.DisplayForStat.Layer = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        defaultDir(item, key, val, x, y, w, h, window, "Mixed", "Front", "Back")
    end
    self.DisplayForStat.ZIndex = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        local label = graphics:NewEditableText(0, 0, w/2 - h, h)
        label.Settings.NumberOnly = true
        label.Settings.RoundNumber = 0
        label.Settings.Bounds.Enabled = true
        label.Settings.Bounds.Max = math.huge
        label.Settings.Bounds.Min = 1
        label.Text = tostring(math.floor(val+.5))
        label.OnCompletion = function()
            item.Stats.Dict[key] = tonumber(label.Text)
        end
        label:SetColours(unpack(Colours.WindowUI.NormalField))
        label.FontColour = {
            R = Colours.WindowUI.NormalTextColour[1] or 0,
            G = Colours.WindowUI.NormalTextColour[2] or 0,
            B = Colours.WindowUI.NormalTextColour[3] or 0,
            A = Colours.WindowUI.NormalTextColour[4] or 1;
        }
        window:Attach(label, x + w/2, y, 3)
        addSub(item, key, x, y, w, h, label, window, 1, 1)
    end

    --water
    self.DisplayForStat.Depth = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        local label = graphics:NewEditableText(0, 0, w/2 - h, h)
        label.Settings.NumberOnly = true
        label.Settings.RoundNumber = 0
        label.Settings.Bounds.Enabled = true
        label.Settings.Bounds.Min = 0
        label.Settings.Bounds.Max = math.huge
        label.Text = tostring(math.floor(val+.5))
        label.OnCompletion = function()
            item.Stats.Dict[key] = tonumber(label.Text)
        end
        label.FontColour = {
            R = Colours.WindowUI.NormalTextColour[1] or 0,
            G = Colours.WindowUI.NormalTextColour[2] or 0,
            B = Colours.WindowUI.NormalTextColour[3] or 0,
            A = Colours.WindowUI.NormalTextColour[4] or 1;
        }
        label:SetColours(unpack(Colours.WindowUI.NormalField))
        window:Attach(label, x + w/2, y, 3)
        addSub(item, key, x, y, w, h, label, window, 16, 0)
    end
    self.DisplayForStat.Length = self.DisplayForStat.Depth
    
    --speed & length & size
    self.DisplayForStat.XSpeed = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        local label = graphics:NewEditableText(0, 0, w/2 - h, h)
        label.Settings.NumberOnly = true
        label.Settings.RoundNumber = 0
        label.Text = tostring(math.floor(val+.5))
        label.OnCompletion = function()
            item.Stats.Dict[key] = tonumber(label.Text)
        end
        label:SetColours(unpack(Colours.WindowUI.NormalField))
        label.FontColour = {
            R = Colours.WindowUI.NormalTextColour[1] or 0,
            G = Colours.WindowUI.NormalTextColour[2] or 0,
            B = Colours.WindowUI.NormalTextColour[3] or 0,
            A = Colours.WindowUI.NormalTextColour[4] or 1;
        }
        window:Attach(label, x + w/2, y, 3)
        addSub(item, key, x, y, w, h, label, window, 2)
    end
    self.DisplayForStat.YSpeed = self.DisplayForStat.XSpeed
    self.DisplayForStat.XLength = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        local label = graphics:NewEditableText(0, 0, w/2 - h, h)
        label.Settings.NumberOnly = true
        label.Settings.RoundNumber = 0
        label.Settings.Bounds.Enabled = true
        label.Settings.Bounds.Min = 0
        label.Settings.Bounds.Max = math.huge
        label.Text = tostring(math.floor(val+.5))
        label.OnCompletion = function()
            item.Stats.Dict[key] = tonumber(label.Text)
        end
        label.FontColour = {
            R = Colours.WindowUI.NormalTextColour[1] or 0,
            G = Colours.WindowUI.NormalTextColour[2] or 0,
            B = Colours.WindowUI.NormalTextColour[3] or 0,
            A = Colours.WindowUI.NormalTextColour[4] or 1;
        }
        label:SetColours(unpack(Colours.WindowUI.NormalField))
        window:Attach(label, x + w/2, y, 3)
        addSub(item, key, x, y, w, h, label, window, 8, 0)
    end
    self.DisplayForStat.YLength = self.DisplayForStat.XLength
    self.DisplayForStat.Size = self.DisplayForStat.XLength

    --frame & color & blocktype & platform size
    self.DisplayForStat.Frame = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        local label = graphics:NewEditableText(0, 0, w/2 - h, h)
        label.Settings.NumberOnly = true
        label.Settings.RoundNumber = 0
        label.Settings.Bounds.Enabled = true
        label.Settings.Bounds.Min = 1
        label.Settings.Bounds.Max = 6
        label.Text = tostring(math.floor(val+.5))
        label.OnCompletion = function()
            item.Stats.Dict[key] = tonumber(label.Text)
        end
        label:SetColours(unpack(Colours.WindowUI.NormalField))
        label.FontColour = {
            R = Colours.WindowUI.NormalTextColour[1] or 0,
            G = Colours.WindowUI.NormalTextColour[2] or 0,
            B = Colours.WindowUI.NormalTextColour[3] or 0,
            A = Colours.WindowUI.NormalTextColour[4] or 1;
        }
        window:Attach(label, x + w/2, y, 3)
        addSub(item, key, x, y, w, h, label, window, 1, 1, 6)
    end
    self.DisplayForStat.BlockType = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        local label = graphics:NewEditableText(0, 0, w/2 - h, h)
        label.Settings.NumberOnly = true
        label.Settings.RoundNumber = 0
        label.Settings.Bounds.Enabled = true
        label.Settings.Bounds.Min = 1
        label.Settings.Bounds.Max = 31
        label.Text = tostring(math.floor(val+.5))
        label.OnCompletion = function()
            item.Stats.Dict[key] = tonumber(label.Text)
        end
        label:SetColours(unpack(Colours.WindowUI.NormalField))
        label.FontColour = {
            R = Colours.WindowUI.NormalTextColour[1] or 0,
            G = Colours.WindowUI.NormalTextColour[2] or 0,
            B = Colours.WindowUI.NormalTextColour[3] or 0,
            A = Colours.WindowUI.NormalTextColour[4] or 1;
        }
        window:Attach(label, x + w/2, y, 3)
        addSub(item, key, x, y, w, h, label, window, 1, 1, 31)
    end
    self.DisplayForStat.Color = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        local label = graphics:NewEditableText(0, 0, w/2 - h, h)
        label.Settings.NumberOnly = true
        label.Settings.RoundNumber = 0
        label.Settings.Bounds.Enabled = true
        label.Settings.Bounds.Min = 1
        label.Settings.Bounds.Max = 9
        label.Text = tostring(math.floor(val+.5))
        label.OnCompletion = function()
            item.Stats.Dict[key] = tonumber(label.Text)
        end
        label:SetColours(unpack(Colours.WindowUI.NormalField))
        label.FontColour = {
            R = Colours.WindowUI.NormalTextColour[1] or 0,
            G = Colours.WindowUI.NormalTextColour[2] or 0,
            B = Colours.WindowUI.NormalTextColour[3] or 0,
            A = Colours.WindowUI.NormalTextColour[4] or 1;
        }
        window:Attach(label, x + w/2, y, 3)
        addSub(item, key, x, y, w, h, label, window, 1, 1, 9)
    end
    self.DisplayForStat.PlatformSize = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        local label = graphics:NewEditableText(0, 0, w/2 - h, h)
        label.Settings.NumberOnly = true
        label.Settings.RoundNumber = 0
        label.Settings.Bounds.Enabled = true
        label.Settings.Bounds.Min = 1
        label.Settings.Bounds.Max = 3
        label.Text = tostring(math.floor(val+.5))
        label.OnCompletion = function()
            item.Stats.Dict[key] = tonumber(label.Text)
        end
        label:SetColours(unpack(Colours.WindowUI.NormalField))
        label.FontColour = {
            R = Colours.WindowUI.NormalTextColour[1] or 0,
            G = Colours.WindowUI.NormalTextColour[2] or 0,
            B = Colours.WindowUI.NormalTextColour[3] or 0,
            A = Colours.WindowUI.NormalTextColour[4] or 1;
        }
        window:Attach(label, x + w/2, y, 3)
        addSub(item, key, x, y, w, h, label, window, 1, 1, 3)
    end

    self.DisplayForStat.Acceleration = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        local label = graphics:NewEditableText(0, 0, w/2, h)
        label.Settings.NumberOnly = true
        label.Settings.RoundNumber = 2
        label.Settings.Bounds.Enabled = true
        label.Settings.Bounds.Min = 0
        label.Settings.Bounds.Max = math.huge
        label.Text = tostring(math.floor(val*100+.5)/100)
        label.OnCompletion = function()
            item.Stats.Dict[key] = tonumber(label.Text)
        end
        label:SetColours(unpack(Colours.WindowUI.NormalField))
        label.FontColour = {
            R = Colours.WindowUI.NormalTextColour[1] or 0,
            G = Colours.WindowUI.NormalTextColour[2] or 0,
            B = Colours.WindowUI.NormalTextColour[3] or 0,
            A = Colours.WindowUI.NormalTextColour[4] or 1;
        }
        window:Attach(label, x + w/2, y, 3)
    end

    --angle & mirror and a lot of other bools
    self.DisplayForStat.Angle = function(item, key, val, x, y, w, h, window)
        defLabel(key, x, y, w, h, window)
        local label = graphics:NewEditableText(0, 0, w/2 - h, h)
        label.Settings.NumberOnly = true
        label.Settings.RoundNumber = 0
        label.Settings.Bounds.Enabled = true
        label.Settings.Bounds.Min = 0
        label.Settings.Bounds.Max = 360
        label.Text = tostring(math.floor(val+.5))
        label.OnCompletion = function()
            item.Stats.Dict[key] = tonumber(label.Text)
        end
        label:SetColours(unpack(Colours.WindowUI.NormalField))
        label.FontColour = {
            R = Colours.WindowUI.NormalTextColour[1] or 0,
            G = Colours.WindowUI.NormalTextColour[2] or 0,
            B = Colours.WindowUI.NormalTextColour[3] or 0,
            A = Colours.WindowUI.NormalTextColour[4] or 1;
        }
        window:Attach(label, x + w/2, y, 3)
        local add, sub = addSub(item, key, x, y, w, h, label, window, 5, 0, 360)
        add.Collision.OnClick = function()
            local res = tonumber(label.Text) + 5
            label.Text = tostring(res >= 360 and res - 360 or res)
            item.Stats.Dict[key] = tonumber(label.Text)
        end
        sub.Collision.OnClick = function()
            local res = tonumber(label.Text) - 5 --calculate the result
            label.Text = tostring(res < 0 and 360 + res or res)
            item.Stats.Dict[key] = tonumber(label.Text)
        end
    end
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
    self.DisplayForStat.Chase = self.DisplayForStat.Mirror
    self.DisplayForStat.Disabled = self.DisplayForStat.Mirror
    self.DisplayForStat.StartOff = self.DisplayForStat.Mirror

    self.DisplayForStat.DisableAI = self.DisplayForStat.Mirror --disable AI

    self.DisplayForStat.Offset = self.DisplayForStat.NoDecimals

    self.DisplayForStat.Unknown = self.DisplayForStat.ItemId
    self.DisplayForStat.Default = defaultNum
end

function mod:GetStats(item)
    --39 & 40 [4][5] = X, Y
    local stats = {
        Stats = {item.ItemId, item.Frame.X, item.Frame.Y, 0, item.Frame.Z, item.Frame.Layer};
        Desc = {"Item Id", "X", "Y", "Disable AI", "Z Index", "Layer"};
    }
    local l = #stats.Desc --get the length for the offset
    local special = self.SpecialStats[tostring(item.ItemId)]
    if special then --if there are special stats, add them here
        for i,val in ipairs(special.Stats) do
            stats.Stats[i+l] = val
            stats.Desc[i+l] = special.Desc[i]
        end
        if item.ItemId == 39 or item.ItemId == 40 then
            stats.Stats[1+l] = item.Frame.X
            stats.Stats[2+l] = item.Frame.Y
        end
    end
    local dict = {}
    for i,val in ipairs(stats.Stats) do --create a dictionary instead of an array
        local key = stats.Desc[i]
        if key then
            key = key:gsub(" ","") --remove all spaces, to re-add them is simple, key:gsub("%u", function(c) return " "..c end)
            stats.Desc[i] = key
            dict[key] = val
        end
    end
    local initialised = false
    stats.Dict = setmetatable({},{ --create a metatable so it automaticly applies the changes
        __index = function(_, key)
            return dict[key]
        end;
        __newindex = function(_, key, val)
            dict[key] = val
            if key == "X" then
                item.Frame:Move(val, item.Frame.Y)
            elseif key == "Y" then
                item.Frame:Move(item.Frame.X, val)
            elseif key == "Size" then
                item.Frame:Resize(stats.Dict.Size, stats.Dict.Size)
            elseif key == "Angle" then
                item.Frame.R = val / 180 * math.pi
            elseif key == "Mirror" then
                item.Frame.Mirror = val == 1
            elseif key == "ZIndex" then --can't combined layer and index into one due to we not knowing the index of either
                item.Frame:ChangeZ(val)
            elseif key == "Layer" then
                item.Frame:ChangeZ(nil, val == "Mixed" and "r" or val == "Front" and "f" or "b")
            elseif key == "Depth" then
                if initialised then
                    local delta = item.Frame.H - val
                    print(delta)
                    item.Frame:Move(nil, item.Frame.Y - delta/2)
                end
                item.Frame:Resize(nil, val)
            elseif key == "Length" then
                if initialised then
                    local delta = item.Frame.W - val
                    item.Frame:Move(item.Frame.X - delta/2)
                end
                item.Frame:Resize(val)
            end
        end
    })
    for i,val in ipairs(stats.Stats) do
        local key = stats.Desc[i]
        if key then
            key = key:gsub(" ","")
            stats.Dict[key] = val --invoke all of the metaevents so it updated once placed
        end
    end
    stats.Stats = nil --remove the old stats table

    if item.ItemId == 9 or item.ItemId == 38 then --if the item is rotating square make it fit between the sizes
        item.Frame:Resize(stats.Dict.Size, stats.Dict.Size)
        item.Frame.FitImageInsideWH = true
    end

    initialised = true
    return stats
end

function mod:New(id, x, y) --create new
    if ToolSettings.CtrlDown then
        x = math.floor(x/ToolSettings.ItemGrid.X+0.5)*ToolSettings.ItemGrid.X
        y = math.floor(y/ToolSettings.ItemGrid.Y+0.5)*ToolSettings.ItemGrid.Y
    end
    local item = {}
    item.Id = GetId()
    item.ItemId = id
    item.Frame = graphics:NewFrame(x, y, nil, nil, 1) --create the frame for the item (including img)
    item.Frame:SetImage(Textures.ItemTextures[id])
    item.Frame:Resize(item.Frame.ImageData.W, item.Frame.ImageData.H)
    item.Frame.Visible = true
    item.IsBeingDragged = false
    if Textures.RawTextures.Items[item.ItemId] then
        item.Frame:SetCollisionTexture(Textures.RawTextures.Items[item.ItemId])
    end
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
                basic.FontColour = {
                    R = Colours.WindowUI.HeaderTextColour[1] or 0,
                    G = Colours.WindowUI.HeaderTextColour[2] or 0,
                    B = Colours.WindowUI.HeaderTextColour[3] or 0,
                    A = Colours.WindowUI.HeaderTextColour[4] or 1;
                }
                basic:SetFont("InconsolataBold", 16)
                basic:SetColours(unpack(Colours.WindowUI.Tab))
                basic.AnchorX, basic.AnchorY = 0, 0
                window:Attach(basic, 2, 18)
                self.DisplayForStat.ItemId(item, "ItemId", item.Stats.Dict.ItemId, 0, 41, (window.W - 4)/2, 16, window)
                self.DisplayForStat.DisableAI(item, "DisableAI", item.Stats.Dict.DisableAI, (window.W - 4)/2, 41, (window.W - 4)/2, 16, window)
                self.DisplayForStat.NoDecimals(item, "X", item.Stats.Dict.X, 0, 59, (window.W - 4)/2, 16, window)
                self.DisplayForStat.NoDecimals(item, "Y", item.Stats.Dict.Y, (window.W - 4)/2, 59, (window.W - 4)/2, 16, window)
                
                local offsetS, offsetA = 0, 0 --place "advanced" textboxes
                local IgnoreOffset = 5 --any stat below this is not drawn automaticly
                for i,key in ipairs(item.Stats.Desc) do
                    if i >= IgnoreOffset then
                        if not self.Appearance[key] then
                            offsetS = offsetS + 1
                        else
                            offsetA = offsetA + 1
                        end
                    end
                end
                local _a, _s = 0, 0
                for i,key in ipairs(item.Stats.Desc) do
                    if i >= IgnoreOffset then
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
                    specific.FontColour = {
                        R = Colours.WindowUI.HeaderTextColour[1] or 0,
                        G = Colours.WindowUI.HeaderTextColour[2] or 0,
                        B = Colours.WindowUI.HeaderTextColour[3] or 0,
                        A = Colours.WindowUI.HeaderTextColour[4] or 1;
                    }
                    specific:SetFont("InconsolataBold", 16)
                    specific:SetColours(unpack(Colours.WindowUI.Tab))
                    specific.AnchorX, basic.AnchorY = 0, 0
                    window:Attach(specific, 2, 79)
                    height = height + math.ceil(offsetS/2) * 18 + 25
                end
                if offsetA ~= 0 then --if there are no advanced options, don't place
                    local appear = graphics:NewText(0, 0, window.W - 4, math.ceil(offsetA/2) * 18 + 23)
                    appear.Text = "  Appearance"
                    appear.FontColour = {
                        R = Colours.WindowUI.HeaderTextColour[1] or 0,
                        G = Colours.WindowUI.HeaderTextColour[2] or 0,
                        B = Colours.WindowUI.HeaderTextColour[3] or 0,
                        A = Colours.WindowUI.HeaderTextColour[4] or 1;
                    }
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
    if not ToolSettings.ShiftDown then
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
                if ToolSettings.CtrlDown then
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
