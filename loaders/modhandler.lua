
local graphics = require("loaders.graphics")
local windows = require("loaders.window")

local mod = {}

function mod:OpenEditor(id)
    print(id)
    local window = windows:NewWindow(ToolSettings.MouseX - 230, ToolSettings.MouseY - 150, 300, 200)
    window:SetTitle("Value Editor")
    
end

return mod
