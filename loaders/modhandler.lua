
local graphics = require("loaders.graphics")
local windows = require("loaders.window")

local mod = {}

function mod:OpenEditor(id)
    print(id)
    local window = windows:NewWindow(ToolSettings.MouseX - 230, ToolSettings.MouseY - 150, 300, 200)
    window:SetScaling(true)
    window:SetTitle("Value Editor")
    local main = graphics:NewScrollbar(0, 16, 300, 186)
    main:SetColours(0, 0, 0, 0)
    window.OnResize = function(w, h)
        main:Resize(w, h - 16)
    end
    window:Attach(main, 0, 16)
    local t = graphics:NewFrame(0, 0, 20, 20)
    main:Attach(t, 20, 180)
end

return mod
