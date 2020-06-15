
local graphics = require("loaders.graphics")
local mod = {}

function mod:NewWindow(x, y, w, h) --honestly this is just placing frames together in a nice fashion
    local window = {}
    window.X, window.Y = x or 0, y or 0
    window.W, window.H = w or 300, h or 225
    window.Z = 999
    window.Title = "My Window" --todo: make this work, also add textlabels in loaders.graphics
    window.Tabs = {
        MainBg = graphics:NewFrame(window.X, window.Y+16, window.W, window.H-16, window.Z, "Menu", 0, 0);
        TopBar = graphics:NewFrame(window.X, window.Y, window.W-16, 16, window.Z+1, "Menu", 0, 0);
        ClosingIcon = graphics:NewFrame(window.X+window.W-16, window.Y, 16, 16, window.Z+1, "Menu", 0, 0);
    }
    --initiating some values
    window.Tabs.MainBg:SetColours(.3,.3,.3)
    for _,tab in pairs(window.Tabs) do
        tab.Visible = true
        tab.ScreenPosition = true
        tab.ApplyZoom = false
        tab.Collision.OnEnter = nil
        tab.Collision.OnLeave = nil
        tab.Collision.DetectHover = true
    end
    --drag behaviour
    window.Tabs.TopBar:SetColours(.4,.4,.4)
    window.Tabs.TopBar.Collision.OnClick = function()
        print("Drag Start!")
    end
    --close behaviour
    window.Tabs.ClosingIcon:SetImage(Textures.HUDTextures.genericClose)
    window.Tabs.ClosingIcon.FitImageInsideWH = true
    window.Tabs.ClosingIcon.Collision.OnClick = function()
        window:Close()
    end
    function window:Close()
        graphics:MassDelete(self.Tabs)
    end
    function window:Move(x, y)
        self.X, self.Y = x or self.X, y or self.Y
        self.Tabs.MainBg:Move(window.X, window.Y+16)
        self.Tabs.TopBar:Move(window.X, window.Y)
        self.Tabs.ClosingIcon:Move(window.X+window.W-16, window.Y)
    end
    return window
end

return mod
