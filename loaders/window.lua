
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
    window.IsScaled = false
    window.CloseAponUnfocus = true
    window._EnableClose = os.clock() + 0.5
    window.Title = "My Window"
    window.Attached = {}
    window.WindowScale = {
        Enabled = false;
        MinX = 50;
        MinY = 50;
        MaxX = 500;
        MaxY = 500;
    }
    window.Tabs = {
        MainBg = graphics:NewFrame(window.X, window.Y+16, window.W, window.H-16, window.Z, "Menu", 0, 0);
        TopBar = graphics:NewText(window.X, window.Y, window.W-16, 16, window.Z+1, "Menu", 0, 0);
        ClosingIcon = graphics:NewFrame(window.X+window.W-16, window.Y, 16, 16, window.Z+1, "Menu", 0, 0);
        ScaleIcon = graphics:NewFrame(window.X+window.W-16, window.Y+window.H-16, 16, 16, window.Z+1, "Menu", 0, 0);
    }
    --initiating some values
    window.Tabs.MainBg:SetColours(unpack(Colours.WindowUI.MainBg))
    for _,tab in pairs(window.Tabs) do
        tab.Visible = true
        tab.ScreenPosition = true
        tab.ApplyZoom = false
        if tab ~= window.Tabs.ClosingIcon and tab ~= window.Tabs.ScaleIcon then
            tab.Collision.OnEnter = nil
            tab.Collision.OnLeave = nil
        end
        tab.Collision.DetectHover = true
    end
    --scale behaviour
    window.Tabs.ScaleIcon.Collision.OnClick = function(x, y)
        window.LastLocation.X, window.LastLocation.Y = x, y
        window.IsScaled = true
    end
    window.Tabs.ScaleIcon.Collision.OnUp = function(x, y)
        window.IsScaled = false
    end
    --drag behaviour
    window.Tabs.TopBar:SetColours(unpack(Colours.WindowUI.TopBar))
    window.Tabs.TopBar.Text = " "..window.Title
    window.Tabs.TopBar.FontColour = {
        R = Colours.WindowUI.HeaderTextColour[1] or 0,
        G = Colours.WindowUI.HeaderTextColour[2] or 0,
        B = Colours.WindowUI.HeaderTextColour[3] or 0,
        A = Colours.WindowUI.HeaderTextColour[4] or 1;
    }
    window.Tabs.TopBar:SetFont("InconsolataMedium", 12)
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
    function window:Resize(w, h)
        self.W, self.H = w or self.W, h or self.H
        self.Tabs.MainBg:Resize(self.W, self.H - 16)
        self.Tabs.TopBar:Resize(self.W-16, 16)
        self.Tabs.ClosingIcon:Move(self.X+self.W-16, self.Y)
        self.Tabs.ScaleIcon:Move(self.X+self.W-16, self.Y+self.H-16)
    end
    function window:Move(x, y) --invoke when moving the window, also updates attached frames
        self.X, self.Y = x or self.X, y or self.Y
        self.Tabs.MainBg:Move(self.X, self.Y+16)
        self.Tabs.TopBar:Move(self.X, self.Y)
        self.Tabs.ClosingIcon:Move(self.X+self.W-16, self.Y)
        self.Tabs.ScaleIcon:Move(self.X+self.W-16, self.Y+self.H-16)
        for _,data in pairs(self.Attached) do
            data[1]:Move(self.X + data[2], self.Y + data[3])
        end
    end
    function window:SetScaling(enabled) --STILL NEED TO ADD FUNCTIONALITY TO SCALING BUTTON!!
        self.WindowScale.Enabled = enabled
        self.Tabs.ScaleIcon.Visible = enabled
    end
    function window:SetTitle(s)
        self.Text = s
        self.Tabs.TopBar.Text = " "..s
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
    window:SetScaling(false)
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
        elseif window.IsScaled then --resizing still needs worK (aka; resize bounds and fix negative resizes)
            local dx, dy = window.LastLocation.X - x, window.LastLocation.Y - y
            window:Resize(window.W - dx, window.H - dy)
            window.LastLocation.X, window.LastLocation.Y = x, y
        end
    end
end

return mod
