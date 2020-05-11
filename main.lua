
_G.WindowX, _G.WindowY = love.window.getMode()
love.window.setTitle("Super Designer 63")
love.window.setMode(WindowX,WindowY,{resizable = true, minwidth=500, minheight=375, vsync = false})
love.graphics.setBackgroundColor(0,0,.5)

_G.__ID = 0
_G.CameraPosition = {X = 0, Y = 0, Z = 1} --Z is camera zoom; z<1 = zoomout; x>1 = zoomin
_G.Catagories = {
    ItemCatagories = {};
    TileCatagories = {};
}
_G.Textures = {
    MenuTextures = {};
    TileTextures = {};
    HUDTextures = {};
    RawTextures = {
        Cursors = {};
    };
}
_G.ClickAfterEvents = {}
_G.ClickBeforeEvents = {}
_G.GetId = function()
    __ID = __ID + 1
    return __ID
end
_G.Lerp = function(x,y,t)
    return (1-t)*x + t*y
end
_G.PrintTable = function(...)
    for _,t in pairs({...}) do
        local s = ""
        for k,v in pairs(t) do s = s..tostring(k)..": "..tostring(v).."\t" end
        if s ~= "" then
            print(s)
        end
    end
end
_G.ToolSettings = {
    CurrentDisplay = false;
    UIBlockingMouse = false;
    EraserMode = false;
    ItemTool = "normal";
    TileTool = "normal";
    SelectedTile = "2K";
    SelectedItem = "2";
    TileCatagory = 100;
    ItemCatagory = 0;
    MouseX = 0;
    MouseY = 0;
    MouseDown = false;
    Translation = {
        BeginX = 0;
        BeginY = 0;
        X = 0;
        Y = 0;
        Enabled = false;
    };
    TileRange = {
        StartX = 0;
        StartY = 0;
        EndX = 0;
        EndY = 0;
        Stage = 1; --1 = select start, 2 = select end, 3 = finish
    };
    ItemRange = {
        StartX = 0;
        StartY = 0;
        EndX = 0;
        EndY = 0;
        Stage = 1;
    };
}
_G.LD = {
    Level = {
        Size = {X = 0, Y = 0};
        Tiles = {};
        Items = {};
    };
    Settings = {
        CameraSpeed = 1;
        ScrollSpeed = 1;
        Mods = {};
        ToolHolder = {
            SizeX = 200;
            SizeY = WindowY;
            X = WindowX-210;
            Y = 0;
        }
    };
}

local graphics = require("loaders.graphics")
local menu = require("loaders.menu")
local threads = require("loaders.threading")
local tools = require("loaders.toolhandler")
local decoding = require("loaders.decode")
local DIR = tostring(io.popen("CD"):read())

function love.load()
    --load textures
    local dir = "textures/menuTexturesDark"
    for _,texture in pairs(love.filesystem.getDirectoryItems(dir)) do
        Textures.MenuTextures[texture:sub(1,-5)] = love.graphics.newImage(dir.."/"..texture)
    end
    local dir = "textures/HUD"
    for _,texture in pairs(love.filesystem.getDirectoryItems(dir)) do
        Textures.HUDTextures[texture:sub(1,-5)] = love.graphics.newImage(dir.."/"..texture)
    end
    --tile textures
    local dir = "textures/tiles"
    Textures.TileTextures["0"] = love.graphics.newImage("textures/airTile.png")
    for _,folder in ipairs(love.filesystem.getDirectoryItems(dir)) do
        local subDir = dir.."/"..folder
        Catagories.TileCatagories[tonumber(folder)] = {}
        for _,texture in ipairs(love.filesystem.getDirectoryItems(subDir)) do
            local group = tonumber(folder)
            if string.sub(texture,1,1) == "m" then
                local id = tonumber(texture:sub(2,-5))
                Textures.TileTextures[texture:sub(1,-5)] = love.graphics.newImage(subDir.."/"..texture)
                Catagories.TileCatagories[group][id] = texture:sub(1,-5)
            else
                local num = tonumber(texture:sub(1,-5))
                local id = string.char(math.floor((group+num)/75)+49)..string.char((group+num)-math.floor((group+num)/75)*75+49)
                Textures.TileTextures[id] = love.graphics.newImage(subDir.."/"..texture)
                Catagories.TileCatagories[group][num] = id
            end
        end
    end
    --cursor icons
    local dir = "textures/cursorIcons"
    for _,texture in pairs(love.filesystem.getDirectoryItems(dir)) do
        local x, y = 0, 0
        if texture == "bucket.png" or texture == "bucketRemove.png" then
            x, y = 5, 25
        elseif texture == "pencil.png" then
            x, y = 4, 27
        end
        Textures.RawTextures.Cursors[texture:sub(1,-5)] = love.mouse.newCursor(love.image.newImageData(dir.."/"..texture),x,y)
    end
    --themes
    local dir = "textures/themes/tiles"
    for _,texture in pairs(love.filesystem.getDirectoryItems(dir)) do
        Textures.MenuTextures["THEME/TILES/"..texture:sub(1,-5)] = love.graphics.newImage(dir.."/"..texture)
    end
    --setup default Level
    for x = 1,50 do
        LD.Level.Tiles[x] = {}
        for y = 1,30 do
            LD.Level.Tiles[x][y] = "0"
        end
    end
    LD.Level.Size = {X = 50, Y = 30}
    menu:InitMenu()
