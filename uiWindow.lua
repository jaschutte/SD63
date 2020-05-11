--[[
local songNames = {"Mushroom Kingdom","Bob-Omb Battlefield","Secret Course #1","Secret Course #2","Rainbow Ride","Boo's Mansion","Hazy Maze Cave","Snowman's Land","Lethal Lava Land","Shifting Sand Land","Bowser's Castle","Boss Fight 1","Boss Fight 2","Floater Land","Terror Theme","The Final Battle","The Meteor","Inside the Castle","No Music"}
local jsonModule = require("dkjson")
local wxLua = require("wx")
_G.modsPage = 0
local currentPointer = 4
local whitestGrey = wxLua.wxColour(100,100,100)
local grey = wxLua.wxColour(80,80,80)
local darkGrey = wxLua.wxColour(60,60,60)
local white = wxLua.wxColour(220,220,220)
local dark = wxLua.wxColour(40,40,40)
local nextBitmap = wxLua.wxBitmap("textures/windowIcons/next.png")
local backBitmap = wxLua.wxBitmap("textures/windowIcons/back.png")
local playBitmap = wxLua.wxBitmap("textures/windowIcons/play.png")
local pauseBitmap = wxLua.wxBitmap("textures/windowIcons/pause.png")

if not love.filesystem.getInfo("Settings.json") then
    local t = {}
    t.ShowAnimations = true
    t.SaveAfterClose = true
    t.AutoSaveEvery = 300
    t.Incement = 1
    t.ShowPlayerView = true
    t.CameraSpeed = 1
    love.filesystem.write("Settings.json",jsonModule.encode(t))
end

local mod = {}

mod.LevelConfig = {}
mod.LevelConfig.Name = "My Level"
mod.LevelConfig.BackgroundId = 1
mod.LevelConfig.SongName = "Mushroom Kingdom"
mod.LevelConfig.SongId = 1
mod.LevelConfig.Incement = 1

local rawSettings = love.filesystem.read("Settings.json")
mod.LDSettings = jsonModule.decode(rawSettings)
mod.LDSettings.ShowAnimations = mod.LDSettings.ShowAnimations == nil and true or mod.LDSettings.ShowAnimations == true --check if true to ensure boolean
mod.LDSettings.SaveAfterClose = mod.LDSettings.SaveAfterClose == nil and true or mod.LDSettings.SaveAfterClose == true
mod.LDSettings.ShowPlayerView = mod.LDSettings.ShowPlayerView == nil and true or mod.LDSettings.ShowPlayerView == true
mod.LDSettings.AutoSaveEvery = tonumber(mod.LDSettings.AutoSaveEvery) or 300
mod.LDSettings.CameraSpeed = tonumber(mod.LDSettings.CameraSpeed) or 1
mod.LevelConfig.Incement = 1
mod.LDSettings.Incement = nil

function mod:Init()
    --goal: replace legacy system with wxLua
    mod.Windows = {
        love.graphics.newImage("textures/levelSettingsWindow.png");
        love.graphics.newImage("textures/levelSizeWindow.png");
        love.graphics.newImage("textures/designerSettingsWindow.png");
        love.graphics.newImage("textures/loadLevelWindow.png");
        love.graphics.newImage("textures/saveLevelWindow.png");
        love.graphics.newImage("textures/resetWindow.png");
        love.graphics.newImage("textures/copyright.png");
        love.graphics.newImage("textures/modWindow.png");
        love.graphics.newImage("textures/cameraWindow.png");
        love.graphics.newImage("textures/modWarningWindow.png")
    }
    mod.WindowCollision = {
        love.image.newImageData("textures/windowCollisionMaps/levelSettingsWindow.png");
        love.image.newImageData("textures/windowCollisionMaps/levelSizeWindow.png");
        love.image.newImageData("textures/windowCollisionMaps/designerSettingsWindow.png");
        love.image.newImageData("textures/windowCollisionMaps/loadLevelWindow.png");
        love.image.newImageData("textures/windowCollisionMaps/saveLevelWindow.png");
        love.image.newImageData("textures/windowCollisionMaps/resetWindow.png");
        love.image.newImageData("textures/windowCollisionMaps/copyright.png");
        love.image.newImageData("textures/windowCollisionMaps/modWindow.png");
        love.image.newImageData("textures/windowCollisionMaps/cameraWindow.png");
        love.image.newImageData("textures/windowCollisionMaps/modWarningWindow.png")
    }
end
--TODO: add button code
mod.ButtonForColor = {
    {
        ["25500"] = "BG-";
        ["2550255"] = "BG+";
        ["0255255"] = "SOUND-";
        ["02550"] = "SOUND+";
        ["2552550"] = "STOP";
        ["000"] = "PLAY";
    },
    {
        ["25500"] = "TOP+";
        ["2552550"] = "TOP-";
        ["255255255"] = "RIGHT+";
        ["2550255"] = "RIGHT-";
        ["00255"] = "BOTTEM-";
        ["0255255"] = "BOTTEM+";
        ["000"] = "LEFT-";
        ["02550"] = "LEFT+";
        ["2551270"] = "1";
        ["255127127"] = "5";
        ["127127127"] = "10";
        ["12400"] = "20";
        ["1240255"] = "50";
        ["124255255"] = "75";
        ["2550128"] = "100";
        ["0255144"] = "250";
    },
    {
        ["0255255"] = "ANIMATIONS";
        ["02550"] = "AUTOSAVE";
        ["2552550"] = "EVERY";
        ["25500"] = "RESTORETEMPLATE";
        ["2552550"] = "SAVEASTEMPLATE";
        ["00255"] = "CREDITS";
        ["2550255"] = "RESTORE";
        ["000"] = "PLAYERVIEW"
    },
    {
        ["25500"] = "FILE";
        ["00255"] = "CLIPBOARD";
        ["000"] = "FROMAUTOSAVE";
    },
    {
        ["00255"] = "NAME";
        ["25500"] = "SAVE";
        ["02550"] = "COPY";
    },
    {
        ["025533"] = "KEEP";
        ["25500"] = "DELETE";
    },
    {},
    {
        ["000"] = "MOD_DELETE";
        ["02550"] = "MOD_NEW";
        ["25500"] = "MOD_NEXT";
        ["00255"] = "MOD_PREVIOUS";
        ["0255255"] = "MOD_UP";
        ["2550255"] = "MOD_DOWN";
    },
    {
        ["25500"] = "TPTOPLEFT";
        ["2552550"] = "TPTOPRIGHT";
        ["2550255"] = "TPBOTTEMLEFT";
        ["0255255"] = "TPBOTTEMRIGHT";
        ["00255"] = "TPCENTER";
    },
    {
        ["00255"] = "MOD_ENABLE";
        ["02550"] = "MOD_DISABLE";
        ["25500"] = "MOD_DISCARD";
    }
}
mod.X = 200
mod.Y = 0
mod.Visible = false
mod.Dragged = false
mod.Textboxes = {}
mod.Counters = {}

function FolderPicker()
    local dialog = wxLua.wxDirDialog(wxLua.NULL, "Select a save file.", "")
    dialog:ShowModal()
    local res = dialog:GetPath()
    return res ~= "" and res or nil
end
function SaveFile()
    local dialog = wxLua.wxFileDialog(wxLua.NULL, "Select a location to save the file.", "", "", "Text files (*.txt)|*.txt", 2)
    dialog:ShowModal()
    local res = dialog:GetPath()
    return res ~= "" and res or nil
end
function PickFile(loc)
    loc = loc or ""
    local dialog = wxLua.wxFileDialog(wxLua.NULL, "Select a file to load.", loc, "", "Text files (*.txt)|*.txt")
    dialog:ShowModal()
    local res = dialog:GetPath()
    return res ~= "" and res or nil
end

function mod:SaveSettings()
    local t = {}
    for k,v in pairs(mod.LDSettings) do
        t[k] = v
    end
    t.Incement = mod.LevelConfig.Incement
    if not love.filesystem.getInfo("ShowPlayerView.png") then
        local f = io.open("textures\\defaultViewer.png","rb")
        love.filesystem.write("ShowPlayerView.png",f:read("*a"))
        f:close()
    end
    playerViewer = love.graphics.newImage("ShowPlayerView.png")
    love.filesystem.write("Settings.json",jsonModule.encode(t))
end

function mod:MouseDown(r,g,b)
    local button = self.ButtonForColor[self.Id][r..g..b]
    if button == "SAVE" then --saving levels
        local location = SaveFile()
        if location then
            local file = io.open(location,"w")
            local code = GenerateLevelCode()
            file:write(code)
            file:close()
        end
    elseif button == "COPY" then
        love.system.setClipboardText(GenerateLevelCode())
    elseif button == "FILE" then --LOADING LEVELS
        local location = PickFile()
        if location then
            local file = io.open(location,"r")
            local content = file:read()
            file:close()
            local suc, e = pcall(ReadLevelCode,content)
            if not suc then
                print("something went wrong", e)
                levelSizeX = 25
                levelSizeY = 17
                tiles = cleanLevel
                items = {}
                itemsOnZ = {b={},r={},f={}}
            end
        end
    elseif button == "FROMAUTOSAVE" then
        local loc = string.gsub(love.filesystem.getAppdataDirectory(),"/","\\").."\\LOVE\\SuperDesigner63\\AutoSaveFolder"
        local location = PickFile(loc)
        if location then
            local file = io.open(location,"r")
            local content = file:read()
            file:close()
            local suc, e = pcall(ReadLevelCode,content,true)
            if not suc then
                print("something went wrong", e)
                levelSizeX = 25
                levelSizeY = 17
                tiles = cleanLevel
                items = {}
                itemsOnZ = {b={},r={},f={}}
            end
        end
    elseif button == "CLIPBOARD" then
        local suc, e = pcall(ReadLevelCode,love.system.getClipboardText())
        if  not suc then
            print("something went wrong", e)
            levelSizeX = 25
            levelSizeY = 17
            tiles = cleanLevel
            items = {}
            itemsOnZ = {b={},r={},f={}}
        end
    elseif button == "SOUND-" then --LEVEL SETTINGS
        self.LevelConfig.SongId = math.max(1,self.LevelConfig.SongId-1)
        self.LevelConfig.SongName = songNames[self.LevelConfig.SongId]
    elseif button == "SOUND+" then
        self.LevelConfig.SongId = math.min(19,self.LevelConfig.SongId+1)
        self.LevelConfig.SongName = songNames[self.LevelConfig.SongId]
    elseif button == "PLAY" then
        for i = 1,18 do
            gameSounds[i]:stop()
        end
        if gameSounds[self.LevelConfig.SongId] then
            gameSounds[self.LevelConfig.SongId]:play()
        end
    elseif button == "STOP" then
        if gameSounds[self.LevelConfig.SongId] then
            gameSounds[self.LevelConfig.SongId]:pause()
        end
    elseif button == "BG-" then
        self.LevelConfig.BackgroundId = math.max(1,self.LevelConfig.BackgroundId-1)
    elseif button == "BG+" then
        self.LevelConfig.BackgroundId = math.min(15,self.LevelConfig.BackgroundId+1)
    elseif button == "TOP+" then --LEVEL SIZE
        for x = 1,levelSizeX do
            for y = levelSizeY,1,-1 do
                if tiles[x] ~= nil and tiles[x][y] ~= nil then
                    tiles[x][y+self.LevelConfig.Incement] = tiles[x][y]
                elseif tiles[x] == nil then
                    tiles[x] = {[y+self.LevelConfig.Incement] = "0"}
                else
                    tiles[x][y+self.LevelConfig.Incement] = "0"
                end
            end
        end
        for x = 1,levelSizeX do
            for y = 1,self.LevelConfig.Incement do
                tiles[x][y] = "0"
            end
        end
        for _,v in pairs(items) do
            v.Y = v.Y + self.LevelConfig.Incement*32
        end
        levelSizeY = levelSizeY + self.LevelConfig.Incement
    elseif button == "TOP-" then
        if levelSizeY - self.LevelConfig.Incement < 17 then
            return
        end
        levelSizeY = levelSizeY - self.LevelConfig.Incement
        for x = 1,levelSizeX do
            for y = 1,levelSizeY do
                tiles[x][y] = tiles[x][y+self.LevelConfig.Incement]
            end
        end
        for _,v in pairs(items) do
            v.Y = v.Y - self.LevelConfig.Incement*32
        end
    elseif button == "RIGHT+" then
        for x = levelSizeX+1,levelSizeX+self.LevelConfig.Incement do
            tiles[x] = {}
            for y = 1,levelSizeY do
                tiles[x][y] = "0"
            end
        end
        levelSizeX = levelSizeX + self.LevelConfig.Incement
    elseif button == "RIGHT-" then
        if levelSizeX - self.LevelConfig.Incement < 25 then
            return
        end
        levelSizeX = levelSizeX - self.LevelConfig.Incement
    elseif button == "BOTTEM+" then
        for x = 1,levelSizeX do
            for y = levelSizeY+1,levelSizeY+self.LevelConfig.Incement do
                tiles[x][y] = "0"
            end
        end
        levelSizeY = levelSizeY + self.LevelConfig.Incement
    elseif button == "BOTTEM-" then
        if levelSizeY - self.LevelConfig.Incement < 17 then
            return
        end
        levelSizeY = levelSizeY - self.LevelConfig.Incement
    elseif button == "LEFT+" then
        for x = levelSizeX,1,-1 do
            for y = 1,levelSizeY do
                if tiles[x+self.LevelConfig.Incement] ~= nil and tiles[x+self.LevelConfig.Incement][y] ~= nil then
                    tiles[x+self.LevelConfig.Incement][y] = tiles[x][y]
                elseif tiles[x+self.LevelConfig.Incement] == nil then
                    tiles[x+self.LevelConfig.Incement] = {[y] = "0"}
                else
                    tiles[x+self.LevelConfig.Incement][y] = "0"
                end
            end
        end
        for x = 1,self.LevelConfig.Incement do
            for y = 1,levelSizeY do
                tiles[x][y] = "0"
            end
        end
        for _,v in pairs(items) do
            v.X = v.X + self.LevelConfig.Incement*32
        end
        levelSizeX = levelSizeX + self.LevelConfig.Incement
    elseif button == "LEFT-" then
        if levelSizeX - self.LevelConfig.Incement < 25 then
            return
        end
        levelSizeX = levelSizeX - self.LevelConfig.Incement
        for x = 1,levelSizeX do
            for y = 1,levelSizeY do
                tiles[x][y] = tiles[x+self.LevelConfig.Incement][y]
            end
        end
        for _,v in pairs(items) do
            v.X = v.X - self.LevelConfig.Incement*32
        end
    elseif button == "1" then
        self.LevelConfig.Incement = 1
    elseif button == "5" then
        self.LevelConfig.Incement = 5
    elseif button == "10" then
        self.LevelConfig.Incement = 10
    elseif button == "20" then
        self.LevelConfig.Incement = 20
    elseif button == "50" then
        self.LevelConfig.Incement = 50
    elseif button == "75" then
        self.LevelConfig.Incement = 75
    elseif button == "100" then
        self.LevelConfig.Incement = 100
    elseif button == "250" then
        self.LevelConfig.Incement = 250
    elseif button == "KEEP" then --KEEP/DELETE LEVEL
        self.Visible = false
    elseif button == "DELETE" then
        self.Visible = false
        if not love.filesystem.getInfo("StarterTemplate.txt") then
            love.filesystem.write("StarterTemplate.txt",'80x30~0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2T2Z0*2190*~b|r|1,32,800,0,0,Right|f~1~1~My%20Level')
        end
        local suc, e = pcall(ReadLevelCode,love.filesystem.read("StarterTemplate.txt"))
        if not suc then
            error([[


                Starter template has failed to load. 
                The startertemplate may be corrupted. Please try the following:

                1. Delete the file located at: %appdata%/LOVE/SuperDesigner63/StarterTemplate.txt
                2. Restart the game.

                If this problem persist please report the following error to jaschutte on the runouw forum:

                ]]--[[..e)
        end
    elseif button == "ANIMATIONS" then --SETTINGS (yes finally)
        mod.LDSettings.ShowAnimations = not mod.LDSettings.ShowAnimations
        AnimControl(not mod.LDSettings.ShowAnimations)
    elseif button == "AUTOSAVE" then
        mod.LDSettings.SaveAfterClose = not mod.LDSettings.SaveAfterClose
    elseif button == "RESTORETEMPLATE" then
        love.filesystem.write("StarterTemplate.txt",'80x30~0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2T2Z0*2190*~b|r|1,32,800,0,0,Right|f~1~1~My%20Level')
    elseif button == "SAVEASTEMPLATE" then
        love.filesystem.write("StarterTemplate.txt",GenerateLevelCode())
    elseif button == "CREDITS" then
        self:OpenWindow(7)
    elseif button == "PLAYERVIEW" then
        self.LDSettings.ShowPlayerView = not self.LDSettings.ShowPlayerView
        if not love.filesystem.getInfo("ShowPlayerView.png") then
            local f = io.open("textures\\defaultViewer.png","rb")
            love.filesystem.write("ShowPlayerView.png",f:read("*a"))
            f:close()
        end
        playerViewer = love.graphics.newImage("ShowPlayerView.png")
    elseif button == "RESTORE" then
        self.LDSettings.ShowAnimations = true
        self.LDSettings.SaveAfterClose = true
        self.LDSettings.ShowPlayerView = true
        self.LDSettings.AutoSaveEvery = 300
        self.LDSettings.CameraSpeed = 1
        self.LevelConfig.Incement = 1
        self:OpenWindow(3)
    elseif button == "TPTOPLEFT" then --CAMERA CONTROLS
        camX,camY = 0, 0
    elseif button == "TPTOPRIGHT" then
        camX,camY = levelSizeX*32-windowX, 0
    elseif button == "TPBOTTEMLEFT" then
        camX,camY = 0, levelSizeY*32-windowY
    elseif button == "TPBOTTEMRIGHT" then
        camX,camY = levelSizeX*32-windowX, levelSizeY*32-windowY
    elseif button == "TPCENTER" then
        camX,camY = levelSizeX*16-windowX/2, levelSizeY*16-windowY/2
    elseif button == "MOD_NEXT" then --MOD SUPPORT
        modsPage = modsPage + 1
    elseif button == "MOD_PREVIOUS" then
        modsPage = math.max(modsPage-1,0)
        currentPointer = modsPage == 0 and math.max(currentPointer,3) or currentPointer
    elseif button == "MOD_DELETE" then
        if not (modsPage*10+currentPointer == 1 or modsPage*10+currentPointer == 2) then
            Mods[modsPage*10+currentPointer] = nil
            local temp = {}
            for k,v in pairs(Mods) do
                if k > modsPage*10+currentPointer then
                    temp[k-1] = v
                else
                    temp[k] = v
                end
            end
            Mods = temp
        end
    elseif button == "MOD_NEW" then
        if Mods[modsPage*10+currentPointer] then
            local temp = {}
            for k,v in pairs(Mods) do
                if k >= modsPage*10+currentPointer then
                    temp[k+1] = v
                else
                    temp[k] = v
                end
            end
            Mods = temp
            Mods[modsPage*10+currentPointer] = {"Please set an url. [no mod]","",false}
        else
            Mods[modsPage*10+currentPointer] = {"Please set an url. [no mod]","",false}
        end
    elseif button == "MOD_UP" then
        if modsPage == 0 then
            currentPointer = math.max(currentPointer-1,3)
        else
            currentPointer = math.max(currentPointer-1,1)
        end
    elseif button == "MOD_DOWN" then
        currentPointer = math.min(currentPointer+1,10)
    end
    self:SaveSettings()
end

function mod:OpenWindow(id) --opens windows
    if self.Dialog ~= nil then
        self.Dialog:Close()
        self.Dialog = nil
    end
    if id == 10 then
        local opt = {
            "Load mods and enable them.",
            "Load mods but don't enable them.",
            "Discard the mods. Current mod setup won't be changed."
        }
        local popup = wxLua.wxSingleChoiceDialog(wxLua.NULL,"This level code contains one or multiple mods. Would you like to:","Level contains mods!",opt)
        popup:SetBackgroundColour(dark)
        popup:ShowModal()
        local choice = popup:GetStringSelection()
        choice = opt[1] == choice and 1 or opt[2] == choice and 2 or 3
        if choice == 3 then
        elseif choice == 2 then
            for _,v in pairs(Mods) do
                for l,x in pairs(ModsFromCode) do
                    if v[2] == x then
                        ModsFromCode[l] = nil
                    end
                end
            end
            for _,v in pairs(ModsFromCode) do
                local og = v
                v = string.sub(v,0,-2)
                local name = string.match(v,"[^/]+$")
                local ext = string.match(v,"[^.]+$")
                if name and ext then
                    local final = name:gsub("."..ext,""):gsub("%u",function(s) return " "..s:lower() end):gsub("-"," "):gsub("_"," ")
                    table.insert(Mods,{final,og,false})
                end
            end
        else
            for id,v in pairs(Mods) do
                for l,x in pairs(ModsFromCode) do
                    if v[2] == x then
                        Mods[id][3] = true
                        ModsFromCode[l] = nil
                    end
                end
            end
            for _,v in pairs(ModsFromCode) do
                local og = v
                v = string.sub(v,0,-2)
                local name = string.match(v,"[^/]+$")
                local ext = string.match(v,"[^.]+$")
                if name and ext then
                    local final = name:gsub("."..ext,""):gsub("%u",function(s) return " "..s:lower() end):gsub("-"," "):gsub("_"," ")
                    table.insert(Mods,{final,og,true})
                end
            end
        end
        self:SaveSettings()
    elseif id == 9 then
        self.Width = 215
        self.Height = 195
        self.Dialog = wxLua.wxDialog(wxLua.NULL,wxLua.wxID_ANY,"Camera Settings",wxLua.wxDefaultPosition,wxLua.wxSize(self.Width,self.Height),wxLua.wxDEFAULT_DIALOG_STYLE)--,wxLua.wxCLOSE_BOX)
        self.Dialog:SetBackgroundColour(dark)
        self.MainLayer = wxLua.wxPanel(self.Dialog,wxLua.wxID_ANY,wxLua.wxDefaultPosition,wxLua.wxSize(self.Width,self.Height))
        --create grid for number only input
        self.Grid = wxLua.wxGrid(self.MainLayer,2,wxLua.wxPoint(0,0),wxLua.wxSize(self.Width,30))
        self.Grid:SetDefaultCellTextColour(white)
        self.Grid:SetDefaultCellBackgroundColour(dark)
        self.Grid:SetGridLineColour(darkGrey)
        self.Grid:SetColLabelSize(0)
        self.Grid:SetRowLabelSize(0)
        self.Grid:EnableDragGridSize(false)
        self.Grid:SetDefaultCellOverflow(false)
        self.Grid:CreateGrid(1,2)
        self.Grid:SetColSize(0,100)
        self.Grid:SetColSize(1,100)
        self.Grid:SetReadOnly(0,0)
        --actual input
        self.Grid:SetCellValue(0,0,"Camera Speed:")
        self.Grid:SetCellBackgroundColour(0,1,grey)
        self.Grid:SetCellValue(0,1,tostring(self.LDSettings.CameraSpeed))
        self.Grid:SetCellEditor(0,1,wxLua.wxGridCellFloatEditor(0,2))
        self.Grid:SetCellRenderer(0,1,wxLua.wxGridCellFloatRenderer(0,2))
        self.BgImage = wxLua.wxBitmapButton(self.MainLayer,1,wxLua.wxBitmap("textures/windowIcons/cameraPosition.png"),wxLua.wxPoint(20,50),wxLua.wxSize(100,100),wxLua.wxNO_BORDER)
        self.BgImage:SetBackgroundColour(dark)
        self.BgImage:SetForegroundColour(dark)
        --listeners
        self.Dialog:Connect(2,wxLua.wxEVT_GRID_CELL_CHANGE,function(ev)
            mod.LDSettings.CameraSpeed = self.Grid:GetCellValue(0,1)
            self:SaveSettings()
        end)
        self.Dialog:Connect(1,wxLua.wxEVT_COMMAND_BUTTON_CLICKED,function(ev)
            local mouse = wxLua.wxGetMousePosition()
            local x, y = self.Dialog:ScreenToClient(mouse):GetXY()
            camX,camY = 0, 0
            if x >= 55 and x <= 85 and y >= 75 and y <= 105 then
                --center
                camX, camY = levelSizeX*16-windowX/2, levelSizeY*16-windowY/2
                return
            end
            if x >= 60 then
                if y >= 90 then
                    camX, camY = levelSizeX*32-windowX, levelSizeY*32-windowY
                else
                    camX, camY = levelSizeX*32-windowX, 0
                end
            else
                if y >= 90 then
                    camX, camY = 0, levelSizeY*32-windowY
                else
                    camX, camY = 0, 0
                end
            end
        end)
        --show
        self.Dialog:Show()
    elseif id == 3 then
        self.Width = 415
        self.Height = 300
        self.Dialog = wxLua.wxDialog(wxLua.NULL,wxLua.wxID_ANY,"LD Settings",wxLua.wxDefaultPosition,wxLua.wxSize(self.Width,self.Height),wxLua.wxDEFAULT_DIALOG_STYLE)--,wxLua.wxCLOSE_BOX)
        self.Dialog:SetBackgroundColour(dark)
        self.MainLayer = wxLua.wxPanel(self.Dialog,wxLua.wxID_ANY,wxLua.wxDefaultPosition,wxLua.wxSize(self.Width,self.Height))
        --create grid
        self.Grid = wxLua.wxGrid(self.MainLayer,2,wxLua.wxPoint(0,0),wxLua.wxSize(self.Width,self.Height))
        self.Grid:SetDefaultCellTextColour(white)
        self.Grid:SetDefaultCellBackgroundColour(dark)
        self.Grid:SetGridLineColour(darkGrey)
        self.Grid:SetColLabelSize(0)
        self.Grid:SetRowLabelSize(0)
        self.Grid:EnableDragGridSize(false)
        self.Grid:SetDefaultCellOverflow(false)
        self.Grid:CreateGrid(9,2)
        self.Grid:SetColSize(0,165)
        self.Grid:SetColSize(1,235)
        for i = 0,8 do
            self.Grid:SetReadOnly(i,0)
            self.Grid:SetCellBackgroundColour(i,1,grey)
        end
        --fill setting names in the grid
        self.Grid:SetCellValue(0,0,"Show item animations?")
        self.Grid:SetCellValue(1,0,"Autosave when closing designer?")
        self.Grid:SetCellValue(2,0,"Autosave after every:")
        self.Grid:SetCellValue(3,0,"Enable player view radius?")
        self.Grid:SetCellValue(4,0,"Autosave folder location:")
        self.Grid:SetCellValue(5,0,"View credits?")
        self.Grid:SetCellValue(6,0,"Set current level as template?")
        self.Grid:SetCellValue(7,0,"Reset template?")
        self.Grid:SetCellValue(8,0,"Reset settings?")
        --fill settings
        self.Grid:SetCellValue(0,1,self.LDSettings.ShowAnimations and "1" or "0")
        self.Grid:SetCellEditor(0,1,wxLua.wxGridCellBoolEditor())
        self.Grid:SetCellRenderer(0,1,wxLua.wxGridCellBoolRenderer())
        self.Grid:SetCellValue(1,1,self.LDSettings.SaveAfterClose and "1" or "0")
        self.Grid:SetCellEditor(1,1,wxLua.wxGridCellBoolEditor())
        self.Grid:SetCellRenderer(1,1,wxLua.wxGridCellBoolRenderer())
        self.Grid:SetCellValue(2,1,tostring(self.LDSettings.AutoSaveEvery))
        self.Grid:SetCellEditor(2,1,wxLua.wxGridCellFloatEditor(0,2))
        self.Grid:SetCellRenderer(2,1,wxLua.wxGridCellFloatRenderer(0,2))
        self.Grid:SetCellBackgroundColour(2,1,grey)
        self.Grid:SetCellValue(3,1,self.LDSettings.ShowPlayerView and "1" or "0")
        self.Grid:SetCellEditor(3,1,wxLua.wxGridCellBoolEditor())
        self.Grid:SetCellRenderer(3,1,wxLua.wxGridCellBoolRenderer())
        self.Grid:SetCellValue(4,1,"%appdata%/SuperDesigner63/AutoSaveFolder")
        self.Grid:SetReadOnly(4,1)
        self.Grid:SetCellBackgroundColour(4,1,whitestGrey)
        self.Grid:SetCellValue(5,1,"0")
        self.Grid:SetCellEditor(5,1,wxLua.wxGridCellBoolEditor())
        self.Grid:SetCellRenderer(5,1,wxLua.wxGridCellBoolRenderer())
        self.Grid:SetCellValue(6,1,"0")
        self.Grid:SetCellEditor(6,1,wxLua.wxGridCellBoolEditor())
        self.Grid:SetCellRenderer(6,1,wxLua.wxGridCellBoolRenderer())
        self.Grid:SetCellValue(7,1,"0")
        self.Grid:SetCellEditor(7,1,wxLua.wxGridCellBoolEditor())
        self.Grid:SetCellRenderer(7,1,wxLua.wxGridCellBoolRenderer())
        self.Grid:SetCellValue(8,1,"0")
        self.Grid:SetCellEditor(8,1,wxLua.wxGridCellBoolEditor())
        self.Grid:SetCellRenderer(8,1,wxLua.wxGridCellBoolRenderer())
        --set settings
        self.Dialog:Connect(2,wxLua.wxEVT_GRID_CELL_CHANGE,function(ev)
            local row = ev:GetRow()
            local val = self.Grid:GetCellValue(row,1)
            if row > 4 then
                self.Grid:SetCellValue(row,1,"0")
            end
            if row == 0 then
                mod.LDSettings.ShowAnimations = val == "1"
                AnimControl(not mod.LDSettings.ShowAnimations)
            elseif row == 1 then
                mod.LDSettings.SaveAfterClose = val == "1"
            elseif row == 2 then
                mod.LDSettings.AutoSaveEvery = tonumber(val)
            elseif row == 7 then
                love.filesystem.write("StarterTemplate.txt",'80x30~0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2K2M0*28*2T2Z0*2190*~b|r|1,32,800,0,0,Right|f~1~1~My%20Level')
            elseif row == 6 then
                love.filesystem.write("StarterTemplate.txt",GenerateLevelCode())
            elseif row == 5 then
                self:SaveSettings()
                self:OpenWindow(7)
            elseif row == 3 then
                self.LDSettings.ShowPlayerView = val == "1"
                if not love.filesystem.getInfo("ShowPlayerView.png") then
                    local f = io.open("textures\\defaultViewer.png","rb")
                    love.filesystem.write("ShowPlayerView.png",f:read("*a"))
                    f:close()
                end
                playerViewer = love.graphics.newImage("ShowPlayerView.png")
            elseif row == 8 then
                self.LDSettings.ShowAnimations = true
                self.LDSettings.SaveAfterClose = true
                self.LDSettings.AutoSaveEvery = 300
                self.LevelConfig.Incement = 1
                self:SaveSettings()
                mod:OpenWindow(3)
            end
            self:SaveSettings()
        end)
        self.Dialog:Show()
    elseif id == 1 then
        self.Width = 415
        self.Height = 340
        --labels
        self.Dialog = wxLua.wxDialog(wxLua.NULL,wxLua.wxID_ANY,"Level Settings",wxLua.wxDefaultPosition,wxLua.wxSize(self.Width,self.Height),wxLua.wxDEFAULT_DIALOG_STYLE)--,wxLua.wxCLOSE_BOX)
        self.Dialog:SetBackgroundColour(dark)
        --[[self.Grid:SetDefaultCellTextColour(white)
        self.Grid:SetDefaultCellBackgroundColour(dark)
        self.Grid:SetGridLineColour(darkGrey)]]
        --[[self.MainLayer = wxLua.wxPanel(self.Dialog,wxLua.wxID_ANY,wxLua.wxDefaultPosition,wxLua.wxSize(self.Width,self.Height))
        self.PrevSong = wxLua.wxBitmapButton(self.MainLayer,4,backBitmap,wxLua.wxPoint(234,44),wxLua.wxSize(10,10),wxLua.wxNO_BORDER)
        self.NextSong = wxLua.wxBitmapButton(self.MainLayer,5,nextBitmap,wxLua.wxPoint(264,44),wxLua.wxSize(10,10),wxLua.wxNO_BORDER)
        self.ImageButton = wxLua.wxBitmapButton(self.MainLayer,6,gameBackgrounds[self.LevelConfig.BackgroundId] == nil and gameBackgrounds[15] or gameBackgrounds[self.LevelConfig.BackgroundId],wxLua.wxPoint(12,88),wxLua.wxSize(200,200),wxLua.wxNO_BORDER)
        self.Textfield = wxLua.wxTextCtrl(self.MainLayer,3,self.LevelConfig.Name,wxLua.wxPoint(12,41),wxLua.wxSize(120,20))
        self.PrevBg = wxLua.wxBitmapButton(self.MainLayer,7,backBitmap,wxLua.wxPoint(137,75),wxLua.wxSize(10,10),wxLua.wxNO_BORDER)
        self.NextBg = wxLua.wxBitmapButton(self.MainLayer,8,nextBitmap,wxLua.wxPoint(166,75),wxLua.wxSize(10,10),wxLua.wxNO_BORDER)
        self.Pause = wxLua.wxBitmapButton(self.MainLayer,9,pauseBitmap,wxLua.wxPoint(284,67),wxLua.wxSize(31,33),wxLua.wxNO_BORDER)
        self.Play = wxLua.wxBitmapButton(self.MainLayer,10,playBitmap,wxLua.wxPoint(233,67),wxLua.wxSize(31,33),wxLua.wxNO_BORDER)
        self.SongName = wxLua.wxStaticText(self.MainLayer,wxLua.wxID_ANY,"Level Music: "..songNames[self.LevelConfig.SongId],wxLua.wxPoint(233,27))
        self.SongName:SetForegroundColour(white)
        wxLua.wxStaticText(self.MainLayer,wxLua.wxID_ANY,"Level Name:",wxLua.wxPoint(11,27)):SetForegroundColour(white)
        wxLua.wxStaticText(self.MainLayer,wxLua.wxID_ANY,"Level Background:",wxLua.wxPoint(11,73)):SetForegroundColour(white)
        self.Pause:SetBackgroundColour(dark)
        self.Play:SetBackgroundColour(dark)
        self.NextBg:SetBackgroundColour(dark)
        self.PrevBg:SetBackgroundColour(dark)
        self.ImageButton:SetBackgroundColour(dark)
        self.PrevSong:SetBackgroundColour(dark)
        self.NextSong:SetBackgroundColour(dark)
        --response
        self.Dialog:Connect(3,wxLua.wxEVT_COMMAND_TEXT_UPDATED,function(ev)
            self.LevelConfig.Name = ev:GetString()
        end)
        self.Dialog:Connect(4,wxLua.wxEVT_COMMAND_BUTTON_CLICKED,function()
            self.LevelConfig.SongId = math.max(1,self.LevelConfig.SongId-1)
            self.SongName:SetLabel("Level Music: "..songNames[self.LevelConfig.SongId])
        end)
        self.Dialog:Connect(5,wxLua.wxEVT_COMMAND_BUTTON_CLICKED,function()
            self.LevelConfig.SongId = math.min(19,self.LevelConfig.SongId+1)
            self.SongName:SetLabel("Level Music: "..songNames[self.LevelConfig.SongId])
        end)
        self.Dialog:Connect(6,wxLua.wxEVT_COMMAND_BUTTON_CLICKED,function()
            local mouse = wxLua.wxGetMousePosition()
            local x = self.Dialog:ScreenToClient(mouse):GetXY()
            if x >= 112 then
                self.LevelConfig.BackgroundId = math.min(15,self.LevelConfig.BackgroundId+1)
                self.ImageButton:SetBitmapLabel(gameBackgrounds[self.LevelConfig.BackgroundId])
            else
                self.LevelConfig.BackgroundId = math.max(1,self.LevelConfig.BackgroundId-1)
                self.ImageButton:SetBitmapLabel(gameBackgrounds[self.LevelConfig.BackgroundId])
            end
        end)
        self.Dialog:Connect(7,wxLua.wxEVT_COMMAND_BUTTON_CLICKED,function()
            self.LevelConfig.BackgroundId = math.max(1,self.LevelConfig.BackgroundId-1)
            self.ImageButton:SetBitmapLabel(gameBackgrounds[self.LevelConfig.BackgroundId])
        end)
        self.Dialog:Connect(8,wxLua.wxEVT_COMMAND_BUTTON_CLICKED,function()
            self.LevelConfig.BackgroundId = math.min(15,self.LevelConfig.BackgroundId+1)
            self.ImageButton:SetBitmapLabel(gameBackgrounds[self.LevelConfig.BackgroundId])
        end)
        self.Dialog:Connect(9,wxLua.wxEVT_COMMAND_BUTTON_CLICKED,function()
            if gameSounds[self.LevelConfig.SongId] then
                gameSounds[self.LevelConfig.SongId]:pause()
            end
        end)
        self.Dialog:Connect(10,wxLua.wxEVT_COMMAND_BUTTON_CLICKED,function()
            for i = 1,18 do
                gameSounds[i]:stop()
            end
            if gameSounds[self.LevelConfig.SongId] then
                gameSounds[self.LevelConfig.SongId]:play()
            end
        end)
        self.Dialog:Show()
    else
        self.Width = (id == 5 or id == 4 or id == 2 or id == 9 or id == 10) and 200 or id == 6 and 100 or 400
        self.Height = (id == 5 or id == 4 or id == 2 or id == 9 or id == 10) and 150  or id == 6 and 75 or 300
        self.Id = id
        self.Img = self.Windows[id]
        self.CollisionMap = self.WindowCollision[id]
        mod.Dragged = false
        if self.Id == 1 then
            --[[self.Textboxes = {
                {mod.LevelConfig.Name,"txt",12,41,120,14,function(txt) mod.LevelConfig.Name = txt end}
            }--]]--[[
            self.Counters = {
                {280,55,"LevelConfig","SongName"}
            }
        elseif self.Id == 2 then
            self.Counters = {
                {62,30,"LevelConfig","Incement"},
                {104,133,"X"},
                {158,133,"Y"}
            }
        elseif self.Id == 3 then
            --[[self.Textboxes = {
                {tostring(mod.LDSettings.AutoSaveEvery),"num",145,217,40,14}
            }
            self.Textboxes[1][7] = function(n) 
                mod.LDSettings.AutoSaveEvery = math.max(n,20) 
                self.Textboxes[1][1] = tostring(math.max(n,20)) 
                local t = {}
                for k,v in pairs(mod.LDSettings) do
                    t[k] = v
                end
                t.Incement = mod.LevelConfig.Incement
                love.filesystem.write("Settings.json",jsonModule.encode(t))
            end--]]--[[
            self.Counters = {
                {160,56,"LDSettings","ShowAnimations"},
                {163,75,"LDSettings","ShowPlayerView"},
                {210,191,"LDSettings","SaveAfterClose"},
            }
        elseif self.Id == 9 then
            --[[self.Textboxes = {{tostring(mod.LDSettings.CameraSpeed),"num",90,65,40,14}}
            self.Textboxes[1][7] = function(n)
                mod.LDSettings.CameraSpeed = math.max(n,.2)
                self.Textboxes[1][1] = tostring(math.max(n,.2))
                local t = {}
                for k,v in pairs(mod.LDSettings) do
                    t[k] = v
                end
                t.Incement = mod.LevelConfig.Incement
                love.filesystem.write("Settings.json",jsonModule.encode(t))
            end--]]--[[
            self.Counters = {}
        else
            self.Counters = {}
        end
        self.Visible = true
    end
end

function mod:Draw()
    if self.Visible then
        --add more stuff to draw
        love.graphics.setColor(1,1,1)
        love.graphics.draw(self.Img,self.X,self.Y)
        if self.Id == 1 then
            if gameBackgrounds[self.LevelConfig.BackgroundId] == nil then
                love.graphics.draw(gameBackgrounds[15],self.X+12,self.Y+88,0,0.68965517241,0.68965517241)
            else
                love.graphics.draw(gameBackgrounds[self.LevelConfig.BackgroundId],self.X+12,self.Y+88,0,0.68965517241,0.68965517241)
            end
        end
        if self.Id ~= 8 then
            love.graphics.setColor(0,0,0)
            for _,v in pairs(self.Counters) do
                if v[3] ~= "X" and v[3] ~= "Y" then
                    love.graphics.print(tostring(mod[v[3]]--[[[v[4]]--),v[1]+self.X,v[2]+self.Y)
                --[[else
                    if v[3] == "X" then
                        love.graphics.print(levelSizeX,v[1]+self.X,v[2]+self.Y)
                    else
                        love.graphics.print(levelSizeY,v[1]+self.X,v[2]+self.Y)
                    end
                end
            end
            for _,v in pairs(self.Textboxes) do
                love.graphics.print(v[1],v[3]+self.X,v[4]+self.Y)
            end
        else --change the drawing settings for the mod tab since that require totally unique setting
            love.graphics.setColor(0,0,.8)
            love.graphics.rectangle("fill",self.X+4,self.Y+64+currentPointer*20,9,9)
            for i = 0,9 do
                love.graphics.setColor(.5,.5,.5)
                love.graphics.rectangle("fill",self.X+18,self.Y+81+i*20,365,18)
                local m = Mods[modsPage*10+i+1]
                if m then
                    love.graphics.setColor(0,0,0)
                    love.graphics.print(m[1],self.X+18,self.Y+83+i*20)
                    love.graphics.print("[GET] [SET]",self.X+195,self.Y+83+i*20)
                    love.graphics.print("["..string.upper(tostring(m[3])).."]",self.X+295,self.Y+83+i*20)
                else
                    love.graphics.setColor(.2,.2,.2)
                    love.graphics.print("Empty",self.X+18,self.Y+83+i*20)
                    love.graphics.print("None",self.X+195,self.Y+83+i*20)
                    love.graphics.print("None",self.X+295,self.Y+83+i*20)
                end
            end
        end
    end
end

return mod
--]]