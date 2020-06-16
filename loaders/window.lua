
local graphics = require("loaders.graphics")
local mod = {}
mod.Windows = {}

function mod:NewWindow(x, y, w, h) --honestly this is just placing frames together in a nice fashion
    local window = {}
    window.X, window.Y = x or 0, y or 0
    window.W, window.H = w or 300, h or 225
    window.Z = 999
    window.LastLocation = {X = window.X, Y = window.Y}
    window.Id = GetId()
    window.IsDragging = false
    window.CloseAponUnfocus = true
    window._EnableClose = os.clock() + 0.5
    window.Title = "My Window" --todo: make this work, also add textlabels in loaders.graphics
    window.Attached = {}
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
    window.Tabs.TopBar.Collision.OnClick = function(x, y)
        window.LastLocation.X, window.LastLocation.Y = x, y
        window.IsDragging = true
    end
    window.Tabs.TopBar.Collision.OnUp = function()
        window.IsDragging = false
    end
    --close behaviour
    window.Tabs.ClosingIcon:SetImage(Textures.HUDTextures.genericClose)
    window.Tabs.ClosingIcon.FitImageInsideWH = true
    window.Tabs.ClosingIcon.Collision.OnClick = function()
        window:Close()
    end
    function window:IsMouseInFrame()
        local main = self.Tabs.MainBg.Collision.IsBeingHovered or self.Tabs.TopBar.Collision.IsBeingHovered or self.Tabs.ClosingIcon.Collision.IsBeingHovered
        if main then return main end --don't loop if it succeeds here
        for _,data in pairs(self.Attached) do
            if data[1].Collision.DetectHover and data[1].Collision.IsBeingHovered then
                return true
            end
        end
        return false --if all fails, it is false
    end
    function window:Close()
        graphics:MassDelete(self.Tabs)
        local att = {}
        for id,frame in pairs(self.Attached) do
            att[id] = frame[1]
        end
        graphics:MassDelete(att)
        mod.Windows[self.Id] = nil
    end
    function window:Move(x, y) --invoke when moving the window, also updates attached frames
        self.X, self.Y = x or self.X, y or self.Y
        self.Tabs.MainBg:Move(window.X, window.Y+16)
        self.Tabs.TopBar:Move(window.X, window.Y)
        self.Tabs.ClosingIcon:Move(window.X+window.W-16, window.Y)
        for _,data in pairs(self.Attached) do
            data[1]:Move(window.X + data[2], window.Y + data[3])
        end
    end
    function window:Attach(frame, offx, offy, z)
        z = z or 1
        frame.AponDeletion[GetId()] = function(fr) --make sure the same gets deattached when deleted, would cause nasty problems otherwise
            window:DeAttach(fr)
        end
        frame:ChangeZ(window.Z + z, "Menu")
        frame:Move(window.X + offx, window.Y + offy)
        frame.ScreenPosition = true
        frame.ApplyZoom = false
        frame.Visible = true
        self.Attached[frame.Id] = {frame, offx, offy, z}
    end
    function window:DeAttach(frame) --only accepts a frame, NOT AN ID!
        self.Attached[frame.Id] = nil
    end
    self.Windows[window.Id] = window
    return window
end

function mod:MouseUp(button)
    local now = os.clock()
    for _,window in pairs(self.Windows) do
        if window._EnableClose <= now and window.CloseAponUnfocus and not window:IsMouseInFrame() then
            window:Close()
        end
    end
end

function mod:OnMove(x, y)
    for _,window in pairs(self.Windows) do
        if window.IsDragging then
            local dx, dy = window.LastLocation.X - x, window.LastLocation.Y - y
            window:Move(window.X - dx, window.Y - dy)
            window.LastLocation.X, window.LastLocation.Y = x, y
        end
    end
end

return mod