end

function love.resize(sx,sy)
    local dx, dy = sx-WindowX, sy-WindowY
    WindowX, WindowY = sx, sy
    LD.Settings.ToolHolder.SizeY = LD.Settings.ToolHolder.SizeY+dy
    LD.Settings.ToolHolder.X = LD.Settings.ToolHolder.X+dx
    --update menu
    menu.OnResize()
end

function love.mousereleased(mx,my,b)
    ToolSettings.MouseDown = false
    tools:MouseUp(b)
end

function love.mousepressed(mx,my,b)
    --afterclick
    for _,event in pairs(ClickBeforeEvents) do
        event(mx,my,b)
    end
    --update toolsettings
    ToolSettings.MouseDown = true
    tools:MouseDown(b)
    --OnClick events
    for i = #graphics.FramesOnZ,1,-1 do
        local frame = graphics.FramesOnZ[i]
        if frame then
            if frame.Visible and frame.Collision.OnClick then
                if frame:CheckCollision(mx,my) then
                    frame.Collision.OnClick(mx,my,b)
                    break
                end
            end
        else
            print("Warning: Id "..i.." is nil!")
        end
    end
    --afterclick
    for _,event in pairs(ClickAfterEvents) do
        event(mx,my,b)
    end
end

function love.wheelmoved(_,delta)
    local mx, my = love.mouse.getPosition()
    for _,frame in ipairs(graphics.FramesOnZ) do
        if frame.Visible and frame.Collision.OnScroll then
            local x,y, w,h = frame:ToScreenPixels()
            if mx > x and mx < x+w and my > y and my < y+h then
                frame.Collision.OnScroll(delta)
                break
            end
        end
    end
end

function love.mousemoved(mx,my)
    ToolSettings.MouseX, ToolSettings.MouseY = mx, my
    --frame collision detection
    local oldFrames = {}
    local block = false
    for id,frame in pairs(graphics.Frames) do
        if frame.Visible and frame.Collision.DetectHover and frame.Collision.IsBeingHovered then
            frame.Collision.IsBeingHovered = false
            oldFrames[id] = frame
        end
    end
    for i = #graphics.FramesOnZ,1,-1 do
        local frame = graphics.FramesOnZ[i]
        if frame then
            if frame.Visible and frame.Collision.DetectHover then
                if frame:CheckCollision(mx,my) then
                    frame.Collision.IsBeingHovered = true
                    if not oldFrames[frame.Id] then
                        frame.Collision.OnEnter(frame,mx,my)
                        block = true --check if ui is blocking tile grid
                    end
                    break
                end
            end
        else
            print("Warning: Id "..i.." is nil!")
        end
    end
    for _,frame in pairs(oldFrames) do
        if frame.Collision.OnLeave and not frame.Collision.IsBeingHovered then
            frame.Collision.OnLeave(frame,mx,my)
            ToolSettings.UIBlockingMouse = false
        end
    end
    ToolSettings.UIBlockingMouse = block or ToolSettings.UIBlockingMouse
    --
end

function love.textinput(key)
    if key == "-" then
        CameraPosition.Z = math.max(CameraPosition.Z - .2,.4)
    elseif key == "=" then
        CameraPosition.Z = math.min(CameraPosition.Z + .2,2)
    end
end

function love.update(dt)
    --camera
    local ch = 500*dt*LD.Settings.CameraSpeed
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        CameraPosition.Y = CameraPosition.Y + ch
    end
    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        CameraPosition.Y = CameraPosition.Y - ch
    end
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        CameraPosition.X = CameraPosition.X + ch
    end
    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        CameraPosition.X = CameraPosition.X - ch
    end
    --update modules
    tools:Update()
    graphics:UpdateMessages(dt)
    threads:OnFrame()
end

function love.draw()
    graphics:DrawTiles()
    graphics:DrawHovers()
    for _,frame in ipairs(graphics.FramesOnZ) do
        frame:Draw()
    end
    graphics:DrawMessages()
    --display framerate
    --love.graphics.print("FPS: "..love.timer.getFPS(),5,WindowY-20)
end
